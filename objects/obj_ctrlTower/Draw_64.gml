draw_set_colour(c_black);
draw_set_font(arial24);
draw_set_halign(fa_center);
if (global.playerHp > 0) {
	draw_text(x + 34, y, "Current HP: " + string(global.playerHp));
}
draw_text(x + 34, y + 40, "Wins: " + string(global.playerWins));
draw_text(x + 34, y + 80, "Gold: " + string(global.playerGold));

draw_set_font(-1);
draw_text(x + 34, y + 120, "There's nothing here yet, sorry.");
draw_text(x + 34, y + 180, "Go on, git.");
