
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
	FORCE_GENPROTO=true $(DUNE) build @genproto --auto-promote

genlib:
	#make genpython -C src/py/lib/ --debug
	@make -s genpython -C src/py/lib/
	@make -s genpython -C src/py/bindings/
	@make -s genrust -C src/rust/lib/ --debug
	#make genrust -C src/rust/

test-docker-4.14:
	docker build . -f dep/Dockerfile.4.14 --network=host

test-docker-4.12:
	docker build . -f dep/Dockerfile.4.12 --network=host

test-docker-5.2:
	docker build . -f dep/Dockerfile.5.2 --network=host

build-dev:
	$(DUNE) build @install @runtest $(DUNE_OPTS) --workspace=dune-workspace.dev

pull-rust-twine:
	git subtree pull --prefix src/rust/lib/twine/ twine-origin main

build-python:
	make -C src/py build

PYTHON_REPO_URL = https://europe-west1-python.pkg.dev/imandra-dev/imandrax-api/
publish-python: build-python
	@echo "uploading to $(PYTHON_REPO_URL)"
	twine upload --repository-url $(PYTHON_REPO_URL)  src/py/imandrax_api.whl

list-python-artifacts:
	gcloud artifacts packages list --location=europe-west1 --project=imandra-dev --repository=imandrax-api

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

