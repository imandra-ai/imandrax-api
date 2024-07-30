open Common_
module J = Yojson.Safe

let get_arts () : Artifact.t list =
  let l = J.from_string Data_.artifacts |> J.Util.to_list in
  let get_art j =
    let l = J.Util.to_assoc j in
    let tag = List.assoc "tag" l |> J.Util.to_string in
    let ty =
      let c = List.assoc "ty" l |> J.Util.to_string in
      TR.Ty_expr.Cstor (c, [])
    in
    { Artifact.tag; ty }
  in
  List.map get_art l
