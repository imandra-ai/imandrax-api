open Common_

let bpf = Printf.bprintf
let fpf = Printf.fprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let prelude =
  {|
// automatically generated using genbindings.ml, do not edit

#![rustfmt::skip]
#![allow(non_camel_case_types)]

use bumpalo::Bump;
use num_bigint::BigInt;
use std::collections::HashSet;
use anyhow::bail;

// TODO: pub trait FromTwine { … }

// data we ignore upon deserialization.
#[derive(Clone,Copy,Debug)]
pub struct Ignored;

pub type Error = ErrorError_core;
  |}

(* TODO: B.t for the bitfield *)

(* TODO:
   - keep map of names to python names (replace . with _, capitalize, etc.)
   - map cliques
   - assume twine exists (!)
   - implement small twine library
*)

let mangle_ty_name (s : string) : string =
  let s =
    CCString.chop_prefix ~pre:"Imandrax_api." s
    ||? CCString.chop_prefix ~pre:"Imandrax_api_" s
    ||? CCString.chop_prefix ~pre:"Imandrakit_" s
    |? s
  in
  let s = CCString.chop_suffix ~suf:".t" s |? s in
  let components = String.split_on_char '.' s in
  String.concat "" @@ List.map String.capitalize_ascii components

let mangle_field_name (s : string) : string =
  let s = String.uncapitalize_ascii s in
  match s with
  | "from" -> "from_"
  | _ -> s

let of_twine_of_ty_name (s : string) : string =
  let s = mangle_ty_name s in
  (* TODO: use the trait with ::<> *)
  spf "%s_of_twine" s

let mangle_cstor_name_def (c : TR.Ty_def.cstor) : string =
  spf "%s" (String.capitalize_ascii c.c)

let mangle_cstor_name_use ~tyname (c : TR.Ty_def.cstor) : string =
  spf "%s::%s" (mangle_ty_name tyname) (String.capitalize_ascii c.c)

let rec gen_type_expr (ty : tyexpr) : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "V%s" s
  | Tuple l -> spf "(%s)" (String.concat "," @@ List.map gen_type_expr l)
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] -> "BigInt"
    | "string", [] -> "String"
    | "bool", [] -> "bool"
    | "array", [ x ] | "list", [ x ] -> spf "Vec<%s>" (gen_type_expr x)
    | "float", [] -> "f64"
    | "unit", [] -> "()"
    | "B.t", [] -> "usize" (* bllbll bitfield *)
    | "Imandrakit_error__Error_core.Data.t", [] ->
      "Ignored /* data */" (* just skip *)
    | "Imandrax_eval__Value.Custom_value.t", [] ->
      "Ignored /* custom value */" (* just skip *)
    | "Uid.Set.t", [] -> "HashSet<Uid>"
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> "f64"
    | "Error.result", [ x ] ->
      spf "core::result::Result<%s,Error>" (gen_type_expr x)
    | "Util_twine.Result.t", [ x; y ] ->
      spf "core::result::Result<%s, %s>" (gen_type_expr x) (gen_type_expr y)
    | "option", [ x ] -> spf "Option<%s>" (gen_type_expr x)
    | "Util_twine_.Q.t", [] -> "Vec<u8>" (* TODO *)
    | s, [] -> spf "%s" (mangle_ty_name s)
    | _ ->
      spf "%s<%s>" (mangle_ty_name s)
        (String.concat "," @@ List.map gen_type_expr args))

let rec of_twine_of_type_expr (ty : tyexpr) ~off : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "decode_%s(d=d,off=%s)" s off
  | Tuple l ->
    spf "(%s)" (String.concat "," @@ List.map (of_twine_of_type_expr ~off) l)
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] ->
      spf "d.get_int(off=%s)" off
    | "string", [] -> spf "d.get_str(off=%s)" off
    | "bool", [] -> spf "d.get_bool(off=%s)" off
    | "array", [ x ] | "list", [ x ] ->
      spf "[%s for x in d.get_array(off=%s)]"
        (of_twine_of_type_expr ~off:"x" x)
        off
    | "float", [] -> spf "d.get_float(off=%s)" off
    | "unit", [] -> spf "d.get_null(off=%s)" off
    | "B.t", [] -> spf "d.get_int(off=%s)" off (* bllbll bitfield *)
    | "Uid.Set.t", [] ->
      spf "set(%s for x in d.get_array(off=%s))"
        (of_twine_of_type_expr (Cstor ("Uid", [])) ~off:"x")
        off
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> spf "d.get_float(off=%s)" off
    | "Error.result", [ x ] ->
      spf
        "twine_result(d=d, off=%s, d0=lambda off: %s, d1=lambda off: \
         Error_Error_core_of_twine(d=d, off=off))"
        off
        (of_twine_of_type_expr x ~off:"off")
    | "Util_twine.result", [ x; y ] ->
      spf "twine_result(d=d, off=%s, d0=lambda off: %s, d1=lambda off: %s)" off
        (of_twine_of_type_expr x ~off:"off")
        (of_twine_of_type_expr y ~off:"off")
    | "option", [ x ] ->
      spf "twine.optional(d=d, off=%s, d0=lambda off: %s)" off
        (of_twine_of_type_expr ~off:"off" x)
    | "Util_twine_.Q.t", [] ->
      "string" (* TODO: add a decode_q function in prelude, use it *)
    | s, [] -> spf "%s(d=d, off=%s)" (of_twine_of_ty_name s) off
    | _ ->
      let args =
        String.concat ","
        @@ List.mapi
             (fun i ty ->
               spf "d%d=(lambda off: %s)" i
                 (of_twine_of_type_expr ~off:"off" ty))
             args
      in
      spf "%s(d=d,off=%s,%s)" (of_twine_of_ty_name s) off args)

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

let special_defs =
  [
    ( "Imandrax_api.Uid_set.t",
      {|pub type Uid_set = HashSet<Uid>;

// def Uid_set_of_twine(d, off:int) -> Uid_set:
//      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off))
      |}
    );
    ( "Imandrax_api.Chash.t",
      {|#[derive(Debug, Clone)]
pub struct Chash(pub Vec<u8>);

//fn Chash_of_twine(d, off: usize) -> Chash {
//    d.get_bytes(off)
//}
      |}
    );
  ]
  |> Str_map.of_list

let gen_clique ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n// clique %s\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let rsname = mangle_ty_name def.name in

    let rsparams, _rs_twine_params, _params_decls, _rs_twine_params_kw =
      match def.params with
      | [] -> "", "", [], ""
      | _ ->
        let params =
          spf "<%s>" (String.concat "," @@ List.map (spf "V%s") def.params)
        and twine_params =
          spf "%s,"
            (String.concat ","
            @@ List.mapi
                 (fun i v -> spf "d%d: Callable[...,_V%s]" i v)
                 def.params)
        and params_decls =
          List.mapi (fun i v -> spf "decode_%s = d%d" v i) def.params
        and twine_params_kw =
          spf "%s,"
            (String.concat ","
            @@ List.mapi (fun i _ -> spf "d%d=d%d" i i) def.params)
        in
        params, twine_params, params_decls, twine_params_kw
    in

    let declare_ty (def : tydef) =
      match def.decl with
      | Alias ty ->
        bpf buf "pub type %s%s = %s;\n\n" rsname rsparams (gen_type_expr ty)
        (* bpf buf "fn %s(d: twine.Decoder, %soff: int) -> %s {\n" *)
        (*   (of_twine_of_ty_name def.name) *)
        (*   rs_twine_params rsname; *)
        (* List.iter (fun s -> bpf buf "    %s\n" s) params_decls; *)
        (* bpf buf "    return %s;\n" (of_twine_of_type_expr ty ~off:"off"); *)
        (* bpf buf "}\n" *)
      | Record r ->
        bpf buf "#[derive(Debug, Clone)]\n";
        bpf buf "pub struct %s%s {\n" rsname rsparams;
        List.iter
          (fun (field, ty) ->
            bpf buf "  pub %s: %s,\n" (mangle_field_name field)
              (gen_type_expr ty))
          r.fields;
        bpf buf "}\n\n"
        (* bpf buf "fn %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s {\n" *)
        (*   rsname rsparams rs_twine_params rsname; *)
        (* List.iter (fun s -> bpf buf "    %s\n" s) params_decls; *)
        (* List.iter *)
        (*   (fun (field, ty) -> *)
        (*     bpf buf "    %s = %s\n" (mangle_field_name field) *)
        (*       (of_twine_of_type_expr ~off:"off" ty)) *)
        (*   r.fields; *)
        (* bpf buf "    return %s(%s)\n" rsname *)
        (*   (String.concat "," *)
        (*   @@ List.map *)
        (*        (fun (field, _) -> *)
        (*          spf "%s=%s" (mangle_field_name field) (mangle_field_name field)) *)
        (*        r.fields); *)
        (* bpf buf "}\n" *)
      | TR.Ty_def.Alg cstors ->
        (* declare type *)
        bpf buf "#[derive(Debug, Clone)]\n";
        bpf buf "pub enum %s%s {\n" rsname rsparams;
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_name = mangle_cstor_name_def c in
            match c.args, c.labels with
            | [], _ -> bpf buf "  %s,\n" c_name
            | [ x ], None -> bpf buf "  %s(%s),\n" c_name (gen_type_expr x)
            | _, None ->
              bpf buf "  %s(%s),\n" c_name
                (String.concat "," @@ List.map gen_type_expr c.args)
            | _, Some labels ->
              bpf buf "  %s {\n" c_name;
              List.iter2
                (fun lbl ty ->
                  bpf buf "    %s: %s,\n" (mangle_field_name lbl)
                    (gen_type_expr ty))
                labels c.args;
              bpf buf "  },\n")
          cstors;
        bpf buf "}\n"
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

let gen ~out (cliques : TR.Ty_def.clique list) : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter (fun cl -> if not (skip_clique cl) then gen_clique ~oc cl) cliques;

  ()
