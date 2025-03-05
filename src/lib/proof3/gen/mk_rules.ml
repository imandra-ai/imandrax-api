module P = Parse_spec
module Str_map = CCMap.Make (String)

let spf = Printf.sprintf
let pf = Printf.printf

let prelude =
  {|
(** Proof rules.

    Proof rules in use in ImandraX. *)

(* auto-generated in [gen/mk_rules.ml], do not modify *)

type 'a offset_for = 'a Imandrakit_twine.offset_for [@@deriving eq, show, twine, typereg]
|}

let main () =
  pf "%s" prelude;
  pf "\n";

  let spec = Parse_spec.spec in

  let map_types =
    [
      spec.wire_types
      |> CCList.filter_map (fun (ty : P.wire_type) ->
             ty.ml |> Option.map (fun ml -> ty.name, ml));
      spec.types |> List.map (fun (ty : P.type_) -> ty.name, ty.ml);
      spec.defined_types
      |> List.map (fun (ty : P.defined_type) ->
             ty.name, spf "%s offset_for" ty.ml_name);
    ]
    |> List.flatten |> Str_map.of_list
  in

  let caml_name_of_name s =
    match Str_map.find_opt s map_types with
    | Some ty -> ty
    | None ->
      CCString.map
        (function
          | '-' -> '_'
          | c -> c)
        s
      |> String.uncapitalize_ascii
  in

  let rec str_of_mt (ty : P.meta_type) : string =
    match ty with
    | M_ty s -> caml_name_of_name s
    | M_list l -> spf "%s list" (str_of_mt l)
    | M_option o -> spf "%s option" (str_of_mt o)
    | M_tuple l -> spf "(%s)" @@ String.concat " * " @@ List.map str_of_mt l
  in

  (* pf "(* map: {%s} *)\n"
    (Str_map.to_list map_types
    |> List.map (fun (name, ty) -> spf "%S=%s" name ty)
    |> String.concat ",\n");*)

  (* the types to define *)
  let types =
    List.map
      (fun (ty : P.defined_type) ->
        ( ty,
          List.filter (fun (c : P.cstor) -> c.ret = P.M_ty ty.name) spec.cstors
        ))
      spec.defined_types
  in

  List.iteri
    (fun i ((ty, cstors) : P.defined_type * P.cstor list) ->
      pf "\n(** %s *)\n" ty.doc;
      if i > 0 then
        pf "and "
      else
        pf "type ";
      pf "%s =\n" ty.ml_name;
      List.iter
        (fun (c : P.cstor) ->
          pf "  | %s" (String.capitalize_ascii @@ caml_name_of_name c.name);
          (match c.args with
          | [] -> ()
          | [ ty ] -> pf " of %s" (str_of_mt ty)
          | tys -> pf " of %s" (String.concat " * " @@ List.map str_of_mt tys));
          pf "\n")
        cstors)
    types;
  pf "[@@deriving eq, twine, show, typereg]\n";
  ()

let () = main ()
