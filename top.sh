#!/bin/sh

DUNE_OPTS="--display=quiet"
exec dune exec $DUNE_OPTS src/toplevel/top.exe -- $@
