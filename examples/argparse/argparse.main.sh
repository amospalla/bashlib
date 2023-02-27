#!/usr/bin/env bash

main() {
	local argparse_defs=""

	# Program name, overwrites the automatic retrieved program name (optional)
	__bl_argparse_program_name="git"

	# Program description, array of paragraphs
	__bl_argparse_doc_description+=( "I am a program description paragraph." "I am another paragraph." )

	# String of arguments definition.
	# Note: argparse injects :parameter:help:help:.
	argparse_defs+=":literal:mode:add: [:parameter:verbose:v:verbose:] (:parameter:all:a:all: | :remaining:files:)"
	argparse_defs+=" | "
	argparse_defs+=":literal:mode:commit: [:parameter:verbose:v:verbose:] :parameter:param_message:m:message: :variable:message:str:"

	# Documentation: Parameters.
	__bl_argparse_doc_add_section "add" "adds files to stage area"
	__bl_argparse_doc_add_parameter "-a|--add"   "add all files"
	__bl_argparse_doc_add_parameter "{files...}" "list of manually specified files to add"

	__bl_argparse_doc_add_section  "commit" "commit changes in stage area"
	__bl_argparse_doc_add_parameter "-m|--message {msg}" "message for the commit"

	__bl_argparse_doc_add_section "Common parameters"  # Notice we didn't specify any documentation for this section
	__bl_argparse_doc_add_parameter "-v|--verbose" "execute program in verbose mode"

	# Documentation: Examples.
	__bl_argparse_doc_examples_code+=("${__bl_argparse_program_name} --verbose add --all")
	__bl_argparse_doc_examples_text+=("add all files to the stage area in verbose mode")

	__bl_argparse_doc_examples_code+=("${__bl_argparse_program_name} commit -m \"some message\"")
	__bl_argparse_doc_examples_text+=("commit the changes in the staged area")

	__bl_argparse "${argparse_defs}" "${@}"

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
