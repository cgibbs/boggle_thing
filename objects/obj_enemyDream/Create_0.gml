image_speed = 0;

randomize();

gold = 0;

state_machine = new Statement(self);

turnsElapsed = 1;

// Idle
var _idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
		
	})
	.AddUpdate(function() {
		var player = instance_find(obj_player, 0);
		if (self.isMyTurn == true and turnsElapsed > 2) {
			state_machine.ChangeState("Dead");	
		} else if (self.pendingDamage > 0) {
			state_machine.ChangeState("TakingDamage");	
		}
		else if (self.isMyTurn == true and player.pendingDamage < 0) {
			state_machine.ChangeState("Thinking");
		}
	});
	
var _attacking = new StatementState(self, "Attacking")
	.AddEnter(function() {
		var player = instance_find(obj_player, 0);
		addToCombatLog("You dream that you're in an exam you didn't study for all semester. It doesn't actually hurt, but you still didn't enjoy the experience.");
		image_index = 1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			var board = instance_find(obj_dreamBoggleBoard, 0);
			board.state_machine.ChangeState("PlayerTurn");
			self.isMyTurn = false;
			state_machine.ChangeState("Idle");	
		}
	});
	
var _thinking = new StatementState(self, "Thinking")
	.AddEnter(function() {
		image_index = 4;
		turnsElapsed += 1;
	})
	.AddUpdate(function() {
		// this is where you put logic to figure out next attack
		if (state_machine.GetStateTime() >= 60) {
			if (self.attackedLastTurn) {
				self.attackedLastTurn = false;
				var board = instance_find(obj_dreamBoggleBoard, 0);
				board.state_machine.ChangeState("PlayerTurn");
			} else {
				state_machine.ChangeState("Attacking");	
			}
		}
	});
	
var _takingDamage = new StatementState(self, "TakingDamage")
	.AddEnter(function() {
		image_index = 3;
		self.hp += self.pendingDamage - self.defense;
		addToCombatLog("You dream about doing something cool in front of a crowd, and it actually goes as planned. Nice.");
		self.pendingDamage = -1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			if (self.hp > 0) {
				state_machine.ChangeState("Idle");
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
		addToCombatLog("The dream has ended, and you feel well-rested.");
		//global.playerGold += gold;
		var player = instance_find(obj_player, 0);
		player.hp += self.hp;
		var board = instance_find(obj_dreamBoggleBoard, 0);
		board.state_machine.ChangeState("YouWin");
	})
	.AddUpdate(function() {
		
	});

state_machine
	.AddState(_idle)
	.AddState(_attacking)
	.AddState(_takingDamage)
	.AddState(_blockingDamage)
	.AddState(_thinking)
	.AddState(_dead);