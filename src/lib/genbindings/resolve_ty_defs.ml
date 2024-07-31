open Common_
module J = Yojson.Safe

let show_prefix path = spf "[%s]" (String.concat "," @@ List.map (spf "%S") path)

module Path = struct
  type t = string list * string

  let compare = Stdlib.compare
  let append (p : string list) (self : t) : t = p @ fst self, snd self

  let show (self : t) =
    let path, n = self in
    spf "{path=%s, name=%S}" (show_prefix path) n

  let to_string (self : t) =
    let path, n = self in
    if path = [] then
      n
    else
      spf "%s.%s" (String.concat "." path) n
end

module Path_map = Map.Make (Path)

(** Special names from dependencies *)
let names_to_exclude : Str_set.t =
  Str_set.of_list
    [
      "Z.t";
      "_Z.t";
      "string";
      "B.t";
      "Uid.Set.t";
      "Var_set.t";
      "int";
      "Void.t";
      "bool";
      "list";
      "float";
      "unit";
      "array";
      "Timestamp_s.t";
      "Duration_s.t";
      "Error.result";
      "Util_twine.Result.t";
      "Util_twine_.With_tag7.t";
      "Imandrakit_error__Error_core.Data.t";
      "Imandrax_api_eval__Value.Custom_value.t";
      "option";
      "Util_twine_.Z.t";
      "Util_twine_.Q.t";
    ]

let split_any_path (path : string) : string list =
  let path = CCString.replace ~sub:"." ~by:"__" path in
  CCString.Split.list_cpy ~by:"__" path

let split_full_path (path : string) : Path.t =
  match List.rev @@ split_any_path path with
  | [] -> [], path
  | p :: rest -> List.rev rest, p

let add_str_path_maybe ~path name : string =
  if path = "" then
    name
  else
    spf "%s.%s" path name

let is_excluded name : bool = Str_set.mem name names_to_exclude

let path_of_path_name ~path (name : string) : string list * Path.t =
  let qname = add_str_path_maybe ~path name in
  if is_excluded name then
    [], ([], name)
  else if is_excluded qname then
    [], ([], qname)
  else if path = "" then
    [], split_full_path name
  else
    split_any_path path, split_full_path name

let path_of_def (def : TR.Ty_def.t) : Path.t =
  assert (def.path <> "");
  let pre, path = path_of_path_name ~path:def.path def.name in
  Path.append pre path

type subst = { subst: string Path_map.t } [@@unboxed]

let find_subst ~path ~subst (name : string) : string =
  let prefix0, path0 = path_of_path_name ~path name in
  if !debug then
    Printf.eprintf "looking for %S in path=%S (prefix0=%s, path0=%s)\n" name
      path (show_prefix prefix0) (Path.show path0);
  let warn () =
    if is_excluded name || is_excluded (add_str_path_maybe ~path name) then
      ()
    else
      Printf.eprintf "Could not find name %S in path %S (path=%s) in substs\n%!"
        name path (Path.show path0)
  in

  let all_derived_path path : Path.t list =
    let rec loop = function
      | [] -> [ [] ]
      | x :: tl ->
        let l = loop tl in
        List.map (fun tl -> x :: tl) l @ l
    in
    loop (List.rev path)
    |> List.map (fun pre -> Path.append (List.rev pre) path0)
  in

  match
    CCList.find_map
      (fun path ->
        if !debug then Printf.eprintf "trying %s\n%!" (Path.show path);
        Path_map.find_opt path subst.subst)
      (all_derived_path prefix0)
  with
  | Some r -> r
  | None ->
    warn ();
    (* just return the name *)
    Path.to_string @@ Path.append prefix0 path0

let rec subst_ty ~path ~subst ty : TR.Ty_expr.t =
  let recurse ty = subst_ty ~path ~subst ty in
  match ty with
  | TR.Ty_expr.Cstor (name, l) ->
    let name = find_subst ~path ~subst name in
    TR.Ty_expr.Cstor (name, List.map recurse l)
  | _ -> TR.Ty_expr.map_shallow ~f:recurse ty

let subst_def ~(subst : subst) (def : TR.Ty_def.t) : TR.Ty_def.t =
  let path = def.path in
  {
    (TR.Ty_def.map ~f:(subst_ty ~path ~subst) def) with
    name = find_subst ~path ~subst def.name;
  }

let qualify_types_in_cliques (cliques : TR.Ty_def.clique list) :
    TR.Ty_def.clique list =
  let rename_clique (subst : subst) (cl : TR.Ty_def.clique) : subst =
    assert (cl <> []);
    List.fold_left
      (fun subst (def : TR.Ty_def.t) ->
        let full_path = path_of_def def in
        if !debug then
          Printf.eprintf "Adding %s --> %S to subst\n" (Path.show full_path)
            (Path.to_string full_path);
        {
          subst = Path_map.add full_path (Path.to_string full_path) subst.subst;
        })
      subst cl
  in
  let subst = List.fold_left rename_clique { subst = Path_map.empty } cliques in
  List.map (List.map (subst_def ~subst)) cliques

let parse_typereg () : TR.Ty_def.clique list =
  let cliques = ref [] in
  let l =
    let j = J.from_string Data_.types in
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
      | Ok cl -> cliques := cl :: !cliques)
    l;
  let cl = qualify_types_in_cliques @@ List.rev !cliques in
  cl
