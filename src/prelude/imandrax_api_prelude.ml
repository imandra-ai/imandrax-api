(* extracted by imandrax-extract from "src/prelude/prelude.iml" *)

module Program_prelude_ =
  struct
    module Int =
      struct
        type t = int[@@deriving (to_iml, of_mir)]
        include Stdlib
        let of_int i = i
      end
    module List =
      struct
        type 'a t = 'a list =
          | [] 
          | (::) of 'a * 'a t [@@deriving (to_iml, of_mir)]
      end
    module String =
      struct
        include String
        let prefix pre s = CCString.prefix ~pre s
        let suffix a b = CCString.suffix ~suf:a b
        let contains a sub = CCString.mem ~sub a
        let unsafe_to_nat s =
          try
            let n = Z.of_string s in if Z.lt n Z.zero then Z.minus_one else n
          with | _ -> Z.minus_one
      end
    let implies x y = (not x) || y[@@inline ]
  end[@@program ]
[@@@ocaml.text " {2 Bare minimum needed for ordinals and validation} "]
type int = Z.t[@@deriving (to_iml, of_mir)][@@builtin.logic_core "mk_s_int"]
[@@ocaml.doc
  " Builtin integer type, using arbitrary precision integers.\n\n    This type is an alias to {!Z.t}\n    (using {{: https://github.com/ocaml/Zarith} Zarith}).\n\n    {b NOTE}: here Imandra diverges from normal OCaml, where integers width\n    is bounded by native machine integers.\n    \"Normal\" OCaml integers have type {!Caml.Int.t} and can be entered\n    using the 'i' suffix: [0i]\n"]
type nonrec bool = bool[@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                      "mk_s_bool"][@@ocaml.doc
                                                                    " Builtin boolean type. "]
(* skip *)
(* skip *)
type nonrec unit = unit =
  | () [@@deriving (to_iml, of_mir)][@@builtin.special "ty.unit"][@@noalias ]
let (=) : 'a -> 'a -> bool = Stdlib.(=)[@@ocaml.doc
                                         " Equality. Must be applied to non-function types. "]
  [@@builtin.logic_core "mk_eq"]
let (<>) : 'a -> 'a -> bool = Stdlib.(<>)[@@builtin.logic_core "mk_neq"]
let not : bool -> bool = let open Stdlib in not[@@builtin.logic_core
                                                 "mk_not"]
let implies : bool -> bool -> bool = Program_prelude_.implies[@@builtin.logic_core
                                                               "mk_implies"]
let explies x y = implies y x[@@macro ]
let iff : bool -> bool -> bool = Stdlib.(=)[@@builtin.logic_core "mk_iff"]
let (+) : int -> int -> int = Z.(+)[@@builtin.logic_core "mk_i_add"]
let const x _ = x[@@ocaml.doc
                   " [const x y] returns [x]. In other words, [const x] is\n    the constant function that always returns [x]. "]
  [@@builtin.special "fn.const"][@@macro ]
let (>=) : int -> int -> bool = Stdlib.(>=)[@@builtin.logic_core "mk_i_ge"]
let mk_nat (x : int) : int=
  if x >= (Z.of_nativeint 0n) then x else Z.of_nativeint 0n[@@macro ]
  [@@builtin.special "fn.mk_nat"]
type nonrec 'a option = 'a option =
  | None 
  | Some of 'a [@@deriving (to_iml, of_mir)][@@builtin.special "ty.option"]
[@@noalias ]
type 'a list = 'a Program_prelude_.List.t =
  | [] 
  | (::) of 'a * 'a list [@@deriving (to_iml, of_mir)][@@builtin.special
                                                        "ty.list"][@@noalias
                                                                    ]
type nonrec float = float[@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                        "mk_s_float"]
type nonrec real = Q.t[@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                     "mk_s_real"]
type nonrec string = string[@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                          "mk_s_str"]
let (<) : int -> int -> bool = (<)[@@builtin.logic_core "mk_i_lt"]
let (<=) : int -> int -> bool = (<=)[@@builtin.logic_core "mk_i_le"]
let (>) : int -> int -> bool = (>)[@@builtin.logic_core "mk_i_gt"]
let min : int -> int -> int = min[@@builtin.logic_core "mk_i_min"]
let max : int -> int -> int = max[@@builtin.logic_core "mk_i_max"]
let (<.) : real -> real -> bool = Q.lt[@@builtin.logic_core "mk_r_lt"]
let (<=.) : real -> real -> bool = Q.leq[@@builtin.logic_core "mk_r_le"]
let (>.) : real -> real -> bool = Q.gt[@@builtin.logic_core "mk_r_gt"]
let (>=.) : real -> real -> bool = Q.geq[@@builtin.logic_core "mk_r_ge"]
let min_r : real -> real -> real = Q.min[@@builtin.logic_core "mk_r_min"]
let max_r : real -> real -> real = Q.max[@@builtin.logic_core "mk_r_max"]
let (~-) : int -> int = Z.(~-)[@@builtin.logic_core "mk_i_usub"]
let abs (x : int) : int= if x >= (Z.of_nativeint 0n) then x else - x[@@macro
                                                                    ]
let (-) : int -> int -> int = Z.(-)[@@builtin.logic_core "mk_i_sub"]
let (~+) (x : int) : int= x[@@macro ]
let ( * ) : int -> int -> int = Z.( * )[@@builtin.logic_core "mk_i_mul"]
let (/) : int -> int -> int = Z.ediv[@@ocaml.doc
                                      " Euclidian division on integers,\n    see {{: http://smtlib.cs.uiowa.edu/theories-Ints.shtml} http://smtlib.cs.uiowa.edu/theories-Ints.shtml} "]
  [@@builtin.logic_core "mk_i_div"]
let \#mod : int -> int -> int = Z.erem[@@ocaml.doc
                                        " Euclidian remainder on integers "]
  [@@builtin.logic_core "mk_mod"]
let compare (x : int) (y : int) : int=
  if x = y
  then Z.of_nativeint 0n
  else if x < y then Z.of_nativeint (-1n) else Z.of_nativeint 1n[@@ocaml.doc
                                                                  " Total order "]
type ('a, 'b) result = ('a, 'b) Stdlib.result =
  | Ok of 'a 
  | Error of 'b [@@deriving (to_iml, of_mir)][@@ocaml.doc
                                               " Result type, representing either a successul result [Ok x]\n    or an error [Error x]. "]
[@@noalias ][@@builtin.special "ty.result"]
(* skip *)
[@@@ocaml.text " {2 Ordinals} "]
module Ordinal =
  struct
    type t =
      | Int of int 
      | Cons of t * int * t
      [@ocaml.doc
        " [cons a x tl] is [x\194\183(\207\137^a) + tl], where [tl < \207\137\194\183a], [a\226\137\1600], [x\226\137\1600] "]
    [@@deriving (to_iml, of_mir)][@@ocaml.doc
                                   " Ordinals, up to \206\181\226\130\128, in Cantor Normal Form "]
    [@@builtin.special "ty.ordinal"][@@no_validate ]
    let pp out (x : t) : unit=
      let pp_coeff out x =
        if Z.equal Z.one x
        then ()
        else Format.fprintf out "%a@<1>\194\183" Z.pp_print x in
      let rec pp out =
        function
        | Int x -> Z.pp_print out x
        | Cons (a, x, tl) ->
            Format.fprintf out "%a@<1>\207\137%a%a" pp_coeff x pp_power a
              pp_tail tl
      and pp_tail out =
        function
        | Int n when Z.equal Z.zero n -> ()
        | x -> Format.fprintf out "@ + %a" pp x
      and pp_power out =
        function
        | Int n when Z.equal Z.one n -> ()
        | x -> Format.fprintf out "^%a" pp_inner x
      and pp_inner out x =
        match x with
        | Int _ -> pp out x
        | Cons _ -> Format.fprintf out "(@[%a@])" pp x in
      Format.fprintf out "@[%a@]" pp x[@@program ]
    let of_int_unsafe (x : int) : t= Int x[@@builtin.special
                                            "ordinal.of_int"][@@no_validate ]
      [@@macro ]
    let zero = Int (Z.of_nativeint 0n)[@@macro ]
    let one = Int (Z.of_nativeint 1n)[@@macro ]
    let two = Int (Z.of_nativeint 2n)[@@macro ]
    let of_int (x : int) : t= of_int_unsafe (mk_nat x)[@@macro ]
    let rec (<<) (x : t) (y : t) : bool=
      match (x, y) with
      | (Int x, Int y) -> x < y
      | (Int _, Cons _) -> true
      | (Cons _, Int _) -> false
      | (Cons (a1, x1, tl1), Cons (a2, x2, tl2)) ->
          (a1 << a2) ||
            ((a1 = a2) && ((x1 < x2) || ((x1 = x2) && (tl1 << tl2))))
      [@@ocaml.doc
        " special axiom: the original well founded relation we use\n      for proving all the other functions terminating. "]
      [@@builtin.special "ordinal.cmp"][@@no_validate ][@@adm (x, y)]
    let rec plus (x : t) (y : t) : t=
      match (x, y) with
      | (Int x, Int y) -> Int (x + y)
      | (Int _, Cons _) -> y
      | (Cons (a, x, tl), Int _) -> Cons (a, x, (plus tl y))
      | (Cons (a1, x1, tl1), Cons (a2, x2, tl2)) ->
          if a1 << a2
          then y
          else
            if a1 = a2
            then Cons (a1, (x1 + x2), tl2)
            else Cons (a1, x1, (plus tl1 y))[@@ocaml.doc
                                              " Addition of ordinals. Not commutative. "]
      [@@builtin.special "ordinal.plus"][@@no_validate ][@@adm (x, y)]
    let rec shift (x : t) (n : t) : t=
      if (n = (Int (Z.of_nativeint 0n))) || (x = (Int (Z.of_nativeint 0n)))
      then x
      else
        (match x with
         | Int x -> Cons (n, x, zero)
         | Cons (a, x, tl) -> Cons ((plus a n), x, (shift tl n)))[@@builtin.special
                                                                   "ordinal.shift"]
      [@@no_validate ][@@adm x]
    let pair (x : t) (y : t) : t=
      match x with
      | Int x -> Cons (one, (x + (Z.of_nativeint 1n)), y)
      | Cons (a, x, _tl) -> Cons ((plus a one), x, y)
    let triple x y z = pair x (pair y z)
    let quad x y z w = pair x (triple y z w)
    let simple_plus (x : t) (y : t) : t=
      match (x, y) with
      | (Int a, Int b) -> Int (a + b)
      | _ -> Int (Z.of_nativeint 0n)
    let rec of_list_rec (acc : t) (l : t list) : t=
      match l with
      | [] -> acc
      | x::tail -> of_list_rec (plus (shift acc one) x) tail[@@adm l]
      [@@no_validate ]
    let of_list (l : t list) : t=
      match l with
      | [] -> zero
      | x::[] -> x
      | x::y::[] -> plus (shift one x) y
      | x::y::z::[] -> plus (shift two x) (plus (shift one y) z)
      | x::y::z::tl ->
          of_list_rec (plus (shift two x) (plus (shift one y) z)) tl[@@builtin.special
                                                                    "ordinal.of_list"]
    let rec is_valid_rec (x : t) : bool=
      match x with
      | Int x -> x >= (Z.of_nativeint 0n)
      | Cons (a, x, tl) ->
          (is_valid_rec a) &&
            ((a <> zero) &&
               ((x > (Z.of_nativeint 0n)) &&
                  ((is_valid_rec tl) &&
                     ((match tl with
                       | Cons (b, _, _) -> b << a
                       | Int _ -> true)))))[@@ocaml.doc
                                             " Is this a valid ordinal? "]
      [@@no_validate ][@@adm x]
    let is_valid (x : t) : bool=
      match x with | Int x -> x >= (Z.of_nativeint 0n) | o -> is_valid_rec o
      [@@ocaml.doc " Is this a valid ordinal? "][@@builtin.special
                                                  "ordinal.is_valid"]
    let (+) = plus[@@macro ]
    let (~$) = of_int[@@macro ]
    let omega = of_list [one; zero]
    let omega_omega = shift omega omega
  end[@@ocaml.doc
       " We need to define ordinals before any recursive function is defined,\n    because ordinals are used for termination proofs.\n"]
module Peano_nat =
  struct
    type t =
      | Z 
      | S of t [@@deriving (to_iml, of_mir)][@@builtin.special
                                              "ty.peano.nat"]
    let zero = Z[@@builtin.special "fn.peano.zero"][@@macro ]
    let succ x = S x[@@builtin.special "fn.peano.succ"][@@macro ]
    let rec of_int i : t=
      if i <= (Z.of_nativeint 0n)
      then Z
      else S (of_int (i - (Z.of_nativeint 1n)))[@@ocaml.doc
                                                 " Turn this integer into a natural number. Negative integers map to zero. "]
      [@@builtin.special "fn.peano.of_int"]
    let rec to_int x : int=
      match x with
      | Z -> Z.of_nativeint 0n
      | S y -> (Z.of_nativeint 1n) + (to_int y)[@@ocaml.doc
                                                 " Turn this natural number into a native integer. "]
    let rec plus x y = match x with | Z -> y | S x' -> S (plus x' y)[@@ocaml.doc
                                                                    " Peano addition "]
      [@@builtin.special "fn.peano.plus"]
    let rec leq x y =
      match (x, y) with
      | (Z, _) -> true
      | (_, Z) -> false
      | (S x', S y') -> leq x' y'[@@ocaml.doc " Comparison "][@@builtin.special
                                                               "fn.peano.leq"]
    let (=) : t -> t -> bool = (=)[@@macro ]
    let (<=) : t -> t -> bool = leq[@@macro ]
    let (+) : t -> t -> t = plus[@@macro ]
  end[@@ocaml.doc " {2 Natural numbers} "]
[@@@ocaml.text " {2 Other builtin types} "]
module Result =
  struct
    type ('a, 'b) t = ('a, 'b) result[@@deriving (to_iml, of_mir)]
    let return x = Ok x[@@macro ]
    let fail s = Error s[@@macro ]
    let map f e = match e with | Ok x -> Ok (f x) | Error s -> Error s
      [@@macro ]
    let map_err f e = match e with | Ok x -> Ok x | Error y -> Error (f y)
      [@@macro ]
    let get_or ~default e = match e with | Ok x -> x | Error _ -> default
      [@@macro ]
    let map_or ~default f e = match e with | Ok x -> f x | Error _ -> default
      [@@macro ]
    let (>|=) e f = map f e[@@macro ]
    let flat_map f e = match e with | Ok x -> f x | Error s -> Error s
      [@@macro ]
    let (>>=) e f = flat_map f e[@@macro ]
    let fold ok error x = match x with | Ok x -> ok x | Error s -> error s
      [@@macro ]
    let is_ok = function | Ok _ -> true | Error _ -> false[@@macro ]
    let is_error = function | Ok _ -> false | Error _ -> true[@@macro ]
    let monoid_product a b =
      match (a, b) with
      | (Ok x, Ok y) -> Ok (x, y)
      | (Error e, _) -> Error e
      | (_, Error e) -> Error e[@@macro ]
    let (let+) = (>|=)[@@macro ]
    let (and+) = monoid_product[@@macro ]
    let ( let* ) = (>>=)[@@macro ]
    let ( and* ) = monoid_product[@@macro ]
  end
type ('a, 'b) either =
  | Left of 'a 
  | Right of 'b [@@deriving (to_iml, of_mir)][@@ocaml.doc
                                               " A familiar type for Haskellers "]
let (|>) x f = f x[@@ocaml.doc
                    " Pipeline operator.\n\n    [x |> f] is the same as [f x], but it composes nicely:\n    [ x |> f |> g |> h] can be more readable than [h(g(f x))].\n"]
  [@@builtin.special "fn.revapply"][@@macro ]
let (@@) f x = f x[@@ocaml.doc
                    " Right-associative application operator.\n\n    [f @@ x] is the same as [f x], but it binds to the right:\n    [f @@ g @@ h @@ x] is the same as [f (g (h x))] but with fewer parentheses.\n"]
  [@@builtin.special "fn.atapply"][@@macro ]
let id x = x[@@ocaml.doc " Identity function. [id x = x] always holds. "]
  [@@builtin.special "fn.id"][@@macro ]
let (%>) f g x = g (f x)[@@ocaml.doc
                          " Mathematical composition operator.\n\n    [f %> g] is [fun x -> g (f x)] "]
  [@@macro ]
let (==) = Stdlib.(==)[@@program ]
let (!=) = Stdlib.(!=)[@@program ]
let (+.) : real -> real -> real = Q.(+)[@@builtin.logic_core "mk_r_add"]
let (-.) : real -> real -> real = Q.(-)[@@builtin.logic_core "mk_r_sub"]
let (~-.) : real -> real = Q.neg[@@builtin.logic_core "mk_r_usub"]
let ( *. ) : real -> real -> real = Q.( * )[@@builtin.logic_core "mk_r_mul"]
let (/.) : real -> real -> real = Q.(/)[@@builtin.logic_core "mk_r_div"]
module List =
  struct
    type 'a t = 'a list[@@deriving (to_iml, of_mir)]
    let empty = [][@@macro ]
    let is_empty = function | [] -> true | _::_ -> false[@@ocaml.doc
                                                          " Test whether a list is empty "]
    let cons x y = x :: y[@@ocaml.doc
                           " [cons x l] prepends [x] to the beginning of [l], returning a new list "]
      [@@macro ]
    let return x = [x][@@ocaml.doc " Singleton list "][@@macro ]
    let hd : 'a list -> 'a = List.hd[@@ocaml.doc
                                      " Partial function to access the head of the list.\n      This function will fail when applied to the empty list.\n      {b NOTE} it is recommended to rely on pattern matching instead "]
      [@@builtin.logic_core "mk_list_hd"]
    let tl : 'a list -> 'a list = List.tl[@@ocaml.doc
                                           " Partial function to access the tail of the list.\n      This function will fail when applied to the empty list\n      {b NOTE} it is recommended to rely on pattern matching instead "]
      [@@builtin.logic_core "mk_list_tl"]
    let head_opt l = match l with | [] -> None | x::_ -> Some x
    let rec append l1 l2 =
      match l1 with | [] -> l2 | x::l1' -> x :: (append l1' l2)[@@ocaml.doc
                                                                 " List append / concatenation. [append l1 l2] returns a list\n      composed of all elements of [l1], followed by all elements of [l2] "]
      [@@adm l1]
    let append_to_nil x = (append x []) = x[@@imandra_theorem ][@@by
                                                                 induct
                                                                   ~on_vars:
                                                                   ["x"] ()]
      [@@rw ]
    let append_single x y z = (append (append y [x]) z) = (append y (x :: z))
      [@@imandra_theorem ][@@by induct ~on_vars:["y"] ()][@@rw ]
    let rec rev l = match l with | [] -> [] | x::l' -> append (rev l') [x]
      [@@ocaml.doc " Reverse a list "][@@adm l]
    let rec length l =
      match l with
      | [] -> Z.of_nativeint 0n
      | _::l2 -> (Z.of_nativeint 1n) + (length l2)[@@ocaml.doc
                                                    " Compute the length of a list. Linear time. "]
      [@@adm l]
    let len_nonnegative l = ((length l)[@trigger ]) >= (Z.of_nativeint 0n)
      [@@ocaml.doc
        " Length of a list is non-negative. This useful theorem is installed\n      as a forward-chaining rule. "]
      [@@imandra_theorem ][@@fc ][@@by induct ~on_vars:["l"] ()]
    let len_zero_is_empty x = ((length x) = (Z.of_nativeint 0n)) = (x = [])
      [@@ocaml.doc
        " A list has length zero iff it is empty.\n      This is a useful rewrite rule for obtaining empty lists. "]
      [@@imandra_theorem ][@@rewrite ][@@by induct ~on_vars:["x"] ()]
    let len_append x y = (length (append x y)) = ((length x) + (length y))
      [@@ocaml.doc
        " The length of (x @ y) is the sum of the lengths of x and y "]
      [@@imandra_theorem ][@@by auto][@@rw ]
    let rec split l =
      match l with
      | [] -> ([], [])
      | (x, y)::tail ->
          let (tail1, tail2) = split tail in ((x :: tail1), (y :: tail2))
      [@@ocaml.doc " Split a list of pairs into a pair of lists "][@@adm l]
    let rec map f l = match l with | [] -> [] | x::l2 -> (f x) :: (map f l2)
      [@@ocaml.doc
        " Map a function over a list.\n\n      - [map f [] = []]\n      - [map f [x] = [f x]]\n      - [map f (x :: tail) = f x :: map f tail]\n  "]
      [@@adm l]
    let rec map2 f l1 l2 =
      let open Result in
        match (l1, l2) with
        | ([], []) -> Ok []
        | (x::l1, y::l2) -> (map2 f l1 l2) >|= (cons (f x y))
        | (_, _) -> Error "map2: Lengths of l1 and l2 don't match"[@@adm
                                                                    (l1, l2)]
    let rec for_all (f : 'a -> bool) (l : 'a list) =
      match l with | [] -> true | x::l2 -> (f x) && (for_all f l2)[@@ocaml.doc
                                                                    " [for_all f l] tests whether all elements of [l] satisfy the predicate [f] "]
      [@@adm l]
    let rec exists (f : 'a -> bool) (l : 'a list) =
      match l with | [] -> false | x::l2 -> (f x) || (exists f l2)[@@ocaml.doc
                                                                    " [exists f l] tests whether there is an element of [l]\n      that satisfies the predicate [f] "]
      [@@adm l]
    let rec fold_left f acc =
      function | [] -> acc | x::tail -> fold_left f (f acc x) tail[@@ocaml.doc
                                                                    " Fold-left, with an accumulator that makes induction more challenging "]
    let rec fold_right f l acc =
      match l with
      | [] -> acc
      | x::tail -> let acc = fold_right f tail acc in f x acc[@@ocaml.doc
                                                               " Fold-right, without accumulator. This is generally more friendly for\n      induction than [fold_left]. "]
    let mapi f l =
      let rec loop i l =
        match l with
        | [] -> []
        | x::l2 -> let y = f i x in y :: (loop (i + (Z.of_nativeint 1n)) l2) in
      loop (Z.of_nativeint 0n) l
    let rec filter f =
      function
      | [] -> []
      | x::tail ->
          let tail = filter f tail in if f x then x :: tail else tail
      [@@ocaml.doc
        " [filter f l] keeps only the elements of [l] that satisfy [f]. "]
    let rec filter_map f =
      function
      | [] -> []
      | x::tail ->
          let tail = filter_map f tail in
          (match f x with | None -> tail | Some y -> y :: tail)
    let rec flat_map f =
      function | [] -> [] | x::tail -> append (f x) (flat_map f tail)
    let rec find f l =
      match l with | [] -> None | x::tl -> if f x then Some x else find f tl
      [@@ocaml.doc
        " [find f l] returns [Some x] if [x] is the first element of\n      [l] such that [f x] is true. Otherwise it returns [None] "]
    let rec mem x =
      function | [] -> false | y::tail -> (x = y) || (mem x tail)[@@ocaml.doc
                                                                   " [mem x l] returns [true] iff [x] is an element of [l] "]
      [@@builtin.special "list.mem"]
    let rec mem_assoc x =
      function | [] -> false | (k, _)::tail -> (x = k) || (mem_assoc x tail)
    let rec nth n =
      function
      | [] -> None
      | y::tail ->
          if n = (Z.of_nativeint 0n)
          then Some y
          else nth (n - (Z.of_nativeint 1n)) tail[@@adm 1n]
    let rec assoc x =
      function
      | [] -> None
      | (k, v)::tail -> if x = k then Some v else assoc x tail
    let rec bounded_recons n l =
      if n <= (Z.of_nativeint 0n)
      then []
      else
        (match l with
         | [] -> []
         | hd::tl -> hd :: (bounded_recons (n - (Z.of_nativeint 1n)) tl))
      [@@ocaml.doc
        " Like [take n l], but measured subset is [n] instead of [l]. "]
      [@@adm n]
    let rec take n =
      function
      | [] -> []
      | _ when n <= (Z.of_nativeint 0n) -> []
      | x::tl -> x :: (take (n - (Z.of_nativeint 1n)) tl)[@@ocaml.doc
                                                           " [take n l] returns a list composed of the first (at most) [n] elements\n      of [l]. If [length l <= n] then it returns [l] "]
      [@@adm 1n]
    let rec drop n =
      function
      | [] -> []
      | l when n <= (Z.of_nativeint 0n) -> l
      | _::tl -> drop (n - (Z.of_nativeint 1n)) tl[@@ocaml.doc
                                                    " [drop n l] returns [l] where the first (at most) [n] elements\n      have been removed. If [length l <= n] then it returns [[]] "]
      [@@adm 0n]
    let rec range i j =
      if i >= j then [] else i :: (range (i + (Z.of_nativeint 1n)) j)
      [@@ocaml.doc
        " Integer range. [i -- j] is the list [[i; i+1; i+2; \226\128\166; j-1]].\n      Returns the empty list if [i >= j]. "]
      [@@measure Ordinal.of_int (j - i)]
    let (--) = range[@@macro ]
    let rec insert_sorted ~leq x l =
      match l with
      | [] -> [x]
      | y::_ when leq x y -> x :: l
      | y::tail -> y :: (insert_sorted ~leq x tail)[@@ocaml.doc
                                                     " Insert [x] in [l], keeping [l] sorted. "]
      [@@adm l]
    let sort ~leq l : _ list=
      fold_right (fun x acc -> insert_sorted ~leq x acc) l [][@@ocaml.doc
                                                               " Basic sorting function "]
    let rec is_sorted ~leq =
      function
      | [] | _::[] -> true
      | x::(y::_ as tail) -> (leq x y) && (is_sorted ~leq tail)[@@ocaml.doc
                                                                 " Check whether a list is sorted, using the [leq] less-than-or-equal predicate "]
    let monoid_product l1 l2 =
      flat_map (fun x -> map (fun y -> (x, y)) l2) l1
    let (>|=) o f = map f o[@@macro ]
    let (>>=) o f = flat_map f o[@@macro ]
    let (let+) = (>|=)[@@macro ]
    let (and+) = monoid_product[@@macro ]
    let ( let* ) = (>>=)[@@macro ]
    let ( and* ) = monoid_product[@@macro ]
  end[@@ocaml.doc
       " {2 List module}\n\n    This module contains many safe functions for manipulating lists.\n"]
let (@) = List.append[@@ocaml.doc " Infix alias to {!List.append} "][@@macro
                                                                    ]
let (--) = List.(--)[@@ocaml.doc " Alias to {!List.(--)} "][@@macro ]
module Int =
  struct
    type t = int[@@deriving (to_iml, of_mir)]
    let (+) = (+)[@@macro ]
    let (-) = (-)[@@macro ]
    let (~-) = (~-)[@@macro ]
    let ( * ) = ( * )[@@macro ]
    let (/) = (/)[@@macro ]
    let \#mod = \#mod[@@macro ]
    let (<) = (<)[@@macro ]
    let (<=) = (<=)[@@macro ]
    let (>) = (>)[@@macro ]
    let (>=) = (>=)[@@macro ]
    let min = min[@@macro ]
    let max = max[@@macro ]
    let abs = abs[@@macro ]
    let to_string : t -> string = Z.to_string[@@ocaml.doc
                                               " Conversion to a string.\n      Only works for nonnegative numbers "]
      [@@builtin.logic_core "mk_int_to_str"]
    let compare (x : t) (y : t) =
      if x = y
      then Z.of_nativeint 0n
      else if x < y then Z.of_nativeint (-1n) else Z.of_nativeint 1n[@@macro
                                                                    ]
    let equal = (=)[@@macro ]
    let pp = Z.pp_print[@@program ]
    let of_caml_int = Z.of_int[@@program ]
    let rec for_ i j f : unit=
      if i <= j then (f i; for_ (i + (Z.of_nativeint 1n)) j f)[@@program ]
    let pow_ x n =
      let rec aux base exp acc =
        if exp = (Z.of_nativeint 0n)
        then acc
        else
          (let acc' =
             if (exp mod (Z.of_nativeint 2n)) = (Z.of_nativeint 1n)
             then acc * base
             else acc in
           aux (base * base) (exp / (Z.of_nativeint 2n)) acc') in
      aux x n (Z.of_nativeint 1n)[@@program ]
    let pow : t -> t -> t = pow_[@@builtin.logic_core "mk_i_power"]
    let rec for_down_to i j f : unit=
      if i >= j then (f i; for_down_to (i - (Z.of_nativeint 1n)) j f)
      [@@program ]
    let mod_zero_prod n m x =
      implies
        ((n > (Z.of_nativeint 0n)) && ((x mod n) = (Z.of_nativeint 0n)))
        (((x * m) mod n) = (Z.of_nativeint 0n))[@@imandra_axiom ][@@rw ]
    let mod_sub_id n m =
      implies ((m <= n) && (m > (Z.of_nativeint 0n)))
        (((n + ((Z.of_nativeint (-1n)) * m)) mod m) = (n mod m))[@@imandra_axiom
                                                                  ][@@rw ]
  end
module Bool = struct type t = bool[@@deriving (to_iml, of_mir)] end
module Array =
  struct
    include Stdlib.Array[@@ocaml.doc
                          " A program-mode imperative array, that can be mutated "]
    let get a i = Stdlib.Array.get a (Z.to_int i)
    let set a i v = Stdlib.Array.set a (Z.to_int i) v
    let make i x = Stdlib.Array.make (Z.to_int i) x
    let init i f = Stdlib.Array.init (Z.to_int i) (fun i -> f (Z.of_int i))
    let sub a i len = Stdlib.Array.sub a (Z.to_int i) (Z.to_int len)
    let length a = Z.of_int (Stdlib.Array.length a)
    let mapi f a = Stdlib.Array.mapi (fun i x -> f (Z.of_int i) x) a
    let iteri f a = Stdlib.Array.iteri (fun i x -> f (Z.of_int i) x) a
    let fill a i len x = Stdlib.Array.fill a (Z.to_int i) (Z.to_int len) x
    let blit a i b j len =
      Stdlib.Array.blit a (Z.to_int i) b (Z.to_int j) (Z.to_int len)
  end[@@ocaml.doc " {2 Arrays}\n\n   Program mode only "][@@program ]
module Option =
  struct
    type 'a t = 'a option[@@deriving (to_iml, of_mir)]
    let map f = function | None -> None | Some x -> Some (f x)[@@ocaml.doc
                                                                " Map over the option.\n\n      - [map f None = None]\n      - [map f (Some x) = Some (f x)]\n  "]
    let map_or ~default f = function | None -> default | Some x -> f x
    let is_some = function | None -> false | Some _ -> true[@@ocaml.doc
                                                             " Returns [true] iff the argument is of the form [Some x] "]
      [@@macro ]
    let is_none = function | None -> true | Some _ -> false[@@ocaml.doc
                                                             " Returns [true] iff the argument is [None] "]
      [@@macro ]
    let return x = Some x[@@ocaml.doc
                           " Wrap a value into an option. [return x = Some x] "]
      [@@macro ]
    let (>|=) x f = map f x[@@ocaml.doc " Infix alias to {!map} "][@@macro ]
    let flat_map f o = match o with | None -> None | Some x -> f x[@@ocaml.doc
                                                                    " Monadic operator, useful for chaining multiple optional computations "]
    let (>>=) o f = flat_map f o[@@ocaml.doc
                                  " Infix monadic operator, useful for chaining multiple optional computations\n      together.\n      It holds that [(return x >>= f) = f x] "]
      [@@macro ]
    let or_ a b = match a with | None -> b | Some _ -> a[@@ocaml.doc
                                                          " Choice of a value\n\n      - [or_ None x = x]\n      - [or_ (Some y) x = Some y]\n  "]
      [@@macro ]
    let (<+>) a b = or_ a b[@@macro ]
    let exists p = function | None -> false | Some x -> p x
    let for_all p = function | None -> true | Some x -> p x
    let get_or ~default x = match x with | None -> default | Some y -> y
    let fold f acc o = match o with | None -> acc | Some x -> f acc x
    let (<$>) = map[@@ocaml.doc " [f <$> x = map f x] "][@@macro ]
    let monoid_product a b =
      match (a, b) with | (Some x, Some y) -> Some (x, y) | _ -> None
    let (let+) = (>|=)[@@macro ]
    let (and+) = monoid_product[@@macro ]
    let ( let* ) = (>>=)[@@macro ]
    let ( and* ) = monoid_product[@@macro ]
  end[@@ocaml.doc
       " {2 Option module}\n\n    The option type [type 'a option = None | Some of 'a] is useful for\n    representing partial functions and optional values.\n    "]
module Real =
  struct
    type t = real[@@deriving (to_iml, of_mir)]
    let of_int : int -> t = Q.of_bigint[@@builtin.logic_core "mk_r_of_i"]
    let _to_int_round_down : t -> int = Q.to_bigint[@@builtin.logic_core
                                                     "mk_i_of_r"]
    let to_int (r : t) : int=
      if r >=. (of_int (Z.of_nativeint 0n))
      then _to_int_round_down r
      else - (_to_int_round_down (-. r))
    let (+) = (+.)[@@macro ]
    let (-) = (-.)[@@macro ]
    let (~-) = (~-.)[@@macro ]
    let ( * ) = ( *. )[@@macro ]
    let (/) = (/.)[@@macro ]
    let (<) = (<.)[@@macro ]
    let (<=) = (<=.)[@@macro ]
    let (>) = (>.)[@@macro ]
    let (>=) = (>=.)[@@macro ]
    let abs r = if r >= (of_int (Z.of_nativeint 0n)) then r else - r
    let min = min_r[@@macro ]
    let max = max_r[@@macro ]
    let mk_of_float = Q.of_float[@@program ]
    let mk_of_q (x : Q.t) = x[@@program ]
    let mk_of_string (x : string) = Q.of_string x[@@program ]
    let to_float = Q.to_float[@@program ]
    let of_float : float -> real = Q.of_float[@@builtin.logic_core
                                               "mk_r_of_f"]
    let compare (x : t) (y : t) =
      if x = y then 0 else if x < y then (-1) else 1[@@program ]
    let pp = Q.pp_print[@@program ]
    let to_string = Q.to_string[@@program ]
    let to_string_approx x = string_of_float @@ (Q.to_float x)[@@program ]
    let pow_ a b =
      let (p, q) = ((Q.num a), (Q.den a)) in
      if let open Int in b >= (Z.of_nativeint 0n)
      then let p_b = Int.pow p b in let q_b = Int.pow q b in Q.make p_b q_b
      else
        (let b = let open Int in - b in
         let p_b = Int.pow p b in let q_b = Int.pow q b in Q.make q_b p_b)
      [@@program ]
    let pow : t -> Int.t -> t = pow_[@@builtin.logic_core "mk_r_power"]
  end
module Map =
  struct
    type (+'a, 'b) t = {
      l: ('a * 'b) list ;
      default: 'b }[@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                  "mk_s_array"]
    let const_ x = { default = x; l = [] }[@@program ]
    let const : 'b -> ('a, 'b) t = const_[@@builtin.logic_core
                                           "mk_array_const"]
    let add_rec m k v : _ t=
      let rec aux l =
        match l with
        | [] -> if v = m.default then [] else [(k, v)]
        | (k', v')::tail ->
            (match Stdlib.compare k k' with
             | 0 -> if v = m.default then tail else (k, v) :: tail
             | n when let open Program_prelude_.Int in n < 0 ->
                 if v = m.default then l else (k, v) :: l
             | _ -> (k', v') :: (aux tail)) in
      { m with l = (aux m.l) }[@@program ]
    let add' : ('a, 'b) t -> 'a -> 'b -> ('a, 'b) t = add_rec[@@ocaml.doc
                                                               " [add' m k v] adds the binding [k -> v] to [m] "]
      [@@builtin.logic_core "mk_array_store"]
    let add k v m = add' m k v[@@ocaml.doc
                                " Same as {!add'} but with arguments swapped "]
      [@@macro ]
    let get_default_ m = m.default[@@program ]
    let get_default : (_, 'b) t -> 'b = get_default_[@@builtin.logic_core
                                                      "mk_array_default"]
    let get_rec m k =
      let rec aux l =
        match l with
        | [] -> m.default
        | (k', v)::tail -> if k = k' then v else aux tail in
      aux m.l[@@program ]
    let get' : ('a, 'b) t -> 'a -> 'b = get_rec[@@builtin.logic_core
                                                 "mk_array_select"]
    let get (k : 'a) (m : ('a, 'b) t) : 'b= get' m k[@@macro ]
    let rec of_list (default : 'b) (l : ('a * 'b) list) : ('a, 'b) t=
      match l with
      | [] -> const default
      | (k, v)::tail -> add k v (of_list default tail)[@@adm l][@@builtin.special
                                                                 "map.of_list"]
    let filter_map ~default ~f m : _ t=
      let rec aux =
        function
        | [] -> []
        | (x, v)::tl ->
            let tl = aux tl in
            (match f x v with | None -> tl | Some v' -> (x, v') :: tl) in
      { default = (default m.default); l = (aux m.l) }[@@program ]
    let for_all ~default ~f m : bool=
      (default m.default) && (List.for_all (fun (x, v) -> f x v) m.l)
      [@@program ]
    let merge ~default ~f_both ~f1 ~f2 (s1 : ('a, 'b) t) (s2 : ('a, 'c) t) :
      ('a, 'd) t=
      let open Stdlib in
        let rec aux l1 l2 =
          match (l1, l2) with
          | ([], []) -> []
          | ([], _) ->
              List.filter_map
                (fun (k, v) -> (Option.map (fun v -> (k, v))) @@ (f2 k v)) l2
          | (_, []) ->
              List.filter_map
                (fun (k, v) -> (Option.map (fun v -> (k, v))) @@ (f1 k v)) l1
          | ((x1, v1)::tl1, (x2, v2)::tl2) ->
              if x1 = x2
              then
                let tl = aux tl1 tl2 in
                (match f_both x1 v1 v2 with
                 | None -> tl
                 | Some v -> (x1, v) :: tl)
              else
                if x1 < x2
                then
                  (let tl = aux tl1 l2 in
                   match f1 x1 v1 with | None -> tl | Some v -> (x1, v) :: tl)
                else
                  (let tl = aux l1 tl2 in
                   match f2 x2 v2 with | None -> tl | Some v -> (x2, v) :: tl) in
        { default = (default s1.default s2.default); l = (aux s1.l s2.l) }
      [@@program ]
    let extract (m : ('a, 'b) t) : (('a * 'b) list * 'b)=
      ((m.l), (m.default))[@@program ]
    let pp pp_k pp_v out (m : (_, _) t) : unit=
      match m.l with
      | [] -> Format.fprintf out "(@[Map.const %a@])" pp_v m.default
      | _ ->
          let pp_sep out () = Format.fprintf out ";@ " in
          let pp_pair out (k, v) =
            Format.fprintf out "(@[%a,@ %a@])" pp_k k pp_v v in
          Format.fprintf out "(@[Map.of_list@ ~default:%a@ [@[%a@]]@])" pp_v
            m.default (Format.pp_print_list ~pp_sep pp_pair) m.l[@@program ]
  end
module Multiset =
  struct
    type +'a t = ('a, int) Map.t[@@deriving (to_iml, of_mir)]
    let empty = Map.const (Z.of_nativeint 0n)[@@macro ]
    let add (x : 'a) (m : 'a t) : 'a t=
      Map.add x ((Map.get x m) + (Z.of_nativeint 1n)) m
    let find = Map.get[@@macro ]
    let mem x m : bool= (find x m) > (Z.of_nativeint 0n)
    let remove (x : 'a) (m : 'a t) : 'a t=
      let n = max (Z.of_nativeint 0n) ((Map.get x m) - (Z.of_nativeint 1n)) in
      Map.add x n m
    let rec of_list =
      function | [] -> empty | x::tail -> (add x) @@ (of_list tail)
  end[@@ocaml.doc
       " {2 Multiset}\n\n    A multiset is a collection of elements that don't have any particular\n    order, but can occur several times (unlike a regular set). "]
[@@@ocaml.text " {2 Sets} "]
module Set =
  struct
    type +'a t = ('a, bool) Map.t[@@deriving (to_iml, of_mir)]
    let empty : 'a t = Map.const false[@@macro ]
    let full : 'a t = Map.const true[@@macro ]
    let is_empty s : bool= s = empty
    let is_valid (_s : _ t) = true[@@macro ]
    let mem : 'a -> 'a t -> bool = Map.get[@@builtin.logic_core
                                            "mk_set_member"]
    let subset_ s1 s2 =
      Map.for_all s1 ~default:(fun v1 -> implies v1 (Map.get_default s2))
        ~f:(fun x v1 -> implies v1 (mem x s2))[@@ocaml.doc
                                                " Checks if [s1] is a subset of [s2] "]
      [@@program ]
    let subset : 'a t -> 'a t -> bool = subset_[@@builtin.logic_core
                                                 "mk_set_subset"]
    let add_ x s = Map.add x true s[@@program ]
    let add : 'a -> 'a t -> 'a t = add_[@@builtin.logic_core "mk_set_add"]
    let remove_ x s = Map.add x false s[@@program ]
    let remove : 'a -> 'a t -> 'a t = remove_[@@builtin.logic_core
                                               "mk_set_del"]
    let inter_ (s1 : 'a t) (s2 : 'a t) : 'a t=
      Map.merge s1 s2 ~default:(&&) ~f1:(fun _ x -> Some (x && s2.default))
        ~f2:(fun _ x -> Some (x && s1.default))
        ~f_both:(fun _ s1 s2 -> Some (s1 && s2))[@@program ]
    let inter : 'a t -> 'a t -> 'a t = inter_[@@builtin.logic_core
                                               "mk_set_inter"]
    let union_ (s1 : 'a t) (s2 : 'a t) : 'a t=
      Map.merge ~default:(||) ~f1:(fun _ x -> Some (x || s2.default))
        ~f2:(fun _ x -> Some (x || s1.default))
        ~f_both:(fun _ s1 s2 -> Some (s1 || s2)) s1 s2[@@program ]
    let union : 'a t -> 'a t -> 'a t = union_[@@builtin.logic_core
                                               "mk_set_union"]
    let complement_ (s : 'a t) : 'a t=
      Map.filter_map s ~default:not ~f:(fun _ v -> Some (not v))[@@program ]
    let complement : 'a t -> 'a t = complement_[@@builtin.logic_core
                                                 "mk_set_complement"]
    let diff_ (s1 : 'a t) (s2 : 'a t) : 'a t=
      Map.merge ~default:(fun v1 v2 -> v1 && (not v2))
        ~f1:(fun _ x -> Some (x && (not s2.default)))
        ~f2:(fun _ x -> Some (s1.default && (not x)))
        ~f_both:(fun _ s1 s2 -> Some (s1 && (not s2))) s1 s2[@@program ]
    let diff : 'a t -> 'a t -> 'a t = diff_[@@builtin.logic_core
                                             "mk_set_difference"]
    let rec of_list = function | [] -> empty | x::tl -> add x (of_list tl)
      [@@adm 0n][@@builtin.special "set.of_list"]
    let to_list (s : 'a t) : 'a list=
      let (l, _) = Map.extract s in
      List.filter_map (fun (x, b) -> if b then Some x else None) l[@@program
                                                                    ]
    let (++) = union[@@macro ]
    let (--) = diff[@@macro ]
    let pp pp_x out (x : 'a t) : unit=
      match to_list x with
      | [] -> Format.pp_print_string out "Set.empty"
      | l ->
          Format.fprintf out "(@[Set.of_list@ [@[%a@]]@])"
            (Format.pp_print_list
               ~pp_sep:(fun out () -> Format.fprintf out ";@ ") pp_x) l
      [@@program ]
  end
module String =
  struct
    type t = string[@@deriving (to_iml, of_mir)]
    let empty = ""
    let length_ (s : t) : int= Z.of_int (Stdlib.String.length s)[@@program ]
    let length : t -> int = length_[@@ocaml.doc
                                     " Length of the string, i.e. its number of bytes "]
      [@@builtin.logic_core "mk_str_length"]
    let make (i : Program_prelude_.Int.t) c : t= String.make i c[@@ocaml.doc
                                                                  " [make i c] makes a string containing [i] times the char [c] "]
      [@@program ]
    let append : t -> t -> t = Stdlib.(^)[@@ocaml.doc
                                           " String concatenation "][@@builtin.logic_core
                                                                    "mk_str_append"]
    let get = Stdlib.String.get[@@program ]
    let rec concat sep (l : t list) : t=
      match l with
      | [] -> ""
      | x::[] -> x
      | x::tail -> append x (append sep (concat sep tail))[@@ocaml.doc
                                                            " [concat sep l] concatenates strings in [l] with [sep] inserted between\n    each element.\n\n    - [concat sep [] = \"\"]\n    - [concat sep [x] = x]\n    - [concat sep [x;y] = x ^ sep ^ y]\n    - [concat sep (x :: tail) = x ^ sep ^ concat sep tail]\n    "]
      [@@adm l]
    let prefix : t -> t -> bool = Program_prelude_.String.prefix[@@ocaml.doc
                                                                  " [prefix a b] returns [true] iff [a] is a prefix of [b]\n      (or if [a=b] "]
      [@@builtin.logic_core "mk_str_prefix"]
    let suffix : t -> t -> bool = Program_prelude_.String.suffix[@@ocaml.doc
                                                                  " [suffix a b] returns [true] iff [a] is a suffix of [b]\n      (or if [a=b] "]
      [@@builtin.logic_core "mk_str_suffix"]
    let contains : t -> t -> bool = Program_prelude_.String.contains[@@builtin.logic_core
                                                                    "mk_str_contains"]
    let unsafe_sub_ (a : t) (i : int) (len : int) : t=
      Stdlib.String.sub a (Z.to_int i) (Z.to_int len)[@@program ]
    let unsafe_sub : t -> int -> int -> t = unsafe_sub_[@@builtin.logic_core
                                                         "mk_str_sub"]
    let sub (a : t) (i : int) (len : int) : t option=
      if
        (i >= (Z.of_nativeint 0n)) &&
          ((len >= (Z.of_nativeint 0n)) && ((i + len) <= (length a)))
      then Some (unsafe_sub a i len)
      else None[@@ocaml.doc
                 " Substring. [sub s i len] returns the string [s[i], s[i+1],\226\128\166,s[i+len-1]]. "]
    let of_int (i : int) : t=
      if i >= (Z.of_nativeint 0n)
      then Int.to_string i
      else append "-" (Int.to_string (- i))[@@ocaml.doc
                                             " String representation of an integer "]
    let unsafe_to_nat : t -> int = Program_prelude_.String.unsafe_to_nat
      [@@builtin.logic_core "mk_unsafe_str_to_nat"]
    let to_nat (s : t) : int option=
      let x = unsafe_to_nat s in
      if x >= (Z.of_nativeint 0n) then Some x else None[@@ocaml.doc
                                                         " Parse a string into a nonnegative number, or return [None] "]
    let is_nat (s : t) : bool=
      (s <> "") && ((unsafe_to_nat s) >= (Z.of_nativeint 0n))[@@macro ]
    let is_int (s : t) : bool=
      (is_nat s) ||
        ((prefix "-" s) &&
           (is_nat
              (unsafe_sub s (Z.of_nativeint 1n)
                 ((length s) - (Z.of_nativeint 1n)))))[@@macro ]
    let unsafe_to_int (s : t) : int=
      let x = unsafe_to_nat s in
      if x >= (Z.of_nativeint 0n)
      then x
      else
        -
          (unsafe_to_nat
             (unsafe_sub s (Z.of_nativeint 1n)
                ((length s) - (Z.of_nativeint 1n))))
    let to_int (s : t) : int option=
      if is_int s then Some (unsafe_to_int s) else None
  end[@@ocaml.doc
       " {2 Byte strings}\n\n    These strings correspond to OCaml native strings, and do not have\n    a particular unicode encoding.\n\n    Rather, they should be seen as sequences of bytes, and it is also\n    this way that Imandra considers them.\n"]
let (^) = String.append[@@ocaml.doc " Alias to {!String.append} "][@@macro ]
let succ x = x + (Z.of_nativeint 1n)[@@ocaml.doc " Next integer "][@@macro ]
let pred x = x - (Z.of_nativeint 1n)[@@ocaml.doc " Previous integer "]
  [@@macro ]
let fst (x, _) = x[@@macro ]
let snd (_, y) = y[@@macro ]
module Float =
  struct
    type t = float[@@deriving (to_iml, of_mir)]
    module Round =
      struct
        type t =
          | Nearest_ties_to_even [@ocaml.doc " default "]
          | Nearest_ties_to_away 
          | Towards_positive 
          | Towards_negative 
          | Towards_zero [@@deriving (to_iml, of_mir)][@@builtin.logic_core
                                                        "mk_s_float_rounding"]
        let _ = fun (x : t) -> x = x[@@imandra_verify ]
      end
    let of_int = Z.to_float[@@program ]
    let of_string = Stdlib.float_of_string[@@program ]
    let (~-) : t -> t = Stdlib.(~-.)[@@builtin.logic_core "mk_f_neg"]
    let (+) : t -> t -> t = Stdlib.(+.)[@@builtin.logic_core "mk_f_add"]
    let (-) : t -> t -> t = Stdlib.(-.)[@@builtin.logic_core "mk_f_sub"]
    let ( * ) : t -> t -> t = Stdlib.( *. )[@@builtin.logic_core "mk_f_mul"]
    let (/) : t -> t -> t = Stdlib.(/.)[@@builtin.logic_core "mk_f_div"]
    let nan : t = Stdlib.nan[@@builtin.logic_core "mk_f_nan"]
    let infinity : t = Stdlib.infinity[@@builtin.logic_core "mk_f_infinity"]
    let (<) : t -> t -> bool = Stdlib.(<)[@@builtin.logic_core "mk_f_lt"]
    let (<=) : t -> t -> bool = Stdlib.(<=)[@@builtin.logic_core "mk_f_le"]
    let (>) : t -> t -> bool = Stdlib.(>)[@@builtin.logic_core "mk_f_gt"]
    let (>=) : t -> t -> bool = Stdlib.(>=)[@@builtin.logic_core "mk_f_ge"]
    let (=) : t -> t -> bool = Stdlib.(=)[@@builtin.logic_core "mk_f_eq"]
    let (<>) : t -> t -> bool = Stdlib.(<>)[@@builtin.logic_core "mk_f_neq"]
    let neg : t -> t = (~-)[@@macro ]
    let abs : t -> t = Stdlib.abs_float[@@builtin.logic_core "mk_f_abs"]
    let is_zero x = Stdlib.(=) x 0.[@@program ]
    let is_nan (x : t) : bool=
      Stdlib.(=) (Stdlib.classify_float x) Stdlib.FP_nan[@@program ]
    let is_infinite (x : t) : bool=
      Stdlib.(=) (Stdlib.classify_float x) Stdlib.FP_infinite[@@program ]
    let is_normal (x : t) : bool=
      Stdlib.(=) (Stdlib.classify_float x) Stdlib.FP_normal[@@program ]
    let is_subnormal (x : t) : bool=
      Stdlib.(=) (Stdlib.classify_float x) Stdlib.FP_subnormal[@@program ]
    let is_positive (x : t) : bool= x > 0.[@@program ]
    let is_negative (x : t) : bool= x < 0.[@@program ]
    let is_zero : t -> bool = is_zero[@@builtin.logic_core "mk_f_is_zero"]
    let is_nan : t -> bool = is_nan[@@builtin.logic_core "mk_f_is_nan"]
    let is_infinite : t -> bool = is_infinite[@@builtin.logic_core
                                               "mk_f_is_infinite"]
    let is_normal : t -> bool = is_normal[@@builtin.logic_core
                                           "mk_f_is_normal"]
    let is_subnormal : t -> bool = is_subnormal[@@builtin.logic_core
                                                 "mk_f_is_subnormal"]
    let is_positive : t -> bool = is_positive[@@builtin.logic_core
                                               "mk_f_is_positive"]
    let is_negative : t -> bool = is_negative[@@builtin.logic_core
                                               "mk_f_is_negative"]
    let min (x : t) (y : t) : t=
      if is_nan x then y else if is_nan y then x else Stdlib.min x y[@@program
                                                                    ]
    let max (x : t) (y : t) : t=
      if is_nan x then y else if is_nan y then x else Stdlib.max x y[@@program
                                                                    ]
    let min : t -> t -> t = min[@@builtin.logic_core "mk_f_min"]
    let max : t -> t -> t = max[@@builtin.logic_core "mk_f_max"]
    let rem : t -> t -> t = Stdlib.mod_float[@@builtin.logic_core "mk_f_rem"]
    let sqrt : t -> t = Stdlib.sqrt[@@builtin.logic_core "mk_f_sqrt"]
  end
module LChar =
  struct
    type t =
      | Char of bool * bool * bool * bool * bool * bool * bool * bool 
    [@@deriving (to_iml, of_mir)]
    let zero : t =
      Char (false, false, false, false, false, false, false, false)
    let to_int (c : t) : Program_prelude_.Int.t=
      let open Program_prelude_.Int in
        let Char (a7, a6, a5, a4, a3, a2, a1, a0) = c in
        let (!) x = if x then 1 else 0 in
        ((((((((!a7) lsl 7) + ((!a6) lsl 6)) + ((!a5) lsl 5)) + ((!a4) lsl 4))
             + ((!a3) lsl 3))
            + ((!a2) lsl 2))
           + ((!a1) lsl 1))
          + ((!a0) lsl 0)[@@program ]
    let of_int (i : Program_prelude_.Int.t) : t=
      assert ((let open Program_prelude_.Int in (i >= 0) && (i < 256)));
      (let (!) x = x <> 0 in
       let a7 = !(i land (1 lsl 7)) in
       let a6 = !(i land (1 lsl 6)) in
       let a5 = !(i land (1 lsl 5)) in
       let a4 = !(i land (1 lsl 4)) in
       let a3 = !(i land (1 lsl 3)) in
       let a2 = !(i land (1 lsl 2)) in
       let a1 = !(i land (1 lsl 1)) in
       let a0 = !(i land (1 lsl 0)) in Char (a7, a6, a5, a4, a3, a2, a1, a0))
      [@@program ]
    let of_char (c : char) : t= of_int (Stdlib.Char.code c)[@@program ]
    let to_char (c : t) : char= Stdlib.Char.chr (to_int c)[@@program ]
    let pp out c = Format.fprintf out "%C" (to_char c)[@@program ]
    let explode (s : string) : t list=
      let l = ref [] in
      Stdlib.String.iter (fun c -> l := ((of_char c) :: (!l))) s;
      List.rev (!l)[@@program ]
    let is_printable (c : t) : bool=
      match c with
      | Char (false, false, true, false, false, false, false, false) -> false
      | Char (_, true, _, _, _, _, _, _) | Char (_, _, true, _, _, _, _, _)
          -> true
      | _ -> false
  end[@@ocaml.doc " {1 Logic mode char}\n\n    An 8-bit char. "]
[@@@ocaml.text " {2 Logic-mode strings}\n\n    Strings purely in Imandra. "]
module LString =
  struct
    type t = LChar.t list[@@deriving (to_iml, of_mir)]
    let empty : t = []
    let of_list l = l
    let to_string (s : t) = (CCList.map LChar.to_char s) |> CCString.of_list
      [@@program ]
    let of_string = LChar.explode[@@program ]
    let rec length (s : t) =
      match s with
      | [] -> Z.of_nativeint 0n
      | _::tl -> (Z.of_nativeint 1n) + (length tl)[@@unroll
                                                    Z.of_nativeint 32n]
      [@@adm s]
    let pp out l =
      if List.for_all LChar.is_printable l
      then
        Format.fprintf out "{l|@[<hov>%s@]|l}"
          ((CCList.map LChar.to_char l) |> CCString.of_list)
      else CCFormat.Dump.list LChar.pp out l[@@program ]
    let len_pos (s : t) = ((length s)[@trigger ]) >= (Z.of_nativeint 0n)
      [@@imandra_theorem ][@@fc ][@@by induct ~on_vars:["s"] ()]
    let len_zero_inversion (s : t) =
      implies (((length s)[@trigger ]) = (Z.of_nativeint 0n)) (s = [])
      [@@imandra_theorem ][@@fc ][@@by induct ~on_vars:["s"] ()]
    let rec append (s1 : t) (s2 : t) : t=
      match s1 with | [] -> s2 | c::s1' -> c :: (append s1' s2)
    let (^^) = append
    let rec for_all f (s : t) =
      match s with | [] -> true | x::tl -> (f x) && (for_all f tl)[@@unroll
                                                                    Z.of_nativeint
                                                                    32n]
      [@@adm s]
    let rec exists f (s : t) =
      match s with | [] -> false | x::tl -> (f x) || (exists f tl)[@@unroll
                                                                    Z.of_nativeint
                                                                    32n]
      [@@adm s]
    let rec concat sep =
      function
      | [] -> []
      | s::[] -> s
      | s1::tl -> append s1 (append sep (concat sep tl))
    let is_printable (s : t) : bool= for_all LChar.is_printable s
    let rec sub (s : t) (i : int) (len : int) : t=
      match s with
      | [] -> []
      | c1::s' ->
          if len <= (Z.of_nativeint 0n)
          then []
          else
            if i <= (Z.of_nativeint 0n)
            then c1 ::
              (sub s' (Z.of_nativeint 0n) (len - (Z.of_nativeint 1n)))
            else sub s' (i - (Z.of_nativeint 1n)) len
    let rec prefix (s1 : t) (s2 : t) : bool=
      match s1 with
      | [] -> true
      | c1::s1' ->
          (match s2 with
           | [] -> false
           | c2::s2' -> (c1 = c2) && (prefix s1' s2'))
    let rec suffix (s1 : t) (s2 : t) : bool=
      (s1 = s2) || (match s2 with | [] -> false | _::s2' -> suffix s1 s2')
    let rec contains (s1 : t) (s2 : t) : bool=
      match s2 with
      | [] -> true
      | c2::s2' ->
          (match s1 with
           | [] -> false
           | c1::s1' ->
               ((c1 = c2) && (contains s1' s2')) || (contains s1' s2))
      [@@ocaml.doc
        " [contains s1 s2] is [true] if [s2] is a substring of [s1] "]
      [@@adm s1]
    let take : int -> t -> t = List.take
    let drop : int -> t -> t = List.drop
  end
