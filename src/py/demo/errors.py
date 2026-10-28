from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .interface import Error, ErrorCore, Task


class ImandraXError(Exception):
    """Base class for errors from ImandraX requests"""


class UnexpectedResponseError(ImandraXError):
    """The server's response did not have the expected shape"""


class ServerError(ImandraXError):
    """The server reported an error"""

    def __init__(self, error: Error | ErrorCore):
        super().__init__(str(error))
        self.error: Error | ErrorCore = error


class ClientGoneError(ImandraXError):
    """Task data was fetched after the client that created the task was garbage-collected"""


class NoClientError(ImandraXError):
    """Task data that is not fetched yet was accessed on a task created without a client"""


class NotFetchedError(ImandraXError):
    """An artifact of a task from an `AsyncClient` was accessed before it was fetched

    Fetch it by accessing the attribute with `await task.awaitable.<attribute>` first
    """

    def __init__(self, task: Task, kind: str):
        super().__init__(
            f"artifact {kind!r} of task {task.id} not fetched; use `await task.awaitable.<attribute>` first"
        )
        self.task: Task = task
        self.kind: str = kind
