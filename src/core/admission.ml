(** Function admission data. *)

type t = {
  measured_subset: string list;
      (** Subset of variables that participate in termination. *)
  measure_fun: Uid.t option;
      (** Name of the measure function (takes subset of arguments, returns an ordinal) *)
}
[@@deriving show { with_path = false }, eq, twine, typereg]
(** The admission data for a particular function. *)
