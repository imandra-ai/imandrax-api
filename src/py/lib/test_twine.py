
from . import twine

def test_leb128():
    c = twine.Decoder(b'\x07')
    assert c._leb128(off=0) == 7

    c = twine.Decoder(b'\x81\x42')
    assert c._leb128(off=0) == ((0x42 << 7) + 1)
