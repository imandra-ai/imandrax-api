use anyhow::Result;
use insta::assert_debug_snapshot; // see: https://docs.rs/insta/latest/insta/
use std::fs;

#[test]
fn test_pubsub() -> Result<()> {
    let data = fs::read("tests/test_data/pubsub.twine")?;
    assert_debug_snapshot!(data.len());
    let d = twine::Decoder::new(&data)?;
    let bump = bumpalo::Bump::new();
    //println!("data:");
    //println!("{}", pretty_hex::pretty_hex(&data));
    let v = twine::value::get_value_from_entrypoint(&d, &bump)?;
    assert_debug_snapshot!(v);
    Ok(())
}

#[test]
fn test_typereg() -> Result<()> {
    let data = fs::read("tests/test_data/typereg.twine")?;
    assert_debug_snapshot!(data.len());
    let d = twine::Decoder::new(&data)?;
    let bump = bumpalo::Bump::new();
    //println!("data:");
    //println!("{}", pretty_hex::pretty_hex(&data));
    let v = twine::value::get_value_from_entrypoint(&d, &bump)?;
    assert_debug_snapshot!(v);
    Ok(())
}
