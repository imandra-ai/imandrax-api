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
    |? s
  in
  let s = CCString.chop_suffix ~suf:".t" s |? s in
  String.capitalize_ascii s |> CCString.replace ~sub:"." ~by:"_"

let mangle_field_name (s : string) : string = String.uncapitalize_ascii s

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
    | "option", [ x ] -> spf "None | %s" (gen_type_expr x)
    | "Util_twine_.Q.t", [] -> "string" (* TODO *)
    | s, [] -> mangle_ty_name s
    | _ ->
      spf "%s[%s]" (mangle_ty_name s)
        (String.concat "," @@ List.map gen_type_expr args))

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

let special_defs =
  [
    "Imandrax_api.Uid_set.t", "type Uid_set = set[Uid]";
    "Imandrax_api.Chash.t", "type Chash = bytes";
  ]
  |> Str_map.of_list

let gen_clique ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n# clique %s\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let pyname = mangle_ty_name def.name in
    bpf buf "# def %s (mangled name: %S)\n" def.name pyname;

    let pyparams =
      match def.params with
      | [] -> ""
      | _ -> spf "[%s]" (String.concat "," @@ List.map (spf "V%s") def.params)
    in

    (match Str_map.find_opt def.name special_defs with
    | Some d ->
      (* special case *)
      bpf buf "%s\n" d
    | None ->
      (match def.decl with
      | Alias ty ->
        bpf buf "type %s%s = %s\n" pyname pyparams (gen_type_expr ty)
      | Record r ->
        bpf buf "@dataclass(slots=True)\n";
        bpf buf "class %s%s:\n" pyname pyparams;
        List.iter
          (fun (field, ty) ->
            bpf buf "    %s: %s\n" (mangle_field_name field) (gen_type_expr ty))
          r.fields
      | TR.Ty_def.Alg cstors ->
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_pyname = mangle_cstor_name ~tyname:def.name c in
            bpf buf "@dataclass(slots=True)\n";
            bpf buf "class %s%s:\n" c_pyname pyparams;

            (match c.args, c.labels with
            | [], _ -> bpf buf "    pass\n"
            | [ x ], None -> bpf buf "    arg: %s\n" (gen_type_expr x)
            | _, None ->
              bpf buf "    args: tuple[%s]\n"
                (String.concat "," @@ List.map gen_type_expr c.args)
            | _, Some labels ->
              List.iter2
                (fun lbl ty ->
                  bpf buf "    %s: %s\n" (mangle_field_name lbl)
                    (gen_type_expr ty))
                labels c.args);
            bpf buf "\n")
          cstors;

        bpf buf "type %s%s = " pyname pyparams;
        List.iteri
          (fun i (c : TR.Ty_def.cstor) ->
            if i > 0 then bpf buf "| ";
            let c_name = mangle_cstor_name ~tyname:def.name c in
            bpf buf "%s%s" c_name pyparams)
          cstors;
        bpf buf "\n"));

    Buffer.output_buffer oc buf
  in

  List.iter gen_def clique;
  ()

let gen ~out (cliques : TR.Ty_def.clique list) : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter (fun cl -> if not (skip_clique cl) then gen_clique ~oc cl) cliques;

  ()
