(** Rich text *)

type 'term t = 'term item list

(** Rich text *)
and 'term item =
  | S of string
  | B of string
  | I of string
  | Newline
  | Sub of 'term t  (** Insert a rtext inside another *)
  | L of 'term t list  (** List of items *)
  | Uid of Uid.t
  | Term of 'term
  | Sequent of 'term Sequent_poly.t
  | Subst of ('term * 'term) list
[@@deriving twine, typereg, map]

let pp ppt out (t : 't t) : unit =
  let rec loop_item out t =
    match t with
    | S s | B s | I s -> Fmt.string out s
    | Newline -> Fmt.fprintf out "@ "
    | Sub l -> loop out l
    | L l -> Fmt.Dump.list loop out l
    | Uid id -> Uid.pp out id
    | Term t -> ppt out t
    | Sequent seq -> Sequent_poly.pp ppt out seq
    | Subst s -> Fmt.(hovbox @@ Dump.(list (pair ppt ppt))) out s
  and loop out (l : 't t) =
    Fmt.fprintf out "@[<v>%a@]" (Util.pp_list ~sep:"" loop_item) l
  in

  Fmt.fprintf out {|"%a"|} loop t
