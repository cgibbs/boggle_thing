image_speed = 0;

randomize();

gold = round(random(5) + 5);

var _item = new FateValueEntry("Popped Soda Tab").SetWeight(50);
var _gold = new FateValueEntry("Gold").SetWeight(50);

loot_table = new FateTable([_item, _gold]);

//addToCombatLog("This is a REAL Bad Sprite, and also a REAL bad joke. The anger you feel about how bad the joke is pushes you to violence.")

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
		player.pendingDamage = 3;
		image_index = 1;
		addToCombatLog("The Real Bad Sprite does the can-can and kicks you in the head. Yes, the can can can-can.");
		addToCombatLog("... God, this joke sucks.");
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			var board = instance_find(getBoardType(), 0);
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
		addToCombatLog("The Real Bad Sprite cowers, increasing its defense by 3.");
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 30) {
			var board = instance_find(getBoardType(), 0);
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
		addToCombatLog("The Real Bad Sprite crumples under the weight of your blow, taking " + string(self.pendingDamage - self.defense) + " damage as a result.");
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
		addToCombatLog("The Real Bad Sprite successfully defends itself from your attack.");
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
		addToCombatLog("The Real Bad Sprite is defeated! You feel less angry now that there are no more puns to be made.");
		// this should all be made into a helper function
		var _roll = FateRollValues(loot_table, 1);
		var _value = _roll.GetFirstDrop();
		if (string(_value) == "Gold") {
			global.playerGold += gold;
		} else {
			// need to show this in end battle text
			self.loot = string(_value);
			addInventoryItem(string(_value), 1);
		}
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