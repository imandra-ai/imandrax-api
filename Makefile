
debug:
	cargo build

release:
	cargo build --release


FEATURES?=bumpalo
test:
	#cargo test --features $(FEATURES)
	cargo insta test --features $(FEATURES)

test-insta-review:
	cargo insta review

clean:
	cargo clean
