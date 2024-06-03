module type S = sig
  include CCHashtbl.S

  val cached : 'a t -> (key -> 'a) -> key -> 'a
end

module Make (X : Hashtbl.HashedType) = struct
  include CCHashtbl.Make (X)

  let cached cache f t =
    match find cache t with
    | u -> u
    | exception Not_found ->
      let u = f t in
      add cache t u;
      u
end
