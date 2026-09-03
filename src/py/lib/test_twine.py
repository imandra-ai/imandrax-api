import json
from pathlib import Path

from . import twine

CURR_DIR = Path(__file__).parent

def test_leb128():
    c = twine.Decoder(b'\x07')
    assert c._leb128(off=0)[0] == 7  # pyright: ignore[reportPrivateUsage]

    c = twine.Decoder(b'\x81\x42')
    assert c._leb128(off=0)[0] == ((0x42 << 7) + 1)  # pyright: ignore[reportPrivateUsage]

def test_caches_are_per_instance():
    # Regression: `Decoder.caches` must not be shared across instances, otherwise
    # cached values keyed by offset leak from one artifact's decoder into another's,
    # returning stale decoded sub-values at colliding offsets.
    d1 = twine.Decoder(b'\x00')
    d2 = twine.Decoder(b'\x00')
    assert d1.caches is not d2.caches
    d1.caches.setdefault('T', {})[42] = 'stale'
    assert 42 not in d2.caches.get('T', {})

def test_get_float():
    # Regression: the float payload starts *after* the first byte, which holds
    # the (high=3, low=is_f32) tag; reading from the tag byte itself yields garbage.
    import struct

    f64 = twine.Decoder(b'\x31' + struct.pack('<d', 0.125))
    assert f64.get_float(off=0) == 0.125

    f32 = twine.Decoder(b'\x30' + struct.pack('<f', 0.125))
    assert f32.get_float(off=0) == 0.125

def test_skip_float_matches_payload_size():
    import struct

    d = twine.Decoder(b'\x31' + struct.pack('<d', 1.5) + b'\x11')
    assert d._skip(off=0) == 9  # pyright: ignore[reportPrivateUsage]
    assert d.get_int(off=9) == 1

def _get_testdata1() -> twine.Decoder:
    with (CURR_DIR / 'test_data/typereg.twine').open('rb') as f:
        data = bytearray(f.read())
    return twine.Decoder(data)

def test_integration1():
    d = _get_testdata1()
    off: twine.offset = d.entrypoint()
    assert off == 22172
    v = d.value(off=off)
    v_json = twine.value_to_json(v)
    with (CURR_DIR / 'test_data/typereg.json').open('r') as f:
        data_json = json.dumps(json.loads(f.read()))
    assert data_json == v_json

def test_integration_pubsub():
    with (CURR_DIR / 'test_data/pubsub.twine').open('rb') as f:
        data = bytearray(f.read())
    d = twine.Decoder(data)
    off: twine.offset = d.entrypoint()
    v = d.value(off)
    assert "{'PUBSUB': {'summary': 'A container for Pub/Sub commands.', 'complexity': 'Depends on subcommand.', 'group': 'pubsub', 'since': '2.8.0', 'arity': -2}}" == str(v)
