(* checking that all this compiles *)

type t = {
  x: Z.t; [@printer Z.pp_print]
  y: bool;
}
[@@deriving show, to_iml]

(* check type *)
let () = ignore (to_iml_string : t -> string)

type bar = {
  x: (Z.t * bool option * unit) option list list;
  y: unit list;
  z: string;
}
[@@deriving to_iml]

(* check type *)
let () = ignore (bar_to_iml_string : bar -> string)

type ('a, 'b) yolo = { x: ('a option * 'b list) list } [@@deriving to_iml]

let () = ignore (yolo_to_iml_string : _ -> _ -> _ yolo -> string)

module Foo = struct
  type t =
    | A
    | B of {
        x: Z.t option;
        y: bool list;
      }
    | C of Z.t
    | D of bool * bool * unit option
  [@@deriving to_iml]

  (* check type *)
  let () = ignore (to_iml_string : t -> string)
end
