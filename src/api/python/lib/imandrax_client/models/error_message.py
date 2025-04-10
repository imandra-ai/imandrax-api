from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.location import Location


T = TypeVar("T", bound="ErrorMessage")


@_attrs_define
class ErrorMessage:
    """
    Attributes:
        message (str):
        locs (Union[Unset, list['Location']]):
        backtrace (Union[Unset, str]):
    """

    message: str
    locs: Union[Unset, list["Location"]] = UNSET
    backtrace: Union[Unset, str] = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        message = self.message

        locs: Union[Unset, list[dict[str, Any]]] = UNSET
        if not isinstance(self.locs, Unset):
            locs = []
            for locs_item_data in self.locs:
                locs_item = locs_item_data.to_dict()
                locs.append(locs_item)

        backtrace = self.backtrace

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "message": message,
            }
        )
        if locs is not UNSET:
            field_dict["locs"] = locs
        if backtrace is not UNSET:
            field_dict["backtrace"] = backtrace

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.location import Location

        d = dict(src_dict)
        message = d.pop("message")

        locs = []
        _locs = d.pop("locs", UNSET)
        for locs_item_data in _locs or []:
            locs_item = Location.from_dict(locs_item_data)

            locs.append(locs_item)

        backtrace = d.pop("backtrace", UNSET)

        error_message = cls(
            message=message,
            locs=locs,
            backtrace=backtrace,
        )

        error_message.additional_properties = d
        return error_message

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
