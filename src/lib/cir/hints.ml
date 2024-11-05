module Induct = struct
  type style =
    | Multiplicative
    | Additive
  [@@deriving show, twine, typereg, enum, eq]

  type method_ =
    | Functional of { f_name: Imandrax_api.Uid.t option }
        (** functional induction *)
    | Structural of {
        style: style;
        vars: string list;
      }  (** structural induction *)
    | Term of {
        t: Term.t;
        vars: Var.t list;
      }
    | Default
  [@@deriving twine, typereg, eq]

  type t = {
    otf: bool;
    method_: method_;
  }
  [@@deriving twine, typereg, eq] [@@typereg.name "Induct.t"]

  let pp_method out = function
    | Default -> Fmt.string out "<default>"
    | Structural { style = Additive; vars } ->
      Format.fprintf out "(@[structural+@ %a@])" Fmt.(list Dump.string) vars
    | Structural { style = Multiplicative; vars } ->
      Format.fprintf out "(@[structural*@ %a@])" Fmt.(list Dump.string) vars
    | Functional { f_name = Some f } ->
      Format.fprintf out "(@[functional %a@])" Imandrax_api.Uid.pp f
    | Functional { f_name = None } -> Format.fprintf out "(@[functional ?@])"
    | Term { t; _ } -> Format.fprintf out "(@[term %a@])" Term.pp t

  let pp out { otf; method_ } =
    Fmt.fprintf out "(@[otf:%b, method:%a@])" otf pp_method method_

  let show = Fmt.to_string pp
end
