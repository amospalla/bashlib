#!/usr/bin/env bash

set -eu -o pipefail -o errtrace

main() {
	local script_full_path
	local script_name
	local -a what
	local -a from
	local w f relative_path
	local bashlib_path

	script_name="paths"
	script_full_path="$(dirname "$(readlink -f "${0}")")"

	bashlib_path="$(readlink -f "${script_full_path}/../../src")"

	/home/jordi/projectes/bashlib/examples/generate_standalone.sh


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

# vim: set ft=sh:
