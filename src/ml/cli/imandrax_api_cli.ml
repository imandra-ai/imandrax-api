open Common_
module Opts = Cli_opts_

type cli =
  | Login of Opts.login
  | Version of Opts.conn  (** Display the version. *)
  | GC_stats of Opts.conn_with_repeat
  | Reduce_memory of Opts.conn  (** Reduce memory usage *)
  | Repl of Opts.repl
      (** Open an interactive REPL session (read-eval-print loop). *)
(*
  | Check of check  (** Check files in batch mode. *)
  | Serve of serve  (** Start a server to explore existing sessions. *)
  | Run_po of run_po  (** Run a single PO from a file *)
  | Analyze_dune of analyze_dune  (** Analyze dune project *)
  | Show_imports of show_imports  (** Show imports for a file *)
  *)
[@@deriving subliner]

let version (self : Opts.conn) : int =
  Utils.setup_logs ~debug:self.debug ();
  let@ runner = Moonpool.Fifo_pool.with_ () in
  let@ (c : C.t) =
    Utils.with_client ~rpc_json:self.rpc_json ?rpc_port:self.rpc_port ~runner
      ~debug:self.debug ~local_rpc:self.local_rpc ~dev:self.dev ()
  in
  let v = C.System.version c |> Fut.wait_block_exn in
  Fmt.printf "version %s (git=%s)" v.version
    (Option.value ~default:"<unknown>" v.git_version);
  0

let pp_gc_stats (out : Fmt.t) (v : C.API.gc_stats) : unit =
  Fmt.fprintf out "heap=%LdB major=%Ld minor=%Ld" v.heap_size_b
    v.major_collections v.minor_collections

let repeat_ ~every f =
  while true do
    f ();
    Thread.delay every
  done

let gc_stats (self : Opts.conn_with_repeat) : int =
  Utils.setup_logs ~debug:self.debug ();
  Log.debug (fun k -> k "CONNECT");
  let@ runner = Moonpool.Fifo_pool.with_ () in
  let@ (c : C.t) =
    Utils.with_client ~rpc_json:self.rpc_json ?rpc_port:self.rpc_port ~runner
      ~debug:self.debug ~local_rpc:self.local_rpc ~dev:self.dev ()
  in

  Log.debug (fun k -> k "CONNECTED %a" C.pp c);

  let run () =
    let v = C.System.gc_stats c |> Fut.wait_block_exn in
    Fmt.printf "%a@." pp_gc_stats v
  in
  match self.repeat with
  | None ->
    run ();
    0
  | Some r ->
    repeat_ ~every:r run;
    0

let reduce_memory (self : Opts.conn) : int =
  Utils.setup_logs ~debug:self.debug ();
  let@ runner = Moonpool.Fifo_pool.with_ () in
  let@ (c : C.t) =
    Utils.with_client ~rpc_json:self.rpc_json ?rpc_port:self.rpc_port ~runner
      ~debug:self.debug ~local_rpc:self.local_rpc ~dev:self.dev ()
  in
  let v = C.System.release_memory c |> Fut.wait_block_exn in
  Fmt.printf "%a@." pp_gc_stats v;
  0

let run (cli : cli) : unit =
  let@ () = Utils.with_exit in
  let@ () = Trace_tef.with_setup () in
  match cli with
  | Login opts -> Login.run opts
  | Version c -> version c
  | GC_stats c -> gc_stats c
  | Reduce_memory c -> reduce_memory c
  | Repl r -> Repl.run r

[%%subliner.cmds eval.cli <- run] [@@name "imandrax-cli"]
