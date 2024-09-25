module PS = Imandra_proof_system_spec

let bpf = Printf.bprintf
let spf = Printf.sprintf
let capitalize = String.capitalize_ascii
let prelude = Preludes.ocaml_prelude

module Make (X : sig
  val spec : PS.t
end) =
struct
  open X

  let terms_by_ret_type_ : (PS.meta_type, PS.dag_term list) Hashtbl.t =
    let res = Hashtbl.create 32 in
    List.iter
      (fun (t : PS.dag_term) ->
        let l = Hashtbl.find_opt res t.ret |> Option.value ~default:[] in
        Hashtbl.replace res t.ret (t :: l))
      spec.dag_terms;
    res

  let fun_name (s : string) : string =
    s |> String.uncapitalize_ascii
    |> String.map (function
         | '-' | '.' -> '_'
         | c -> c)

  let is_dag_type s : bool = Hashtbl.mem terms_by_ret_type_ (PS.M_ty s)

  let type_name s =
    if is_dag_type s then
      spf "%s_id.t" (capitalize s)
    else
      String.uncapitalize_ascii s |> function
      | "type" -> "ty"
      | "fun" -> "fn"
      | s -> s

  let rec type_of_meta_type (m : PS.meta_type) : string =
    match m with
    | M_ty s -> type_name s
    | M_list s -> spf "%s list" (type_of_meta_type s)
    | M_option s -> spf "%s option" (type_of_meta_type s)
    | M_tuple l ->
      spf "(%s)" @@ String.concat " * " @@ List.map type_of_meta_type l

  (** Emit code to encode [x:ty] to CBOR.

      Format for a command is a CBOR array [["command" "id" arg0 arg1…]] *)
  let rec encode_meta_type (ty : PS.meta_type) enc st (x : string) : string =
    match ty with
    | M_ty "Int" -> spf "Encoder.int %s %s %s" enc st x
    | M_ty "Int64" -> spf "Encoder.int64 %s %s %s" enc st x
    | M_ty "Bool" -> spf "Encoder.bool %s %s %s" enc st x
    | M_ty "String" -> spf "Encoder.text %s %s %s" enc st x
    | M_ty "Bytes" ->
      spf "Encoder.bytes %s %s (Bytes.unsafe_to_string %s)" enc st x
    | M_ty s when is_dag_type s ->
      spf "%s_id.encode %s %s %s" (capitalize s) enc st x
    | M_ty s -> failwith @@ spf "cannot encode type %S" s
    | M_list s ->
      spf "Encoder.array_l %s %s (fun enc st x -> %s) %s" enc st
        (encode_meta_type s "enc" "st" "x")
        x
    | M_option s ->
      spf "Encoder.nullable %s %s (fun enc st x -> %s) %s" enc st
        (encode_meta_type s "enc" "st" "x")
        x
    | M_tuple l ->
      let n = List.length l in
      spf
        "(let %s = %s in Encoder.array_begin %s %s ~len:%d; %s; \
         Encoder.array_end %s %s)"
        (String.concat "," @@ List.init n (spf "x_%d"))
        x enc st n
        (String.concat ";"
        @@ List.mapi (fun i ty -> encode_meta_type ty enc st (spf "x_%d" i)) l)
        enc st

  let codegen_encode_ (out : Buffer.t) : unit =
    (* declare ID types *)
    List.iter
      (fun (ty : PS.dag_type) ->
        bpf out "(** %s *)\n" ty.doc;
        bpf out "module %s_id = Make_id()\n" (capitalize ty.name);
        bpf out "\n")
      spec.dag_types;

    let emit_dag_term (t : PS.dag_term) : unit =
      let args_as_fun_params =
        List.mapi (fun i ty -> spf "(x%d : %s)" i (type_of_meta_type ty)) t.args
        |> String.concat " "
      in

      let name = Option.value t.full_name ~default:t.name in

      bpf out "(** %s *)\n" t.doc;
      bpf out "let %s ((Output.Out out):Output.t) %s : %s =\n" (fun_name name)
        args_as_fun_params (type_of_meta_type t.ret);
      (* array with space for "command", "id", and args *)
      bpf out "  let id = out.gen_id() in\n";
      bpf out "  Encoder.array_begin out.enc out.st ~len:%d;\n"
        (2 + List.length t.args);
      bpf out "  Encoder.text out.enc out.st %S;\n" t.name;
      bpf out "  Identifier.encode out.enc out.st id;\n";
      List.iteri
        (fun i (ty : PS.meta_type) ->
          bpf out "  %s;\n"
            (encode_meta_type ty "out.enc" "out.st" (spf "x%d" i)))
        t.args;
      bpf out "  Encoder.array_end out.enc out.st;\n";
      bpf out "  out.output_entry out.st;\n";

      (* return *)
      match t.ret with
      | M_ty s -> bpf out "  %s_id.make id\n\n" (capitalize s)
      | M_list (M_ty s) ->
        (* for each item, with index [i], use identifier [id.<i>] *)
        bpf out
          "  List.init %d (fun i -> %s_id.make @@ Identifier.append id (I i))"
          (List.length t.args) (capitalize s)
      | _ty ->
        failwith (spf "cannot handle return type %s" (PS.show_meta_type _ty))
    in

    Hashtbl.iter
      (fun (ty : PS.meta_type) ts ->
        bpf out "(** {2 constructors for %s} *)\n\n" (PS.show_meta_type ty);
        List.iter emit_dag_term ts;
        bpf out "\n")
      terms_by_ret_type_;

    let emit_builtin_sym (t : PS.builtin_symbol) =
      (* TODO: a comment with the type signature *)
      if t.ret = PS.M_ty "Type" then (
        assert (t.args = []);
        bpf out "let ty_builtin_%s (out: Output.t) : Type_id.t =\n"
          (String.uncapitalize_ascii t.name);
        bpf out "  ty_builtin out %S []\n\n" t.name
      ) else (
        let ty_params =
          String.concat " "
          @@ List.mapi (fun i _ty -> spf "(ty%d : Type_id.t)" i) t.params
        in
        let params =
          String.concat " "
          @@ List.mapi (fun i _ty -> spf "(x%d : Term_id.t)" i) t.args
        in

        let ml_name =
          match t.name with
          | "=" -> "eq"
          | "=>" -> "imply"
          | s -> String.uncapitalize_ascii s
        in

        bpf out "let t_builtin_%s (out: Output.t)%s%s : Term_id.t =\n" ml_name
          ty_params params;
        bpf out "  t_builtin out %S [%s] [%s]\n\n" t.name
          (String.concat ";" @@ List.mapi (fun i _ -> spf "ty%d" i) t.params)
          (String.concat ";" @@ List.mapi (fun i _ -> spf "x%d" i) t.args)
      )
    in

    (* shortcuts for builtins *)
    List.iter emit_builtin_sym spec.builtin_symbols;

    (* scope 0 *)
    bpf out "let scope0 : Scope_id.t = Scope_id.make (Identifier.I 0)\n";

    ()

  let codegen_decode_ (_out : Buffer.t) : unit =
    (* TODO: for all terms, add a type decl + decoder *)
    ()
end

let codegen (oc : out_channel) : unit =
  let module M = Make (struct
    let spec = PS.spec
  end) in
  let buf = Buffer.create 32 in
  bpf buf
    "(* auto-generated from spec.json by codegen_ocaml.ml, do not modify *)\n\n";
  bpf buf "%s\n" prelude;
  M.codegen_decode_ buf;
  M.codegen_encode_ buf;
  Buffer.output_buffer oc buf
