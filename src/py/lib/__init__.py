
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


@dataclass(slots=True, frozen=True)
class Builtin_data_kind_Decomp:
    decomp_name: str


def Builtin_data_kind_Decomp_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Builtin_data_kind_Decomp:
    decomp_name = d.get_str(off=args[0])
    return Builtin_data_kind_Decomp(decomp_name=decomp_name)


type Builtin_data_kind = Builtin_data_kind_Logic_core| Builtin_data_kind_Special| Builtin_data_kind_Tactic| Builtin_data_kind_Decomp

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
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Builtin_data_kind_Decomp_of_twine(d=d, args=args, )
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

# clique Imandrax_api.Clique.t
# def Imandrax_api.Clique.t (mangled name: "Clique")
type Clique = Uid_set

def Clique_of_twine(d: twine.Decoder, off: int) -> Clique:
    return Uid_set_of_twine(d=d, off=off)

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

# clique Imandrax_api.Ty_view.def_poly
# def Imandrax_api.Ty_view.def_poly (mangled name: "Ty_view_def_poly")
@dataclass(slots=True, frozen=True)
class Ty_view_def_poly[_V_tyreg_poly_ty]:
    name: Uid
    params: list[Uid]
    decl: Ty_view_decl[Uid,"_V_tyreg_poly_ty",Void]
    clique: None | Clique
    timeout: None | int

def Ty_view_def_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Ty_view_def_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    name = Uid_of_twine(d=d, off=fields[0])
    params = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    decl = Ty_view_decl_of_twine(d=d,off=fields[2],d0=(lambda d, off: Uid_of_twine(d=d, off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d2=(lambda d, off: Void_of_twine(d=d, off=off)))
    clique = twine.optional(d=d, off=fields[3], d0=lambda d, off: Clique_of_twine(d=d, off=off))
    timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    return Ty_view_def_poly(name=name,params=params,decl=decl,clique=clique,timeout=timeout)

# clique Imandrax_api.Stat_time.t
# def Imandrax_api.Stat_time.t (mangled name: "Stat_time")
@dataclass(slots=True, frozen=True)
class Stat_time:
    time_s: float

def Stat_time_of_twine(d: twine.Decoder, off: int) -> Stat_time:
    x = d.get_float(off=off) # single unboxed field
    return Stat_time(time_s=x)

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

# clique Imandrax_api.Case_poly.t_poly
# def Imandrax_api.Case_poly.t_poly (mangled name: "Case_poly_t_poly")
@dataclass(slots=True, frozen=True)
class Case_poly_t_poly[_V_tyreg_poly_t,_V_tyreg_poly_var,_V_tyreg_poly_sym]:
    case_cstor: "_V_tyreg_poly_sym"
    case_vars: list["_V_tyreg_poly_var"]
    case_rhs: "_V_tyreg_poly_t"
    case_labels: None | list[Uid]

def Case_poly_t_poly_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_var,_V_tyreg_poly_sym](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_var],d2: Callable[...,_V_tyreg_poly_sym],off: int) -> Case_poly_t_poly:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_var = d1
    decode__tyreg_poly_sym = d2
    fields = list(d.get_array(off=off))
    case_cstor = decode__tyreg_poly_sym(d=d,off=fields[0])
    case_vars = [decode__tyreg_poly_var(d=d,off=x) for x in d.get_array(off=fields[1])]
    case_rhs = decode__tyreg_poly_t(d=d,off=fields[2])
    case_labels = twine.optional(d=d, off=fields[3], d0=lambda d, off: [Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return Case_poly_t_poly(case_cstor=case_cstor,case_vars=case_vars,case_rhs=case_rhs,case_labels=case_labels)

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

# clique Imandrax_api_common.Var.t_poly
# def Imandrax_api_common.Var.t_poly (mangled name: "Common_Var_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Var_t_poly[_V_tyreg_poly_ty]:
    id: Uid
    ty: "_V_tyreg_poly_ty"

def Common_Var_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Var_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    id = Uid_of_twine(d=d, off=fields[0])
    ty = decode__tyreg_poly_ty(d=d,off=fields[1])
    return Common_Var_t_poly(id=id,ty=ty)

# clique Imandrax_api_common.Type_schema.t_poly
# def Imandrax_api_common.Type_schema.t_poly (mangled name: "Common_Type_schema_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Type_schema_t_poly[_V_tyreg_poly_ty]:
    params: list[Uid]
    ty: "_V_tyreg_poly_ty"

def Common_Type_schema_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Type_schema_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    params = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[0])]
    ty = decode__tyreg_poly_ty(d=d,off=fields[1])
    return Common_Type_schema_t_poly(params=params,ty=ty)

# clique Imandrax_api_common.Typed_symbol.t_poly
# def Imandrax_api_common.Typed_symbol.t_poly (mangled name: "Common_Typed_symbol_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Typed_symbol_t_poly[_V_tyreg_poly_ty]:
    id: Uid
    ty: Common_Type_schema_t_poly["_V_tyreg_poly_ty"]

def Common_Typed_symbol_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Typed_symbol_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    id = Uid_of_twine(d=d, off=fields[0])
    ty = Common_Type_schema_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Common_Typed_symbol_t_poly(id=id,ty=ty)

# clique Imandrax_api_common.Applied_symbol.t_poly
# def Imandrax_api_common.Applied_symbol.t_poly (mangled name: "Common_Applied_symbol_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Applied_symbol_t_poly[_V_tyreg_poly_ty]:
    sym: Common_Typed_symbol_t_poly["_V_tyreg_poly_ty"]
    args: list["_V_tyreg_poly_ty"]
    ty: "_V_tyreg_poly_ty"

def Common_Applied_symbol_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Applied_symbol_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    sym = Common_Typed_symbol_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    args = [decode__tyreg_poly_ty(d=d,off=x) for x in d.get_array(off=fields[1])]
    ty = decode__tyreg_poly_ty(d=d,off=fields[2])
    return Common_Applied_symbol_t_poly(sym=sym,args=args,ty=ty)

# clique Imandrax_api_common.Fo_pattern.view
# def Imandrax_api_common.Fo_pattern.view (mangled name: "Common_Fo_pattern_view")
@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_any[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    pass

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_bool[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: bool

def Common_Fo_pattern_view_FO_bool_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_bool[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = d.get_bool(off=args[0])
    return Common_Fo_pattern_view_FO_bool(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_const[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: Const

def Common_Fo_pattern_view_FO_const_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_const[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = Const_of_twine(d=d, off=args[0])
    return Common_Fo_pattern_view_FO_const(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_var[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: Common_Var_t_poly["_V_tyreg_poly_ty"]

def Common_Fo_pattern_view_FO_var_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_var[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = Common_Var_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Common_Fo_pattern_view_FO_var(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_app[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    args: tuple[Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],list["_V_tyreg_poly_t"]]

def Common_Fo_pattern_view_FO_app_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_app[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    cargs = (Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),[decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])])
    return Common_Fo_pattern_view_FO_app(args=cargs)

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    args: tuple[None | Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],list["_V_tyreg_poly_t"]]

def Common_Fo_pattern_view_FO_cstor_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    cargs = (twine.optional(d=d, off=args[0], d0=lambda d, off: Common_Applied_symbol_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))),[decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])])
    return Common_Fo_pattern_view_FO_cstor(args=cargs)

@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    c: None | Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    i: int
    u: "_V_tyreg_poly_t"


def Common_Fo_pattern_view_FO_destruct_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    c = twine.optional(d=d, off=args[0], d0=lambda d, off: Common_Applied_symbol_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))
    i = d.get_int(off=args[1])
    u = decode__tyreg_poly_t(d=d,off=args[2])
    return Common_Fo_pattern_view_FO_destruct(c=c,i=i,u=u)


@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    c: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    u: "_V_tyreg_poly_t"


def Common_Fo_pattern_view_FO_is_a_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    c = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    u = decode__tyreg_poly_t(d=d,off=args[1])
    return Common_Fo_pattern_view_FO_is_a(c=c,u=u)


type Common_Fo_pattern_view[_V_tyreg_poly_t,_V_tyreg_poly_ty] = Common_Fo_pattern_view_FO_any[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_bool[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_const[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_var[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_app[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_cstor[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Common_Fo_pattern_view_FO_is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]

def Common_Fo_pattern_view_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Fo_pattern_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Common_Fo_pattern_view_FO_any[_V_tyreg_poly_t,_V_tyreg_poly_ty]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_bool_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_const_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_var_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_app_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_cstor_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_destruct_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Common_Fo_pattern_view_FO_is_a_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Fo_pattern_view, got invalid constructor {idx}')

# clique Imandrax_api_common.Fo_pattern.t_poly
# def Imandrax_api_common.Fo_pattern.t_poly (mangled name: "Common_Fo_pattern_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Fo_pattern_t_poly[_V_tyreg_poly_ty]:
    view: Common_Fo_pattern_view[Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_ty"]
    ty: "_V_tyreg_poly_ty"

def Common_Fo_pattern_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Fo_pattern_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    view = Common_Fo_pattern_view_of_twine(d=d,off=fields[0],d0=(lambda d, off: Common_Fo_pattern_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    ty = decode__tyreg_poly_ty(d=d,off=fields[1])
    return Common_Fo_pattern_t_poly(view=view,ty=ty)

# clique Imandrax_api_common.Pattern_head.t_poly
# def Imandrax_api_common.Pattern_head.t_poly (mangled name: "Common_Pattern_head_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Pattern_head_t_poly_PH_id[_V_tyreg_poly_ty]:
    arg: Uid

def Common_Pattern_head_t_poly_PH_id_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Pattern_head_t_poly_PH_id[_V_tyreg_poly_ty]:
    decode__tyreg_poly_ty = d0
    arg = Uid_of_twine(d=d, off=args[0])
    return Common_Pattern_head_t_poly_PH_id(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Pattern_head_t_poly_PH_ty[_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_ty"

def Common_Pattern_head_t_poly_PH_ty_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Pattern_head_t_poly_PH_ty[_V_tyreg_poly_ty]:
    decode__tyreg_poly_ty = d0
    arg = decode__tyreg_poly_ty(d=d,off=args[0])
    return Common_Pattern_head_t_poly_PH_ty(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Pattern_head_t_poly_PH_datatype_op[_V_tyreg_poly_ty]:
    pass

type Common_Pattern_head_t_poly[_V_tyreg_poly_ty] = Common_Pattern_head_t_poly_PH_id[_V_tyreg_poly_ty]| Common_Pattern_head_t_poly_PH_ty[_V_tyreg_poly_ty]| Common_Pattern_head_t_poly_PH_datatype_op[_V_tyreg_poly_ty]

def Common_Pattern_head_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Pattern_head_t_poly:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Common_Pattern_head_t_poly_PH_id_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Pattern_head_t_poly_PH_ty_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=2, args=args):
             return Common_Pattern_head_t_poly_PH_datatype_op[_V_tyreg_poly_ty]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Pattern_head_t_poly, got invalid constructor {idx}')

# clique Imandrax_api_common.Trigger.t_poly
# def Imandrax_api_common.Trigger.t_poly (mangled name: "Common_Trigger_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Trigger_t_poly[_V_tyreg_poly_ty]:
    trigger_head: Common_Pattern_head_t_poly["_V_tyreg_poly_ty"]
    trigger_patterns: list[Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"]]
    trigger_instantiation_rule_name: Uid

def Common_Trigger_t_poly_of_twine[_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Trigger_t_poly:
    decode__tyreg_poly_ty = d0
    fields = list(d.get_array(off=off))
    trigger_head = Common_Pattern_head_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    trigger_patterns = [Common_Fo_pattern_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[1])]
    trigger_instantiation_rule_name = Uid_of_twine(d=d, off=fields[2])
    return Common_Trigger_t_poly(trigger_head=trigger_head,trigger_patterns=trigger_patterns,trigger_instantiation_rule_name=trigger_instantiation_rule_name)

# clique Imandrax_api_common.Admission.t
# def Imandrax_api_common.Admission.t (mangled name: "Common_Admission")
@dataclass(slots=True, frozen=True)
class Common_Admission:
    measured_subset: list[str]
    measure_fun: None | Uid

def Common_Admission_of_twine(d: twine.Decoder, off: int) -> Common_Admission:
    fields = list(d.get_array(off=off))
    measured_subset = [d.get_str(off=x) for x in d.get_array(off=fields[0])]
    measure_fun = twine.optional(d=d, off=fields[1], d0=lambda d, off: Uid_of_twine(d=d, off=off))
    return Common_Admission(measured_subset=measured_subset,measure_fun=measure_fun)

# clique Imandrax_api_common.Hints.validation_strategy
# def Imandrax_api_common.Hints.validation_strategy (mangled name: "Common_Hints_validation_strategy")
@dataclass(slots=True, frozen=True)
class Common_Hints_validation_strategy_VS_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    tactic: None | tuple[list[Common_Var_t_poly["_V_tyreg_poly_ty"]],"_V_tyreg_poly_term"]


def Common_Hints_validation_strategy_VS_validate_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Hints_validation_strategy_VS_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    tactic = twine.optional(d=d, off=args[0], d0=lambda d, off: (lambda tup: ([Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=off))))
    return Common_Hints_validation_strategy_VS_validate(tactic=tactic)


@dataclass(slots=True, frozen=True)
class Common_Hints_validation_strategy_VS_no_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    pass

type Common_Hints_validation_strategy[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Common_Hints_validation_strategy_VS_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Common_Hints_validation_strategy_VS_no_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Common_Hints_validation_strategy_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Hints_validation_strategy:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Common_Hints_validation_strategy_VS_validate_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             return Common_Hints_validation_strategy_VS_no_validate[_V_tyreg_poly_term,_V_tyreg_poly_ty]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Hints_validation_strategy, got invalid constructor {idx}')

# clique Imandrax_api_common.Hints.t_poly
# def Imandrax_api_common.Hints.t_poly (mangled name: "Common_Hints_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Hints_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    f_validate_strat: Common_Hints_validation_strategy["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    f_unroll_def: None | int
    f_enable: list[Uid]
    f_disable: list[Uid]
    f_timeout: None | int
    f_admission: None | Common_Admission
    f_decomp: None | "_V_tyreg_poly_term"

def Common_Hints_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Hints_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    f_validate_strat = Common_Hints_validation_strategy_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    f_unroll_def = twine.optional(d=d, off=fields[1], d0=lambda d, off: d.get_int(off=off))
    f_enable = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    f_disable = [Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[3])]
    f_timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    f_admission = twine.optional(d=d, off=fields[5], d0=lambda d, off: Common_Admission_of_twine(d=d, off=off))
    f_decomp = twine.optional(d=d, off=fields[6], d0=lambda d, off: decode__tyreg_poly_term(d=d,off=off))
    return Common_Hints_t_poly(f_validate_strat=f_validate_strat,f_unroll_def=f_unroll_def,f_enable=f_enable,f_disable=f_disable,f_timeout=f_timeout,f_admission=f_admission,f_decomp=f_decomp)

# clique Imandrax_api_common.Fun_def.fun_kind
# def Imandrax_api_common.Fun_def.fun_kind (mangled name: "Common_Fun_def_fun_kind")
@dataclass(slots=True, frozen=True)
class Common_Fun_def_fun_kind_Fun_defined:
    is_macro: bool
    from_lambda: bool


def Common_Fun_def_fun_kind_Fun_defined_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Common_Fun_def_fun_kind_Fun_defined:
    is_macro = d.get_bool(off=args[0])
    from_lambda = d.get_bool(off=args[1])
    return Common_Fun_def_fun_kind_Fun_defined(is_macro=is_macro,from_lambda=from_lambda)


@dataclass(slots=True, frozen=True)
class Common_Fun_def_fun_kind_Fun_builtin:
    arg: Builtin_Fun

def Common_Fun_def_fun_kind_Fun_builtin_of_twine(d: twine.Decoder, args: tuple[int, ...]) -> Common_Fun_def_fun_kind_Fun_builtin:
    arg = Builtin_Fun_of_twine(d=d, off=args[0])
    return Common_Fun_def_fun_kind_Fun_builtin(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Fun_def_fun_kind_Fun_opaque:
    pass

type Common_Fun_def_fun_kind = Common_Fun_def_fun_kind_Fun_defined| Common_Fun_def_fun_kind_Fun_builtin| Common_Fun_def_fun_kind_Fun_opaque

def Common_Fun_def_fun_kind_of_twine(d: twine.Decoder, off: int) -> Common_Fun_def_fun_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Common_Fun_def_fun_kind_Fun_defined_of_twine(d=d, args=args, )
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Fun_def_fun_kind_Fun_builtin_of_twine(d=d, args=args, )
         case twine.Constructor(idx=2, args=args):
             return Common_Fun_def_fun_kind_Fun_opaque()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Fun_def_fun_kind, got invalid constructor {idx}')

# clique Imandrax_api_common.Fun_def.t_poly
# def Imandrax_api_common.Fun_def.t_poly (mangled name: "Common_Fun_def_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Fun_def_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    f_name: Uid
    f_ty: Common_Type_schema_t_poly["_V_tyreg_poly_ty"]
    f_args: list[Common_Var_t_poly["_V_tyreg_poly_ty"]]
    f_body: "_V_tyreg_poly_term"
    f_clique: None | Clique
    f_kind: Common_Fun_def_fun_kind
    f_hints: Common_Hints_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Common_Fun_def_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Fun_def_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    f_name = Uid_of_twine(d=d, off=fields[0])
    f_ty = Common_Type_schema_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    f_args = [Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[2])]
    f_body = decode__tyreg_poly_term(d=d,off=fields[3])
    f_clique = twine.optional(d=d, off=fields[4], d0=lambda d, off: Clique_of_twine(d=d, off=off))
    f_kind = Common_Fun_def_fun_kind_of_twine(d=d, off=fields[5])
    f_hints = Common_Hints_t_poly_of_twine(d=d,off=fields[6],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Common_Fun_def_t_poly(f_name=f_name,f_ty=f_ty,f_args=f_args,f_body=f_body,f_clique=f_clique,f_kind=f_kind,f_hints=f_hints)

# clique Imandrax_api_common.Pre_trigger.t_poly
# def Imandrax_api_common.Pre_trigger.t_poly (mangled name: "Common_Pre_trigger_t_poly")
type Common_Pre_trigger_t_poly[_V_tyreg_poly_term] = tuple["_V_tyreg_poly_term",As_trigger]

def Common_Pre_trigger_t_poly_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Common_Pre_trigger_t_poly:
    decode__tyreg_poly_term = d0
    return (lambda tup: (decode__tyreg_poly_term(d=d,off=tup[0]),As_trigger_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_common.Theorem.t_poly
# def Imandrax_api_common.Theorem.t_poly (mangled name: "Common_Theorem_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Theorem_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    thm_link: Common_Fun_def_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    thm_rewriting: bool
    thm_perm_restrict: bool
    thm_fc: bool
    thm_elim: bool
    thm_gen: bool
    thm_triggers: list[Common_Pre_trigger_t_poly["_V_tyreg_poly_term"]]
    thm_is_axiom: bool
    thm_by: tuple[list[Common_Var_t_poly["_V_tyreg_poly_ty"]],"_V_tyreg_poly_term"]

def Common_Theorem_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Theorem_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    thm_link = Common_Fun_def_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    thm_rewriting = d.get_bool(off=fields[1])
    thm_perm_restrict = d.get_bool(off=fields[2])
    thm_fc = d.get_bool(off=fields[3])
    thm_elim = d.get_bool(off=fields[4])
    thm_gen = d.get_bool(off=fields[5])
    thm_triggers = [Common_Pre_trigger_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=fields[6])]
    thm_is_axiom = d.get_bool(off=fields[7])
    thm_by = (lambda tup: ([Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=fields[8])))
    return Common_Theorem_t_poly(thm_link=thm_link,thm_rewriting=thm_rewriting,thm_perm_restrict=thm_perm_restrict,thm_fc=thm_fc,thm_elim=thm_elim,thm_gen=thm_gen,thm_triggers=thm_triggers,thm_is_axiom=thm_is_axiom,thm_by=thm_by)

# clique Imandrax_api_common.Tactic.t_poly
# def Imandrax_api_common.Tactic.t_poly (mangled name: "Common_Tactic_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Tactic_t_poly_Default_termination[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    basis: Uid_set


def Common_Tactic_t_poly_Default_termination_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Tactic_t_poly_Default_termination[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    basis = Uid_set_of_twine(d=d, off=args[0])
    return Common_Tactic_t_poly_Default_termination(basis=basis)


@dataclass(slots=True, frozen=True)
class Common_Tactic_t_poly_Default_thm[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    pass

@dataclass(slots=True, frozen=True)
class Common_Tactic_t_poly_Term[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: tuple[list[Common_Var_t_poly["_V_tyreg_poly_ty"]],"_V_tyreg_poly_term"]

def Common_Tactic_t_poly_Term_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Tactic_t_poly_Term[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = (lambda tup: ([Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=args[0])))
    return Common_Tactic_t_poly_Term(arg=arg)

type Common_Tactic_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Common_Tactic_t_poly_Default_termination[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Common_Tactic_t_poly_Default_thm[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Common_Tactic_t_poly_Term[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Common_Tactic_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Tactic_t_poly:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Common_Tactic_t_poly_Default_termination_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             return Common_Tactic_t_poly_Default_thm[_V_tyreg_poly_term,_V_tyreg_poly_ty]()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Common_Tactic_t_poly_Term_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Tactic_t_poly, got invalid constructor {idx}')

# clique Imandrax_api_common.Sequent.t_poly
# def Imandrax_api_common.Sequent.t_poly (mangled name: "Common_Sequent_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Sequent_t_poly[_V_tyreg_poly_term]:
    hyps: list["_V_tyreg_poly_term"]
    concls: list["_V_tyreg_poly_term"]

def Common_Sequent_t_poly_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Common_Sequent_t_poly:
    decode__tyreg_poly_term = d0
    fields = list(d.get_array(off=off))
    hyps = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[0])]
    concls = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[1])]
    return Common_Sequent_t_poly(hyps=hyps,concls=concls)

# clique Imandrax_api_common.Rewrite_rule.t_poly
# def Imandrax_api_common.Rewrite_rule.t_poly (mangled name: "Common_Rewrite_rule_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Rewrite_rule_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    rw_name: Uid
    rw_head: Common_Pattern_head_t_poly["_V_tyreg_poly_ty"]
    rw_lhs: Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"]
    rw_rhs: "_V_tyreg_poly_term"
    rw_guard: list["_V_tyreg_poly_term"]
    rw_vars: list[Common_Var_t_poly["_V_tyreg_poly_ty"]]
    rw_triggers: list[Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"]]
    rw_perm_restrict: bool
    rw_loop_break: None | Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"]

def Common_Rewrite_rule_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Rewrite_rule_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    rw_name = Uid_of_twine(d=d, off=fields[0])
    rw_head = Common_Pattern_head_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    rw_lhs = Common_Fo_pattern_t_poly_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    rw_rhs = decode__tyreg_poly_term(d=d,off=fields[3])
    rw_guard = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[4])]
    rw_vars = [Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[5])]
    rw_triggers = [Common_Fo_pattern_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[6])]
    rw_perm_restrict = d.get_bool(off=fields[7])
    rw_loop_break = twine.optional(d=d, off=fields[8], d0=lambda d, off: Common_Fo_pattern_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))
    return Common_Rewrite_rule_t_poly(rw_name=rw_name,rw_head=rw_head,rw_lhs=rw_lhs,rw_rhs=rw_rhs,rw_guard=rw_guard,rw_vars=rw_vars,rw_triggers=rw_triggers,rw_perm_restrict=rw_perm_restrict,rw_loop_break=rw_loop_break)

# clique Imandrax_api_common.Model.ty_def
# def Imandrax_api_common.Model.ty_def (mangled name: "Common_Model_ty_def")
@dataclass(slots=True, frozen=True)
class Common_Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: list["_V_tyreg_poly_term"]

def Common_Model_ty_def_Ty_finite_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=args[0])]
    return Common_Model_ty_def_Ty_finite(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: "_V_tyreg_poly_ty"

def Common_Model_ty_def_Ty_alias_unit_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = decode__tyreg_poly_ty(d=d,off=args[0])
    return Common_Model_ty_def_Ty_alias_unit(arg=arg)

type Common_Model_ty_def[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Common_Model_ty_def_Ty_finite[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Common_Model_ty_def_Ty_alias_unit[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Common_Model_ty_def_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Model_ty_def:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Common_Model_ty_def_Ty_finite_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Model_ty_def_Ty_alias_unit_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Model_ty_def, got invalid constructor {idx}')

# clique Imandrax_api_common.Model.fi
# def Imandrax_api_common.Model.fi (mangled name: "Common_Model_fi")
@dataclass(slots=True, frozen=True)
class Common_Model_fi[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    fi_args: list[Common_Var_t_poly["_V_tyreg_poly_ty"]]
    fi_ty_ret: "_V_tyreg_poly_ty"
    fi_cases: list[tuple[list["_V_tyreg_poly_term"],"_V_tyreg_poly_term"]]
    fi_else: "_V_tyreg_poly_term"

def Common_Model_fi_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Model_fi:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    fi_args = [Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[0])]
    fi_ty_ret = decode__tyreg_poly_ty(d=d,off=fields[1])
    fi_cases = [(lambda tup: ([decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    fi_else = decode__tyreg_poly_term(d=d,off=fields[3])
    return Common_Model_fi(fi_args=fi_args,fi_ty_ret=fi_ty_ret,fi_cases=fi_cases,fi_else=fi_else)

# clique Imandrax_api_common.Model.t_poly
# def Imandrax_api_common.Model.t_poly (mangled name: "Common_Model_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Model_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    tys: list[tuple["_V_tyreg_poly_ty",Common_Model_ty_def["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]
    consts: list[tuple[Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_term"]]
    funs: list[tuple[Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],Common_Model_fi["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]
    representable: bool
    completed: bool
    ty_subst: list[tuple[Uid,"_V_tyreg_poly_ty"]]

def Common_Model_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Model_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    tys = [(lambda tup: (decode__tyreg_poly_ty(d=d,off=tup[0]),Common_Model_ty_def_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[0])]
    consts = [(lambda tup: (Common_Applied_symbol_t_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[1])]
    funs = [(lambda tup: (Common_Applied_symbol_t_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),Common_Model_fi_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    representable = d.get_bool(off=fields[3])
    completed = d.get_bool(off=fields[4])
    ty_subst = [(lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_ty(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[5])]
    return Common_Model_t_poly(tys=tys,consts=consts,funs=funs,representable=representable,completed=completed,ty_subst=ty_subst)

# clique Imandrax_api_common.Region.status
# def Imandrax_api_common.Region.status (mangled name: "Common_Region_status")
@dataclass(slots=True, frozen=True)
class Common_Region_status_Unknown[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    pass

@dataclass(slots=True, frozen=True)
class Common_Region_status_Feasible[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Common_Region_status_Feasible_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Common_Region_status_Feasible[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Common_Model_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Common_Region_status_Feasible(arg=arg)

type Common_Region_status[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Common_Region_status_Unknown[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Common_Region_status_Feasible[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Common_Region_status_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Region_status:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Common_Region_status_Unknown[_V_tyreg_poly_term,_V_tyreg_poly_ty]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Region_status_Feasible_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Region_status, got invalid constructor {idx}')

# clique Imandrax_api_common.Region.meta
# def Imandrax_api_common.Region.meta (mangled name: "Common_Region_meta")
@dataclass(slots=True, frozen=True)
class Common_Region_meta_Null[_V_tyreg_poly_term]:
    pass

@dataclass(slots=True, frozen=True)
class Common_Region_meta_Bool[_V_tyreg_poly_term]:
    arg: bool

def Common_Region_meta_Bool_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_Bool[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_bool(off=args[0])
    return Common_Region_meta_Bool(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_Int[_V_tyreg_poly_term]:
    arg: int

def Common_Region_meta_Int_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_Int[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_int(off=args[0])
    return Common_Region_meta_Int(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_Real[_V_tyreg_poly_term]:
    arg: tuple[int, int]

def Common_Region_meta_Real_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_Real[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = decode_q(d=d,off=args[0])
    return Common_Region_meta_Real(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_String[_V_tyreg_poly_term]:
    arg: str

def Common_Region_meta_String_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_String[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = d.get_str(off=args[0])
    return Common_Region_meta_String(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_Assoc[_V_tyreg_poly_term]:
    arg: list[tuple[str,Common_Region_meta["_V_tyreg_poly_term"]]]

def Common_Region_meta_Assoc_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_Assoc[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = [(lambda tup: (d.get_str(off=tup[0]),Common_Region_meta_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    return Common_Region_meta_Assoc(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_Term[_V_tyreg_poly_term]:
    arg: "_V_tyreg_poly_term"

def Common_Region_meta_Term_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_Term[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Common_Region_meta_Term(arg=arg)

@dataclass(slots=True, frozen=True)
class Common_Region_meta_List[_V_tyreg_poly_term]:
    arg: list[Common_Region_meta["_V_tyreg_poly_term"]]

def Common_Region_meta_List_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Common_Region_meta_List[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = [Common_Region_meta_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Common_Region_meta_List(arg=arg)

type Common_Region_meta[_V_tyreg_poly_term] = Common_Region_meta_Null[_V_tyreg_poly_term]| Common_Region_meta_Bool[_V_tyreg_poly_term]| Common_Region_meta_Int[_V_tyreg_poly_term]| Common_Region_meta_Real[_V_tyreg_poly_term]| Common_Region_meta_String[_V_tyreg_poly_term]| Common_Region_meta_Assoc[_V_tyreg_poly_term]| Common_Region_meta_Term[_V_tyreg_poly_term]| Common_Region_meta_List[_V_tyreg_poly_term]

def Common_Region_meta_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Common_Region_meta:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Common_Region_meta_Null[_V_tyreg_poly_term]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Common_Region_meta_Bool_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Common_Region_meta_Int_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Common_Region_meta_Real_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Common_Region_meta_String_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Common_Region_meta_Assoc_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Common_Region_meta_Term_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Common_Region_meta_List_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Region_meta, got invalid constructor {idx}')

# clique Imandrax_api_common.Region.t_poly
# def Imandrax_api_common.Region.t_poly (mangled name: "Common_Region_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Region_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    constraints: list["_V_tyreg_poly_term"]
    invariant: "_V_tyreg_poly_term"
    meta: list[tuple[str,Common_Region_meta["_V_tyreg_poly_term"]]]
    status: Common_Region_status["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Common_Region_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Region_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    constraints = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[0])]
    invariant = decode__tyreg_poly_term(d=d,off=fields[1])
    meta = [(lambda tup: (d.get_str(off=tup[0]),Common_Region_meta_of_twine(d=d,off=tup[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    status = Common_Region_status_of_twine(d=d,off=fields[3],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Common_Region_t_poly(constraints=constraints,invariant=invariant,meta=meta,status=status)

# clique Imandrax_api_common.Proof_obligation.t_poly
# def Imandrax_api_common.Proof_obligation.t_poly (mangled name: "Common_Proof_obligation_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Proof_obligation_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    descr: str
    goal: tuple[list[Common_Var_t_poly["_V_tyreg_poly_ty"]],"_V_tyreg_poly_term"]
    tactic: Common_Tactic_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    is_instance: bool
    anchor: Anchor
    timeout: None | int

def Common_Proof_obligation_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Proof_obligation_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    descr = d.get_str(off=fields[0])
    goal = (lambda tup: ([Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=fields[1])))
    tactic = Common_Tactic_t_poly_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    is_instance = d.get_bool(off=fields[3])
    anchor = Anchor_of_twine(d=d, off=fields[4])
    timeout = twine.optional(d=d, off=fields[5], d0=lambda d, off: d.get_int(off=off))
    return Common_Proof_obligation_t_poly(descr=descr,goal=goal,tactic=tactic,is_instance=is_instance,anchor=anchor,timeout=timeout)

# clique Imandrax_api_common.Instantiation_rule_kind.t
# def Imandrax_api_common.Instantiation_rule_kind.t (mangled name: "Common_Instantiation_rule_kind")
@dataclass(slots=True, frozen=True)
class Common_Instantiation_rule_kind_IR_forward_chaining:
    pass

@dataclass(slots=True, frozen=True)
class Common_Instantiation_rule_kind_IR_generalization:
    pass

type Common_Instantiation_rule_kind = Common_Instantiation_rule_kind_IR_forward_chaining| Common_Instantiation_rule_kind_IR_generalization

def Common_Instantiation_rule_kind_of_twine(d: twine.Decoder, off: int) -> Common_Instantiation_rule_kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Common_Instantiation_rule_kind_IR_forward_chaining()
         case twine.Constructor(idx=1, args=args):
             return Common_Instantiation_rule_kind_IR_generalization()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Instantiation_rule_kind, got invalid constructor {idx}')

# clique Imandrax_api_common.Instantiation_rule.t_poly
# def Imandrax_api_common.Instantiation_rule.t_poly (mangled name: "Common_Instantiation_rule_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Instantiation_rule_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    ir_from: Common_Fun_def_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    ir_triggers: list[Common_Trigger_t_poly["_V_tyreg_poly_ty"]]
    ir_kind: Common_Instantiation_rule_kind

def Common_Instantiation_rule_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Instantiation_rule_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    ir_from = Common_Fun_def_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    ir_triggers = [Common_Trigger_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[1])]
    ir_kind = Common_Instantiation_rule_kind_of_twine(d=d, off=fields[2])
    return Common_Instantiation_rule_t_poly(ir_from=ir_from,ir_triggers=ir_triggers,ir_kind=ir_kind)

# clique Imandrax_api_common.Fun_decomp.t_poly
# def Imandrax_api_common.Fun_decomp.t_poly (mangled name: "Common_Fun_decomp_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Fun_decomp_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    f_id: Uid
    f_args: list[Common_Var_t_poly["_V_tyreg_poly_ty"]]
    regions: list[Common_Region_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]

def Common_Fun_decomp_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Fun_decomp_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    f_id = Uid_of_twine(d=d, off=fields[0])
    f_args = [Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[1])]
    regions = [Common_Region_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[2])]
    return Common_Fun_decomp_t_poly(f_id=f_id,f_args=f_args,regions=regions)

# clique Imandrax_api_common.Elimination_rule.t_poly
# def Imandrax_api_common.Elimination_rule.t_poly (mangled name: "Common_Elimination_rule_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Elimination_rule_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    er_name: Uid
    er_guard: list["_V_tyreg_poly_term"]
    er_lhs: "_V_tyreg_poly_term"
    er_rhs: Common_Var_t_poly["_V_tyreg_poly_ty"]
    er_dests: list[Common_Fo_pattern_t_poly["_V_tyreg_poly_ty"]]
    er_dest_tms: list["_V_tyreg_poly_term"]

def Common_Elimination_rule_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Elimination_rule_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    er_name = Uid_of_twine(d=d, off=fields[0])
    er_guard = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[1])]
    er_lhs = decode__tyreg_poly_term(d=d,off=fields[2])
    er_rhs = Common_Var_t_poly_of_twine(d=d,off=fields[3],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    er_dests = [Common_Fo_pattern_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=fields[4])]
    er_dest_tms = [decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=fields[5])]
    return Common_Elimination_rule_t_poly(er_name=er_name,er_guard=er_guard,er_lhs=er_lhs,er_rhs=er_rhs,er_dests=er_dests,er_dest_tms=er_dest_tms)

# clique Imandrax_api_common.Decomp.lift_bool
# def Imandrax_api_common.Decomp.lift_bool (mangled name: "Common_Decomp_lift_bool")
@dataclass(slots=True, frozen=True)
class Common_Decomp_lift_bool_Default:
    pass

@dataclass(slots=True, frozen=True)
class Common_Decomp_lift_bool_Nested_equalities:
    pass

@dataclass(slots=True, frozen=True)
class Common_Decomp_lift_bool_Equalities:
    pass

@dataclass(slots=True, frozen=True)
class Common_Decomp_lift_bool_All:
    pass

type Common_Decomp_lift_bool = Common_Decomp_lift_bool_Default| Common_Decomp_lift_bool_Nested_equalities| Common_Decomp_lift_bool_Equalities| Common_Decomp_lift_bool_All

def Common_Decomp_lift_bool_of_twine(d: twine.Decoder, off: int) -> Common_Decomp_lift_bool:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return Common_Decomp_lift_bool_Default()
         case twine.Constructor(idx=1, args=args):
             return Common_Decomp_lift_bool_Nested_equalities()
         case twine.Constructor(idx=2, args=args):
             return Common_Decomp_lift_bool_Equalities()
         case twine.Constructor(idx=3, args=args):
             return Common_Decomp_lift_bool_All()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Common_Decomp_lift_bool, got invalid constructor {idx}')

# clique Imandrax_api_common.Decomp.t_
# def Imandrax_api_common.Decomp.t_ (mangled name: "Common_Decomp_t_")
@dataclass(slots=True, frozen=True)
class Common_Decomp_t_:
    f_id: Uid
    assuming: None | Uid
    basis: Uid_set
    rule_specs: Uid_set
    ctx_simp: bool
    lift_bool: Common_Decomp_lift_bool
    prune: bool

def Common_Decomp_t__of_twine(d: twine.Decoder, off: int) -> Common_Decomp_t_:
    fields = list(d.get_array(off=off))
    f_id = Uid_of_twine(d=d, off=fields[0])
    assuming = twine.optional(d=d, off=fields[1], d0=lambda d, off: Uid_of_twine(d=d, off=off))
    basis = Uid_set_of_twine(d=d, off=fields[2])
    rule_specs = Uid_set_of_twine(d=d, off=fields[3])
    ctx_simp = d.get_bool(off=fields[4])
    lift_bool = Common_Decomp_lift_bool_of_twine(d=d, off=fields[5])
    prune = d.get_bool(off=fields[6])
    return Common_Decomp_t_(f_id=f_id,assuming=assuming,basis=basis,rule_specs=rule_specs,ctx_simp=ctx_simp,lift_bool=lift_bool,prune=prune)

# clique Imandrax_api_common.Db_ser.uid_map
# def Imandrax_api_common.Db_ser.uid_map (mangled name: "Common_Db_ser_uid_map")
type Common_Db_ser_uid_map[_V_tyreg_poly_a] = list[tuple[Uid,"_V_tyreg_poly_a"]]

def Common_Db_ser_uid_map_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Common_Db_ser_uid_map:
    decode__tyreg_poly_a = d0
    return [(lambda tup: (Uid_of_twine(d=d, off=tup[0]),decode__tyreg_poly_a(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=off)]

# clique Imandrax_api_common.Db_ser.ph_map
# def Imandrax_api_common.Db_ser.ph_map (mangled name: "Common_Db_ser_ph_map")
type Common_Db_ser_ph_map[_V_tyreg_poly_ty,_V_tyreg_poly_a] = list[tuple[Common_Pattern_head_t_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_a"]]

def Common_Db_ser_ph_map_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_ty],d1: Callable[...,_V_tyreg_poly_a],off: int) -> Common_Db_ser_ph_map:
    decode__tyreg_poly_ty = d0
    decode__tyreg_poly_a = d1
    return [(lambda tup: (Common_Pattern_head_t_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),decode__tyreg_poly_a(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=off)]

# clique Imandrax_api_common.Db_ser.ca_ptr
# def Imandrax_api_common.Db_ser.ca_ptr (mangled name: "Common_Db_ser_ca_ptr")
type Common_Db_ser_ca_ptr[_V_tyreg_poly_a] = Ca_store_Ca_ptr["_V_tyreg_poly_a"]

def Common_Db_ser_ca_ptr_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],off: int) -> Common_Db_ser_ca_ptr:
    decode__tyreg_poly_a = d0
    return Ca_store_Ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_a(d=d,off=off)))

# clique Imandrax_api_common.Db_ser.t_poly
# def Imandrax_api_common.Db_ser.t_poly (mangled name: "Common_Db_ser_t_poly")
@dataclass(slots=True, frozen=True)
class Common_Db_ser_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decls: Uid_set
    rw_rules: Common_Db_ser_ph_map["_V_tyreg_poly_ty",list[Common_Db_ser_ca_ptr[Common_Rewrite_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    inst_rules: Common_Db_ser_uid_map[Common_Db_ser_ca_ptr[Common_Instantiation_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]
    rule_spec_fc: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Trigger_t_poly["_V_tyreg_poly_ty"]]]]
    rule_spec_rw_rules: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Rewrite_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    fc: Common_Db_ser_ph_map["_V_tyreg_poly_ty",list[Common_Db_ser_ca_ptr[Common_Trigger_t_poly["_V_tyreg_poly_ty"]]]]
    elim: Common_Db_ser_ph_map["_V_tyreg_poly_ty",list[Common_Db_ser_ca_ptr[Common_Elimination_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    gen: Common_Db_ser_ph_map["_V_tyreg_poly_ty",list[Common_Db_ser_ca_ptr[Common_Trigger_t_poly["_V_tyreg_poly_ty"]]]]
    thm_as_rw: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Rewrite_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    thm_as_fc: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Instantiation_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    thm_as_elim: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Elimination_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    thm_as_gen: Common_Db_ser_uid_map[list[Common_Db_ser_ca_ptr[Common_Instantiation_rule_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]]]
    admission: Common_Db_ser_uid_map[Common_Db_ser_ca_ptr[Common_Admission]]
    count_funs_of_ty: Common_Db_ser_uid_map[Uid]
    disabled: Uid_set

def Common_Db_ser_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Common_Db_ser_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    decls = Uid_set_of_twine(d=d, off=fields[0])
    rw_rules = Common_Db_ser_ph_map_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d1=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Rewrite_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    inst_rules = Common_Db_ser_uid_map_of_twine(d=d,off=fields[2],d0=(lambda d, off: Common_Db_ser_ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: Common_Instantiation_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))))
    rule_spec_fc = Common_Db_ser_uid_map_of_twine(d=d,off=fields[3],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Trigger_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    rule_spec_rw_rules = Common_Db_ser_uid_map_of_twine(d=d,off=fields[4],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Rewrite_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    fc = Common_Db_ser_ph_map_of_twine(d=d,off=fields[5],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d1=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Trigger_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    elim = Common_Db_ser_ph_map_of_twine(d=d,off=fields[6],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d1=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Elimination_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    gen = Common_Db_ser_ph_map_of_twine(d=d,off=fields[7],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d1=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Trigger_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    thm_as_rw = Common_Db_ser_uid_map_of_twine(d=d,off=fields[8],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Rewrite_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    thm_as_fc = Common_Db_ser_uid_map_of_twine(d=d,off=fields[9],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Instantiation_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    thm_as_elim = Common_Db_ser_uid_map_of_twine(d=d,off=fields[10],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Elimination_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    thm_as_gen = Common_Db_ser_uid_map_of_twine(d=d,off=fields[11],d0=(lambda d, off: [Common_Db_ser_ca_ptr_of_twine(d=d,off=x,d0=(lambda d, off: Common_Instantiation_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))) for x in d.get_array(off=off)]))
    admission = Common_Db_ser_uid_map_of_twine(d=d,off=fields[12],d0=(lambda d, off: Common_Db_ser_ca_ptr_of_twine(d=d,off=off,d0=(lambda d, off: Common_Admission_of_twine(d=d, off=off)))))
    count_funs_of_ty = Common_Db_ser_uid_map_of_twine(d=d,off=fields[13],d0=(lambda d, off: Uid_of_twine(d=d, off=off)))
    disabled = Uid_set_of_twine(d=d, off=fields[14])
    return Common_Db_ser_t_poly(decls=decls,rw_rules=rw_rules,inst_rules=inst_rules,rule_spec_fc=rule_spec_fc,rule_spec_rw_rules=rule_spec_rw_rules,fc=fc,elim=elim,gen=gen,thm_as_rw=thm_as_rw,thm_as_fc=thm_as_fc,thm_as_elim=thm_as_elim,thm_as_gen=thm_as_gen,admission=admission,count_funs_of_ty=count_funs_of_ty,disabled=disabled)

# clique Imandrax_api_mir.Type.var
# def Imandrax_api_mir.Type.var (mangled name: "Mir_Type_var")
type Mir_Type_var = Uid

def Mir_Type_var_of_twine(d: twine.Decoder, off: int) -> Mir_Type_var:
    return Uid_of_twine(d=d, off=off)

# clique Imandrax_api_mir.Type.clique
# def Imandrax_api_mir.Type.clique (mangled name: "Mir_Type_clique")
type Mir_Type_clique = Uid_set

def Mir_Type_clique_of_twine(d: twine.Decoder, off: int) -> Mir_Type_clique:
    return Uid_set_of_twine(d=d, off=off)

# clique Imandrax_api_mir.Type.generation
# def Imandrax_api_mir.Type.generation (mangled name: "Mir_Type_generation")
type Mir_Type_generation = int

def Mir_Type_generation_of_twine(d: twine.Decoder, off: int) -> Mir_Type_generation:
    return d.get_int(off=off)

# clique Imandrax_api_mir.Type.t
# def Imandrax_api_mir.Type.t (mangled name: "Mir_Type")
@dataclass(slots=True, frozen=True)
class Mir_Type:
    view: Ty_view_view[None,Mir_Type_var,Mir_Type]

def Mir_Type_of_twine(d: twine.Decoder, off: int) -> Mir_Type:
    x = Ty_view_view_of_twine(d=d,off=off,d0=(lambda d, off: d.get_null(off=off)),d1=(lambda d, off: Mir_Type_var_of_twine(d=d, off=off)),d2=(lambda d, off: Mir_Type_of_twine(d=d, off=off))) # single unboxed field
    return Mir_Type(view=x)

# clique Imandrax_api_mir.Type.ser
# def Imandrax_api_mir.Type.ser (mangled name: "Mir_Type_ser")
@dataclass(slots=True, frozen=True)
class Mir_Type_ser:
    view: Ty_view_view[None,Mir_Type_var,Mir_Type]

def Mir_Type_ser_of_twine(d: twine.Decoder, off: int) -> Mir_Type_ser:
    x = Ty_view_view_of_twine(d=d,off=off,d0=(lambda d, off: d.get_null(off=off)),d1=(lambda d, off: Mir_Type_var_of_twine(d=d, off=off)),d2=(lambda d, off: Mir_Type_of_twine(d=d, off=off))) # single unboxed field
    return Mir_Type_ser(view=x)

# clique Imandrax_api_mir.Type.def
# def Imandrax_api_mir.Type.def (mangled name: "Mir_Type_def")
type Mir_Type_def = Ty_view_def_poly[Mir_Type]

def Mir_Type_def_of_twine(d: twine.Decoder, off: int) -> Mir_Type_def:
    return Ty_view_def_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Var.t
# def Imandrax_api_mir.Var.t (mangled name: "Mir_Var")
type Mir_Var = Common_Var_t_poly[Mir_Type]

def Mir_Var_of_twine(d: twine.Decoder, off: int) -> Mir_Var:
    return Common_Var_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Typed_symbol.t
# def Imandrax_api_mir.Typed_symbol.t (mangled name: "Mir_Typed_symbol")
type Mir_Typed_symbol = Common_Typed_symbol_t_poly[Mir_Type]

def Mir_Typed_symbol_of_twine(d: twine.Decoder, off: int) -> Mir_Typed_symbol:
    return Common_Typed_symbol_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Type_schema.t
# def Imandrax_api_mir.Type_schema.t (mangled name: "Mir_Type_schema")
type Mir_Type_schema = Common_Type_schema_t_poly[Mir_Type]

def Mir_Type_schema_of_twine(d: twine.Decoder, off: int) -> Mir_Type_schema:
    return Common_Type_schema_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Trigger.t
# def Imandrax_api_mir.Trigger.t (mangled name: "Mir_Trigger")
type Mir_Trigger = Common_Trigger_t_poly[Mir_Type]

def Mir_Trigger_of_twine(d: twine.Decoder, off: int) -> Mir_Trigger:
    return Common_Trigger_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Applied_symbol.t
# def Imandrax_api_mir.Applied_symbol.t (mangled name: "Mir_Applied_symbol")
type Mir_Applied_symbol = Common_Applied_symbol_t_poly[Mir_Type]

def Mir_Applied_symbol_of_twine(d: twine.Decoder, off: int) -> Mir_Applied_symbol:
    return Common_Applied_symbol_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Term.view
# def Imandrax_api_mir.Term.view (mangled name: "Mir_Term_view")
@dataclass(slots=True, frozen=True)
class Mir_Term_view_Const[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: Const

def Mir_Term_view_Const_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Const[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = Const_of_twine(d=d, off=args[0])
    return Mir_Term_view_Const(arg=arg)

@dataclass(slots=True, frozen=True)
class Mir_Term_view_If[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    args: tuple["_V_tyreg_poly_t","_V_tyreg_poly_t","_V_tyreg_poly_t"]

def Mir_Term_view_If_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_If[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    cargs = (decode__tyreg_poly_t(d=d,off=args[0]),decode__tyreg_poly_t(d=d,off=args[1]),decode__tyreg_poly_t(d=d,off=args[2]))
    return Mir_Term_view_If(args=cargs)

@dataclass(slots=True, frozen=True)
class Mir_Term_view_Apply[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    f: "_V_tyreg_poly_t"
    l: list["_V_tyreg_poly_t"]


def Mir_Term_view_Apply_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Apply[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    f = decode__tyreg_poly_t(d=d,off=args[0])
    l = [decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])]
    return Mir_Term_view_Apply(f=f,l=l)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Var[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: Common_Var_t_poly["_V_tyreg_poly_ty"]

def Mir_Term_view_Var_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Var[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = Common_Var_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Mir_Term_view_Var(arg=arg)

@dataclass(slots=True, frozen=True)
class Mir_Term_view_Sym[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    arg: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]

def Mir_Term_view_Sym_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Sym[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    arg = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Mir_Term_view_Sym(arg=arg)

@dataclass(slots=True, frozen=True)
class Mir_Term_view_Construct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    c: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    args: list["_V_tyreg_poly_t"]


def Mir_Term_view_Construct_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Construct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    c = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    args = [decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[1])]
    return Mir_Term_view_Construct(c=c,args=args)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    c: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    i: int
    t: "_V_tyreg_poly_t"


def Mir_Term_view_Destruct_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    c = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    i = d.get_int(off=args[1])
    t = decode__tyreg_poly_t(d=d,off=args[2])
    return Mir_Term_view_Destruct(c=c,i=i,t=t)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    c: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    t: "_V_tyreg_poly_t"


def Mir_Term_view_Is_a_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    c = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    t = decode__tyreg_poly_t(d=d,off=args[1])
    return Mir_Term_view_Is_a(c=c,t=t)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Tuple[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    l: list["_V_tyreg_poly_t"]


def Mir_Term_view_Tuple_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Tuple[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    l = [decode__tyreg_poly_t(d=d,off=x) for x in d.get_array(off=args[0])]
    return Mir_Term_view_Tuple(l=l)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Field[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    f: Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"]
    t: "_V_tyreg_poly_t"


def Mir_Term_view_Field_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Field[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    f = Common_Applied_symbol_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    t = decode__tyreg_poly_t(d=d,off=args[1])
    return Mir_Term_view_Field(f=f,t=t)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Tuple_field[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    i: int
    t: "_V_tyreg_poly_t"


def Mir_Term_view_Tuple_field_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Tuple_field[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    i = d.get_int(off=args[0])
    t = decode__tyreg_poly_t(d=d,off=args[1])
    return Mir_Term_view_Tuple_field(i=i,t=t)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Record[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    rows: list[tuple[Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_t"]]
    rest: None | "_V_tyreg_poly_t"


def Mir_Term_view_Record_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Record[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    rows = [(lambda tup: (Common_Applied_symbol_t_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),decode__tyreg_poly_t(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[0])]
    rest = twine.optional(d=d, off=args[1], d0=lambda d, off: decode__tyreg_poly_t(d=d,off=off))
    return Mir_Term_view_Record(rows=rows,rest=rest)


@dataclass(slots=True, frozen=True)
class Mir_Term_view_Case[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    u: "_V_tyreg_poly_t"
    cases: list[tuple[Common_Applied_symbol_t_poly["_V_tyreg_poly_ty"],"_V_tyreg_poly_t"]]
    default: None | "_V_tyreg_poly_t"


def Mir_Term_view_Case_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Mir_Term_view_Case[_V_tyreg_poly_t,_V_tyreg_poly_ty]:
    decode__tyreg_poly_t = d0
    decode__tyreg_poly_ty = d1
    u = decode__tyreg_poly_t(d=d,off=args[0])
    cases = [(lambda tup: (Common_Applied_symbol_t_poly_of_twine(d=d,off=tup[0],d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))),decode__tyreg_poly_t(d=d,off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=args[1])]
    default = twine.optional(d=d, off=args[2], d0=lambda d, off: decode__tyreg_poly_t(d=d,off=off))
    return Mir_Term_view_Case(u=u,cases=cases,default=default)


type Mir_Term_view[_V_tyreg_poly_t,_V_tyreg_poly_ty] = Mir_Term_view_Const[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_If[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Apply[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Var[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Sym[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Construct[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Destruct[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Is_a[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Tuple[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Field[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Tuple_field[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Record[_V_tyreg_poly_t,_V_tyreg_poly_ty]| Mir_Term_view_Case[_V_tyreg_poly_t,_V_tyreg_poly_ty]

def Mir_Term_view_of_twine[_V_tyreg_poly_t,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_t],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Mir_Term_view:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Mir_Term_view_Const_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Mir_Term_view_If_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Mir_Term_view_Apply_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Mir_Term_view_Var_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Mir_Term_view_Sym_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return Mir_Term_view_Construct_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return Mir_Term_view_Destruct_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return Mir_Term_view_Is_a_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return Mir_Term_view_Tuple_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return Mir_Term_view_Field_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return Mir_Term_view_Tuple_field_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return Mir_Term_view_Record_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return Mir_Term_view_Case_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Mir_Term_view, got invalid constructor {idx}')

# clique Imandrax_api_mir.Term.generation
# def Imandrax_api_mir.Term.generation (mangled name: "Mir_Term_generation")
type Mir_Term_generation = int

def Mir_Term_generation_of_twine(d: twine.Decoder, off: int) -> Mir_Term_generation:
    return d.get_int(off=off)

# clique Imandrax_api_mir.Term.t
# def Imandrax_api_mir.Term.t (mangled name: "Mir_Term")
@dataclass(slots=True, frozen=True)
class Mir_Term:
    view: Mir_Term_view[Mir_Term,Mir_Type]
    ty: Mir_Type

def Mir_Term_of_twine(d: twine.Decoder, off: int) -> Mir_Term:
    fields = list(d.get_array(off=off))
    view = Mir_Term_view_of_twine(d=d,off=fields[0],d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))
    ty = Mir_Type_of_twine(d=d, off=fields[1])
    return Mir_Term(view=view,ty=ty)

# clique Imandrax_api_mir.Term.ser
# def Imandrax_api_mir.Term.ser (mangled name: "Mir_Term_ser")
@dataclass(slots=True, frozen=True)
class Mir_Term_ser:
    view: Mir_Term_view[Mir_Term,Mir_Type]
    ty: Mir_Type

def Mir_Term_ser_of_twine(d: twine.Decoder, off: int) -> Mir_Term_ser:
    fields = list(d.get_array(off=off))
    view = Mir_Term_view_of_twine(d=d,off=fields[0],d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))
    ty = Mir_Type_of_twine(d=d, off=fields[1])
    return Mir_Term_ser(view=view,ty=ty)

# clique Imandrax_api_mir.Term.term
# def Imandrax_api_mir.Term.term (mangled name: "Mir_Term_term")
type Mir_Term_term = Mir_Term

def Mir_Term_term_of_twine(d: twine.Decoder, off: int) -> Mir_Term_term:
    return Mir_Term_of_twine(d=d, off=off)

# clique Imandrax_api_mir.Top_fun.t
# def Imandrax_api_mir.Top_fun.t (mangled name: "Mir_Top_fun")
type Mir_Top_fun = tuple[list[Mir_Var],Mir_Term]

def Mir_Top_fun_of_twine(d: twine.Decoder, off: int) -> Mir_Top_fun:
    return (lambda tup: ([Mir_Var_of_twine(d=d, off=x) for x in d.get_array(off=tup[0])],Mir_Term_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_mir.Theorem.t
# def Imandrax_api_mir.Theorem.t (mangled name: "Mir_Theorem")
type Mir_Theorem = Common_Theorem_t_poly[Mir_Term,Mir_Type]

def Mir_Theorem_of_twine(d: twine.Decoder, off: int) -> Mir_Theorem:
    return Common_Theorem_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Tactic.t
# def Imandrax_api_mir.Tactic.t (mangled name: "Mir_Tactic")
type Mir_Tactic = Common_Tactic_t_poly[Mir_Term,Mir_Type]

def Mir_Tactic_of_twine(d: twine.Decoder, off: int) -> Mir_Tactic:
    return Common_Tactic_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Sequent.t
# def Imandrax_api_mir.Sequent.t (mangled name: "Mir_Sequent")
type Mir_Sequent = Common_Sequent_t_poly[Mir_Term]

def Mir_Sequent_of_twine(d: twine.Decoder, off: int) -> Mir_Sequent:
    return Common_Sequent_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Rewrite_rule.t
# def Imandrax_api_mir.Rewrite_rule.t (mangled name: "Mir_Rewrite_rule")
type Mir_Rewrite_rule = Common_Rewrite_rule_t_poly[Mir_Term,Mir_Type]

def Mir_Rewrite_rule_of_twine(d: twine.Decoder, off: int) -> Mir_Rewrite_rule:
    return Common_Rewrite_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Region.Region.t
# def Imandrax_api_mir.Region.Region.t (mangled name: "Mir_Region_Region")
type Mir_Region_Region = Common_Region_t_poly[Mir_Term,Mir_Type]

def Mir_Region_Region_of_twine(d: twine.Decoder, off: int) -> Mir_Region_Region:
    return Common_Region_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Proof_obligation.t
# def Imandrax_api_mir.Proof_obligation.t (mangled name: "Mir_Proof_obligation")
type Mir_Proof_obligation = Common_Proof_obligation_t_poly[Mir_Term,Mir_Type]

def Mir_Proof_obligation_of_twine(d: twine.Decoder, off: int) -> Mir_Proof_obligation:
    return Common_Proof_obligation_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Pre_trigger.t
# def Imandrax_api_mir.Pre_trigger.t (mangled name: "Mir_Pre_trigger")
type Mir_Pre_trigger = tuple[Mir_Term,As_trigger]

def Mir_Pre_trigger_of_twine(d: twine.Decoder, off: int) -> Mir_Pre_trigger:
    return (lambda tup: (Mir_Term_of_twine(d=d, off=tup[0]),As_trigger_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

# clique Imandrax_api_mir.Pattern_head.t
# def Imandrax_api_mir.Pattern_head.t (mangled name: "Mir_Pattern_head")
type Mir_Pattern_head = Common_Pattern_head_t_poly[Mir_Type]

def Mir_Pattern_head_of_twine(d: twine.Decoder, off: int) -> Mir_Pattern_head:
    return Common_Pattern_head_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Model.t
# def Imandrax_api_mir.Model.t (mangled name: "Mir_Model")
type Mir_Model = Common_Model_t_poly[Mir_Term,Mir_Type]

def Mir_Model_of_twine(d: twine.Decoder, off: int) -> Mir_Model:
    return Common_Model_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Instantiation_rule.t
# def Imandrax_api_mir.Instantiation_rule.t (mangled name: "Mir_Instantiation_rule")
type Mir_Instantiation_rule = Common_Instantiation_rule_t_poly[Mir_Term,Mir_Type]

def Mir_Instantiation_rule_of_twine(d: twine.Decoder, off: int) -> Mir_Instantiation_rule:
    return Common_Instantiation_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Hints.t
# def Imandrax_api_mir.Hints.t (mangled name: "Mir_Hints")
type Mir_Hints = Common_Hints_t_poly[Mir_Term,Mir_Type]

def Mir_Hints_of_twine(d: twine.Decoder, off: int) -> Mir_Hints:
    return Common_Hints_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Fun_def.t
# def Imandrax_api_mir.Fun_def.t (mangled name: "Mir_Fun_def")
type Mir_Fun_def = Common_Fun_def_t_poly[Mir_Term,Mir_Type]

def Mir_Fun_def_of_twine(d: twine.Decoder, off: int) -> Mir_Fun_def:
    return Common_Fun_def_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Fun_decomp.t
# def Imandrax_api_mir.Fun_decomp.t (mangled name: "Mir_Fun_decomp")
type Mir_Fun_decomp = Common_Fun_decomp_t_poly[Mir_Term,Mir_Type]

def Mir_Fun_decomp_of_twine(d: twine.Decoder, off: int) -> Mir_Fun_decomp:
    return Common_Fun_decomp_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Fo_pattern.t
# def Imandrax_api_mir.Fo_pattern.t (mangled name: "Mir_Fo_pattern")
type Mir_Fo_pattern = Common_Fo_pattern_t_poly[Mir_Type]

def Mir_Fo_pattern_of_twine(d: twine.Decoder, off: int) -> Mir_Fo_pattern:
    return Common_Fo_pattern_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Elimination_rule.t
# def Imandrax_api_mir.Elimination_rule.t (mangled name: "Mir_Elimination_rule")
type Mir_Elimination_rule = Common_Elimination_rule_t_poly[Mir_Term,Mir_Type]

def Mir_Elimination_rule_of_twine(d: twine.Decoder, off: int) -> Mir_Elimination_rule:
    return Common_Elimination_rule_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_mir.Decomp.t
# def Imandrax_api_mir.Decomp.t (mangled name: "Mir_Decomp")
@dataclass(slots=True, frozen=True)
class Mir_Decomp:
    f_id: Uid
    assuming: None | Uid
    basis: Uid_set
    rule_specs: Uid_set
    ctx_simp: bool
    lift_bool: Common_Decomp_lift_bool
    prune: bool

def Mir_Decomp_of_twine(d: twine.Decoder, off: int) -> Mir_Decomp:
    fields = list(d.get_array(off=off))
    f_id = Uid_of_twine(d=d, off=fields[0])
    assuming = twine.optional(d=d, off=fields[1], d0=lambda d, off: Uid_of_twine(d=d, off=off))
    basis = Uid_set_of_twine(d=d, off=fields[2])
    rule_specs = Uid_set_of_twine(d=d, off=fields[3])
    ctx_simp = d.get_bool(off=fields[4])
    lift_bool = Common_Decomp_lift_bool_of_twine(d=d, off=fields[5])
    prune = d.get_bool(off=fields[6])
    return Mir_Decomp(f_id=f_id,assuming=assuming,basis=basis,rule_specs=rule_specs,ctx_simp=ctx_simp,lift_bool=lift_bool,prune=prune)

# clique Imandrax_api_mir.Db_ser.t
# def Imandrax_api_mir.Db_ser.t (mangled name: "Mir_Db_ser")
type Mir_Db_ser = Common_Db_ser_t_poly[Mir_Term,Mir_Type]

def Mir_Db_ser_of_twine(d: twine.Decoder, off: int) -> Mir_Db_ser:
    return Common_Db_ser_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

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
    arg: Mir_Top_fun

def Eval_Value_view_V_quoted_term_of_twine[_V_tyreg_poly_v,_V_tyreg_poly_closure](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_v],d1: Callable[...,_V_tyreg_poly_closure],args: tuple[int, ...]) -> Eval_Value_view_V_quoted_term[_V_tyreg_poly_v,_V_tyreg_poly_closure]:
    decode__tyreg_poly_v = d0
    decode__tyreg_poly_closure = d1
    arg = Mir_Top_fun_of_twine(d=d, off=args[0])
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

# clique Imandrax_api_eval.Value.erased_closure
# def Imandrax_api_eval.Value.erased_closure (mangled name: "Eval_Value_erased_closure")
@dataclass(slots=True, frozen=True)
class Eval_Value_erased_closure:
    missing: int

def Eval_Value_erased_closure_of_twine(d: twine.Decoder, off: int) -> Eval_Value_erased_closure:
    x = d.get_int(off=off) # single unboxed field
    return Eval_Value_erased_closure(missing=x)

# clique Imandrax_api_eval.Value.t
# def Imandrax_api_eval.Value.t (mangled name: "Eval_Value")
@dataclass(slots=True, frozen=True)
class Eval_Value:
    v: Eval_Value_view[Eval_Value,Eval_Value_erased_closure]

def Eval_Value_of_twine(d: twine.Decoder, off: int) -> Eval_Value:
    x = Eval_Value_view_of_twine(d=d,off=off,d0=(lambda d, off: Eval_Value_of_twine(d=d, off=off)),d1=(lambda d, off: Eval_Value_erased_closure_of_twine(d=d, off=off))) # single unboxed field
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
    arg: Common_Sequent_t_poly["_V_tyreg_poly_term"]

def Report_Rtext_item_Sequent_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Report_Rtext_item_Sequent[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = Common_Sequent_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
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

# clique Imandrax_api_report.Atomic_event.model
# def Imandrax_api_report.Atomic_event.model (mangled name: "Report_Atomic_event_model")
type Report_Atomic_event_model[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Report_Atomic_event_model_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Report_Atomic_event_model:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    return Common_Model_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))

# clique Imandrax_api_report.Atomic_event.poly
# def Imandrax_api_report.Atomic_event.poly (mangled name: "Report_Atomic_event_poly")
@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    arg: Report_Rtext["_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_message_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    arg = Report_Rtext_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    return Report_Atomic_event_poly_E_message(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    arg: str

def Report_Atomic_event_poly_E_title_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    arg = d.get_str(off=args[0])
    return Report_Atomic_event_poly_E_title(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    vars: list[Common_Var_t_poly["_V_tyreg_poly_ty"]]
    goal: "_V_tyreg_poly_term"


def Report_Atomic_event_poly_E_enter_waterfall_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    vars = [Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=args[0])]
    goal = decode__tyreg_poly_term(d=d,off=args[1])
    return Report_Atomic_event_poly_E_enter_waterfall(vars=vars,goal=goal)


@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    arg: str

def Report_Atomic_event_poly_E_enter_tactic_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    arg = d.get_str(off=args[0])
    return Report_Atomic_event_poly_E_enter_tactic(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple[Common_Rewrite_rule_t_poly["_V_tyreg_poly_term2","_V_tyreg_poly_ty2"],"_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_rw_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (Common_Rewrite_rule_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term2(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty2(d=d,off=off))),decode__tyreg_poly_term(d=d,off=args[1]),decode__tyreg_poly_term(d=d,off=args[2]))
    return Report_Atomic_event_poly_E_rw_success(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple[Common_Rewrite_rule_t_poly["_V_tyreg_poly_term2","_V_tyreg_poly_ty2"],"_V_tyreg_poly_term",str]

def Report_Atomic_event_poly_E_rw_fail_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (Common_Rewrite_rule_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term2(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty2(d=d,off=off))),decode__tyreg_poly_term(d=d,off=args[1]),d.get_str(off=args[2]))
    return Report_Atomic_event_poly_E_rw_fail(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple[Common_Instantiation_rule_t_poly["_V_tyreg_poly_term2","_V_tyreg_poly_ty2"],"_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_inst_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (Common_Instantiation_rule_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term2(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty2(d=d,off=off))),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_inst_success(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    arg: list[Common_Sequent_t_poly["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    arg = [Common_Sequent_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))) for x in d.get_array(off=args[0])]
    return Report_Atomic_event_poly_E_waterfall_checkpoint(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    arg: "_V_tyreg_poly_term"

def Report_Atomic_event_poly_E_induction_scheme_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Report_Atomic_event_poly_E_induction_scheme(arg=arg)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    name: str
    goal: Common_Sequent_t_poly["_V_tyreg_poly_term"]
    depth: int


def Report_Atomic_event_poly_E_attack_subgoal_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    name = d.get_str(off=args[0])
    goal = Common_Sequent_t_poly_of_twine(d=d,off=args[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    depth = d.get_int(off=args[2])
    return Report_Atomic_event_poly_E_attack_subgoal(name=name,goal=goal,depth=depth)


@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple["_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_simplify_t_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_simplify_t(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple["_V_tyreg_poly_term",list["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_simplify_clause_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),[decode__tyreg_poly_term(d=d,off=x) for x in d.get_array(off=args[1])])
    return Report_Atomic_event_poly_E_simplify_clause(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple["_V_tyreg_poly_term",Report_Smt_proof["_V_tyreg_poly_term"]]

def Report_Atomic_event_poly_E_proved_by_smt_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),Report_Smt_proof_of_twine(d=d,off=args[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off))))
    return Report_Atomic_event_poly_E_proved_by_smt(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple["_V_tyreg_poly_term",None | Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]

def Report_Atomic_event_poly_E_refuted_by_smt_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),twine.optional(d=d, off=args[1], d0=lambda d, off: Common_Model_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    return Report_Atomic_event_poly_E_refuted_by_smt(args=cargs)

@dataclass(slots=True, frozen=True)
class Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    args: tuple["_V_tyreg_poly_term","_V_tyreg_poly_term"]

def Report_Atomic_event_poly_E_fun_expansion_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],args: tuple[int, ...]) -> Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    decode__tyreg_poly_term2 = d2
    decode__tyreg_poly_ty2 = d3
    cargs = (decode__tyreg_poly_term(d=d,off=args[0]),decode__tyreg_poly_term(d=d,off=args[1]))
    return Report_Atomic_event_poly_E_fun_expansion(args=cargs)

type Report_Atomic_event_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2] = Report_Atomic_event_poly_E_message[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_title[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_enter_waterfall[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_enter_tactic[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_rw_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_rw_fail[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_inst_success[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_waterfall_checkpoint[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_induction_scheme[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_attack_subgoal[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_simplify_t[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_simplify_clause[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_proved_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_refuted_by_smt[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]| Report_Atomic_event_poly_E_fun_expansion[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2]

def Report_Atomic_event_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty,_V_tyreg_poly_term2,_V_tyreg_poly_ty2](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],d2: Callable[...,_V_tyreg_poly_term2],d3: Callable[...,_V_tyreg_poly_ty2],off: int) -> Report_Atomic_event_poly:
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

# clique Imandrax_api_report.Atomic_event.Mir.t
# def Imandrax_api_report.Atomic_event.Mir.t (mangled name: "Report_Atomic_event_Mir")
type Report_Atomic_event_Mir = Report_Atomic_event_poly[Mir_Term,Mir_Type,Mir_Term,Mir_Type]

def Report_Atomic_event_Mir_of_twine(d: twine.Decoder, off: int) -> Report_Atomic_event_Mir:
    return Report_Atomic_event_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)),d2=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d3=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

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
type Report_Report_event = Report_Event_t_linear[Report_Atomic_event_Mir]

def Report_Report_event_of_twine(d: twine.Decoder, off: int) -> Report_Report_event:
    return Report_Event_t_linear_of_twine(d=d,off=off,d0=(lambda d, off: Report_Atomic_event_Mir_of_twine(d=d, off=off)))

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
    arg: Common_Sequent_t_poly["_V_tyreg_poly_term"]

def Proof_Arg_A_seq_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Proof_Arg_A_seq[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Common_Sequent_t_poly_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
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

# clique Imandrax_api_proof.Proof_term.t_poly
# def Imandrax_api_proof.Proof_term.t_poly (mangled name: "Proof_Proof_term_t_poly")
@dataclass(slots=True, frozen=True)
class Proof_Proof_term_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    id: int
    concl: Common_Sequent_t_poly["_V_tyreg_poly_term"]
    view: Proof_View["_V_tyreg_poly_term","_V_tyreg_poly_ty",Proof_Proof_term_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]

def Proof_Proof_term_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Proof_Proof_term_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    id = d.get_int(off=fields[0])
    concl = Common_Sequent_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    view = Proof_View_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)),d2=(lambda d, off: Proof_Proof_term_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    return Proof_Proof_term_t_poly(id=id,concl=concl,view=view)

# clique Imandrax_api_tasks.PO_task.t_poly
# def Imandrax_api_tasks.PO_task.t_poly (mangled name: "Tasks_PO_task_t_poly")
@dataclass(slots=True, frozen=True)
class Tasks_PO_task_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    from_sym: str
    count: int
    db: Common_Db_ser_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    po: Common_Proof_obligation_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_task_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_task_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    from_sym = d.get_str(off=fields[0])
    count = d.get_int(off=fields[1])
    db = Common_Db_ser_t_poly_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    po = Common_Proof_obligation_t_poly_of_twine(d=d,off=fields[3],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_task_t_poly(from_sym=from_sym,count=count,db=db,po=po)

# clique Imandrax_api_tasks.PO_task.Imandrax_api_mir.t
# def Imandrax_api_tasks.PO_task.Imandrax_api_mir.t (mangled name: "Tasks_PO_task_Imandrax_api_mir")
type Tasks_PO_task_Imandrax_api_mir = Tasks_PO_task_t_poly[Mir_Term,Mir_Type]

def Tasks_PO_task_Imandrax_api_mir_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_task_Imandrax_api_mir:
    return Tasks_PO_task_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.PO_res.stats
# def Imandrax_api_tasks.PO_res.stats (mangled name: "Tasks_PO_res_stats")
type Tasks_PO_res_stats = Stat_time

def Tasks_PO_res_stats_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_stats:
    return Stat_time_of_twine(d=d, off=off)

# clique Imandrax_api_tasks.PO_res.proof_found
# def Imandrax_api_tasks.PO_res.proof_found (mangled name: "Tasks_PO_res_proof_found")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_proof_found[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    anchor: Anchor
    proof: Proof_Proof_term_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_proof_found_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_proof_found:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    proof = Proof_Proof_term_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_proof_found(anchor=anchor,proof=proof)

# clique Imandrax_api_tasks.PO_res.instance
# def Imandrax_api_tasks.PO_res.instance (mangled name: "Tasks_PO_res_instance")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_instance[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    anchor: Anchor
    model: Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_instance_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_instance:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    model = Common_Model_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_instance(anchor=anchor,model=model)

# clique Imandrax_api_tasks.PO_res.no_proof
# def Imandrax_api_tasks.PO_res.no_proof (mangled name: "Tasks_PO_res_no_proof")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_no_proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    err: Error_Error_core
    counter_model: None | Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    subgoals: list[Mir_Sequent]

def Tasks_PO_res_no_proof_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_no_proof:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    err = Error_Error_core_of_twine(d=d, off=fields[0])
    counter_model = twine.optional(d=d, off=fields[1], d0=lambda d, off: Common_Model_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))
    subgoals = [Mir_Sequent_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    return Tasks_PO_res_no_proof(err=err,counter_model=counter_model,subgoals=subgoals)

# clique Imandrax_api_tasks.PO_res.unsat
# def Imandrax_api_tasks.PO_res.unsat (mangled name: "Tasks_PO_res_unsat")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_unsat[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    anchor: Anchor
    err: Error_Error_core
    proof: Proof_Proof_term_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_unsat_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_unsat:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    err = Error_Error_core_of_twine(d=d, off=fields[1])
    proof = Proof_Proof_term_t_poly_of_twine(d=d,off=fields[2],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_unsat(anchor=anchor,err=err,proof=proof)

# clique Imandrax_api_tasks.PO_res.success
# def Imandrax_api_tasks.PO_res.success (mangled name: "Tasks_PO_res_success")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_success_Proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Tasks_PO_res_proof_found["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_success_Proof_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_success_Proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Tasks_PO_res_proof_found_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_success_Proof(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_success_Instance[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Tasks_PO_res_instance["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_success_Instance_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_success_Instance[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Tasks_PO_res_instance_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_success_Instance(arg=arg)

type Tasks_PO_res_success[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Tasks_PO_res_success_Proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Tasks_PO_res_success_Instance[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Tasks_PO_res_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_success:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_PO_res_success_Proof_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Tasks_PO_res_success_Instance_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_PO_res_success, got invalid constructor {idx}')

# clique Imandrax_api_tasks.PO_res.error
# def Imandrax_api_tasks.PO_res.error (mangled name: "Tasks_PO_res_error")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_No_proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Tasks_PO_res_no_proof["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_error_No_proof_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_error_No_proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Tasks_PO_res_no_proof_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_error_No_proof(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Unsat[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Tasks_PO_res_unsat["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_error_Unsat_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_error_Unsat[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Tasks_PO_res_unsat_of_twine(d=d,off=args[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    return Tasks_PO_res_error_Unsat(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Invalid_model[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    args: tuple[Error_Error_core,Common_Model_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]

def Tasks_PO_res_error_Invalid_model_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_error_Invalid_model[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    cargs = (Error_Error_core_of_twine(d=d, off=args[0]),Common_Model_t_poly_of_twine(d=d,off=args[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))
    return Tasks_PO_res_error_Invalid_model(args=cargs)

@dataclass(slots=True, frozen=True)
class Tasks_PO_res_error_Error[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    arg: Error_Error_core

def Tasks_PO_res_error_Error_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],args: tuple[int, ...]) -> Tasks_PO_res_error_Error[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    arg = Error_Error_core_of_twine(d=d, off=args[0])
    return Tasks_PO_res_error_Error(arg=arg)

type Tasks_PO_res_error[_V_tyreg_poly_term,_V_tyreg_poly_ty] = Tasks_PO_res_error_No_proof[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Tasks_PO_res_error_Unsat[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Tasks_PO_res_error_Invalid_model[_V_tyreg_poly_term,_V_tyreg_poly_ty]| Tasks_PO_res_error_Error[_V_tyreg_poly_term,_V_tyreg_poly_ty]

def Tasks_PO_res_error_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_error:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_No_proof_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Unsat_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Invalid_model_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Tasks_PO_res_error_Error_of_twine(d=d, args=args, d0=d0,d1=d1,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_PO_res_error, got invalid constructor {idx}')

# clique Imandrax_api_tasks.PO_res.result
# def Imandrax_api_tasks.PO_res.result (mangled name: "Tasks_PO_res_result")
type Tasks_PO_res_result[_V_tyreg_poly_a,_V_tyreg_poly_term,_V_tyreg_poly_ty] = "_V_tyreg_poly_a" | Tasks_PO_res_error["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_PO_res_result_of_twine(d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_a],d1: Callable[...,_V_tyreg_poly_term],d2: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_result:
    decode__tyreg_poly_a = d0
    decode__tyreg_poly_term = d1
    decode__tyreg_poly_ty = d2
    return twine_result(d=d, off=off, d0=lambda d, off: decode__tyreg_poly_a(d=d,off=off), d1=lambda d, off: Tasks_PO_res_error_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))))

# clique Imandrax_api_tasks.PO_res.shallow_poly
# def Imandrax_api_tasks.PO_res.shallow_poly (mangled name: "Tasks_PO_res_shallow_poly")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_shallow_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    from_: Ca_store_Ca_ptr[Common_Proof_obligation_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]
    res: Tasks_PO_res_result[Tasks_PO_res_success["_V_tyreg_poly_term","_V_tyreg_poly_ty"],"_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    stats: Tasks_PO_res_stats
    report: In_mem_archive[Report_Report]

def Tasks_PO_res_shallow_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_shallow_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    from_ = Ca_store_Ca_ptr_of_twine(d=d,off=fields[0],d0=(lambda d, off: Common_Proof_obligation_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    res = Tasks_PO_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_PO_res_success_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))),d1=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    stats = Tasks_PO_res_stats_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_PO_res_shallow_poly(from_=from_,res=res,stats=stats,report=report)

# clique Imandrax_api_tasks.PO_res.full_poly
# def Imandrax_api_tasks.PO_res.full_poly (mangled name: "Tasks_PO_res_full_poly")
@dataclass(slots=True, frozen=True)
class Tasks_PO_res_full_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    from_: Common_Proof_obligation_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    res: Tasks_PO_res_result[Tasks_PO_res_success["_V_tyreg_poly_term","_V_tyreg_poly_ty"],"_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    stats: Tasks_PO_res_stats
    report: In_mem_archive[Report_Report]

def Tasks_PO_res_full_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_PO_res_full_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    from_ = Common_Proof_obligation_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    res = Tasks_PO_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_PO_res_success_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))),d1=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d2=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    stats = Tasks_PO_res_stats_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_PO_res_full_poly(from_=from_,res=res,stats=stats,report=report)

# clique Imandrax_api_tasks.PO_res.t
# def Imandrax_api_tasks.PO_res.t (mangled name: "Tasks_PO_res")
type Tasks_PO_res = Tasks_PO_res_shallow_poly[Mir_Term,Mir_Type]

def Tasks_PO_res_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res:
    return Tasks_PO_res_shallow_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.PO_res.full.t
# def Imandrax_api_tasks.PO_res.full.t (mangled name: "Tasks_PO_res_full")
type Tasks_PO_res_full = Tasks_PO_res_full_poly[Mir_Term,Mir_Type]

def Tasks_PO_res_full_of_twine(d: twine.Decoder, off: int) -> Tasks_PO_res_full:
    return Tasks_PO_res_full_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.Eval_task.t_poly
# def Imandrax_api_tasks.Eval_task.t_poly (mangled name: "Tasks_Eval_task_t_poly")
@dataclass(slots=True, frozen=True)
class Tasks_Eval_task_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    db: Common_Db_ser_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    term: tuple[list[Common_Var_t_poly["_V_tyreg_poly_ty"]],"_V_tyreg_poly_term"]
    anchor: Anchor
    timeout: None | int

def Tasks_Eval_task_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_Eval_task_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    db = Common_Db_ser_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    term = (lambda tup: ([Common_Var_t_poly_of_twine(d=d,off=x,d0=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off))) for x in d.get_array(off=tup[0])],decode__tyreg_poly_term(d=d,off=tup[1])))(tuple(d.get_array(off=fields[1])))
    anchor = Anchor_of_twine(d=d, off=fields[2])
    timeout = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_int(off=off))
    return Tasks_Eval_task_t_poly(db=db,term=term,anchor=anchor,timeout=timeout)

# clique Imandrax_api_tasks.Eval_task.Imandrax_api_mir.t
# def Imandrax_api_tasks.Eval_task.Imandrax_api_mir.t (mangled name: "Tasks_Eval_task_Imandrax_api_mir")
type Tasks_Eval_task_Imandrax_api_mir = Tasks_Eval_task_t_poly[Mir_Term,Mir_Type]

def Tasks_Eval_task_Imandrax_api_mir_of_twine(d: twine.Decoder, off: int) -> Tasks_Eval_task_Imandrax_api_mir:
    return Tasks_Eval_task_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

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

# clique Imandrax_api_tasks.Decomp_task.decomp_poly
# def Imandrax_api_tasks.Decomp_task.decomp_poly (mangled name: "Tasks_Decomp_task_decomp_poly")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_task_decomp_poly_Decomp[_V_tyreg_poly_term]:
    arg: Common_Decomp_t_

def Tasks_Decomp_task_decomp_poly_Decomp_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Tasks_Decomp_task_decomp_poly_Decomp[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = Common_Decomp_t__of_twine(d=d, off=args[0])
    return Tasks_Decomp_task_decomp_poly_Decomp(arg=arg)

@dataclass(slots=True, frozen=True)
class Tasks_Decomp_task_decomp_poly_Term[_V_tyreg_poly_term]:
    arg: "_V_tyreg_poly_term"

def Tasks_Decomp_task_decomp_poly_Term_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],args: tuple[int, ...]) -> Tasks_Decomp_task_decomp_poly_Term[_V_tyreg_poly_term]:
    decode__tyreg_poly_term = d0
    arg = decode__tyreg_poly_term(d=d,off=args[0])
    return Tasks_Decomp_task_decomp_poly_Term(arg=arg)

type Tasks_Decomp_task_decomp_poly[_V_tyreg_poly_term] = Tasks_Decomp_task_decomp_poly_Decomp[_V_tyreg_poly_term]| Tasks_Decomp_task_decomp_poly_Term[_V_tyreg_poly_term]

def Tasks_Decomp_task_decomp_poly_of_twine[_V_tyreg_poly_term](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],off: int) -> Tasks_Decomp_task_decomp_poly:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Tasks_Decomp_task_decomp_poly_Decomp_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Tasks_Decomp_task_decomp_poly_Term_of_twine(d=d, args=args, d0=d0,)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tasks_Decomp_task_decomp_poly, got invalid constructor {idx}')

# clique Imandrax_api_tasks.Decomp_task.t_poly
# def Imandrax_api_tasks.Decomp_task.t_poly (mangled name: "Tasks_Decomp_task_t_poly")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_task_t_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    db: Common_Db_ser_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]
    decomp: Tasks_Decomp_task_decomp_poly["_V_tyreg_poly_term"]
    anchor: Anchor

def Tasks_Decomp_task_t_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_Decomp_task_t_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    db = Common_Db_ser_t_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
    decomp = Tasks_Decomp_task_decomp_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    anchor = Anchor_of_twine(d=d, off=fields[2])
    return Tasks_Decomp_task_t_poly(db=db,decomp=decomp,anchor=anchor)

# clique Imandrax_api_tasks.Decomp_task.Imandrax_api_mir.decomp
# def Imandrax_api_tasks.Decomp_task.Imandrax_api_mir.decomp (mangled name: "Tasks_Decomp_task_Imandrax_api_mir_decomp")
type Tasks_Decomp_task_Imandrax_api_mir_decomp = Tasks_Decomp_task_decomp_poly[Mir_Term]

def Tasks_Decomp_task_Imandrax_api_mir_decomp_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_task_Imandrax_api_mir_decomp:
    return Tasks_Decomp_task_decomp_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.Decomp_task.Imandrax_api_mir.t
# def Imandrax_api_tasks.Decomp_task.Imandrax_api_mir.t (mangled name: "Tasks_Decomp_task_Imandrax_api_mir")
type Tasks_Decomp_task_Imandrax_api_mir = Tasks_Decomp_task_t_poly[Mir_Term,Mir_Type]

def Tasks_Decomp_task_Imandrax_api_mir_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_task_Imandrax_api_mir:
    return Tasks_Decomp_task_t_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.Decomp_res.success
# def Imandrax_api_tasks.Decomp_res.success (mangled name: "Tasks_Decomp_res_success")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res_success[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    anchor: Anchor
    decomp: Common_Fun_decomp_t_poly["_V_tyreg_poly_term","_V_tyreg_poly_ty"]

def Tasks_Decomp_res_success_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_Decomp_res_success:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    anchor = Anchor_of_twine(d=d, off=fields[0])
    decomp = Common_Fun_decomp_t_poly_of_twine(d=d,off=fields[1],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))
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

# clique Imandrax_api_tasks.Decomp_res.shallow_poly
# def Imandrax_api_tasks.Decomp_res.shallow_poly (mangled name: "Tasks_Decomp_res_shallow_poly")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res_shallow_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    from_: Ca_store_Ca_ptr[Tasks_Decomp_task_decomp_poly["_V_tyreg_poly_term"]]
    res: Tasks_Decomp_res_result[Tasks_Decomp_res_success["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]
    stats: Stat_time
    report: In_mem_archive[Report_Report]

def Tasks_Decomp_res_shallow_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_Decomp_res_shallow_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    from_ = Ca_store_Ca_ptr_of_twine(d=d,off=fields[0],d0=(lambda d, off: Tasks_Decomp_task_decomp_poly_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))))
    res = Tasks_Decomp_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_Decomp_res_success_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    stats = Stat_time_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_Decomp_res_shallow_poly(from_=from_,res=res,stats=stats,report=report)

# clique Imandrax_api_tasks.Decomp_res.full_poly
# def Imandrax_api_tasks.Decomp_res.full_poly (mangled name: "Tasks_Decomp_res_full_poly")
@dataclass(slots=True, frozen=True)
class Tasks_Decomp_res_full_poly[_V_tyreg_poly_term,_V_tyreg_poly_ty]:
    from_: Tasks_Decomp_task_decomp_poly["_V_tyreg_poly_term"]
    res: Tasks_Decomp_res_result[Tasks_Decomp_res_success["_V_tyreg_poly_term","_V_tyreg_poly_ty"]]
    stats: Stat_time
    report: In_mem_archive[Report_Report]

def Tasks_Decomp_res_full_poly_of_twine[_V_tyreg_poly_term,_V_tyreg_poly_ty](d: twine.Decoder, d0: Callable[...,_V_tyreg_poly_term],d1: Callable[...,_V_tyreg_poly_ty],off: int) -> Tasks_Decomp_res_full_poly:
    decode__tyreg_poly_term = d0
    decode__tyreg_poly_ty = d1
    fields = list(d.get_array(off=off))
    from_ = Tasks_Decomp_task_decomp_poly_of_twine(d=d,off=fields[0],d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)))
    res = Tasks_Decomp_res_result_of_twine(d=d,off=fields[1],d0=(lambda d, off: Tasks_Decomp_res_success_of_twine(d=d,off=off,d0=(lambda d, off: decode__tyreg_poly_term(d=d,off=off)),d1=(lambda d, off: decode__tyreg_poly_ty(d=d,off=off)))))
    stats = Stat_time_of_twine(d=d, off=fields[2])
    report = In_mem_archive_of_twine(d=d,off=fields[3],d0=(lambda d, off: Report_Report_of_twine(d=d, off=off)))
    return Tasks_Decomp_res_full_poly(from_=from_,res=res,stats=stats,report=report)

# clique Imandrax_api_tasks.Decomp_res.Shallow.t
# def Imandrax_api_tasks.Decomp_res.Shallow.t (mangled name: "Tasks_Decomp_res_Shallow")
type Tasks_Decomp_res_Shallow = Tasks_Decomp_res_shallow_poly[Mir_Term,Mir_Type]

def Tasks_Decomp_res_Shallow_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_res_Shallow:
    return Tasks_Decomp_res_shallow_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))

# clique Imandrax_api_tasks.Decomp_res.Full.t
# def Imandrax_api_tasks.Decomp_res.Full.t (mangled name: "Tasks_Decomp_res_Full")
type Tasks_Decomp_res_Full = Tasks_Decomp_res_full_poly[Mir_Term,Mir_Type]

def Tasks_Decomp_res_Full_of_twine(d: twine.Decoder, off: int) -> Tasks_Decomp_res_Full:
    return Tasks_Decomp_res_full_poly_of_twine(d=d,off=off,d0=(lambda d, off: Mir_Term_of_twine(d=d, off=off)),d1=(lambda d, off: Mir_Type_of_twine(d=d, off=off)))


# Artifacts

type Artifact = Mir_Term|Mir_Type|Tasks_PO_task_Mir|Tasks_PO_res_Shallow|Tasks_Eval_task_Mir|Tasks_Eval_res|Mir_Model|str|Mir_Fun_decomp|Tasks_Decomp_task_Mir|Tasks_Decomp_res_Shallow|Report_Report

artifact_decoders = {\
  'term': (lambda d, off: Mir_Term_of_twine(d=d, off=off)),
  'ty': (lambda d, off: Mir_Type_of_twine(d=d, off=off)),
  'po_task': (lambda d, off: Tasks_PO_task_Mir_of_twine(d=d, off=off)),
  'po_res': (lambda d, off: Tasks_PO_res_Shallow_of_twine(d=d, off=off)),
  'eval_task': (lambda d, off: Tasks_Eval_task_Mir_of_twine(d=d, off=off)),
  'eval_res': (lambda d, off: Tasks_Eval_res_of_twine(d=d, off=off)),
  'mir.model': (lambda d, off: Mir_Model_of_twine(d=d, off=off)),
  'show': (lambda d, off: d.get_str(off=off)),
  'mir.fun_decomp': (lambda d, off: Mir_Fun_decomp_of_twine(d=d, off=off)),
  'decomp_task': (lambda d, off: Tasks_Decomp_task_Mir_of_twine(d=d, off=off)),
  'decomp_res': (lambda d, off: Tasks_Decomp_res_Shallow_of_twine(d=d, off=off)),
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
  

