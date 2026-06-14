// relative to board's 0,0
#macro TILE_ZERO_X 10
#macro TILE_ZERO_Y 38
#macro TILE_SIZE 64
#macro TILE_SIZE_W_BOUNDARIES 66
#macro BOARD_WIDTH 4
#macro TILE_COUNT 16

global.FRESH_BAG = [
	{letter: "a", value: 1},
	{letter: "a", value: 1},
	{letter: "a", value: 1},
	{letter: "a", value: 1},
	{letter: "a", value: 1},
	{letter: "b", value: 1},
	{letter: "b", value: 1},
	{letter: "c", value: 1},
	{letter: "c", value: 1},
	{letter: "d", value: 1},
	{letter: "d", value: 1},
	{letter: "e", value: 1},
	{letter: "e", value: 1},
	{letter: "e", value: 1},
	{letter: "e", value: 1},
	{letter: "e", value: 1},
	{letter: "e", value: 1},
	{letter: "f", value: 1},
	{letter: "f", value: 1},
	{letter: "g", value: 1},
	{letter: "g", value: 1},
	{letter: "g", value: 1},
	{letter: "h", value: 1},
	{letter: "i", value: 1},
	{letter: "i", value: 1},
	{letter: "i", value: 1},
	{letter: "j", value: 1},
	{letter: "k", value: 1},
	{letter: "l", value: 1},
	{letter: "l", value: 1},
	{letter: "l", value: 1},
	{letter: "m", value: 1},
	{letter: "m", value: 1},
	{letter: "n", value: 1},
	{letter: "n", value: 1},
	{letter: "n", value: 1},
	{letter: "n", value: 1},
	{letter: "o", value: 1},
	{letter: "o", value: 1},
	{letter: "o", value: 1},
	{letter: "o", value: 1},
	{letter: "o", value: 1},
	{letter: "p", value: 1},
	{letter: "q", value: 1},
	{letter: "r", value: 1},
	{letter: "r", value: 1},
	{letter: "s", value: 1},
	{letter: "s", value: 1},
	{letter: "s", value: 1},
	{letter: "t", value: 1},
	{letter: "u", value: 1},
	{letter: "u", value: 1},
	{letter: "u", value: 1},
	{letter: "v", value: 1},
	{letter: "w", value: 1},
	{letter: "x", value: 1},
	{letter: "y", value: 1},
	{letter: "z", value: 1}
]

// call me at board creation time
function populateBoard(){
	var tile_bag = ds_list_create();
	
	for (var i = 0; i < array_length(global.FRESH_BAG); i++) {
		ds_list_add(tile_bag, global.FRESH_BAG[i]);	
	}
	
	ds_list_shuffle(tile_bag)
	
	show_debug_message("populating board");
	var board_inst = instance_find(obj_boggleBoard, 0);
	var board_x = board_inst.x;
	var board_y = board_inst.y;
	
	var tile_x = board_x + TILE_ZERO_X;
	var tile_y = board_y + TILE_ZERO_Y;
	
	for (var i = 0; i < TILE_COUNT; i++) {
		// just making a handle in case we need it later
		var createdTile = createTile(tile_x, tile_y);
		createdTile.tile_letter = ds_list_find_value(tile_bag, i).letter;
		createdTile.tile_value = ds_list_find_value(tile_bag, i).value;
	
		ds_list_add(board_inst.tile_list, createdTile);
	
		if ((i + 1) % 4 == 0) {
			tile_x = board_x + TILE_ZERO_X;
			tile_y += TILE_SIZE_W_BOUNDARIES;
		} else {
			tile_x += TILE_SIZE_W_BOUNDARIES;
		}
	}
}

// do this when a word gets played successfully
function refillBoard(){
	// loop over tile_list
	// if tile == undefined
	// make new tile and replace undefined
	
	
	// OLD NOTES
	// check whether hasBeenPlayed is true on tile
	// (note: played tiles should be flagged thusly at time of successful submission)
	// move down all tiles above hasBeenPlayedTile
	// create new tile at the appropriate tile locations
	// destroy played tile
}

function removePlayed(){
	show_debug_message("removing played tiles");
	var board_inst = instance_find(obj_boggleBoard, 0);
	var s = ds_list_size(board_inst.tile_list);
	for (var i = 0; i < ds_list_size(board_inst.tile_list); i++) {
		var cur_tile = ds_list_find_value(board_inst.tile_list, i);
		
		if (cur_tile == undefined) continue;
		
		if (cur_tile.hasBeenPlayed == true) {
			//board_inst.tile_list[i] = undefined;
			show_debug_message("deleting tile")
			ds_list_set(board_inst.tile_list, i, undefined);
			instance_destroy(cur_tile);
		}
	}
	
	show_debug_message(json_encode(board_inst.tile_list));
}

function DoGravity(){
	// start from last tile and work backwards
	var board_tile_list = instance_find(obj_boggleBoard, 0).tile_list;
	// subtracting 4 because we don't need to do gravity on bottom tiles
	for (var i = ds_list_size(board_tile_list) - 4 - 1; i >= 0; i--) {
		if (ds_list_find_value(board_tile_list, i) != undefined) {
			//LiftNullTile(i);
			DropTile(i);
		}
	}
}

function DropTile(ind) {
	var curInd = ind;
	var board_tile_list = instance_find(obj_boggleBoard, 0).tile_list;
	var tileBelowInd = ind + 4;
	while (tileBelowInd < 16) {
		if (ds_list_find_value(board_tile_list, tileBelowInd) == undefined) {
			with(ds_list_find_value(board_tile_list, curInd)) {
				y += TILE_SIZE_W_BOUNDARIES;
			}
			
			ds_list_set(board_tile_list, tileBelowInd, ds_list_find_value(board_tile_list, curInd));
			ds_list_set(board_tile_list, curInd, undefined);
		}
		
		curInd = tileBelowInd;
		tileBelowInd += 4;
	}
}

//function LiftNullTile(ti) {
//	var tileIndex = ti;
//	var tileAboveIndex = tileIndex - BOARD_WIDTH;
//	var board_tile_list = instance_find(obj_boggleBoard, 0).tile_list;
//	while (tileAboveIndex >= 0) {
//	    // code here
//		//var tempTile = board_tile_list[tileIndex];
//		//board_tile_list[tileIndex] = board_tile_list[tileAboveIndex];
//		//board_tile_list[tileAboveIndex] = tempTile;
//		var tempTile = ds_list_find_value(board_tile_list, tileIndex);
//		var tempTile2 = ds_list_find_value(board_tile_list, tileAboveIndex);
//		tempTile2.y += TILE_SIZE_W_BOUNDARIES;
//		ds_list_set(board_tile_list, tileIndex, tempTile2);
//		ds_list_set(board_tile_list, tileAboveIndex, tempTile);
		
//		tileIndex = tileAboveIndex;
//		tileAboveIndex -= BOARD_WIDTH;
//	}
//}

function createTile(new_x, new_y) {
	show_debug_message("created tile");
	var new_tile = instance_create_layer(new_x, new_y, "Instances", obj_tile);
	// get tile letter and value from bag once we're done testing board population code
	//new_tile.tile_letter = 
	//new_tile.tile_value = 
	// need to think hard about how to put effects on tiles; tag system?
	//new_tile.effect = 
	return new_tile;
}