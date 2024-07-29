
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto
genpython:
	@for f in $(PROTO_FILES); do \
		protoc --python_out=./ --twirpy_out=./ -I ../../proto "../../proto/$$f"; \
	done

help:
	echo "see https://github.com/verloop/twirpy"
	echo "install protoc plugin using: GOBIN=~/bin/ go install github.com/verloop/twirpy/protoc-gen-twirpy@latest"

.PHONY: genpython
