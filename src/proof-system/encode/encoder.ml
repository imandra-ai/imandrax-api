(** Generic encoder *)

(** Generic encoder *)
type t =
  | Enc : {
      st: 'st;
      int: 'st -> int -> unit;
      int64: 'st -> int64 -> unit;
      float: 'st -> float -> unit;
      bool: 'st -> bool -> unit;
      text: 'st -> string -> unit;
      bytes: 'st -> string -> unit;
      null: 'st -> unit;
      array_begin: 'st -> len:int -> unit;
      array_end: 'st -> unit;
      map_begin: 'st -> len:int -> unit;
      map_end: 'st -> len:int -> unit;
      tag: 'st -> tag:int -> unit;
    }
      -> t

type 'a enc = t -> 'a -> unit

let[@inline] int : 'st -> int -> unit = fun (Enc r) x -> r.int r.st x
let[@inline] int64 : 'st -> int64 -> unit = fun (Enc r) x -> r.int64 r.st x
let[@inline] float : 'st -> float -> unit = fun (Enc r) x -> r.float r.st x
let[@inline] bool : 'st -> bool -> unit = fun (Enc r) x -> r.bool r.st x
let[@inline] text : 'st -> string -> unit = fun (Enc r) x -> r.text r.st x
let[@inline] bytes : 'st -> string -> unit = fun (Enc r) x -> r.bytes r.st x
let[@inline] null : 'st -> unit = fun (Enc r) -> r.null r.st

let[@inline] array_begin : 'st -> len:int -> unit =
 fun (Enc r) ~len -> r.array_begin r.st ~len

let[@inline] array_end : 'st -> unit = fun (Enc r) -> r.array_end r.st

let[@inline] map_begin : 'st -> len:int -> unit =
 fun (Enc r) ~len -> r.map_begin r.st ~len

let[@inline] map_end : 'st -> len:int -> unit = fun (Enc r) -> r.map_end r.st
let[@inline] tag : 'st -> tag:int -> unit = fun (Enc r) ~tag -> r.tag r.st ~tag

let[@inline] nullable : 'a enc -> 'a option enc =
 fun enc self x ->
  match x with
  | None -> null self
  | Some x -> enc self x

let cstor1 self s enc x : unit =
  array_begin self ~len:2;
  text self s;
  enc self x;
  array_end self

let cstor2 self s enc1 x1 enc2 x2 : unit =
  array_begin self ~len:3;
  text self s;
  enc1 self x1;
  enc2 self x2;
  array_end self

let array self enc arr : unit =
  array_begin self ~len:(Array.length arr);
  for i = 0 to Array.length arr - 1 do
    let x = Array.get arr i in
    enc self x
  done

let array_l self enc l : unit =
  array_begin self ~len:(List.length l);
  List.iter (enc self) l
