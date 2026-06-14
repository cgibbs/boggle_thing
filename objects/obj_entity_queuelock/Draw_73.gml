draw_set_color(c_black);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(10, 10,	"-- Exit-Locked and Queued States Example --\n" +
					$"State: {sm.GetStateName()}\n" +
					"Move with left and right (or A and D) keys.\n" +
					"Press space to hide in a box\n" + 
					$"(box state prevents exit for {box_lock_time} frames)\n" +
					"While in box, press left or right to queue a Move state.\n\nPress enter to move to the next room!");