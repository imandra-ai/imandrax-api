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

               (*
                At the time of writing, there are three types that are not marked as unboxed while they have only one field:
                  - Imandrax_api_common.Db_ser.t_poly (only `ops`)
                  - Imandrax_api_mir.Type.t (two fields, but `generation` is @ocaml_only)
                  - Imandrax_api_eval.Value.erased_closure (only `missing`)
                Of those, we only want to treat Imandrax_api_mir.Type.t as unboxed, the others are generated boxed.
              *)
               let unboxed =
                 d.unboxed || String.equal d.name "Imandrax_api_mir.Type.t"
               in
               { d with unboxed; decl = TR.Ty_def.Record { fields } }
             | _ -> d)
           defs)
  |> Iter.to_list
