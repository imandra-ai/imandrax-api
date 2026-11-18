# Conformance test of twine decoders, one target per decoder.
# TWINE_CONFORMANCE_COUNT and QCHECK_SEED pass through from the environment

DUNE ?= opam exec -- dune
UV ?= uv
NODE ?= node

HERE := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ROOT := $(abspath $(HERE)/../..)
PY_PROJECT := $(ROOT)/src/py
TS_PROJECT := $(ROOT)/src/ts

EXE := $(ROOT)/_build/default/tests/twine-conformance/twine_conformance.exe

.PHONY: test test-py test-ts test-ocaml build

# run with make -k to test every decoder even if one fails
test: test-py test-ts test-ocaml

# the harness runs directly, not through the dune alias, so that a failure is
# reported by the harness alone
build:
	@cd '$(ROOT)' && $(DUNE) build ./tests/twine-conformance/twine_conformance.exe

test-py: build
	@$(UV) sync --quiet --project '$(PY_PROJECT)'
	@TWINE_CONFORMANCE_NAME=py \
	  TWINE_CONFORMANCE_DECODER="$(UV) run --project '$(PY_PROJECT)' python '$(HERE)/py_adapter.py'" \
	  '$(EXE)'

# runs on the built client, with Node's type stripping (Node >= 22.18)
test-ts: build
	@$(MAKE) --no-print-directory -C '$(TS_PROJECT)' build >/dev/null
	@TWINE_CONFORMANCE_NAME=ts \
	  TWINE_CONFORMANCE_DECODER="$(NODE) '$(HERE)/ts_adapter.ts'" \
	  '$(EXE)'

# imandrakit's own decoder, through the same protocol as any other
test-ocaml: build
	@TWINE_CONFORMANCE_NAME=ocaml \
	  TWINE_CONFORMANCE_DECODER="'$(EXE)' serve-ocaml" \
	  '$(EXE)'
