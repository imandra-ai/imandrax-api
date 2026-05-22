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
