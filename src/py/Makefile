
VERSION=$(shell grep 'version =' pyproject.toml | sed 's/version =//' | tr -d '"')
echo-version:
	@echo version: $(VERSION)

API_TYPES_VERSION=$(shell cat ../core/API_TYPES_VERSION)
api_types_version.py:
	@echo "api_types_version = 'v$(API_TYPES_VERSION)'" > $@

build: clean api_types_version.py
	uv build --wheel

clean:
	rm -rf build dist

test:
	uv run ../../tests/api/py/test_cloud_dev.py
	uv run ../../tests/api/py/test_extract_region_str.py

pre-release-test: build  # Run pre-release tests with built wheel
	@echo "Running pre-release tests with built wheel..."
	@WHEEL=$$(ls dist/imandrax_api-*.whl | head -n 1); \
	echo "Using wheel: $$WHEEL"; \
	uv run --isolated --no-project --with "$$WHEEL" python ../../tests/api/py/test_cloud_dev.py && \
	uv run --isolated --no-project --with "$$WHEEL" python ../../tests/api/py/test_extract_region_str.py

PYTHON_REPO_URL = https://europe-west1-python.pkg.dev/imandra-dev/imandrax-api/

install-artifact-deps:
	@echo 'run: `pip install build setuptools keyring keyrings-google-artifactregistry-auth`'

list-artifacts:
	gcloud artifacts packages list --location=europe-west1 --project=imandra-dev --repository=imandrax-api

publish: build
	@echo "uploading to $(PYTHON_REPO_URL)"
	uv run twine upload --non-interactive --repository-url $(PYTHON_REPO_URL) dist/*

publish-pypi-test: pre-release-test build
	@echo "publish to test PyPI"
	uv run twine upload -u __token__ -p $$(gcloud secrets versions access --project imandra-dev --secret pypi-test-imandrax-api-api-token latest) -r testpypi dist/*

publish-pypi: pre-release-test build
	@echo "publish to PyPI"
	uv run twine upload -u __token__ -p $$(gcloud secrets versions access --project imandra-dev --secret pypi-imandrax-api-api-token latest) dist/*

GOBIN?=~/.local/bin
install-go-protobuf-plugin:
	@echo "installing twirp plugin for protoc into `echo $(GOBIN)`"
	cd protoc-gen-twirpy && GOBIN="`echo $(GOBIN)`" go install ./

.PHONY: remove-wheels build genversion api_types_version.py
