
try:
    import http.client as httplib
except ImportError:
    import httplib

try:
    import ujson as json
except ImportError:
    import json

from typing import Any

from google.protobuf.message import DecodeError

from .._errors import ImandraXError
from . import errors


class TwirpServerException(ImandraXError, httplib.HTTPException):
    """An RPC failed: the server answered with a Twirp error, or there was no usable answer"""

    def __init__(self, *, code, message, meta={}, status=None):
        try:
            self._code = errors.Errors(code)
        except ValueError:
            self._code = errors.Errors.Unknown
        self._message = message
        self._meta = meta
        # the HTTP status, `None` when the request failed without a response
        self.status: int | None = status
        super(TwirpServerException, self).__init__(message, meta)

    @property
    def code(self):
        if isinstance(self._code, errors.Errors):
            return self._code
        return errors.Errors.Unknown

    @property
    def message(self):
        return self._message

    @property
    def meta(self) -> dict[str, Any]:
        return self._meta

    def to_dict(self):
        err = {
            "code": self._code.value,
            "msg": self._message,
            "meta": {}
        }
        for k, v in self._meta.items():
            err["meta"][k] = str(v)
        return err

    def to_json_bytes(self):
        return json.dumps(self.to_dict()).encode('utf-8')

    @staticmethod
    def from_json(err_dict):
        return TwirpServerException(
            code=err_dict.get('code', errors.Errors.Unknown),
            message=err_dict.get('msg',''),
            meta=err_dict.get('meta',{}),
        )

def InvalidArgument(*, argument, error):
    return TwirpServerException(
        code=errors.Errors.InvalidArgument,
        message="{} {}".format(argument, error),
        meta={
            "argument":argument
        }
    )

def RequiredArgument(*, argument):
    return InvalidArgument(
        argument=argument,
        error="is required"
    )


def twirp_error_from_intermediary(status, reason, headers, body):
    # see https://twitchtv.github.io/twirp/docs/errors.html#http-errors-from-intermediary-proxies
    meta = {
        'http_error_from_intermediary': 'true',
        'status_code': str(status),
    }

    if 300 <= status < 400:
        # twirp uses POST which should not redirect
        code = errors.Errors.Internal
        location = headers.get('location')
        message = 'unexpected HTTP status code %d "%s" received, Location="%s"' % (
            status,
            reason,
            location,
        )
        meta['location'] = location

    else:
        code = {
            400: errors.Errors.Internal,  # JSON response should have been returned
            401: errors.Errors.Unauthenticated,
            403: errors.Errors.PermissionDenied,
            404: errors.Errors.BadRoute,
            429: errors.Errors.ResourceExhausted,
            502: errors.Errors.Unavailable,
            503: errors.Errors.Unavailable,
            504: errors.Errors.Unavailable,
        }.get(status, errors.Errors.Unknown)

        message = 'Error from intermediary with HTTP status code %d "%s"' % (
            status,
            reason,
        )
        meta['body'] = body

    return TwirpServerException(code=code, message=message, meta=meta, status=status)


def decode_response(response_obj, body):
    """Decode the body of a 200 response; a body that doesn't decode is an `internal` error"""
    response = response_obj()
    try:
        response.ParseFromString(body)
    except DecodeError as e:
        # e.g. an HTML or truncated body, from an intermediary or a dropped connection
        raise TwirpServerException(
            code=errors.Errors.Internal,
            message="failed to decode the response: %s" % e,
            meta={"original_exception": e},
            status=200,
        ) from e
    return response


def twirp_error_of_response(status, reason, headers, body):
    """The error for a non-200 response: its Twirp JSON error, else as from an intermediary"""
    # a redirect is an error, whatever its body (twirp uses POST, which should not redirect)
    if not 300 <= status < 400:
        try:
            err = json.loads(body)
        except ValueError:
            err = None
        if isinstance(err, dict) and isinstance(err.get("code"), str):
            return TwirpServerException(
                code=err["code"],
                message=err.get("msg", ""),
                meta={"body": err},
                status=status,
            )
    return twirp_error_from_intermediary(
        status, reason, headers, body.decode(errors="replace")
    )
