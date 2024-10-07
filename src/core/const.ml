type t =
  | Const_float of float
  | Const_string of string
  | Const_z of Util_twine_.Z.t
  | Const_q of Util_twine_.Q.t
  | Const_real_approx of string
  | Const_uid of Uid.t
  | Const_bool of bool
[@@deriving twine, typereg, eq, ord]

let show = function
  | Const_float r -> string_of_float r
  | Const_string s -> Printf.sprintf "%S" s
  | Const_z x -> Z.to_string x
  | Const_q x ->
    if Z.equal x.den Z.one then
      Z.to_string x.num ^ ".0"
    else
      "(" ^ Z.to_string x.num ^ ".0 /. " ^ Z.to_string x.den ^ ".0)"
  | Const_real_approx s -> s
  | Const_uid uid -> Uid.show uid
  | Const_bool b -> string_of_bool b

(* print in Iml *)
let pp out self = Fmt.string out (show self)
