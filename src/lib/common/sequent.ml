(** Sequent *)

type 'term t_poly = {
  hyps: 'term list;  (** Hypotheses *)
  concls: 'term list;  (** Conclusions *)
}
[@@deriving eq, ord, twine, typereg, map, iter]
(** A classical sequent *)

let pp_t_poly ppt out (self : _ t_poly) : unit =
  if self.hyps = [] then
    Fmt.fprintf out "`@[|- %a@]`" (Util.pp_list ~sep:"," ppt) self.concls
  else
    Fmt.fprintf out "`@[%a |- %a@]`"
      (Util.pp_list ~sep:"," ppt)
      self.hyps
      (Util.pp_list ~sep:"," ppt)
      self.concls

let show ppt = Fmt.to_string @@ pp_t_poly ppt
