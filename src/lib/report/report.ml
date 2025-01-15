(** Serializable report *)

type event = Atomic_event.Mir.t Event.t_linear [@@deriving show, twine, typereg]

type t = { events: event array }
[@@unboxed] [@@deriving show { with_path = false }, twine, typereg]
(** A (serializable) linear report, ie. a sequence of events.

    Nesting events (enter span/exit span) need to be correctly balanced. *)
