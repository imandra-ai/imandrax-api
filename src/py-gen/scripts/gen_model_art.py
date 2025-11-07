# pyright: basic
# %%
import base64
import json
from pathlib import Path

import yaml
from imandrax_api import Client, url_prod
from imandrax_api.lib import read_artifact_data
from IPython.core.getipython import get_ipython
from rich import print

if ip := get_ipython():
    ip.run_line_magic('reload_ext', 'autoreload')
    ip.run_line_magic('autoreload', '2')
import os
from typing import Any, Final

import dotenv
from google.protobuf.json_format import MessageToDict
from google.protobuf.message import Message

curr_dir = Path.cwd() if ip else Path(__file__).parent
dotenv.load_dotenv()


ONE_YAML: Final = False


class LiteralString(str):
    pass


def literal_presenter(dumper, data):
    if '\n' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)


yaml.add_representer(LiteralString, literal_presenter)


def proto_to_dict(proto_obj: Message) -> dict[Any, Any]:
    return MessageToDict(
        proto_obj,
        preserving_proto_field_name=True,
        always_print_fields_with_no_presence=True,
    )


# %%
c = Client(auth_token=os.environ['IMANDRAX_API_KEY'], url=url_prod)

# out_dir = curr_dir.parent / 'examples' / 'art'
out_dir = curr_dir


# %%
iml_v_template = """\
let v =
  fun w ->
    if w = {v} then true else false\
"""

values: list[tuple[str, str]] = [
    # Primitive
    ('real', iml_v_template.format(v=r'3.14')),
    ('int', iml_v_template.format(v=r'2')),
    ('LChar', iml_v_template.format(v=r'LChar.zero')),
    ('LString', iml_v_template.format(v=r'{l|hi|l}')),
    ('tuple (bool * int)', iml_v_template.format(v=r'(true, 2)')),
    # Composite
    ('empty list', iml_v_template.format(v=r'[]')),
    ('single element int list', iml_v_template.format(v=r'[1]')),
    ('bool list', iml_v_template.format(v=r'[true; false]')),
    ('int option', iml_v_template.format(v=r'Some 2')),
    (
        'record',
        """\
type user = {
    id: int;
    active: bool;
}

let v = {id = 1; active = true}

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant1',
        """\
type status =
    | Active
    | Waitlist of int

let v = Active

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant2',
        """\
type status =
    | Active
    | Waitlist of int

let v = Waitlist 1

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant3',
        """\
type status =
    | Active
    | Waitlist of int * bool

let v = Waitlist (2, true)

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
]


values: list[tuple[str, str]] = [
    (
        'variant_and_record',
        """\
type direction = North | South | East | West

type position = { x: int; y: int; z: real }

type movement =
  | Stay of position
  | Move of position * direction

let v =
  fun w ->
      if w = Move ({x=1; y=2; z=3.0}, North) then true else false\
""",
    ),
]

values: list[tuple[str, str]] = [
    (
        'inline_record',
        """\
type event =
    | Click of { x: int; y: int }
    | Keypress of { key: LChar.t; modifiers: LString.t list }
    | Scroll of { delta: real }

let v = Scroll {delta = 2.0}\

let v = fun w -> if w = v then true else false\
""",
    ),
]
values = [
    (
        'map_int_bool',
        """\
let v : (int, bool) Map.t =
  Map.const false

let v = fun w -> if w = v then true else false\
""",
    ),
]

values = [
    (
        'multiset_nonempty',
        """\
let v = Multiset.of_list [1; 2; 3; 2; 1]

let v = fun w -> if w = v then true else false\
""",
    ),
    (
        'multiset_empty',
        """\
let v = Multiset.of_list []

let v = fun w -> if w = v then true else false
instance v\
""",
    ),
    (
        'set_nonempty',
        """\
let v = Set.of_list [1; 2; 3; 2; 1]

let v = fun w -> if w = v then true else false\
""",
    ),
    (
        'set_empty',
        """\
let v = Set.of_list []

let v = fun w -> if w = v then true else false\
""",
    ),
]

values = [
    (
        'map_default_value_only',
        """\
let v = Map.const false

let v = fun w -> if w = v then true else false\
""",
    )
]

values = [
    (
        'annotated_polymorphic',
        """\
let v =  (fun (w: _ list) -> if w = [] then true else false)\
""",
    )
]


values = [
    (
        'annotated_polymorphic_weird_type_name',
        """\
type _a_0 = My_dummy_0

let v =  (fun (w: _a_0 list) -> if w = [] then true else false)\
""",
    )
]
# iml = r"""
# let v = function
#   | {v} -> true
#   | _ -> false
# """


# %%
def gen_art(name: str, iml: str) -> dict[str, Any]:
    _eval_res = c.eval_src(iml)
    instance_res = c.instance_src(src='v')
    instance_res = proto_to_dict(instance_res)
    art = instance_res['sat']['model']['artifact']
    art['iml'] = LiteralString(iml)
    art['name'] = name
    art['instance_src'] = 'v'
    order = [
        'name',
        'iml',
        'instance_src',
        'data',
        'api_version',
        'kind',
        'storage',
    ]
    return {k: art[k] for k in order}


art_data: list[dict[str, Any]] = []
for name, iml in values:
    art_data_item = gen_art(name, iml)
    art_data.append(art_data_item)

if ONE_YAML:
    with (out_dir / 'art.yaml').open('w') as f:
        f.write(yaml.dump(art_data, sort_keys=False, default_flow_style=False))
else:
    out_art_dir = out_dir / 'art'
    out_art_dir.mkdir(exist_ok=True)
    for art in art_data:
        file_name = art['name'].replace(' ', '_')
        with (out_art_dir / f'{file_name}.yaml').open('w') as f:
            f.write(yaml.dump(art, sort_keys=False, default_flow_style=False))
