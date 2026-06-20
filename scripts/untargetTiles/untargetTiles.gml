function untargetTiles(){
	var board = instance_find(getBoardType(), 0);
	var tile_list = board.tile_list;
	
	for (var i = 0; i < ds_list_size(tile_list); i++) {
		targetTile = ds_list_find_value(tile_list, i);
		targetTile.isTargeted = false;
	}
}

function deleteTargetedTiles(){
	var board = instance_find(getBoardType(), 0);
	var tile_list = board.tile_list;
	
	for (var i = 0; i < ds_list_size(tile_list); i++) {
		targetTile = ds_list_find_value(tile_list, i);
		if (targetTile.isTargeted) {
			ds_list_set(tile_list, i, undefined);
			instance_destroy(targetTile);
		}
	}
}