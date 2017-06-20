.PHONY: help build

help: ## show this help message and exit
	@echo "usage: make [target]"
	@echo
	@echo "targets:"
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

icon: ## generate app icons
	@scripts/generate_app_icon resources/logo.png TySimulator/Assets.xcassets/AppIcon.appiconset

menu-icon: ## generate menu icons
	@scripts/generate_menu_icon resources/menu-icon.png TySimulator/Assets.xcassets/MenuIcon.imageset

bootstrap:
	@pod install
	@carthage bootstrap --platform osx

build: ## archive TySimulator
	@./scripts/build
	@open build

clean: ## clean
	@rm -rf build

pack:
	@./scripts/pack

i18n:
	@./scripts/i18n

%:
	@: