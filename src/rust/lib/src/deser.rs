use anyhow::Result;
use bumpalo::Bump;
use twine_data::{types::Offset, Immediate};

/// Resolve an offset past any Tag wrappers to the underlying value.
pub fn deref_tag(
    d: &twine_data::Decoder<'_>,
    mut off: Offset,
) -> twine_data::types::Result<Offset> {
    loop {
        match d.get_shallow_value(off)? {
            twine_data::shallow_value::ShallowValue::Tag(_, inner) => off = inner,
            _ => return Ok(off),
        }
    }
}

/// Trait for reading from twine.
pub trait FromTwine<'a>: Sized + 'a {
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self>;
}

// Blanket impls for primitive types
// ====================

impl<'a> FromTwine<'a> for bool {
    fn read(d: &'_ twine_data::Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        Ok(d.get_bool(off)?)
    }
}

impl<'a> FromTwine<'a> for f64 {
    fn read(d: &'_ twine_data::Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        Ok(d.get_float(off)?)
    }
}

impl<'a> FromTwine<'a> for i64 {
    fn read(d: &'_ twine_data::Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        Ok(d.get_i64(off)?)
    }
}

impl<'a> FromTwine<'a> for usize {
    fn read(d: &'_ twine_data::Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let i = d.get_i64(off)?;
        Ok(i as usize)
    }
}

impl<'a> FromTwine<'a> for () {
    fn read(d: &'_ twine_data::Decoder<'a>, _bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        d.get_null(off)?;
        Ok(())
    }
}

// Blanket impls for reference types (used by derive macro)
// ====================

impl<'a> FromTwine<'a> for &'a str {
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let s = d.get_str(off)?;
        Ok(bump.alloc_str(s))
    }
}

impl<'a> FromTwine<'a> for &'a [u8] {
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let bs = d.get_bytes(off)?;
        Ok(bump.alloc_slice_copy(bs))
    }
}

impl<'a, T> FromTwine<'a> for &'a T
where
    T: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let val = T::read(d, bump, off)?;
        Ok(bump.alloc(val))
    }
}

impl<'a, T> FromTwine<'a> for &'a [T]
where
    T: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        let items: Vec<T> = offsets
            .into_iter()
            .map(|o| T::read(d, bump, o))
            .collect::<Result<_>>()?;
        Ok(bump.alloc_slice_fill_iter(items))
    }
}

// Tuple impls
// ====================

impl<'a, A, B> FromTwine<'a> for (A, B)
where
    A: FromTwine<'a>,
    B: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        anyhow::ensure!(
            offsets.len() == 2,
            "expected 2-tuple, got {}",
            offsets.len()
        );
        Ok((A::read(d, bump, offsets[0])?, B::read(d, bump, offsets[1])?))
    }
}

impl<'a, A, B, C> FromTwine<'a> for (A, B, C)
where
    A: FromTwine<'a>,
    B: FromTwine<'a>,
    C: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        anyhow::ensure!(
            offsets.len() == 3,
            "expected 3-tuple, got {}",
            offsets.len()
        );
        Ok((
            A::read(d, bump, offsets[0])?,
            B::read(d, bump, offsets[1])?,
            C::read(d, bump, offsets[2])?,
        ))
    }
}

// Result impl (twine encodes Result as cstor: 0=Ok, 1=Err)
// ====================

impl<'a, T, E> FromTwine<'a> for core::result::Result<T, E>
where
    T: FromTwine<'a>,
    E: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let mut args = vec![];
        let idx = d.get_variant(off, &mut args)?;
        match idx.0 {
            0 => {
                anyhow::ensure!(args.len() == 1, "Result::Ok expected 1 arg");
                Ok(Ok(T::read(d, bump, args[0])?))
            }
            1 => {
                anyhow::ensure!(args.len() == 1, "Result::Err expected 1 arg");
                Ok(Err(E::read(d, bump, args[0])?))
            }
            other => anyhow::bail!("Result: unknown constructor index {}", other),
        }
    }
}

// Container impls
// ====================

impl<'a, T> FromTwine<'a> for Option<T>
where
    T: FromTwine<'a>,
{
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        use twine_data::shallow_value::ShallowValue::*;
        let off = deref_tag(d, off)?;
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
    fn read(d: &'_ twine_data::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self> {
        let off = deref_tag(d, off)?;
        let mut offsets = vec![];
        d.get_array(off, &mut offsets)?;
        let res = offsets
            .into_iter()
            .map(|off| <T as FromTwine>::read(d, bump, off))
            .collect::<Result<Vec<T>>>()?;
        Ok(res)
    }
}
