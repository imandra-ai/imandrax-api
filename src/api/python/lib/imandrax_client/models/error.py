from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.error_message import ErrorMessage


T = TypeVar("T", bound="Error")


@_attrs_define
class Error:
    """
    Attributes:
        msg (ErrorMessage):
        kind (str):
        context (Union[Unset, list['ErrorMessage']]):
        process (Union[Unset, str]):
    """

    msg: "ErrorMessage"
    kind: str
    context: Union[Unset, list["ErrorMessage"]] = UNSET
    process: Union[Unset, str] = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        msg = self.msg.to_dict()

        kind = self.kind

        context: Union[Unset, list[dict[str, Any]]] = UNSET
        if not isinstance(self.context, Unset):
            context = []
            for context_item_data in self.context:
                context_item = context_item_data.to_dict()
                context.append(context_item)

        process = self.process

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "msg": msg,
                "kind": kind,
            }
        )
        if context is not UNSET:
            field_dict["context"] = context
        if process is not UNSET:
            field_dict["process"] = process

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.error_message import ErrorMessage

        d = dict(src_dict)
        msg = ErrorMessage.from_dict(d.pop("msg"))

        kind = d.pop("kind")

        context = []
        _context = d.pop("context", UNSET)
        for context_item_data in _context or []:
            context_item = ErrorMessage.from_dict(context_item_data)

            context.append(context_item)

        process = d.pop("process", UNSET)

        error = cls(
            msg=msg,
            kind=kind,
            context=context,
            process=process,
        )

        error.additional_properties = d
        return error

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
