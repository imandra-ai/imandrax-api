import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";

import {
  ApiVersionMismatchError,
  Client,
  ClientClosedError,
  EndSessionError,
  ServerError,
  TwirpError,
  decomp,
  taskOfRaw,
  urlProd,
} from "../lib/index.js";
import * as apiPb from "../lib/raw/proto/api.js";
import * as sessionPb from "../lib/raw/proto/session.js";
import * as simplePb from "../lib/raw/proto/simple_api.js";
import * as systemPb from "../lib/raw/proto/system.js";
import * as taskPb from "../lib/raw/proto/task.js";
import * as utilsPb from "../lib/raw/proto/utils.js";
import { version } from "../lib/version.js";
import { FakeServer, ok, twirpError } from "./fake_server.js";

let server: FakeServer;

beforeEach(() => {
  server = new FakeServer();
});

afterEach(() => {
  vi.unstubAllGlobals();
});

const SIMPLE = "imandrax.simple.Simple";

describe("connect", () => {
  test("creates a session, with auth and version headers", async () => {
    server.withSessions("s1");
    const c = await Client.connect({ apiKey: "key", authToken: "token" });
    expect(c.sessionId).toBe("s1");

    const [req] = server.calls(`${SIMPLE}/create_session`);
    // concatenated as the Python client does
    expect(req!.url).toBe(`${urlProd}/api/v1/${SIMPLE}/create_session`);
    expect(req!.headers.get("content-type")).toBe("application/protobuf");
    expect(req!.headers.get("x-api-version")).toBe(version);
    // `apiKey` wins over `authToken`
    expect(req!.headers.get("authorization")).toBe("Bearer key");
    expect(server.body(`${SIMPLE}/create_session`, simplePb.SessionCreateReq)).toEqual({
      apiVersion: version,
    });
  });

  test("uses authToken without apiKey, and the given url and prefix", async () => {
    server.withSessions();
    await Client.connect({ url: "http://localhost:1234", serverPathPrefix: "/x", authToken: "t" });
    const [req] = server.calls(`${SIMPLE}/create_session`);
    expect(req!.url).toBe(`http://localhost:1234/x/${SIMPLE}/create_session`);
    expect(req!.headers.get("authorization")).toBe("Bearer t");
  });

  test("sends no authorization header without credentials", async () => {
    server.withSessions();
    await Client.connect();
    expect(server.requests[0]!.headers.has("authorization")).toBe(false);
  });

  test("an invalid_argument on create_session is an API version mismatch", async () => {
    server.on(`${SIMPLE}/create_session`, () => twirpError(400, "invalid_argument", "bad version"));
    const err = await Client.connect().catch((e: unknown) => e);
    expect(err).toBeInstanceOf(ApiVersionMismatchError);
    expect((err as Error).cause).toBeInstanceOf(TwirpError);
  });

  test("reopens a session", async () => {
    server.on("imandrax.session.SessionManager/open_session", () => ok(utilsPb.Empty, {}));
    const c = await Client.connect({ sessionId: "old" });
    expect(c.sessionId).toBe("old");
    expect(server.body("imandrax.session.SessionManager/open_session", sessionPb.SessionOpen)).toEqual({
      id: { id: "old" },
      apiVersion: version,
    });
    expect(server.calls(`${SIMPLE}/create_session`)).toHaveLength(0);
  });

  test("a missing session is recreated only with createIfNotFound", async () => {
    server
      .withSessions("new")
      .on("imandrax.session.SessionManager/open_session", () =>
        twirpError(500, "internal", "Unknown session old"),
      );
    await expect(Client.connect({ sessionId: "old" })).rejects.toBeInstanceOf(TwirpError);
    const c = await Client.connect({ sessionId: "old", createIfNotFound: true });
    expect(c.sessionId).toBe("new");
  });

  test("other open_session errors are not recreated", async () => {
    server
      .withSessions("new")
      .on("imandrax.session.SessionManager/open_session", () =>
        twirpError(403, "permission_denied", "no"),
      );
    await expect(
      Client.connect({ sessionId: "old", createIfNotFound: true }),
    ).rejects.toMatchObject({ code: "permission_denied" });
  });
});

describe("close", () => {
  test("ends the session once; later calls throw ClientClosedError", async () => {
    server.withSessions("s1");
    const c = await Client.connect();
    await c.close();
    await c.close();
    expect(server.body(`${SIMPLE}/end_session`, sessionPb.Session)).toEqual({ id: "s1" });
    expect(c.closed).toBe(true);
    await expect(c.status()).rejects.toBeInstanceOf(ClientClosedError);
  });

  test("a failure to end the session is an EndSessionError, and the client is closed", async () => {
    server
      .withSessions("s1")
      .on(`${SIMPLE}/end_session`, () => twirpError(500, "internal", "boom"));
    const c = await Client.connect();
    const err = await c.close().catch((e: unknown) => e);
    expect(err).toBeInstanceOf(EndSessionError);
    expect((err as EndSessionError).sessionId).toBe("s1");
    expect(c.closed).toBe(true);
  });

  test("await using ends the session, keeping the body's error", async () => {
    server
      .withSessions("s1")
      .on(`${SIMPLE}/end_session`, () => twirpError(500, "internal", "boom"));
    const body = new Error("body failed");
    const err = await (async () => {
      await using _c = await Client.connect();
      throw body;
    })().catch((e: unknown) => e);
    // the body's error, with the failure to end the session attached
    expect(err).toBeInstanceOf(SuppressedError);
    expect((err as SuppressedError).suppressed).toBe(body);
    expect((err as SuppressedError).error).toBeInstanceOf(EndSessionError);
  });
});

describe("transport", () => {
  test("maps Twirp JSON errors", async () => {
    server.withSessions().on(`${SIMPLE}/status`, () => twirpError(404, "not_found", "nope"));
    const c = await Client.connect();
    const err = (await c.status().catch((e: unknown) => e)) as TwirpError;
    expect(err).toBeInstanceOf(TwirpError);
    expect([err.code, err.msg, err.status]).toEqual(["not_found", "nope", 404]);
  });

  test("maps errors from intermediaries", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/status`, () => ({ status: 503, text: "<html>down</html>", statusText: "Unavailable" }));
    const c = await Client.connect();
    const err = (await c.status().catch((e: unknown) => e)) as TwirpError;
    expect(err.code).toBe("unavailable");
    expect(err.status).toBe(503);
    expect(err.meta).toMatchObject({
      http_error_from_intermediary: "true",
      status_code: "503",
      body: "<html>down</html>",
    });
  });

  test("a timeout is deadline_exceeded", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/status`, () => new Promise(() => {}));
    const c = await Client.connect();
    await expect(c.status({ timeoutMs: 20 })).rejects.toMatchObject({ code: "deadline_exceeded" });
  });

  test("the client's timeoutMs applies to calls without their own", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/status`, () => new Promise(() => {}));
    const c = await Client.connect({ timeoutMs: 20 });
    await expect(c.status()).rejects.toMatchObject({ code: "deadline_exceeded" });
  });

  test("an abort rejects with the signal's reason", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/status`, () => new Promise(() => {}));
    const c = await Client.connect();
    const ac = new AbortController();
    const reason = new Error("stop");
    const p = c.status({ signal: ac.signal });
    ac.abort(reason);
    await expect(p).rejects.toBe(reason);
  });

  test("a network failure is unavailable", async () => {
    server.withSessions();
    const c = await Client.connect();
    vi.stubGlobal("fetch", async () => {
      throw new TypeError("fetch failed");
    });
    await expect(c.status()).rejects.toMatchObject({ code: "unavailable" });
  });

  test("sends back cookies the server set", async () => {
    server
      .on(`${SIMPLE}/create_session`, () =>
        ok(sessionPb.Session, { id: "s" }, { "set-cookie": "affinity=abc; Path=/; HttpOnly" }),
      )
      .on(`${SIMPLE}/status`, () => ok(utilsPb.StringMsg, { msg: "ok" }));
    const c = await Client.connect();
    expect(await c.status()).toBe("ok");
    expect(server.calls(`${SIMPLE}/status`)[0]!.headers.get("cookie")).toBe("affinity=abc");
  });
});

describe("requests", () => {
  test("evalSrc leaves unset options unset", async () => {
    server.withSessions("s").on(`${SIMPLE}/eval_src`, () => ok(simplePb.EvalRes, simplePb.EvalRes.fromPartial({})));
    const c = await Client.connect();
    await c.evalSrc("let x = 1");
    expect(server.body(`${SIMPLE}/eval_src`, simplePb.EvalSrcReq)).toEqual({
      session: { id: "s" },
      src: "let x = 1",
      asyncOnly: undefined,
      taskFilter: [],
    });
  });

  test("evalSrc sends its options", async () => {
    server.withSessions("s").on(`${SIMPLE}/eval_src`, () => ok(simplePb.EvalRes, simplePb.EvalRes.fromPartial({})));
    const c = await Client.connect();
    await c.evalSrc("x", { asyncOnly: false, taskFilter: ["*f*"] });
    expect(server.body(`${SIMPLE}/eval_src`, simplePb.EvalSrcReq)).toMatchObject({
      asyncOnly: false,
      taskFilter: ["*f*"],
    });
  });

  test("decompose sends its options", async () => {
    server
      .withSessions("s")
      .on(`${SIMPLE}/decompose`, () => ok(simplePb.DecomposeRes, simplePb.DecomposeRes.fromPartial({})));
    const c = await Client.connect();
    const res = await c.decompose("f", {
      assuming: "g",
      basis: ["h"],
      ruleSpecs: ["r"],
      prune: true,
      ctxSimp: false,
      liftBool: "nestedEqualities",
      stringResults: true,
      computeTimeout: 5,
    });
    expect(res.success).toBe(false);
    expect(server.body(`${SIMPLE}/decompose`, simplePb.DecomposeReq)).toEqual({
      session: { id: "s" },
      name: "f",
      assuming: "g",
      basis: ["h"],
      ruleSpecs: ["r"],
      prune: true,
      ctxSimp: false,
      liftBool: simplePb.LiftBool.NestedEqualities,
      stringResults: true,
      timeout: 5,
    });
  });

  test("decomposeFull sends the request tree", async () => {
    server
      .withSessions("s")
      .on(`${SIMPLE}/decompose_full`, () => ok(simplePb.DecomposeRes, simplePb.DecomposeRes.fromPartial({})));
    const c = await Client.connect();
    const d = decomp.let_(
      [["base", decomp.byName("f", { prune: true, liftBool: "all" })]],
      decomp.merge(decomp.prune(decomp.get("base")), decomp.combine(decomp.compoundMerge(decomp.get("base"), decomp.byName("g")))),
    );
    await c.decomposeFull(d, { computeTimeout: 3 });
    const req = server.body(`${SIMPLE}/decompose_full`, simplePb.DecomposeReqFull);
    expect(req.timeout).toBe(3);
    expect(req.decomp).toEqual(d);
    expect(req.decomp?.set?.bindings[0]?.d?.byName).toMatchObject({
      name: "f",
      prune: true,
      liftBool: simplePb.LiftBool.All,
      ctxSimp: undefined,
    });
  });

  test("test, verify and instance requests", async () => {
    server
      .withSessions("s")
      .on(`${SIMPLE}/test_src`, () => ok(simplePb.TestRes, simplePb.TestRes.fromPartial({})))
      .on(`${SIMPLE}/verify_name`, () => ok(simplePb.VerifyRes, simplePb.VerifyRes.fromPartial({})))
      .on(`${SIMPLE}/instance_src`, () => ok(simplePb.InstanceRes, simplePb.InstanceRes.fromPartial({})));
    const c = await Client.connect();
    await c.testSrc("fun x -> x > 0", { seed: 7 });
    await c.verifyName("p", { hints: "[@@by auto]" });
    await c.instanceSrc("fun x -> x > 0");
    expect(server.body(`${SIMPLE}/test_src`, simplePb.TestSrcReq)).toEqual({
      session: { id: "s" },
      src: "fun x -> x > 0",
      seed: 7,
    });
    expect(server.body(`${SIMPLE}/verify_name`, simplePb.VerifyNameReq)).toEqual({
      session: { id: "s" },
      name: "p",
      hints: "[@@by auto]",
    });
    expect(server.body(`${SIMPLE}/instance_src`, simplePb.InstanceSrcReq).hints).toBeUndefined();
  });

  test("oneshot is sessionless", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/oneshot`, () =>
        ok(simplePb.OneshotRes, simplePb.OneshotRes.fromPartial({ results: ["r"], stats: { time: 1.5 } })),
      );
    const c = await Client.connect();
    const res = await c.oneshot("1 + 1", { computeTimeout: 2.5 });
    expect([res.results, res.timeS]).toEqual([["r"], 1.5]);
    expect(server.body(`${SIMPLE}/oneshot`, simplePb.OneshotReq)).toEqual({ input: "1 + 1", timeout: 2.5 });
  });

  test("typecheck decodes the types from JSON", async () => {
    server
      .withSessions()
      .on(`${SIMPLE}/typecheck`, () =>
        ok(simplePb.TypecheckRes, simplePb.TypecheckRes.fromPartial({ success: true, types: '[{"name":"f"}]' })),
      );
    const c = await Client.connect();
    const res = await c.typecheck("let f x = x");
    expect(res.success).toBe(true);
    expect(res.types).toEqual([{ name: "f" }]);
  });

  test("version", async () => {
    server
      .withSessions()
      .on("imandrax.system.System/version", () => ok(systemPb.VersionResponse, { version: "1.2" }));
    const c = await Client.connect();
    const v = await c.version();
    expect([v.version, v.gitVersion]).toEqual(["1.2", undefined]);
  });

  test("keepSessionAlive sends the session", async () => {
    server
      .withSessions("s")
      .on("imandrax.session.SessionManager/keep_session_alive", () => ok(utilsPb.Empty, {}));
    const c = await Client.connect();
    await c.keepSessionAlive();
    expect(server.body("imandrax.session.SessionManager/keep_session_alive", sessionPb.Session)).toEqual({
      id: "s",
    });
  });

  test("artifact errors are ServerErrors", async () => {
    server
      .withSessions()
      .on("imandrax.api.Eval/get_artifact", () =>
        ok(apiPb.ArtifactResult, {
          error: { kind: '{ Kind.name = "NotFound" }', msg: { msg: "no such artifact", locs: [] }, stack: [] },
        }),
      )
      .on("imandrax.api.Eval/list_artifacts", () => ok(apiPb.ArtifactListResult, { ok: { kinds: ["po_task", "po_res"] } }));
    const c = await Client.connect();
    const task = taskOfRaw({ id: { id: "t1" }, kind: taskPb.TaskKind.TASK_CHECK_PO }, c);
    expect(await c.listArtifacts(task)).toEqual(["po_task", "po_res"]);
    const err = (await c.getArtifact(task, "po_task").catch((e: unknown) => e)) as ServerError;
    expect(err).toBeInstanceOf(ServerError);
    expect(String(err.error)).toBe("NotFound: no such artifact");
    expect(server.body("imandrax.api.Eval/get_artifact", apiPb.ArtifactGetQuery)).toEqual({
      taskId: { id: "t1" },
      kind: "po_task",
    });
  });
});
