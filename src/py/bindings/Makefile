
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto
genpython:
	@for f in $(PROTO_FILES); do \
		protoc --experimental_allow_proto3_optional --python_out=./ --twirpy_out=./ -I ../../proto "../../proto/$$f"; \
	done

.PHONY: genpython
