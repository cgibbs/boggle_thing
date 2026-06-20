function getCombatByRoom(room_type){
	switch (room_type) {
	    case MarketRoom:
	        // code here
			return choose(KirbysDadRoom, FurryRoom, BadSpriteRoom, RealBadSpriteRoom);
	    default:
	        // code here
	        break;
	}
}