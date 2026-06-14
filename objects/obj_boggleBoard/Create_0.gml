depth = 1

self.tile_list = ds_list_create();

state_machine = new Statement(self);

// Idle
var _playerTurn = new StatementState(self, "PlayerTurn")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		player.isMyTurn = true;
		
		var enemy = instance_find(obj_enemy, 0);
		enemy.isMyTurn = false;
	})
	.AddUpdate(function() {
		
	});

var _enemyTurn = new StatementState(self, "EnemyTurn")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		player.isMyTurn = false;
		
		var enemy = instance_find(obj_enemy, 0);
		enemy.isMyTurn = true;
	})
	.AddUpdate(function() {
		
	});

state_machine
	.AddState(_playerTurn)
	.AddState(_enemyTurn)

randomize();

populateBoard();

StatementLensUpdate();