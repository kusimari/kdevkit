.PHONY: test test-install test-dev-mode install-claude install-gemini install-kiro

test:
	bash tests/run.sh

test-install:
	bash tests/run.sh tests/install/claude-code.sh tests/install/gemini.sh tests/install/kiro.sh

test-dev-mode:
	bash tests/run.sh tests/dev-mode/prompt.sh tests/dev-mode/references.sh

install-claude:
	bash install.sh --agent claude-code

install-claude-global:
	bash install.sh --agent claude-code --global

install-gemini:
	bash install.sh --agent gemini

install-kiro:
	bash install.sh --agent kiro
