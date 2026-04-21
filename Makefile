SHELL := /usr/bin/env bash

.PHONY: build lint test legacy-clean shellharden-fix-wrapper

SHELL_SOURCES := gaeta scripts/test-doctor.sh
SHELLHARDEN_SOURCES := scripts/test-doctor.sh tests/doctor.bats
SHELLHARDEN_WRAPPER_SOURCE := gaeta
GAETA_CONFIG_HOME ?= $(HOME)/.config/gaeta

GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

build:
	@printf "$(BLUE)==> Installing gaeta config bundle$(NC)\n"
	@mkdir -p "$(GAETA_CONFIG_HOME)/commands"
	@mkdir -p "$(GAETA_CONFIG_HOME)/agents"
	@mkdir -p "$(GAETA_CONFIG_HOME)/bin"
	@$(MAKE) legacy-clean >/dev/null
	@install -m 0755 gaeta "$(GAETA_CONFIG_HOME)/bin/gaeta"
	@install -m 0644 opencode.json "$(GAETA_CONFIG_HOME)/opencode.json"
	@install -m 0644 .opencode/commands/*.md "$(GAETA_CONFIG_HOME)/commands/"
	@install -m 0644 .opencode/agents/*.md "$(GAETA_CONFIG_HOME)/agents/"
	@if [ -f tui.json ]; then \
		install -m 0644 tui.json "$(GAETA_CONFIG_HOME)/tui.json"; \
		printf "$(GREEN)[OK] installed tui.json$(NC)\n"; \
	else \
		printf "$(YELLOW)[SKIP] tui.json not found$(NC)\n"; \
	fi
	@printf "$(GREEN)[OK] installed gaeta launcher + opencode.json + command/agent templates to $(GAETA_CONFIG_HOME)$(NC)\n"

legacy-clean:
	@printf "$(BLUE)==> Removing legacy gaeta templates$(NC)\n"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/handoff.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/check.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/doctor.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/qa.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/propose.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/approve.md"
	@rm -f "$(GAETA_CONFIG_HOME)/commands/reject.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/discovery.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/orchestrator.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/reviewer.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/qa.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/evolution.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/architect.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/implementer.md"
	@rm -f "$(GAETA_CONFIG_HOME)/agents/handoff-writer.md"
	@printf "$(GREEN)[OK] legacy templates cleaned from $(GAETA_CONFIG_HOME)$(NC)\n"

lint:
	@printf "$(BLUE)==> Running lint checks$(NC)\n"
	@bash -n $(SHELL_SOURCES) && printf "$(GREEN)[OK] bash -n$(NC)\n"
	@shellcheck $(SHELL_SOURCES) && printf "$(GREEN)[OK] shellcheck$(NC)\n"
	@shfmt -i 2 -ci -d scripts/test-doctor.sh tests/doctor.bats && printf "$(GREEN)[OK] shfmt$(NC)\n"
	@if command -v shellharden >/dev/null 2>&1; then \
		shellharden --check $(SHELLHARDEN_SOURCES) && printf "$(GREEN)[OK] shellharden tests$(NC)\n"; \
		if shellharden --check $(SHELLHARDEN_WRAPPER_SOURCE); then \
			printf "$(GREEN)[OK] shellharden gaeta wrapper$(NC)\n"; \
		else \
			printf "$(YELLOW)[WARN] shellharden gaeta wrapper has pending suggestions$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)[SKIP] shellharden not found$(NC)\n"; \
	fi

test:
	@printf "$(BLUE)==> Running test checks$(NC)\n"
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/doctor.bats && printf "$(GREEN)[OK] bats doctor suite$(NC)\n"; \
	else \
		printf "$(YELLOW)[SKIP] bats not found; using shell test fallback$(NC)\n"; \
		./scripts/test-doctor.sh && printf "$(GREEN)[OK] shell fallback suite$(NC)\n"; \
	fi

shellharden-fix-wrapper:
	@printf "$(BLUE)==> Applying shellharden wrapper fixes$(NC)\n"
	@shellharden --transform gaeta > gaeta.shellharden && mv gaeta.shellharden gaeta && chmod +x gaeta
	@printf "$(GREEN)[OK] shellharden transformed gaeta$(NC)\n"
