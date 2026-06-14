var testWord = getPlayedWordAsString();

if (global.dictionary.check(testWord)) {
	// do damage stuff here, before emptying out the played word and stuff
	
	var enemy = instance_find(obj_enemy, 0);
	enemy.pendingDamage = getPlayedWordAttack();
	
	var player = instance_find(obj_player, 0);
	player.defense = getPlayedWordDefense();
	
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

	player.state_machine.ChangeState("Attacking");
	
} else {
	show_debug_message("word is invalid!");	
}