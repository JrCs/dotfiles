#!/bin/bash

# bash library
#
# Copyright (C) 2014-2015 Yves Blusseau
#
version_sort ()
{
    case $version_sort_sort_has_v in
        yes)
             LC_ALL=C sort -V;;
        no)
            LC_ALL=C sort -n;;
        *)
           if sort -V </dev/null > /dev/null 2>&1; then
               version_sort_sort_has_v=yes
               LC_ALL=C sort -V
           else
               version_sort_sort_has_v=no
               LC_ALL=C sort -n
           fi;;
    esac
}

version_test_numeric ()
{
    version_test_numeric_a="$1"
    version_test_numeric_cmp="$2"
    version_test_numeric_b="$3"
    if [ "$version_test_numeric_a" = "$version_test_numeric_b" ] ; then
        case "$version_test_numeric_cmp" in
            ge|eq|le) return 0 ;;
            gt|lt) return 1 ;;
        esac
    fi
    if [ "$version_test_numeric_cmp" = "lt" ] ; then
        version_test_numeric_c="$version_test_numeric_a"
        version_test_numeric_a="$version_test_numeric_b"
        version_test_numeric_b="$version_test_numeric_c"
    fi
    if (echo "$version_test_numeric_a" ; echo "$version_test_numeric_b") | version_sort | head -n 1 | grep -qx "$version_test_numeric_b" ; then
        return 0
    else
        return 1
    fi
}

version_test_gt ()
{
    version_test_gt_a="`echo "$1" | sed -e "s/[^-]*-//"`"
    version_test_gt_b="`echo "$2" | sed -e "s/[^-]*-//"`"
    version_test_gt_cmp=gt
    if [ "x$version_test_gt_b" = "x" ] ; then
        return 0
    fi
    case "$version_test_gt_a:$version_test_gt_b" in
        *.old:*.old) ;;
        *.old:*) version_test_gt_a="`echo -n "$version_test_gt_a" | sed -e 's/\.old$//'`" ; version_test_gt_cmp=gt ;;
        *:*.old) version_test_gt_b="`echo -n "$version_test_gt_b" | sed -e 's/\.old$//'`" ; version_test_gt_cmp=ge ;;
    esac
    version_test_numeric "$version_test_gt_a" "$version_test_gt_cmp" "$version_test_gt_b"
    return "$?"
}

print_option_help () {
    if test x${print_option_help_wc:-} = x; then
        if wc -L  </dev/null > /dev/null 2>&1; then
            print_option_help_wc=-L
        elif wc -m  </dev/null > /dev/null 2>&1; then
            print_option_help_wc=-m
        else
            print_option_help_wc=-b
        fi
    fi
    if test x${_have_fmt:-} = x; then
        if fmt -w 40  </dev/null > /dev/null 2>&1; then
            _have_fmt=y;
        else
            _have_fmt=n;
        fi
    fi
    print_option_help_lead="  $1"
    print_option_help_lspace="$(echo "$print_option_help_lead" | wc $print_option_help_wc)"
    print_option_help_fill="$((26 - print_option_help_lspace))"
    printf "%s" "$print_option_help_lead"
    if test $print_option_help_fill -le 0; then
        print_option_help_nl=y
        echo
    else
        print_option_help_i=0;
        while test $print_option_help_i -lt $print_option_help_fill; do
            printf " "
            print_option_help_i=$((print_option_help_i+1))
        done
        print_option_help_nl=n
    fi
    if test x$_have_fmt = xy; then
        print_option_help_split="$(echo "${2:-}" | fmt -w 50)"
    else
        print_option_help_split="${2:-}"
    fi
    if test x$print_option_help_nl = xy; then
        echo "$print_option_help_split" | awk \
 '{ print "                          " $0; }'
    else
        echo "$print_option_help_split" | awk 'BEGIN   { n = 0 }
    { if (n == 1) print "                          " $0; else print $0; n = 1 ; }'
    fi
}


# Convert numeric size to human
declare -a _unit=( $((2**30)) $((2**20)) $((2**10)) )
declare -a _unit_string=( 'G' 'M' 'K' )

numeric_to_human() {
    local value=${1?missing argument}
    local idx=0
    local u
    if [[ "$value" -lt 1024 ]]; then
        echo "${value}"
        return
    fi
    for u in "${_unit[@]}"; do
        if [[ $value -ge $u ]]; then
            local result=$(echo "scale=0; $value / $u" | bc -l)
            echo "$result${_unit_string[$idx]}"
            return
        fi
        (( idx++ ))
    done
}

# Convert human size to numeric
human_to_numeric() {
    local value=${1?missing argument}
    local i
    for i in "g G m M k K"; do
        value=${value//[gG]/*1024m}
        value=${value//[mM]/*1024k}
        value=${value//[kK]/*1024}
    done
    [[ ${value} == *\** ]] && echo $((value)) || return 1
}


# Return on absolute path from a relative or absolute path
# Remove . and .. in the path
abspath() {
    local thePath="${1?missing path argument}"
    local fromPath="${2:-$PWD}"
    if [[ ! "$1" =~ ^/ ]]; then
        thePath="$fromPath/$thePath"
    fi
    local IFS=/
    local i
    read -a parr <<< "$thePath"
    declare -a outp
    for i in "${parr[@]}";do
        case "$i" in
            ''|.) continue ;;
            ..)
                local len=${#outp[@]}
                if ((len==0));then
                    continue
                else
                    unset outp[$((len-1))]
                fi
                ;;
            *)
               outp+=("$i")
               ;;
        esac
    done
    echo /"${outp[*]}"
}

relpath() {
    local path="${1?missing path argument}"
    local base="${2?missing base argument}"
    perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' "$path" "$base"
}


# Colors

sayColor() {
    local fmt="%s"
    case "$1" in
        red)
            fmt='\e[0;31m%b\e[0m';; # red
        blue)
            fmt='\e[0;34m%b\e[0m';; # blue
        yellow)
            fmt='\e[0;33m%b\e[0m';; # yellow
        green)
            fmt='\e[0;32m%b\e[0m';; # green
        cyan)
            fmt='\e[0;36m%b\e[0m';; # cyan
        error|bred)
            fmt='\e[1;31m%b\e[0m';; # bold red
        skip|bblue)
            fmt='\e[1;34m%b\e[0m';; # bold blue
        warn|byellow)
            fmt='\e[1;33m%b\e[0m';; # bold yellow
        pass|bgreen)
            fmt='\e[1;32m%b\e[0m';; # bold green
        info|bcyan)
            fmt='\e[1;36m%b\e[0m';; # bold cyan
    esac
    shift
    printf "$fmt" "$*"
}

say() {
    sayColor info "$*"
}

error() {
    sayColor error "Error: $*" >&2
}

die() {
    error "$*"
    exit 1
}

function echob() {
    echo $(tput bold)"$1"$(tput sgr0)
}

# Convert argument to lowercase
function lc() {
    echo "$@" | tr '[A-Z]' '[a-z]'
}

# Check if an element is valid
# Arguments:
#    $1: string to validate
#    $2+: array of valid elements
#
# Return the string if found else return an empty string
function valid() {
    local element
    local lcString=$(lc "$1")
    for element in $(lc ${@:2}); do
        [[ "$lcString" == $element* ]] && echo "$1" && return 0
    done
    return 1
}

function prompt() {
    local message="$1"
    local default=${@:2:1}
    local valid=${@:3}
    local goodAnswer=0
    until [[ "$goodAnswer" -eq 1 ]]; do
        read -p "${message}${default:+ [$default]}: " answer >&2
        [[ -z "$answer" && -n "$default" ]] && answer="$default"
        [[ -z "$valid" || (-n "$valid" && -n "$(valid ${answer} $valid)") ]] && goodAnswer=1
    done
    echo "$answer"
}
