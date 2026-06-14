/*
	=================================== QUEUE AND LOCK EXAMPLE ===================================
	In this example, we are combining two advanced features of Statement:
	
		1) Non interruptible states using the exit lock helpers.
		2) Queued transitions that only apply once a state can be exited.
		
	We have three states:
		
		"Idle" - The player is not moving and their animation is stopped.
		"Move" - The player is walking left and right at a normal speed.
		"Box"  - A non interruptible state where movement attempts are queued.
		
	From "Idle", pressing any key will move the state machine into the "Move" state.
	From "Idle" or "Move", pressing Space will move the state machine into the "Box" state.
	
	While in the "Box" state:
		- The state is exit locked for a set amount of time, so it cannot be exited normally.
		- If the player presses a movement key, Statement will QUEUE a transition to the "Move" state.
		- Because the state is locked, that queued transition will not apply yet.
		
	Once the lock duration has passed:
		- The "Box" state unlocks its exit.
		- The queued "Move" state is applied the next time the state machine updates.
		- The on screen text updates so you can see both the lock status and any queued state.
*/


// ************** BASIC SETUP **************

// Base move speed for the player.
move_speed = 2;

// The number of frames the "Box" state will be exit-locked for.
box_lock_time = 120;

// Create a state machine bound to this instance that will control our movement states.
sm = new Statement(id);



// ************** IDLE STATE **************

var _idle_state = new StatementState(id, "Idle")
	.AddEnter(function() {
		// In "Idle", stop the animation on a single frame
		image_speed = 0;
		image_index = 1;
	})
	.AddUpdate(function() {
		// Any key will move us into the "Move" state so the player can walk
		if (keyboard_check(vk_anykey)) {
			sm.ChangeState("Move");
		}
		
		// Pressing Space from "Idle" moves us into the "Box" state
		if (keyboard_check_pressed(vk_space)) {
			sm.ChangeState("Box");
		}
	});



// ************** MOVE STATE **************

var _move_state = new StatementState(id, "Move")
	.AddEnter(function() {
		// In "Move", play the walking animation
		image_speed = 1;
	})
	.AddUpdate(function() {
		// Simple directional check using arrow keys or WASD
		var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		// If the player is not pressing a direction key, then change back to "Idle"
		if (_hor == 0) {
			sm.ChangeState("Idle");
		}
		// Otherwise move them left or right
		else {
			x += _hor * move_speed;
			image_xscale = _hor;
		}
		
		// Pressing Space from "Move" also moves us into the "Box" state
		if (keyboard_check_pressed(vk_space)) {
			sm.ChangeState("Box");
		}
	});



// ************** BOX STATE **************

var _box_state = new StatementState(id, "Box")
	.AddEnter(function() {
		// When we enter the "Box" state, lock the state so it cannot be exited normally
		sm.GetState().LockExit();
		
		// Reset the state timer so we can track how long we have been in this state
		sm.SetStateTime(0);
		
		// Switch to a different sprite so it is clear that we are in the locked state
		sprite_index = spr_entity_queuelock_box;
	})
	.AddUpdate(function() {
		// Same directional check as the "Move" state
		var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
		var _hor   = 0;

		if (_right) _hor = 1;
		if (_left)  _hor = -1;
		
		// If the player tries to move while in the "Box" state, QUEUE a transition to "Move".
		// Because this state is exit-locked, the queued transition will not apply until we unlock.
		if (_hor != 0) {
			sm.QueueState("Move");
		}
		// We could also call ChangeState here. The lock would still block the change while it is active,
		// but because ChangeState does not queue anything, the state will not switch automatically
		// when the lock ends. You would have to press a movement key again to trigger the change.


		// Once we have been in the "Box" state long enough, unlock the exit.
		// On the next update, the queued state (if any) will be processed.
		if (sm.GetStateTime() >= box_lock_time) {
			sm.GetState().UnlockExit();
		}
	})
	.AddExit(function() {
		// When we leave the "Box" state, switch back to the normal sprite
		sprite_index = spr_entity_queuelock;
	})
	.AddDraw(function() {
		// Display the queued state (if any)
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		
		var yy = room_height - 10;
		
		var _queue_str = $"Queued State: None"
		if (sm.HasQueuedState()) {
            _queue_str = $"Queued State: {sm.GetQueuedStateName()}";
        }
		draw_text(room_width * 0.5, yy, _queue_str);
		
		// Just above that, display how long the state will remain locked for (in frames)
		yy -= string_height(_queue_str) + 5;
		var _str = "";
		if (sm.GetStateTime() < box_lock_time) {
			_str = $"Box state exit locked for {box_lock_time - sm.GetStateTime()} frames";
		}
		else {
			_str = $"Box state exit unlocked!";
		}
		
		draw_text(room_width * 0.5, yy, _str);
	});



// ************** REGISTER STATES WITH THE STATE MACHINE **************

// Always make sure you add your states to the state machine so it can use them.
sm.AddState(_idle_state)
  .AddState(_move_state)
  .AddState(_box_state);