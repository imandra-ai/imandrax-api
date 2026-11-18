type outcome =
  | Reply of (Sexp.reply, string) result
  | Died of string

(* One child process
   ================= *)

type child = {
  pid: int;
  to_child: out_channel;
  from_child: in_channel;
  stderr_file: string;
  mutable stopped: bool;
}

let spawn (command : string) : child =
  (* writing to a child that died must raise, not kill the harness *)
  Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
  let stdin_r, stdin_w = Unix.pipe ~cloexec:true () in
  let stdout_r, stdout_w = Unix.pipe ~cloexec:true () in
  let stderr_file = Filename.temp_file "twine-conformance" ".stderr" in
  let stderr_fd =
    Unix.openfile stderr_file [ O_WRONLY; O_TRUNC; O_CLOEXEC ] 0o600
  in
  let pid =
    Unix.create_process "/bin/sh"
      [| "/bin/sh"; "-c"; "exec " ^ command |]
      stdin_r stdout_w stderr_fd
  in
  List.iter Unix.close [ stdin_r; stdout_w; stderr_fd ];
  {
    pid;
    to_child = Unix.out_channel_of_descr stdin_w;
    from_child = Unix.in_channel_of_descr stdout_r;
    stderr_file;
    stopped = false;
  }

let read_stderr (c : child) : string =
  try In_channel.with_open_bin c.stderr_file In_channel.input_all
  with Sys_error _ -> ""

(** The reply line, or [Error what] when the child exited or hung *)
let exchange ~(timeout : float) (c : child) (ty : string) (bytes : string) :
    (string, string) result =
  match
    output_string c.to_child ty;
    output_char c.to_child ' ';
    output_string c.to_child (Sexp.hex_of_string bytes);
    output_char c.to_child '\n';
    flush c.to_child
  with
  | exception Sys_error _ -> Error "stopped reading requests"
  | () ->
    (* Waiting on the descriptor only works while the channel's buffer is
       empty. It is between replies as long as the child writes exactly one line
       per request. A child that writes more fills the buffer, the next wait
       does not see the buffered line, and the request reports a timeout. *)
    let fd = Unix.descr_of_in_channel c.from_child in
    (match Unix.select [ fd ] [] [] timeout with
    | [], _, _ ->
      (try Unix.kill c.pid Sys.sigkill with Unix.Unix_error _ -> ());
      Error (Printf.sprintf "did not reply within %gs" timeout)
    | _ ->
      (match In_channel.input_line c.from_child with
      | Some line -> Ok line
      | None -> Error "exited without replying"))

let stop_child (c : child) : unit =
  if not c.stopped then (
    c.stopped <- true;
    (try close_out c.to_child with Sys_error _ -> ());
    close_in_noerr c.from_child;
    (try ignore (Unix.waitpid [] c.pid : int * Unix.process_status)
     with Unix.Unix_error _ -> ());
    try Sys.remove c.stderr_file with Sys_error _ -> ()
  )

(* Restarting on death
   =================== *)

type t = {
  command: string;
  mutable child: child;
}

let start command = { command; child = spawn command }

let request ?(ty = "any") ?(timeout = 10.) (self : t) (bytes : string) : outcome
    =
  match exchange ~timeout self.child ty bytes with
  | Ok line -> Reply (Sexp.parse_reply line)
  | Error what ->
    let msg =
      Printf.sprintf "the adapter %s; its stderr:\n%s" what
        (String.trim (read_stderr self.child))
    in
    stop_child self.child;
    self.child <- spawn self.command;
    Died msg

let stop (self : t) : unit = stop_child self.child
