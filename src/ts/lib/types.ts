'use strict';
// automatically generated using genbindings.ml, do not edit

import * as  twine from './twine';

type offset = twine.offset;
export type Error = Error_Error_core;

export type WithTag6<T> = T;
export type WithTag7<T> = T;

function checkArrayLength(off: offset, a: Array<offset>, len: number): void {
  if (a.length < len) {
    throw new twine.TwineError({msg: `Array is too short (len=${a.length}, expected ${len} elements)`, offset: off})
  }
}

function decode_with_tag<T>(tag: number, d: twine.Decoder, off: offset, d0: (d: twine.Decoder, o: offset) => T) : T {
  const dec_tag = d.get_tag(off);
  if (dec_tag.tag != tag)
  throw new twine.TwineError({msg: `Expected tag ${tag}, got tag ${dec_tag.tag}`, offset: off})
  return d0(d, dec_tag.value)
}

export type Void = never;
export function Void_of_twine(_d: twine.Decoder, off:offset): Void {
  throw new twine.TwineError({ msg: `Cannot decode Void`, offset: off });
}

export type Eval__Value_Custom_value = any;
export function Eval__Value_Custom_value_of_twine(_d: twine.Decoder, off:offset): Eval__Value_Custom_value {
  throw new twine.TwineError({ msg: `Cannot decode Eval__Value_Custom_value`, offset: off });
}


export function decode_q(d: twine.Decoder, off: offset) : [bigint, bigint] {
  const [num, denum] = d.get_array(off)
  const bnum = d.get_int(num)
  const bdenum = d.get_int(denum)
  return [bnum, bdenum]
}
  

// clique Imandrakit_error.Kind.t (cached: false)
// def Imandrakit_error.Kind.t (mangled name: "Error_Kind")
export class Error_Kind {
  constructor(
    public name:string) {}
}

export function Error_Kind_of_twine(d: twine.Decoder, off: offset): Error_Kind {
  const x = d.get_str(off) // single unboxed field
  return new Error_Kind(x)
}

// clique Imandrakit_error.Error_core.message (cached: false)
// def Imandrakit_error.Error_core.message (mangled name: "Error_Error_core_message")
export class Error_Error_core_message {
  constructor(
    public msg:string,
    public data:null,
    public bt:undefined | string) {}
}

export function Error_Error_core_message_of_twine(d: twine.Decoder, off: offset): Error_Error_core_message {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const msg = d.get_str(fields[0])
  const data = null
  const bt = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_str(off)), fields[2])
  return new Error_Error_core_message(msg, data, bt)
}

// clique Imandrakit_error.Error_core.stack (cached: false)
// def Imandrakit_error.Error_core.stack (mangled name: "Error_Error_core_stack")
export type Error_Error_core_stack = Array<Error_Error_core_message>;

export function Error_Error_core_stack_of_twine(d: twine.Decoder, off: offset): Error_Error_core_stack {
  return d.get_array(off).toArray().map(x => Error_Error_core_message_of_twine(d, x))
}

// clique Imandrakit_error.Error_core.t (cached: false)
// def Imandrakit_error.Error_core.t (mangled name: "Error_Error_core")
export class Error_Error_core {
  constructor(
    public process:string,
    public kind:Error_Kind,
    public msg:Error_Error_core_message,
    public stack:Error_Error_core_stack) {}
}

export function Error_Error_core_of_twine(d: twine.Decoder, off: offset): Error_Error_core {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const process = d.get_str(fields[0])
  const kind = Error_Kind_of_twine(d, fields[1])
  const msg = Error_Error_core_message_of_twine(d, fields[2])
  const stack = Error_Error_core_stack_of_twine(d, fields[3])
  return new Error_Error_core(process, kind, msg, stack)
}

// clique Imandrax_api.Upto.t (cached: false)
// def Imandrax_api.Upto.t (mangled name: "Upto")
export class Upto_N_steps {
  constructor(public arg: bigint) {}
}
export function Upto_N_steps_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Upto_N_steps {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Upto_N_steps(arg)
}
export type Upto = Upto_N_steps

export function Upto_of_twine(d: twine.Decoder, off: offset): Upto {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Upto_N_steps_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Upto, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Builtin_data.kind (cached: false)
// def Imandrax_api.Builtin_data.kind (mangled name: "Builtin_data_kind")
export class Builtin_data_kind_Logic_core {
  constructor(
    public logic_core_name: string){}
}

export function Builtin_data_kind_Logic_core_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Builtin_data_kind_Logic_core {
  checkArrayLength(off, _tw_args, 1)
  const logic_core_name = d.get_str(_tw_args[0])
  return new Builtin_data_kind_Logic_core(logic_core_name)
}
export class Builtin_data_kind_Special {
  constructor(
    public tag: string){}
}

export function Builtin_data_kind_Special_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Builtin_data_kind_Special {
  checkArrayLength(off, _tw_args, 1)
  const tag = d.get_str(_tw_args[0])
  return new Builtin_data_kind_Special(tag)
}
export class Builtin_data_kind_Tactic {
  constructor(
    public tac_name: string){}
}

export function Builtin_data_kind_Tactic_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Builtin_data_kind_Tactic {
  checkArrayLength(off, _tw_args, 1)
  const tac_name = d.get_str(_tw_args[0])
  return new Builtin_data_kind_Tactic(tac_name)
}
export class Builtin_data_kind_Decomp {
  constructor(
    public decomp_name: string){}
}

export function Builtin_data_kind_Decomp_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Builtin_data_kind_Decomp {
  checkArrayLength(off, _tw_args, 1)
  const decomp_name = d.get_str(_tw_args[0])
  return new Builtin_data_kind_Decomp(decomp_name)
}
export type Builtin_data_kind = Builtin_data_kind_Logic_core| Builtin_data_kind_Special| Builtin_data_kind_Tactic| Builtin_data_kind_Decomp

export function Builtin_data_kind_of_twine(d: twine.Decoder, off: offset): Builtin_data_kind {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Builtin_data_kind_Logic_core_of_twine(d,  c.args, off)
   case 1:
      return Builtin_data_kind_Special_of_twine(d,  c.args, off)
   case 2:
      return Builtin_data_kind_Tactic_of_twine(d,  c.args, off)
   case 3:
      return Builtin_data_kind_Decomp_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Builtin_data_kind, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Chash.t (cached: false)
// def Imandrax_api.Chash.t (mangled name: "Chash")
type Chash = Uint8Array;

function Chash_of_twine(d: twine.Decoder, off:number): Chash {
    return d.get_bytes(off)
}

// clique Imandrax_api.Cname.t_ (cached: false)
// def Imandrax_api.Cname.t_ (mangled name: "Cname_t_")
export class Cname_t_ {
  constructor(
    public name:string,
    public chash:Chash,
    public is_key:boolean) {}
}

export function Cname_t__of_twine(d: twine.Decoder, off: offset): Cname_t_ {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const name = d.get_str(fields[0])
  const chash = Chash_of_twine(d, fields[1])
  const is_key = d.get_bool(fields[2])
  return new Cname_t_(name, chash, is_key)
}

// clique Imandrax_api.Cname.t (cached: false)
// def Imandrax_api.Cname.t (mangled name: "Cname")
export type Cname = WithTag6<Cname_t_>;

export function Cname_of_twine(d: twine.Decoder, off: offset): Cname {
  return decode_with_tag(6, d, off, ((d:twine.Decoder,off:offset) => Cname_t__of_twine(d, off)))
}

// clique Imandrax_api.Uid.gen_kind (cached: false)
// def Imandrax_api.Uid.gen_kind (mangled name: "Uid_gen_kind")
export class Uid_gen_kind_Local {
  constructor(){}
}
export class Uid_gen_kind_To_be_rewritten {
  constructor(){}
}
export type Uid_gen_kind = Uid_gen_kind_Local| Uid_gen_kind_To_be_rewritten

export function Uid_gen_kind_of_twine(d: twine.Decoder, off: offset): Uid_gen_kind {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Uid_gen_kind_Local()
   case 1:
     return new Uid_gen_kind_To_be_rewritten()
   default:
      throw new twine.TwineError({msg: `expected Uid_gen_kind, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Uid.view (cached: false)
// def Imandrax_api.Uid.view (mangled name: "Uid_view")
export class Uid_view_Generative {
  constructor(
    public id: bigint,
    public gen_kind: Uid_gen_kind){}
}

export function Uid_view_Generative_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Uid_view_Generative {
  checkArrayLength(off, _tw_args, 2)
  const id = d.get_int(_tw_args[0])
  const gen_kind = Uid_gen_kind_of_twine(d, _tw_args[1])
  return new Uid_view_Generative(id,gen_kind)
}
export class Uid_view_Persistent {
  constructor(){}
}
export class Uid_view_Cname {
  constructor(
    public cname: Cname){}
}

export function Uid_view_Cname_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Uid_view_Cname {
  checkArrayLength(off, _tw_args, 1)
  const cname = Cname_of_twine(d, _tw_args[0])
  return new Uid_view_Cname(cname)
}
export class Uid_view_Builtin {
  constructor(
    public kind: Builtin_data_kind){}
}

export function Uid_view_Builtin_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Uid_view_Builtin {
  checkArrayLength(off, _tw_args, 1)
  const kind = Builtin_data_kind_of_twine(d, _tw_args[0])
  return new Uid_view_Builtin(kind)
}
export type Uid_view = Uid_view_Generative| Uid_view_Persistent| Uid_view_Cname| Uid_view_Builtin

export function Uid_view_of_twine(d: twine.Decoder, off: offset): Uid_view {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Uid_view_Generative_of_twine(d,  c.args, off)
   case 1:
     return new Uid_view_Persistent()
   case 2:
      return Uid_view_Cname_of_twine(d,  c.args, off)
   case 3:
      return Uid_view_Builtin_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Uid_view, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Uid.t (cached: false)
// def Imandrax_api.Uid.t (mangled name: "Uid")
export class Uid {
  constructor(
    public name:string,
    public view:Uid_view) {}
}

export function Uid_of_twine(d: twine.Decoder, off: offset): Uid {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const name = d.get_str(fields[0])
  const view = Uid_view_of_twine(d, fields[1])
  return new Uid(name, view)
}

// clique Imandrax_api.Uid_set.t (cached: false)
// def Imandrax_api.Uid_set.t (mangled name: "Uid_set")
type Uid_set = Set<Uid>

function Uid_set_of_twine(d: twine.Decoder, off: offset): Uid_set {
  return new Set(d.get_array(off).toArray().map(x => Uid_of_twine(d,x)))
}

// clique Imandrax_api.Builtin.Fun.t (cached: false)
// def Imandrax_api.Builtin.Fun.t (mangled name: "Builtin_Fun")
export class Builtin_Fun {
  constructor(
    public id:Uid,
    public kind:Builtin_data_kind,
    public lassoc:boolean,
    public commutative:boolean,
    public connective:boolean) {}
}

export function Builtin_Fun_of_twine(d: twine.Decoder, off: offset): Builtin_Fun {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 5)
  const id = Uid_of_twine(d, fields[0])
  const kind = Builtin_data_kind_of_twine(d, fields[1])
  const lassoc = d.get_bool(fields[2])
  const commutative = d.get_bool(fields[3])
  const connective = d.get_bool(fields[4])
  return new Builtin_Fun(id, kind, lassoc, commutative, connective)
}

// clique Imandrax_api.Builtin.Ty.t (cached: false)
// def Imandrax_api.Builtin.Ty.t (mangled name: "Builtin_Ty")
export class Builtin_Ty {
  constructor(
    public id:Uid,
    public kind:Builtin_data_kind) {}
}

export function Builtin_Ty_of_twine(d: twine.Decoder, off: offset): Builtin_Ty {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const id = Uid_of_twine(d, fields[0])
  const kind = Builtin_data_kind_of_twine(d, fields[1])
  return new Builtin_Ty(id, kind)
}

// clique Imandrax_api.Clique.t (cached: false)
// def Imandrax_api.Clique.t (mangled name: "Clique")
export type Clique = Uid_set;

export function Clique_of_twine(d: twine.Decoder, off: offset): Clique {
  return Uid_set_of_twine(d, off)
}

// clique Imandrax_api.Ty_view.adt_row (cached: false)
// def Imandrax_api.Ty_view.adt_row (mangled name: "Ty_view_adt_row")
export class Ty_view_adt_row<_V_tyreg_poly_id,_V_tyreg_poly_t> {
  constructor(
    public c:_V_tyreg_poly_id,
    public labels:undefined | Array<_V_tyreg_poly_id>,
    public args:Array<_V_tyreg_poly_t>,
    public doc:undefined | string) {}
}

export function Ty_view_adt_row_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,off: offset): Ty_view_adt_row<_V_tyreg_poly_id,_V_tyreg_poly_t> {
    decode__tyreg_poly_id
    decode__tyreg_poly_t
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const c = decode__tyreg_poly_id(d,fields[0])
  const labels = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_array(off).toArray().map(x => decode__tyreg_poly_id(d,x))), fields[1])
  const args = d.get_array(fields[2]).toArray().map(x => decode__tyreg_poly_t(d,x))
  const doc = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_str(off)), fields[3])
  return new Ty_view_adt_row(c, labels, args, doc)
}

// clique Imandrax_api.Ty_view.rec_row (cached: false)
// def Imandrax_api.Ty_view.rec_row (mangled name: "Ty_view_rec_row")
export class Ty_view_rec_row<_V_tyreg_poly_id,_V_tyreg_poly_t> {
  constructor(
    public f:_V_tyreg_poly_id,
    public ty:_V_tyreg_poly_t,
    public doc:undefined | string) {}
}

export function Ty_view_rec_row_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,off: offset): Ty_view_rec_row<_V_tyreg_poly_id,_V_tyreg_poly_t> {
    decode__tyreg_poly_id
    decode__tyreg_poly_t
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const f = decode__tyreg_poly_id(d,fields[0])
  const ty = decode__tyreg_poly_t(d,fields[1])
  const doc = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_str(off)), fields[2])
  return new Ty_view_rec_row(f, ty, doc)
}

// clique Imandrax_api.Ty_view.decl (cached: false)
// def Imandrax_api.Ty_view.decl (mangled name: "Ty_view_decl")
export class Ty_view_decl_Algebraic<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(public arg: Array<Ty_view_adt_row<_V_tyreg_poly_id,_V_tyreg_poly_t>>) {}
}
export function Ty_view_decl_Algebraic_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_alias: (d:twine.Decoder, off:offset) => _V_tyreg_poly_alias,_tw_args: Array<offset>, off: offset): Ty_view_decl_Algebraic<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  decode__tyreg_poly_id; // ignore 
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_alias; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Ty_view_adt_row_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_id(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_t(d,off)),x))
  return new Ty_view_decl_Algebraic(arg)
}
export class Ty_view_decl_Record<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(public arg: Array<Ty_view_rec_row<_V_tyreg_poly_id,_V_tyreg_poly_t>>) {}
}
export function Ty_view_decl_Record_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_alias: (d:twine.Decoder, off:offset) => _V_tyreg_poly_alias,_tw_args: Array<offset>, off: offset): Ty_view_decl_Record<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  decode__tyreg_poly_id; // ignore 
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_alias; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Ty_view_rec_row_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_id(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_t(d,off)),x))
  return new Ty_view_decl_Record(arg)
}
export class Ty_view_decl_Alias<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(
    public target: _V_tyreg_poly_alias,
    public reexport_def: undefined | Ty_view_decl<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>){}
}

export function Ty_view_decl_Alias_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_alias: (d:twine.Decoder, off:offset) => _V_tyreg_poly_alias,_tw_args: Array<offset>, off: offset): Ty_view_decl_Alias<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  decode__tyreg_poly_id
  decode__tyreg_poly_t
  decode__tyreg_poly_alias
  checkArrayLength(off, _tw_args, 2)
  const target = decode__tyreg_poly_alias(d,_tw_args[0])
  const reexport_def = twine.optional(d,  ((d:twine.Decoder,off:offset) => Ty_view_decl_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_id(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_t(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_alias(d,off)),off)), _tw_args[1])
  return new Ty_view_decl_Alias(target,reexport_def)
}
export class Ty_view_decl_Skolem<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(){}
}
export class Ty_view_decl_Builtin<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(public arg: Builtin_Ty) {}
}
export function Ty_view_decl_Builtin_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_alias: (d:twine.Decoder, off:offset) => _V_tyreg_poly_alias,_tw_args: Array<offset>, off: offset): Ty_view_decl_Builtin<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  decode__tyreg_poly_id; // ignore 
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_alias; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Builtin_Ty_of_twine(d, _tw_args[0])
  return new Ty_view_decl_Builtin(arg)
}
export class Ty_view_decl_Other<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  constructor(){}
}
export type Ty_view_decl<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> = Ty_view_decl_Algebraic<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>| Ty_view_decl_Record<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>| Ty_view_decl_Alias<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>| Ty_view_decl_Skolem<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>| Ty_view_decl_Builtin<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>| Ty_view_decl_Other<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>

export function Ty_view_decl_of_twine<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>(d: twine.Decoder, decode__tyreg_poly_id: (d:twine.Decoder, off:offset) => _V_tyreg_poly_id, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_alias: (d:twine.Decoder, off:offset) => _V_tyreg_poly_alias,off: offset): Ty_view_decl<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Ty_view_decl_Algebraic_of_twine(d, decode__tyreg_poly_id, decode__tyreg_poly_t, decode__tyreg_poly_alias, c.args, off)
   case 1:
      return Ty_view_decl_Record_of_twine(d, decode__tyreg_poly_id, decode__tyreg_poly_t, decode__tyreg_poly_alias, c.args, off)
   case 2:
      return Ty_view_decl_Alias_of_twine(d, decode__tyreg_poly_id, decode__tyreg_poly_t, decode__tyreg_poly_alias, c.args, off)
   case 3:
     return new Ty_view_decl_Skolem<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>()
   case 4:
      return Ty_view_decl_Builtin_of_twine(d, decode__tyreg_poly_id, decode__tyreg_poly_t, decode__tyreg_poly_alias, c.args, off)
   case 5:
     return new Ty_view_decl_Other<_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias>()
   default:
      throw new twine.TwineError({msg: `expected Ty_view_decl, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Ty_view.view (cached: false)
// def Imandrax_api.Ty_view.view (mangled name: "Ty_view_view")
export class Ty_view_view_Var<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  constructor(public arg: _V_tyreg_poly_var) {}
}
export function Ty_view_view_Var_of_twine<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_lbl: (d:twine.Decoder, off:offset) => _V_tyreg_poly_lbl, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,_tw_args: Array<offset>, off: offset): Ty_view_view_Var<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  decode__tyreg_poly_lbl; // ignore 
  decode__tyreg_poly_var; // ignore 
  decode__tyreg_poly_t; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_var(d,_tw_args[0])
  return new Ty_view_view_Var(arg)
}
export class Ty_view_view_Arrow<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  constructor(public args: [_V_tyreg_poly_lbl,_V_tyreg_poly_t,_V_tyreg_poly_t]){}
}
export function Ty_view_view_Arrow_of_twine<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_lbl: (d:twine.Decoder, off:offset) => _V_tyreg_poly_lbl, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,_tw_args: Array<offset>, off: offset): Ty_view_view_Arrow<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  decode__tyreg_poly_lbl; // ignore
  decode__tyreg_poly_var; // ignore
  decode__tyreg_poly_t; // ignore
  checkArrayLength(off, _tw_args, 3)
  const cargs: [_V_tyreg_poly_lbl,_V_tyreg_poly_t,_V_tyreg_poly_t] = [decode__tyreg_poly_lbl(d,_tw_args[0]),decode__tyreg_poly_t(d,_tw_args[1]),decode__tyreg_poly_t(d,_tw_args[2])]
  return new Ty_view_view_Arrow(cargs)
}
export class Ty_view_view_Tuple<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  constructor(public arg: Array<_V_tyreg_poly_t>) {}
}
export function Ty_view_view_Tuple_of_twine<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_lbl: (d:twine.Decoder, off:offset) => _V_tyreg_poly_lbl, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,_tw_args: Array<offset>, off: offset): Ty_view_view_Tuple<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  decode__tyreg_poly_lbl; // ignore 
  decode__tyreg_poly_var; // ignore 
  decode__tyreg_poly_t; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => decode__tyreg_poly_t(d,x))
  return new Ty_view_view_Tuple(arg)
}
export class Ty_view_view_Constr<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  constructor(public args: [Uid,Array<_V_tyreg_poly_t>]){}
}
export function Ty_view_view_Constr_of_twine<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_lbl: (d:twine.Decoder, off:offset) => _V_tyreg_poly_lbl, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,_tw_args: Array<offset>, off: offset): Ty_view_view_Constr<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  decode__tyreg_poly_lbl; // ignore
  decode__tyreg_poly_var; // ignore
  decode__tyreg_poly_t; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<_V_tyreg_poly_t>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_t(d,x))]
  return new Ty_view_view_Constr(cargs)
}
export type Ty_view_view<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> = Ty_view_view_Var<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>| Ty_view_view_Arrow<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>| Ty_view_view_Tuple<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>| Ty_view_view_Constr<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>

export function Ty_view_view_of_twine<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t>(d: twine.Decoder, decode__tyreg_poly_lbl: (d:twine.Decoder, off:offset) => _V_tyreg_poly_lbl, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t,off: offset): Ty_view_view<_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Ty_view_view_Var_of_twine(d, decode__tyreg_poly_lbl, decode__tyreg_poly_var, decode__tyreg_poly_t, c.args, off)
   case 1:
      return Ty_view_view_Arrow_of_twine(d, decode__tyreg_poly_lbl, decode__tyreg_poly_var, decode__tyreg_poly_t, c.args, off)
   case 2:
      return Ty_view_view_Tuple_of_twine(d, decode__tyreg_poly_lbl, decode__tyreg_poly_var, decode__tyreg_poly_t, c.args, off)
   case 3:
      return Ty_view_view_Constr_of_twine(d, decode__tyreg_poly_lbl, decode__tyreg_poly_var, decode__tyreg_poly_t, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Ty_view_view, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Ty_view.def_poly (cached: false)
// def Imandrax_api.Ty_view.def_poly (mangled name: "Ty_view_def_poly")
export class Ty_view_def_poly<_V_tyreg_poly_ty> {
  constructor(
    public name:Uid,
    public params:Array<Uid>,
    public decl:Ty_view_decl<Uid,_V_tyreg_poly_ty,Void>,
    public clique:undefined | Clique,
    public timeout:undefined | bigint) {}
}

export function Ty_view_def_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Ty_view_def_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 5)
  const name = Uid_of_twine(d, fields[0])
  const params = d.get_array(fields[1]).toArray().map(x => Uid_of_twine(d, x))
  const decl = Ty_view_decl_of_twine(d,((d:twine.Decoder,off:offset) => Uid_of_twine(d, off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)), ((d:twine.Decoder,off:offset) => Void_of_twine(d, off)),fields[2])
  const clique = twine.optional(d,  ((d:twine.Decoder,off:offset) => Clique_of_twine(d, off)), fields[3])
  const timeout = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[4])
  return new Ty_view_def_poly(name, params, decl, clique, timeout)
}

// clique Imandrax_api.Sub_anchor.fname (cached: false)
// def Imandrax_api.Sub_anchor.fname (mangled name: "Sub_anchor_fname")
export type Sub_anchor_fname = string;

export function Sub_anchor_fname_of_twine(d: twine.Decoder, off: offset): Sub_anchor_fname {
  return d.get_str(off)
}

// clique Imandrax_api.Sub_anchor.t (cached: false)
// def Imandrax_api.Sub_anchor.t (mangled name: "Sub_anchor")
export class Sub_anchor {
  constructor(
    public fname:Sub_anchor_fname,
    public anchor:bigint) {}
}

export function Sub_anchor_of_twine(d: twine.Decoder, off: offset): Sub_anchor {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const fname = Sub_anchor_fname_of_twine(d, fields[0])
  const anchor = d.get_int(fields[1])
  return new Sub_anchor(fname, anchor)
}

// clique Imandrax_api.Stat_time.t (cached: false)
// def Imandrax_api.Stat_time.t (mangled name: "Stat_time")
export class Stat_time {
  constructor(
    public time_s:number) {}
}

export function Stat_time_of_twine(d: twine.Decoder, off: offset): Stat_time {
  const x = d.get_float(off) // single unboxed field
  return new Stat_time(x)
}

// clique Imandrax_api.Misc_types.rec_flag (cached: false)
// def Imandrax_api.Misc_types.rec_flag (mangled name: "Misc_types_rec_flag")
export class Misc_types_rec_flag_Recursive {
  constructor(){}
}
export class Misc_types_rec_flag_Nonrecursive {
  constructor(){}
}
export type Misc_types_rec_flag = Misc_types_rec_flag_Recursive| Misc_types_rec_flag_Nonrecursive

export function Misc_types_rec_flag_of_twine(d: twine.Decoder, off: offset): Misc_types_rec_flag {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Misc_types_rec_flag_Recursive()
   case 1:
     return new Misc_types_rec_flag_Nonrecursive()
   default:
      throw new twine.TwineError({msg: `expected Misc_types_rec_flag, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Misc_types.apply_label (cached: false)
// def Imandrax_api.Misc_types.apply_label (mangled name: "Misc_types_apply_label")
export class Misc_types_apply_label_Nolabel {
  constructor(){}
}
export class Misc_types_apply_label_Label {
  constructor(public arg: string) {}
}
export function Misc_types_apply_label_Label_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Misc_types_apply_label_Label {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Misc_types_apply_label_Label(arg)
}
export class Misc_types_apply_label_Optional {
  constructor(public arg: string) {}
}
export function Misc_types_apply_label_Optional_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Misc_types_apply_label_Optional {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Misc_types_apply_label_Optional(arg)
}
export type Misc_types_apply_label = Misc_types_apply_label_Nolabel| Misc_types_apply_label_Label| Misc_types_apply_label_Optional

export function Misc_types_apply_label_of_twine(d: twine.Decoder, off: offset): Misc_types_apply_label {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Misc_types_apply_label_Nolabel()
   case 1:
      return Misc_types_apply_label_Label_of_twine(d,  c.args, off)
   case 2:
      return Misc_types_apply_label_Optional_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Misc_types_apply_label, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Logic_fragment.t (cached: false)
// def Imandrax_api.Logic_fragment.t (mangled name: "Logic_fragment")
export type Logic_fragment = bigint;

export function Logic_fragment_of_twine(d: twine.Decoder, off: offset): Logic_fragment {
  return d.get_int(off)
}

// clique Imandrax_api.In_mem_archive.raw (cached: false)
// def Imandrax_api.In_mem_archive.raw (mangled name: "In_mem_archive_raw")
export class In_mem_archive_raw {
  constructor(
    public ty:string,
    public compressed:boolean,
    public data:Uint8Array) {}
}

export function In_mem_archive_raw_of_twine(d: twine.Decoder, off: offset): In_mem_archive_raw {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const ty = d.get_str(fields[0])
  const compressed = d.get_bool(fields[1])
  const data = d.get_bytes(fields[2])
  return new In_mem_archive_raw(ty, compressed, data)
}

// clique Imandrax_api.In_mem_archive.t (cached: false)
// def Imandrax_api.In_mem_archive.t (mangled name: "In_mem_archive")
export type In_mem_archive<_V_tyreg_poly_a> = In_mem_archive_raw;

export function In_mem_archive_of_twine<_V_tyreg_poly_a>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a,off: offset): In_mem_archive<_V_tyreg_poly_a> {
 decode__tyreg_poly_a; // ignore
  return In_mem_archive_raw_of_twine(d, off)
}

// clique Imandrax_api.Const.t (cached: false)
// def Imandrax_api.Const.t (mangled name: "Const")
export class Const_Const_float {
  constructor(public arg: number) {}
}
export function Const_Const_float_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_float {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_float(_tw_args[0])
  return new Const_Const_float(arg)
}
export class Const_Const_string {
  constructor(public arg: string) {}
}
export function Const_Const_string_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_string {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Const_Const_string(arg)
}
export class Const_Const_z {
  constructor(public arg: bigint) {}
}
export function Const_Const_z_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_z {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Const_Const_z(arg)
}
export class Const_Const_q {
  constructor(public arg: [bigint, bigint]) {}
}
export function Const_Const_q_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_q {
  checkArrayLength(off, _tw_args, 1)
  const arg = decode_q(d,_tw_args[0])
  return new Const_Const_q(arg)
}
export class Const_Const_real_approx {
  constructor(public arg: string) {}
}
export function Const_Const_real_approx_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_real_approx {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Const_Const_real_approx(arg)
}
export class Const_Const_uid {
  constructor(public arg: Uid) {}
}
export function Const_Const_uid_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_uid {
  checkArrayLength(off, _tw_args, 1)
  const arg = Uid_of_twine(d, _tw_args[0])
  return new Const_Const_uid(arg)
}
export class Const_Const_bool {
  constructor(public arg: boolean) {}
}
export function Const_Const_bool_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Const_Const_bool {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_bool(_tw_args[0])
  return new Const_Const_bool(arg)
}
export type Const = Const_Const_float| Const_Const_string| Const_Const_z| Const_Const_q| Const_Const_real_approx| Const_Const_uid| Const_Const_bool

export function Const_of_twine(d: twine.Decoder, off: offset): Const {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Const_Const_float_of_twine(d,  c.args, off)
   case 1:
      return Const_Const_string_of_twine(d,  c.args, off)
   case 2:
      return Const_Const_z_of_twine(d,  c.args, off)
   case 3:
      return Const_Const_q_of_twine(d,  c.args, off)
   case 4:
      return Const_Const_real_approx_of_twine(d,  c.args, off)
   case 5:
      return Const_Const_uid_of_twine(d,  c.args, off)
   case 6:
      return Const_Const_bool_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Const, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Case_poly.t_poly (cached: false)
// def Imandrax_api.Case_poly.t_poly (mangled name: "Case_poly_t_poly")
export class Case_poly_t_poly<_V_tyreg_poly_t,_V_tyreg_poly_var,_V_tyreg_poly_sym> {
  constructor(
    public case_cstor:_V_tyreg_poly_sym,
    public case_vars:Array<_V_tyreg_poly_var>,
    public case_rhs:_V_tyreg_poly_t,
    public case_labels:undefined | Array<Uid>) {}
}

export function Case_poly_t_poly_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_var,_V_tyreg_poly_sym>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_var: (d:twine.Decoder, off:offset) => _V_tyreg_poly_var, decode__tyreg_poly_sym: (d:twine.Decoder, off:offset) => _V_tyreg_poly_sym,off: offset): Case_poly_t_poly<_V_tyreg_poly_t,_V_tyreg_poly_var,_V_tyreg_poly_sym> {
    decode__tyreg_poly_t
    decode__tyreg_poly_var
    decode__tyreg_poly_sym
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const case_cstor = decode__tyreg_poly_sym(d,fields[0])
  const case_vars = d.get_array(fields[1]).toArray().map(x => decode__tyreg_poly_var(d,x))
  const case_rhs = decode__tyreg_poly_t(d,fields[2])
  const case_labels = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_array(off).toArray().map(x => Uid_of_twine(d, x))), fields[3])
  return new Case_poly_t_poly(case_cstor, case_vars, case_rhs, case_labels)
}

// clique Imandrax_api.As_trigger.t (cached: false)
// def Imandrax_api.As_trigger.t (mangled name: "As_trigger")
export class As_trigger_Trig_none {
  constructor(){}
}
export class As_trigger_Trig_anon {
  constructor(){}
}
export class As_trigger_Trig_named {
  constructor(public arg: bigint) {}
}
export function As_trigger_Trig_named_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): As_trigger_Trig_named {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new As_trigger_Trig_named(arg)
}
export class As_trigger_Trig_rw {
  constructor(){}
}
export type As_trigger = As_trigger_Trig_none| As_trigger_Trig_anon| As_trigger_Trig_named| As_trigger_Trig_rw

export function As_trigger_of_twine(d: twine.Decoder, off: offset): As_trigger {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new As_trigger_Trig_none()
   case 1:
     return new As_trigger_Trig_anon()
   case 2:
      return As_trigger_Trig_named_of_twine(d,  c.args, off)
   case 3:
     return new As_trigger_Trig_rw()
   default:
      throw new twine.TwineError({msg: `expected As_trigger, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api.Anchor.t (cached: false)
// def Imandrax_api.Anchor.t (mangled name: "Anchor")
export class Anchor_Named {
  constructor(public arg: Cname) {}
}
export function Anchor_Named_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Anchor_Named {
  checkArrayLength(off, _tw_args, 1)
  const arg = Cname_of_twine(d, _tw_args[0])
  return new Anchor_Named(arg)
}
export class Anchor_Eval {
  constructor(public arg: bigint) {}
}
export function Anchor_Eval_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Anchor_Eval {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Anchor_Eval(arg)
}
export class Anchor_Proof_check {
  constructor(public arg: Anchor) {}
}
export function Anchor_Proof_check_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Anchor_Proof_check {
  checkArrayLength(off, _tw_args, 1)
  const arg = Anchor_of_twine(d, _tw_args[0])
  return new Anchor_Proof_check(arg)
}
export class Anchor_Decomp {
  constructor(public arg: Anchor) {}
}
export function Anchor_Decomp_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Anchor_Decomp {
  checkArrayLength(off, _tw_args, 1)
  const arg = Anchor_of_twine(d, _tw_args[0])
  return new Anchor_Decomp(arg)
}
export type Anchor = Anchor_Named| Anchor_Eval| Anchor_Proof_check| Anchor_Decomp

export function Anchor_of_twine(d: twine.Decoder, off: offset): Anchor {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Anchor_Named_of_twine(d,  c.args, off)
   case 1:
      return Anchor_Eval_of_twine(d,  c.args, off)
   case 2:
      return Anchor_Proof_check_of_twine(d,  c.args, off)
   case 3:
      return Anchor_Decomp_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Anchor, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_ca_store.Key.t (cached: false)
// def Imandrax_api_ca_store.Key.t (mangled name: "Ca_store_Key")
export type Ca_store_Key = WithTag7<string>;

export function Ca_store_Key_of_twine(d: twine.Decoder, off: offset): Ca_store_Key {
  return decode_with_tag(7, d, off, ((d:twine.Decoder,off:offset) => d.get_str(off)))
}

// clique Imandrax_api_ca_store.Ca_ptr.Raw.t (cached: false)
// def Imandrax_api_ca_store.Ca_ptr.Raw.t (mangled name: "Ca_store_Ca_ptr_Raw")
export class Ca_store_Ca_ptr_Raw {
  constructor(
    public key:Ca_store_Key) {}
}

export function Ca_store_Ca_ptr_Raw_of_twine(d: twine.Decoder, off: offset): Ca_store_Ca_ptr_Raw {
  const x = Ca_store_Key_of_twine(d, off) // single unboxed field
  return new Ca_store_Ca_ptr_Raw(x)
}

// clique Imandrax_api_ca_store.Ca_ptr.t (cached: false)
// def Imandrax_api_ca_store.Ca_ptr.t (mangled name: "Ca_store_Ca_ptr")
export type Ca_store_Ca_ptr<_V_tyreg_poly_a> = Ca_store_Ca_ptr_Raw;

export function Ca_store_Ca_ptr_of_twine<_V_tyreg_poly_a>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a,off: offset): Ca_store_Ca_ptr<_V_tyreg_poly_a> {
 decode__tyreg_poly_a; // ignore
  return Ca_store_Ca_ptr_Raw_of_twine(d, off)
}

// clique Imandrax_api_common.Admission.t (cached: false)
// def Imandrax_api_common.Admission.t (mangled name: "Common_Admission")
export class Common_Admission {
  constructor(
    public measured_subset:Array<string>,
    public measure_fun:undefined | Uid) {}
}

export function Common_Admission_of_twine(d: twine.Decoder, off: offset): Common_Admission {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const measured_subset = d.get_array(fields[0]).toArray().map(x => d.get_str(x))
  const measure_fun = twine.optional(d,  ((d:twine.Decoder,off:offset) => Uid_of_twine(d, off)), fields[1])
  return new Common_Admission(measured_subset, measure_fun)
}

// clique Imandrax_api_common.Var.t_poly (cached: false)
// def Imandrax_api_common.Var.t_poly (mangled name: "Common_Var_t_poly")
export class Common_Var_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public id:Uid,
    public ty:_V_tyreg_poly_ty) {}
}

export function Common_Var_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Var_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const id = Uid_of_twine(d, fields[0])
  const ty = decode__tyreg_poly_ty(d,fields[1])
  return new Common_Var_t_poly(id, ty)
}

// clique Imandrax_api_common.Hints.validation_strategy (cached: false)
// def Imandrax_api_common.Hints.validation_strategy (mangled name: "Common_Hints_validation_strategy")
export class Common_Hints_validation_strategy_VS_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public tactic: undefined | [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term]){}
}

export function Common_Hints_validation_strategy_VS_validate_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Hints_validation_strategy_VS_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 1)
  const tactic = twine.optional(d,  ((d:twine.Decoder,off:offset) => ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(off, tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(off).toArray())), _tw_args[0])
  return new Common_Hints_validation_strategy_VS_validate(tactic)
}
export class Common_Hints_validation_strategy_VS_no_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(){}
}
export type Common_Hints_validation_strategy<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Hints_validation_strategy_VS_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Hints_validation_strategy_VS_no_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Hints_validation_strategy_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Hints_validation_strategy<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Hints_validation_strategy_VS_validate_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
     return new Common_Hints_validation_strategy_VS_no_validate<_V_tyreg_poly_term,_V_tyreg_poly_ty>()
   default:
      throw new twine.TwineError({msg: `expected Common_Hints_validation_strategy, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Hints.t_poly (cached: false)
// def Imandrax_api_common.Hints.t_poly (mangled name: "Common_Hints_t_poly")
export class Common_Hints_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public f_validate_strat:Common_Hints_validation_strategy<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public f_unroll_def:undefined | bigint,
    public f_enable:Array<Uid>,
    public f_disable:Array<Uid>,
    public f_timeout:undefined | bigint,
    public f_admission:undefined | Common_Admission,
    public f_decomp:undefined | _V_tyreg_poly_term) {}
}

export function Common_Hints_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Hints_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const f_validate_strat = Common_Hints_validation_strategy_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const f_unroll_def = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[1])
  const f_enable = d.get_array(fields[2]).toArray().map(x => Uid_of_twine(d, x))
  const f_disable = d.get_array(fields[3]).toArray().map(x => Uid_of_twine(d, x))
  const f_timeout = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[4])
  const f_admission = twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Admission_of_twine(d, off)), fields[5])
  const f_decomp = twine.optional(d,  ((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), fields[6])
  return new Common_Hints_t_poly(f_validate_strat, f_unroll_def, f_enable, f_disable, f_timeout, f_admission, f_decomp)
}

// clique Imandrax_api_common.Type_schema.t_poly (cached: false)
// def Imandrax_api_common.Type_schema.t_poly (mangled name: "Common_Type_schema_t_poly")
export class Common_Type_schema_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public params:Array<Uid>,
    public ty:_V_tyreg_poly_ty) {}
}

export function Common_Type_schema_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Type_schema_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const params = d.get_array(fields[0]).toArray().map(x => Uid_of_twine(d, x))
  const ty = decode__tyreg_poly_ty(d,fields[1])
  return new Common_Type_schema_t_poly(params, ty)
}

// clique Imandrax_api_common.Fun_def.fun_kind (cached: false)
// def Imandrax_api_common.Fun_def.fun_kind (mangled name: "Common_Fun_def_fun_kind")
export class Common_Fun_def_fun_kind_Fun_defined {
  constructor(
    public is_macro: boolean,
    public from_lambda: boolean){}
}

export function Common_Fun_def_fun_kind_Fun_defined_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Common_Fun_def_fun_kind_Fun_defined {
  checkArrayLength(off, _tw_args, 2)
  const is_macro = d.get_bool(_tw_args[0])
  const from_lambda = d.get_bool(_tw_args[1])
  return new Common_Fun_def_fun_kind_Fun_defined(is_macro,from_lambda)
}
export class Common_Fun_def_fun_kind_Fun_builtin {
  constructor(public arg: Builtin_Fun) {}
}
export function Common_Fun_def_fun_kind_Fun_builtin_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Common_Fun_def_fun_kind_Fun_builtin {
  checkArrayLength(off, _tw_args, 1)
  const arg = Builtin_Fun_of_twine(d, _tw_args[0])
  return new Common_Fun_def_fun_kind_Fun_builtin(arg)
}
export class Common_Fun_def_fun_kind_Fun_opaque {
  constructor(){}
}
export type Common_Fun_def_fun_kind = Common_Fun_def_fun_kind_Fun_defined| Common_Fun_def_fun_kind_Fun_builtin| Common_Fun_def_fun_kind_Fun_opaque

export function Common_Fun_def_fun_kind_of_twine(d: twine.Decoder, off: offset): Common_Fun_def_fun_kind {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Fun_def_fun_kind_Fun_defined_of_twine(d,  c.args, off)
   case 1:
      return Common_Fun_def_fun_kind_Fun_builtin_of_twine(d,  c.args, off)
   case 2:
     return new Common_Fun_def_fun_kind_Fun_opaque()
   default:
      throw new twine.TwineError({msg: `expected Common_Fun_def_fun_kind, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Fun_def.t_poly (cached: false)
// def Imandrax_api_common.Fun_def.t_poly (mangled name: "Common_Fun_def_t_poly")
export class Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public f_name:Uid,
    public f_ty:Common_Type_schema_t_poly<_V_tyreg_poly_ty>,
    public f_args:Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,
    public f_body:_V_tyreg_poly_term,
    public f_clique:undefined | Clique,
    public f_kind:Common_Fun_def_fun_kind,
    public f_hints:Common_Hints_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}

export function Common_Fun_def_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const f_name = Uid_of_twine(d, fields[0])
  const f_ty = Common_Type_schema_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const f_args = d.get_array(fields[2]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const f_body = decode__tyreg_poly_term(d,fields[3])
  const f_clique = twine.optional(d,  ((d:twine.Decoder,off:offset) => Clique_of_twine(d, off)), fields[4])
  const f_kind = Common_Fun_def_fun_kind_of_twine(d, fields[5])
  const f_hints = Common_Hints_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[6])
  return new Common_Fun_def_t_poly(f_name, f_ty, f_args, f_body, f_clique, f_kind, f_hints)
}

// clique Imandrax_api_common.Verify.t_poly (cached: false)
// def Imandrax_api_common.Verify.t_poly (mangled name: "Common_Verify_t_poly")
export class Common_Verify_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public verify_link:Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public verify_simplify:boolean,
    public verify_nonlin:boolean,
    public verify_upto:undefined | Upto,
    public verify_is_instance:boolean,
    public verify_minimize:Array<_V_tyreg_poly_term>,
    public verify_by:undefined | [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term]) {}
}

export function Common_Verify_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Verify_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const verify_link = Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const verify_simplify = d.get_bool(fields[1])
  const verify_nonlin = d.get_bool(fields[2])
  const verify_upto = twine.optional(d,  ((d:twine.Decoder,off:offset) => Upto_of_twine(d, off)), fields[3])
  const verify_is_instance = d.get_bool(fields[4])
  const verify_minimize = d.get_array(fields[5]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const verify_by = twine.optional(d,  ((d:twine.Decoder,off:offset) => ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(off, tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(off).toArray())), fields[6])
  return new Common_Verify_t_poly(verify_link, verify_simplify, verify_nonlin, verify_upto, verify_is_instance, verify_minimize, verify_by)
}

// clique Imandrax_api_common.Typed_symbol.t_poly (cached: false)
// def Imandrax_api_common.Typed_symbol.t_poly (mangled name: "Common_Typed_symbol_t_poly")
export class Common_Typed_symbol_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public id:Uid,
    public ty:Common_Type_schema_t_poly<_V_tyreg_poly_ty>) {}
}

export function Common_Typed_symbol_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Typed_symbol_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const id = Uid_of_twine(d, fields[0])
  const ty = Common_Type_schema_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  return new Common_Typed_symbol_t_poly(id, ty)
}

// clique Imandrax_api_common.Applied_symbol.t_poly (cached: false)
// def Imandrax_api_common.Applied_symbol.t_poly (mangled name: "Common_Applied_symbol_t_poly")
export class Common_Applied_symbol_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public sym:Common_Typed_symbol_t_poly<_V_tyreg_poly_ty>,
    public args:Array<_V_tyreg_poly_ty>,
    public ty:_V_tyreg_poly_ty) {}
}

export function Common_Applied_symbol_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Applied_symbol_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const sym = Common_Typed_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const args = d.get_array(fields[1]).toArray().map(x => decode__tyreg_poly_ty(d,x))
  const ty = decode__tyreg_poly_ty(d,fields[2])
  return new Common_Applied_symbol_t_poly(sym, args, ty)
}

// clique Imandrax_api_common.Fo_pattern.view (cached: false)
// def Imandrax_api_common.Fo_pattern.view (mangled name: "Common_Fo_pattern_view")
export class Common_Fo_pattern_view_FO_any<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(){}
}
export class Common_Fo_pattern_view_FO_bool<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: boolean) {}
}
export function Common_Fo_pattern_view_FO_bool_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_bool<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_bool(_tw_args[0])
  return new Common_Fo_pattern_view_FO_bool(arg)
}
export class Common_Fo_pattern_view_FO_const<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: Const) {}
}
export function Common_Fo_pattern_view_FO_const_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_const<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Const_of_twine(d, _tw_args[0])
  return new Common_Fo_pattern_view_FO_const(arg)
}
export class Common_Fo_pattern_view_FO_var<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Var_t_poly<_V_tyreg_poly_ty>) {}
}
export function Common_Fo_pattern_view_FO_var_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_var<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Fo_pattern_view_FO_var(arg)
}
export class Common_Fo_pattern_view_FO_app<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public args: [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,Array<_V_tyreg_poly_t>]){}
}
export function Common_Fo_pattern_view_FO_app_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_app<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,Array<_V_tyreg_poly_t>] = [Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_t(d,x))]
  return new Common_Fo_pattern_view_FO_app(cargs)
}
export class Common_Fo_pattern_view_FO_cstor<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: undefined | Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public args: Array<_V_tyreg_poly_t>,
    public labels: undefined | Array<Uid>){}
}

export function Common_Fo_pattern_view_FO_cstor_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_cstor<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 3)
  const c = twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), _tw_args[0])
  const args = d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_t(d,x))
  const labels = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_array(off).toArray().map(x => Uid_of_twine(d, x))), _tw_args[2])
  return new Common_Fo_pattern_view_FO_cstor(c,args,labels)
}
export class Common_Fo_pattern_view_FO_destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: undefined | Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public i: bigint,
    public u: _V_tyreg_poly_t){}
}

export function Common_Fo_pattern_view_FO_destruct_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 3)
  const c = twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), _tw_args[0])
  const i = d.get_int(_tw_args[1])
  const u = decode__tyreg_poly_t(d,_tw_args[2])
  return new Common_Fo_pattern_view_FO_destruct(c,i,u)
}
export class Common_Fo_pattern_view_FO_is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public u: _V_tyreg_poly_t){}
}

export function Common_Fo_pattern_view_FO_is_a_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Fo_pattern_view_FO_is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const c = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  const u = decode__tyreg_poly_t(d,_tw_args[1])
  return new Common_Fo_pattern_view_FO_is_a(c,u)
}
export type Common_Fo_pattern_view<_V_tyreg_poly_t,_V_tyreg_poly_ty> = Common_Fo_pattern_view_FO_any<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_bool<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_const<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_var<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_app<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_cstor<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Common_Fo_pattern_view_FO_is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty>

export function Common_Fo_pattern_view_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Fo_pattern_view<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Common_Fo_pattern_view_FO_any<_V_tyreg_poly_t,_V_tyreg_poly_ty>()
   case 1:
      return Common_Fo_pattern_view_FO_bool_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Common_Fo_pattern_view_FO_const_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Common_Fo_pattern_view_FO_var_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Common_Fo_pattern_view_FO_app_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 5:
      return Common_Fo_pattern_view_FO_cstor_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 6:
      return Common_Fo_pattern_view_FO_destruct_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 7:
      return Common_Fo_pattern_view_FO_is_a_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Fo_pattern_view, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Fo_pattern.t_poly (cached: false)
// def Imandrax_api_common.Fo_pattern.t_poly (mangled name: "Common_Fo_pattern_t_poly")
export class Common_Fo_pattern_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public view:Common_Fo_pattern_view<Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_ty>,
    public ty:_V_tyreg_poly_ty) {}
}

export function Common_Fo_pattern_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Fo_pattern_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const view = Common_Fo_pattern_view_of_twine(d,((d:twine.Decoder,off:offset) => Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const ty = decode__tyreg_poly_ty(d,fields[1])
  return new Common_Fo_pattern_t_poly(view, ty)
}

// clique Imandrax_api_common.Pattern_head.t_poly (cached: false)
// def Imandrax_api_common.Pattern_head.t_poly (mangled name: "Common_Pattern_head_t_poly")
export class Common_Pattern_head_t_poly_PH_id<_V_tyreg_poly_ty> {
  constructor(public arg: Uid) {}
}
export function Common_Pattern_head_t_poly_PH_id_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Pattern_head_t_poly_PH_id<_V_tyreg_poly_ty> {
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Uid_of_twine(d, _tw_args[0])
  return new Common_Pattern_head_t_poly_PH_id(arg)
}
export class Common_Pattern_head_t_poly_PH_ty<_V_tyreg_poly_ty> {
  constructor(public arg: _V_tyreg_poly_ty) {}
}
export function Common_Pattern_head_t_poly_PH_ty_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Pattern_head_t_poly_PH_ty<_V_tyreg_poly_ty> {
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_ty(d,_tw_args[0])
  return new Common_Pattern_head_t_poly_PH_ty(arg)
}
export class Common_Pattern_head_t_poly_PH_datatype_op<_V_tyreg_poly_ty> {
  constructor(){}
}
export type Common_Pattern_head_t_poly<_V_tyreg_poly_ty> = Common_Pattern_head_t_poly_PH_id<_V_tyreg_poly_ty>| Common_Pattern_head_t_poly_PH_ty<_V_tyreg_poly_ty>| Common_Pattern_head_t_poly_PH_datatype_op<_V_tyreg_poly_ty>

export function Common_Pattern_head_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Pattern_head_t_poly<_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Pattern_head_t_poly_PH_id_of_twine(d, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Common_Pattern_head_t_poly_PH_ty_of_twine(d, decode__tyreg_poly_ty, c.args, off)
   case 2:
     return new Common_Pattern_head_t_poly_PH_datatype_op<_V_tyreg_poly_ty>()
   default:
      throw new twine.TwineError({msg: `expected Common_Pattern_head_t_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Trigger.t_poly (cached: false)
// def Imandrax_api_common.Trigger.t_poly (mangled name: "Common_Trigger_t_poly")
export class Common_Trigger_t_poly<_V_tyreg_poly_ty> {
  constructor(
    public trigger_head:Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,
    public trigger_patterns:Array<Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>>,
    public trigger_instantiation_rule_name:Uid) {}
}

export function Common_Trigger_t_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Trigger_t_poly<_V_tyreg_poly_ty> {
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const trigger_head = Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const trigger_patterns = d.get_array(fields[1]).toArray().map(x => Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const trigger_instantiation_rule_name = Uid_of_twine(d, fields[2])
  return new Common_Trigger_t_poly(trigger_head, trigger_patterns, trigger_instantiation_rule_name)
}

// clique Imandrax_api_common.Pre_trigger.t_poly (cached: false)
// def Imandrax_api_common.Pre_trigger.t_poly (mangled name: "Common_Pre_trigger_t_poly")
export type Common_Pre_trigger_t_poly<_V_tyreg_poly_term> = [_V_tyreg_poly_term,As_trigger];

export function Common_Pre_trigger_t_poly_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Common_Pre_trigger_t_poly<_V_tyreg_poly_term> {
 decode__tyreg_poly_term; // ignore
  return ((tup : Array<offset>): [_V_tyreg_poly_term,As_trigger] => { checkArrayLength(off, tup, 2); return [decode__tyreg_poly_term(d,tup[0]), As_trigger_of_twine(d, tup[1])] })(d.get_array(off).toArray())
}

// clique Imandrax_api_common.Theorem.t_poly (cached: false)
// def Imandrax_api_common.Theorem.t_poly (mangled name: "Common_Theorem_t_poly")
export class Common_Theorem_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public thm_link:Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public thm_rewriting:boolean,
    public thm_perm_restrict:boolean,
    public thm_fc:boolean,
    public thm_elim:boolean,
    public thm_gen:boolean,
    public thm_triggers:Array<Common_Pre_trigger_t_poly<_V_tyreg_poly_term>>,
    public thm_is_axiom:boolean,
    public thm_by:[Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term]) {}
}

export function Common_Theorem_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Theorem_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 9)
  const thm_link = Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const thm_rewriting = d.get_bool(fields[1])
  const thm_perm_restrict = d.get_bool(fields[2])
  const thm_fc = d.get_bool(fields[3])
  const thm_elim = d.get_bool(fields[4])
  const thm_gen = d.get_bool(fields[5])
  const thm_triggers = d.get_array(fields[6]).toArray().map(x => Common_Pre_trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  const thm_is_axiom = d.get_bool(fields[7])
  const thm_by = ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(fields[8], tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(fields[8]).toArray())
  return new Common_Theorem_t_poly(thm_link, thm_rewriting, thm_perm_restrict, thm_fc, thm_elim, thm_gen, thm_triggers, thm_is_axiom, thm_by)
}

// clique Imandrax_api_common.Tactic.t_poly (cached: false)
// def Imandrax_api_common.Tactic.t_poly (mangled name: "Common_Tactic_t_poly")
export class Common_Tactic_t_poly_Default_termination<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public max_steps: bigint,
    public basis: Uid_set){}
}

export function Common_Tactic_t_poly_Default_termination_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Tactic_t_poly_Default_termination<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const max_steps = d.get_int(_tw_args[0])
  const basis = Uid_set_of_twine(d, _tw_args[1])
  return new Common_Tactic_t_poly_Default_termination(max_steps,basis)
}
export class Common_Tactic_t_poly_Default_thm<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public max_steps: bigint,
    public upto: undefined | Upto){}
}

export function Common_Tactic_t_poly_Default_thm_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Tactic_t_poly_Default_thm<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const max_steps = d.get_int(_tw_args[0])
  const upto = twine.optional(d,  ((d:twine.Decoder,off:offset) => Upto_of_twine(d, off)), _tw_args[1])
  return new Common_Tactic_t_poly_Default_thm(max_steps,upto)
}
export class Common_Tactic_t_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term]) {}
}
export function Common_Tactic_t_poly_Term_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Tactic_t_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(_tw_args[0], tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(_tw_args[0]).toArray())
  return new Common_Tactic_t_poly_Term(arg)
}
export type Common_Tactic_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Tactic_t_poly_Default_termination<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Tactic_t_poly_Default_thm<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Tactic_t_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Tactic_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Tactic_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Tactic_t_poly_Default_termination_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Common_Tactic_t_poly_Default_thm_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Common_Tactic_t_poly_Term_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Tactic_t_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Sequent.t_poly (cached: false)
// def Imandrax_api_common.Sequent.t_poly (mangled name: "Common_Sequent_t_poly")
export class Common_Sequent_t_poly<_V_tyreg_poly_term> {
  constructor(
    public hyps:Array<_V_tyreg_poly_term>,
    public concls:Array<_V_tyreg_poly_term>) {}
}

export function Common_Sequent_t_poly_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Common_Sequent_t_poly<_V_tyreg_poly_term> {
    decode__tyreg_poly_term
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const hyps = d.get_array(fields[0]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const concls = d.get_array(fields[1]).toArray().map(x => decode__tyreg_poly_term(d,x))
  return new Common_Sequent_t_poly(hyps, concls)
}

// clique Imandrax_api_common.Rule_spec.t_poly (cached: false)
// def Imandrax_api_common.Rule_spec.t_poly (mangled name: "Common_Rule_spec_t_poly")
export class Common_Rule_spec_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public rule_spec_fc:boolean,
    public rule_spec_rewriting:boolean,
    public rule_spec_perm_restrict:boolean,
    public rule_spec_link:Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public rule_spec_triggers:Array<Common_Pre_trigger_t_poly<_V_tyreg_poly_term>>) {}
}

export function Common_Rule_spec_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Rule_spec_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 5)
  const rule_spec_fc = d.get_bool(fields[0])
  const rule_spec_rewriting = d.get_bool(fields[1])
  const rule_spec_perm_restrict = d.get_bool(fields[2])
  const rule_spec_link = Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[3])
  const rule_spec_triggers = d.get_array(fields[4]).toArray().map(x => Common_Pre_trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  return new Common_Rule_spec_t_poly(rule_spec_fc, rule_spec_rewriting, rule_spec_perm_restrict, rule_spec_link, rule_spec_triggers)
}

// clique Imandrax_api_common.Rewrite_rule.t_poly (cached: false)
// def Imandrax_api_common.Rewrite_rule.t_poly (mangled name: "Common_Rewrite_rule_t_poly")
export class Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public rw_name:Uid,
    public rw_head:Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,
    public rw_lhs:Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>,
    public rw_rhs:_V_tyreg_poly_term,
    public rw_guard:Array<_V_tyreg_poly_term>,
    public rw_vars:Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,
    public rw_triggers:Array<Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>>,
    public rw_perm_restrict:boolean,
    public rw_loop_break:undefined | Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>) {}
}

export function Common_Rewrite_rule_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 9)
  const rw_name = Uid_of_twine(d, fields[0])
  const rw_head = Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const rw_lhs = Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[2])
  const rw_rhs = decode__tyreg_poly_term(d,fields[3])
  const rw_guard = d.get_array(fields[4]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const rw_vars = d.get_array(fields[5]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const rw_triggers = d.get_array(fields[6]).toArray().map(x => Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const rw_perm_restrict = d.get_bool(fields[7])
  const rw_loop_break = twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), fields[8])
  return new Common_Rewrite_rule_t_poly(rw_name, rw_head, rw_lhs, rw_rhs, rw_guard, rw_vars, rw_triggers, rw_perm_restrict, rw_loop_break)
}

// clique Imandrax_api_common.Model.ty_def (cached: false)
// def Imandrax_api_common.Model.ty_def (mangled name: "Common_Model_ty_def")
export class Common_Model_ty_def_Ty_finite<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<_V_tyreg_poly_term>) {}
}
export function Common_Model_ty_def_Ty_finite_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Model_ty_def_Ty_finite<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => decode__tyreg_poly_term(d,x))
  return new Common_Model_ty_def_Ty_finite(arg)
}
export class Common_Model_ty_def_Ty_alias_unit<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: _V_tyreg_poly_ty) {}
}
export function Common_Model_ty_def_Ty_alias_unit_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Model_ty_def_Ty_alias_unit<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_ty(d,_tw_args[0])
  return new Common_Model_ty_def_Ty_alias_unit(arg)
}
export type Common_Model_ty_def<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Model_ty_def_Ty_finite<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Model_ty_def_Ty_alias_unit<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Model_ty_def_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Model_ty_def<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Model_ty_def_Ty_finite_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Common_Model_ty_def_Ty_alias_unit_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Model_ty_def, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Model.fi (cached: false)
// def Imandrax_api_common.Model.fi (mangled name: "Common_Model_fi")
export class Common_Model_fi<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public fi_args:Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,
    public fi_ty_ret:_V_tyreg_poly_ty,
    public fi_cases:Array<[Array<_V_tyreg_poly_term>,_V_tyreg_poly_term]>,
    public fi_else:_V_tyreg_poly_term) {}
}

export function Common_Model_fi_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Model_fi<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const fi_args = d.get_array(fields[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const fi_ty_ret = decode__tyreg_poly_ty(d,fields[1])
  const fi_cases = d.get_array(fields[2]).toArray().map(x => ((tup : Array<offset>): [Array<_V_tyreg_poly_term>,_V_tyreg_poly_term] => { checkArrayLength(x, tup, 2); return [d.get_array(tup[0]).toArray().map(x => decode__tyreg_poly_term(d,x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(x).toArray()))
  const fi_else = decode__tyreg_poly_term(d,fields[3])
  return new Common_Model_fi(fi_args, fi_ty_ret, fi_cases, fi_else)
}

// clique Imandrax_api_common.Model.t_poly (cached: false)
// def Imandrax_api_common.Model.t_poly (mangled name: "Common_Model_t_poly")
export class Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public tys:Array<[_V_tyreg_poly_ty,Common_Model_ty_def<_V_tyreg_poly_term,_V_tyreg_poly_ty>]>,
    public consts:Array<[Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_term]>,
    public funs:Array<[Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,Common_Model_fi<_V_tyreg_poly_term,_V_tyreg_poly_ty>]>,
    public representable:boolean,
    public completed:boolean,
    public ty_subst:Array<[Uid,_V_tyreg_poly_ty]>) {}
}

export function Common_Model_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 6)
  const tys = d.get_array(fields[0]).toArray().map(x => ((tup : Array<offset>): [_V_tyreg_poly_ty,Common_Model_ty_def<_V_tyreg_poly_term,_V_tyreg_poly_ty>] => { checkArrayLength(x, tup, 2); return [decode__tyreg_poly_ty(d,tup[0]), Common_Model_ty_def_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[1])] })(d.get_array(x).toArray()))
  const consts = d.get_array(fields[1]).toArray().map(x => ((tup : Array<offset>): [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_term] => { checkArrayLength(x, tup, 2); return [Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[0]), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(x).toArray()))
  const funs = d.get_array(fields[2]).toArray().map(x => ((tup : Array<offset>): [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,Common_Model_fi<_V_tyreg_poly_term,_V_tyreg_poly_ty>] => { checkArrayLength(x, tup, 2); return [Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[0]), Common_Model_fi_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[1])] })(d.get_array(x).toArray()))
  const representable = d.get_bool(fields[3])
  const completed = d.get_bool(fields[4])
  const ty_subst = d.get_array(fields[5]).toArray().map(x => ((tup : Array<offset>): [Uid,_V_tyreg_poly_ty] => { checkArrayLength(x, tup, 2); return [Uid_of_twine(d, tup[0]), decode__tyreg_poly_ty(d,tup[1])] })(d.get_array(x).toArray()))
  return new Common_Model_t_poly(tys, consts, funs, representable, completed, ty_subst)
}

// clique Imandrax_api_common.Region.status (cached: false)
// def Imandrax_api_common.Region.status (mangled name: "Common_Region_status")
export class Common_Region_status_Unknown<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(){}
}
export class Common_Region_status_Feasible<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Region_status_Feasible_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Region_status_Feasible<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Region_status_Feasible(arg)
}
export class Common_Region_status_Feasibility_check_failed<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: string) {}
}
export function Common_Region_status_Feasibility_check_failed_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Region_status_Feasibility_check_failed<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Common_Region_status_Feasibility_check_failed(arg)
}
export type Common_Region_status<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Region_status_Unknown<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Region_status_Feasible<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Region_status_Feasibility_check_failed<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Region_status_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Region_status<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Common_Region_status_Unknown<_V_tyreg_poly_term,_V_tyreg_poly_ty>()
   case 1:
      return Common_Region_status_Feasible_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Common_Region_status_Feasibility_check_failed_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Region_status, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Region.meta (cached: false)
// def Imandrax_api_common.Region.meta (mangled name: "Common_Region_meta")
export class Common_Region_meta_Null<_V_tyreg_poly_term> {
  constructor(){}
}
export class Common_Region_meta_Bool<_V_tyreg_poly_term> {
  constructor(public arg: boolean) {}
}
export function Common_Region_meta_Bool_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_Bool<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_bool(_tw_args[0])
  return new Common_Region_meta_Bool(arg)
}
export class Common_Region_meta_Int<_V_tyreg_poly_term> {
  constructor(public arg: bigint) {}
}
export function Common_Region_meta_Int_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_Int<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Common_Region_meta_Int(arg)
}
export class Common_Region_meta_Real<_V_tyreg_poly_term> {
  constructor(public arg: [bigint, bigint]) {}
}
export function Common_Region_meta_Real_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_Real<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode_q(d,_tw_args[0])
  return new Common_Region_meta_Real(arg)
}
export class Common_Region_meta_String<_V_tyreg_poly_term> {
  constructor(public arg: string) {}
}
export function Common_Region_meta_String_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_String<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Common_Region_meta_String(arg)
}
export class Common_Region_meta_Assoc<_V_tyreg_poly_term> {
  constructor(public arg: Array<[string,Common_Region_meta<_V_tyreg_poly_term>]>) {}
}
export function Common_Region_meta_Assoc_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_Assoc<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [string,Common_Region_meta<_V_tyreg_poly_term>] => { checkArrayLength(x, tup, 2); return [d.get_str(tup[0]), Common_Region_meta_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),tup[1])] })(d.get_array(x).toArray()))
  return new Common_Region_meta_Assoc(arg)
}
export class Common_Region_meta_Term<_V_tyreg_poly_term> {
  constructor(public arg: _V_tyreg_poly_term) {}
}
export function Common_Region_meta_Term_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_Term<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_term(d,_tw_args[0])
  return new Common_Region_meta_Term(arg)
}
export class Common_Region_meta_List<_V_tyreg_poly_term> {
  constructor(public arg: Array<Common_Region_meta<_V_tyreg_poly_term>>) {}
}
export function Common_Region_meta_List_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Common_Region_meta_List<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Common_Region_meta_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  return new Common_Region_meta_List(arg)
}
export type Common_Region_meta<_V_tyreg_poly_term> = Common_Region_meta_Null<_V_tyreg_poly_term>| Common_Region_meta_Bool<_V_tyreg_poly_term>| Common_Region_meta_Int<_V_tyreg_poly_term>| Common_Region_meta_Real<_V_tyreg_poly_term>| Common_Region_meta_String<_V_tyreg_poly_term>| Common_Region_meta_Assoc<_V_tyreg_poly_term>| Common_Region_meta_Term<_V_tyreg_poly_term>| Common_Region_meta_List<_V_tyreg_poly_term>

export function Common_Region_meta_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Common_Region_meta<_V_tyreg_poly_term> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Common_Region_meta_Null<_V_tyreg_poly_term>()
   case 1:
      return Common_Region_meta_Bool_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 2:
      return Common_Region_meta_Int_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 3:
      return Common_Region_meta_Real_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 4:
      return Common_Region_meta_String_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 5:
      return Common_Region_meta_Assoc_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 6:
      return Common_Region_meta_Term_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 7:
      return Common_Region_meta_List_of_twine(d, decode__tyreg_poly_term, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Region_meta, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Region.t_poly (cached: false)
// def Imandrax_api_common.Region.t_poly (mangled name: "Common_Region_t_poly")
export class Common_Region_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public constraints:Array<_V_tyreg_poly_term>,
    public invariant:_V_tyreg_poly_term,
    public meta:Array<[string,Common_Region_meta<_V_tyreg_poly_term>]>,
    public status:Common_Region_status<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}

export function Common_Region_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Region_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const constraints = d.get_array(fields[0]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const invariant = decode__tyreg_poly_term(d,fields[1])
  const meta = d.get_array(fields[2]).toArray().map(x => ((tup : Array<offset>): [string,Common_Region_meta<_V_tyreg_poly_term>] => { checkArrayLength(x, tup, 2); return [d.get_str(tup[0]), Common_Region_meta_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),tup[1])] })(d.get_array(x).toArray()))
  const status = Common_Region_status_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[3])
  return new Common_Region_t_poly(constraints, invariant, meta, status)
}

// clique Imandrax_api_common.Proof_obligation.t_poly (cached: false)
// def Imandrax_api_common.Proof_obligation.t_poly (mangled name: "Common_Proof_obligation_t_poly")
export class Common_Proof_obligation_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public descr:string,
    public goal:[Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term],
    public tactic:Common_Tactic_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public is_instance:boolean,
    public anchor:Anchor,
    public timeout:undefined | bigint,
    public upto:undefined | Upto) {}
}

export function Common_Proof_obligation_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Proof_obligation_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const descr = d.get_str(fields[0])
  const goal = ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(fields[1], tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(fields[1]).toArray())
  const tactic = Common_Tactic_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[2])
  const is_instance = d.get_bool(fields[3])
  const anchor = Anchor_of_twine(d, fields[4])
  const timeout = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[5])
  const upto = twine.optional(d,  ((d:twine.Decoder,off:offset) => Upto_of_twine(d, off)), fields[6])
  return new Common_Proof_obligation_t_poly(descr, goal, tactic, is_instance, anchor, timeout, upto)
}

// clique Imandrax_api_common.Instantiation_rule_kind.t (cached: false)
// def Imandrax_api_common.Instantiation_rule_kind.t (mangled name: "Common_Instantiation_rule_kind")
export class Common_Instantiation_rule_kind_IR_forward_chaining {
  constructor(){}
}
export class Common_Instantiation_rule_kind_IR_generalization {
  constructor(){}
}
export type Common_Instantiation_rule_kind = Common_Instantiation_rule_kind_IR_forward_chaining| Common_Instantiation_rule_kind_IR_generalization

export function Common_Instantiation_rule_kind_of_twine(d: twine.Decoder, off: offset): Common_Instantiation_rule_kind {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Common_Instantiation_rule_kind_IR_forward_chaining()
   case 1:
     return new Common_Instantiation_rule_kind_IR_generalization()
   default:
      throw new twine.TwineError({msg: `expected Common_Instantiation_rule_kind, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Instantiation_rule.t_poly (cached: false)
// def Imandrax_api_common.Instantiation_rule.t_poly (mangled name: "Common_Instantiation_rule_t_poly")
export class Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public ir_from:Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public ir_triggers:Array<Common_Trigger_t_poly<_V_tyreg_poly_ty>>,
    public ir_kind:Common_Instantiation_rule_kind) {}
}

export function Common_Instantiation_rule_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const ir_from = Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const ir_triggers = d.get_array(fields[1]).toArray().map(x => Common_Trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const ir_kind = Common_Instantiation_rule_kind_of_twine(d, fields[2])
  return new Common_Instantiation_rule_t_poly(ir_from, ir_triggers, ir_kind)
}

// clique Imandrax_api_common.Fun_decomp.list_with_len (cached: false)
// def Imandrax_api_common.Fun_decomp.list_with_len (mangled name: "Common_Fun_decomp_list_with_len")
export type Common_Fun_decomp_list_with_len<_V_tyreg_poly_a> = Array<_V_tyreg_poly_a>;

export function Common_Fun_decomp_list_with_len_of_twine<_V_tyreg_poly_a>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a,off: offset): Common_Fun_decomp_list_with_len<_V_tyreg_poly_a> {
 decode__tyreg_poly_a; // ignore
  return d.get_array(off).toArray().map(x => decode__tyreg_poly_a(d,x))
}

// clique Imandrax_api_common.Fun_decomp.t_poly (cached: false)
// def Imandrax_api_common.Fun_decomp.t_poly (mangled name: "Common_Fun_decomp_t_poly")
export class Common_Fun_decomp_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public f_id:Uid,
    public f_args:Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,
    public regions:Common_Fun_decomp_list_with_len<Common_Region_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>) {}
}

export function Common_Fun_decomp_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Fun_decomp_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const f_id = Uid_of_twine(d, fields[0])
  const f_args = d.get_array(fields[1]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const regions = Common_Fun_decomp_list_with_len_of_twine(d,((d:twine.Decoder,off:offset) => Common_Region_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[2])
  return new Common_Fun_decomp_t_poly(f_id, f_args, regions)
}

// clique Imandrax_api_common.Elimination_rule.t_poly (cached: false)
// def Imandrax_api_common.Elimination_rule.t_poly (mangled name: "Common_Elimination_rule_t_poly")
export class Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public er_name:Uid,
    public er_guard:Array<_V_tyreg_poly_term>,
    public er_lhs:_V_tyreg_poly_term,
    public er_rhs:Common_Var_t_poly<_V_tyreg_poly_ty>,
    public er_dests:Array<Common_Fo_pattern_t_poly<_V_tyreg_poly_ty>>,
    public er_dest_tms:Array<_V_tyreg_poly_term>) {}
}

export function Common_Elimination_rule_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 6)
  const er_name = Uid_of_twine(d, fields[0])
  const er_guard = d.get_array(fields[1]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const er_lhs = decode__tyreg_poly_term(d,fields[2])
  const er_rhs = Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[3])
  const er_dests = d.get_array(fields[4]).toArray().map(x => Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const er_dest_tms = d.get_array(fields[5]).toArray().map(x => decode__tyreg_poly_term(d,x))
  return new Common_Elimination_rule_t_poly(er_name, er_guard, er_lhs, er_rhs, er_dests, er_dest_tms)
}

// clique Imandrax_api_common.Decomp.lift_bool (cached: false)
// def Imandrax_api_common.Decomp.lift_bool (mangled name: "Common_Decomp_lift_bool")
export class Common_Decomp_lift_bool_Default {
  constructor(){}
}
export class Common_Decomp_lift_bool_Nested_equalities {
  constructor(){}
}
export class Common_Decomp_lift_bool_Equalities {
  constructor(){}
}
export class Common_Decomp_lift_bool_All {
  constructor(){}
}
export type Common_Decomp_lift_bool = Common_Decomp_lift_bool_Default| Common_Decomp_lift_bool_Nested_equalities| Common_Decomp_lift_bool_Equalities| Common_Decomp_lift_bool_All

export function Common_Decomp_lift_bool_of_twine(d: twine.Decoder, off: offset): Common_Decomp_lift_bool {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Common_Decomp_lift_bool_Default()
   case 1:
     return new Common_Decomp_lift_bool_Nested_equalities()
   case 2:
     return new Common_Decomp_lift_bool_Equalities()
   case 3:
     return new Common_Decomp_lift_bool_All()
   default:
      throw new twine.TwineError({msg: `expected Common_Decomp_lift_bool, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Decomp.t_ (cached: false)
// def Imandrax_api_common.Decomp.t_ (mangled name: "Common_Decomp_t_")
export class Common_Decomp_t_ {
  constructor(
    public f_id:Uid,
    public assuming:undefined | Uid,
    public basis:Uid_set,
    public rule_specs:Uid_set,
    public ctx_simp:boolean,
    public lift_bool:Common_Decomp_lift_bool,
    public prune:boolean) {}
}

export function Common_Decomp_t__of_twine(d: twine.Decoder, off: offset): Common_Decomp_t_ {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const f_id = Uid_of_twine(d, fields[0])
  const assuming = twine.optional(d,  ((d:twine.Decoder,off:offset) => Uid_of_twine(d, off)), fields[1])
  const basis = Uid_set_of_twine(d, fields[2])
  const rule_specs = Uid_set_of_twine(d, fields[3])
  const ctx_simp = d.get_bool(fields[4])
  const lift_bool = Common_Decomp_lift_bool_of_twine(d, fields[5])
  const prune = d.get_bool(fields[6])
  return new Common_Decomp_t_(f_id, assuming, basis, rule_specs, ctx_simp, lift_bool, prune)
}

// clique Imandrax_api_common.Decl.t_poly (cached: false)
// def Imandrax_api_common.Decl.t_poly (mangled name: "Common_Decl_t_poly")
export class Common_Decl_t_poly_Fun<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Decl_t_poly_Fun_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Decl_t_poly_Fun<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Decl_t_poly_Fun(arg)
}
export class Common_Decl_t_poly_Ty<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Ty_view_def_poly<_V_tyreg_poly_ty>) {}
}
export function Common_Decl_t_poly_Ty_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Decl_t_poly_Ty<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Ty_view_def_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Decl_t_poly_Ty(arg)
}
export class Common_Decl_t_poly_Theorem<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Theorem_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Decl_t_poly_Theorem_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Decl_t_poly_Theorem<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Theorem_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Decl_t_poly_Theorem(arg)
}
export class Common_Decl_t_poly_Rule_spec<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Rule_spec_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Decl_t_poly_Rule_spec_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Decl_t_poly_Rule_spec<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Rule_spec_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Decl_t_poly_Rule_spec(arg)
}
export class Common_Decl_t_poly_Verify<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Verify_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Decl_t_poly_Verify_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Decl_t_poly_Verify<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Verify_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Decl_t_poly_Verify(arg)
}
export type Common_Decl_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Decl_t_poly_Fun<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Decl_t_poly_Ty<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Decl_t_poly_Theorem<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Decl_t_poly_Rule_spec<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Decl_t_poly_Verify<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Decl_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Decl_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Decl_t_poly_Fun_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Common_Decl_t_poly_Ty_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Common_Decl_t_poly_Theorem_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Common_Decl_t_poly_Rule_spec_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Common_Decl_t_poly_Verify_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Decl_t_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Db_op.t_poly (cached: false)
// def Imandrax_api_common.Db_op.t_poly (mangled name: "Common_Db_op_t_poly")
export class Common_Db_op_t_poly_Op_enable<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<Uid>) {}
}
export function Common_Db_op_t_poly_Op_enable_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_enable<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Uid_of_twine(d, x))
  return new Common_Db_op_t_poly_Op_enable(arg)
}
export class Common_Db_op_t_poly_Op_disable<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<Uid>) {}
}
export function Common_Db_op_t_poly_Op_disable_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_disable<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Uid_of_twine(d, x))
  return new Common_Db_op_t_poly_Op_disable(arg)
}
export class Common_Db_op_t_poly_Op_add_decls<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<Common_Decl_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>) {}
}
export function Common_Db_op_t_poly_Op_add_decls_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_decls<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Common_Decl_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  return new Common_Db_op_t_poly_Op_add_decls(arg)
}
export class Common_Db_op_t_poly_Op_add_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_add_rw_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_add_rw(cargs)
}
export class Common_Db_op_t_poly_Op_add_fc_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Trigger_t_poly<_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_add_fc_trigger_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_fc_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Trigger_t_poly<_V_tyreg_poly_ty>] = [Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Common_Trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_add_fc_trigger(cargs)
}
export class Common_Db_op_t_poly_Op_add_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_add_elim_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Common_Elimination_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_add_elim(cargs)
}
export class Common_Db_op_t_poly_Op_add_gen_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Trigger_t_poly<_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_add_gen_trigger_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_gen_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Pattern_head_t_poly<_V_tyreg_poly_ty>,Common_Trigger_t_poly<_V_tyreg_poly_ty>] = [Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Common_Trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_add_gen_trigger(cargs)
}
export class Common_Db_op_t_poly_Op_add_count_fun<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_add_count_fun_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_count_fun<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Common_Fun_def_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Uid_of_twine(d, _tw_args[0]),Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_add_count_fun(cargs)
}
export class Common_Db_op_t_poly_Op_set_admission<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Common_Admission]){}
}
export function Common_Db_op_t_poly_Op_set_admission_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_set_admission<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Common_Admission] = [Uid_of_twine(d, _tw_args[0]),Common_Admission_of_twine(d, _tw_args[1])]
  return new Common_Db_op_t_poly_Op_set_admission(cargs)
}
export class Common_Db_op_t_poly_Op_set_thm_as_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Array<Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>]){}
}
export function Common_Db_op_t_poly_Op_set_thm_as_rw_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_set_thm_as_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))]
  return new Common_Db_op_t_poly_Op_set_thm_as_rw(cargs)
}
export class Common_Db_op_t_poly_Op_set_thm_as_fc<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Array<Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>]){}
}
export function Common_Db_op_t_poly_Op_set_thm_as_fc_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_set_thm_as_fc<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => Common_Instantiation_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))]
  return new Common_Db_op_t_poly_Op_set_thm_as_fc(cargs)
}
export class Common_Db_op_t_poly_Op_set_thm_as_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Array<Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>]){}
}
export function Common_Db_op_t_poly_Op_set_thm_as_elim_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_set_thm_as_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<Common_Elimination_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => Common_Elimination_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))]
  return new Common_Db_op_t_poly_Op_set_thm_as_elim(cargs)
}
export class Common_Db_op_t_poly_Op_set_thm_as_gen<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Common_Db_op_t_poly_Op_set_thm_as_gen_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_set_thm_as_gen<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Uid_of_twine(d, _tw_args[0]),Common_Instantiation_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Common_Db_op_t_poly_Op_set_thm_as_gen(cargs)
}
export class Common_Db_op_t_poly_Op_add_instantiation_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Instantiation_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Common_Db_op_t_poly_Op_add_instantiation_rule_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_instantiation_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Instantiation_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Common_Db_op_t_poly_Op_add_instantiation_rule(arg)
}
export class Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Array<Common_Trigger_t_poly<_V_tyreg_poly_ty>>]){}
}
export function Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<Common_Trigger_t_poly<_V_tyreg_poly_ty>>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => Common_Trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))]
  return new Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers(cargs)
}
export class Common_Db_op_t_poly_Op_add_rule_spec_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Uid,Array<Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>]){}
}
export function Common_Db_op_t_poly_Op_add_rule_spec_rw_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Common_Db_op_t_poly_Op_add_rule_spec_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Uid,Array<Common_Rewrite_rule_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>] = [Uid_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))]
  return new Common_Db_op_t_poly_Op_add_rule_spec_rw(cargs)
}
export type Common_Db_op_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Db_op_t_poly_Op_enable<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_disable<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_decls<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_fc_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_gen_trigger<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_count_fun<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_set_admission<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_set_thm_as_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_set_thm_as_fc<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_set_thm_as_elim<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_set_thm_as_gen<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_instantiation_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Common_Db_op_t_poly_Op_add_rule_spec_rw<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Common_Db_op_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Db_op_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Common_Db_op_t_poly_Op_enable_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Common_Db_op_t_poly_Op_disable_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Common_Db_op_t_poly_Op_add_decls_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Common_Db_op_t_poly_Op_add_rw_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Common_Db_op_t_poly_Op_add_fc_trigger_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 5:
      return Common_Db_op_t_poly_Op_add_elim_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 6:
      return Common_Db_op_t_poly_Op_add_gen_trigger_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 7:
      return Common_Db_op_t_poly_Op_add_count_fun_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 8:
      return Common_Db_op_t_poly_Op_set_admission_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 9:
      return Common_Db_op_t_poly_Op_set_thm_as_rw_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 10:
      return Common_Db_op_t_poly_Op_set_thm_as_fc_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 11:
      return Common_Db_op_t_poly_Op_set_thm_as_elim_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 12:
      return Common_Db_op_t_poly_Op_set_thm_as_gen_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 13:
      return Common_Db_op_t_poly_Op_add_instantiation_rule_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 14:
      return Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 15:
      return Common_Db_op_t_poly_Op_add_rule_spec_rw_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Common_Db_op_t_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_common.Db_ser.ca_ptr (cached: false)
// def Imandrax_api_common.Db_ser.ca_ptr (mangled name: "Common_Db_ser_ca_ptr")
export type Common_Db_ser_ca_ptr<_V_tyreg_poly_a> = Ca_store_Ca_ptr<_V_tyreg_poly_a>;

export function Common_Db_ser_ca_ptr_of_twine<_V_tyreg_poly_a>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a,off: offset): Common_Db_ser_ca_ptr<_V_tyreg_poly_a> {
 decode__tyreg_poly_a; // ignore
  return Ca_store_Ca_ptr_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_a(d,off)),off)
}

// clique Imandrax_api_common.Db_ser.t_poly (cached: false)
// def Imandrax_api_common.Db_ser.t_poly (mangled name: "Common_Db_ser_t_poly")
export class Common_Db_ser_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public ops:Array<Common_Db_ser_ca_ptr<Common_Db_op_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>>) {}
}

export function Common_Db_ser_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Common_Db_ser_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const x = d.get_array(off).toArray().map(x => Common_Db_ser_ca_ptr_of_twine(d,((d:twine.Decoder,off:offset) => Common_Db_op_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),x)) // single unboxed field
  return new Common_Db_ser_t_poly(x)
}

// clique Imandrax_api_mir.Type.var (cached: false)
// def Imandrax_api_mir.Type.var (mangled name: "Mir_Type_var")
export type Mir_Type_var = Uid;

export function Mir_Type_var_of_twine(d: twine.Decoder, off: offset): Mir_Type_var {
  return Uid_of_twine(d, off)
}

// clique Imandrax_api_mir.Type.clique (cached: false)
// def Imandrax_api_mir.Type.clique (mangled name: "Mir_Type_clique")
export type Mir_Type_clique = Uid_set;

export function Mir_Type_clique_of_twine(d: twine.Decoder, off: offset): Mir_Type_clique {
  return Uid_set_of_twine(d, off)
}

// clique Imandrax_api_mir.Type.generation (cached: false)
// def Imandrax_api_mir.Type.generation (mangled name: "Mir_Type_generation")
export type Mir_Type_generation = bigint;

export function Mir_Type_generation_of_twine(d: twine.Decoder, off: offset): Mir_Type_generation {
  return d.get_int(off)
}

// clique Imandrax_api_mir.Type.t (cached: true)
// def Imandrax_api_mir.Type.t (mangled name: "Mir_Type")
export class Mir_Type {
  constructor(
    public view:Ty_view_view<null,Mir_Type_var,Mir_Type>) {}
}

export function Mir_Type_of_twine(d: twine.Decoder, off: offset): Mir_Type {
  return twine.withCache(d, off, "Imandrax_api_mir.Type.t", ((d: twine.Decoder, off:offset) => {
  const x = Ty_view_view_of_twine(d,((d:twine.Decoder,off:offset) => d.get_null(off)), ((d:twine.Decoder,off:offset) => Mir_Type_var_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off) // single unboxed field
  return new Mir_Type(x)
  }))
}

// clique Imandrax_api_mir.Type.ser (cached: false)
// def Imandrax_api_mir.Type.ser (mangled name: "Mir_Type_ser")
export class Mir_Type_ser {
  constructor(
    public view:Ty_view_view<null,Mir_Type_var,Mir_Type>) {}
}

export function Mir_Type_ser_of_twine(d: twine.Decoder, off: offset): Mir_Type_ser {
  const x = Ty_view_view_of_twine(d,((d:twine.Decoder,off:offset) => d.get_null(off)), ((d:twine.Decoder,off:offset) => Mir_Type_var_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off) // single unboxed field
  return new Mir_Type_ser(x)
}

// clique Imandrax_api_mir.Type.def (cached: false)
// def Imandrax_api_mir.Type.def (mangled name: "Mir_Type_def")
export type Mir_Type_def = Ty_view_def_poly<Mir_Type>;

export function Mir_Type_def_of_twine(d: twine.Decoder, off: offset): Mir_Type_def {
  return Ty_view_def_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Var.t (cached: false)
// def Imandrax_api_mir.Var.t (mangled name: "Mir_Var")
export type Mir_Var = Common_Var_t_poly<Mir_Type>;

export function Mir_Var_of_twine(d: twine.Decoder, off: offset): Mir_Var {
  return Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Typed_symbol.t (cached: false)
// def Imandrax_api_mir.Typed_symbol.t (mangled name: "Mir_Typed_symbol")
export type Mir_Typed_symbol = Common_Typed_symbol_t_poly<Mir_Type>;

export function Mir_Typed_symbol_of_twine(d: twine.Decoder, off: offset): Mir_Typed_symbol {
  return Common_Typed_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Type_schema.t (cached: false)
// def Imandrax_api_mir.Type_schema.t (mangled name: "Mir_Type_schema")
export type Mir_Type_schema = Common_Type_schema_t_poly<Mir_Type>;

export function Mir_Type_schema_of_twine(d: twine.Decoder, off: offset): Mir_Type_schema {
  return Common_Type_schema_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Trigger.t (cached: false)
// def Imandrax_api_mir.Trigger.t (mangled name: "Mir_Trigger")
export type Mir_Trigger = Common_Trigger_t_poly<Mir_Type>;

export function Mir_Trigger_of_twine(d: twine.Decoder, off: offset): Mir_Trigger {
  return Common_Trigger_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Applied_symbol.t (cached: false)
// def Imandrax_api_mir.Applied_symbol.t (mangled name: "Mir_Applied_symbol")
export type Mir_Applied_symbol = Common_Applied_symbol_t_poly<Mir_Type>;

export function Mir_Applied_symbol_of_twine(d: twine.Decoder, off: offset): Mir_Applied_symbol {
  return Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Term.view (cached: false)
// def Imandrax_api_mir.Term.view (mangled name: "Mir_Term_view")
export class Mir_Term_view_Const<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: Const) {}
}
export function Mir_Term_view_Const_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Const<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Const_of_twine(d, _tw_args[0])
  return new Mir_Term_view_Const(arg)
}
export class Mir_Term_view_If<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public args: [_V_tyreg_poly_t,_V_tyreg_poly_t,_V_tyreg_poly_t]){}
}
export function Mir_Term_view_If_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_If<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 3)
  const cargs: [_V_tyreg_poly_t,_V_tyreg_poly_t,_V_tyreg_poly_t] = [decode__tyreg_poly_t(d,_tw_args[0]),decode__tyreg_poly_t(d,_tw_args[1]),decode__tyreg_poly_t(d,_tw_args[2])]
  return new Mir_Term_view_If(cargs)
}
export class Mir_Term_view_Apply<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public f: _V_tyreg_poly_t,
    public l: Array<_V_tyreg_poly_t>){}
}

export function Mir_Term_view_Apply_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Apply<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const f = decode__tyreg_poly_t(d,_tw_args[0])
  const l = d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_t(d,x))
  return new Mir_Term_view_Apply(f,l)
}
export class Mir_Term_view_Var<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Var_t_poly<_V_tyreg_poly_ty>) {}
}
export function Mir_Term_view_Var_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Var<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Mir_Term_view_Var(arg)
}
export class Mir_Term_view_Sym<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>) {}
}
export function Mir_Term_view_Sym_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Sym<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Mir_Term_view_Sym(arg)
}
export class Mir_Term_view_Construct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public args: Array<_V_tyreg_poly_t>,
    public labels: undefined | Array<Uid>){}
}

export function Mir_Term_view_Construct_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Construct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 3)
  const c = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  const args = d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_t(d,x))
  const labels = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_array(off).toArray().map(x => Uid_of_twine(d, x))), _tw_args[2])
  return new Mir_Term_view_Construct(c,args,labels)
}
export class Mir_Term_view_Destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public i: bigint,
    public t: _V_tyreg_poly_t){}
}

export function Mir_Term_view_Destruct_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 3)
  const c = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  const i = d.get_int(_tw_args[1])
  const t = decode__tyreg_poly_t(d,_tw_args[2])
  return new Mir_Term_view_Destruct(c,i,t)
}
export class Mir_Term_view_Is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public c: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public t: _V_tyreg_poly_t){}
}

export function Mir_Term_view_Is_a_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const c = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  const t = decode__tyreg_poly_t(d,_tw_args[1])
  return new Mir_Term_view_Is_a(c,t)
}
export class Mir_Term_view_Tuple<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public l: Array<_V_tyreg_poly_t>){}
}

export function Mir_Term_view_Tuple_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Tuple<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 1)
  const l = d.get_array(_tw_args[0]).toArray().map(x => decode__tyreg_poly_t(d,x))
  return new Mir_Term_view_Tuple(l)
}
export class Mir_Term_view_Field<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public f: Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,
    public t: _V_tyreg_poly_t){}
}

export function Mir_Term_view_Field_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Field<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const f = Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  const t = decode__tyreg_poly_t(d,_tw_args[1])
  return new Mir_Term_view_Field(f,t)
}
export class Mir_Term_view_Tuple_field<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public i: bigint,
    public t: _V_tyreg_poly_t){}
}

export function Mir_Term_view_Tuple_field_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Tuple_field<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const i = d.get_int(_tw_args[0])
  const t = decode__tyreg_poly_t(d,_tw_args[1])
  return new Mir_Term_view_Tuple_field(i,t)
}
export class Mir_Term_view_Record<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public rows: Array<[Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_t]>,
    public rest: undefined | _V_tyreg_poly_t){}
}

export function Mir_Term_view_Record_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Record<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const rows = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_t] => { checkArrayLength(x, tup, 2); return [Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[0]), decode__tyreg_poly_t(d,tup[1])] })(d.get_array(x).toArray()))
  const rest = twine.optional(d,  ((d:twine.Decoder,off:offset) => decode__tyreg_poly_t(d,off)), _tw_args[1])
  return new Mir_Term_view_Record(rows,rest)
}
export class Mir_Term_view_Case<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(
    public u: _V_tyreg_poly_t,
    public cases: Array<[Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_t]>,
    public default_: undefined | _V_tyreg_poly_t){}
}

export function Mir_Term_view_Case_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Case<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 3)
  const u = decode__tyreg_poly_t(d,_tw_args[0])
  const cases = d.get_array(_tw_args[1]).toArray().map(x => ((tup : Array<offset>): [Common_Applied_symbol_t_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_t] => { checkArrayLength(x, tup, 2); return [Common_Applied_symbol_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[0]), decode__tyreg_poly_t(d,tup[1])] })(d.get_array(x).toArray()))
  const default_ = twine.optional(d,  ((d:twine.Decoder,off:offset) => decode__tyreg_poly_t(d,off)), _tw_args[2])
  return new Mir_Term_view_Case(u,cases,default_)
}
export class Mir_Term_view_Sequence<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  constructor(public args: [Array<_V_tyreg_poly_t>,_V_tyreg_poly_t]){}
}
export function Mir_Term_view_Sequence_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Mir_Term_view_Sequence<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  decode__tyreg_poly_t; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Array<_V_tyreg_poly_t>,_V_tyreg_poly_t] = [d.get_array(_tw_args[0]).toArray().map(x => decode__tyreg_poly_t(d,x)),decode__tyreg_poly_t(d,_tw_args[1])]
  return new Mir_Term_view_Sequence(cargs)
}
export type Mir_Term_view<_V_tyreg_poly_t,_V_tyreg_poly_ty> = Mir_Term_view_Const<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_If<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Apply<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Var<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Sym<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Construct<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Destruct<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Is_a<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Tuple<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Field<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Tuple_field<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Record<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Case<_V_tyreg_poly_t,_V_tyreg_poly_ty>| Mir_Term_view_Sequence<_V_tyreg_poly_t,_V_tyreg_poly_ty>

export function Mir_Term_view_of_twine<_V_tyreg_poly_t,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_t: (d:twine.Decoder, off:offset) => _V_tyreg_poly_t, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Mir_Term_view<_V_tyreg_poly_t,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Mir_Term_view_Const_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Mir_Term_view_If_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Mir_Term_view_Apply_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Mir_Term_view_Var_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Mir_Term_view_Sym_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 5:
      return Mir_Term_view_Construct_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 6:
      return Mir_Term_view_Destruct_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 7:
      return Mir_Term_view_Is_a_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 8:
      return Mir_Term_view_Tuple_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 9:
      return Mir_Term_view_Field_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 10:
      return Mir_Term_view_Tuple_field_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 11:
      return Mir_Term_view_Record_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 12:
      return Mir_Term_view_Case_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   case 13:
      return Mir_Term_view_Sequence_of_twine(d, decode__tyreg_poly_t, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Mir_Term_view, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_mir.Term.generation (cached: false)
// def Imandrax_api_mir.Term.generation (mangled name: "Mir_Term_generation")
export type Mir_Term_generation = bigint;

export function Mir_Term_generation_of_twine(d: twine.Decoder, off: offset): Mir_Term_generation {
  return d.get_int(off)
}

// clique Imandrax_api_mir.Term.t (cached: true)
// def Imandrax_api_mir.Term.t (mangled name: "Mir_Term")
export class Mir_Term {
  constructor(
    public view:Mir_Term_view<Mir_Term,Mir_Type>,
    public ty:Mir_Type,
    public sub_anchor:undefined | Sub_anchor) {}
}

export function Mir_Term_of_twine(d: twine.Decoder, off: offset): Mir_Term {
  return twine.withCache(d, off, "Imandrax_api_mir.Term.t", ((d: twine.Decoder, off:offset) => {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const view = Mir_Term_view_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),fields[0])
  const ty = Mir_Type_of_twine(d, fields[1])
  const sub_anchor = twine.optional(d,  ((d:twine.Decoder,off:offset) => Sub_anchor_of_twine(d, off)), fields[2])
  return new Mir_Term(view, ty, sub_anchor)
  }))
}

// clique Imandrax_api_mir.Term.ser (cached: false)
// def Imandrax_api_mir.Term.ser (mangled name: "Mir_Term_ser")
export class Mir_Term_ser {
  constructor(
    public view:Mir_Term_view<Mir_Term,Mir_Type>,
    public ty:Mir_Type,
    public sub_anchor:undefined | Sub_anchor) {}
}

export function Mir_Term_ser_of_twine(d: twine.Decoder, off: offset): Mir_Term_ser {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const view = Mir_Term_view_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),fields[0])
  const ty = Mir_Type_of_twine(d, fields[1])
  const sub_anchor = twine.optional(d,  ((d:twine.Decoder,off:offset) => Sub_anchor_of_twine(d, off)), fields[2])
  return new Mir_Term_ser(view, ty, sub_anchor)
}

// clique Imandrax_api_mir.Term.term (cached: false)
// def Imandrax_api_mir.Term.term (mangled name: "Mir_Term_term")
export type Mir_Term_term = Mir_Term;

export function Mir_Term_term_of_twine(d: twine.Decoder, off: offset): Mir_Term_term {
  return Mir_Term_of_twine(d, off)
}

// clique Imandrax_api_mir.Top_fun.t (cached: false)
// def Imandrax_api_mir.Top_fun.t (mangled name: "Mir_Top_fun")
export type Mir_Top_fun = [Array<Mir_Var>,Mir_Term];

export function Mir_Top_fun_of_twine(d: twine.Decoder, off: offset): Mir_Top_fun {
  return ((tup : Array<offset>): [Array<Mir_Var>,Mir_Term] => { checkArrayLength(off, tup, 2); return [d.get_array(tup[0]).toArray().map(x => Mir_Var_of_twine(d, x)), Mir_Term_of_twine(d, tup[1])] })(d.get_array(off).toArray())
}

// clique Imandrax_api_mir.Theorem.t (cached: false)
// def Imandrax_api_mir.Theorem.t (mangled name: "Mir_Theorem")
export type Mir_Theorem = Common_Theorem_t_poly<Mir_Term,Mir_Type>;

export function Mir_Theorem_of_twine(d: twine.Decoder, off: offset): Mir_Theorem {
  return Common_Theorem_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Tactic.t (cached: false)
// def Imandrax_api_mir.Tactic.t (mangled name: "Mir_Tactic")
export type Mir_Tactic = Common_Tactic_t_poly<Mir_Term,Mir_Type>;

export function Mir_Tactic_of_twine(d: twine.Decoder, off: offset): Mir_Tactic {
  return Common_Tactic_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Sequent.t (cached: false)
// def Imandrax_api_mir.Sequent.t (mangled name: "Mir_Sequent")
export type Mir_Sequent = Common_Sequent_t_poly<Mir_Term>;

export function Mir_Sequent_of_twine(d: twine.Decoder, off: offset): Mir_Sequent {
  return Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Rewrite_rule.t (cached: false)
// def Imandrax_api_mir.Rewrite_rule.t (mangled name: "Mir_Rewrite_rule")
export type Mir_Rewrite_rule = Common_Rewrite_rule_t_poly<Mir_Term,Mir_Type>;

export function Mir_Rewrite_rule_of_twine(d: twine.Decoder, off: offset): Mir_Rewrite_rule {
  return Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Region.Region.t (cached: false)
// def Imandrax_api_mir.Region.Region.t (mangled name: "Mir_Region_Region")
export type Mir_Region_Region = Common_Region_t_poly<Mir_Term,Mir_Type>;

export function Mir_Region_Region_of_twine(d: twine.Decoder, off: offset): Mir_Region_Region {
  return Common_Region_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Proof_obligation.t (cached: false)
// def Imandrax_api_mir.Proof_obligation.t (mangled name: "Mir_Proof_obligation")
export type Mir_Proof_obligation = Common_Proof_obligation_t_poly<Mir_Term,Mir_Type>;

export function Mir_Proof_obligation_of_twine(d: twine.Decoder, off: offset): Mir_Proof_obligation {
  return Common_Proof_obligation_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Pre_trigger.t (cached: false)
// def Imandrax_api_mir.Pre_trigger.t (mangled name: "Mir_Pre_trigger")
export type Mir_Pre_trigger = [Mir_Term,As_trigger];

export function Mir_Pre_trigger_of_twine(d: twine.Decoder, off: offset): Mir_Pre_trigger {
  return ((tup : Array<offset>): [Mir_Term,As_trigger] => { checkArrayLength(off, tup, 2); return [Mir_Term_of_twine(d, tup[0]), As_trigger_of_twine(d, tup[1])] })(d.get_array(off).toArray())
}

// clique Imandrax_api_mir.Pattern_head.t (cached: false)
// def Imandrax_api_mir.Pattern_head.t (mangled name: "Mir_Pattern_head")
export type Mir_Pattern_head = Common_Pattern_head_t_poly<Mir_Type>;

export function Mir_Pattern_head_of_twine(d: twine.Decoder, off: offset): Mir_Pattern_head {
  return Common_Pattern_head_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Model.t (cached: false)
// def Imandrax_api_mir.Model.t (mangled name: "Mir_Model")
export type Mir_Model = Common_Model_t_poly<Mir_Term,Mir_Type>;

export function Mir_Model_of_twine(d: twine.Decoder, off: offset): Mir_Model {
  return Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Instantiation_rule.t (cached: false)
// def Imandrax_api_mir.Instantiation_rule.t (mangled name: "Mir_Instantiation_rule")
export type Mir_Instantiation_rule = Common_Instantiation_rule_t_poly<Mir_Term,Mir_Type>;

export function Mir_Instantiation_rule_of_twine(d: twine.Decoder, off: offset): Mir_Instantiation_rule {
  return Common_Instantiation_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Hints.t (cached: false)
// def Imandrax_api_mir.Hints.t (mangled name: "Mir_Hints")
export type Mir_Hints = Common_Hints_t_poly<Mir_Term,Mir_Type>;

export function Mir_Hints_of_twine(d: twine.Decoder, off: offset): Mir_Hints {
  return Common_Hints_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Fun_def.t (cached: false)
// def Imandrax_api_mir.Fun_def.t (mangled name: "Mir_Fun_def")
export type Mir_Fun_def = Common_Fun_def_t_poly<Mir_Term,Mir_Type>;

export function Mir_Fun_def_of_twine(d: twine.Decoder, off: offset): Mir_Fun_def {
  return Common_Fun_def_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Fun_decomp.t (cached: false)
// def Imandrax_api_mir.Fun_decomp.t (mangled name: "Mir_Fun_decomp")
export type Mir_Fun_decomp = Common_Fun_decomp_t_poly<Mir_Term,Mir_Type>;

export function Mir_Fun_decomp_of_twine(d: twine.Decoder, off: offset): Mir_Fun_decomp {
  return Common_Fun_decomp_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Fo_pattern.t (cached: false)
// def Imandrax_api_mir.Fo_pattern.t (mangled name: "Mir_Fo_pattern")
export type Mir_Fo_pattern = Common_Fo_pattern_t_poly<Mir_Type>;

export function Mir_Fo_pattern_of_twine(d: twine.Decoder, off: offset): Mir_Fo_pattern {
  return Common_Fo_pattern_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Elimination_rule.t (cached: false)
// def Imandrax_api_mir.Elimination_rule.t (mangled name: "Mir_Elimination_rule")
export type Mir_Elimination_rule = Common_Elimination_rule_t_poly<Mir_Term,Mir_Type>;

export function Mir_Elimination_rule_of_twine(d: twine.Decoder, off: offset): Mir_Elimination_rule {
  return Common_Elimination_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Decomp.t (cached: false)
// def Imandrax_api_mir.Decomp.t (mangled name: "Mir_Decomp")
export class Mir_Decomp {
  constructor(
    public f_id:Uid,
    public assuming:undefined | Uid,
    public basis:Uid_set,
    public rule_specs:Uid_set,
    public ctx_simp:boolean,
    public lift_bool:Common_Decomp_lift_bool,
    public prune:boolean) {}
}

export function Mir_Decomp_of_twine(d: twine.Decoder, off: offset): Mir_Decomp {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 7)
  const f_id = Uid_of_twine(d, fields[0])
  const assuming = twine.optional(d,  ((d:twine.Decoder,off:offset) => Uid_of_twine(d, off)), fields[1])
  const basis = Uid_set_of_twine(d, fields[2])
  const rule_specs = Uid_set_of_twine(d, fields[3])
  const ctx_simp = d.get_bool(fields[4])
  const lift_bool = Common_Decomp_lift_bool_of_twine(d, fields[5])
  const prune = d.get_bool(fields[6])
  return new Mir_Decomp(f_id, assuming, basis, rule_specs, ctx_simp, lift_bool, prune)
}

// clique Imandrax_api_mir.Decl.t (cached: false)
// def Imandrax_api_mir.Decl.t (mangled name: "Mir_Decl")
export type Mir_Decl = Common_Decl_t_poly<Mir_Term,Mir_Type>;

export function Mir_Decl_of_twine(d: twine.Decoder, off: offset): Mir_Decl {
  return Common_Decl_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_mir.Db_ser.t (cached: false)
// def Imandrax_api_mir.Db_ser.t (mangled name: "Mir_Db_ser")
export type Mir_Db_ser = Common_Db_ser_t_poly<Mir_Term,Mir_Type>;

export function Mir_Db_ser_of_twine(d: twine.Decoder, off: offset): Mir_Db_ser {
  return Common_Db_ser_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_eval.Ordinal.t (cached: false)
// def Imandrax_api_eval.Ordinal.t (mangled name: "Eval_Ordinal")
export class Eval_Ordinal_Int {
  constructor(public arg: bigint) {}
}
export function Eval_Ordinal_Int_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Eval_Ordinal_Int {
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Eval_Ordinal_Int(arg)
}
export class Eval_Ordinal_Cons {
  constructor(public args: [Eval_Ordinal,bigint,Eval_Ordinal]){}
}
export function Eval_Ordinal_Cons_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Eval_Ordinal_Cons {
  checkArrayLength(off, _tw_args, 3)
  const cargs: [Eval_Ordinal,bigint,Eval_Ordinal] = [Eval_Ordinal_of_twine(d, _tw_args[0]),d.get_int(_tw_args[1]),Eval_Ordinal_of_twine(d, _tw_args[2])]
  return new Eval_Ordinal_Cons(cargs)
}
export type Eval_Ordinal = Eval_Ordinal_Int| Eval_Ordinal_Cons

export function Eval_Ordinal_of_twine(d: twine.Decoder, off: offset): Eval_Ordinal {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Eval_Ordinal_Int_of_twine(d,  c.args, off)
   case 1:
      return Eval_Ordinal_Cons_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Eval_Ordinal, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_eval.Value.cstor_descriptor (cached: false)
// def Imandrax_api_eval.Value.cstor_descriptor (mangled name: "Eval_Value_cstor_descriptor")
export class Eval_Value_cstor_descriptor {
  constructor(
    public cd_idx:bigint,
    public cd_name:Uid) {}
}

export function Eval_Value_cstor_descriptor_of_twine(d: twine.Decoder, off: offset): Eval_Value_cstor_descriptor {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const cd_idx = d.get_int(fields[0])
  const cd_name = Uid_of_twine(d, fields[1])
  return new Eval_Value_cstor_descriptor(cd_idx, cd_name)
}

// clique Imandrax_api_eval.Value.record_descriptor (cached: false)
// def Imandrax_api_eval.Value.record_descriptor (mangled name: "Eval_Value_record_descriptor")
export class Eval_Value_record_descriptor {
  constructor(
    public rd_name:Uid,
    public rd_fields:Array<Uid>) {}
}

export function Eval_Value_record_descriptor_of_twine(d: twine.Decoder, off: offset): Eval_Value_record_descriptor {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const rd_name = Uid_of_twine(d, fields[0])
  const rd_fields = d.get_array(fields[1]).toArray().map(x => Uid_of_twine(d, x))
  return new Eval_Value_record_descriptor(rd_name, rd_fields)
}

// clique Imandrax_api_eval.Value.view (cached: false)
// def Imandrax_api_eval.Value.view (mangled name: "Eval_Value_view")
export class Eval_Value_view_V_true<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(){}
}
export class Eval_Value_view_V_false<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(){}
}
export class Eval_Value_view_V_int<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: bigint) {}
}
export function Eval_Value_view_V_int_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_int<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Eval_Value_view_V_int(arg)
}
export class Eval_Value_view_V_real<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: [bigint, bigint]) {}
}
export function Eval_Value_view_V_real_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_real<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode_q(d,_tw_args[0])
  return new Eval_Value_view_V_real(arg)
}
export class Eval_Value_view_V_string<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: string) {}
}
export function Eval_Value_view_V_string_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_string<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Eval_Value_view_V_string(arg)
}
export class Eval_Value_view_V_cstor<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public args: [Eval_Value_cstor_descriptor,Array<_V_tyreg_poly_v>]){}
}
export function Eval_Value_view_V_cstor_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_cstor<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore
  decode__tyreg_poly_closure; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Eval_Value_cstor_descriptor,Array<_V_tyreg_poly_v>] = [Eval_Value_cstor_descriptor_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_v(d,x))]
  return new Eval_Value_view_V_cstor(cargs)
}
export class Eval_Value_view_V_tuple<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: Array<_V_tyreg_poly_v>) {}
}
export function Eval_Value_view_V_tuple_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_tuple<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => decode__tyreg_poly_v(d,x))
  return new Eval_Value_view_V_tuple(arg)
}
export class Eval_Value_view_V_record<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public args: [Eval_Value_record_descriptor,Array<_V_tyreg_poly_v>]){}
}
export function Eval_Value_view_V_record_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_record<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore
  decode__tyreg_poly_closure; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Eval_Value_record_descriptor,Array<_V_tyreg_poly_v>] = [Eval_Value_record_descriptor_of_twine(d, _tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_v(d,x))]
  return new Eval_Value_view_V_record(cargs)
}
export class Eval_Value_view_V_quoted_term<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: Mir_Top_fun) {}
}
export function Eval_Value_view_V_quoted_term_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_quoted_term<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Mir_Top_fun_of_twine(d, _tw_args[0])
  return new Eval_Value_view_V_quoted_term(arg)
}
export class Eval_Value_view_V_uid<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: Uid) {}
}
export function Eval_Value_view_V_uid_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_uid<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Uid_of_twine(d, _tw_args[0])
  return new Eval_Value_view_V_uid(arg)
}
export class Eval_Value_view_V_closure<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: _V_tyreg_poly_closure) {}
}
export function Eval_Value_view_V_closure_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_closure<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_closure(d,_tw_args[0])
  return new Eval_Value_view_V_closure(arg)
}
export class Eval_Value_view_V_custom<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: Eval__Value_Custom_value) {}
}
export function Eval_Value_view_V_custom_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_custom<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Eval__Value_Custom_value_of_twine(d, _tw_args[0])
  return new Eval_Value_view_V_custom(arg)
}
export class Eval_Value_view_V_ordinal<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  constructor(public arg: Eval_Ordinal) {}
}
export function Eval_Value_view_V_ordinal_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,_tw_args: Array<offset>, off: offset): Eval_Value_view_V_ordinal<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  decode__tyreg_poly_v; // ignore 
  decode__tyreg_poly_closure; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Eval_Ordinal_of_twine(d, _tw_args[0])
  return new Eval_Value_view_V_ordinal(arg)
}
export type Eval_Value_view<_V_tyreg_poly_v,_V_tyreg_poly_closure> = Eval_Value_view_V_true<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_false<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_int<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_real<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_string<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_cstor<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_tuple<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_record<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_quoted_term<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_uid<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_closure<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_custom<_V_tyreg_poly_v,_V_tyreg_poly_closure>| Eval_Value_view_V_ordinal<_V_tyreg_poly_v,_V_tyreg_poly_closure>

export function Eval_Value_view_of_twine<_V_tyreg_poly_v,_V_tyreg_poly_closure>(d: twine.Decoder, decode__tyreg_poly_v: (d:twine.Decoder, off:offset) => _V_tyreg_poly_v, decode__tyreg_poly_closure: (d:twine.Decoder, off:offset) => _V_tyreg_poly_closure,off: offset): Eval_Value_view<_V_tyreg_poly_v,_V_tyreg_poly_closure> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Eval_Value_view_V_true<_V_tyreg_poly_v,_V_tyreg_poly_closure>()
   case 1:
     return new Eval_Value_view_V_false<_V_tyreg_poly_v,_V_tyreg_poly_closure>()
   case 2:
      return Eval_Value_view_V_int_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 3:
      return Eval_Value_view_V_real_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 4:
      return Eval_Value_view_V_string_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 5:
      return Eval_Value_view_V_cstor_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 6:
      return Eval_Value_view_V_tuple_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 7:
      return Eval_Value_view_V_record_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 8:
      return Eval_Value_view_V_quoted_term_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 9:
      return Eval_Value_view_V_uid_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 10:
      return Eval_Value_view_V_closure_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 11:
      return Eval_Value_view_V_custom_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   case 12:
      return Eval_Value_view_V_ordinal_of_twine(d, decode__tyreg_poly_v, decode__tyreg_poly_closure, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Eval_Value_view, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_eval.Value.erased_closure (cached: false)
// def Imandrax_api_eval.Value.erased_closure (mangled name: "Eval_Value_erased_closure")
export class Eval_Value_erased_closure {
  constructor(
    public missing:bigint) {}
}

export function Eval_Value_erased_closure_of_twine(d: twine.Decoder, off: offset): Eval_Value_erased_closure {
  const x = d.get_int(off) // single unboxed field
  return new Eval_Value_erased_closure(x)
}

// clique Imandrax_api_eval.Value.t (cached: false)
// def Imandrax_api_eval.Value.t (mangled name: "Eval_Value")
export class Eval_Value {
  constructor(
    public v:Eval_Value_view<Eval_Value,Eval_Value_erased_closure>) {}
}

export function Eval_Value_of_twine(d: twine.Decoder, off: offset): Eval_Value {
  const x = Eval_Value_view_of_twine(d,((d:twine.Decoder,off:offset) => Eval_Value_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Eval_Value_erased_closure_of_twine(d, off)),off) // single unboxed field
  return new Eval_Value(x)
}

// clique Imandrax_api_report.Expansion.t (cached: false)
// def Imandrax_api_report.Expansion.t (mangled name: "Report_Expansion")
export class Report_Expansion<_V_tyreg_poly_term> {
  constructor(
    public f_name:Uid,
    public lhs:_V_tyreg_poly_term,
    public rhs:_V_tyreg_poly_term) {}
}

export function Report_Expansion_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Report_Expansion<_V_tyreg_poly_term> {
    decode__tyreg_poly_term
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const f_name = Uid_of_twine(d, fields[0])
  const lhs = decode__tyreg_poly_term(d,fields[1])
  const rhs = decode__tyreg_poly_term(d,fields[2])
  return new Report_Expansion(f_name, lhs, rhs)
}

// clique Imandrax_api_report.Instantiation.t (cached: false)
// def Imandrax_api_report.Instantiation.t (mangled name: "Report_Instantiation")
export class Report_Instantiation<_V_tyreg_poly_term> {
  constructor(
    public assertion:_V_tyreg_poly_term,
    public from_rule:Uid) {}
}

export function Report_Instantiation_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Report_Instantiation<_V_tyreg_poly_term> {
    decode__tyreg_poly_term
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const assertion = decode__tyreg_poly_term(d,fields[0])
  const from_rule = Uid_of_twine(d, fields[1])
  return new Report_Instantiation(assertion, from_rule)
}

// clique Imandrax_api_report.Smt_proof.t (cached: false)
// def Imandrax_api_report.Smt_proof.t (mangled name: "Report_Smt_proof")
export class Report_Smt_proof<_V_tyreg_poly_term> {
  constructor(
    public logic:Logic_fragment,
    public unsat_core:Array<_V_tyreg_poly_term>,
    public expansions:Array<Report_Expansion<_V_tyreg_poly_term>>,
    public instantiations:Array<Report_Instantiation<_V_tyreg_poly_term>>) {}
}

export function Report_Smt_proof_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Report_Smt_proof<_V_tyreg_poly_term> {
    decode__tyreg_poly_term
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const logic = Logic_fragment_of_twine(d, fields[0])
  const unsat_core = d.get_array(fields[1]).toArray().map(x => decode__tyreg_poly_term(d,x))
  const expansions = d.get_array(fields[2]).toArray().map(x => Report_Expansion_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  const instantiations = d.get_array(fields[3]).toArray().map(x => Report_Instantiation_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  return new Report_Smt_proof(logic, unsat_core, expansions, instantiations)
}

// clique Imandrax_api_report.Rtext.t, Imandrax_api_report.Rtext.item (cached: false)
// def Imandrax_api_report.Rtext.t (mangled name: "Report_Rtext")
export type Report_Rtext<_V_tyreg_poly_term> = Array<Report_Rtext_item<_V_tyreg_poly_term>>;

export function Report_Rtext_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Report_Rtext<_V_tyreg_poly_term> {
 decode__tyreg_poly_term; // ignore
  return d.get_array(off).toArray().map(x => Report_Rtext_item_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
}
// def Imandrax_api_report.Rtext.item (mangled name: "Report_Rtext_item")
export class Report_Rtext_item_S<_V_tyreg_poly_term> {
  constructor(public arg: string) {}
}
export function Report_Rtext_item_S_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_S<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Report_Rtext_item_S(arg)
}
export class Report_Rtext_item_B<_V_tyreg_poly_term> {
  constructor(public arg: string) {}
}
export function Report_Rtext_item_B_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_B<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Report_Rtext_item_B(arg)
}
export class Report_Rtext_item_I<_V_tyreg_poly_term> {
  constructor(public arg: string) {}
}
export function Report_Rtext_item_I_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_I<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Report_Rtext_item_I(arg)
}
export class Report_Rtext_item_Newline<_V_tyreg_poly_term> {
  constructor(){}
}
export class Report_Rtext_item_Sub<_V_tyreg_poly_term> {
  constructor(public arg: Report_Rtext<_V_tyreg_poly_term>) {}
}
export function Report_Rtext_item_Sub_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_Sub<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Report_Rtext_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[0])
  return new Report_Rtext_item_Sub(arg)
}
export class Report_Rtext_item_L<_V_tyreg_poly_term> {
  constructor(public arg: Array<Report_Rtext<_V_tyreg_poly_term>>) {}
}
export function Report_Rtext_item_L_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_L<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Report_Rtext_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  return new Report_Rtext_item_L(arg)
}
export class Report_Rtext_item_Uid<_V_tyreg_poly_term> {
  constructor(public arg: Uid) {}
}
export function Report_Rtext_item_Uid_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_Uid<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Uid_of_twine(d, _tw_args[0])
  return new Report_Rtext_item_Uid(arg)
}
export class Report_Rtext_item_Term<_V_tyreg_poly_term> {
  constructor(public arg: _V_tyreg_poly_term) {}
}
export function Report_Rtext_item_Term_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_Term<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_term(d,_tw_args[0])
  return new Report_Rtext_item_Term(arg)
}
export class Report_Rtext_item_Sequent<_V_tyreg_poly_term> {
  constructor(public arg: Common_Sequent_t_poly<_V_tyreg_poly_term>) {}
}
export function Report_Rtext_item_Sequent_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_Sequent<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[0])
  return new Report_Rtext_item_Sequent(arg)
}
export class Report_Rtext_item_Subst<_V_tyreg_poly_term> {
  constructor(public arg: Array<[_V_tyreg_poly_term,_V_tyreg_poly_term]>) {}
}
export function Report_Rtext_item_Subst_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,_tw_args: Array<offset>, off: offset): Report_Rtext_item_Subst<_V_tyreg_poly_term> {
  decode__tyreg_poly_term; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [_V_tyreg_poly_term,_V_tyreg_poly_term] => { checkArrayLength(x, tup, 2); return [decode__tyreg_poly_term(d,tup[0]), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(x).toArray()))
  return new Report_Rtext_item_Subst(arg)
}
export type Report_Rtext_item<_V_tyreg_poly_term> = Report_Rtext_item_S<_V_tyreg_poly_term>| Report_Rtext_item_B<_V_tyreg_poly_term>| Report_Rtext_item_I<_V_tyreg_poly_term>| Report_Rtext_item_Newline<_V_tyreg_poly_term>| Report_Rtext_item_Sub<_V_tyreg_poly_term>| Report_Rtext_item_L<_V_tyreg_poly_term>| Report_Rtext_item_Uid<_V_tyreg_poly_term>| Report_Rtext_item_Term<_V_tyreg_poly_term>| Report_Rtext_item_Sequent<_V_tyreg_poly_term>| Report_Rtext_item_Subst<_V_tyreg_poly_term>

export function Report_Rtext_item_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Report_Rtext_item<_V_tyreg_poly_term> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Report_Rtext_item_S_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 1:
      return Report_Rtext_item_B_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 2:
      return Report_Rtext_item_I_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 3:
     return new Report_Rtext_item_Newline<_V_tyreg_poly_term>()
   case 4:
      return Report_Rtext_item_Sub_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 5:
      return Report_Rtext_item_L_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 6:
      return Report_Rtext_item_Uid_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 7:
      return Report_Rtext_item_Term_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 8:
      return Report_Rtext_item_Sequent_of_twine(d, decode__tyreg_poly_term, c.args, off)
   case 9:
      return Report_Rtext_item_Subst_of_twine(d, decode__tyreg_poly_term, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Report_Rtext_item, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_report.Atomic_event.model (cached: false)
// def Imandrax_api_report.Atomic_event.model (mangled name: "Report_Atomic_event_model")
export type Report_Atomic_event_model<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>;

export function Report_Atomic_event_model_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Report_Atomic_event_model<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
 decode__tyreg_poly_term; // ignore
 decode__tyreg_poly_ty; // ignore
  return Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)
}

// clique Imandrax_api_report.Atomic_event.poly (cached: false)
// def Imandrax_api_report.Atomic_event.poly (mangled name: "Report_Atomic_event_poly")
export class Report_Atomic_event_poly_E_message<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public arg: Report_Rtext<_V_tyreg_poly_term>) {}
}
export function Report_Atomic_event_poly_E_message_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_message<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  decode__tyreg_poly_term2; // ignore 
  decode__tyreg_poly_ty2; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Report_Rtext_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[0])
  return new Report_Atomic_event_poly_E_message(arg)
}
export class Report_Atomic_event_poly_E_title<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public arg: string) {}
}
export function Report_Atomic_event_poly_E_title_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_title<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  decode__tyreg_poly_term2; // ignore 
  decode__tyreg_poly_ty2; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Report_Atomic_event_poly_E_title(arg)
}
export class Report_Atomic_event_poly_E_enter_waterfall<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(
    public vars: Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,
    public goal: _V_tyreg_poly_term){}
}

export function Report_Atomic_event_poly_E_enter_waterfall_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_enter_waterfall<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  decode__tyreg_poly_term2
  decode__tyreg_poly_ty2
  checkArrayLength(off, _tw_args, 2)
  const vars = d.get_array(_tw_args[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  const goal = decode__tyreg_poly_term(d,_tw_args[1])
  return new Report_Atomic_event_poly_E_enter_waterfall(vars,goal)
}
export class Report_Atomic_event_poly_E_enter_tactic<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public arg: string) {}
}
export function Report_Atomic_event_poly_E_enter_tactic_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_enter_tactic<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  decode__tyreg_poly_term2; // ignore 
  decode__tyreg_poly_ty2; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Report_Atomic_event_poly_E_enter_tactic(arg)
}
export class Report_Atomic_event_poly_E_rw_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [Common_Rewrite_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term,_V_tyreg_poly_term]){}
}
export function Report_Atomic_event_poly_E_rw_success_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_rw_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 3)
  const cargs: [Common_Rewrite_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term,_V_tyreg_poly_term] = [Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term2(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty2(d,off)),_tw_args[0]),decode__tyreg_poly_term(d,_tw_args[1]),decode__tyreg_poly_term(d,_tw_args[2])]
  return new Report_Atomic_event_poly_E_rw_success(cargs)
}
export class Report_Atomic_event_poly_E_rw_fail<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [Common_Rewrite_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term,string]){}
}
export function Report_Atomic_event_poly_E_rw_fail_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_rw_fail<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 3)
  const cargs: [Common_Rewrite_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term,string] = [Common_Rewrite_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term2(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty2(d,off)),_tw_args[0]),decode__tyreg_poly_term(d,_tw_args[1]),d.get_str(_tw_args[2])]
  return new Report_Atomic_event_poly_E_rw_fail(cargs)
}
export class Report_Atomic_event_poly_E_inst_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [Common_Instantiation_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term]){}
}
export function Report_Atomic_event_poly_E_inst_success_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_inst_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Common_Instantiation_rule_t_poly<_V_tyreg_poly_term2,_V_tyreg_poly_ty2>,_V_tyreg_poly_term] = [Common_Instantiation_rule_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term2(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty2(d,off)),_tw_args[0]),decode__tyreg_poly_term(d,_tw_args[1])]
  return new Report_Atomic_event_poly_E_inst_success(cargs)
}
export class Report_Atomic_event_poly_E_waterfall_checkpoint<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public arg: Array<Common_Sequent_t_poly<_V_tyreg_poly_term>>) {}
}
export function Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_waterfall_checkpoint<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  decode__tyreg_poly_term2; // ignore 
  decode__tyreg_poly_ty2; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  return new Report_Atomic_event_poly_E_waterfall_checkpoint(arg)
}
export class Report_Atomic_event_poly_E_induction_scheme<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public arg: _V_tyreg_poly_term) {}
}
export function Report_Atomic_event_poly_E_induction_scheme_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_induction_scheme<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  decode__tyreg_poly_term2; // ignore 
  decode__tyreg_poly_ty2; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_term(d,_tw_args[0])
  return new Report_Atomic_event_poly_E_induction_scheme(arg)
}
export class Report_Atomic_event_poly_E_attack_subgoal<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(
    public name: string,
    public goal: Common_Sequent_t_poly<_V_tyreg_poly_term>,
    public depth: bigint){}
}

export function Report_Atomic_event_poly_E_attack_subgoal_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_attack_subgoal<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  decode__tyreg_poly_term2
  decode__tyreg_poly_ty2
  checkArrayLength(off, _tw_args, 3)
  const name = d.get_str(_tw_args[0])
  const goal = Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[1])
  const depth = d.get_int(_tw_args[2])
  return new Report_Atomic_event_poly_E_attack_subgoal(name,goal,depth)
}
export class Report_Atomic_event_poly_E_simplify_t<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [_V_tyreg_poly_term,_V_tyreg_poly_term]){}
}
export function Report_Atomic_event_poly_E_simplify_t_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_simplify_t<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [_V_tyreg_poly_term,_V_tyreg_poly_term] = [decode__tyreg_poly_term(d,_tw_args[0]),decode__tyreg_poly_term(d,_tw_args[1])]
  return new Report_Atomic_event_poly_E_simplify_t(cargs)
}
export class Report_Atomic_event_poly_E_simplify_clause<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [_V_tyreg_poly_term,Array<_V_tyreg_poly_term>]){}
}
export function Report_Atomic_event_poly_E_simplify_clause_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_simplify_clause<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [_V_tyreg_poly_term,Array<_V_tyreg_poly_term>] = [decode__tyreg_poly_term(d,_tw_args[0]),d.get_array(_tw_args[1]).toArray().map(x => decode__tyreg_poly_term(d,x))]
  return new Report_Atomic_event_poly_E_simplify_clause(cargs)
}
export class Report_Atomic_event_poly_E_proved_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [_V_tyreg_poly_term,Report_Smt_proof<_V_tyreg_poly_term>]){}
}
export function Report_Atomic_event_poly_E_proved_by_smt_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_proved_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [_V_tyreg_poly_term,Report_Smt_proof<_V_tyreg_poly_term>] = [decode__tyreg_poly_term(d,_tw_args[0]),Report_Smt_proof_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[1])]
  return new Report_Atomic_event_poly_E_proved_by_smt(cargs)
}
export class Report_Atomic_event_poly_E_refuted_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [_V_tyreg_poly_term,undefined | Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Report_Atomic_event_poly_E_refuted_by_smt_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_refuted_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [_V_tyreg_poly_term,undefined | Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [decode__tyreg_poly_term(d,_tw_args[0]),twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), _tw_args[1])]
  return new Report_Atomic_event_poly_E_refuted_by_smt(cargs)
}
export class Report_Atomic_event_poly_E_fun_expansion<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  constructor(public args: [_V_tyreg_poly_term,_V_tyreg_poly_term]){}
}
export function Report_Atomic_event_poly_E_fun_expansion_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,_tw_args: Array<offset>, off: offset): Report_Atomic_event_poly_E_fun_expansion<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  decode__tyreg_poly_term2; // ignore
  decode__tyreg_poly_ty2; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [_V_tyreg_poly_term,_V_tyreg_poly_term] = [decode__tyreg_poly_term(d,_tw_args[0]),decode__tyreg_poly_term(d,_tw_args[1])]
  return new Report_Atomic_event_poly_E_fun_expansion(cargs)
}
export type Report_Atomic_event_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> = Report_Atomic_event_poly_E_message<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_title<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_enter_waterfall<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_enter_tactic<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_rw_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_rw_fail<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_inst_success<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_waterfall_checkpoint<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_induction_scheme<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_attack_subgoal<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_simplify_t<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_simplify_clause<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_proved_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_refuted_by_smt<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>| Report_Atomic_event_poly_E_fun_expansion<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>

export function Report_Atomic_event_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_term2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term2, decode__tyreg_poly_ty2: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty2,off: offset): Report_Atomic_event_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Report_Atomic_event_poly_E_message_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 1:
      return Report_Atomic_event_poly_E_title_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 2:
      return Report_Atomic_event_poly_E_enter_waterfall_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 3:
      return Report_Atomic_event_poly_E_enter_tactic_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 4:
      return Report_Atomic_event_poly_E_rw_success_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 5:
      return Report_Atomic_event_poly_E_rw_fail_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 6:
      return Report_Atomic_event_poly_E_inst_success_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 7:
      return Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 8:
      return Report_Atomic_event_poly_E_induction_scheme_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 9:
      return Report_Atomic_event_poly_E_attack_subgoal_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 10:
      return Report_Atomic_event_poly_E_simplify_t_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 11:
      return Report_Atomic_event_poly_E_simplify_clause_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 12:
      return Report_Atomic_event_poly_E_proved_by_smt_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 13:
      return Report_Atomic_event_poly_E_refuted_by_smt_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   case 14:
      return Report_Atomic_event_poly_E_fun_expansion_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_term2, decode__tyreg_poly_ty2, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Report_Atomic_event_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_report.Atomic_event.Mir.t (cached: false)
// def Imandrax_api_report.Atomic_event.Mir.t (mangled name: "Report_Atomic_event_Mir")
export type Report_Atomic_event_Mir = Report_Atomic_event_poly<Mir_Term,Mir_Type,Mir_Term,Mir_Type>;

export function Report_Atomic_event_Mir_of_twine(d: twine.Decoder, off: offset): Report_Atomic_event_Mir {
  return Report_Atomic_event_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_report.Event.t_linear (cached: false)
// def Imandrax_api_report.Event.t_linear (mangled name: "Report_Event_t_linear")
export class Report_Event_t_linear_EL_atomic<_V_tyreg_poly_atomic_ev> {
  constructor(
    public ts: number,
    public ev: _V_tyreg_poly_atomic_ev){}
}

export function Report_Event_t_linear_EL_atomic_of_twine<_V_tyreg_poly_atomic_ev>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev,_tw_args: Array<offset>, off: offset): Report_Event_t_linear_EL_atomic<_V_tyreg_poly_atomic_ev> {
  decode__tyreg_poly_atomic_ev
  checkArrayLength(off, _tw_args, 2)
  const ts = d.get_float(_tw_args[0])
  const ev = decode__tyreg_poly_atomic_ev(d,_tw_args[1])
  return new Report_Event_t_linear_EL_atomic(ts,ev)
}
export class Report_Event_t_linear_EL_enter_span<_V_tyreg_poly_atomic_ev> {
  constructor(
    public ts: number,
    public ev: _V_tyreg_poly_atomic_ev){}
}

export function Report_Event_t_linear_EL_enter_span_of_twine<_V_tyreg_poly_atomic_ev>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev,_tw_args: Array<offset>, off: offset): Report_Event_t_linear_EL_enter_span<_V_tyreg_poly_atomic_ev> {
  decode__tyreg_poly_atomic_ev
  checkArrayLength(off, _tw_args, 2)
  const ts = d.get_float(_tw_args[0])
  const ev = decode__tyreg_poly_atomic_ev(d,_tw_args[1])
  return new Report_Event_t_linear_EL_enter_span(ts,ev)
}
export class Report_Event_t_linear_EL_exit_span<_V_tyreg_poly_atomic_ev> {
  constructor(
    public ts: number){}
}

export function Report_Event_t_linear_EL_exit_span_of_twine<_V_tyreg_poly_atomic_ev>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev,_tw_args: Array<offset>, off: offset): Report_Event_t_linear_EL_exit_span<_V_tyreg_poly_atomic_ev> {
  decode__tyreg_poly_atomic_ev
  checkArrayLength(off, _tw_args, 1)
  const ts = d.get_float(_tw_args[0])
  return new Report_Event_t_linear_EL_exit_span(ts)
}
export type Report_Event_t_linear<_V_tyreg_poly_atomic_ev> = Report_Event_t_linear_EL_atomic<_V_tyreg_poly_atomic_ev>| Report_Event_t_linear_EL_enter_span<_V_tyreg_poly_atomic_ev>| Report_Event_t_linear_EL_exit_span<_V_tyreg_poly_atomic_ev>

export function Report_Event_t_linear_of_twine<_V_tyreg_poly_atomic_ev>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev,off: offset): Report_Event_t_linear<_V_tyreg_poly_atomic_ev> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Report_Event_t_linear_EL_atomic_of_twine(d, decode__tyreg_poly_atomic_ev, c.args, off)
   case 1:
      return Report_Event_t_linear_EL_enter_span_of_twine(d, decode__tyreg_poly_atomic_ev, c.args, off)
   case 2:
      return Report_Event_t_linear_EL_exit_span_of_twine(d, decode__tyreg_poly_atomic_ev, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Report_Event_t_linear, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_report.Event.t_tree (cached: false)
// def Imandrax_api_report.Event.t_tree (mangled name: "Report_Event_t_tree")
export class Report_Event_t_tree_ET_atomic<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> {
  constructor(
    public ts: number,
    public ev: _V_tyreg_poly_atomic_ev){}
}

export function Report_Event_t_tree_ET_atomic_of_twine<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev, decode__tyreg_poly_sub: (d:twine.Decoder, off:offset) => _V_tyreg_poly_sub,_tw_args: Array<offset>, off: offset): Report_Event_t_tree_ET_atomic<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> {
  decode__tyreg_poly_atomic_ev
  decode__tyreg_poly_sub
  checkArrayLength(off, _tw_args, 2)
  const ts = d.get_float(_tw_args[0])
  const ev = decode__tyreg_poly_atomic_ev(d,_tw_args[1])
  return new Report_Event_t_tree_ET_atomic(ts,ev)
}
export class Report_Event_t_tree_ET_span<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> {
  constructor(
    public ts: number,
    public duration: number,
    public ev: _V_tyreg_poly_atomic_ev,
    public sub: _V_tyreg_poly_sub){}
}

export function Report_Event_t_tree_ET_span_of_twine<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev, decode__tyreg_poly_sub: (d:twine.Decoder, off:offset) => _V_tyreg_poly_sub,_tw_args: Array<offset>, off: offset): Report_Event_t_tree_ET_span<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> {
  decode__tyreg_poly_atomic_ev
  decode__tyreg_poly_sub
  checkArrayLength(off, _tw_args, 4)
  const ts = d.get_float(_tw_args[0])
  const duration = d.get_float(_tw_args[1])
  const ev = decode__tyreg_poly_atomic_ev(d,_tw_args[2])
  const sub = decode__tyreg_poly_sub(d,_tw_args[3])
  return new Report_Event_t_tree_ET_span(ts,duration,ev,sub)
}
export type Report_Event_t_tree<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> = Report_Event_t_tree_ET_atomic<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub>| Report_Event_t_tree_ET_span<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub>

export function Report_Event_t_tree_of_twine<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub>(d: twine.Decoder, decode__tyreg_poly_atomic_ev: (d:twine.Decoder, off:offset) => _V_tyreg_poly_atomic_ev, decode__tyreg_poly_sub: (d:twine.Decoder, off:offset) => _V_tyreg_poly_sub,off: offset): Report_Event_t_tree<_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Report_Event_t_tree_ET_atomic_of_twine(d, decode__tyreg_poly_atomic_ev, decode__tyreg_poly_sub, c.args, off)
   case 1:
      return Report_Event_t_tree_ET_span_of_twine(d, decode__tyreg_poly_atomic_ev, decode__tyreg_poly_sub, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Report_Event_t_tree, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_report.Report.event (cached: false)
// def Imandrax_api_report.Report.event (mangled name: "Report_Report_event")
export type Report_Report_event = Report_Event_t_linear<Report_Atomic_event_Mir>;

export function Report_Report_event_of_twine(d: twine.Decoder, off: offset): Report_Report_event {
  return Report_Event_t_linear_of_twine(d,((d:twine.Decoder,off:offset) => Report_Atomic_event_Mir_of_twine(d, off)),off)
}

// clique Imandrax_api_report.Report.t (cached: false)
// def Imandrax_api_report.Report.t (mangled name: "Report_Report")
export class Report_Report {
  constructor(
    public events:Array<Report_Report_event>) {}
}

export function Report_Report_of_twine(d: twine.Decoder, off: offset): Report_Report {
  const x = d.get_array(off).toArray().map(x => Report_Report_event_of_twine(d, x)) // single unboxed field
  return new Report_Report(x)
}

// clique Imandrax_api_proof.Arg.t (cached: false)
// def Imandrax_api_proof.Arg.t (mangled name: "Proof_Arg")
export class Proof_Arg_A_term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: _V_tyreg_poly_term) {}
}
export function Proof_Arg_A_term_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_term(d,_tw_args[0])
  return new Proof_Arg_A_term(arg)
}
export class Proof_Arg_A_ty<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: _V_tyreg_poly_ty) {}
}
export function Proof_Arg_A_ty_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_ty<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_ty(d,_tw_args[0])
  return new Proof_Arg_A_ty(arg)
}
export class Proof_Arg_A_int<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: bigint) {}
}
export function Proof_Arg_A_int_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_int<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_int(_tw_args[0])
  return new Proof_Arg_A_int(arg)
}
export class Proof_Arg_A_string<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: string) {}
}
export function Proof_Arg_A_string_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_string<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Proof_Arg_A_string(arg)
}
export class Proof_Arg_A_list<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty>>) {}
}
export function Proof_Arg_A_list_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_list<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => Proof_Arg_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  return new Proof_Arg_A_list(arg)
}
export class Proof_Arg_A_dict<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Array<[string,Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty>]>) {}
}
export function Proof_Arg_A_dict_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_dict<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [string,Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty>] => { checkArrayLength(x, tup, 2); return [d.get_str(tup[0]), Proof_Arg_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[1])] })(d.get_array(x).toArray()))
  return new Proof_Arg_A_dict(arg)
}
export class Proof_Arg_A_seq<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Sequent_t_poly<_V_tyreg_poly_term>) {}
}
export function Proof_Arg_A_seq_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Proof_Arg_A_seq<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),_tw_args[0])
  return new Proof_Arg_A_seq(arg)
}
export type Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Proof_Arg_A_term<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_ty<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_int<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_string<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_list<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_dict<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Proof_Arg_A_seq<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Proof_Arg_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Proof_Arg_A_term_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Proof_Arg_A_ty_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Proof_Arg_A_int_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Proof_Arg_A_string_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Proof_Arg_A_list_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 5:
      return Proof_Arg_A_dict_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 6:
      return Proof_Arg_A_seq_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Proof_Arg, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_proof.Var_poly.t (cached: false)
// def Imandrax_api_proof.Var_poly.t (mangled name: "Proof_Var_poly")
export type Proof_Var_poly<_V_tyreg_poly_ty> = [Uid,_V_tyreg_poly_ty];

export function Proof_Var_poly_of_twine<_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Proof_Var_poly<_V_tyreg_poly_ty> {
 decode__tyreg_poly_ty; // ignore
  return ((tup : Array<offset>): [Uid,_V_tyreg_poly_ty] => { checkArrayLength(off, tup, 2); return [Uid_of_twine(d, tup[0]), decode__tyreg_poly_ty(d,tup[1])] })(d.get_array(off).toArray())
}

// clique Imandrax_api_proof.View.t (cached: false)
// def Imandrax_api_proof.View.t (mangled name: "Proof_View")
export class Proof_View_T_assume<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  constructor(){}
}
export class Proof_View_T_subst<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  constructor(
    public t_subst: Array<[Proof_Var_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_term]>,
    public ty_subst: Array<[Uid,_V_tyreg_poly_ty]>,
    public premise: _V_tyreg_poly_proof){}
}

export function Proof_View_T_subst_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_proof: (d:twine.Decoder, off:offset) => _V_tyreg_poly_proof,_tw_args: Array<offset>, off: offset): Proof_View_T_subst<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  decode__tyreg_poly_proof
  checkArrayLength(off, _tw_args, 3)
  const t_subst = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [Proof_Var_poly<_V_tyreg_poly_ty>,_V_tyreg_poly_term] => { checkArrayLength(x, tup, 2); return [Proof_Var_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[0]), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(x).toArray()))
  const ty_subst = d.get_array(_tw_args[1]).toArray().map(x => ((tup : Array<offset>): [Uid,_V_tyreg_poly_ty] => { checkArrayLength(x, tup, 2); return [Uid_of_twine(d, tup[0]), decode__tyreg_poly_ty(d,tup[1])] })(d.get_array(x).toArray()))
  const premise = decode__tyreg_poly_proof(d,_tw_args[2])
  return new Proof_View_T_subst(t_subst,ty_subst,premise)
}
export class Proof_View_T_deduction<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  constructor(
    public premises: Array<[string,Array<_V_tyreg_poly_proof>]>){}
}

export function Proof_View_T_deduction_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_proof: (d:twine.Decoder, off:offset) => _V_tyreg_poly_proof,_tw_args: Array<offset>, off: offset): Proof_View_T_deduction<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  decode__tyreg_poly_proof
  checkArrayLength(off, _tw_args, 1)
  const premises = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [string,Array<_V_tyreg_poly_proof>] => { checkArrayLength(x, tup, 2); return [d.get_str(tup[0]), d.get_array(tup[1]).toArray().map(x => decode__tyreg_poly_proof(d,x))] })(d.get_array(x).toArray()))
  return new Proof_View_T_deduction(premises)
}
export class Proof_View_T_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  constructor(
    public rule: string,
    public args: Array<Proof_Arg<_V_tyreg_poly_term,_V_tyreg_poly_ty>>){}
}

export function Proof_View_T_rule_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_proof: (d:twine.Decoder, off:offset) => _V_tyreg_poly_proof,_tw_args: Array<offset>, off: offset): Proof_View_T_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  decode__tyreg_poly_proof
  checkArrayLength(off, _tw_args, 2)
  const rule = d.get_str(_tw_args[0])
  const args = d.get_array(_tw_args[1]).toArray().map(x => Proof_Arg_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x))
  return new Proof_View_T_rule(rule,args)
}
export type Proof_View<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> = Proof_View_T_assume<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>| Proof_View_T_subst<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>| Proof_View_T_deduction<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>| Proof_View_T_rule<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>

export function Proof_View_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty, decode__tyreg_poly_proof: (d:twine.Decoder, off:offset) => _V_tyreg_poly_proof,off: offset): Proof_View<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
     return new Proof_View_T_assume<_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof>()
   case 1:
      return Proof_View_T_subst_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_proof, c.args, off)
   case 2:
      return Proof_View_T_deduction_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_proof, c.args, off)
   case 3:
      return Proof_View_T_rule_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, decode__tyreg_poly_proof, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Proof_View, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_proof.Proof_term.t_poly (cached: false)
// def Imandrax_api_proof.Proof_term.t_poly (mangled name: "Proof_Proof_term_t_poly")
export class Proof_Proof_term_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public id:bigint,
    public concl:Common_Sequent_t_poly<_V_tyreg_poly_term>,
    public view:Proof_View<_V_tyreg_poly_term,_V_tyreg_poly_ty,Proof_Proof_term_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>) {}
}

export function Proof_Proof_term_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Proof_Proof_term_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const id = d.get_int(fields[0])
  const concl = Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),fields[1])
  const view = Proof_View_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)), ((d:twine.Decoder,off:offset) => Proof_Proof_term_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[2])
  return new Proof_Proof_term_t_poly(id, concl, view)
}

// clique Imandrax_api_tasks.PO_task.t_poly (cached: false)
// def Imandrax_api_tasks.PO_task.t_poly (mangled name: "Tasks_PO_task_t_poly")
export class Tasks_PO_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public from_sym:string,
    public count:bigint,
    public db:Common_Db_ser_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public po:Common_Proof_obligation_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}

export function Tasks_PO_task_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const from_sym = d.get_str(fields[0])
  const count = d.get_int(fields[1])
  const db = Common_Db_ser_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[2])
  const po = Common_Proof_obligation_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[3])
  return new Tasks_PO_task_t_poly(from_sym, count, db, po)
}

// clique Imandrax_api_tasks.PO_task.Mir.t (cached: false)
// def Imandrax_api_tasks.PO_task.Mir.t (mangled name: "Tasks_PO_task_Mir")
export type Tasks_PO_task_Mir = Tasks_PO_task_t_poly<Mir_Term,Mir_Type>;

export function Tasks_PO_task_Mir_of_twine(d: twine.Decoder, off: offset): Tasks_PO_task_Mir {
  return Tasks_PO_task_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.PO_res.stats (cached: false)
// def Imandrax_api_tasks.PO_res.stats (mangled name: "Tasks_PO_res_stats")
export type Tasks_PO_res_stats = Stat_time;

export function Tasks_PO_res_stats_of_twine(d: twine.Decoder, off: offset): Tasks_PO_res_stats {
  return Stat_time_of_twine(d, off)
}

// clique Imandrax_api_tasks.PO_res.sub_res (cached: false)
// def Imandrax_api_tasks.PO_res.sub_res (mangled name: "Tasks_PO_res_sub_res")
export class Tasks_PO_res_sub_res<_V_tyreg_poly_term> {
  constructor(
    public sub_anchor:Sub_anchor,
    public goal:Common_Sequent_t_poly<_V_tyreg_poly_term>,
    public sub_goals:Array<Common_Sequent_t_poly<_V_tyreg_poly_term>>,
    public res:null | string) {}
}

export function Tasks_PO_res_sub_res_of_twine<_V_tyreg_poly_term>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term,off: offset): Tasks_PO_res_sub_res<_V_tyreg_poly_term> {
    decode__tyreg_poly_term
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const sub_anchor = Sub_anchor_of_twine(d, fields[0])
  const goal = Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),fields[1])
  const sub_goals = d.get_array(fields[2]).toArray().map(x => Common_Sequent_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x))
  const res = twine.result(d,  ((d:twine.Decoder,off:offset)=> d.get_null(off)), ((d:twine.Decoder,off:offset) => d.get_str(off)), fields[3])
  return new Tasks_PO_res_sub_res(sub_anchor, goal, sub_goals, res)
}

// clique Imandrax_api_tasks.PO_res.proof_found (cached: false)
// def Imandrax_api_tasks.PO_res.proof_found (mangled name: "Tasks_PO_res_proof_found")
export class Tasks_PO_res_proof_found<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public anchor:Anchor,
    public proof:Proof_Proof_term_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public sub_anchor:undefined | Sub_anchor) {}
}

export function Tasks_PO_res_proof_found_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_proof_found<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 3)
  const anchor = Anchor_of_twine(d, fields[0])
  const proof = Proof_Proof_term_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const sub_anchor = twine.optional(d,  ((d:twine.Decoder,off:offset) => Sub_anchor_of_twine(d, off)), fields[2])
  return new Tasks_PO_res_proof_found(anchor, proof, sub_anchor)
}

// clique Imandrax_api_tasks.PO_res.verified_upto (cached: false)
// def Imandrax_api_tasks.PO_res.verified_upto (mangled name: "Tasks_PO_res_verified_upto")
export class Tasks_PO_res_verified_upto {
  constructor(
    public anchor:Anchor,
    public upto:Upto) {}
}

export function Tasks_PO_res_verified_upto_of_twine(d: twine.Decoder, off: offset): Tasks_PO_res_verified_upto {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const anchor = Anchor_of_twine(d, fields[0])
  const upto = Upto_of_twine(d, fields[1])
  return new Tasks_PO_res_verified_upto(anchor, upto)
}

// clique Imandrax_api_tasks.PO_res.instance (cached: false)
// def Imandrax_api_tasks.PO_res.instance (mangled name: "Tasks_PO_res_instance")
export class Tasks_PO_res_instance<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public anchor:Anchor,
    public model:Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}

export function Tasks_PO_res_instance_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_instance<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const anchor = Anchor_of_twine(d, fields[0])
  const model = Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  return new Tasks_PO_res_instance(anchor, model)
}

// clique Imandrax_api_tasks.PO_res.no_proof (cached: false)
// def Imandrax_api_tasks.PO_res.no_proof (mangled name: "Tasks_PO_res_no_proof")
export class Tasks_PO_res_no_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public err:Error_Error_core,
    public counter_model:undefined | Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public subgoals:Array<Mir_Sequent>,
    public sub_anchor:undefined | Sub_anchor) {}
}

export function Tasks_PO_res_no_proof_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_no_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const err = Error_Error_core_of_twine(d, fields[0])
  const counter_model = twine.optional(d,  ((d:twine.Decoder,off:offset) => Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), fields[1])
  const subgoals = d.get_array(fields[2]).toArray().map(x => Mir_Sequent_of_twine(d, x))
  const sub_anchor = twine.optional(d,  ((d:twine.Decoder,off:offset) => Sub_anchor_of_twine(d, off)), fields[3])
  return new Tasks_PO_res_no_proof(err, counter_model, subgoals, sub_anchor)
}

// clique Imandrax_api_tasks.PO_res.unsat (cached: false)
// def Imandrax_api_tasks.PO_res.unsat (mangled name: "Tasks_PO_res_unsat")
export class Tasks_PO_res_unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public anchor:Anchor,
    public err:Error_Error_core,
    public proof:Proof_Proof_term_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public sub_anchor:undefined | Sub_anchor) {}
}

export function Tasks_PO_res_unsat_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const anchor = Anchor_of_twine(d, fields[0])
  const err = Error_Error_core_of_twine(d, fields[1])
  const proof = Proof_Proof_term_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[2])
  const sub_anchor = twine.optional(d,  ((d:twine.Decoder,off:offset) => Sub_anchor_of_twine(d, off)), fields[3])
  return new Tasks_PO_res_unsat(anchor, err, proof, sub_anchor)
}

// clique Imandrax_api_tasks.PO_res.success (cached: false)
// def Imandrax_api_tasks.PO_res.success (mangled name: "Tasks_PO_res_success")
export class Tasks_PO_res_success_Proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_PO_res_proof_found<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_PO_res_success_Proof_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_success_Proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_PO_res_proof_found_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_PO_res_success_Proof(arg)
}
export class Tasks_PO_res_success_Instance<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_PO_res_instance<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_PO_res_success_Instance_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_success_Instance<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_PO_res_instance_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_PO_res_success_Instance(arg)
}
export class Tasks_PO_res_success_Verified_upto<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_PO_res_verified_upto) {}
}
export function Tasks_PO_res_success_Verified_upto_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_success_Verified_upto<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_PO_res_verified_upto_of_twine(d, _tw_args[0])
  return new Tasks_PO_res_success_Verified_upto(arg)
}
export type Tasks_PO_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Tasks_PO_res_success_Proof<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_PO_res_success_Instance<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_PO_res_success_Verified_upto<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Tasks_PO_res_success_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Tasks_PO_res_success_Proof_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Tasks_PO_res_success_Instance_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Tasks_PO_res_success_Verified_upto_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Tasks_PO_res_success, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_tasks.PO_res.error (cached: false)
// def Imandrax_api_tasks.PO_res.error (mangled name: "Tasks_PO_res_error")
export class Tasks_PO_res_error_No_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_PO_res_no_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_PO_res_error_No_proof_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_error_No_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_PO_res_no_proof_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_PO_res_error_No_proof(arg)
}
export class Tasks_PO_res_error_Unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_PO_res_unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_PO_res_error_Unsat_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_error_Unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_PO_res_unsat_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_PO_res_error_Unsat(arg)
}
export class Tasks_PO_res_error_Invalid_model<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Error_Error_core,Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Tasks_PO_res_error_Invalid_model_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_error_Invalid_model<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Error_Error_core,Common_Model_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Error_Error_core_of_twine(d, _tw_args[0]),Common_Model_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Tasks_PO_res_error_Invalid_model(cargs)
}
export class Tasks_PO_res_error_Error<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Error_Error_core) {}
}
export function Tasks_PO_res_error_Error_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_PO_res_error_Error<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Error_Error_core_of_twine(d, _tw_args[0])
  return new Tasks_PO_res_error_Error(arg)
}
export type Tasks_PO_res_error<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Tasks_PO_res_error_No_proof<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_PO_res_error_Unsat<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_PO_res_error_Invalid_model<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_PO_res_error_Error<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Tasks_PO_res_error_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_error<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Tasks_PO_res_error_No_proof_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Tasks_PO_res_error_Unsat_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Tasks_PO_res_error_Invalid_model_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Tasks_PO_res_error_Error_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Tasks_PO_res_error, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_tasks.PO_res.result (cached: false)
// def Imandrax_api_tasks.PO_res.result (mangled name: "Tasks_PO_res_result")
export type Tasks_PO_res_result<_V_tyreg_poly_a,_V_tyreg_poly_term,_V_tyreg_poly_ty> = _V_tyreg_poly_a | Tasks_PO_res_error<_V_tyreg_poly_term,_V_tyreg_poly_ty>;

export function Tasks_PO_res_result_of_twine<_V_tyreg_poly_a,_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_result<_V_tyreg_poly_a,_V_tyreg_poly_term,_V_tyreg_poly_ty> {
 decode__tyreg_poly_a; // ignore
 decode__tyreg_poly_term; // ignore
 decode__tyreg_poly_ty; // ignore
  return twine.result(d,  ((d:twine.Decoder,off:offset)=> decode__tyreg_poly_a(d,off)), ((d:twine.Decoder,off:offset) => Tasks_PO_res_error_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), off)
}

// clique Imandrax_api_tasks.PO_res.shallow_poly (cached: false)
// def Imandrax_api_tasks.PO_res.shallow_poly (mangled name: "Tasks_PO_res_shallow_poly")
export class Tasks_PO_res_shallow_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public from_:Ca_store_Ca_ptr<Common_Proof_obligation_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>,
    public res:Tasks_PO_res_result<Tasks_PO_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty>,_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public stats:Tasks_PO_res_stats,
    public report:In_mem_archive<Report_Report>,
    public sub_res:Array<Array<Tasks_PO_res_sub_res<_V_tyreg_poly_term>>>) {}
}

export function Tasks_PO_res_shallow_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_shallow_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 5)
  const from_ = Ca_store_Ca_ptr_of_twine(d,((d:twine.Decoder,off:offset) => Common_Proof_obligation_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[0])
  const res = Tasks_PO_res_result_of_twine(d,((d:twine.Decoder,off:offset) => Tasks_PO_res_success_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const stats = Tasks_PO_res_stats_of_twine(d, fields[2])
  const report = In_mem_archive_of_twine(d,((d:twine.Decoder,off:offset) => Report_Report_of_twine(d, off)),fields[3])
  const sub_res = d.get_array(fields[4]).toArray().map(x => d.get_array(x).toArray().map(x => Tasks_PO_res_sub_res_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x)))
  return new Tasks_PO_res_shallow_poly(from_, res, stats, report, sub_res)
}

// clique Imandrax_api_tasks.PO_res.full_poly (cached: false)
// def Imandrax_api_tasks.PO_res.full_poly (mangled name: "Tasks_PO_res_full_poly")
export class Tasks_PO_res_full_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public from_:Common_Proof_obligation_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public res:Tasks_PO_res_result<Tasks_PO_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty>,_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public stats:Tasks_PO_res_stats,
    public report:In_mem_archive<Report_Report>,
    public sub_res:Array<Array<Tasks_PO_res_sub_res<_V_tyreg_poly_term>>>) {}
}

export function Tasks_PO_res_full_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_PO_res_full_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 5)
  const from_ = Common_Proof_obligation_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const res = Tasks_PO_res_result_of_twine(d,((d:twine.Decoder,off:offset) => Tasks_PO_res_success_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const stats = Tasks_PO_res_stats_of_twine(d, fields[2])
  const report = In_mem_archive_of_twine(d,((d:twine.Decoder,off:offset) => Report_Report_of_twine(d, off)),fields[3])
  const sub_res = d.get_array(fields[4]).toArray().map(x => d.get_array(x).toArray().map(x => Tasks_PO_res_sub_res_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)),x)))
  return new Tasks_PO_res_full_poly(from_, res, stats, report, sub_res)
}

// clique Imandrax_api_tasks.PO_res.Shallow.t (cached: false)
// def Imandrax_api_tasks.PO_res.Shallow.t (mangled name: "Tasks_PO_res_Shallow")
export type Tasks_PO_res_Shallow = Tasks_PO_res_shallow_poly<Mir_Term,Mir_Type>;

export function Tasks_PO_res_Shallow_of_twine(d: twine.Decoder, off: offset): Tasks_PO_res_Shallow {
  return Tasks_PO_res_shallow_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.PO_res.full.t (cached: false)
// def Imandrax_api_tasks.PO_res.full.t (mangled name: "Tasks_PO_res_full")
export type Tasks_PO_res_full = Tasks_PO_res_full_poly<Mir_Term,Mir_Type>;

export function Tasks_PO_res_full_of_twine(d: twine.Decoder, off: offset): Tasks_PO_res_full {
  return Tasks_PO_res_full_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.Eval_task.t_poly (cached: false)
// def Imandrax_api_tasks.Eval_task.t_poly (mangled name: "Tasks_Eval_task_t_poly")
export class Tasks_Eval_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public db:Common_Db_ser_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public term:[Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term],
    public anchor:Anchor,
    public timeout:undefined | bigint) {}
}

export function Tasks_Eval_task_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Eval_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const db = Common_Db_ser_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const term = ((tup : Array<offset>): [Array<Common_Var_t_poly<_V_tyreg_poly_ty>>,_V_tyreg_poly_term] => { checkArrayLength(fields[1], tup, 2); return [d.get_array(tup[0]).toArray().map(x => Common_Var_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),x)), decode__tyreg_poly_term(d,tup[1])] })(d.get_array(fields[1]).toArray())
  const anchor = Anchor_of_twine(d, fields[2])
  const timeout = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[3])
  return new Tasks_Eval_task_t_poly(db, term, anchor, timeout)
}

// clique Imandrax_api_tasks.Eval_task.Mir.t (cached: false)
// def Imandrax_api_tasks.Eval_task.Mir.t (mangled name: "Tasks_Eval_task_Mir")
export type Tasks_Eval_task_Mir = Tasks_Eval_task_t_poly<Mir_Term,Mir_Type>;

export function Tasks_Eval_task_Mir_of_twine(d: twine.Decoder, off: offset): Tasks_Eval_task_Mir {
  return Tasks_Eval_task_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.Eval_res.value (cached: false)
// def Imandrax_api_tasks.Eval_res.value (mangled name: "Tasks_Eval_res_value")
export type Tasks_Eval_res_value = Eval_Value;

export function Tasks_Eval_res_value_of_twine(d: twine.Decoder, off: offset): Tasks_Eval_res_value {
  return Eval_Value_of_twine(d, off)
}

// clique Imandrax_api_tasks.Eval_res.stats (cached: false)
// def Imandrax_api_tasks.Eval_res.stats (mangled name: "Tasks_Eval_res_stats")
export class Tasks_Eval_res_stats {
  constructor(
    public compile_time:number,
    public exec_time:number) {}
}

export function Tasks_Eval_res_stats_of_twine(d: twine.Decoder, off: offset): Tasks_Eval_res_stats {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const compile_time = d.get_float(fields[0])
  const exec_time = d.get_float(fields[1])
  return new Tasks_Eval_res_stats(compile_time, exec_time)
}

// clique Imandrax_api_tasks.Eval_res.success (cached: false)
// def Imandrax_api_tasks.Eval_res.success (mangled name: "Tasks_Eval_res_success")
export class Tasks_Eval_res_success {
  constructor(
    public v:Tasks_Eval_res_value) {}
}

export function Tasks_Eval_res_success_of_twine(d: twine.Decoder, off: offset): Tasks_Eval_res_success {
  const x = Tasks_Eval_res_value_of_twine(d, off) // single unboxed field
  return new Tasks_Eval_res_success(x)
}

// clique Imandrax_api_tasks.Eval_res.t (cached: false)
// def Imandrax_api_tasks.Eval_res.t (mangled name: "Tasks_Eval_res")
export class Tasks_Eval_res {
  constructor(
    public res:Error | Tasks_Eval_res_success,
    public stats:Tasks_Eval_res_stats) {}
}

export function Tasks_Eval_res_of_twine(d: twine.Decoder, off: offset): Tasks_Eval_res {
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const res = twine.result(d, ((d:twine.Decoder,off:offset) =>  Tasks_Eval_res_success_of_twine(d, off)), ((d: twine.Decoder, off: offset)  => Error_Error_core_of_twine(d, off)), fields[0])
  const stats = Tasks_Eval_res_stats_of_twine(d, fields[1])
  return new Tasks_Eval_res(res, stats)
}

// clique Imandrax_api_tasks.Decomp_task.decomp_poly (cached: false)
// def Imandrax_api_tasks.Decomp_task.decomp_poly (mangled name: "Tasks_Decomp_task_decomp_poly")
export class Tasks_Decomp_task_decomp_poly_Decomp<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Decomp_t_) {}
}
export function Tasks_Decomp_task_decomp_poly_Decomp_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Decomp<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Decomp_t__of_twine(d, _tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Decomp(arg)
}
export class Tasks_Decomp_task_decomp_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: _V_tyreg_poly_term) {}
}
export function Tasks_Decomp_task_decomp_poly_Term_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = decode__tyreg_poly_term(d,_tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Term(arg)
}
export class Tasks_Decomp_task_decomp_poly_Return<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Common_Fun_decomp_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_Decomp_task_decomp_poly_Return_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Return<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Common_Fun_decomp_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Return(arg)
}
export class Tasks_Decomp_task_decomp_poly_Prune<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_Decomp_task_decomp_poly_Prune_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Prune<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Prune(arg)
}
export class Tasks_Decomp_task_decomp_poly_Merge<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Tasks_Decomp_task_decomp_poly_Merge_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Merge<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Tasks_Decomp_task_decomp_poly_Merge(cargs)
}
export class Tasks_Decomp_task_decomp_poly_Compound_merge<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public args: [Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]){}
}
export function Tasks_Decomp_task_decomp_poly_Compound_merge_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Compound_merge<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore
  decode__tyreg_poly_ty; // ignore
  checkArrayLength(off, _tw_args, 2)
  const cargs: [Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] = [Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0]),Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])]
  return new Tasks_Decomp_task_decomp_poly_Compound_merge(cargs)
}
export class Tasks_Decomp_task_decomp_poly_Combine<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}
export function Tasks_Decomp_task_decomp_poly_Combine_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Combine<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Combine(arg)
}
export class Tasks_Decomp_task_decomp_poly_Get<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(public arg: string) {}
}
export function Tasks_Decomp_task_decomp_poly_Get_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Get<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term; // ignore 
  decode__tyreg_poly_ty; // ignore 
  checkArrayLength(off, _tw_args, 1)
  const arg = d.get_str(_tw_args[0])
  return new Tasks_Decomp_task_decomp_poly_Get(arg)
}
export class Tasks_Decomp_task_decomp_poly_Let<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public bindings: Array<[string,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>]>,
    public and_then: Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>){}
}

export function Tasks_Decomp_task_decomp_poly_Let_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,_tw_args: Array<offset>, off: offset): Tasks_Decomp_task_decomp_poly_Let<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  decode__tyreg_poly_term
  decode__tyreg_poly_ty
  checkArrayLength(off, _tw_args, 2)
  const bindings = d.get_array(_tw_args[0]).toArray().map(x => ((tup : Array<offset>): [string,Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>] => { checkArrayLength(x, tup, 2); return [d.get_str(tup[0]), Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),tup[1])] })(d.get_array(x).toArray()))
  const and_then = Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),_tw_args[1])
  return new Tasks_Decomp_task_decomp_poly_Let(bindings,and_then)
}
export type Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> = Tasks_Decomp_task_decomp_poly_Decomp<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Term<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Return<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Prune<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Merge<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Compound_merge<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Combine<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Get<_V_tyreg_poly_term,_V_tyreg_poly_ty>| Tasks_Decomp_task_decomp_poly_Let<_V_tyreg_poly_term,_V_tyreg_poly_ty>

export function Tasks_Decomp_task_decomp_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Tasks_Decomp_task_decomp_poly_Decomp_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 1:
      return Tasks_Decomp_task_decomp_poly_Term_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 2:
      return Tasks_Decomp_task_decomp_poly_Return_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 3:
      return Tasks_Decomp_task_decomp_poly_Prune_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 4:
      return Tasks_Decomp_task_decomp_poly_Merge_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 5:
      return Tasks_Decomp_task_decomp_poly_Compound_merge_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 6:
      return Tasks_Decomp_task_decomp_poly_Combine_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 7:
      return Tasks_Decomp_task_decomp_poly_Get_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   case 8:
      return Tasks_Decomp_task_decomp_poly_Let_of_twine(d, decode__tyreg_poly_term, decode__tyreg_poly_ty, c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Tasks_Decomp_task_decomp_poly, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_tasks.Decomp_task.t_poly (cached: false)
// def Imandrax_api_tasks.Decomp_task.t_poly (mangled name: "Tasks_Decomp_task_t_poly")
export class Tasks_Decomp_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public db:Common_Db_ser_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public decomp:Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public anchor:Anchor,
    public timeout:undefined | bigint) {}
}

export function Tasks_Decomp_task_t_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Decomp_task_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const db = Common_Db_ser_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const decomp = Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  const anchor = Anchor_of_twine(d, fields[2])
  const timeout = twine.optional(d,  ((d:twine.Decoder,off:offset) => d.get_int(off)), fields[3])
  return new Tasks_Decomp_task_t_poly(db, decomp, anchor, timeout)
}

// clique Imandrax_api_tasks.Decomp_task.Mir.decomp (cached: false)
// def Imandrax_api_tasks.Decomp_task.Mir.decomp (mangled name: "Tasks_Decomp_task_Mir_decomp")
export type Tasks_Decomp_task_Mir_decomp = Tasks_Decomp_task_decomp_poly<Mir_Term,Mir_Type>;

export function Tasks_Decomp_task_Mir_decomp_of_twine(d: twine.Decoder, off: offset): Tasks_Decomp_task_Mir_decomp {
  return Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.Decomp_task.Mir.t (cached: false)
// def Imandrax_api_tasks.Decomp_task.Mir.t (mangled name: "Tasks_Decomp_task_Mir")
export type Tasks_Decomp_task_Mir = Tasks_Decomp_task_t_poly<Mir_Term,Mir_Type>;

export function Tasks_Decomp_task_Mir_of_twine(d: twine.Decoder, off: offset): Tasks_Decomp_task_Mir {
  return Tasks_Decomp_task_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.Decomp_res.success (cached: false)
// def Imandrax_api_tasks.Decomp_res.success (mangled name: "Tasks_Decomp_res_success")
export class Tasks_Decomp_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public anchor:Anchor,
    public decomp:Common_Fun_decomp_t_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>) {}
}

export function Tasks_Decomp_res_success_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Decomp_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 2)
  const anchor = Anchor_of_twine(d, fields[0])
  const decomp = Common_Fun_decomp_t_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[1])
  return new Tasks_Decomp_res_success(anchor, decomp)
}

// clique Imandrax_api_tasks.Decomp_res.error (cached: false)
// def Imandrax_api_tasks.Decomp_res.error (mangled name: "Tasks_Decomp_res_error")
export class Tasks_Decomp_res_error_Error {
  constructor(public arg: Error_Error_core) {}
}
export function Tasks_Decomp_res_error_Error_of_twine(d: twine.Decoder, _tw_args: Array<offset>, off: offset): Tasks_Decomp_res_error_Error {
  checkArrayLength(off, _tw_args, 1)
  const arg = Error_Error_core_of_twine(d, _tw_args[0])
  return new Tasks_Decomp_res_error_Error(arg)
}
export type Tasks_Decomp_res_error = Tasks_Decomp_res_error_Error

export function Tasks_Decomp_res_error_of_twine(d: twine.Decoder, off: offset): Tasks_Decomp_res_error {
  const c = d.get_cstor(off)
  switch (c.cstor_idx) {
   case 0:
      return Tasks_Decomp_res_error_Error_of_twine(d,  c.args, off)
   default:
      throw new twine.TwineError({msg: `expected Tasks_Decomp_res_error, got invalid constructor ${c.cstor_idx}`, offset: off})

  }
}

// clique Imandrax_api_tasks.Decomp_res.result (cached: false)
// def Imandrax_api_tasks.Decomp_res.result (mangled name: "Tasks_Decomp_res_result")
export type Tasks_Decomp_res_result<_V_tyreg_poly_a> = _V_tyreg_poly_a | Tasks_Decomp_res_error;

export function Tasks_Decomp_res_result_of_twine<_V_tyreg_poly_a>(d: twine.Decoder, decode__tyreg_poly_a: (d:twine.Decoder, off:offset) => _V_tyreg_poly_a,off: offset): Tasks_Decomp_res_result<_V_tyreg_poly_a> {
 decode__tyreg_poly_a; // ignore
  return twine.result(d,  ((d:twine.Decoder,off:offset)=> decode__tyreg_poly_a(d,off)), ((d:twine.Decoder,off:offset) => Tasks_Decomp_res_error_of_twine(d, off)), off)
}

// clique Imandrax_api_tasks.Decomp_res.shallow_poly (cached: false)
// def Imandrax_api_tasks.Decomp_res.shallow_poly (mangled name: "Tasks_Decomp_res_shallow_poly")
export class Tasks_Decomp_res_shallow_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public from_:Ca_store_Ca_ptr<Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>>,
    public res:Tasks_Decomp_res_result<Tasks_Decomp_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty>>,
    public stats:Stat_time,
    public report:In_mem_archive<Report_Report>) {}
}

export function Tasks_Decomp_res_shallow_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Decomp_res_shallow_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const from_ = Ca_store_Ca_ptr_of_twine(d,((d:twine.Decoder,off:offset) => Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[0])
  const res = Tasks_Decomp_res_result_of_twine(d,((d:twine.Decoder,off:offset) => Tasks_Decomp_res_success_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[1])
  const stats = Stat_time_of_twine(d, fields[2])
  const report = In_mem_archive_of_twine(d,((d:twine.Decoder,off:offset) => Report_Report_of_twine(d, off)),fields[3])
  return new Tasks_Decomp_res_shallow_poly(from_, res, stats, report)
}

// clique Imandrax_api_tasks.Decomp_res.full_poly (cached: false)
// def Imandrax_api_tasks.Decomp_res.full_poly (mangled name: "Tasks_Decomp_res_full_poly")
export class Tasks_Decomp_res_full_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
  constructor(
    public from_:Tasks_Decomp_task_decomp_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty>,
    public res:Tasks_Decomp_res_result<Tasks_Decomp_res_success<_V_tyreg_poly_term,_V_tyreg_poly_ty>>,
    public stats:Stat_time,
    public report:In_mem_archive<Report_Report>) {}
}

export function Tasks_Decomp_res_full_poly_of_twine<_V_tyreg_poly_term,_V_tyreg_poly_ty>(d: twine.Decoder, decode__tyreg_poly_term: (d:twine.Decoder, off:offset) => _V_tyreg_poly_term, decode__tyreg_poly_ty: (d:twine.Decoder, off:offset) => _V_tyreg_poly_ty,off: offset): Tasks_Decomp_res_full_poly<_V_tyreg_poly_term,_V_tyreg_poly_ty> {
    decode__tyreg_poly_term
    decode__tyreg_poly_ty
  const fields = d.get_array(off).toArray()
  checkArrayLength(off, fields, 4)
  const from_ = Tasks_Decomp_task_decomp_poly_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),fields[0])
  const res = Tasks_Decomp_res_result_of_twine(d,((d:twine.Decoder,off:offset) => Tasks_Decomp_res_success_of_twine(d,((d:twine.Decoder,off:offset) => decode__tyreg_poly_term(d,off)), ((d:twine.Decoder,off:offset) => decode__tyreg_poly_ty(d,off)),off)),fields[1])
  const stats = Stat_time_of_twine(d, fields[2])
  const report = In_mem_archive_of_twine(d,((d:twine.Decoder,off:offset) => Report_Report_of_twine(d, off)),fields[3])
  return new Tasks_Decomp_res_full_poly(from_, res, stats, report)
}

// clique Imandrax_api_tasks.Decomp_res.Shallow.t (cached: false)
// def Imandrax_api_tasks.Decomp_res.Shallow.t (mangled name: "Tasks_Decomp_res_Shallow")
export type Tasks_Decomp_res_Shallow = Tasks_Decomp_res_shallow_poly<Mir_Term,Mir_Type>;

export function Tasks_Decomp_res_Shallow_of_twine(d: twine.Decoder, off: offset): Tasks_Decomp_res_Shallow {
  return Tasks_Decomp_res_shallow_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}

// clique Imandrax_api_tasks.Decomp_res.Full.t (cached: false)
// def Imandrax_api_tasks.Decomp_res.Full.t (mangled name: "Tasks_Decomp_res_Full")
export type Tasks_Decomp_res_Full = Tasks_Decomp_res_full_poly<Mir_Term,Mir_Type>;

export function Tasks_Decomp_res_Full_of_twine(d: twine.Decoder, off: offset): Tasks_Decomp_res_Full {
  return Tasks_Decomp_res_full_poly_of_twine(d,((d:twine.Decoder,off:offset) => Mir_Term_of_twine(d, off)), ((d:twine.Decoder,off:offset) => Mir_Type_of_twine(d, off)),off)
}


// Artifacts

export type Artifact = Mir_Term|Mir_Type|Tasks_PO_task_Mir|Tasks_PO_res_Shallow|Tasks_Eval_task_Mir|Tasks_Eval_res|Mir_Model|string|Mir_Fun_decomp|Tasks_Decomp_task_Mir|Tasks_Decomp_res_Shallow|Report_Report|Mir_Decl

/** Artifact decoders */
export const artifact_decoders = {
  "term": ((d:twine.Decoder, off: offset): Mir_Term => Mir_Term_of_twine(d, off)),
  "ty": ((d:twine.Decoder, off: offset): Mir_Type => Mir_Type_of_twine(d, off)),
  "po_task": ((d:twine.Decoder, off: offset): Tasks_PO_task_Mir => Tasks_PO_task_Mir_of_twine(d, off)),
  "po_res": ((d:twine.Decoder, off: offset): Tasks_PO_res_Shallow => Tasks_PO_res_Shallow_of_twine(d, off)),
  "eval_task": ((d:twine.Decoder, off: offset): Tasks_Eval_task_Mir => Tasks_Eval_task_Mir_of_twine(d, off)),
  "eval_res": ((d:twine.Decoder, off: offset): Tasks_Eval_res => Tasks_Eval_res_of_twine(d, off)),
  "mir.model": ((d:twine.Decoder, off: offset): Mir_Model => Mir_Model_of_twine(d, off)),
  "show": ((d:twine.Decoder, off: offset): string => d.get_str(off)),
  "mir.fun_decomp": ((d:twine.Decoder, off: offset): Mir_Fun_decomp => Mir_Fun_decomp_of_twine(d, off)),
  "decomp_task": ((d:twine.Decoder, off: offset): Tasks_Decomp_task_Mir => Tasks_Decomp_task_Mir_of_twine(d, off)),
  "decomp_res": ((d:twine.Decoder, off: offset): Tasks_Decomp_res_Shallow => Tasks_Decomp_res_Shallow_of_twine(d, off)),
  "report": ((d:twine.Decoder, off: offset): Report_Report => Report_Report_of_twine(d, off)),
  "mir.decl": ((d:twine.Decoder, off: offset): Mir_Decl => Mir_Decl_of_twine(d, off))
}



  /*
def read_artifact_data(data: bytes, kind: str) -> Artifact:
    'Read artifact from `data`, with artifact kind `kind`'
    decoder = artifact_decoders[kind]
    twine_dec = twine.Decoder(data)
    return decoder(twine_dec, twine_dec.entrypoint())

def read_artifact_zip(path: str) -> Artifact:
    'Read artifact from a zip file'
    with ZipFile(path) as f:
        manifest = json.loads(f.read('manifest.json'))
        kind = str(manifest['kind'])
        twine_data = f.read('data.twine')
    return read_artifact_data(data=twine_data, kind=kind)
  */
  

