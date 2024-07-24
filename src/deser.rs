use super::types::*;

/// A decoder for a twine bytestring.
#[derive(Clone)]
pub struct Decoder<'a> {
    bs: &'a [u8],
}

impl<'a> Decoder<'a> {
    pub fn new(bs: &'a [u8]) -> Result<Self> {
        if bs.len() > u32::MAX as usize {
            return Err(Error {
                msg: "byte buffer is too long",
                off: 0,
            });
        }
        Ok(Self { bs })
    }

    #[inline]
    pub(crate) fn first_byte(&self, off: Offset) -> (u8, u8) {
        let c = self.bs[off as usize];
        let high = c >> 4;
        let low = c & 0xf;
        (high, low)
    }

    /// read an integer
    fn leb128(&self, mut off: Offset) -> Result<(u64, u8)> {
        let mut res: u64 = 0;
        let mut shift = 0;
        let mut n_bytes = 0;

        loop {
            n_bytes += 1;
            let c = self.bs[off as usize];
            off += 1;
            let cur = c & 0x7f;
            res = res & ((cur as u64) << shift);

            if cur == c {
                // last byte
                return Ok((res, n_bytes));
            } else {
                shift += 7;
                if shift >= 64 {
                    return Err(Error {
                        msg: "out of bound for LEB128",
                        off,
                    });
                }
            }
        }
    }

    pub(crate) fn u64_with_low(&self, off: Offset, low: u8) -> Result<(u64, Offset)> {
        if low < 15 {
            return Ok((low as u64, 0));
        }
        let (rest, consumed) = self.leb128(off)?;
        Ok((rest + 15, consumed as Offset))
    }

    pub(crate) fn deref(&self, mut off: Offset) -> Result<Offset> {
        loop {
            let (high, low) = self.first_byte(off);
            if high == 15 {
                let (p, _) = self.u64_with_low(off, low)?;
                // checked sub
                off = off.checked_sub(p as Offset + 1).ok_or_else(|| Error {
                    msg: "pointer underflow",
                    off,
                })?;
            } else {
                return Ok(off);
            }
        }
    }

    /// Skip an immediate value, return offset of next value.
    fn skip(&self, off: Offset) -> Result<Offset> {
        let (high, low) = self.first_byte(off);
        let off: Offset = match high {
            0 => off + 1,
            1 | 2 => {
                let (_, n_bytes) = self.u64_with_low(off, low)?;
                off + 1 + n_bytes
            }
            3 => {
                if low == 0 {
                    off + 5
                } else {
                    off + 9
                }
            }
            4 | 5 => {
                let (len, n_bytes) = self.u64_with_low(off, low)?;
                if len > u32::MAX as u64 {
                    return Err(Error {
                        msg: "length overflow",
                        off,
                    });
                }
                off + 1 + n_bytes + len as Offset
            }
            6 | 7 | 8 => {
                return Err(Error {
                    msg: "cannot skip over array/dict/tag",
                    off,
                })
            }

            9 | 13 | 14 => {
                return Err(Error {
                    msg: "tag is reserved",
                    off,
                })
            }
            10 => {
                let (_, n_bytes) = self.u64_with_low(off, low)?;
                off + 1 + n_bytes
            }
            11 | 12 => {
                return Err(Error {
                    msg: "cannot skip over constructor",
                    off,
                })
            }
            15 => {
                let (_, n_bytes) = self.u64_with_low(off, low)?;
                off + 1 + n_bytes
            }
            _ => {
                unreachable!()
            }
        };
        Ok(off)
    }

    /// Get an integer.
    pub fn get_i64(&self, mut off: Offset) -> Result<i64> {
        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);
        if high == 1 {
            let (x, _) = self.u64_with_low(off, low)?;
            if x > i64::MAX as u64 {
                return Err(Error {
                    msg: "i64 overflow",
                    off,
                });
            }
            Ok(x as i64)
        } else if high == 2 {
            // negative int
            let (x, _) = self.u64_with_low(off, low)?;
            if x > i64::MAX as u64 {
                return Err(Error {
                    msg: "i64 overflow",
                    off,
                });
            }
            Ok(-(x as i64) - 1)
        } else {
            Err(Error {
                msg: "expected integer",
                off,
            })
        }
    }

    pub fn get_bool(&self, mut off: Offset) -> Result<bool> {
        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);
        match (high, low) {
            (0, 0) => Ok(false),
            (0, 1) => Ok(true),
            _ => Err(Error {
                msg: "expected integer",
                off,
            }),
        }
    }

    pub fn get_null(&self, mut off: Offset) -> Result<()> {
        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);
        match (high, low) {
            (0, 2) => Ok(()),
            _ => Err(Error {
                msg: "expected null",
                off,
            }),
        }
    }

    pub fn get_float(&self, mut off: Offset) -> Result<f64> {
        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);
        let off1 = (off + 1) as usize;
        match (high, low) {
            (3, 0) => {
                let arr: [u8; 4] = self.bs[off1..off1 + 4].try_into().unwrap();
                let u: u32 = u32::from_le_bytes(arr);
                let f = f32::from_bits(u);
                Ok(f as f64)
            }
            (3, 1) => {
                let arr: [u8; 8] = self.bs[off1..off1 + 8].try_into().unwrap();
                let u: u64 = u64::from_le_bytes(arr);
                let f = f64::from_bits(u);
                Ok(f)
            }
            _ => Err(Error {
                msg: "expected float",
                off,
            }),
        }
    }

    pub fn get_str(&self, mut off: Offset) -> Result<&str> {
        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);
        if high == 4 {
            let (len, n_bytes) = self.u64_with_low(off, low)?;
            off = off + 1 + n_bytes;
            std::str::from_utf8(&self.bs[off as usize..(off as usize + len as usize)]).map_err(
                |_| Error {
                    msg: "overflow in string",
                    off,
                },
            )
        } else {
            Err(Error {
                msg: "expected float",
                off,
            })
        }
    }

    // TODO: bytes

    /// Read an array of offsets into `res`
    pub fn get_array(&self, mut off: Offset, res: &mut Vec<Offset>) -> Result<()> {
        res.clear();

        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);

        if high == 6 {
            let (len, n_bytes) = self.u64_with_low(off, low)?;
            off = off + 1 + n_bytes;

            for _ in 0..len {
                res.push(off);
                off = self.skip(off)?;
            }
            Ok(())
        } else {
            Err(Error {
                msg: "expected array",
                off,
            })
        }
    }

    /// Read a dictionary of offsets into `res`
    pub fn get_dict(&self, mut off: Offset, res: &mut Vec<(Offset, Offset)>) -> Result<()> {
        res.clear();

        off = self.deref(off)?;
        let (high, low) = self.first_byte(off);

        if high == 7 {
            let (len, n_bytes) = self.u64_with_low(off, low)?;
            off = off + 1 + n_bytes;

            for _ in 0..len {
                let k = off;
                off = self.skip(off)?;
                let v = off;
                off = self.skip(off)?;
                res.push((k, v));
            }
            Ok(())
        } else {
            Err(Error {
                msg: "expected dict",
                off,
            })
        }
    }

    // TODO: tag
    // TODO: cstor
}

