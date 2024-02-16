open Common_

type t = Cli_opts_.repl [@@deriving show]

(** Parser for top phrases from stdin *)
module Reader : sig
  type t

  val create : linenoise:bool -> init_prompt:(unit -> string) -> unit -> t
  val read : t -> string option
end = struct
  type t = {
    buf: Buffer.t;
    init_prompt: unit -> string;
    linenoise: bool;
  }

  let create ~linenoise ~init_prompt () : t =
    if linenoise then (
      LNoise.set_multiline true;
      LNoise.catch_break true
    ) else
      Sys.catch_break true;
    { init_prompt; buf = Buffer.create 2048; linenoise }

  let prompt_cont = "  "

  let prompt_ (self : t) =
    if Buffer.length self.buf = 0 then
      self.init_prompt ()
    else
      prompt_cont

  let read_line (self : t) : string option =
    let prompt = prompt_ self in
    if self.linenoise then
      LNoise.linenoise prompt
    else (
      Printf.printf "%s%!" prompt;
      try Some (input_line stdin) with End_of_file -> None
    )

  let read (self : t) : string option =
    let rec loop () =
      match read_line self with
      | None -> None
      | Some line ->
        Buffer.add_string self.buf line;
        if CCString.mem ~sub:";;" line then (
          (* done reading lines *)
          let content = Buffer.contents self.buf in
          Buffer.reset self.buf;
          Some content
        ) else
          loop ()
    in
    loop ()
end

(*
  let proc_phrase ~loc_ctx p : unit =
    let decl_cells, res = Imandrax_ocaml_repl.add_top_phrase ~loc_ctx repl p in
    let fdecls = Iter.of_list decl_cells |> Iter.flat_map_l Decls_cell.decls in

    Iter.iter
      (fun (d : Stateful_decl.t) ->
        if self.dump_decls then
          Fmt.printf "%a" (Dump_typing.dump_decl ~color:self.color) d.decl
        else
          Fmt.printf "%a" (Dump_typing.dump_decl_type ~color:self.color) d.decl)
      fdecls;

    (* print results of evaluation *)
    Iter.iter
      (fun (d : Stateful_decl.t) ->
        match d.as_cir with
        | Ok { eval_tasks; _ } ->
          List.iter
            (fun (_, t) ->
              match Rvar.get t with
              | None -> ()
              | Some t -> Util_check.print_eval_res ~color:self.color t)
            eval_tasks
        | _ -> ())
      fdecls;

    (* print results of validation *)
    Iter.iter
      (fun (d : Stateful_decl.t) ->
        match d.as_cir with
        | Ok { Stateful_cir_decl.po_tasks; _ } ->
          List.iter
            (fun (_, t) ->
              match Rvar.get t with
              | None -> ()
              | Some t -> Util_check.print_po_res ~color:self.color t)
            po_tasks
        | _ -> ())
      fdecls;

    match res with
    | Ok { orepl_res; message; goals } ->
      Option.iter (Fmt.printf "%s@.") message;
      List.iter
        (fun (g : Rir.Sequent.t) ->
          Fmt.printf "@[<2>goal:@ %a@]@."
            (Dump_rir.dump_sequent ~name:true ~color:self.color)
            g)
        goals;

      (* result of OCaml evaluation *)
      Option.iter
        (fun (r : ORepl.eval_result) ->
          Fmt.printf "evaluation: %s in %.4fs@."
            (ORepl.show_eval_status r.status)
            r.elapsed_s;
          Fmt.printf "%s@." r.stdout;
          Fmt.eprintf "%s@." r.stderr)
        orepl_res
    | Error e ->
      any_error := true;
      Fmt.printf "%a@." Error.pp e
  in

  let proc_phrase_catch_ ~loc_ctx p : unit =
    try proc_phrase ~loc_ctx p with
    | Error.E err -> Fmt.printf "%a@." Error.pp err
    | ex -> Fmt.printf "Exception: %s@." (Printexc.to_string ex)
  in
  *)

let process_input ~client ~session ~(code : string) () : unit =
  let res = C.Eval.eval_code client ~session ~code () in

  match Fut.wait_block res with
  | Error (e, bt) ->
    Fmt.eprintf "RPC call failed with %s@ %s@." (Printexc.to_string e)
      (Printexc.raw_backtrace_to_string bt)
  | Ok _res ->
    (* TODO: also wait for each Task! *)
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.show-res" in
    Fmt.printf "EVALed: %a@." C.API.pp_code_snippet_eval_result _res

let main_loop ~reader ~session ~(client : C.t) () : unit =
  let continue = ref true in
  while !continue && C.RPC.Switch.is_on client.active do
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.loop.iter" in
    match Reader.read reader with
    | None -> continue := false
    | Some code -> process_input ~client ~session ~code ()
  done

let do_keepalive ~(client : C.t) ~session () =
  ignore
    (Fut.spawn ~on:client.runner (fun () ->
         Log.info (fun k -> k "send keep alive");
         try C.Session.keep_alive client session |> Fut.await
         with exn ->
           Log.err (fun k ->
               k "error in keepalive: %s" (Printexc.to_string exn));
           C.RPC.Switch.turn_off client.active;
           C.disconnect client)
      : unit Fut.t)

let period_keep_session_alive_s = 5.

(** Entrypoint. *)
let run (self : t) : int =
  if self.bt then Printexc.record_backtrace true;

  let log_file = Option.value ~default:"/tmp/repl.log" self.log_file in
  Utils.setup_logs ~log_file ?lvl:self.log_level ~debug:self.debug ();

  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.run" in

  let port = Option.value ~default:9991 self.port in
  Log.app (fun k -> k "connecting on port %d" port);
  let@ client =
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.connect" in
    Utils.with_client ~json:self.json ~port ()
  in

  let session =
    match self.session with
    | None -> C.Session.create client |> Fut.wait_block_exn
    | Some id ->
      (* reuse an existing session *)
      let sesh = C.API.make_session ~id () in
      (try C.Session.open_ client sesh |> Fut.wait_block_exn
       with e ->
         Fmt.eprintf "could not open session: %s@." (Printexc.to_string e);
         raise e);
      sesh
  in
  Fmt.printf "open session %s@." session.id;

  (* regularly ask for the session to survive *)
  C.Timer.run_every_s client.timer period_keep_session_alive_s
    (do_keepalive ~client ~session);

  let reader =
    Reader.create ~linenoise:(not self.raw) ~init_prompt:(fun () -> "> ") ()
  in

  main_loop ~reader ~session ~client ();
  0
