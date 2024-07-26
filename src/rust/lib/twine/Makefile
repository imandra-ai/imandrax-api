
debug:
	cargo build

release:
	cargo build --release


build-ci: debug

TEST_FEATURES?=bumpalo

test-ci:
	cargo test --features $(TEST_FEATURES)

test:
	cargo insta test --features $(TEST_FEATURES)

test-insta-review:
	cargo insta review

clean:
	cargo clean
