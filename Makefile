# Makefile for managing Apptainer dev environment

ENV_VARS := $(shell ./scripts/load_config.sh --print)
$(foreach var,$(ENV_VARS),$(eval $(var)))

.PHONY: all clean uninstall reinstall purge distclean build

all:
	@echo "Available targets:"
	@echo "  make clean       - Remove cache and temporary files"
	@echo "  make uninstall   - Run uninstall.sh"
	@echo "  make reinstall   - Uninstall then install cleanly"
	@echo "  make purge       - Wipe venv, code-server, cache, backups"
	@echo "  make distclean   - Wipe everything including Apptainer image"
	@echo "  make build       - Re-build the apptainer image"

clean:
	@echo "[Clean] Removing Python/pip cache"
	rm -rf $(PROJECT_ROOT)/.cache/pip
	rm -rf $(PROJECT_ROOT)/.cache/code-server
	rm -rf $(PROJECT_ROOT)/.cache/
	@echo "[Clean] Done"

uninstall: distclean
	@echo "[Uninstall] Purging all enviornmental files."

reinstall: uninstall install
	@echo "[Reinstall] Running install.sh"

purge:
	@echo "[Purge] Removing venv, code-server, cache, backups"
	rm -rf $(VENV_PATH)
	rm -rf $(CODESERVER_DIR)
	rm -rf $(PROJECT_ROOT)/.cache/pip
	rm -rf $(PROJECT_ROOT)/.cache/code-server
	rm -rf $(PROJECT_ROOT)/.apptainer-cache
	rm -rf $(PROJECT_ROOT)/tmp
	rm -f ~/.bash_profile.backup.*
	@echo "[Purge] Done"

distclean: purge
	@echo "[Distclean] Removing Apptainer image"
	rm -f $(CONTAINER_IMAGE)
	@echo "[Distclean] Done"

build: 
	@echo "[Build] Building Apptainer Image"
	mkdir -p $(PROJECT_ROOT)/.apptainer-cache
	mkdir -p $(PROJECT_ROOT)/tmp
	APPTAINER_CACHEDIR="$(PROJECT_ROOT)/.apptainer-cache" \
	TEMP="$(PROJECT_ROOT)/tmp" \
	TMPDIR="$(PROJECT_ROOT)/tmp" \
	apptainer build $(CONTAINER_IMAGE) container.def
	@echo "[Build] Rebuilt Apptainer Image"
