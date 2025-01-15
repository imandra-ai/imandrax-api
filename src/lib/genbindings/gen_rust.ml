open Common_

let bpf = Printf.bprintf
let fpf = Printf.fprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let prelude =
  {|
// automatically generated using genbindings.ml, do not edit

#![allow(non_camel_case_types)]

// do not format
#![cfg_attr(any(), rustfmt::skip)]


pub mod deser;
pub use deser::FromTwine;
pub mod utils;
use utils::*;

//use bumpalo::Bump;
use num_bigint::BigInt;
use num_rational::BigRational as Rational;
//use anyhow::bail;

pub type Error<'a> = ErrorError_core<'a>;

pub type UidSet<'a> = [Uid<'a>];
pub type Var_set<'a> = UidSet<'a>;

// def Uid_set_of_twine(d, off:int) -> UidSet:
//      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off)) 
|}

(* TODO:
   - find which types are immediate, in advance (build a set of them).
       that includes some the special primitives below (bool, f64, etc.)
       as well as nullary struct, true enums, etc.

       we must carry around some state with all the immediate types in it, because we
       need that info even deep in a typeexpr.
   - a struct/enum gets a 'a lifetime if >= 1 argument/cstor is not immediate
   - non immediate types in fields/cstors are stored via &'a (which takes care of
    recursive types)

   - ALSO: expand aliases eagerly, so we don't have to worry about phantom types in aliases.
   - for structs we might need phantom markers in a few places
*)

module State = struct
  type t = { immediate_types: Str_set.t } [@@deriving make]
end

let mangle_ty_name (s : string) : string =
  let s =
    CCString.chop_prefix ~pre:"Imandrax_api." s
    ||? CCString.chop_prefix ~pre:"Imandrax_api_" s
    ||? CCString.chop_prefix ~pre:"Imandrakit_" s
    |? s
  in
  let s = CCString.chop_suffix ~suf:".t" s |? s in
  let components = String.split_on_char '.' s in
  String.concat "" @@ List.map String.capitalize_ascii components

let mangle_field_name (s : string) : string =
  let s = String.uncapitalize_ascii s in
  match s with
  | "from" -> "from_"
  | _ -> s

let of_twine_of_ty_name (s : string) : string =
  let s = mangle_ty_name s in
  (* TODO: use the trait with ::<> *)
  spf "%s_of_twine" s

let mangle_cstor_name_def (c : TR.Ty_def.cstor) : string =
  spf "%s" (String.capitalize_ascii c.c)

let mangle_cstor_name_use ~tyname (c : TR.Ty_def.cstor) : string =
  spf "%s::%s" (mangle_ty_name tyname) (String.capitalize_ascii c.c)

type special_type = string * int * bool * (string list -> string)

let special_types : special_type Str_map.t =
  let mk0 name imm c = name, 0, imm, Fun.const c in
  let mk1 name imm c =
    ( name,
      1,
      imm,
      function
      | [ x ] -> c x
      | _ -> assert false )
  in
  let mk2 name imm c =
    ( name,
      2,
      imm,
      function
      | [ x; y ] -> c x y
      | _ -> assert false )
  in
  [
    mk0 "int" true "BigInt";
    mk0 "Util_twine_.Z.t" true "BigInt";
    mk0 "Z.t" true "BigInt";
    mk0 "_Z.t" true "BigInt";
    mk0 "string" false "&'a str";
    mk0 "bool" true "bool";
    mk1 "array" false (spf "&'a [%s]");
    mk1 "list" false (spf "&'a [%s]");
    mk0 "Imandrax_api.Uid_set.t" false "&'a UidSet<'a>";
    mk0 "Imandrax_api.Chash.t" false "Chash<'a>";
    mk0 "float" true "f64";
    mk0 "unit" true "()";
    mk0 "B.t" true "usize" (* bllbll bitfield *);
    mk0 "Imandrakit_error__Error_core.Data.t" true
      "Ignored /* data */" (* just skip *);
    mk0 "Imandrax_api_eval__Value.Custom_value.t" true
      "Ignored /* custom value */" (* just skip *);
    mk0 "Uid.Set.t" false "&'a UidSet<'a>";
    mk0 "Timestamp_s.t" true "f64";
    mk0 "Duration_s.t" true "f64";
    mk1 "Error.result" false (spf "&'a core::result::Result<%s,Error<'a>>");
    mk2 "Util_twine.Result.t" false (spf "&'a core::result::Result<%s, %s>");
    mk1 "option" true (spf "Option<%s>");
    mk0 "Void.t" true "Void";
    mk0 "Util_twine_.Q.t" true "Rational";
  ]
  |> List.map (fun ((name, _, _, _) as r) -> name, r)
  |> Str_map.of_list

let rec gen_type_expr (self : State.t) (ty : tyexpr) : string =
  let gen_type_expr = gen_type_expr self in
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "V%s" s
  | Tuple l -> spf "(%s)" (String.concat "," @@ List.map gen_type_expr l)
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    "&'a [u8]"
  | Attrs (ty, _) -> gen_type_expr ty
  | Cstor (s, args) ->
    let is_immediate = Str_set.mem s self.immediate_types in
    let lifetime_param =
      if is_immediate then
        []
      else
        [ "'a" ]
    in
    (match Str_map.find s special_types with
    | _name, arity, _imm, mk ->
      assert (arity = List.length args);
      let args = List.map gen_type_expr args in
      mk args
    | exception Not_found ->
      (match args with
      | [] when is_immediate -> spf "%s" (mangle_ty_name s)
      | [] -> spf "&'a %s<'a>" (mangle_ty_name s)
      | _ when is_immediate ->
        spf "&'a %s<%s>" (mangle_ty_name s)
          (String.concat "," @@ List.map gen_type_expr args)
      | _ ->
        spf "&'a %s<%s>" (mangle_ty_name s)
          (String.concat "," @@ lifetime_param @ List.map gen_type_expr args)))

let rec of_twine_of_type_expr (ty : tyexpr) ~off : string =
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "decode_%s(d=d,off=%s)" s off
  | Tuple l ->
    spf "(%s)" (String.concat "," @@ List.map (of_twine_of_type_expr ~off) l)
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    spf "d.get_bytes(off=%s)" off
  | Attrs (ty, _) -> of_twine_of_type_expr ty ~off
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "Util_twine_.Z.t" | "Z.t" | "_Z.t"), [] ->
      spf "d.get_int(off=%s)" off
    | "string", [] -> spf "d.get_str(off=%s)" off
    | "bool", [] -> spf "d.get_bool(off=%s)" off
    | "array", [ x ] | "list", [ x ] ->
      spf "[%s for x in d.get_array(off=%s)]"
        (of_twine_of_type_expr ~off:"x" x)
        off
    | "float", [] -> spf "d.get_float(off=%s)" off
    | "unit", [] -> spf "d.get_null(off=%s)" off
    | "B.t", [] -> spf "d.get_int(off=%s)" off (* bllbll bitfield *)
    | "Uid.Set.t", [] ->
      spf "set(%s for x in d.get_array(off=%s))"
        (of_twine_of_type_expr (Cstor ("Uid", [])) ~off:"x")
        off
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> spf "d.get_float(off=%s)" off
    | "Error.result", [ x ] ->
      spf
        "twine_result(d=d, off=%s, d0=lambda off: %s, d1=lambda off: \
         Error_Error_core_of_twine(d=d, off=off))"
        off
        (of_twine_of_type_expr x ~off:"off")
    | "Util_twine.result", [ x; y ] ->
      spf "twine_result(d=d, off=%s, d0=lambda off: %s, d1=lambda off: %s)" off
        (of_twine_of_type_expr x ~off:"off")
        (of_twine_of_type_expr y ~off:"off")
    | "option", [ x ] ->
      spf "twine.optional(d=d, off=%s, d0=lambda off: %s)" off
        (of_twine_of_type_expr ~off:"off" x)
    | "Util_twine_.Q.t", [] ->
      "string" (* TODO: add a decode_q function in prelude, use it *)
    | s, [] -> spf "%s(d=d, off=%s)" (of_twine_of_ty_name s) off
    | _ ->
      let args =
        String.concat ","
        @@ List.mapi
             (fun i ty ->
               spf "d%d=(lambda off: %s)" i
                 (of_twine_of_type_expr ~off:"off" ty))
             args
      in
      spf "%s(d=d,off=%s,%s)" (of_twine_of_ty_name s) off args)

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

let rec is_immediate_ty ~immediate_types (ty : tyexpr) : bool =
  let recurse = is_immediate_ty ~immediate_types in
  match ty with
  | Cstor (s, args) ->
    Str_set.mem s immediate_types && List.for_all recurse args
  | Attrs (Cstor ("string", []), attrs) ->
    List.mem_assoc "twine.use_bytes" attrs
  | Attrs (ty, _) -> recurse ty
  | Var _ -> true
  | Tuple l -> List.for_all recurse l
  | Arrow _ -> false

let is_immediate_cstor ~immediate_types (c : tycstor) =
  List.for_all (is_immediate_ty ~immediate_types) c.args

let is_flat_def ~immediate_types (d : tydef) : bool =
  match d.decl with
  | Alg cs -> List.for_all (is_immediate_cstor ~immediate_types) cs
  | Record { fields } ->
    List.for_all (fun (_, ty) -> is_immediate_ty ~immediate_types ty) fields
  | Alias _ -> false

let gen_clique (self : State.t) ~oc (clique : TR.Ty_def.clique) : unit =
  fpf oc "\n// clique %s\n"
    (String.concat "," @@ List.map (fun (d : tydef) -> d.name) clique);

  let gen_def (def : tydef) : unit =
    let buf = Buffer.create 32 in
    let rsname = mangle_ty_name def.name in

    let rsparams, _rs_twine_params, _params_decls, _rs_twine_params_kw =
      match def.params with
      | [] when is_flat_def ~immediate_types:self.immediate_types def ->
        "", "", [], ""
      | _ ->
        let lifetime_param_bound, lifetime_param_l =
          if is_flat_def ~immediate_types:self.immediate_types def then
            "", []
          else
            ":'a", [ "'a" ]
        in
        let params =
          spf "<%s>"
            (String.concat "," @@ lifetime_param_l
            @ List.map (fun v -> spf "V%s%s" v lifetime_param_bound) def.params
            )
        and twine_params =
          spf "%s,"
            (String.concat ","
            @@ List.mapi
                 (fun i v -> spf "d%d: Callable[...,_V%s]" i v)
                 def.params)
        and params_decls =
          List.mapi (fun i v -> spf "decode_%s = d%d" v i) def.params
        and twine_params_kw =
          spf "%s,"
            (String.concat ","
            @@ List.mapi (fun i _ -> spf "d%d=d%d" i i) def.params)
        in
        params, twine_params, params_decls, twine_params_kw
    in

    let declare_ty (def : tydef) =
      if Str_set.mem def.name self.immediate_types then bpf buf "// immediate\n";
      match def.decl with
      | Alias _ -> assert false (* expanded *)
      | Record r ->
        bpf buf "#[derive(Debug, Clone)]\n";
        bpf buf "pub struct %s%s {\n" rsname rsparams;
        List.iter
          (fun (field, ty) ->
            bpf buf "  pub %s: %s,\n" (mangle_field_name field)
              (gen_type_expr self ty))
          r.fields;
        bpf buf "}\n\n"
        (* bpf buf "fn %s_of_twine%s(d: twine.Decoder, %soff: int) -> %s {\n" *)
        (*   rsname rsparams rs_twine_params rsname; *)
        (* List.iter (fun s -> bpf buf "    %s\n" s) params_decls; *)
        (* List.iter *)
        (*   (fun (field, ty) -> *)
        (*     bpf buf "    %s = %s\n" (mangle_field_name field) *)
        (*       (of_twine_of_type_expr ~off:"off" ty)) *)
        (*   r.fields; *)
        (* bpf buf "    return %s(%s)\n" rsname *)
        (*   (String.concat "," *)
        (*   @@ List.map *)
        (*        (fun (field, _) -> *)
        (*          spf "%s=%s" (mangle_field_name field) (mangle_field_name field)) *)
        (*        r.fields); *)
        (* bpf buf "}\n" *)
      | TR.Ty_def.Alg cstors ->
        (* declare type *)
        bpf buf "#[derive(Debug, Clone)]\n";
        bpf buf "pub enum %s%s {\n" rsname rsparams;
        List.iter
          (fun (c : TR.Ty_def.cstor) ->
            let c_name = mangle_cstor_name_def c in
            match c.args, c.labels with
            | [], _ -> bpf buf "  %s,\n" c_name
            | [ x ], None -> bpf buf "  %s(%s),\n" c_name (gen_type_expr self x)
            | _, None ->
              bpf buf "  %s(%s),\n" c_name
                (String.concat "," @@ List.map (gen_type_expr self) c.args)
            | _, Some labels ->
              bpf buf "  %s {\n" c_name;
              List.iter2
                (fun lbl ty ->
                  bpf buf "    %s: %s,\n" (mangle_field_name lbl)
                    (gen_type_expr self ty))
                labels c.args;
              bpf buf "  },\n")
          cstors;
        bpf buf "}\n"
    in

    declare_ty def;
    Buffer.output_buffer oc buf
  in

  List.iter gen_def clique;
  ()

let find_immediate_types (cliques : tydef list list) : State.t =
  let set =
    ref
      (Str_map.values special_types
      |> Iter.filter_map (fun (name, _, imm, _) ->
             if imm then
               Some name
             else
               None)
      |> Str_set.of_iter)
  in
  let add_def (d : tydef) =
    let is_immediate =
      match d.decl with
      | Alias ty -> is_immediate_ty ~immediate_types:!set ty
      | Alg cs -> List.for_all (is_immediate_cstor ~immediate_types:!set) cs
      | Record { fields } ->
        List.for_all
          (fun (_, ty) -> is_immediate_ty ~immediate_types:!set ty)
          fields
    in
    if is_immediate then set := Str_set.add d.name !set
  in
  List.iter (List.iter add_def) cliques;
  State.make ~immediate_types:!set

let gen ~out ~artifacts:_ ~types:(cliques : TR.Ty_def.clique list) () : unit =
  let@ oc = CCIO.with_out out in

  (* aliases are complicated because sometimes they erase type
     variables, which in rust requires a phantom data *)
  let cliques = Expand_aliases.expand_aliases cliques in

  fpf oc "%s\n" prelude;
  let st = find_immediate_types cliques in
  List.iter
    (fun cl -> if not (skip_clique cl) then gen_clique st ~oc cl)
    cliques;

  ()
