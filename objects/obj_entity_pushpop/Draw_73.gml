draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(10, 10,	"-- Push and Pop States Example --\n" + 
					$"State: {sm.GetStateName()}\n" +
					"Change between 'Move' and 'Idle' states with move keys.\n" +
					"Press space while in 'Move' state to push `Sprint` state.\n" +
					"Press enter to move to the next room!");