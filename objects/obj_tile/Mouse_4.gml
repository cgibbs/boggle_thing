show_debug_message("clicked tile");

if (!isSelected) {
	var playedWord = instance_find(obj_playedWord, 0);

	// do this before duplication for the sake of playedWord logic later
	isSelected = true;

	var duplicate = instance_copy(false);

	show_debug_message("adding to played word");
	ds_list_add(playedWord.word_list, duplicate);
	arrangePlayedWord();
} else {

}