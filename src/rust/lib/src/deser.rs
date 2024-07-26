use anyhow::Result;
use bumpalo::Bump;
use twine::types::Offset;

/// Trait for reading from twine.
pub trait FromTwine<'a>: Sized + 'a {
    fn read(d: &'_ twine::Decoder<'a>, bump: &'a Bump, off: Offset) -> Result<Self>;
}
