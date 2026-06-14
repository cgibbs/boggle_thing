/*
	=================================== ADVANCED GAME MANAGER STATE EXAMPLE ===================================
	In this example, we are using a game manager to run our other entities. This means that we do NOT need
	to run our sm.Update() in the Step Event for this object, since the game manager will be running it instead.
*/


// ************** BASIC SETUP **************

// Some simple stats for our player
move_speed = 2;
grav = 0.2;
vsp = 0;
jump_height = 6;

// Get the tilemap layer id so we can have proper collisions
col_tm = layer_tilemap_get_id("tl_lay_blocks");



// ************** ENTITY STATE MACHINE SETUP **************

// Create a state machine bound to this instance that will control our movement states.
sm = new Statement(id);
// We will NOT run the Update handler for this state machine in the Step Event of this object,
// as we are handling it from inside the obj_controller_multimachine object's "Running" state
// instead.



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
		var _jump = keyboard_check(vk_space);
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		if (position_meeting(x, y + 1, col_tm)) {
			vsp = 0;
			if (_jump) {
				vsp = -jump_height;
			}
		}
		else {
			vsp += grav;
		}
		
		move_and_collide(_hor * move_speed, vsp, col_tm);
		
		// If the player is not pressing a direction key, then change back to the "Idle" state
		if (_hor == 0 && place_meeting(x, y + 1, col_tm)) {
			sm.ChangeState("Idle");
		}
		// Otherwise move them left or right
		else {			
			if (_hor != 0) {
				image_xscale = _hor;
			}
		}
	});



// ************** REGISTER STATES WITH THE STATE MACHINE **************

// Always make sure you add your states to the state machine so it can use them.
sm.AddState(_state_idle)
  .AddState(_state_move);
