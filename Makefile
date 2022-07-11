default: help

.PHONY: create_artifact 
create_artifact: ## Create a release artifact
	tar \
	--exclude='.git' \
	--exclude='Makefile' \
	--exclude='install.sh' \
	--exclude='dotfiles-cli.tar.gz' \
	-zcvf dotfiles-cli.tar.gz \
	.
	
.PHONY: release_version_create
release_version_create: ## Create release tag in GitHub with version from resources/version.txt
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: create' \
	'version_file_path: ./resources/version.txt' \
	'artifact_file_path: git-deps-syncer.sh' \
	'debug'"

.PHONY: release_version_delete
release_version_delete: ## Enter a tag to delete its attached release tag from GitHub
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: delete' \
	'debug'"

.PHONY: calculate_sha_by_commit_hash
calculate_sha_by_commit_hash: ## Enter a commit to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: commit-hash' \
	'repository_url: https://github.com/ZachiNachshon/git-deps-syncer'"

.PHONY: calculate_sha_by_tag
calculate_sha_by_tag: ## Enter a tag to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: tag' \
	'repository_url: https://github.com/ZachiNachshon/git-deps-syncer' \
	'asset_name: git-deps-syncer.sh'"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


