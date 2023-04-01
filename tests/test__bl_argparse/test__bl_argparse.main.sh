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

__bl_test_empty_input() {
	# __bl_argparse_arguments_definition=""
	input_tokens=()
}

__bl_test_empty_input_error() {
	inverse=1
	# __bl_argparse_arguments_definition=""
	input_tokens=( "a" )
}

__bl_test_empty_input_error2() {
	inverse=1
	__bl_argparse_arguments_definition=":literal:a:a:"
	input_tokens=()
}

__bl_test_literal() {
	__bl_argparse_arguments_definition=":literal:a:a:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} a"
}

__bl_test_literal_fail() {
	inverse=1
	__bl_argparse_arguments_definition=":literal:a:a:"
	input_tokens=( "b" )
}

__bl_test_parameter() {
	__bl_argparse_arguments_definition=":parameter:a:short:large:"
	input_tokens=( "-short" )
	expected_tree_text="${__bl_program_name} -short|--large"
}

__bl_test_variable() {
	__bl_argparse_arguments_definition=":variable:a:"
	input_tokens=( "random value" )
	expected_tree_text="${__bl_program_name} {a}"
}

__bl_test_variable_csv_1() {
	__bl_argparse_arguments_definition=":variable:myvar::a,b,c:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_csv_2() {
	__bl_argparse_arguments_definition=":variable:myvar::a,b,c:"
	input_tokens=( "c" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_csv_3() {
	inverse=1
	__bl_argparse_arguments_definition=":variable:myvar::a,b,c:"
	input_tokens=( "d" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_int() {
	__bl_argparse_arguments_definition=":variable:myvar:int:"
	input_tokens=( "1" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_int_str() {
	inverse=1
	__bl_argparse_arguments_definition=":variable:myvar:int:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

data1() {
	__bl_argparse_arguments_definition+=":literal:mode:add: [:parameter:verbose:v:verbose:] (:parameter:add_all:a:all: | :remaining:files:)"
	__bl_argparse_arguments_definition+=" | "
	__bl_argparse_arguments_definition+=":literal:mode:commit: [:parameter:verbose:v:verbose:] :parameter:p_commit_message:m:message: :variable:commit_message:str:"

	printf -v expected_tree_text "%s"                             "${__bl_program_name} add [-v|--verbose] (-a|--all | {files...})"
	printf -v expected_tree_text "%s\n%s" "${expected_tree_text}" "${__bl_program_name} commit [-v|--verbose] -m|--message {commit_message}"
}

__bl_test_git_like() {
	data1; input_tokens=( "add" "-a" )
}

__bl_test_git_like2() {
	data1; input_tokens=( "add" "--all" )
}

__bl_test_git_like3() {
	data1; input_tokens=( "add" "--all" "file1" )
}

__bl_test_git_like4() {
	data1; input_tokens=( "add" "-v" "--all" "file1" )
}

__bl_test_git_like5() {
	data1; input_tokens=( "add" "--verbose" "--all" "file1" )
}

__bl_test_git_like6() {
	data1; input_tokens=( "add" "--verbose" "file1" "file2" )
}

__bl_test_git_like7() {
	inverse=1
	data1; input_tokens=( "add2" "--verbose" "file1" "file2" )
}

__bl_test_git_like8() {
	inverse=1
	data1; input_tokens=( "commit" )
}

__bl_test_git_like9() {
	data1; input_tokens=( "commit" "-v" "-m" "random" )
}

main() {
	local -a input_tokens
	local expected_tree_text
	local obtained_tree_text
	local -i inverse
	local -i failed
	local -i exit_code=0
	local debug=1

	for test in $(declare -F | grep -E "^declare -f __bl_test_.*$" | sed "s/^declare -f //" | sort -g || true); do
		__bl_argparse_init
		expected_tree_text=""
		inverse=0

		# Load test
		"${test}"

		if [[ "${expected_tree_text}" ]]; then
			expected_tree_text+="${__bl_character_newline}${__bl_program_name} -h|--help"
		else
			expected_tree_text+="${__bl_program_name} [-h|--help]"
		fi

		__bl_argparse_input_tokens=( "${input_tokens[@]}" )

		# Add help section. This setion is copied as-is from source because we are not executing the library
		# main function, but parts of it.
		if [[ "${__bl_argparse_arguments_definition}" ]]; then
			__bl_argparse_arguments_definition="(${__bl_argparse_arguments_definition} | :parameter:help:h:help:)"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		else
			__bl_argparse_arguments_definition="([:parameter:help:h:help:])"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		fi

		__bl_argparse_build_tree_expressions
		last_tree_index="${#__bl_argparse_tree_expressions[@]}-1"

		# Check if the input tokens are valid for the input expression and store its values
		__bl_argparse_compare_expr_with_input_tokens \
			1 \
			"${__bl_argparse_tree_expressions_type[last_tree_index]}" \
			"${__bl_argparse_tree_expressions[last_tree_index]}" \
			0 && failed=0 || failed=1

		if [[ inverse -eq 1 ]]; then
			if [[ failed -eq 0 ]]; then
				failed=1
			else
				failed=0
			fi
		fi

		if [[ "${failed}" -eq 0 ]]; then
			true
			# printf "%s" "test ${test} executes: "
			# __bl_echo_color green "ok"
		else
			printf "%s" "test ${test} executes: "
			__bl_echo_color boldred "fail"
		fi

		if [[ "${failed}" -eq 0 && "${inverse}" -eq 0 ]]; then
			obtained_tree_text="$(__bl_argparse_tree_to_string)"
			if [[ "${expected_tree_text}" != "${obtained_tree_text}" ]]; then
				echo
				__bl_echo_color boldred "test ${test} output text not equal to expected:"
				__bl_echo_color blue "expected text:"
				echo "${expected_tree_text}"
				__bl_echo_color blue "obtained text:"
				echo "${obtained_tree_text}"
			fi
		elif [[ "${debug}" -eq 1 ]]; then
			echo
			__bl_echo_color blue "expected text:"
			echo "${expected_tree_text}"
			__bl_echo_color blue "obtained text:"
			echo "${obtained_tree_text}"
		fi
		if [[ failed -ne 0 ]]; then
			exit_code=1
		fi
	done
	return "${exit_code}"
}

# vim: set ft=sh:
