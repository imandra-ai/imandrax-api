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
  | Tuple _ | Arrow _ | Attrs _ ->
    TR.Ty_expr.map_shallow ty ~f:(expand_in_ty aliases)
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

let expand_aliases (cliques : Ty_set.t list) : _ list =
  let aliases = ref Str_map.empty in
  let sets =
    Iter.of_list cliques
    |> Iter.filter_map (fun (defs : Ty_set.t) ->
           let clique =
             CCList.filter
               (fun (d : TR.Ty_def.t) ->
                 match d.decl with
                 | Alias ty ->
                   aliases :=
                     Str_map.add d.name
                       { name = d.name; args = d.params; body = ty }
                       !aliases;
                   false
                 | _ -> true)
               defs.clique
           in
           if defs.clique = [] then
             None
           else
             Some { defs with clique })
    |> Iter.to_list
  in

  List.map
    (fun (set : Ty_set.t) ->
      {
        set with
        Ty_set.clique =
          List.map
            (fun (d : TR.Ty_def.t) ->
              {
                d with
                decl = TR.Ty_def.map_decl ~f:(expand_in_ty !aliases) d.decl;
              })
            set.clique;
      })
    sets
