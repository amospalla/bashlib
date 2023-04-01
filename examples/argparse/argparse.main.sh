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

parse_arguments() {
	# Program name, overwrites the automatic retrieved program name (optional)
	__bl_argparse_set_program_name "git"

	# Program description, array of paragraphs
	__bl_argparse_doc_add_description "I am a program description paragraph."
	__bl_argparse_doc_add_description "  - foo."
	__bl_argparse_doc_add_description "  - bar."

	# String of arguments definition.
	# Note: argparse injects :parameter:help:help:.
	__bl_argparse_arguments_definition+=":literal:mode:add: [:parameter:verbose:v:verbose:] (:parameter:all:a:all: | :remaining:files:)"
	__bl_argparse_arguments_definition+=" | "
	__bl_argparse_arguments_definition+=":literal:mode:commit: [:parameter:verbose:v:verbose:] :parameter:param_message:m:message: :variable:message:str:"

	# Documentation: Parameters.
	__bl_argparse_doc_add_section "add" "adds files to stage area"
	__bl_argparse_doc_add_parameter "-a|--add"   "add all files"
	__bl_argparse_doc_add_parameter "{files...}" "list of manually specified files to add"

	__bl_argparse_doc_add_section  "commit" "commit changes in stage area"
	__bl_argparse_doc_add_parameter "-m|--message {msg}" "message for the commit"

	__bl_argparse_doc_add_section "Common parameters"  # Notice we didn't specify any documentation for this section
	__bl_argparse_doc_add_parameter "-v|--verbose" "execute program in verbose mode"

	# Documentation: Examples.
	__bl_argparse_doc_add_example \
		"${__bl_argparse_program_name} --verbose add --all" \
		"add all files to the stage area in verbose mode"

	__bl_argparse_doc_add_example \
		"${__bl_argparse_program_name} commit -m \"some message\"" \
		"commit the changes in the staged area"

	__bl_argparse "${__bl_argparse_arguments_definition}" "${@}"
}

main() {
	parse_arguments "${@}"

	__bl_color green
	printf "argparser succeeded, correct input tokens were issued, we can access valid tokens "
	echo "on associative array __bl_argparse_values[]."
	echo

	# shellcheck disable=SC2154
	for name in "${!__bl_argparse_values[@]}"; do
		echo "__bl_argparse_values[\"${name}\"]='${__bl_argparse_values[${name}]}'"
	done
	# shellcheck disable=SC2154
	if [[ "${#__bl_argparse_remaining[@]}" -gt 0 ]]; then
		echo "__bl_argparse_remaining[@]='${__bl_argparse_remaining[*]}'"
	fi
	__bl_color
}

# vim: set ft=sh:
