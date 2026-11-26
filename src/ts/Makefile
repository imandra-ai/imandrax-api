
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

format-check: node_modules
	npm run format:check

# integration tests against the ImandraX server; needs API key
test-integration: node_modules lib/version.ts
	npm run test:integration

# API reference as Markdown, in docs/api
docs: node_modules lib/version.ts
	npm run docs

# The same reference as a local HTML site, in docs/html (not shipped)
docs-html: node_modules lib/version.ts
	npm run docs:html

publish-dry-run: node_modules lib/version.ts
	npm publish --dry-run

clean:
	@rm -f lib/version.ts
	@rm -rf dist docs/api docs/html

NPM_ROOT=$(shell npm root)

tsproto: node_modules
	mkdir -p lib/raw/proto
	protoc --plugin=${NPM_ROOT}/.bin/protoc-gen-ts_proto --ts_proto_out=lib/raw/proto --proto_path=../proto ../proto/*.proto --ts_proto_opt=esModuleInterop=true --ts_proto_opt=importSuffix=.js

.PHONY: all check build test format-check test-integration docs docs-html publish-dry-run clean tsproto
