// Code generated by protoc-gen-ts_proto. DO NOT EDIT.
// versions:
//   protoc-gen-ts_proto  v2.7.0
//   protoc               v6.30.1
// source: error.proto

/* eslint-disable */
import { BinaryReader, BinaryWriter } from "@bufbuild/protobuf/wire";
import { Location } from "./locs.js";

export interface Error {
  /** The toplevel error message. */
  msg:
    | Error_Message
    | undefined;
  /** / A string description of the kind of error */
  kind: string;
  /** / Context for the error. */
  stack: Error_Message[];
  process?: string | undefined;
}

/** / An error message */
export interface Error_Message {
  msg: string;
  /** / Locations for this message */
  locs: Location[];
  /** / Captured backtrace */
  backtrace?: string | undefined;
}

function createBaseError(): Error {
  return { msg: undefined, kind: "", stack: [], process: undefined };
}

export const Error: MessageFns<Error> = {
  encode(message: Error, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.msg !== undefined) {
      Error_Message.encode(message.msg, writer.uint32(10).fork()).join();
    }
    if (message.kind !== "") {
      writer.uint32(18).string(message.kind);
    }
    for (const v of message.stack) {
      Error_Message.encode(v!, writer.uint32(26).fork()).join();
    }
    if (message.process !== undefined) {
      writer.uint32(34).string(message.process);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): Error {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseError();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.msg = Error_Message.decode(reader, reader.uint32());
          continue;
        }
        case 2: {
          if (tag !== 18) {
            break;
          }

          message.kind = reader.string();
          continue;
        }
        case 3: {
          if (tag !== 26) {
            break;
          }

          message.stack.push(Error_Message.decode(reader, reader.uint32()));
          continue;
        }
        case 4: {
          if (tag !== 34) {
            break;
          }

          message.process = reader.string();
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

  fromJSON(object: any): Error {
    return {
      msg: isSet(object.msg) ? Error_Message.fromJSON(object.msg) : undefined,
      kind: isSet(object.kind) ? gt.String(object.kind) : "",
      stack: gt.Array.isArray(object?.stack) ? object.stack.map((e: any) => Error_Message.fromJSON(e)) : [],
      process: isSet(object.process) ? gt.String(object.process) : undefined,
    };
  },

  toJSON(message: Error): unknown {
    const obj: any = {};
    if (message.msg !== undefined) {
      obj.msg = Error_Message.toJSON(message.msg);
    }
    if (message.kind !== "") {
      obj.kind = message.kind;
    }
    if (message.stack?.length) {
      obj.stack = message.stack.map((e) => Error_Message.toJSON(e));
    }
    if (message.process !== undefined) {
      obj.process = message.process;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Error>, I>>(base?: I): Error {
    return Error.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Error>, I>>(object: I): Error {
    const message = createBaseError();
    message.msg = (object.msg !== undefined && object.msg !== null) ? Error_Message.fromPartial(object.msg) : undefined;
    message.kind = object.kind ?? "";
    message.stack = object.stack?.map((e) => Error_Message.fromPartial(e)) || [];
    message.process = object.process ?? undefined;
    return message;
  },
};

function createBaseError_Message(): Error_Message {
  return { msg: "", locs: [], backtrace: undefined };
}

export const Error_Message: MessageFns<Error_Message> = {
  encode(message: Error_Message, writer: BinaryWriter = new BinaryWriter()): BinaryWriter {
    if (message.msg !== "") {
      writer.uint32(10).string(message.msg);
    }
    for (const v of message.locs) {
      Location.encode(v!, writer.uint32(18).fork()).join();
    }
    if (message.backtrace !== undefined) {
      writer.uint32(26).string(message.backtrace);
    }
    return writer;
  },

  decode(input: BinaryReader | Uint8Array, length?: number): Error_Message {
    const reader = input instanceof BinaryReader ? input : new BinaryReader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseError_Message();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1: {
          if (tag !== 10) {
            break;
          }

          message.msg = reader.string();
          continue;
        }
        case 2: {
          if (tag !== 18) {
            break;
          }

          message.locs.push(Location.decode(reader, reader.uint32()));
          continue;
        }
        case 3: {
          if (tag !== 26) {
            break;
          }

          message.backtrace = reader.string();
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

  fromJSON(object: any): Error_Message {
    return {
      msg: isSet(object.msg) ? gt.String(object.msg) : "",
      locs: gt.Array.isArray(object?.locs) ? object.locs.map((e: any) => Location.fromJSON(e)) : [],
      backtrace: isSet(object.backtrace) ? gt.String(object.backtrace) : undefined,
    };
  },

  toJSON(message: Error_Message): unknown {
    const obj: any = {};
    if (message.msg !== "") {
      obj.msg = message.msg;
    }
    if (message.locs?.length) {
      obj.locs = message.locs.map((e) => Location.toJSON(e));
    }
    if (message.backtrace !== undefined) {
      obj.backtrace = message.backtrace;
    }
    return obj;
  },

  create<I extends Exact<DeepPartial<Error_Message>, I>>(base?: I): Error_Message {
    return Error_Message.fromPartial(base ?? ({} as any));
  },
  fromPartial<I extends Exact<DeepPartial<Error_Message>, I>>(object: I): Error_Message {
    const message = createBaseError_Message();
    message.msg = object.msg ?? "";
    message.locs = object.locs?.map((e) => Location.fromPartial(e)) || [];
    message.backtrace = object.backtrace ?? undefined;
    return message;
  },
};

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

type Builtin = Date | Function | Uint8Array | string | number | boolean | bigint | undefined;

type DeepPartial<T> = T extends Builtin ? T
  : T extends globalThis.Array<infer U> ? globalThis.Array<DeepPartial<U>>
  : T extends ReadonlyArray<infer U> ? ReadonlyArray<DeepPartial<U>>
  : T extends { $case: string } ? { [K in keyof Omit<T, "$case">]?: DeepPartial<T[K]> } & { $case: T["$case"] }
  : T extends {} ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;

type KeysOfUnion<T> = T extends T ? keyof T : never;
type Exact<P, I extends P> = P extends Builtin ? P
  : P & { [K in keyof P]: Exact<P[K], I[K]> } & { [K in Exclude<keyof I, KeysOfUnion<P>>]: never };

function isSet(value: any): boolean {
  return value !== null && value !== undefined;
}

interface MessageFns<T> {
  encode(message: T, writer?: BinaryWriter): BinaryWriter;
  decode(input: BinaryReader | Uint8Array, length?: number): T;
  fromJSON(object: any): T;
  toJSON(message: T): unknown;
  create<I extends Exact<DeepPartial<T>, I>>(base?: I): T;
  fromPartial<I extends Exact<DeepPartial<T>, I>>(object: I): T;
}
