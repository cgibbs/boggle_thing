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
		
		var enemy = instance_find(global.enemyType, 0);
		enemy.isMyTurn = false;
	})
	.AddUpdate(function() {
		
	});

var _enemyTurn = new StatementState(self, "EnemyTurn")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		player.isMyTurn = false;
		
		var enemy = instance_find(global.enemyType, 0);
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
		global.playerWins += 1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 120) {
			show_debug_message("going back to overworld");
			var player = instance_find(obj_player, 0);
			global.playerHp = player.hp;
			room_goto(OverworldRoom);
		}
	});
	
var _youLose = new StatementState(self, "YouLose")
	.AddEnter(function() {
		
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 120) {
			room_goto(OverworldRoom);
		}
	});

state_machine
	.AddState(_playerTurn)
	.AddState(_enemyTurn)
	.AddState(_youWin)
	.AddState(_youLose);

state_machine.ChangeState("PlayerTurn");
state_machine.SetPaused(false);

randomize();

populateBoard();