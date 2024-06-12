(** An event for a tree-like report *)

(** An event in a linear report (ie an array of events) *)
type 'atomic_ev t_linear =
  | EL_atomic of {
      ts: Timestamp_s.t;  (** Instant at which the event happened *)
      ev: 'atomic_ev;
    }
  | EL_enter_span of {
      ts: Timestamp_s.t;
      ev: 'atomic_ev;
    }
  | EL_exit_span of { ts: Timestamp_s.t }
[@@deriving show { with_path = false }, twine, typereg, map, iter]

(** An event in a tree report *)
type ('atomic_ev, 'sub) t_tree =
  | ET_atomic of {
      ts: Timestamp_s.t;
      ev: 'atomic_ev;
    }
  | ET_span of {
      ts: Timestamp_s.t;
      duration: Duration_s.t;
      ev: 'atomic_ev;
      sub: 'sub;
    }
[@@deriving show { with_path = false }, twine, typereg, map, iter]
