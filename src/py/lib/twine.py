from dataclasses import dataclass


@dataclass
class Error(Exception):
    msg: str


class Decoder:
    """A twine decoder"""

    def __init__(self, a: bytearray):
        self.bs = a

    def __first_byte(self, off: int) -> tuple[int, int]:
        c = self.bs[off]
        high = c >> 4
        low = c & 0xF
        return (high, low)

    def _leb128(self, off: int) -> int:
        res = 0
        shift = 0
        while True:
            x = self.bs[off]
            off += 1
            cur = x & 0x7F
            if x != cur:
                res = res | (cur << shift)
                shift += 7
            else:
                res = res | (x << shift)
                return res

    def __getint64(self, off: int, low: int) -> int:
        if low < 15:
            return low
        rest = self._leb128(off=off + 1)
        return rest + 15

    def get_int(self, off: int) -> int:
        high, low = self.__first_byte(off)
        if high == 1:
            return self.__getint64(off=off, low=low)
        elif high == 2:
            # negative int
            x = self.__getint64(off=off, low=low)
            return -x - 1
        else:
            raise Error(f"expected integer, but high={high}")

    def get_bool(self, off: int) -> bool:
        high, low = self.__first_byte(off=off)
        if high != 0:
            raise Error(f"expected bool, but high={high}")
        if low == 0:
            return False
        elif low == 1:
            return True
        else:
            raise Error(f"expected bool, but high={high}, low={low}")

    def get_null(self, off: int) -> None:
        high, low = self.__first_byte(off=off)
        if high == 0 and low == 2:
            return None
        else:
            raise Error(f"expected bool, but high={high}, low={low}")
