# Differential test of twine decoders, one target per decoder.
# TWINE_DIFF_COUNT, TWINE_DIFF_CORRUPT and QCHECK_SEED pass through from the environment

DUNE ?= opam exec -- dune
UV ?= uv

HERE := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ROOT := $(abspath $(HERE)/../..)
PY_PROJECT := $(ROOT)/src/py

.PHONY: test test-py

test: test-py

test-py:
	$(UV) sync --project '$(PY_PROJECT)'
	cd '$(ROOT)' && \
	  TWINE_DIFF_DECODER="$(UV) run --project '$(PY_PROJECT)' python '$(HERE)/py_decoder.py'" \
	  $(DUNE) build @tests/twine-diff/twine-diff --force
