OUTDIR=out

all: tsproto check build-dev build-release

lib/version.ts: ../core/API_TYPES_VERSION
	@echo "'use strict'; export const version: string = 'v$(file <$<)'" > $@

node_modules:
	@npm install

check: node_modules lib/version.ts
	@npm run check

build-dev: check lib/version.ts
	npm run build-dev

build-release: check lib/version.ts
	npm run build-release

clean:
	@rm -rf lib/version.ts
	@rm -rf $(OUTDIR)

NPM_ROOT=$(shell npm root)

tsproto: node_modules
	mkdir -p lib/proto
	protoc --plugin=${NPM_ROOT}/.bin/protoc-gen-ts_proto --ts_proto_out=lib/proto --proto_path=../proto ../proto/*.proto --ts_proto_opt=esModuleInterop=true --ts_proto_opt=importSuffix=.js

.PHONY: check build-dev build-release
