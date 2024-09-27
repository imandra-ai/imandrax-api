(** API versioning.

    This version number (in [API_TYPES_VERSION])
    {b MUST} be changed every time we modify the types. *)

(* for now we are conservative and use over-specific versions. *)

(** The main version. See [API_TYPES_VERSION] file. *)
let api_types_version : string = Version_.version

(** Full git version *)
let git_version = Gitid.rev
