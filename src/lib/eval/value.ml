(** A view of computation values. *)

open Imandrax_api_mir

type cstor_descriptor = {
  cd_idx: int;  (** Index in the list of cstors of its type *)
  cd_name: Imandrax_api.Uid.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** Representation of a constructor *)

type record_descriptor = {
  rd_name: Imandrax_api.Uid.t;
  rd_fields: Imandrax_api.Uid.t array;  (** Labels of fields of the record *)
}
[@@deriving show { with_path = false }, twine, typereg]
(** Description of a record's fields *)

type ('v, 'closure) view =
  | V_true
  | V_false
  | V_int of Util_twine_.Z.t
  | V_real of Util_twine_.Q.t
  | V_string of string
  | V_cstor of cstor_descriptor * 'v array
  | V_tuple of 'v array
  | V_record of record_descriptor * 'v array
  | V_quoted_term of Imandrax_api_mir.Top_fun.t  (** A quoted term *)
  | V_uid of Imandrax_api.Uid.t
  | V_closure of 'closure
  | V_custom of Custom_value.t
  | V_ordinal of Ordinal.t
[@@deriving twine, typereg, map, iter, show { with_path = false }]

type t = { v: (t, unit) view } [@@unboxed] [@@deriving twine, typereg]
(** A value obtained by evaluation or as a model. Closures are erased. *)

let[@inline] make (v : (t, unit) view) : t = { v }
let rec pp out (self : t) = pp_view pp (Fmt.return "<closure>") out self.v
let show = Fmt.to_string pp

(** A bit of a hack, used for pretty printing *)
let to_list v : t list option =
  let rec loop acc (v : t) =
    match v.v with
    | V_cstor (c, [| a; b |]) when c.cd_name.name = "::" -> loop (a :: acc) b
    | V_cstor (c, [||]) when c.cd_name.name = "[]" -> List.rev acc
    | _ -> raise Exit
  in
  try Some (loop [] v) with Exit -> None
