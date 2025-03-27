let pf = Printf.printf

type kind = {
  name: string;
  ty: string;
  tag: string;
  pp: string;
  docstring: string;
  to_twine: string;
  of_twine: string;
}

let mk ~tag ~docstring ?pp ?to_twine ?of_twine name ty : kind =
  let to_twine =
    match to_twine with
    | Some t -> t
    | None ->
      let pre = CCString.chop_suffix ~suf:".t" ty |> Option.get in
      pre ^ ".to_twine"
  in
  let of_twine =
    match of_twine with
    | Some t -> t
    | None ->
      let pre = CCString.chop_suffix ~suf:".t" ty |> Option.get in
      pre ^ ".of_twine"
  in

  let pp =
    match pp with
    | Some f -> f
    | None ->
      let pre = CCString.chop_suffix ~suf:".t" ty |> Option.get in
      pre ^ ".pp"
  in
  { name; ty; tag; to_twine; of_twine; docstring; pp }

let all : kind list =
  [
    mk "Term" "Imandrax_api_mir.Term.t" ~tag:"term" ~docstring:"A MIR term";
    mk "Type" "Imandrax_api_mir.Type.t" ~tag:"ty" ~docstring:"A MIR type";
    mk "PO_task" "Imandrax_api_tasks.PO_task.Mir.t" ~tag:"po_task"
      ~docstring:"Task to verify a Proof Obligation";
    mk "PO_res" "Imandrax_api_tasks.PO_res.Shallow.t" ~tag:"po_res"
      ~docstring:"Result of verifying a PO";
    mk "Eval_task" "Imandrax_api_tasks.Eval_task.Mir.t" ~tag:"eval_task"
      ~docstring:"Task to evaluate a term";
    mk "Eval_res" "Imandrax_api_tasks.Eval_res.t" ~tag:"eval_res"
      ~docstring:"Result of evaluating a term";
    mk "Model" "Imandrax_api_mir.Model.t" ~tag:"mir.model"
      ~docstring:"A MIR-level model";
    mk "Show" "string" ~tag:"show" ~pp:"CCFormat.Dump.string"
      ~to_twine:"(fun _enc s -> Imandrakit_twine.Immediate.string s)"
      ~of_twine:
        "(fun d i -> Imandrakit_twine.Decode.(string d @@ deref_rec d i))"
      ~docstring:"A human readable description";
    mk "Fun_decomp" "Imandrax_api_mir.Fun_decomp.t" ~tag:"mir.fun_decomp"
      ~docstring:"A MIR-level function decomposition";
    mk "Decomp_task" "Imandrax_api_tasks.Decomp_task.Mir.t" ~tag:"decomp_task"
      ~docstring:"Task to decompose a function";
    mk "Decomp_res" "Imandrax_api_tasks.Decomp_res.Shallow.t" ~tag:"decomp_res"
      ~docstring:"Result of decomposing a function";
    mk "Report" "Imandrax_api_report.Report.t" ~tag:"report"
      ~docstring:"Report from some task";
  ]

let prelude =
  {|
(* this file is autogenerated, do not edit *)

open struct
  let spf = Printf.sprintf
end

module Mir = Imandrax_api_mir
module Task = Imandrax_api_tasks
|}

let middle =
  {|
type string_as_bytes = (string[@use_bytes]) [@@deriving twine]
type storage = (Imandrax_api_ca_store.Key.t * string_as_bytes) list
[@@deriving twine]

(** An artifact. *)
type t = Artifact : {
  kind: 'a kind;
    (** Kind of artifact *)
  data: 'a;
    (** Main data *)
  storage: storage;
    (** Additional storage *)
} -> t

(** Pack together an artifact *)
  let[@inline] make ~storage ~kind data : t = Artifact {kind; data; storage}
|}

let main_ml () =
  pf "%s\n" prelude;

  pf "(** The kind of artifact. *)\n";
  pf "type _ kind =\n";
  List.iter
    (fun { name; ty; docstring; _ } ->
      pf "| %s : %s kind\n(** %s *)\n" name ty docstring)
    all;
  pf "\n\n";

  pf "let kind_to_string : type a. a kind -> string = function\n";
  List.iter (fun { name; tag; _ } -> pf "  | %s -> %S\n" name tag) all;
  pf "\n\n";

  pf "(** A type erased kind. *)\n";
  pf "type any_kind = Any_kind : _ kind -> any_kind\n\n";

  pf "let any_kind_to_string (Any_kind k) : string = kind_to_string k\n\n";

  pf "let kind_of_string : string -> (any_kind, string) result = function\n";
  List.iter
    (fun { name; tag; _ } -> pf "  | %S -> Ok (Any_kind %s)\n" tag name)
    all;
  pf "  | s -> Error (spf {|Unknown artifact kind: %%S|} s)\n";
  pf "\n\n";

  List.iter
    (fun { name; tag; _ } ->
      pf "let is_%s : string -> bool = fun str -> str = %S\n"
        (String.lowercase_ascii name)
        tag)
    all;

  pf "%s\n" middle;

  List.iter
    (fun { name; ty; _ } ->
      pf
        "let[@inline] make_%s ?(storage=[]) : %s -> t = fun x -> make ~storage \
         ~kind:%s x\n\n"
        (String.lowercase_ascii name)
        ty name;
      pf "let as_%s : t -> %s option = function\n"
        (String.lowercase_ascii name)
        ty;
      pf "  | Artifact {kind=%s; data=x; _} -> Some x\n" name;
      pf "  | _ -> None\n\n")
    all;

  pf
    "let to_twine : t Imandrakit_twine.Encode.encoder = fun enc (Artifact \
     {kind; data=x; storage=_}) -> match kind with\n";
  List.iter
    (fun { name; to_twine; _ } -> pf "|  %s -> %s enc x\n" name to_twine)
    all;
  pf "\n";

  List.iter
    (fun { name; ty; of_twine; _ } ->
      pf "let %s_of_twine : %s Imandrakit_twine.Decode.decoder = %s\n\n"
        (String.lowercase_ascii name)
        ty of_twine)
    all;

  pf
    "let of_twine : type a. a kind -> a Imandrakit_twine.Decode.decoder = \
     function\n";
  List.iter (fun { name; of_twine; _ } -> pf "| %s -> %s\n" name of_twine) all;
  pf "\n";

  pf "let pp out (Artifact {kind;data=x;storage=_}) : unit = match kind with\n";
  List.iter (fun { name; pp; _ } -> pf "| %s -> %s out x\n" name pp) all;
  pf "\n";

  ()

let main_json () =
  pf "[\n";
  List.iteri
    (fun i (k : kind) ->
      if i > 0 then
        pf ",\n"
      else
        pf "\n";
      pf {|  {"tag": %S, "ty": %S}|} k.tag k.ty)
    all;
  pf "\n]\n";
  ()

let () =
  match Sys.argv.(1) with
  | "ml" -> main_ml ()
  | "json" -> main_json ()
  | _ -> failwith "need json|ml"
