use std::marker::PhantomData;

use crate::deser::FromTwine;

use anyhow::Result;
use bumpalo::Bump;
use num_bigint::BigInt;
use num_rational::BigRational as Rational;
use twine_data::{types::Offset, Decoder};

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

impl<'a> FromTwine<'a> for BigInt {
    fn read(d: &Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = crate::deser::deref_tag(d, off)?;
        let i = d.get_i64(off)?;
        Ok(BigInt::from(i))
    }
}

impl<'a> FromTwine<'a> for Rational {
    fn read(d: &Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = crate::deser::deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        anyhow::ensure!(offsets.len() == 2, "expected 2-element array for rational");
        let num = BigInt::from(d.get_i64(offsets[0])?);
        let denom = BigInt::from(d.get_i64(offsets[1])?);
        Ok(Rational::new(num, denom))
    }
}
