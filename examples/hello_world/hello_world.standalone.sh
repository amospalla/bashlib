#!/usr/bin/env bash

# Generated using bashlib

[[ "${DEBUG:-0}" -eq 1 ]] && set -x

set -eu -o pipefail -o errtrace

__bl_get_main_paths () 
{ 
    local path;
    path="${BASH_SOURCE[-1]}";
    [[ "${path}" =~ ^[./] ]] || path="./${path}";
    __bl_program_path="${path%/*}";
    __bl_program_name="${path##*/}";
    if [[ "${__bl_sourced}" -eq 1 ]]; then
        __bl_bashlib_path="${BASH_SOURCE[-2]%/*}";
    fi
}

# Bashlib Modules:

__bl_echo_color () 
{ 
    __bl_printf_or_echo_color echo "${@}"
}

__bl_color () 
{ 
    if [[ "${1:-None}" == "-f" ]]; then
        shift;
    else
        if ! [[ -t 1 ]]; then
            return;
        fi;
    fi;
    __bl_color_raw "${1:-}";
    printf "${__bl_return}"
}

__bl_color_raw () 
{ 
    local mode number;
    case "${1:-}" in 
        *bold*)
            mode=1
        ;;
        *dim*)
            mode=2
        ;;
        *underline*)
            mode=4
        ;;
        *blink*)
            mode=5
        ;;
        *reverse*)
            mode=7
        ;;
        *hidden*)
            mode=8
        ;;
        *)
            mode=0
        ;;
    esac;
    case "${1:-}" in 
        *white*)
            number="37"
        ;;
        *black*)
            number="30"
        ;;
        *red*)
            number="31"
        ;;
        *green*)
            number="32"
        ;;
        *yellow*)
            number="33"
        ;;
        *blue*)
            number="34"
        ;;
        *magenta*)
            number="35"
        ;;
        *cyan*)
            number="36"
        ;;
        *)
            number="0"
        ;;
    esac;
    printf -v __bl_return "%s" "\e[${mode};${number}m"
}

__bl_trap_error_init () 
{ 
    trap '__bl_trap_error_on_error $? 1' ERR SIGHUP SIGTERM;
    trap '__bl_trap_error_on_int   $?' SIGINT
}

__bl_trap_error_on_error () 
{ 
    local -i ec;
    local -i show_line;
    local lines;
    ec="${1}";
    show_line="${2}";
    __bl_log critical "Exit code: ${ec}.";
    if [[ "${show_line}" -eq 1 ]]; then
        lines="Trace of errors produced on function(line):";
        for ((i=${#BASH_LINENO[@]}-2; i>=0; i-- ))
        do
            lines+=" ${FUNCNAME[i]}(${BASH_LINENO[i]})";
        done;
        __bl_log critical "${lines}";
        if [[ __bl_sourced -eq 0 ]]; then
            __bl_trap_error_print_line "${BASH_LINENO[0]}";
        fi;
    fi;
    exit "${ec}"
}

__bl_trap_error_on_int () 
{ 
    local -i ec;
    ec="${1}";
    __bl_log critical "User requested program termination.";
    __bl_trap_error_on_error "${ec}" 0
}

__bl_trap_error_print_line () 
{ 
    local -a text_array;
    local -i line i surrounding_lines;
    local arrow;
    surrounding_lines=6;
    line="${1}";
    readarray -t text_array < "${__bl_program_path}/${__bl_program_name}";
    for ((i=line-1-surrounding_lines; i<line+surrounding_lines; i++))
    do
        [[ i -ge 0 ]] || continue;
        [[ i -lt ${#text_array[@]} ]] || continue;
        [[ "${i}"+1 -eq "${line}" ]] && arrow=">>" || arrow="  ";
        __bl_log critical "${__bl_program_name}($(( i+1 ))):${arrow}${text_array[i]}";
    done
}

__bl_log () 
{ 
    local level;
    level="${1}";
    shift;
    if [[ "${__bl_log_levels[${level}]}" -ge "${__bl_log_level}" ]]; then
        case "${level}" in 
            debug)
                __bl_echo_color cyan "[${level}] ${*}"
            ;;
            info)
                __bl_echo_color green "[${level}] ${*}"
            ;;
            warning)
                __bl_echo_color yellow "[${level}] ${*}"
            ;;
            error)
                __bl_echo_color magenta "[${level}] ${*}"
            ;;
            critical)
                __bl_echo_color red "[${level}] ${*}"
            ;;
        esac;
    fi
}

__bl_log_init () 
{ 
    declare -g -A __bl_log_levels;
    declare -g -i __bl_log_level;
    __bl_log_levels=([debug]="0" [info]="1" [warning]="2" [error]="3" [critical]="4");
    __bl_log_level="2"
}

__bl_printf_or_echo_color () 
{ 
    local mode;
    local force;
    local color;
    mode="${1}";
    shift;
    if [[ "${1:-}" == '-f' ]]; then
        shift;
        force="-f";
    fi;
    color="${1}";
    shift;
    __bl_color ${force:-} "${color}";
    "${mode}" "${@}";
    __bl_color
}

__bl_initialize_common () 
{ 
    declare -g -i __bl_sourced;
    declare -g __bl_program_name;
    declare -g __bl_program_path;
    declare -g __bl_return;
    declare -g -a __bl_return_array=();
    declare -g -A __bl_return_asarray=();
    __bl_get_main_paths
}

# Bashlib initialization start
declare -g -i __bl_sourced=0
__bl_initialize_common
# Bashlib modules initialization
__bl_trap_error_init
unset -f '__bl_trap_error_init'
__bl_log_init
unset -f '__bl_log_init'
# Bashlib initialization end

# Main program

# Copyright (c) 2023 Jordi Marqués
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

main() {
	__bl_echo_color green "Hello world"
}

main "${@}"

# vim: set ft=sh:
