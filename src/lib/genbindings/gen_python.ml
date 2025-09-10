open Common_

(* FIXME: for ca store key: we need to read a tag 7 around the actual value *)

let bpf = Printf.bprintf
let fpf = Printf.fprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let prelude =
  {|
# automatically generated using genbindings.ml, do not edit

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from dataclasses import dataclass
from zipfile import ZipFile
import json
from typing import Callable
from . import twine

__all__ = ['twine']

type Error = Error_Error_core
def twine_result[T,E](d: twine.Decoder, off: int, d0: Callable[...,T], d1: Callable[...,E]) -> T | E:
    match d.get_cstor(off=off):
        case twine.Constructor(idx=0, args=args):
            args = tuple(args)
            return d0(d=d, off=args[0])
        case twine.Constructor(idx=1, args=args):
            args = tuple(args)
            return d1(d=d, off=args[0])
        case _:
            raise twine.Error('expected result')

type WithTag6[T] = T
type WithTag7[T] = T

def decode_with_tag[T](tag: int, d: twine.Decoder, off: int, d0: Callable[...,T]) -> WithTag7[T]:
    dec_tag = d.get_tag(off=off)
    if dec_tag.tag != tag:
        raise ValueError(f'Expected tag {tag}, got tag {dec_tag.tag} at off=0x{off:x}')
    return d0(d=d, off=dec_tag.arg)

def decode_q(d: twine.Decoder, off:int) -> tuple[int,int]:
    num, denum = d.get_array(off=off)
    num = d.get_int(off=num)
    denum = d.get_int(off=denum)
    return num, denum
  |}

let footer =
  {|

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
  | Var s -> spf "%S" @@ spf "_V%s" s
  | Tuple l -> spf "tuple[%s]" (String.concat "," @@ List.map gen_type_expr l)
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    "bytes"
  | Attrs (ty, _attrs) ->
    if List.mem_assoc "ocaml_only" _attrs then
      Printf.eprintf "warning: remaining `ocaml_only` attr\n%!";
    gen_type_expr ty
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine.Z.t" | "Z.t" | "_Z.t"), [] -> "int"
    | "string", [] -> "str"
    | "bool", [] -> "bool"
    | "array", [ x ] | "list", [ x ] -> spf "list[%s]" (gen_type_expr x)
    | "float", [] -> "float"
    | "unit", [] -> "None"
    | "B.t", [] -> "int" (* bllbll bitfield *)
    | "Uid.Set.t", [] -> "set[Uid]"
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> "float"
    | "Error.result", [ x ] -> spf "Error | %s" (gen_type_expr x)
    | "Util_twine.Result.t", [ x; y ] ->
      spf "%s | %s" (gen_type_expr x) (gen_type_expr y)
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "None"
    | "option", [ x ] -> spf "None | %s" (gen_type_expr x)
    | "Util_twine.With_tag7.t", [ x ] -> spf "WithTag7[%s]" (gen_type_expr x)
    | "Util_twine.With_tag6.t", [ x ] -> spf "WithTag6[%s]" (gen_type_expr x)
    | "Util_twine.Q.t", [] -> "tuple[int, int]"
    | s, [] -> mangle_ty_name s
    | _ ->
      spf "%s[%s]" (mangle_ty_name s)
        (String.concat "," @@ List.map gen_type_expr args))

let rec of_twine_of_type_expr (ty : tyexpr) ~off : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "decode_%s(d=d,off=%s)" s off
  | Tuple l ->
    spf "(lambda tup: (%s))(tuple(d.get_array(off=%s)))"
      (String.concat ","
      @@ List.mapi
           (fun i ty -> of_twine_of_type_expr ~off:(spf "tup[%d]" i) ty)
           l)
      off
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    spf "d.get_bytes(off=%s)" off
  | Attrs (ty, _) -> of_twine_of_type_expr ty ~off
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine.Z.t" | "Z.t" | "_Z.t"), [] ->
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
        "twine_result(d=d, off=%s, d0=lambda d, off: %s, d1=lambda d, off: \
         Error_Error_core_of_twine(d=d, off=off))"
        off
        (of_twine_of_type_expr x ~off:"off")
    | "Util_twine.Result.t", [ x; y ] ->
      spf
        "twine_result(d=d, off=%s, d0=lambda d, off: %s, d1=lambda d, off: %s)"
        off
        (of_twine_of_type_expr x ~off:"off")
        (of_twine_of_type_expr y ~off:"off")
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "None"
    | "Util_twine.With_tag6.t", [ x ] ->
      spf "decode_with_tag(tag=6, d=d, off=%s, d0=lambda d, off: %s)" off
        (of_twine_of_type_expr x ~off:"off")
    | "Util_twine.With_tag7.t", [ x ] ->
      spf "decode_with_tag(tag=7, d=d, off=%s, d0=lambda d, off: %s)" off
        (of_twine_of_type_expr x ~off:"off")
    | "option", [ x ] ->
      spf "twine.optional(d=d, off=%s, d0=lambda d, off: %s)" off
        (of_twine_of_type_expr ~off:"off" x)
    | "Util_twine.Q.t", [] -> spf "decode_q(d=d,off=%s)" off
    | s, [] -> spf "%s(d=d, off=%s)" (of_twine_of_ty_name s) off
    | _ ->
      let args =
        String.concat ","
        @@ List.mapi
             (fun i ty ->
               spf "d%d=(lambda d, off: %s)" i
                 (of_twine_of_type_expr ~off:"off" ty))
             args
      in
      spf "%s(d=d,off=%s,%s)" (of_twine_of_ty_name s) off args)

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

(* TODO: ca store key (decode with tag) *)
let special_defs =
  [
    ( "Imandrax_api.Uid_set.t",
      {|type Uid_set = set[Uid]

def Uid_set_of_twine(d, off:int) -> Uid_set:
      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off))|}
    );
    ( "Imandrax_api.Chash.t",
      {|type Chash = bytes

def Chash_of_twine(d, off:int) -> Chash:
    return d.get_bytes(off=off)|}
    );
  ]
  |> Str_map.of_list

let gen_clique ~oc (tys : Ty_set.t) : unit =
  fpf oc "\n# clique %s (cached: %b)\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) tys.clique)
    tys.cached;

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let pyname = mangle_ty_name def.name in
    bpf buf "# def %s (mangled name: %S)\n" def.name pyname;

    let pyparams, pytwine_params, params_decls, pytwine_params_kw =
      match def.params with
      | [] -> "", "", [], ""
      | _ ->
        let params =
          spf "[%s]" (String.concat "," @@ List.map (spf "_V%s") def.params)
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

    let cached_decorator =
      if tys.cached then
        spf "@twine.cached(name=%S)\n" def.name
      else
        ""
    in

    let declare_ty (def : tydef) =
      match def.decl with
      | Alias ty ->
        bpf buf "type %s%s = %s\n\n" pyname pyparams (gen_type_expr ty);
        bpf buf "%sdef %s(d: twine.Decoder, %soff: int) -> %s:\n"
          cached_decorator
          (of_twine_of_ty_name def.name)
          pytwine_params pyname;
        List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
        bpf buf "    return %s\n" (of_twine_of_type_expr ty ~off:"off")
      | Record r ->
        bpf buf "@dataclass(slots=True, frozen=True)\n";
        bpf buf "class %s%s:\n" pyname pyparams;
        List.iter
          (fun (field, ty) ->
            bpf buf "    %s: %s\n" (mangle_field_name field) (gen_type_expr ty))
          r.fields;
        bpf buf "\n";

        bpf buf "%sdef %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s:\n"
          cached_decorator pyname pyparams pytwine_params pyname;
        if def.unboxed then (
          let field_name, field_ty =
            match r.fields with
            | [ hd ] -> hd
            | _ -> assert false
          in
          bpf buf "    x = %s # single unboxed field\n"
            (of_twine_of_type_expr ~off:"off" field_ty);
          bpf buf "    return %s(%s=x)\n" pyname (mangle_field_name field_name)
        ) else (
          List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
          bpf buf "    fields = list(d.get_array(off=off))\n";
          List.iteri
            (fun i (field, ty) ->
              bpf buf "    %s = %s\n" (mangle_field_name field)
                (of_twine_of_type_expr ~off:(spf "fields[%d]" i) ty))
            r.fields;
          bpf buf "    return %s(%s)\n" pyname
            (String.concat ","
            @@ List.map
                 (fun (field, _) ->
                   spf "%s=%s" (mangle_field_name field)
                     (mangle_field_name field))
                 r.fields)
        )
      | TR.Ty_def.Alg cstors ->
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_pyname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "@dataclass(slots=True, frozen=True)\n";
            bpf buf "class %s%s:\n" c_pyname pyparams;

            (match c.args, c.labels with
            | [], _ -> bpf buf "    pass\n"
            | [ x ], None ->
              bpf buf "    arg: %s\n\n" (gen_type_expr x);
              bpf buf
                "%sdef %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, \
                 ...]) -> %s%s:\n"
                cached_decorator c_pyname pyparams pytwine_params c_pyname
                pyparams;
              List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
              bpf buf "    arg = %s\n" (of_twine_of_type_expr ~off:"args[0]" x);
              bpf buf "    return %s(arg=arg)\n" c_pyname
            | _, None ->
              bpf buf "    args: tuple[%s]\n\n"
                (String.concat "," @@ List.map gen_type_expr c.args);
              bpf buf
                "%sdef %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, \
                 ...]) -> %s%s:\n"
                cached_decorator c_pyname pyparams pytwine_params c_pyname
                pyparams;
              List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
              bpf buf "    cargs = (%s)\n"
                (String.concat ","
                @@ List.mapi
                     (fun i ty ->
                       of_twine_of_type_expr ~off:(spf "args[%d]" i) ty)
                     c.args);
              bpf buf "    return %s(args=cargs)\n" c_pyname
            | _, Some labels ->
              List.iter2
                (fun lbl ty ->
                  bpf buf "    %s: %s\n" (mangle_field_name lbl)
                    (gen_type_expr ty))
                labels c.args;
              bpf buf "\n\n";
              bpf buf
                "%sdef %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, \
                 ...]) -> %s%s:\n"
                cached_decorator c_pyname pyparams pytwine_params c_pyname
                pyparams;
              List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
              CCList.iteri2
                (fun i lbl ty ->
                  bpf buf "    %s = %s\n" (mangle_field_name lbl)
                    (of_twine_of_type_expr ty ~off:(spf "args[%d]" i)))
                labels c.args;
              bpf buf "    return %s(%s)\n" c_pyname
                (String.concat ","
                @@ List.map
                     (fun lbl ->
                       spf "%s=%s" (mangle_field_name lbl)
                         (mangle_field_name lbl))
                     labels);
              bpf buf "\n");
            bpf buf "\n")
          cstors;

        bpf buf "type %s%s = " pyname pyparams;
        List.iteri
          (fun i (c : TR.Ty_def.cstor) ->
            if i > 0 then bpf buf "| ";
            let c_name = mangle_cstor_name ~tyname:def.name c in
            bpf buf "%s%s" c_name pyparams)
          cstors;
        bpf buf "\n\n";

        bpf buf "%sdef %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s:\n"
          cached_decorator pyname pyparams pytwine_params pyname;
        bpf buf "    match d.get_cstor(off=off):\n";
        List.iteri
          (fun i (c : TR.Ty_def.cstor) ->
            let c_pyname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "         case twine.Constructor(idx=%d, args=args):\n" i;
            (match c.args with
            | [] -> bpf buf "             return %s%s()\n" c_pyname pyparams
            | _ ->
              bpf buf "             args = tuple(args)\n";
              bpf buf "             return %s_of_twine(d=d, args=args, %s)\n"
                c_pyname pytwine_params_kw);
            ())
          cstors;

        bpf buf "         case twine.Constructor(idx=idx):\n";
        bpf buf
          "             raise twine.Error(f'expected %s, got invalid \
           constructor {idx}')\n"
          pyname
    in

    (match Str_map.find_opt def.name special_defs with
    | Some d ->
      (* special case *)
      bpf buf "%s\n" d
    | None -> declare_ty def);
    Buffer.output_buffer oc buf
  in

  List.iter gen_def tys.clique;
  ()

let gen_artifacts (artifacts : Artifact.t list) : string =
  let buf = Buffer.create 32 in

  (* union of the types! *)
  bpf buf "\n\n# Artifacts\n\n";

  bpf buf "type Artifact = %s\n\n"
  @@ String.concat "|"
  @@ List.map (fun (a : Artifact.t) -> gen_type_expr a.ty) artifacts;

  bpf buf "artifact_decoders = {\\\n";
  List.iter
    (fun (a : Artifact.t) ->
      bpf buf "  '%s': (lambda d, off: %s),\n" a.tag
        (of_twine_of_type_expr ~off:"off" a.ty))
    artifacts;
  bpf buf "}\n\n";

  bpf buf "%s\n" footer;

  Buffer.contents buf

let gen ~out ~(artifacts : Artifact.t list) ~types:(cliques : Ty_set.t list) ()
    : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter
    (fun (set : Ty_set.t) ->
      if not (skip_clique set.clique) then gen_clique ~oc set)
    cliques;
  fpf oc "%s\n" (gen_artifacts artifacts);

  ()
