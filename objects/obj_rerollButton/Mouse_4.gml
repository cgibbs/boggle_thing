var board = instance_find(getBoardType(), 0);
var player = instance_find(obj_player, 0);

if (board.state_machine.GetCurrentStateName() != "PlayerTurn"
	or player.state_machine.GetCurrentStateName() != "Idle") return;
	
if (board.state_machine.GetCurrentStateName() == "PlayerTurn") {
	emptyBoard();
	if (getBoardType() == obj_dreamBoggleBoard) {
		populateBadDream()	
	} else {
		populateBoard();
	}
	board.state_machine.ChangeState("EnemyTurn");
}