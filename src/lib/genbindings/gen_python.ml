open Common_

(* FIXME: for ca store key: we need to read a tag 7 around the actual value *)

(* Layout of the generated package (rooted at [out]):

   - [<pkg>/<module>.py]: one module per OCaml compilation unit, where [pkg]
     is derived from the OCaml library ([Imandrax_api] -> [core],
     [Imandrax_api_common] -> [common], [Imandrakit_error] -> [error], …).
     Names are relative to the OCaml module, eg.
     [Imandrax_api_common.Db_op.t_poly] becomes [common.db_op.DbOp].
     Decoders are named [<name>_of_twine].
   - [_runtime.py]: helpers shared by the generated modules.
   - [artifact.py]: the [Artifact] union and the artifact readers.
   - [__init__.py]: re-exports the legacy flat names
     ([Common_Db_op_t_poly], [Uid_of_twine], …) for backward compatibility. *)

let bpf = Printf.bprintf
let ( |? ) o x = Option.value ~default:x o
let ( ||? ) o o2 = CCOption.or_ o ~else_:o2

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t

let header =
  {|# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false
|}

let runtime =
  {|
"""Helpers shared by the generated modules."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from typing import Any, Never
from . import twine


def twine_result[T,E](d: twine.Decoder, off: int, d0: twine.DecoderFn[T], d1: twine.DecoderFn[E]) -> T | E:
    match d.get_cstor(off=off):
        case twine.Constructor(idx=0, args=args):
            args = tuple(args)
            return d0(d=d, off=args[0])
        case twine.Constructor(idx=1, args=args):
            args = tuple(args)
            return d1(d=d, off=args[0])
        case _:
            raise twine.Error('expected result')

type WithTag6[T] = T
type WithTag7[T] = T

def decode_with_tag[T](tag: int, d: twine.Decoder, off: int, d0: twine.DecoderFn[T]) -> WithTag7[T]:
    dec_tag = d.get_tag(off=off)
    if dec_tag.tag != tag:
        raise twine.Error(f'Expected tag {tag}, got tag {dec_tag.tag} at off=0x{off:x}')
    return d0(d=d, off=dec_tag.arg)

def decode_q(d: twine.Decoder, off:int) -> tuple[int,int]:
    num, denum = d.get_array(off=off)
    num = d.get_int(off=num)
    denum = d.get_int(off=denum)
    return num, denum

def decode_void(d: twine.Decoder, off: int) -> Never:
    raise twine.Error(f'Cannot decode Void at off=0x{off:x}')

type Custom_value = Any
def decode_custom_value(d: twine.Decoder, off: int) -> Custom_value:
    raise twine.Error(f'Cannot decode Eval.Value.Custom_value at off=0x{off:x}')
|}

let artifact_prelude =
  {|
"""Artifacts returned by ImandraX, and functions to read them."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from dataclasses import dataclass
from zipfile import ZipFile
import json
from typing import Any, assert_never
from . import twine
from . import _runtime as _rt
|}

let artifact_footer =
  {|

def read_artifact_data(data: bytes, kind: str) -> Artifact:
    'Read artifact from `data`, with artifact kind `kind`'
    decoder = artifact_decoders[kind]
    twine_dec = twine.Decoder(data)
    return decoder(twine_dec, twine_dec.entrypoint())

def read_artifact_zip(path: str) -> Artifact:
    'Read artifact from a zip file'
    with ZipFile(path) as f:
        manifest = json.loads(f.read('manifest.json'))
        kind = str(manifest['kind'])
        twine_data = f.read('data.twine')
    return read_artifact_data(data=twine_data, kind=kind)


@dataclass
class RegionStr:
    constraints_str: list[str] | None
    invariant_str: str | None
    model_str: dict[str, str] | None
    model_eval_str: str | None


type region_meta_value = (
    common_region.MetaAssoc[mir_term.Term]
    | common_region.MetaTerm[mir_term.Term]
    | common_region.MetaString[mir_term.Term]
)


def get_region_str_from_decomp_artifact(
    data: bytes,
    kind: str,
) -> list[RegionStr]:
    """Get string representation of regions from `mir.fun_decomp` artifact."""
    art: Artifact = read_artifact_data(data=data, kind=kind)
    match (art, kind):
        case (
            common_fun_decomp.FunDecomp(
                f_id=_f_id,
                f_args=_f_args,
                regions=regions,
            ) as _fun_decomp,
            'mir.fun_decomp',
        ):
            _fun_decomp: mir_fun_decomp.FunDecomp
            _f_id: core_uid.Uid
            _f_args: list[common_var.Var[mir_type.Type]]
            regions: list[common_region.Region[mir_term.Term, mir_type.Type]]

            return [unwrap_region_str(region) for region in regions]
        case _:
            raise Exception(
                f'Incorrect artifact type: {type(art)}, with {kind = }. Expected "mir.fun_decomp"'
            )


def unwrap_region_str(
    region: common_region.Region[mir_term.Term, mir_type.Type],
) -> RegionStr:
    """Get `RegionStr` from `Region.t`."""
    match region:
        case common_region.Region(
            constraints=_constraints,
            invariant=_invariant,
            meta=meta,
            status=_status,
        ):
            # Convert meta list to dict
            meta_d: dict[Any, Any] = dict(meta)

            # get `str` dict
            meta_str_raw = meta_d.get('str')
            assert meta_str_raw is not None, "Never: no 'str' in meta"

            # meta_str should be common_region.MetaAssoc[mir_term.Term]
            if not isinstance(meta_str_raw, common_region.MetaAssoc):
                raise ValueError(
                    f'Expected common_region.MetaAssoc, got {type(meta_str_raw)}'
                )

            meta_str_d: dict[Any, Any] = dict(meta_str_raw.arg)  # type: ignore[arg-type]

            # Extract constraints
            constraints_raw = meta_str_d.get('constraints')
            constraints: list[str] | None
            if constraints_raw is not None:
                constraints = [c.arg for c in constraints_raw.arg]
            else:
                constraints = None

            # Extract invariant
            invariant_raw = meta_str_d.get('invariant')
            invariant: str = invariant_raw.arg if invariant_raw is not None else ''

            # Extract model
            model_raw = meta_str_d.get('model')
            model: dict[str, str] = {}
            if model_raw is not None:
                model = {k: v.arg for (k, v) in model_raw.arg}

            # Extract model_eval (optional)
            model_eval: str | None = None
            if 'model_eval' in meta_str_d:
                model_eval_raw = meta_str_d['model_eval']
                if model_eval_raw is not None:
                    model_eval = model_eval_raw.arg

            return RegionStr(
                invariant_str=invariant,
                constraints_str=constraints,
                model_str=model,
                model_eval_str=model_eval,
            )
        case _:
            assert_never(region)
|}

(* modules referenced by [artifact_footer] *)
let artifact_footer_types =
  [
    "Imandrax_api.Uid.t";
    "Imandrax_api_common.Var.t_poly";
    "Imandrax_api_common.Region.t_poly";
    "Imandrax_api_common.Fun_decomp.t_poly";
    "Imandrax_api_mir.Type.t";
    "Imandrax_api_mir.Term.t";
    "Imandrax_api_mir.Fun_decomp.t";
  ]

(* Naming
   ====== *)

(** Flat name used by the previous single-file bindings, eg.
    [Imandrax_api_common.Db_op.t_poly] -> [Common_Db_op_t_poly]. Still used for
    the backward-compatible re-exports, and to look up type references. *)
let legacy_ty_name (s : string) : string =
  let s =
    CCString.chop_prefix ~pre:"Imandrax_api." s
    ||? CCString.chop_prefix ~pre:"Imandrax_api_" s
    ||? CCString.chop_prefix ~pre:"Imandrakit_" s
    |? s
  in
  let s = CCString.chop_suffix ~suf:".t" s |? s in
  String.capitalize_ascii s |> CCString.replace ~sub:"." ~by:"_"

let legacy_cstor_name ~tyname (c : string) : string =
  spf "%s_%s" (legacy_ty_name tyname) (String.capitalize_ascii c)

let mangle_field_name (s : string) : string =
  let s = String.uncapitalize_ascii s in
  match s with
  | "from" -> "from_"
  | _ -> s

let decoder_name (pyname : string) : string = spf "%s_of_twine" pyname

type loc = {
  pkg: string;  (** python sub-package, eg. ["common"] *)
  modname: string;  (** python module, eg. ["db_op"] *)
  ocaml_mod: string;  (** OCaml compilation unit, eg. ["Db_op"] *)
  inner: string list;  (** nested modules, then the type name *)
}
(** Where an OCaml type definition lives in the generated package *)

let modkey (l : loc) = spf "%s.%s" l.pkg l.modname
let mod_alias (l : loc) = spf "%s_%s" l.pkg l.modname

let loc_of_def_name (s : string) : loc =
  match String.split_on_char '.' s with
  | lib :: m :: (_ :: _ as inner) ->
    let pkg =
      match lib with
      | "Imandrax_api" -> "core"
      | "Imandrakit_error" -> "error"
      | _ ->
        (match CCString.chop_prefix ~pre:"Imandrax_api_" lib with
        | Some p -> p
        | None -> failwith (spf "genpython: unknown library for type %S" s))
    in
    {
      pkg = String.lowercase_ascii pkg;
      modname = String.lowercase_ascii m;
      ocaml_mod = m;
      inner;
    }
  | _ -> failwith (spf "genpython: unexpected type name %S" s)

let split_last (l : 'a list) : 'a list * 'a =
  match List.rev l with
  | [] -> assert false
  | x :: rev_rest -> List.rev rev_rest, x

(** [t_poly] -> [t], [poly] -> [t], [t_] -> [t], [shallow_poly] -> [shallow] *)
let strip_poly (n : string) : string =
  let s = CCString.chop_suffix ~suf:"_poly" n |? n in
  let s =
    if s = "poly" then
      "t"
    else
      s
  in
  CCString.chop_suffix ~suf:"_" s |? s

(** The main type of [Db_op] is named after the module; other types are named
    after their nested modules and OCaml name, eg. [Ty_view.decl] -> [Decl],
    [PO_res.Shallow.t] -> [Shallow]. Names are then camel-cased by [mk_ent]. *)
let join_ty_name ~(loc : loc) (parts : string list) : string =
  match parts with
  | [] -> loc.ocaml_mod
  | _ -> String.capitalize_ascii (String.concat "_" parts)

let python_reserved : Str_set.t =
  Str_set.of_list
    [
      "None";
      "True";
      "False";
      "Ellipsis";
      "NotImplemented";
      "Exception";
      "BaseException";
      "ValueError";
      "TypeError";
    ]

type name_ent = {
  cands: string array;
  rank: int;
  mutable idx: int;
}
(** A python name to be picked among [cands], by order of preference. On a
    clash, the entity with the lowest [rank] keeps its name and the others fall
    back to their next candidate. *)

(** OCaml spelling to python class naming, eg. [Op_add_rw] -> [OpAddRw],
    [PO_res] -> [PORes] *)
let camel_case (s : string) : string =
  String.split_on_char '_' s
  |> List.map String.capitalize_ascii
  |> String.concat ""

(** Short upper-case prefix of a constructor, eg. [A] for [A_term] *)
let cstor_tag (c : string) : string option =
  match String.split_on_char '_' c with
  | tag :: _ :: _
    when String.length tag <= 2 && String.uppercase_ascii tag = tag ->
    Some tag
  | _ -> None

(** Tags shared by at least two of [cstors] *)
let cstor_tags (cstors : string list) : string list =
  let tags = List.filter_map cstor_tag cstors in
  List.filter
    (fun t -> List.length (List.filter (String.equal t) tags) >= 2)
    (CCList.uniq ~eq:String.equal tags)

(** Like [camel_case], but a tag in [tags] at the start of a constructor keeps
    its underscore, eg. [A_term] -> [A_Term], [PH_id] -> [PH_Id],
    [E_proved_by_smt] -> [E_ProvedBySmt]. A prefix that is not shared with a
    sibling is not a tag, eg. [N_steps] -> [NSteps]. *)
let camel_case_cstor ~(tags : string list) (c : string) : string =
  match cstor_tag c with
  | Some tag when List.mem tag tags ->
    let rest = CCString.drop (String.length tag + 1) c in
    spf "%s_%s" tag (camel_case rest)
  | _ -> camel_case c

(** [cands] must already be python names *)
let mk_ent ~rank (cands : string list) : name_ent =
  let cands =
    CCList.uniq ~eq:String.equal cands
    |> List.filter (fun c -> not (Str_set.mem c python_reserved))
  in
  if cands = [] then failwith "genpython: no valid python name";
  { cands = Array.of_list cands; rank; idx = 0 }

let ent_name (e : name_ent) = e.cands.(e.idx)

let resolve_names ~what (ents : name_ent list) : unit =
  let rec loop () =
    let groups = Hashtbl.create 16 in
    List.iter
      (fun e ->
        let n = ent_name e in
        Hashtbl.replace groups n (e :: (Hashtbl.find_opt groups n |? [])))
      ents;
    let changed = ref false in
    Hashtbl.iter
      (fun name es ->
        match es with
        | [] | [ _ ] -> ()
        | _ ->
          let best = List.fold_left (fun m e -> min m e.rank) max_int es in
          let n_best = List.length (List.filter (fun e -> e.rank = best) es) in
          List.iter
            (fun e ->
              if e.rank > best || n_best > 1 then (
                if e.idx + 1 >= Array.length e.cands then
                  failwith
                    (spf "genpython: cannot find a unique name for %S in %s"
                       name what);
                e.idx <- e.idx + 1;
                changed := true
              ))
            es)
      groups;
    if !changed then loop ()
  in
  loop ()

type ty_info = {
  loc: loc;
  def: tydef;
  mutable pyname: string;
  mutable cstor_names: string list;  (** same order as the constructors *)
}

let ty_name_ent (loc : loc) : name_ent =
  let ms, n = split_last loc.inner in
  let s = strip_poly n in
  let name n =
    join_ty_name ~loc
      (ms
      @
      if n = "t" then
        []
      else
        [ n ])
  in
  let keep_poly =
    match CCString.chop_suffix ~suf:"_poly" n with
    | Some s1 when s1 <> "t" -> [ name n ]
    | _ -> []
  in
  let rank =
    if n = "t" then
      0
    else if s = n then
      1
    else
      2
  in
  mk_ent ~rank
  @@ List.map camel_case
       ((name s :: keep_poly)
       @ [ spf "%s_%s" loc.ocaml_mod (String.concat "_" loc.inner) ])

let is_main_ty (loc : loc) : bool =
  match loc.inner with
  | [ n ] -> strip_poly n = "t"
  | _ -> false

(** Assign python names to every type and constructor. The result is indexed by
    the legacy name of each type. *)
let build_names (defs : tydef list) : (string, ty_info) Hashtbl.t =
  let infos =
    List.map
      (fun (def : tydef) ->
        { loc = loc_of_def_name def.name; def; pyname = ""; cstor_names = [] })
      defs
  in
  let by_mod = Hashtbl.create 64 in
  List.iter
    (fun info ->
      let k = modkey info.loc in
      Hashtbl.replace by_mod k (info :: (Hashtbl.find_opt by_mod k |? [])))
    infos;

  Hashtbl.iter
    (fun k infos ->
      let infos = List.rev infos in
      let ty_ents = List.map (fun info -> info, ty_name_ent info.loc) infos in
      resolve_names ~what:k (List.map snd ty_ents);
      List.iter (fun (info, e) -> info.pyname <- ent_name e) ty_ents;

      (* type names are fixed, constructors avoid them *)
      let fixed =
        List.map (fun info -> mk_ent ~rank:(-1) [ info.pyname ]) infos
      in
      let cstor_ents =
        List.map
          (fun info ->
            match info.def.decl with
            | Alg cstors ->
              let tags =
                cstor_tags (List.map (fun (c : TR.Ty_def.cstor) -> c.c) cstors)
              in
              (* constructors that all share a tag are already distinctive,
                 eg. [V_int] -> [V_Int] rather than [ViewV_Int] *)
              let all_tagged =
                List.for_all
                  (fun (c : TR.Ty_def.cstor) ->
                    match cstor_tag c.c with
                    | Some t -> List.mem t tags
                    | None -> false)
                  cstors
              in
              ( info,
                List.map
                  (fun (c : TR.Ty_def.cstor) ->
                    let c = camel_case_cstor ~tags c.c in
                    mk_ent ~rank:0
                      ((if is_main_ty info.loc || all_tagged then
                          [ c ]
                        else
                          [])
                      @ [ info.pyname ^ c ]))
                  cstors )
            | _ -> info, [])
          infos
      in
      resolve_names ~what:k (fixed @ List.concat_map snd cstor_ents);
      List.iter
        (fun (info, es) -> info.cstor_names <- List.map ent_name es)
        cstor_ents)
    by_mod;

  let tbl = Hashtbl.create 256 in
  List.iter
    (fun info -> Hashtbl.replace tbl (legacy_ty_name info.def.name) info)
    infos;
  tbl

(* Code generation
   =============== *)

type ctx = {
  names: (string, ty_info) Hashtbl.t;
  cur: string option;  (** module being generated, [None] for the root *)
  local: Str_set.t;  (** names defined in the current module *)
  mutable imports: loc Str_map.t;
}

let find_ty (ctx : ctx) (s : string) : ty_info =
  match Hashtbl.find_opt ctx.names (legacy_ty_name s) with
  | Some info -> info
  | None -> failwith (spf "genpython: unknown type %S" s)

(** Refer to [name], defined in the module of [info], from the current module *)
let qualify (ctx : ctx) (info : ty_info) (name : string) : string =
  let k = modkey info.loc in
  if Some k = ctx.cur then
    name
  else (
    ctx.imports <- Str_map.add k info.loc ctx.imports;
    spf "%s.%s" (mod_alias info.loc) name
  )

let mangle_ty_var (ctx : ctx) (s : string) : string =
  let s = CCString.chop_prefix ~pre:"_tyreg_poly_" s |? s in
  let s = String.capitalize_ascii s in
  if Str_set.mem s ctx.local then
    "_" ^ s
  else
    s

let rec gen_type_expr (ctx : ctx) (ty : tyexpr) : string =
  let recurse = gen_type_expr ctx in
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> mangle_ty_var ctx s
  | Tuple l -> spf "tuple[%s]" (String.concat ", " @@ List.map recurse l)
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    "bytes"
  | Attrs (ty, _attrs) ->
    if List.mem_assoc "ocaml_only" _attrs then
      Printf.eprintf "warning: remaining `ocaml_only` attr\n%!";
    recurse ty
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "int64" | "Util_twine.Z.t" | "Z.t" | "_Z.t"), [] -> "int"
    | "string", [] -> "str"
    | "bool", [] -> "bool"
    | "array", [ x ] | "list", [ x ] -> spf "list[%s]" (recurse x)
    | "float", [] -> "float"
    | "unit", [] -> "None"
    | "Void.t", [] -> "typing.Never"
    | "B.t", [] -> "int" (* bllbll bitfield *)
    | "Uid.Set.t", [] ->
      let uid = find_ty ctx "Imandrax_api.Uid.t" in
      spf "set[%s]" (qualify ctx uid uid.pyname)
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> "float"
    | "Error.result", [ x ] ->
      let err = find_ty ctx "Imandrakit_error.Error_core.t" in
      spf "%s | %s" (qualify ctx err err.pyname) (recurse x)
    | "Util_twine.Result.t", [ x; y ] -> spf "%s | %s" (recurse x) (recurse y)
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "None"
    | "Imandrax_api_eval__Value.Custom_value.t", [] -> "_rt.Custom_value"
    | "option", [ x ] -> spf "None | %s" (recurse x)
    | "Util_twine.With_tag7.t", [ x ] -> spf "_rt.WithTag7[%s]" (recurse x)
    | "Util_twine.With_tag6.t", [ x ] -> spf "_rt.WithTag6[%s]" (recurse x)
    | "Util_twine.Q.t", [] -> "tuple[int, int]"
    | s, [] ->
      let info = find_ty ctx s in
      qualify ctx info info.pyname
    | _ ->
      let info = find_ty ctx s in
      spf "%s[%s]"
        (qualify ctx info info.pyname)
        (String.concat ", " @@ List.map recurse args))

let rec of_twine_of_type_expr (ctx : ctx) (ty : tyexpr) ~off : string =
  let recurse = of_twine_of_type_expr ctx in
  match ty with
  | Arrow (_, _, _) -> assert false
  | Var s -> spf "decode_%s(d=d, off=%s)" (mangle_ty_var ctx s) off
  | Tuple l ->
    spf "(lambda tup: (%s))(tuple(d.get_array(off=%s)))"
      (String.concat ", "
      @@ List.mapi (fun i ty -> recurse ~off:(spf "tup[%d]" i) ty) l)
      off
  | Attrs (Cstor ("string", []), attrs)
    when List.mem_assoc "twine.use_bytes" attrs ->
    spf "d.get_bytes(off=%s)" off
  | Attrs (ty, _) -> recurse ty ~off
  | Cstor (s, args) ->
    (match s, args with
    | ("int" | "int64" | "Util_twine.Z.t" | "Z.t" | "_Z.t"), [] ->
      spf "d.get_int(off=%s)" off
    | "string", [] -> spf "d.get_str(off=%s)" off
    | "bool", [] -> spf "d.get_bool(off=%s)" off
    | "array", [ x ] | "list", [ x ] ->
      spf "[%s for x in d.get_array(off=%s)]" (recurse ~off:"x" x) off
    | "float", [] -> spf "d.get_float(off=%s)" off
    | "unit", [] -> spf "d.get_null(off=%s)" off
    | "Void.t", [] -> spf "_rt.decode_void(d=d, off=%s)" off
    | "B.t", [] -> spf "d.get_int(off=%s)" off (* bllbll bitfield *)
    | "Uid.Set.t", [] ->
      spf "set(%s for x in d.get_array(off=%s))"
        (recurse (Cstor ("Imandrax_api.Uid.t", [])) ~off:"x")
        off
    | ("Timestamp_s.t" | "Duration_s.t"), [] -> spf "d.get_float(off=%s)" off
    | "Error.result", [ x ] ->
      let err = find_ty ctx "Imandrakit_error.Error_core.t" in
      spf
        "_rt.twine_result(d=d, off=%s, d0=lambda d, off: %s, d1=lambda d, off: \
         %s(d=d, off=off))"
        off (recurse x ~off:"off")
        (qualify ctx err (decoder_name err.pyname))
    | "Util_twine.Result.t", [ x; y ] ->
      spf
        "_rt.twine_result(d=d, off=%s, d0=lambda d, off: %s, d1=lambda d, off: \
         %s)"
        off (recurse x ~off:"off") (recurse y ~off:"off")
    | "Imandrakit_error__Error_core.Data.t", [] -> spf "None"
    | "Imandrax_api_eval__Value.Custom_value.t", [] ->
      spf "_rt.decode_custom_value(d=d, off=%s)" off
    | "Util_twine.With_tag6.t", [ x ] ->
      spf "_rt.decode_with_tag(tag=6, d=d, off=%s, d0=lambda d, off: %s)" off
        (recurse x ~off:"off")
    | "Util_twine.With_tag7.t", [ x ] ->
      spf "_rt.decode_with_tag(tag=7, d=d, off=%s, d0=lambda d, off: %s)" off
        (recurse x ~off:"off")
    | "option", [ x ] ->
      spf "twine.optional(d=d, off=%s, d0=lambda d, off: %s)" off
        (recurse ~off:"off" x)
    | "Util_twine.Q.t", [] -> spf "_rt.decode_q(d=d, off=%s)" off
    | s, [] ->
      let info = find_ty ctx s in
      spf "%s(d=d, off=%s)" (qualify ctx info (decoder_name info.pyname)) off
    | _ ->
      let info = find_ty ctx s in
      let args =
        String.concat ", "
        @@ List.mapi
             (fun i ty ->
               spf "d%d=(lambda d, off: %s)" i (recurse ~off:"off" ty))
             args
      in
      spf "%s(d=d, off=%s, %s)"
        (qualify ctx info (decoder_name info.pyname))
        off args)

let skip_clique (clique : tydef list) =
  List.exists (fun (d : tydef) -> CCString.mem d.name ~sub:"Util_twine.") clique

(* TODO: ca store key (decode with tag) *)
let special_def (ctx : ctx) (info : ty_info) : string option =
  let pyname = info.pyname in
  match info.def.name with
  | "Imandrax_api.Uid_set.t" ->
    let uid = find_ty ctx "Imandrax_api.Uid.t" in
    Some
      (spf
         "type %s = set[%s]\n\n\
          def %s(d: twine.Decoder, off:int) -> %s:\n\
         \    return set(%s(d=d, off=x) for x in d.get_array(off=off))\n"
         pyname
         (qualify ctx uid uid.pyname)
         (decoder_name pyname) pyname
         (qualify ctx uid (decoder_name uid.pyname)))
  | "Imandrax_api.Chash.t" ->
    Some
      (spf
         "type %s = bytes\n\n\
          def %s(d: twine.Decoder, off:int) -> %s:\n\
         \    return d.get_bytes(off=off)\n"
         pyname (decoder_name pyname) pyname)
  | _ -> None

let gen_def ~(ctx : ctx) ~cached ~(buf : Buffer.t) (info : ty_info) : unit =
  let def = info.def in
  let pyname = info.pyname in
  let decoder = decoder_name pyname in
  bpf buf "# def %s\n" def.name;

  let pyparams, pytwine_params, params_decls, pytwine_params_kw =
    match def.params with
    | [] -> "", "", [], ""
    | _ ->
      let params =
        spf "[%s]"
          (String.concat ", " @@ List.map (mangle_ty_var ctx) def.params)
      and twine_params =
        spf "%s, "
          (String.concat ", "
          @@ List.mapi
               (fun i v ->
                 spf "d%d: twine.DecoderFn[%s]" i (mangle_ty_var ctx v))
               def.params)
      and params_decls =
        List.mapi
          (fun i v -> spf "decode_%s = d%d" (mangle_ty_var ctx v) i)
          def.params
      and twine_params_kw =
        spf ", %s"
          (String.concat ", "
          @@ List.mapi (fun i _ -> spf "d%d=d%d" i i) def.params)
      in
      params, twine_params, params_decls, twine_params_kw
  in

  let cached_decorator =
    if cached then
      spf "@twine.cached(name=%S)\n" def.name
    else
      ""
  in

  let declare_ty () =
    match def.decl with
    | Alias ty ->
      bpf buf "type %s%s = %s\n\n" pyname pyparams (gen_type_expr ctx ty);
      bpf buf "%sdef %s%s(d: twine.Decoder, %soff: int) -> %s%s:\n"
        cached_decorator decoder pyparams pytwine_params pyname pyparams;
      List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
      bpf buf "    return %s\n" (of_twine_of_type_expr ctx ty ~off:"off")
    | Record r ->
      bpf buf "@dataclass(slots=True, frozen=True)\n";
      bpf buf "class %s%s:\n" pyname pyparams;
      List.iter
        (fun (field, ty) ->
          bpf buf "    %s: %s\n" (mangle_field_name field)
            (gen_type_expr ctx ty))
        r.fields;
      bpf buf "\n";

      bpf buf "%sdef %s%s(d: twine.Decoder, %soff: int) -> %s%s:\n"
        cached_decorator decoder pyparams pytwine_params pyname pyparams;
      if def.unboxed then (
        let field_name, field_ty =
          match r.fields with
          | [ hd ] -> hd
          | _ -> assert false
        in
        bpf buf "    x = %s # single unboxed field\n"
          (of_twine_of_type_expr ctx ~off:"off" field_ty);
        bpf buf "    return %s(%s=x)\n" pyname (mangle_field_name field_name)
      ) else (
        List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
        bpf buf "    fields = list(d.get_array(off=off))\n";
        List.iteri
          (fun i (field, ty) ->
            bpf buf "    %s = %s\n" (mangle_field_name field)
              (of_twine_of_type_expr ctx ~off:(spf "fields[%d]" i) ty))
          r.fields;
        bpf buf "    return %s(%s)\n" pyname
          (String.concat ", "
          @@ List.map
               (fun (field, _) ->
                 spf "%s=%s" (mangle_field_name field) (mangle_field_name field))
               r.fields)
      )
    | TR.Ty_def.Alg cstors ->
      let cstors = List.combine cstors info.cstor_names in
      List.iter
        (fun ((c : TR.Ty_def.cstor), c_pyname) ->
          let c_decoder = decoder_name c_pyname in
          bpf buf "@dataclass(slots=True, frozen=True)\n";
          bpf buf "class %s%s:\n" c_pyname pyparams;

          (match c.args, c.labels with
          | [], _ -> bpf buf "    pass\n"
          | [ x ], None ->
            bpf buf "    arg: %s\n\n" (gen_type_expr ctx x);
            bpf buf
              "%sdef %s%s(d: twine.Decoder, %s_tw_args: tuple[int, ...]) -> \
               %s%s:\n"
              cached_decorator c_decoder pyparams pytwine_params c_pyname
              pyparams;
            List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
            bpf buf "    arg = %s\n"
              (of_twine_of_type_expr ctx ~off:"_tw_args[0]" x);
            bpf buf "    return %s(arg=arg)\n" c_pyname
          | _, None ->
            bpf buf "    args: tuple[%s]\n\n"
              (String.concat ", " @@ List.map (gen_type_expr ctx) c.args);
            bpf buf
              "%sdef %s%s(d: twine.Decoder, %s_tw_args: tuple[int, ...]) -> \
               %s%s:\n"
              cached_decorator c_decoder pyparams pytwine_params c_pyname
              pyparams;
            List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
            bpf buf "    cargs = (%s)\n"
              (String.concat ", "
              @@ List.mapi
                   (fun i ty ->
                     of_twine_of_type_expr ctx ~off:(spf "_tw_args[%d]" i) ty)
                   c.args);
            bpf buf "    return %s(args=cargs)\n" c_pyname
          | _, Some labels ->
            List.iter2
              (fun lbl ty ->
                bpf buf "    %s: %s\n" (mangle_field_name lbl)
                  (gen_type_expr ctx ty))
              labels c.args;
            bpf buf "\n\n";
            bpf buf
              "%sdef %s%s(d: twine.Decoder, %s_tw_args: tuple[int, ...]) -> \
               %s%s:\n"
              cached_decorator c_decoder pyparams pytwine_params c_pyname
              pyparams;
            List.iter (fun s -> bpf buf "    %s\n" s) params_decls;
            CCList.iteri2
              (fun i lbl ty ->
                bpf buf "    %s = %s\n" (mangle_field_name lbl)
                  (of_twine_of_type_expr ctx ty ~off:(spf "_tw_args[%d]" i)))
              labels c.args;
            bpf buf "    return %s(%s)\n" c_pyname
              (String.concat ", "
              @@ List.map
                   (fun lbl ->
                     spf "%s=%s" (mangle_field_name lbl) (mangle_field_name lbl))
                   labels);
            bpf buf "\n");
          bpf buf "\n")
        cstors;

      bpf buf "type %s%s = " pyname pyparams;
      List.iteri
        (fun i (_, c_pyname) ->
          if i > 0 then bpf buf " | ";
          bpf buf "%s%s" c_pyname pyparams)
        cstors;
      bpf buf "\n\n";

      bpf buf "%sdef %s%s(d: twine.Decoder, %soff: int) -> %s%s:\n"
        cached_decorator decoder pyparams pytwine_params pyname pyparams;
      bpf buf "    match d.get_cstor(off=off):\n";
      List.iteri
        (fun i ((c : TR.Ty_def.cstor), c_pyname) ->
          bpf buf "         case twine.Constructor(idx=%d, args=args):\n" i;
          match c.args with
          | [] -> bpf buf "             return %s%s()\n" c_pyname pyparams
          | _ ->
            bpf buf "             args = tuple(args)\n";
            bpf buf "             return %s(d=d, _tw_args=args%s)\n"
              (decoder_name c_pyname) pytwine_params_kw)
        cstors;

      bpf buf "         case twine.Constructor(idx=idx):\n";
      bpf buf
        "             raise twine.Error(f'expected %s, got invalid constructor \
         {idx}')\n"
        pyname
  in

  (match special_def ctx info with
  | Some d -> bpf buf "%s" d
  | None -> declare_ty ());
  bpf buf "\n"

(* Output
   ====== *)

let mkdir_p (dir : string) : unit =
  if not (Sys.file_exists dir) then Sys.mkdir dir 0o755

let write_file (path : string) (content : string) : unit =
  let@ oc = CCIO.with_out path in
  output_string oc content

(** [from <rel><pkg> import <mod> as <prefix><alias>] for each import *)
let gen_imports ~rel ?(prefix = "") (imports : loc Str_map.t) : string =
  Str_map.to_list imports
  |> List.map (fun (_, l) ->
         spf "from %s%s import %s as %s%s\n" rel l.pkg l.modname prefix
           (mod_alias l))
  |> String.concat ""

let gen_all (names : string list) : string =
  spf "__all__ = [\n%s]\n" (String.concat "" @@ List.map (spf "    %S,\n") names)

type module_out = {
  m_loc: loc;
  m_ctx: ctx;
  m_buf: Buffer.t;
  mutable m_infos: ty_info list;  (** in reverse order *)
}

let gen_module_file ~out (m : module_out) : unit =
  let infos = List.rev m.m_infos in
  let body = Buffer.contents m.m_buf in
  let exports =
    List.concat_map (fun info -> info.cstor_names @ [ info.pyname ]) infos
  in
  let content =
    String.concat ""
      [
        header;
        spf "\n\"\"\"Types from the OCaml module `%s`.\"\"\"\n\n"
          (String.concat "."
          @@ List.filteri (fun i _ -> i < 2)
          @@ String.split_on_char '.' (List.hd infos).def.name);
        "from __future__ import annotations  # delaying typing: \
         https://peps.python.org/pep-0563/\n";
        "import typing\n";
        "from dataclasses import dataclass\n";
        "from .. import twine\n";
        "from .. import _runtime as _rt\n";
        gen_imports ~rel:".." m.m_ctx.imports;
        "\n";
        gen_all exports;
        "\n";
        body;
      ]
  in
  write_file
    (Filename.concat
       (Filename.concat out m.m_loc.pkg)
       (m.m_loc.modname ^ ".py"))
    content

let gen_artifact_file ~out ~names (artifacts : Artifact.t list) : unit =
  let ctx =
    { names; cur = None; local = Str_set.empty; imports = Str_map.empty }
  in
  List.iter
    (fun s ->
      let info = find_ty ctx s in
      ignore (qualify ctx info info.pyname : string))
    artifact_footer_types;

  let buf = Buffer.create 32 in
  bpf buf "\n\n# union of the types!\ntype Artifact = %s\n\n"
  @@ String.concat "|"
  @@ List.map (fun (a : Artifact.t) -> gen_type_expr ctx a.ty) artifacts;

  bpf buf "artifact_decoders: dict[str, twine.DecoderFn[Artifact]] = {\\\n";
  List.iter
    (fun (a : Artifact.t) ->
      bpf buf "  '%s': (lambda d, off: %s),\n" a.tag
        (of_twine_of_type_expr ctx ~off:"off" a.ty))
    artifacts;
  bpf buf "}\n";

  write_file
    (Filename.concat out "artifact.py")
    (String.concat ""
       [
         header;
         artifact_prelude;
         gen_imports ~rel:"." ctx.imports;
         Buffer.contents buf;
         artifact_footer;
       ])

(** Backward compatible flat names *)
let gen_root_init ~out ~(pkgs : string list) (infos : ty_info list) : unit =
  let buf = Buffer.create 1024 in
  bpf buf "%s" header;
  bpf buf
    "\n\
     \"\"\"Python bindings for the ImandraX API types.\n\n\
     Types live in one module per OCaml module, eg. `lib.common.region.Region`\n\
     for `Imandrax_api_common.Region.t_poly`. The flat names of earlier versions\n\
     (eg. `Common_Region_t_poly`) are re-exported here for backward \
     compatibility.\n\
     \"\"\"\n\n";
  bpf buf "from . import twine as twine\n";
  bpf buf "from . import _runtime as _rt\n";
  List.iter (fun p -> bpf buf "from . import %s as %s\n" p p) pkgs;
  bpf buf "from . import artifact as artifact\n";
  List.iter
    (fun n -> bpf buf "from .artifact import %s as %s\n" n n)
    [
      "Artifact";
      "artifact_decoders";
      "read_artifact_data";
      "read_artifact_zip";
      "RegionStr";
      "region_meta_value";
      "get_region_str_from_decomp_artifact";
      "unwrap_region_str";
    ];
  let imports =
    List.fold_left
      (fun m info -> Str_map.add (modkey info.loc) info.loc m)
      Str_map.empty infos
  in
  bpf buf "%s" (gen_imports ~rel:"." ~prefix:"_" imports);

  bpf buf "\n# Legacy flat names\n# =================\n\n";
  bpf buf "twine_result = _rt.twine_result\n";
  bpf buf "type WithTag6[T] = _rt.WithTag6[T]\n";
  bpf buf "type WithTag7[T] = _rt.WithTag7[T]\n";
  bpf buf "decode_with_tag = _rt.decode_with_tag\n";
  bpf buf "decode_q = _rt.decode_q\n";
  bpf buf "Void_of_twine = _rt.decode_void\n";
  bpf buf "Eval__Value_Custom_value = _rt.Custom_value\n";
  bpf buf "Eval__Value_Custom_value_of_twine = _rt.decode_custom_value\n";
  (let err =
     List.find
       (fun info -> info.def.name = "Imandrakit_error.Error_core.t")
       infos
   in
   bpf buf "Error = _%s.%s\n" (mod_alias err.loc) err.pyname);
  List.iter
    (fun info ->
      let m = "_" ^ mod_alias info.loc in
      let legacy = legacy_ty_name info.def.name in
      bpf buf "\n";
      (match info.def.decl with
      | Alg cstors ->
        List.iter2
          (fun (c : TR.Ty_def.cstor) c_pyname ->
            let legacy_c = legacy_cstor_name ~tyname:info.def.name c.c in
            bpf buf "%s = %s.%s\n" legacy_c m c_pyname;
            if c.args <> [] then
              bpf buf "%s_of_twine = %s.%s\n" legacy_c m (decoder_name c_pyname))
          cstors info.cstor_names
      | _ -> ());
      bpf buf "%s = %s.%s\n" legacy m info.pyname;
      bpf buf "%s_of_twine = %s.%s\n" legacy m (decoder_name info.pyname))
    infos;
  write_file (Filename.concat out "__init__.py") (Buffer.contents buf)

let gen_pkg_init ~out (pkg : string) (mods : string list) : unit =
  let content =
    String.concat ""
      (header :: "\n"
      :: List.map (fun m -> spf "from . import %s as %s\n" m m) mods)
  in
  write_file (Filename.concat (Filename.concat out pkg) "__init__.py") content

let gen ~out ~(artifacts : Artifact.t list) ~types:(cliques : Ty_set.t list) ()
    : unit =
  let cliques =
    List.filter (fun (set : Ty_set.t) -> not (skip_clique set.clique)) cliques
  in
  let names =
    build_names (List.concat_map (fun (s : Ty_set.t) -> s.clique) cliques)
  in

  (* modules, in order of first appearance *)
  let modules : (string, module_out) Hashtbl.t = Hashtbl.create 64 in
  let order = ref [] in
  let get_module (info : ty_info) : module_out =
    let k = modkey info.loc in
    match Hashtbl.find_opt modules k with
    | Some m -> m
    | None ->
      let local =
        Hashtbl.fold
          (fun _ i acc ->
            if modkey i.loc = k then
              List.fold_left
                (fun acc n -> Str_set.add n acc)
                (Str_set.add i.pyname acc) i.cstor_names
            else
              acc)
          names Str_set.empty
      in
      let m =
        {
          m_loc = info.loc;
          m_ctx = { names; cur = Some k; local; imports = Str_map.empty };
          m_buf = Buffer.create 1024;
          m_infos = [];
        }
      in
      Hashtbl.add modules k m;
      order := k :: !order;
      m
  in

  let all_infos = ref [] in
  List.iter
    (fun (set : Ty_set.t) ->
      List.iter
        (fun (def : tydef) ->
          let info = Hashtbl.find names (legacy_ty_name def.name) in
          let m = get_module info in
          m.m_infos <- info :: m.m_infos;
          all_infos := info :: !all_infos;
          gen_def ~ctx:m.m_ctx ~cached:set.cached ~buf:m.m_buf info)
        set.clique)
    cliques;
  let order = List.rev !order in

  mkdir_p out;
  write_file (Filename.concat out "_runtime.py") (header ^ runtime);
  let pkgs =
    CCList.uniq ~eq:String.equal
    @@ List.map (fun k -> (Hashtbl.find modules k).m_loc.pkg) order
  in
  List.iter
    (fun pkg ->
      mkdir_p (Filename.concat out pkg);
      gen_pkg_init ~out pkg
        (List.filter_map
           (fun k ->
             let m = Hashtbl.find modules k in
             if m.m_loc.pkg = pkg then
               Some m.m_loc.modname
             else
               None)
           order))
    pkgs;
  List.iter (fun k -> gen_module_file ~out (Hashtbl.find modules k)) order;
  gen_artifact_file ~out ~names artifacts;
  gen_root_init ~out ~pkgs (List.rev !all_infos);
  ()
