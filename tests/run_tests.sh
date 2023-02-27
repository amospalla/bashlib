#!/usr/bin/env bash

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
