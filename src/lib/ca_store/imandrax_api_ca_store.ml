(** Storage based on cryptographic content-addressing.

    This library provides several ways to store data
    in a content-addressed way.

    One way, {!Ca_ptr}, is to serialize the data and hash its serialized
    version (classic content addressing). Another way is to use
    a {!Cname.t} for data that has already been content-addressed
    {i before} serialization — that can be more efficient because we don't
    always need to serialize a value if it's found to be stored already
    based on its cname.
*)

module Ca_codec = Ca_codec
module Ca_ptr = Ca_ptr
module In_memory = In_memory
module Key = Key
module Reader = Reader
module Storage = Storage
module With_lump = With_lump
module Writer = Writer
module Typed_key = Typed_key

class type t = Storage.t

module Private_ = struct
  module Log = Common_cstore_.Log
end
