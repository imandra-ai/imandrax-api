(** API versioning.

    This version number {b MUST} be changed every time we modify the types. *)

(* for now we are conservative and use over-specific versions. *)

(** The main version. See [VERSION]. *)
let version : string = Version_.version

(** Full git version *)
let git_version = Gitid.rev
