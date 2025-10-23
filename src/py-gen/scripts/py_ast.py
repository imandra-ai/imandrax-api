# %%
from IPython.core.getipython import get_ipython

if ip := get_ipython():
    ip.run_line_magic('reload_ext', 'autoreload')
    ip.run_line_magic('autoreload', '2')

import ast

from devtools import pprint
from rich import print

# %%
src = """\
x = 0
"""

node = ast.parse(src)

pprint(node.body)
