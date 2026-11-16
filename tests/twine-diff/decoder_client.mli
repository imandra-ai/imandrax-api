(** An adapter running as a child process: framed requests on its stdin, one
    reply line each on its stdout.

    The child's stderr goes to a temporary file, so a chatty child cannot block
    on a full pipe; it is part of the report when the child dies. A child that
    dies is restarted, since a crash ends the process and shrinking a crash
    sends more requests after it. *)

type t

(** A decoder's answer to one request *)
type outcome =
  | Reply of (Sexp.reply, string) result
      (** a reply line, parsed. [Error] means it is not in the text form. *)
  | Died of string  (** the decoder crashed: it exited or hung *)

val start : string -> t
(** Start a shell command line (run with [/bin/sh -c]). *)

val request : ?mode:char -> ?timeout:float -> t -> string -> outcome
(** Send one request and read the reply. [mode] is ['v'] (decode the entry
    point, the default) or ['i'] (read the entry point as an integer). A child
    that does not reply within [timeout] seconds (default 10) is killed. *)

val stop : t -> unit
(** Close the child's stdin, which tells it to exit, and wait for it. *)
