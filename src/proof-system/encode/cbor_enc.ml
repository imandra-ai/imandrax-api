type t = Buffer.t
type 'a enc = t -> 'a -> unit

let i64_to_int = Int64.to_int
let create (buf : Buffer.t) : t = buf

let[@inline] add_byte (self : t) (high : int) (low : int) =
  let i = (high lsl 5) lor low in
  assert (i land 0xff == i);
  Buffer.add_char self (Char.unsafe_chr i)

let[@inline] add_i64 (self : t) (i : int64) = Buffer.add_int64_be self i

(* add unsigned integer, including first tag byte *)
let[@inline] add_uint (self : t) (high : int) (x : int64) =
  assert (x >= 0L);
  if x < 24L then
    add_byte self high (i64_to_int x)
  else if x <= 0xffL then (
    add_byte self high 24;
    Buffer.add_char self (Char.unsafe_chr (i64_to_int x))
  ) else if x <= 0xff_ffL then (
    add_byte self high 25;
    Buffer.add_uint16_be self (i64_to_int x)
  ) else if x <= 0xff_ff_ff_ffL then (
    add_byte self high 26;
    Buffer.add_int32_be self (Int64.to_int32 x)
  ) else (
    add_byte self high 27;
    Buffer.add_int64_be self x
  )

let[@inline] false_ (self : t) = add_byte self 7 20
let[@inline] true_ (self : t) = add_byte self 7 21
let[@inline] null self = add_byte self 7 22
let[@inline] undefined self = add_byte self 7 23

let[@inline] bool (self : t) b =
  if b then
    true_ self
  else
    false_ self

let simple (self : t) i =
  if i < 24 then
    add_byte self 7 i
  else if i <= 0xff then (
    add_byte self 7 24;
    Buffer.add_char self (Char.unsafe_chr i)
  ) else
    failwith "cbor: simple value too high (above 255)"

let float (self : t) f =
  add_byte self 7 27;
  (* float 64 *)
  add_i64 self (Int64.bits_of_float f)

let[@inline] array_begin (self : t) ~len : unit =
  add_uint self 4 (Int64.of_int len)

let array self enc arr : unit =
  array_begin self ~len:(Array.length arr);
  for i = 0 to Array.length arr - 1 do
    let x = Array.get arr i in
    enc self x
  done

let array_l self enc l : unit =
  array_begin self ~len:(List.length l);
  List.iter (enc self) l

let[@inline] nullable self enc x =
  match x with
  | None -> null self
  | Some x -> enc self x

let[@inline] map_begin (self : t) ~len : unit =
  add_uint self 5 (Int64.of_int len)

let[@inline] int64 (self : t) (i : int64) =
  if i >= Int64.zero then
    add_uint self 0 i
  else if Int64.(add min_int 2L) > i then (
    (* large negative int, be careful. encode [(-i)-1] via int64. *)
    add_byte self 1 27;
    Buffer.add_int64_be self Int64.(neg (add 1L i))
  ) else
    add_uint self 1 Int64.(sub (neg i) one)

let[@inline] int (self : t) (i : int) : unit = int64 self (Int64.of_int i)

let text self s =
  add_uint self 3 (Int64.of_int (String.length s));
  Buffer.add_string self s

let text_slice self s i len =
  add_uint self 3 (Int64.of_int len);
  Buffer.add_substring self s i len

let bytes self s =
  add_uint self 2 (Int64.of_int (String.length s));
  Buffer.add_string self s

let bytes_slice self s i len =
  add_uint self 2 (Int64.of_int len);
  Buffer.add_substring self s i len

let tag (self : t) ~tag : unit = add_uint self 6 (Int64.of_int tag)

let cstor1 self s enc x : unit =
  array_begin self ~len:2;
  text self s;
  enc self x

let cstor2 self s enc1 x1 enc2 x2 : unit =
  array_begin self ~len:3;
  text self s;
  enc1 self x1;
  enc2 self x2
