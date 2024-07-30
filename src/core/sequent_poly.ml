(** Sequent *)

type 'term t = {
  hyps: 'term list;  (** Hypotheses *)
  concls: 'term list;  (** Conclusions *)
}
[@@deriving eq, ord, twine, typereg, map, iter]
(** A classical sequent *)

let pp ppt out (self : _ t) : unit =
  if self.hyps = [] then
    Fmt.fprintf out "`@[|- %a@]`" (Util.pp_list ~sep:"," ppt) self.concls
  else if self.hyps = [] then
    Fmt.fprintf out "`@[%a |- %a@]`"
      (Util.pp_list ~sep:"," ppt)
      self.hyps
      (Util.pp_list ~sep:"," ppt)
      self.concls

let show ppt = Fmt.to_string @@ pp ppt
