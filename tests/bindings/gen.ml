(* Golden cases: OCaml values encoded as artifacts, decoded by the bindings' tests.

   Writes [<out dir>/<artifact kind>/<name>.pb] for every case: the artifact as
   the server sends it, a protobuf [Artifact] message with the twine-encoded
   data and the storage. *)

open Builders

let cases =
  List.concat
    [
      Cases_term.cases;
      Cases_decl.cases;
      Cases_model.cases;
      Cases_report.cases;
      Cases_po_res.cases;
      Cases_eval_res.cases;
      Cases_decomp.cases;
      Cases_task.cases;
    ]

let () =
  let out_dir = Sys.argv.(1) in
  List.iter
    (fun (Case { name; kind; data; storage }) ->
      let dir = Filename.concat out_dir (A.kind_to_string kind) in
      if not (Sys.file_exists dir) then Sys.mkdir dir 0o755;
      let msg =
        Imandrax_api_artifact.Proto.to_msg_str (A.make ~storage ~kind data)
      in
      Out_channel.with_open_bin
        (Filename.concat dir (name ^ ".pb"))
        (fun oc -> Out_channel.output_string oc msg))
    cases
