
all: tsproto check build

lib/version.ts: ../core/API_TYPES_VERSION
	@echo "export const version: string = 'v$$(cat $<)'" > $@

node_modules:
	@npm install

check: node_modules lib/version.ts
	@npm run check

build: check
	npm run build

test: node_modules lib/version.ts
	npm test

# integration tests against the ImandraX server; needs IMANDRAX_API_KEY
test-integration: node_modules lib/version.ts
	npm run test:integration

clean:
	@rm -f lib/version.ts
	@rm -rf dist

NPM_ROOT=$(shell npm root)

tsproto: node_modules
	mkdir -p lib/raw/proto
	protoc --plugin=${NPM_ROOT}/.bin/protoc-gen-ts_proto --ts_proto_out=lib/raw/proto --proto_path=../proto ../proto/*.proto --ts_proto_opt=esModuleInterop=true --ts_proto_opt=importSuffix=.js

.PHONY: all check build test test-integration clean tsproto
