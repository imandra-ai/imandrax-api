# Conformance test of twine decoders, one target per decoder.
# TWINE_CONFORMANCE_COUNT and QCHECK_SEED pass through from the environment

DUNE ?= opam exec -- dune
UV ?= uv

HERE := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ROOT := $(abspath $(HERE)/../..)
PY_PROJECT := $(ROOT)/src/py

EXE := $(ROOT)/_build/default/tests/twine-conformance/twine_conformance.exe

.PHONY: test test-py test-ocaml

# run with make -k to test every decoder even if one fails
test: test-py test-ocaml

test-py:
	$(UV) sync --project '$(PY_PROJECT)'
	cd '$(ROOT)' && \
	  TWINE_CONFORMANCE_DECODER="$(UV) run --project '$(PY_PROJECT)' python '$(HERE)/py_adapter.py'" \
	  $(DUNE) build @tests/twine-conformance/twine-conformance --force

# imandrakit's own decoder, through the same protocol as any other
test-ocaml:
	cd '$(ROOT)' && \
	  $(DUNE) build ./tests/twine-conformance/twine_conformance.exe && \
	  TWINE_CONFORMANCE_DECODER="'$(EXE)' serve-ocaml" \
	  $(DUNE) build @tests/twine-conformance/twine-conformance --force
