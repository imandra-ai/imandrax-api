module PS = Imandra_proof_system
module Str_set = Set.Make (String)

let bpf = Printf.bprintf
let spf = Printf.sprintf
let capitalize = String.capitalize_ascii
let prelude = Preludes.ocaml_prelude

let terms_by_ret_type_ (spec : PS.t) : (string, PS.dag_term list) Hashtbl.t =
  let res = Hashtbl.create 32 in
  List.iter
    (fun (t : PS.dag_term) ->
      let l = Hashtbl.find_opt res t.ret |> Option.value ~default:[] in
      Hashtbl.replace res t.ret (t :: l))
    spec.dag_terms;
  res

let cstor_name (s : string) : string =
  s |> capitalize
  |> String.map (function
       | '-' | '.' -> '_'
       | c -> c)

let type_name s =
  String.uncapitalize_ascii s |> function
  | "type" -> "ty"
  | "fun" -> "fn"
  | s -> s

let field_name (s : string) : string = type_name s

let rec type_of_meta_type (m : PS.meta_type) : string =
  match m with
  | M_ty s -> type_name s
  | M_list s -> spf "%s list" (type_of_meta_type s)
  | M_option s -> spf "%s option" (type_of_meta_type s)
  | M_tuple l ->
    spf "(%s)" @@ String.concat " * " @@ List.map type_of_meta_type l

let codegen_decode_ (out : Buffer.t) (spec : PS.t) : unit =
  let emit fmt = bpf out fmt in

  (* do we need this?
     List.iter
       (fun (ty : PS.dag_type) ->
         emit "(** %s *)\n" ty.doc;
         emit "module %s_id = Make_id()\n" (capitalize ty.name);
         emit "\n")
       spec.dag_types;
  *)
  let terms_by_ret = terms_by_ret_type_ spec in

  (let first = ref true in

   let emitted = ref Str_set.empty in
   let get_prefix () =
     if !first then (
       first := false;
       "type"
     ) else
       "and"
   in

   Hashtbl.iter
     (fun (ty : string) ts ->
       emitted := Str_set.add ty !emitted;
       let prefix = get_prefix () in
       emit "%s %s =\n" prefix (type_name ty);
       List.iter
         (fun (t : PS.dag_term) ->
           let args =
             match t.args with
             | [] -> ""
             | l ->
               spf " of %s" @@ String.concat " * "
               @@ List.map type_of_meta_type l
           in

           emit "  | %s%s\n" (cstor_name t.name) args)
         ts;
       emit "\n")
     terms_by_ret;

   List.iter
     (fun (ty : PS.dag_type_def) ->
       match ty.def with
       | Some { struct_ = Some d; _ } when not (Str_set.mem ty.name !emitted) ->
         emitted := Str_set.add ty.name !emitted;

         let prefix = get_prefix () in
         emit "%s %s = {\n" prefix (type_name ty.name);
         List.iter
           (fun (field : PS.dag_type_field) ->
             emit "  %s: %s;\n"
               (field_name field.field_name)
               (type_of_meta_type field.ty))
           d;
         emit "}\n\n"
       | _ -> ())
     spec.dag_type_defs);

  ()

let codegen_encode_ (out : Buffer.t) (_spec : PS.t) : unit =
  let _emit fmt = bpf out fmt in

  (* TODO: for all terms, add a encoder function; same for all commands *)
  ()

let codegen (oc : out_channel) : unit =
  let buf = Buffer.create 32 in
  bpf buf "(* auto-generated from spec.json *)\n\n";
  bpf buf "%s\n" prelude;
  codegen_decode_ buf PS.spec;
  codegen_encode_ buf PS.spec;
  Buffer.output_buffer oc buf
