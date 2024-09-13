module PS = Imandra_proof_system

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

  let codegen_decode_ (out : Buffer.t) : unit =
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

      bpf out "let %s ((Output.Out out):Output.t) %s : %s =\n" (fun_name t.name)
        args_as_fun_params (type_of_meta_type t.ret);
      bpf out "  Buffer.reset out.buf;\n";
      bpf out "  let id = out.new_id out.st in\n";
      bpf out "  Cbor_enc.array_begin out.buf ~len:%d\n" (List.length t.args);
      (* FIXME: t.ret must be a string. Find a solution for mutually recursive functions :/,
         everything else returns a single ID *)
      bpf out "  %s_id.make id\n\n" (capitalize t.ret)
    in

    Hashtbl.iter
      (fun (ty : PS.meta_type) ts ->
        bpf out "(** {2 constructors for %s} *)\n\n" (PS.show_meta_type ty);
        List.iter emit_dag_term ts;
        bpf out "\n")
      terms_by_ret_type_;

    ()

  let codegen_encode_ (_out : Buffer.t) : unit =
    (* TODO: for all terms, add a encoder function; same for all commands *)
    ()
end

let codegen (oc : out_channel) : unit =
  let module M = Make (struct
    let spec = PS.spec
  end) in
  let buf = Buffer.create 32 in
  bpf buf "(* auto-generated from spec.json *)\n\n";
  bpf buf "%s\n" prelude;
  M.codegen_decode_ buf;
  M.codegen_encode_ buf;
  Buffer.output_buffer oc buf
