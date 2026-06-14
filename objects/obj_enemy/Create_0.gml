image_speed = 0;

state_machine = new Statement(self);

// Idle
var _idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
	})
	.AddUpdate(function() {
		if (self.pendingDamage == 0) {
			state_machine.ChangeState("BlockingDamage");
		} else if (self.pendingDamage > 0) {
			state_machine.ChangeState("TakingDamage");	
		}
	});
	
var _attacking = new StatementState(self, "Attacking")
	.AddEnter(function() {
		image_index = 1;
	})
	.AddUpdate(function() {
		if (state_machine.GetStateTime() >= 60) {
			state_machine.ChangeState("Idle");	
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
	.AddState(_blockingDamage);