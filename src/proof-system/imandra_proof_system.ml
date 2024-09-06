module J = Yojson.Safe

(** The raw text *)
module Raw = struct
  let commands = Commands_.commands
end

type encoding_type = {
  name: string;
  doc: string;
}

(** The type of a command, term definition, etc. *)
type meta_type = Ty_app of string * meta_type list

type builtin_symbol = {
  name: string;
  params: string list;
  args: meta_type list;
  ret: meta_type;
}
