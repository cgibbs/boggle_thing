image_speed = 0;

state_machine = new Statement(self);

// Idle
var _idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
	})
	.AddUpdate(function() {
		//var player = instance_find(obj_player, 0)
		//if (player.pendingDamage == 0) {
		//	state_machine.ChangeState("BlockingDamage");
		//} else if (player.pendingDamage > 0) {
		//	state_machine.ChangeState("TakingDamage");	
		//}
		var player = instance_find(obj_player, 0);
		var calcDamage = self.pendingDamage - self.defense;
		calcDamage = max(calcDamage, 0)
		if (self.pendingDamage > 0 and calcDamage == 0) {
			state_machine.ChangeState("BlockingDamage");
		} else if (calcDamage > 0) {
			state_machine.ChangeState("TakingDamage");
		} 
	});
	
var _attacking = new StatementState(self, "Attacking")
	.AddEnter(function() {
		image_index = 1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			var board = instance_find(obj_boggleBoard, 0);
			board.state_machine.ChangeState("EnemyTurn");
			
			state_machine.ChangeState("Idle");	
		}
	});
	
var _takingDamage = new StatementState(self, "TakingDamage")
	.AddEnter(function() {
		show_debug_message("taking damage");
		image_index = 3;
		self.hp -= (self.pendingDamage - self.defense);
		self.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			if (self.hp > 0) {
				state_machine.ChangeState("Idle");
			} else {
				state_machine.ChangeState("Dead");
			}
		}
	});
	
var _blockingDamage = new StatementState(self, "BlockingDamage")
	.AddEnter(function() {
		image_index = 2;
		var player = instance_find(obj_player, 0)
		player.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			state_machine.ChangeState("Idle");	
		}
	});
	
var _dead = new StatementState(self, "Dead")
	.AddEnter(function() {
		image_index = 4;
		isMyTurn = false;
	}).AddUpdate(function() {
		
	});

state_machine
	.AddState(_idle)
	.AddState(_attacking)
	.AddState(_takingDamage)
	.AddState(_blockingDamage)
	.AddState(_dead);