.PHONY: help

help: ## show this help message and exit
	@echo "usage: make [target]"
	@echo
	@echo "targets:"
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

archive: ## archive TySimulator
	@./scripts/packager
	@open build

clean: ## clean
	@rm -rf build

pack:
	dmgcanvas finalize "packager/DMG Canvas.dmgCanvas" "TySimulator.dmg"

%:
	@: