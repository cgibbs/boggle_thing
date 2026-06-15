var playedWord = instance_find(obj_playedWord, 0);

with (instance_find(getBoardType(), 0)) {
	for (var i = 0; i < ds_list_size(tile_list); i++) {
		var current_tile_val = ds_list_find_value(tile_list, i);
		current_tile_val.isSelected = false;
	}
}

for (var i = 0; i < ds_list_size(playedWord.word_list); i++) {
	with (ds_list_find_value(playedWord.word_list, i)) {
		instance_destroy();	
	}
}

ds_list_clear(playedWord.word_list);

arrangePlayedWord();