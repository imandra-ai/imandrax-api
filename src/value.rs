//! Values that rely on a bump allocator.

use super::{
    types::{CstorIdx, Offset, Tag},
    Decoder, Error, Immediate, Result,
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

/// Read a value
pub fn get_value<'a, 'tmp>(
    d: &'a Decoder<'a>,
    bump: &'tmp Bump,
    off: Offset,
) -> Result<Value<'a, 'tmp>> {
    use Value::*;

    println!("get value at off={off:x}");
    let off = d.deref(off)?;
    let (high, low) = d.first_byte(off);
    let v: Value = match high {
        0 => {
            if low == 2 {
                Imm(Immediate::Null)
            } else if low == 0 {
                Imm(Immediate::Bool(false))
            } else if low == 1 {
                Imm(Immediate::Bool(true))
            } else {
                return Err(Error {
                    msg: "invalid value with high=0",
                    off,
                });
            }
        }
        1 | 2 => Imm(Immediate::Int64(d.get_i64(off)?)),
        3 => Imm(Immediate::Float(d.get_float(off)?)),
        4 => Imm(Immediate::String(d.get_str(off)?)),
        5 => Imm(Immediate::Bytes(d.get_bytes(off)?)),
        6 => {
            let mut offsets = vec![];
            d.get_array(off, &mut offsets)?;
            let res: &'tmp mut [Value] =
                bump.alloc_slice_fill_copy(offsets.len(), Imm(Immediate::Null));
            for (idx, off) in offsets.into_iter().enumerate() {
                res[idx] = get_value(d, bump, off)?;
            }
            Array(res)
        }
        7 => {
            let mut offsets_kv = vec![];
            d.get_dict(off, &mut offsets_kv)?;
            let res: &'tmp mut [(Value, Value)] = bump.alloc_slice_fill_copy(
                offsets_kv.len(),
                (Imm(Immediate::Null), Imm(Immediate::Null)),
            );
            for (idx, (k, v)) in offsets_kv.into_iter().enumerate() {
                res[idx] = (get_value(d, bump, k)?, get_value(d, bump, v)?);
            }
            Dict(res)
        }
        8 => {
            let (tag, off) = d.get_tag(off)?;
            let v = bump.alloc(get_value(d, bump, off)?);
            Tag(tag, v)
        }
        10 | 11 | 12 => {
            let mut offset_args = vec![];
            let cstor_idx = d.get_cstor(off, &mut offset_args)?;
            let args: &'tmp mut [Value] =
                bump.alloc_slice_fill_copy(offset_args.len(), Imm(Immediate::Null));
            for (idx, off) in offset_args.into_iter().enumerate() {
                args[idx] = get_value(d, bump, off)?;
            }
            Cstor(cstor_idx, args)
        }
        15 => unreachable!(), // we did deref
        _ => {
            return Err(Error {
                msg: "invalid value",
                off,
            })
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
