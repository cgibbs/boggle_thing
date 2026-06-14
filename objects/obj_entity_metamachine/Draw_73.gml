draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(10, 10,	"-- Meta-State Machine Example --\n" + 
					$"State: {sm.GetStateName()}\n" +
					"Move keys to move, Space to jump.\n" +
					"Get the key to win!");