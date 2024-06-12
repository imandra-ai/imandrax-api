(** Reading values *)

open Common_

(** Reading end of the storage *)
class type t = object
  inherit Core_classes.named
  inherit Core_classes.with_stats

  method mem : Key.t list -> Basic_bv.t
  (** Return a bitset where bit [i] is true if key [i] is present *)

  method find_l : Key.t list -> (Key.t * string option) list
  method find_l_in_order : Key.t list -> string option list
  method find_opt : Key.t -> string option
end

class dummy : t =
  object
    method name = "dummy"
    method add_stats _ = ()
    method mem l = Basic_bv.create (List.length l)
    method find_opt _ = None
    method find_l _ = []
    method find_l_in_order _ = []
  end

let[@inline] mem (self : #t) (ks : Key.t list) : Basic_bv.t = self#mem ks
let[@inline] find_opt (self : #t) k : _ option = self#find_opt k
let[@inline] find_l (self : #t) ks : _ list = self#find_l ks

(** Find all keys, in the same order, or raise *)
let[@inline] find_l_in_order (self : #t) ks : string option list =
  self#find_l_in_order ks

let pp out (self : #t) = Fmt.fprintf out "<cstore.reader %s>" self#name
let show self = Fmt.to_string pp self
