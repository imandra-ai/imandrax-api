module C = Imandrax_api_client_ezcurl
module Fmt = CCFormat

let c : C.t = C.create ~auth_token:None ~url:"http://127.0.0.1:8082" ()
let () = Fmt.printf "status=%a@." C.API.pp_string_msg @@ C.status c
let session = C.get_session c
let x1 = C.eval_src c ~session ~src:"let f x =x+1;;" ()
let () = Fmt.printf "x1: %a@." C.API.pp_eval_res x1
let x2 = C.eval_src c ~session ~src:"theorem yolo1 x = f x > x;;" ()
let () = Fmt.printf "x2: %a@." C.API.pp_eval_res x2
let task2 = List.hd x2.tasks
let () = Fmt.printf "task2 = %a@." C.API.pp_task task2
let arts = C.list_artifacts c ~task:(Option.get task2.id) ()

let () =
  Fmt.printf "artifacts for task2: %a@." C.API.pp_artifact_list_result arts

let get_artifact_zip ~kind : C.API.artifact_zip =
  match C.get_artifact_zip c ~task:(Option.get task2.id) ~kind () with
  | C.API.Ok art -> art
  | C.API.Error err ->
    Fmt.printf "get_artifact_zip %S failed: %a@." kind C.API.pp_error err;
    exit 1

let art_show = get_artifact_zip ~kind:"show"
let () = Fmt.printf "art show size=%d@." (Bytes.length art_show.art_zip)
let art_po_task = get_artifact_zip ~kind:"po_task"
let () = Fmt.printf "art po_task size=%d@." (Bytes.length art_po_task.art_zip)

let () =
  CCIO.File.write_exn "art.po_task.zip"
    (Bytes.unsafe_to_string art_po_task.art_zip)

let art_po_res = get_artifact_zip ~kind:"po_res"
let () = Fmt.printf "art po_res size=%d@." (Bytes.length art_po_res.art_zip)

let () =
  CCIO.File.write_exn "art.po_res.zip"
    (Bytes.unsafe_to_string art_po_res.art_zip)
