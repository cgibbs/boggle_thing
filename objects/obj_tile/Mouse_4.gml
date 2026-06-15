var board = instance_find(getBoardType(), 0);
var boardType = getBoardType();
var player = instance_find(obj_player, 0);

if (board.state_machine.GetCurrentStateName() != "PlayerTurn"
	or player.state_machine.GetCurrentStateName() != "Idle") return;

if (!isSelected and !isInWord) {
	var playedWord = instance_find(obj_playedWord, 0);

	// do this before duplication for the sake of playedWord logic later
	isSelected = true;

	var duplicate = instance_copy(false);
	duplicate.isSelected = false;
	duplicate.isInWord = true;
	duplicate.original_tile = self;
	duplicate.spotInPlayedWord = ds_list_size(playedWord.word_list);

	show_debug_message("adding to played word");
	ds_list_add(playedWord.word_list, duplicate);
	arrangePlayedWord();
} else if (isInWord) {
	var playedWord = instance_find(obj_playedWord, 0);
	var myIndex = spotInPlayedWord;
	for (var i = myIndex; i < ds_list_size(playedWord.word_list); i++) {
		with (ds_list_find_value(playedWord.word_list, i)) {
			original_tile.isSelected = false;
			ds_list_set(playedWord.word_list, i, undefined);
			instance_destroy();
		}
	}
	
	while (myIndex < ds_list_size(playedWord.word_list)) {
		if (ds_list_find_value(playedWord.word_list, myIndex) == undefined) {
			ds_list_delete(playedWord.word_list, myIndex);
		} else {
			myIndex += 1;	
		}
	}
	
	arrangePlayedWord();
}