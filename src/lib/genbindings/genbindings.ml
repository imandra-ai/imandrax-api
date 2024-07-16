open Common_
module J = Yojson.Safe

let dump = ref false
let debug = ref false

let qualified_name (def : TR.Ty_def.t) : string =
  let remove__ (s : string) =
    match CCString.Split.right ~by:"__" s with
    | None -> s
    | Some (_, x) -> x
  in
  let add_prefix p s =
    if p = "" then
      s
    else
      spf "%s.%s" p s
  in
  add_prefix (remove__ def.path) def.name

let rec subst_ty ~subst ty =
  match ty with
  | TR.Ty_expr.Cstor (name, l) ->
    let name = try Str_map.find name subst with Not_found -> name in
    TR.Ty_expr.Cstor (name, List.map (subst_ty ~subst) l)
  | _ -> TR.Ty_expr.map_shallow ~f:(subst_ty ~subst) ty

let qualify_types_in_clique (clique : TR.Ty_def.clique) : TR.Ty_def.clique =
  let subst =
    List.map (fun (def : TR.Ty_def.t) -> def.name, qualified_name def) clique
    |> Str_map.of_list
  in
  List.map
    (fun (def : TR.Ty_def.t) ->
      {
        (TR.Ty_def.map ~f:(subst_ty ~subst) def) with
        name = Str_map.find def.name subst;
      })
    clique

let parse_typereg () : TR.Ty_def.clique list =
  let cliques = ref [] in
  let l =
    let j = J.from_string Types_.json in
    J.Util.to_list j
  in
  List.iter
    (fun j ->
      match TR.Ty_def.clique_of_yojson j with
      | exception e ->
        failwith
        @@ spf "JSON error: %s\nin`%s`" (Printexc.to_string e) (J.to_string j)
      | Error msg ->
        failwith @@ spf "JSON parse error: %s\nin `%s`" msg (J.to_string j)
      | Ok cl -> cliques := qualify_types_in_clique cl :: !cliques)
    l;
  List.rev !cliques

let main ~out ~lang () : unit =
  let types = parse_typereg () in

  if !dump then
    List.iter
      (fun d -> Format.printf "@[<2>got clique@ %a@]@." TR.Ty_def.pp_clique d)
      types;

  match lang with
  | "python" -> Gen_python.gen ~out types
  | _ -> failwith @@ spf "unsupported target language: %S" lang

let () =
  let out = ref "" in
  let lang = ref "" in
  let opts =
    [
      "-d", Arg.Set debug, " debug";
      "-o", Arg.Set_string out, " output file";
      "--dump", Arg.Set dump, " dump type defs";
      "--lang", Arg.Set_string lang, " set target language";
    ]
    |> Arg.align
  in
  Arg.parse opts ignore "generate bindings in other languages";

  if !lang = "" then failwith "target language not specified";

  main ~out:!out ~lang:!lang ()
