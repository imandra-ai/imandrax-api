open struct
  module J = Yojson.Safe

  let spf = Printf.sprintf
end

module Encoder = Encoder

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
  | M_option of meta_type
  | M_tuple of meta_type list
[@@deriving show { with_path = false }, ord]

let meta_type_of_yojson j =
  let rec loop = function
    | `String s -> M_ty s
    | `List [ `String "List"; s ] -> M_list (loop s)
    | `List [ `String "Option"; s ] -> M_option (loop s)
    | `List (`String "Tuple" :: l) -> M_tuple (List.map loop l)
    | _j -> failwith (spf "cannot parse meta-type: %s" (J.to_string _j))
  in
  try Ok (loop j) with Failure err -> Error err

type dag_type = {
  name: string;
  doc: string;
}
[@@deriving show { with_path = false }, of_yojson]

type dag_type_field = {
  field_name: string; [@key "field"]
  ty: meta_type; [@key "type"]
}
[@@deriving show { with_path = false }, of_yojson]

type dag_type_def_def = {
  struct_: dag_type_field list option; [@key "struct"] [@default None]
}
[@@deriving show { with_path = false }, of_yojson]

type dag_type_def = {
  name: string;
  doc: string;
  def: dag_type_def_def option; [@default None]
}
[@@deriving show { with_path = false }, of_yojson]

type dag_term = {
  name: string;
  full_name: string option; [@default None]
  ret: meta_type;
  args: meta_type list;
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
  dag_type_defs: dag_type_def list;
  dag_terms: dag_term list;
  builtin_symbols: builtin_symbol list;
}
[@@deriving show { with_path = false }, of_yojson]

let spec : t =
  match of_yojson @@ J.from_string Raw.spec with
  | Ok s -> s
  | Error msg -> failwith @@ spf "Could not parse spec: %s" msg
