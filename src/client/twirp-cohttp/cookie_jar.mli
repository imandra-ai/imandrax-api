(** A minimal cookie jar.

    The server sits behind a load balancer that pins a session to one backend
    using a cookie (e.g. [GCILB]). Sessions live in the memory of a single
    backend, so a call issued without replaying that cookie can land on a
    backend that knows nothing about our session and fail with [InvalidSession]. *)

type t

val create : unit -> t

val to_header : t -> (string * string) option
(** Header to add to a request, or [None] while the jar is empty. *)

val update_from_response : t -> (string * string) list -> unit
(** Record the cookies set by a response, given its headers. *)
