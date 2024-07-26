
build:
	cargo build

#OPTS=--dump -d
genrust:
	@dune exec ../../lib/genbindings/genbindings.exe -- --lang=rust -o src/lib.rs $(OPTS)
