(** Sequent *)

type 'term t_poly = {
  hyps: 'term list;  (** Hypotheses *)
  concls: 'term list;  (** Conclusions *)
}
[@@deriving eq, ord, twine, typereg, map, iter]
(** A classical sequent *)

let pp_seq ppt ppf lhs rhs =
  let h_i, c_i = ref 0, ref 0 in
  let next x =
    let i = !x in
    x := !x + 1;
    i
  in
  let f ppf x = ppt ppf x in
  let pp_hyp ppf h = Fmt.fprintf ppf "@[H%d. @[<hov 1>%a@]@]" (next h_i) f h in
  let pp_hyps ppf hs = Fmt.list ~sep:Fmt.(return "@\n") pp_hyp ppf hs in
  let pp_conc ppf c = Fmt.fprintf ppf "@[C%d. @[<hov 1>%a@]@]" (next c_i) f c in
  let pp_concs ppf cs =
    match cs with
    | [] -> Fmt.fprintf ppf "false"
    | [ c ] -> f ppf c
    | cs -> Fmt.list ~sep:Fmt.(return "@\n") pp_conc ppf cs
  in
  Fmt.fprintf ppf
    "@\n\
     @[%a@[<hov \
     1>@[%a@]@]%a@[|----------------------------------------------------------------------@]@\n\
     @[<hov 1> %a@]@]@\n"
    (fun ppf () ->
      if lhs <> [] then
        Fmt.(fprintf ppf "@ ")
      else
        Fmt.(fprintf ppf ""))
    () pp_hyps lhs
    (fun ppf () ->
      if lhs <> [] then
        Fmt.(fprintf ppf "@\n")
      else
        Fmt.(fprintf ppf ""))
    () pp_concs rhs

let pp ppt ppf g = pp_seq ppt ppf g.hyps g.concls
let pp_t_poly ppt out (self : _ t_poly) : unit = pp ppt out self
let show ppt = Fmt.to_string @@ pp_t_poly ppt
