use std::marker::PhantomData;

use crate::deser::FromTwine;

use anyhow::Result;
use bumpalo::Bump;
use num_bigint::{BigInt, BigUint};
use num_rational::BigRational as Rational;
use twine_data::shallow_value::ShallowValue;
use twine_data::{types::Offset, Decoder, Immediate};

/// Used for type-erasing aliases
pub struct Alias<T, Raw> {
    alias: Raw,
    phantom: PhantomData<T>,
}

impl<T, Raw> std::ops::Deref for Alias<T, Raw> {
    type Target = Raw;

    fn deref(&self) -> &Self::Target {
        &self.alias
    }
}

// data we ignore upon deserialization.
#[derive(Clone, Copy, Debug)]
pub struct Ignored;

impl<'a> FromTwine<'a> for Ignored {
    fn read(_d: &Decoder<'a>, _bump: &'a Bump, _off: Offset) -> Result<Self> {
        Ok(Self)
    }
}

#[derive(Debug, Clone)]
pub enum Void {}

impl<'a> FromTwine<'a> for Void {
    fn read(
        _d: &twine_data::Decoder<'a>,
        _bump: &'a bumpalo::Bump,
        _off: twine_data::types::Offset,
    ) -> anyhow::Result<Self> {
        unreachable!()
    }
}

#[derive(Debug, Clone)]
pub struct Chash<'a>(pub &'a [u8]);

impl<'a> FromTwine<'a> for Chash<'a> {
    fn read(d: &twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Chash<'a>> {
        let off = crate::deser::deref_tag(d, off)?;
        let bs = d.get_bytes(off)?;
        let res = bump.alloc_slice_copy(bs);
        Ok(Chash(res))
    }
}

// BigInt / Rational decoding
// --------------------------
// OCaml's `Util_twine.Z.to_twine` encodes a `Z.t` as a twine blob (high=5):
// the bytes are `Z.to_bits ((|x| << 1) | sign_bit)`, i.e. little-endian
// unsigned magnitude with the sign stored in the low bit. The generator
// (`gen_rust.ml`) also maps OCaml `int` to Rust `BigInt`, and those values
// arrive as immediate twine ints (high=1/2). So both wire forms must be
// accepted here.

impl<'a> FromTwine<'a> for BigInt {
    fn read(d: &Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = crate::deser::deref_tag(d, off)?;
        match d.get_shallow_value(off)? {
            ShallowValue::Imm(Immediate::Int64(i)) => Ok(BigInt::from(i)),
            ShallowValue::Imm(Immediate::Bytes(bytes)) => {
                let n = BigUint::from_bytes_le(bytes);
                let is_neg = !bytes.is_empty() && (bytes[0] & 1) == 1;
                let mag = BigInt::from(n >> 1);
                Ok(if is_neg { -mag } else { mag })
            }
            _ => anyhow::bail!("expected integer or bytes for BigInt at offset={off}"),
        }
    }
}

impl<'a> FromTwine<'a> for Rational {
    fn read(d: &Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = crate::deser::deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        anyhow::ensure!(offsets.len() == 2, "expected 2-element array for rational");
        let num = BigInt::read(d, bump, offsets[0])?;
        let denom = BigInt::read(d, bump, offsets[1])?;
        Ok(Rational::new(num, denom))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use num_bigint::Sign;
    use std::str::FromStr;
    use twine_data::Encoder;

    fn decode_bigint(buf: &[u8]) -> BigInt {
        let dec = Decoder::new(buf).unwrap();
        let off = dec.entrypoint().unwrap();
        BigInt::read(&dec, &Bump::new(), off).unwrap()
    }

    // Wrap the encoded value with an entrypoint trailer so `Decoder::new`
    // can find it. The `Pointer` keeps the value byte-exact at its original
    // offset, which matters for `blob_zero_is_one_byte_0x50` below.
    fn encode_one(
        write: impl FnOnce(&mut Encoder<&mut Vec<u8>>) -> twine_data::types::Offset,
    ) -> Vec<u8> {
        let mut buf = vec![];
        let mut enc = Encoder::new(&mut buf);
        let off = write(&mut enc);
        enc.finalize(Immediate::Pointer(off)).unwrap();
        buf
    }

    fn as_immediate_int(x: i64) -> Vec<u8> {
        encode_one(|enc| enc.write_i64(x).unwrap())
    }

    // OCaml `Util_twine.Z.to_twine`: bytes are
    //   `Z.to_bits ((|x| << 1) | sign_bit)` — LE magnitude, sign in low bit.
    fn as_blob(x: &BigInt) -> Vec<u8> {
        let is_neg = x.sign() == Sign::Minus;
        let n: BigUint = (x.magnitude().clone() << 1) | BigUint::from(is_neg as u8);
        let bytes = if n == BigUint::from(0u32) { vec![] } else { n.to_bytes_le() };
        encode_one(|enc| enc.write_bytes(&bytes).unwrap())
    }

    // Immediate-int wire form (high=1/2). Reaches `BigInt` because
    // `gen_rust.ml` maps OCaml `int` → Rust `BigInt`. `i64::MIN` is excluded
    // because twine-data's `write_i64` overflows on it; `as_blob` covers
    // values past i64 range anyway.
    #[test]
    fn from_immediate_int() {
        for x in [0i64, 1, -1, 42, -7, i64::MAX, i64::MIN + 1] {
            assert_eq!(decode_bigint(&as_immediate_int(x)), BigInt::from(x), "{x}");
        }
    }

    // Blob wire form (high=5) — the Util_twine.Z convention.
    #[test]
    fn from_blob() {
        let huge = BigInt::from_str(
            "123456789012345678901234567890123456789012345678901234567890",
        )
        .unwrap();
        let cases: Vec<BigInt> = vec![
            BigInt::from(0),
            BigInt::from(1),
            BigInt::from(-1),
            BigInt::from(12345),
            BigInt::from(-12345),
            BigInt::from(1) << 65u32,
            -(BigInt::from(1) << 100u32),
            huge.clone(),
            -huge,
        ];
        for x in cases {
            assert_eq!(decode_bigint(&as_blob(&x)), x, "{x}");
        }
    }

    // Regression for the original failing artifact: `Const_z(0)` is a single
    // `0x50` byte (high=5 bytes, low=0 length-0) — exactly the byte at
    // offset 0x1acf in the captured `po_res_art.zip`.
    #[test]
    fn blob_zero_is_one_byte_0x50() {
        let buf = as_blob(&BigInt::from(0));
        assert!(buf.contains(&0x50), "expected 0x50 in {buf:?}");
    }
}
