#!/usr/bin/env bash

set -eu -o pipefail -o errtrace

main() {
	local mypath="$(readlink -f "$(dirname "${0}")")"
	local test

	cd "${mypath}"
	./generate_standalone.sh

	for test in "test__bl_"*; do
		[[ -d "${test}" ]] || continue

		echo
		echo "Execute: ${mypath}/${test}/${test}.sh"
		"${mypath}/${test}/${test}.sh"

		echo
		echo "Execute: ${mypath}/${test}/${test}.standalone.sh"
		"${mypath}/${test}/${test}.standalone.sh"

		echo
		echo "Execute: bash ${mypath}/${test}/${test}.sh"
		bash "${mypath}/${test}/${test}.sh"

		echo
		echo "Execute: bash ${mypath}/${test}/${test}.standalone.sh"
		bash "${mypath}/${test}/${test}.standalone.sh"
	done

}

main "${@}"

# vim: set ft=sh:
