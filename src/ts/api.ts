/* eslint-disable */
import Long from "long";
import _m0 from "protobufjs/minimal";

export const protobufPackage = "";

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

/** Void type, used for messages without arguments or return value. */
export interface Empty {
}

export interface Position {
  line: number;
  col: number;
}

/** A location */
export interface Location {
  file: string;
  start?: Position | undefined;
  stop?: Position | undefined;
}

export interface Error {
  /** The full error message. */
  msg: string;
  /** / A string description of the kind of error */
  kind: string;
  loc?: Location | undefined;
}

export interface TaskID {
  /** The task identifier. */
  id: Uint8Array;
}

/** A session identifier. */
export interface Session {
  /** The session's unique ID (e.g a uuid). */
  id: Uint8Array;
}

export interface SessionCreate {
  /** / Do we check Proof Obligations? Default true. */
  poCheck?: boolean | undefined;
}

export interface CodeSnippet {
  session?:
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
  tasks: TaskID[];
  /** Errors occurring during evaluation. */
  errors: Error[];
}

export interface GcStats {
  heapSizeB: bigint;
  majorCollections: bigint;
  minorCollections: bigint;
}

function createBaseEmpty(): Empty {
  return {};
}

export const Empty = {
  encode(_: Empty, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Empty {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseEmpty();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(_: any): Empty {
    return {};
  },

  toJSON(_: Empty): unknown {
    const obj: any = {};
    return obj;
  },

  create<I extends Exact<DeepPartial<Empty>, I>>(base?: I): Empty {
    return Empty.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Empty>, I>>(_: I): Empty {
    const message = createBaseEmpty();
    return message;
  },
};

function createBasePosition(): Position {
  return { line: 0, col: 0 };
}

export const Position = {
  encode(message: Position, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.line !== 0) {
      writer.uint32(8).int32(message.line);
    }
    if (message.col !== 0) {
      writer.uint32(16).int32(message.col);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Position {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBasePosition();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 8) {
            break;
          }

          message.line = reader.int32();
          continue;
        case 2:
          if (tag !== 16) {
            break;
          }

          message.col = reader.int32();
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): Position {
    return {
      line: isSet(object.line) ? gt.Number(object.line) : 0,
      col: isSet(object.col) ? gt.Number(object.col) : 0,
    };
  },

  toJSON(message: Position): unknown {
    const obj: any = {};
    if (message.line !== 0) {
      obj.line = Math.round(message.line);
    }
    if (message.col !== 0) {
      obj.col = Math.round(message.col);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Position>, I>>(base?: I): Position {
    return Position.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Position>, I>>(object: I): Position {
    const message = createBasePosition();
    message.line = object.line ?? 0;
    message.col = object.col ?? 0;
    return message;
  },
};

function createBaseLocation(): Location {
  return { file: "", start: undefined, stop: undefined };
}

export const Location = {
  encode(message: Location, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.file !== "") {
      writer.uint32(10).string(message.file);
    }
    if (message.start !== undefined) {
      Position.encode(message.start, writer.uint32(18).fork()).ldelim();
    }
    if (message.stop !== undefined) {
      Position.encode(message.stop, writer.uint32(26).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Location {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseLocation();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 10) {
            break;
          }

          message.file = reader.string();
          continue;
        case 2:
          if (tag !== 18) {
            break;
          }

          message.start = Position.decode(reader, reader.uint32());
          continue;
        case 3:
          if (tag !== 26) {
            break;
          }

          message.stop = Position.decode(reader, reader.uint32());
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): Location {
    return {
      file: isSet(object.file) ? gt.String(object.file) : "",
      start: isSet(object.start) ? Position.fromJSON(object.start) : undefined,
      stop: isSet(object.stop) ? Position.fromJSON(object.stop) : undefined,
    };
  },

  toJSON(message: Location): unknown {
    const obj: any = {};
    if (message.file !== "") {
      obj.file = message.file;
    }
    if (message.start !== undefined) {
      obj.start = Position.toJSON(message.start);
    }
    if (message.stop !== undefined) {
      obj.stop = Position.toJSON(message.stop);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Location>, I>>(base?: I): Location {
    return Location.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Location>, I>>(object: I): Location {
    const message = createBaseLocation();
    message.file = object.file ?? "";
    message.start = (object.start !== undefined && object.start !== null)
      ? Position.fromPartial(object.start)
      : undefined;
    message.stop = (object.stop !== undefined && object.stop !== null) ? Position.fromPartial(object.stop) : undefined;
    return message;
  },
};

function createBaseError(): Error {
  return { msg: "", kind: "", loc: undefined };
}

export const Error = {
  encode(message: Error, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.msg !== "") {
      writer.uint32(10).string(message.msg);
    }
    if (message.kind !== "") {
      writer.uint32(18).string(message.kind);
    }
    if (message.loc !== undefined) {
      Location.encode(message.loc, writer.uint32(26).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Error {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseError();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 10) {
            break;
          }

          message.msg = reader.string();
          continue;
        case 2:
          if (tag !== 18) {
            break;
          }

          message.kind = reader.string();
          continue;
        case 3:
          if (tag !== 26) {
            break;
          }

          message.loc = Location.decode(reader, reader.uint32());
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): Error {
    return {
      msg: isSet(object.msg) ? gt.String(object.msg) : "",
      kind: isSet(object.kind) ? gt.String(object.kind) : "",
      loc: isSet(object.loc) ? Location.fromJSON(object.loc) : undefined,
    };
  },

  toJSON(message: Error): unknown {
    const obj: any = {};
    if (message.msg !== "") {
      obj.msg = message.msg;
    }
    if (message.kind !== "") {
      obj.kind = message.kind;
    }
    if (message.loc !== undefined) {
      obj.loc = Location.toJSON(message.loc);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Error>, I>>(base?: I): Error {
    return Error.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Error>, I>>(object: I): Error {
    const message = createBaseError();
    message.msg = object.msg ?? "";
    message.kind = object.kind ?? "";
    message.loc = (object.loc !== undefined && object.loc !== null) ? Location.fromPartial(object.loc) : undefined;
    return message;
  },
};

function createBaseTaskID(): TaskID {
  return { id: new Uint8Array(0) };
}

export const TaskID = {
  encode(message: TaskID, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.id.length !== 0) {
      writer.uint32(10).bytes(message.id);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): TaskID {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseTaskID();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 10) {
            break;
          }

          message.id = reader.bytes();
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): TaskID {
    return { id: isSet(object.id) ? bytesFromBase64(object.id) : new Uint8Array(0) };
  },

  toJSON(message: TaskID): unknown {
    const obj: any = {};
    if (message.id.length !== 0) {
      obj.id = base64FromBytes(message.id);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<TaskID>, I>>(base?: I): TaskID {
    return TaskID.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<TaskID>, I>>(object: I): TaskID {
    const message = createBaseTaskID();
    message.id = object.id ?? new Uint8Array(0);
    return message;
  },
};

function createBaseSession(): Session {
  return { id: new Uint8Array(0) };
}

export const Session = {
  encode(message: Session, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.id.length !== 0) {
      writer.uint32(10).bytes(message.id);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Session {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSession();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 10) {
            break;
          }

          message.id = reader.bytes();
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): Session {
    return { id: isSet(object.id) ? bytesFromBase64(object.id) : new Uint8Array(0) };
  },

  toJSON(message: Session): unknown {
    const obj: any = {};
    if (message.id.length !== 0) {
      obj.id = base64FromBytes(message.id);
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Session>, I>>(base?: I): Session {
    return Session.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Session>, I>>(object: I): Session {
    const message = createBaseSession();
    message.id = object.id ?? new Uint8Array(0);
    return message;
  },
};

function createBaseSessionCreate(): SessionCreate {
  return { poCheck: undefined };
}

export const SessionCreate = {
  encode(message: SessionCreate, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.poCheck !== undefined) {
      writer.uint32(8).bool(message.poCheck);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): SessionCreate {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSessionCreate();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 8) {
            break;
          }

          message.poCheck = reader.bool();
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): SessionCreate {
    return { poCheck: isSet(object.poCheck) ? gt.Boolean(object.poCheck) : undefined };
  },

  toJSON(message: SessionCreate): unknown {
    const obj: any = {};
    if (message.poCheck !== undefined) {
      obj.poCheck = message.poCheck;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<SessionCreate>, I>>(base?: I): SessionCreate {
    return SessionCreate.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<SessionCreate>, I>>(object: I): SessionCreate {
    const message = createBaseSessionCreate();
    message.poCheck = object.poCheck ?? undefined;
    return message;
  },
};

function createBaseCodeSnippet(): CodeSnippet {
  return { session: undefined, code: "" };
}

export const CodeSnippet = {
  encode(message: CodeSnippet, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.session !== undefined) {
      Session.encode(message.session, writer.uint32(10).fork()).ldelim();
    }
    if (message.code !== "") {
      writer.uint32(18).string(message.code);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): CodeSnippet {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseCodeSnippet();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 10) {
            break;
          }

          message.session = Session.decode(reader, reader.uint32());
          continue;
        case 2:
          if (tag !== 18) {
            break;
          }

          message.code = reader.string();
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): CodeSnippet {
    return {
      session: isSet(object.session) ? Session.fromJSON(object.session) : undefined,
      code: isSet(object.code) ? gt.String(object.code) : "",
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

export const CodeSnippetEvalResult = {
  encode(message: CodeSnippetEvalResult, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.res !== 0) {
      writer.uint32(8).int32(message.res);
    }
    if (message.durationS !== 0) {
      writer.uint32(29).float(message.durationS);
    }
    for (const v of message.tasks) {
      TaskID.encode(v!, writer.uint32(74).fork()).ldelim();
    }
    for (const v of message.errors) {
      Error.encode(v!, writer.uint32(82).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): CodeSnippetEvalResult {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseCodeSnippetEvalResult();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 8) {
            break;
          }

          message.res = reader.int32() as any;
          continue;
        case 3:
          if (tag !== 29) {
            break;
          }

          message.durationS = reader.float();
          continue;
        case 9:
          if (tag !== 74) {
            break;
          }

          message.tasks.push(TaskID.decode(reader, reader.uint32()));
          continue;
        case 10:
          if (tag !== 82) {
            break;
          }

          message.errors.push(Error.decode(reader, reader.uint32()));
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): CodeSnippetEvalResult {
    return {
      res: isSet(object.res) ? evalResultFromJSON(object.res) : 0,
      durationS: isSet(object.durationS) ? gt.Number(object.durationS) : 0,
      tasks: gt.Array.isArray(object?.tasks) ? object.tasks.map((e: any) => TaskID.fromJSON(e)) : [],
      errors: gt.Array.isArray(object?.errors) ? object.errors.map((e: any) => Error.fromJSON(e)) : [],
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
      obj.tasks = message.tasks.map((e) => TaskID.toJSON(e));
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
    message.tasks = object.tasks?.map((e) => TaskID.fromPartial(e)) || [];
    message.errors = object.errors?.map((e) => Error.fromPartial(e)) || [];
    return message;
  },
};

function createBaseGcStats(): GcStats {
  return { heapSizeB: BigInt("0"), majorCollections: BigInt("0"), minorCollections: BigInt("0") };
}

export const GcStats = {
  encode(message: GcStats, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.heapSizeB !== BigInt("0")) {
      if (BigInt.asIntN(64, message.heapSizeB) !== message.heapSizeB) {
        throw new gt.Error("value provided for field message.heapSizeB of type int64 too large");
      }
      writer.uint32(8).int64(message.heapSizeB.toString());
    }
    if (message.majorCollections !== BigInt("0")) {
      if (BigInt.asIntN(64, message.majorCollections) !== message.majorCollections) {
        throw new gt.Error("value provided for field message.majorCollections of type int64 too large");
      }
      writer.uint32(16).int64(message.majorCollections.toString());
    }
    if (message.minorCollections !== BigInt("0")) {
      if (BigInt.asIntN(64, message.minorCollections) !== message.minorCollections) {
        throw new gt.Error("value provided for field message.minorCollections of type int64 too large");
      }
      writer.uint32(24).int64(message.minorCollections.toString());
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): GcStats {
    const reader = input instanceof _m0.Reader ? input : _m0.Reader.create(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseGcStats();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          if (tag !== 8) {
            break;
          }

          message.heapSizeB = longToBigint(reader.int64() as Long);
          continue;
        case 2:
          if (tag !== 16) {
            break;
          }

          message.majorCollections = longToBigint(reader.int64() as Long);
          continue;
        case 3:
          if (tag !== 24) {
            break;
          }

          message.minorCollections = longToBigint(reader.int64() as Long);
          continue;
      }
      if ((tag & 7) === 4 || tag === 0) {
        break;
      }
      reader.skipType(tag & 7);
    }
    return message;
  },

  fromJSON(object: any): GcStats {
    return {
      heapSizeB: isSet(object.heapSizeB) ? BigInt(object.heapSizeB) : BigInt("0"),
      majorCollections: isSet(object.majorCollections) ? BigInt(object.majorCollections) : BigInt("0"),
      minorCollections: isSet(object.minorCollections) ? BigInt(object.minorCollections) : BigInt("0"),
    };
  },

  toJSON(message: GcStats): unknown {
    const obj: any = {};
    if (message.heapSizeB !== BigInt("0")) {
      obj.heapSizeB = message.heapSizeB.toString();
    }
    if (message.majorCollections !== BigInt("0")) {
      obj.majorCollections = message.majorCollections.toString();
    }
    if (message.minorCollections !== BigInt("0")) {
      obj.minorCollections = message.minorCollections.toString();
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<GcStats>, I>>(base?: I): GcStats {
    return GcStats.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<GcStats>, I>>(object: I): GcStats {
    const message = createBaseGcStats();
    message.heapSizeB = object.heapSizeB ?? BigInt("0");
    message.majorCollections = object.majorCollections ?? BigInt("0");
    message.minorCollections = object.minorCollections ?? BigInt("0");
    return message;
  },
};

export type SessionManagerDefinition = typeof SessionManagerDefinition;
export const SessionManagerDefinition = {
  name: "SessionManager",
  fullName: "SessionManager",
  methods: {
    /** Create a new session. */
    create_session: {
      name: "create_session",
      requestType: SessionCreate,
      requestStream: false,
      responseType: Session,
      responseStream: false,
      options: {},
    },
  },
} as const;

export type EvalDefinition = typeof EvalDefinition;
export const EvalDefinition = {
  name: "Eval",
  fullName: "Eval",
  methods: {
    /** / Evaluate a snippet */
    eval_code_snippet: {
      name: "eval_code_snippet",
      requestType: CodeSnippet,
      requestStream: false,
      responseType: CodeSnippetEvalResult,
      responseStream: false,
      options: {},
    },
  },
} as const;

export type Gc_serviceDefinition = typeof Gc_serviceDefinition;
export const Gc_serviceDefinition = {
  name: "Gc_service",
  fullName: "Gc_service",
  methods: {
    get_stats: {
      name: "get_stats",
      requestType: Empty,
      requestStream: false,
      responseType: GcStats,
      responseStream: false,
      options: {},
    },
  },
} as const;

export interface DataLoaderOptions {
  cache?: boolean;
}

export interface DataLoaders {
  rpcDataLoaderOptions?: DataLoaderOptions;
  getDataLoader<T>(identifier: string, constructorFn: () => T): T;
}

declare const self: any | undefined;
declare const window: any | undefined;
declare const global: any | undefined;
const gt: any = (() => {
  if (typeof globalThis !== "undefined") {
    return globalThis;
  }
  if (typeof self !== "undefined") {
    return self;
  }
  if (typeof window !== "undefined") {
    return window;
  }
  if (typeof global !== "undefined") {
    return global;
  }
  throw "Unable to locate global object";
})();

function bytesFromBase64(b64: string): Uint8Array {
  if (gt.Buffer) {
    return Uint8Array.from(gt.Buffer.from(b64, "base64"));
  } else {
    const bin = gt.atob(b64);
    const arr = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; ++i) {
      arr[i] = bin.charCodeAt(i);
    }
    return arr;
  }
}

function base64FromBytes(arr: Uint8Array): string {
  if (gt.Buffer) {
    return gt.Buffer.from(arr).toString("base64");
  } else {
    const bin: string[] = [];
    arr.forEach((byte) => {
      bin.push(gt.String.fromCharCode(byte));
    });
    return gt.btoa(bin.join(""));
  }
}

type Builtin = Date | Function | Uint8Array | string | number | boolean | bigint | undefined;

export type DeepPartial<T> = T extends Builtin ? T
  : T extends globalThis.Array<infer U> ? globalThis.Array<DeepPartial<U>>
  : T extends ReadonlyArray<infer U> ? ReadonlyArray<DeepPartial<U>>
  : T extends { $case: string } ? { [K in keyof Omit<T, "$case">]?: DeepPartial<T[K]> } & { $case: T["$case"] }
  : T extends {} ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;

type KeysOfUnion<T> = T extends T ? keyof T : never;
export type Exact<P, I extends P> = P extends Builtin ? P
  : P & { [K in keyof P]: Exact<P[K], I[K]> } & { [K in Exclude<keyof I, KeysOfUnion<P>>]: never };

function longToBigint(long: Long) {
  return BigInt(long.toString());
}

if (_m0.util.Long !== Long) {
  _m0.util.Long = Long as any;
  _m0.configure();
}

function isSet(value: any): boolean {
  return value !== null && value !== undefined;
}
