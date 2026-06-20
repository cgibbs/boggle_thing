if ChatterboxIsWaiting(chatterbox){
	if keyboard_check_pressed(vk_space) {
		ChatterboxContinue(chatterbox);
		text = ChatterboxGetContent(chatterbox,0);
		nodeTitle   = ChatterboxGetCurrent(chatterbox); 
	}
}