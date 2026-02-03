(** Sequent *)

type 'term t_poly = {
  hyps: (string option * 'term) list;  (** Hypotheses *)
  concls: (string option * 'term) list;  (** Conclusions *)
}
[@@deriving eq, ord, twine, typereg, map, iter]
(** A classical sequent *)

let[@inline] hypotheses (self : 'term t_poly) : (string option * 'term) list =
  self.hyps

let[@inline] conclusions (self : 'term t_poly) : (string option * 'term) list =
  self.concls

let[@inline] hypothesis_terms (self : 'term t_poly) = List.map snd self.hyps
let[@inline] conclusion_terms (self : 'term t_poly) = List.map snd self.concls

let iter_hypotheses (self : 'term t_poly) : (string option * 'term) Iter.t =
  Iter.of_list self.hyps

let iter_conclusions (self : 'term t_poly) : (string option * 'term) Iter.t =
  Iter.of_list self.concls

let iter_hypothesis_terms (self : 'term t_poly) : 'term Iter.t =
  iter_hypotheses self |> Iter.map snd

let iter_conclusion_terms (self : 'term t_poly) : 'term Iter.t =
  iter_conclusions self |> Iter.map snd

let[@inline] num_named_hypotheses (self : 'term t_poly) : int =
  Iter.of_list self.hyps |> Iter.filter_count (fun (n, _) -> Option.is_some n)

let[@inline] num_named_conclusions (self : 'term t_poly) : int =
  Iter.of_list self.concls |> Iter.filter_count (fun (n, _) -> Option.is_some n)

let[@inline] num_unnamed_hypotheses (self : 'term t_poly) : int =
  Iter.of_list self.hyps |> Iter.filter_count (fun (n, _) -> Option.is_none n)

let[@inline] num_unnamed_conclusions (self : 'term t_poly) : int =
  Iter.of_list self.concls |> Iter.filter_count (fun (n, _) -> Option.is_none n)

let[@inline] has_hypotheses x = not (CCList.is_empty x.hyps)

let nth_hypothesis (self : 'term t_poly) i : string option * 'term =
  List.nth self.hyps i

let nth_conclusion (self : 'term t_poly) i : string option * 'term =
  List.nth self.concls i

let find_term (self : 'term t_poly) (name : string) :
    (string option * 'term) option =
  CCList.find_opt
    (fun (n, _) -> Option.equal String.equal n (Some name))
    self.hyps

let rename (self : 'term t_poly) (old_name : string) (new_name : string) :
    'term t_poly option =
  let found = ref false in
  let aux ((n, t) : string option * 'term) =
    if !found then
      n, t
    else (
      match n with
      | Some n when String.equal n old_name ->
        found := true;
        Some new_name, t
      | _ -> n, t
    )
  in
  let hyps = List.map aux self.hyps in
  let concls =
    if not !found then
      List.map aux self.concls
    else
      self.concls
  in
  if not !found then
    None
  else
    Some { hyps; concls }

let name (self : 'term t_poly) (i : int) (new_name : string) :
    'term t_poly option =
  let found = ref false in
  let aux j ((n, t) : string option * 'term) =
    if !found then
      n, t
    else (
      match n with
      | None when i = j ->
        found := true;
        Some new_name, t
      | _ -> n, t
    )
  in
  let hyps = List.mapi aux self.hyps in
  let concls =
    if not !found then
      List.mapi aux self.concls
    else
      self.concls
  in
  if not !found then
    None
  else
    Some { hyps; concls }

let pp_seq ppt ppf (lhs : (string option * 'term) list)
    (rhs : (string option * 'term) list) =
  let h_i, c_i = ref 0, ref 0 in
  let next x =
    let i = !x in
    x := !x + 1;
    i
  in
  let f ppf x = ppt ppf x in
  let pp_hyp ppf (n, h) =
    match n with
    | Some n ->
      ignore (next h_i);
      Fmt.fprintf ppf "@[%s: @[<hov 1>%a@]@]" n f h
    | None -> Fmt.fprintf ppf "@[H%d. @[<hov 1>%a@]@]" (next h_i) f h
  in
  let pp_hyps ppf hs = Fmt.list ~sep:Fmt.(return "@\n") pp_hyp ppf hs in
  let pp_conc ppf ((n, c) : string option * 'term) =
    match n with
    | Some n ->
      ignore (next c_i);
      Fmt.fprintf ppf "@[%s: @[<hov 1>%a@]@]" n f c
    | None -> Fmt.fprintf ppf "@[C%d. @[<hov 1>%a@]@]" (next c_i) f c
  in
  let pp_concs ppf (cs : (string option * 'term) list) =
    match cs with
    | [] -> Fmt.fprintf ppf "false"
    | [ (n, c) ] ->
      (match n with
      | Some n -> Fmt.fprintf ppf "%s: %a" n f c
      | None -> f ppf c)
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
