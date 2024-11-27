
# automatically generated using genbindings.ml, do not edit

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from dataclasses import dataclass
from zipfile import ZipFile
import json
from typing import Callable
from . import twine

__all__ = ['twine']

type Error = Error_Error_core
def twine_result[T,E](d: twine.Decoder, off: int, d0: Callable[...,T], d1: Callable[...,E]) -> T | E:
    match d.get_cstor(off=off):
        case twine.Constructor(idx=0, args=args):
            args = tuple(args)
            return d0(d=d, off=args[0])
        case twine.Constructor(idx=1, args=args):
            args = tuple(args)
            return d1(d=d, off=args[0])
        case _:
            raise twine.Error('expected result')

type WithTag7[T] = T

def decode_with_tag7[T](d: twine.Decoder, off: int, d0: [Callable[...,T]]) -> With_tag7[T]:
    tag = d.get_tag(off=off)
    if tag.tag != 7:
        raise Error(f'Expected tag 7, got tag {tag.tag} at off=0x{off:x}')
    return d0(d=d, off=tag.arg)

def decode_q(d: twine.Decoder, off:int) -> tuple[int,int]:
    num, denum = d.get_array(off=off)
    num = d.get_int(off=num)
    denum = d.get_int(off=denum)
    return num, denum
  

# clique Imandrakit_error.Kind.t
# def Imandrakit_error.Kind.t (mangled name: "Error_Kind")
@dataclass(slots=True, frozen=True)
class Error_Kind:
    name: str

def Error_Kind_of_twine(d: twine.Decoder, off: int) -> Error_Kind:
    x = d.get_str(off=off) # single unboxed field
    return Error_Kind(name=x)

# clique Imandrakit_error.Error_core.message
# def Imandrakit_error.Error_core.message (mangled name: "Error_Error_core_message")
@dataclass(slots=True, frozen=True)
class Error_Error_core_message:
    msg: str
    data: unit
    bt: None | str

def Error_Error_core_message_of_twine(d: twine.Decoder, off: int) -> Error_Error_core_message:
    fields = list(d.get_array(off=off))
    msg = d.get_str(off=fields[0])
    data = ()
    bt = twine.optional(d=d, off=fields[2], d0=lambda d, off: d.get_str(off=off))
    return Error_Error_core_message(msg=msg,data=data,bt=bt)

# clique Imandrakit_error.Error_core.stack
# def Imandrakit_error.Error_core.stack (mangled name: "Error_Error_core_stack")
type Error_Error_core_stack = list[Error_Error_core_message]

def Error_Error_core_stack_of_twine(d: twine.Decoder, off: int) -> Error_Error_core_stack:
    return [Error_Error_core_message_of_twine(d=d, off=x) for x in d.get_array(off=off)]

# clique Imandrakit_error.Error_core.t
# def Imandrakit_error.Error_core.t (mangled name: "Error_Error_core")
@dataclass(slots=True, frozen=True)
class Error_Error_core:
    process: str
    kind: Error_Kind
    msg: Error_Error_core_message
    stack: Error_Error_core_stack

def Error_Error_core_of_twine(d: twine.Decoder, off: int) -> Error_Error_core:
    fields = list(d.get_array(off=off))
    process = d.get_str(off=fields[0])
    kind = Error_Kind_of_twine(d=d, off=fields[1])
    msg = Error_Error_core_message_of_twine(d=d, off=fields[2])
    stack = Error_Error_core_stack_of_twine(d=d, off=fields[3])
    return Error_Error_core(process=process,kind=kind,msg=msg,stack=stack)

# clique Imandrax_api.Util_twine_.as_pair
# def Imandrax_api.Util_twine_.as_pair (mangled name: "Util_twine__as_pair")
@dataclass(slots=True, frozen=True)
class Util_twine__as_pair:
    num: int
    denum: int

def Util_twine__as_pair_of_twine(d: twine.Decoder, off: int) -> Util_twine__as_pair:
    fields = list(d.get_array(off=off))
    num = d.get_int(off=fields[0])
    denum = d.get_int(off=fields[1])
    return Util_twine__as_pair(num=num,denum=denum)

# clique Imandrax_api.Util_twine_.t
# def Imandrax_api.Util_twine_.t (mangled name: "Util_twine_")
type Util_twine_[_V_tyreg_poly_a] = "_V_tyreg_poly_a"

def Util_twine__of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Util_twine_:
    decode__tyreg_poly_a = d0
    return decode__tyreg_poly_a(d=d,off=off)

# clique Imandrax_api.Builtin_data.kind
# def Imandrax_api.Builtin_data.kind (mangled name: "Builtin_data_kind")
@dataclass(slots=True, frozen=True)
class Builtin_data_kind_Logic_core:
    logic_core_name: str


def Builtin_data_kind_Logic_core_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Builtin_data_kind_Logic_core:
    logic_core_name = d.get_str(off=args[0])
    return Builtin_data_kind_Logic_core(logic_core_name=logic_core_name)


@dataclass(slots=True, frozen=True)
class Builtin_data_kind_Special:
    tag: str


def Builtin_data_kind_Special_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Builtin_data_kind_Special:
    tag = d.get_str(off=args[0])
    return Builtin_data_kind_Special(tag=tag)


@dataclass(slots=True, frozen=True)
class Builtin_data_kind_Tactic:
    tac_name: str


def Builtin_data_kind_Tactic_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Builtin_data_kind_Tactic:
    tac_name = d.get_str(off=args[0])
    return Builtin_data_kind_Tactic(tac_name=tac_name)


type Builtin_data_kind = Builtin_data_kind_Logic_core| Builtin_data_kind_Special| Builtin_data_kind_Tactic

def Builtin_data_kind_of_twine(d: twine.Decoder, off: int) -> Builtin_data_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Builtin_data_kind_Logic_core_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Builtin_data_kind_Special_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Builtin_data_kind_Tactic_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Builtin_data_kind, got invalid constructor {idx}')

# clique Imandrax_api.Chash.t
# def Imandrax_api.Chash.t (mangled name: "Chash")
type Chash = bytes

def Chash_of_twine(d, off:int) -> Chash:
    return d.get_bytes(off=off)

# clique Imandrax_api.Cname.t
# def Imandrax_api.Cname.t (mangled name: "Cname")
@dataclass(slots=True, frozen=True)
class Cname:
    name: str
    chash: Chash

def Cname_of_twine(d: twine.Decoder, off: int) -> Cname:
    fields = list(d.get_array(off=off))
    name = d.get_str(off=fields[0])
    chash = Chash_of_twine(d=d, off=fields[1])
    return Cname(name=name,chash=chash)

# clique Imandrax_api.Uid.gen_kind
# def Imandrax_api.Uid.gen_kind (mangled name: "Uid_gen_kind")
@dataclass(slots=True, frozen=True)
class Uid_gen_kind_Local:
    pass

@dataclass(slots=True, frozen=True)
class Uid_gen_kind_To_be_rewritten:
    pass

type Uid_gen_kind = Uid_gen_kind_Local| Uid_gen_kind_To_be_rewritten

def Uid_gen_kind_of_twine(d: twine.Decoder, off: int) -> Uid_gen_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Uid_gen_kind_Local()
         case twine.Constructor(idx=1, args=args):
             return Uid_gen_kind_To_be_rewritten()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Uid_gen_kind, got invalid constructor {idx}')

# clique Imandrax_api.Uid.view
# def Imandrax_api.Uid.view (mangled name: "Uid_view")
@dataclass(slots=True, frozen=True)
class Uid_view_Generative:
    id: int
    gen_kind: Uid_gen_kind


def Uid_view_Generative_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Uid_view_Generative:
    id = d.get_int(off=args[0])
    gen_kind = Uid_gen_kind_of_twine(d=d, off=args[1])
    return Uid_view_Generative(id=id,gen_kind=gen_kind)


@dataclass(slots=True, frozen=True)
class Uid_view_Persistent:
    pass

@dataclass(slots=True, frozen=True)
class Uid_view_Cname:
    cname: Cname


def Uid_view_Cname_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Uid_view_Cname:
    cname = Cname_of_twine(d=d, off=args[0])
    return Uid_view_Cname(cname=cname)


@dataclass(slots=True, frozen=True)
class Uid_view_Builtin:
    kind: Builtin_data_kind


def Uid_view_Builtin_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Uid_view_Builtin:
    kind = Builtin_data_kind_of_twine(d=d, off=args[0])
    return Uid_view_Builtin(kind=kind)


type Uid_view = Uid_view_Generative| Uid_view_Persistent| Uid_view_Cname| Uid_view_Builtin

def Uid_view_of_twine(d: twine.Decoder, off: int) -> Uid_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Uid_view_Generative_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             return Uid_view_Persistent()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Uid_view_Cname_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Uid_view_Builtin_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Uid_view, got invalid constructor {idx}')

# clique Imandrax_api.Uid.t
# def Imandrax_api.Uid.t (mangled name: "Uid")
@dataclass(slots=True, frozen=True)
class Uid:
    name: str
    view: Uid_view

def Uid_of_twine(d: twine.Decoder, off: int) -> Uid:
    fields = list(d.get_array(off=off))
    name = d.get_str(off=fields[0])
    view = Uid_view_of_twine(d=d, off=fields[1])
    return Uid(name=name,view=view)

# clique Imandrax_api.Uid_set.t
# def Imandrax_api.Uid_set.t (mangled name: "Uid_set")
type Uid_set = set[Uid]

def Uid_set_of_twine(d, off:int) -> Uid_set:
      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off))

# clique Imandrax_api.Builtin.Fun.t
# def Imandrax_api.Builtin.Fun.t (mangled name: "Builtin_Fun")
@dataclass(slots=True, frozen=True)
class Builtin_Fun:
    id: Uid
    kind: Builtin_data_kind
    lassoc: bool
    commutative: bool
    connective: bool

def Builtin_Fun_of_twine(d: twine.Decoder, off: int) -> Builtin_Fun:
    fields = list(d.get_array(off=off))
    id = Uid_of_twine(d=d, off=fields[0])
    kind = Builtin_data_kind_of_twine(d=d, off=fields[1])
    lassoc = d.get_bool(off=fields[2])
    commutative = d.get_bool(off=fields[3])
    connective = d.get_bool(off=fields[4])
    return Builtin_Fun(id=id,kind=kind,lassoc=lassoc,commutative=commutative,connective=connective)

# clique Imandrax_api.Builtin.Ty.t
# def Imandrax_api.Builtin.Ty.t (mangled name: "Builtin_Ty")
@dataclass(slots=True, frozen=True)
class Builtin_Ty:
    id: Uid
    kind: Builtin_data_kind

def Builtin_Ty_of_twine(d: twine.Decoder, off: int) -> Builtin_Ty:
    fields = list(d.get_array(off=off))
    id = Uid_of_twine(d=d, off=fields[0])
    kind = Builtin_data_kind_of_twine(d=d, off=fields[1])
    return Builtin_Ty(id=id,kind=kind)

# clique Imandrax_api.Ty_view.adt_row
# def Imandrax_api.Ty_view.adt_row (mangled name: "Ty_view_adt_row")
@dataclass(slots=True, frozen=True)
class Ty_view_adt_row[_V_tyreg_poly_id,_V_tyreg_poly_t]:
    c: "_V_tyreg_poly_id"
    labels: None | list["_V_tyreg_poly_id"]
    args: list["_V_tyreg_poly_t"]
    doc: None | str

def Ty_view_adt_row_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],off: int) -> Ty_view_adt_row:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    fields = list(d.get_array(off=off))
    c = decode__tyreg_poly_id(d=d,off=fields[0])
    labels = twine.optional(d=d, off=fields[1], d0=lambda d, off: [decode__tyreg_poly_id(d=d,off=x) for x in d.get_array(off=off)])
    args = [decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=fields[2])]
    doc = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_str(off=off))
    return Ty_view_adt_row(c=c,labels=labels,args=args,doc=doc)

# clique Imandrax_api.Ty_view.rec_row
# def Imandrax_api.Ty_view.rec_row (mangled name: "Ty_view_rec_row")
@dataclass(slots=True, frozen=True)
class Ty_view_rec_row[_V_tyreg_poly_id,_V_tyreg_poly_t]:
    f: "_V_tyreg_poly_id"
    ty: "_V_tyreg_poly_t"
    doc: None | str

def Ty_view_rec_row_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],off: int) -> Ty_view_rec_row:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    fields = list(d.get_array(off=off))
    f = decode__tyreg_poly_id(d=d,off=fields[0])
    ty = decode__tyreg_poly_t(d=d,off=fields[1])
    doc = twine.optional(d=d, off=fields[2], d0=lambda d, off: d.get_str(off=off))
    return Ty_view_rec_row(f=f,ty=ty,doc=doc)

# clique Imandrax_api.Ty_view.decl
# def Imandrax_api.Ty_view.decl (mangled name: "Ty_view_decl")
@dataclass(slots=True, frozen=True)
class Ty_view_decl_Algebraic[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    arg: list[Ty_view_adt_row["_V_tyreg_poly_id","_V_tyreg_poly_t"]]

def Ty_view_decl_Algebraic_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],d2: Callable[...,_V_tyreg_poly_alias],args: tuple[int, ...]) -> Ty_view_decl_Algebraic[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    decode__tyreg_poly_alias = d2
    arg = [Ty_view_adt_row_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_id(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_t(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Ty_view_decl_Algebraic(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty_view_decl_Record[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    arg: list[Ty_view_rec_row["_V_tyreg_poly_id","_V_tyreg_poly_t"]]

def Ty_view_decl_Record_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],d2: Callable[...,_V_tyreg_poly_alias],args: tuple[int, ...]) -> Ty_view_decl_Record[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    decode__tyreg_poly_alias = d2
    arg = [Ty_view_rec_row_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_id(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_t(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Ty_view_decl_Record(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty_view_decl_Alias[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    target: "_V_tyreg_poly_alias"
    reexport_def: None | Ty_view_decl["_V_tyreg_poly_id","_V_tyreg_poly_t","_V_tyreg_poly_alias"]


def Ty_view_decl_Alias_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],d2: Callable[...,_V_tyreg_poly_alias],args: tuple[int, ...]) -> Ty_view_decl_Alias[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    decode__tyreg_poly_alias = d2
    target = decode__tyreg_poly_alias(d=d,off=args[0])
    reexport_def = twine.optional(d=d, off=args[1], d0=lambda d, off: Ty_view_decl_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_id(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_t(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_alias(d=d,off=off))))
    return Ty_view_decl_Alias(target=target,reexport_def=reexport_def)


@dataclass(slots=True, frozen=True)
class Ty_view_decl_Skolem[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    pass

@dataclass(slots=True, frozen=True)
class Ty_view_decl_Builtin[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    arg: Builtin_Ty

def Ty_view_decl_Builtin_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],d2: Callable[...,_V_tyreg_poly_alias],args: tuple[int, ...]) -> Ty_view_decl_Builtin[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    decode__tyreg_poly_id = d0
    decode__tyreg_poly_t = d1
    decode__tyreg_poly_alias = d2
    arg = Builtin_Ty_of_twine(d=d, off=args[0])
    return Ty_view_decl_Builtin(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty_view_decl_Other[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]:
    pass

type Ty_view_decl[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias] = Ty_view_decl_Algebraic[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]| Ty_view_decl_Record[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]| Ty_view_decl_Alias[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]| Ty_view_decl_Skolem[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]| Ty_view_decl_Builtin[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]| Ty_view_decl_Other[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]

def Ty_view_decl_of_twine[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_id],d1: Callable[...,_V_tyreg_poly_t],d2: Callable[...,_V_tyreg_poly_alias],off: int) -> Ty_view_decl:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Ty_view_decl_Algebraic_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Ty_view_decl_Record_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Ty_view_decl_Alias_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=3, args=args):
             return Ty_view_decl_Skolem[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]()
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Ty_view_decl_Builtin_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=5, args=args):
             return Ty_view_decl_Other[_V_tyreg_poly_id,_V_tyreg_poly_t,_V_tyreg_poly_alias]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Ty_view_decl, got invalid constructor {idx}')

# clique Imandrax_api.Ty_view.view
# def Imandrax_api.Ty_view.view (mangled name: "Ty_view_view")
@dataclass(slots=True, frozen=True)
class Ty_view_view_Var[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    arg: "_V_tyreg_poly_var"

def Ty_view_view_Var_of_twine[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_lbl],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Ty_view_view_Var[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    decode__tyreg_poly_lbl = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_t = d2
    arg = decode__tyreg_poly_var(d=d,off=args[0])
    return Ty_view_view_Var(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty_view_view_Arrow[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    args: tuple["_V_tyreg_poly_lbl","_V_tyreg_poly_t","_V_tyreg_poly_t"]

def Ty_view_view_Arrow_of_twine[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_lbl],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Ty_view_view_Arrow[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    decode__tyreg_poly_lbl = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_t = d2
    cargs = (decode__tyreg_poly_lbl(d=d,off=args[0]),decode__tyreg_poly_t(d=d,off=args[1]),decode__tyreg_poly_t(d=d,off=args[2]))
    return Ty_view_view_Arrow(args=cargs)

@dataclass(slots=True, frozen=True)
class Ty_view_view_Tuple[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    arg: list["_V_tyreg_poly_t"]

def Ty_view_view_Tuple_of_twine[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_lbl],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Ty_view_view_Tuple[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    decode__tyreg_poly_lbl = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_t = d2
    arg = [decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[0])]
    return Ty_view_view_Tuple(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty_view_view_Constr[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    args: tuple[Uid,list["_V_tyreg_poly_t"]]

def Ty_view_view_Constr_of_twine[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_lbl],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Ty_view_view_Constr[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]:
    decode__tyreg_poly_lbl = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_t = d2
    cargs = (Uid_of_twine(d=d, off=args[0]),[decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])])
    return Ty_view_view_Constr(args=cargs)

type Ty_view_view[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t] = Ty_view_view_Var[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]| Ty_view_view_Arrow[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]| Ty_view_view_Tuple[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]| Ty_view_view_Constr[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t]

def Ty_view_view_of_twine[_V_tyreg_poly_lbl,_V_tyreg_poly_var,_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_lbl],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_t],off: int) -> Ty_view_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Ty_view_view_Var_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Ty_view_view_Arrow_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Ty_view_view_Tuple_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Ty_view_view_Constr_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Ty_view_view, got invalid constructor {idx}')

# clique Imandrax_api.Stat_time.t
# def Imandrax_api.Stat_time.t (mangled name: "Stat_time")
@dataclass(slots=True, frozen=True)
class Stat_time:
    time_s: float

def Stat_time_of_twine(d: twine.Decoder, off: int) -> Stat_time:
    x = d.get_float(off=off) # single unboxed field
    return Stat_time(time_s=x)

# clique Imandrax_api.Sequent_poly.t
# def Imandrax_api.Sequent_poly.t (mangled name: "Sequent_poly")
@dataclass(slots=True, frozen=True)
class Sequent_poly[_V_tyreg_poly_term]:
    hyps: list["_V_tyreg_poly_term"]
    concls: list["_V_tyreg_poly_term"]

def Sequent_poly_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Sequent_poly:
    decode__tyreg_poly_term = d0
    fields = list(d.get_array(off=off))
    hyps = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[0])]
    concls = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[1])]
    return Sequent_poly(hyps=hyps,concls=concls)

# clique Imandrax_api.Misc_types.rec_flag
# def Imandrax_api.Misc_types.rec_flag (mangled name: "Misc_types_rec_flag")
@dataclass(slots=True, frozen=True)
class Misc_types_rec_flag_Recursive:
    pass

@dataclass(slots=True, frozen=True)
class Misc_types_rec_flag_Nonrecursive:
    pass

type Misc_types_rec_flag = Misc_types_rec_flag_Recursive| Misc_types_rec_flag_Nonrecursive

def Misc_types_rec_flag_of_twine(d: twine.Decoder, off: int) -> Misc_types_rec_flag:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Misc_types_rec_flag_Recursive()
         case twine.Constructor(idx=1, args=args):
             return Misc_types_rec_flag_Nonrecursive()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Misc_types_rec_flag, got invalid constructor {idx}')

# clique Imandrax_api.Misc_types.apply_label
# def Imandrax_api.Misc_types.apply_label (mangled name: "Misc_types_apply_label")
@dataclass(slots=True, frozen=True)
class Misc_types_apply_label_Nolabel:
    pass

@dataclass(slots=True, frozen=True)
class Misc_types_apply_label_Label:
    arg: str

def Misc_types_apply_label_Label_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Misc_types_apply_label_Label:
    arg = d.get_str(off=args[0])
    return Misc_types_apply_label_Label(arg=arg)

@dataclass(slots=True, frozen=True)
class Misc_types_apply_label_Optional:
    arg: str

def Misc_types_apply_label_Optional_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Misc_types_apply_label_Optional:
    arg = d.get_str(off=args[0])
    return Misc_types_apply_label_Optional(arg=arg)

type Misc_types_apply_label = Misc_types_apply_label_Nolabel| Misc_types_apply_label_Label| Misc_types_apply_label_Optional

def Misc_types_apply_label_of_twine(d: twine.Decoder, off: int) -> Misc_types_apply_label:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Misc_types_apply_label_Nolabel()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Misc_types_apply_label_Label_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Misc_types_apply_label_Optional_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Misc_types_apply_label, got invalid constructor {idx}')

# clique Imandrax_api.Logic_fragment.t
# def Imandrax_api.Logic_fragment.t (mangled name: "Logic_fragment")
type Logic_fragment = int

def Logic_fragment_of_twine(d: twine.Decoder, off: int) -> Logic_fragment:
    return d.get_int(off=off)

# clique Imandrax_api.In_mem_archive.raw
# def Imandrax_api.In_mem_archive.raw (mangled name: "In_mem_archive_raw")
@dataclass(slots=True, frozen=True)
class In_mem_archive_raw:
    ty: str
    compressed: bool
    data: bytes

def In_mem_archive_raw_of_twine(d: twine.Decoder, off: int) -> In_mem_archive_raw:
    fields = list(d.get_array(off=off))
    ty = d.get_str(off=fields[0])
    compressed = d.get_bool(off=fields[1])
    data = d.get_bytes(off=fields[2])
    return In_mem_archive_raw(ty=ty,compressed=compressed,data=data)

# clique Imandrax_api.In_mem_archive.t
# def Imandrax_api.In_mem_archive.t (mangled name: "In_mem_archive")
type In_mem_archive[_V_tyreg_poly_a] = In_mem_archive_raw

def In_mem_archive_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> In_mem_archive:
    decode__tyreg_poly_a = d0
    return In_mem_archive_raw_of_twine(d=d, off=off)

# clique Imandrax_api.Const.t
# def Imandrax_api.Const.t (mangled name: "Const")
@dataclass(slots=True, frozen=True)
class Const_Const_float:
    arg: float

def Const_Const_float_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_float:
    arg = d.get_float(off=args[0])
    return Const_Const_float(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_string:
    arg: str

def Const_Const_string_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_string:
    arg = d.get_str(off=args[0])
    return Const_Const_string(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_z:
    arg: int

def Const_Const_z_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_z:
    arg = d.get_int(off=args[0])
    return Const_Const_z(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_q:
    arg: tuple[int, int]

def Const_Const_q_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_q:
    arg = decode_q(d=d,off=args[0])
    return Const_Const_q(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_real_approx:
    arg: str

def Const_Const_real_approx_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_real_approx:
    arg = d.get_str(off=args[0])
    return Const_Const_real_approx(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_uid:
    arg: Uid

def Const_Const_uid_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_uid:
    arg = Uid_of_twine(d=d, off=args[0])
    return Const_Const_uid(arg=arg)

@dataclass(slots=True, frozen=True)
class Const_Const_bool:
    arg: bool

def Const_Const_bool_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Const_Const_bool:
    arg = d.get_bool(off=args[0])
    return Const_Const_bool(arg=arg)

type Const = Const_Const_float| Const_Const_string| Const_Const_z| Const_Const_q| Const_Const_real_approx| Const_Const_uid| Const_Const_bool

def Const_of_twine(d: twine.Decoder, off: int) -> Const:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Const_Const_float_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Const_Const_string_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Const_Const_z_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Const_Const_q_of_twine(d=d, args=args, )
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Const_Const_real_approx_of_twine(d=d, args=args, )
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Const_Const_uid_of_twine(d=d, args=args, )
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Const_Const_bool_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Const, got invalid constructor {idx}')

# clique Imandrax_api.As_trigger.t
# def Imandrax_api.As_trigger.t (mangled name: "As_trigger")
@dataclass(slots=True, frozen=True)
class As_trigger_Trig_none:
    pass

@dataclass(slots=True, frozen=True)
class As_trigger_Trig_anon:
    pass

@dataclass(slots=True, frozen=True)
class As_trigger_Trig_named:
    arg: int

def As_trigger_Trig_named_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> As_trigger_Trig_named:
    arg = d.get_int(off=args[0])
    return As_trigger_Trig_named(arg=arg)

@dataclass(slots=True, frozen=True)
class As_trigger_Trig_rw:
    pass

type As_trigger = As_trigger_Trig_none| As_trigger_Trig_anon| As_trigger_Trig_named| As_trigger_Trig_rw

def As_trigger_of_twine(d: twine.Decoder, off: int) -> As_trigger:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return As_trigger_Trig_none()
         case twine.Constructor(idx=1, args=args):
             return As_trigger_Trig_anon()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return As_trigger_Trig_named_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             return As_trigger_Trig_rw()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected As_trigger, got invalid constructor {idx}')

# clique Imandrax_api.Anchor.t
# def Imandrax_api.Anchor.t (mangled name: "Anchor")
@dataclass(slots=True, frozen=True)
class Anchor_Named:
    arg: Cname

def Anchor_Named_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Anchor_Named:
    arg = Cname_of_twine(d=d, off=args[0])
    return Anchor_Named(arg=arg)

@dataclass(slots=True, frozen=True)
class Anchor_Eval:
    arg: int

def Anchor_Eval_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Anchor_Eval:
    arg = d.get_int(off=args[0])
    return Anchor_Eval(arg=arg)

@dataclass(slots=True, frozen=True)
class Anchor_Proof_check:
    arg: Anchor

def Anchor_Proof_check_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Anchor_Proof_check:
    arg = Anchor_of_twine(d=d, off=args[0])
    return Anchor_Proof_check(arg=arg)

@dataclass(slots=True, frozen=True)
class Anchor_Decomp:
    arg: Anchor

def Anchor_Decomp_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Anchor_Decomp:
    arg = Anchor_of_twine(d=d, off=args[0])
    return Anchor_Decomp(arg=arg)

type Anchor = Anchor_Named| Anchor_Eval| Anchor_Proof_check| Anchor_Decomp

def Anchor_of_twine(d: twine.Decoder, off: int) -> Anchor:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Anchor_Named_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Anchor_Eval_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Anchor_Proof_check_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Anchor_Decomp_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Anchor, got invalid constructor {idx}')

# clique Imandrax_api.Admission.t
# def Imandrax_api.Admission.t (mangled name: "Admission")
@dataclass(slots=True, frozen=True)
class Admission:
    measured_subset: list[str]
    measure_fun: None | Uid

def Admission_of_twine(d: twine.Decoder, off: int) -> Admission:
    fields = list(d.get_array(off=off))
    measured_subset = [d.get_str(off=x) for x in d.get_array(off=fields[0])]
    measure_fun = twine.optional(d=d, off=fields[1], d0=lambda d, off: Uid_of_twine(d=d, off=off))
    return Admission(measured_subset=measured_subset,measure_fun=measure_fun)

# clique Imandrax_api_model.ty_def
# def Imandrax_api_model.ty_def (mangled name: "Model_ty_def")
@dataclass(slots=True, frozen=True)
class Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: list["_V_tyreg_poly_term"]

def Model_ty_def_Ty_finite_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=args[0])]
    return Model_ty_def_Ty_finite(arg=arg)

@dataclass(slots=True, frozen=True)
class Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_ty"

def Model_ty_def_Ty_alias_unit_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = decode__tyreg_poly_ty(d=d,off=args[0])
    return Model_ty_def_Ty_alias_unit(arg=arg)

type Model_ty_def[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Model_ty_def_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Model_ty_def:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Model_ty_def_Ty_finite_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Model_ty_def_Ty_alias_unit_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Model_ty_def, got invalid constructor {idx}')

# clique Imandrax_api_model.fi
# def Imandrax_api_model.fi (mangled name: "Model_fi")
@dataclass(slots=True, frozen=True)
class Model_fi[_V_tyreg_poly_term,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    fi_args: list["_V_tyreg_poly_var"]
    fi_ty_ret: "_V_tyreg_poly_ty"
    fi_cases: list[tuple[list["_V_tyreg_poly_term"],"_V_tyreg_poly_term"]]
    fi_else: "_V_tyreg_poly_term"

def Model_fi_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_ty],off: int) -> Model_fi:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_ty = d2
    fields = list(d.get_array(off=off))
    fi_args = [decode__tyreg_poly_var(d=d,off=x) for x in d.get_array(off=fields[0])]
    fi_ty_ret = decode__tyreg_poly_ty(d=d,off=fields[1])
    fi_cases = [(lambda tup: ([decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    fi_else = decode__tyreg_poly_term(d=d,off=fields[3])
    return Model_fi(fi_args=fi_args,fi_ty_ret=fi_ty_ret,fi_cases=fi_cases,fi_else=fi_else)

# clique Imandrax_api_model.t
# def Imandrax_api_model.t (mangled name: "Model")
@dataclass(slots=True, frozen=True)
class Model[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    tys: list[tuple["_V_tyreg_poly_ty",Model_ty_def["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]
    consts: list[tuple["_V_tyreg_poly_fn","_V_tyreg_poly_term"]]
    funs: list[tuple["_V_tyreg_poly_fn",Model_fi["_V_tyreg_poly_term","_V_tyreg_poly_var","_V_tyreg_poly_ty"]]]
    representable: bool
    completed: bool
    ty_subst: list[tuple[Uid,"_V_tyreg_poly_ty"]]

def Model_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],off: int) -> Model:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    fields = list(d.get_array(off=off))
    tys = [(lambda tup: (decode__tyreg_poly_ty(d=d,off=tup[0]),Model_ty_def_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[0])]
    consts = [(lambda tup: (decode__tyreg_poly_fn(d=d,off=tup[0]),decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[1])]
    funs = [(lambda tup: (decode__tyreg_poly_fn(d=d,off=tup[0]),Model_fi_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_var(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    representable = d.get_bool(off=fields[3])
    completed = d.get_bool(off=fields[4])
    ty_subst = [(lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_ty(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[5])]
    return Model(tys=tys,consts=consts,funs=funs,representable=representable,completed=completed,ty_subst=ty_subst)

# clique Imandrax_api_ca_store.Key.t
# def Imandrax_api_ca_store.Key.t (mangled name: "Ca_store_Key")
type Ca_store_Key = WithTag7[str]

def Ca_store_Key_of_twine(d: twine.Decoder, off: int) -> Ca_store_Key:
    return decode_with_tag7(d=d, off=off, d0=lambda d, off: d.get_str(off=off))

# clique Imandrax_api_ca_store.Ca_ptr.Raw.t
# def Imandrax_api_ca_store.Ca_ptr.Raw.t (mangled name: "Ca_store_Ca_ptr_Raw")
@dataclass(slots=True, frozen=True)
class Ca_store_Ca_ptr_Raw:
    key: Ca_store_Key

def Ca_store_Ca_ptr_Raw_of_twine(d: twine.Decoder, off: int) -> Ca_store_Ca_ptr_Raw:
    x = Ca_store_Key_of_twine(d=d, off=off) # single unboxed field
    return Ca_store_Ca_ptr_Raw(key=x)

# clique Imandrax_api_ca_store.Ca_ptr.t
# def Imandrax_api_ca_store.Ca_ptr.t (mangled name: "Ca_store_Ca_ptr")
type Ca_store_Ca_ptr[_V_tyreg_poly_a] = Ca_store_Ca_ptr_Raw

def Ca_store_Ca_ptr_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Ca_store_Ca_ptr:
    decode__tyreg_poly_a = d0
    return Ca_store_Ca_ptr_Raw_of_twine(d=d, off=off)

# clique Imandrax_api_cir.Type.var
# def Imandrax_api_cir.Type.var (mangled name: "Cir_Type_var")
type Cir_Type_var = Uid

def Cir_Type_var_of_twine(d: twine.Decoder, off: int) -> Cir_Type_var:
    return Uid_of_twine(d=d, off=off)

# clique Imandrax_api_cir.Type.clique
# def Imandrax_api_cir.Type.clique (mangled name: "Cir_Type_clique")
type Cir_Type_clique = Uid_set

def Cir_Type_clique_of_twine(d: twine.Decoder, off: int) -> Cir_Type_clique:
    return Uid_set_of_twine(d=d, off=off)

# clique Imandrax_api_cir.Type.t
# def Imandrax_api_cir.Type.t (mangled name: "Cir_Type")
@dataclass(slots=True, frozen=True)
class Cir_Type:
    view: Ty_view_view[None,Cir_Type_var,Cir_Type]

def Cir_Type_of_twine(d: twine.Decoder, off: int) -> Cir_Type:
    x = Ty_view_view_of_twine(d=d,off=off,d0=(lambda d, off: d.get_null(off=off)),d1=(lambda d, off: Cir_Type_var_of_twine(d=d, off=off)),d2=(lambda d, off: Cir_Type_of_twine(d=d, off=off))) # single unboxed field
    return Cir_Type(view=x)

# clique Imandrax_api_cir.Type.def
# def Imandrax_api_cir.Type.def (mangled name: "Cir_Type_def")
@dataclass(slots=True, frozen=True)
class Cir_Type_def:
    name: Uid
    params: list[Cir_Type_var]
    decl: Ty_view_decl[Uid,Cir_Type,Void]
    clique: None | Cir_Type_clique
    timeout: None | int

def Cir_Type_def_of_twine(d: twine.Decoder, off: int) -> Cir_Type_def:
    fields = list(d.get_array(off=off))
    name = Uid_of_twine(d=d, off=fields[0])
    params = [Cir_Type_var_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    decl = Ty_view_decl_of_twine(d=d,off=fields[2],d0=(lambda d, off: Uid_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Type_of_twine(d=d, off=off)),d2=(lambda d, off: Void_of_twine(d=d, off=off)))
    clique = twine.optional(d=d, off=fields[3], d0=lambda d, off: Cir_Type_clique_of_twine(d=d, off=off))
    timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    return Cir_Type_def(name=name,params=params,decl=decl,clique=clique,timeout=timeout)

# clique Imandrax_api_cir.With_ty.t
# def Imandrax_api_cir.With_ty.t (mangled name: "Cir_With_ty")
@dataclass(slots=True, frozen=True)
class Cir_With_ty[_V_tyreg_poly_a]:
    view: "_V_tyreg_poly_a"
    ty: Cir_Type

def Cir_With_ty_of_twine[_V_tyreg_poly_a](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Cir_With_ty:
    decode__tyreg_poly_a = d0
    fields = list(d.get_array(off=off))
    view = decode__tyreg_poly_a(d=d,off=fields[0])
    ty = Cir_Type_of_twine(d=d, off=fields[1])
    return Cir_With_ty(view=view,ty=ty)

# clique Imandrax_api_cir.Var.t
# def Imandrax_api_cir.Var.t (mangled name: "Cir_Var")
type Cir_Var = Cir_With_ty[Uid]

def Cir_Var_of_twine(d: twine.Decoder, off: int) -> Cir_Var:
    return Cir_With_ty_of_twine(d=d,off=off,d0=(lambda d, off: Uid_of_twine(d=d, off=off)))

# clique Imandrax_api_cir.Type_schema.t
# def Imandrax_api_cir.Type_schema.t (mangled name: "Cir_Type_schema")
@dataclass(slots=True, frozen=True)
class Cir_Type_schema:
    params: list[Cir_Type_var]
    ty: Cir_Type

def Cir_Type_schema_of_twine(d: twine.Decoder, off: int) -> Cir_Type_schema:
    fields = list(d.get_array(off=off))
    params = [Cir_Type_var_of_twine(d=d, off=x) for x in d.get_array(off=fields[0])]
    ty = Cir_Type_of_twine(d=d, off=fields[1])
    return Cir_Type_schema(params=params,ty=ty)

# clique Imandrax_api_cir.Typed_symbol.t
# def Imandrax_api_cir.Typed_symbol.t (mangled name: "Cir_Typed_symbol")
@dataclass(slots=True, frozen=True)
class Cir_Typed_symbol:
    id: Uid
    ty: Cir_Type_schema

def Cir_Typed_symbol_of_twine(d: twine.Decoder, off: int) -> Cir_Typed_symbol:
    fields = list(d.get_array(off=off))
    id = Uid_of_twine(d=d, off=fields[0])
    ty = Cir_Type_schema_of_twine(d=d, off=fields[1])
    return Cir_Typed_symbol(id=id,ty=ty)

# clique Imandrax_api_cir.Applied_symbol.t
# def Imandrax_api_cir.Applied_symbol.t (mangled name: "Cir_Applied_symbol")
@dataclass(slots=True, frozen=True)
class Cir_Applied_symbol:
    sym: Cir_Typed_symbol
    args: list[Cir_Type]
    ty: Cir_Type

def Cir_Applied_symbol_of_twine(d: twine.Decoder, off: int) -> Cir_Applied_symbol:
    fields = list(d.get_array(off=off))
    sym = Cir_Typed_symbol_of_twine(d=d, off=fields[0])
    args = [Cir_Type_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    ty = Cir_Type_of_twine(d=d, off=fields[2])
    return Cir_Applied_symbol(sym=sym,args=args,ty=ty)

# clique Imandrax_api_cir.Fo_pattern.view
# def Imandrax_api_cir.Fo_pattern.view (mangled name: "Cir_Fo_pattern_view")
@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_any[_V_tyreg_poly_t]:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_bool[_V_tyreg_poly_t]:
    arg: bool

def Cir_Fo_pattern_view_FO_bool_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_bool[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    arg = d.get_bool(off=args[0])
    return Cir_Fo_pattern_view_FO_bool(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_const[_V_tyreg_poly_t]:
    arg: Const

def Cir_Fo_pattern_view_FO_const_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_const[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    arg = Const_of_twine(d=d, off=args[0])
    return Cir_Fo_pattern_view_FO_const(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_var[_V_tyreg_poly_t]:
    arg: Cir_Var

def Cir_Fo_pattern_view_FO_var_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_var[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    arg = Cir_Var_of_twine(d=d, off=args[0])
    return Cir_Fo_pattern_view_FO_var(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_app[_V_tyreg_poly_t]:
    args: tuple[Cir_Applied_symbol,list["_V_tyreg_poly_t"]]

def Cir_Fo_pattern_view_FO_app_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_app[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    cargs = (Cir_Applied_symbol_of_twine(d=d, off=args[0]),[decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])])
    return Cir_Fo_pattern_view_FO_app(args=cargs)

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t]:
    args: tuple[None | Cir_Applied_symbol,list["_V_tyreg_poly_t"]]

def Cir_Fo_pattern_view_FO_cstor_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    cargs = (twine.optional(d=d, off=args[0], d0=lambda d, off: Cir_Applied_symbol_of_twine(d=d, off=off)),[decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])])
    return Cir_Fo_pattern_view_FO_cstor(args=cargs)

@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t]:
    c: None | Cir_Applied_symbol
    i: int
    u: "_V_tyreg_poly_t"


def Cir_Fo_pattern_view_FO_destruct_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    c = twine.optional(d=d, off=args[0], d0=lambda d, off: Cir_Applied_symbol_of_twine(d=d, off=off))
    i = d.get_int(off=args[1])
    u = decode__tyreg_poly_t(d=d,off=args[2])
    return Cir_Fo_pattern_view_FO_destruct(c=c,i=i,u=u)


@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t]:
    c: Cir_Applied_symbol
    u: "_V_tyreg_poly_t"


def Cir_Fo_pattern_view_FO_is_a_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],args: tuple[int, ...]) -> Cir_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t]:
    decode__tyreg_poly_t = d0
    c = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    u = decode__tyreg_poly_t(d=d,off=args[1])
    return Cir_Fo_pattern_view_FO_is_a(c=c,u=u)


type Cir_Fo_pattern_view[_V_tyreg_poly_t] = Cir_Fo_pattern_view_FO_any[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_bool[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_const[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_var[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_app[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t]

def Cir_Fo_pattern_view_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],off: int) -> Cir_Fo_pattern_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Cir_Fo_pattern_view_FO_any[_V_tyreg_poly_t]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_bool_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_const_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_var_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_app_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_cstor_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_destruct_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Cir_Fo_pattern_view_FO_is_a_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Fo_pattern_view, got invalid constructor {idx}')

# clique Imandrax_api_cir.Fo_pattern.t
# def Imandrax_api_cir.Fo_pattern.t (mangled name: "Cir_Fo_pattern")
@dataclass(slots=True, frozen=True)
class Cir_Fo_pattern:
    view: Cir_Fo_pattern_view[Cir_Fo_pattern]
    ty: Cir_Type

def Cir_Fo_pattern_of_twine(d: twine.Decoder, off: int) -> Cir_Fo_pattern:
    fields = list(d.get_array(off=off))
    view = Cir_Fo_pattern_view_of_twine(d=d,off=fields[0],d0=(lambda d, off: Cir_Fo_pattern_of_twine(d=d, off=off)))
    ty = Cir_Type_of_twine(d=d, off=fields[1])
    return Cir_Fo_pattern(view=view,ty=ty)

# clique Imandrax_api_cir.Pattern_head.t
# def Imandrax_api_cir.Pattern_head.t (mangled name: "Cir_Pattern_head")
@dataclass(slots=True, frozen=True)
class Cir_Pattern_head_PH_id:
    arg: Uid

def Cir_Pattern_head_PH_id_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Pattern_head_PH_id:
    arg = Uid_of_twine(d=d, off=args[0])
    return Cir_Pattern_head_PH_id(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Pattern_head_PH_ty:
    arg: Cir_Type

def Cir_Pattern_head_PH_ty_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Pattern_head_PH_ty:
    arg = Cir_Type_of_twine(d=d, off=args[0])
    return Cir_Pattern_head_PH_ty(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Pattern_head_PH_datatype_op:
    pass

type Cir_Pattern_head = Cir_Pattern_head_PH_id| Cir_Pattern_head_PH_ty| Cir_Pattern_head_PH_datatype_op

def Cir_Pattern_head_of_twine(d: twine.Decoder, off: int) -> Cir_Pattern_head:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Cir_Pattern_head_PH_id_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cir_Pattern_head_PH_ty_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             return Cir_Pattern_head_PH_datatype_op()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Pattern_head, got invalid constructor {idx}')

# clique Imandrax_api_cir.Trigger.t
# def Imandrax_api_cir.Trigger.t (mangled name: "Cir_Trigger")
@dataclass(slots=True, frozen=True)
class Cir_Trigger:
    trigger_head: Cir_Pattern_head
    trigger_patterns: list[Cir_Fo_pattern]
    trigger_instantiation_rule_name: Uid

def Cir_Trigger_of_twine(d: twine.Decoder, off: int) -> Cir_Trigger:
    fields = list(d.get_array(off=off))
    trigger_head = Cir_Pattern_head_of_twine(d=d, off=fields[0])
    trigger_patterns = [Cir_Fo_pattern_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    trigger_instantiation_rule_name = Uid_of_twine(d=d, off=fields[2])
    return Cir_Trigger(trigger_head=trigger_head,trigger_patterns=trigger_patterns,trigger_instantiation_rule_name=trigger_instantiation_rule_name)

# clique Imandrax_api_cir.Case.t
# def Imandrax_api_cir.Case.t (mangled name: "Cir_Case")
@dataclass(slots=True, frozen=True)
class Cir_Case[_V_tyreg_poly_t]:
    case_cstor: Cir_Applied_symbol
    case_vars: list[Cir_Var]
    case_rhs: "_V_tyreg_poly_t"
    case_labels: None | list[Uid]

def Cir_Case_of_twine[_V_tyreg_poly_t](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],off: int) -> Cir_Case:
    decode__tyreg_poly_t = d0
    fields = list(d.get_array(off=off))
    case_cstor = Cir_Applied_symbol_of_twine(d=d, off=fields[0])
    case_vars = [Cir_Var_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    case_rhs = decode__tyreg_poly_t(d=d,off=fields[2])
    case_labels = twine.optional(d=d, off=fields[3], d0=lambda d, off: [Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return Cir_Case(case_cstor=case_cstor,case_vars=case_vars,case_rhs=case_rhs,case_labels=case_labels)

# clique Imandrax_api_cir.Clique.t
# def Imandrax_api_cir.Clique.t (mangled name: "Cir_Clique")
type Cir_Clique = Uid_set

def Cir_Clique_of_twine(d: twine.Decoder, off: int) -> Cir_Clique:
    return Uid_set_of_twine(d=d, off=off)

# clique Imandrax_api_cir.Term.binding
# def Imandrax_api_cir.Term.binding (mangled name: "Cir_Term_binding")
type Cir_Term_binding[_V_tyreg_poly_t] = tuple[Cir_Var,"_V_tyreg_poly_t"]

def Cir_Term_binding_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],off: int) -> Cir_Term_binding:
    decode__tyreg_poly_t = d0
    return (lambda tup: (Cir_Var_of_twine(d=d, off=tup[0]),decode__tyreg_poly_t(d=d,off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_cir.Term.t,Imandrax_api_cir.Term.view
# def Imandrax_api_cir.Term.t (mangled name: "Cir_Term")
type Cir_Term = Cir_With_ty[Cir_Term_view]

def Cir_Term_of_twine(d: twine.Decoder, off: int) -> Cir_Term:
    return Cir_With_ty_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_view_of_twine(d=d, off=off)))
# def Imandrax_api_cir.Term.view (mangled name: "Cir_Term_view")
@dataclass(slots=True, frozen=True)
class Cir_Term_view_Const:
    arg: Const

def Cir_Term_view_Const_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Const:
    arg = Const_of_twine(d=d, off=args[0])
    return Cir_Term_view_Const(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Term_view_If:
    args: tuple[Cir_Term,Cir_Term,Cir_Term]

def Cir_Term_view_If_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_If:
    cargs = (Cir_Term_of_twine(d=d, off=args[0]),Cir_Term_of_twine(d=d, off=args[1]),Cir_Term_of_twine(d=d, off=args[2]))
    return Cir_Term_view_If(args=cargs)

@dataclass(slots=True, frozen=True)
class Cir_Term_view_Let:
    flg: Misc_types_rec_flag
    bs: list[Cir_Term_binding[Cir_Term]]
    body: Cir_Term


def Cir_Term_view_Let_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Let:
    flg = Misc_types_rec_flag_of_twine(d=d, off=args[0])
    bs = [Cir_Term_binding_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off))) for x in d.get_array(off=args[1])]
    body = Cir_Term_of_twine(d=d, off=args[2])
    return Cir_Term_view_Let(flg=flg,bs=bs,body=body)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Apply:
    f: Cir_Term
    l: list[Cir_Term]


def Cir_Term_view_Apply_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Apply:
    f = Cir_Term_of_twine(d=d, off=args[0])
    l = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=args[1])]
    return Cir_Term_view_Apply(f=f,l=l)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Fun:
    v: Cir_Var
    body: Cir_Term


def Cir_Term_view_Fun_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Fun:
    v = Cir_Var_of_twine(d=d, off=args[0])
    body = Cir_Term_of_twine(d=d, off=args[1])
    return Cir_Term_view_Fun(v=v,body=body)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Var:
    arg: Cir_Var

def Cir_Term_view_Var_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Var:
    arg = Cir_Var_of_twine(d=d, off=args[0])
    return Cir_Term_view_Var(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Term_view_Sym:
    arg: Cir_Applied_symbol

def Cir_Term_view_Sym_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Sym:
    arg = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    return Cir_Term_view_Sym(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Term_view_Construct:
    c: Cir_Applied_symbol
    args: list[Cir_Term]
    labels: None | list[Uid]


def Cir_Term_view_Construct_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Construct:
    c = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    args = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=args[1])]
    labels = twine.optional(d=d, off=args[2], d0=lambda d, off: [Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return Cir_Term_view_Construct(c=c,args=args,labels=labels)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Destruct:
    c: Cir_Applied_symbol
    i: int
    t: Cir_Term


def Cir_Term_view_Destruct_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Destruct:
    c = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    i = d.get_int(off=args[1])
    t = Cir_Term_of_twine(d=d, off=args[2])
    return Cir_Term_view_Destruct(c=c,i=i,t=t)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Is_a:
    c: Cir_Applied_symbol
    t: Cir_Term


def Cir_Term_view_Is_a_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Is_a:
    c = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    t = Cir_Term_of_twine(d=d, off=args[1])
    return Cir_Term_view_Is_a(c=c,t=t)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Tuple:
    l: list[Cir_Term]


def Cir_Term_view_Tuple_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Tuple:
    l = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=args[0])]
    return Cir_Term_view_Tuple(l=l)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Field:
    f: Cir_Applied_symbol
    t: Cir_Term


def Cir_Term_view_Field_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Field:
    f = Cir_Applied_symbol_of_twine(d=d, off=args[0])
    t = Cir_Term_of_twine(d=d, off=args[1])
    return Cir_Term_view_Field(f=f,t=t)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Tuple_field:
    i: int
    t: Cir_Term


def Cir_Term_view_Tuple_field_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Tuple_field:
    i = d.get_int(off=args[0])
    t = Cir_Term_of_twine(d=d, off=args[1])
    return Cir_Term_view_Tuple_field(i=i,t=t)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Record:
    rows: list[tuple[Cir_Applied_symbol,Cir_Term]]
    rest: None | Cir_Term


def Cir_Term_view_Record_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Record:
    rows = [(lambda tup: (Cir_Applied_symbol_of_twine(d=d, off=tup[0]),Cir_Term_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    rest = twine.optional(d=d, off=args[1], d0=lambda d, off: Cir_Term_of_twine(d=d, off=off))
    return Cir_Term_view_Record(rows=rows,rest=rest)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Case:
    u: Cir_Term
    cases: list[Cir_Case[Cir_Term]]
    default: None | Cir_Term


def Cir_Term_view_Case_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Case:
    u = Cir_Term_of_twine(d=d, off=args[0])
    cases = [Cir_Case_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off))) for x in d.get_array(off=args[1])]
    default = twine.optional(d=d, off=args[2], d0=lambda d, off: Cir_Term_of_twine(d=d, off=off))
    return Cir_Term_view_Case(u=u,cases=cases,default=default)


@dataclass(slots=True, frozen=True)
class Cir_Term_view_Let_tuple:
    vars: list[Cir_Var]
    rhs: Cir_Term
    body: Cir_Term


def Cir_Term_view_Let_tuple_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Term_view_Let_tuple:
    vars = [Cir_Var_of_twine(d=d, off=x) for x in d.get_array(off=args[0])]
    rhs = Cir_Term_of_twine(d=d, off=args[1])
    body = Cir_Term_of_twine(d=d, off=args[2])
    return Cir_Term_view_Let_tuple(vars=vars,rhs=rhs,body=body)


type Cir_Term_view = Cir_Term_view_Const| Cir_Term_view_If| Cir_Term_view_Let| Cir_Term_view_Apply| Cir_Term_view_Fun| Cir_Term_view_Var| Cir_Term_view_Sym| Cir_Term_view_Construct| Cir_Term_view_Destruct| Cir_Term_view_Is_a| Cir_Term_view_Tuple| Cir_Term_view_Field| Cir_Term_view_Tuple_field| Cir_Term_view_Record| Cir_Term_view_Case| Cir_Term_view_Let_tuple

def Cir_Term_view_of_twine(d: twine.Decoder, off: int) -> Cir_Term_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Cir_Term_view_Const_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cir_Term_view_If_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Cir_Term_view_Let_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Cir_Term_view_Apply_of_twine(d=d, args=args, )
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Cir_Term_view_Fun_of_twine(d=d, args=args, )
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Cir_Term_view_Var_of_twine(d=d, args=args, )
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Cir_Term_view_Sym_of_twine(d=d, args=args, )
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Cir_Term_view_Construct_of_twine(d=d, args=args, )
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return Cir_Term_view_Destruct_of_twine(d=d, args=args, )
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return Cir_Term_view_Is_a_of_twine(d=d, args=args, )
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return Cir_Term_view_Tuple_of_twine(d=d, args=args, )
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return Cir_Term_view_Field_of_twine(d=d, args=args, )
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return Cir_Term_view_Tuple_field_of_twine(d=d, args=args, )
         case twine.Constructor(idx=13, args=args):
             args = tuple(args)
             return Cir_Term_view_Record_of_twine(d=d, args=args, )
         case twine.Constructor(idx=14, args=args):
             args = tuple(args)
             return Cir_Term_view_Case_of_twine(d=d, args=args, )
         case twine.Constructor(idx=15, args=args):
             args = tuple(args)
             return Cir_Term_view_Let_tuple_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Term_view, got invalid constructor {idx}')

# clique Imandrax_api_cir.Term.term
# def Imandrax_api_cir.Term.term (mangled name: "Cir_Term_term")
type Cir_Term_term = Cir_Term

def Cir_Term_term_of_twine(d: twine.Decoder, off: int) -> Cir_Term_term:
    return Cir_Term_of_twine(d=d, off=off)

# clique Imandrax_api_cir.Hints.validation_strategy
# def Imandrax_api_cir.Hints.validation_strategy (mangled name: "Cir_Hints_validation_strategy")
@dataclass(slots=True, frozen=True)
class Cir_Hints_validation_strategy_VS_validate:
    tactic: None | Cir_Term


def Cir_Hints_validation_strategy_VS_validate_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Hints_validation_strategy_VS_validate:
    tactic = twine.optional(d=d, off=args[0], d0=lambda d, off: Cir_Term_of_twine(d=d, off=off))
    return Cir_Hints_validation_strategy_VS_validate(tactic=tactic)


@dataclass(slots=True, frozen=True)
class Cir_Hints_validation_strategy_VS_no_validate:
    pass

type Cir_Hints_validation_strategy = Cir_Hints_validation_strategy_VS_validate| Cir_Hints_validation_strategy_VS_no_validate

def Cir_Hints_validation_strategy_of_twine(d: twine.Decoder, off: int) -> Cir_Hints_validation_strategy:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Cir_Hints_validation_strategy_VS_validate_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             return Cir_Hints_validation_strategy_VS_no_validate()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Hints_validation_strategy, got invalid constructor {idx}')

# clique Imandrax_api_cir.Hints.t
# def Imandrax_api_cir.Hints.t (mangled name: "Cir_Hints")
@dataclass(slots=True, frozen=True)
class Cir_Hints:
    f_validate_strat: Cir_Hints_validation_strategy
    f_unroll_def: None | int
    f_enable: list[Uid]
    f_disable: list[Uid]
    f_timeout: None | int
    f_admission: None | Admission

def Cir_Hints_of_twine(d: twine.Decoder, off: int) -> Cir_Hints:
    fields = list(d.get_array(off=off))
    f_validate_strat = Cir_Hints_validation_strategy_of_twine(d=d, off=fields[0])
    f_unroll_def = twine.optional(d=d, off=fields[1], d0=lambda d, off: d.get_int(off=off))
    f_enable = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    f_disable = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[3])]
    f_timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    f_admission = twine.optional(d=d, off=fields[5], d0=lambda d, off: Admission_of_twine(d=d, off=off))
    return Cir_Hints(f_validate_strat=f_validate_strat,f_unroll_def=f_unroll_def,f_enable=f_enable,f_disable=f_disable,f_timeout=f_timeout,f_admission=f_admission)

# clique Imandrax_api_cir.Fun_def.fun_kind
# def Imandrax_api_cir.Fun_def.fun_kind (mangled name: "Cir_Fun_def_fun_kind")
@dataclass(slots=True, frozen=True)
class Cir_Fun_def_fun_kind_Fun_defined:
    is_macro: bool
    from_lambda: bool


def Cir_Fun_def_fun_kind_Fun_defined_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Fun_def_fun_kind_Fun_defined:
    is_macro = d.get_bool(off=args[0])
    from_lambda = d.get_bool(off=args[1])
    return Cir_Fun_def_fun_kind_Fun_defined(is_macro=is_macro,from_lambda=from_lambda)


@dataclass(slots=True, frozen=True)
class Cir_Fun_def_fun_kind_Fun_builtin:
    arg: Builtin_Fun

def Cir_Fun_def_fun_kind_Fun_builtin_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Fun_def_fun_kind_Fun_builtin:
    arg = Builtin_Fun_of_twine(d=d, off=args[0])
    return Cir_Fun_def_fun_kind_Fun_builtin(arg=arg)

@dataclass(slots=True, frozen=True)
class Cir_Fun_def_fun_kind_Fun_opaque:
    pass

type Cir_Fun_def_fun_kind = Cir_Fun_def_fun_kind_Fun_defined| Cir_Fun_def_fun_kind_Fun_builtin| Cir_Fun_def_fun_kind_Fun_opaque

def Cir_Fun_def_fun_kind_of_twine(d: twine.Decoder, off: int) -> Cir_Fun_def_fun_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Cir_Fun_def_fun_kind_Fun_defined_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cir_Fun_def_fun_kind_Fun_builtin_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             return Cir_Fun_def_fun_kind_Fun_opaque()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Fun_def_fun_kind, got invalid constructor {idx}')

# clique Imandrax_api_cir.Fun_def.t
# def Imandrax_api_cir.Fun_def.t (mangled name: "Cir_Fun_def")
@dataclass(slots=True, frozen=True)
class Cir_Fun_def:
    f_name: Uid
    f_ty: Cir_Type_schema
    f_args: list[Cir_Var]
    f_body: Cir_Term
    f_clique: None | Cir_Clique
    f_kind: Cir_Fun_def_fun_kind
    f_hints: Cir_Hints

def Cir_Fun_def_of_twine(d: twine.Decoder, off: int) -> Cir_Fun_def:
    fields = list(d.get_array(off=off))
    f_name = Uid_of_twine(d=d, off=fields[0])
    f_ty = Cir_Type_schema_of_twine(d=d, off=fields[1])
    f_args = [Cir_Var_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    f_body = Cir_Term_of_twine(d=d, off=fields[3])
    f_clique = twine.optional(d=d, off=fields[4], d0=lambda d, off: Cir_Clique_of_twine(d=d, off=off))
    f_kind = Cir_Fun_def_fun_kind_of_twine(d=d, off=fields[5])
    f_hints = Cir_Hints_of_twine(d=d, off=fields[6])
    return Cir_Fun_def(f_name=f_name,f_ty=f_ty,f_args=f_args,f_body=f_body,f_clique=f_clique,f_kind=f_kind,f_hints=f_hints)

# clique Imandrax_api_cir.Pre_trigger.t
# def Imandrax_api_cir.Pre_trigger.t (mangled name: "Cir_Pre_trigger")
type Cir_Pre_trigger = tuple[Cir_Term,As_trigger]

def Cir_Pre_trigger_of_twine(d: twine.Decoder, off: int) -> Cir_Pre_trigger:
    return (lambda tup: (Cir_Term_of_twine(d=d, off=tup[0]),As_trigger_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_cir.Theorem.t
# def Imandrax_api_cir.Theorem.t (mangled name: "Cir_Theorem")
@dataclass(slots=True, frozen=True)
class Cir_Theorem:
    thm_link: Cir_Fun_def
    thm_rewriting: bool
    thm_perm_restrict: bool
    thm_fc: bool
    thm_elim: bool
    thm_gen: bool
    thm_triggers: list[Cir_Pre_trigger]
    thm_is_axiom: bool
    thm_by: Cir_Term

def Cir_Theorem_of_twine(d: twine.Decoder, off: int) -> Cir_Theorem:
    fields = list(d.get_array(off=off))
    thm_link = Cir_Fun_def_of_twine(d=d, off=fields[0])
    thm_rewriting = d.get_bool(off=fields[1])
    thm_perm_restrict = d.get_bool(off=fields[2])
    thm_fc = d.get_bool(off=fields[3])
    thm_elim = d.get_bool(off=fields[4])
    thm_gen = d.get_bool(off=fields[5])
    thm_triggers = [Cir_Pre_trigger_of_twine(d=d, off=x) for x in d.get_array(off=fields[6])]
    thm_is_axiom = d.get_bool(off=fields[7])
    thm_by = Cir_Term_of_twine(d=d, off=fields[8])
    return Cir_Theorem(thm_link=thm_link,thm_rewriting=thm_rewriting,thm_perm_restrict=thm_perm_restrict,thm_fc=thm_fc,thm_elim=thm_elim,thm_gen=thm_gen,thm_triggers=thm_triggers,thm_is_axiom=thm_is_axiom,thm_by=thm_by)

# clique Imandrax_api_cir.Tactic.t
# def Imandrax_api_cir.Tactic.t (mangled name: "Cir_Tactic")
@dataclass(slots=True, frozen=True)
class Cir_Tactic_Default_termination:
    basis: Uid_set


def Cir_Tactic_Default_termination_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Tactic_Default_termination:
    basis = Uid_set_of_twine(d=d, off=args[0])
    return Cir_Tactic_Default_termination(basis=basis)


@dataclass(slots=True, frozen=True)
class Cir_Tactic_Default_thm:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Tactic_Term:
    arg: Cir_Term

def Cir_Tactic_Term_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Tactic_Term:
    arg = Cir_Term_of_twine(d=d, off=args[0])
    return Cir_Tactic_Term(arg=arg)

type Cir_Tactic = Cir_Tactic_Default_termination| Cir_Tactic_Default_thm| Cir_Tactic_Term

def Cir_Tactic_of_twine(d: twine.Decoder, off: int) -> Cir_Tactic:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Cir_Tactic_Default_termination_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             return Cir_Tactic_Default_thm()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Cir_Tactic_Term_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Tactic, got invalid constructor {idx}')

# clique Imandrax_api_cir.Sequent.t
# def Imandrax_api_cir.Sequent.t (mangled name: "Cir_Sequent")
type Cir_Sequent = Sequent_poly[Cir_Term]

def Cir_Sequent_of_twine(d: twine.Decoder, off: int) -> Cir_Sequent:
    return Sequent_poly_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)))

# clique Imandrax_api_cir.Rewrite_rule.t
# def Imandrax_api_cir.Rewrite_rule.t (mangled name: "Cir_Rewrite_rule")
@dataclass(slots=True, frozen=True)
class Cir_Rewrite_rule:
    rw_name: Uid
    rw_head: Cir_Pattern_head
    rw_lhs: Cir_Fo_pattern
    rw_rhs: Cir_Term
    rw_guard: list[Cir_Term]
    rw_vars: Var_set
    rw_triggers: list[Cir_Fo_pattern]
    rw_perm_restrict: bool
    rw_loop_break: None | Cir_Fo_pattern

def Cir_Rewrite_rule_of_twine(d: twine.Decoder, off: int) -> Cir_Rewrite_rule:
    fields = list(d.get_array(off=off))
    rw_name = Uid_of_twine(d=d, off=fields[0])
    rw_head = Cir_Pattern_head_of_twine(d=d, off=fields[1])
    rw_lhs = Cir_Fo_pattern_of_twine(d=d, off=fields[2])
    rw_rhs = Cir_Term_of_twine(d=d, off=fields[3])
    rw_guard = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=fields[4])]
    rw_vars = Var_set_of_twine(d=d, off=fields[5])
    rw_triggers = [Cir_Fo_pattern_of_twine(d=d, off=x) for x in d.get_array(off=fields[6])]
    rw_perm_restrict = d.get_bool(off=fields[7])
    rw_loop_break = twine.optional(d=d, off=fields[8], d0=lambda d, off: Cir_Fo_pattern_of_twine(d=d, off=off))
    return Cir_Rewrite_rule(rw_name=rw_name,rw_head=rw_head,rw_lhs=rw_lhs,rw_rhs=rw_rhs,rw_guard=rw_guard,rw_vars=rw_vars,rw_triggers=rw_triggers,rw_perm_restrict=rw_perm_restrict,rw_loop_break=rw_loop_break)

# clique Imandrax_api_cir.Proof_obligation.t
# def Imandrax_api_cir.Proof_obligation.t (mangled name: "Cir_Proof_obligation")
@dataclass(slots=True, frozen=True)
class Cir_Proof_obligation:
    descr: str
    goal: Cir_Term
    tactic: Cir_Tactic
    is_instance: bool
    anchor: Anchor
    timeout: None | int

def Cir_Proof_obligation_of_twine(d: twine.Decoder, off: int) -> Cir_Proof_obligation:
    fields = list(d.get_array(off=off))
    descr = d.get_str(off=fields[0])
    goal = Cir_Term_of_twine(d=d, off=fields[1])
    tactic = Cir_Tactic_of_twine(d=d, off=fields[2])
    is_instance = d.get_bool(off=fields[3])
    anchor = Anchor_of_twine(d=d, off=fields[4])
    timeout = twine.optional(d=d, off=fields[5], d0=lambda d, off: d.get_int(off=off))
    return Cir_Proof_obligation(descr=descr,goal=goal,tactic=tactic,is_instance=is_instance,anchor=anchor,timeout=timeout)

# clique Imandrax_api_cir.Model.ty_def
# def Imandrax_api_cir.Model.ty_def (mangled name: "Cir_Model_ty_def")
type Cir_Model_ty_def = Model_ty_def[Cir_Term,Cir_Type]

def Cir_Model_ty_def_of_twine(d: twine.Decoder, off: int) -> Cir_Model_ty_def:
    return Model_ty_def_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_cir.Model.fi
# def Imandrax_api_cir.Model.fi (mangled name: "Cir_Model_fi")
type Cir_Model_fi = Model_fi[Cir_Term,Cir_Var,Cir_Type]

def Cir_Model_fi_of_twine(d: twine.Decoder, off: int) -> Cir_Model_fi:
    return Model_fi_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Var_of_twine(d=d, off=off)),d2=(lambda d, off: Cir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_cir.Model.t
# def Imandrax_api_cir.Model.t (mangled name: "Cir_Model")
type Cir_Model = Model[Cir_Term,Cir_Applied_symbol,Cir_Var,Cir_Type]

def Cir_Model_of_twine(d: twine.Decoder, off: int) -> Cir_Model:
    return Model_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Applied_symbol_of_twine(d=d, off=off)),d2=(lambda d, off: Cir_Var_of_twine(d=d, off=off)),d3=(lambda d, off: Cir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_cir.Instantiation_rule_kind.t
# def Imandrax_api_cir.Instantiation_rule_kind.t (mangled name: "Cir_Instantiation_rule_kind")
@dataclass(slots=True, frozen=True)
class Cir_Instantiation_rule_kind_IR_forward_chaining:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Instantiation_rule_kind_IR_generalization:
    pass

type Cir_Instantiation_rule_kind = Cir_Instantiation_rule_kind_IR_forward_chaining| Cir_Instantiation_rule_kind_IR_generalization

def Cir_Instantiation_rule_kind_of_twine(d: twine.Decoder, off: int) -> Cir_Instantiation_rule_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Cir_Instantiation_rule_kind_IR_forward_chaining()
         case twine.Constructor(idx=1, args=args):
             return Cir_Instantiation_rule_kind_IR_generalization()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Instantiation_rule_kind, got invalid constructor {idx}')

# clique Imandrax_api_cir.Instantiation_rule.t
# def Imandrax_api_cir.Instantiation_rule.t (mangled name: "Cir_Instantiation_rule")
@dataclass(slots=True, frozen=True)
class Cir_Instantiation_rule:
    ir_from: Cir_Fun_def
    ir_triggers: list[Cir_Trigger]
    ir_kind: Cir_Instantiation_rule_kind

def Cir_Instantiation_rule_of_twine(d: twine.Decoder, off: int) -> Cir_Instantiation_rule:
    fields = list(d.get_array(off=off))
    ir_from = Cir_Fun_def_of_twine(d=d, off=fields[0])
    ir_triggers = [Cir_Trigger_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    ir_kind = Cir_Instantiation_rule_kind_of_twine(d=d, off=fields[2])
    return Cir_Instantiation_rule(ir_from=ir_from,ir_triggers=ir_triggers,ir_kind=ir_kind)

# clique Imandrax_api_cir.Fun_decomp.status
# def Imandrax_api_cir.Fun_decomp.status (mangled name: "Cir_Fun_decomp_status")
@dataclass(slots=True, frozen=True)
class Cir_Fun_decomp_status_Unknown:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Fun_decomp_status_Feasible:
    arg: Cir_Model

def Cir_Fun_decomp_status_Feasible_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Cir_Fun_decomp_status_Feasible:
    arg = Cir_Model_of_twine(d=d, off=args[0])
    return Cir_Fun_decomp_status_Feasible(arg=arg)

type Cir_Fun_decomp_status = Cir_Fun_decomp_status_Unknown| Cir_Fun_decomp_status_Feasible

def Cir_Fun_decomp_status_of_twine(d: twine.Decoder, off: int) -> Cir_Fun_decomp_status:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Cir_Fun_decomp_status_Unknown()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cir_Fun_decomp_status_Feasible_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Fun_decomp_status, got invalid constructor {idx}')

# clique Imandrax_api_cir.Fun_decomp.Region.t
# def Imandrax_api_cir.Fun_decomp.Region.t (mangled name: "Cir_Fun_decomp_Region")
@dataclass(slots=True, frozen=True)
class Cir_Fun_decomp_Region:
    constraints: list[Cir_Term]
    invariant: Cir_Term
    status: Cir_Fun_decomp_status

def Cir_Fun_decomp_Region_of_twine(d: twine.Decoder, off: int) -> Cir_Fun_decomp_Region:
    fields = list(d.get_array(off=off))
    constraints = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=fields[0])]
    invariant = Cir_Term_of_twine(d=d, off=fields[1])
    status = Cir_Fun_decomp_status_of_twine(d=d, off=fields[2])
    return Cir_Fun_decomp_Region(constraints=constraints,invariant=invariant,status=status)

# clique Imandrax_api_cir.Fun_decomp.t
# def Imandrax_api_cir.Fun_decomp.t (mangled name: "Cir_Fun_decomp")
@dataclass(slots=True, frozen=True)
class Cir_Fun_decomp:
    f_id: Uid
    f_args: list[Cir_Var]
    regions: list[Cir_Fun_decomp_Region]

def Cir_Fun_decomp_of_twine(d: twine.Decoder, off: int) -> Cir_Fun_decomp:
    fields = list(d.get_array(off=off))
    f_id = Uid_of_twine(d=d, off=fields[0])
    f_args = [Cir_Var_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    regions = [Cir_Fun_decomp_Region_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    return Cir_Fun_decomp(f_id=f_id,f_args=f_args,regions=regions)

# clique Imandrax_api_cir.Elimination_rule.t
# def Imandrax_api_cir.Elimination_rule.t (mangled name: "Cir_Elimination_rule")
@dataclass(slots=True, frozen=True)
class Cir_Elimination_rule:
    er_name: Uid
    er_guard: list[Cir_Term]
    er_lhs: Cir_Term
    er_rhs: Cir_Var
    er_dests: list[Cir_Fo_pattern]
    er_dest_tms: list[Cir_Term]

def Cir_Elimination_rule_of_twine(d: twine.Decoder, off: int) -> Cir_Elimination_rule:
    fields = list(d.get_array(off=off))
    er_name = Uid_of_twine(d=d, off=fields[0])
    er_guard = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    er_lhs = Cir_Term_of_twine(d=d, off=fields[2])
    er_rhs = Cir_Var_of_twine(d=d, off=fields[3])
    er_dests = [Cir_Fo_pattern_of_twine(d=d, off=x) for x in d.get_array(off=fields[4])]
    er_dest_tms = [Cir_Term_of_twine(d=d, off=x) for x in d.get_array(off=fields[5])]
    return Cir_Elimination_rule(er_name=er_name,er_guard=er_guard,er_lhs=er_lhs,er_rhs=er_rhs,er_dests=er_dests,er_dest_tms=er_dest_tms)

# clique Imandrax_api_cir.Decomp.lift_bool
# def Imandrax_api_cir.Decomp.lift_bool (mangled name: "Cir_Decomp_lift_bool")
@dataclass(slots=True, frozen=True)
class Cir_Decomp_lift_bool_Default:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Decomp_lift_bool_Nested_equalities:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Decomp_lift_bool_Equalities:
    pass

@dataclass(slots=True, frozen=True)
class Cir_Decomp_lift_bool_All:
    pass

type Cir_Decomp_lift_bool = Cir_Decomp_lift_bool_Default| Cir_Decomp_lift_bool_Nested_equalities| Cir_Decomp_lift_bool_Equalities| Cir_Decomp_lift_bool_All

def Cir_Decomp_lift_bool_of_twine(d: twine.Decoder, off: int) -> Cir_Decomp_lift_bool:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Cir_Decomp_lift_bool_Default()
         case twine.Constructor(idx=1, args=args):
             return Cir_Decomp_lift_bool_Nested_equalities()
         case twine.Constructor(idx=2, args=args):
             return Cir_Decomp_lift_bool_Equalities()
         case twine.Constructor(idx=3, args=args):
             return Cir_Decomp_lift_bool_All()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Cir_Decomp_lift_bool, got invalid constructor {idx}')

# clique Imandrax_api_cir.Decomp.t
# def Imandrax_api_cir.Decomp.t (mangled name: "Cir_Decomp")
@dataclass(slots=True, frozen=True)
class Cir_Decomp:
    f_id: Uid
    assuming: None | Uid
    basis: Uid_set
    rule_specs: Uid_set
    ctx_simp: bool
    lift_bool: Cir_Decomp_lift_bool
    prune: bool

def Cir_Decomp_of_twine(d: twine.Decoder, off: int) -> Cir_Decomp:
    fields = list(d.get_array(off=off))
    f_id = Uid_of_twine(d=d, off=fields[0])
    assuming = twine.optional(d=d, off=fields[1], d0=lambda d, off: Uid_of_twine(d=d, off=off))
    basis = Uid_set_of_twine(d=d, off=fields[2])
    rule_specs = Uid_set_of_twine(d=d, off=fields[3])
    ctx_simp = d.get_bool(off=fields[4])
    lift_bool = Cir_Decomp_lift_bool_of_twine(d=d, off=fields[5])
    prune = d.get_bool(off=fields[6])
    return Cir_Decomp(f_id=f_id,assuming=assuming,basis=basis,rule_specs=rule_specs,ctx_simp=ctx_simp,lift_bool=lift_bool,prune=prune)

# clique Imandrax_api_cir.Db_ser.uid_map
# def Imandrax_api_cir.Db_ser.uid_map (mangled name: "Cir_Db_ser_uid_map")
type Cir_Db_ser_uid_map[_V_tyreg_poly_a] = list[tuple[Uid,"_V_tyreg_poly_a"]]

def Cir_Db_ser_uid_map_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Cir_Db_ser_uid_map:
    decode__tyreg_poly_a = d0
    return [(lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_a(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=off)]

# clique Imandrax_api_cir.Db_ser.ph_map
# def Imandrax_api_cir.Db_ser.ph_map (mangled name: "Cir_Db_ser_ph_map")
type Cir_Db_ser_ph_map[_V_tyreg_poly_a] = list[tuple[Cir_Pattern_head,"_V_tyreg_poly_a"]]

def Cir_Db_ser_ph_map_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Cir_Db_ser_ph_map:
    decode__tyreg_poly_a = d0
    return [(lambda tup: (Cir_Pattern_head_of_twine(d=d, off=tup[0]),decode__tyreg_poly_a(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=off)]

# clique Imandrax_api_cir.Db_ser.ca_ptr
# def Imandrax_api_cir.Db_ser.ca_ptr (mangled name: "Cir_Db_ser_ca_ptr")
type Cir_Db_ser_ca_ptr[_V_tyreg_poly_a] = Ca_store_Ca_ptr["_V_tyreg_poly_a"]

def Cir_Db_ser_ca_ptr_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Cir_Db_ser_ca_ptr:
    decode__tyreg_poly_a = d0
    return Ca_store_Ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_a(d=d,off=off)))

# clique Imandrax_api_cir.Db_ser.t
# def Imandrax_api_cir.Db_ser.t (mangled name: "Cir_Db_ser")
@dataclass(slots=True, frozen=True)
class Cir_Db_ser:
    decls: Uid_set
    rw_rules: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    inst_rules: Cir_Db_ser_uid_map[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]
    rule_spec_fc: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    rule_spec_rw_rules: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    fc: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    elim: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Elimination_rule]]]
    gen: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    thm_as_rw: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    thm_as_fc: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]]
    thm_as_elim: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Elimination_rule]]]
    thm_as_gen: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]]
    admission: Cir_Db_ser_uid_map[Cir_Db_ser_ca_ptr[Admission]]
    count_funs_of_ty: Cir_Db_ser_uid_map[Uid]
    disabled: Uid_set

def Cir_Db_ser_of_twine(d: twine.Decoder, off: int) -> Cir_Db_ser:
    fields = list(d.get_array(off=off))
    decls = Uid_set_of_twine(d=d, off=fields[0])
    rw_rules = Cir_Db_ser_ph_map_of_twine(d=d,off=fields[1],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Rewrite_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    inst_rules = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[2],d0=(lambda d, off: Cir_Db_ser_ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Instantiation_rule_of_twine(d=d, off=off)))))
    rule_spec_fc = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[3],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Trigger_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    rule_spec_rw_rules = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[4],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Rewrite_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    fc = Cir_Db_ser_ph_map_of_twine(d=d,off=fields[5],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Trigger_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    elim = Cir_Db_ser_ph_map_of_twine(d=d,off=fields[6],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Elimination_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    gen = Cir_Db_ser_ph_map_of_twine(d=d,off=fields[7],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Trigger_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    thm_as_rw = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[8],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Rewrite_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    thm_as_fc = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[9],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Instantiation_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    thm_as_elim = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[10],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Elimination_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    thm_as_gen = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[11],d0=(lambda d, off: [Cir_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Cir_Instantiation_rule_of_twine(d=d, off=off))) for x in d.get_array(off=off)]))
    admission = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[12],d0=(lambda d, off: Cir_Db_ser_ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: Admission_of_twine(d=d, off=off)))))
    count_funs_of_ty = Cir_Db_ser_uid_map_of_twine(d=d,off=fields[13],d0=(lambda d, off: Uid_of_twine(d=d, off=off)))
    disabled = Uid_set_of_twine(d=d, off=fields[14])
    return Cir_Db_ser(decls=decls,rw_rules=rw_rules,inst_rules=inst_rules,rule_spec_fc=rule_spec_fc,rule_spec_rw_rules=rule_spec_rw_rules,fc=fc,elim=elim,gen=gen,thm_as_rw=thm_as_rw,thm_as_fc=thm_as_fc,thm_as_elim=thm_as_elim,thm_as_gen=thm_as_gen,admission=admission,count_funs_of_ty=count_funs_of_ty,disabled=disabled)

# clique Imandrax_api_eval.Ordinal.t
# def Imandrax_api_eval.Ordinal.t (mangled name: "Eval_Ordinal")
@dataclass(slots=True, frozen=True)
class Eval_Ordinal_Int:
    arg: int

def Eval_Ordinal_Int_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Eval_Ordinal_Int:
    arg = d.get_int(off=args[0])
    return Eval_Ordinal_Int(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Ordinal_Cons:
    args: tuple[Eval_Ordinal,int,Eval_Ordinal]

def Eval_Ordinal_Cons_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Eval_Ordinal_Cons:
    cargs = (Eval_Ordinal_of_twine(d=d, off=args[0]),d.get_int(off=args[1]),Eval_Ordinal_of_twine(d=d, off=args[2]))
    return Eval_Ordinal_Cons(args=cargs)

type Eval_Ordinal = Eval_Ordinal_Int| Eval_Ordinal_Cons

def Eval_Ordinal_of_twine(d: twine.Decoder, off: int) -> Eval_Ordinal:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Eval_Ordinal_Int_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Eval_Ordinal_Cons_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Eval_Ordinal, got invalid constructor {idx}')

# clique Imandrax_api_eval.Value.cstor_descriptor
# def Imandrax_api_eval.Value.cstor_descriptor (mangled name: "Eval_Value_cstor_descriptor")
@dataclass(slots=True, frozen=True)
class Eval_Value_cstor_descriptor:
    cd_idx: int
    cd_name: Uid

def Eval_Value_cstor_descriptor_of_twine(d: twine.Decoder, off: int) -> Eval_Value_cstor_descriptor:
    fields = list(d.get_array(off=off))
    cd_idx = d.get_int(off=fields[0])
    cd_name = Uid_of_twine(d=d, off=fields[1])
    return Eval_Value_cstor_descriptor(cd_idx=cd_idx,cd_name=cd_name)

# clique Imandrax_api_eval.Value.record_descriptor
# def Imandrax_api_eval.Value.record_descriptor (mangled name: "Eval_Value_record_descriptor")
@dataclass(slots=True, frozen=True)
class Eval_Value_record_descriptor:
    rd_name: Uid
    rd_fields: list[Uid]

def Eval_Value_record_descriptor_of_twine(d: twine.Decoder, off: int) -> Eval_Value_record_descriptor:
    fields = list(d.get_array(off=off))
    rd_name = Uid_of_twine(d=d, off=fields[0])
    rd_fields = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    return Eval_Value_record_descriptor(rd_name=rd_name,rd_fields=rd_fields)

# clique Imandrax_api_eval.Value.view
# def Imandrax_api_eval.Value.view (mangled name: "Eval_Value_view")
@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_true[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    pass

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_false[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    pass

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_int[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: int

def Eval_Value_view_V_int_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_int[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = d.get_int(off=args[0])
    return Eval_Value_view_V_int(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_real[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: tuple[int, int]

def Eval_Value_view_V_real_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_real[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = decode_q(d=d,off=args[0])
    return Eval_Value_view_V_real(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_string[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: str

def Eval_Value_view_V_string_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_string[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = d.get_str(off=args[0])
    return Eval_Value_view_V_string(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_cstor[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    args: tuple[Eval_Value_cstor_descriptor,list["_V_tyreg_poly_v"]]

def Eval_Value_view_V_cstor_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_cstor[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    cargs = (Eval_Value_cstor_descriptor_of_twine(d=d, off=args[0]),[decode__tyreg_poly_v(d=d,off=x) for x in d.get_array(off=args[1])])
    return Eval_Value_view_V_cstor(args=cargs)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_tuple[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: list["_V_tyreg_poly_v"]

def Eval_Value_view_V_tuple_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_tuple[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = [decode__tyreg_poly_v(d=d,off=x) for x in d.get_array(off=args[0])]
    return Eval_Value_view_V_tuple(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_record[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    args: tuple[Eval_Value_record_descriptor,list["_V_tyreg_poly_v"]]

def Eval_Value_view_V_record_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_record[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    cargs = (Eval_Value_record_descriptor_of_twine(d=d, off=args[0]),[decode__tyreg_poly_v(d=d,off=x) for x in d.get_array(off=args[1])])
    return Eval_Value_view_V_record(args=cargs)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_quoted_term[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: Cir_Term

def Eval_Value_view_V_quoted_term_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_quoted_term[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = Cir_Term_of_twine(d=d, off=args[0])
    return Eval_Value_view_V_quoted_term(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_uid[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: Uid

def Eval_Value_view_V_uid_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_uid[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = Uid_of_twine(d=d, off=args[0])
    return Eval_Value_view_V_uid(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_closure[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: "_V_tyreg_poly_closure"

def Eval_Value_view_V_closure_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_closure[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = decode__tyreg_poly_closure(d=d,off=args[0])
    return Eval_Value_view_V_closure(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_custom[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: Eval__Value_Custom_value

def Eval_Value_view_V_custom_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_custom[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = Eval__Value_Custom_value_of_twine(d=d, off=args[0])
    return Eval_Value_view_V_custom(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval_Value_view_V_ordinal[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    arg: Eval_Ordinal

def Eval_Value_view_V_ordinal_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_ordinal[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = Eval_Ordinal_of_twine(d=d, off=args[0])
    return Eval_Value_view_V_ordinal(arg=arg)

type Eval_Value_view[_V_tyreg_poly_v,_V_tyreg_poly_closure] = Eval_Value_view_V_true[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_false[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_int[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_real[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_string[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_cstor[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_tuple[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_record[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_quoted_term[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_uid[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_closure[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_custom[_V_tyreg_poly_v,_V_tyreg_poly_closure]| Eval_Value_view_V_ordinal[_V_tyreg_poly_v,_V_tyreg_poly_closure]

def Eval_Value_view_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],off: int) -> Eval_Value_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Eval_Value_view_V_true[_V_tyreg_poly_v,_V_tyreg_poly_closure]()
         case twine.Constructor(idx=1, args=args):
             return Eval_Value_view_V_false[_V_tyreg_poly_v,_V_tyreg_poly_closure]()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Eval_Value_view_V_int_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Eval_Value_view_V_real_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Eval_Value_view_V_string_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Eval_Value_view_V_cstor_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Eval_Value_view_V_tuple_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Eval_Value_view_V_record_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return Eval_Value_view_V_quoted_term_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return Eval_Value_view_V_uid_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return Eval_Value_view_V_closure_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return Eval_Value_view_V_custom_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return Eval_Value_view_V_ordinal_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Eval_Value_view, got invalid constructor {idx}')

# clique Imandrax_api_eval.Value.t
# def Imandrax_api_eval.Value.t (mangled name: "Eval_Value")
@dataclass(slots=True, frozen=True)
class Eval_Value:
    v: Eval_Value_view[Eval_Value,None]

def Eval_Value_of_twine(d: twine.Decoder, off: int) -> Eval_Value:
    x = Eval_Value_view_of_twine(d=d,off=off,d0=(lambda d, off: Eval_Value_of_twine(d=d, off=off)),d1=(lambda d, off: d.get_null(off=off))) # single unboxed field
    return Eval_Value(v=x)

# clique Imandrax_api_report.Expansion.t
# def Imandrax_api_report.Expansion.t (mangled name: "Report_Expansion")
@dataclass(slots=True, frozen=True)
class Report_Expansion[_V_tyreg_poly_term]:
    f_name: Uid
    lhs: "_V_tyreg_poly_term"
    rhs: "_V_tyreg_poly_term"

def Report_Expansion_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Report_Expansion:
    decode__tyreg_poly_term = d0
    fields = list(d.get_array(off=off))
    f_name = Uid_of_twine(d=d, off=fields[0])
    lhs = decode__tyreg_poly_term(d=d,off=fields[1])
    rhs = decode__tyreg_poly_term(d=d,off=fields[2])
    return Report_Expansion(f_name=f_name,lhs=lhs,rhs=rhs)

# clique Imandrax_api_report.Instantiation.t
# def Imandrax_api_report.Instantiation.t (mangled name: "Report_Instantiation")
@dataclass(slots=True, frozen=True)
class Report_Instantiation[_V_tyreg_poly_term]:
    assertion: "_V_tyreg_poly_term"
    from_rule: Uid

def Report_Instantiation_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Report_Instantiation:
    decode__tyreg_poly_term = d0
    fields = list(d.get_array(off=off))
    assertion = decode__tyreg_poly_term(d=d,off=fields[0])
    from_rule = Uid_of_twine(d=d, off=fields[1])
    return Report_Instantiation(assertion=assertion,from_rule=from_rule)

# clique Imandrax_api_report.Smt_proof.t
# def Imandrax_api_report.Smt_proof.t (mangled name: "Report_Smt_proof")
@dataclass(slots=True, frozen=True)
class Report_Smt_proof[_V_tyreg_poly_term]:
    logic: Logic_fragment
    unsat_core: list["_V_tyreg_poly_term"]
    expansions: list[Report_Expansion["_V_tyreg_poly_term"]]
    instantiations: list[Report_Instantiation["_V_tyreg_poly_term"]]

def Report_Smt_proof_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Report_Smt_proof:
    decode__tyreg_poly_term = d0
    fields = list(d.get_array(off=off))
    logic = Logic_fragment_of_twine(d=d, off=fields[0])
    unsat_core = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[1])]
    expansions = [Report_Expansion_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=fields[2])]
    instantiations = [Report_Instantiation_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=fields[3])]
    return Report_Smt_proof(logic=logic,unsat_core=unsat_core,expansions=expansions,instantiations=instantiations)

# clique Imandrax_api_report.Rtext.t,Imandrax_api_report.Rtext.item
# def Imandrax_api_report.Rtext.t (mangled name: "Report_Rtext")
type Report_Rtext[_V_tyreg_poly_term] = list[Report_Rtext_item["_V_tyreg_poly_term"]]

def Report_Rtext_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Report_Rtext:
    decode__tyreg_poly_term = d0
    return [Report_Rtext_item_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=off)]
# def Imandrax_api_report.Rtext.item (mangled name: "Report_Rtext_item")
@dataclass(slots=True, frozen=True)
class Report_Rtext_item_S[_V_tyreg_poly_term]:
    arg: str

def Report_Rtext_item_S_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_S[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_str(off=args[0])
    return Report_Rtext_item_S(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_B[_V_tyreg_poly_term]:
    arg: str

def Report_Rtext_item_B_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_B[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_str(off=args[0])
    return Report_Rtext_item_B(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_I[_V_tyreg_poly_term]:
    arg: str

def Report_Rtext_item_I_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_I[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_str(off=args[0])
    return Report_Rtext_item_I(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Newline[_V_tyreg_poly_term]:
    pass

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Sub[_V_tyreg_poly_term]:
    arg: Report_Rtext["_V_tyreg_poly_term"]

def Report_Rtext_item_Sub_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Sub[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = Report_Rtext_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    return Report_Rtext_item_Sub(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_L[_V_tyreg_poly_term]:
    arg: list[Report_Rtext["_V_tyreg_poly_term"]]

def Report_Rtext_item_L_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_L[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = [Report_Rtext_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Report_Rtext_item_L(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Uid[_V_tyreg_poly_term]:
    arg: Uid

def Report_Rtext_item_Uid_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Uid[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = Uid_of_twine(d=d, off=args[0])
    return Report_Rtext_item_Uid(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Term[_V_tyreg_poly_term]:
    arg: "_V_tyreg_poly_term"

def Report_Rtext_item_Term_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Term[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Report_Rtext_item_Term(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Sequent[_V_tyreg_poly_term]:
    arg: Sequent_poly["_V_tyreg_poly_term"]

def Report_Rtext_item_Sequent_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Sequent[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = Sequent_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    return Report_Rtext_item_Sequent(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Rtext_item_Subst[_V_tyreg_poly_term]:
    arg: list[tuple["_V_tyreg_poly_term","_V_tyreg_poly_term"]]

def Report_Rtext_item_Subst_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Subst[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = [(lambda tup: (decode__tyreg_poly_term(d=d,off=tup[0]),decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    return Report_Rtext_item_Subst(arg=arg)

type Report_Rtext_item[_V_tyreg_poly_term] = Report_Rtext_item_S[_V_tyreg_poly_term]| Report_Rtext_item_B[_V_tyreg_poly_term]| Report_Rtext_item_I[_V_tyreg_poly_term]| Report_Rtext_item_Newline[_V_tyreg_poly_term]| Report_Rtext_item_Sub[_V_tyreg_poly_term]| Report_Rtext_item_L[_V_tyreg_poly_term]| Report_Rtext_item_Uid[_V_tyreg_poly_term]| Report_Rtext_item_Term[_V_tyreg_poly_term]| Report_Rtext_item_Sequent[_V_tyreg_poly_term]| Report_Rtext_item_Subst[_V_tyreg_poly_term]

def Report_Rtext_item_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Report_Rtext_item:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Report_Rtext_item_S_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Report_Rtext_item_B_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Report_Rtext_item_I_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=3, args=args):
             return Report_Rtext_item_Newline[_V_tyreg_poly_term]()
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Report_Rtext_item_Sub_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Report_Rtext_item_L_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Report_Rtext_item_Uid_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Report_Rtext_item_Term_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return Report_Rtext_item_Sequent_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return Report_Rtext_item_Subst_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Report_Rtext_item, got invalid constructor {idx}')

# clique Imandrax_api_report.Atomic_event.poly
# def Imandrax_api_report.Atomic_event.poly (mangled name: "Report_Atomic_event_poly")
@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    arg: Report_Rtext["_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_message_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    arg = Report_Rtext_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    return Report_Atomic_event_poly_E_message(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    arg: str

def Report_Atomic_event_poly_E_title_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    arg = d.get_str(off=args[0])
    return Report_Atomic_event_poly_E_title(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    vars: list["_V_tyreg_poly_var"]
    goal: "_V_tyreg_poly_term"


def Report_Atomic_event_poly_E_enter_waterfall_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    vars = [decode__tyreg_poly_var(d=d,off=x) for x in d.get_array(off=args[0])]
    goal = decode__tyreg_poly_term(d=d,off=args[1])
    return Report_Atomic_event_poly_E_enter_waterfall(vars=vars,goal=goal)


@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    arg: str

def Report_Atomic_event_poly_E_enter_tactic_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    arg = d.get_str(off=args[0])
    return Report_Atomic_event_poly_E_enter_tactic(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple[Cir_Rewrite_rule,"_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_rw_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (Cir_Rewrite_rule_of_twine(d=d, off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]),decode__tyreg_poly_term(d=d,off=args[2]))
    return Report_Atomic_event_poly_E_rw_success(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple[Cir_Rewrite_rule,"_V_tyreg_poly_term",str]

def Report_Atomic_event_poly_E_rw_fail_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (Cir_Rewrite_rule_of_twine(d=d, off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]),d.get_str(off=args[2]))
    return Report_Atomic_event_poly_E_rw_fail(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple[Cir_Instantiation_rule,"_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_inst_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (Cir_Instantiation_rule_of_twine(d=d, off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_inst_success(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    arg: list[Sequent_poly["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    arg = [Sequent_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Report_Atomic_event_poly_E_waterfall_checkpoint(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_term"

def Report_Atomic_event_poly_E_induction_scheme_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Report_Atomic_event_poly_E_induction_scheme(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    name: str
    goal: Sequent_poly["_V_tyreg_poly_term"]
    depth: int


def Report_Atomic_event_poly_E_attack_subgoal_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    name = d.get_str(off=args[0])
    goal = Sequent_poly_of_twine(d=d,off=args[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    depth = d.get_int(off=args[2])
    return Report_Atomic_event_poly_E_attack_subgoal(name=name,goal=goal,depth=depth)


@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_simplify_t_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_simplify_t(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_term",list["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_simplify_clause_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),[decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=args[1])])
    return Report_Atomic_event_poly_E_simplify_clause(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_term",Report_Smt_proof["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_proved_by_smt_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),Report_Smt_proof_of_twine(d=d,off=args[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))))
    return Report_Atomic_event_poly_E_proved_by_smt(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_term",None | Model["_V_tyreg_poly_term","_V_tyreg_poly_fn","_V_tyreg_poly_var","_V_tyreg_poly_ty"]]

def Report_Atomic_event_poly_E_refuted_by_smt_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),twine.optional(d=d, off=args[1], d0=lambda d, off: Model_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_fn(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_var(d=d,off=off)),d3=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    return Report_Atomic_event_poly_E_refuted_by_smt(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_fun_expansion_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_fn = d1
    decode__tyreg_poly_var = d2
    decode__tyreg_poly_ty = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_fun_expansion(args=cargs)

type Report_Atomic_event_poly[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty] = Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]| Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty]

def Report_Atomic_event_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_fn,_V_tyreg_poly_var,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_fn],d2: Callable[...,_V_tyreg_poly_var],d3: Callable[...,_V_tyreg_poly_ty],off: int) -> Report_Atomic_event_poly:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_message_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_title_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_enter_waterfall_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_enter_tactic_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_rw_success_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_rw_fail_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_inst_success_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_induction_scheme_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_attack_subgoal_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_simplify_t_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_simplify_clause_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_proved_by_smt_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=13, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_refuted_by_smt_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=14, args=args):
             args = tuple(args)
             return Report_Atomic_event_poly_E_fun_expansion_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,d3=d3,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Report_Atomic_event_poly, got invalid constructor {idx}')

# clique Imandrax_api_report.Atomic_event.t
# def Imandrax_api_report.Atomic_event.t (mangled name: "Report_Atomic_event")
type Report_Atomic_event = Report_Atomic_event_poly[Cir_Term,Cir_Applied_symbol,Cir_Var,Cir_Type]

def Report_Atomic_event_of_twine(d: twine.Decoder, off: int) -> Report_Atomic_event:
    return Report_Atomic_event_poly_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Applied_symbol_of_twine(d=d, off=off)),d2=(lambda d, off: Cir_Var_of_twine(d=d, off=off)),d3=(lambda d, off: Cir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_report.Event.t_linear
# def Imandrax_api_report.Event.t_linear (mangled name: "Report_Event_t_linear")
@dataclass(slots=True, frozen=True)
class Report_Event_t_linear_EL_atomic[_V_tyreg_poly_atomic_ev]:
    ts: float
    ev: "_V_tyreg_poly_atomic_ev"


def Report_Event_t_linear_EL_atomic_of_twine[_V_tyreg_poly_atomic_ev](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],args: tuple[int, ...]) -> Report_Event_t_linear_EL_atomic[_V_tyreg_poly_atomic_ev]:
    decode__tyreg_poly_atomic_ev = d0
    ts = d.get_float(off=args[0])
    ev = decode__tyreg_poly_atomic_ev(d=d,off=args[1])
    return Report_Event_t_linear_EL_atomic(ts=ts,ev=ev)


@dataclass(slots=True, frozen=True)
class Report_Event_t_linear_EL_enter_span[_V_tyreg_poly_atomic_ev]:
    ts: float
    ev: "_V_tyreg_poly_atomic_ev"


def Report_Event_t_linear_EL_enter_span_of_twine[_V_tyreg_poly_atomic_ev](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],args: tuple[int, ...]) -> Report_Event_t_linear_EL_enter_span[_V_tyreg_poly_atomic_ev]:
    decode__tyreg_poly_atomic_ev = d0
    ts = d.get_float(off=args[0])
    ev = decode__tyreg_poly_atomic_ev(d=d,off=args[1])
    return Report_Event_t_linear_EL_enter_span(ts=ts,ev=ev)


@dataclass(slots=True, frozen=True)
class Report_Event_t_linear_EL_exit_span[_V_tyreg_poly_atomic_ev]:
    ts: float


def Report_Event_t_linear_EL_exit_span_of_twine[_V_tyreg_poly_atomic_ev](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],args: tuple[int, ...]) -> Report_Event_t_linear_EL_exit_span[_V_tyreg_poly_atomic_ev]:
    decode__tyreg_poly_atomic_ev = d0
    ts = d.get_float(off=args[0])
    return Report_Event_t_linear_EL_exit_span(ts=ts)


type Report_Event_t_linear[_V_tyreg_poly_atomic_ev] = Report_Event_t_linear_EL_atomic[_V_tyreg_poly_atomic_ev]| Report_Event_t_linear_EL_enter_span[_V_tyreg_poly_atomic_ev]| Report_Event_t_linear_EL_exit_span[_V_tyreg_poly_atomic_ev]

def Report_Event_t_linear_of_twine[_V_tyreg_poly_atomic_ev](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],off: int) -> Report_Event_t_linear:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Report_Event_t_linear_EL_atomic_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Report_Event_t_linear_EL_enter_span_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Report_Event_t_linear_EL_exit_span_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Report_Event_t_linear, got invalid constructor {idx}')

# clique Imandrax_api_report.Event.t_tree
# def Imandrax_api_report.Event.t_tree (mangled name: "Report_Event_t_tree")
@dataclass(slots=True, frozen=True)
class Report_Event_t_tree_ET_atomic[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]:
    ts: float
    ev: "_V_tyreg_poly_atomic_ev"


def Report_Event_t_tree_ET_atomic_of_twine[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],d1: Callable[...,_V_tyreg_poly_sub],args: tuple[int, ...]) -> Report_Event_t_tree_ET_atomic[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]:
    decode__tyreg_poly_atomic_ev = d0
    decode__tyreg_poly_sub = d1
    ts = d.get_float(off=args[0])
    ev = decode__tyreg_poly_atomic_ev(d=d,off=args[1])
    return Report_Event_t_tree_ET_atomic(ts=ts,ev=ev)


@dataclass(slots=True, frozen=True)
class Report_Event_t_tree_ET_span[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]:
    ts: float
    duration: float
    ev: "_V_tyreg_poly_atomic_ev"
    sub: "_V_tyreg_poly_sub"


def Report_Event_t_tree_ET_span_of_twine[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],d1: Callable[...,_V_tyreg_poly_sub],args: tuple[int, ...]) -> Report_Event_t_tree_ET_span[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]:
    decode__tyreg_poly_atomic_ev = d0
    decode__tyreg_poly_sub = d1
    ts = d.get_float(off=args[0])
    duration = d.get_float(off=args[1])
    ev = decode__tyreg_poly_atomic_ev(d=d,off=args[2])
    sub = decode__tyreg_poly_sub(d=d,off=args[3])
    return Report_Event_t_tree_ET_span(ts=ts,duration=duration,ev=ev,sub=sub)


type Report_Event_t_tree[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub] = Report_Event_t_tree_ET_atomic[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]| Report_Event_t_tree_ET_span[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub]

def Report_Event_t_tree_of_twine[_V_tyreg_poly_atomic_ev,_V_tyreg_poly_sub](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_atomic_ev],d1: Callable[...,_V_tyreg_poly_sub],off: int) -> Report_Event_t_tree:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Report_Event_t_tree_ET_atomic_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Report_Event_t_tree_ET_span_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Report_Event_t_tree, got invalid constructor {idx}')

# clique Imandrax_api_report.Report.event
# def Imandrax_api_report.Report.event (mangled name: "Report_Report_event")
type Report_Report_event = Report_Event_t_linear[Report_Atomic_event]

def Report_Report_event_of_twine(d: twine.Decoder, off: int) -> Report_Report_event:
    return Report_Event_t_linear_of_twine(d=d,off=off,d0=(lambda d, off: Report_Atomic_event_of_twine(d=d, off=off)))

# clique Imandrax_api_report.Report.t
# def Imandrax_api_report.Report.t (mangled name: "Report_Report")
@dataclass(slots=True, frozen=True)
class Report_Report:
    events: list[Report_Report_event]

def Report_Report_of_twine(d: twine.Decoder, off: int) -> Report_Report:
    x = [Report_Report_event_of_twine(d=d, off=x) for x in d.get_array(off=off)] # single unboxed field
    return Report_Report(events=x)

# clique Imandrax_api_proof.Arg.t
# def Imandrax_api_proof.Arg.t (mangled name: "Proof_Arg")
@dataclass(slots=True, frozen=True)
class Proof_Arg_A_term[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_term"

def Proof_Arg_A_term_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_term[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Proof_Arg_A_term(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_ty[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_ty"

def Proof_Arg_A_ty_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_ty[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = decode__tyreg_poly_ty(d=d,off=args[0])
    return Proof_Arg_A_ty(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_int[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: int

def Proof_Arg_A_int_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_int[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = d.get_int(off=args[0])
    return Proof_Arg_A_int(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_string[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: str

def Proof_Arg_A_string_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_string[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = d.get_str(off=args[0])
    return Proof_Arg_A_string(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_list[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: list[Proof_Arg["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]

def Proof_Arg_A_list_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_list[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = [Proof_Arg_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Proof_Arg_A_list(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_dict[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: list[tuple[str,Proof_Arg["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]

def Proof_Arg_A_dict_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_dict[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = [(lambda tup: (d.get_str(off=tup[0]),Proof_Arg_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    return Proof_Arg_A_dict(arg=arg)

@dataclass(slots=True, frozen=True)
class Proof_Arg_A_seq[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Sequent_poly["_V_tyreg_poly_term"]

def Proof_Arg_A_seq_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_seq[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Sequent_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    return Proof_Arg_A_seq(arg=arg)

type Proof_Arg[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Proof_Arg_A_term[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_ty[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_int[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_string[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_list[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_dict[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Proof_Arg_A_seq[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Proof_Arg_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Proof_Arg:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Proof_Arg_A_term_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Proof_Arg_A_ty_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Proof_Arg_A_int_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Proof_Arg_A_string_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Proof_Arg_A_list_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Proof_Arg_A_dict_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Proof_Arg_A_seq_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Proof_Arg, got invalid constructor {idx}')

# clique Imandrax_api_proof.Var_poly.t
# def Imandrax_api_proof.Var_poly.t (mangled name: "Proof_Var_poly")
type Proof_Var_poly[_V_tyreg_poly_ty] = tuple[Uid,"_V_tyreg_poly_ty"]

def Proof_Var_poly_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Proof_Var_poly:
    decode__tyreg_poly_ty = d0
    return (lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_ty(d=d,off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_proof.View.t
# def Imandrax_api_proof.View.t (mangled name: "Proof_View")
@dataclass(slots=True, frozen=True)
class Proof_View_T_assume[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    pass

@dataclass(slots=True, frozen=True)
class Proof_View_T_subst[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    t_subst: list[tuple[Proof_Var_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_term"]]
    ty_subst: list[tuple[Uid,"_V_tyreg_poly_ty"]]
    premise: "_V_tyreg_poly_proof"


def Proof_View_T_subst_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_proof],args: tuple[int, ...]) -> Proof_View_T_subst[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_proof = d2
    t_subst = [(lambda tup: (Proof_Var_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    ty_subst = [(lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_ty(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[1])]
    premise = decode__tyreg_poly_proof(d=d,off=args[2])
    return Proof_View_T_subst(t_subst=t_subst,ty_subst=ty_subst,premise=premise)


@dataclass(slots=True, frozen=True)
class Proof_View_T_deduction[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    premises: list[tuple[str,list["_V_tyreg_poly_proof"]]]


def Proof_View_T_deduction_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_proof],args: tuple[int, ...]) -> Proof_View_T_deduction[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_proof = d2
    premises = [(lambda tup: (d.get_str(off=tup[0]),[decode__tyreg_poly_proof(d=d,off=x) for x in d.get_array(off=tup[1])]))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    return Proof_View_T_deduction(premises=premises)


@dataclass(slots=True, frozen=True)
class Proof_View_T_rule[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    rule: str
    args: list[Proof_Arg["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]


def Proof_View_T_rule_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_proof],args: tuple[int, ...]) -> Proof_View_T_rule[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_proof = d2
    rule = d.get_str(off=args[0])
    args = [Proof_Arg_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=args[1])]
    return Proof_View_T_rule(rule=rule,args=args)


type Proof_View[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof] = Proof_View_T_assume[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]| Proof_View_T_subst[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]| Proof_View_T_deduction[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]| Proof_View_T_rule[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]

def Proof_View_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_proof],off: int) -> Proof_View:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Proof_View_T_assume[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Proof_View_T_subst_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Proof_View_T_deduction_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Proof_View_T_rule_of_twine(d=d, args=args, d0=d0,d1=d1,d2=d2,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Proof_View, got invalid constructor {idx}')

# clique Imandrax_api_proof.Proof_term_poly.t
# def Imandrax_api_proof.Proof_term_poly.t (mangled name: "Proof_Proof_term_poly")
@dataclass(slots=True, frozen=True)
class Proof_Proof_term_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof]:
    id: int
    concl: Sequent_poly["_V_tyreg_poly_term"]
    view: Proof_View["_V_tyreg_poly_term","_V_tyreg_poly_ty","_V_tyreg_poly_proof"]

def Proof_Proof_term_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_proof](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_proof],off: int) -> Proof_Proof_term_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_proof = d2
    fields = list(d.get_array(off=off))
    id = d.get_int(off=fields[0])
    concl = Sequent_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    view = Proof_View_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_proof(d=d,off=off)))
    return Proof_Proof_term_poly(id=id,concl=concl,view=view)

# clique Imandrax_api_proof.Cir_proof_term.t,Imandrax_api_proof.Cir_proof_term.t_inner
# def Imandrax_api_proof.Cir_proof_term.t (mangled name: "Proof_Cir_proof_term")
@dataclass(slots=True, frozen=True)
class Proof_Cir_proof_term:
    p: Proof_Cir_proof_term_t_inner

def Proof_Cir_proof_term_of_twine(d: twine.Decoder, off: int) -> Proof_Cir_proof_term:
    x = Proof_Cir_proof_term_t_inner_of_twine(d=d, off=off) # single unboxed field
    return Proof_Cir_proof_term(p=x)
# def Imandrax_api_proof.Cir_proof_term.t_inner (mangled name: "Proof_Cir_proof_term_t_inner")
type Proof_Cir_proof_term_t_inner = Proof_Proof_term_poly[Cir_Term,Cir_Type,Proof_Cir_proof_term]

def Proof_Cir_proof_term_t_inner_of_twine(d: twine.Decoder, off: int) -> Proof_Cir_proof_term_t_inner:
    return Proof_Proof_term_poly_of_twine(d=d,off=off,d0=(lambda d, off: Cir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Cir_Type_of_twine(d=d, off=off)),d2=(lambda d, off: Proof_Cir_proof_term_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.PO_task.t
# def Imandrax_api_tasks.PO_task.t (mangled name: "Tasks_PO_task")
@dataclass(slots=True, frozen=True)
class Tasks_PO_task:
    from_sym: str
    count: int
    db: Cir_Db_ser
    po: Cir_Proof_obligation

def Tasks_PO_task_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_task:
    fields = list(d.get_array(off=off))
    from_sym = d.get_str(off=fields[0])
    count = d.get_int(off=fields[1])
    db = Cir_Db_ser_of_twine(d=d, off=fields[2])
    po = Cir_Proof_obligation_of_twine(d=d, off=fields[3])
    return Tasks_PO_task(from_sym=from_sym,count=count,db=db,po=po)

# clique Imandrax_api_tasks.PO_res.stats
# def Imandrax_api_tasks.PO_res.stats (mangled name: "Tasks_PO_res_stats")
type Tasks_PO_res_stats = Stat_time

def Tasks_PO_res_stats_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_stats:
    return Stat_time_of_twine(d=d, off=off)

# clique Imandrax_api_tasks.PO_res.proof_found
# def Imandrax_api_tasks.PO_res.proof_found (mangled name: "Tasks_PO_res_proof_found")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_proof_found:
    anchor: Anchor
    proof: Proof_Cir_proof_term

def Tasks_PO_res_proof_found_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_proof_found:
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    proof = Proof_Cir_proof_term_of_twine(d=d, off=fields[1])
    return Tasks_PO_res_proof_found(anchor=anchor,proof=proof)

# clique Imandrax_api_tasks.PO_res.instance
# def Imandrax_api_tasks.PO_res.instance (mangled name: "Tasks_PO_res_instance")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_instance:
    anchor: Anchor
    model: Cir_Model

def Tasks_PO_res_instance_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_instance:
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    model = Cir_Model_of_twine(d=d, off=fields[1])
    return Tasks_PO_res_instance(anchor=anchor,model=model)

# clique Imandrax_api_tasks.PO_res.no_proof
# def Imandrax_api_tasks.PO_res.no_proof (mangled name: "Tasks_PO_res_no_proof")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_no_proof:
    err: Error_Error_core
    counter_model: None | Cir_Model
    subgoals: list[Cir_Sequent]

def Tasks_PO_res_no_proof_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_no_proof:
    fields = list(d.get_array(off=off))
    err = Error_Error_core_of_twine(d=d, off=fields[0])
    counter_model = twine.optional(d=d, off=fields[1], d0=lambda d, off: Cir_Model_of_twine(d=d, off=off))
    subgoals = [Cir_Sequent_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    return Tasks_PO_res_no_proof(err=err,counter_model=counter_model,subgoals=subgoals)

# clique Imandrax_api_tasks.PO_res.unsat
# def Imandrax_api_tasks.PO_res.unsat (mangled name: "Tasks_PO_res_unsat")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_unsat:
    anchor: Anchor
    err: Error_Error_core
    proof: Proof_Cir_proof_term

def Tasks_PO_res_unsat_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_unsat:
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    err = Error_Error_core_of_twine(d=d, off=fields[1])
    proof = Proof_Cir_proof_term_of_twine(d=d, off=fields[2])
    return Tasks_PO_res_unsat(anchor=anchor,err=err,proof=proof)

# clique Imandrax_api_tasks.PO_res.success
# def Imandrax_api_tasks.PO_res.success (mangled name: "Tasks_PO_res_success")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_success_Proof:
    arg: Tasks_PO_res_proof_found

def Tasks_PO_res_success_Proof_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_success_Proof:
    arg = Tasks_PO_res_proof_found_of_twine(d=d, off=args[0])
    return Tasks_PO_res_success_Proof(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_success_Instance:
    arg: Tasks_PO_res_instance

def Tasks_PO_res_success_Instance_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_success_Instance:
    arg = Tasks_PO_res_instance_of_twine(d=d, off=args[0])
    return Tasks_PO_res_success_Instance(arg=arg)

type Tasks_PO_res_success = Tasks_PO_res_success_Proof| Tasks_PO_res_success_Instance

def Tasks_PO_res_success_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_success:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_PO_res_success_Proof_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Tasks_PO_res_success_Instance_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_PO_res_success, got invalid constructor {idx}')

# clique Imandrax_api_tasks.PO_res.error
# def Imandrax_api_tasks.PO_res.error (mangled name: "Tasks_PO_res_error")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_No_proof:
    arg: Tasks_PO_res_no_proof

def Tasks_PO_res_error_No_proof_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_error_No_proof:
    arg = Tasks_PO_res_no_proof_of_twine(d=d, off=args[0])
    return Tasks_PO_res_error_No_proof(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Unsat:
    arg: Tasks_PO_res_unsat

def Tasks_PO_res_error_Unsat_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_error_Unsat:
    arg = Tasks_PO_res_unsat_of_twine(d=d, off=args[0])
    return Tasks_PO_res_error_Unsat(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Invalid_model:
    args: tuple[Error_Error_core,Cir_Model]

def Tasks_PO_res_error_Invalid_model_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_error_Invalid_model:
    cargs = (Error_Error_core_of_twine(d=d, off=args[0]),Cir_Model_of_twine(d=d, off=args[1]))
    return Tasks_PO_res_error_Invalid_model(args=cargs)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Error:
    arg: Error_Error_core

def Tasks_PO_res_error_Error_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_PO_res_error_Error:
    arg = Error_Error_core_of_twine(d=d, off=args[0])
    return Tasks_PO_res_error_Error(arg=arg)

type Tasks_PO_res_error = Tasks_PO_res_error_No_proof| Tasks_PO_res_error_Unsat| Tasks_PO_res_error_Invalid_model| Tasks_PO_res_error_Error

def Tasks_PO_res_error_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_error:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_No_proof_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Unsat_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Invalid_model_of_twine(d=d, args=args, )
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Error_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_PO_res_error, got invalid constructor {idx}')

# clique Imandrax_api_tasks.PO_res.result
# def Imandrax_api_tasks.PO_res.result (mangled name: "Tasks_PO_res_result")
type Tasks_PO_res_result[_V_tyreg_poly_a] = "_V_tyreg_poly_a" | Tasks_PO_res_error

def Tasks_PO_res_result_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Tasks_PO_res_result:
    decode__tyreg_poly_a = d0
    return twine_result(d=d, off=off, d0=lambda d, off: decode__tyreg_poly_a(d=d,off=off), d1=lambda d, off: Tasks_PO_res_error_of_twine(d=d, off=off))

# clique Imandrax_api_tasks.PO_res.t
# def Imandrax_api_tasks.PO_res.t (mangled name: "Tasks_PO_res")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res:
    from_: Ca_store_Ca_ptr[Cir_Proof_obligation]
    res: Tasks_PO_res_result[Tasks_PO_res_success]
    stats: Tasks_PO_res_stats
    report: In_mem_archive[Report_Report]

def Tasks_PO_res_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res:
    fields = list(d.get_array(off=off))
    from_ = Ca_store_Ca_ptr_of_twine(d=d,off=fields[0],d0=(lambda d, off: Cir_Proof_obligation_of_twine(d=d, off=off)))
    res = Tasks_PO_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_PO_res_success_of_twine(d=d, off=off)))
    stats = Tasks_PO_res_stats_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_PO_res(from_=from_,res=res,stats=stats,report=report)

# clique Imandrax_api_tasks.Eval_task.t
# def Imandrax_api_tasks.Eval_task.t (mangled name: "Tasks_Eval_task")
@dataclass(slots=True, frozen=True)
class Tasks_Eval_task:
    db: Cir_Db_ser
    term: Cir_Term
    anchor: Anchor
    timeout: None | int

def Tasks_Eval_task_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_task:
    fields = list(d.get_array(off=off))
    db = Cir_Db_ser_of_twine(d=d, off=fields[0])
    term = Cir_Term_of_twine(d=d, off=fields[1])
    anchor = Anchor_of_twine(d=d, off=fields[2])
    timeout = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_int(off=off))
    return Tasks_Eval_task(db=db,term=term,anchor=anchor,timeout=timeout)

# clique Imandrax_api_tasks.Eval_res.value
# def Imandrax_api_tasks.Eval_res.value (mangled name: "Tasks_Eval_res_value")
type Tasks_Eval_res_value = Eval_Value

def Tasks_Eval_res_value_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_res_value:
    return Eval_Value_of_twine(d=d, off=off)

# clique Imandrax_api_tasks.Eval_res.stats
# def Imandrax_api_tasks.Eval_res.stats (mangled name: "Tasks_Eval_res_stats")
@dataclass(slots=True, frozen=True)
class Tasks_Eval_res_stats:
    compile_time: float
    exec_time: float

def Tasks_Eval_res_stats_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_res_stats:
    fields = list(d.get_array(off=off))
    compile_time = d.get_float(off=fields[0])
    exec_time = d.get_float(off=fields[1])
    return Tasks_Eval_res_stats(compile_time=compile_time,exec_time=exec_time)

# clique Imandrax_api_tasks.Eval_res.success
# def Imandrax_api_tasks.Eval_res.success (mangled name: "Tasks_Eval_res_success")
@dataclass(slots=True, frozen=True)
class Tasks_Eval_res_success:
    v: Tasks_Eval_res_value

def Tasks_Eval_res_success_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_res_success:
    x = Tasks_Eval_res_value_of_twine(d=d, off=off) # single unboxed field
    return Tasks_Eval_res_success(v=x)

# clique Imandrax_api_tasks.Eval_res.t
# def Imandrax_api_tasks.Eval_res.t (mangled name: "Tasks_Eval_res")
@dataclass(slots=True, frozen=True)
class Tasks_Eval_res:
    res: Error | Tasks_Eval_res_success
    stats: Tasks_Eval_res_stats

def Tasks_Eval_res_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_res:
    fields = list(d.get_array(off=off))
    res = twine_result(d=d, off=fields[0], d0=lambda d, off: Tasks_Eval_res_success_of_twine(d=d, off=off), d1=lambda d, off: Error_Error_core_of_twine(d=d, off=off))
    stats = Tasks_Eval_res_stats_of_twine(d=d, off=fields[1])
    return Tasks_Eval_res(res=res,stats=stats)

# clique Imandrax_api_tasks.Decomp_task.t
# def Imandrax_api_tasks.Decomp_task.t (mangled name: "Tasks_Decomp_task")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_task:
    db: Cir_Db_ser
    decomp: Cir_Decomp
    anchor: Anchor

def Tasks_Decomp_task_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_task:
    fields = list(d.get_array(off=off))
    db = Cir_Db_ser_of_twine(d=d, off=fields[0])
    decomp = Cir_Decomp_of_twine(d=d, off=fields[1])
    anchor = Anchor_of_twine(d=d, off=fields[2])
    return Tasks_Decomp_task(db=db,decomp=decomp,anchor=anchor)

# clique Imandrax_api_tasks.Decomp_res.success
# def Imandrax_api_tasks.Decomp_res.success (mangled name: "Tasks_Decomp_res_success")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res_success:
    anchor: Anchor
    decomp: Cir_Fun_decomp

def Tasks_Decomp_res_success_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_res_success:
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    decomp = Cir_Fun_decomp_of_twine(d=d, off=fields[1])
    return Tasks_Decomp_res_success(anchor=anchor,decomp=decomp)

# clique Imandrax_api_tasks.Decomp_res.error
# def Imandrax_api_tasks.Decomp_res.error (mangled name: "Tasks_Decomp_res_error")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res_error_Error:
    arg: Error_Error_core

def Tasks_Decomp_res_error_Error_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Tasks_Decomp_res_error_Error:
    arg = Error_Error_core_of_twine(d=d, off=args[0])
    return Tasks_Decomp_res_error_Error(arg=arg)

type Tasks_Decomp_res_error = Tasks_Decomp_res_error_Error

def Tasks_Decomp_res_error_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_res_error:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_Decomp_res_error_Error_of_twine(d=d, args=args, )
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_Decomp_res_error, got invalid constructor {idx}')

# clique Imandrax_api_tasks.Decomp_res.result
# def Imandrax_api_tasks.Decomp_res.result (mangled name: "Tasks_Decomp_res_result")
type Tasks_Decomp_res_result[_V_tyreg_poly_a] = "_V_tyreg_poly_a" | Tasks_Decomp_res_error

def Tasks_Decomp_res_result_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Tasks_Decomp_res_result:
    decode__tyreg_poly_a = d0
    return twine_result(d=d, off=off, d0=lambda d, off: decode__tyreg_poly_a(d=d,off=off), d1=lambda d, off: Tasks_Decomp_res_error_of_twine(d=d, off=off))

# clique Imandrax_api_tasks.Decomp_res.t
# def Imandrax_api_tasks.Decomp_res.t (mangled name: "Tasks_Decomp_res")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res:
    from_: Ca_store_Ca_ptr[Cir_Decomp]
    res: Tasks_Decomp_res_result[Tasks_Decomp_res_success]
    stats: Stat_time
    report: In_mem_archive[Report_Report]

def Tasks_Decomp_res_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_res:
    fields = list(d.get_array(off=off))
    from_ = Ca_store_Ca_ptr_of_twine(d=d,off=fields[0],d0=(lambda d, off: Cir_Decomp_of_twine(d=d, off=off)))
    res = Tasks_Decomp_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_Decomp_res_success_of_twine(d=d, off=off)))
    stats = Stat_time_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_Decomp_res(from_=from_,res=res,stats=stats,report=report)


# Artifacts

type Artifact = Cir_Term|Cir_Type|Tasks_PO_task|Tasks_PO_res|Tasks_Eval_task|Tasks_Eval_res|Cir_Model|str|Cir_Fun_decomp|Tasks_Decomp_task|Tasks_Decomp_res|Report_Report

artifact_decoders = {\
  'term': (lambda d, off: Cir_Term_of_twine(d=d, off=off)),
  'ty': (lambda d, off: Cir_Type_of_twine(d=d, off=off)),
  'po_task': (lambda d, off: Tasks_PO_task_of_twine(d=d, off=off)),
  'po_res': (lambda d, off: Tasks_PO_res_of_twine(d=d, off=off)),
  'eval_task': (lambda d, off: Tasks_Eval_task_of_twine(d=d, off=off)),
  'eval_res': (lambda d, off: Tasks_Eval_res_of_twine(d=d, off=off)),
  'cir.model': (lambda d, off: Cir_Model_of_twine(d=d, off=off)),
  'show': (lambda d, off: d.get_str(off=off)),
  'cir.fun_decomp': (lambda d, off: Cir_Fun_decomp_of_twine(d=d, off=off)),
  'decomp_task': (lambda d, off: Tasks_Decomp_task_of_twine(d=d, off=off)),
  'decomp_res': (lambda d, off: Tasks_Decomp_res_of_twine(d=d, off=off)),
  'report': (lambda d, off: Report_Report_of_twine(d=d, off=off)),
}



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
  

