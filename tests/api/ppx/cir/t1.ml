(* checking that all this compiles *)

type t = {
  x: Z.t; [@printer Z.pp_print]
  y: bool;
}
[@@deriving show, of_cir]

(* check type *)
let () = ignore (of_cir : Imandrax_api_cir.Term.t -> t)

type bar = {
  x: (Z.t * bool option * unit) option list list;
  y: unit list;
  z: string;
}
[@@deriving of_cir]

(* check type *)
let () = ignore (bar_of_cir : Imandrax_api_cir.Term.t -> bar)

type ('a, 'b) yolo = { x: ('a option * 'b list) list } [@@deriving of_cir]

let () = ignore (yolo_of_cir : _ -> _ -> Imandrax_api_cir.Term.t -> _ yolo)

module Foo = struct
  type t =
    | A
    | B of {
        x: Z.t option;
        y: bool list;
      }
    | C of Z.t
    | D of bool * bool * unit option
  [@@deriving of_cir]

  (* check type *)
  let () = ignore (of_cir : Imandrax_api_cir.Term.t -> t)
end
