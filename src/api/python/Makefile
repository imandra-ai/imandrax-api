
# https://github.com/openapi-generators/openapi-python-client

SCHEMA=../openapi.yml
TARGET=lib

install-tools:
	pipx install openapi-python-client ruff

gen:
	#swagger-codegen generate -l typescript-fetch -i $(SCHEMA)
	openapi-python-client generate --path=$(SCHEMA) --meta=poetry --overwrite --output-path=$(TARGET)

clean:
	rm -rf $(TARGET)
