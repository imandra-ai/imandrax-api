open Common_cstore_

module Raw = struct
  type t = { key: Key.t }
  [@@unboxed] [@@deriving eq, ord, typereg] [@@typereg.name "Raw.t"]

  let show self = Key.show self.key
  let pp out self = Key.pp out self.key
  let to_twine st self = Key.to_twine st self.key

  let of_twine st v =
    let key = Key.of_twine st v in
    { key }

  let to_string self = Key.slugify self.key
  let[@inline] slugify (self : t) = Key.slugify self.key
  let[@inline] unslugify_exn s : t = { key = Key.unslugify_exn s }
end

type 'a t = Raw.t [@@deriving typereg]

let[@inline] raw self = self
let show (self : _ t) = Raw.show self
let pp out (self : _ t) = Raw.pp out self
let to_twine' st (self : _ t) = Raw.to_twine st (raw self)
let of_twine' : _ t Imandrakit_twine.decoder = fun dec x -> Raw.of_twine dec x
let to_twine _ st self = to_twine' st self
let of_twine _ st c = of_twine' st c

module Private_ = struct
  let[@inline] unsafe_of_raw r = r
  let[@inline] raw_of_key key = { Raw.key }
  let[@inline] raw_to_key r = r.Raw.key
end

let[@inline] of_key_ key =
  Private_.raw_of_key key |> (Private_.unsafe_of_raw [@alert "-expert"])

let[@inline] to_key_ (self : _ t) = raw self |> Private_.raw_to_key

let store (store : #Writer.t) (codec : (_, 'a) Ca_codec.t) x : 'a t =
  let str = Ca_codec.encode_to_string codec x in
  let ch = Chash.(make string str) in
  let key = Key.chash ~ty:(Ca_codec.name codec) ch in
  Writer.store1 store key (fun () -> str);
  of_key_ key

let store_l (wr : #Writer.t) (codec : _ Ca_codec.t) l : 'a t list =
  let name = Ca_codec.name codec in
  let cptrs, entries =
    List.map
      (fun x ->
        let str = Ca_codec.encode_to_string codec x in
        let ch = Chash.(make string str) in
        let key = Key.chash ~ty:name ch in
        of_key_ key, (key, fun () -> str))
      l
    |> List.split
  in
  Writer.store_l wr entries;
  cptrs

let decode_value (codec : _ Ca_codec.t) st (self : _ t) (v : string option) :
    _ Error.result =
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "cptr.decode-value" in
  match Option.map (Ca_codec.decode_string codec st) v with
  | Some v -> Ok v
  | None ->
    let err =
      Error.mk_errorf ~kind:Error_kinds.cptrNotFoundInStorage
        "Cptr: no stored value for %a." Raw.pp (raw self)
    in
    Error err
  | exception Error.E e -> Error e
  | exception exn ->
    let bt = Printexc.get_raw_backtrace () in
    let err =
      Error.of_exn ~bt exn ~kind:Error_kinds.cptrGetOtherErr
      |> Error.add_ctx (Error.messagef "In Cptr.get %a" Raw.pp (raw self))
    in
    Error err

let decode_value_exn (codec : (_, 'a) Ca_codec.t) st (self : 'a t)
    (v : string option) : 'a =
  match decode_value codec st self v with
  | Ok x -> x
  | Error err -> Error.raise_err err

open struct
  (** Key from a cptr *)
  let[@inline] key_of_cptr (self : _ t) : Key.t = to_key_ self
end

(** Get value *)
let get (rd : #Reader.t) (codec : (_, 'a) Ca_codec.t) st (self : 'a t) :
    _ result =
  let key = key_of_cptr self in
  let v = Reader.find_opt rd key in
  decode_value codec st self v

let try_get (rd : #Reader.t) (codec : _ Ca_codec.t) st (self : _ t) :
    _ result option =
  let key = key_of_cptr self in
  let v = Reader.find_opt rd key in
  match v with
  | None -> None
  | Some _ as v -> Some (decode_value codec st self v)

let get_exn store codec st self =
  let x = get store codec st self in
  match x with
  | Ok x -> x
  | Error e -> Error.raise_err e

let get_l_exn (rd : #Reader.t) codec st (ptr_l : 'a t list) : 'a list =
  if ptr_l = [] then
    []
  else
    let@ _sp =
      Imandrakit_log.Trace_async.with_span ~__FILE__ ~__LINE__ "cptr.get-l"
    in

    Log.debug (fun k -> k "(@[cptr.get_l@ :n %d@])" (List.length ptr_l));
    let keys = List.map key_of_cptr ptr_l in
    let values_l = Reader.find_l_in_order rd keys in

    match ptr_l, values_l with
    | [ ptr ], [ v ] -> [ decode_value_exn codec st ptr v ]
    | _ ->
      assert (List.length ptr_l = List.length values_l);
      List.map2 (fun ptr v -> decode_value_exn codec st ptr v) ptr_l values_l
