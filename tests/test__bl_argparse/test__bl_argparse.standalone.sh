#!/usr/bin/env bash

# Generated using bashlib

[[ "${DEBUG:-0}" -eq 1 ]] && set -x

set -eu -o pipefail -o errtrace

__bl_get_main_paths () 
{ 
    local path;
    path="${BASH_SOURCE[-1]}";
    [[ "${path}" =~ ^[./] ]] || path="./${path}";
    __bl_program_path="${path%/*}";
    __bl_program_name="${path##*/}";
    if [[ "${__bl_sourced}" -eq 1 ]]; then
        __bl_bashlib_path="${BASH_SOURCE[-2]%/*}";
    fi
}

# Bashlib Modules:

__bl_constants_init () 
{ 
    local temp;
    printf -v temp "\t";
    declare -g __bl_character_tab="${temp}";
    printf -v temp "\n";
    declare -g __bl_character_newline="${temp}"
}

__bl_echo_color () 
{ 
    __bl_printf_or_echo_color echo "${@}"
}

__bl_argparse () 
{ 
    local input_expression;
    local -i last_tree_index;
    input_expression="${1}";
    if [[ -n "${input_expression}" ]]; then
        input_expression="(${input_expression} | :parameter:help:h:help:)";
        __bl_argparse_doc_add_section "Help";
        __bl_argparse_doc_add_parameter "-h|--help" "show program help and exit";
    else
        input_expression="([:parameter:help:h:help:])";
        __bl_argparse_doc_add_section "Help";
        __bl_argparse_doc_add_parameter "-h|--help" "show program help and exit";
    fi;
    shift;
    __bl_argparse_input_tokens=("${@}");
    __bl_argparse_build_tree_expressions "${input_expression}";
    last_tree_index="${#__bl_argparse_tree_expressions[@]}-1";
    if [[ "${#}" -eq 1 && "${1:-}" =~ ^(-h|--help)$ ]]; then
        __bl_argparse_show_help;
        exit 0;
    fi;
    if __bl_argparse_compare_expr_with_input_tokens 1 "${__bl_argparse_tree_expressions_type[last_tree_index]}" "${__bl_argparse_tree_expressions[last_tree_index]}" 0; then
        true;
    else
        __bl_echo_color red "Invalid input tokens.";
        echo;
        __bl_argparse_show_help;
        exit 1;
    fi
}

__bl_argparse_add_expression_to_tree () 
{ 
    local token;
    local -i index;
    token="${1}";
    if [[ "${token}" =~ ^:([0-9]+):$ ]]; then
        index="${BASH_REMATCH[1]}";
        __bl_argparse_tree_expressions_type+=("sequence");
        __bl_argparse_tree_expressions+=(":${index}:");
    else
        __bl_argparse_tree_expressions_type+=("primitive");
        __bl_argparse_tree_expressions+=("${1}");
    fi
}

__bl_argparse_add_result () 
{ 
    __bl_argparse_result_name+=("${1}");
    __bl_argparse_result_datatype+=("${2}");
    __bl_argparse_result_choices+=("${3}");
    __bl_argparse_result_short+=("${4}");
    __bl_argparse_result_long+=("${5}");
    __bl_argparse_result_type+=("${6}");
    __bl_argparse_result_value+=("${7}")
}

__bl_argparse_build_tree_expressions () 
{ 
    local __bl_arguments_definition;
    __bl_arguments_definition="${1}";
    __bl_argparse_tree_expressions=();
    __bl_argparse_tree_expressions_type=();
    while true; do
        __bl_argparse_reduce_grouped_expression "sequence" "(" ")" && continue;
        __bl_argparse_reduce_grouped_expression "optional" "[" "]" && continue;
        break;
    done
}

__bl_argparse_compare_expr_with_input_tokens () 
{ 
    local -a expression_tokens;
    local -a input_tokens;
    local -i expression_index;
    local -i first_run;
    local -i input_tokens_index;
    local -i valid_items_counter=0;
    local expression_token;
    local expression_type;
    first_run="${1}";
    expression_type="${2}";
    read -r -a expression_tokens <<< "${3}";
    input_tokens_index="${4}";
    input_tokens=("${__bl_argparse_input_tokens[@]:input_tokens_index}");
    if [[ first_run -eq 1 ]]; then
        __bl_argparse_result_name=();
        __bl_argparse_result_datatype=();
        __bl_argparse_result_choices=();
        __bl_argparse_result_short=();
        __bl_argparse_result_long=();
        __bl_argparse_result_type=();
        __bl_argparse_result_value=();
        __bl_argparse_remaining=();
        __bl_argparse_values=();
        local -a return_value=(0 0);
        shift;
        __bl_argparse_compare_expr_with_input_tokens 0 "${@}";
        __bl_argparse_result_reindex;
        if [[ "${return_value[0]}" -eq 0 ]] && [[ "${return_value[1]}" -eq "${#__bl_argparse_input_tokens[@]}" ]]; then
            __bl_argparse_store_values;
            return 0;
        else
            return 1;
        fi;
    fi;
    case "${expression_type}" in 
        "sequence")
            for expression_token in "${expression_tokens[@]}";
            do
                expression_index="${expression_token//:/}";
                __bl_argparse_compare_expr_with_input_tokens 0 "${__bl_argparse_tree_expressions_type[expression_index]}" "${__bl_argparse_tree_expressions[expression_index]}" "$(( input_tokens_index + valid_items_counter ))";
                if [[ "${return_value[0]}" -eq 0 ]]; then
                    valid_items_counter+="${return_value[1]}";
                    return_value=(0 "${valid_items_counter}");
                else
                    return_value=(1 0);
                    break;
                fi;
            done
        ;;
        "or")
            for expression_token in "${expression_tokens[@]}";
            do
                expression_index="${expression_token//:/}";
                __bl_argparse_compare_expr_with_input_tokens 0 "${__bl_argparse_tree_expressions_type[expression_index]}" "${__bl_argparse_tree_expressions[expression_index]}" "$(( input_tokens_index + valid_items_counter ))";
                if [[ "${return_value[0]}" -eq 0 ]] && [[ "${return_value[1]}" -eq "${#input_tokens[@]}" ]]; then
                    valid_items_counter="${return_value[1]}";
                    return_value=(0 "${valid_items_counter}");
                    return;
                fi;
            done;
            return_value=(1 0)
        ;;
        "primitive")
            if [[ "${#input_tokens[@]}" -eq 0 ]]; then
                return_value=(1 0);
            else
                if __bl_argparse_primitive_equals_input_token "${expression_tokens[0]}" "${input_tokens[@]}"; then
                    if [[ "${expression_tokens[0]}" == ":remaining:"* ]]; then
                        return_value=(0 "${#input_tokens[@]}");
                    else
                        return_value=(0 1);
                    fi;
                else
                    return_value=(1 0);
                fi;
            fi
        ;;
        "optional")
            if [[ "${#input_tokens[@]}" -eq 0 ]]; then
                return_value=(0 0);
            else
                expression_index="${expression_tokens[*]//:/}";
                __bl_argparse_compare_expr_with_input_tokens 0 "${__bl_argparse_tree_expressions_type[expression_index]}" "${__bl_argparse_tree_expressions[expression_index]}" "${input_tokens_index}";
                if [[ "${return_value[0]}" -eq 0 ]]; then
                    valid_items_counter="${return_value[1]}";
                    return_value=(0 "${valid_items_counter}");
                else
                    return_value=(0 0);
                fi;
            fi
        ;;
    esac
}

__bl_argparse_doc_add_parameter () 
{ 
    local name;
    local description;
    name="${1}";
    description="${2}";
    __bl_argparse_doc_argument_names+=("${name}");
    __bl_argparse_doc_argument_descriptions+=("${description}");
    [[ "${#name}" -gt __bl_argparse_doc_argument_max_size ]] && __bl_argparse_doc_argument_max_size="${#name}" || true
}

__bl_argparse_doc_add_section () 
{ 
    local name;
    local description;
    name="${1}";
    description="${2:-}";
    __bl_argparse_doc_section_names+=("${name}");
    __bl_argparse_doc_section_descriptions+=("${description}");
    __bl_argparse_doc_section_first_arg+=("${#__bl_argparse_doc_argument_names[@]}")
}

__bl_argparse_get_expression_tokens () 
{ 
    local expression="${1}";
    local -a tokens;
    local -i i;
    if ! [[ "${expression}" =~ ^:.+:$ ]]; then
        echo "invalid expression";
        return 1;
    fi;
    expression="${expression:1}";
    IFS=':' read -r -a tokens <<< "${expression}";
    case "${tokens[0]}" in 
        "literal")
            expression_data=("literal" "${tokens[1]}" "${tokens[2]:-${tokens[1]}}")
        ;;
        "variable")
            expression_data=("variable" "${tokens[1]}" "${tokens[2]:-str}" "${tokens[3]:-}")
        ;;
        "parameter")
            expression_data=("parameter" "${tokens[1]}" "${tokens[2]:-}" "${tokens[3]:-}")
        ;;
        "remaining")
            expression_data=("remaining" "${tokens[1]}" "${tokens[2]:-str}")
        ;;
    esac
}

__bl_argparse_get_primitive_tokens () 
{ 
    local primitive;
    local -a tokens;
    local -i i;
    primitive="${1}";
    read -r -a tokens <<< "${primitive//:/ }";
    case "${tokens[0]}" in 
        "literal")
            __bl_return="${tokens[2]}"
        ;;
        "variable")
            if [[ -n "${tokens[3]:-}" ]]; then
                __bl_return="{${tokens[1]}}:csv";
            else
                __bl_return="{${tokens[1]}}";
            fi
        ;;
        "parameter")
            __bl_return="-${tokens[2]}:or_symbol:--${tokens[3]}"
        ;;
        "remaining")
            __bl_return="{${tokens[1]}...}"
        ;;
    esac
}

__bl_argparse_init () 
{ 
    declare -g __bl_argparse_program_name;
    declare -g -a __bl_argparse_result_name;
    declare -g -a __bl_argparse_result_datatype;
    declare -g -a __bl_argparse_result_choices;
    declare -g -a __bl_argparse_result_short;
    declare -g -a __bl_argparse_result_long;
    declare -g -a __bl_argparse_result_type;
    declare -g -a __bl_argparse_result_value;
    declare -g -a __bl_argparse_tree_expressions;
    declare -g -a __bl_argparse_tree_expressions_type;
    declare -g -a __bl_argparse_input_tokens;
    declare -g -A __bl_argparse_values;
    declare -g -a __bl_argparse_remaining;
    declare -g -a __bl_argparse_doc_description=();
    declare -g -a __bl_argparse_doc_examples_code=();
    declare -g -a __bl_argparse_doc_examples_text=();
    declare -g -a __bl_argparse_doc_examples=();
    declare -g -a __bl_argparse_doc_section_descriptions=();
    declare -g -a __bl_argparse_doc_section_first_arg=();
    declare -g -a __bl_argparse_doc_argument_names=();
    declare -g -a __bl_argparse_doc_argument_descriptions=();
    declare -g -i __bl_argparse_doc_argument_max_size=0;
    declare -g __bl_argparse_color_program_name="blue bold";
    declare -g __bl_argparse_color_header="white bold";
    declare -g __bl_argparse_color_main="red";
    declare -g __bl_argparse_color_optional="green";
    declare -g __bl_argparse_color_name="blue"
}

__bl_argparse_is_data_type () 
{ 
    local _type;
    local data;
    _type="${1}";
    data="${2}";
    case "${_type}" in 
        "str")
            [[ "${#data}" -gt 0 ]]
        ;;
        "int")
            [[ "${data}" =~ ^[0-9]+$ ]]
        ;;
        *)
            return 1
        ;;
    esac
}

__bl_argparse_primitive_equals_input_token () 
{ 
    local expression;
    local -a input;
    local -a expression_data;
    local name data_type choices_csv short long;
    local input_token;
    expression="${1}";
    shift;
    input=("${@}");
    __bl_argparse_get_expression_tokens "${expression}";
    case "${expression_data[0]}" in 
        "literal")
            name="${expression_data[1]}";
            value="${expression_data[2]}";
            if [[ "${input[0]}" == "${value}" ]]; then
                __bl_argparse_add_result "${name}" "" "" "" "" "literal" "${value}";
            else
                return 1;
            fi
        ;;
        "remaining")
            name=${expression_data[1]};
            data_type=${expression_data[2]};
            for input_token in "${input[@]}";
            do
                if ! __bl_argparse_is_data_type "${data_type}" "${input_token}"; then
                    return 1;
                fi;
            done;
            __bl_argparse_add_result "${name}" "${data_type}" "" "" "" "remaining" "";
            __bl_argparse_remaining=("${input[@]}")
        ;;
        "variable")
            name=${expression_data[1]};
            data_type=${expression_data[2]};
            choices_csv=${expression_data[3]};
            if ! __bl_argparse_is_data_type "${data_type}" "${input[0]}"; then
                return 1;
            fi;
            if [[ "${#choices_csv}" -gt 0 ]]; then
                if ! [[ "${choices_csv}" =~ (^|.+,)"${input[0]}"(,.+|$) ]]; then
                    return 1;
                fi;
            fi;
            __bl_argparse_add_result "${name}" "${data_type}" "${choices_csv}" "" "" "variable" "${input[0]}"
        ;;
        "parameter")
            name="${expression_data[1]}";
            short="${expression_data[2]}";
            long="${expression_data[3]}";
            if ! [[ "${input[0]}" =~ ^(-${short}|--${long})$ ]]; then
                return 1;
            fi;
            __bl_argparse_add_result "${name}" "" "" "${short}" "${long}" "parameter" ""
        ;;
    esac
}

__bl_argparse_print_expressions_tree () 
{ 
    ( echo "Expressions_tree:";
    echo "Index Type Expression";
    for ((i=0; i<${#__bl_argparse_tree_expressions[@]}; i++ ))
    do
        echo "${i} ${__bl_argparse_tree_expressions_type[i]} ${__bl_argparse_tree_expressions[i]// /_}";
    done ) | column -t
}

__bl_argparse_print_parameters () 
{ 
    local -i ident;
    local -i index_start index_end;
    local -i argument_id;
    local -i current_ident;
    ident="${1}";
    index_start="${2}";
    index_end="${3}";
    __bl_argparse_doc_argument_max_size=0;
    current_ident=$(( ident + 2 ));
    for ((argument_id=index_start; argument_id<=index_end; argument_id++ ))
    do
        printf "%${current_ident}s" "";
        __bl_color "${__bl_argparse_color_name}";
        printf "%${__bl_argparse_doc_argument_max_size}s" "${__bl_argparse_doc_argument_names[argument_id]}";
        __bl_color;
        printf ": %s.\n" "${__bl_argparse_doc_argument_descriptions[argument_id]}";
    done
}

__bl_argparse_reduce_grouped_expression () 
{ 
    local group_type;
    local open_symbol;
    local close_symbol;
    local prefix postfix;
    local simple_group_expression;
    group_type="${1}";
    open_symbol="${2}";
    close_symbol="${3}";
    if [[ "${__bl_arguments_definition}" =~ (.*)("${open_symbol}")([^][()]+)(" "*"${close_symbol}")(.*) ]]; then
        prefix="${BASH_REMATCH[1]}";
        simple_group_expression="${BASH_REMATCH[3]}";
        postfix="${BASH_REMATCH[5]}";
        __bl_argparse_reduce_ungrouped_expression "${simple_group_expression}";
        __bl_argparse_tree_expressions_type+=("${group_type}");
        __bl_argparse_tree_expressions+=(":$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):");
        __bl_arguments_definition="${prefix}:$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):${postfix}";
    else
        return 1;
    fi
}

__bl_argparse_reduce_ungrouped_expression () 
{ 
    local -a tokens;
    local expression_new;
    local expression_type;
    local ungrouped_expression_string;
    ungrouped_expression_string="${1}";
    if [[ "${ungrouped_expression_string}" == *"|"* ]]; then
        expression_type="or";
    else
        read -r -a tokens <<< "${ungrouped_expression_string}";
        if [[ "${#tokens[@]}" -eq 1 ]]; then
            expression_type="primitive";
        else
            expression_type="sequence";
        fi;
    fi;
    case "${expression_type}" in 
        "primitive")
            __bl_argparse_add_expression_to_tree "${tokens[0]}"
        ;;
        "or")
            IFS="|" read -r -a tokens <<< "${ungrouped_expression_string}";
            for token in "${tokens[@]}";
            do
                __bl_argparse_reduce_ungrouped_expression "${token}";
                expression_new+=" :$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):";
            done;
            __bl_argparse_tree_expressions_type+=("or");
            __bl_argparse_tree_expressions+=("${expression_new# }")
        ;;
        "sequence")
            for token in "${tokens[@]}";
            do
                __bl_argparse_add_expression_to_tree "${token}";
                expression_new+=" :$(( ${#__bl_argparse_tree_expressions[@]} - 1 )):";
            done;
            __bl_argparse_tree_expressions_type+=("sequence");
            __bl_argparse_tree_expressions+=("${expression_new# }")
        ;;
    esac
}

__bl_argparse_result_reindex () 
{ 
    __bl_argparse_result_name=("${__bl_argparse_result_name[@]}");
    __bl_argparse_result_datatype=("${__bl_argparse_result_datatype[@]}");
    __bl_argparse_result_choices=("${__bl_argparse_result_choices[@]}");
    __bl_argparse_result_short=("${__bl_argparse_result_short[@]}");
    __bl_argparse_result_long=("${__bl_argparse_result_long[@]}");
    __bl_argparse_result_type=("${__bl_argparse_result_type[@]}");
    __bl_argparse_result_value=("${__bl_argparse_result_value[@]}")
}

__bl_argparse_show_help () 
{ 
    local -i section_id;
    local -i arguments_index_start;
    local -i arguments_index_end;
    local -i next_section_id;
    local -i i;
    __bl_echo_color "${__bl_argparse_color_header}" "Usage:";
    __bl_argparse_tree_to_string color;
    echo;
    __bl_echo_color "${__bl_argparse_color_header}" "Parameters:";
    if [[ "${#__bl_argparse_doc_section_names[@]}" -eq 1 ]]; then
        __bl_argparse_print_parameters 0 0 "${#__bl_argparse_doc_argument_names[@]}-1";
    else
        for ((section_id=0; section_id<${#__bl_argparse_doc_section_names[@]}; section_id++ ))
        do
            [[ section_id -gt 0 ]] && echo;
            __bl_printf_color "${__bl_argparse_color_name}" "  ${__bl_argparse_doc_section_names[section_id]}";
            if [[ -n "${__bl_argparse_doc_section_descriptions[section_id]}" ]]; then
                __bl_color;
                printf ": %s.\n" "${__bl_argparse_doc_section_descriptions[section_id]}";
            else
                __bl_color;
                printf "%s.\n" "";
            fi;
            arguments_index_start="${__bl_argparse_doc_section_first_arg[section_id]}";
            if [[ "${section_id}" -eq "${#__bl_argparse_doc_section_names[@]}-1" ]]; then
                arguments_index_end="${#__bl_argparse_doc_argument_names[@]}-1";
            else
                next_section_id="${section_id}+1";
                arguments_index_end="${__bl_argparse_doc_section_first_arg[next_section_id]}-1";
            fi;
            __bl_argparse_print_parameters 2 "${arguments_index_start}" "${arguments_index_end}";
        done;
    fi;
    if [[ "${#__bl_argparse_doc_description[@]}" -gt 0 ]]; then
        [[ "${#__bl_argparse_doc_description[@]}" -gt 0 ]] && echo;
        __bl_echo_color "${__bl_argparse_color_header}" "Description:";
        for ((i=0; i<${#__bl_argparse_doc_description[@]}; i++))
        do
            echo "  ${__bl_argparse_doc_description[i]}";
        done;
    fi;
    if [[ "${#__bl_argparse_doc_examples_code[@]}" -gt 0 ]]; then
        echo;
        __bl_echo_color "${__bl_argparse_color_header}" "Examples:";
        for ((i=0; i<${#__bl_argparse_doc_examples_code[@]}; i++ ))
        do
            __bl_printf_color "${__bl_argparse_color_name}" "  $ ${__bl_argparse_doc_examples_code[i]}";
            __bl_color;
            echo ": ${__bl_argparse_doc_examples_text[i]}.";
        done;
    fi
}

__bl_argparse_store_values () 
{ 
    local -i i;
    local name;
    local value;
    for ((i=0; i<${#__bl_argparse_result_type[@]}; i++ ))
    do
        name="${__bl_argparse_result_name[i]}";
        case "${__bl_argparse_result_type[i]}" in 
            "variable" | "literal")
                value="${__bl_argparse_result_value[i]}";
                __bl_argparse_values[${name}]="${value}"
            ;;
            "parameter" | "remaining")
                __bl_argparse_values[${name}]="set"
            ;;
        esac;
    done
}

__bl_argparse_string_clean () 
{ 
    while true; do
        [[ "${token}" =~ ^[[:blank:]]+(.*)$ ]] && token="${BASH_REMATCH[1]}" && continue;
        [[ "${token}" =~ ^(.*)[[:blank:]]+$ ]] && token="${BASH_REMATCH[1]}" && continue;
        [[ "${token}" =~ ^"("(.*)")"$ ]] && token="${BASH_REMATCH[1]}" && continue;
        if [[ "${token}" =~ ^(.*)"("([^"|()"]+)")"(.*)$ ]]; then
            token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}";
            continue;
        fi;
        if [[ "${token}" =~ ^(.*)"("('('[^"()"]+')')")"(.*)$ ]]; then
            token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}";
            continue;
        fi;
        if [[ "${token}" =~ ^(.*)"["('['[^][]+']')"]"(.*)$ ]]; then
            token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}";
            continue;
        fi;
        if [[ "${token}" =~ ^(.*["[("])[[:blank:]]+(.*)$ ]]; then
            token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}";
            continue;
        fi;
        if [[ "${token}" =~ ^(.*)[[:blank:]]+(['])'].*)$ ]]; then
            token="${BASH_REMATCH[1]}${BASH_REMATCH[2]}";
            continue;
        fi;
        if [[ "${token}" =~ ^(.*)[[:blank:]][[:blank:]]+(.*)$ ]]; then
            token="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}";
            continue;
        fi;
        break;
    done
}

__bl_argparse_tree_to_string () 
{ 
    local -i color;
    [[ "${1:-None}" == "color" ]] && color=1 || color=0;
    __bl_argparse_tree_to_string_real "${color}" 0 0 "${#__bl_argparse_tree_expressions[@]}-1"
}

__bl_argparse_tree_to_string_real () 
{ 
    function __bl_argparse_get_expression_index () 
    { 
        [[ "${1}" =~ ^:([0-9]+):$ ]] && next_index="${BASH_REMATCH[1]}"
    };
    local -i recursive_depth;
    local -i index;
    local -a tokens;
    local -i first_element=1;
    local -i optional_depth;
    local -i next_index;
    local return_text="";
    local token;
    local -i use_color;
    use_color="${1}";
    recursive_depth="${2}";
    optional_depth="${3}";
    index="${4}";
    read -r -a tokens <<< "${__bl_argparse_tree_expressions[index]}";
    token="${tokens[0]}";
    case "${__bl_argparse_tree_expressions_type[index]}" in 
        "sequence")
            [[ "${recursive_depth}" -gt 0 ]] && return_text+="(";
            for token in "${tokens[@]}";
            do
                [[ "${first_element}" -eq 0 ]] && return_text+=" ";
                __bl_argparse_get_expression_index "${token}";
                return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}" "${next_index}")";
                first_element=0;
            done;
            [[ "${recursive_depth}" -gt 0 ]] && return_text+=")"
        ;;
        "or")
            [[ "${recursive_depth}" -gt 1 ]] && return_text+="(";
            for token in "${tokens[@]}";
            do
                if [[ "${first_element}" -eq 0 ]]; then
                    if [[ "${recursive_depth}" -lt 2 ]]; then
                        return_text+=" ${__bl_character_tab} ";
                    else
                        return_text+=" | ";
                    fi;
                fi;
                __bl_argparse_get_expression_index "${token}";
                return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}" "${next_index}")";
                first_element=0;
            done;
            [[ "${recursive_depth}" -gt 1 ]] && return_text+=")"
        ;;
        "primitive")
            __bl_argparse_get_primitive_tokens "${token}";
            return_text="${__bl_return}"
        ;;
        "optional")
            [[ "${optional_depth}" -eq 0 && "${use_color}" -eq 1 ]] && return_text+=":color:optional:";
            return_text+="[";
            __bl_argparse_get_expression_index "${token}";
            return_text+="$(__bl_argparse_tree_to_string_real "${use_color}" "${recursive_depth}+1" "${optional_depth}+1" "${next_index}")";
            return_text+="]";
            [[ "${optional_depth}" -eq 0 && "${use_color}" -eq 1 ]] && return_text+=":color:main:"
        ;;
    esac;
    if [[ "${recursive_depth}" -eq 0 ]]; then
        tokens=();
        IFS="${__bl_character_tab}" read -r -a tokens <<< "${return_text}";
        for token in "${tokens[@]}";
        do
            __bl_argparse_string_clean;
            token="${token//:or_symbol:/|}";
            if [[ -t 1 ]]; then
                __bl_color "${__bl_argparse_color_main}";
                token="${token//:color:main:/"${__bl_return}"}";
                __bl_color "${__bl_argparse_color_optional}";
                token="${token//:color:optional:/"${__bl_return}"}";
            else
                token="${token//:color:main:/}";
                token="${token//:color:optional:/}";
            fi;
            if [[ "${use_color}" -eq 1 ]]; then
                printf "%s" "  ";
                if [[ -n "${__bl_argparse_program_name:-}" ]]; then
                    __bl_printf_color "${__bl_argparse_color_program_name}" "${__bl_argparse_program_name}";
                else
                    __bl_printf_color "${__bl_argparse_color_program_name}" "${__bl_program_name}";
                fi;
                __bl_color "${__bl_argparse_color_main}";
                echo -e " ${token}";
                __bl_color;
            else
                echo -e "${__bl_program_name} ${token}";
            fi;
        done;
    else
        echo "${return_text}";
    fi
}

__bl_color () 
{ 
    if [[ "${1:-None}" == "-f" ]]; then
        shift;
    else
        if ! [[ -t 1 ]]; then
            return;
        fi;
    fi;
    __bl_color_raw "${1:-}";
    printf "${__bl_return}"
}

__bl_color_raw () 
{ 
    local mode number;
    case "${1:-}" in 
        *bold*)
            mode=1
        ;;
        *dim*)
            mode=2
        ;;
        *underline*)
            mode=4
        ;;
        *blink*)
            mode=5
        ;;
        *reverse*)
            mode=7
        ;;
        *hidden*)
            mode=8
        ;;
        *)
            mode=0
        ;;
    esac;
    case "${1:-}" in 
        *white*)
            number="37"
        ;;
        *black*)
            number="30"
        ;;
        *red*)
            number="31"
        ;;
        *green*)
            number="32"
        ;;
        *yellow*)
            number="33"
        ;;
        *blue*)
            number="34"
        ;;
        *magenta*)
            number="35"
        ;;
        *cyan*)
            number="36"
        ;;
        *)
            number="0"
        ;;
    esac;
    printf -v __bl_return "%s" "\e[${mode};${number}m"
}

__bl_trap_error_init () 
{ 
    if [[ "${__bl_generate_standalone_interactive:-0}" -eq 0 ]]; then
        trap '__bl_trap_error_on_error $? 1' ERR SIGHUP SIGTERM;
        trap '__bl_trap_error_on_int   $?' SIGINT;
    fi
}

__bl_trap_error_on_error () 
{ 
    local -i ec;
    local -i show_line;
    local lines;
    ec="${1}";
    show_line="${2}";
    __bl_log critical "Exit code: ${ec}.";
    if [[ "${show_line}" -eq 1 ]]; then
        lines="Trace of errors produced on function(line):";
        for ((i=${#BASH_LINENO[@]}-2; i>=0; i-- ))
        do
            lines+=" ${FUNCNAME[i]}(${BASH_LINENO[i]})";
        done;
        __bl_log critical "${lines}";
        if [[ __bl_sourced -eq 0 ]]; then
            __bl_trap_error_print_line "${BASH_LINENO[0]}";
        fi;
    fi;
    exit "${ec}"
}

__bl_trap_error_on_int () 
{ 
    local -i ec;
    ec="${1}";
    __bl_log critical "User requested program termination.";
    __bl_trap_error_on_error "${ec}" 0
}

__bl_trap_error_print_line () 
{ 
    local -a text_array;
    local -i line i surrounding_lines;
    local arrow;
    surrounding_lines=6;
    line="${1}";
    readarray -t text_array < "${__bl_program_path}/${__bl_program_name}";
    for ((i=line-1-surrounding_lines; i<line+surrounding_lines; i++))
    do
        [[ i -ge 0 ]] || continue;
        [[ i -lt ${#text_array[@]} ]] || continue;
        [[ "${i}"+1 -eq "${line}" ]] && arrow=">>" || arrow="  ";
        __bl_log critical "${__bl_program_name}($(( i+1 ))):${arrow}${text_array[i]}";
    done
}

__bl_log () 
{ 
    local level;
    level="${1}";
    shift;
    if [[ "${__bl_log_levels[${level}]}" -ge "${__bl_log_level}" ]]; then
        case "${level}" in 
            debug)
                __bl_echo_color cyan "[${level}] ${*}"
            ;;
            info)
                __bl_echo_color green "[${level}] ${*}"
            ;;
            warning)
                __bl_echo_color yellow "[${level}] ${*}"
            ;;
            error)
                __bl_echo_color magenta "[${level}] ${*}"
            ;;
            critical)
                __bl_echo_color red "[${level}] ${*}"
            ;;
        esac;
    fi
}

__bl_log_init () 
{ 
    declare -g -A __bl_log_levels;
    declare -g -i __bl_log_level;
    __bl_log_levels=([debug]="0" [info]="1" [warning]="2" [error]="3" [critical]="4");
    __bl_log_level="2"
}

__bl_printf_or_echo_color () 
{ 
    local mode;
    local force;
    local color;
    mode="${1}";
    shift;
    if [[ "${1:-}" == '-f' ]]; then
        shift;
        force="-f";
    fi;
    color="${1}";
    shift;
    __bl_color ${force:-} "${color}";
    "${mode}" "${@}";
    __bl_color
}

__bl_initialize_common () 
{ 
    declare -g -i __bl_sourced;
    declare -g __bl_program_name;
    declare -g __bl_program_path;
    declare -g __bl_return;
    declare -g -a __bl_return_array=();
    declare -g -A __bl_return_asarray=();
    __bl_get_main_paths
}

# Bashlib initialization start
declare -g -i __bl_sourced=0
__bl_initialize_common
# Bashlib modules initialization
__bl_constants_init
unset -f '__bl_constants_init'
__bl_argparse_init
unset -f '__bl_argparse_init'
__bl_trap_error_init
unset -f '__bl_trap_error_init'
__bl_log_init
unset -f '__bl_log_init'
# Bashlib initialization end

# Main program

__bl_test_empty_input() {
	argparse_defs=""
	input_tokens=()
}

__bl_test_empty_input_error() {
	inverse=1
	argparse_defs=""
	input_tokens=( "a" )
}

__bl_test_empty_input_error2() {
	inverse=1
	argparse_defs=":literal:a:a:"
	input_tokens=()
}

__bl_test_literal() {
	argparse_defs=":literal:a:a:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} a"
}

__bl_test_literal_fail() {
	inverse=1
	argparse_defs=":literal:a:a:"
	input_tokens=( "b" )
}

__bl_test_parameter() {
	argparse_defs=":parameter:a:short:large:"
	input_tokens=( "-short" )
	expected_tree_text="${__bl_program_name} -short|--large"
}

__bl_test_variable() {
	argparse_defs=":variable:a:"
	input_tokens=( "random value" )
	expected_tree_text="${__bl_program_name} {a}"
}

__bl_test_variable_csv_1() {
	argparse_defs=":variable:myvar::a,b,c:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_csv_2() {
	argparse_defs=":variable:myvar::a,b,c:"
	input_tokens=( "c" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_csv_3() {
	inverse=1
	argparse_defs=":variable:myvar::a,b,c:"
	input_tokens=( "d" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_int() {
	argparse_defs=":variable:myvar:int:"
	input_tokens=( "1" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

__bl_test_variable_int_str() {
	inverse=1
	argparse_defs=":variable:myvar:int:"
	input_tokens=( "a" )
	expected_tree_text="${__bl_program_name} {myvar}"
}

data1() {
	argparse_defs+=":literal:mode:add: [:parameter:verbose:v:verbose:] (:parameter:add_all:a:all: | :remaining:files:)"
	argparse_defs+=" | "
	argparse_defs+=":literal:mode:commit: [:parameter:verbose:v:verbose:] :parameter:p_commit_message:m:message: :variable:commit_message:str:"

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
	local argparse_defs
	local -a input_tokens
	local expected_tree_text
	local obtained_tree_text
	local -i inverse
	local -i failed
	local -i exit_code=0

	for test in $(declare -F | grep -E "^declare -f __bl_test_.*$" | sed "s/^declare -f //" | sort -g || true); do
		expected_tree_text=""
		inverse=0
		argparse_defs=""

		# Load test
		"${test}"

		if [[ "${expected_tree_text}" ]]; then
			expected_tree_text+="${__bl_character_newline}${__bl_program_name} -h|--help"
		else
			expected_tree_text+="${__bl_program_name} [-h|--help]"
		fi

		__bl_argparse_input_tokens=( "${input_tokens[@]}" )

		# Add help section
		if [[ "${argparse_defs}" ]]; then
			argparse_defs="(${argparse_defs} | :parameter:help:h:help:)"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		else
			argparse_defs="([:parameter:help:h:help:])"
			__bl_argparse_doc_add_section "Help"
			__bl_argparse_doc_add_parameter "-h|--help"    "show program help and exit"
		fi

		__bl_argparse_build_tree_expressions "${argparse_defs}"
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
			__bl_echo_color boldred "test ${test} output text not equal to expected:"
				__bl_echo_color blue "expected text:"
				echo "${expected_tree_text}"
				__bl_echo_color blue "obtained text:"
				echo "${obtained_tree_text}"
			fi
		fi
		if [[ failed -ne 0 ]]; then
			exit_code=1
		fi
	done
	return "${exit_code}"
}


main "${@}"

# vim: set ft=sh:
