module E = Imandrax_errors

let pf = Printf.printf

let emit_value () =
  List.iter
    (fun { E.name; descr } ->
      pf "\n(** %s *)\n" descr;
      pf
        "let %s: Imandrakit.Error_kind.t = Imandrakit.Error_kind.make ~name:%S \
         ()\n"
        (String.uncapitalize_ascii name)
        (String.capitalize_ascii name))
    E.all;
  ()

let () =
  pf "(* this file is auto-generated *)\n\n";
  emit_value ();
  pf "\n";

  ()
