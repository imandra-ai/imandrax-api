from enum import Enum


class EvalResKind(str, Enum):
    ERRORS = "errors"
    OK = "ok"

    def __str__(self) -> str:
        return str(self.value)
