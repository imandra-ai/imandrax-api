
VERSION=$(shell grep VERSION= setup.py | sed 's/VERSION=//' | tr -d '"')
echo-version:
	@echo version: $(VERSION)

build:
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

.PHONY: remove-wheels build
