
build:
	cargo build

#OPTS=--dump -d
genrust:
	@dune exec ../../lib/genbindings/genbindings.exe -- --lang=rust -o src/lib.rs $(OPTS)

TWINE_UPSTREAM_URL=git@github.com:c-cube/twine-data.rs.git
TWINE_PREFIX=src/rust/lib/twine
TWINE_TMP=/tmp/twine-data-upstream

define step
	@echo ">>> $(1)"; bash -c 'read -p "    press enter when done..."'
endef

update-twine:  ## Update the twine-data from the upstream repository
	$(call step,git clone --single-branch $(TWINE_UPSTREAM_URL) $(TWINE_TMP))
	$(call step,cd $(TWINE_TMP) && git subtree split --prefix=twine-data -b twine-data-only)
	$(call step,[INSPECT] git -C $(TWINE_TMP) log twine-data-only --oneline | head -10)
	$(call step,[POINT OF NO RETURN] git subtree pull --prefix=$(TWINE_PREFIX) $(TWINE_TMP) twine-data-only --squash)
	$(call step,rm -rf $(TWINE_TMP))
	@echo "Done."
