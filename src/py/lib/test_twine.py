
import json
from . import twine

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

def _get_testdata1() -> twine.Decoder:
    with open('test_data/typereg.twine', 'rb') as f:
        data = bytearray(f.read())
    return twine.Decoder(data)

def test_integration1():
    d = _get_testdata1()
    off: twine.offset = d.entrypoint()
    assert off == 22172
    v = d.value(off=off)
    v_json = twine.value_to_json(v)
    with open('test_data/typereg.json', 'r') as f:
        data_json = json.dumps(json.loads(f.read()))
    assert data_json == v_json

def test_integration_pubsub():
    with open('test_data/pubsub.twine', 'rb') as f:
        data = bytearray(f.read())
    d = twine.Decoder(data)
    off: twine.offset = d.entrypoint()
    v = d.value(off)
    assert "{'PUBSUB': {'summary': 'A container for Pub/Sub commands.', 'complexity': 'Depends on subcommand.', 'group': 'pubsub', 'since': '2.8.0', 'arity': -2}}" == str(v)
