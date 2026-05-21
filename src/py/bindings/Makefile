
PROTO_FILES=locs.proto error.proto task.proto simple_api.proto system.proto utils.proto session.proto api.proto artmsg.proto

TWIRPY_BIN_DIR=$(CURDIR)/.bin
TWIRPY_BIN=$(TWIRPY_BIN_DIR)/protoc-gen-twirpy

$(TWIRPY_BIN):  ## Gen twirpy clients
	mkdir -p $(TWIRPY_BIN_DIR)
	cd ../protoc-gen-twirpy && go build -o $(TWIRPY_BIN) .

genpython:  ## Gen proto definitions
	@for f in $(PROTO_FILES); do \
		PATH="$(TWIRPY_BIN_DIR):$$PATH" uv tool run --from=protobuf-protoc-bin==29.5 protoc --python_out=./ --pyi_out=./ --twirpy_out=./ -I ../../proto "../../proto/$$f"; \
	done

.PHONY: genpython
