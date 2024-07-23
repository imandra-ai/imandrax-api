
DUNE_OPTS?=
DUNE?=opam exec -- dune

build:
	$(DUNE) build @install $(DUNE_OPTS) --ignore-promoted-rules

clean:
	$(DUNE) clean

test:
	$(DUNE) runtest $(DUNE_OPTS) --ignore-promoted-rules

doc:
	$(DUNE) build $(DUNE_OPTS) @doc --ignore-promoted-rules

format:
	$(DUNE) build @fmt --auto-promote --ignore-promoted-rules

check-format:
	$(DUNE) build $(DUNE_OPTS) @fmt --ignore-promoted-rules

genproto:
	FORCE_GENPROTO=true $(DUNE) build @genproto

genlib:
	#make genpython -C src/py/lib/ --debug
	@make -s genpython -C src/py/lib/
	@make -s genpython -C src/py/bindings/
	@make -s genrust -C src/rust/lib/ --debug
	#make genrust -C src/rust/

build-dev:
	$(DUNE) build @install @runtest $(DUNE_OPTS) --workspace=dune-workspace.dev

WATCH?= @check @runtest
watch:
	$(DUNE) build $(DUNE_OPTS) --ignore-promoted-rules -w $(WATCH)

## handle vendored deps

update-submodules:
	git submodule update --init

opam-pin-submodules-nodep:
	opam pin -k path -y -n vendor/batrpc

opam-pin-submodules: update-submodules opam-pin-submodules-nodep

opam-install-deps: update-submodules
	opam install . --deps-only

opam-install-test-deps: update-submodules
	opam install . --deps-only -t

