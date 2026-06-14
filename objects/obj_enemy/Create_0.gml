image_speed = 0;

randomize();

gold = round(random(5) + 5);

state_machine = new Statement(self);

// Idle
var _idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
	})
	.AddUpdate(function() {
		var player = instance_find(obj_player, 0);
		var calcDamage = self.pendingDamage - self.defense;
		calcDamage = max(calcDamage, 0)
		if (self.pendingDamage > 0 and calcDamage == 0) {
			state_machine.ChangeState("BlockingDamage");
		} else if (calcDamage > 0) {
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
			self.attackedLastTurn = true;
			state_machine.ChangeState("Idle");	
		}
	});
	
var _blocking = new StatementState(self, "Blocking")
	.AddEnter(function() {
		self.image_index = 2
		self.defense = 3;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 30) {
			var board = instance_find(obj_boggleBoard, 0);
			board.state_machine.ChangeState("PlayerTurn");
			self.attackedLastTurn = false;
			state_machine.ChangeState("Idle");	
		}
	})
	
var _thinking = new StatementState(self, "Thinking")
	.AddEnter(function() {
		image_index = 4;
	})
	.AddUpdate(function() {
		// this is where you put logic to figure out next attack
		if (state_machine.GetStateTime() >= 60) {
			if (self.attackedLastTurn) {
				state_machine.ChangeState("Blocking");
			} else {
				state_machine.ChangeState("Attacking");	
			}
		}
	});
	
var _takingDamage = new StatementState(self, "TakingDamage")
	.AddEnter(function() {
		image_index = 3;
		self.hp -= self.pendingDamage - self.defense;
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
		self.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			state_machine.ChangeState("Idle");
		}
	});
	
var _dead = new StatementState(self, "Dead")
	.AddEnter(function() {
		image_index = 5;
		isMyTurn = false;
		global.playerGold += gold;
	})
	.AddUpdate(function() {
		
	});

state_machine
	.AddState(_idle)
	.AddState(_attacking)
	.AddState(_takingDamage)
	.AddState(_blockingDamage)
	.AddState(_blocking)
	.AddState(_thinking)
	.AddState(_dead);