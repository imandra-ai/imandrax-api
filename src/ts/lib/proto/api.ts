// Code generated by protoc-gen-ts_proto. DO NOT EDIT.
// versions:
//   protoc-gen-ts_proto  v2.7.5
//   protoc               v5.29.4
// source: api.proto

/* eslint-disable */
import { BinaryReader, BinaryWriter } from "@bufbuild/protobuf/wire";
import { Art } from "./artmsg.js";
import { Error } from "./error.js";
import { Session } from "./session.js";
import { Task, TaskID } from "./task.js";

export const protobufPackage = "imandrax.api";

export enum EvalResult {
  EVAL_OK = 0,
  EVAL_ERRORS = 1,
  UNRECOGNIZED = -1,
}

export function evalResultFromJSON(object: any): EvalResult {
  switch (object) {
    case 0:
    case "EVAL_OK":
      return EvalResult.EVAL_OK;
    case 1:
    case "EVAL_ERRORS":
      return EvalResult.EVAL_ERRORS;
    case -1:
    case "UNRECOGNIZED":
    default:
      return EvalResult.UNRECOGNIZED;
  }
}

export function evalResultToJSON(object: EvalResult): string {
  switch (object) {
    case EvalResult.EVAL_OK:
      return "EVAL_OK";
    case EvalResult.EVAL_ERRORS:
      return "EVAL_ERRORS";
    case EvalResult.UNRECOGNIZED:
    default:
      return "UNRECOGNIZED";
  }
}

export interface CodeSnippet {
  session:
    | Session
    | undefined;
  /** / Code snippet. */
  code: string;
}

export interface CodeSnippetEvalResult {
  /** Result of the evaluation */
  res: EvalResult;
  /** / Duration in seconds. */
  durationS: number;
  /** Tasks produced in the evaluation. */
  tasks: Task[];
  /** Errors occurring during evaluation. */
  errors: Error[];
}

export interface ParseQuery {
  /** string to parse */
  code: string;
}

export interface ArtifactListQuery {
  /** the task from which to list the artifacts */
  taskId: TaskID | undefined;
}

export interface ArtifactListResult {
  /** the kinds of artifacts available for this task */
  kinds: string[];
}

export interface ArtifactGetQuery {
  /** the task from which the artifact comes from */
  taskId:
    | TaskID
    | undefined;
  /** the kind of artifact we want */
  kind: string;
}

export interface Artifact {
  /** requested artifact */
  art: Art | undefined;
}

export interface ArtifactZip {
  /** requested artifact as a .zip file */
  artZip: Uint8Array;
}

function createBaseCodeSnippet(): CodeSnippet {
  return { session: undefined, code: "" };
}

export const CodeSnippet: MessageFns<CodeSnippet> = {
  encode(message: CodeSnippet, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.session !== undefined) {
      Session.encode(message.session, writer.uint32(10).fork()).join();
    }
    if (message.code !== "") {
      writer.uint32(18).string(message.code);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): CodeSnippet {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseCodeSnippet();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.session = Session.decode(reader, reader.uint32());
          continue;
        }
        case 2: {
          if (tag !== 18) {
            break;
          }

          message.code = reader.string();
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): CodeSnippet {
    return {
      session: isSet(object.session) ? Session.fromJSON(object.session) : undefined,
      code: isSet(object.code) ? globalThis.String(object.code) : "",
    };
  },

  toJSON(message: CodeSnippet): unknown {
    const obj: any = {};
    if (message.session !== undefined) {
      obj.session = Session.toJSON(message.session);
    }
    if (message.code !== "") {
      obj.code = message.code;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<CodeSnippet>, I>>(base?: I): CodeSnippet {
    return CodeSnippet.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<CodeSnippet>, I>>(object: I): CodeSnippet {
    const message = createBaseCodeSnippet();
    message.session = (object.session !== undefined && object.session !== null)
      ? Session.fromPartial(object.session)
      : undefined;
    message.code = object.code ?? "";
    return message;
  },
};

function createBaseCodeSnippetEvalResult(): CodeSnippetEvalResult {
  return { res: 0, durationS: 0, tasks: [], errors: [] };
}

export const CodeSnippetEvalResult: MessageFns<CodeSnippetEvalResult> = {
  encode(message: CodeSnippetEvalResult, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.res !== 0) {
      writer.uint32(8).int32(message.res);
    }
    if (message.durationS !== 0) {
      writer.uint32(29).float(message.durationS);
    }
    for (const v of message.tasks) {
      Task.encode(v!, writer.uint32(74).fork()).join();
    }
    for (const v of message.errors) {
      Error.encode(v!, writer.uint32(82).fork()).join();
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): CodeSnippetEvalResult {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseCodeSnippetEvalResult();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 8) {
            break;
          }

          message.res = reader.int32() as any;
          continue;
        }
        case 3: {
          if (tag !== 29) {
            break;
          }

          message.durationS = reader.float();
          continue;
        }
        case 9: {
          if (tag !== 74) {
            break;
          }

          message.tasks.push(Task.decode(reader, reader.uint32()));
          continue;
        }
        case 10: {
          if (tag !== 82) {
            break;
          }

          message.errors.push(Error.decode(reader, reader.uint32()));
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): CodeSnippetEvalResult {
    return {
      res: isSet(object.res) ? evalResultFromJSON(object.res) : 0,
      durationS: isSet(object.durationS) ? globalThis.Number(object.durationS) : 0,
      tasks: globalThis.Array.isArray(object?.tasks) ? object.tasks.map((e: any) => Task.fromJSON(e)) : [],
      errors: globalThis.Array.isArray(object?.errors) ? object.errors.map((e: any) => Error.fromJSON(e)) : [],
    };
  },

  toJSON(message: CodeSnippetEvalResult): unknown {
    const obj: any = {};
    if (message.res !== 0) {
      obj.res = evalResultToJSON(message.res);
    }
    if (message.durationS !== 0) {
      obj.durationS = message.durationS;
    }
    if (message.tasks?.length) {
      obj.tasks = message.tasks.map((e) => Task.toJSON(e));
    }
    if (message.errors?.length) {
      obj.errors = message.errors.map((e) => Error.toJSON(e));
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<CodeSnippetEvalResult>, I>>(base?: I): CodeSnippetEvalResult {
    return CodeSnippetEvalResult.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<CodeSnippetEvalResult>, I>>(object: I): CodeSnippetEvalResult {
    const message = createBaseCodeSnippetEvalResult();
    message.res = object.res ?? 0;
    message.durationS = object.durationS ?? 0;
    message.tasks = object.tasks?.map((e) => Task.fromPartial(e)) || [];
    message.errors = object.errors?.map((e) => Error.fromPartial(e)) || [];
    return message;
  },
};

function createBaseParseQuery(): ParseQuery {
  return { code: "" };
}

export const ParseQuery: MessageFns<ParseQuery> = {
  encode(message: ParseQuery, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.code !== "") {
      writer.uint32(10).string(message.code);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): ParseQuery {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseParseQuery();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.code = reader.string();
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): ParseQuery {
    return { code: isSet(object.code) ? globalThis.String(object.code) : "" };
  },

  toJSON(message: ParseQuery): unknown {
    const obj: any = {};
    if (message.code !== "") {
      obj.code = message.code;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<ParseQuery>, I>>(base?: I): ParseQuery {
    return ParseQuery.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<ParseQuery>, I>>(object: I): ParseQuery {
    const message = createBaseParseQuery();
    message.code = object.code ?? "";
    return message;
  },
};

function createBaseArtifactListQuery(): ArtifactListQuery {
  return { taskId: undefined };
}

export const ArtifactListQuery: MessageFns<ArtifactListQuery> = {
  encode(message: ArtifactListQuery, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.taskId !== undefined) {
      TaskID.encode(message.taskId, writer.uint32(10).fork()).join();
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): ArtifactListQuery {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseArtifactListQuery();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.taskId = TaskID.decode(reader, reader.uint32());
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): ArtifactListQuery {
    return { taskId: isSet(object.taskId) ? TaskID.fromJSON(object.taskId) : undefined };
  },

  toJSON(message: ArtifactListQuery): unknown {
    const obj: any = {};
    if (message.taskId !== undefined) {
      obj.taskId = TaskID.toJSON(message.taskId);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<ArtifactListQuery>, I>>(base?: I): ArtifactListQuery {
    return ArtifactListQuery.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<ArtifactListQuery>, I>>(object: I): ArtifactListQuery {
    const message = createBaseArtifactListQuery();
    message.taskId = (object.taskId !== undefined && object.taskId !== null)
      ? TaskID.fromPartial(object.taskId)
      : undefined;
    return message;
  },
};

function createBaseArtifactListResult(): ArtifactListResult {
  return { kinds: [] };
}

export const ArtifactListResult: MessageFns<ArtifactListResult> = {
  encode(message: ArtifactListResult, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    for (const v of message.kinds) {
      writer.uint32(10).string(v!);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): ArtifactListResult {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseArtifactListResult();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.kinds.push(reader.string());
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): ArtifactListResult {
    return { kinds: globalThis.Array.isArray(object?.kinds) ? object.kinds.map((e: any) => globalThis.String(e)) : [] };
  },

  toJSON(message: ArtifactListResult): unknown {
    const obj: any = {};
    if (message.kinds?.length) {
      obj.kinds = message.kinds;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<ArtifactListResult>, I>>(base?: I): ArtifactListResult {
    return ArtifactListResult.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<ArtifactListResult>, I>>(object: I): ArtifactListResult {
    const message = createBaseArtifactListResult();
    message.kinds = object.kinds?.map((e) => e) || [];
    return message;
  },
};

function createBaseArtifactGetQuery(): ArtifactGetQuery {
  return { taskId: undefined, kind: "" };
}

export const ArtifactGetQuery: MessageFns<ArtifactGetQuery> = {
  encode(message: ArtifactGetQuery, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.taskId !== undefined) {
      TaskID.encode(message.taskId, writer.uint32(10).fork()).join();
    }
    if (message.kind !== "") {
      writer.uint32(18).string(message.kind);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): ArtifactGetQuery {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseArtifactGetQuery();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.taskId = TaskID.decode(reader, reader.uint32());
          continue;
        }
        case 2: {
          if (tag !== 18) {
            break;
          }

          message.kind = reader.string();
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): ArtifactGetQuery {
    return {
      taskId: isSet(object.taskId) ? TaskID.fromJSON(object.taskId) : undefined,
      kind: isSet(object.kind) ? globalThis.String(object.kind) : "",
    };
  },

  toJSON(message: ArtifactGetQuery): unknown {
    const obj: any = {};
    if (message.taskId !== undefined) {
      obj.taskId = TaskID.toJSON(message.taskId);
    }
    if (message.kind !== "") {
      obj.kind = message.kind;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<ArtifactGetQuery>, I>>(base?: I): ArtifactGetQuery {
    return ArtifactGetQuery.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<ArtifactGetQuery>, I>>(object: I): ArtifactGetQuery {
    const message = createBaseArtifactGetQuery();
    message.taskId = (object.taskId !== undefined && object.taskId !== null)
      ? TaskID.fromPartial(object.taskId)
      : undefined;
    message.kind = object.kind ?? "";
    return message;
  },
};

function createBaseArtifact(): Artifact {
  return { art: undefined };
}

export const Artifact: MessageFns<Artifact> = {
  encode(message: Artifact, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.art !== undefined) {
      Art.encode(message.art, writer.uint32(10).fork()).join();
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): Artifact {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseArtifact();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.art = Art.decode(reader, reader.uint32());
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): Artifact {
    return { art: isSet(object.art) ? Art.fromJSON(object.art) : undefined };
  },

  toJSON(message: Artifact): unknown {
    const obj: any = {};
    if (message.art !== undefined) {
      obj.art = Art.toJSON(message.art);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Artifact>, I>>(base?: I): Artifact {
    return Artifact.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Artifact>, I>>(object: I): Artifact {
    const message = createBaseArtifact();
    message.art = (object.art !== undefined && object.art !== null) ? Art.fromPartial(object.art) : undefined;
    return message;
  },
};

function createBaseArtifactZip(): ArtifactZip {
  return { artZip: new Uint8Array(0) };
}

export const ArtifactZip: MessageFns<ArtifactZip> = {
  encode(message: ArtifactZip, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.artZip.length !== 0) {
      writer.uint32(10).bytes(message.artZip);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): ArtifactZip {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    const end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseArtifactZip();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.artZip = reader.bytes();
          continue;
        }
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skip(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): ArtifactZip {
    return { artZip: isSet(object.artZip) ? bytesFromBase64(object.artZip) : new Uint8Array(0) };
  },

  toJSON(message: ArtifactZip): unknown {
    const obj: any = {};
    if (message.artZip.length !== 0) {
      obj.artZip = base64FromBytes(message.artZip);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<ArtifactZip>, I>>(base?: I): ArtifactZip {
    return ArtifactZip.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<ArtifactZip>, I>>(object: I): ArtifactZip {
    const message = createBaseArtifactZip();
    message.artZip = object.artZip ?? new Uint8Array(0);
    return message;
  },
};

export interface Eval {
  /** / Evaluate a snippet */
  eval_code_snippet(request: CodeSnippet): Promise<CodeSnippetEvalResult>;
  /** parse+typecheck a term, return it as artifact */
  parse_term(request: CodeSnippet): Promise<Artifact>;
  /** parse+typecheck a type, return it as artifact */
  parse_type(request: CodeSnippet): Promise<Artifact>;
  list_artifacts(request: ArtifactListQuery): Promise<ArtifactListResult>;
  /** Obtain an artifact from a task */
  get_artifact(request: ArtifactGetQuery): Promise<Artifact>;
  /** Obtain an artifact from a task as a zip file */
  get_artifact_zip(request: ArtifactGetQuery): Promise<ArtifactZip>;
}

export const EvalServiceName = "imandrax.api.Eval";
export class EvalClientImpl implements Eval {
  private readonly rpc: Rpc;
  private readonly service: string;
  constructor(rpc: Rpc, opts?: { service?: string }) {
    this.service = opts?.service || EvalServiceName;
    this.rpc = rpc;
    this.eval_code_snippet = this.eval_code_snippet.bind(this);
    this.parse_term = this.parse_term.bind(this);
    this.parse_type = this.parse_type.bind(this);
    this.list_artifacts = this.list_artifacts.bind(this);
    this.get_artifact = this.get_artifact.bind(this);
    this.get_artifact_zip = this.get_artifact_zip.bind(this);
  }
  eval_code_snippet(request: CodeSnippet): Promise<CodeSnippetEvalResult> {
    const data = CodeSnippet.encode(request).finish();
    const promise = this.rpc.request(this.service, "eval_code_snippet", data);
    return promise.then((data) => CodeSnippetEvalResult.decode(new BinaryReader(data)));
  }

  parse_term(request: CodeSnippet): Promise<Artifact> {
    const data = CodeSnippet.encode(request).finish();
    const promise = this.rpc.request(this.service, "parse_term", data);
    return promise.then((data) => Artifact.decode(new BinaryReader(data)));
  }

  parse_type(request: CodeSnippet): Promise<Artifact> {
    const data = CodeSnippet.encode(request).finish();
    const promise = this.rpc.request(this.service, "parse_type", data);
    return promise.then((data) => Artifact.decode(new BinaryReader(data)));
  }

  list_artifacts(request: ArtifactListQuery): Promise<ArtifactListResult> {
    const data = ArtifactListQuery.encode(request).finish();
    const promise = this.rpc.request(this.service, "list_artifacts", data);
    return promise.then((data) => ArtifactListResult.decode(new BinaryReader(data)));
  }

  get_artifact(request: ArtifactGetQuery): Promise<Artifact> {
    const data = ArtifactGetQuery.encode(request).finish();
    const promise = this.rpc.request(this.service, "get_artifact", data);
    return promise.then((data) => Artifact.decode(new BinaryReader(data)));
  }

  get_artifact_zip(request: ArtifactGetQuery): Promise<ArtifactZip> {
    const data = ArtifactGetQuery.encode(request).finish();
    const promise = this.rpc.request(this.service, "get_artifact_zip", data);
    return promise.then((data) => ArtifactZip.decode(new BinaryReader(data)));
  }
}

interface Rpc {
  request(service: string, method: string, data: Uint8Array): Promise<Uint8Array>;
}

function bytesFromBase64(b64: string): Uint8Array {
  if ((globalThis as any).Buffer) {
    return Uint8Array.from(globalThis.Buffer.from(b64, "base64"));
  } else {
    const bin = globalThis.atob(b64);
    const arr = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; ++i) {
      arr[i] = bin.charCodeAt(i);
    }
    return arr;
  }
}

function base64FromBytes(arr: Uint8Array): string {
  if ((globalThis as any).Buffer) {
    return globalThis.Buffer.from(arr).toString("base64");
  } else {
    const bin: string[] = [];
    arr.forEach((byte) => {
      bin.push(globalThis.String.fromCharCode(byte));
    });
    return globalThis.btoa(bin.join(""));
  }
}

type Builtin = Date | Function | Uint8Array | string | number | boolean | undefined;

export type DeepPartial<T> = T extends Builtin ? T
  : T extends globalThis.Array<infer U> ? globalThis.Array<DeepPartial<U>>
  : T extends ReadonlyArray<infer U> ? ReadonlyArray<DeepPartial<U>>
  : T extends {} ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;

type KeysOfUnion<T> = T extends T ? keyof T : never;
export type Exact<P, I extends P> = P extends Builtin ? P
  : P & { [K in keyof P]: Exact<P[K], I[K]> } & { [K in Exclude<keyof I, KeysOfUnion<P>>]: never };

function isSet(value: any): boolean {
  return value !== null && value !== undefined;
}

export interface MessageFns<T> {
  encode(message: T, writer?: BinaryWriter): BinaryWriter;
  decode(input: BinaryReader | Uint8Array, length?: number): T;
  fromJSON(object: any): T;
  toJSON(message: T): unknown;
  create<I extends Exact<DeepPartial<T>, I>>(base?: I): T;
  fromPartial<I extends Exact<DeepPartial<T>, I>>(object: I): T;
}
