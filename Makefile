
debug:
	cargo build

release:
	cargo build --release


FEATURES?=bumpalo
test:
	cargo test --features $(FEATURES)

test-insta-review: test
	cargo insta review

clean:
	cargo clean
