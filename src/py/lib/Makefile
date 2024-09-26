
VERSION=$(shell cat ../../core/API_TYPES_VERSION)
version.py: 
	@echo "api_types_version = 'v$(VERSION)'" > $@

#OPTS=--dump -d
genpython: version.py
	@dune exec ../../lib/genbindings/genbindings.exe -- --lang=python -o __init__.py $(OPTS)
