if (isHidden) {
	
} else {
	draw_self();
	if (isInvalid) {
		draw_set_colour(c_red);
		draw_set_font(arial24);
		draw_set_halign(fa_center);
		draw_text(x + 32, y + 74, "Invalid word!");
	}
}