draw_set_colour(c_black);
draw_set_font(arial24);
draw_set_halign(fa_center);
if (hp > 0) {
	draw_text(x + 34, y + 200, hp);
}
if (defense > 0) {
	draw_set_colour(c_blue);
	draw_text(x + 84, y + 200, "(" + string(defense) + ")");
}

if (isMyTurn) {
	draw_sprite(sTurnIndicator, 0, x + 34, y - 100)
}