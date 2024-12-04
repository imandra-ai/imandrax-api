
VERSION=$(shell grep 'VERSION =' setup.py | sed 's/VERSION =//' | tr -d '"')
echo-version:
	@echo version: $(VERSION)

API_TYPES_VERSION=$(shell cat ../core/API_TYPES_VERSION)
api_types_version.py:
	@echo "api_types_version = 'v$(API_TYPES_VERSION)'" > $@

build: api_types_version.py
	python -m build --wheel

clean:
	rm -rf dist

PYTHON_REPO_URL = https://europe-west1-python.pkg.dev/imandra-dev/imandrax-api/

install-artifact-deps:
	@echo 'run: `pip install build setuptools keyring keyrings-google-artifactregistry-auth`'

list-artifacts:
	gcloud artifacts packages list --location=europe-west1 --project=imandra-dev --repository=imandrax-api

publish: build
	@echo "uploading to $(PYTHON_REPO_URL)"
	python -m twine upload --non-interactive --repository-url $(PYTHON_REPO_URL) dist/*

publish-pypi-test: build
	@echo "publish to test PyPI"
	python -m twine upload -u __token__ -p $$(gcloud secrets versions access --project imandra-dev --secret pypi-test-imandrax-api-api-token latest) -r testpypi dist/*

publish-pypi: # build
	@echo "publish to test PyPI"
	python -m twine upload -u __token__ -p $$(gcloud secrets versions access --project imandra-dev --secret pypi-imandrax-api-api-token latest) dist/*

GOBIN?=~/.local/bin
install-go-protobuf-plugin:
	@echo "installing twirp plugin for protoc into `echo $(GOBIN)`"
	cd protoc-gen-twirpy && GOBIN="`echo $(GOBIN)`" go install ./

.PHONY: remove-wheels build genversion api_types_version.py
