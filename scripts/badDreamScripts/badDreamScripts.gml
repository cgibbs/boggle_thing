function populateBadDream(){
	// call me at board creation time
	var tile_bag = ds_list_create();
	
	for (var i = 0; i < array_length(global.FRESH_BAG); i++) {
		ds_list_add(tile_bag, global.FRESH_BAG[i]);	
	}
	
	ds_list_shuffle(tile_bag)
	
	show_debug_message("populating board");
	var board_inst = instance_find(obj_dreamBoggleBoard, 0);
	var board_x = board_inst.x;
	var board_y = board_inst.y;
	
	var tile_x = board_x + TILE_ZERO_X;
	var tile_y = board_y + TILE_ZERO_Y;
	
	for (var i = 0; i < TILE_COUNT; i++) {
		// just making a handle in case we need it later
		var createdTile = createDreamTile(tile_x, tile_y);
		createdTile.tile_letter = ds_list_find_value(tile_bag, i).letter;
		createdTile.tile_value = ds_list_find_value(tile_bag, i).value;
		
		if (createdTile.tile_type == "nightmare") createdTile.tile_value = 0 - createdTile.tile_value;
	
		ds_list_add(board_inst.tile_list, createdTile);
	
		if ((i + 1) % 4 == 0) {
			tile_x = board_x + TILE_ZERO_X;
			tile_y += TILE_SIZE_W_BOUNDARIES;
		} else {
			tile_x += TILE_SIZE_W_BOUNDARIES;
		}
	}
}

function createDreamTile(new_x, new_y) {
	show_debug_message("created tile");
	var new_tile = instance_create_layer(new_x, new_y, "Instances", obj_tile);
	if (random(10) > 8) new_tile.tile_type = "nightmare";
	else new_tile.tile_type = "dream";
	// get tile letter and value from bag once we're done testing board population code
	//new_tile.tile_letter = 
	//new_tile.tile_value = 
	// need to think hard about how to put effects on tiles; tag system?
	//new_tile.effect = 
	return new_tile;
}

function refillDreamBoard(){
	// loop over tile_list
	// if tile == undefined
	// make new tile and replace undefined
	
	var tile_bag = ds_list_create();
	
	for (var i = 0; i < array_length(global.FRESH_BAG); i++) {
		ds_list_add(tile_bag, global.FRESH_BAG[i]);	
	}
	
	ds_list_shuffle(tile_bag)
	
	var board_inst = instance_find(getBoardType(), 0);
	
	var board_x = board_inst.x;
	var board_y = board_inst.y;
	
	for (var i = 0; i < ds_list_size(board_inst.tile_list); i++) {
		var cur_tile = ds_list_find_value(board_inst.tile_list, i);
		
		if (cur_tile == undefined) {
			var new_x = board_x + TILE_ZERO_X + TILE_SIZE_W_BOUNDARIES * (i % 4);
			var new_y = board_y + TILE_ZERO_Y + TILE_SIZE_W_BOUNDARIES * (int64(i / 4));
			var new_tile = createDreamTile(new_x, new_y);
			
			new_tile.tile_letter = ds_list_find_value(tile_bag, i).letter;
			new_tile.tile_value = ds_list_find_value(tile_bag, i).value;
			
			if (new_tile.tile_type == "nightmare") new_tile.tile_value = 0 - new_tile.tile_value;
			
			ds_list_set(board_inst.tile_list, i, new_tile);
		}
	}
	
	// OLD NOTES
	// check whether hasBeenPlayed is true on tile
	// (note: played tiles should be flagged thusly at time of successful submission)
	// move down all tiles above hasBeenPlayedTile
	// create new tile at the appropriate tile locations
	// destroy played tile
}