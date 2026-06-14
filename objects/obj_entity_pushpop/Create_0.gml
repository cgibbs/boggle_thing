/*
	=================================== PUSH / POP PATTERN EXAMPLE ===================================
	In this example, we are building on the simple 2 state pattern by adding a third state that uses
	Statement's state stack to temporarily "overlay" a Sprint state on top of our normal Move state.
	
	We have three states:
		
		"Idle"   - The player is not moving and their animation is stopped.
		"Move"   - The player is walking left or right at a normal speed.
		"Sprint" - The player is sprinting at a higher speed, as long as they keep moving and hold Space.
		
	When the state machine enters the "Idle" state, it stops the player's animation and waits for input.
	If the player presses any key while in the "Idle" state, the state machine will change to the "Move"
	state.
	
	When entering the "Move" state, the player's animation will start and they can move back and forth.
	If they stop pressing a movement key, the state machine will transition back to the "Idle" state.
	
	While in the "Move" state, if the player holds Space, we will PUSH the "Sprint" state onto the top of
	the state stack. Because we are using PushState, when the "Sprint" state eventually POPS itself, the
	state machine will automatically return to the previous "Move" state, without us having to explicitly
	change back to it.
	
	When entering the "Sprint" state, the player's move speed is doubled and the animation is sped up to
	reflect that they are moving faster. If they stop moving or release Space, the "Sprint" state will
	POP itself off the stack, returning the state machine back to the underlying "Move" state and restoring
	the original move speed.
*/


// ************** BASIC SETUP **************

// Base move speed for the player. We will modify this in the Sprint state.
move_speed = 2;

// Create a state machine bound to this instance that will control our movement states.
sm = new Statement(id);



// ************** IDLE STATE **************

// The "Idle" state handles when the player is standing still.
var _state_idle = new StatementState(id, "Idle")
	.AddEnter(function() {
		// When we enter the "Idle" state, we want the animation to stop on a single frame
		image_speed = 0;
		image_index = 1;
	})
	.AddUpdate(function() {
		// If the player presses any key, then change to the "Move" state
		if (keyboard_check(vk_anykey)) {
			sm.ChangeState("Move");
		}
	});



// ************** MOVE STATE **************

// The "Move" state handles normal walking left and right.
var _state_move = new StatementState(id, "Move")
	.AddEnter(function() {
		// When we enter the "Move" state, we want the animation to play
		image_speed = 1;
	})
	.AddUpdate(function() {
		// Simple directional check using arrow keys or WASD
		var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		// If the player is not pressing a direction key, then change back to the "Idle" state
		if (_hor == 0) {
			sm.ChangeState("Idle");
		}
		// Otherwise move them left or right
		else {
			x += _hor * move_speed;
			image_xscale = _hor;
			
			// While moving, if Space is pressed, PUSH the "Sprint" state onto the state stack.
			// Because we are using PushState, when "Sprint" eventually pops, the machine will
			// automatically return to this "Move" state.
			if (keyboard_check_pressed(vk_space)) {
				sm.PushState("Sprint");
			}
		}
	});



// ************** SPRINT STATE **************

// The "Sprint" state sits on top of the "Move" state and temporarily increases move speed.
var _state_sprint = new StatementState(id, "Sprint")
	.AddEnter(function() {
		// When we enter the "Sprint" state, speed up the animation and double the move speed
		image_speed = 1.5;
		move_speed *= 2;
	})
	.AddUpdate(function() {
		// Simple directional check again, same as the "Move" state
		var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		// If the player stops moving OR releases Space, then POP the "Sprint" state.
		// This will return the machine to whatever state was underneath ("Move" in this example).
		if (_hor == 0 || !keyboard_check(vk_space)) {
			sm.PopState();
		}
		// Otherwise keep sprinting in the chosen direction
		else {
			x += _hor * move_speed;
			image_xscale = _hor;
		}
	})
	.AddExit(function() {
		// When we leave the "Sprint" state, restore the original move speed
		move_speed /= 2;
	});



// ************** REGISTER STATES WITH THE STATE MACHINE **************

// Always make sure you add your states to the state machine so it can use them.
sm.AddState(_state_idle)
  .AddState(_state_move)
  .AddState(_state_sprint);
