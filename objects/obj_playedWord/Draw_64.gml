if (getPlayedWordValue() > 0) {
	draw_set_colour(c_red);
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	gui_x = x -40;

	draw_text(gui_x, y + 10, getPlayedWordValue());
	draw_text(gui_x, y + 40, "dmg");
}