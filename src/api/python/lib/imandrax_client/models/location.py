from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.position import Position


T = TypeVar("T", bound="Location")


@_attrs_define
class Location:
    """
    Attributes:
        file (Union[Unset, str]):
        start (Union[Unset, Position]): Position in a code snippet
        stop (Union[Unset, Position]): Position in a code snippet
    """

    file: Union[Unset, str] = UNSET
    start: Union[Unset, "Position"] = UNSET
    stop: Union[Unset, "Position"] = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        file = self.file

        start: Union[Unset, dict[str, Any]] = UNSET
        if not isinstance(self.start, Unset):
            start = self.start.to_dict()

        stop: Union[Unset, dict[str, Any]] = UNSET
        if not isinstance(self.stop, Unset):
            stop = self.stop.to_dict()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if file is not UNSET:
            field_dict["file"] = file
        if start is not UNSET:
            field_dict["start"] = start
        if stop is not UNSET:
            field_dict["stop"] = stop

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.position import Position

        d = dict(src_dict)
        file = d.pop("file", UNSET)

        _start = d.pop("start", UNSET)
        start: Union[Unset, Position]
        if isinstance(_start, Unset):
            start = UNSET
        else:
            start = Position.from_dict(_start)

        _stop = d.pop("stop", UNSET)
        stop: Union[Unset, Position]
        if isinstance(_stop, Unset):
            stop = UNSET
        else:
            stop = Position.from_dict(_stop)

        location = cls(
            file=file,
            start=start,
            stop=stop,
        )

        location.additional_properties = d
        return location

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
