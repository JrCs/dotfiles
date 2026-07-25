# -*- shell-script -*-

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Some systems (e.g. Synology DSM) force the login shell to /bin/sh, which is
# actually bash but invoked under that name: it then behaves like sh and loses
# bash extensions this configuration relies on, process substitution in
# particular. POSIX mode is a reliable proxy for that state on those systems;
# escape it by re-execing a real bash login shell.
if shopt -qo posix; then
	__real_bash=$(type -P bash)
	[[ -n "$__real_bash" ]] && exec "$__real_bash" --login
	unset __real_bash
fi

if [[ -f ~/.localrc.pre ]]; then
	source ~/.localrc.pre
fi

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	. /etc/bashrc
fi

# Declare dotfiles directory
export DOTFILES_DIR=${DOTFILES_DIR:-"$HOME"/.dotfiles}
if [[ ! -d "$DOTFILES_DIR" ]]; then
	echo "Error: can't find $DOTFILES_DIR directory" >&2
	return 1
fi

source "$DOTFILES_DIR"/bash/paths
source "$DOTFILES_DIR"/bash/config
source "$DOTFILES_DIR"/bash/completions
source "$DOTFILES_DIR"/bash/aliases

# use .localrc for settings specific to one system
if [[ -f ~/.localrc ]]; then
	source ~/.localrc
fi

## Adapting PATH environment variable for use with perlbrew,
## load RVM into a shell session *as a function*, and add completion
#if [[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]]; then
#	source "$HOME/perl5/perlbrew/etc/bashrc"
#	[[ -r "$PERLBREW_ROOT"/etc/perlbrew-completion.bash ]] && \
	#		. "$PERLBREW_ROOT"/etc/perlbrew-completion.bash
#fi
#
## Adapting PATH environment variable for use with RVM,
## load RVM into a shell session *as a function*, and
## add completion
#if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
#	source "$HOME/.rvm/scripts/rvm"
#	[[ -r "$rvm_path"/scripts/completion ]] && . "$rvm_path"/scripts/completion
#fi
