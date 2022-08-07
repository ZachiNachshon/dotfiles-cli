default: help

.PHONY: create_tarball
create_tarball: ## Create a tarball from local repository
	@tar \
	--exclude='.git' \
	--exclude='docs-site/' \
	--exclude='formula.rb' \
	--exclude='dotfiles-cli.tar.gz' \
	-zcf dotfiles-cli.tar.gz \
	.

.PHONY: install_from_respository
install_from_respository: create_tarball ## Install a local dotfiles CLI from this repository
	@LOCAL_ARCHIVE_FILEPATH=$(CURDIR)/dotfiles-cli.tar.gz ./install.sh
	@rm -rf $(CURDIR)/dotfiles-cli.tar.gz

.PHONY: uninstall
uninstall: ## Uninstall a local dotfiles CLI
	@./uninstall.sh

.PHONY: release_version_create
release_version_create: create_tarball ## Create release tag in GitHub with version from resources/version.txt
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: create' \
	'version_file_path: ./resources/version.txt' \
	'artifact_file_path: dotfiles-cli.tar.gz' \
	'debug'"
	@rm -rf $(CURDIR)/dotfiles-cli.tar.gz

.PHONY: release_version_delete
release_version_delete: ## Enter a tag to delete its attached release tag from GitHub
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: delete' \
	'debug'"

.PHONY: calculate_sha_by_commit_hash
calculate_sha_by_commit_hash: ## Enter a commit to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: commit-hash' \
	'repository_url: https://github.com/ZachiNachshon/dotfiles-cli'"

.PHONY: calculate_sha_by_tag
calculate_sha_by_tag: ## Enter a tag to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: tag' \
	'repository_url: https://github.com/ZachiNachshon/dotfiles-cli' \
	'asset_name: dotfiles-cli.tar.gz'"

# http://localhost:9001/dotfiles-cli/
.PHONY: serve_docs_site
serve_docs_site: ## Run a local site
	@cd docs-site && npm run docs-serve

# http://192.168.x.xx:9001/
.PHONY: serve_docs_site_lan
serve_docs_site_lan: ## Run a local site (open for LAN)
	@cd docs-site && npm run docs-serve-lan

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


