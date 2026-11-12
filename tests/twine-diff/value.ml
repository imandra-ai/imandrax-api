(** Values the harness generates, encodes and compares.

    One constructor per kind of twine value. [Int] holds a [Z.t] so that replies
    from decoders with unbounded integers (and the bigint property) parse into
    the same type; generated [Int]s stay within int64. *)

type t =
  | Null
  | Bool of bool
  | Int of Z.t
  | F32 of float  (** a float that is exactly representable as an f32 *)
  | F64 of float
  | Str of string  (** valid UTF-8 *)
  | Blob of string
  | Array of t list
  | Dict of (t * t) list
  | Tag of Z.t * t
  | Cstor of Z.t * t list  (** indices are unbounded, like integers *)
  | Ref of t  (** explicit reference (kind 14) to the value *)

(** Readable form, for failure reports *)
let rec pp out (v : t) : unit =
  let pp_list sep pp_x out l =
    List.iteri
      (fun i x ->
        if i > 0 then Format.fprintf out sep;
        pp_x out x)
      l
  in
  match v with
  | Null -> Format.fprintf out "null"
  | Bool b -> Format.fprintf out "%b" b
  | Int z -> Format.fprintf out "%s" (Z.to_string z)
  | F32 f -> Format.fprintf out "f32:%h" f
  | F64 f -> Format.fprintf out "%h" f
  | Str s -> Format.fprintf out "%S" s
  | Blob s -> Format.fprintf out "blob%S" s
  | Array l -> Format.fprintf out "[@[%a@]]" (pp_list ";@ " pp) l
  | Dict l ->
    let pp_pair out (k, v) = Format.fprintf out "@[%a@ => %a@]" pp k pp v in
    Format.fprintf out "{@[%a@]}" (pp_list ";@ " pp_pair) l
  | Tag (n, x) -> Format.fprintf out "@[tag %s(%a)@]" (Z.to_string n) pp x
  | Cstor (i, l) ->
    Format.fprintf out "@[C%s(%a)@]" (Z.to_string i) (pp_list ",@ " pp) l
  | Ref x -> Format.fprintf out "@[ref(%a)@]" pp x

let show v = Format.asprintf "%a" pp v

(** What a decoder is expected to report for [v]: f32 leaves widened to f64,
    since twine decoders return f32 values as ordinary floats. *)
let rec widen (v : t) : t =
  match v with
  | F32 f -> F64 f
  | Null | Bool _ | Int _ | F64 _ | Str _ | Blob _ -> v
  | Array l -> Array (List.map widen l)
  | Dict l -> Dict (List.map (fun (k, v) -> widen k, widen v) l)
  | Tag (n, x) -> Tag (n, widen x)
  | Cstor (i, l) -> Cstor (i, List.map widen l)
  | Ref x -> Ref (widen x)

(** Structural equality. Floats compare by bit pattern, except that any NaN
    equals any NaN (payloads may not survive widening). *)
let rec equal (a : t) (b : t) : bool =
  let float_eq x y =
    (Float.is_nan x && Float.is_nan y)
    || Int64.equal (Int64.bits_of_float x) (Int64.bits_of_float y)
  in
  match a, b with
  | Null, Null -> true
  | Bool x, Bool y -> x = y
  | Int x, Int y -> Z.equal x y
  | F32 x, F32 y | F64 x, F64 y -> float_eq x y
  | Str x, Str y | Blob x, Blob y -> String.equal x y
  | Array xs, Array ys -> List.equal equal xs ys
  | Dict xs, Dict ys ->
    List.equal (fun (k1, v1) (k2, v2) -> equal k1 k2 && equal v1 v2) xs ys
  | Tag (n, x), Tag (m, y) -> Z.equal n m && equal x y
  | Cstor (i, xs), Cstor (j, ys) -> Z.equal i j && List.equal equal xs ys
  | Ref x, Ref y -> equal x y
  | ( ( Null | Bool _ | Int _ | F32 _ | F64 _ | Str _ | Blob _ | Array _
      | Dict _ | Tag _ | Cstor _ | Ref _ ),
      _ ) ->
    false

(* Generators
   ==========

    Leaves are weighted towards the boundaries of the encoding: integers and
    lengths around 15 (where the inline form ends), floats with unusual bit
    patterns, and multi-byte UTF-8. *)

module G = QCheck2.Gen

(** Integers 14, 15 and 16 are where the 4-bit inline form ends. *)
let edge_ints : int64 list =
  [
    0L;
    1L;
    -1L;
    14L;
    15L;
    16L;
    -15L;
    -16L;
    -17L;
    127L;
    128L;
    -128L;
    -129L;
    0xFFFF_FFFFL;
    Int64.min_int;
    Int64.max_int;
    Int64.(add min_int 1L);
    Int64.(sub max_int 1L);
  ]

let gen_int : Z.t G.t =
  G.(
    map Z.of_int64
      (oneof_weighted
         [
           3, map Int64.of_int (int_range (-20) 20);
           2, oneof_list edge_ints;
           2, int64;
         ]))

let edge_f64 : float list =
  [
    0.;
    -0.;
    Float.nan;
    Float.infinity;
    Float.neg_infinity;
    Float.max_float;
    Float.min_float;
    Int64.float_of_bits 1L (* smallest subnormal *);
    Int64.float_of_bits 0x000F_FFFF_FFFF_FFFFL (* largest subnormal *);
    Int64.float_of_bits 0x7FF0_0000_0000_0001L (* NaN with a payload *);
    Float.pi;
    1e300;
    -1e-300;
  ]

let gen_f64 : float G.t =
  G.(
    oneof_weighted
      [ 2, oneof_list edge_f64; 2, map Int64.float_of_bits int64; 1, float ])

let edge_f32_bits : int32 list =
  [
    0l;
    0x8000_0000l;
    0x7F80_0000l;
    0xFF80_0000l;
    0x7FC0_0000l;
    1l;
    0x007F_FFFFl;
    0x7F7F_FFFFl;
    0x3F80_0000l;
  ]

(** Every f32 bit pattern, so the value is exactly representable as an f32 *)
let gen_f32 : float G.t =
  G.(map Int32.float_of_bits (oneof [ oneof_list edge_f32_bits; int32 ]))

(** A Unicode scalar value, mostly ASCII. Surrogates are skipped. *)
let gen_uchar : Uchar.t G.t =
  let skip_surrogates c =
    if c >= 0xD800 && c <= 0xDFFF then
      c + 0x800
    else
      c
  in
  G.(
    map Uchar.of_int
      (oneof_weighted
         [
           6, int_range 0x20 0x7E;
           1, int_range 0 0x7F;
           2, int_range 0x80 0x7FF;
           2, map skip_surrogates (int_range 0x800 0xFFFF);
           1, int_range 0x10000 0x10FFFF;
         ]))

let utf8_of_uchars (l : Uchar.t list) : string =
  let buf = Buffer.create 16 in
  List.iter (Buffer.add_utf_8_uchar buf) l;
  Buffer.contents buf

let gen_str : string G.t =
  G.(
    oneof_weighted
      [
        4, map utf8_of_uchars (list_size (int_range 0 20) gen_uchar);
        2, string_size ~gen:(char_range 'a' 'z') (int_range 13 17);
        1, map utf8_of_uchars (list_size (int_range 100 300) gen_uchar);
      ])

let gen_blob : string G.t =
  G.(
    oneof_weighted
      [
        4, string_size ~gen:char (int_range 0 20);
        2, string_size ~gen:char (int_range 13 17);
        1, string_size ~gen:char (int_range 100 300);
      ])

(** Tag numbers and constructor indices *)
let gen_index : Z.t G.t =
  G.(
    map Z.of_int
    @@ oneof_weighted
         [
           4, int_range 0 20;
           1, oneof_list [ 14; 15; 16; 127; 128; 1000; 1 lsl 20 ];
         ])

let gen_leaf : t G.t =
  G.(
    oneof_weighted
      [
        1, pure Null;
        1, map (fun b -> Bool b) bool;
        4, map (fun z -> Int z) gen_int;
        1, map (fun f -> F32 f) gen_f32;
        2, map (fun f -> F64 f) gen_f64;
        3, map (fun s -> Str s) gen_str;
        2, map (fun s -> Blob s) gen_blob;
        1, map (fun i -> Cstor (i, [])) gen_index;
      ])

(* Shrinking
   ---------

    Integrated shrinking cannot move from a container to one of its children, so
    failures would stop at a large container. This shrinker tries, in order:
    each direct child, removing one item, shrinking one item, and shrinking a
    leaf towards zero or empty. *)

let shrink_int (z : Z.t) : Z.t Seq.t =
  if Z.equal z Z.zero then
    Seq.empty
  else
    List.to_seq [ Z.zero; Z.div z (Z.of_int 2); Z.sub z (Z.of_int (Z.sign z)) ]
    |> Seq.filter (fun x -> not (Z.equal x z))

(** Shorter strings: empty, then the first half, then all but the last
    character. For [Str], cuts fall on character boundaries. *)
let shrink_string ~(utf8 : bool) (s : string) : string Seq.t =
  let n = String.length s in
  let rec boundary i =
    if (not utf8) || i <= 0 || i >= n then
      i
    else if Char.code s.[i] land 0xC0 = 0x80 then
      boundary (i - 1)
    else
      i
  in
  if n = 0 then
    Seq.empty
  else
    List.to_seq [ 0; boundary (n / 2); boundary (n - 1) ]
    |> Seq.filter (fun k -> k < n)
    |> Seq.map (fun k -> String.sub s 0 k)

(** Remove one item, then shrink one item *)
let shrink_list (shrink_x : 'a -> 'a Seq.t) (l : 'a list) : 'a list Seq.t =
  let removals =
    Seq.init (List.length l) (fun i -> List.filteri (fun j _ -> j <> i) l)
  in
  let shrink_at i =
    Seq.map
      (fun x' ->
        List.mapi
          (fun j x ->
            if j = i then
              x'
            else
              x)
          l)
      (shrink_x (List.nth l i))
  in
  Seq.append removals (Seq.flat_map shrink_at (Seq.init (List.length l) Fun.id))

let rec shrink (v : t) : t Seq.t =
  let shrink_pair (k, v) =
    Seq.append
      (Seq.map (fun k' -> k', v) (shrink k))
      (Seq.map (fun v' -> k, v') (shrink v))
  in
  match v with
  | Null -> Seq.empty
  | Bool b ->
    if b then
      Seq.return (Bool false)
    else
      Seq.empty
  | Int z -> Seq.map (fun z -> Int z) (shrink_int z)
  | (F32 f | F64 f) when Int64.equal (Int64.bits_of_float f) 0L -> Seq.empty
  | F32 _ -> Seq.return (F32 0.)
  | F64 _ -> Seq.return (F64 0.)
  | Str s -> Seq.map (fun s -> Str s) (shrink_string ~utf8:true s)
  | Blob s -> Seq.map (fun s -> Blob s) (shrink_string ~utf8:false s)
  | Array l ->
    Seq.append (List.to_seq l)
      (Seq.map (fun l -> Array l) (shrink_list shrink l))
  | Dict l ->
    Seq.append
      (Seq.flat_map (fun (k, v) -> List.to_seq [ k; v ]) (List.to_seq l))
      (Seq.map (fun l -> Dict l) (shrink_list shrink_pair l))
  | Tag (n, x) -> Seq.cons x (Seq.map (fun x -> Tag (n, x)) (shrink x))
  | Cstor (i, l) ->
    Seq.append (List.to_seq l)
      (Seq.map (fun l -> Cstor (i, l)) (shrink_list shrink l))
  | Ref x -> Seq.cons x (Seq.map (fun x -> Ref x) (shrink x))

(** Values of depth bounded by a size in [0, 30]. Some nodes repeat a subtree,
    so the shared encoding has something to share. *)
let gen : t G.t =
  G.set_shrink shrink
  @@ G.sized_size (G.int_range 0 30)
  @@ G.fix (fun self n ->
         if n <= 0 then
           gen_leaf
         else (
           let sub = self (n / 3) in
           let small_list = G.list_size (G.int_range 0 5) sub in
           G.oneof_weighted
             [
               3, gen_leaf;
               2, G.map (fun l -> Array l) small_list;
               ( 2,
                 G.map
                   (fun l -> Dict l)
                   G.(list_size (int_range 0 4) (pair sub sub)) );
               1, G.map2 (fun i x -> Tag (i, x)) gen_index sub;
               2, G.map2 (fun i l -> Cstor (i, l)) gen_index small_list;
               1, G.map (fun x -> Array [ x; x ]) sub;
               1, G.map2 (fun k v -> Dict [ k, v; k, v ]) sub sub;
               1, G.map (fun x -> Ref x) sub;
             ]
         ))

(** Integers for the bigint property, mostly beyond 64 bits *)
let gen_bigint : Z.t G.t =
  G.(
    oneof_weighted
      [
        1, gen_int;
        ( 3,
          map2
            (fun bits neg ->
              let z = Z.of_bits bits in
              if neg then
                Z.neg z
              else
                z)
            (string_size ~gen:char (int_range 0 40))
            bool );
      ])
