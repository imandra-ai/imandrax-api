open Common_

let process (cliques : TR.Ty_def.clique list) : _ list =
  Iter.of_list cliques
  |> Iter.map (fun defs ->
         CCList.map
           (fun (d : tydef) ->
             match d.decl with
             | Record { fields } ->
               let fields =
                 List.filter
                   (fun (_name, ty) ->
                     match ty with
                     | TR.Ty_expr.Attrs (_, attrs)
                       when List.mem_assoc "ocaml_only" attrs ->
                       false
                     | _ -> true)
                   fields
               in

               let unboxed = d.unboxed || List.length fields = 1 in
               { d with unboxed; decl = TR.Ty_def.Record { fields } }
             | _ -> d)
           defs)
  |> Iter.to_list
