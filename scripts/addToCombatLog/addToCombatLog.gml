function addToCombatLog(message){
	show_debug_message("Adding message to combat log");
	var MAX_LINE_COUNT = 12;
	obj_log = instance_find(obj_combatLog, 0);
	if (obj_log != noone) {
		ds_list_add(obj_log.log, message);
	}
	
	var start_idx = max(0, ds_list_size(obj_log.log) - MAX_LINE_COUNT);
	var end_idx = min(start_idx + MAX_LINE_COUNT, ds_list_size(obj_log.log));
	
	// update text to render in combat log
	obj_log.textToRender = ds_list_find_value(obj_log.log, start_idx);
	for (var i = start_idx + 1; i < end_idx; i++) {
		obj_log.textToRender = string_join("\n", obj_log.textToRender, ds_list_find_value(obj_log.log, i));
	}
}