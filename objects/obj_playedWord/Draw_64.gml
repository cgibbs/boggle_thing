if (getPlayedWordValue() > 0) {
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	
	draw_set_colour(c_red);
	gui_x = x -40;

	draw_text(gui_x, y + 10, getPlayedWordAttack());
	draw_text(gui_x, y + 40, "dmg");
	
	draw_set_colour(c_blue);
	gui_x = x -120;

	draw_text(gui_x, y + 10, getPlayedWordDefense());
	draw_text(gui_x, y + 40, "def");
}