"""The base class of the client's errors

It lives in a module of its own, which imports nothing, so the Twirp layer, `v1` and `v2` can all
derive from it without import cycles.
"""


class ImandraXError(Exception):
    """Base class for errors from ImandraX requests"""
