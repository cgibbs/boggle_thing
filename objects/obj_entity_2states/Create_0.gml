/*
	=================================== 2 STATE PATTERN EXAMPLE ===================================
	In this example, we are implementing a very simple state machine consisting of 2 states:
		
		"Idle"
		"Move"
		
	When the state machine enters the "Idle" state, it stops the player's animation. If the player presses
	any key while in the "Idle" state, the state machine will change to the "Move" state. When entering
	the "Move" state, the player's animation will be started, and they can move back and forth. If they stop 
	moving, the state machine will transition back to the "Idle" state.
*/


// ************** BASIC SETUP **************

// Create a state machine bound to this instance that will control our movement states.
sm = new Statement(self);


// ************** IDLE STATE **************

var _state_idle = new StatementState(self, "Idle")
	.AddEnter(function() {
		// When we enter the "Idle" state, we want the animation to stop
		image_speed = 0;
		image_index = 0;
	})
	.AddUpdate(function() {
		// If the player presses any key, then change to the "Move" state
		if (keyboard_check(vk_anykey)) {
			sm.ChangeState("Move");
		}
	});



// ************** MOVE STATE **************

var _state_move = new StatementState(self, "Move")
	.AddEnter(function() {
		// When we enter the "Move" state, we want the animation to play
		image_speed = 1;
	})
	.AddUpdate(function() {
		// Simple directional check
		var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		// If the player is not pressing a direction key, then change back to the "Idle" state
		if (_hor == 0) {
			sm.ChangeState("Idle");
		}
		// Otherwise move them
		else {
			x += _hor * 2;
			image_xscale = _hor;
		}
	});



// ************** REGISTER STATES WITH THE STATE MACHINE **************

// Always make sure you add your states to the state machine so it can use them.
sm.AddState(_state_idle).AddState(_state_move);