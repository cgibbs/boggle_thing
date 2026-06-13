draw_self();

draw_set_colour(c_red);
draw_set_font(arial24);
draw_set_halign(fa_center);
draw_text(x + 32, y + 14, tile_letter);
draw_set_font(-1);
draw_set_halign(fa_right);
draw_text(x+54, y+42, tile_value);