//! Values that rely on a bump allocator.

use super::{types::CstorIdx, types::Tag, Decoder, Error, Immediate, Result};
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
pub fn get_value<'a, 'tmp>(d: &'a Decoder<'a>, bump: &'tmp Bump) -> Result<Value<'a, 'tmp>> {
    todo!()
}
