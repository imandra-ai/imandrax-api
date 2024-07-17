module Induct = struct
  type style =
    | Multiplicative
    | Additive
  [@@deriving show, twine, typereg, enum, eq]

  type t =
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
  [@@deriving twine, typereg, eq] [@@typereg.name "Induct.t"]

  let pp out = function
    | Default -> Fmt.string out "<default>"
    | Structural { style = Additive; vars } ->
      Format.fprintf out "(@[structural+@ %a@])" Fmt.(list Dump.string) vars
    | Structural { style = Multiplicative; vars } ->
      Format.fprintf out "(@[structural*@ %a@])" Fmt.(list Dump.string) vars
    | Functional { f_name = Some f } ->
      Format.fprintf out "(@[functional %a@])" Imandrax_api.Uid.pp f
    | Functional { f_name = None } -> Format.fprintf out "(@[functional ?@])"
    | Term { t; _ } -> Format.fprintf out "(@[term %a@])" Term.pp t

  let show = Fmt.to_string pp
end

module Method = struct
  type t =
    | Unroll of { steps: int option }
    | Ext_solver of { name: string }
    | Auto
    | Induct of Induct.t
  [@@deriving twine, typereg, eq] [@@typereg.name "Method.t"]

  let pp out = function
    | Unroll { steps = None } -> Format.fprintf out "unroll"
    | Unroll { steps = Some i } -> Format.fprintf out "(unroll %d)" i
    | Auto -> Fmt.string out "auto"
    | Induct i -> Format.fprintf out "(@[induct@ %a@])" Induct.pp i
    | Ext_solver { name } -> Fmt.fprintf out "(ext-solver %S)" name

  let show = Fmt.to_string pp
end

(* define a sub-module for easier inclusion *)
module Top = struct
  type +'f t = {
    basis: Imandrax_api.Uid_set.t;
    method_: Method.t;
    apply_hint: 'f list;
    logic_config_ops: Logic_config.op list;
    otf: bool;
  }
  [@@deriving twine, typereg, map, eq] [@@typereg.name "t"]
  (** A hint *)

  open Imandrax_api

  let pp pp_f out (h : 'f t) : unit =
    let pp_basis out b =
      if Uid.Set.is_empty b then
        ()
      else
        Fmt.fprintf out "@ :basis {@[%a@]}" (Fmt.list Uid.pp)
          (Uid.Set.to_list b)
    and pp_apply out = function
      | [] -> ()
      | [ f ] -> Fmt.fprintf out "@ :apply %a" pp_f f
      | fs -> Fmt.fprintf out "@ :apply [@[%a@]]" (Fmt.list pp_f) fs
    in
    Format.fprintf out "(@[hints@ :method %a%a%a@])" Method.pp h.method_
      pp_basis h.basis pp_apply h.apply_hint

  let show pp_f = Fmt.to_string (pp pp_f)
end
