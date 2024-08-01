(** API versioning.

    This version number {b MUST} be changed every time we modify the types. *)

(* for now we are conservative and use over-specific versions. *)

open struct
  let internal_count_ = 2
end

(** The main version. *)
let version : string = spf "v%d" internal_count_

(** Full git version *)
let git_version = Gitid.rev
