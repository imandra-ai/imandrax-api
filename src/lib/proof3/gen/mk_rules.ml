module P = Parse_spec
module Str_map = CCMap.Make (String)

let spf = Printf.sprintf
let pf = Printf.printf

let prelude =
  {|
(** Proof rules.

    Proof rules in use in ImandraX. *)

(* auto-generated in [gen/mk_rules.ml], do not modify *)

[@@@ocaml.warning "-27-39"]

type 'a offset_for = 'a Imandrakit_twine.offset_for [@@deriving eq, twine, typereg]
let pp_offset_for _ out (Offset_for x:_ offset_for) = Fmt.fprintf out "ref(0x%x)" x
|}

let bracketify doc =
  let opening = ref true in
  String.map
    (function
      | '`' when !opening ->
        opening := false;
        '['
      | '`' when not !opening ->
        opening := true;
        ']'
      | c -> c)
    doc

let gen_ml () =
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
             let rhs =
               if ty.direct then
                 ty.ml_name
               else
                 spf "%s offset_for" ty.ml_name
             in
             ty.name, rhs);
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
          | [ (f, ty) ] -> pf " of {\n      %s: %s\n    }" f (str_of_mt ty)
          | tys ->
            pf " of {\n%s\n    }"
              (String.concat ";\n"
              @@ List.map
                   (fun (s, ty) -> spf "      %s: %s" s @@ str_of_mt ty)
                   tys));
          pf "\n";
          pf "    (** %s *)\n" (bracketify c.doc);
          ())
        cstors)
    types;
  pf "[@@deriving eq, twine, show {with_path=false}, typereg]\n";

  (* generate [iter] functions *)
  let iter_args, mutual_types =
    List.map
      (fun ((ty, _) : P.defined_type * _) ->
        spf "yield_%s" (String.lowercase_ascii ty.name), ty.name)
      types
    |> List.split
  in

  let rec iter_ty ty expr : string list =
    match ty with
    | P.M_ty ty when List.mem ty mutual_types ->
      [ spf "yield_%s %s" (String.lowercase_ascii ty) expr ]
    | P.M_ty _ -> []
    | P.M_tuple l ->
      (match
         List.mapi (fun i ty -> iter_ty ty (spf "x%d" i)) l |> List.flatten
       with
      | [] -> []
      | seq ->
        [
          spf "(match %s with %s -> %s)" expr
            (List.mapi (fun i _ -> spf "x%d" i) l |> String.concat ",")
            (String.concat "; " seq);
        ])
    | P.M_option ty ->
      (match iter_ty ty "x" with
      | [] -> []
      | seq ->
        [ spf "Option.iter (fun x -> %s) %s" (String.concat "; " seq) expr ])
    | P.M_list ty ->
      (match iter_ty ty "x" with
      | [] -> []
      | seq ->
        [ spf "List.iter (fun x -> %s) %s" (String.concat "; " seq) expr ])
  in

  List.iteri
    (fun i ((ty, cstors) : P.defined_type * P.cstor list) ->
      pf "\n(** iterate on %s *)\n" ty.name;
      if i > 0 then
        pf "and "
      else
        pf "let rec ";
      pf "iter_%s %s x = match x with\n" ty.ml_name
        (iter_args |> List.map (spf "~%s") |> String.concat " ");
      List.iter
        (fun (c : P.cstor) ->
          pf "  | %s" (String.capitalize_ascii @@ caml_name_of_name c.name);
          (match c.args with
          | [] -> pf " -> ()"
          | [ (name, ty) ] ->
            pf " x ->%s"
              (match iter_ty ty (spf "x.%s" name) with
              | [] -> "()"
              | seq -> String.concat "; " seq)
          | tys ->
            pf " x -> %s"
              (match
                 List.flatten
                   (List.map
                      (fun (name, ty) -> iter_ty ty (spf "x.%s" name))
                      tys)
               with
              | [] -> "()"
              | seq -> String.concat "; " seq));
          pf "\n")
        cstors)
    types;
  pf "[@@deriving eq, twine, show {with_path=false}, typereg]\n";

  ()

let gen_doc () = Codegen_md.gen ()

let () =
  let doc = ref false in
  Arg.parse [ "--doc", Arg.Set doc, " produce doc" ] ignore "";
  if !doc then
    gen_doc ()
  else
    gen_ml ()
