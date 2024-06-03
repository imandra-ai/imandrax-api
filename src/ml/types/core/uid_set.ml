type t =
  (Uid.Set.t
  [@printer
    fun out s ->
      Format.fprintf out "{@[%a@]}" (Util.pp_iter Uid.pp) (Uid.Set.to_iter s)]
  [@twine.encode
    Imandrakit_twine.Encode.(
      fun enc set ->
        array_iter enc (Uid.Set.to_iter set |> Iter.map (Uid.to_twine enc)))]
  [@twine.decode
    Imandrakit_twine.Decode.(
      fun dec c ->
        let c = array dec c in
        Array_cursor.to_iter_of c (Uid.of_twine dec) |> Uid.Set.of_iter)])
[@@deriving twine, typereg, show, eq, ord]

let hash set = CCHash.(iter Uid.hash) (Uid.Set.to_iter set)
