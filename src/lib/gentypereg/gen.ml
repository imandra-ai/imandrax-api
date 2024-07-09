module TR = Imandrakit_typereg
module J = Yojson.Safe

let () =
  let j : J.t =
    `List (TR.to_iter TR.top |> Iter.map TR.Ty_def.to_yojson |> Iter.to_rev_list)
  in
  print_endline @@ J.pretty_to_string j
