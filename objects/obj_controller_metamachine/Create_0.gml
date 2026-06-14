/*
	=================================== ADVANCED GAME MANAGER STATE EXAMPLE ===================================
	In this example, I want to demonstrate how you might use Statement to handle a "game state manager"
	allowing you to easily deal with things like pausing, and other game states that you might want
	to switch between. So we will be:
	
	1)	Creating a game state manager state machine, and then running the state machines from other 
		game entities from inside the Update handler of the game state manager. This means that when
		we change our game state manager's state to "Paused", all relevant entities will cease to run
		their state machines.
		
	2)	We take advantage of our ability to pass data through state changes to take a screenshot
		of the gameplay before we pause, pass that screenshot through to the pause state, and then
		display it underneath whatever we want the pause state to display, as a real world example of
		how easily passing data through states can be useful.
		
	3)	We also utilise Push/Pop states to handle our "Paused" state, pushing it to the top of the stack
		when we want to pause, and popping it off when we want to return back to our previous state.
		
	4)	Finally, we have the use of a "declarative transition". These are essentially state changes that
		are performed automatically when a condition we decide upon is met. We'll use the condition of the
		'game_won' variable being true.
*/



// ************** BASIC SETUP **************

game_won = false;



// ************** SETTING UP THE GAME CONTROLLER STATE MACHINE **************

// Create a state machine to handle whether the game is running or paused
game_sm = new Statement(id);



// ************** CREATING ITS "RUNNING" AND "PAUSED" STATES **************

// Create the "running" and "paused" states
game_running_state = new StatementState(id, "Running")
	.AddUpdate(function() {
		// We'll push and pop the paused state when escape is pressed,
		if (keyboard_check_released(vk_escape)) {
			if (game_sm.GetStateName() != "Paused") {
				// When we pause the game, we want to take a screenshot of the current app_surf, so we can draw it in
				// the background
				var _screen_surf = surface_create(
					surface_get_width(application_surface),
					surface_get_height(application_surface)
				);
				surface_copy(_screen_surf, 0, 0, application_surface);
				// Then we fill a struct with that data and pass it off to the next state
				var _pause_data = {
					screen_surf: _screen_surf
				}
				game_sm.PushState("Paused", _pause_data);
			}
		}
		
		// And here we run our entities. We run the Update handler for our pausable entities here, instead of their
		// Step Events, which means that when we switch to our "Paused" state, none of the entities will run their
		// Update handlers, effectively "pausing" them. In this specific case, we only have one entity, but the use
		// of GM's parenting and/or tags would allow us to handle as many entities as we want easily.
		
		with (obj_entity_metamachine) {
			sm.Update();
		}
	})
	.AddDraw(function() {
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(room_width - 10, room_height - 10, "Press Escape to pause and resume");
	})
	// To create a Declarative transition, all we need to do is provide the name of the state
	// to transition to, and a "predicate" function (one that returns a boolean yes/no answer.
	// Here we just return the value of game_won, because it's a boolean variable. As soon as
	// game_won gets set to true, our state machine will automatically change states to the "Won"
	// state.
	.AddTransition("Won", function() {
		return game_won;
	});

game_paused_state = new StatementState(id, "Paused")
	.AddEnter(function() {
		// As we enter into the pause state, we want to grab the data we passed through when we changed the
		// state from "Running" to "Paused". Since we'll be continuing to use this data through the state,
		// we'll save it to an instance variable.
		pause_data = game_sm.GetLastTransitionData();
		
		// And because surfaces are volatile and could be destroyed at any moment, we'll save the surface
		// to a buffer, so we can recreate the surface from the buffer data if it gets destroyed
		with (pause_data) {
			screen_buffer = buffer_create(
				surface_get_width(application_surface) * surface_get_height(application_surface) * 4,
				buffer_fixed,
				1
			);
			buffer_get_surface(screen_buffer, screen_surf, 0);
		}
	})
	.AddUpdate(function() {
		if (keyboard_check_released(vk_escape)) {
			game_sm.PopState();
		}
	})
	.AddExit(function() {
		// When we leave the pause state, we want to make sure that we free the surface we created
		// and delete the buffer, so we don't leave any memory leaks hanging around
		with (pause_data) {
			if (surface_exists(screen_surf)) {
				surface_free(screen_surf);
			}
			if (buffer_exists(screen_buffer)) {
				buffer_delete(screen_buffer);
			}
		}
	})
	.AddDraw(function() {
		// Now we draw the screenshot
		with (pause_data) {
			// First check if the screenshot surface exists
			if (!surface_exists(screen_surf)) {
				// If it doesn't, we want to first recreate the surface
				screen_surf = surface_create(
					surface_get_width(application_surface),
					surface_get_height(application_surface)
				);
				// And then fill it with the data from the buffer (checking to see if the buffer exists as
				// safety mechanism)
				if (buffer_exists(screen_buffer)) {
					buffer_set_surface(screen_buffer, screen_surf, 0)
				}
			}
			// Now we know that the screenshot surface exists, we can draw it
			draw_surface_stretched(screen_surf, 0, 0, window_get_width(), window_get_height());
		}
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(room_width * 0.5, room_height * 0.5, "Game paused!");
	});
	
game_won_state = new StatementState(id, "Won")
	.AddUpdate(function() {
		if (keyboard_check_released(vk_enter)) {
			room_goto_next();
		}
	})
	.AddDraw(function() {
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(room_width * 0.5, room_height * 0.5, "GAME WON!\nPress enter to test out Statement Lens.");
	});
	
// Always make sure we add our states to the state machine
game_sm.AddState(game_running_state).AddState(game_paused_state).AddState(game_won_state);