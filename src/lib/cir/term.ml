(** Surface terms.

    These terms use content-addressed names for functions, constructors, etc.
    They're also serializable (using cbor-pack). *)

type ('t, 'ty) binding = 'ty Var.t_poly * 't
[@@deriving map, iter, eq, twine, typereg, show]
(** simple variable binding *)

type ('t, 'ty) view =
  | Const of Imandrax_api.Const.t
  | If of 't * 't * 't
  | Let of {
      flg: Imandrax_api.Misc_types.rec_flag;
      bs: ('t, 'ty) binding list;
      body: 't;
    }
  | Apply of {
      f: 't;
      l: 't list;
    }
  | Fun of {
      v: 'ty Var.t_poly;
      body: 't; (* type of function, var, body *)
    }
  | Var of 'ty Var.t_poly
  | Sym of 'ty Applied_symbol.t_poly
  | Construct of {
      c: 'ty Applied_symbol.t_poly;
      args: 't list;
      labels: Imandrax_api.Uid.t list option;
    }
  | Destruct of {
      c: 'ty Applied_symbol.t_poly;
      i: int;
      t: 't;
    }
  | Is_a of {
      c: 'ty Applied_symbol.t_poly;
      t: 't;
    }
  | Tuple of { l: 't list }
  | Field of {
      f: 'ty Applied_symbol.t_poly;
      t: 't;
    }
  | Tuple_field of {
      i: int;
      t: 't;
    }
  | Record of {
      rows: ('ty Applied_symbol.t_poly * 't) list;
      rest: 't option;
    }
  | Case of {
      u: 't;
      cases: ('t, 'ty Var.t_poly, 'ty Applied_symbol.t_poly) Case.t_poly list;
      default: 't option;
    }
  | Let_tuple of {
      vars: 'ty Var.t_poly list;
      rhs: 't;
      body: 't;
    }
  | With_subanchor of 't * Imandrax_api.Sub_anchor.t
[@@deriving map, iter, eq, twine, typereg, show { with_path = false }]

type t = {
  view: (t, Type.t) view;
  ty: Type.t;
}
[@@deriving twine, typereg, show { with_path = false }]

let pp_ = ref pp
let pp_view_ = ref pp_view
let pp out x = !pp_ out x
let pp_view out v = !pp_view_ pp Type.pp out v
let show = Fmt.to_string pp

type term = t [@@deriving twine, typereg, show]

open Imandrax_api

let () =
  (* we can cache on the decoding end, but during encoding
     it would amount to full on-the-fly hashconsing of
     values because we have no explicit sharing of [Term.t]. *)
  Imandrakit_twine.Decode.add_cache of_twine_ref

let[@inline] view (self : t) : (t, Type.t) view = self.view

(** Syntactic equality on terms. This is not modulo alpha. *)
let rec equal (t1 : t) (t2 : t) =
  if t1 == t2 then
    true
  else (
    match t1.view, t2.view with
    | Var v1, Var v2 -> Var.equal v1 v2
    | Sym s1, Sym s2 -> Applied_symbol.equal s1 s2
    | Const c1, Const c2 -> Const.equal c1 c2
    | If (a1, b1, c1), If (a2, b2, c2) ->
      equal a1 a2 && equal b1 b2 && equal c1 c2
    | ( Let { flg = rec1; bs = bs1; body = body1; _ },
        Let { flg = rec2; bs = bs2; body = body2; _ } ) ->
      rec1 = rec2
      && CCList.equal (CCPair.equal Var.equal equal) bs1 bs2
      && equal body1 body2
    | Apply { f = f1; l = args1 }, Apply { f = f2; l = args2 } ->
      equal f1 f2 && CCList.equal equal args1 args2
    | Fun { v = v1; body = body1 }, Fun { v = v2; body = body2 } ->
      Var.equal v1 v2 && equal body1 body2
    | Construct r1, Construct r2 ->
      Applied_symbol.equal r1.c r2.c && CCList.equal equal r1.args r2.args
    | Destruct r1, Destruct r2 ->
      Applied_symbol.equal r1.c r2.c && r1.i = r2.i && equal r1.t r2.t
    | Is_a r1, Is_a r2 -> Applied_symbol.equal r1.c r2.c && equal r1.t r2.t
    | Tuple { l = args1 }, Tuple { l = args2 } -> CCList.equal equal args1 args2
    | Field r1, Field r2 -> Applied_symbol.equal r1.f r2.f && equal r1.t r2.t
    | Tuple_field r1, Tuple_field r2 -> r1.i = r2.i && equal r1.t r2.t
    | Record r1, Record r2 ->
      Type.equal t1.ty t2.ty
      && CCList.equal (CCPair.equal Applied_symbol.equal equal) r1.rows r2.rows
      && CCOption.equal equal r1.rest r2.rest
    | Case c1, Case c2 ->
      equal c1.u c2.u
      && CCOption.equal equal c1.default c2.default
      && CCList.equal
           (fun (c1 : _ Case.t) (c2 : _ Case.t) ->
             Applied_symbol.equal c1.case_cstor c2.case_cstor
             && CCList.equal Var.equal c1.case_vars c2.case_vars
             && equal c1.case_rhs c2.case_rhs)
           c1.cases c2.cases
    | Let_tuple c1, Let_tuple c2 ->
      equal c1.rhs c2.rhs
      && CCList.equal Var.equal c1.vars c2.vars
      && equal c1.body c2.body
    | With_subanchor (t1, a1), With_subanchor (t2, a2) ->
      equal t1 t2 && Sub_anchor.equal a1 a2
    | ( ( Var _ | Sym _ | Const _ | If _ | Let _ | Let_tuple _ | Apply _ | Fun _
        | Construct _ | Destruct _ | Is_a _ | Tuple _ | Field _ | Tuple_field _
        | Record _ | Case _ | With_subanchor _ ),
        _ ) ->
      false
  )
