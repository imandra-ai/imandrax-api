class ImandraXError(Exception):
    """Base class for errors from ImandraX requests"""


class UnexpectedResponseError(ImandraXError):
    """The server's response did not have the expected shape"""
