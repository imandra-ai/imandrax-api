open Common_

let fpf = Printf.fprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let prelude =
  {|
# automatically generated using genbindings.ml, do not edit

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

let rec gen_type_expr (ty : tyexpr) : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> s
  | Tuple l -> spf "(%s)" (String.concat "," @@ List.map gen_type_expr l)
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] -> "int"
    | "string", [] -> "str"
    | "bool", [] -> "bool"
    | "array", [ x ] | "list", [ x ] -> spf "list[%s]" (gen_type_expr x)
    | "float", [] -> "float"
    | "unit", [] -> "None"
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

let gen_clique ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n# clique %s\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let pyname = mangle_ty_name def.name in
    fpf oc "# def %s (mangled name: %S)\n" def.name pyname
  in

  List.iter gen_def clique;
  ()

let gen ~out (cliques : TR.Ty_def.clique list) : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "%s\n" prelude;
  List.iter (fun cl -> if not (skip_clique cl) then gen_clique ~oc cl) cliques;

  ()
