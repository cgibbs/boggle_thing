draw_set_colour(c_black);
draw_set_font(arial24);
draw_set_halign(fa_center);
if (global.playerHp > 0) {
	draw_text(x + 34, y, "Current HP: " + string(global.playerHp));
}
draw_text(x + 34, y + 40, "Wins: " + string(global.playerWins));
draw_text(x + 34, y + 80, "Gold: " + string(global.playerGold));

draw_set_font(-1);
draw_text(x + 34, y + 120, "You're hemmed in on all sides by towering aisles.");
draw_text(x + 34, y + 140, "The floors are somehow both slippery and sticky.");
draw_text(x + 34, y + 160, "Dare ye start some shit?");