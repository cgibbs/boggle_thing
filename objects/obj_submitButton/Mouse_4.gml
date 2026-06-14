var testWord = getPlayedWordAsString();
var potentialScore = getPlayedWordValue();

show_debug_message(testWord);

if (global.dictionary.check(testWord)) {
	show_debug_message("word is valid!");
	show_debug_message("submitted \"" + testWord + "\" for " + string(potentialScore) + " points!");
	
	// do damage stuff here, before emptying out the played word and stuff
	
	var enemy = instance_find(obj_enemy, 0);
	
	enemy.pendingDamage = potentialScore;
	
	var playedWord = instance_find(obj_playedWord, 0);
	
	with (instance_find(obj_boggleBoard, 0)) {
		for (var i = 0; i < ds_list_size(tile_list); i++) {
			var temp_var = ds_list_find_value(tile_list, i)
			if (ds_list_find_value(tile_list, i) != undefined) {
				with (ds_list_find_value(tile_list, i)) {
					if (isSelected) {
						hasBeenPlayed = true;	
					}
				}
			}
		}
	}
	
	removePlayed();
	
	for (var i = 0; i < ds_list_size(playedWord.word_list); i++) {
		with (ds_list_find_value(playedWord.word_list, i)) {
			instance_destroy();	
		}
	}

	ds_list_clear(playedWord.word_list);
	
	DoGravity();
	
	refillBoard();
	
	arrangePlayedWord();
	
} else {
	show_debug_message("word is invalid!");	
}