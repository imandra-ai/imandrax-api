
DUNE_OPTS?=
build:
	dune build @install $(DUNE_OPTS) --ignore-promoted-rules

clean:
	@dune clean

test:
	@dune runtest $(DUNE_OPTS) --ignore-promoted-rules

doc:
	@dune build $(DUNE_OPTS) @doc --ignore-promoted-rules

format:
	@dune build @fmt --auto-promote

genproto:
	@dune build @genproto

build-dev:
	dune build @install @runtest $(DUNE_OPTS) --workspace=dune-workspace.dev

WATCH?= @check @runtest
watch:
	dune build $(DUNE_OPTS) --ignore-promoted-rules -w $(WATCH)

## handle vendored deps

update-submodules:
	git submodule update --init

opam-pin-submodules: update-submodules
	opam pin -k path -y -n vendor/batrpc

opam-install-deps: update-submodules
	opam install . --deps-only

opam-install-test-deps: update-submodules
	opam install . --deps-only -t

