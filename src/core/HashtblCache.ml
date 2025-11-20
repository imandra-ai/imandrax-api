module type S = sig
  include CCHashtbl.S

  val cached : 'a t -> (key -> 'a) -> key -> 'a
end

module Make (X : Hashtbl.HashedType) = struct
  include CCHashtbl.Make (X)

  let cached cache f t =
    match find_opt cache t with
    | Some u -> u
    | None ->
      let u = f t in
      add cache t u;
      u
end
