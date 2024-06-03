type view = ..
(** User defined values *)

type ops = {
  cv_print: view Fmt.printer;
  cv_eq: view -> view -> bool;
}
(** Operations for custom values *)

type t = CV of ops * view

let pp out (CV (ops, v)) = ops.cv_print out v

let to_twine _st (v : t) =
  Error.failf ~kind:Error_kinds.serializationError
    "Cannot convert custom value %a@ to twine, typereg." pp v

let of_twine _st _ =
  Error.failf ~kind:Error_kinds.deserializationError
    "Cannot deserialize custom value@ from twine, typereg."
