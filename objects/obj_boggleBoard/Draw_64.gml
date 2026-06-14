//StatementLensDraw();

if (state_machine.GetCurrentStateName() == "YouWin") {
	draw_set_colour(c_black);
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	draw_text(x + 134, y - 36, "You win!");
}

if (state_machine.GetCurrentStateName() == "YouLose") {
	draw_set_colour(c_black);
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	draw_text(x + 134, y - 36, "You lose!");
}