from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..models.eval_res_kind import EvalResKind
from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.error import Error


T = TypeVar("T", bound="EvalRes")


@_attrs_define
class EvalRes:
    """Result for the evaluation endpoints

    Attributes:
        current (str): New current state
        res (EvalResKind):
        duration_s (float):
        tasks (Union[Unset, list[str]]):
        errors (Union[Unset, list['Error']]):
    """

    current: str
    res: EvalResKind
    duration_s: float
    tasks: Union[Unset, list[str]] = UNSET
    errors: Union[Unset, list["Error"]] = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        current = self.current

        res = self.res.value

        duration_s = self.duration_s

        tasks: Union[Unset, list[str]] = UNSET
        if not isinstance(self.tasks, Unset):
            tasks = self.tasks

        errors: Union[Unset, list[dict[str, Any]]] = UNSET
        if not isinstance(self.errors, Unset):
            errors = []
            for errors_item_data in self.errors:
                errors_item = errors_item_data.to_dict()
                errors.append(errors_item)

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "current": current,
                "res": res,
                "duration_s": duration_s,
            }
        )
        if tasks is not UNSET:
            field_dict["tasks"] = tasks
        if errors is not UNSET:
            field_dict["errors"] = errors

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.error import Error

        d = dict(src_dict)
        current = d.pop("current")

        res = EvalResKind(d.pop("res"))

        duration_s = d.pop("duration_s")

        tasks = cast(list[str], d.pop("tasks", UNSET))

        errors = []
        _errors = d.pop("errors", UNSET)
        for errors_item_data in _errors or []:
            errors_item = Error.from_dict(errors_item_data)

            errors.append(errors_item)

        eval_res = cls(
            current=current,
            res=res,
            duration_s=duration_s,
            tasks=tasks,
            errors=errors,
        )

        eval_res.additional_properties = d
        return eval_res

    @property
    def additional_keys(self) -> list[str]:
        return list(self.additional_properties.keys())

    def __getitem__(self, key: str) -> Any:
        return self.additional_properties[key]

    def __setitem__(self, key: str, value: Any) -> None:
        self.additional_properties[key] = value

    def __delitem__(self, key: str) -> None:
        del self.additional_properties[key]

    def __contains__(self, key: str) -> bool:
        return key in self.additional_properties
