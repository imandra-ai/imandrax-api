(** Function admission data. *)

type t = {
  measured_subset: int list;
      (** Subset of variables that participate in termination,
          given by their position in the list of arguments. *)
  measure_fun: Uid.t option;
      (** Name of the measure function (takes subset of arguments, returns an ordinal) *)
}
[@@deriving show { with_path = false }, eq, twine, typereg]
(** The admission data for a particular function. *)
