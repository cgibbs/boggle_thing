if (tile_type == "wood") {
	image_index = 0;
} else if (tile_type == "plastic") {
	image_index = 1;	
} else if (tile_type == "dream") {
	image_index = 2;
} else if (tile_type == "nightmare") {
	image_index = 3;	
}



if (isSelected) {
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_gray, 0.8)
} else {
	draw_self();
}

if (isTargeted) {
	draw_sprite(sTarget, 0, x, y);	
}

draw_set_colour(c_red);
draw_set_font(arial24);
draw_set_halign(fa_center);
draw_text(x + 32, y + 14, tile_letter);
draw_set_font(-1);
draw_set_halign(fa_right);
draw_text(x+54, y+42, tile_value);