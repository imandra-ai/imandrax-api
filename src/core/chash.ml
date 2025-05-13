(** Cryptographic Hash *)

module H = Cryptokit.Hash

type t = (string[@use_bytes]) [@@deriving twine, typereg, ord, eq]

let hash = CCHash.string

let () =
  Imandrakit_twine.Encode.add_cache_with ~max_string_size:0 ~eq:equal ~hash
    to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

let dummy : t = "\xDE\xAD\xBE\xEF"
let n_bits_ = 256
let n_bytes = n_bits_ / 8

let _of_bin x : t =
  if x <> dummy && String.length x <> n_bytes then
    Imandrakit.Error.failf ~kind:Error_kinds.deserializationError
      "chash: expected %dB, got a blob %dB long." n_bytes (String.length x);
  x

type builder = {
  h: Cryptokit.hash;
  buf: bytes;  (** Buffer to accumulate bytes, at least 8 bytes long *)
  mutable off: int;  (** Offset in [buf] *)
}

type 'a hasher = builder -> 'a -> unit

let[@inline] new_hash_ () : Cryptokit.hash = H.blake2b n_bits_

let new_builder_ () : builder =
  { h = new_hash_ (); buf = Bytes.create 1024; off = 0 }

let[@inline] to_bin (x : t) : string = (x :> string)

let[@inline never] flush_buf_ (self : builder) : unit =
  if self.off > 0 then (
    self.h#add_substring self.buf 0 self.off;
    self.off <- 0
  )

let finalize (self : builder) =
  flush_buf_ self;
  self.h#result |> _of_bin

let[@inline] available_ (self : builder) : int =
  Bytes.length self.buf - self.off - 1

(** Reserve [n] bytes of space *)
let[@inline] reserve_ (self : builder) (n : int) =
  assert (n < Bytes.length self.buf);
  if available_ self < n then flush_buf_ self

let to_string (s : t) =
  Base64.encode_exn ~alphabet:Base64.uri_safe_alphabet ~pad:false (s :> string)

let slugify (s : t) : string =
  Base64.encode_exn ~alphabet:Base64.uri_safe_alphabet ~pad:true (s :> string)

let _of_string s =
  Base64.decode_exn ~alphabet:Base64.uri_safe_alphabet ~pad:false s |> _of_bin

let unslugify s =
  Base64.decode_exn ~alphabet:Base64.uri_safe_alphabet ~pad:false s |> _of_bin

let pp out s = Fmt.string out @@ to_string s

let show_abbrev (self : t) =
  let str = String.sub (self :> string) 0 6 in
  Base64.encode_exn ~alphabet:Base64.uri_safe_alphabet ~pad:false str

let[@inline] pp_abbrev out (self : t) = Fmt.string out @@ show_abbrev self
let show = to_string
let init () : builder = new_builder_ ()

let make (c : 'a hasher) (x : 'a) : t =
  let@ _sp = Trace_core.with_span ~__FILE__ ~__LINE__ "chash.make" in
  let ctx = init () in
  c ctx x;
  finalize ctx

let[@inline] int64 self x =
  reserve_ self 8;
  Bytes.set_int64_le self.buf self.off x;
  self.off <- self.off + 8

let[@inline] int (self : builder) x = int64 self (Int64.of_int x)

let[@inline] int32 self x =
  reserve_ self 4;
  Bytes.set_int32_le self.buf self.off x;
  self.off <- self.off + 4

let[@inline] nativeint self x = int64 self (Int64.of_nativeint x)

external char_of_bool_ : bool -> char = "%identity"

let[@inline] bool self x =
  reserve_ self 1;
  Bytes.set self.buf self.off (char_of_bool_ x);
  self.off <- self.off + 1

let[@inline] char self x =
  reserve_ self 1;
  Bytes.set self.buf self.off x;
  self.off <- self.off + 1

let string (self : builder) (str : string) =
  let len = String.length str in
  if len < Bytes.length self.buf then (
    reserve_ self len;
    Bytes.blit_string str 0 self.buf self.off len;
    self.off <- self.off + len
  ) else (
    (* write what we have and pass [s] directly to hasher *)
    flush_buf_ self;
    self.h#add_string str
  )

let[@inline] float self x = int64 self (Int64.bits_of_float x)

let sub_hash (self : builder) (x : t) =
  let str = to_bin x in
  let n = String.length str in
  reserve_ self n;
  Bytes.blit_string str 0 self.buf self.off n;
  self.off <- self.off + n

(* store sign, then bits *)
let z self x =
  bool self (Z.sign x >= 0);
  self.h#add_string (Z.to_bits x)

let q b x =
  z b (Q.num x);
  z b (Q.den x)

let list f b x =
  string b "(list";
  int b (List.length x);
  List.iter (f b) x;
  string b ")"

let iter f b x =
  string b "(iter";
  x (f b);
  string b ")"

let seq f b seq =
  string b "(seq";
  Seq.iter (fun x -> f b x) seq;
  string b ")"

let array f b x =
  string b "(array";
  int b (Array.length x);
  Array.iter (f b) x;
  string b ")"

let option f b x =
  match x with
  | None -> string b "none"
  | Some x ->
    string b "some";
    f b x

let result fok ferr ctx x =
  match x with
  | Ok x ->
    string ctx "ok:";
    fok ctx x
  | Error e ->
    string ctx "err:";
    ferr ctx e

let pair f1 f2 b (x, y) =
  f1 b x;
  f2 b y

let triple f1 f2 f3 b (x, y, z) =
  f1 b x;
  f2 b y;
  f3 b z

let quad f1 f2 f3 f4 b (x, y, z, u) =
  f1 b x;
  f2 b y;
  f3 b z;
  f4 b u

let list_sorted h ctx l =
  let hashes = List.map (make h) l |> List.sort compare in
  string ctx "(slist";
  int ctx (List.length hashes);
  list sub_hash ctx hashes;
  string ctx ")"

let map f h ctx x = h ctx (f x)
let hash_as_int x = CCHash.string (to_bin x)

let hash_file (file : string) : t =
  let hash = new_hash_ () in
  let@ ic = CCIO.with_in file in
  Cryptokit.hash_channel hash ic |> _of_bin

module Tbl = CCHashtbl.Make (struct
  type nonrec t = t

  let equal = equal
  let hash = hash_as_int
end)
