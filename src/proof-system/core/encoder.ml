(** Generic encoder *)

type 'st t = {
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
  map_end: 'st -> unit;
  tag: 'st -> tag:int -> unit;
}
(** Generic encoder *)

type ('st, 'a) enc = 'st t -> 'st -> 'a -> unit

let[@inline] int : 'st t -> 'st -> int -> unit = fun r st x -> r.int st x
let[@inline] int64 : 'st t -> 'st -> int64 -> unit = fun r st x -> r.int64 st x
let[@inline] float : 'st t -> 'st -> float -> unit = fun r st x -> r.float st x
let[@inline] bool : 'st t -> 'st -> bool -> unit = fun r st x -> r.bool st x
let[@inline] text : 'st t -> 'st -> string -> unit = fun r st x -> r.text st x
let[@inline] bytes : 'st t -> 'st -> string -> unit = fun r st x -> r.bytes st x
let[@inline] null : 'st t -> 'st -> unit = fun r st -> r.null st

let[@inline] array_begin : 'st t -> 'st -> len:int -> unit =
 fun r st ~len -> r.array_begin st ~len

let[@inline] array_end : 'st t -> 'st -> unit = fun r st -> r.array_end st

let[@inline] map_begin : 'st t -> 'st -> len:int -> unit =
 fun r st ~len -> r.map_begin st ~len

let[@inline] map_end : 'st t -> 'st -> unit = fun r st -> r.map_end st

let[@inline] tag : 'st t -> 'st -> tag:int -> unit =
 fun r st ~tag -> r.tag st ~tag

let[@inline] nullable : ('st, 'a) enc -> ('st, 'a option) enc =
 fun enc st self x ->
  match x with
  | None -> null st self
  | Some x -> enc st self x

let cstor1 self st s enc x : unit =
  array_begin self st ~len:2;
  text self st s;
  enc self st x;
  array_end self st

let cstor2 self st s enc1 x1 enc2 x2 : unit =
  array_begin self st ~len:3;
  text self st s;
  enc1 self st x1;
  enc2 self st x2;
  array_end self st

let array self st (enc : _ enc) arr : unit =
  array_begin self st ~len:(Array.length arr);
  for i = 0 to Array.length arr - 1 do
    let x = Array.get arr i in
    enc self st x
  done

let array_l self st (enc : _ enc) l : unit =
  array_begin self st ~len:(List.length l);
  List.iter (enc self st) l
