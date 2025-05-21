module Mir = Imandrax_api_mir
module MT = Mir.Term
module MTy = Mir.Type

type 'a offset_for = 'a Imandrakit_twine.offset_for [@@deriving eq, show, twine]
