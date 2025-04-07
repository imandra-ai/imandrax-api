
API_TYPES_VERSION=$(shell cat ../core/API_TYPES_VERSION)
api_types_version.ts:
	@echo "'use strict'; const api_types_version: string = 'v$(API_TYPES_VERSION)'" > $@

check:
	@tsc --noEmit

OUTDIR=dist
build-dev: check
	@mkdir -p $(OUTDIR)/dev/
	esbuild $(wildcard lib/*.ts) --outdir=$(OUTDIR)/dev/ --sourcemap

build-release: check
	@mkdir -p $(OUTDIR)/release/
	#esbuild $(wildcard lib/*.ts) --outdir=$(OUTDIR)/release --bundle --minify --sourcemap
	esbuild lib/types.ts --outfile=$(OUTDIR)/release/imandrax_api.js --bundle --minify --sourcemap

clean:
	@rm -r $(OUTDIR)

.PHONY: check api_types_version.ts
