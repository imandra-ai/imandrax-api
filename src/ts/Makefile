
API_TYPES_VERSION=$(shell cat ../core/API_TYPES_VERSION)
api_types_version.ts:
	@echo "'use strict'; const api_types_version: string = 'v$(API_TYPES_VERSION)'" > $@

check:
	tsc --noEmit $(wildcard *.ts)

.PHONY: check api_types_version.ts
