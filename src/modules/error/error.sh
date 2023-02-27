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
#
# This module should be loaded first so it can trap any module loading code errors like
# intializations (example: file creation errors).

################################################################################
__bl_trap_error_load() {
	__bl_module_load __bl_log

	__bl_trap_error_on_error() {
		local -i ec
		local -i show_line
		local lines

		ec="${1}"
		show_line="${2}"

		__bl_log critical "Exit code: ${ec}."
		if [[ "${show_line}" -eq 1 ]]; then
			lines="Trace of errors produced on function(line):"
			# ignore the last value, it is the start of the file
			# BASH_LINENO[@] = ( last_line, intermediate_lines..., first_line)
			# example: (line of error, intermediate lines, first line of file)
			for (( i=${#BASH_LINENO[@]}-2; i>=0; i-- )); do
				lines+=" ${FUNCNAME[i]}(${BASH_LINENO[i]})"
			done
			__bl_log critical "${lines}"
			if [[ __bl_sourced -eq 0 ]]; then
				__bl_trap_error_print_line "${BASH_LINENO[0]}"
			fi
		fi
		exit "${ec}"
	}

	__bl_trap_error_on_int() {
		local -i ec
		ec="${1}"
		__bl_log critical "User requested program termination."
		__bl_trap_error_on_error "${ec}" 0
	}

	__bl_trap_error_print_line() {
		# __bl_trap_error_print_line(int: line): print current running
		# program specified line and its surrounding ones.
		#
		# Surrounding lines is a number greater or equal to zero.

		local -a text_array
		local -i line i surrounding_lines
		local arrow

		surrounding_lines=6
		line="${1}"
		readarray -t text_array < "${__bl_program_path}/${__bl_program_name}"
		for (( i=line-1-surrounding_lines; i<line+surrounding_lines; i++)); do
			[[ i -ge 0 ]] || continue
			[[ i -lt ${#text_array[@]} ]] || continue
			[[ "${i}"+1 -eq "${line}" ]] && arrow=">>" || arrow="  "
			__bl_log critical "${__bl_program_name}($(( i+1 ))):${arrow}${text_array[i]}"
		done
	}
}

__bl_trap_error_init() {
	# trap_error init: make trap functions available and setup traps.
	# __bl_trap_error

	if [[ "${__bl_generate_standalone_interactive:-0}" -eq 0 ]]; then
		trap '__bl_trap_error_on_error $? 1' ERR SIGHUP SIGTERM
		trap '__bl_trap_error_on_int   $?' SIGINT
	fi
}

# vim: set ft=sh:
