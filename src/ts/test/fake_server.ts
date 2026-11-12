/** A fake ImandraX server behind a stubbed `fetch`, for offline tests */

import { vi } from "vitest";

import { Session as SessionType } from "../lib/raw/proto/session.js";
import { Empty as EmptyType } from "../lib/raw/proto/utils.js";
import type { MessageType } from "../lib/transport.js";

export interface Request {
  url: string;
  path: string;
  headers: Headers;
  body: Uint8Array;
}

export type Reply =
  | { status?: 200; message: Uint8Array; headers?: Record<string, string> }
  | { status: number; text: string; statusText?: string; headers?: Record<string, string> };

type Handler = (req: Request) => Reply | Promise<Reply>;

/** A Twirp JSON error reply */
export function twirpError(status: number, code: string, msg: string): Reply {
  return { status, text: JSON.stringify({ code, msg }) };
}

/** A protobuf reply */
export function ok<T>(type: MessageType<T>, message: T, headers?: Record<string, string>): Reply {
  return headers === undefined
    ? { message: type.encode(message).finish() }
    : { message: type.encode(message).finish(), headers };
}

export class FakeServer {
  readonly requests: Request[] = [];
  readonly #handlers = new Map<string, Handler>();

  constructor() {
    vi.stubGlobal("fetch", async (url: string, init: RequestInit) => {
      const signal = init.signal;
      signal?.throwIfAborted();
      const path = new URL(url).pathname;
      const req: Request = {
        url,
        path,
        headers: new Headers(init.headers),
        body: init.body as Uint8Array,
      };
      this.requests.push(req);
      const method = path.split("/").slice(-2).join("/");
      const handler = this.#handlers.get(method);
      if (handler === undefined) {
        return new Response(JSON.stringify({ code: "bad_route", msg: `no route ${method}` }), {
          status: 404,
        });
      }
      const reply = await abortable(handler(req), signal);
      const headers = new Headers(reply.headers);
      if ("message" in reply) {
        return new Response(reply.message, { status: 200, headers });
      }
      return new Response(reply.text, {
        status: reply.status,
        statusText: reply.statusText ?? "",
        headers,
      });
    });
  }

  /** Answer `service/method` (e.g. `imandrax.simple.Simple/status`) with `handler` */
  on(method: string, handler: Handler): this {
    this.#handlers.set(method, handler);
    return this;
  }

  /** Answer session creation and ending */
  withSessions(id = "sesh-1"): this {
    return this.on("imandrax.simple.Simple/create_session", () =>
      ok(SessionType, { id }),
    ).on("imandrax.simple.Simple/end_session", () => ok(EmptyType, {}));
  }

  /** The requests to `service/method` */
  calls(method: string): Request[] {
    return this.requests.filter((r) => r.path.endsWith(`/${method}`));
  }

  /** The body of the only request to `service/method`, decoded as `type` */
  body<T>(method: string, type: MessageType<T>): T {
    const calls = this.calls(method);
    if (calls.length !== 1) throw new Error(`expected one call to ${method}, got ${calls.length}`);
    return type.decode(calls[0]!.body);
  }
}

async function abortable<T>(p: T | Promise<T>, signal: AbortSignal | null | undefined): Promise<T> {
  if (!signal) return p;
  return await new Promise<T>((resolve, reject) => {
    signal.addEventListener("abort", () => reject(signal.reason), { once: true });
    Promise.resolve(p).then(resolve, reject);
  });
}
