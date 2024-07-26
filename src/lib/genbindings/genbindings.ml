open Common_

let main ~out ~lang () : unit =
  let types = Resolve_ty_defs.parse_typereg () in

  if !dump then
    List.iter
      (fun d -> Format.printf "@[<2>got clique@ %a@]@." TR.Ty_def.pp_clique d)
      types;

  match lang with
  | "python" -> Gen_python.gen ~out types
  | "rust" -> Gen_rust.gen ~out types
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
