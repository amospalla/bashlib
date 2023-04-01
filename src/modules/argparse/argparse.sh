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

# TODO:
#
#     - is type funcio
#
#     - provar tots els tipus de primitives

# Documentation:
#     primitives:
#         "literal :
#             format
#                 :literal:{name}:{token}:
#             examples
#                 :literal:mode:add:
#                 :literal:mode:commit:
#                 :literal:mode:reset:
#         "variable"
#             when not specified datatype=str
#             format
#                 :variable:{name}:[datatype]:[choices_comma_separated]:
#             examples
#                 :variable:path:
#                 :variable:path:str:
#                 :variable:path:str:option1,option2,option3:
#                 :variable:path::option1,option2,option3:
#         "parameter"
#             format
#                 :parameter:{name}:{short}:{long}:
#             examples
#                 :parameter:verbose:v:verbose:
#         "remaining"
#             must be the last parameter because it will consume al the remaining input tokens
#             when not specified datatype=str
#             format
#                 :remaining:{name}:[datatype]:
#             examples
#                 :remaining:files:
#
#     available expressions:
#         sequence: "expression1 expression2 expression3"
#         or: "expression1 | expression2 | expression3"
#         optional: "expression1 [expression2]"
#         group: "(expressionA | expressionB) | expression2"
#
#     example:
#         # Main expression must be always inside a group ().
#         __bl_argparse "expression" input_token1 input_token2 ... input_token<n>
#         __bl_argparse "(:literal:a: [:literal:b:] | :literal:c:)" a b
#
#     built expressions tree:
#         Arr Index  Type       Expression
#         0          primitive  :literal:b:
#         1          optional   :0:
#         2          primitive  :literal:a:
#         3          sequence   :1:
#         4          sequence   :2: :3:
#         5          primitive  :literal:c:
#         6          or         :4: :5:
#         7          sequence   :6:
#
#     more examples:
#         __bl_argparse_arguments_definition="( :literal:mode:add: ([:parameter:add_all:a:all:] | :remaining:files:) | :literal:mode:commit: :parameter:p_commit_message:m:message: :variable:commit_message:str:)"

################################################################################
__bl_argparse_load() {
	__bl_module_load __bl_constants
	__bl_module_load __bl_printf_color

	###############################################################################
	## Compare input tokens with expressions tree #################################
	###############################################################################
	__bl_argparse_compare_expr_with_input_tokens() {
		# Compare if the expression tree validate with the input tokens. Recursive.

		local -a expression_tokens
		local -a input_tokens
		local -i expression_index
		local -i first_run
		local -i input_tokens_index
		local -i valid_items_counter=0
		local expression_token
		local expression_type

		first_run="${1}"
		expression_type="${2}"
		read -r -a expression_tokens <<< "${3}"
		input_tokens_index="${4}"

		input_tokens=( "${__bl_argparse_input_tokens[@]:input_tokens_index}" )

		if [[ first_run -eq 1 ]]; then
			__bl_argparse_result_name=()
			__bl_argparse_result_datatype=()
			__bl_argparse_result_choices=()
			__bl_argparse_result_short=()
			__bl_argparse_result_long=()
			__bl_argparse_result_type=()
			__bl_argparse_result_value=()
			__bl_argparse_remaining=()
			__bl_argparse_values=()
			local -a return_value=( 0 0 )  # [0]: exit code, [1], number of valid input tokens, shared to simulate return values.
			shift
			# This is where the first call actually starts
			__bl_argparse_compare_expr_with_input_tokens 0 "${@}"
			__bl_argparse_result_reindex
			if [[ "${return_value[0]}" -eq 0 ]] && [[ "${return_value[1]}" -eq "${#__bl_argparse_input_tokens[@]}" ]]; then
				__bl_argparse_store_values  # Store input variables into an array for end user
				return 0
			else
				return 1
			fi
		fi

		# Debug:
		# printf "\n__bl_argparse_compare_expr_with_input_tokens: %3s %12s %14s %3s %5s %3s %3s\n" ${first_run} ${expression_type} "${expression_tokens[*]}" "${input_tokens_index[*]}" "${input_tokens[*]}" "${return_value[0]}" "${return_value[1]}"

		case "${expression_type}" in
			"sequence")
				# For every item in the sequence do the check.
				for expression_token in "${expression_tokens[@]}"; do
					expression_index="${expression_token//:/}"

					__bl_argparse_compare_expr_with_input_tokens 0 \
						"${__bl_argparse_tree_expressions_type[expression_index]}" \
						"${__bl_argparse_tree_expressions[expression_index]}" \
						"$(( input_tokens_index + valid_items_counter ))"

					if [[ "${return_value[0]}" -eq 0 ]]; then
						valid_items_counter+="${return_value[1]}"
						return_value=(0 "${valid_items_counter}")
					else
						# If one element on the sequence fails, don't continue comparing the others.
						return_value=(1 0)
						break
					fi
				done
				;;
			"or")
				for expression_token in "${expression_tokens[@]}"; do
					expression_index="${expression_token//:/}"

					__bl_argparse_compare_expr_with_input_tokens 0 \
						"${__bl_argparse_tree_expressions_type[expression_index]}" \
						"${__bl_argparse_tree_expressions[expression_index]}" \
						"$(( input_tokens_index + valid_items_counter ))"

					if [[ "${return_value[0]}" -eq 0 ]] && [[ "${return_value[1]}" -eq "${#input_tokens[@]}" ]]; then
						valid_items_counter="${return_value[1]}"
						return_value=(0 "${valid_items_counter}")
						return
					fi
				done
				return_value=(1 0)
				;;
			"primitive")
				if [[ "${#input_tokens[@]}" -eq 0 ]]; then  # Input token empty
					# there is no input token to fulfill a primitive, return no ok
					return_value=(1 0)
				elif __bl_argparse_primitive_equals_input_token "${expression_tokens[0]}" "${input_tokens[@]}"; then
					if [[ "${expression_tokens[0]}" == ":remaining:"* ]]; then
						# This primitive is remaining, if succeed, then accept all tokens
						return_value=( 0 "${#input_tokens[@]}" )
					else
						# Primitive equals to input token, return ok and notify 1 token is correct
						return_value=( 0 1 )
					fi
				else
					# Primitive differs, return no ok
					return_value=( 1 0 )
				fi
				;;
			"optional")
				if [[ "${#input_tokens[@]}" -eq 0 ]]; then  # Input token empty
					# it is ok if there is no input token for this, it is optional
					return_value=(0 0)
				else
					expression_index="${expression_tokens[*]//:/}"

					__bl_argparse_compare_expr_with_input_tokens 0 \
						"${__bl_argparse_tree_expressions_type[expression_index]}" \
						"${__bl_argparse_tree_expressions[expression_index]}" \
						"${input_tokens_index}"

					if [[ "${return_value[0]}" -eq 0 ]]; then
						valid_items_counter="${return_value[1]}"
						return_value=(0 "${valid_items_counter}")
					else
						return_value=(0 0)
					fi
				fi
				;;
		esac
	}

	__bl_argparse_store_values() {
		local -i i
		local name
		local value

		for (( i=0; i<${#__bl_argparse_result_type[@]}; i++ )); do
			name="${__bl_argparse_result_name[i]}"
			case "${__bl_argparse_result_type[i]}" in
				"variable"|"literal")
					value="${__bl_argparse_result_value[i]}"
					__bl_argparse_values[${name}]="${value}"
					;;
				"parameter"|"remaining")
					__bl_argparse_values[${name}]="set"
					;;
			esac
		done
	}

	__bl_argparse_result_reindex() {
		__bl_argparse_result_name=( "${__bl_argparse_result_name[@]}" )
		__bl_argparse_result_datatype=( "${__bl_argparse_result_datatype[@]}" )
		__bl_argparse_result_choices=( "${__bl_argparse_result_choices[@]}" )
		__bl_argparse_result_short=( "${__bl_argparse_result_short[@]}" )
		__bl_argparse_result_long=( "${__bl_argparse_result_long[@]}" )
		__bl_argparse_result_type=( "${__bl_argparse_result_type[@]}" )
		__bl_argparse_result_value=( "${__bl_argparse_result_value[@]}" )
	}

	__bl_argparse_get_expression_tokens() {
		local expression="${1}"
		local -a tokens
		local -i i
		if ! [[ "${expression}" =~ ^:.+:$ ]]; then
			echo "invalid expression"
			return 1
		fi
		expression="${expression:1}"
		IFS=':' read -r -a tokens <<< "${expression}"
		case "${tokens[0]}" in
			"literal")
				# :literal:name:[text]:  use <name> as <text> if <text> is not set
				expression_data=("literal" "${tokens[1]}" "${tokens[2]:-${tokens[1]}}" )
				;;
			"variable")
				expression_data=("variable" "${tokens[1]}" "${tokens[2]:-str}" "${tokens[3]:-}")
				;;
			"parameter")
				expression_data=("parameter" "${tokens[1]}" "${tokens[2]:-}" "${tokens[3]:-}")
				;;
			"remaining")
				# : remaining : {name} : {datatype} :
				expression_data=("remaining" "${tokens[1]}" "${tokens[2]:-str}")
				;;
		esac
	}

	__bl_argparse_is_data_type() {  # -> return <bool>
		local _type
		local data
		_type="${1}"
		data="${2}"

		case "${_type}" in
			"str") [[ "${#data}" -gt 0 ]] ;;
			"int") [[ "${data}" =~ ^[0-9]+$ ]] ;;
			*) return 1 ;;
		esac
	}

	__bl_argparse_add_result() {  # -> return None
		__bl_argparse_result_name+=("${1}")
		__bl_argparse_result_datatype+=("${2}")
		__bl_argparse_result_choices+=("${3}")
		__bl_argparse_result_short+=("${4}")
		__bl_argparse_result_long+=("${5}")
		__bl_argparse_result_type+=("${6}")
		__bl_argparse_result_value+=("${7}")
	}

	__bl_argparse_primitive_equals_input_token() {  # -> return <bool>
		local expression
		local -a input
		local -a expression_data
		local name data_type choices_csv short long
		local input_token

		expression="${1}"
		shift
		# echo "Comparing $1 with $@"
		input=( "${@}" )

		__bl_argparse_get_expression_tokens "${expression}"  # -> returns to expression_data[]
		case "${expression_data[0]}" in
			"literal")
				name="${expression_data[1]}"
				value="${expression_data[2]}"
				# echo "name: $name"
				# echo "value: $value"
				if [[ "${input[0]}" == "${value}" ]]; then
					__bl_argparse_add_result "${name}" "" "" "" "" "literal" "${value}"
				else
					return 1
				fi
				;;
			"remaining")
				name=${expression_data[1]}
				data_type=${expression_data[2]}
				for input_token in "${input[@]}"; do
					if ! __bl_argparse_is_data_type "${data_type}" "${input_token}"; then
						return 1
					fi
				done
				__bl_argparse_add_result "${name}" "${data_type}" "" "" "" "remaining" ""
				__bl_argparse_remaining=( "${input[@]}" )
				;;
			"variable")
				name=${expression_data[1]}
				data_type=${expression_data[2]}
				choices_csv=${expression_data[3]}

				if ! __bl_argparse_is_data_type "${data_type}" "${input[0]}"; then
					return 1
				fi
				if [[ "${#choices_csv}" -gt 0 ]]; then
					if ! [[ "${choices_csv}" =~ (^|.+,)"${input[0]}"(,.+|$) ]]; then
						return 1
					fi
				fi
				__bl_argparse_add_result "${name}" "${data_type}" "${choices_csv}" "" "" "variable" "${input[0]}"
				;;
			"parameter")
				name="${expression_data[1]}"
				short="${expression_data[2]}"
				long="${expression_data[3]}"
				if ! [[ "${input[0]}" =~ ^(-${short}|--${long})$ ]]; then
					return 1
				fi
				__bl_argparse_add_result "${name}" "" "" "${short}" "${long}" "parameter" ""
				;;
		esac
	}

	###############################################################################
	## build expression tree ######################################################
	###############################################################################
	__bl_argparse_add_arguments_definition() {
		__bl_argparse_arguments_definition+="${1}"
	}

	__bl_argparse_build_tree_expressions() {
		# Given the initial text expression, reduce its simplest expressions until everything gets reduced.
		# Input is a string representing the expression, inside a sequence group "()".
		# Keep trying to reduce the expression stored into the variable arguments_definition.

		# Example:
		# (a b | c d) => (a b | sequence(c,d))
		#     => (sequence(a,b)|sequence(c,d))
		#          => or(sequence(a,b), sequence(c,d))

		# Example:
		# __bl_argparse_arguments_definition="a | [b]" is processed into:
		#
		# array_id  __bl_argparse_tree_expressions_type  __bl_argparse_tree_expressions
		# --------  -----------------------------------  ------------------------------
		#        0                            primitive                             'b'
		#        1                             optional                           ':0:'
		#        2                            primitive                             'a'
		#        3                             sequence                           ':1:'
		#        4                                   or                       ':2: :3:'
		#        5                             sequence                           ':4:'

		local arguments_definition
		arguments_definition="${__bl_argparse_arguments_definition}"

		__bl_argparse_tree_expressions=()
		__bl_argparse_tree_expressions_type=()

		while true; do
			# For example, given the expression (a b [c]), only the optional [] can be
			# reduced into :n:. The sequence defined by parenthesis can not because it has
			# embedded brackets inside. Once it becomes (a b :1:) it can be reduced.
			# It works the same the other way, with parenthesis embedded into brackets.

			# Keep reducing until there are no more expression that can be reduced.
			__bl_argparse_reduce_grouped_expression "sequence" "(" ")" && continue
			__bl_argparse_reduce_grouped_expression "optional" "[" "]" && continue
			break
		done
	}

	__bl_argparse_reduce_grouped_expression() {
		# Try to reduce the definition in the variable arguments_definition.
		# If an ungrouped expression is found (a group without any nested group inside):
		#     (1) Add to __bl_argparse_tree_expressions and __bl_argparse_tree_expressions_type references to the
		#         inner contents.
		#     (2) Add to __bl_argparse_tree_expressions and __bl_argparse_tree_expressions_type a reference, to the
		#         group itself, either "sequence" or "optional".

		local group_type
		local open_symbol
		local close_symbol
		local prefix postfix
		local simple_group_expression  # expression found that can be reduced

		group_type="${1}"       # "sequence" or "optional"
		open_symbol="${2}"      # "(" or "["
		close_symbol="${3}"     # ")" or "]"

		# If there is any simple group expression (without any nested group) reduce it.
		if [[ "${arguments_definition}" =~ (.*)("${open_symbol}")([^][()]+)(" "*"${close_symbol}")(.*) ]]; then
			# Example: expression="a b [c] d":
			#     Sets __bl_argparse_tree_expressions_type+=("optional")
			#     Sets expressions+=("a b :0: d")  # given that next array index is 0
			# Grouped expressions without another nested grouped expression inside

			prefix="${BASH_REMATCH[1]}"
			# open_symbol="${BASH_REMATCH[2]}"
			simple_group_expression="${BASH_REMATCH[3]}"
			# close_symbol="${BASH_REMATCH[4]}"
			postfix="${BASH_REMATCH[5]}"

			# Debug:
			# echo "reduce_grouped_expression(${group_type} ${open_symbol}${close_symbol}) found: ${simple_group_expression}"

			# (1)
			# Simplify the single group expression into its simple parts
			# Add __bl_argparse_tree_expressions and __bl_argparse_tree_expressions_type for inner expression parts
			__bl_argparse_reduce_ungrouped_expression "${simple_group_expression}"

			# (2)
			# Add __bl_argparse_tree_expressions and __bl_argparse_tree_expressions_type for the outer group expression
			# Add type:
			__bl_argparse_tree_expressions_type+=( "${group_type}" )
			# Add reference to the latest expression added by __bl_argparse_reduce_ungrouped_expression
			__bl_argparse_tree_expressions+=( ":$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):" )
			# Replace grouped expression by a reference to the expressions tree.
			arguments_definition="${prefix}:$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):${postfix}"
		else
			return 1
		fi
	}

	__bl_argparse_reduce_ungrouped_expression() {
		# Read expression without groups and add its tokens to the expressions tree.
		# Input examples: "a", "a | b", "a b c"

		local -a tokens
		local expression_new
		local expression_type
		local ungrouped_expression_string

		ungrouped_expression_string="${1}"

		# Get the expression type
		if [[ "${ungrouped_expression_string}" ==  *"|"* ]]; then
			expression_type="or"
		else
			read -r -a tokens <<< "${ungrouped_expression_string}"
			if [[ "${#tokens[@]}" -eq 1 ]]; then
				expression_type="primitive"
			else
				expression_type="sequence"
			fi
		fi

		# Separate its tokens and add them to the expressions tree:
		case "${expression_type}" in
			"primitive")
				__bl_argparse_add_expression_to_tree "${tokens[0]}"
				;;
			"or")
				IFS="|" read -r -a tokens <<< "${ungrouped_expression_string}"
				for token in "${tokens[@]}"; do
					__bl_argparse_reduce_ungrouped_expression "${token}"  # Token here may be a sequence of several primitives
					expression_new+=" :$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):"
				done
				__bl_argparse_tree_expressions_type+=( "or" )
				__bl_argparse_tree_expressions+=( "${expression_new# }" )
				;;
			"sequence")
				for token in "${tokens[@]}"; do
					__bl_argparse_add_expression_to_tree "${token}"
					expression_new+=" :$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):"
				done
				__bl_argparse_tree_expressions_type+=( "sequence" )
				__bl_argparse_tree_expressions+=( "${expression_new# }" )
				;;
		esac
	}

	__bl_argparse_add_expression_to_tree() {
		# Add tree_expressions_type and tree_expressions for an input token.
		local token
		local -i index

		token="${1}"

		if [[ "${token}" =~ ^:([0-9]+):$ ]]; then
			# Expression is an existing reference, create a new reference pointing to the same as the token.
			# Example: ":0:"
			index="${BASH_REMATCH[1]}"
			__bl_argparse_tree_expressions_type+=( "sequence" )
			__bl_argparse_tree_expressions+=( ":${index}:" )
		else
			# Create new primitive
			# Example: ":literal:name:"
			__bl_argparse_tree_expressions_type+=( "primitive" )
			__bl_argparse_tree_expressions+=( "${1}" )
		fi
	}

	###############################################################################
	## Tree to string #############################################################
	###############################################################################
	__bl_argparse_tree_to_string() {
		# Simple function to call the first recursive call for the real function.
		local -i color
		[[ "${1:-None}" == "color" ]] && color=1 || color=0
		__bl_argparse_tree_to_string_real "${color}" 0 0 "${#__bl_argparse_tree_expressions[@]}-1"
	}

	__bl_argparse_tree_to_string_real() {
		__bl_argparse_get_expression_index() {
			[[ "${1}" =~ ^:([0-9]+):$ ]] && next_index="${BASH_REMATCH[1]}"
		}
		local -i recursive_depth
		local -i index  # current index of __bl_argparse_tree_expressions
		local -a tokens
		local -i first_element=1
		local -i optional_depth  # track the nested or level, used to print colors
		local -i next_index
		local return_text=""
		local token
		local -i use_color

		use_color="${1}"
		recursive_depth="${2}"
		optional_depth="${3}"
		index="${4}"

		read -r -a tokens <<< "${__bl_argparse_tree_expressions[index]}"
		token="${tokens[0]}"

		case "${__bl_argparse_tree_expressions_type[index]}" in
			"sequence")
				# On first call it is always a sequence, don't output parenthesis
				[[ "${recursive_depth}" -gt 0 ]] && return_text+="("
				for token in "${tokens[@]}"; do
					[[ "${first_element}" -eq 0 ]] && return_text+=" "
					__bl_argparse_get_expression_index "${token}"
					return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}" "${next_index}")"
					first_element=0
				done
				[[ "${recursive_depth}" -gt 0 ]] && return_text+=")"
				;;
			"or")
				# On second call or's are used to separate into different lines, don't output parenthesis
				[[ "${recursive_depth}" -gt 1 ]] && return_text+="("
				for token in "${tokens[@]}"; do
					if [[ "${first_element}" -eq 0 ]]; then
						if [[ "${recursive_depth}" -lt 2 ]]; then
							# tab character will be substituted by newline at the end of the process
							# shellcheck disable=SC2154
							return_text+=" ${__bl_character_tab} "
						else
							return_text+=" | "
						fi
					fi
					__bl_argparse_get_expression_index "${token}"
					return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}" "${next_index}")"
					first_element=0
				done
				[[ "${recursive_depth}" -gt 1 ]] && return_text+=")"
				;;
			"primitive")
				__bl_argparse_get_primitive_tokens "${token}"
				return_text="${__bl_return}"
				;;
			"optional")
				[[ "${optional_depth}" -eq 0 && "${use_color}" -eq 1 ]] && return_text+=":color:optional:"
				return_text+="["
				__bl_argparse_get_expression_index "${token}"
				return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}+1" "${next_index}")"
				return_text+="]"
				[[ "${optional_depth}" -eq 0 && "${use_color}" -eq 1 ]] && return_text+=":color:main:"
				;;
		esac

		if [[ "${recursive_depth}" -eq 0 ]]; then
			# First call, process and clean text and return caller
			tokens=()
			IFS="${__bl_character_tab}" read -r -a tokens <<< "${return_text}"
			for token in "${tokens[@]}"; do
				__bl_argparse_string_clean
				token="${token//:or_symbol:/|}"
				if [[ -t 1 ]]; then  # Don't output colors when stdout is opened
					__bl_color "${__bl_argparse_color_main}"
					token="${token//:color:main:/"${__bl_return}"}"
					__bl_color "${__bl_argparse_color_optional}"
					token="${token//:color:optional:/"${__bl_return}"}"
				else
					token="${token//:color:main:/}"
					token="${token//:color:optional:/}"
				fi
				if [[ "${use_color}" -eq 1 ]]; then
					printf "%s" "  "
					if [[ -n "${__bl_argparse_program_name}" ]]; then
						__bl_printf_color "${__bl_argparse_color_program_name}" "${__bl_argparse_program_name}"
					else
						__bl_printf_color "${__bl_argparse_color_program_name}" "${__bl_program_name}"
					fi
					__bl_color "${__bl_argparse_color_main}"
					echo -e " ${token}"
					__bl_color
				else
					echo -e "${__bl_program_name} ${token}"
				fi
			done
		else
			echo "${return_text}"
		fi
	}

	__bl_argparse_get_primitive_tokens() {  # -> return <str> using __bl_return
		local primitive
		local -a tokens
		local -i i

		primitive="${1}"
		read -r -a tokens <<< "${primitive//:/ }"

		case "${tokens[0]}" in
			"literal")
				__bl_return="${tokens[2]}"
				;;
			"variable")
				if [[ "${tokens[3]:-}" ]]; then
					__bl_return="{${tokens[1]}}:csv"
				else
					__bl_return="{${tokens[1]}}"
				fi
				;;
			"parameter")
				# Using "|" symbol will make __bl_argparse_string_clean() fail.
				__bl_return="-${tokens[2]}:or_symbol:--${tokens[3]}"
				;;
			"remaining")
				# : remaining : {name} : {datatype} :
				__bl_return="{${tokens[1]}...}"
				;;
		esac
	}

	__bl_argparse_string_clean() {
		# echo "input token ${token}"
		while true; do
			[[ "${token}" =~ ^[[:blank:]]+(.*)$ ]] && token="${BASH_REMATCH[1]}" && continue # Remove leading space

			[[ "${token}" =~ ^(.*)[[:blank:]]+$ ]] && token="${BASH_REMATCH[1]}" && continue # Remove trailing space

			[[ "${token}" =~ ^"("(.*)")"$ ]] && token="${BASH_REMATCH[1]}" && continue # Remove surrounding ()

			if [[ "${token}" =~ ^(.*)"("([^"|()"]+)")"(.*)$ ]]; then
				token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"  # (*) --> *
				continue
			fi

			if [[ "${token}" =~ ^(.*)"("('('[^"()"]+')')")"(.*)$ ]]; then
				token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"  # (()) -> ()
				continue
			fi

			if [[ "${token}" =~ ^(.*)"["('['[^][]+']')"]"(.*)$ ]]; then
				token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"  # [[]] -> []
				continue
			fi

			if [[ "${token}" =~ ^(.*["[("])[[:blank:]]+(.*)$ ]]; then
				token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"  # "[ " -> "[", "( " -> "("
				continue
			fi

			if [[ "${token}" =~ ^(.*)[[:blank:]]+(['])'].*)$ ]]; then
				token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"  # " ]" -> "]". "[ " -> "["
				continue
			fi

			if [[ "${token}" =~ ^(.*)[[:blank:]][[:blank:]]+(.*)$ ]]; then
				token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"  # remove duplicated blanks
				continue
			fi
			break
		done
	}

	###############################################################################
	## Debug ######################################################################
	###############################################################################
	__bl_argparse_print_expressions_tree() {
		(
			echo "Expressions_tree:"	
			echo "Index Type Expression"
			for (( i=0; i<${#__bl_argparse_tree_expressions[@]}; i++ )); do
				echo "${i} ${__bl_argparse_tree_expressions_type[i]} ${__bl_argparse_tree_expressions[i]// /_}"
			done
		) | column -t
	}

	###############################################################################
	## Documentation ##############################################################
	###############################################################################
	__bl_argparse_show_help() {
		local -i section_id
		local -i arguments_index_start
		local -i arguments_index_end
		local -i next_section_id
		local -i i
		local dot

		__bl_echo_color "${__bl_argparse_color_header}" "Usage:"
		__bl_argparse_tree_to_string color
		echo

		__bl_echo_color "${__bl_argparse_color_header}" "Parameters:"
		if [[ "${#__bl_argparse_doc_section_names[@]}" -eq 1 ]]; then
			__bl_argparse_print_parameters 0 0 "${#__bl_argparse_doc_argument_names[@]}-1"
		else
			for (( section_id=0; section_id<${#__bl_argparse_doc_section_names[@]}; section_id++ )); do
				[[ section_id -gt 0 ]] && echo
				__bl_printf_color "${__bl_argparse_color_name}" "  ${__bl_argparse_doc_section_names[section_id]}"
				if [[ -n "${__bl_argparse_doc_section_descriptions[section_id]}" ]]; then
					[[ "${__bl_argparse_doc_section_descriptions[section_id]: -1}" == "." ]] && dot="" || dot="."
					__bl_color; printf ": %s\n" "${__bl_argparse_doc_section_descriptions[section_id]}${dot}"
				else
					__bl_color; printf ":\n" ""
				fi

				arguments_index_start="${__bl_argparse_doc_section_first_arg[section_id]}"

				if [[ "${section_id}" -eq "${#__bl_argparse_doc_section_names[@]}-1" ]]; then
					# Current section is the last one, last section argument is last argument on array
					arguments_index_end="${#__bl_argparse_doc_argument_names[@]}-1"
				else
					# Current section is not the last one, last section argument is the previous to the first argument
					# of the next section
					next_section_id="${section_id}+1"
					arguments_index_end="${__bl_argparse_doc_section_first_arg[next_section_id]}-1"
				fi
				__bl_argparse_print_parameters 2 "${arguments_index_start}" "${arguments_index_end}"
			done
		fi

		if [[ "${#__bl_argparse_doc_description[@]}" -gt 0 ]]; then
			[[ "${#__bl_argparse_doc_description[@]}" -gt 0 ]] && echo
			__bl_echo_color "${__bl_argparse_color_header}" "Description:"
			for (( i=0; i<${#__bl_argparse_doc_description[@]}; i++)); do
				echo "  ${__bl_argparse_doc_description[i]}"
			done
		fi

		if [[ "${#__bl_argparse_doc_examples_code[@]}" -gt 0 ]]; then
			echo
			__bl_echo_color "${__bl_argparse_color_header}" "Examples:"
			for (( i=0; i<${#__bl_argparse_doc_examples_code[@]}; i++ )); do
				__bl_printf_color "${__bl_argparse_color_name}" "  $ ${__bl_argparse_doc_examples_code[i]}"
				__bl_color

				[[ "${__bl_argparse_examples_description[i]: -1}" == "." ]] && dot="" || dot="."
				echo ": ${__bl_argparse_examples_description[i]}${dot}"
			done
		fi
	}

	__bl_argparse_print_parameters() {
		local -i ident
		local -i index_start index_end
		local -i argument_id
		local -i current_ident

		ident="${1}"
		index_start="${2}"
		index_end="${3}"

		# Comment next line to right align on parameter names
		__bl_argparse_doc_argument_max_size=0

		current_ident=$(( ident + 2 ))

		for (( argument_id=index_start; argument_id<=index_end; argument_id++ )); do
			printf "%${current_ident}s" ""
			__bl_color "${__bl_argparse_color_name}"
			printf "%${__bl_argparse_doc_argument_max_size}s" "${__bl_argparse_doc_argument_names[argument_id]}"
			__bl_color
			printf ": %s.\n" "${__bl_argparse_doc_argument_descriptions[argument_id]}"
		done
	}

	__bl_argparse_doc_add_section() {
		local name
		local description

		name="${1}"
		description="${2:-}"

		__bl_argparse_doc_section_names+=( "${name}" )
		__bl_argparse_doc_section_descriptions+=( "${description}" )
		# When adding a new section, record the position for its first argument on the arguments array.
		__bl_argparse_doc_section_first_arg+=( "${#__bl_argparse_doc_argument_names[@]}" )
	}

	__bl_argparse_doc_add_parameter() {
		local name
		local description

		name="${1}"
		description="${2}"
		
		__bl_argparse_doc_argument_names+=( "${name}" )
		__bl_argparse_doc_argument_descriptions+=( "${description}" )

		[[ "${#name}" -gt __bl_argparse_doc_argument_max_size ]] && __bl_argparse_doc_argument_max_size="${#name}" || true
	}

	__bl_argparse_doc_add_example() {
		local code
		local description

		code="${1}"
		description="${2:-}"

		__bl_argparse_doc_examples_code+=( "${code}" )
		__bl_argparse_examples_description+=( "${description}" )
	}

	__bl_argparse_set_program_name() {
		__bl_argparse_program_name="${1}"
	}

	__bl_argparse_doc_add_description() {
		__bl_argparse_doc_description+=( "${1}" )
	}

	###############################################################################
	## Main #######################################################################
	###############################################################################
	__bl_argparse() {
		# Arguments:
		#     __bl_argparse_input_tokens(list): user input tokens.
		local -i last_tree_index

		__bl_argparse_input_tokens=( "${@}" )

		# Add help section
		if [[ "${__bl_argparse_arguments_definition}" ]]; then
			__bl_argparse_arguments_definition="(${__bl_argparse_arguments_definition} | :parameter:help:h:help:)"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		else
			__bl_argparse_arguments_definition="([:parameter:help:h:help:])"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		fi

		# Build the expressions tree for the given arguments definition string
		__bl_argparse_build_tree_expressions
		# Get last element index for the array
		last_tree_index="${#__bl_argparse_tree_expressions[@]}-1"

		# Check if the input tokens are valid for the input expression and store its values
		if __bl_argparse_compare_expr_with_input_tokens \
			1 \
			"${__bl_argparse_tree_expressions_type[last_tree_index]}" \
			"${__bl_argparse_tree_expressions[last_tree_index]}" \
			0
		then
			if [[ "${__bl_argparse_values[help]:-}" == "set" ]]; then
				__bl_argparse_show_help
				exit 0
			else
				# Calling program execution continues here.
				true
			fi
		else
			__bl_echo_color red "Invalid input tokens."
			echo
			# [[ "${show_help}" -eq 1 ]] && __bl_argparse_show_help
			__bl_argparse_show_help
			exit 1
		fi
	}
}

__bl_argparse_init() {
	declare -g __bl_argparse_program_name=""
	declare -g __bl_argparse_arguments_definition=""  # String with the arguments definition: "(a | b [c])"
	declare -g -a __bl_argparse_result_name=()
	declare -g -a __bl_argparse_result_datatype=()
	declare -g -a __bl_argparse_result_choices=()
	declare -g -a __bl_argparse_result_short=()
	declare -g -a __bl_argparse_result_long=()
	declare -g -a __bl_argparse_result_type=()
	declare -g -a __bl_argparse_result_value=()
	declare -g -a __bl_argparse_tree_expressions=()
	declare -g -a __bl_argparse_tree_expressions_type=()
	declare -g -a __bl_argparse_input_tokens=()
	declare -g -A __bl_argparse_values=()  # Array where validated input tokens are stored
	declare -g -a __bl_argparse_remaining=()  # Array where validated remaining type values are stored
	# Program documentation
	declare -g -a __bl_argparse_doc_description=()
	declare -g -a __bl_argparse_doc_examples_code=()
	declare -g -a __bl_argparse_examples_description=()
	declare -g -a __bl_argparse_doc_examples=()
	declare -g -a __bl_argparse_doc_section_descriptions=()
	declare -g -a __bl_argparse_doc_section_first_arg=()
	declare -g -a __bl_argparse_doc_argument_names=()
	declare -g -a __bl_argparse_doc_argument_descriptions=()
	declare -g -i __bl_argparse_doc_argument_max_size=0
	# Colors
	declare -g __bl_argparse_color_program_name="blue bold"
	declare -g __bl_argparse_color_header="white bold"
	declare -g __bl_argparse_color_main="red"
	declare -g __bl_argparse_color_optional="green"
	declare -g __bl_argparse_color_name="blue"
}

# vim: set ft=sh:
