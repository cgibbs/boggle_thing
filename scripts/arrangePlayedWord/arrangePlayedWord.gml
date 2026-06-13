function arrangePlayedWord(){
	var playedWord = instance_find(obj_playedWord, 0);
	
	var tile_x = playedWord.x;
	var tile_y = playedWord.y;

	show_debug_message("arranging tiles in played word");
	var board = instance_find(obj_boggleBoard, 0);
	var testList = board.tile_list;
	
	if (ds_list_size(playedWord.word_list) > 0) {
		var clear_inst = instance_find(obj_clearButton, 0);
		var submit_inst = instance_find(obj_submitButton, 0);
		clear_inst.isHidden = false;
		submit_inst.isHidden = false;
	} else {
		var clear_inst = instance_find(obj_clearButton, 0);
		var submit_inst = instance_find(obj_submitButton, 0);
		clear_inst.isHidden = true;
		submit_inst.isHidden = true;
	}
	
	for (var i = 0; i < ds_list_size(playedWord.word_list); i++) {
		var tile_to_move = ds_list_find_value(playedWord.word_list, i);
		//show_debug_message(tile_to_move.tile_letter);
		tile_to_move.x = tile_x;
		tile_to_move.y = tile_y;
		
		tile_x += TILE_SIZE_W_BOUNDARIES;
	}
}