
PROTO_FILES=locs.proto error.proto simple_api.proto system.proto utils.proto
genpython:
	@for f in $(PROTO_FILES); do \
		protoc --python_out=./ --twirpy_out=./ -I .. "../$$f"; \
	done

.PHONY: genpython
