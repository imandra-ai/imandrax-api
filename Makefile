
DUNE_OPTS?=
DUNE?=opam exec -- dune

build:
	$(DUNE) build @install $(DUNE_OPTS)

clean:
	$(DUNE) clean

test:
	$(DUNE) runtest $(DUNE_OPTS)

test-autopromote:
	$(DUNE) runtest $(DUNE_OPTS) --auto-promote

doc:
	$(DUNE) build $(DUNE_OPTS) @doc

format:
	$(DUNE) build @fmt --auto-promote

check-format:
	$(DUNE) build $(DUNE_OPTS) @fmt

genproto:
	FORCE_GENPROTO=true $(DUNE) build @genproto --auto-promote

genlib:
	#make genpython -C src/py/lib/ --debug
	@make -s genpython -C src/py/lib/
	@make -s genpython -C src/py/bindings/
	@make -s genrust -C src/rust/lib/ --debug
	#make genrust -C src/rust/

test-docker-4.14:
	docker build . -f dep/Dockerfile.4.14 --network=host

test-docker-5.2:
	docker build . -f dep/Dockerfile.5.2 --network=host

build-dev:
	$(DUNE) build @install @runtest $(DUNE_OPTS) --workspace=dune-workspace.dev

pull-rust-twine:
	git subtree pull --prefix src/rust/lib/twine/ twine-origin main

build-python:
	make -C src/py build

publish-python:
	make -C src/py publish

list-python-artifacts:
	make -C src/py list-artifacts

lint:
	$(DUNE) build @lint --auto-promote

WATCH?= @check @runtest
watch:
	$(DUNE) build $(DUNE_OPTS) -w $(WATCH)

## handle vendored deps

update-submodules:
	git submodule update --init

opam-pin-submodules: update-submodules

opam-install-deps: update-submodules
	opam install . --deps-only

opam-install-test-deps: update-submodules
	opam install . --deps-only -t

