draw_set_colour(c_black);
draw_set_font(arial24);
draw_set_halign(fa_center);
draw_text(x + 64, y + 200, hp);

if (isMyTurn) {
	draw_sprite(sTurnIndicator, 0, x + 64, y - 70)
}