open Common_

type t = Cli_opts_.repl [@@deriving show]

(** Parser for top phrases from stdin *)
module Reader : sig
  type t

  val create : linenoise:bool -> init_prompt:(unit -> string) -> unit -> t
  val read : t -> string option
  val dispose : t -> unit
end = struct
  type t = {
    buf: Buffer.t;
    init_prompt: unit -> string;
    linenoise: bool;
  }

  let hist_dir =
    let xdg = Xdg.create ~env:Sys.getenv_opt () in
    Filename.concat (Xdg.state_dir xdg) "imandrax"

  let hist_file = Filename.concat hist_dir "repl-history"

  let create ~linenoise ~init_prompt () : t =
    if linenoise then (
      (try
         ignore (Unix.system (spf "mkdir -p %S" hist_dir) : Unix.process_status)
       with _ -> ());
      LNoise.history_load ~filename:hist_file |> ignore;
      ignore (LNoise.history_set ~max_length:1000);
      LNoise.set_multiline false;
      LNoise.catch_break true
    ) else
      Sys.catch_break true;
    { init_prompt; buf = Buffer.create 2048; linenoise }

  let dispose (self : t) =
    if self.linenoise then LNoise.history_save ~filename:hist_file |> ignore

  let prompt_cont = "  "

  let prompt_ (self : t) =
    if Buffer.length self.buf = 0 then
      self.init_prompt ()
    else
      prompt_cont

  let read_line (self : t) : string option =
    let prompt = prompt_ self in
    if self.linenoise then (
      let s = LNoise.linenoise prompt in
      (match s with
      | Some s when String.trim s <> "" -> LNoise.history_add s |> ignore
      | _ -> ());
      s
    ) else (
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

let process_input ~client ~session ~(code : string) () : unit =
  match C.Eval.eval_code client ~session ~code () with
  | exception e ->
    let bt = Printexc.get_raw_backtrace () in
    Fmt.eprintf "RPC call failed with %s@ %s@." (Printexc.to_string e)
      (Printexc.raw_backtrace_to_string bt)
  | _res ->
    (* TODO: also wait for each Task! *)
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.show-res" in
    Fmt.printf "EVALed: %a@." C.API.pp_code_snippet_eval_result _res

let main_loop ~reader ~session ~(client : C.t) () : unit =
  let continue = ref true in
  while !continue && C.is_active client do
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.loop.iter" in
    match Reader.read reader with
    | None -> continue := false
    | Some code -> process_input ~client ~session ~code ()
  done;
  Reader.dispose reader

let do_keepalive ~runner ~(client : C.t) ~session () =
  Moonpool.run_async runner (fun () ->
      Log.info (fun k -> k "send keep alive");
      try C.Session.keep_alive client session
      with exn ->
        Log.err (fun k -> k "error in keepalive: %s" (Printexc.to_string exn));
        C.disconnect client)

let period_keep_session_alive_s = 30.

(** Entrypoint. *)
let run (self : t) : int =
  if self.bt then Printexc.record_backtrace true;

  let log_file = Option.value ~default:"/tmp/repl.log" self.log_file in
  Utils.setup_logs ~log_file ?lvl:self.log_level ~debug:self.debug ();

  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.run" in

  let@ runner = Moonpool.Fifo_pool.with_ () in
  let@ (client : C.t) =
    let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "repl.connect" in
    Utils.with_client ~local_http:self.local_http ~debug:self.debug
      ~dev:self.dev ()
  in

  let session =
    match self.session with
    | None -> C.Session.create client
    | Some id ->
      (* reuse an existing session *)
      let sesh = C.API.make_session ~id () in
      (try C.Session.open_ client sesh
       with e ->
         Fmt.eprintf "could not open session: %s@." (Printexc.to_string e);
         raise e);
      sesh
  in
  Fmt.printf "open session %s@." session.id;

  (* regularly ask for the session to survive *)
  ignore
    (Thread.create
       (fun () ->
         while C.is_active client do
           Thread.delay period_keep_session_alive_s;
           do_keepalive ~runner ~client ~session ()
         done)
       ()
      : Thread.t);

  let reader =
    Reader.create ~linenoise:(not self.raw) ~init_prompt:(fun () -> "> ") ()
  in

  main_loop ~reader ~session ~client ();
  0
