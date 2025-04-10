from http import HTTPStatus
from typing import Any, Optional, Union

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.get_artifact_list_taskid_response_200 import GetArtifactListTaskidResponse200
from ...types import Response


def _get_kwargs(
    taskid: str,
) -> dict[str, Any]:
    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": f"/artifact/list/{taskid}/",
    }

    return _kwargs


def _parse_response(
    *, client: Union[AuthenticatedClient, Client], response: httpx.Response
) -> Optional[GetArtifactListTaskidResponse200]:
    if response.status_code == 200:
        response_200 = GetArtifactListTaskidResponse200.from_dict(response.json())

        return response_200
    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: Union[AuthenticatedClient, Client], response: httpx.Response
) -> Response[GetArtifactListTaskidResponse200]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    taskid: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Response[GetArtifactListTaskidResponse200]:
    """list available artifact kinds for this task

    Args:
        taskid (str): Task identifier

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[GetArtifactListTaskidResponse200]
    """

    kwargs = _get_kwargs(
        taskid=taskid,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    taskid: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Optional[GetArtifactListTaskidResponse200]:
    """list available artifact kinds for this task

    Args:
        taskid (str): Task identifier

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        GetArtifactListTaskidResponse200
    """

    return sync_detailed(
        taskid=taskid,
        client=client,
    ).parsed


async def asyncio_detailed(
    taskid: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Response[GetArtifactListTaskidResponse200]:
    """list available artifact kinds for this task

    Args:
        taskid (str): Task identifier

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[GetArtifactListTaskidResponse200]
    """

    kwargs = _get_kwargs(
        taskid=taskid,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    taskid: str,
    *,
    client: Union[AuthenticatedClient, Client],
) -> Optional[GetArtifactListTaskidResponse200]:
    """list available artifact kinds for this task

    Args:
        taskid (str): Task identifier

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        GetArtifactListTaskidResponse200
    """

    return (
        await asyncio_detailed(
            taskid=taskid,
            client=client,
        )
    ).parsed
