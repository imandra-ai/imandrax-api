(* ai-disclosure: ai-generated *)

type t = (string * string) list Atomic.t
(** Pairs [name, value], most recently set first. *)

let create () : t = Atomic.make []

(** Parse a [Set-Cookie] value. Attributes ([Path], [HttpOnly], …) are dropped:
    we only ever echo the pair back, and never persist it. *)
let parse_set_cookie (v : string) : (string * string) option =
  let v =
    match String.index_opt v ';' with
    | None -> v
    | Some i -> String.sub v 0 i
  in
  match String.index_opt v '=' with
  | None -> None
  | Some i ->
    let name = String.trim @@ String.sub v 0 i in
    let value = String.trim @@ String.sub v (i + 1) (String.length v - i - 1) in
    if name = "" then
      None
    else
      Some (name, value)

let to_header (self : t) : (string * string) option =
  match Atomic.get self with
  | [] -> None
  | cookies ->
    let s =
      String.concat "; "
      @@ List.rev_map (fun (k, v) -> Printf.sprintf "%s=%s" k v) cookies
    in
    Some ("cookie", s)

let update_from_response (self : t) (headers : (string * string) list) : unit =
  let set =
    List.filter_map
      (fun (k, v) ->
        if String.lowercase_ascii k = "set-cookie" then
          parse_set_cookie v
        else
          None)
      headers
  in
  if set <> [] then (
    (* a cookie already in the jar is replaced, not duplicated *)
    let rec update () =
      let old = Atomic.get self in
      let cookies =
        List.fold_left
          (fun acc (k, v) -> (k, v) :: List.remove_assoc k acc)
          old set
      in
      if not (Atomic.compare_and_set self old cookies) then update ()
    in
    update ()
  )
