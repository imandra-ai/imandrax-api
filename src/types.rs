//! Base types

use std::fmt::{Debug, Display};

pub type Offset = u32;
pub type Tag = u32;

#[derive(Debug, Clone, Copy, Eq, PartialEq, Hash)]
pub struct CstorIdx(pub u32);

/// Immediate value, without nesting.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Immediate<'a> {
    Null,
    Bool(bool),
    Int64(i64),
    Float(f64),
    String(&'a str),
    Bytes(&'a [u8]),
    Pointer(Offset),
    Cstor0(u32),
}

#[derive(Debug, Clone, Copy)]
pub struct Error {
    pub msg: &'static str,
    /// Offset at which error occurred
    pub off: Offset,
}

pub type Result<T> = core::result::Result<T, Error>;

impl Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "twine error: {} at offset={}", self.msg, self.off)
    }
}

impl std::error::Error for Error {}
