function getNRandomTileIndices(n) {
	var board = instance_find(getBoardType(), 0);
	var tile_list = board.tile_list;
	var bag = ds_list_create();
	// populate a bag of all possible tile indices
	for (var i = 0; i < ds_list_size(tile_list); i++) {
		ds_list_add(bag, i);	
	}
	
	// shuffle bag
	ds_list_shuffle(bag);
	
	// return first n tiles in shuffled bag
	var ret = ds_list_create();
	
	for (var i = 0; i < n; i++) {
		var ret_idx = ds_list_find_value(bag, i);
		//ds_list_add(ret, ds_list_find_value(tile_list, ret_idx));	
		ds_list_add(ret, ret_idx);
	}
	
	return ret;
}