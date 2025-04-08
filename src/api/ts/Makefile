
# https://openapi-ts.dev/introduction
# https://openapi-ts.dev/openapi-fetch/

SCHEMA=../openapi.yml
TARGETS=api.d.ts

gen:
	#swagger-codegen generate -l typescript-fetch -i $(SCHEMA)
	npx openapi-typescript $(SCHEMA) -o $(TARGETS)

clean:
	rm $(TARGETS)
