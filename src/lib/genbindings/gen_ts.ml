open Common_

(* FIXME: for ca store key: we need to read a tag 7 around the actual value *)

let bpf = Printf.bprintf
let fpf = Printf.fprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let prelude =
  {|'use strict';
// automatically generated using genbindings.ml, do not edit

import * as  twine from './twine.ts';

type offset = twine.offset;
export type Error = Error_Error_core;

export type WithTag7<T> = T;

function checkArrayLength(off: offset, a: Array<offset>, len: number): void {
  if (a.length < len) {
    throw new twine.TwineError({msg: `Array is too short (len=${a.length}, expected ${len} elements)`, offset: off})
  }
}

function decode_with_tag7<T>(d: twine.Decoder, off: offset, d0: (d: twine.Decoder, o: offset) => T) : WithTag7<T> {
  const tag = d.get_tag(off);
  if (tag.tag != 7)
    throw new twine.TwineError({msg: `Expected tag 7, got tag ${tag.tag}`, offset: off})
  return d0(d, tag.value)
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
  |}

let footer =
  {|

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
  |}

let mangle_ty_name (s : string) : string =
  let s =
    CCString.chop_prefix ~pre:"Imandrax_api." s
    ||? CCString.chop_prefix ~pre:"Imandrax_api_" s
    ||? CCString.chop_prefix ~pre:"Imandrakit_" s
    |? s
  in
  let s = CCString.chop_suffix ~suf:".t" s |? s in
  String.capitalize_ascii s |> CCString.replace ~sub:"." ~by:"_"

let mangle_field_name (s : string) : string =
  let s = String.uncapitalize_ascii s in
  match s with
  | "default" -> "default_"
  | "from" -> "from_"
  | _ -> s

let of_twine_of_ty_name (s : string) : string =
  let s = mangle_ty_name s in
  spf "%s_of_twine" s

let mangle_cstor_name_str ~tyname (c : string) : string =
  spf "%s_%s" (mangle_ty_name tyname) (String.capitalize_ascii c)

let mangle_cstor_name ~tyname (c : TR.Ty_def.cstor) : string =
  mangle_cstor_name_str ~tyname c.c

let rec gen_type_expr (ty : tyexpr) : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "_V%s" s
  | Tuple l -> spf "[%s]" (String.concat "," @@ List.map gen_type_expr l)
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    "Uint8Array"
  | Attrs (ty, _attrs) ->
    if List.mem_assoc "ocaml_only" _attrs then
      Printf.eprintf "warning: remaining `ocaml_only` attr\n%!";
    gen_type_expr ty
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] -> "bigint"
    | "string", [] -> "string"
    | "bool", [] -> "boolean"
    | "array", [ x ] | "list", [ x ] -> spf "Array<%s>" (gen_type_expr x)
    | "float", [] -> "number"
    | "unit", [] -> "null"
    | "B.t", [] -> "bigint" (* bllbll bitfield *)
    | "Uid.Set.t", [] -> "Set<Uid>"
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> "number" (* TODO: Date? *)
    | "Error.result", [ x ] -> spf "Error | %s" (gen_type_expr x)
    | "Util_twine.Result.t", [ x; y ] ->
      spf "%s | %s" (gen_type_expr x) (gen_type_expr y)
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "null"
    | "option", [ x ] -> spf "undefined | %s" (gen_type_expr x)
    | "Util_twine_.With_tag7.t", [ x ] -> spf "WithTag7<%s>" (gen_type_expr x)
    | "Util_twine_.Q.t", [] -> "[bigint, bigint]"
    | s, [] -> mangle_ty_name s
    | _ ->
      spf "%s<%s>" (mangle_ty_name s)
        (String.concat "," @@ List.map gen_type_expr args))

let of_twine_of_var (s : string) : string = spf "decode_%s" s

let rec of_twine_of_type_expr (ty : tyexpr) ~off : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "%s(d,%s)" (of_twine_of_var s) off
  | Tuple l ->
    spf
      "((tup : Array<offset>): %s => { checkArrayLength(%s, tup, %d); return \
       [%s] })(d.get_array(%s).toArray())"
      (gen_type_expr ty) (* explicit type needed *)
      off (List.length l)
      (String.concat ", "
      @@ List.mapi
           (fun i ty -> of_twine_of_type_expr ~off:(spf "tup[%d]" i) ty)
           l)
      off
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    spf "d.get_bytes(%s)" off
  | Attrs (ty, _) -> of_twine_of_type_expr ty ~off
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] ->
      spf "d.get_int(%s)" off
    | "string", [] -> spf "d.get_str(%s)" off
    | "bool", [] -> spf "d.get_bool(%s)" off
    | "array", [ x ] | "list", [ x ] ->
      spf "d.get_array(%s).toArray().map(x => %s)" off
        (of_twine_of_type_expr ~off:"x" x)
    | "float", [] -> spf "d.get_float(%s)" off
    | "unit", [] -> spf "d.get_null(%s)" off
    | "B.t", [] -> spf "d.get_int(%s)" off (* bllbll bitfield *)
    | "Uid.Set.t", [] ->
      spf "new Set(d.get_array(%s).toArray().map(x => %s))" off
        (of_twine_of_type_expr (Cstor ("Uid", [])) ~off:"x")
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> spf "d.get_float(%s)" off
    | "Error.result", [ x ] ->
      spf
        "twine.result(d, ((d:twine.Decoder,off:offset) =>  %s), ((d: \
         twine.Decoder, off: offset)  => Error_Error_core_of_twine(d, off)), \
         %s)"
        (of_twine_of_type_expr x ~off:"off")
        off
    | "Util_twine.Result.t", [ x; y ] ->
      spf
        "twine.result(d,  ((d:twine.Decoder,off:offset)=> %s), \
         ((d:twine.Decoder,off:offset) => %s), %s)"
        (of_twine_of_type_expr x ~off:"off")
        (of_twine_of_type_expr y ~off:"off")
        off
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "null"
    | "Util_twine_.With_tag7.t", [ x ] ->
      spf "decode_with_tag7(d, %s, ((d:twine.Decoder,off:offset) => %s))" off
        (of_twine_of_type_expr x ~off:"off")
    | "option", [ x ] ->
      spf "twine.optional(d,  ((d:twine.Decoder,off:offset) => %s), %s)"
        (of_twine_of_type_expr ~off:"off" x)
        off
    | "Util_twine_.Q.t", [] -> spf "decode_q(d,%s)" off
    | s, [] -> spf "%s(d, %s)" (of_twine_of_ty_name s) off
    | _ ->
      let args =
        String.concat ", "
        @@ List.map
             (fun ty ->
               spf "((d:twine.Decoder,off:offset) => %s)"
                 (of_twine_of_type_expr ~off:"off" ty))
             args
      in
      spf "%s(d,%s,%s)" (of_twine_of_ty_name s) args off)

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

(* TODO: ca store key (decode with tag) *)
let special_defs =
  [
    ( "Imandrax_api.Uid_set.t",
      {|type Uid_set = Set<Uid>

function Uid_set_of_twine(d: twine.Decoder, off: offset): Uid_set {
  return new Set(d.get_array(off).toArray().map(x => Uid_of_twine(d,x)))
}|}
    );
    ( "Imandrax_api.Chash.t",
      {|type Chash = Uint8Array;

function Chash_of_twine(d: twine.Decoder, off:number): Chash {
    return d.get_bytes(off)
}|}
    );
  ]
  |> Str_map.of_list

let gen_clique ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n// clique %s\n"
    (String.concat ", " @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let tsname = mangle_ty_name def.name in
    bpf buf "// def %s (mangled name: %S)\n" def.name tsname;

    let tsparams, ts_twine_params, params_decls, ts_twine_params_kw =
      match def.params with
      | [] -> "", "", [], ""
      | _ ->
        let params =
          spf "<%s>" (String.concat "," @@ List.map (spf "_V%s") def.params)
        and twine_params =
          spf "%s,"
            (String.concat ", "
            @@ List.map
                 (fun v ->
                   spf "%s: (d:twine.Decoder, off:offset) => _V%s"
                     (of_twine_of_var v) v)
                 def.params)
        and params_decls = List.map of_twine_of_var def.params
        and twine_params_kw =
          spf "%s," (String.concat ", " @@ List.map of_twine_of_var def.params)
        in
        params, twine_params, params_decls, twine_params_kw
    in

    let declare_ty (def : tydef) =
      match def.decl with
      | Alias ty ->
        bpf buf "export type %s%s = %s;\n\n" tsname tsparams (gen_type_expr ty);
        bpf buf
          "export function %s%s(d: twine.Decoder, %soff: offset): %s%s {\n"
          (of_twine_of_ty_name def.name)
          tsparams ts_twine_params tsname tsparams;
        List.iter (fun s -> bpf buf " %s; // ignore\n" s) params_decls;
        bpf buf "  return %s\n" (of_twine_of_type_expr ty ~off:"off");
        bpf buf "}\n"
      | Record r ->
        bpf buf "export class %s%s {\n" tsname tsparams;
        bpf buf "  constructor(";
        List.iteri
          (fun i (field, ty) ->
            if i > 0 then bpf buf ",";
            bpf buf "\n    public %s:%s" (mangle_field_name field)
              (gen_type_expr ty))
          r.fields;
        bpf buf ") {}\n";
        bpf buf "}\n";
        bpf buf "\n";

        bpf buf
          "export function %s_of_twine%s(d: twine.Decoder, %soff: offset): \
           %s%s {\n"
          tsname tsparams ts_twine_params tsname tsparams;
        if def.unboxed then (
          let _field_name, field_ty =
            match r.fields with
            | [ hd ] -> hd
            | _ -> assert false
          in
          bpf buf "  const x = %s // single unboxed field\n"
            (of_twine_of_type_expr ~off:"off" field_ty);
          bpf buf "  return new %s(x)\n" tsname
        ) else (
          List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
          bpf buf "  const fields = d.get_array(off).toArray()\n";
          bpf buf "  checkArrayLength(off, fields, %d)\n" (List.length r.fields);
          List.iteri
            (fun i (field, ty) ->
              bpf buf "  const %s = %s\n" (mangle_field_name field)
                (of_twine_of_type_expr ~off:(spf "fields[%d]" i) ty))
            r.fields;
          bpf buf "  return new %s(%s)\n" tsname
            (String.concat ", "
            @@ List.map (fun (field, _) -> mangle_field_name field) r.fields)
        );
        bpf buf "}\n"
      | TR.Ty_def.Alg cstors ->
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_tsname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "export class %s%s {\n" c_tsname tsparams;
            bpf buf "  constructor(";

            (match c.args, c.labels with
            | [], _ -> bpf buf "){}\n"
            | [ x ], None ->
              bpf buf "public arg: %s) {}\n}\n" (gen_type_expr x);
              bpf buf
                "export function %s_of_twine%s(d: twine.Decoder, %s_tw_args: \
                 Array<offset>, off: offset): %s%s {\n"
                c_tsname tsparams ts_twine_params c_tsname tsparams;
              List.iter (fun s -> bpf buf "  %s; // ignore \n" s) params_decls;
              bpf buf "  checkArrayLength(off, _tw_args, 1)\n";
              bpf buf "  const arg = %s\n"
                (of_twine_of_type_expr ~off:"_tw_args[0]" x);
              bpf buf "  return new %s(arg)\n" c_tsname
            | _, None ->
              bpf buf "public args: [%s]){}\n}\n"
                (String.concat "," @@ List.map gen_type_expr c.args);
              bpf buf
                "export function %s_of_twine%s(d: twine.Decoder, %s_tw_args: \
                 Array<offset>, off: offset): %s%s {\n"
                c_tsname tsparams ts_twine_params c_tsname tsparams;
              List.iter (fun s -> bpf buf "  %s; // ignore\n" s) params_decls;
              bpf buf "  checkArrayLength(off, _tw_args, %d)\n"
                (List.length c.args);
              bpf buf "  const cargs: %s = [%s]\n"
                (gen_type_expr @@ Tuple c.args)
                (String.concat ","
                @@ List.mapi
                     (fun i ty ->
                       of_twine_of_type_expr ~off:(spf "_tw_args[%d]" i) ty)
                     c.args);
              bpf buf "  return new %s(cargs)\n" c_tsname
            | _, Some labels ->
              let first = ref true in
              List.iter2
                (fun lbl ty ->
                  if !first then
                    first := false
                  else
                    bpf buf ",";
                  bpf buf "\n    public %s: %s" (mangle_field_name lbl)
                    (gen_type_expr ty))
                labels c.args;
              bpf buf "){}\n}\n\n";
              bpf buf
                "export function %s_of_twine%s(d: twine.Decoder, %s_tw_args: \
                 Array<offset>, off: offset): %s%s {\n"
                c_tsname tsparams ts_twine_params c_tsname tsparams;
              List.iter (fun s -> bpf buf "  %s\n" s) params_decls;
              bpf buf "  checkArrayLength(off, _tw_args, %d)\n"
                (List.length labels);
              CCList.iteri2
                (fun i lbl ty ->
                  bpf buf "  const %s = %s\n" (mangle_field_name lbl)
                    (of_twine_of_type_expr ty ~off:(spf "_tw_args[%d]" i)))
                labels c.args;
              bpf buf "  return new %s(%s)\n" c_tsname
                (String.concat "," @@ List.map mangle_field_name labels));
            bpf buf "}\n")
          cstors;
        bpf buf "export type %s%s = " tsname tsparams;
        List.iteri
          (fun i (c : TR.Ty_def.cstor) ->
            if i > 0 then bpf buf "| ";
            let c_name = mangle_cstor_name ~tyname:def.name c in
            bpf buf "%s%s" c_name tsparams)
          cstors;
        bpf buf "\n\n";

        bpf buf
          "export function %s_of_twine%s(d: twine.Decoder, %soff: offset): \
           %s%s {\n"
          tsname tsparams ts_twine_params tsname tsparams;
        bpf buf "  const c = d.get_cstor(off)\n";
        bpf buf "  switch (c.cstor_idx) {\n";
        List.iteri
          (fun i (c : TR.Ty_def.cstor) ->
            let c_tsname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "   case %d:\n" i;
            (match c.args with
            | [] -> bpf buf "     return new %s%s()\n" c_tsname tsparams
            | _ ->
              bpf buf "      return %s_of_twine(d, %s c.args, off)\n" c_tsname
                ts_twine_params_kw);
            ())
          cstors;

        bpf buf "   default:\n";
        bpf buf
          "      throw new twine.TwineError({msg: `expected %s, got invalid \
           constructor ${c.cstor_idx}`, offset: off})\n"
          tsname;
        bpf buf "\n  }\n}\n"
    in

    (match Str_map.find_opt def.name special_defs with
    | Some d ->
      (* special case *)
      bpf buf "%s\n" d
    | None -> declare_ty def);
    Buffer.output_buffer oc buf
  in

  List.iter gen_def clique;
  ()

let gen_artifacts (artifacts : Artifact.t list) : string =
  let buf = Buffer.create 32 in

  (* union of the types! *)
  bpf buf "\n\n// Artifacts\n\n";

  bpf buf "export type Artifact = %s\n\n"
  @@ String.concat "|"
  @@ List.map (fun (a : Artifact.t) -> gen_type_expr a.ty) artifacts;

  bpf buf "/** Artifact decoders */\n";
  bpf buf "export const artifact_decoders = {";
  List.iteri
    (fun i (a : Artifact.t) ->
      if i > 0 then bpf buf ",";
      bpf buf "\n  %S: ((d:twine.Decoder, off: offset): %s => %s)" a.tag
        (gen_type_expr a.ty)
        (of_twine_of_type_expr ~off:"off" a.ty))
    artifacts;
  bpf buf "\n}\n\n";

  bpf buf "%s\n" footer;

  Buffer.contents buf

let gen ~out ~(artifacts : Artifact.t list)
    ~types:(cliques : TR.Ty_def.clique list) () : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter (fun cl -> if not (skip_clique cl) then gen_clique ~oc cl) cliques;
  fpf oc "%s\n" (gen_artifacts artifacts);

  ()
