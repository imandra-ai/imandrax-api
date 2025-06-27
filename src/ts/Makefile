
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

NPM_ROOT=$(shell npm root)

${NPM_ROOT}/.bin/protoc-gen-ts_proto:
	npm install ts-proto

tsproto: ${NPM_ROOT}/.bin/protoc-gen-ts_proto
	mkdir -p lib/proto
	protoc --plugin=${NPM_ROOT}/.bin/protoc-gen-ts_proto --ts_proto_out=lib/proto --proto_path=../proto ../proto/*.proto

.PHONY: check api_types_version.ts
