declare -a _ack_options
declare -a _ack_types=()

_ack_options=(
  "--invert-match" \
  "--word-regexp" \
  "--before-context" \
  "--files-without-matches" \
  "--color" \
  "--recurse" \
  "--context" \
  "--count" \
  "--help" \
  "--after-context" \
  "--no-filename" \
  "--max-count" \
  "--literal" \
  "--no-recurse" \
  "--ignore-directory" \
  "--with-filename" \
  "--files-with-matches" \
  "--ignore-case" \
)

function __setup_ack() {
    local type

    while read LINE; do
        case $LINE in
            --*)
                type="${LINE%% *}"
                type=${type/--\[no\]/}
                _ack_options[ ${#_ack_options[@]} ]="--$type"
                _ack_options[ ${#_ack_options[@]} ]="--no$type"
                _ack_types[ ${#_ack_types[@]} ]="$type"
            ;;
        esac
    done < <(ack --help-types)
}
__setup_ack
unset -f __setup_ack

function _ack_complete() {
    local current_word
    local pattern

    current_word=${COMP_WORDS[$COMP_CWORD]}

    if [[ "$current_word" == -* ]]; then
        pattern="${current_word}*"
        for option in ${_ack_options[@]}; do
            if [[ "$option" == $pattern ]]; then
                COMPREPLY[ ${#COMPREPLY[@]} ]=$option
            fi
        done
    else
        local previous_word
        previous_word=${COMP_WORDS[$(( $COMP_CWORD - 1 ))]}
        if [[ "$previous_word" == "=" ]]; then
            previous_word=${COMP_WORDS[$(( $COMP_CWORD - 2 ))]}
        fi

        if [ "$previous_word" == '--type' -o "$previous_word" == '--notype' ]; then
            pattern="${current_word}*"
            for type in ${_ack_types[@]}; do
                if [[ "$type" == $pattern ]]; then
                    COMPREPLY[ ${#COMPREPLY[@]} ]=$type
                fi
            done
        fi
    fi
}

complete -o default -F _ack_complete ack ack2 ack-grep
