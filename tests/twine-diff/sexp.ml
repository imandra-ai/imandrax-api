(** The text form decoders reply with: one labelled S-expression per value. *)

type sexp = CCSexp.t

(** What a decoder replies to one request *)
type reply =
  | Value of Value.t
  | Decode_error of string  (** the decoder rejected the input *)
  | Crash of string  (** anything else went wrong *)

let atom s : sexp = `Atom s
let list l : sexp = `List l

let hex_of_string (s : string) : string =
  let buf = Buffer.create (2 * String.length s) in
  String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) s;
  Buffer.contents buf

let string_of_hex (h : string) : string =
  if String.length h mod 2 <> 0 then failwith "odd number of hex digits";
  String.init
    (String.length h / 2)
    (fun i -> Char.chr (int_of_string ("0x" ^ String.sub h (2 * i) 2)))

let f64_bits (f : float) : string =
  Printf.sprintf "%016Lx" (Int64.bits_of_float f)

(** Text form of [v]. [F32] leaves are written as f64, the way a decoder reports
    them. *)
let rec of_value (v : Value.t) : sexp =
  match v with
  | Null -> atom "null"
  | Bool b -> list [ atom "bool"; atom (string_of_bool b) ]
  | Int z -> list [ atom "int"; atom (Z.to_string z) ]
  | F32 f | F64 f -> list [ atom "f64"; atom (f64_bits f) ]
  | Str s -> list [ atom "str"; atom (hex_of_string s) ]
  | Blob s -> list [ atom "blob"; atom (hex_of_string s) ]
  | Array l -> list (atom "array" :: List.map of_value l)
  | Dict l ->
    list
      (atom "dict" :: List.map (fun (k, v) -> list [ of_value k; of_value v ]) l)
  | Tag (n, x) -> list [ atom "tag"; atom (Z.to_string n); of_value x ]
  | Cstor (i, l) ->
    list (atom "cstor" :: atom (Z.to_string i) :: List.map of_value l)
  | Ref x -> list [ atom "ref"; of_value x ]

let of_reply (r : reply) : sexp =
  match r with
  | Value v -> of_value v
  | Decode_error msg -> list [ atom "error"; atom "decode"; atom msg ]
  | Crash msg -> list [ atom "error"; atom "crash"; atom msg ]

let to_string : sexp -> string = CCSexp.to_string

exception Bad of string

let bad fmt = Printf.ksprintf (fun s -> raise (Bad s)) fmt

let rec to_value (s : sexp) : Value.t =
  let int_atom = function
    | `Atom a ->
      (try Z.of_string a
       with Invalid_argument _ -> bad "expected an integer, got %S" a)
    | `List _ -> bad "expected an integer, got a list"
  in
  match s with
  | `Atom "null" -> Null
  | `List [ `Atom "bool"; `Atom "true" ] -> Bool true
  | `List [ `Atom "bool"; `Atom "false" ] -> Bool false
  | `List [ `Atom "int"; `Atom z ] ->
    (try Int (Z.of_string z) with Invalid_argument _ -> bad "bad integer %S" z)
  | `List [ `Atom "f64"; `Atom h ] when String.length h = 16 ->
    (match Int64.of_string_opt ("0x" ^ h) with
    | Some bits -> F64 (Int64.float_of_bits bits)
    | None -> bad "bad f64 bit pattern %S" h)
  | `List [ `Atom "str"; `Atom h ] -> Str (string_of_hex h)
  | `List [ `Atom "blob"; `Atom h ] -> Blob (string_of_hex h)
  | `List (`Atom "array" :: l) -> Array (List.map to_value l)
  | `List (`Atom "dict" :: l) ->
    Dict
      (List.map
         (function
           | `List [ k; v ] -> to_value k, to_value v
           | _ -> bad "expected a (key value) pair")
         l)
  | `List [ `Atom "tag"; n; x ] -> Tag (int_atom n, to_value x)
  | `List (`Atom "cstor" :: i :: l) -> Cstor (int_atom i, List.map to_value l)
  | `List [ `Atom "ref"; x ] -> Ref (to_value x)
  | _ -> bad "unexpected node %s" (CCSexp.to_string s)

(** Parse one reply line. [Error] means the line is not in the text form, which
    is a bug in the decoder program, not in the decoder. *)
let parse_reply (line : string) : (reply, string) result =
  match CCSexp.parse_string line with
  | Error e -> Error (Printf.sprintf "not an S-expression (%s): %S" e line)
  | Ok (`List [ `Atom "error"; `Atom "decode"; `Atom msg ]) ->
    Ok (Decode_error msg)
  | Ok (`List [ `Atom "error"; `Atom "crash"; `Atom msg ]) -> Ok (Crash msg)
  | Ok s ->
    (try Ok (Value (to_value s))
     with Bad msg -> Error (Printf.sprintf "%s, in reply %S" msg line))
