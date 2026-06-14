var _key = instance_place(x, y, obj_key);
if (instance_exists(_key)) {
	with (obj_controller_metamachine) {
		game_won = true;
	}
	with (_key) {
		instance_destroy();
	}
}