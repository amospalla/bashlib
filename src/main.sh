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

# ShellCheck can't follow non-const...
# shellcheck disable=SC1090

__bl_get_main_paths() {
	# __bl_get_main_paths() -> None
	# 
	# Get program path from BASH_SOURCE and PWD, so we can both
	# execute script directly and by calling 'bash script.sh'.
	#
	# This function is also used as is on standalone files.
	local path
	path="${BASH_SOURCE[-1]}"

	[[ "${path}" =~ ^[./] ]] || path="./${path}"

	__bl_program_path="${path%/*}"
	__bl_program_name="${path##*/}"
	if [[ "${__bl_sourced}" -eq 1 ]]; then
		__bl_bashlib_path="${BASH_SOURCE[-2]%/*}"
	fi
}

__bl_modules() {
	# __bl_modules() -> None
	#
	# Initialize module variables
	module_file=(
		[__bl_argparse]="argparse/argparse.sh"
		[__bl_color]="io/color.sh"
		[__bl_constants]="constants/constants.sh"
		[__bl_echo_color]="io/color.sh"
		[__bl_generate_standalone]="standalone/standalone.sh"
		[__bl_load_bash_builtin]="builtin/builtin.sh"
		[__bl_log]="log/log.sh"
		[__bl_path_canonicalize]="path/path.sh"
		[__bl_printf_color]="io/color.sh"
		[__bl_printf_or_echo_color]="io/color.sh"  # internal use only
		[__bl_sleep]="builtin/builtin.sh"
		[__bl_temp_path_get]="utils/utils.sh"
		[__bl_trap_error]="error/error.sh"
		[__bl_version_string]="utils/utils.sh"
	)
}

__bl_module_load() {
	# __bl_module_load(module_name) -> None
	#
	# Loads a named module.
	# 
	# Modules reside in files. When a module is loaded:
	#     - its file is sourced.
	#     - <module_name>_load() function is called if it exists.
	#     - <module_name>_init is called if it exists.
	#
	# Files where modules are stored can contain multiple modules.

	local module_name
	local module_path
	declare -A module_file  # Dictionary with ${module_name}=${module_path} (relative to ${__bashlib_path}/modules)
	__bl_modules

	module_name="${1}"

	module_path="${module_file[${module_name}]:-}"

	if [[ -z "${module_path}" ]]; then
		echo "Error: module ${module_name} does not exist."
		exit 1
	fi

	# Keep track of already sourced files to avoid sourcing multiple times.
	if [[ "${__bl_modules_file_sourced[${module_name}]:-0}" -eq 0 ]]; then
		. "${__bl_bashlib_path}/modules/${module_path}"
		__bl_modules_file_sourced[${module_name}]=1
	fi

	# Keep track of already loaded modules to avoid loading multiple times.
	if [[ "${__bl_modules_loaded[${module_name}]:-0}" -eq 0 ]]; then
		[[ "$(type -t "${module_name}_load")" == "function" ]] && "${module_name}_load"
		[[ "$(type -t "${module_name}_init")" == "function" ]] && "${module_name}_init"
		__bl_modules_loaded[${module_name}]=1
	fi
}

__bl_run_main() {
	# __bl_run_main() -> None
	#
	# When in sourced mode, this function is called from main program, which then loads the source file containing the 

	local path_main

	if [[ "${__bl_program_name}" == *.sh ]]; then
		# If called program is *.sh, assume main code resides on *.main.sh
		path_main="${__bl_program_path}/${__bl_program_name%.sh}.main.sh"
	else
		# If called program is not *.sh, assume main code resides on *.main
		path_main="${__bl_program_path}/${__bl_program_name}.main"
	fi

	if [[ -n "${__bl_generate_standalone_filename:-}" ]]; then
		echo "Warning: Not executing the program, instead creating the standalone file: ${__bl_generate_standalone_filename}."
		__bl_module_load __bl_generate_standalone
		__bl_generate_standalone "${path_main}"
		chmod u+x "${__bl_generate_standalone_filename}"
	else
		. "${path_main}"
		# End here, call the real program execution
		main "${@}"
	fi
}

__bl_initialize_common() {
	# __bl_initialize_common() -> None
	#
	# Initializetion code that is also used by standalone module.

	declare -g -i __bl_sourced    # Boolean value stating if bashlib has been sourced else on generated standalone.
	declare -g __bl_program_name  # Name of the script invoking the library.
	declare -g __bl_program_path  # Path of the script invoking the library, may be relative.

	# global variables for functions to store values instead of sending to stdout.
	declare -g __bl_return
	declare -g -a __bl_return_array=()
	declare -g -A __bl_return_asarray=()

	__bl_get_main_paths
}

__bl_initialize() {
	# __bl_initialize() -> None
	#
	# Bashlib initialization, this code runs when bashlib is sourced.

	[[ "${DEBUG:-0}" -eq 1 ]] && set -x

	set -eu -o pipefail -o errtrace

	declare -g __bl_bashlib_path  # Directory where bashlib resides.
	declare -g -A __bl_modules_file_sourced  # Dictionary with ${module_name}="1" if
	declare -g -A __bl_modules_loaded  # Dictionary with ${module_name}="1" if module is already loaded.

	__bl_sourced=1
	__bl_modules_loaded=()

	__bl_initialize_common
}

__bl_initialize

# vim: set ft=sh:
