# Inspired by https://github.com/jessfraz/dotfiles

.PHONY: test
test: psscriptanalyzer shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: psscriptanalyzer
psscriptanalyzer:
	@echo Running PSScriptAnalyzer
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-psscriptanalyzer \
		-v $(CURDIR):/usr/src:ro \
		mcr.microsoft.com/powershell \
		pwsh -command "Save-Module -Name PSScriptAnalyzer -Path .; Import-Module .\PSScriptAnalyzer; Invoke-ScriptAnalyzer -EnableExit -Path /usr/src -Recurse"

.PHONY: shellcheck
shellcheck:
	@echo Running shellcheck
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		ferrarimarco/shellcheck

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
