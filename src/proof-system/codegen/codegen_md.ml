module PS = Imandra_proof_system_spec

let bpf = Printf.bprintf
let spf = Printf.sprintf

module Make (X : sig
  val spec : PS.t
end) =
struct
  open X

  let indent n s =
    match String.split_on_char '\n' s with
    | [] -> ""
    | [ _ ] -> s
    | s :: tl ->
      String.concat "\n"
      @@ (s :: List.map (fun line -> String.make n ' ' ^ line) tl)

  let terms_by_ret_type_ : (PS.meta_type, PS.dag_term list) Hashtbl.t =
    let res = Hashtbl.create 32 in
    List.iter
      (fun (t : PS.dag_term) ->
        let l = Hashtbl.find_opt res t.ret |> Option.value ~default:[] in
        Hashtbl.replace res t.ret (t :: l))
      spec.dag_terms;
    res

  let is_dag_type s : bool = Hashtbl.mem terms_by_ret_type_ (PS.M_ty s)

  let rec pp_meta_type (m : PS.meta_type) : string =
    match m with
    | M_ty s -> s
    | M_list s -> spf "[%s]" (pp_meta_type s)
    | M_option s -> spf "optional(%s)" (pp_meta_type s)
    | M_tuple l -> spf "(%s)" @@ String.concat ", " @@ List.map pp_meta_type l

  let gendoc (out : Buffer.t) : unit =
    let emit_dag_term (t : PS.dag_term) : unit =
      bpf out "- `%s : %s -> %s`\n" t.name
        (String.concat ", " @@ List.map pp_meta_type t.args)
        (pp_meta_type t.ret);
      Option.iter
        (fun n2 -> bpf out "  (full name used for codegen: `%s`)\n" n2)
        t.full_name;
      bpf out "  %s\n\n" (indent 2 t.doc)
    in

    let emit_dag_type (ty : PS.dag_type) : unit =
      bpf out "- `%s`: %s\n\n" ty.name ty.doc
    in

    bpf out "\n## DAG types \n\n";
    List.iter emit_dag_type spec.dag_types;

    bpf out "\n## DAG terms\n\n";

    Hashtbl.iter
      (fun (ty : PS.meta_type) ts ->
        bpf out "### Terms returning `%s`\n\n" (pp_meta_type ty);
        List.iter emit_dag_term ts;
        bpf out "\n")
      terms_by_ret_type_;

    let emit_builtin_sym (t : PS.builtin_symbol) =
      (* TODO: a comment with the type signature *)
      if t.ret = PS.M_ty "Type" then (
        assert (t.args = []);
        bpf out "- type builtin `%s`\n\n" t.name
      ) else
        bpf out "- builtin symbol `%s : %s%s -> %s`\n\n" t.name
          (match t.params with
          | [] -> ""
          | l -> spf "forall %s. " (String.concat "," l))
          (String.concat ", " @@ List.map pp_meta_type t.args)
          (pp_meta_type t.ret)
      (* TODO: doc? *)
    in

    (* shortcuts for builtins *)
    bpf out "\n## Builtin symbols\n\n";
    List.iter emit_builtin_sym spec.builtin_symbols;

    ()
end

let codegen (oc : out_channel) : unit =
  let module M = Make (struct
    let spec = PS.spec
  end) in
  let buf = Buffer.create 32 in
  bpf buf "# Imandra Proof System\n\n";
  M.gendoc buf;
  Buffer.output_buffer oc buf
