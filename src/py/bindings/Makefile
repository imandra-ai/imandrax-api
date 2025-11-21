
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto
genpython:
	@for f in $(PROTO_FILES); do \
		uv tool run --from=protobuf-protoc-bin==29.5 protoc --python_out=./ --pyi_out=./ --twirpy_out=./ -I ../../proto "../../proto/$$f"; \
	done

.PHONY: genpython
