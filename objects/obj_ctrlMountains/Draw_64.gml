draw_set_colour(c_black);
draw_set_font(arial24);
draw_set_halign(fa_center);
if (global.playerHp > 0) {
	draw_text(x + 34, y, "Current HP: " + string(global.playerHp));
}
draw_text(x + 34, y + 40, "Wins: " + string(global.playerWins));
draw_text(x + 34, y + 80, "Gold: " + string(global.playerGold));

draw_set_font(-1);
draw_text(x + 34, y + 120, "You arrive at the foot of the Off to the Side Mountains.");
draw_text(x + 34, y + 140, "The guy who named them didn't know they would only ever be seen from one angle.");
draw_text(x + 34, y + 160, "One day there'll be a lore video about this game that includes that stupid joke.");
draw_text(x + 34, y + 180, "Dare ye start some shit?");
