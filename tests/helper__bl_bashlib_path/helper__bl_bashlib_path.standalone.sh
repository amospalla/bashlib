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
# Bashlib initialization end

# Main program

main() {
	local in_bashlib_path
	local in_path
	local in_name

	in_bashlib_path="${1}"
	in_path="${2%/*}"
	in_name="${2##*/}"


	if [[ -z "${__bl_bashlib_path:-}" ]]; then
		__bl_echo_color gray "bashlib path n/a"
	elif [[ "${in_bashlib_path}" == "$(readlink -f "${__bl_bashlib_path:-}")" ]]; then
		__bl_echo_color green "__bl_bashlib_path '${__bl_bashlib_path}'"
	else
		__bl_echo_color red "__bl_bashlib_path expected '${in_bashlib_path}', but got: '${__bl_bashlib_path:-}'"
		exit 1
	fi

	if [[ "${in_path}" == "$(readlink -f "${__bl_program_path}")" ]]; then
		__bl_echo_color green "__bl_program_path '${__bl_program_path}'"
	else
		__bl_echo_color red "__bl_program_path '${__bl_program_path}'"
		exit 1
	fi

	if [[ "${in_path}/${in_name}" == "$(readlink -f "${__bl_program_path}/${__bl_program_name}")" ]]; then
		__bl_echo_color green "__bl_program_name '${__bl_program_name}'"
	else
		__bl_echo_color red "__bl_program_name '${in_path} / ${in_name}'  '${__bl_program_path} / ${__bl_program_name}'"
		exit 1
	fi
}


main "${@}"

# vim: set ft=sh:
