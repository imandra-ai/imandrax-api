#!/bin/sh
OPTS="--display=quiet"
exec dune exec $OPTS ./src/ml/cli/imandrax_api_cli.exe -- $@
