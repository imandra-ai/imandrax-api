(** A store keyed by cryptographic hashes.

     Here data can be keyed  by {{!Imandrax_util.Cname}Cname} (for defined, name items)
     or by {!Cptr} (for arbitrary content-addressed data) *)

(** Storage with both reader and writer end *)
class type t = object
  inherit Writer.t
  inherit Reader.t
end

class dummy : t =
  object
    inherit Reader.dummy
    inherit! Writer.dummy
  end

let pp out (self : #t) = Fmt.fprintf out "<cstore %s>" self#name
