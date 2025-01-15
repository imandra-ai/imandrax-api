(** Serializable report *)

module Mir = struct
  type event = Atomic_event.Mir.t Event.t_linear
  [@@typereg.name "Mir.event"] [@@deriving show, twine, typereg]

  type t = { events: event array }
  [@@unboxed]
  [@@deriving show { with_path = false }, twine, typereg]
  [@@typereg.name "Mir.t"]
  (** A (serializable) linear report, ie. a sequence of events.

    Nesting events (enter span/exit span) need to be correctly balanced. *)
end
