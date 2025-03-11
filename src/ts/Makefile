
# https://github.com/stephenh/ts-proto?tab=readme-ov-file#supported-options
OPTS=--ts_proto_opt=forceLong=bigint --ts_proto_opt=esModuleInterop=true \
	 --ts_proto_opt=env=browser --ts_proto_opt=context=true \
	 --ts_proto_opt=useOptionals=messages --ts_proto_opt=oneof=unions \
	 --ts_proto_opt=outputServices=generic-definitions \
	 --ts_proto_opt=globalThisPolyfill=true

gen:
	protoc --plugin=./node_modules/.bin/protoc-gen-ts_proto --ts_proto_out=. ./api.proto $(OPTS)

clean:
	rm *.ts
