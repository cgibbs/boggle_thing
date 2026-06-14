// Call the Update() method on your state machine to make it run the Update handler for
// your current state
sm.Update();

if (keyboard_check_released(vk_enter)) {
	room_goto_next();
}