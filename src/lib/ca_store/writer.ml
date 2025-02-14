(** Writing values *)

(** Writing end of the storage *)
class type t = object
  inherit Core_classes.named
  inherit Core_classes.with_stats

  method store : (Key.t * (unit -> string)) Iter.t -> unit
  (** Store a batch of key/value pairs. Values are lazy so that, if a key is
      found to be present, we don't need to compute the exact serialization for
      the key's value. *)

  method store1 : Key.t -> (unit -> string) -> unit
  (** Store a single k/v pair *)

  method flush : unit -> unit
  (** Flush into underlying storage, if relevant *)
end

let[@inline] store (self : #t) (entries : _ Iter.t) : unit = self#store entries

let[@inline] store_l (self : #t) (entries : _ list) : unit =
  if entries <> [] then store self (Iter.of_list entries)

let[@inline] store1 (self : #t) k v : unit = self#store1 k v
let[@inline] flush (self : #t) : unit = self#flush ()
let pp out (self : #t) = Fmt.fprintf out "<cstore.writer %s>" self#name
let show self = Fmt.to_string pp self

(** Dummy storage, stores nothing. *)
class dummy : t =
  object
    method add_stats _ = ()
    method name = "dummy"
    method store1 _ _ = ()
    method store _ = ()
    method flush () = ()
  end
