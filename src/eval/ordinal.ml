(** Ordinal type. *)
type t =
  | Int of Util_twine_.Z.t
  | Cons of t * Util_twine_.Z.t * t
[@@deriving twine, typereg, eq]

let pp out (self : t) : unit =
  let pp_coeff out x =
    if not (Z.equal Z.one x) then Format.fprintf out "%a@<1>·" Z.pp_print x
  in
  let rec pp out = function
    | Int x -> Z.pp_print out x
    | Cons (a, x, tl) ->
      Format.fprintf out "%a@<1>ω%a%a" pp_coeff x pp_power a pp_tail tl
  and pp_tail out = function
    | Int n when Z.equal Z.zero n -> ()
    | x -> Format.fprintf out "@ + %a" pp x
  and pp_power out = function
    | Int n when Z.equal Z.one n -> ()
    | x -> Format.fprintf out "^%a" pp_inner x
  and pp_inner out x =
    match x with
    | Int _ -> pp out x
    | Cons _ -> Format.fprintf out "(@[%a@])" pp x
  in
  pp out self

let show = Fmt.to_string pp
