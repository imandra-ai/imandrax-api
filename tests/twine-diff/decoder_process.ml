(** A decoder program running as a child process: framed requests on its stdin,
    one reply line each on its stdout.

    The child's stderr goes to a temporary file, so a chatty child cannot block
    on a full pipe; it is shown when the child dies. *)

type t = {
  command: string;
  pid: int;
  to_child: out_channel;
  from_child: in_channel;
  stderr_file: string;
  mutable stopped: bool;
}

exception Died of string

(** Start [command], a shell command line (run with [/bin/sh -c]). *)
let start (command : string) : t =
  (* writing to a child that died must raise, not kill the harness *)
  Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
  let stdin_r, stdin_w = Unix.pipe ~cloexec:true () in
  let stdout_r, stdout_w = Unix.pipe ~cloexec:true () in
  let stderr_file = Filename.temp_file "twine-diff" ".stderr" in
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
    command;
    pid;
    to_child = Unix.out_channel_of_descr stdin_w;
    from_child = Unix.in_channel_of_descr stdout_r;
    stderr_file;
    stopped = false;
  }

let read_stderr (self : t) : string =
  try In_channel.with_open_bin self.stderr_file In_channel.input_all
  with Sys_error _ -> ""

let died (self : t) (what : string) : 'a =
  raise
    (Died
       (Printf.sprintf "decoder %S %s; its stderr:\n%s" self.command what
          (read_stderr self)))

(** Send one request and return the reply line. [mode] is ['v'] (decode the
    entry point) or ['i'] (read the entry point as an integer).
    @raise Died if the child exits or closes its stdout *)
let request ?timeout (self : t) (mode : char) (bytes : string) : string =
  let len = Bytes.create 4 in
  Bytes.set_int32_be len 0 (Int32.of_int (String.length bytes));
  (try
     output_char self.to_child mode;
     output_bytes self.to_child len;
     output_string self.to_child bytes;
     flush self.to_child
   with Sys_error _ -> died self "stopped reading requests");
  (* the channel's buffer is empty between replies (each is one line, read
     whole), so waiting on the descriptor is enough *)
  Option.iter
    (fun seconds ->
      let fd = Unix.descr_of_in_channel self.from_child in
      match Unix.select [ fd ] [] [] seconds with
      | [], _, _ ->
        (try Unix.kill self.pid Sys.sigkill with Unix.Unix_error _ -> ());
        died self (Printf.sprintf "did not reply within %gs" seconds)
      | _ -> ())
    timeout;
  match In_channel.input_line self.from_child with
  | Some line -> line
  | None -> died self "exited without replying"

(** Close the child's stdin, which tells it to exit, and wait for it. *)
let stop (self : t) : unit =
  if not self.stopped then (
    self.stopped <- true;
    (try close_out self.to_child with Sys_error _ -> ());
    close_in_noerr self.from_child;
    (try ignore (Unix.waitpid [] self.pid : int * Unix.process_status)
     with Unix.Unix_error _ -> ());
    try Sys.remove self.stderr_file with Sys_error _ -> ()
  )
