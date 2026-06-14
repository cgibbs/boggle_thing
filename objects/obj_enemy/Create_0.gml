image_speed = 0;

state_machine = new Statement(self);

// Idle
var _idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
	})
	.AddUpdate(function() {
		var player = instance_find(obj_player, 0);
		if (self.pendingDamage == 0) {
			state_machine.ChangeState("BlockingDamage");
		} else if (self.pendingDamage > 0) {
			state_machine.ChangeState("TakingDamage");
		} else if (self.isMyTurn == true and player.pendingDamage < 0) {
			state_machine.ChangeState("Thinking");
		}
	});
	
var _attacking = new StatementState(self, "Attacking")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		show_debug_message("enemy attacking");
		player.pendingDamage = 3;
		image_index = 1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			var board = instance_find(obj_boggleBoard, 0);
			board.state_machine.ChangeState("PlayerTurn");
			self.isMyTurn = false;
			state_machine.ChangeState("Idle");	
		}
	});
	
var _thinking = new StatementState(self, "Thinking")
	.AddEnter(function() {
		
	})
	.AddUpdate(function() {
		// this is where you put logic to figure out next attack
		if (state_machine.GetStateTime() >= 30) {
			state_machine.ChangeState("Attacking");	
		}
	});
	
var _takingDamage = new StatementState(self, "TakingDamage")
	.AddEnter(function() {
		image_index = 3;
		self.hp -= self.pendingDamage;
		self.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			state_machine.ChangeState("Idle");	
		}
	});
	
var _blockingDamage = new StatementState(self, "BlockingDamage")
	.AddEnter(function() {
		image_index = 2;
		self.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			state_machine.ChangeState("Idle");
		}
	});

state_machine
	.AddState(_idle)
	.AddState(_attacking)
	.AddState(_takingDamage)
	.AddState(_blockingDamage)
	.AddState(_thinking);