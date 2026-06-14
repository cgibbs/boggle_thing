draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(10, 10,	"-- Simple 2-State Example --\n" +
					$"State: {sm.GetStateName()}\n" +
					"Change between 'Move' and 'Idle' states with left and right\n(or A and D) keys.\n" +
					"Press enter to move to the next room!");