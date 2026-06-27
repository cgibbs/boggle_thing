var _text = scribble(textToRender)
.wrap(280)
.padding(5, 5, 5, 5);
var _bbox = _text.get_bbox(x+10, y+10);
draw_set_colour(c_black);
draw_rectangle(_bbox.left, _bbox.top, _bbox.right, _bbox.bottom, false);
_text.draw(x + 10, y + 10);