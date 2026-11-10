"""Griffe extension for the docs: don't document names a module only got from `import *`

`interface.py` does `from .mir import *`; without this, the interface page repeats the
whole mir page. Loaded via `extensions` in mkdocs.yml.
"""

from typing import Any

import griffe


class HideWildcardImports(griffe.Extension):
    def on_package(self, *, pkg: griffe.Module, **kwargs: Any) -> None:
        for name, m in list(pkg.members.items()):
            if m.is_alias and m.wildcard_imported:
                del pkg.members[name]
        for sub in pkg.modules.values():
            self.on_package(pkg=sub)
