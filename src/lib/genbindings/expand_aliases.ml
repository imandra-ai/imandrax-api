open Common_

type alias = {
  name: string;
  args: string list;
  body: tyexpr;
}

type aliases = alias Str_map.t

let rec expand_in_ty (aliases : aliases) (ty : tyexpr) =
  match ty with
  | Var _ -> ty
  | Tuple _ | Arrow _ -> TR.Ty_expr.map_shallow ty ~f:(expand_in_ty aliases)
  | Cstor (s, s_args) ->
    (match Str_map.find s aliases with
    | exception Not_found -> TR.Ty_expr.map_shallow ty ~f:(expand_in_ty aliases)
    | { name = _; args; body } ->
      assert (List.length args = List.length s_args);

      let subst =
        List.fold_left2
          (fun s arg s_arg -> Str_map.add arg s_arg s)
          Str_map.empty args s_args
      in
      Utils.subst_ty subst body |> expand_in_ty aliases)

let expand_aliases (cliques : TR.Ty_def.clique list) : _ list =
  let aliases = ref Str_map.empty in
  let cliques =
    Iter.of_list cliques
    |> Iter.filter_map (fun defs ->
           let defs =
             CCList.filter
               (fun (d : tydef) ->
                 match d.decl with
                 | Alias ty ->
                   aliases :=
                     Str_map.add d.name
                       { name = d.name; args = d.params; body = ty }
                       !aliases;
                   false
                 | _ -> true)
               defs
           in
           if defs = [] then
             None
           else
             Some defs)
    |> Iter.to_list
  in

  List.map
    (List.map (fun (d : tydef) ->
         { d with decl = TR.Ty_def.map_decl ~f:(expand_in_ty !aliases) d.decl }))
    cliques
