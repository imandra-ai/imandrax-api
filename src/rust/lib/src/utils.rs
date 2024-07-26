use crate::deser::FromTwine;

use anyhow::bail;
use anyhow::Result;
use bumpalo::Bump;
use num_bigint::BigInt;
use num_rational::BigRational as Rational;
use twine::{types::Offset, Decoder};

// data we ignore upon deserialization.
#[derive(Clone, Copy, Debug)]
pub struct Ignored;

impl<'a> FromTwine<'a> for Ignored {
    fn read(d: &Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        Ok(Self)
    }
}

#[derive(Debug, Clone)]
pub enum Void {}

impl<'a> FromTwine<'a> for Void {
    fn read(
        d: &twine::Decoder<'a>,
        bump: &'a bumpalo::Bump,
        off: twine::types::Offset,
    ) -> anyhow::Result<Self> {
        unreachable!()
    }
}

#[derive(Debug, Clone)]
pub struct Chash<'a>(pub &'a [u8]);

impl<'a> FromTwine<'a> for Chash<'a> {
    fn read(d: &twine::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Chash<'a>> {
        let bs = d.get_bytes(off)?;
        let res = bump.alloc_slice_copy(bs);
        Ok(Chash(res))
    }
}

impl<'a> FromTwine<'a> for BigInt {
    fn read(d: &Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        todo!()
    \}
}
impl<'a> FromTwine<'a> for Rational {}
