open Common_

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
from typing import Callable
from . import twine


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

  |}

(* TODO: B.t for the bitfield *)

(* TODO:
   - keep map of names to python names (replace . with _, capitalize, etc.)
   - map cliques
   - assume twine exists (!)
   - implement small twine library


   @dataclass(frozen=True, slots=True)
*)

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

let mangle_cstor_name ~tyname (c : TR.Ty_def.cstor) : string =
  spf "%s_%s" (mangle_ty_name tyname) (String.capitalize_ascii c.c)

let rec gen_type_expr (ty : tyexpr) : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "%S" @@ spf "V%s" s
  | Tuple l -> spf "tuple[%s]" (String.concat "," @@ List.map gen_type_expr l)
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] -> "int"
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
    | "option", [ x ] -> spf "None | %s" (gen_type_expr x)
    | "Util_twine_.Q.t", [] -> "bytes" (* TODO *)
    | s, [] -> mangle_ty_name s
    | _ ->
      spf "%s[%s]" (mangle_ty_name s)
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
    | "Util_twine_.Q.t", [] -> "string" (* TODO *)
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

let gen_clique ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n# clique %s\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let pyname = mangle_ty_name def.name in
    bpf buf "# def %s (mangled name: %S)\n" def.name pyname;

    let pyparams, pytwine_params, params_decls, pytwine_params_kw =
      match def.params with
      | [] -> "", "", [], ""
      | _ ->
        let params =
          spf "[%s]" (String.concat "," @@ List.map (spf "V%s") def.params)
        and twine_params =
          spf "%s,"
            (String.concat ","
            @@ List.mapi
                 (fun i v -> spf "d%d: Callable[...,V%s]" i v)
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
        bpf buf "type %s%s = %s\n\n" pyname pyparams (gen_type_expr ty);
        bpf buf "def %s(d: twine.Decoder, %soff: int) -> %s:\n"
          (of_twine_of_ty_name def.name)
          pytwine_params_kw pyname;
        List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
        bpf buf "    return %s\n" (of_twine_of_type_expr ty ~off:"off")
      | Record r ->
        bpf buf "@dataclass(slots=True)\n";
        bpf buf "class %s%s:\n" pyname pyparams;
        List.iter
          (fun (field, ty) ->
            bpf buf "    %s: %s\n" (mangle_field_name field) (gen_type_expr ty))
          r.fields;
        bpf buf "\n";

        bpf buf "def %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s:\n"
          pyname pyparams pytwine_params_kw pyname;
        List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
        List.iter
          (fun (field, ty) ->
            bpf buf "    %s = %s\n" (mangle_field_name field)
              (of_twine_of_type_expr ~off:"off" ty))
          r.fields;
        bpf buf "    return %s(%s)\n" pyname
          (String.concat ","
          @@ List.map
               (fun (field, _) ->
                 spf "%s=%s" (mangle_field_name field) (mangle_field_name field))
               r.fields)
      | TR.Ty_def.Alg cstors ->
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_pyname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "@dataclass(slots=True)\n";
            bpf buf "class %s%s:\n" c_pyname pyparams;

            (match c.args, c.labels with
            | [], _ -> bpf buf "    pass\n"
            | [ x ], None ->
              bpf buf "    arg: %s\n\n" (gen_type_expr x);
              bpf buf
                "def %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, ...]) \
                 -> %s%s:\n"
                c_pyname pyparams pytwine_params c_pyname pyparams;
              List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
              bpf buf "    arg = %s\n" (of_twine_of_type_expr ~off:"args[0]" x);
              bpf buf "    return %s(arg=arg)\n" c_pyname
            | _, None ->
              bpf buf "    args: tuple[%s]\n\n"
                (String.concat "," @@ List.map gen_type_expr c.args);
              bpf buf
                "def %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, ...]) \
                 -> %s%s:\n"
                c_pyname pyparams pytwine_params c_pyname pyparams;
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
                "def %s_of_twine%s(d: twine.Decoder, %sargs: tuple[int, ...]) \
                 -> %s%s:\n"
                c_pyname pyparams pytwine_params c_pyname pyparams;
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

        bpf buf "def %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s:\n"
          pyname pyparams pytwine_params pyname;
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

  List.iter gen_def clique;
  ()

let gen ~out (cliques : TR.Ty_def.clique list) : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter (fun cl -> if not (skip_clique cl) then gen_clique ~oc cl) cliques;

  ()
