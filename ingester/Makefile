# The ingester's one container: the document flattener (runbook D0). Everything else is plain sh.
# make build                      build the flattener image
# make flatten ENG=<eng> DOC=Dnnn write sessions/Dnnn/Dnnn.fragments.tsv, .sections.tsv and .meta.tsv
# make check                      sh -n over every script
# ENGAGEMENTS_ROOT defaults to the engagements folder beside ingester/; set it (absolute) to flatten in a scratch copy.

DOCKER_HOST := unix://$(HOME)/.docker/run/docker.sock
export DOCKER_HOST
UID := $(shell id -u)
GID := $(shell id -g)
ENGAGEMENTS_ROOT ?= $(abspath ../engagements)
export UID GID ENG ENGAGEMENTS_ROOT

.PHONY: build rebuild up down logs flatten check

build: docker/corp-ca.crt
	docker compose build

rebuild: docker/corp-ca.crt
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f flatten

# Corporate TLS interception (Netskope): the system keychain certificates, so pip in the image trusts the
# intercepting proxy. Made once; delete the file to regenerate after the proxy certificate changes.
docker/corp-ca.crt:
	security find-certificate -a -p /Library/Keychains/System.keychain > $@

flatten:
	@[ -n "$(ENG)" ] && [ -n "$(DOC)" ] || { echo "usage: make flatten ENG=<engagement> DOC=Dnnn" >&2; exit 1; }
	@[ -f $(ENGAGEMENTS_ROOT)/$(ENG)/documents/$(DOC).md ] || { echo "error: $(DOC) is not registered in $(ENGAGEMENTS_ROOT)/$(ENG)/documents/" >&2; exit 1; }
	docker compose run --rm flatten $(ENG) $(DOC)

check:
	@for f in bin/*; do sh -n "$$f" || exit 1; done; echo "check passed"
