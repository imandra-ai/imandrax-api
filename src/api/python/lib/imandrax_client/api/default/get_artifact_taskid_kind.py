from http import HTTPStatus
from io import BytesIO
from typing import Any, Optional, Union

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...types import File, Response


def _get_kwargs(
    taskid: str,
    kind: str,
) -> dict[str, Any]:
    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": f"/artifact/{taskid}/{kind}",
    }

    return _kwargs


def _parse_response(*, client: Union[AuthenticatedClient, Client], response: httpx.Response) -> Optional[File]:
    if response.status_code == 200:
        response_200 = File(payload=BytesIO(response.content))

        return response_200
    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(*, client: Union[AuthenticatedClient, Client], response: httpx.Response) -> Response[File]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    taskid: str,
    kind: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Response[File]:
    """get artifact of given kind

    Args:
        taskid (str): Task identifier
        kind (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[File]
    """

    kwargs = _get_kwargs(
        taskid=taskid,
        kind=kind,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    taskid: str,
    kind: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Optional[File]:
    """get artifact of given kind

    Args:
        taskid (str): Task identifier
        kind (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        File
    """

    return sync_detailed(
        taskid=taskid,
        kind=kind,
        client=client,
    ).parsed


async def asyncio_detailed(
    taskid: str,
    kind: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Response[File]:
    """get artifact of given kind

    Args:
        taskid (str): Task identifier
        kind (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[File]
    """

    kwargs = _get_kwargs(
        taskid=taskid,
        kind=kind,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    taskid: str,
    kind: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Optional[File]:
    """get artifact of given kind

    Args:
        taskid (str): Task identifier
        kind (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        File
    """

    return (
        await asyncio_detailed(
            taskid=taskid,
            kind=kind,
            client=client,
        )
    ).parsed
