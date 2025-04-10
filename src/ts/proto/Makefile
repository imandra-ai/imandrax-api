
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto
gents:
	protoc --plugin=node_modules/.bin/protoc-gen-ts_proto --ts_proto_out=./ -I ../../proto $(addprefix ../../proto/, $(PROTO_FILES)); \

install-deps:
	npm install ts-proto

.PHONY: genpython
