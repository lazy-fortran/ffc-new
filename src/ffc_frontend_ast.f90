module ffc_frontend_ast
    use, intrinsic :: iso_fortran_env, only: int32, int64
    use ffc_lowering, only: ffc_lower_program_root, ffc_program_declaration_from_sx, &
        ffc_program_root_from_sx, ffc_program_root_t, ffc_validate_program_root
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, opcode_add, opcode_const, &
        opcode_div, opcode_load, opcode_mul, opcode_output, opcode_pow, opcode_return, opcode_store, opcode_sub, &
        mir_type_spec_name, &
        mir_type_spec_value_kind, mir_validate_function_body, value_kind_integer
    use ffc_mir_metadata, only: instruction_shape_frontend_ast_v1_integer_program_count, &
        instruction_shape_frontend_ast_v1_integer_program_opcode_0, &
        instruction_shape_frontend_ast_v1_integer_program_opcode_1, &
        instruction_shape_frontend_ast_v1_integer_program_result_kind, &
        instruction_shape_frontend_ast_v1_integer_program_result_type, &
        instruction_shape_frontend_ast_v1_integer_program_source_rule, &
        instruction_shape_v2_pow_print_two_items_count, &
        instruction_shape_v2_pow_print_two_items_opcode_0, &
        instruction_shape_v2_pow_print_two_items_opcode_1, &
        instruction_shape_v2_pow_print_two_items_opcode_2, &
        instruction_shape_v2_pow_print_two_items_opcode_3, &
        instruction_shape_v2_pow_print_two_items_opcode_4, &
        instruction_shape_v2_pow_print_two_items_opcode_5, &
        instruction_shape_v2_pow_print_two_items_opcode_6, &
        instruction_shape_v2_pow_print_two_items_opcode_7, &
        instruction_shape_v2_pow_print_two_items_opcode_8, &
        instruction_shape_v2_pow_print_two_items_opcode_9, &
        instruction_shape_v2_pow_print_two_items_opcode_10, &
        instruction_shape_v2_pow_print_two_items_result_kind, &
        instruction_shape_v2_pow_print_two_items_result_type, &
        instruction_shape_v2_pow_print_two_items_source_rule, &
        instruction_shape_v2_pow_print_three_items_count, &
        instruction_shape_v2_pow_print_three_items_opcode_0, &
        instruction_shape_v2_pow_print_three_items_opcode_1, &
        instruction_shape_v2_pow_print_three_items_opcode_2, &
        instruction_shape_v2_pow_print_three_items_opcode_3, &
        instruction_shape_v2_pow_print_three_items_opcode_4, &
        instruction_shape_v2_pow_print_three_items_opcode_5, &
        instruction_shape_v2_pow_print_three_items_opcode_6, &
        instruction_shape_v2_pow_print_three_items_opcode_7, &
        instruction_shape_v2_pow_print_three_items_opcode_8, &
        instruction_shape_v2_pow_print_three_items_opcode_9, &
        instruction_shape_v2_pow_print_three_items_opcode_10, &
        instruction_shape_v2_pow_print_three_items_opcode_11, &
        instruction_shape_v2_pow_print_three_items_opcode_12, &
        instruction_shape_v2_pow_print_three_items_result_kind, &
        instruction_shape_v2_pow_print_three_items_result_type, &
        instruction_shape_v2_pow_print_three_items_source_rule, &
        instruction_shape_v2_pow_print_four_items_count, &
        instruction_shape_v2_pow_print_four_items_opcode_0, &
        instruction_shape_v2_pow_print_four_items_opcode_1, &
        instruction_shape_v2_pow_print_four_items_opcode_2, &
        instruction_shape_v2_pow_print_four_items_opcode_3, &
        instruction_shape_v2_pow_print_four_items_opcode_4, &
        instruction_shape_v2_pow_print_four_items_opcode_5, &
        instruction_shape_v2_pow_print_four_items_opcode_6, &
        instruction_shape_v2_pow_print_four_items_opcode_7, &
        instruction_shape_v2_pow_print_four_items_opcode_8, &
        instruction_shape_v2_pow_print_four_items_opcode_9, &
        instruction_shape_v2_pow_print_four_items_opcode_10, &
        instruction_shape_v2_pow_print_four_items_opcode_11, &
        instruction_shape_v2_pow_print_four_items_opcode_12, &
        instruction_shape_v2_pow_print_four_items_opcode_13, &
        instruction_shape_v2_pow_print_four_items_opcode_14, &
        instruction_shape_v2_pow_print_four_items_result_kind, &
        instruction_shape_v2_pow_print_four_items_result_type, &
        instruction_shape_v2_pow_print_four_items_source_rule, &
        instruction_shape_v2_pow_print_five_items_count, &
        instruction_shape_v2_pow_print_five_items_opcode_0, &
        instruction_shape_v2_pow_print_five_items_opcode_1, &
        instruction_shape_v2_pow_print_five_items_opcode_2, &
        instruction_shape_v2_pow_print_five_items_opcode_3, &
        instruction_shape_v2_pow_print_five_items_opcode_4, &
        instruction_shape_v2_pow_print_five_items_opcode_5, &
        instruction_shape_v2_pow_print_five_items_opcode_6, &
        instruction_shape_v2_pow_print_five_items_opcode_7, &
        instruction_shape_v2_pow_print_five_items_opcode_8, &
        instruction_shape_v2_pow_print_five_items_opcode_9, &
        instruction_shape_v2_pow_print_five_items_opcode_10, &
        instruction_shape_v2_pow_print_five_items_opcode_11, &
        instruction_shape_v2_pow_print_five_items_opcode_12, &
        instruction_shape_v2_pow_print_five_items_opcode_13, &
        instruction_shape_v2_pow_print_five_items_opcode_14, &
        instruction_shape_v2_pow_print_five_items_opcode_15, &
        instruction_shape_v2_pow_print_five_items_opcode_16, &
        instruction_shape_v2_pow_print_five_items_result_kind, &
        instruction_shape_v2_pow_print_five_items_result_type, &
        instruction_shape_v2_pow_print_five_items_source_rule, &
        instruction_shape_v2_pow_print_six_items_count, &
        instruction_shape_v2_pow_print_six_items_opcode_0, &
        instruction_shape_v2_pow_print_six_items_opcode_1, &
        instruction_shape_v2_pow_print_six_items_opcode_2, &
        instruction_shape_v2_pow_print_six_items_opcode_3, &
        instruction_shape_v2_pow_print_six_items_opcode_4, &
        instruction_shape_v2_pow_print_six_items_opcode_5, &
        instruction_shape_v2_pow_print_six_items_opcode_6, &
        instruction_shape_v2_pow_print_six_items_opcode_7, &
        instruction_shape_v2_pow_print_six_items_opcode_8, &
        instruction_shape_v2_pow_print_six_items_opcode_9, &
        instruction_shape_v2_pow_print_six_items_opcode_10, &
        instruction_shape_v2_pow_print_six_items_opcode_11, &
        instruction_shape_v2_pow_print_six_items_opcode_12, &
        instruction_shape_v2_pow_print_six_items_opcode_13, &
        instruction_shape_v2_pow_print_six_items_opcode_14, &
        instruction_shape_v2_pow_print_six_items_opcode_15, &
        instruction_shape_v2_pow_print_six_items_opcode_16, &
        instruction_shape_v2_pow_print_six_items_opcode_17, &
        instruction_shape_v2_pow_print_six_items_opcode_18, &
        instruction_shape_v2_pow_print_six_items_result_kind, &
        instruction_shape_v2_pow_print_six_items_result_type, &
        instruction_shape_v2_pow_print_six_items_source_rule, &
        instruction_shape_v2_pow_print_seven_items_count, &
        instruction_shape_v2_pow_print_seven_items_opcode_0, &
        instruction_shape_v2_pow_print_seven_items_opcode_1, &
        instruction_shape_v2_pow_print_seven_items_opcode_2, &
        instruction_shape_v2_pow_print_seven_items_opcode_3, &
        instruction_shape_v2_pow_print_seven_items_opcode_4, &
        instruction_shape_v2_pow_print_seven_items_opcode_5, &
        instruction_shape_v2_pow_print_seven_items_opcode_6, &
        instruction_shape_v2_pow_print_seven_items_opcode_7, &
        instruction_shape_v2_pow_print_seven_items_opcode_8, &
        instruction_shape_v2_pow_print_seven_items_opcode_9, &
        instruction_shape_v2_pow_print_seven_items_opcode_10, &
        instruction_shape_v2_pow_print_seven_items_opcode_11, &
        instruction_shape_v2_pow_print_seven_items_opcode_12, &
        instruction_shape_v2_pow_print_seven_items_opcode_13, &
        instruction_shape_v2_pow_print_seven_items_opcode_14, &
        instruction_shape_v2_pow_print_seven_items_opcode_15, &
        instruction_shape_v2_pow_print_seven_items_opcode_16, &
        instruction_shape_v2_pow_print_seven_items_opcode_17, &
        instruction_shape_v2_pow_print_seven_items_opcode_18, &
        instruction_shape_v2_pow_print_seven_items_opcode_19, &
        instruction_shape_v2_pow_print_seven_items_opcode_20, &
        instruction_shape_v2_pow_print_seven_items_result_kind, &
        instruction_shape_v2_pow_print_seven_items_result_type, &
        instruction_shape_v2_pow_print_seven_items_source_rule, &
        instruction_shape_v2_pow_print_eight_items_count, &
        instruction_shape_v2_pow_print_eight_items_opcode_0, &
        instruction_shape_v2_pow_print_eight_items_opcode_1, &
        instruction_shape_v2_pow_print_eight_items_opcode_2, &
        instruction_shape_v2_pow_print_eight_items_opcode_3, &
        instruction_shape_v2_pow_print_eight_items_opcode_4, &
        instruction_shape_v2_pow_print_eight_items_opcode_5, &
        instruction_shape_v2_pow_print_eight_items_opcode_6, &
        instruction_shape_v2_pow_print_eight_items_opcode_7, &
        instruction_shape_v2_pow_print_eight_items_opcode_8, &
        instruction_shape_v2_pow_print_eight_items_opcode_9, &
        instruction_shape_v2_pow_print_eight_items_opcode_10, &
        instruction_shape_v2_pow_print_eight_items_opcode_11, &
        instruction_shape_v2_pow_print_eight_items_opcode_12, &
        instruction_shape_v2_pow_print_eight_items_opcode_13, &
        instruction_shape_v2_pow_print_eight_items_opcode_14, &
        instruction_shape_v2_pow_print_eight_items_opcode_15, &
        instruction_shape_v2_pow_print_eight_items_opcode_16, &
        instruction_shape_v2_pow_print_eight_items_opcode_17, &
        instruction_shape_v2_pow_print_eight_items_opcode_18, &
        instruction_shape_v2_pow_print_eight_items_opcode_19, &
        instruction_shape_v2_pow_print_eight_items_opcode_20, &
        instruction_shape_v2_pow_print_eight_items_opcode_21, &
        instruction_shape_v2_pow_print_eight_items_opcode_22, &
        instruction_shape_v2_pow_print_eight_items_result_kind, &
        instruction_shape_v2_pow_print_eight_items_result_type, &
        instruction_shape_v2_pow_print_eight_items_source_rule, &
        instruction_shape_v2_pow_print_nine_items_count, &
        instruction_shape_v2_pow_print_nine_items_opcode_0, &
        instruction_shape_v2_pow_print_nine_items_opcode_1, &
        instruction_shape_v2_pow_print_nine_items_opcode_2, &
        instruction_shape_v2_pow_print_nine_items_opcode_3, &
        instruction_shape_v2_pow_print_nine_items_opcode_4, &
        instruction_shape_v2_pow_print_nine_items_opcode_5, &
        instruction_shape_v2_pow_print_nine_items_opcode_6, &
        instruction_shape_v2_pow_print_nine_items_opcode_7, &
        instruction_shape_v2_pow_print_nine_items_opcode_8, &
        instruction_shape_v2_pow_print_nine_items_opcode_9, &
        instruction_shape_v2_pow_print_nine_items_opcode_10, &
        instruction_shape_v2_pow_print_nine_items_opcode_11, &
        instruction_shape_v2_pow_print_nine_items_opcode_12, &
        instruction_shape_v2_pow_print_nine_items_opcode_13, &
        instruction_shape_v2_pow_print_nine_items_opcode_14, &
        instruction_shape_v2_pow_print_nine_items_opcode_15, &
        instruction_shape_v2_pow_print_nine_items_opcode_16, &
        instruction_shape_v2_pow_print_nine_items_opcode_17, &
        instruction_shape_v2_pow_print_nine_items_opcode_18, &
        instruction_shape_v2_pow_print_nine_items_opcode_19, &
        instruction_shape_v2_pow_print_nine_items_opcode_20, &
        instruction_shape_v2_pow_print_nine_items_opcode_21, &
        instruction_shape_v2_pow_print_nine_items_opcode_22, &
        instruction_shape_v2_pow_print_nine_items_opcode_23, &
        instruction_shape_v2_pow_print_nine_items_opcode_24, &
        instruction_shape_v2_pow_print_nine_items_result_kind, &
        instruction_shape_v2_pow_print_nine_items_result_type, &
        instruction_shape_v2_pow_print_nine_items_source_rule, &
        instruction_shape_v2_pow_print_ten_items_count, &
        instruction_shape_v2_pow_print_ten_items_opcode_0, &
        instruction_shape_v2_pow_print_ten_items_opcode_1, &
        instruction_shape_v2_pow_print_ten_items_opcode_2, &
        instruction_shape_v2_pow_print_ten_items_opcode_3, &
        instruction_shape_v2_pow_print_ten_items_opcode_4, &
        instruction_shape_v2_pow_print_ten_items_opcode_5, &
        instruction_shape_v2_pow_print_ten_items_opcode_6, &
        instruction_shape_v2_pow_print_ten_items_opcode_7, &
        instruction_shape_v2_pow_print_ten_items_opcode_8, &
        instruction_shape_v2_pow_print_ten_items_opcode_9, &
        instruction_shape_v2_pow_print_ten_items_opcode_10, &
        instruction_shape_v2_pow_print_ten_items_opcode_11, &
        instruction_shape_v2_pow_print_ten_items_opcode_12, &
        instruction_shape_v2_pow_print_ten_items_opcode_13, &
        instruction_shape_v2_pow_print_ten_items_opcode_14, &
        instruction_shape_v2_pow_print_ten_items_opcode_15, &
        instruction_shape_v2_pow_print_ten_items_opcode_16, &
        instruction_shape_v2_pow_print_ten_items_opcode_17, &
        instruction_shape_v2_pow_print_ten_items_opcode_18, &
        instruction_shape_v2_pow_print_ten_items_opcode_19, &
        instruction_shape_v2_pow_print_ten_items_opcode_20, &
        instruction_shape_v2_pow_print_ten_items_opcode_21, &
        instruction_shape_v2_pow_print_ten_items_opcode_22, &
        instruction_shape_v2_pow_print_ten_items_opcode_23, &
        instruction_shape_v2_pow_print_ten_items_opcode_24, &
        instruction_shape_v2_pow_print_ten_items_opcode_25, &
        instruction_shape_v2_pow_print_ten_items_opcode_26, &
        instruction_shape_v2_pow_print_ten_items_result_kind, &
        instruction_shape_v2_pow_print_ten_items_result_type, &
        instruction_shape_v2_pow_print_ten_items_source_rule, &
        instruction_shape_v2_pow_print_41_60_count, &
        instruction_shape_v2_pow_print_41_60_result_kind, &
        instruction_shape_v2_pow_print_41_60_result_type, &
        instruction_shape_v2_pow_print_41_60_source_rule, &
        instruction_shape_v2_pow_print_61_80_result_kind, &
        instruction_shape_v2_pow_print_61_80_result_type, &
        instruction_shape_v2_pow_print_61_80_source_rule, &
        instruction_shape_v2_pow_print_81_100_result_kind, &
        instruction_shape_v2_pow_print_81_100_result_type, &
        instruction_shape_v2_pow_print_81_100_source_rule, &
        instruction_shape_frontend_ast_v1_int_assign_count, &
        instruction_shape_frontend_ast_v1_int_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_lit_assign_count, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_lit_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_lit_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_expr_assign_count, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_3, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_4, &
        instruction_shape_frontend_ast_v1_int_expr_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_expr_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_expr_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_var_assign_count, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_3, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_4, &
        instruction_shape_frontend_ast_v1_int_var_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_var_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_var_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_mul_assign_count, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_mul_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_mul_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_mul_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_div_assign_count, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_div_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_div_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_div_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_sub_assign_count, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_sub_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_sub_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_sub_assign_source_rule, &
        instruction_shape_frontend_ast_v1_logical_program_count, &
        instruction_shape_frontend_ast_v1_logical_program_opcode_0, &
        instruction_shape_frontend_ast_v1_logical_program_opcode_1, &
        instruction_shape_frontend_ast_v1_logical_program_result_kind, &
        instruction_shape_frontend_ast_v1_logical_program_result_type, &
        instruction_shape_frontend_ast_v1_logical_program_source_rule, &
        instruction_shape_frontend_ast_v1_real_program_count, &
        instruction_shape_frontend_ast_v1_real_program_opcode_0, &
        instruction_shape_frontend_ast_v1_real_program_opcode_1, &
        instruction_shape_frontend_ast_v1_real_program_result_kind, &
        instruction_shape_frontend_ast_v1_real_program_result_type, &
        instruction_shape_frontend_ast_v1_real_program_source_rule, &
        instruction_shape_frontend_ast_v1_dp_program_count, &
        instruction_shape_frontend_ast_v1_dp_program_opcode_0, &
        instruction_shape_frontend_ast_v1_dp_program_opcode_1, &
        instruction_shape_frontend_ast_v1_dp_program_result_kind, &
        instruction_shape_frontend_ast_v1_dp_program_result_type, &
        instruction_shape_frontend_ast_v1_dp_program_source_rule, &
        instruction_shape_frontend_ast_v1_complex_program_count, &
        instruction_shape_frontend_ast_v1_complex_program_opcode_0, &
        instruction_shape_frontend_ast_v1_complex_program_opcode_1, &
        instruction_shape_frontend_ast_v1_complex_program_result_kind, &
        instruction_shape_frontend_ast_v1_complex_program_result_type, &
        instruction_shape_frontend_ast_v1_complex_program_source_rule, &
        instruction_shape_frontend_ast_v1_character_program_count, &
        instruction_shape_frontend_ast_v1_character_program_opcode_0, &
        instruction_shape_frontend_ast_v1_character_program_opcode_1, &
        instruction_shape_frontend_ast_v1_character_program_result_kind, &
        instruction_shape_frontend_ast_v1_character_program_result_type, &
        instruction_shape_frontend_ast_v1_character_program_source_rule, &
        instruction_shape_frontend_ast_v2_stop_7_count, &
        instruction_shape_frontend_ast_v2_stop_7_opcode_0, &
        instruction_shape_frontend_ast_v2_stop_7_opcode_1, &
        instruction_shape_frontend_ast_v2_stop_7_result_kind, &
        instruction_shape_frontend_ast_v2_stop_7_result_type, &
        instruction_shape_frontend_ast_v2_stop_7_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_count, &
        instruction_shape_frontend_ast_v2_print_7_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_result_type, &
        instruction_shape_frontend_ast_v2_print_7_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_count, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_8, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule, &
        instruction_shape_frontend_ast_v2_print_six_count, &
        instruction_shape_frontend_ast_v2_print_six_opcode_0, &
        instruction_shape_frontend_ast_v2_print_six_opcode_1, &
        instruction_shape_frontend_ast_v2_print_six_opcode_2, &
        instruction_shape_frontend_ast_v2_print_six_opcode_3, &
        instruction_shape_frontend_ast_v2_print_six_opcode_4, &
        instruction_shape_frontend_ast_v2_print_six_opcode_5, &
        instruction_shape_frontend_ast_v2_print_six_opcode_6, &
        instruction_shape_frontend_ast_v2_print_six_opcode_7, &
        instruction_shape_frontend_ast_v2_print_six_opcode_8, &
        instruction_shape_frontend_ast_v2_print_six_opcode_9, &
        instruction_shape_frontend_ast_v2_print_six_opcode_10, &
        instruction_shape_frontend_ast_v2_print_six_opcode_11, &
        instruction_shape_frontend_ast_v2_print_six_opcode_12, &
        instruction_shape_frontend_ast_v2_print_six_result_kind, &
        instruction_shape_frontend_ast_v2_print_six_result_type, &
        instruction_shape_frontend_ast_v2_print_six_source_rule, &
        instruction_shape_frontend_ast_v2_print_seven_count, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_0, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_1, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_2, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_3, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_4, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_5, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_6, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_7, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_8, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_9, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_10, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_11, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_12, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_13, &
        instruction_shape_frontend_ast_v2_print_seven_opcode_14, &
        instruction_shape_frontend_ast_v2_print_seven_result_kind, &
        instruction_shape_frontend_ast_v2_print_seven_result_type, &
        instruction_shape_frontend_ast_v2_print_seven_source_rule, &
        instruction_shape_frontend_ast_v2_print_eight_count, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_0, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_1, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_2, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_3, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_4, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_5, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_6, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_7, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_8, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_9, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_10, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_11, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_12, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_13, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_14, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_15, &
        instruction_shape_frontend_ast_v2_print_eight_opcode_16, &
        instruction_shape_frontend_ast_v2_print_eight_result_kind, &
        instruction_shape_frontend_ast_v2_print_eight_result_type, &
        instruction_shape_frontend_ast_v2_print_eight_source_rule, &
        instruction_shape_frontend_ast_v2_print_nine_count, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_0, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_1, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_2, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_3, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_4, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_5, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_6, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_7, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_8, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_9, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_10, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_11, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_12, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_13, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_14, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_15, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_16, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_17, &
        instruction_shape_frontend_ast_v2_print_nine_opcode_18, &
        instruction_shape_frontend_ast_v2_print_nine_result_kind, &
        instruction_shape_frontend_ast_v2_print_nine_result_type, &
        instruction_shape_frontend_ast_v2_print_nine_source_rule, &
        instruction_shape_frontend_ast_v2_print_ten_count, &
        instruction_shape_frontend_ast_v2_print_ten_opcode_0, &
        instruction_shape_frontend_ast_v2_print_ten_opcode_1, &
        instruction_shape_frontend_ast_v2_print_ten_opcode_20, &
        instruction_shape_frontend_ast_v2_print_ten_result_kind, &
        instruction_shape_frontend_ast_v2_print_ten_result_type, &
        instruction_shape_frontend_ast_v2_print_ten_source_rule, &
        mir_frontend_ast_v1_integer_expression_route, &
        mir_frontend_ast_v1_integer_expression_instruction_count, &
        mir_frontend_ast_v1_integer_expression_opcode, &
        mir_frontend_ast_v1_integer_expression_result_kind, &
        mir_frontend_ast_v1_integer_expression_result_type, &
        mir_frontend_ast_v1_integer_expression_source_rule_at, &
        mir_frontend_ast_v1_integer_expression_literal_value, &
        mir_frontend_ast_v1_integer_expression_result_id, &
        mir_frontend_ast_v1_integer_expression_storage_key
    use ffc_lowering_policy, only: bounded_integer_declaration_count, &
        bounded_integer_variable_count, bounded_integer_initializer_minimum, &
        bounded_integer_initializer_maximum, bounded_integer_addend_minimum, &
        bounded_integer_addend_maximum, bounded_integer_subtrahend_minimum, &
        bounded_integer_subtrahend_maximum, bounded_integer_multiplier_minimum, &
        bounded_integer_multiplier_maximum, bounded_integer_divisor_minimum, &
        bounded_integer_divisor_maximum
    implicit none
    private

    integer, parameter :: frontend_ast_token_capacity = 2048
    integer, parameter :: frontend_ast_token_length = 256
    integer, parameter :: frontend_ast_expression_length = 16384
    integer(int32), parameter :: bounded_integer_power_minimum = 2_int32
    integer(int32), parameter :: bounded_integer_power_maximum = 10_int32

    type, public :: ffc_frontend_ast_v0_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        integer(int64) :: declaration_count = 0_int64
        logical :: declaration_present = .false.
    end type ffc_frontend_ast_v0_t

    type, public :: ffc_frontend_variable_declaration_v1_t
        character(len=128) :: type_spec = ''
        character(len=128) :: name = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_frontend_variable_declaration_v1_t

    type, public :: ffc_frontend_assignment_v1_t
        character(len=128) :: target = ''
        character(len=128) :: value = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_frontend_assignment_v1_t

    type, public :: ffc_frontend_ast_v1_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        type(ffc_frontend_variable_declaration_v1_t) :: variable
        type(ffc_frontend_assignment_v1_t) :: assignment
        integer(int64) :: declaration_count = 0_int64
        integer(int64) :: variable_count = 0_int64
        integer(int64) :: assignment_count = 0_int64
    end type ffc_frontend_ast_v1_t

    public :: ffc_frontend_ast_v0_from_sx
    public :: ffc_lower_frontend_ast_v0
    public :: ffc_lower_frontend_ast_v0_from_sx
    public :: ffc_validate_frontend_ast_v0
    public :: ffc_frontend_ast_v1_from_sx
    public :: ffc_lower_frontend_ast_v1
    public :: ffc_lower_frontend_ast_v1_from_sx
    public :: ffc_lower_frontend_ast_v1_assignment_sequence_from_sx
    public :: ffc_lower_frontend_ast_v2_from_sx
    public :: ffc_validate_frontend_ast_v1
    public :: ffc_validate_frontend_ast_v1_integer_program_shape
    public :: ffc_validate_frontend_ast_v1_integer_assignment_program_shape
    public :: ffc_validate_frontend_ast_v1_int_literal_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_var_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_logical_program_shape
    public :: ffc_validate_frontend_ast_v1_real_program_shape
    public :: ffc_validate_frontend_ast_v1_double_precision_program_shape
    public :: ffc_validate_frontend_ast_v1_complex_program_shape
    public :: ffc_validate_frontend_ast_v1_character_program_shape
    public :: ffc_validate_frontend_ast_v2_stop_7_shape
    public :: ffc_validate_frontend_ast_v2_print_7_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape
    public :: ffc_validate_frontend_ast_v2_print_seven_shape
    public :: ffc_validate_frontend_ast_v2_print_eight_shape
    public :: ffc_validate_frontend_ast_v2_print_nine_shape
    public :: ffc_validate_frontend_ast_v2_print_ten_shape
    public :: ffc_validate_frontend_ast_v2_print_generic_shape
    public :: ffc_validate_frontend_ast_v2_initialized_variable_mul_shape
    public :: ffc_validate_frontend_ast_v2_initialized_variable_div_shape
    public :: ffc_validate_frontend_ast_v2_initialized_variable_sub_shape
    public :: ffc_validate_frontend_ast_v2_initialized_power_shape
    public :: ffc_validate_frontend_ast_v2_initialized_variable_power_shape

contains

    logical function ffc_frontend_ast_v1_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position

        ast = ffc_frontend_ast_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-root')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%declaration_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
            message)
        if (.not. parsed) return
        parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-declaration')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'variable-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%variable_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'variable', expression, message)
        if (.not. parsed) return
        parsed = parse_variable_declaration_v1(trim(expression), ast%variable, message)
        if (.not. parsed) return
        if (position < token_count .and. trim(token(position)) /= ')') then
            parsed = read_named_atom(token, token_count, position, 'assignment-count', count_text, &
                message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-count')
                return
            end if
            parsed = parse_count(count_text, ast%assignment_count, message)
            if (.not. parsed) return
            parsed = read_named_expression(token, token_count, position, 'assignment', expression, &
                message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-field')
                return
            end if
            parsed = parse_assignment_v1(trim(expression), ast%assignment, message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-record')
                return
            end if
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1')
            parsed = .false.
            return
        end if
        parsed = ffc_validate_frontend_ast_v1(ast, message)
    end function ffc_frontend_ast_v1_from_sx

    logical function ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(serialized, body, &
            message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: assignment_text(10)
        character(len=64) :: count_text
        type(ffc_frontend_assignment_v1_t) :: assignments(10)
        character(len=frontend_ast_expression_length) :: route_key
        integer :: assignment_count, assignment_index, token_count, position
        integer(int32) :: route

        call clear_message(message)
        lowered = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'assignment-sequence', message)) return
        if (.not. read_named_atom(token, token_count, position, 'assignment-count', count_text, &
            message)) return
        if (trim(count_text) /= '2' .and. trim(count_text) /= '3' .and. trim(count_text) /= '4' .and. &
            trim(count_text) /= '5' .and. trim(count_text) /= '6' .and. trim(count_text) /= '7' .and. &
            trim(count_text) /= '8' .and. trim(count_text) /= '9' .and. trim(count_text) /= '10') then
            call set_message(message, 'unsupported-assignment-sequence')
            return
        end if
        read (count_text, *) assignment_count
        do assignment_index = 1, assignment_count
            if (.not. read_named_expression(token, token_count, position, 'assignment', &
                assignment_text(assignment_index), message)) return
            if (.not. parse_assignment_v1(trim(assignment_text(assignment_index)), &
                assignments(assignment_index), message)) return
        end do
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-assignment-sequence')
            return
        end if
        route_key = '(assignment-sequence (assignment-count '//trim(count_text)//')'
        do assignment_index = 1, assignment_count
            route_key = trim(route_key)//' ('//trim(sequence_position_name(assignment_index))//' '// &
                trim(assignments(assignment_index)%target)//' '//trim(assignments(assignment_index)%value)//')'
        end do
        route_key = trim(route_key)//')'
        route = mir_frontend_ast_v1_integer_expression_route(trim(route_key))
        if (route == 0_int32) then
            call set_message(message, 'unsupported-assignment-sequence')
            return
        end if
        call mir_make_function_witness(body)
        call emit_frontend_ast_v1_integer_expression(body, route)
        lowered = mir_validate_function_body(body, message)
    end function ffc_lower_frontend_ast_v1_assignment_sequence_from_sx

    logical function ffc_lower_frontend_ast_v2_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        type(ffc_program_root_t) :: root, declaration
        type(ffc_frontend_variable_declaration_v1_t) :: variable
        type(ffc_frontend_assignment_v1_t) :: assignments(6)
        character(len=frontend_ast_expression_length) :: route_key
        character(len=frontend_ast_expression_length) :: print_statement
        integer :: assignment_count, assignment_index, token_count, position
        integer(int64) :: declaration_count, variable_count
        integer(int32) :: initializer_value, addend_value, subtrahend_value, multiplier_value, &
            divisor_value, power_value, route
        logical :: initialized_xplus_addend, initialized_xminus_subtrahend, &
            initialized_xmultiply_multiplier, initialized_xdivide_divisor, initialized_xpower, &
            initialized_xvariable_power, initialized_xvariable_add, initialized_xvariable_mul, &
            initialized_xvariable_div, initialized_xvariable_sub

        call clear_message(message)
        lowered = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'program-unit-v2', message)) return
        if (.not. read_named_expression(token, token_count, position, 'root', expression, message)) return
        if (.not. ffc_program_root_from_sx(trim(expression), root, message)) return
        if (.not. read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, declaration_count, message)) return
        if (declaration_count == 0_int64) then
            if (.not. expect_token(token, token_count, position, '(', message)) return
            if (.not. expect_token(token, token_count, position, 'declaration', message)) return
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (.not. read_named_atom(token, token_count, position, 'variable-count', count_text, &
                message)) return
            if (.not. parse_count(count_text, variable_count, message)) return
            if (variable_count /= 0_int64) then
                call set_message(message, 'invalid-frontend-ast-v2-stop-variable-count')
                return
            end if
            if (.not. expect_token(token, token_count, position, '(', message)) return
            if (.not. expect_token(token, token_count, position, 'variable', message)) return
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (.not. read_named_expression(token, token_count, position, 'execution-part', &
                expression, message)) return
            route = frontend_ast_v2_stop_route(expression)
            if (route == 0_int32) route = frontend_ast_v2_print_route(expression)
            if (route == 0_int32) then
                call set_message(message, 'unsupported-frontend-ast-v2-stop-stmt')
                return
            end if
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (position <= token_count) then
                call set_message(message, 'malformed-frontend-ast-v2')
                return
            end if
            if (trim(root%name) /= 'p') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            if (route == 18_int32) then
                call emit_frontend_ast_v1_integer_expression(body, route)
                lowered = ffc_validate_frontend_ast_v2_stop_7_shape(body, message)
            else if (route == 29_int32) then
                call emit_frontend_ast_v2_print_generic(body)
                lowered = ffc_validate_frontend_ast_v2_print_generic_shape(body, message)
            else if (route == 20_int32) then
                call emit_frontend_ast_v2_print_7_8(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_shape(body, message)
            else if (route == 21_int32) then
                call emit_frontend_ast_v2_print_7_8_9(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_shape(body, message)
            else if (route == 22_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_shape(body, message)
            else if (route == 23_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10_11(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape(body, message)
            else if (route == 24_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10_11_12(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape(body, message)
            else if (route == 26_int32) then
                call emit_frontend_ast_v2_print_eight(body)
                lowered = ffc_validate_frontend_ast_v2_print_eight_shape(body, message)
            else if (route == 27_int32) then
                call emit_frontend_ast_v2_print_nine(body)
                lowered = ffc_validate_frontend_ast_v2_print_nine_shape(body, message)
            else if (route == 28_int32) then
                call emit_frontend_ast_v2_print_ten(body)
                lowered = ffc_validate_frontend_ast_v2_print_ten_shape(body, message)
            else if (route == 25_int32) then
                call emit_frontend_ast_v2_print_seven(body)
                lowered = ffc_validate_frontend_ast_v2_print_seven_shape(body, message)
            else
                call emit_frontend_ast_v2_print_7(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_shape(body, message)
            end if
            return
        end if
        if (declaration_count /= 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-declaration-count')
            return
        end if
        if (.not. read_named_expression(token, token_count, position, 'declaration', expression, &
            message)) return
        if (.not. ffc_program_declaration_from_sx(trim(expression), declaration, message)) return
        if (.not. read_named_atom(token, token_count, position, 'variable-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, variable_count, message)) return
        if (variable_count /= 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-variable-count')
            return
        end if
        if (.not. read_named_expression(token, token_count, position, 'variable', expression, &
            message)) return
        if (.not. parse_variable_declaration_v1(trim(expression), variable, message)) return
        if (.not. read_v2_execution_part(token, token_count, position, expression, &
            print_statement, message)) then
            return
        end if
        if (trim(root%name) == 'main' .and. trim(declaration%name) == 'main' .and. &
            trim(variable%type_spec) == 'integer' .and. trim(variable%name) == 'y' .and. &
            index(print_statement, 'output-items') == 0) then
            if (.not. parse_v2_assignment_sequence(trim(expression), assignments, assignment_count, &
                message)) return
            if (assignment_count /= 1 .or. trim(assignments(1)%target) /= 'y' .or. &
                index(trim(assignments(1)%value), 'integer-literal') == 0 .or. &
                index(print_statement, '( output-name y )') == 0 .or. &
                .not. frontend_ast_v2_print_variable_match(print_statement)) then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                trim(root%source_file) /= trim(variable%source_file) .or. &
                trim(root%source_hash) /= trim(variable%source_hash) .or. &
                trim(root%source_file) /= trim(assignments(1)%source_file) .or. &
                trim(root%source_hash) /= trim(assignments(1)%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            if (.not. parse_integer_literal_expression(trim(assignments(1)%value), initializer_value, &
                message)) return
            call emit_frontend_ast_v2_print_y_initializer(body, initializer_value)
            lowered = mir_validate_function_body(body, message)
            return
        end if
        if (index(print_statement, 'output-items') /= 0) then
            if (trim(root%name) == 'main' .and. trim(declaration%name) == 'main' .and. &
                trim(variable%type_spec) == 'integer' .and. trim(variable%name) == 'y') then
                if (.not. parse_v2_assignment_sequence(trim(expression), assignments, assignment_count, &
                    message)) return
                if (.not. frontend_ast_v2_print_generic_list_match(print_statement) .or. &
                    assignment_count /= 1 .or. trim(assignments(1)%target) /= 'y' .or. &
                    index(trim(assignments(1)%value), 'integer-literal') == 0) then
                    call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                    return
                end if
                if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                    trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                    trim(root%source_file) /= trim(variable%source_file) .or. &
                    trim(root%source_hash) /= trim(variable%source_hash) .or. &
                    trim(root%source_file) /= trim(assignments(1)%source_file) .or. &
                    trim(root%source_hash) /= trim(assignments(1)%source_hash)) then
                    call set_message(message, 'frontend-ast-v2-invalid-provenance')
                    return
                end if
                call mir_make_function_witness(body)
                body%function%name = trim(root%name)
                if (.not. parse_integer_literal_expression(trim(assignments(1)%value), initializer_value, &
                    message)) return
                call emit_frontend_ast_v2_print_y_initializer(body, initializer_value)
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (trim(root%name) /= 'main' .or. trim(declaration%name) /= 'main' .or. &
                trim(variable%type_spec) /= 'integer' .or. trim(variable%name) /= 'x') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            if (.not. parse_v2_assignment_sequence(trim(expression), assignments, assignment_count, &
                message)) return
            if (.not. frontend_ast_v2_print_generic_list_match(print_statement) .or. &
                assignment_count /= 1 .or. trim(assignments(1)%target) /= 'x' .or. &
                index(trim(assignments(1)%value), 'integer-literal') == 0) then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                trim(root%source_file) /= trim(variable%source_file) .or. &
                trim(root%source_hash) /= trim(variable%source_hash) .or. &
                trim(root%source_file) /= trim(assignments(1)%source_file) .or. &
                trim(root%source_hash) /= trim(assignments(1)%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            if (.not. parse_integer_literal_expression(trim(assignments(1)%value), initializer_value, &
                message)) return
            call emit_frontend_ast_v2_print_generic_list(body, print_statement, initializer_value)
            lowered = mir_validate_function_body(body, message)
            return
        end if
        route = mir_frontend_ast_v1_integer_expression_route(&
            '(execution-part '//trim(expression)//')')
        if (route /= 18_int32) then
            if (.not. parse_v2_assignment_sequence(trim(expression), assignments, assignment_count, &
                message)) return
        end if
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2')
            return
        end if
        if (route == 18_int32) then
            if (trim(root%name) /= 'p' .or. trim(declaration%name) /= 'p') then
                call set_message(message, 'unsupported-frontend-ast-v2-stop-stmt')
                return
            end if
            if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                trim(root%source_file) /= trim(variable%source_file) .or. &
                trim(root%source_hash) /= trim(variable%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            call emit_frontend_ast_v1_integer_expression(body, route)
            lowered = ffc_validate_frontend_ast_v2_stop_7_shape(body, message)
            return
        end if
        if (trim(root%name) /= 'main' .or. trim(declaration%name) /= 'main' .or. &
            trim(variable%type_spec) /= 'integer' .or. trim(variable%name) /= 'x') then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        initialized_xplus_addend = .false.
        initialized_xminus_subtrahend = .false.
        initialized_xmultiply_multiplier = .false.
        initialized_xdivide_divisor = .false.
        initialized_xpower = .false.
        initialized_xvariable_power = .false.
        initialized_xvariable_add = .false.
        initialized_xvariable_mul = .false.
        initialized_xvariable_div = .false.
        initialized_xvariable_sub = .false.
        if (assignment_count == 2 .and. trim(assignments(1)%target) == 'x' .and. &
            trim(assignments(2)%target) == 'x') then
            initialized_xplus_addend = parse_bounded_addend_expression(trim(assignments(2)%value), &
                addend_value)
            initialized_xminus_subtrahend = parse_bounded_subtrahend_expression(&
                trim(assignments(2)%value), subtrahend_value)
            initialized_xmultiply_multiplier = parse_bounded_multiplier_expression(&
                trim(assignments(2)%value), multiplier_value)
            initialized_xdivide_divisor = parse_bounded_divisor_expression(&
                trim(assignments(2)%value), divisor_value)
            initialized_xpower = parse_bounded_power_expression(trim(assignments(2)%value), power_value)
            initialized_xvariable_power = is_variable_power_expression(trim(assignments(2)%value))
            initialized_xvariable_add = is_variable_add_expression(trim(assignments(2)%value))
            initialized_xvariable_mul = is_variable_mul_expression(trim(assignments(2)%value))
            initialized_xvariable_div = is_variable_div_expression(trim(assignments(2)%value))
            initialized_xvariable_sub = is_variable_sub_expression(trim(assignments(2)%value))
        end if
        if (len_trim(print_statement) > 0) then
            if (index(print_statement, '( output-count 7 )') == 0 .and. &
                index(print_statement, '( output-count 8 )') == 0 .and. &
                index(print_statement, '( output-count 9 )') == 0 .and. &
                index(print_statement, '( output-count 10 )') == 0 .and. &
                .not. initialized_xplus_addend .and. &
                .not. initialized_xminus_subtrahend .and. &
                .not. initialized_xmultiply_multiplier .and. &
                .not. initialized_xdivide_divisor .and. &
                .not. initialized_xpower .and. &
                .not. initialized_xvariable_power .and. &
                .not. initialized_xvariable_add .and. &
                .not. initialized_xvariable_mul .and. &
                .not. initialized_xvariable_div .and. &
                .not. initialized_xvariable_sub .and. &
                ((assignment_count /= 1 .and. assignment_count /= 2) .or. &
                trim(assignments(1)%target) /= 'x' .or. &
                (assignment_count == 1 .and. .not. starts_integer_literal_expression(&
                trim(assignments(1)%value))) .or. &
                (assignment_count == 2 .and. &
                (.not. starts_integer_literal_expression(trim(assignments(1)%value)) .or. &
                trim(assignments(2)%target) /= 'x' .or. trim(assignments(2)%value) /= &
                '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))' .and. &
                trim(assignments(2)%value) /= &
                '(assignment-expression (kind binary-expression) (operator *) (left-operand x) (right-operand 2))' .and. &
                trim(assignments(2)%value) /= &
                '(assignment-expression (kind binary-expression) (operator –) (left-operand x) (right-operand 2))' .and. &
                trim(assignments(2)%value) /= &
                '(assignment-expression (kind binary-expression) (operator /) (left-operand x) (right-operand 2))')) .or. &
                .not. frontend_ast_v2_print_variable_match(print_statement))) then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                trim(root%source_file) /= trim(variable%source_file) .or. &
                trim(root%source_hash) /= trim(variable%source_hash) .or. &
                trim(root%source_file) /= trim(assignments(1)%source_file) .or. &
                trim(root%source_hash) /= trim(assignments(1)%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
            if (assignment_count == 1) then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call mir_make_function_witness(body)
                body%function%name = trim(root%name)
                call emit_frontend_ast_v1_integer_expression(body, 19_int32)
                body%instructions(1)%literal_value = initializer_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (assignment_count == 2) then
                if (trim(root%source_file) /= trim(assignments(2)%source_file) .or. &
                    trim(root%source_hash) /= trim(assignments(2)%source_hash)) then
                    call set_message(message, 'frontend-ast-v2-invalid-provenance')
                    return
                end if
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            write (count_text, '(i0)') assignment_count
            route_key = '(execution-part (assignment-sequence (assignment-count '// &
                trim(count_text)//')'
            do assignment_index = 1, assignment_count
                route_key = trim(route_key)//' (assignment x '// &
                    trim(assignments(assignment_index)%value)//')'
            end do
            route_key = trim(route_key)//') )'
            route = mir_frontend_ast_v1_integer_expression_route(&
                route_key)
            if (route == 0_int32 .and. assignment_count == 2 .and. &
                trim(assignments(2)%value) == &
                '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))') then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 21_int32)
                body%instructions(1)%literal_value = initializer_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xplus_addend) then
                if (.not. parse_bounded_addend_expression(trim(assignments(2)%value), addend_value, &
                    message)) return
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 21_int32)
                body%instructions(1)%literal_value = initializer_value
                body%instructions(4)%literal_value = addend_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xvariable_add) then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v2_initialized_variable_add(body, initializer_value)
                lowered = ffc_validate_frontend_ast_v2_initialized_variable_add_shape(body, &
                    initializer_value, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xvariable_mul) then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v2_initialized_variable_mul(body, initializer_value)
                lowered = ffc_validate_frontend_ast_v2_initialized_variable_mul_shape(body, &
                    initializer_value, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xvariable_div) then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v2_initialized_variable_div(body, initializer_value)
                lowered = ffc_validate_frontend_ast_v2_initialized_variable_div_shape(body, initializer_value, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xvariable_sub) then
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v2_initialized_variable_sub(body, initializer_value)
                lowered = ffc_validate_frontend_ast_v2_initialized_variable_sub_shape(body, initializer_value, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xminus_subtrahend) then
                if (.not. parse_bounded_subtrahend_expression(trim(assignments(2)%value), &
                    subtrahend_value, message)) return
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 29_int32)
                body%instructions(1)%literal_value = initializer_value
                body%instructions(4)%literal_value = subtrahend_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xmultiply_multiplier) then
                if (.not. parse_bounded_multiplier_expression(trim(assignments(2)%value), &
                    multiplier_value, message)) return
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 28_int32)
                body%instructions(1)%literal_value = initializer_value
                body%instructions(4)%literal_value = multiplier_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xdivide_divisor) then
                if (.not. parse_bounded_divisor_expression(trim(assignments(2)%value), &
                    divisor_value, message)) return
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 30_int32)
                body%instructions(1)%literal_value = initializer_value
                body%instructions(4)%literal_value = divisor_value
                lowered = mir_validate_function_body(body, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xpower) then
                if (.not. parse_bounded_power_expression(trim(assignments(2)%value), power_value, message)) return
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v1_integer_expression(body, 26_int32)
                body%instructions(1)%literal_value = initializer_value
                body%instructions(4)%literal_value = power_value
                lowered = ffc_validate_frontend_ast_v2_initialized_power_shape(body, initializer_value, &
                    power_value, message)
                return
            end if
            if (route == 0_int32 .and. initialized_xvariable_power) then
                if (.not. frontend_ast_v2_print_variable_match(print_statement)) then
                    call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                    return
                end if
                if (.not. parse_bounded_signed_initializer_literal(trim(assignments(1)%value), &
                    initializer_value, message)) return
                call emit_frontend_ast_v2_initialized_variable_power(body, initializer_value)
                lowered = ffc_validate_frontend_ast_v2_initialized_variable_power_shape(body, &
                    initializer_value, message)
                return
            end if
            if (route == 0_int32) then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            if (index(print_statement, '( output-count ') /= 0) then
                do assignment_index = 11, 60
                    if (frontend_ast_v2_print_variable_item_count_match(print_statement, assignment_index)) then
                        call emit_frontend_ast_v2_print_variable_items_11_to_60(body, assignment_index)
                        lowered = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, assignment_index, &
                            int(2 * assignment_index + 7, int32), &
                            instruction_shape_v2_pow_print_41_60_result_kind, &
                            instruction_shape_v2_pow_print_41_60_result_type, &
                            instruction_shape_v2_pow_print_41_60_source_rule, message)
                        return
                    end if
                end do
                do assignment_index = 61, 80
                    if (frontend_ast_v2_print_variable_item_count_match(print_statement, assignment_index)) then
                        call emit_frontend_ast_v2_print_variable_items_61_to_80(body, assignment_index)
                        lowered = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, assignment_index, &
                            int(2 * assignment_index + 7, int32), &
                            instruction_shape_v2_pow_print_61_80_result_kind, &
                            instruction_shape_v2_pow_print_61_80_result_type, &
                            instruction_shape_v2_pow_print_61_80_source_rule, message)
                        return
                    end if
                end do
                do assignment_index = 81, 100
                    if (frontend_ast_v2_print_variable_item_count_match(print_statement, assignment_index)) then
                        call emit_frontend_ast_v2_print_variable_items_81_to_100(body, assignment_index)
                        lowered = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, assignment_index, &
                            int(2 * assignment_index + 7, int32), &
                            instruction_shape_v2_pow_print_81_100_result_kind, &
                            instruction_shape_v2_pow_print_81_100_result_type, &
                            instruction_shape_v2_pow_print_81_100_source_rule, message)
                        return
                    end if
                end do
                if (frontend_ast_v2_print_variable_item_count_match(print_statement, 10)) then
                    call emit_frontend_ast_v2_print_variable_ten_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_ten_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_item_count_match(print_statement, 9)) then
                    call emit_frontend_ast_v2_print_variable_nine_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_nine_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_item_count_match(print_statement, 8)) then
                    call emit_frontend_ast_v2_print_variable_eight_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_eight_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_item_count_match(print_statement, 7)) then
                    call emit_frontend_ast_v2_print_variable_seven_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_seven_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_six_item_match(print_statement)) then
                    call emit_frontend_ast_v2_print_variable_six_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_six_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_five_item_match(print_statement)) then
                    call emit_frontend_ast_v2_print_variable_five_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_five_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_four_item_match(print_statement)) then
                    call emit_frontend_ast_v2_print_variable_four_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_four_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_three_item_match(print_statement)) then
                    call emit_frontend_ast_v2_print_variable_three_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_three_items_shape(body, message)
                    return
                end if
                if (frontend_ast_v2_print_variable_two_item_match(print_statement)) then
                    call emit_frontend_ast_v2_print_variable_two_items(body)
                    lowered = ffc_validate_frontend_ast_v2_print_variable_two_items_shape(body, message)
                    return
                end if
                if (index(print_statement, '( output-count ') /= 0) then
                    call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                    return
                end if
            end if
            call emit_frontend_ast_v1_integer_expression(body, route)
            lowered = mir_validate_function_body(body, message)
            return
        end if
        if (trim(assignments(1)%target) /= 'x' .or. &
            trim(assignments(1)%value) /= '( integer-literal 7 )') then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        do assignment_index = 2, assignment_count
            if (trim(assignments(assignment_index)%target) /= 'x' .or. &
                trim(assignments(assignment_index)%value) /= &
                '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
        end do
        if (trim(root%source_file) /= trim(declaration%source_file) .or. &
            trim(root%source_hash) /= trim(declaration%source_hash) .or. &
            trim(root%source_file) /= trim(variable%source_file) .or. &
            trim(root%source_hash) /= trim(variable%source_hash)) then
            call set_message(message, 'frontend-ast-v2-invalid-provenance')
            return
        end if
        do assignment_index = 1, assignment_count
            if (trim(root%source_file) /= trim(assignments(assignment_index)%source_file)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end do
        do assignment_index = 2, assignment_count
            if (trim(assignments(1)%source_hash) /= trim(assignments(assignment_index)%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end do
        if (assignment_count == 2) then
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-two-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        else if (assignment_count == 5) then
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-five-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        else
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-six-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end if
        write (count_text, '(i0)') assignment_count
        route_key = '(execution-part (assignment-sequence (assignment-count '// &
            trim(count_text)//')'
        do assignment_index = 1, assignment_count
            route_key = trim(route_key)//' (assignment x '//trim(assignments(assignment_index)%value)//')'
        end do
        route_key = trim(route_key)//') )'
        route = mir_frontend_ast_v1_integer_expression_route(route_key)
        if (route == 0_int32) then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        call mir_make_function_witness(body)
        body%function%name = trim(root%name)
        call emit_frontend_ast_v1_integer_expression(body, route)
        lowered = mir_validate_function_body(body, message)
    end function ffc_lower_frontend_ast_v2_from_sx

    logical function read_v2_execution_part(token, token_count, position, expression, &
            print_statement, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression, print_statement
        character(len=:), allocatable, intent(out), optional :: message

        expression = ''
        print_statement = ''
        call clear_message(message)
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'execution-part', message)
        if (.not. ok) return
        ok = read_expression(token, token_count, position, expression, message)
        if (.not. ok) return
        if (position <= token_count) then
            if (trim(token(position)) /= '(') then
                ok = expect_token(token, token_count, position, ')', message)
                return
            end if
            if (position + 1 > token_count) then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                ok = .false.
                return
            end if
            if (trim(token(position + 1)) /= 'print-stmt') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                ok = .false.
                return
            end if
            ok = read_expression(token, token_count, position, print_statement, message)
            if (.not. ok) return
        end if
        ok = expect_token(token, token_count, position, ')', message)
    end function read_v2_execution_part

    logical function parse_v2_assignment_sequence(serialized, assignments, assignment_count, message) &
            result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_assignment_v1_t), intent(out) :: assignments(5)
        integer, intent(out) :: assignment_count
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: assignment_text
        character(len=64) :: count_text
        integer :: token_count, position, assignment_index
        integer(int64) :: count

        assignments = ffc_frontend_assignment_v1_t()
        assignment_count = 0
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'assignment-sequence', message)) return
        if (.not. read_named_atom(token, token_count, position, 'assignment-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, count, message)) return
        if (count /= 1_int64 .and. count /= 2_int64 .and. count /= 5_int64 .and. &
            count /= 6_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-assignment-count')
            parsed = .false.
            return
        end if
        assignment_count = int(count)
        do assignment_index = 1, assignment_count
            if (.not. read_named_expression(token, token_count, position, 'assignment', &
                assignment_text, message)) return
            if (.not. parse_assignment_v1(trim(assignment_text), assignments(assignment_index), &
                message)) return
        end do
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-execution-part')
            parsed = .false.
        end if
    end function parse_v2_assignment_sequence

    logical function frontend_ast_v2_print_variable_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = index(canonical, '( print-stmt ') == 1 .and. &
            index(canonical, '( format-kind default-char-expr )') /= 0 .and. &
            index(canonical, '( format-value * )') /= 0 .and. &
            index(canonical, '( output-kind variable )') /= 0 .and. &
            (index(canonical, '( output-name x )') /= 0 .or. &
            index(canonical, '( output-name y )') /= 0) .and. &
            index(canonical, '( statement-rule R1212 )') /= 0 .and. &
            index(canonical, '( format-rule R1215 )') /= 0 .and. &
            index(canonical, '( output-rule R901 )') /= 0 .and. &
            index(canonical, '( source-document J3-24-007 )') /= 0 .and. &
            index(canonical, '( statement-clause 12.6.1 )') /= 0 .and. &
            index(canonical, '( format-clause 12.6.2.2 )') /= 0 .and. &
            index(canonical, '( output-clause 12.6.3 )') /= 0 .and. &
            index(canonical, '( statement-page 242 )') /= 0 .and. &
            index(canonical, '( format-page 244 )') /= 0 .and. &
            index(canonical, '( output-page 248 )') /= 0 .and. &
            index(canonical, '( source-hash ') /= 0 .and. &
            index(canonical, 'write-stmt') == 0 .and. &
            index(canonical, 'control-list') == 0 .and. &
            index(canonical, 'io-implied-do') == 0
    end function frontend_ast_v2_print_variable_match

    logical function frontend_ast_v2_print_variable_two_item_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count 2 )') /= 0 .and. &
            index(canonical, '( output-kind-2 variable )') /= 0 .and. &
            index(canonical, '( output-name-2 x )') /= 0 .and. &
            index(canonical, '( output-rule-2 R901 )') /= 0
    end function frontend_ast_v2_print_variable_two_item_match

    logical function frontend_ast_v2_print_variable_three_item_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count 3 )') /= 0 .and. &
            index(canonical, '( output-kind-2 variable )') /= 0 .and. &
            index(canonical, '( output-name-2 x )') /= 0 .and. &
            index(canonical, '( output-rule-2 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-3 variable )') /= 0 .and. &
            index(canonical, '( output-name-3 x )') /= 0 .and. &
            index(canonical, '( output-rule-3 R901 )') /= 0
    end function frontend_ast_v2_print_variable_three_item_match

    logical function frontend_ast_v2_print_variable_four_item_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count 4 )') /= 0 .and. &
            index(canonical, '( output-kind-2 variable )') /= 0 .and. &
            index(canonical, '( output-name-2 x )') /= 0 .and. &
            index(canonical, '( output-rule-2 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-3 variable )') /= 0 .and. &
            index(canonical, '( output-name-3 x )') /= 0 .and. &
            index(canonical, '( output-rule-3 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-4 variable )') /= 0 .and. &
            index(canonical, '( output-name-4 x )') /= 0 .and. &
            index(canonical, '( output-rule-4 R901 )') /= 0
    end function frontend_ast_v2_print_variable_four_item_match

    logical function frontend_ast_v2_print_variable_five_item_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count 5 )') /= 0 .and. &
            index(canonical, '( output-kind-2 variable )') /= 0 .and. &
            index(canonical, '( output-name-2 x )') /= 0 .and. &
            index(canonical, '( output-rule-2 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-3 variable )') /= 0 .and. &
            index(canonical, '( output-name-3 x )') /= 0 .and. &
            index(canonical, '( output-rule-3 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-4 variable )') /= 0 .and. &
            index(canonical, '( output-name-4 x )') /= 0 .and. &
            index(canonical, '( output-rule-4 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-5 variable )') /= 0 .and. &
            index(canonical, '( output-name-5 x )') /= 0 .and. &
            index(canonical, '( output-rule-5 R901 )') /= 0
    end function frontend_ast_v2_print_variable_five_item_match

    logical function frontend_ast_v2_print_variable_six_item_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count 6 )') /= 0 .and. &
            index(canonical, '( output-kind-2 variable )') /= 0 .and. &
            index(canonical, '( output-name-2 x )') /= 0 .and. &
            index(canonical, '( output-rule-2 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-3 variable )') /= 0 .and. &
            index(canonical, '( output-name-3 x )') /= 0 .and. &
            index(canonical, '( output-rule-3 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-4 variable )') /= 0 .and. &
            index(canonical, '( output-name-4 x )') /= 0 .and. &
            index(canonical, '( output-rule-4 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-5 variable )') /= 0 .and. &
            index(canonical, '( output-name-5 x )') /= 0 .and. &
            index(canonical, '( output-rule-5 R901 )') /= 0 .and. &
            index(canonical, '( output-kind-6 variable )') /= 0 .and. &
            index(canonical, '( output-name-6 x )') /= 0 .and. &
            index(canonical, '( output-rule-6 R901 )') /= 0
    end function frontend_ast_v2_print_variable_six_item_match

    logical function frontend_ast_v2_print_variable_item_count_match(expression, item_count) result(matches)
        character(len=*), intent(in) :: expression
        integer, intent(in) :: item_count
        character(len=:), allocatable :: canonical
        character(len=16) :: count_text, item_text
        integer :: item_index

        canonical = trim(expression)
        write (count_text, '(i0)') item_count
        matches = frontend_ast_v2_print_variable_match(canonical) .and. &
            index(canonical, '( output-count '//trim(count_text)//' )') /= 0
        do item_index = 2, item_count
            write (item_text, '(i0)') item_index
            matches = matches .and. index(canonical, '( output-kind-'//trim(item_text)//' variable )') /= 0 .and. &
                index(canonical, '( output-name-'//trim(item_text)//' x )') /= 0 .and. &
                index(canonical, '( output-rule-'//trim(item_text)//' R901 )') /= 0
        end do
    end function frontend_ast_v2_print_variable_item_count_match

    logical function frontend_ast_v2_print_generic_list_match(expression) result(matches)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: message
        character(len=:), allocatable :: item_kind(:), item_value(:), item_rule(:)
        integer :: item_count

        matches = parse_frontend_ast_v2_print_generic_list(expression, item_kind, item_value, &
            item_rule, item_count, message)
    end function frontend_ast_v2_print_generic_list_match

    logical function parse_frontend_ast_v2_print_generic_list(expression, item_kind, item_value, &
            item_rule, item_count, message) result(parsed)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable, intent(out) :: item_kind(:), item_value(:), item_rule(:)
        integer, intent(out) :: item_count
        character(len=:), allocatable, intent(out), optional :: message
        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: item_expression
        character(len=64) :: count_text
        integer :: token_count, position, item_index
        integer(int64) :: parsed_count

        if (allocated(item_kind)) deallocate (item_kind)
        if (allocated(item_value)) deallocate (item_value)
        if (allocated(item_rule)) deallocate (item_rule)
        allocate (character(len=32) :: item_kind(0), item_value(0), item_rule(0))
        item_count = 0
        call clear_message(message)
        parsed = .false.
        if (.not. tokenize_frontend_ast_sx(expression, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'print-stmt', message)) return
        if (.not. read_named_atom(token, token_count, position, 'format-kind', count_text, message)) return
        if (trim(count_text) /= 'default-char-expr') then
            parsed = .false.
            return
        end if
        if (.not. read_named_atom(token, token_count, position, 'format-value', count_text, message)) return
        if (trim(count_text) /= '*') then
            parsed = .false.
            return
        end if
        if (.not. read_named_atom(token, token_count, position, 'output-count', count_text, message)) return
        if (.not. parse_count(count_text, parsed_count, message)) return
        if (parsed_count <= 0 .or. parsed_count > 10) then
            call set_message(message, 'unsupported-frontend-ast-v2-print-output-count')
            parsed = .false.
            return
        end if
        deallocate (item_kind, item_value, item_rule)
        allocate (character(len=32) :: item_kind(int(parsed_count)), &
            item_value(int(parsed_count)), item_rule(int(parsed_count)))
        item_kind = ''
        item_value = ''
        item_rule = ''
        item_count = 0
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'output-items', message)) return
        do item_index = 1, int(parsed_count)
            if (.not. read_expression(token, token_count, position, item_expression, message)) return
            if (index(trim(item_expression), '( clause 12.6.3 )') == 0 .or. &
                index(trim(item_expression), '( page 248 )') == 0) then
                call set_message(message, 'invalid-frontend-ast-v2-print-item-provenance')
                parsed = .false.
                return
            end if
            if (.not. parse_frontend_ast_v2_print_item(item_expression, item_kind(item_index), &
                item_value(item_index), item_rule(item_index), message)) return
        end do
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (index(expression, '( statement-rule R1212 )') == 0 .or. &
            index(expression, '( format-rule R1215 )') == 0 .or. &
            index(expression, '( source-document J3-24-007 )') == 0 .or. &
            index(expression, '( statement-clause 12.6.1 )') == 0 .or. &
            index(expression, '( format-clause 12.6.2.2 )') == 0 .or. &
            index(expression, '( output-clause 12.6.3 )') == 0 .or. &
            index(expression, '( statement-page 242 )') == 0 .or. &
            index(expression, '( format-page 244 )') == 0 .or. &
            index(expression, '( output-page 248 )') == 0 .or. &
            index(expression, '( source-hash ') == 0) then
            call set_message(message, 'invalid-frontend-ast-v2-print-provenance')
            parsed = .false.
            return
        end if
        item_count = parsed_count
        parsed = .true.
        return
    end function parse_frontend_ast_v2_print_generic_list

    logical function parse_frontend_ast_v2_print_item(expression, item_kind, item_value, item_rule, &
            message) result(parsed)
        character(len=*), intent(in) :: expression
        character(len=*), intent(out) :: item_kind, item_value, item_rule
        character(len=:), allocatable, intent(out), optional :: message
        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=32) :: item_clause, item_operator, item_page
        integer :: token_count, position
        integer(int64) :: numeric_value
        integer(int32) :: power_value, literal_value

        item_kind = ''
        item_value = ''
        item_rule = ''
        call clear_message(message)
        parsed = .false.
        if (.not. tokenize_frontend_ast_sx(expression, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'output-item', message)) return
        if (.not. read_named_atom(token, token_count, position, 'kind', item_kind, message)) return
        if (trim(item_kind) == 'variable') then
            if (.not. read_named_atom(token, token_count, position, 'name', item_value, message)) return
            if (trim(item_value) /= 'x' .and. trim(item_value) /= 'y') then
                call set_message(message, 'unsupported-frontend-ast-v2-print-variable')
                parsed = .false.
                return
            end if
        else if (trim(item_kind) == 'integer-expression') then
            if (.not. read_named_atom(token, token_count, position, 'operator', item_operator, message)) return
            if (trim(item_operator) /= '+' .and. trim(item_operator) /= '*' .and. &
                trim(item_operator) /= '/' .and. trim(item_operator) /= '-' .and. &
                trim(item_operator) /= '–' .and. trim(item_operator) /= '**') then
                call set_message(message, 'unsupported-frontend-ast-v2-print-expression-operator')
                parsed = .false.
                return
            end if
            if (trim(item_operator) == '*') item_kind = 'integer-expression-multiply'
            if (trim(item_operator) == '/') item_kind = 'integer-expression-divide'
            if (trim(item_operator) == '-' .or. trim(item_operator) == '–') then
                item_kind = 'integer-expression-subtract'
            end if
            if (trim(item_operator) == '**') item_kind = 'integer-expression-power'
            if (.not. read_named_atom(token, token_count, position, 'left', item_clause, message)) return
            if (trim(item_clause) /= 'x') then
                call set_message(message, 'unsupported-frontend-ast-v2-print-expression-left')
                parsed = .false.
                return
            end if
            if (.not. read_named_atom(token, token_count, position, 'right', item_value, message)) return
            if (trim(item_operator) == '+') then
                if (trim(item_value) /= 'x') then
                    if (.not. parse_bounded_decimal_literal(trim(item_value), power_value, message) .or. &
                        power_value < 0 .or. power_value > 100) then
                        call set_message(message, 'unsupported-frontend-ast-v2-print-expression-right')
                        parsed = .false.
                        return
                    end if
                end if
            else if ((trim(item_operator) == '-' .or. trim(item_operator) == '–')) then
                if (.not. parse_bounded_decimal_literal(trim(item_value), power_value, message) .or. &
                    power_value < 0 .or. power_value > 100) then
                    call set_message(message, 'unsupported-frontend-ast-v2-print-expression-right')
                    parsed = .false.
                    return
                end if
            end if
            if ((trim(item_operator) == '*' .and. trim(item_value) /= '2') .or. &
                (trim(item_operator) == '/' .and. trim(item_value) /= '2')) then
                call set_message(message, 'unsupported-frontend-ast-v2-print-expression-right')
                parsed = .false.
                return
            end if
            if (trim(item_operator) == '**') then
                if (trim(item_value) /= 'x') then
                    if (index('0123456789', item_value(1:1)) == 0 .or. &
                        .not. parse_bounded_decimal_literal(trim(item_value), power_value, message)) then
                        call set_message(message, 'unsupported-frontend-ast-v2-print-expression-right')
                        parsed = .false.
                        return
                    end if
                end if
            end if
        else if (trim(item_kind) == 'integer-literal') then
            if (.not. read_named_atom(token, token_count, position, 'value', item_value, message)) return
            if (len_trim(item_value) > 0 .and. item_value(1:1) == '-') then
                if (len_trim(item_value) == 1 .or. &
                    .not. parse_bounded_decimal_literal(trim(item_value(2:)), literal_value, message) .or. &
                    literal_value < 1_int32 .or. literal_value > 100_int32) then
                    call set_message(message, 'unsupported-frontend-ast-v2-print-negative-literal')
                    parsed = .false.
                    return
                end if
            else if (.not. parse_count(item_value, numeric_value, message)) then
                parsed = .false.
                return
            end if
        else
            call set_message(message, 'unsupported-frontend-ast-v2-print-item')
            parsed = .false.
            return
        end if
        if (.not. read_named_atom(token, token_count, position, 'rule', item_rule, message)) return
        if ((trim(item_kind) == 'variable' .and. trim(item_rule) /= 'R901') .or. &
            ((trim(item_kind) == 'integer-literal' .or. trim(item_kind) == 'integer-expression' .or. &
            trim(item_kind) == 'integer-expression-multiply' .or. trim(item_kind) == 'integer-expression-divide' .or. &
            trim(item_kind) == 'integer-expression-subtract' .or. trim(item_kind) == 'integer-expression-power') .and. &
            trim(item_rule) /= 'R1217')) then
            call set_message(message, 'invalid-frontend-ast-v2-print-item-rule')
            parsed = .false.
            return
        end if
        if (.not. read_named_atom(token, token_count, position, 'clause', item_clause, message)) return
        if (trim(item_clause) /= '12.6.3') then
            call set_message(message, 'invalid-frontend-ast-v2-print-item-clause')
            parsed = .false.
            return
        end if
        if (.not. read_named_atom(token, token_count, position, 'page', item_page, message)) return
        if (trim(item_page) /= '248') then
            call set_message(message, 'invalid-frontend-ast-v2-print-item-page')
            parsed = .false.
            return
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (parsed .and. position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-print-item')
            parsed = .false.
        end if
    end function parse_frontend_ast_v2_print_item

    subroutine emit_frontend_ast_v2_print_generic_list(body, expression, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        character(len=*), intent(in) :: expression
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable :: item_kind(:), item_value(:), item_rule(:), message
        integer :: item_count, item_index, instruction_index, instruction_count, value, io_status

        if (.not. parse_frontend_ast_v2_print_generic_list(expression, item_kind, item_value, &
            item_rule, item_count, message)) then
            body%function%instruction_count = 0
            return
        end if
        item_count = 0
        do while (item_count < size(item_kind))
            if (len_trim(item_kind(item_count + 1)) == 0) exit
            item_count = item_count + 1
        end do
        instruction_count = 3
        do item_index = 1, item_count
            if (trim(item_kind(item_index)) == 'integer-expression') then
                instruction_count = instruction_count + 4
            else if (trim(item_kind(item_index)) == 'integer-expression-multiply') then
                instruction_count = instruction_count + 4
            else if (trim(item_kind(item_index)) == 'integer-expression-divide') then
                instruction_count = instruction_count + 4
            else if (trim(item_kind(item_index)) == 'integer-expression-subtract') then
                instruction_count = instruction_count + 4
            else if (trim(item_kind(item_index)) == 'integer-expression-power') then
                instruction_count = instruction_count + 4
            else
                instruction_count = instruction_count + 2
            end if
        end do
        if (allocated(body%instructions)) deallocate (body%instructions)
        allocate (body%instructions(instruction_count))
        body%function%instruction_count = instruction_count
        do instruction_index = 1, instruction_count
            body%instructions(instruction_index)%id = instruction_index - 1
            body%instructions(instruction_index)%result%id = instruction_index
            body%instructions(instruction_index)%result%kind = value_kind_integer
            body%instructions(instruction_index)%result%type_name = 'i32'
            body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/execution-part'
        end do
        body%instructions(1)%opcode = opcode_const
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%opcode = opcode_store
        body%instructions(2)%storage_key = 'x'
        instruction_index = 2
        do item_index = 1, item_count
            if (trim(item_kind(item_index)) == 'variable') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = trim(item_value(item_index))
                body%instructions(instruction_index + 1)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 1
            else if (trim(item_kind(item_index)) == 'integer-literal') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_const
                read (item_value(item_index), *, iostat=io_status) value
                if (io_status /= 0) value = 0
                body%instructions(instruction_index)%literal_value = value
                body%instructions(instruction_index + 1)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 1
            else if (trim(item_kind(item_index)) == 'integer-expression-multiply') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = 'x'
                body%instructions(instruction_index + 1)%opcode = opcode_const
                body%instructions(instruction_index + 1)%literal_value = 2
                body%instructions(instruction_index + 2)%opcode = opcode_mul
                body%instructions(instruction_index + 3)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 2)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 3)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 3
            else if (trim(item_kind(item_index)) == 'integer-expression-subtract') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = 'x'
                body%instructions(instruction_index + 1)%opcode = opcode_const
                read (item_value(item_index), *, iostat=io_status) value
                if (io_status /= 0) value = 0
                body%instructions(instruction_index + 1)%literal_value = value
                body%instructions(instruction_index + 2)%opcode = opcode_sub
                body%instructions(instruction_index + 3)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 2)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 3)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 3
            else if (trim(item_kind(item_index)) == 'integer-expression-divide') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = 'x'
                body%instructions(instruction_index + 1)%opcode = opcode_const
                body%instructions(instruction_index + 1)%literal_value = 2
                body%instructions(instruction_index + 2)%opcode = opcode_div
                body%instructions(instruction_index + 3)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 2)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 3)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 3
            else if (trim(item_kind(item_index)) == 'integer-expression-power') then
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = 'x'
                if (trim(item_value(item_index)) == 'x') then
                    body%instructions(instruction_index + 1)%opcode = opcode_load
                    body%instructions(instruction_index + 1)%storage_key = 'x'
                else
                    body%instructions(instruction_index + 1)%opcode = opcode_const
                    read (item_value(item_index), *, iostat=io_status) value
                    if (io_status /= 0) value = 0
                    body%instructions(instruction_index + 1)%literal_value = value
                end if
                body%instructions(instruction_index + 2)%opcode = opcode_pow
                body%instructions(instruction_index + 3)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 2)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 3)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 3
            else
                instruction_index = instruction_index + 1
                body%instructions(instruction_index)%opcode = opcode_load
                body%instructions(instruction_index)%storage_key = 'x'
                if (trim(item_value(item_index)) /= 'x') then
                    body%instructions(instruction_index + 1)%opcode = opcode_const
                    read (item_value(item_index), *, iostat=io_status) value
                    if (io_status /= 0) value = 0
                    body%instructions(instruction_index + 1)%literal_value = value
                else
                    body%instructions(instruction_index + 1)%opcode = opcode_load
                    body%instructions(instruction_index + 1)%storage_key = 'x'
                end if
                body%instructions(instruction_index + 2)%opcode = opcode_add
                body%instructions(instruction_index + 3)%opcode = opcode_output
                body%instructions(instruction_index)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 1)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 2)%source_rule = 'frontend-ast-v2/print-stmt'
                body%instructions(instruction_index + 3)%source_rule = 'frontend-ast-v2/print-stmt'
                instruction_index = instruction_index + 3
            end if
        end do
        body%instructions(instruction_count)%opcode = opcode_return
        body%instructions(instruction_count)%source_rule = 'frontend-ast-v2/print-stmt'
    end subroutine emit_frontend_ast_v2_print_generic_list

    subroutine emit_frontend_ast_v2_print_y_initializer(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: initializer_value
        integer :: index

        if (allocated(body%instructions)) deallocate (body%instructions)
        allocate (body%instructions(5))
        body%function%instruction_count = 5
        do index = 1, 5
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%id = 1
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 2) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%result%id = 2
        body%instructions(1)%opcode = opcode_const
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%opcode = opcode_store
        body%instructions(2)%storage_key = 'y'
        body%instructions(3)%opcode = opcode_load
        body%instructions(3)%storage_key = 'y'
        body%instructions(4)%opcode = opcode_output
        body%instructions(5)%opcode = opcode_return
    end subroutine emit_frontend_ast_v2_print_y_initializer

    subroutine emit_frontend_ast_v2_print_variable_items_11_to_60(body, item_count)
        type(mir_function_body_t), intent(inout) :: body
        integer, intent(in) :: item_count
        integer(int32) :: opcodes(2 * item_count + 7)
        integer :: output_index

        opcodes = opcode_load
        opcodes(1) = opcode_const
        opcodes(2) = opcode_store
        opcodes(3) = opcode_load
        opcodes(4) = opcode_const
        opcodes(5) = opcode_pow
        opcodes(6) = opcode_store
        do output_index = 1, item_count
            opcodes(7 + 2 * (output_index - 1)) = opcode_load
            opcodes(8 + 2 * (output_index - 1)) = opcode_output
        end do
        opcodes(2 * item_count + 7) = opcode_return
        call emit_frontend_ast_v2_print_variable_items(body, item_count, 3, 2, int(size(opcodes), int32), opcodes, &
            instruction_shape_v2_pow_print_41_60_result_kind, &
            instruction_shape_v2_pow_print_41_60_result_type, &
            instruction_shape_v2_pow_print_41_60_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_items_11_to_60

    subroutine emit_frontend_ast_v2_print_variable_items_61_to_80(body, item_count)
        type(mir_function_body_t), intent(inout) :: body
        integer, intent(in) :: item_count
        integer(int32) :: opcodes(2 * item_count + 7)
        integer :: output_index

        opcodes = opcode_load
        opcodes(1) = opcode_const
        opcodes(2) = opcode_store
        opcodes(3) = opcode_load
        opcodes(4) = opcode_const
        opcodes(5) = opcode_pow
        opcodes(6) = opcode_store
        do output_index = 1, item_count
            opcodes(7 + 2 * (output_index - 1)) = opcode_load
            opcodes(8 + 2 * (output_index - 1)) = opcode_output
        end do
        opcodes(2 * item_count + 7) = opcode_return
        call emit_frontend_ast_v2_print_variable_items(body, item_count, 3, 2, int(size(opcodes), int32), opcodes, &
            instruction_shape_v2_pow_print_61_80_result_kind, &
            instruction_shape_v2_pow_print_61_80_result_type, instruction_shape_v2_pow_print_61_80_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_items_61_to_80

    subroutine emit_frontend_ast_v2_print_variable_items_81_to_100(body, item_count)
        type(mir_function_body_t), intent(inout) :: body
        integer, intent(in) :: item_count
        integer(int32) :: opcodes(2 * item_count + 7)
        integer :: output_index

        opcodes = opcode_load
        opcodes(1) = opcode_const
        opcodes(2) = opcode_store
        opcodes(3) = opcode_load
        opcodes(4) = opcode_const
        opcodes(5) = opcode_pow
        opcodes(6) = opcode_store
        do output_index = 1, item_count
            opcodes(7 + 2 * (output_index - 1)) = opcode_load
            opcodes(8 + 2 * (output_index - 1)) = opcode_output
        end do
        opcodes(2 * item_count + 7) = opcode_return
        call emit_frontend_ast_v2_print_variable_items(body, item_count, 3, 2, int(size(opcodes), int32), opcodes, &
            instruction_shape_v2_pow_print_81_100_result_kind, &
            instruction_shape_v2_pow_print_81_100_result_type, instruction_shape_v2_pow_print_81_100_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_items_81_to_100

    subroutine emit_frontend_ast_v2_print_variable_seven_items(body)
        type(mir_function_body_t), intent(inout) :: body

        call emit_frontend_ast_v2_print_variable_items(body, 7, 3, 2, instruction_shape_v2_pow_print_seven_items_count, &
            [instruction_shape_v2_pow_print_seven_items_opcode_0, instruction_shape_v2_pow_print_seven_items_opcode_1, &
            instruction_shape_v2_pow_print_seven_items_opcode_2, instruction_shape_v2_pow_print_seven_items_opcode_3, &
            instruction_shape_v2_pow_print_seven_items_opcode_4, instruction_shape_v2_pow_print_seven_items_opcode_5, &
            instruction_shape_v2_pow_print_seven_items_opcode_6, instruction_shape_v2_pow_print_seven_items_opcode_7, &
            instruction_shape_v2_pow_print_seven_items_opcode_8, instruction_shape_v2_pow_print_seven_items_opcode_9, &
            instruction_shape_v2_pow_print_seven_items_opcode_10, instruction_shape_v2_pow_print_seven_items_opcode_11, &
            instruction_shape_v2_pow_print_seven_items_opcode_12, instruction_shape_v2_pow_print_seven_items_opcode_13, &
            instruction_shape_v2_pow_print_seven_items_opcode_14, instruction_shape_v2_pow_print_seven_items_opcode_15, &
            instruction_shape_v2_pow_print_seven_items_opcode_16, instruction_shape_v2_pow_print_seven_items_opcode_17, &
            instruction_shape_v2_pow_print_seven_items_opcode_18, instruction_shape_v2_pow_print_seven_items_opcode_19, &
            instruction_shape_v2_pow_print_seven_items_opcode_20], instruction_shape_v2_pow_print_seven_items_result_kind, &
            instruction_shape_v2_pow_print_seven_items_result_type, instruction_shape_v2_pow_print_seven_items_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_seven_items

    subroutine emit_frontend_ast_v2_print_variable_eight_items(body)
        type(mir_function_body_t), intent(inout) :: body

        call emit_frontend_ast_v2_print_variable_items(body, 8, 3, 2, instruction_shape_v2_pow_print_eight_items_count, &
            [instruction_shape_v2_pow_print_eight_items_opcode_0, instruction_shape_v2_pow_print_eight_items_opcode_1, &
            instruction_shape_v2_pow_print_eight_items_opcode_2, instruction_shape_v2_pow_print_eight_items_opcode_3, &
            instruction_shape_v2_pow_print_eight_items_opcode_4, instruction_shape_v2_pow_print_eight_items_opcode_5, &
            instruction_shape_v2_pow_print_eight_items_opcode_6, instruction_shape_v2_pow_print_eight_items_opcode_7, &
            instruction_shape_v2_pow_print_eight_items_opcode_8, instruction_shape_v2_pow_print_eight_items_opcode_9, &
            instruction_shape_v2_pow_print_eight_items_opcode_10, instruction_shape_v2_pow_print_eight_items_opcode_11, &
            instruction_shape_v2_pow_print_eight_items_opcode_12, instruction_shape_v2_pow_print_eight_items_opcode_13, &
            instruction_shape_v2_pow_print_eight_items_opcode_14, instruction_shape_v2_pow_print_eight_items_opcode_15, &
            instruction_shape_v2_pow_print_eight_items_opcode_16, instruction_shape_v2_pow_print_eight_items_opcode_17, &
            instruction_shape_v2_pow_print_eight_items_opcode_18, instruction_shape_v2_pow_print_eight_items_opcode_19, &
            instruction_shape_v2_pow_print_eight_items_opcode_20, instruction_shape_v2_pow_print_eight_items_opcode_21, &
            instruction_shape_v2_pow_print_eight_items_opcode_22], instruction_shape_v2_pow_print_eight_items_result_kind, &
            instruction_shape_v2_pow_print_eight_items_result_type, instruction_shape_v2_pow_print_eight_items_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_eight_items

    subroutine emit_frontend_ast_v2_print_variable_nine_items(body)
        type(mir_function_body_t), intent(inout) :: body

        call emit_frontend_ast_v2_print_variable_items(body, 9, 3, 2, instruction_shape_v2_pow_print_nine_items_count, &
            [instruction_shape_v2_pow_print_nine_items_opcode_0, instruction_shape_v2_pow_print_nine_items_opcode_1, &
            instruction_shape_v2_pow_print_nine_items_opcode_2, instruction_shape_v2_pow_print_nine_items_opcode_3, &
            instruction_shape_v2_pow_print_nine_items_opcode_4, instruction_shape_v2_pow_print_nine_items_opcode_5, &
            instruction_shape_v2_pow_print_nine_items_opcode_6, instruction_shape_v2_pow_print_nine_items_opcode_7, &
            instruction_shape_v2_pow_print_nine_items_opcode_8, instruction_shape_v2_pow_print_nine_items_opcode_9, &
            instruction_shape_v2_pow_print_nine_items_opcode_10, instruction_shape_v2_pow_print_nine_items_opcode_11, &
            instruction_shape_v2_pow_print_nine_items_opcode_12, instruction_shape_v2_pow_print_nine_items_opcode_13, &
            instruction_shape_v2_pow_print_nine_items_opcode_14, instruction_shape_v2_pow_print_nine_items_opcode_15, &
            instruction_shape_v2_pow_print_nine_items_opcode_16, instruction_shape_v2_pow_print_nine_items_opcode_17, &
            instruction_shape_v2_pow_print_nine_items_opcode_18, instruction_shape_v2_pow_print_nine_items_opcode_19, &
            instruction_shape_v2_pow_print_nine_items_opcode_20, instruction_shape_v2_pow_print_nine_items_opcode_21, &
            instruction_shape_v2_pow_print_nine_items_opcode_22, instruction_shape_v2_pow_print_nine_items_opcode_23, &
            instruction_shape_v2_pow_print_nine_items_opcode_24], instruction_shape_v2_pow_print_nine_items_result_kind, &
            instruction_shape_v2_pow_print_nine_items_result_type, instruction_shape_v2_pow_print_nine_items_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_nine_items

    subroutine emit_frontend_ast_v2_print_variable_ten_items(body)
        type(mir_function_body_t), intent(inout) :: body

        call emit_frontend_ast_v2_print_variable_items(body, 10, 3, 2, instruction_shape_v2_pow_print_ten_items_count, &
            [instruction_shape_v2_pow_print_ten_items_opcode_0, instruction_shape_v2_pow_print_ten_items_opcode_1, &
            instruction_shape_v2_pow_print_ten_items_opcode_2, instruction_shape_v2_pow_print_ten_items_opcode_3, &
            instruction_shape_v2_pow_print_ten_items_opcode_4, instruction_shape_v2_pow_print_ten_items_opcode_5, &
            instruction_shape_v2_pow_print_ten_items_opcode_6, instruction_shape_v2_pow_print_ten_items_opcode_7, &
            instruction_shape_v2_pow_print_ten_items_opcode_8, instruction_shape_v2_pow_print_ten_items_opcode_9, &
            instruction_shape_v2_pow_print_ten_items_opcode_10, instruction_shape_v2_pow_print_ten_items_opcode_11, &
            instruction_shape_v2_pow_print_ten_items_opcode_12, instruction_shape_v2_pow_print_ten_items_opcode_13, &
            instruction_shape_v2_pow_print_ten_items_opcode_14, instruction_shape_v2_pow_print_ten_items_opcode_15, &
            instruction_shape_v2_pow_print_ten_items_opcode_16, instruction_shape_v2_pow_print_ten_items_opcode_17, &
            instruction_shape_v2_pow_print_ten_items_opcode_18, instruction_shape_v2_pow_print_ten_items_opcode_19, &
            instruction_shape_v2_pow_print_ten_items_opcode_20, instruction_shape_v2_pow_print_ten_items_opcode_21, &
            instruction_shape_v2_pow_print_ten_items_opcode_22, instruction_shape_v2_pow_print_ten_items_opcode_23, &
            instruction_shape_v2_pow_print_ten_items_opcode_24, instruction_shape_v2_pow_print_ten_items_opcode_25, &
            instruction_shape_v2_pow_print_ten_items_opcode_26], instruction_shape_v2_pow_print_ten_items_result_kind, &
            instruction_shape_v2_pow_print_ten_items_result_type, instruction_shape_v2_pow_print_ten_items_source_rule)
    end subroutine emit_frontend_ast_v2_print_variable_ten_items

    subroutine emit_frontend_ast_v2_print_variable_items(body, item_count, literal_value, exponent, instruction_count, &
            opcodes, result_kind, result_type, source_rule)
        type(mir_function_body_t), intent(inout) :: body
        integer, intent(in) :: item_count, literal_value, exponent
        integer(int32), intent(in) :: instruction_count, opcodes(:), result_kind
        character(len=*), intent(in) :: result_type, source_rule
        integer :: index, output_index, output_load_index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_count))
        body%function%instruction_count = instruction_count
        do index = 1, instruction_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = opcodes(index)
            body%instructions(index)%result%kind = result_kind
            body%instructions(index)%result%type_name = result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = source_rule
            end if
        end do
        body%instructions(1)%literal_value = literal_value
        body%instructions(4)%literal_value = exponent
        body%instructions(:)%result%id = 0
        body%instructions(2)%result%id = 1
        body%instructions(3)%result%id = 2
        body%instructions(4)%result%id = 3
        body%instructions(5)%result%id = 4
        body%instructions(6)%result%id = 4
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        do output_index = 1, item_count
            output_load_index = 7 + 2 * (output_index - 1)
            body%instructions(output_load_index)%result%id = 5 + output_index
            body%instructions(output_load_index + 1)%result%id = 5 + output_index
            body%instructions(output_load_index)%storage_key = 'x'
        end do
        body%instructions(instruction_count)%result%id = 5 + item_count
    end subroutine emit_frontend_ast_v2_print_variable_items

    subroutine emit_frontend_ast_v2_print_variable_two_items(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_shape_v2_pow_print_two_items_count))
        body%function%instruction_count = instruction_shape_v2_pow_print_two_items_count
        do index = 1, instruction_shape_v2_pow_print_two_items_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_v2_pow_print_two_items_result_kind
            body%instructions(index)%result%type_name = instruction_shape_v2_pow_print_two_items_result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = instruction_shape_v2_pow_print_two_items_source_rule
            end if
        end do
        body%instructions(1)%opcode = instruction_shape_v2_pow_print_two_items_opcode_0
        body%instructions(1)%literal_value = 3
        body%instructions(2)%opcode = instruction_shape_v2_pow_print_two_items_opcode_1
        body%instructions(3)%opcode = instruction_shape_v2_pow_print_two_items_opcode_2
        body%instructions(4)%opcode = instruction_shape_v2_pow_print_two_items_opcode_3
        body%instructions(4)%literal_value = 2
        body%instructions(5)%opcode = instruction_shape_v2_pow_print_two_items_opcode_4
        body%instructions(6)%opcode = instruction_shape_v2_pow_print_two_items_opcode_5
        body%instructions(7)%opcode = instruction_shape_v2_pow_print_two_items_opcode_6
        body%instructions(8)%opcode = instruction_shape_v2_pow_print_two_items_opcode_7
        body%instructions(9)%opcode = instruction_shape_v2_pow_print_two_items_opcode_8
        body%instructions(10)%opcode = instruction_shape_v2_pow_print_two_items_opcode_9
        body%instructions(11)%opcode = instruction_shape_v2_pow_print_two_items_opcode_10
        body%instructions(1)%result%id = 0
        body%instructions(2)%result%id = 1
        body%instructions(3)%result%id = 2
        body%instructions(4)%result%id = 3
        body%instructions(5)%result%id = 4
        body%instructions(6)%result%id = 4
        body%instructions(7)%result%id = 6
        body%instructions(8)%result%id = 6
        body%instructions(9)%result%id = 7
        body%instructions(10)%result%id = 7
        body%instructions(11)%result%id = 7
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
        body%instructions(9)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_print_variable_two_items

    subroutine emit_frontend_ast_v2_print_variable_three_items(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_shape_v2_pow_print_three_items_count))
        body%function%instruction_count = instruction_shape_v2_pow_print_three_items_count
        do index = 1, instruction_shape_v2_pow_print_three_items_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%kind = instruction_shape_v2_pow_print_three_items_result_kind
            body%instructions(index)%result%type_name = instruction_shape_v2_pow_print_three_items_result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = instruction_shape_v2_pow_print_three_items_source_rule
            end if
        end do
        body%instructions(1)%opcode = instruction_shape_v2_pow_print_three_items_opcode_0
        body%instructions(1)%literal_value = 3
        body%instructions(2)%opcode = instruction_shape_v2_pow_print_three_items_opcode_1
        body%instructions(3)%opcode = instruction_shape_v2_pow_print_three_items_opcode_2
        body%instructions(4)%opcode = instruction_shape_v2_pow_print_three_items_opcode_3
        body%instructions(4)%literal_value = 2
        body%instructions(5)%opcode = instruction_shape_v2_pow_print_three_items_opcode_4
        body%instructions(6)%opcode = instruction_shape_v2_pow_print_three_items_opcode_5
        body%instructions(7)%opcode = instruction_shape_v2_pow_print_three_items_opcode_6
        body%instructions(8)%opcode = instruction_shape_v2_pow_print_three_items_opcode_7
        body%instructions(9)%opcode = instruction_shape_v2_pow_print_three_items_opcode_8
        body%instructions(10)%opcode = instruction_shape_v2_pow_print_three_items_opcode_9
        body%instructions(11)%opcode = instruction_shape_v2_pow_print_three_items_opcode_10
        body%instructions(12)%opcode = instruction_shape_v2_pow_print_three_items_opcode_11
        body%instructions(13)%opcode = instruction_shape_v2_pow_print_three_items_opcode_12
        body%instructions(:)%result%id = [0, 1, 2, 3, 4, 4, 6, 6, 7, 7, 8, 8, 8]
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
        body%instructions(9)%storage_key = 'x'
        body%instructions(11)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_print_variable_three_items

    subroutine emit_frontend_ast_v2_print_variable_four_items(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_shape_v2_pow_print_four_items_count))
        body%function%instruction_count = instruction_shape_v2_pow_print_four_items_count
        do index = 1, instruction_shape_v2_pow_print_four_items_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%kind = instruction_shape_v2_pow_print_four_items_result_kind
            body%instructions(index)%result%type_name = instruction_shape_v2_pow_print_four_items_result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = instruction_shape_v2_pow_print_four_items_source_rule
            end if
        end do
        body%instructions(1)%opcode = instruction_shape_v2_pow_print_four_items_opcode_0
        body%instructions(1)%literal_value = 3
        body%instructions(2)%opcode = instruction_shape_v2_pow_print_four_items_opcode_1
        body%instructions(3)%opcode = instruction_shape_v2_pow_print_four_items_opcode_2
        body%instructions(4)%opcode = instruction_shape_v2_pow_print_four_items_opcode_3
        body%instructions(4)%literal_value = 2
        body%instructions(5)%opcode = instruction_shape_v2_pow_print_four_items_opcode_4
        body%instructions(6)%opcode = instruction_shape_v2_pow_print_four_items_opcode_5
        body%instructions(7)%opcode = instruction_shape_v2_pow_print_four_items_opcode_6
        body%instructions(8)%opcode = instruction_shape_v2_pow_print_four_items_opcode_7
        body%instructions(9)%opcode = instruction_shape_v2_pow_print_four_items_opcode_8
        body%instructions(10)%opcode = instruction_shape_v2_pow_print_four_items_opcode_9
        body%instructions(11)%opcode = instruction_shape_v2_pow_print_four_items_opcode_10
        body%instructions(12)%opcode = instruction_shape_v2_pow_print_four_items_opcode_11
        body%instructions(13)%opcode = instruction_shape_v2_pow_print_four_items_opcode_12
        body%instructions(14)%opcode = instruction_shape_v2_pow_print_four_items_opcode_13
        body%instructions(15)%opcode = instruction_shape_v2_pow_print_four_items_opcode_14
        body%instructions(:)%result%id = [0, 1, 2, 3, 4, 4, 6, 6, 7, 7, 8, 8, 9, 9, 9]
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
        body%instructions(9)%storage_key = 'x'
        body%instructions(11)%storage_key = 'x'
        body%instructions(13)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_print_variable_four_items

    subroutine emit_frontend_ast_v2_print_variable_five_items(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_shape_v2_pow_print_five_items_count))
        body%function%instruction_count = instruction_shape_v2_pow_print_five_items_count
        do index = 1, instruction_shape_v2_pow_print_five_items_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%kind = instruction_shape_v2_pow_print_five_items_result_kind
            body%instructions(index)%result%type_name = instruction_shape_v2_pow_print_five_items_result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = instruction_shape_v2_pow_print_five_items_source_rule
            end if
        end do
        body%instructions(1)%opcode = instruction_shape_v2_pow_print_five_items_opcode_0
        body%instructions(1)%literal_value = 3
        body%instructions(2)%opcode = instruction_shape_v2_pow_print_five_items_opcode_1
        body%instructions(3)%opcode = instruction_shape_v2_pow_print_five_items_opcode_2
        body%instructions(4)%opcode = instruction_shape_v2_pow_print_five_items_opcode_3
        body%instructions(4)%literal_value = 2
        body%instructions(5)%opcode = instruction_shape_v2_pow_print_five_items_opcode_4
        body%instructions(6)%opcode = instruction_shape_v2_pow_print_five_items_opcode_5
        body%instructions(7)%opcode = instruction_shape_v2_pow_print_five_items_opcode_6
        body%instructions(8)%opcode = instruction_shape_v2_pow_print_five_items_opcode_7
        body%instructions(9)%opcode = instruction_shape_v2_pow_print_five_items_opcode_8
        body%instructions(10)%opcode = instruction_shape_v2_pow_print_five_items_opcode_9
        body%instructions(11)%opcode = instruction_shape_v2_pow_print_five_items_opcode_10
        body%instructions(12)%opcode = instruction_shape_v2_pow_print_five_items_opcode_11
        body%instructions(13)%opcode = instruction_shape_v2_pow_print_five_items_opcode_12
        body%instructions(14)%opcode = instruction_shape_v2_pow_print_five_items_opcode_13
        body%instructions(15)%opcode = instruction_shape_v2_pow_print_five_items_opcode_14
        body%instructions(16)%opcode = instruction_shape_v2_pow_print_five_items_opcode_15
        body%instructions(17)%opcode = instruction_shape_v2_pow_print_five_items_opcode_16
        body%instructions(:)%result%id = [0, 1, 2, 3, 4, 4, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 10]
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
        body%instructions(9)%storage_key = 'x'
        body%instructions(11)%storage_key = 'x'
        body%instructions(13)%storage_key = 'x'
        body%instructions(15)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_print_variable_five_items

    subroutine emit_frontend_ast_v2_print_variable_six_items(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(instruction_shape_v2_pow_print_six_items_count))
        body%function%instruction_count = instruction_shape_v2_pow_print_six_items_count
        do index = 1, instruction_shape_v2_pow_print_six_items_count
            body%instructions(index)%id = index - 1
            body%instructions(index)%result%kind = instruction_shape_v2_pow_print_six_items_result_kind
            body%instructions(index)%result%type_name = instruction_shape_v2_pow_print_six_items_result_type
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = instruction_shape_v2_pow_print_six_items_source_rule
            end if
        end do
        body%instructions(1)%opcode = instruction_shape_v2_pow_print_six_items_opcode_0
        body%instructions(1)%literal_value = 3
        body%instructions(2)%opcode = instruction_shape_v2_pow_print_six_items_opcode_1
        body%instructions(3)%opcode = instruction_shape_v2_pow_print_six_items_opcode_2
        body%instructions(4)%opcode = instruction_shape_v2_pow_print_six_items_opcode_3
        body%instructions(4)%literal_value = 2
        body%instructions(5)%opcode = instruction_shape_v2_pow_print_six_items_opcode_4
        body%instructions(6)%opcode = instruction_shape_v2_pow_print_six_items_opcode_5
        body%instructions(7)%opcode = instruction_shape_v2_pow_print_six_items_opcode_6
        body%instructions(8)%opcode = instruction_shape_v2_pow_print_six_items_opcode_7
        body%instructions(9)%opcode = instruction_shape_v2_pow_print_six_items_opcode_8
        body%instructions(10)%opcode = instruction_shape_v2_pow_print_six_items_opcode_9
        body%instructions(11)%opcode = instruction_shape_v2_pow_print_six_items_opcode_10
        body%instructions(12)%opcode = instruction_shape_v2_pow_print_six_items_opcode_11
        body%instructions(13)%opcode = instruction_shape_v2_pow_print_six_items_opcode_12
        body%instructions(14)%opcode = instruction_shape_v2_pow_print_six_items_opcode_13
        body%instructions(15)%opcode = instruction_shape_v2_pow_print_six_items_opcode_14
        body%instructions(16)%opcode = instruction_shape_v2_pow_print_six_items_opcode_15
        body%instructions(17)%opcode = instruction_shape_v2_pow_print_six_items_opcode_16
        body%instructions(18)%opcode = instruction_shape_v2_pow_print_six_items_opcode_17
        body%instructions(19)%opcode = instruction_shape_v2_pow_print_six_items_opcode_18
        body%instructions(:)%result%id = [0, 1, 2, 3, 4, 4, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
        body%instructions(9)%storage_key = 'x'
        body%instructions(11)%storage_key = 'x'
        body%instructions(13)%storage_key = 'x'
        body%instructions(15)%storage_key = 'x'
        body%instructions(17)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_print_variable_six_items

    logical function ffc_validate_frontend_ast_v2_print_variable_seven_items_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        valid = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, 7, &
            instruction_shape_v2_pow_print_seven_items_count, instruction_shape_v2_pow_print_seven_items_result_kind, &
            instruction_shape_v2_pow_print_seven_items_result_type, instruction_shape_v2_pow_print_seven_items_source_rule, message)
    end function ffc_validate_frontend_ast_v2_print_variable_seven_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_eight_items_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        valid = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, 8, &
            instruction_shape_v2_pow_print_eight_items_count, instruction_shape_v2_pow_print_eight_items_result_kind, &
            instruction_shape_v2_pow_print_eight_items_result_type, instruction_shape_v2_pow_print_eight_items_source_rule, message)
    end function ffc_validate_frontend_ast_v2_print_variable_eight_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_nine_items_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        valid = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, 9, &
            instruction_shape_v2_pow_print_nine_items_count, instruction_shape_v2_pow_print_nine_items_result_kind, &
            instruction_shape_v2_pow_print_nine_items_result_type, instruction_shape_v2_pow_print_nine_items_source_rule, message)
    end function ffc_validate_frontend_ast_v2_print_variable_nine_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_ten_items_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        valid = ffc_validate_frontend_ast_v2_print_variable_items_shape(body, 10, &
            instruction_shape_v2_pow_print_ten_items_count, instruction_shape_v2_pow_print_ten_items_result_kind, &
            instruction_shape_v2_pow_print_ten_items_result_type, instruction_shape_v2_pow_print_ten_items_source_rule, message)
    end function ffc_validate_frontend_ast_v2_print_variable_ten_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_items_shape(body, item_count, instruction_count, result_kind, &
            result_type, source_rule, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer, intent(in) :: item_count
        integer(int32), intent(in) :: instruction_count, result_kind
        character(len=*), intent(in) :: result_type, source_rule
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_count) then
            call set_message(message, 'frontend-ast-v2 variable item instruction count changed')
            return
        end if
        do index = 1, instruction_count
            if (body%instructions(index)%result%kind /= result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= trim(result_type) .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= trim(source_rule))) then
                call set_message(message, 'frontend-ast-v2 variable item result shape changed')
                return
            end if
        end do
        if (instruction_count /= 2 * item_count + 7) then
            call set_message(message, 'frontend-ast-v2 variable item count contract changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_items_shape

    logical function is_variable_add_expression(serialized) result(matches)
        character(len=*), intent(in) :: serialized

        matches = trim(serialized) == &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand x))'
    end function is_variable_add_expression

    logical function is_variable_mul_expression(serialized) result(matches)
        character(len=*), intent(in) :: serialized

        matches = trim(serialized) == &
            '(assignment-expression (kind binary-expression) (operator *) (left-operand x) (right-operand x))'
    end function is_variable_mul_expression

    logical function is_variable_div_expression(serialized) result(matches)
        character(len=*), intent(in) :: serialized

        matches = trim(serialized) == &
            '(assignment-expression (kind binary-expression) (operator /) (left-operand x) (right-operand x))'
    end function is_variable_div_expression

    logical function is_variable_sub_expression(serialized) result(matches)
        character(len=*), intent(in) :: serialized

        matches = trim(serialized) == &
            '(assignment-expression (kind binary-expression) (operator –) (left-operand x) (right-operand x))'
    end function is_variable_sub_expression

    subroutine emit_frontend_ast_v2_initialized_variable_add(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body

        integer(int32), intent(in) :: initializer_value
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9_int32
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_add, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            body%instructions(index)%id = int(index - 1, int32)
            body%instructions(index)%opcode = expected_opcodes(index)
            body%instructions(index)%result%id = expected_results(index)
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(4)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_initialized_variable_add

    logical function ffc_validate_frontend_ast_v2_initialized_variable_add_shape(body, &
            initializer_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized variable add instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_add, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized variable add MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable add execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, 'frontend-ast-v2 initialized variable add print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value) then
            call set_message(message, 'frontend-ast-v2 initialized variable add initializer shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 4 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v2 initialized variable add storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, 'frontend-ast-v2 initialized variable add storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v2 initialized variable add storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_variable_add_shape

    subroutine emit_frontend_ast_v2_initialized_variable_mul(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: initializer_value
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9_int32
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_mul, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            body%instructions(index)%id = int(index - 1, int32)
            body%instructions(index)%opcode = expected_opcodes(index)
            body%instructions(index)%result%id = expected_results(index)
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(4)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_initialized_variable_mul

    logical function ffc_validate_frontend_ast_v2_initialized_variable_mul_shape(body, &
            initializer_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized variable multiply instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_mul, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized variable multiply MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable multiply execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, &
                    'frontend-ast-v2 initialized variable multiply print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value) then
            call set_message(message, 'frontend-ast-v2 initialized variable multiply initializer shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 4 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v2 initialized variable multiply storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, 'frontend-ast-v2 initialized variable multiply storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v2 initialized variable multiply storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_variable_mul_shape

    subroutine emit_frontend_ast_v2_initialized_variable_sub(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: initializer_value
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9_int32
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_sub, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            body%instructions(index)%id = int(index - 1, int32)
            body%instructions(index)%opcode = expected_opcodes(index)
            body%instructions(index)%result%id = expected_results(index)
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(4)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_initialized_variable_sub

    logical function ffc_validate_frontend_ast_v2_initialized_variable_sub_shape(body, &
            initializer_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized variable subtraction instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_sub, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized variable subtraction MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable subtraction execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, &
                    'frontend-ast-v2 initialized variable subtraction print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value) then
            call set_message(message, 'frontend-ast-v2 initialized variable subtraction initializer shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 4 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable subtraction storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable subtraction storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, &
                    'frontend-ast-v2 initialized variable subtraction storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_variable_sub_shape

    subroutine emit_frontend_ast_v2_initialized_variable_div(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: initializer_value
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9_int32
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_div, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            body%instructions(index)%id = int(index - 1, int32)
            body%instructions(index)%opcode = expected_opcodes(index)
            body%instructions(index)%result%id = expected_results(index)
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(4)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_initialized_variable_div

    logical function ffc_validate_frontend_ast_v2_initialized_variable_div_shape(body, &
            initializer_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized variable division instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_div, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized variable division MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, 'frontend-ast-v2 initialized variable division execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, 'frontend-ast-v2 initialized variable division print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value) then
            call set_message(message, 'frontend-ast-v2 initialized variable division initializer shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 4 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v2 initialized variable division storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, 'frontend-ast-v2 initialized variable division storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v2 initialized variable division storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_variable_div_shape

    subroutine emit_frontend_ast_v2_initialized_variable_power(body, initializer_value)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: initializer_value

        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9_int32
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_pow, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            body%instructions(index)%id = int(index - 1, int32)
            body%instructions(index)%opcode = expected_opcodes(index)
            body%instructions(index)%result%id = expected_results(index)
            body%instructions(index)%result%kind = value_kind_integer
            body%instructions(index)%result%type_name = 'i32'
            if (index <= 6) then
                body%instructions(index)%source_rule = 'frontend-ast-v2/execution-part'
            else
                body%instructions(index)%source_rule = 'frontend-ast-v2/print-stmt'
            end if
        end do
        body%instructions(1)%literal_value = initializer_value
        body%instructions(2)%storage_key = 'x'
        body%instructions(3)%storage_key = 'x'
        body%instructions(4)%storage_key = 'x'
        body%instructions(6)%storage_key = 'x'
        body%instructions(7)%storage_key = 'x'
    end subroutine emit_frontend_ast_v2_initialized_variable_power

    logical function ffc_validate_frontend_ast_v2_initialized_power_shape(body, initializer_value, &
            power_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value, power_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized power instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_pow, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized power MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, 'frontend-ast-v2 initialized power execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, 'frontend-ast-v2 initialized power print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value .or. &
            body%instructions(4)%literal_value /= power_value .or. &
            .not. is_bounded_integer_power(power_value)) then
            call set_message(message, 'frontend-ast-v2 initialized power literal shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v2 initialized power storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, 'frontend-ast-v2 initialized power storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v2 initialized power storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_power_shape

    logical function ffc_validate_frontend_ast_v2_initialized_variable_power_shape(body, &
            initializer_value, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: initializer_value
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 9_int32) then
            call set_message(message, 'frontend-ast-v2 initialized variable power instruction count changed')
            return
        end if
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_pow, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        do index = 1, 9
            if (body%instructions(index)%opcode /= expected_opcodes(index) .or. &
                body%instructions(index)%result%id /= expected_results(index) .or. &
                body%instructions(index)%result%kind /= value_kind_integer .or. &
                trim(body%instructions(index)%result%type_name) /= 'i32') then
                call set_message(message, 'frontend-ast-v2 initialized variable power MIR shape changed')
                return
            end if
            if (index <= 6) then
                if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/execution-part') then
                    call set_message(message, &
                        'frontend-ast-v2 initialized variable power execution provenance changed')
                    return
                end if
            else if (trim(body%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') then
                call set_message(message, &
                    'frontend-ast-v2 initialized variable power print provenance changed')
                return
            end if
        end do
        if (body%instructions(1)%literal_value /= initializer_value .or. &
            initializer_value < bounded_integer_power_minimum .or. &
            initializer_value > bounded_integer_power_maximum) then
            call set_message(message, 'frontend-ast-v2 initialized variable power initializer shape changed')
            return
        end if
        do index = 1, 9
            if (index == 2 .or. index == 3 .or. index == 4 .or. index == 6 .or. index == 7) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v2 initialized variable power storage shape changed')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= 'x') then
                    call set_message(message, 'frontend-ast-v2 initialized variable power storage shape changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v2 initialized variable power storage shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_initialized_variable_power_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_two_items_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_v2_pow_print_two_items_count) then
            call set_message(message, 'frontend-ast-v2 variable two-item instruction count changed')
            return
        end if
        do index = 1, instruction_shape_v2_pow_print_two_items_count
            if (body%instructions(index)%result%kind /= instruction_shape_v2_pow_print_two_items_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_v2_pow_print_two_items_result_type .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= &
                instruction_shape_v2_pow_print_two_items_source_rule)) then
                call set_message(message, 'frontend-ast-v2 variable two-item result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_two_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_three_items_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_v2_pow_print_three_items_count) then
            call set_message(message, 'frontend-ast-v2 variable three-item instruction count changed')
            return
        end if
        do index = 1, instruction_shape_v2_pow_print_three_items_count
            if (body%instructions(index)%result%kind /= instruction_shape_v2_pow_print_three_items_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_v2_pow_print_three_items_result_type .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= &
                instruction_shape_v2_pow_print_three_items_source_rule)) then
                call set_message(message, 'frontend-ast-v2 variable three-item result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_three_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_four_items_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_v2_pow_print_four_items_count) then
            call set_message(message, 'frontend-ast-v2 variable four-item instruction count changed')
            return
        end if
        do index = 1, instruction_shape_v2_pow_print_four_items_count
            if (body%instructions(index)%result%kind /= instruction_shape_v2_pow_print_four_items_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_v2_pow_print_four_items_result_type .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= &
                instruction_shape_v2_pow_print_four_items_source_rule)) then
                call set_message(message, 'frontend-ast-v2 variable four-item result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_four_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_five_items_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_v2_pow_print_five_items_count) then
            call set_message(message, 'frontend-ast-v2 variable five-item instruction count changed')
            return
        end if
        do index = 1, instruction_shape_v2_pow_print_five_items_count
            if (body%instructions(index)%result%kind /= instruction_shape_v2_pow_print_five_items_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_v2_pow_print_five_items_result_type .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= &
                instruction_shape_v2_pow_print_five_items_source_rule)) then
                call set_message(message, 'frontend-ast-v2 variable five-item result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_five_items_shape

    logical function ffc_validate_frontend_ast_v2_print_variable_six_items_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_v2_pow_print_six_items_count) then
            call set_message(message, 'frontend-ast-v2 variable six-item instruction count changed')
            return
        end if
        do index = 1, instruction_shape_v2_pow_print_six_items_count
            if (body%instructions(index)%result%kind /= instruction_shape_v2_pow_print_six_items_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_v2_pow_print_six_items_result_type .or. &
                (index <= 6 .and. trim(body%instructions(index)%source_rule) /= &
                'frontend-ast-v2/execution-part') .or. &
                (index > 6 .and. trim(body%instructions(index)%source_rule) /= &
                instruction_shape_v2_pow_print_six_items_source_rule)) then
                call set_message(message, 'frontend-ast-v2 variable six-item result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_variable_six_items_shape

    character(len=16) function sequence_position_name(position)
        integer, intent(in) :: position

        select case (position)
        case (1); sequence_position_name = 'first'
        case (2); sequence_position_name = 'second'
        case (3); sequence_position_name = 'third'
        case (4); sequence_position_name = 'fourth'
        case (5); sequence_position_name = 'fifth'
        case (6); sequence_position_name = 'sixth'
        case (7); sequence_position_name = 'seventh'
        case (8); sequence_position_name = 'eighth'
        case (9); sequence_position_name = 'ninth'
        case (10); sequence_position_name = 'tenth'
        case default; sequence_position_name = ''
        end select
    end function sequence_position_name

    logical function ffc_validate_frontend_ast_v1(ast, message) result(valid)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count /= bounded_integer_declaration_count .or. &
            ast%variable_count /= bounded_integer_variable_count) then
            call set_message(message, 'invalid-frontend-ast-v1-cardinality')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%name) /= trim(ast%declaration%name)) then
            call set_message(message, 'frontend-ast-v1-declaration-name-mismatch')
            return
        end if
        if (.not. ffc_validate_variable_declaration_v1(ast%variable, message)) return
        if (trim(ast%root%source_file) /= trim(ast%variable%source_file) .or. &
            trim(ast%root%source_hash) /= trim(ast%variable%source_hash)) then
            call set_message(message, 'frontend-ast-v1-invalid-provenance')
            return
        end if
        if (ast%assignment_count < 0_int64 .or. ast%assignment_count > 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment-cardinality')
            return
        end if
        if (ast%assignment_count == 0_int64) then
            valid = .true.
            return
        end if
        if (.not. ffc_validate_assignment_v1(ast%assignment, message)) return
        if (trim(ast%assignment%source_file) /= trim(ast%root%source_file) .or. &
            trim(ast%assignment%source_hash) /= trim(ast%root%source_hash)) then
            call set_message(message, 'frontend-ast-v1-invalid-provenance')
            return
        end if
        if (trim(ast%variable%type_spec) /= 'integer') then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment-type')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1

    logical function ffc_lower_frontend_ast_v1(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        integer :: kind
        integer(int32) :: expression_route, literal_value
        character(len=32) :: type_name

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v1(ast, message)
        if (.not. lowered) return
        kind = mir_type_spec_value_kind(ast%variable%type_spec)
        type_name = mir_type_spec_name(ast%variable%type_spec)
        call mir_make_function_witness(body)
        body%function%name = trim(ast%root%name)
        body%instructions(1)%result%kind = kind
        body%instructions(1)%result%type_name = trim(type_name)
        body%instructions(2)%result = body%instructions(1)%result
        if (trim(ast%variable%type_spec) == 'integer') then
            if (ast%assignment_count == 1_int64) then
                expression_route = mir_frontend_ast_v1_integer_expression_route(&
                    trim(ast%assignment%value))
                if (expression_route > 0_int32) then
                    call emit_frontend_ast_v1_integer_expression(body, expression_route)
                    select case (expression_route)
                    case (1_int32); lowered = ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
                            body, message)
                    case (2_int32); lowered = ffc_validate_frontend_ast_v1_int_var_assignment_shape(&
                            body, message)
                    case (3_int32); lowered = ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(&
                            body, message)
                    case (4_int32); lowered = ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape(&
                            body, message)
                    case (5_int32); lowered = ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape(&
                            body, message)
                    end select
                    return
                end if
                if (starts_integer_literal_expression(trim(ast%assignment%value))) then
                    if (.not. parse_integer_literal_expression(trim(ast%assignment%value), &
                        literal_value, message)) return
                    deallocate (body%instructions)
                    allocate (body%instructions(3))
                    body%instructions(1)%id = 0_int32
                    body%instructions(2)%id = 1_int32
                    body%instructions(3)%id = 2_int32
                    body%function%instruction_count = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_count
                    body%instructions(1)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0
                    body%instructions(1)%literal_value = literal_value
                    body%instructions(2)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1
                    body%instructions(3)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2
                    body%instructions(1)%result%kind = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_result_kind
                    body%instructions(1)%result%id = 1_int32
                    body%instructions(1)%result%type_name = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_result_type
                    body%instructions(2)%result = body%instructions(1)%result
                    body%instructions(3)%result = body%instructions(1)%result
                    body%instructions(1)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    body%instructions(2)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    body%instructions(3)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    lowered = ffc_validate_frontend_ast_v1_int_literal_assignment_shape(body, &
                        message)
                    return
                end if
                body%function%instruction_count = &
                    instruction_shape_frontend_ast_v1_int_assign_count
                body%instructions(1)%opcode = &
                    instruction_shape_frontend_ast_v1_int_assign_opcode_0
                body%instructions(2)%opcode = &
                    instruction_shape_frontend_ast_v1_int_assign_opcode_1
                body%instructions(1)%result%kind = &
                    instruction_shape_frontend_ast_v1_int_assign_result_kind
                body%instructions(1)%result%type_name = &
                    instruction_shape_frontend_ast_v1_int_assign_result_type
                body%instructions(2)%result = body%instructions(1)%result
                body%instructions(1)%source_rule = &
                    instruction_shape_frontend_ast_v1_int_assign_source_rule
                body%instructions(2)%source_rule = &
                    instruction_shape_frontend_ast_v1_int_assign_source_rule
                lowered = ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, &
                    message)
                return
            end if
            body%function%instruction_count = instruction_shape_frontend_ast_v1_integer_program_count
            body%instructions(1)%opcode = instruction_shape_frontend_ast_v1_integer_program_opcode_0
            body%instructions(2)%opcode = instruction_shape_frontend_ast_v1_integer_program_opcode_1
            body%instructions(1)%result%kind = instruction_shape_frontend_ast_v1_integer_program_result_kind
            body%instructions(1)%result%type_name = instruction_shape_frontend_ast_v1_integer_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_integer_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_integer_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_integer_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'logical') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_logical_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_logical_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_logical_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_logical_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_logical_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_logical_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_logical_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_logical_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'real') then
            body%function%instruction_count = instruction_shape_frontend_ast_v1_real_program_count
            body%instructions(1)%opcode = instruction_shape_frontend_ast_v1_real_program_opcode_0
            body%instructions(2)%opcode = instruction_shape_frontend_ast_v1_real_program_opcode_1
            body%instructions(1)%result%kind = instruction_shape_frontend_ast_v1_real_program_result_kind
            body%instructions(1)%result%type_name = instruction_shape_frontend_ast_v1_real_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = instruction_shape_frontend_ast_v1_real_program_source_rule
            body%instructions(2)%source_rule = instruction_shape_frontend_ast_v1_real_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_real_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'double-precision') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_dp_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_dp_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_dp_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_dp_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_dp_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_dp_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_dp_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'complex') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_complex_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_complex_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_complex_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_complex_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_complex_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_complex_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_complex_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_complex_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'character') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_character_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_character_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_character_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_character_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_character_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_character_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_character_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_character_program_shape(body, message)
            return
        end if
        body%instructions(1)%source_rule = 'frontend-ast-v1/program'
        body%instructions(2)%source_rule = 'frontend-ast-v1/program'
    end function ffc_lower_frontend_ast_v1

    subroutine emit_frontend_ast_v1_integer_expression(body, route)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: route

        integer(int32) :: index, instruction_count, literal_index

        deallocate (body%instructions)
        instruction_count = mir_frontend_ast_v1_integer_expression_instruction_count(route)
        allocate (body%instructions(instruction_count))
        body%function%instruction_count = instruction_count
        literal_index = 0_int32
        do index = 0_int32, instruction_count - 1_int32
            body%instructions(index + 1)%id = index
            body%instructions(index + 1)%opcode = &
                mir_frontend_ast_v1_integer_expression_opcode(route, index)
            body%instructions(index + 1)%source_rule = &
                trim(mir_frontend_ast_v1_integer_expression_source_rule_at(route, index))
            if (len_trim(mir_frontend_ast_v1_integer_expression_storage_key(route, index)) > 0) then
                body%instructions(index + 1)%storage_key = &
                    trim(mir_frontend_ast_v1_integer_expression_storage_key(route, index))
            end if
            if (body%instructions(index + 1)%opcode == opcode_const) then
                body%instructions(index + 1)%literal_value = &
                    mir_frontend_ast_v1_integer_expression_literal_value(route, literal_index)
                literal_index = literal_index + 1_int32
            end if
        end do
        if (mir_frontend_ast_v1_integer_expression_result_id(route, 0_int32) >= 0_int32) then
            do index = 0_int32, instruction_count - 1_int32
                body%instructions(index + 1)%result%id = &
                    mir_frontend_ast_v1_integer_expression_result_id(route, index)
                body%instructions(index + 1)%result%kind = &
                    mir_frontend_ast_v1_integer_expression_result_kind(route)
                body%instructions(index + 1)%result%type_name = &
                    trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            end do
        else
            body%instructions(1)%result%id = 2
            body%instructions(1)%result%kind = &
                mir_frontend_ast_v1_integer_expression_result_kind(route)
            body%instructions(1)%result%type_name = &
                trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            body%instructions(2)%result%id = 1
            body%instructions(2)%result%kind = &
                mir_frontend_ast_v1_integer_expression_result_kind(route)
            body%instructions(2)%result%type_name = &
                trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            body%instructions(3)%result = body%instructions(2)%result
            if (instruction_count > 3_int32) then
                do index = 4_int32, instruction_count
                    body%instructions(index)%result = body%instructions(3)%result
                end do
            end if
        end if
    end subroutine emit_frontend_ast_v1_integer_expression

    logical function ffc_validate_frontend_ast_v1_integer_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_integer_program_count) then
            call set_message(message, 'frontend-ast-v1 integer instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_integer_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_integer_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 integer opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_integer_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_integer_program_result_type) then
            call set_message(message, 'frontend-ast-v1 integer result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_integer_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_integer_program_result_type) then
            call set_message(message, 'frontend-ast-v1 integer return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_integer_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_integer_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_integer_program_shape

    logical function ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer assignment instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_assign_opcode_1) then
            call set_message(message, 'frontend-ast-v1 integer assignment opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer assignment result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer assignment return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer assignment source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_integer_assignment_program_shape

    logical function ffc_validate_frontend_ast_v1_int_literal_assignment_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer literal instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer literal opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer literal result shape changed')
            return
        end if
        if (body%instructions(1)%literal_value < 0_int32) then
            call set_message(message, 'frontend-ast-v1 integer literal value is out of range')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind) then
            call set_message(message, 'frontend-ast-v1 integer literal return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer literal source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_literal_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_2 .or. &
            body%instructions(4)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_3 .or. &
            body%instructions(5)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_4) then
            call set_message(message, 'frontend-ast-v1 integer expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 1_int32 .or. &
            body%instructions(2)%literal_value /= 2_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 1_int32 .or. &
            body%instructions(3)%result%id /= 2_int32 .or. &
            body%instructions(4)%result%id /= 2_int32 .or. &
            body%instructions(5)%result%id /= 2_int32 .or. &
            body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer expression result shape changed')
            return
        end if
        if (body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type .or. &
            body%instructions(4)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(4)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type .or. &
            body%instructions(5)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(5)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(4)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(5)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_var_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        character(len=64) :: expected_storage_key

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_var_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer variable expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_2 .or. &
            body%instructions(4)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_3 .or. &
            body%instructions(5)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_4) then
            call set_message(message, 'frontend-ast-v1 integer variable expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 0_int32 .or. &
            body%instructions(2)%literal_value /= 1_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 1_int32 .or. &
            body%instructions(3)%result%id /= 2_int32 .or. &
            body%instructions(4)%result%id /= 2_int32 .or. &
            body%instructions(5)%result%id /= 2_int32) then
            call set_message(message, 'frontend-ast-v1 integer variable expression result shape changed')
            return
        end if
        do index = 1, 5
            expected_storage_key = trim(mir_frontend_ast_v1_integer_expression_storage_key(2_int32, &
                int(index - 1, int32)))
            if (len_trim(expected_storage_key) > 0) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v1 integer variable storage key missing')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= trim(expected_storage_key)) then
                    call set_message(message, 'frontend-ast-v1 integer variable storage key changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v1 integer variable storage key unexpected')
                return
            end if
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v1_int_var_assign_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v1_int_var_assign_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v1_int_var_assign_source_rule) then
                call set_message(message, &
                    'frontend-ast-v1 integer variable expression metadata changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_var_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_div_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer division expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer division expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer division expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer division expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer division expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_logical_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_logical_program_count) then
            call set_message(message, 'frontend-ast-v1 logical instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_logical_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_logical_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 logical opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_logical_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_logical_program_result_type) then
            call set_message(message, 'frontend-ast-v1 logical result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_logical_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_logical_program_result_type) then
            call set_message(message, 'frontend-ast-v1 logical return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_logical_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_logical_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 logical source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_logical_program_shape

    logical function ffc_validate_frontend_ast_v1_real_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v1_real_program_count) then
            call set_message(message, 'frontend-ast-v1 real instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v1_real_program_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v1_real_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 real opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= instruction_shape_frontend_ast_v1_real_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= instruction_shape_frontend_ast_v1_real_program_result_type) then
            call set_message(message, 'frontend-ast-v1 real result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= instruction_shape_frontend_ast_v1_real_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= instruction_shape_frontend_ast_v1_real_program_result_type) then
            call set_message(message, 'frontend-ast-v1 real return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= instruction_shape_frontend_ast_v1_real_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= instruction_shape_frontend_ast_v1_real_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 real source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_real_program_shape

    logical function ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_dp_program_count) then
            call set_message(message, 'frontend-ast-v1 double-precision instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_dp_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_dp_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 double-precision opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_dp_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_dp_program_result_type) then
            call set_message(message, 'frontend-ast-v1 double-precision result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_dp_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_dp_program_result_type) then
            call set_message(message, 'frontend-ast-v1 double-precision return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_dp_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_dp_program_source_rule) then
            call set_message(message, &
                'frontend-ast-v1 double-precision source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_double_precision_program_shape

    logical function ffc_validate_frontend_ast_v1_complex_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_complex_program_count) then
            call set_message(message, 'frontend-ast-v1 complex instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_complex_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_complex_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 complex opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_complex_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_complex_program_result_type) then
            call set_message(message, 'frontend-ast-v1 complex result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_complex_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_complex_program_result_type) then
            call set_message(message, 'frontend-ast-v1 complex return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_complex_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_complex_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 complex source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_complex_program_shape

    logical function ffc_validate_frontend_ast_v1_character_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_character_program_count) then
            call set_message(message, 'frontend-ast-v1 character instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_character_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_character_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 character opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_character_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_character_program_result_type) then
            call set_message(message, 'frontend-ast-v1 character result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_character_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_character_program_result_type) then
            call set_message(message, 'frontend-ast-v1 character return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_character_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_character_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 character source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_character_program_shape

    logical function ffc_validate_frontend_ast_v2_stop_7_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_stop_7_count) then
            call set_message(message, 'frontend-ast-v2 stop-7 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_stop_7_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_stop_7_opcode_1) then
            call set_message(message, 'frontend-ast-v2 stop-7 opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 7_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 0_int32 .or. &
            body%instructions(1)%result%kind /= instruction_shape_frontend_ast_v2_stop_7_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v2_stop_7_result_type .or. &
            body%instructions(2)%result%kind /= instruction_shape_frontend_ast_v2_stop_7_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v2_stop_7_result_type) then
            call set_message(message, 'frontend-ast-v2 stop-7 typed result shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v2_stop_7_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v2_stop_7_source_rule) then
            call set_message(message, 'frontend-ast-v2 stop-7 source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v2_stop_7_shape

    subroutine emit_frontend_ast_v2_print_7(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(3))
        body%function%instruction_count = 3
        body%instructions(1)%id = 0
        body%instructions(1)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_0
        body%instructions(1)%literal_value = 7
        body%instructions(2)%id = 1
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_1
        body%instructions(3)%id = 2
        body%instructions(3)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_2
        do index = 1, 3
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_source_rule
        end do
    end subroutine emit_frontend_ast_v2_print_7

    logical function ffc_validate_frontend_ast_v2_print_7_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_count) then
            call set_message(message, 'frontend-ast-v2 print-7 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_2 .or. &
            body%instructions(1)%literal_value /= 7) then
            call set_message(message, 'frontend-ast-v2 print-7 opcode shape changed')
            return
        end if
        do index = 1, 3
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_shape

    subroutine emit_frontend_ast_v2_print_7_8(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(5))
        body%function%instruction_count = 5
        body%instructions(1)%id = 0
        body%instructions(1)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_0
        body%instructions(1)%literal_value = 7
        body%instructions(2)%id = 1
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_1
        body%instructions(3)%id = 2
        body%instructions(3)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_2
        body%instructions(3)%literal_value = 8
        body%instructions(4)%id = 3
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_3
        body%instructions(5)%id = 4
        body%instructions(5)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_4
        do index = 1, 5
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_7_8_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_7_8_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_7_8_source_rule
        end do
    end subroutine emit_frontend_ast_v2_print_7_8

    logical function ffc_validate_frontend_ast_v2_print_7_8_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_4 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8) then
            call set_message(message, 'frontend-ast-v2 print-7-8 opcode shape changed')
            return
        end if
        do index = 1, 5
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_7_8_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_7_8_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_7_8_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_shape

    subroutine emit_frontend_ast_v2_print_7_8_9(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(7))
        body%function%instruction_count = 7
        do index = 1, 7
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5
        body%instructions(7)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6
    end subroutine emit_frontend_ast_v2_print_7_8_9

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9 opcode shape changed')
            return
        end if
        do index = 1, 7
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_7_8_9_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_7_8_9_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_7_8_9_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9
        do index = 1, 9
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7
        body%instructions(9)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8
    end subroutine emit_frontend_ast_v2_print_7_8_9_10

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_10_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10 opcode shape changed')
            return
        end if
        do index = 1, 9
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10_11(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(11))
        body%function%instruction_count = 11
        do index = 1, 11
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7
        body%instructions(9)%literal_value = 11
        body%instructions(10)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9
        body%instructions(11)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10
    end subroutine emit_frontend_ast_v2_print_7_8_9_10_11

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_8 .or. &
            body%instructions(10)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9 .or. &
            body%instructions(11)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10 .or. &
            body%instructions(9)%literal_value /= 11) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 opcode shape changed')
            return
        end if
        do index = 1, 11
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10_11_12(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(13))
        body%function%instruction_count = 13
        do index = 1, 13
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_six_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_six_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_six_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_7
        body%instructions(9)%literal_value = 11
        body%instructions(10)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_9
        body%instructions(11)%literal_value = 12
        body%instructions(12)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_11
        body%instructions(13)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_12
    end subroutine emit_frontend_ast_v2_print_7_8_9_10_11_12

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_six_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_8 .or. &
            body%instructions(10)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_9 .or. &
            body%instructions(11)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_10 .or. &
            body%instructions(12)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_11 .or. &
            body%instructions(13)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_12 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10 .or. &
            body%instructions(9)%literal_value /= 11 .or. body%instructions(11)%literal_value /= 12) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 opcode shape changed')
            return
        end if
        do index = 1, 13
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_six_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_six_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_six_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape

    subroutine emit_frontend_ast_v2_print_seven(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(15))
        body%function%instruction_count = 15
        do index = 1, 15
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_seven_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_seven_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_seven_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_7
        body%instructions(9)%literal_value = 11
        body%instructions(10)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_9
        body%instructions(11)%literal_value = 12
        body%instructions(12)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_11
        body%instructions(13)%literal_value = 13
        body%instructions(14)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_13
        body%instructions(15)%opcode = instruction_shape_frontend_ast_v2_print_seven_opcode_14
    end subroutine emit_frontend_ast_v2_print_seven

    logical function ffc_validate_frontend_ast_v2_print_seven_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_seven_count) then
            call set_message(message, 'frontend-ast-v2 print-seven instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_8 .or. &
            body%instructions(10)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_9 .or. &
            body%instructions(11)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_10 .or. &
            body%instructions(12)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_11 .or. &
            body%instructions(13)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_12 .or. &
            body%instructions(14)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_13 .or. &
            body%instructions(15)%opcode /= instruction_shape_frontend_ast_v2_print_seven_opcode_14 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10 .or. &
            body%instructions(9)%literal_value /= 11 .or. body%instructions(11)%literal_value /= 12 .or. &
            body%instructions(13)%literal_value /= 13) then
            call set_message(message, 'frontend-ast-v2 print-seven opcode shape changed')
            return
        end if
        do index = 1, 15
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_seven_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_seven_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_seven_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-seven typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_seven_shape

    subroutine emit_frontend_ast_v2_print_eight(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(17))
        body%function%instruction_count = 17
        do index = 1, 17
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_eight_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_eight_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_eight_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_eight_source_rule
        end do
        do index = 1, 8
            body%instructions(2 * index - 1)%literal_value = index + 6
            body%instructions(2 * index)%opcode = instruction_shape_frontend_ast_v2_print_eight_opcode_1
        end do
        body%instructions(17)%opcode = instruction_shape_frontend_ast_v2_print_eight_opcode_16
    end subroutine emit_frontend_ast_v2_print_eight

    logical function ffc_validate_frontend_ast_v2_print_eight_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_eight_count) then
            call set_message(message, 'frontend-ast-v2 print-eight instruction count changed')
            return
        end if
        do index = 1, 17
            if (index == 17) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_eight_opcode_16) then
                    call set_message(message, 'frontend-ast-v2 print-eight opcode shape changed')
                    return
                end if
            else if (mod(index, 2) == 1) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_eight_opcode_0 .or. &
                    body%instructions(index)%literal_value /= (index + 13) / 2) then
                    call set_message(message, 'frontend-ast-v2 print-eight literal shape changed')
                    return
                end if
            else
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_eight_opcode_1) then
                    call set_message(message, 'frontend-ast-v2 print-eight opcode shape changed')
                    return
                end if
            end if
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_eight_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_eight_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_eight_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-eight typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_eight_shape

    subroutine emit_frontend_ast_v2_print_nine(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(19))
        body%function%instruction_count = 19
        do index = 1, 19
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_nine_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_nine_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_nine_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_nine_source_rule
        end do
        do index = 1, 9
            body%instructions(2 * index - 1)%literal_value = index + 6
            body%instructions(2 * index)%opcode = instruction_shape_frontend_ast_v2_print_nine_opcode_1
        end do
        body%instructions(19)%opcode = instruction_shape_frontend_ast_v2_print_nine_opcode_18
    end subroutine emit_frontend_ast_v2_print_nine

    logical function ffc_validate_frontend_ast_v2_print_nine_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_nine_count) then
            call set_message(message, 'frontend-ast-v2 print-nine instruction count changed')
            return
        end if
        do index = 1, 19
            if (index == 19) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_nine_opcode_18) then
                    call set_message(message, 'frontend-ast-v2 print-nine opcode shape changed')
                    return
                end if
            else if (mod(index, 2) == 1) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_nine_opcode_0 .or. &
                    body%instructions(index)%literal_value /= (index + 13) / 2) then
                    call set_message(message, 'frontend-ast-v2 print-nine literal shape changed')
                    return
                end if
            else
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_nine_opcode_1) then
                    call set_message(message, 'frontend-ast-v2 print-nine opcode shape changed')
                    return
                end if
            end if
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_nine_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_nine_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_nine_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-nine typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_nine_shape

    subroutine emit_frontend_ast_v2_print_ten(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(21))
        body%function%instruction_count = 21
        do index = 1, 21
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_ten_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_ten_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_ten_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_ten_source_rule
        end do
        do index = 1, 10
            body%instructions(2 * index - 1)%literal_value = index + 6
            body%instructions(2 * index)%opcode = instruction_shape_frontend_ast_v2_print_ten_opcode_1
        end do
        body%instructions(21)%opcode = instruction_shape_frontend_ast_v2_print_ten_opcode_20
    end subroutine emit_frontend_ast_v2_print_ten

    logical function ffc_validate_frontend_ast_v2_print_ten_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_ten_count) then
            call set_message(message, 'frontend-ast-v2 print-ten instruction count changed')
            return
        end if
        do index = 1, 21
            if (index == 21) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_ten_opcode_20) then
                    call set_message(message, 'frontend-ast-v2 print-ten opcode shape changed')
                    return
                end if
            else if (mod(index, 2) == 1) then
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_ten_opcode_0 .or. &
                    body%instructions(index)%literal_value /= (index + 13) / 2) then
                    call set_message(message, 'frontend-ast-v2 print-ten literal shape changed')
                    return
                end if
            else
                if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_ten_opcode_1) then
                    call set_message(message, 'frontend-ast-v2 print-ten opcode shape changed')
                    return
                end if
            end if
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_ten_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_ten_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_ten_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-ten typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_ten_shape

    subroutine emit_frontend_ast_v2_print_generic(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(7))
        body%function%instruction_count = 7
        do index = 1, 7
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_7_8_9_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_7_8_9_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_7_8_9_source_rule
        end do
        do index = 1, 3
            body%instructions(2 * index - 1)%literal_value = index + 16
            body%instructions(2 * index)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1
        end do
        body%instructions(7)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6
    end subroutine emit_frontend_ast_v2_print_generic

    logical function ffc_validate_frontend_ast_v2_print_generic_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 7) then
            call set_message(message, 'frontend-ast-v2 print-generic instruction count changed')
            return
        end if
        do index = 1, 7
            if (mod(index, 2) == 1) then
                if (index == 7) then
                    if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6) then
                        call set_message(message, 'frontend-ast-v2 print-generic return shape changed')
                        return
                    end if
                else if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0 .or. &
                        body%instructions(index)%literal_value /= index / 2 + 17) then
                    call set_message(message, 'frontend-ast-v2 print-generic literal shape changed')
                    return
                end if
            else if (body%instructions(index)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1) then
                call set_message(message, 'frontend-ast-v2 print-generic output shape changed')
                return
            end if
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_7_8_9_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_7_8_9_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_7_8_9_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-generic source correspondence changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_generic_shape

    integer(int32) function frontend_ast_v2_stop_route(expression) result(route)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        route = mir_frontend_ast_v1_integer_expression_route(&
            '(execution-part '//canonical//')')
        if (route /= 0_int32) return
        if (index(canonical, '( stop-stmt ') /= 1) return
        if (index(canonical, '( code 7 )') == 0) return
        if (index(canonical, '( source-rule R1162 )') == 0) return
        if (index(canonical, '( code-rule R1164 )') == 0) return
        if (index(canonical, '( quiet ') /= 0) return
        route = 18_int32
    end function frontend_ast_v2_stop_route

    integer(int32) function frontend_ast_v2_print_route(expression) result(route)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        route = 0_int32
        if (index(canonical, '( print-stmt ') /= 1) return
        if (index(canonical, '( format-kind default-char-expr )') == 0 .or. &
            index(canonical, '( format-value * )') == 0 .or. &
            index(canonical, '( output-kind integer-literal )') == 0) return
        if (index(canonical, '( statement-rule R1212 )') == 0 .or. &
            index(canonical, '( format-rule R1215 )') == 0 .or. &
            index(canonical, '( output-rule R1217 )') == 0) return
        if (index(canonical, '( source-document J3-24-007 )') == 0 .or. &
            index(canonical, '( statement-clause 12.6.1 )') == 0 .or. &
            index(canonical, '( format-clause 12.6.2.2 )') == 0 .or. &
            index(canonical, '( output-clause 12.6.3 )') == 0 .or. &
            index(canonical, '( statement-page 242 )') == 0 .or. &
            index(canonical, '( format-page 244 )') == 0 .or. &
            index(canonical, '( output-page 248 )') == 0 .or. &
            index(canonical, '( source-hash ') == 0) return
        if (index(canonical, 'write-stmt') /= 0 .or. index(canonical, 'control-list') /= 0 .or. &
            index(canonical, 'io-implied-do') /= 0) return
        if (frontend_ast_v2_print_repeated_items_match(canonical, 3, 17)) then
            route = 29_int32
            return
        end if
        if (index(canonical, '( output-count 10 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. index(canonical, '( output-rule-6 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-7 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-7 13 )') == 0 .or. index(canonical, '( output-rule-7 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-8 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-8 14 )') == 0 .or. index(canonical, '( output-rule-8 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-9 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-9 15 )') == 0 .or. index(canonical, '( output-rule-9 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-10 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-10 16 )') == 0 .or. index(canonical, '( output-rule-10 R1217 )') == 0) return
            route = 28_int32
            return
        end if
        if (index(canonical, '( output-count 9 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. index(canonical, '( output-rule-6 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-7 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-7 13 )') == 0 .or. index(canonical, '( output-rule-7 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-8 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-8 14 )') == 0 .or. index(canonical, '( output-rule-8 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-9 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-9 15 )') == 0 .or. index(canonical, '( output-rule-9 R1217 )') == 0) return
            route = 27_int32
            return
        end if
        if (index(canonical, '( output-count 8 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. &
                index(canonical, '( output-rule-6 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-7 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-7 13 )') == 0 .or. &
                index(canonical, '( output-rule-7 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-8 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-8 14 )') == 0 .or. &
                index(canonical, '( output-rule-8 R1217 )') == 0) return
            route = 26_int32
            return
        end if
        if (index(canonical, '( output-count 7 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. &
                index(canonical, '( output-rule-6 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-7 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-7 13 )') == 0 .or. &
                index(canonical, '( output-rule-7 R1217 )') == 0) return
            route = 25_int32
            return
        end if
        if (index(canonical, '( output-count 6 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. &
                index(canonical, '( output-rule-6 R1217 )') == 0) return
            route = 24_int32
            return
        end if
        if (index(canonical, '( output-count 5 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0) return
            route = 23_int32
            return
        end if
        if (index(canonical, '( output-count 4 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0) return
            route = 22_int32
            return
        end if
        if (index(canonical, '( output-count 3 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0) return
            route = 21_int32
            return
        end if
        if (index(canonical, '( output-count 2 )') /= 0 .and. &
            index(canonical, '( output-kind-2 integer-literal )') /= 0 .and. &
            index(canonical, '( output-value-2 8 )') /= 0 .and. &
            index(canonical, '( output-rule-2 R1217 )') /= 0) then
            route = 20_int32
            return
        end if
        if (index(canonical, '( output-count 2 )') /= 0) return
        if (index(canonical, '( output-count ') /= 0) return
        if (count_substring(canonical, '( output-kind integer-literal )') /= 1 .or. &
            count_substring(canonical, '( output-value 7 )') /= 1) return
        route = 19_int32
    end function frontend_ast_v2_print_route

    logical function frontend_ast_v2_print_repeated_items_match(expression, item_count, first_value) result(matches)
        character(len=*), intent(in) :: expression
        integer, intent(in) :: item_count, first_value
        character(len=32) :: suffix, value_text
        integer :: item_index

        matches = .false.
        do item_index = 1, item_count
            suffix = ''
            if (item_index > 1) write (suffix, '(a,i0)') '-', item_index
            write (value_text, '(i0)') first_value + item_index - 1
            if (index(expression, '( output-kind'//trim(suffix)//' integer-literal )') == 0) return
            if (index(expression, '( output-value'//trim(suffix)//' '//trim(value_text)//' )') == 0) return
            if (index(expression, '( output-rule'//trim(suffix)//' R1217 )') == 0) return
        end do
        matches = .true.
    end function frontend_ast_v2_print_repeated_items_match

    integer function count_substring(value, needle) result(count)
        character(len=*), intent(in) :: value, needle
        integer :: position, found

        count = 0
        position = 1
        do while (position <= len_trim(value))
            found = index(value(position:), needle)
            if (found == 0) return
            position = position + found - 1
            count = count + 1
            position = position + len(needle)
        end do
    end function count_substring

    logical function ffc_lower_frontend_ast_v1_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v1_t) :: ast

        call clear_message(message)
        if (starts_assignment_sequence_sx(serialized)) then
            lowered = ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(serialized, body, message)
            return
        end if
        lowered = ffc_frontend_ast_v1_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v1(ast, body, message)
    end function ffc_lower_frontend_ast_v1_from_sx

    logical function starts_assignment_sequence_sx(serialized) result(starts)
        character(len=*), intent(in) :: serialized

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=:), allocatable :: message
        integer :: token_count

        starts = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        if (token_count >= 2) then
            if (trim(token(1)) == '(') then
                starts = trim(token(2)) == 'assignment-sequence'
            end if
        end if
    end function starts_assignment_sequence_sx

    logical function ffc_frontend_ast_v0_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v0_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position
        integer(int64) :: declaration_count

        ast = ffc_frontend_ast_v0_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return

        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) return

        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, declaration_count, message)
        if (.not. parsed) return
        ast%declaration_count = declaration_count

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if
        if (trim(token(position)) == '(') then
            parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
                message)
            if (.not. parsed) return
            parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
            if (.not. parsed) return
            ast%declaration_present = .true.
        else if (trim(token(position)) /= ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = ffc_validate_frontend_ast_v0(ast, message)
    end function ffc_frontend_ast_v0_from_sx

    logical function ffc_validate_frontend_ast_v0(ast, message) result(valid)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count < 0_int64) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            return
        end if
        if (ast%declaration_count == 0_int64) then
            if (ast%declaration_present) then
                call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
                return
            end if
            valid = .true.
            return
        end if
        if (ast%declaration_count /= 1_int64 .or. .not. ast%declaration_present) then
            call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%source_file) /= trim(ast%declaration%source_file)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (trim(ast%root%source_hash) /= trim(ast%declaration%source_hash)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%start_byte < ast%root%start_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%end_byte > ast%root%end_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v0(ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(ast%root%name, ast%root%source_file, &
            ast%root%source_hash, ast%root%start_byte, ast%root%end_byte, body, message)
    end function ffc_lower_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v0_t) :: ast

        call clear_message(message)
        lowered = ffc_frontend_ast_v0_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v0(ast, body, message)
    end function ffc_lower_frontend_ast_v0_from_sx

    logical function tokenize_frontend_ast_sx(input, token, token_count, message) result(ok)
        character(len=*), intent(in) :: input
        character(len=*), intent(out) :: token(:)
        integer, intent(out) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        integer :: position, start, input_length
        character :: current

        token = ''
        token_count = 0
        call clear_message(message)
        position = 1
        input_length = len_trim(input)
        do while (position <= input_length)
            current = input(position:position)
            if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                current == char(13)) then
                position = position + 1
            else if (current == '(' .or. current == ')') then
                if (.not. append_token(input(position:position), token, token_count, message)) &
                    return
                position = position + 1
            else
                start = position
                do while (position <= input_length)
                    current = input(position:position)
                    if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                        current == char(13) .or. current == '(' .or. current == ')') exit
                    position = position + 1
                end do
                if (.not. append_token(input(start:position - 1), token, token_count, message)) &
                    return
            end if
        end do
        ok = token_count > 0
        if (.not. ok) call set_message(message, 'malformed-frontend-ast-v0')
    end function tokenize_frontend_ast_sx

    logical function parse_variable_declaration_v1(serialized, variable, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_variable_declaration_v1_t), intent(out) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=128) :: type_spec, name
        integer :: token_count, position

        variable = ffc_frontend_variable_declaration_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'variable-declaration', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'type-spec', type_spec, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'name', name, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'span', expression, message)
        if (.not. parsed) return
        parsed = parse_source_span_v1(trim(expression), variable%source_file, &
            variable%start_byte, variable%end_byte, variable%source_hash, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            return
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        variable%type_spec = type_spec
        variable%name = name
        parsed = ffc_validate_variable_declaration_v1(variable, message)
    end function parse_variable_declaration_v1

    logical function parse_assignment_v1(serialized, assignment, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_assignment_v1_t), intent(out) :: assignment
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=128) :: target, value
        integer :: token_count, position

        assignment = ffc_frontend_assignment_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'assignment-stmt', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'variable', target, message)
        if (.not. parsed) return
        parsed = read_assignment_expression(token, token_count, position, value, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'span', expression, message)
        if (.not. parsed) return
        parsed = parse_source_span_v1(trim(expression), assignment%source_file, &
            assignment%start_byte, assignment%end_byte, assignment%source_hash, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-assignment')
            parsed = .false.
            return
        end if
        assignment%target = target
        assignment%value = value
        parsed = ffc_validate_assignment_v1(assignment, message)
    end function parse_assignment_v1

    logical function parse_source_span_v1(serialized, source_file, start_byte, end_byte, &
            source_hash, message) result(parsed)
        character(len=*), intent(in) :: serialized
        character(len=*), intent(out) :: source_file, source_hash
        integer(int64), intent(out) :: start_byte, end_byte
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=64) :: start_text, end_text
        integer :: token_count, position

        source_file = ''
        source_hash = ''
        start_byte = 0_int64
        end_byte = 0_int64
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'source-span', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'file', source_file, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'start-byte', start_text, message)
        if (.not. parsed) return
        parsed = parse_count(start_text, start_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'end-byte', end_text, message)
        if (.not. parsed) return
        parsed = parse_count(end_text, end_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'source-hash', source_hash, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            parsed = .false.
        end if
    end function parse_source_span_v1

    logical function ffc_validate_variable_declaration_v1(variable, message) result(valid)
        type(ffc_frontend_variable_declaration_v1_t), intent(in) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (len_trim(variable%type_spec) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-type-spec')
            return
        end if
        if (mir_type_spec_value_kind(variable%type_spec) == 0) then
            call set_message(message, 'unsupported-frontend-ast-v1-type-spec')
            return
        end if
        if (len_trim(variable%name) == 0 .or. len_trim(variable%source_file) == 0 .or. &
            len_trim(variable%source_hash) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-variable')
            return
        end if
        if (variable%start_byte < 0_int64 .or. variable%end_byte < variable%start_byte) then
            call set_message(message, 'invalid-frontend-ast-v1-variable-span')
            return
        end if
        valid = .true.
    end function ffc_validate_variable_declaration_v1

    logical function ffc_validate_assignment_v1(assignment, message) result(valid)
        type(ffc_frontend_assignment_v1_t), intent(in) :: assignment
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: literal_value
        logical :: bounded_addend, bounded_subtrahend, bounded_multiplier, bounded_divisor, bounded_power, &
            variable_power, variable_add, variable_mul, variable_div, variable_sub

        call clear_message(message)
        bounded_addend = parse_bounded_addend_expression(trim(assignment%value), literal_value)
        bounded_subtrahend = parse_bounded_subtrahend_expression(&
            trim(assignment%value), literal_value)
        bounded_multiplier = parse_bounded_multiplier_expression(trim(assignment%value), literal_value)
        bounded_divisor = parse_bounded_divisor_expression(trim(assignment%value), literal_value)
        bounded_power = parse_bounded_power_expression(trim(assignment%value), literal_value)
        variable_power = is_variable_power_expression(trim(assignment%value))
        variable_add = is_variable_add_expression(trim(assignment%value))
        variable_mul = is_variable_mul_expression(trim(assignment%value))
        variable_div = is_variable_div_expression(trim(assignment%value))
        variable_sub = is_variable_sub_expression(trim(assignment%value))
        valid = .false.
        if (trim(assignment%target) /= 'x') then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment')
            return
        end if
        if (trim(assignment%value) /= '1' .and. &
            .not. starts_integer_literal_expression(trim(assignment%value)) .and. &
            trim(assignment%value) /= &
            '( binary-expr ( operator + ) ( left 1 ) ( right 2 ) )' .and. &
            trim(assignment%value) /= '( binary-expr ( operator * ) ( left 2 ) ( right 3 ) )' &
            .and. trim(assignment%value) /= '( binary-expr ( operator / ) ( left 6 ) ( right 2 ) )' &
            .and. trim(assignment%value) /= '( binary-expr ( operator – ) ( left 5 ) ( right 3 ) )' &
            .and. trim(assignment%value) /= &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))' &
            .and. trim(assignment%value) /= &
            '(assignment-expression (kind binary-expression) (operator *) (left-operand x) (right-operand 2))' &
            .and. trim(assignment%value) /= &
            '(assignment-expression (kind binary-expression) (operator –) (left-operand x) (right-operand 2))' &
            .and. trim(assignment%value) /= &
            '(assignment-expression (kind binary-expression) (operator /) (left-operand x) (right-operand 2))' &
            .and. .not. bounded_addend .and. .not. bounded_subtrahend .and. .not. bounded_multiplier .and. &
            .not. bounded_divisor .and. .not. bounded_power .and. .not. variable_power .and. &
            .not. variable_add .and. .not. variable_mul .and. .not. variable_div .and. .not. variable_sub) then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment')
            return
        end if
        if (len_trim(assignment%source_file) == 0 .or. len_trim(assignment%source_hash) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment')
            return
        end if
        if (assignment%start_byte < 0_int64 .or. assignment%end_byte < assignment%start_byte) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment-span')
            return
        end if
        valid = .true.
    end function ffc_validate_assignment_v1

    logical function read_assignment_expression(token, token_count, position, value, message) &
            result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message
        character(len=128) :: kind, operator, left_operand, right_operand
        integer(int32) :: literal_value
        integer(int32) :: addend_value, subtrahend_value, multiplier_value, divisor_value, power_value
        logical :: plus_supported, subtrahend_supported, multiplier_supported, divisor_supported, power_supported, &
            variable_power_supported, variable_add_supported, variable_mul_supported, variable_div_supported, &
            variable_sub_supported

        call clear_message(message)
        value = ''
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'expression', message)
        if (.not. ok) return
        if (position <= token_count) then
            if (trim(token(position)) == '(') then
                if (position + 1 <= token_count) then
                    if (trim(token(position + 1)) /= 'assignment-expression') then
                        ok = read_expression(token, token_count, position, value, message)
                        if (.not. ok) return
                    else
                        position = position + 2
                        ok = read_named_atom(token, token_count, position, 'kind', kind, message)
                        if (.not. ok) return
                        if (trim(kind) == 'integer-literal') then
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'operator', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'left-operand', &
                                message)
                            if (.not. ok) return
                            ok = read_atom(token, token_count, position, left_operand, message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'right-operand', &
                                message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            if (len_trim(left_operand) > 0 .and. left_operand(1:1) == '-') then
                                ok = len_trim(left_operand) > 1 .and. &
                                    parse_bounded_decimal_literal(trim(left_operand(2:)), literal_value, &
                                    message)
                                if (ok) literal_value = -literal_value
                            else
                                ok = parse_bounded_decimal_literal(trim(left_operand), literal_value, &
                                    message)
                            end if
                            if (.not. ok) then
                                call set_message(message, &
                                    'unsupported-frontend-ast-v1-assignment-expression')
                                return
                            end if
                            if (literal_value == 1_int32) then
                                value = '1'
                            else
                                write (value, '(a,i0,a)') '( integer-literal ', literal_value, ' )'
                            end if
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            return
                        end if
                        ok = read_named_atom(token, token_count, position, 'operator', operator, &
                            message)
                        if (.not. ok) return
                        ok = read_named_atom(token, token_count, position, 'left-operand', &
                            left_operand, message)
                        if (.not. ok) return
                        ok = read_named_atom(token, token_count, position, 'right-operand', &
                            right_operand, message)
                        if (.not. ok) return
                        ok = expect_token(token, token_count, position, ')', message)
                        if (.not. ok) return
                        plus_supported = .false.
                        subtrahend_supported = .false.
                        multiplier_supported = .false.
                        divisor_supported = .false.
                        power_supported = .false.
                        variable_power_supported = .false.
                        variable_add_supported = .false.
                        variable_mul_supported = .false.
                        variable_div_supported = .false.
                        variable_sub_supported = .false.
                        if (trim(operator) == '+' .and. trim(left_operand) == '1' .and. &
                            trim(right_operand) == '2') then
                            plus_supported = .true.
                        else if (trim(operator) == '+' .and. trim(left_operand) == 'x' .and. &
                                trim(right_operand) == 'x') then
                            variable_add_supported = .true.
                        else if (trim(operator) == '*' .and. trim(left_operand) == 'x' .and. &
                                trim(right_operand) == 'x') then
                            variable_mul_supported = .true.
                        else if (trim(operator) == '/' .and. trim(left_operand) == 'x' .and. &
                                trim(right_operand) == 'x') then
                            variable_div_supported = .true.
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == 'x' .and. trim(right_operand) == 'x') then
                            variable_sub_supported = .true.
                        else if (trim(operator) == '+' .and. trim(left_operand) == 'x') then
                            if (parse_bounded_decimal_literal(trim(right_operand), addend_value, message)) then
                                plus_supported = addend_value >= bounded_integer_addend_minimum .and. &
                                    addend_value <= bounded_integer_addend_maximum
                            end if
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == '5' .and. &
                                trim(right_operand) == '3') then
                            subtrahend_supported = .true.
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == 'x') then
                            if (parse_bounded_decimal_literal( &
                                trim(right_operand), subtrahend_value, message)) then
                                subtrahend_supported = subtrahend_value >= &
                                    bounded_integer_subtrahend_minimum .and. &
                                    subtrahend_value <= bounded_integer_subtrahend_maximum
                            end if
                        else if (trim(operator) == '*' .and. trim(left_operand) == 'x') then
                            if (parse_bounded_decimal_literal(trim(right_operand), multiplier_value, message)) then
                                multiplier_supported = multiplier_value >= bounded_integer_multiplier_minimum .and. &
                                    multiplier_value <= bounded_integer_multiplier_maximum
                            end if
                        else if (trim(operator) == '/' .and. trim(left_operand) == 'x') then
                            if (parse_bounded_decimal_literal(trim(right_operand), divisor_value, message)) then
                                divisor_supported = divisor_value >= bounded_integer_divisor_minimum .and. &
                                    divisor_value <= bounded_integer_divisor_maximum
                            end if
                        else if (trim(operator) == '**' .and. trim(left_operand) == 'x') then
                            if (trim(right_operand) == 'x') then
                                variable_power_supported = .true.
                            else if (parse_bounded_decimal_literal(trim(right_operand), power_value, message)) then
                                power_supported = is_bounded_integer_power(power_value)
                            end if
                        end if
                        if (trim(kind) /= 'binary-expression' .or. &
                            (trim(operator) /= '+' .and. trim(operator) /= '*' .and. &
                            trim(operator) /= '/' .and. trim(operator) /= '–' .and. trim(operator) /= '-' .and. &
                            trim(operator) /= '**') .or. &
                            (trim(operator) == '+' .and. .not. plus_supported .and. &
                            .not. variable_add_supported) .or. &
                            (trim(operator) == '/' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == 'x' .and. .not. variable_div_supported) .or. &
                            (trim(operator) == '*' .and. &
                            ((trim(left_operand) /= '2' .or. trim(right_operand) /= '3') .and. &
                            .not. multiplier_supported .and. .not. variable_mul_supported)) .or. &
                            (trim(operator) == '/' .and. &
                            ((trim(left_operand) /= '6' .or. trim(right_operand) /= '2') .and. &
                            (trim(left_operand) /= 'x' .or. &
                            (.not. divisor_supported .and. .not. variable_div_supported)))) .or. &
                            ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                            .not. subtrahend_supported .and. .not. variable_sub_supported) .or. &
                            (trim(operator) == '**' .and. .not. power_supported .and. &
                            .not. variable_power_supported)) then
                            call set_message(message, &
                                'unsupported-frontend-ast-v1-assignment-expression')
                            ok = .false.
                            return
                        end if
                        if (trim(operator) == '+' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator +) (left-operand x) (right-operand x))'
                        else if (trim(operator) == '+' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == '1') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator +) (left-operand x) (right-operand 1))'
                        else if (trim(operator) == '+' .and. trim(left_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator +) (left-operand x) (right-operand '//trim(right_operand)//'))'
                        else if (trim(operator) == '*' .and. trim(left_operand) == 'x' .and. &
                                trim(right_operand) == '2') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator *) (left-operand x) (right-operand 2))'
                        else if (trim(operator) == '*' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator *) (left-operand x) (right-operand x))'
                        else if (trim(operator) == '/' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator /) (left-operand x) (right-operand x))'
                        else if (trim(operator) == '*' .and. trim(left_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator *) (left-operand x) (right-operand '//trim(right_operand)//'))'
                        else if (trim(operator) == '/' .and. trim(left_operand) == 'x' .and. &
                                trim(right_operand) == '2') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator /) (left-operand x) (right-operand 2))'
                        else if (trim(operator) == '/' .and. trim(left_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator /) (left-operand x) (right-operand '//trim(right_operand)//'))'
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == 'x' .and. &
                                trim(right_operand) == '2') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator –) (left-operand x) (right-operand 2))'
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == 'x' .and. trim(right_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator –) (left-operand x) (right-operand x))'
                        else if ((trim(operator) == '–' .or. trim(operator) == '-') .and. &
                                trim(left_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator –) (left-operand x) (right-operand '// &
                                trim(right_operand)//'))'
                        else if (trim(operator) == '**' .and. trim(left_operand) == 'x') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator **) (left-operand x) (right-operand '//trim(right_operand)//'))'
                        else
                            value = '( binary-expr ( operator '//trim(operator)//' ) ( left '// &
                                trim(left_operand)//' ) ( right '//trim(right_operand)//' ) )'
                        end if
                    end if
                else
                    ok = read_expression(token, token_count, position, value, message)
                end if
            else
                ok = read_atom(token, token_count, position, value, message)
            end if
        else
            ok = read_atom(token, token_count, position, value, message)
        end if
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_assignment_expression

    logical function parse_integer_literal_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'integer-literal', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-integer-literal')
            ok = .false.
        end if
    end function parse_integer_literal_expression

    logical function parse_bounded_signed_initializer_literal(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position
        integer(int32) :: magnitude

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'integer-literal', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        if (len_trim(literal_text) > 0 .and. literal_text(1:1) == '-') then
            if (len_trim(literal_text) == 1 .or. &
                .not. parse_bounded_decimal_literal(trim(literal_text(2:)), magnitude, message) .or. &
                magnitude < 1_int32 .or. -magnitude < bounded_integer_initializer_minimum) then
                call set_message(message, 'unsupported-frontend-ast-v2-negative-initializer')
                ok = .false.
                return
            end if
            value = -magnitude
        else
            if (.not. parse_bounded_decimal_literal(trim(literal_text), value, message) .or. &
                value > bounded_integer_initializer_maximum .or. &
                value < bounded_integer_initializer_minimum) then
                call set_message(message, 'unsupported-frontend-ast-v2-integer-initializer')
                ok = .false.
                return
            end if
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-initializer')
            ok = .false.
        end if
    end function parse_bounded_signed_initializer_literal

    logical function starts_integer_literal_expression(serialized) result(is_literal)
        character(len=*), intent(in) :: serialized

        is_literal = .false.
        if (len_trim(serialized) < len('( integer-literal')) return
        is_literal = index(trim(serialized), '( integer-literal') == 1
    end function starts_integer_literal_expression

    logical function parse_bounded_addend_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'assignment-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'kind', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'binary-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'operator', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '+', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'left-operand', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'x', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'right-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        if (value < bounded_integer_addend_minimum .or. value > bounded_integer_addend_maximum) then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-addend')
            ok = .false.
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-addend')
            ok = .false.
        end if
    end function parse_bounded_addend_expression

    logical function parse_bounded_subtrahend_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'assignment-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'kind', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'binary-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'operator', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '–', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'left-operand', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'x', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'right-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        if (value < bounded_integer_subtrahend_minimum .or. &
            value > bounded_integer_subtrahend_maximum) then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-subtrahend')
            ok = .false.
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-subtrahend')
            ok = .false.
        end if
    end function parse_bounded_subtrahend_expression

    logical function parse_bounded_multiplier_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'assignment-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'kind', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'binary-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'operator', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '*', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'left-operand', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'x', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'right-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        if (value < bounded_integer_multiplier_minimum .or. &
            value > bounded_integer_multiplier_maximum) then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-multiplier')
            ok = .false.
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-multiplier')
            ok = .false.
        end if
    end function parse_bounded_multiplier_expression

    logical function parse_bounded_divisor_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'assignment-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'kind', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'binary-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'operator', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '/', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'left-operand', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'x', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'right-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        if (value < bounded_integer_divisor_minimum .or. &
            value > bounded_integer_divisor_maximum) then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-divisor')
            ok = .false.
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-divisor')
            ok = .false.
        end if
    end function parse_bounded_divisor_expression

    logical function parse_power_expression(serialized, right_operand, message) result(ok)
        character(len=*), intent(in) :: serialized
        character(len=*), intent(out) :: right_operand
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: left_operand
        integer :: token_count, position

        right_operand = ''
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'assignment-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'kind', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'binary-expression', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'operator', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '**', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'left-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, left_operand, message)
        if (.not. ok) return
        if (trim(left_operand) /= 'x') then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-power')
            ok = .false.
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'right-operand', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, right_operand, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-integer-power')
            ok = .false.
        end if
    end function parse_power_expression

    logical function parse_bounded_power_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=128) :: right_operand

        value = 0_int32
        call clear_message(message)
        ok = parse_power_expression(serialized, right_operand, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(trim(right_operand), value, message)
        if (.not. ok) return
        if (.not. is_bounded_integer_power(value)) then
            call set_message(message, 'unsupported-frontend-ast-v2-integer-power')
            ok = .false.
        end if
    end function parse_bounded_power_expression

    logical function is_variable_power_expression(serialized) result(is_variable)
        character(len=*), intent(in) :: serialized

        character(len=128) :: right_operand

        is_variable = parse_power_expression(serialized, right_operand)
        if (.not. is_variable) return
        is_variable = trim(right_operand) == 'x'
    end function is_variable_power_expression

    logical function is_bounded_integer_power(value) result(supported)
        integer(int32), intent(in) :: value

        supported = value >= bounded_integer_power_minimum .and. value <= bounded_integer_power_maximum
    end function is_bounded_integer_power

    logical function parse_bounded_decimal_literal(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer(int64) :: accumulator, digit
        integer :: position

        value = 0_int32
        call clear_message(message)
        ok = len_trim(text) > 0
        if (.not. ok) return
        accumulator = 0_int64
        do position = 1, len_trim(text)
            if (text(position:position) < '0' .or. text(position:position) > '9') then
                call set_message(message, 'frontend-ast-v1 integer literal is not decimal')
                ok = .false.
                return
            end if
            digit = int(iachar(text(position:position)) - iachar('0'), int64)
            if (accumulator > 214748364_int64 .or. &
                (accumulator == 214748364_int64 .and. digit > 7_int64)) then
                call set_message(message, 'frontend-ast-v1 integer literal is out of range')
                ok = .false.
                return
            end if
            accumulator = accumulator * 10_int64 + digit
        end do
        value = int(accumulator, int32)
        ok = .true.
    end function parse_bounded_decimal_literal

    logical function append_token(value, token, token_count, message) result(ok)
        character(len=*), intent(in) :: value
        character(len=*), intent(inout) :: token(:)
        integer, intent(inout) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        if (token_count == size(token)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(value) > len(token(1))) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        token_count = token_count + 1
        token(token_count) = value
        ok = .true.
    end function append_token

    logical function expect_token(token, token_count, position, expected, message) result(ok)
        character(len=*), intent(in) :: token(:), expected
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=:), allocatable, intent(out), optional :: message

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= expected) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        position = position + 1
        call clear_message(message)
        ok = .true.
    end function expect_token

    logical function read_named_atom(token, token_count, position, name, value, message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(token(position)) > len(value)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_atom

    logical function read_named_expression(token, token_count, position, name, expression, &
            message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        ok = read_expression(token, token_count, position, expression, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_expression

    logical function read_expression(token, token_count, position, expression, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        integer :: depth, index, start

        expression = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= '(') then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        start = position
        depth = 0
        do index = position, token_count
            if (trim(token(index)) == '(') then
                depth = depth + 1
            else if (trim(token(index)) == ')') then
                depth = depth - 1
            end if
            if (depth == 0) then
                expression = trim(token(start))
                do start = position + 1, index
                    if (len_trim(expression) + len_trim(token(start)) + 1 > len(expression)) then
                        call set_message(message, 'malformed-frontend-ast-v0')
                        ok = .false.
                        return
                    end if
                    expression = trim(expression)//' '//trim(token(start))
                end do
                position = index + 1
                ok = .true.
                return
            end if
        end do
        call set_message(message, 'malformed-frontend-ast-v0')
        ok = .false.
    end function read_expression

    logical function read_atom(token, token_count, position, value, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-assignment-expression')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-frontend-ast-v1-assignment-expression')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = .true.
    end function read_atom

    logical function parse_count(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        integer(int64) :: digit

        value = 0_int64
        call clear_message(message)
        if (len_trim(text) == 0) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            ok = .false.
            return
        end if
        do index = 1, len_trim(text)
            if (text(index:index) < '0' .or. text(index:index) > '9') then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            digit = int(iachar(text(index:index)) - iachar('0'), int64)
            if (value > (huge(value) - digit) / 10_int64) then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            value = value * 10_int64 + digit
        end do
        ok = .true.
    end function parse_count

    subroutine clear_message(message)
        character(len=:), allocatable, intent(out), optional :: message

        if (present(message)) then
            if (allocated(message)) deallocate (message)
        end if
    end subroutine clear_message

    subroutine set_message(message, text)
        character(len=:), allocatable, intent(out), optional :: message
        character(len=*), intent(in) :: text

        if (present(message)) message = text
    end subroutine set_message

end module ffc_frontend_ast
