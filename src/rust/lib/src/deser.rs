use anyhow::Result;
use bumpalo::Bump;
use num_bigint::BigInt;
use num_rational::BigRational as Rational;
use twine::{types::Offset, Immediate};

use crate::Chash;

/// Trait for reading from twine.
pub trait FromTwine<'a>: Sized + 'a {
    fn read(d: &'_ twine::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self>;
}

impl<'a, T> FromTwine<'a> for Option<T>
where
    T: FromTwine<'a>,
{
    fn read(d: &'_ twine::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        use twine::shallow_value::ShallowValue::*;
        let r = match d.get_shallow_value(off)? {
            Imm(Immediate::Null) => None,
            _ => {
                let x = <T as FromTwine>::read(d, bump, off)?;
                Some(x)
            }
        };
        Ok(r)
    }
}

impl<'a, T> FromTwine<'a> for Vec<T>
where
    T: FromTwine<'a>,
{
    fn read(d: &'_ twine::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        let res = offsets
            .into_iter()
            .map(|off| <T as FromTwine>::read(d, bump, off))
            .collect::<Result<Vec<T>>>()?;
        Ok(res)
    }
}

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
    }
}
impl<'a> FromTwine<'a> for Rational {}
