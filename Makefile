
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
	$(DUNE) build $(DUNE_OPTS) @fmt --ignore-promoted-rules

genproto:
	FORCE_GENPROTO=true $(DUNE) build @genproto --auto-promote

genpython:
	@make -s	install-go-protobuf-plugin -C src/py
	#make genpython -C src/py/lib/ --debug
	@make -s genpython -C src/py/lib/
	@make -s genpython -C src/py/bindings/

genrust:
	@make -s genrust -C src/rust/lib
	# @make -s genrust -C src/rust/lib/ --debug

gents:
	@make -s gents -C src/ts/lib/
	@make -s tsproto -C src/ts

build-ts-dev: gents
	@make -C src/ts build-dev

build-ts-release: gents
	@make -C src/ts build-release

genlib: gents genpython genrust

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
	# Until there's a new release of `trace`, we need to pin it.
	opam pin https://github.com/c-cube/ocaml-trace.git -y -n

opam-install-deps: update-submodules
	opam install . --deps-only

opam-install-test-deps: update-submodules
	opam install . --deps-only -t

bump-api-version:
	@v="$(shell expr $$(cat src/core/API_TYPES_VERSION) + 1)"; \
	echo "bumping version to $$v"; \
	echo $$v > src/core/API_TYPES_VERSION; \
	echo "let version = \"v$$v"\" > src/core/version_.ml; \
    echo "api_types_version = 'v$$v'" > src/py/api_types_version.py; \
    sed "s/VERSION = \"0.[0-9.]*\"/VERSION = \"0.$$v\"/" -i src/py/setup.py; \
	sed "s/(version 0.[0-9.]*/(version 0.$$v/" -i dune-project; \
	sed "s/version: \"0.[0-9.]*/version: \"0.$$v/" -i *.opam
