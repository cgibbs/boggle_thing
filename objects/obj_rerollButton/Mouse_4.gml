var board = instance_find(getBoardType(), 0);
var player = instance_find(obj_player, 0);

if (board.state_machine.GetCurrentStateName() != "PlayerTurn"
	or player.state_machine.GetCurrentStateName() != "Idle") return;

// copied code from Clear Button, should make it a dedicated script
if (board.state_machine.GetCurrentStateName() == "PlayerTurn") {
	var playedWord = instance_find(obj_playedWord, 0);

	with (instance_find(getBoardType(), 0)) {
		for (var i = 0; i < ds_list_size(tile_list); i++) {
			var current_tile_val = ds_list_find_value(tile_list, i);
			if ((current_tile_val != noone) and current_tile_val != undefined) {
				current_tile_val.isSelected = false;
			}
		}
	}

	for (var i = 0; i < ds_list_size(playedWord.word_list); i++) {
		with (ds_list_find_value(playedWord.word_list, i)) {
			instance_destroy();	
		}
	}

	ds_list_clear(playedWord.word_list);

	arrangePlayedWord();
	
	emptyBoard();
	if (getBoardType() == obj_dreamBoggleBoard) {
		populateBadDream()	
	} else {
		populateBoard();
	}
	board.state_machine.ChangeState("EnemyTurn");
}