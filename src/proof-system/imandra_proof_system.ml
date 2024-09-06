open struct
  module J = Yojson.Safe

  let spf = Printf.sprintf
end

(** The raw text *)
module Raw = struct
  let spec = Spec_.spec
end

type wire_type = {
  name: string;
  doc: string;
}
[@@deriving show { with_path = false }, of_yojson]

(** The type of a command, term definition, etc. *)
type meta_type =
  | M_ty of string
  | M_list of meta_type
  | M_tuple of meta_type list
[@@deriving show { with_path = false }]

let meta_type_of_yojson j =
  let rec loop = function
    | `String s -> M_ty s
    | `List [ `String "List"; s ] -> M_list (loop s)
    | `List (`String "Tuple" :: l) -> M_tuple (List.map loop l)
    | _j -> failwith (spf "cannot parse meta-type: %s" (J.to_string _j))
  in
  try Ok (loop j) with Failure err -> Error err

type dag_type = {
  name: string;
  doc: string;
}
[@@deriving show { with_path = false }, of_yojson]

type dag_term = {
  name: string;
  ret: meta_type;
  args: meta_type list;
  doc: string;
}
[@@deriving show { with_path = false }, of_yojson]

type command = {
  name: string;
  args: meta_type list;
  defines_node: bool;
  doc: string;
}
[@@deriving show { with_path = false }, of_yojson]

type builtin_symbol = {
  name: string;
  params: string list; [@default []]
  args: meta_type list;
  ret: meta_type;
}
[@@deriving show { with_path = false }, of_yojson]

type t = {
  wire_types: wire_type list;
  dag_types: dag_type list;
  dag_terms: dag_term list;
  commands: command list;
  builtin_symbols: builtin_symbol list;
}
[@@deriving show { with_path = false }, of_yojson]

let spec : t =
  match of_yojson @@ J.from_string Raw.spec with
  | Ok s -> s
  | Error msg -> failwith @@ spf "Could not parse spec: %s" msg
