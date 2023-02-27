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

__bl_path_canonicalize () 
{ 
    local -a components;
    local -a components_new;
    local component;
    __bl_return="${1}";
    if [[ "${__bl_return}" != /* ]]; then
        __bl_return="${PWD}/${__bl_return}";
    fi;
    while [[ "${__bl_return}" =~ (.*)//+(.*) ]]; do
        __bl_return="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}";
    done;
    while [[ "${__bl_return}" =~ (.*)"/."(/.*)?$ ]]; do
        __bl_return="${BASH_REMATCH[1]}${BASH_REMATCH[2]}";
    done;
    IFS="/" read -r -a components <<< "${__bl_return#/}";
    components_new=();
    for component in "${components[@]}";
    do
        if [[ "${component}" == .. ]]; then
            if [[ "${#components_new[@]}" -gt 0 ]]; then
                unset "components_new[${#components_new[@]}-1]";
            fi;
        else
            components_new+=("${component}");
        fi;
    done;
    __bl_return="";
    for component in "${components_new[@]}";
    do
        __bl_return+="/${component}";
    done;
    [[ "${__bl_return}" == "" ]] && __bl_return="/";
    if [[ "${__bl_return}" =~ (.*[^/]+)/+$ ]]; then
        __bl_return="${BASH_REMATCH[1]}";
    fi
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

check() {
	local expected_path
	local obtained_path

	expected_path="$(realpath -m "${1}")"

	__bl_path_canonicalize "${1}"
	obtained_path="${__bl_return}"

	if [[ "${expected_path}" != "${obtained_path}" ]]; then
		echo "Error: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
		exit 1
	# else
	# 	echo "OK: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
	fi
}

main() {
	local -a strings
	local string1 string2 string3 string4 string5

	strings=(foo bar . .. / /. /.. // ///)
	for string1 in "${strings[@]}"; do
		for string2 in "${strings[@]}"; do
			for string3 in "${strings[@]}"; do
				for string4 in "${strings[@]}"; do
					for string5 in "${strings[@]}"; do
						check "${string1}${string2}${string3}${string4}${string5}"
					done
				done
			done
		done
	done
}

main "${@}"


main "${@}"

# vim: set ft=sh: