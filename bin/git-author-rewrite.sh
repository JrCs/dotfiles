#!/bin/bash

source "$DOTFILES_DIR"/libraries/bash_library.sh

while [[ -z "$OLD_EMAIL" ]]; do
    read -e -p 'The old email to replace: ' OLD_EMAIL
    if [[ ! -z "$OLD_EMAIL" && "$OLD_EMAIL" != *@* ]]; then
        error "invalid email !\n"
        OLD_EMAIL=''
    fi
done
export OLD_EMAIL

while [[ -z "$CORRECT_NAME" ]]; do
    read -e -p 'The correct user name to use: ' CORRECT_NAME
done
export CORRECT_NAME

while [[ -z "$CORRECT_EMAIL" ]]; do
    read -e -p 'The correct email to use: ' CORRECT_EMAIL
    if [[ ! -z "$CORRECT_EMAIL" && "$CORRECT_EMAIL" != *@* ]]; then
        error "invalid email !\n"
        CORRECT_EMAIL=''
    fi
done
export CORRECT_EMAIL

echo
printf "Old email to replace: %s\n" $(say $OLD_EMAIL)
printf "Replace with: %s <%s>\n" "$(sayColor green $CORRECT_NAME)" "$(say $CORRECT_EMAIL)"
echo

answer=$(prompt "Is it correct [y/n] ?" "" "y" "n")
[[ $(lc "$answer") != y* ]] && exit 0

git filter-branch --env-filter '
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
