if (variable_global_exists("__echo_chamber_root")) {
	StatementLensUpdate();
}

if (keyboard_check_released(vk_enter)) {
	room_goto(rm_statement_2state);
}