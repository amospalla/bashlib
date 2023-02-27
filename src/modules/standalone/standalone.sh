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

# Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
# shellcheck disable=SC2317

################################################################################
__bl_generate_standalone_load() {
	__bl_generate_standalone() {
		__echo(){
			echo "${*}" >> "${__bl_generate_standalone_filename}"
		}

		local main_program_source_path  # Path for the file containing the main program.
		local dirpath  # Current program path

		# Used for recursion
		local include  # Paths for external files to include (include/*.sh)
		local -a modules
		local fn_name
		local module
		local -i i

		main_program_source_path="${1}"
		dirpath="$(dirname "${main_program_source_path}")"

		echo '#!/usr/bin/env bash' > "${__bl_generate_standalone_filename}"
		__echo
		__echo "# Generated using bashlib"

		# When __bl_generate_standalone_interactive is set to 1 the user specifies that the main program
		# is sourced on interactive sessions.
		if [[ "${__bl_generate_standalone_interactive:-0}" -eq 0 ]]; then
			__echo
			__echo '[[ "${DEBUG:-0}" -eq 1 ]] && set -x'
			__echo
			__echo 'set -eu -o pipefail -o errtrace'
		fi
		__echo

		# Export from main.sh
		declare -f __bl_get_main_paths >> "${__bl_generate_standalone_filename}"

		# Export all loaded modules
		if [[ "${#__bl_modules_loaded[@]}" -gt 0 ]]; then
			__echo
			__echo "# Bashlib Modules:"
		fi

		readarray -t modules < <(declare -F)
		for module in "${!__bl_modules_loaded[@]}"; do
			for (( i=0; i<${#modules[@]}; i++ )); do
				if [[ "${modules[i]}" =~ ^"declare -f "(${module}.*)$ ]]; then
					fn_name="${BASH_REMATCH[1]}"
					# Do not export these modules:
					[[ "${fn_name}" == __bl_generate_standalone* ]] && continue  # standalone generation module.
					[[ "${fn_name}" == "${module}_load" ]] && continue  # loading functions.
					__echo
					declare -f "${fn_name}" >> "${__bl_generate_standalone_filename}"
				fi
			done
		done

		# Initialization code
		__echo
		declare -f __bl_initialize_common >> "${__bl_generate_standalone_filename}"
		__echo
		__echo "# Bashlib initialization start"
		__echo "declare -g -i __bl_sourced=0"
		__echo "__bl_initialize_common"

		if [[ "${#__bl_modules_loaded[@]}" -gt 1 ]]; then
			__echo "# Bashlib modules initialization"

			for module in "${!__bl_modules_loaded[@]}"; do
				if [[ "$(type -t "${module}_init")" == "function" ]]; then
					__echo "${module}_init"
					__echo "unset -f '${module}_init'"
				fi
			done
		fi

		# External file includes
		if [[ -d "${dirpath}/include" ]]; then
			__echo
			__echo "# Bashlib modules includes:"
			__echo
			for include in "${dirpath}/include"/*.sh; do
				[[ -f "${include}" ]] || continue
				if grep -Eq "^#\s*vim:\s*set\s+ft=sh\s*:$" "${include}"; then
					cat "${include}" >> "${__bl_generate_standalone_filename}"
				else
					grep -Ev "^#\s*vim:\s*set\s+ft=sh\s*:$" "${include}" >> "${__bl_generate_standalone_filename}"
				fi
			done
		fi
		__echo "# Bashlib initialization end"

		__echo
		__echo "# Main program"

		if grep -Eq -e "^#\s*vim:\s*set\s+ft=sh\s*:$" -e "^#!/usr/bin/env bash$" "${main_program_source_path}"; then
			grep -Ev -e "^#\s*vim:\s*set\s+ft=sh\s*:$" -e "^#!/usr/bin/env bash$" "${main_program_source_path}" >> "${__bl_generate_standalone_filename}"
		else
			cat "${main_program_source_path}" >> "${__bl_generate_standalone_filename}"
		fi

		__echo
		__echo 'main "${@}"'
		__echo
		__echo "# vim: set ft=sh:"
	}
}

# vim: set ft=sh:
