//StatementLensDraw();

if (state_machine.GetCurrentStateName() == "YouWin") {
	var enemy = instance_find(global.enemyType, 0);
	draw_set_colour(c_black);
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	draw_text(x + 134, y - 56, "You win! Gained " + string(enemy.gold) + " gold.");
	if (!(enemy.loot == "")) {
		draw_text(x + 134, y - 30, "Found " + string(enemy.loot) + " after the fight.");
	}
}

if (state_machine.GetCurrentStateName() == "YouLose") {
	draw_set_colour(c_black);
	draw_set_font(arial24);
	draw_set_halign(fa_center);
	draw_text(x + 134, y - 36, "You lose!");
}