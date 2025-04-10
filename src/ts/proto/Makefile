
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto
gents:
	protoc --plugin=node_modules/.bin/protoc-gen-ts_proto --ts_proto_out=./ -I ../../proto \
		$(addprefix ../../proto/, $(PROTO_FILES)) \
		--ts_proto_opt=importSuffix=.js \
		--ts_proto_opt=forceLong=bigint \
		--ts_proto_opt=globalThisPolyfill=true \
		--ts_proto_opt=esModuleInterop=true \
		--ts_proto_opt=exportCommonSymbols=false \
		--ts_proto_opt=oneof=unions

install-deps:
	npm install ts-proto

.PHONY: genpython
