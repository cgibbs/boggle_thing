var _lay_id = layer_get_id("tl_col");
col = layer_tilemap_get_id(_lay_id);

move_speed = 3;
jump_height = 8;
grav = 0.1;
hsp = 0;
vsp = 0;

sm = new Statement(id);

var _idle = new StatementState(id, "Idle")
	.AddEnter(function() {
		sprite_index = spr_entity_platformer_idle;
		image_speed = 0;
		image_index = 0;
	})
	.AddTransition("Fall", function() { return !place_meeting(x, y + 1, col) })
	.AddTransition("Jump", function() { return keyboard_check(vk_space) }, { height : jump_height })
	.AddTransition("Move", function() { return keyboard_check(ord("A")) || keyboard_check(ord("D")) });
	
var _move = new StatementState(id, "Move")
	.AddEnter(function() {
		sprite_index = spr_entity_platformer_move;
		image_speed = 1;
		image_index = 0;
	})
	.AddUpdate(function() {
		var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		if (_hor != 0) {
			hsp = _hor * move_speed;
		}
		move_and_collide(hsp, vsp, col, 10);
		if (!place_meeting(x, y + 1, col)) {
			sm.ChangeState("Fall");
		}
	})
	.AddTransition("Idle", function() { return !(keyboard_check(ord("A")) || keyboard_check(ord("D"))) })
	.AddTransition("Jump", function() { return keyboard_check(vk_space) }, { height : jump_height });
	
var _jump = new StatementState(id, "Jump")
	.AddEnter(function() {
		var _payload = sm.GetLastTransitionData();
		sprite_index = spr_entity_platformer_jump;
		image_speed = 1;
		image_index = 0;
		vsp = -_payload.height;
	})
	.AddUpdate(function() {
		var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		if (_hor != 0) {
			hsp = _hor * move_speed;
		}
		move_and_collide(hsp, vsp, col);
		vsp += grav;
		if (place_meeting(x, y + vsp, col)) {
			sm.ChangeState("Land");
		}
	})
	.AddTransition("Fall", function() { return vsp > 0; })
	.DebugPayload({ height : jump_height });
	
var _fall = new StatementState(id, "Fall")
	.AddEnter(function() {
		sprite_index = spr_entity_platformer_fall;
		image_speed = 1;
		image_index = 0;
	})
	.AddUpdate(function() {
		var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		if (_hor != 0) {
			hsp = _hor * move_speed;
		}
		move_and_collide(hsp, vsp, col);
		vsp += grav;
	})
	.AddTransition("Land", function() { return place_meeting(x, y + 1, col) });
	
var _land = new StatementState(id, "Land")
	.AddEnter(function() {
		sprite_index = spr_entity_platformer_land;
		image_speed = 0;
		image_index = 0;
		var _land_speed = vsp;
		vsp = 0;
		hsp = 0;
		if (_land_speed > 5) {
			sm.GetState().LockExit();
		}
		else {
			if (!place_meeting(x, y + 1, col)) {
				sm.ChangeState("Fall");
			}
			else {
				sm.ChangeState("Idle");
			}
		}
	})
	.AddUpdate(function() {
		if (sm.GetStateTime() > game_get_speed(gamespeed_fps)) {
			sm.GetState().UnlockExit();
			sm.ChangeState("Idle");
		}
	});
	
sm.AddState(_idle).AddState(_move).AddState(_jump).AddState(_fall).AddState(_land);