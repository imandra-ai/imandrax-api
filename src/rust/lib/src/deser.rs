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

#[cfg(test)]
mod tests {
    use super::*;
    use from_twine_derive::FromTwine;
    use twine_data::types::VariantIdx;
    use twine_data::Immediate::*;
    use twine_data::{Decoder, Encoder};

    /// Helper: encode via callback, finalize, then decode with FromTwine.
    fn encode(
        f: impl FnOnce(&mut Encoder<&mut Vec<u8>>) -> twine_data::Immediate<'static>,
    ) -> Vec<u8> {
        let mut buf: Vec<u8> = vec![];
        let mut enc = Encoder::new(&mut buf);
        let root = f(&mut enc);
        enc.finalize(root).unwrap();
        buf
    }

    fn decode<'a, T: FromTwine<'a>>(buf: &'a [u8], bump: &'a Bump) -> T {
        let dec = Decoder::new(buf).unwrap();
        let off = dec.entrypoint().unwrap();
        T::read(&dec, bump, off).unwrap()
    }

    // ========== Primitive blanket impls ==========

    #[test]
    fn test_bool() {
        let buf = encode(|enc| {
            let off = enc.write_bool(true).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<bool>(&buf, &bump), true);
    }

    #[test]
    fn test_i64() {
        let buf = encode(|enc| {
            let off = enc.write_i64(-123).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<i64>(&buf, &bump), -123);
    }

    #[test]
    fn test_f64() {
        let buf = encode(|enc| {
            let off = enc.write_f64(3.14).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert!((decode::<f64>(&buf, &bump) - 3.14).abs() < 1e-10);
    }

    #[test]
    fn test_unit() {
        let buf = encode(|enc| {
            let off = enc.write_null().unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<()>(&buf, &bump), ());
    }

    #[test]
    fn test_str() {
        let buf = encode(|enc| {
            let off = enc.write_string("hello").unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<&str>(&buf, &bump), "hello");
    }

    #[test]
    fn test_bytes() {
        let buf = encode(|enc| {
            let off = enc.write_bytes(&[0xDE, 0xAD]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<&[u8]>(&buf, &bump), &[0xDE, 0xAD]);
    }

    // ========== Container impls ==========

    #[test]
    fn test_option_some() {
        let buf = encode(|enc| {
            let off = enc.write_i64(42).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<Option<i64>>(&buf, &bump), Some(42));
    }

    #[test]
    fn test_option_none() {
        let buf = encode(|enc| {
            let off = enc.write_null().unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<Option<i64>>(&buf, &bump), None);
    }

    #[test]
    fn test_slice() {
        let buf = encode(|enc| {
            let a = enc.write_i64(1).unwrap();
            let b = enc.write_i64(2).unwrap();
            let c = enc.write_i64(3).unwrap();
            let off = enc
                .write_array(&[Pointer(a), Pointer(b), Pointer(c)])
                .unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<&[i64]>(&buf, &bump), &[1, 2, 3]);
    }

    #[test]
    fn test_tuple2() {
        let buf = encode(|enc| {
            let a = enc.write_i64(10).unwrap();
            let b = enc.write_bool(true).unwrap();
            let off = enc.write_array(&[Pointer(a), Pointer(b)]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<(i64, bool)>(&buf, &bump), (10, true));
    }

    #[test]
    fn test_result_ok() {
        let buf = encode(|enc| {
            let inner = enc.write_i64(99).unwrap();
            enc.write_variant(VariantIdx(0), &[Pointer(inner)])
                .unwrap()
        });
        let bump = Bump::new();
        assert_eq!(decode::<Result<i64, bool>>(&buf, &bump), Ok(99));
    }

    #[test]
    fn test_result_err() {
        let buf = encode(|enc| {
            let inner = enc.write_bool(false).unwrap();
            enc.write_variant(VariantIdx(1), &[Pointer(inner)])
                .unwrap()
        });
        let bump = Bump::new();
        assert_eq!(decode::<Result<i64, bool>>(&buf, &bump), Err(false));
    }

    // ========== Derive macro: structs ==========

    #[derive(Debug, PartialEq, FromTwine)]
    struct Pair<'a> {
        x: i64,
        name: &'a str,
    }

    #[test]
    fn test_struct_multi_field() {
        let buf = encode(|enc| {
            let f0 = enc.write_i64(42).unwrap();
            let f1 = enc.write_string("alice").unwrap();
            let off = enc.write_array(&[Pointer(f0), Pointer(f1)]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let val = decode::<Pair>(&buf, &bump);
        assert_eq!(val.x, 42);
        assert_eq!(val.name, "alice");
    }

    #[derive(Debug, PartialEq, FromTwine)]
    struct Wrapper {
        inner: i64,
    }

    #[test]
    fn test_struct_single_field_transparent() {
        let buf = encode(|enc| {
            let off = enc.write_i64(7).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        assert_eq!(decode::<Wrapper>(&buf, &bump).inner, 7);
    }

    #[derive(Debug, PartialEq, FromTwine)]
    struct Unit;

    #[test]
    fn test_struct_unit() {
        let buf = encode(|enc| {
            let off = enc.write_null().unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let _val = decode::<Unit>(&buf, &bump);
    }

    #[derive(Debug, PartialEq, FromTwine)]
    struct WithPhantom<'a, V> {
        value: i64,
        _phantom: std::marker::PhantomData<V>,
        name: &'a str,
    }

    #[test]
    fn test_struct_phantom_data_skipped() {
        let buf = encode(|enc| {
            let f0 = enc.write_i64(10).unwrap();
            let f1 = enc.write_string("bob").unwrap();
            let off = enc.write_array(&[Pointer(f0), Pointer(f1)]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let val = decode::<WithPhantom<bool>>(&buf, &bump);
        assert_eq!(val.value, 10);
        assert_eq!(val.name, "bob");
    }

    // ========== Derive macro: enums ==========

    #[derive(Debug, PartialEq, FromTwine)]
    enum Color {
        Red,
        Green,
        Blue,
    }

    #[test]
    fn test_enum_nullary() {
        let buf = encode(|enc| enc.write_variant(VariantIdx(1), &[]).unwrap());
        let bump = Bump::new();
        assert_eq!(decode::<Color>(&buf, &bump), Color::Green);
    }

    #[derive(Debug, PartialEq, FromTwine)]
    enum Shape<'a> {
        Circle(f64),
        Rect(f64, f64),
        Named { label: &'a str, sides: i64 },
    }

    #[test]
    fn test_enum_single_arg() {
        let buf = encode(|enc| {
            let r = enc.write_f64(2.5).unwrap();
            enc.write_variant(VariantIdx(0), &[Pointer(r)]).unwrap()
        });
        let bump = Bump::new();
        assert_eq!(decode::<Shape>(&buf, &bump), Shape::Circle(2.5));
    }

    #[test]
    fn test_enum_multi_arg() {
        let buf = encode(|enc| {
            let w = enc.write_f64(3.0).unwrap();
            let h = enc.write_f64(4.0).unwrap();
            enc.write_variant(VariantIdx(1), &[Pointer(w), Pointer(h)])
                .unwrap()
        });
        let bump = Bump::new();
        assert_eq!(decode::<Shape>(&buf, &bump), Shape::Rect(3.0, 4.0));
    }

    #[test]
    fn test_enum_struct_variant() {
        let buf = encode(|enc| {
            let label = enc.write_string("pentagon").unwrap();
            let sides = enc.write_i64(5).unwrap();
            enc.write_variant(VariantIdx(2), &[Pointer(label), Pointer(sides)])
                .unwrap()
        });
        let bump = Bump::new();
        assert_eq!(
            decode::<Shape>(&buf, &bump),
            Shape::Named {
                label: "pentagon",
                sides: 5
            }
        );
    }

    // ========== Nested / compound types ==========

    #[derive(Debug, PartialEq, FromTwine)]
    struct Nested<'a> {
        pair: &'a Pair<'a>,
        flag: bool,
    }

    #[test]
    fn test_nested_struct() {
        let buf = encode(|enc| {
            let px = enc.write_i64(1).unwrap();
            let pn = enc.write_string("inner").unwrap();
            let pair_off = enc.write_array(&[Pointer(px), Pointer(pn)]).unwrap();
            let flag = enc.write_bool(true).unwrap();
            let off = enc
                .write_array(&[Pointer(pair_off), Pointer(flag)])
                .unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let val = decode::<Nested>(&buf, &bump);
        assert_eq!(val.pair.x, 1);
        assert_eq!(val.pair.name, "inner");
        assert!(val.flag);
    }

    #[test]
    fn test_slice_of_structs() {
        let buf = encode(|enc| {
            let a = enc.write_i64(10).unwrap();
            let b = enc.write_i64(20).unwrap();
            let off = enc.write_array(&[Pointer(a), Pointer(b)]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let val = decode::<&[Wrapper]>(&buf, &bump);
        assert_eq!(val.len(), 2);
        assert_eq!(val[0], Wrapper { inner: 10 });
        assert_eq!(val[1], Wrapper { inner: 20 });
    }

    #[test]
    fn test_option_of_struct() {
        let buf = encode(|enc| {
            let f0 = enc.write_i64(5).unwrap();
            let f1 = enc.write_string("opt").unwrap();
            let off = enc.write_array(&[Pointer(f0), Pointer(f1)]).unwrap();
            Pointer(off)
        });
        let bump = Bump::new();
        let pair = decode::<Option<Pair>>(&buf, &bump).unwrap();
        assert_eq!(pair.x, 5);
        assert_eq!(pair.name, "opt");
    }
}
