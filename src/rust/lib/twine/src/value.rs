//! Values that rely on a bump allocator.

use crate::shallow_value::ShallowValue;

use super::{
    types::{CstorIdx, Offset, Tag},
    Decoder, Immediate, Result,
};
use bumpalo::Bump;

/// A value, potentially containing other values.
#[derive(Debug, Clone, Copy)]
pub enum Value<'a, 'tmp> {
    Imm(Immediate<'a>),
    Tag(Tag, &'tmp Value<'a, 'tmp>),
    Array(&'tmp [Value<'a, 'tmp>]),
    Dict(&'tmp [(Value<'a, 'tmp>, Value<'a, 'tmp>)]),
    Cstor(CstorIdx, &'tmp [Value<'a, 'tmp>]),
}

impl<'a, 'tmp> Default for Value<'a, 'tmp> {
    fn default() -> Self {
        Value::Imm(Default::default())
    }
}

/// Read a value
pub fn get_value<'a, 'tmp>(
    d: &'a Decoder<'a>,
    bump: &'tmp Bump,
    off: Offset,
) -> Result<Value<'a, 'tmp>> {
    use Value::*;

    let v: Value = match d.get_shallow_value(off)? {
        ShallowValue::Imm(v) => Imm(v),
        ShallowValue::Tag(tag, off) => {
            let v = bump.alloc(get_value(d, bump, off)?);
            Tag(tag, v)
        }
        ShallowValue::Array(arr) => {
            let n_items = arr.len();
            let args: &'tmp mut [Value] = bump.alloc_slice_fill_copy(n_items, Default::default());
            for (i, off) in arr.into_iter().enumerate() {
                let off = off?;
                args[i] = get_value(d, bump, off)?;
            }
            Array(args)
        }
        ShallowValue::Dict(dict) => {
            let n_items = dict.len();
            let pairs: &'tmp mut [(Value, Value)] =
                bump.alloc_slice_fill_copy(n_items, Default::default());
            for (i, pair) in dict.into_iter().enumerate() {
                let (k, v) = pair?;
                pairs[i] = (get_value(d, bump, k)?, get_value(d, bump, v)?);
            }
            Dict(pairs)
        }
        ShallowValue::Cstor(cstor_idx, args) => {
            let local: Vec<Offset> = args.into_iter().collect::<Result<Vec<_>>>()?;
            let args: &'tmp mut [Value] =
                bump.alloc_slice_fill_copy(local.len(), Default::default());
            for (i, off) in local.into_iter().enumerate() {
                args[i] = get_value(d, bump, off)?;
            }
            Cstor(cstor_idx, args)
        }
    };
    Ok(v)
}

/// Find the entrypoint and read a value from it.
pub fn get_value_from_entrypoint<'a, 'tmp>(
    d: &'a Decoder<'a>,
    bump: &'tmp Bump,
) -> Result<Value<'a, 'tmp>> {
    let off = d.entrypoint()?;
    get_value(d, bump, off)
}
