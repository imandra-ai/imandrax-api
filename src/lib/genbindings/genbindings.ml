open Common_

let main ~out ~lang () : unit =
  let types = Resolve_ty_defs.parse_typereg () in
  let artifacts = Resolve_artifacts.get_arts () in

  if !dump then (
    List.iter
      (fun (d : Ty_set.t) ->
        Format.printf "@[<2>got clique@ %a@]@." TR.Ty_def.pp_clique d.clique)
      types;
    List.iter
      (fun (a : Artifact.t) ->
        Format.printf "got artifact %s@." (Artifact.show a))
      artifacts
  );

  match lang with
  | "python" -> Gen_python.gen ~out ~artifacts ~types ()
  | "rust" -> Gen_rust.gen ~out ~artifacts ~types ()
  | "ts" -> Gen_ts.gen ~out ~artifacts ~types ()
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
