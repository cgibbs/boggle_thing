if (keyboard_check_pressed(ECHO_CONSOLE_KEY)) {
	if (variable_global_exists("__echo_chamber_root") && is_instanceof(global.__echo_chamber_root, EchoChamberRoot)) {
		var _win = global.__echo_chamber_root.FindWindow("echo_console");
		if (is_undefined(_win)) {
			EchoChamberOpenConsole(global.__echo_chamber_root);
		}
		else {
			with (_win) {
				if (!visible) {
					EchoChamberOpenConsole(global.__echo_chamber_root);
				}
				else {
					global.__echo_chamber_root.BringWindowToFront(_win);
					Close();
				}
			}
		}
	}
}