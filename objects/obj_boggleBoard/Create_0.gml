depth = 1

self.tile_list = ds_list_create();

state_machine = new Statement(self);

// Idle
var _playerTurn = new StatementState(self, "PlayerTurn")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		if (player.hp < 1) {
			state_machine.ChangeState("YouLose");	
		}
		player.isMyTurn = true;
		player.pendingDamage = -1;
		player.defense = 0;
		
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
		if (enemy.hp < 1) {
			state_machine.ChangeState("YouWin");	
		}
		enemy.isMyTurn = true;
		enemy.defense = 0;
	})
	.AddUpdate(function() {
		
	});
	
var _youWin = new StatementState(self, "YouWin")
	.AddEnter(function() {
		
	})
	.AddUpdate(function() {
		
	});
	
var _youLose = new StatementState(self, "YouLose")
	.AddEnter(function() {
		
	})
	.AddUpdate(function() {
		
	});

state_machine
	.AddState(_playerTurn)
	.AddState(_enemyTurn)
	.AddState(_youWin)
	.AddState(_youLose);

randomize();

populateBoard();

StatementLensUpdate();