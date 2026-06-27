function initializeInventory() {
	if (!variable_global_exists("inventory")) {
		global.inventory = ds_map_create();
	}
	
	if (!variable_global_exists("item_data")) {
		global.item_data = ds_map_create();
		
		// these should probably be made into an actual constructed type at some point
		ds_map_add(global.item_data, "Popped Soda Tab",
		{
			name: "Popped Soda Tab",
			description: "A soda tab wrenched from the corpse of a Real Bad Sprite.",
			value: 1,
			questItem: true,
			equippable: false,
			onUse: undefined
		});
		
		ds_map_add(global.item_data, "Kirby Skin",
		{
			name: "Kirby Skin",
			description: "It's crazy that you thought it was okay to take this, not even gonna lie. I guess you could make it into clothes, if you were some kinda psycho.",
			value: 5,
			questItem: false,
			equippable: false,
			onUse: undefined
		});
		
		ds_map_add(global.item_data, "Viking Hat",
		{
			name: "Viking Hat",
			description: "Mandatory RPG headwear. +1 to defense total if a defense tile is selected.",
			value: 8,
			questItem: false,
			equippable: true,
			onUse: undefined
		});
		
		ds_map_add(global.item_data, "Corrupted Sprite Data",
		{
			name: "Corrupted Sprite Data",
			description: "Looking directly at this makes your head hurt. Throw it at the enemy to make THEIR head hurt, instead.",
			value: 5,
			questItem: false,
			equippable: false,
			onUse: function () {
				
			}
		});
		
		ds_map_add(global.item_data, "Furry Tail",
		{
			name: "Furry Tail",
			description: "The furry anti-fandom pays a nice bounty for these, but I suspect they wear them when no one is looking.",
			questItem: false,
			value: 10,
			equippable: true,
			onUse: undefined
		});
	}
}

function addInventoryItem(itemName, amount) {
	if (!ds_map_exists(global.item_data, itemName)) {
		show_debug_message(string(itemName) + " not found in item_data map!");
		return;
	}
	if (!ds_map_exists(global.inventory, itemName)) {
		ds_map_add(global.inventory, itemName, amount);
	} else {
		var new_amount = ds_map_find_value(global.inventory, itemName) + amount;
		ds_map_set(global.inventory, itemName, new_amount);
	}
}

function getInventoryItemAmount(itemName) {
	if (!ds_map_exists(global.item_data, itemName)) {
		show_debug_message(string(itemName) + " not found in item_data map!");
		return;
	}
	if (ds_map_exists(global.inventory, itemName)) {
		return ds_map_find_value(global.inventory, itemName);	
	} else {
		show_debug_message(string(itemName)	+ " is not in inventory!");
	}
}