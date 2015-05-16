SOURCE_DIR=/tmp/git-extras
DESTDIR ?= "$(DOTFILES_DIR)/"
PREFIX ?= "git-extras"
BINPREFIX ?= "$(PREFIX)/bin"
MANPREFIX ?= "$(PREFIX)/man"
BINS = $(wildcard bin/git-*)
MANS = $(wildcard man/git-*.md)
MAN_HTML = $(MANS:.md=.html)
MAN_PAGES = $(MANS:.md=.1)
LIB = $(addprefix $(SOURCE_DIR)/, helper/reset-env helper/git-extra-utility)

COMMANDS_USED_WITHOUT_GIT_REPO = git-alias git-fork git-setup
COMMANDS_USED_WITH_GIT_REPO = git-changelog git-effort git-delete-merged-branches git-delete-submodule git-delete-tag git-ignore git-info git-line-summary git-lock git-locked git-obliterate git-rebase-patch git-rename-tag git-reset-file git-show-merged-branches git-show-unmerged-branches git-summary git-touch git-undo git-unlock 

MANS = $(addsuffix .1, $(COMMANDS_USED_WITH_GIT_REPO) $(COMMANDS_USED_WITHOUT_GIT_REPO))

$(SOURCE_DIR):
	@git clone https://github.com/tj/git-extras.git $(SOURCE_DIR)

install: $(SOURCE_DIR)
	@rm -rf "$(DESTDIR)$(MANPREFIX)"; mkdir -p $(DESTDIR)$(MANPREFIX)
	@rm -rf "$(DESTDIR)$(BINPREFIX)"; mkdir -p $(DESTDIR)$(BINPREFIX)
	@echo "... installing bins to $(DESTDIR)$(BINPREFIX)"
	@echo "... installing man pages to $(DESTDIR)$(MANPREFIX)"
	$(eval TEMPFILE := $(shell mktemp -t git-extra.XXX))
	@# chmod from rw-------(default) to rwxrwxr-x, so that users can exec the scripts
	@chmod 775 $(TEMPFILE)
	@$(foreach COMMAND, $(COMMANDS_USED_WITH_GIT_REPO), \
		echo "... installing $(COMMAND)"; \
		head -1 $(SOURCE_DIR)/bin/$(COMMAND) | cat - $(LIB) $(SOURCE_DIR)/helper/is-git-repo > $(TEMPFILE); \
		tail -n +2 $(SOURCE_DIR)/bin/$(COMMAND) >> $(TEMPFILE); \
		cp -f $(TEMPFILE) $(DESTDIR)$(BINPREFIX)/$(COMMAND); \
		ln -sf ../$(BINPREFIX)/$(COMMAND) $(DESTDIR)bin/; \
	)
	@$(foreach COMMAND, $(COMMANDS_USED_WITHOUT_GIT_REPO), \
		echo "... installing $(COMMAND)"; \
		head -1 $(SOURCE_DIR)/bin/$(COMMAND) | cat - $(LIB) > $(TEMPFILE); \
		tail -n +2 $(SOURCE_DIR)/bin/$(COMMAND) >> $(TEMPFILE); \
		cp -f $(TEMPFILE) $(DESTDIR)$(BINPREFIX)/$(COMMAND); \
	)
	@echo "... installing man pages"
	@$(foreach MAN, $(MANS), \
		if [[ -f $(SOURCE_DIR)/man/$(MAN) ]]; then \
			cp -f $(SOURCE_DIR)/man/$(MAN) $(DESTDIR)$(MANPREFIX)/; \
			ln -sf ../../$(MANPREFIX)/$(MAN)  $(DESTDIR)man/man1/; \
		fi; \
	)
	@echo "... installing bash completion"
	@mkdir -p $(DESTDIR)$(PREFIX)/bash_completion.d
	@cp -f $(SOURCE_DIR)/etc/bash_completion.sh $(DESTDIR)$(PREFIX)/bash_completion.d/git-extras

update: install

.PHONY: install update
