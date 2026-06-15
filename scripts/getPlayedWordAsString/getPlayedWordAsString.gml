function getPlayedWordAsString(){
	var ret_string = "";
	with(instance_find(obj_playedWord, 0)) {
		for (var i = 0; i < ds_list_size(word_list); i++) {
			var stringToAdd = ds_list_find_value(word_list, i).tile_letter;
			ret_string = string_concat(ret_string, stringToAdd);
		}
	}
	
	return ret_string;
}

function getPlayedWordValue() {
	var word_score = 0;
	with(instance_find(obj_playedWord, 0)) {
		for (var i = 0; i < ds_list_size(word_list); i++) {
			var numToAdd = ds_list_find_value(word_list, i).tile_value;
			word_score += numToAdd;
		}
	}
	
	return word_score;
}

function getPlayedWordAttack() {
	var word_attack = 0;
	with(instance_find(obj_playedWord, 0)) {
		for (var i = 0; i < ds_list_size(word_list); i++) {
			if (ds_list_find_value(word_list, i).tile_type == "wood"
				or ds_list_find_value(word_list, i).tile_type == "dream"
				or ds_list_find_value(word_list, i).tile_type == "nightmare") {
				var numToAdd = ds_list_find_value(word_list, i).tile_value;
				word_attack += numToAdd;
			}
		}
	}
	
	return word_attack;
}

function getPlayedWordDefense() {
	var word_defense = 0;
	with(instance_find(obj_playedWord, 0)) {
		for (var i = 0; i < ds_list_size(word_list); i++) {
			if (ds_list_find_value(word_list, i).tile_type == "plastic") {
				var numToAdd = ds_list_find_value(word_list, i).tile_value;
				word_defense += numToAdd;
			}
		}
	}
	
	return word_defense;
}