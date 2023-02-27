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
# Bashlib initialization end

# Main program

main() {
	local script_full_path
	local script_name
	local -a what
	local -a from
	local w f relative_path
	local bashlib_path

	script_name="helper__bl_bashlib_path"
	script_full_path=$(dirname "${0}")  # Get this script path
	script_full_path+="/../${script_name}"  # Point to ../<script_name>
	script_full_path=$(readlink -f "${script_full_path}")

	bashlib_path="$(readlink -f "${script_full_path}/../../src")"

	what+=( "${script_full_path}/${script_name}.sh" )
	what+=( "${script_full_path}/${script_name}.standalone.sh" )

	from+=( "/" )
	from+=( "${script_full_path}" )
	from+=( "$( readlink -f "${script_full_path}/..")" )

	for w in "${what[@]}"; do
		for f in "${from[@]}"; do
			cd "${f}"
				# <program> <expected bashlib_path> <expected program path>
				echo
				echo "PWD(${PWD}) ${w} bashlib_path(${bashlib_path})"
				"${w}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) ./${relative_path} bashlib_path(none)"
				"./${relative_path}" "${bashlib_path}" "${w}"

				echo
				echo "PWD(${PWD}) bash ${w} bashlib_path(${bashlib_path}) program_path(${w})"
				bash "${w}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) bash ./${relative_path} bashlib_path(none) program_path(${w})"
				bash "./${relative_path}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) bash ${relative_path} bashlib_path(none) program_path(${w})"
				bash "${relative_path}" "${bashlib_path}" "${w}"
		done
	done
}

main "${@}"


main "${@}"

# vim: set ft=sh:
