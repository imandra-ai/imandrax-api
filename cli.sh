#!/bin/sh
OPTS="--display=quiet"
exec dune exec $OPTS ./src/cli/imandrax_api_cli.exe -- $@
