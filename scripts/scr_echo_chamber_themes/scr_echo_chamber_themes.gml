gml_pragma("MarkTagAsUsed", "include");

/// @func EchoChamberThemeTryGetFont(_font_name)
/// @desc Resolve a font asset by name. If missing, returns the current draw font.
/// @param {String, Asset.GMFont} _font_name
/// @return {Asset.GMFont}
function EchoChamberThemeTryGetFont(_font_name) {
	if (!is_string(_font_name) && font_exists(_font_name)) return _font_name;
	var _idx = asset_get_index(_font_name);
	if (_idx != -1 && font_exists(_idx)) return _idx;
	return draw_get_font();
}

/// @func EchoChamberThemeTryGetSprite(_sprite_name)
/// @desc Resolve a sprite asset by name. If missing, returns -1.
/// @param {String, Asset.GMSprite} _sprite_name
/// @return {Asset.GMSprite,Real}
function EchoChamberThemeTryGetSprite(_sprite_name) {
	if (!is_string(_sprite_name) && sprite_exists(_sprite_name)) {
		return _sprite_name;
	}
	var _idx = asset_get_index(_sprite_name);
	if (_idx != -1 && sprite_exists(_idx)) return _idx;
	return -1;
}

/// @func EchoChamberTheme()
/// @desc Creates the shared debug UI theme container for Statement visuals.
/// @return {Struct.EchoChamberTheme}
function EchoChamberTheme() constructor {
	// Fonts for different text roles.
	// You can override these after construction if you want.
	var _current_font = EchoChamberThemeTryGetFont(fnt_theme);
	var _header_font = EchoChamberThemeTryGetFont(fnt_theme_header);
	font_header = _header_font;
	font_body   = _current_font;
	font_small  = _current_font;

	// Base palette (extend as needed)
	col_window_bg = make_color_rgb(18, 22, 36);
	col_panel_bg  = make_color_rgb(22, 26, 42);
	col_text      = c_white;
	col_text_dim  = merge_color(col_text, col_panel_bg, 0.55);
	col_accent    = make_color_rgb(70, 90, 140);
	col_accent_dim = merge_color(col_accent, col_panel_bg, 0.55);
	col_muted     = make_color_rgb(140, 140, 150);
	col_muted_strong = make_color_rgb(160, 160, 180);
	col_error     = make_color_rgb(180, 120, 120);
	col_hover_row = make_color_rgb(36, 42, 60);
	col_hover_row_alt = make_color_rgb(30, 50, 80);
	col_menu_bg   = make_color_rgb(30, 37, 65);
	col_menu_hover = make_color_rgb(36, 42, 60);
	col_label_hover_bg = make_color_rgb(34, 44, 72);
	col_checkbox_off = make_color_rgb(18, 22, 36);
	col_checkbox_on = c_lime;

	var _btn_bg = make_color_rgb(20, 24, 40);
	var _btn_bd = make_color_rgb(60, 70, 100);
	var _btn_tx = col_text;
	var _btn_hover_mix = 0.15;
	var _btn_pressed_mix = 0.25;
	var _btn_bg_hover = merge_color(_btn_bg, _btn_tx, _btn_hover_mix);
	var _btn_bg_pressed = merge_color(_btn_bg_hover, _btn_tx, _btn_pressed_mix);
	var _btn_bg_disabled = merge_color(_btn_bg, col_panel_bg, 0.6);
	var _btn_bd_disabled = merge_color(_btn_bd, col_panel_bg, 0.6);
	var _btn_tx_disabled = col_text_dim;

	var _toggle_bg = make_color_rgb(24, 28, 44);
	var _toggle_bd = make_color_rgb(60, 70, 100);
	var _toggle_tx = col_text;
	var _toggle_hover_mix = 0.12;
	var _toggle_pressed_mix = 0.22;
	var _toggle_bg_hover = merge_color(_toggle_bg, _toggle_tx, _toggle_hover_mix);
	var _toggle_bg_pressed = merge_color(_toggle_bg_hover, _toggle_tx, _toggle_pressed_mix);
	var _toggle_box_on = col_checkbox_on;
	var _toggle_box_off = col_checkbox_off;
	var _toggle_bg_disabled = merge_color(_toggle_bg, col_panel_bg, 0.6);
	var _toggle_bd_disabled = merge_color(_toggle_bd, col_panel_bg, 0.6);
	var _toggle_tx_disabled = col_text_dim;
	var _toggle_box_on_disabled = merge_color(_toggle_box_on, col_panel_bg, 0.6);
	var _toggle_box_off_disabled = merge_color(_toggle_box_off, col_panel_bg, 0.6);
	var _toggle_box_border_disabled = merge_color(_toggle_bd, col_panel_bg, 0.6);

	var _dropdown_bg = make_color_rgb(20, 24, 40);
	var _dropdown_bd = make_color_rgb(60, 70, 100);
	var _dropdown_tx = col_text;
	var _dropdown_hover_mix = 0.15;
	var _dropdown_pressed_mix = 0.25;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, _dropdown_tx, _dropdown_hover_mix);
	var _dropdown_bg_pressed = merge_color(_dropdown_bg_hover, _dropdown_tx, _dropdown_pressed_mix);
	var _dropdown_bg_disabled = merge_color(_dropdown_bg, col_panel_bg, 0.6);
	var _dropdown_bd_disabled = merge_color(_dropdown_bd, col_panel_bg, 0.6);
	var _dropdown_tx_disabled = col_text_dim;

	var _textinput_bg = make_color_rgb(24, 28, 44);
	var _textinput_bd = make_color_rgb(60, 70, 100);
	var _textinput_tx = make_color_rgb(180, 190, 210);
	var _textinput_hover_mix = 0.12;
	var _textinput_pressed_mix = 0.22;
	var _textinput_bg_hover = merge_color(_textinput_bg, _textinput_tx, _textinput_hover_mix);
	var _textinput_bg_pressed = merge_color(_textinput_bg_hover, _textinput_tx, _textinput_pressed_mix);
	var _textinput_bg_active = merge_color(_textinput_bg, _textinput_tx, 0.2);
	var _textinput_bg_disabled = merge_color(_textinput_bg, col_panel_bg, 0.6);
	var _textinput_bd_disabled = merge_color(_textinput_bd, col_panel_bg, 0.6);
	var _textinput_tx_disabled = col_text_dim;
	var _textinput_bg_readonly = merge_color(_textinput_bg, col_panel_bg, 0.1);
	var _textinput_bd_readonly = _textinput_bd;
	var _textinput_tx_readonly = _textinput_tx;
	var _textinput_bg_invalid = merge_color(_textinput_bg, col_error, 0.2);
	var _textinput_bd_invalid = col_error;
	var _textinput_tx_invalid = _textinput_tx;
	var _textinput_selection_bg = merge_color(_textinput_bg, _textinput_tx, 0.35);
	var _textinput_selection_text = _textinput_tx;
	var _textinput_selection_bg_inactive = merge_color(_textinput_selection_bg, _textinput_bg, 0.5);
	var _textinput_selection_text_inactive = _textinput_selection_text;
	var _textinput_caret_color = _textinput_tx;
	var _textinput_caret_char = "|";
	var _textinput_caret_blink_ms = 520;
	var _textinput_caret_width = 1;
	var _textinput_caret_height = 0;
	var _textinput_caret_inset_x = 0;
	var _textinput_caret_inset_y = 0;
	var _textinput_placeholder_alpha = 0.6;

	var _slider_track = col_panel_bg;
	var _slider_fill = col_accent;
	var _slider_knob = col_text;
	var _slider_hover_mix = 0.12;
	var _slider_track_hover = merge_color(_slider_track, col_text, _slider_hover_mix);
	var _slider_fill_hover = merge_color(_slider_fill, col_text, _slider_hover_mix);
	var _slider_knob_hover = merge_color(_slider_knob, col_text, _slider_hover_mix);
	var _slider_track_disabled = merge_color(_slider_track, col_panel_bg, 0.4);
	var _slider_fill_disabled = merge_color(_slider_fill, col_panel_bg, 0.6);
	var _slider_knob_disabled = merge_color(_slider_knob, col_panel_bg, 0.6);

	var _list_row_bg_disabled = merge_color(col_panel_bg, col_window_bg, 0.35);
	var _list_row_text_disabled = col_text_dim;

	var _scroll_track = merge_color(col_window_bg, col_panel_bg, 0.5);
	var _scroll_handle = col_accent;

	// Panel styles by role; extend with more roles per widget as needed.
	panel_styles = {
		_default : { bg : col_panel_bg, border : col_accent, bg_alpha : 1, border_alpha : 1 },
		menu    : { bg : col_menu_bg, border : col_accent, bg_alpha : 1, border_alpha : 1 },
		overlay : { bg : col_window_bg, border : col_accent, bg_alpha : 1, border_alpha : 1 }
	};
	window_styles    = { _default : { bg : col_window_bg, border : col_accent, bg_alpha : 1 } };
	header_styles    = { _default : { bg : make_color_rgb(30, 36, 52), border : col_accent, bg_alpha : 1 } };
	label_styles     = {
		_default : { font : font_body, text : col_text, text_alpha : 1, text_disabled : col_text_dim, text_disabled_alpha : 1 },
		_field : { font : font_small, text : col_text_dim, text_alpha : 1, text_disabled : col_text_dim, text_disabled_alpha : 1 }
	};
	separator_styles = { _default : { line : col_accent, line_alpha : 1, line_disabled : col_accent_dim, line_disabled_alpha : 1 } };
	button_styles    = { _default : {
			bg : _btn_bg, border : _btn_bd, text : _btn_tx,
			bg_alpha : 0.95, border_alpha : 1, text_alpha : 1, align : "center",
			bg_hover : _btn_bg_hover, border_hover : _btn_bd, text_hover : _btn_tx,
			bg_hover_alpha : 0.95, border_hover_alpha : 1, text_hover_alpha : 1,
			pressed_mix : _btn_pressed_mix, bg_pressed : _btn_bg_pressed,
			border_pressed : _btn_bd, text_pressed : _btn_tx,
			bg_pressed_alpha : 0.95, border_pressed_alpha : 1, text_pressed_alpha : 1,
			bg_disabled : _btn_bg_disabled, border_disabled : _btn_bd_disabled, text_disabled : _btn_tx_disabled,
			bg_disabled_alpha : 0.95, border_disabled_alpha : 1, text_disabled_alpha : 1
	} };

	// Window chrome button styles (inherit from _default by default)
	button_styles.__window_close    = button_styles._default;
	button_styles.__window_minimize = button_styles._default;
	button_styles.__window_pin      = button_styles._default;
	toggle_styles    = { _default : {
			bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx,
			bg_alpha : 0.9, border_alpha : 1, text_alpha : 1,
			bg_hover : _toggle_bg_hover, border_hover : _toggle_bd, text_hover : _toggle_tx,
			bg_hover_alpha : 0.9, border_hover_alpha : 1, text_hover_alpha : 1,
			pressed_mix : _toggle_pressed_mix, bg_pressed : _toggle_bg_pressed,
			border_pressed : _toggle_bd, text_pressed : _toggle_tx,
			bg_pressed_alpha : 0.9, border_pressed_alpha : 1, text_pressed_alpha : 1,
			bg_disabled : _toggle_bg_disabled, border_disabled : _toggle_bd_disabled, text_disabled : _toggle_tx_disabled,
			bg_disabled_alpha : 0.9, border_disabled_alpha : 1, text_disabled_alpha : 1,
			box_on : _toggle_box_on, box_off : _toggle_box_off,
			box_on_alpha : 1, box_off_alpha : 1, box_border_alpha : 1,
			box_border : _toggle_bd, box_border_hover : _toggle_bd, box_border_pressed : _toggle_bd,
			box_border_hover_alpha : 1, box_border_pressed_alpha : 1,
			box_on_hover : _toggle_box_on, box_on_pressed : _toggle_box_on,
			box_on_hover_alpha : 1, box_on_pressed_alpha : 1,
			box_off_hover : _toggle_box_off, box_off_pressed : _toggle_box_off,
			box_off_hover_alpha : 1, box_off_pressed_alpha : 1,
			box_on_disabled : _toggle_box_on_disabled, box_off_disabled : _toggle_box_off_disabled,
			box_on_disabled_alpha : 1, box_off_disabled_alpha : 1,
			box_border_disabled : _toggle_box_border_disabled, box_border_disabled_alpha : 1
	} };
	dropdown_styles  = { _default : {
			bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx,
			bg_alpha : 0.9, border_alpha : 1, text_alpha : 1, align : "center",
			bg_hover : _dropdown_bg_hover, border_hover : _dropdown_bd, text_hover : _dropdown_tx,
			bg_hover_alpha : 0.9, border_hover_alpha : 1, text_hover_alpha : 1,
			pressed_mix : _dropdown_pressed_mix, bg_pressed : _dropdown_bg_pressed,
			border_pressed : _dropdown_bd, text_pressed : _dropdown_tx, open_mix : 0.15,
			bg_pressed_alpha : 0.9, border_pressed_alpha : 1, text_pressed_alpha : 1,
			bg_disabled : _dropdown_bg_disabled, border_disabled : _dropdown_bd_disabled, text_disabled : _dropdown_tx_disabled,
			bg_disabled_alpha : 0.9, border_disabled_alpha : 1, text_disabled_alpha : 1,
			overlay_bg : col_window_bg, overlay_border : col_accent, overlay_bg_alpha : 0.95, overlay_border_alpha : 1,
			overlay_row_bg : col_panel_bg, overlay_row_hover : col_hover_row,
			overlay_row_selected : col_hover_row_alt, overlay_row_pressed : col_hover_row,
			overlay_row_bg_alpha : 1, overlay_row_hover_alpha : 1, overlay_row_selected_alpha : 1, overlay_row_pressed_alpha : 1,
			overlay_text : col_text, overlay_text_hover : col_text,
			overlay_text_selected : col_text, overlay_text_pressed : col_text,
			overlay_text_alpha : 1, overlay_text_hover_alpha : 1, overlay_text_selected_alpha : 1, overlay_text_pressed_alpha : 1,
			overlay_search_bg : col_panel_bg, overlay_search_border : col_accent,
			overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.2),
			overlay_search_bg_alpha : 1, overlay_search_hover_bg_alpha : 1,
			overlay_search_border_alpha : 1,
			overlay_search_text : col_text, overlay_search_placeholder : col_muted,
			overlay_search_text_alpha : 1, overlay_search_placeholder_alpha : 1
	} };
	textinput_styles = { _default : {
			bg : _textinput_bg, border : _textinput_bd, text : _textinput_tx,
			bg_alpha : 0.95, border_alpha : 1, text_alpha : 1,
			bg_hover : _textinput_bg_hover, border_hover : _textinput_bd, text_hover : _textinput_tx,
			bg_hover_alpha : 0.95, border_hover_alpha : 1, text_hover_alpha : 1,
			pressed_mix : _textinput_pressed_mix, bg_pressed : _textinput_bg_pressed,
			border_pressed : _textinput_bd, text_pressed : _textinput_tx,
			bg_pressed_alpha : 0.95, border_pressed_alpha : 1, text_pressed_alpha : 1,
			bg_active : _textinput_bg_active, border_active : _textinput_bd, text_active : _textinput_tx,
			bg_active_alpha : 0.95, border_active_alpha : 1, text_active_alpha : 1,
			bg_disabled : _textinput_bg_disabled, border_disabled : _textinput_bd_disabled, text_disabled : _textinput_tx_disabled,
			bg_disabled_alpha : 0.95, border_disabled_alpha : 1, text_disabled_alpha : 1,
			bg_readonly : _textinput_bg_readonly, border_readonly : _textinput_bd_readonly, text_readonly : _textinput_tx_readonly,
			bg_readonly_alpha : 0.95, border_readonly_alpha : 1, text_readonly_alpha : 1,
			bg_invalid : _textinput_bg_invalid, border_invalid : _textinput_bd_invalid, text_invalid : _textinput_tx_invalid,
			bg_invalid_alpha : 0.95, border_invalid_alpha : 1, text_invalid_alpha : 1,
			selection_bg : _textinput_selection_bg, selection_text : _textinput_selection_text,
			selection_bg_inactive : _textinput_selection_bg_inactive, selection_text_inactive : _textinput_selection_text_inactive,
			selection_bg_alpha : 1, selection_text_alpha : 1,
			selection_bg_inactive_alpha : 1, selection_text_inactive_alpha : 1,
			caret_color : _textinput_caret_color, caret_alpha : 1,
			caret_char : _textinput_caret_char, caret_blink_ms : _textinput_caret_blink_ms,
			caret_width : _textinput_caret_width, caret_height : _textinput_caret_height,
			caret_inset_x : _textinput_caret_inset_x, caret_inset_y : _textinput_caret_inset_y,
			placeholder : col_muted_strong, placeholder_alpha : _textinput_placeholder_alpha,
			align : "left",

			validation_gap : 4,
			validation_alpha : 0.9,
			validation_error : col_error,
			validation_warn : make_color_rgb(200, 180, 110),
			validation_info : col_accent,
			validation_font : font_small
	} };
	slider_styles    = { _default : {
			track_bg : _slider_track, track_fill : _slider_fill, knob : _slider_knob,
			track_bg_alpha : 1, track_fill_alpha : 1, knob_alpha : 1,
			track_bg_hover : _slider_track_hover, track_fill_hover : _slider_fill_hover,
			knob_hover : _slider_knob_hover,
			track_bg_hover_alpha : 1, track_fill_hover_alpha : 1, knob_hover_alpha : 1,
			track_bg_pressed : _slider_track_hover, track_fill_pressed : _slider_fill_hover,
			knob_pressed : _slider_knob_hover,
			track_bg_pressed_alpha : 1, track_fill_pressed_alpha : 1, knob_pressed_alpha : 1,
			track_bg_disabled : _slider_track_disabled, track_fill_disabled : _slider_fill_disabled,
			knob_disabled : _slider_knob_disabled,
			track_bg_disabled_alpha : 1, track_fill_disabled_alpha : 1, knob_disabled_alpha : 1
	} };
	popup_styles    = { _default : { bg : col_window_bg, border : col_accent, bg_alpha : 1, header_bg : make_color_rgb(34, 40, 60), header_alpha : 1 } };
	tooltip_styles  = { _default : { bg : col_menu_bg, border : col_accent, bg_alpha : 0.9, text : col_text } };
	toast_styles	= { _default : { bg : col_menu_bg, border : col_accent, bg_alpha : 0.9, text : col_text } };
	scrollbar_styles = { _default : {
			track_bg : _scroll_track, track_bg_alpha : 0.35,
			track_bg_hover : _scroll_track, track_bg_hover_alpha : 0.35,
			track_border : col_accent, track_border_alpha : 1,
			handle_bg : _scroll_handle, handle_bg_alpha : 0.85,
			handle_bg_hover : _scroll_handle, handle_bg_hover_alpha : 0.85,
			handle_bg_pressed : _scroll_handle, handle_bg_pressed_alpha : 0.85,
			handle_border : col_accent, handle_border_alpha : 0
	} };

	// List row styles (for virtualized list views and large inspectors)
	list_row_styles = {
		_default : {
			bg_normal	:	col_panel_bg,
			bg_hover	:	col_hover_row,
			bg_selected	:	col_hover_row_alt,
			bg_pressed	:	col_hover_row,
			text_normal	:	col_text,
			text_hover	:	col_text,
			text_selected	:	col_text,
			text_pressed	:	col_text,
			bg_disabled	:	_list_row_bg_disabled,
			text_disabled	:	_list_row_text_disabled,
			bg_normal_alpha	:	1,
			bg_hover_alpha	:	1,
			bg_selected_alpha	:	1,
			bg_pressed_alpha	:	1,
			text_normal_alpha	:	1,
			text_hover_alpha	:	1,
			text_selected_alpha	:	1,
			text_pressed_alpha	:	1,
			bg_disabled_alpha	:	1,
			text_disabled_alpha	:	1
		},
	};
	
	

	// Base UI scale and padding
	ui_scale  = 1;
	pad_x     = 6;
	pad_y     = 4;
	control_padding_x = pad_x;
	control_padding_y = pad_y;
	control_margin_x  = 0;
	control_margin_y  = 0;
	min_hit_h = 20;

	// Derived row heights for different control types
	row_header_h  = 0;
	row_toolbar_h = 0;
	row_small_h   = 0;

	// Skinnable layout metrics (theme defaults)
	default_control_width      = 160;
	default_control_max_width  = 320;
	gap                        = 4;
	default_padding            = max(pad_x, pad_y);
	default_row_height         = max(20, row_toolbar_h);
	window_padding             = default_padding;
	window_margin_x            = 0;
	window_margin_y            = 0;
	window_titlebar_h          = 0;
	window_resize_grip_size    = 14;
	window_minimized_h          = 0;
	window_button_gap           = 2;
	window_button_size          = 0;
	window_button_close_label   = "X";
	window_button_minimize_label = "-";
	window_button_restore_label  = "+";
	window_button_pin_label      = "P";
	window_button_unpin_label    = "P";
	panel_padding              = default_padding;
	panel_margin_x             = 0;
	panel_margin_y             = 0;
	panel_gap                  = gap;
	panel_row_height           = 0;
	panel_collapsed_size       = 8;
	panel_collapse_handle_size = 8;
	field_label_placement      = eEchoChamberFieldLabelPlacement.AUTO;
	field_label_gap            = 6;
	field_label_width          = -1;
	field_label_min_width      = 60;
	field_label_max_width      = 220;
	field_label_max_ratio      = 0.4;
	field_label_style_id       = "_field";
	field_label_align_leading  = "right";
	field_label_align_above    = "left";
	field_label_auto_min_control_w = 110;
	tooltip_delay_ms           = 350;
	tooltip_padding            = default_padding;
	scrollbar_w                = 6;

	// Framework-specific modules (attach more under other keys later)
	statement = {
		node_base_col   : c_white,
		node_active_col : c_lime,
		node_prev_col   : c_yellow,
		heat_cold_col   : make_color_rgb(40, 70, 120),
		heat_hot_col    : make_color_rgb(255, 3, 40),
		node_sprite		: EchoChamberThemeTryGetSprite("spr_node"),

		edge_structural : {
			color     : c_ltgray,
			sprite    : EchoChamberThemeTryGetSprite(spr_dashed_line),
			scroll    : 0
		},
		edge_last_transition : {
			color     : c_white,
			sprite    : EchoChamberThemeTryGetSprite(spr_dashed_line),
			scroll    : 1.5
		},
		edge_queued : {
			color     : c_aqua,
			sprite    : EchoChamberThemeTryGetSprite(spr_solid_line),
			scroll    : 1.0
		},
		edge_history : {
			color     : make_color_rgb(120, 120, 160),
			sprite    : EchoChamberThemeTryGetSprite(spr_dashed_line),
			scroll    : 0.5,
			hover_col : make_color_rgb(34, 44, 72)
		},
		edge_debug : {
			color     : make_color_rgb(220, 90, 200),
			sprite    : EchoChamberThemeTryGetSprite(spr_dashed_line),
			scroll    : 0.8
		},
		label_bg_alpha    : 0.2,
		label_text_col    : c_white,
		label_hover_col   : c_white,
		label_hover_bg    : make_color_rgb(34, 44, 72),
		node_hover_dim    : 0.25,
		hover_fade_alpha  : 0.25,
		history_hover_col : make_color_rgb(34, 44, 72),
		history_spark_sprite : -1
	};

	/// @ignore
	/// @desc Internal: apply hover/pressed defaults for a single control style.
	/// @param {Struct} _st
	/// @param {Any} _bg_default
	/// @param {Any} _bd_default
	/// @param {Any} _tx_default
	/// @param {Real} _hover_mix
	/// @param {Real} _bg_alpha_default
	/// @param {Real} _bd_alpha_default
	/// @param {Real} _tx_alpha_default
	static __ApplyInteractionDefaults = function(_st, _bg_default, _bd_default, _tx_default, _hover_mix = 0.15, _bg_alpha_default = 1, _bd_alpha_default = 1, _tx_alpha_default = 1) {
		if (!is_struct(_st)) {
			return;
		}
		var _bg = _st[$ "bg"];
		if (is_undefined(_bg)) {
			_bg = _bg_default;
		}
		var _bd = _st[$ "border"];
		if (is_undefined(_bd)) {
			_bd = _bd_default;
		}
		var _tx = _st[$ "text"];
		if (is_undefined(_tx)) {
			_tx = _tx_default;
		}
		var _bg_alpha = _st[$ "bg_alpha"];
		if (is_undefined(_bg_alpha)) {
			_bg_alpha = _bg_alpha_default;
			_st[$ "bg_alpha"] = _bg_alpha;
		}
		var _bd_alpha = _st[$ "border_alpha"];
		if (is_undefined(_bd_alpha)) {
			_bd_alpha = _bd_alpha_default;
			_st[$ "border_alpha"] = _bd_alpha;
		}
		var _tx_alpha = _st[$ "text_alpha"];
		if (is_undefined(_tx_alpha)) {
			_tx_alpha = _tx_alpha_default;
			_st[$ "text_alpha"] = _tx_alpha;
		}
		var _hover = _st[$ "bg_hover"];
		if (is_undefined(_hover)) {
			_hover = _st[$ "hover"];
		}
		if (is_undefined(_hover)) {
			_hover = merge_color(_bg, _tx, _hover_mix);
		}
		var _pressed_mix = _st[$ "pressed_mix"];
		if (is_undefined(_pressed_mix)) {
			_pressed_mix = min(1, _hover_mix + 0.1);
			_st[$ "pressed_mix"] = _pressed_mix;
		}
		if (is_undefined(_st[$ "bg_hover"])) {
			_st[$ "bg_hover"] = _hover;
		}
		if (is_undefined(_st[$ "bg_hover_alpha"])) {
			_st[$ "bg_hover_alpha"] = _bg_alpha;
		}
		if (is_undefined(_st[$ "border_hover"])) {
			_st[$ "border_hover"] = _bd;
		}
		if (is_undefined(_st[$ "border_hover_alpha"])) {
			_st[$ "border_hover_alpha"] = _bd_alpha;
		}
		if (is_undefined(_st[$ "text_hover"])) {
			_st[$ "text_hover"] = _tx;
		}
		if (is_undefined(_st[$ "text_hover_alpha"])) {
			_st[$ "text_hover_alpha"] = _tx_alpha;
		}
		if (is_undefined(_st[$ "bg_pressed"])) {
			_st[$ "bg_pressed"] = merge_color(_st[$ "bg_hover"], _tx, _pressed_mix);
		}
		if (is_undefined(_st[$ "bg_pressed_alpha"])) {
			_st[$ "bg_pressed_alpha"] = _st[$ "bg_hover_alpha"];
		}
		if (is_undefined(_st[$ "border_pressed"])) {
			_st[$ "border_pressed"] = _st[$ "border_hover"];
		}
		if (is_undefined(_st[$ "border_pressed_alpha"])) {
			_st[$ "border_pressed_alpha"] = _st[$ "border_hover_alpha"];
		}
		if (is_undefined(_st[$ "text_pressed"])) {
			_st[$ "text_pressed"] = _st[$ "text_hover"];
		}
		if (is_undefined(_st[$ "text_pressed_alpha"])) {
			_st[$ "text_pressed_alpha"] = _st[$ "text_hover_alpha"];
		}
		if (is_undefined(_st[$ "bg_disabled"])) {
			_st[$ "bg_disabled"] = merge_color(_bg, col_panel_bg, 0.6);
		}
		if (is_undefined(_st[$ "bg_disabled_alpha"])) {
			_st[$ "bg_disabled_alpha"] = _bg_alpha;
		}
		if (is_undefined(_st[$ "border_disabled"])) {
			_st[$ "border_disabled"] = merge_color(_bd, col_panel_bg, 0.6);
		}
		if (is_undefined(_st[$ "border_disabled_alpha"])) {
			_st[$ "border_disabled_alpha"] = _bd_alpha;
		}
		if (is_undefined(_st[$ "text_disabled"])) {
			_st[$ "text_disabled"] = col_text_dim;
		}
		if (is_undefined(_st[$ "text_disabled_alpha"])) {
			_st[$ "text_disabled_alpha"] = _tx_alpha;
		}
	};

	/// @ignore
	/// @desc Internal: apply hover/pressed defaults to every style in a map.
	/// @param {Struct} _styles
	/// @param {Any} _bg_default
	/// @param {Any} _bd_default
	/// @param {Any} _tx_default
	/// @param {Real} _hover_mix
	/// @param {Real} _bg_alpha_default
	/// @param {Real} _bd_alpha_default
	/// @param {Real} _tx_alpha_default
	static __ApplyStyleMapDefaults = function(_styles, _bg_default, _bd_default, _tx_default, _hover_mix = 0.15, _bg_alpha_default = 1, _bd_alpha_default = 1, _tx_alpha_default = 1) {
		if (!is_struct(_styles)) {
			return;
		}
		var _names = variable_struct_get_names(_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = _styles[$ _name];
			if (is_struct(_st)) {
				__ApplyInteractionDefaults(_st, _bg_default, _bd_default, _tx_default, _hover_mix, _bg_alpha_default, _bd_alpha_default, _tx_alpha_default);
			}
		}
	};

	/// @ignore
	/// @desc Internal: copy missing keys from defaults into a struct.
	/// @param {Struct} _dst
	/// @param {Struct} _defaults
	static __ApplyStructDefaults = function(_dst, _defaults) {
		if (!is_struct(_dst) || !is_struct(_defaults)) {
			return;
		}
		var _keys = variable_struct_get_names(_defaults);
		var _count = array_length(_keys);
		for (var _i = 0; _i < _count; _i++) {
			var _k = _keys[_i];
			if (is_undefined(_dst[$ _k])) {
				_dst[$ _k] = _defaults[$ _k];
			}
		}
	};

	/// @ignore
	/// @desc Internal: apply checkbox box defaults for toggle styles.
	/// @param {Struct} _styles
	static __ApplyToggleStyleDefaults = function(_styles) {
		if (!is_struct(_styles)) {
			return;
		}
		var _names = variable_struct_get_names(_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = _styles[$ _name];
			if (!is_struct(_st)) {
				continue;
			}
			var _box_on = _st[$ "box_on"];
			if (is_undefined(_box_on)) {
				_box_on = col_checkbox_on;
				_st[$ "box_on"] = _box_on;
			}
			if (is_undefined(_st[$ "box_on_alpha"])) {
				_st[$ "box_on_alpha"] = 1;
			}
			var _box_off = _st[$ "box_off"];
			if (is_undefined(_box_off)) {
				_box_off = col_checkbox_off;
				_st[$ "box_off"] = _box_off;
			}
			if (is_undefined(_st[$ "box_off_alpha"])) {
				_st[$ "box_off_alpha"] = 1;
			}
			var _box_border = _st[$ "box_border"];
			if (is_undefined(_box_border)) {
				_box_border = _st[$ "border"];
				if (is_undefined(_box_border)) {
					_box_border = col_accent;
				}
				_st[$ "box_border"] = _box_border;
			}
			if (is_undefined(_st[$ "box_border_alpha"])) {
				_st[$ "box_border_alpha"] = 1;
			}
			if (is_undefined(_st[$ "box_border_hover"])) {
				_st[$ "box_border_hover"] = _st[$ "box_border"];
			}
			if (is_undefined(_st[$ "box_border_hover_alpha"])) {
				_st[$ "box_border_hover_alpha"] = _st[$ "box_border_alpha"];
			}
			if (is_undefined(_st[$ "box_border_pressed"])) {
				_st[$ "box_border_pressed"] = _st[$ "box_border_hover"];
			}
			if (is_undefined(_st[$ "box_border_pressed_alpha"])) {
				_st[$ "box_border_pressed_alpha"] = _st[$ "box_border_hover_alpha"];
			}
			if (is_undefined(_st[$ "box_on_hover"])) {
				_st[$ "box_on_hover"] = _st[$ "box_on"];
			}
			if (is_undefined(_st[$ "box_on_hover_alpha"])) {
				_st[$ "box_on_hover_alpha"] = _st[$ "box_on_alpha"];
			}
			if (is_undefined(_st[$ "box_on_pressed"])) {
				_st[$ "box_on_pressed"] = _st[$ "box_on_hover"];
			}
			if (is_undefined(_st[$ "box_on_pressed_alpha"])) {
				_st[$ "box_on_pressed_alpha"] = _st[$ "box_on_hover_alpha"];
			}
			if (is_undefined(_st[$ "box_off_hover"])) {
				_st[$ "box_off_hover"] = _st[$ "box_off"];
			}
			if (is_undefined(_st[$ "box_off_hover_alpha"])) {
				_st[$ "box_off_hover_alpha"] = _st[$ "box_off_alpha"];
			}
			if (is_undefined(_st[$ "box_off_pressed"])) {
				_st[$ "box_off_pressed"] = _st[$ "box_off_hover"];
			}
			if (is_undefined(_st[$ "box_off_pressed_alpha"])) {
				_st[$ "box_off_pressed_alpha"] = _st[$ "box_off_hover_alpha"];
			}
			if (is_undefined(_st[$ "box_on_disabled"])) {
				_st[$ "box_on_disabled"] = merge_color(_box_on, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "box_on_disabled_alpha"])) {
				_st[$ "box_on_disabled_alpha"] = _st[$ "box_on_alpha"];
			}
			if (is_undefined(_st[$ "box_off_disabled"])) {
				_st[$ "box_off_disabled"] = merge_color(_box_off, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "box_off_disabled_alpha"])) {
				_st[$ "box_off_disabled_alpha"] = _st[$ "box_off_alpha"];
			}
			if (is_undefined(_st[$ "box_border_disabled"])) {
				_st[$ "box_border_disabled"] = merge_color(_box_border, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "box_border_disabled_alpha"])) {
				_st[$ "box_border_disabled_alpha"] = _st[$ "box_border_alpha"];
			}
		}
	};

	/// @ignore
	/// @desc Internal: apply active state defaults for text input styles.
	/// @param {Struct} _styles
	static __ApplyTextInputStyleDefaults = function(_styles) {
		if (!is_struct(_styles)) {
			return;
		}

		var _st_default = _styles[$ "_default"];
		if (!is_struct(_st_default)) {
			_st_default = {};
			_styles[$ "_default"] = _st_default;
		}

		var _ed_default = _st_default[$ "editor"];
		if (!is_struct(_ed_default)) {
			_ed_default = {};
			_st_default[$ "editor"] = _ed_default;
		}
		if (is_undefined(_ed_default[$ "dim_color"])) {
			_ed_default[$ "dim_color"] = c_black;
		}
		if (is_undefined(_ed_default[$ "dim_alpha"])) {
			_ed_default[$ "dim_alpha"] = 0.55;
		}
		if (is_undefined(_ed_default[$ "panel_bg"])) {
			_ed_default[$ "panel_bg"] = col_window_bg;
		}
		if (is_undefined(_ed_default[$ "panel_border"])) {
			_ed_default[$ "panel_border"] = col_accent;
		}
		if (is_undefined(_ed_default[$ "panel_bg_alpha"])) {
			_ed_default[$ "panel_bg_alpha"] = 0.96;
		}
		if (is_undefined(_ed_default[$ "panel_border_alpha"])) {
			_ed_default[$ "panel_border_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "viewport_margin"])) {
			_ed_default[$ "viewport_margin"] = 16;
		}
		if (is_undefined(_ed_default[$ "min_width"])) {
			_ed_default[$ "min_width"] = 320;
		}
		if (is_undefined(_ed_default[$ "max_width"])) {
			_ed_default[$ "max_width"] = 720;
		}
		if (is_undefined(_ed_default[$ "min_height"])) {
			_ed_default[$ "min_height"] = 240;
		}
		if (is_undefined(_ed_default[$ "max_height"])) {
			_ed_default[$ "max_height"] = 480;
		}
		if (is_undefined(_ed_default[$ "padding"])) {
			_ed_default[$ "padding"] = 12;
		}
		if (is_undefined(_ed_default[$ "gap"])) {
			_ed_default[$ "gap"] = 8;
		}
		if (is_undefined(_ed_default[$ "row_min_height"])) {
			_ed_default[$ "row_min_height"] = 18;
		}
		if (is_undefined(_ed_default[$ "button_width"])) {
			_ed_default[$ "button_width"] = 72;
		}
		if (is_undefined(_ed_default[$ "button_bg"])) {
			_ed_default[$ "button_bg"] = merge_color(col_window_bg, col_text, 0.08);
		}
		if (is_undefined(_ed_default[$ "button_bg_hover"])) {
			_ed_default[$ "button_bg_hover"] = merge_color(_ed_default[$ "button_bg"], col_text, 0.12);
		}
		if (is_undefined(_ed_default[$ "button_border"])) {
			_ed_default[$ "button_border"] = col_accent;
		}
		if (is_undefined(_ed_default[$ "button_bg_alpha"])) {
			_ed_default[$ "button_bg_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "button_border_alpha"])) {
			_ed_default[$ "button_border_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "button_text"])) {
			_ed_default[$ "button_text"] = col_text;
		}
		if (is_undefined(_ed_default[$ "button_text_alpha"])) {
			_ed_default[$ "button_text_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "button_cancel_inset_x"])) {
			_ed_default[$ "button_cancel_inset_x"] = 12;
		}
		if (is_undefined(_ed_default[$ "button_done_inset_x"])) {
			_ed_default[$ "button_done_inset_x"] = 18;
		}
		if (is_undefined(_ed_default[$ "title_font"])) {
			_ed_default[$ "title_font"] = font_body;
		}
		if (is_undefined(_ed_default[$ "title_text"])) {
			_ed_default[$ "title_text"] = col_text;
		}
		if (is_undefined(_ed_default[$ "title_text_alpha"])) {
			_ed_default[$ "title_text_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "editor_bg"])) {
			_ed_default[$ "editor_bg"] = merge_color(col_window_bg, col_text, 0.05);
		}
		if (is_undefined(_ed_default[$ "editor_border"])) {
			_ed_default[$ "editor_border"] = col_accent;
		}
		if (is_undefined(_ed_default[$ "editor_bg_alpha"])) {
			_ed_default[$ "editor_bg_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "editor_border_alpha"])) {
			_ed_default[$ "editor_border_alpha"] = 1;
		}
		if (is_undefined(_ed_default[$ "editor_inner_padding"])) {
			_ed_default[$ "editor_inner_padding"] = 6;
		}
		if (is_undefined(_ed_default[$ "editor_scrollbar_extra_w"])) {
			_ed_default[$ "editor_scrollbar_extra_w"] = 2;
		}

		var _menu_default = _st_default[$ "menu"];
		if (!is_struct(_menu_default)) {
			_menu_default = {};
			_st_default[$ "menu"] = _menu_default;
		}
		var _legacy_menu_font = self[$ "context_menu_font"];
		var _legacy_menu_padding = self[$ "context_menu_padding"];
		var _legacy_menu_row_h = self[$ "context_menu_row_h"];
		var _legacy_menu_min_w = self[$ "context_menu_min_w"];
		var _legacy_menu_max_w = self[$ "context_menu_max_w"];
		var _row_default = list_row_styles[$ "_default"];
		if (is_undefined(_menu_default[$ "font"])) {
			_menu_default[$ "font"] = is_undefined(_legacy_menu_font) ? font_small : _legacy_menu_font;
		}
		if (is_undefined(_menu_default[$ "padding"])) {
			_menu_default[$ "padding"] = is_undefined(_legacy_menu_padding) ? default_padding : _legacy_menu_padding;
		}
		if (is_undefined(_menu_default[$ "row_height"])) {
			_menu_default[$ "row_height"] = is_undefined(_legacy_menu_row_h) ? default_row_height : _legacy_menu_row_h;
		}
		if (is_undefined(_menu_default[$ "separator_height"])) {
			_menu_default[$ "separator_height"] = 0;
		}
		if (is_undefined(_menu_default[$ "shortcut_gap"])) {
			_menu_default[$ "shortcut_gap"] = 24;
		}
		if (is_undefined(_menu_default[$ "min_width"])) {
			_menu_default[$ "min_width"] = is_undefined(_legacy_menu_min_w) ? 140 : _legacy_menu_min_w;
		}
		if (is_undefined(_menu_default[$ "max_width"])) {
			_menu_default[$ "max_width"] = is_undefined(_legacy_menu_max_w) ? 520 : _legacy_menu_max_w;
		}
		if (is_undefined(_menu_default[$ "viewport_margin"])) {
			_menu_default[$ "viewport_margin"] = 4;
		}
		if (is_undefined(_menu_default[$ "item_inset_x"])) {
			_menu_default[$ "item_inset_x"] = 0;
		}
		if (is_undefined(_menu_default[$ "panel_bg"])) {
			_menu_default[$ "panel_bg"] = col_window_bg;
		}
		if (is_undefined(_menu_default[$ "panel_bg_alpha"])) {
			_menu_default[$ "panel_bg_alpha"] = 1;
		}
		if (is_undefined(_menu_default[$ "panel_border"])) {
			_menu_default[$ "panel_border"] = col_accent;
		}
		if (is_undefined(_menu_default[$ "panel_border_alpha"])) {
			_menu_default[$ "panel_border_alpha"] = 1;
		}
		if (is_undefined(_menu_default[$ "item_bg"])) {
			_menu_default[$ "item_bg"] = is_struct(_row_default) ? (_row_default[$ "bg_normal"] ?? col_panel_bg) : col_panel_bg;
		}
		if (is_undefined(_menu_default[$ "item_bg_alpha"])) {
			_menu_default[$ "item_bg_alpha"] = is_struct(_row_default) ? (_row_default[$ "bg_normal_alpha"] ?? 1) : 1;
		}
		if (is_undefined(_menu_default[$ "item_hover_bg"])) {
			_menu_default[$ "item_hover_bg"] = is_struct(_row_default) ? (_row_default[$ "bg_hover"] ?? col_hover_row) : col_hover_row;
		}
		if (is_undefined(_menu_default[$ "item_hover_bg_alpha"])) {
			_menu_default[$ "item_hover_bg_alpha"] = is_struct(_row_default) ? (_row_default[$ "bg_hover_alpha"] ?? 1) : 1;
		}
		if (is_undefined(_menu_default[$ "item_text"])) {
			_menu_default[$ "item_text"] = is_struct(_row_default) ? (_row_default[$ "text_normal"] ?? col_text) : col_text;
		}
		if (is_undefined(_menu_default[$ "item_text_alpha"])) {
			_menu_default[$ "item_text_alpha"] = is_struct(_row_default) ? (_row_default[$ "text_normal_alpha"] ?? 1) : 1;
		}
		if (is_undefined(_menu_default[$ "item_text_hot"])) {
			_menu_default[$ "item_text_hot"] = is_struct(_row_default) ? (_row_default[$ "text_selected"] ?? col_text) : col_text;
		}
		if (is_undefined(_menu_default[$ "item_text_hot_alpha"])) {
			_menu_default[$ "item_text_hot_alpha"] = is_struct(_row_default) ? (_row_default[$ "text_selected_alpha"] ?? 1) : 1;
		}
		if (is_undefined(_menu_default[$ "item_text_disabled_alpha"])) {
			_menu_default[$ "item_text_disabled_alpha"] = 0.45;
		}
		if (is_undefined(_menu_default[$ "separator_color"])) {
			_menu_default[$ "separator_color"] = col_accent;
		}
		if (is_undefined(_menu_default[$ "separator_alpha"])) {
			_menu_default[$ "separator_alpha"] = 1;
		}

		var _names = variable_struct_get_names(_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = _styles[$ _name];
			if (!is_struct(_st)) {
				continue;
			}
			var _bg = _st[$ "bg"];
			if (is_undefined(_bg)) {
				_bg = col_panel_bg;
			}
			var _bd = _st[$ "border"];
			if (is_undefined(_bd)) {
				_bd = col_accent;
			}
			var _tx = _st[$ "text"];
			if (is_undefined(_tx)) {
				_tx = col_text;
			}
			var _bg_alpha = _st[$ "bg_alpha"];
			if (is_undefined(_bg_alpha)) {
				_bg_alpha = 1;
				_st[$ "bg_alpha"] = _bg_alpha;
			}
			var _bd_alpha = _st[$ "border_alpha"];
			if (is_undefined(_bd_alpha)) {
				_bd_alpha = 1;
				_st[$ "border_alpha"] = _bd_alpha;
			}
			var _tx_alpha = _st[$ "text_alpha"];
			if (is_undefined(_tx_alpha)) {
				_tx_alpha = 1;
				_st[$ "text_alpha"] = _tx_alpha;
			}
			var _sel_bg = _st[$ "selection_bg"];
			if (is_undefined(_sel_bg)) {
				_sel_bg = merge_color(_bg, _tx, 0.35);
				_st[$ "selection_bg"] = _sel_bg;
			}
			if (is_undefined(_st[$ "selection_bg_alpha"])) {
				_st[$ "selection_bg_alpha"] = 1;
			}
			if (is_undefined(_st[$ "selection_text"])) {
				_st[$ "selection_text"] = _tx;
			}
			if (is_undefined(_st[$ "selection_text_alpha"])) {
				_st[$ "selection_text_alpha"] = _tx_alpha;
			}
			if (is_undefined(_st[$ "selection_bg_inactive"])) {
				_st[$ "selection_bg_inactive"] = merge_color(_sel_bg, _bg, 0.5);
			}
			if (is_undefined(_st[$ "selection_bg_inactive_alpha"])) {
				_st[$ "selection_bg_inactive_alpha"] = _st[$ "selection_bg_alpha"];
			}
			if (is_undefined(_st[$ "selection_text_inactive"])) {
				_st[$ "selection_text_inactive"] = _st[$ "selection_text"];
			}
			if (is_undefined(_st[$ "selection_text_inactive_alpha"])) {
				_st[$ "selection_text_inactive_alpha"] = _st[$ "selection_text_alpha"];
			}
			if (is_undefined(_st[$ "caret_color"])) {
				_st[$ "caret_color"] = _tx;
			}
			if (is_undefined(_st[$ "caret_alpha"])) {
				_st[$ "caret_alpha"] = 1;
			}
			if (is_undefined(_st[$ "caret_char"])) {
				_st[$ "caret_char"] = "|";
			}
			if (is_undefined(_st[$ "caret_blink_ms"])) {
				_st[$ "caret_blink_ms"] = 520;
			}
			if (is_undefined(_st[$ "caret_width"])) {
				_st[$ "caret_width"] = 1;
			}
			if (is_undefined(_st[$ "caret_height"])) {
				_st[$ "caret_height"] = 0;
			}
			if (is_undefined(_st[$ "caret_inset_x"])) {
				_st[$ "caret_inset_x"] = 0;
			}
			if (is_undefined(_st[$ "caret_inset_y"])) {
				_st[$ "caret_inset_y"] = 0;
			}
			if (is_undefined(_st[$ "input_bg_sprite"])) {
				_st[$ "input_bg_sprite"] = -1;
			}
			if (is_undefined(_st[$ "input_border_sprite"])) {
				_st[$ "input_border_sprite"] = -1;
			}
			if (is_undefined(_st[$ "input_caret_sprite"])) {
				_st[$ "input_caret_sprite"] = -1;
			}
			if (is_undefined(_st[$ "textarea_grip_sprite"])) {
				_st[$ "textarea_grip_sprite"] = -1;
			}
			if (is_undefined(_st[$ "textarea_expand_sprite"])) {
				_st[$ "textarea_expand_sprite"] = -1;
			}
			if (is_undefined(_st[$ "placeholder_alpha"])) {
				_st[$ "placeholder_alpha"] = 0.6;
			}
			if (is_undefined(_st[$ "bg_disabled"])) {
				_st[$ "bg_disabled"] = merge_color(_bg, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "bg_disabled_alpha"])) {
				_st[$ "bg_disabled_alpha"] = _bg_alpha;
			}
			if (is_undefined(_st[$ "border_disabled"])) {
				_st[$ "border_disabled"] = merge_color(_bd, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "border_disabled_alpha"])) {
				_st[$ "border_disabled_alpha"] = _bd_alpha;
			}
			if (is_undefined(_st[$ "text_disabled"])) {
				_st[$ "text_disabled"] = col_text_dim;
			}
			if (is_undefined(_st[$ "text_disabled_alpha"])) {
				_st[$ "text_disabled_alpha"] = _tx_alpha;
			}
			if (is_undefined(_st[$ "bg_readonly"])) {
				_st[$ "bg_readonly"] = merge_color(_bg, col_panel_bg, 0.1);
			}
			if (is_undefined(_st[$ "bg_readonly_alpha"])) {
				_st[$ "bg_readonly_alpha"] = _bg_alpha;
			}
			if (is_undefined(_st[$ "border_readonly"])) {
				_st[$ "border_readonly"] = _bd;
			}
			if (is_undefined(_st[$ "border_readonly_alpha"])) {
				_st[$ "border_readonly_alpha"] = _bd_alpha;
			}
			if (is_undefined(_st[$ "text_readonly"])) {
				_st[$ "text_readonly"] = _tx;
			}
			if (is_undefined(_st[$ "text_readonly_alpha"])) {
				_st[$ "text_readonly_alpha"] = _tx_alpha;
			}
			if (is_undefined(_st[$ "bg_invalid"])) {
				_st[$ "bg_invalid"] = merge_color(_bg, col_error, 0.2);
			}
			if (is_undefined(_st[$ "bg_invalid_alpha"])) {
				_st[$ "bg_invalid_alpha"] = _bg_alpha;
			}
			if (is_undefined(_st[$ "border_invalid"])) {
				_st[$ "border_invalid"] = col_error;
			}
			if (is_undefined(_st[$ "border_invalid_alpha"])) {
				_st[$ "border_invalid_alpha"] = _bd_alpha;
			}
			if (is_undefined(_st[$ "text_invalid"])) {
				_st[$ "text_invalid"] = _tx;
			}
			if (is_undefined(_st[$ "text_invalid_alpha"])) {
				_st[$ "text_invalid_alpha"] = _tx_alpha;
			}
			if (is_undefined(_st[$ "open_mix"])) {
				_st[$ "open_mix"] = 0.15;
			}
			if (is_undefined(_st[$ "bg_active"])) {
				_st[$ "bg_active"] = merge_color(_bg, _tx, 0.2);
			}
			if (is_undefined(_st[$ "bg_active_alpha"])) {
				_st[$ "bg_active_alpha"] = _bg_alpha;
			}
			if (is_undefined(_st[$ "border_active"])) {
				_st[$ "border_active"] = _bd;
			}
			if (is_undefined(_st[$ "border_active_alpha"])) {
				_st[$ "border_active_alpha"] = _bd_alpha;
			}
			if (is_undefined(_st[$ "text_active"])) {
				_st[$ "text_active"] = _tx;
			}
			if (is_undefined(_st[$ "text_active_alpha"])) {
				_st[$ "text_active_alpha"] = _tx_alpha;
			}

			var _st_editor = _st[$ "editor"];
			if (!is_struct(_st_editor)) {
				_st_editor = {};
				_st[$ "editor"] = _st_editor;
			}
			__ApplyStructDefaults(_st_editor, _ed_default);

			var _st_menu = _st[$ "menu"];
			if (!is_struct(_st_menu)) {
				_st_menu = {};
				_st[$ "menu"] = _st_menu;
			}
			__ApplyStructDefaults(_st_menu, _menu_default);
		}
	};

	/// @ignore
	/// @desc Internal: apply open/overlay defaults for dropdown styles.
	/// @param {Struct} _styles
	static __ApplyDropdownStyleDefaults = function(_styles) {
		if (!is_struct(_styles)) {
			return;
		}
		var _names = variable_struct_get_names(_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = _styles[$ _name];
			if (!is_struct(_st)) {
				continue;
			}
			var _bg = _st[$ "bg"];
			if (is_undefined(_bg)) {
				_bg = col_panel_bg;
			}
			var _bd = _st[$ "border"];
			if (is_undefined(_bd)) {
				_bd = col_accent;
			}
			var _tx = _st[$ "text"];
			if (is_undefined(_tx)) {
				_tx = col_text;
			}
			if (is_undefined(_st[$ "overlay_bg"])) {
				_st[$ "overlay_bg"] = col_window_bg;
			}
			if (is_undefined(_st[$ "overlay_border"])) {
				_st[$ "overlay_border"] = _bd;
			}
			if (is_undefined(_st[$ "overlay_bg_alpha"])) {
				_st[$ "overlay_bg_alpha"] = 0.95;
			}
			if (is_undefined(_st[$ "overlay_border_alpha"])) {
				_st[$ "overlay_border_alpha"] = 1;
			}
			if (is_undefined(_st[$ "overlay_row_bg"])) {
				_st[$ "overlay_row_bg"] = col_panel_bg;
			}
			if (is_undefined(_st[$ "overlay_row_bg_alpha"])) {
				_st[$ "overlay_row_bg_alpha"] = 1;
			}
			if (is_undefined(_st[$ "overlay_row_hover"])) {
				_st[$ "overlay_row_hover"] = col_hover_row;
			}
			if (is_undefined(_st[$ "overlay_row_hover_alpha"])) {
				_st[$ "overlay_row_hover_alpha"] = _st[$ "overlay_row_bg_alpha"];
			}
			if (is_undefined(_st[$ "overlay_row_selected"])) {
				_st[$ "overlay_row_selected"] = col_hover_row_alt;
			}
			if (is_undefined(_st[$ "overlay_row_selected_alpha"])) {
				_st[$ "overlay_row_selected_alpha"] = _st[$ "overlay_row_bg_alpha"];
			}
			if (is_undefined(_st[$ "overlay_row_pressed"])) {
				_st[$ "overlay_row_pressed"] = _st[$ "overlay_row_hover"];
			}
			if (is_undefined(_st[$ "overlay_row_pressed_alpha"])) {
				_st[$ "overlay_row_pressed_alpha"] = _st[$ "overlay_row_hover_alpha"];
			}
			if (is_undefined(_st[$ "overlay_text"])) {
				_st[$ "overlay_text"] = col_text;
			}
			if (is_undefined(_st[$ "overlay_text_alpha"])) {
				_st[$ "overlay_text_alpha"] = 1;
			}
			if (is_undefined(_st[$ "overlay_text_hover"])) {
				_st[$ "overlay_text_hover"] = _st[$ "overlay_text"];
			}
			if (is_undefined(_st[$ "overlay_text_hover_alpha"])) {
				_st[$ "overlay_text_hover_alpha"] = _st[$ "overlay_text_alpha"];
			}
			if (is_undefined(_st[$ "overlay_text_selected"])) {
				_st[$ "overlay_text_selected"] = _st[$ "overlay_text"];
			}
			if (is_undefined(_st[$ "overlay_text_selected_alpha"])) {
				_st[$ "overlay_text_selected_alpha"] = _st[$ "overlay_text_alpha"];
			}
			if (is_undefined(_st[$ "overlay_text_pressed"])) {
				_st[$ "overlay_text_pressed"] = _st[$ "overlay_text_hover"];
			}
			if (is_undefined(_st[$ "overlay_text_pressed_alpha"])) {
				_st[$ "overlay_text_pressed_alpha"] = _st[$ "overlay_text_hover_alpha"];
			}
			if (is_undefined(_st[$ "overlay_search_bg"])) {
				_st[$ "overlay_search_bg"] = col_panel_bg;
			}
			if (is_undefined(_st[$ "overlay_search_bg_alpha"])) {
				_st[$ "overlay_search_bg_alpha"] = 1;
			}
			if (is_undefined(_st[$ "overlay_search_border"])) {
				_st[$ "overlay_search_border"] = _st[$ "overlay_border"];
			}
			if (is_undefined(_st[$ "overlay_search_border_alpha"])) {
				_st[$ "overlay_search_border_alpha"] = _st[$ "overlay_border_alpha"];
			}
			if (is_undefined(_st[$ "overlay_search_hover_bg"])) {
				_st[$ "overlay_search_hover_bg"] = merge_color(col_panel_bg, col_text, 0.2);
			}
			if (is_undefined(_st[$ "overlay_search_hover_bg_alpha"])) {
				_st[$ "overlay_search_hover_bg_alpha"] = _st[$ "overlay_search_bg_alpha"];
			}
			if (is_undefined(_st[$ "overlay_search_text"])) {
				_st[$ "overlay_search_text"] = col_text;
			}
			if (is_undefined(_st[$ "overlay_search_text_alpha"])) {
				_st[$ "overlay_search_text_alpha"] = 1;
			}
			if (is_undefined(_st[$ "overlay_search_placeholder"])) {
				_st[$ "overlay_search_placeholder"] = col_muted;
			}
			if (is_undefined(_st[$ "overlay_search_placeholder_alpha"])) {
				_st[$ "overlay_search_placeholder_alpha"] = _st[$ "overlay_search_text_alpha"];
			}
		}
	};

	/// @ignore
	/// @desc Internal: apply hover/pressed defaults for slider styles.
	/// @param {Struct} _styles
	static __ApplySliderStyleDefaults = function(_styles) {
		if (!is_struct(_styles)) {
			return;
		}
		var _names = variable_struct_get_names(_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = _styles[$ _name];
			if (!is_struct(_st)) {
				continue;
			}
			var _track = _st[$ "track_bg"];
			if (is_undefined(_track)) {
				_track = col_panel_bg;
				_st[$ "track_bg"] = _track;
			}
			if (is_undefined(_st[$ "track_bg_alpha"])) {
				_st[$ "track_bg_alpha"] = 1;
			}
			var _fill = _st[$ "track_fill"];
			if (is_undefined(_fill)) {
				_fill = col_accent;
				_st[$ "track_fill"] = _fill;
			}
			if (is_undefined(_st[$ "track_fill_alpha"])) {
				_st[$ "track_fill_alpha"] = 1;
			}
			var _knob = _st[$ "knob"];
			if (is_undefined(_knob)) {
				_knob = col_text;
				_st[$ "knob"] = _knob;
			}
			if (is_undefined(_st[$ "knob_alpha"])) {
				_st[$ "knob_alpha"] = 1;
			}
			if (is_undefined(_st[$ "track_bg_hover"])) {
				_st[$ "track_bg_hover"] = merge_color(_track, col_text, 0.12);
			}
			if (is_undefined(_st[$ "track_bg_hover_alpha"])) {
				_st[$ "track_bg_hover_alpha"] = _st[$ "track_bg_alpha"];
			}
			if (is_undefined(_st[$ "track_fill_hover"])) {
				_st[$ "track_fill_hover"] = merge_color(_fill, col_text, 0.12);
			}
			if (is_undefined(_st[$ "track_fill_hover_alpha"])) {
				_st[$ "track_fill_hover_alpha"] = _st[$ "track_fill_alpha"];
			}
			if (is_undefined(_st[$ "knob_hover"])) {
				_st[$ "knob_hover"] = merge_color(_knob, col_text, 0.12);
			}
			if (is_undefined(_st[$ "knob_hover_alpha"])) {
				_st[$ "knob_hover_alpha"] = _st[$ "knob_alpha"];
			}
			if (is_undefined(_st[$ "track_bg_pressed"])) {
				_st[$ "track_bg_pressed"] = _st[$ "track_bg_hover"];
			}
			if (is_undefined(_st[$ "track_bg_pressed_alpha"])) {
				_st[$ "track_bg_pressed_alpha"] = _st[$ "track_bg_hover_alpha"];
			}
			if (is_undefined(_st[$ "track_fill_pressed"])) {
				_st[$ "track_fill_pressed"] = _st[$ "track_fill_hover"];
			}
			if (is_undefined(_st[$ "track_fill_pressed_alpha"])) {
				_st[$ "track_fill_pressed_alpha"] = _st[$ "track_fill_hover_alpha"];
			}
			if (is_undefined(_st[$ "knob_pressed"])) {
				_st[$ "knob_pressed"] = _st[$ "knob_hover"];
			}
			if (is_undefined(_st[$ "knob_pressed_alpha"])) {
				_st[$ "knob_pressed_alpha"] = _st[$ "knob_hover_alpha"];
			}
			if (is_undefined(_st[$ "track_bg_disabled"])) {
				_st[$ "track_bg_disabled"] = merge_color(_track, col_panel_bg, 0.4);
			}
			if (is_undefined(_st[$ "track_bg_disabled_alpha"])) {
				_st[$ "track_bg_disabled_alpha"] = _st[$ "track_bg_alpha"];
			}
			if (is_undefined(_st[$ "track_fill_disabled"])) {
				_st[$ "track_fill_disabled"] = merge_color(_fill, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "track_fill_disabled_alpha"])) {
				_st[$ "track_fill_disabled_alpha"] = _st[$ "track_fill_alpha"];
			}
			if (is_undefined(_st[$ "knob_disabled"])) {
				_st[$ "knob_disabled"] = merge_color(_knob, col_panel_bg, 0.6);
			}
			if (is_undefined(_st[$ "knob_disabled_alpha"])) {
				_st[$ "knob_disabled_alpha"] = _st[$ "knob_alpha"];
			}
		}
	};

	/// @ignore
	/// @desc Internal: apply hover/pressed defaults for list row styles.
	static __ApplyListRowDefaults = function() {
		if (!is_struct(list_row_styles)) {
			return;
		}
		var _names = variable_struct_get_names(list_row_styles);
		var _count = array_length(_names);
		for (var _i = 0; _i < _count; _i++) {
			var _name = _names[_i];
			var _st = list_row_styles[$ _name];
			if (!is_struct(_st)) {
				continue;
			}
			if (is_undefined(_st[$ "bg_normal"])) {
				_st[$ "bg_normal"] = col_panel_bg;
			}
			if (is_undefined(_st[$ "bg_hover"])) {
				_st[$ "bg_hover"] = col_hover_row;
			}
			if (is_undefined(_st[$ "bg_selected"])) {
				_st[$ "bg_selected"] = col_hover_row_alt;
			}
			if (is_undefined(_st[$ "bg_pressed"])) {
				_st[$ "bg_pressed"] = _st[$ "bg_hover"];
			}
			if (is_undefined(_st[$ "text_normal"])) {
				_st[$ "text_normal"] = col_text;
			}
			if (is_undefined(_st[$ "text_hover"])) {
				_st[$ "text_hover"] = _st[$ "text_normal"];
			}
			if (is_undefined(_st[$ "text_selected"])) {
				_st[$ "text_selected"] = _st[$ "text_normal"];
			}
			if (is_undefined(_st[$ "text_pressed"])) {
				_st[$ "text_pressed"] = _st[$ "text_hover"];
			}
			if (is_undefined(_st[$ "bg_disabled"])) {
				_st[$ "bg_disabled"] = merge_color(_st[$ "bg_normal"], col_window_bg, 0.35);
			}
			if (is_undefined(_st[$ "text_disabled"])) {
				_st[$ "text_disabled"] = col_text_dim;
			}
			if (is_undefined(_st[$ "bg_normal_alpha"])) {
				_st[$ "bg_normal_alpha"] = 1;
			}
			if (is_undefined(_st[$ "bg_hover_alpha"])) {
				_st[$ "bg_hover_alpha"] = _st[$ "bg_normal_alpha"];
			}
			if (is_undefined(_st[$ "bg_selected_alpha"])) {
				_st[$ "bg_selected_alpha"] = _st[$ "bg_normal_alpha"];
			}
			if (is_undefined(_st[$ "bg_pressed_alpha"])) {
				_st[$ "bg_pressed_alpha"] = _st[$ "bg_hover_alpha"];
			}
			if (is_undefined(_st[$ "bg_disabled_alpha"])) {
				_st[$ "bg_disabled_alpha"] = _st[$ "bg_normal_alpha"];
			}
			if (is_undefined(_st[$ "text_normal_alpha"])) {
				_st[$ "text_normal_alpha"] = 1;
			}
			if (is_undefined(_st[$ "text_hover_alpha"])) {
				_st[$ "text_hover_alpha"] = _st[$ "text_normal_alpha"];
			}
			if (is_undefined(_st[$ "text_selected_alpha"])) {
				_st[$ "text_selected_alpha"] = _st[$ "text_normal_alpha"];
			}
			if (is_undefined(_st[$ "text_pressed_alpha"])) {
				_st[$ "text_pressed_alpha"] = _st[$ "text_hover_alpha"];
			}
			if (is_undefined(_st[$ "text_disabled_alpha"])) {
				_st[$ "text_disabled_alpha"] = _st[$ "text_normal_alpha"];
			}
		}
	};

	/// @desc Recompute row heights based on current fonts and padding.
	static RefreshMetrics = function() {
		var _old_font = draw_get_font();

		// Header row (bigger, title style)
		draw_set_font(font_header);
		var _h_header = string_height("Hg") + pad_y * 2;
		row_header_h  = max(_h_header, min_hit_h) * ui_scale;

		// Toolbar / main control rows
		draw_set_font(font_body);
		var _h_body   = string_height("Hg") + pad_y * 2;
		row_toolbar_h = max(_h_body, min_hit_h) * ui_scale;

		// Smaller informational rows
		draw_set_font(font_small);
		var _h_small  = string_height("Hg") + pad_y * 2;
		row_small_h   = max(_h_small, (min_hit_h * 0.75)) * ui_scale;

		// Derived layout metrics (scaled)
		gap                     = 4 * ui_scale;
		default_control_width   = 160 * ui_scale;
		default_control_max_width = 320 * ui_scale;
		default_padding         = max(pad_x, pad_y) * ui_scale;
		default_row_height      = max(20 * ui_scale, row_toolbar_h);
		control_padding_x       = pad_x;
		control_padding_y       = pad_y;
		window_padding          = default_padding;
		window_titlebar_h       = row_header_h;
		window_resize_grip_size = 14 * ui_scale;
		window_minimized_h       = window_titlebar_h + (window_padding * 2) + 2;
		window_button_gap        = 2 * ui_scale;
		window_button_size       = max(12, window_titlebar_h - (6 * ui_scale));
		panel_padding           = default_padding;
		panel_gap               = gap;
		panel_row_height        = row_toolbar_h;
		panel_collapsed_size    = 8 * ui_scale;
		panel_collapse_handle_size = 8 * ui_scale;
		field_label_gap         = 6 * ui_scale;
		field_label_min_width   = 60 * ui_scale;
		field_label_max_width   = 220 * ui_scale;
		field_label_auto_min_control_w = 110 * ui_scale;
		scrollbar_w             = 6 * ui_scale;
		tooltip_padding         = default_padding;

		var _field_label_style = label_styles[$ "_field"];
		if (is_struct(_field_label_style)) {
			_field_label_style[$ "font"] = font_small;
			_field_label_style[$ "text"] = col_text_dim;
			_field_label_style[$ "text_disabled"] = col_text_dim;
		}

		__ApplyStyleMapDefaults(button_styles, col_panel_bg, col_accent, col_text, 0.15, 0.95, 1, 1);
		__ApplyStyleMapDefaults(toggle_styles, col_panel_bg, col_accent, col_text, 0.12, 0.9, 1, 1);
		__ApplyStyleMapDefaults(dropdown_styles, col_panel_bg, col_accent, col_text, 0.15, 0.9, 1, 1);
		__ApplyStyleMapDefaults(textinput_styles, col_panel_bg, col_accent, col_text, 0.12, 0.95, 1, 1);
		__ApplyToggleStyleDefaults(toggle_styles);
		__ApplyTextInputStyleDefaults(textinput_styles);
		__ApplyDropdownStyleDefaults(dropdown_styles);
		__ApplySliderStyleDefaults(slider_styles);
		__ApplyListRowDefaults();

		draw_set_font(_old_font);
	};
}

/// @func EchoChamberThemeMidnightNeon()
/// @desc Dark midnight blues with neon purple accent.
/// @return {Struct.EchoChamberThemeMidnightNeon}
function EchoChamberThemeMidnightNeon() : EchoChamberTheme() constructor {
	// Base palette
	col_window_bg		= make_color_rgb(8, 10, 26);
	col_panel_bg		= make_color_rgb(18, 22, 40);
	col_text			= make_color_rgb(230, 240, 255);
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(190, 90, 255);
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(130, 145, 175);
	col_muted_strong	= make_color_rgb(165, 180, 210);
	col_error			= make_color_rgb(255, 120, 160);
	
	col_hover_row		= make_color_rgb(26, 30, 70);
	col_hover_row_alt	= make_color_rgb(36, 46, 96);
	
	col_menu_bg			= make_color_rgb(10, 14, 32);
	col_menu_hover		= make_color_rgb(30, 36, 80);
	
	col_label_hover_bg	= make_color_rgb(50, 30, 80);
	
	col_checkbox_off	= make_color_rgb(8, 10, 26);
	col_checkbox_on		= make_color_rgb(90, 255, 235);
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.35);
	
	var _btn_bg			= make_color_rgb(26, 20, 58);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.16;
	var _btn_press_mix	= 0.26;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.62);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.62);
	var _btn_tx_dis		= col_text_dim;
	
	var _toggle_bg		= make_color_rgb(18, 20, 46);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.12;
	var _toggle_press_mix = 0.22;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.62);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.62);
	var _toggle_tx_dis	= col_text_dim;
	
	var _dropdown_bg	= make_color_rgb(22, 18, 52);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.16;
	var _dropdown_press_mix = 0.26;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.62);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.62);
	var _dropdown_tx_dis = col_text_dim;
	
	var _ti_bg			= make_color_rgb(16, 18, 42);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, col_accent, 0.18);
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.62);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.62);
	var _ti_tx_dis		= col_text_dim;
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.22);
	var _ti_sel_bg		= merge_color(_ti_bg, col_checkbox_on, 0.28);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.35);
	var _slider_fill	= col_accent;
	var _slider_knob	= col_checkbox_on;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows
	panel_styles._default = { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu	= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default = { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar
	header_styles._default = { bg : make_color_rgb(18, 18, 48), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (slightly more readable + distinct close)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.15), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.10), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.10),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, col_checkbox_on, 0.05), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_checkbox_on, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_checkbox_on, 0.10),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, col_error, 0.12), border : merge_color(col_error, col_panel_bg, 0.25), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, col_error, 0.22), border_hover : col_error, text_hover : _btn_tx,
		pressed_mix : 0.30, bg_pressed : merge_color(_btn_bg, col_error, 0.32),
		border_pressed : col_error, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(col_error, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : col_checkbox_on, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(col_checkbox_on, col_text, 0.10), box_on_pressed : merge_color(col_checkbox_on, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.62),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.62),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.62)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : col_hover_row_alt,
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : col_muted_strong
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : _bd_main, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : col_checkbox_on, caret_char : "|", caret_blink_ms : 480,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : col_muted_strong, placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.62),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.62)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : make_color_rgb(22, 18, 56),
		header_alpha : 1
	};
	
	tooltip_styles._default = { bg : col_menu_bg, border : _bd_dim, bg_alpha : 0.92, text : col_text };
	toast_styles._default	= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 0.92, text : col_text };
	
	// -------------------------------------------------------------------------
	// Optional alternate role (kept, but nudged toward the neon vibe)
	window_styles.alternate = { bg : make_color_rgb(10, 22, 26), border : make_color_rgb(230, 180, 80), bg_alpha : 0.78 };
	header_styles.alternate = { bg : make_color_rgb(10, 22, 26), border : make_color_rgb(230, 180, 80), bg_alpha : 1 };
	button_styles.alternate = { bg : make_color_rgb(10, 22, 26), border : make_color_rgb(230, 180, 80), text : col_text, bg_alpha : 1, align : "center" };
	panel_styles.alternate	= { bg : make_color_rgb(10, 22, 26), border : make_color_rgb(230, 180, 80), bg_alpha : 1, border_alpha : 1 };
}

/// @func EchoChamberThemeAmberForest()
/// @desc Forest greens with warm amber highlights.
/// @return {Struct.EchoChamberThemeAmberForest}
function EchoChamberThemeAmberForest() : EchoChamberTheme() constructor {
	// Base palette (push this theme into "lantern-lit forest" instead of "standard dark green")
	col_window_bg		= make_color_rgb(6, 14, 10);		// near-black pine
	col_panel_bg		= make_color_rgb(14, 26, 18);		// damp fern shadow
	col_text			= make_color_rgb(232, 252, 236);	// pale moss light
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 170, 60);	// molten amber
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(122, 152, 132);	// desaturated fern
	col_muted_strong	= make_color_rgb(178, 206, 184);	// foggy leaf-silver
	col_error			= make_color_rgb(235, 92, 64);		// ember-red (not pink)
	
	col_hover_row		= make_color_rgb(18, 40, 28);		// wet bark highlight
	col_hover_row_alt	= make_color_rgb(26, 56, 34);		// deeper "selected" glow
	
	col_menu_bg			= make_color_rgb(8, 18, 12);		// under-canopy
	col_menu_hover		= make_color_rgb(22, 44, 30);		// leaf sheen
	
	col_label_hover_bg	= make_color_rgb(46, 36, 18);		// amber stain (distinct from rows)
	
	col_checkbox_off	= make_color_rgb(6, 14, 10);
	col_checkbox_on		= make_color_rgb(90, 240, 170);	// bioluminescent fungus (bold + memorable)
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.38);
	
	var _btn_bg			= make_color_rgb(18, 34, 22);		// bark green
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.28;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.62);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.62);
	var _btn_tx_dis		= col_text_dim;
	
	var _toggle_bg		= make_color_rgb(16, 30, 20);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.23;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.62);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.62);
	var _toggle_tx_dis	= col_text_dim;
	
	var _dropdown_bg	= make_color_rgb(16, 28, 18);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.18;
	var _dropdown_press_mix = 0.28;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.62);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.62);
	var _dropdown_tx_dis = col_text_dim;
	
	var _ti_bg			= make_color_rgb(10, 22, 14);		// deep moss
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, col_checkbox_on, 0.16);	// active focus leans bioluminescent
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.62);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.62);
	var _ti_tx_dis		= col_text_dim;
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.24);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_checkbox_on, 0.30);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.40);
	var _slider_fill	= col_accent;
	var _slider_knob	= col_checkbox_on;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (borders are "sap-amber" instead of flat accent)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (a slightly warmer green so the amber reads hotter)
	header_styles._default	= { bg : make_color_rgb(16, 30, 18), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (lean into theme: pin feels "biolume", close feels "ember")
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.12), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, col_checkbox_on, 0.06), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_checkbox_on, 0.10), border_hover : col_checkbox_on, text_hover : _btn_tx,
		pressed_mix : 0.30, bg_pressed : merge_color(_btn_bg, col_checkbox_on, 0.18),
		border_pressed : col_checkbox_on, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, col_error, 0.16), border : merge_color(col_error, col_panel_bg, 0.28), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, col_error, 0.28), border_hover : col_error, text_hover : _btn_tx,
		pressed_mix : 0.32, bg_pressed : merge_color(_btn_bg, col_error, 0.40),
		border_pressed : col_error, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(col_error, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : col_checkbox_on, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(col_checkbox_on, col_text, 0.10), box_on_pressed : merge_color(col_checkbox_on, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.62),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.62),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.62)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : col_hover_row_alt,
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : col_muted_strong
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : col_checkbox_on, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : col_checkbox_on, caret_char : "|", caret_blink_ms : 500,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : col_muted_strong, placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders (amber fill, biolume knob)
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.62),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.62)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (give them a "lantern glass" warmth)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(14, 26, 18), col_accent, 0.14),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : _bd_dim,
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : _bd_dim,
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeSakuraPunch()
/// @desc Inky plum with candy pink accents.
/// @return {Struct.EchoChamberThemeSakuraPunch}
function EchoChamberThemeSakuraPunch() : EchoChamberTheme() constructor {
	// Base palette (go for "plum ink + neon candy + yuzu highlights", not "standard pink theme")
	col_window_bg		= make_color_rgb(14, 6, 18);		// deep plum ink
	col_panel_bg		= make_color_rgb(26, 12, 34);		// bruised violet
	col_text			= make_color_rgb(255, 238, 248);	// sakura paper
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 92, 186);	// candy punch pink
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(186, 142, 176);	// dusty mauve
	col_muted_strong	= make_color_rgb(220, 170, 202);	// sweetened rose
	col_error			= make_color_rgb(255, 74, 112);	// hot lipstick-red
	
	col_hover_row		= make_color_rgb(46, 18, 62);		// plum sheen
	col_hover_row_alt	= make_color_rgb(58, 26, 84);		// neon-tinted selection
	
	col_menu_bg			= make_color_rgb(18, 8, 26);		// dark grape
	col_menu_hover		= make_color_rgb(56, 18, 74);		// wet neon
	
	col_label_hover_bg	= make_color_rgb(76, 32, 56);		// warm bruised rose (distinct from row hover)
	
	col_checkbox_off	= make_color_rgb(14, 6, 18);
	col_checkbox_on		= make_color_rgb(220, 255, 90);	// yuzu neon (wild, memorable, high contrast)
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	// Buttons: ink-plum base, candy glow on hover, yuzu "sparkle" on pressed
	var _btn_bg			= make_color_rgb(34, 14, 46);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, col_checkbox_on, 0.10);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: slightly softer background so checkbox reads clean
	var _toggle_bg		= make_color_rgb(28, 12, 40);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, col_checkbox_on, 0.08);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	// Dropdowns: darker than buttons, with strong hover glow (menus should feel "wet neon")
	var _dropdown_bg	= make_color_rgb(30, 12, 44);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, col_checkbox_on, 0.10);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	// Text input: focus is yuzu-green (feels like "charged ink"), invalid is hot red
	var _ti_bg			= make_color_rgb(22, 10, 34);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, col_checkbox_on, 0.18);
	
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.26);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_accent, 0.22);
	_ti_sel_bg			= merge_color(_ti_sel_bg, col_checkbox_on, 0.12);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: candy fill, yuzu knob, track is smoky violet
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.40);
	var _slider_fill	= col_accent;
	var _slider_knob	= col_checkbox_on;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (borders slightly dim so the UI isn't screaming 24/7)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (a richer plum that frames the UI like lacquer)
	header_styles._default	= { bg : make_color_rgb(34, 12, 46), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (minimize subtle, pin yuzu, close lipstick)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.12), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, col_checkbox_on, 0.06), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_checkbox_on, 0.10), border_hover : col_checkbox_on, text_hover : _btn_tx,
		pressed_mix : 0.32, bg_pressed : merge_color(_btn_bg, col_checkbox_on, 0.18),
		border_pressed : col_checkbox_on, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, col_error, 0.18), border : merge_color(col_error, col_panel_bg, 0.28), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, col_error, 0.30), border_hover : col_error, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, col_error, 0.44),
		border_pressed : col_error, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(col_error, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : col_checkbox_on, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(col_checkbox_on, col_text, 0.10), box_on_pressed : merge_color(col_checkbox_on, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : col_hover_row_alt,
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : col_muted_strong
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : col_checkbox_on, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : col_checkbox_on, caret_char : "|", caret_blink_ms : 490,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : col_muted_strong, placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (sweet lacquer + candy glass)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(26, 12, 34), col_accent, 0.18),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.16),
		border : _bd_dim,
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.16),
		border : _bd_dim,
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeArcadeWave()
/// @desc Retro arcade navy with bright cyan accents.
/// @return {Struct.EchoChamberThemeArcadeWave}
function EchoChamberThemeArcadeWave() : EchoChamberTheme() constructor {
	// Base palette (push toward "CRT arcade cabinet" instead of "standard navy")
	col_window_bg		= make_color_rgb(4, 6, 18);		// cabinet black-blue
	col_panel_bg		= make_color_rgb(12, 16, 34);		// deep arcade navy
	col_text			= make_color_rgb(226, 252, 255);	// cold phosphor white
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(64, 232, 255);	// electric cyan
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(122, 150, 172);	// steel-blue gray
	col_muted_strong	= make_color_rgb(168, 198, 222);	// bright UI hint
	col_error			= make_color_rgb(255, 70, 120);	// hot arcade red-pink
	
	col_hover_row		= make_color_rgb(16, 28, 64);		// scanline glow
	col_hover_row_alt	= make_color_rgb(22, 42, 88);		// selected: deeper glow
	
	col_menu_bg			= make_color_rgb(6, 10, 26);		// darker cabinet recess
	col_menu_hover		= make_color_rgb(18, 30, 66);		// hover pop
	
	col_label_hover_bg	= make_color_rgb(56, 18, 92);		// synth purple splash
	
	col_checkbox_off	= make_color_rgb(4, 6, 18);
	col_checkbox_on		= make_color_rgb(255, 66, 214);	// neon magenta (arcade pop)
	
	// Extra "arcade candy" colors (used in a few targeted places)
	var _coin_yellow	= make_color_rgb(255, 220, 70);
	var _glow_purple	= make_color_rgb(150, 80, 255);
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	var _btn_bg			= make_color_rgb(10, 18, 46);		// deep navy button
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, col_checkbox_on, 0.08);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	var _toggle_bg		= make_color_rgb(10, 16, 40);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, col_checkbox_on, 0.08);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	var _dropdown_bg	= make_color_rgb(8, 14, 36);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, col_checkbox_on, 0.10);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	var _ti_bg			= make_color_rgb(6, 12, 32);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, col_checkbox_on, 0.16);	// active focus goes magenta
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.26);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_accent, 0.22);
	_ti_sel_bg			= merge_color(_ti_sel_bg, col_checkbox_on, 0.10);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.42);
	var _slider_fill	= col_accent;				// cyan fill
	var _slider_knob	= col_checkbox_on;			// magenta knob
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (borders dimmed so the whole UI isn't screaming cyan)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (CRT top bezel vibe: slightly brighter + subtle purple tint)
	header_styles._default	= { bg : merge_color(make_color_rgb(10, 16, 40), _glow_purple, 0.10), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (give each one personality like an arcade cabinet)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.14), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, _coin_yellow, 0.10), border : merge_color(_coin_yellow, col_panel_bg, 0.35), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _coin_yellow, 0.22), border_hover : _coin_yellow, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _coin_yellow, 0.36),
		border_pressed : _coin_yellow, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_coin_yellow, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, col_error, 0.18), border : merge_color(col_error, col_panel_bg, 0.28), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, col_error, 0.30), border_hover : col_error, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, col_error, 0.44),
		border_pressed : col_error, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(col_error, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : col_checkbox_on, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(col_checkbox_on, col_text, 0.10), box_on_pressed : merge_color(col_checkbox_on, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : col_hover_row_alt,
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, col_accent, 0.18)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : col_checkbox_on, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : col_checkbox_on, caret_char : "|", caret_blink_ms : 480,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, col_accent, 0.22),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders (cyan fill, magenta knob, track feels like dim scanlines)
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (make them feel like "floating CRT glass")
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(8, 14, 36), _glow_purple, 0.14),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, _glow_purple, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, _coin_yellow, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeCircuitCandy()
/// @desc Playful teal and orange on a soft dark background.
/// @return {Struct.EchoChamberThemeCircuitCandy}
function EchoChamberThemeCircuitCandy() : EchoChamberTheme() constructor {
	// Base palette (aim for "sugar-coated circuit board" instead of "standard teal/orange")
	col_window_bg		= make_color_rgb(10, 14, 20);		// dark soda-can blue
	col_panel_bg		= make_color_rgb(18, 24, 30);		// soft graphite-teal
	col_text			= make_color_rgb(238, 252, 255);	// bright frosty text
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 154, 64);	// orange sherbet (main accent)
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(140, 168, 178);	// sea-glass gray
	col_muted_strong	= make_color_rgb(186, 214, 222);	// brighter hint text
	col_error			= make_color_rgb(255, 74, 90);		// punchy candy-red
	
	col_hover_row		= make_color_rgb(26, 36, 44);		// charcoal-teal hover
	col_hover_row_alt	= make_color_rgb(22, 54, 58);		// selected leans teal instead of just "slightly brighter"
	
	col_menu_bg			= make_color_rgb(12, 18, 24);		// darker dropdown well
	col_menu_hover		= make_color_rgb(30, 44, 52);		// hover pop
	
	// Make labels feel like "sticker candy" when hovered, not just another row hover
	col_label_hover_bg	= make_color_rgb(56, 24, 74);		// grape candy
	
	col_checkbox_off	= make_color_rgb(10, 14, 20);
	col_checkbox_on		= make_color_rgb(64, 255, 214);	// neon teal candy (surprising + fun)
	
	// Extra candy colors (used sparingly so the theme feels playful, not chaotic)
	var _candy_pink		= make_color_rgb(255, 92, 210);
	var _soda_purple	= make_color_rgb(160, 96, 255);
	var _acid_lime		= make_color_rgb(210, 255, 88);
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	// Buttons: dark base, orange hover, tiny teal + lime sparkle when pressed
	var _btn_bg			= make_color_rgb(22, 30, 36);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, col_checkbox_on, 0.08);
	_btn_bg_press		= merge_color(_btn_bg_press, _acid_lime, 0.04);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: softer background so checkbox reads clean
	var _toggle_bg		= make_color_rgb(16, 26, 30);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, col_checkbox_on, 0.10);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	// Dropdowns: more "hard candy" shine (hover feels like a glaze)
	var _dropdown_bg	= make_color_rgb(16, 22, 30);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, col_checkbox_on, 0.10);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	// Text input: focus is neon teal, selection has a candy-pink tint
	var _ti_bg			= make_color_rgb(12, 18, 26);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, col_checkbox_on, 0.18);
	
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.26);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_checkbox_on, 0.18);
	_ti_sel_bg			= merge_color(_ti_sel_bg, _candy_pink, 0.10);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: orange fill, neon teal knob, track is muted
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.42);
	var _slider_fill	= col_accent;
	var _slider_knob	= col_checkbox_on;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (borders dimmed so orange stays special)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (slight purple tint like a candy wrapper)
	header_styles._default	= { bg : merge_color(make_color_rgb(16, 22, 30), _soda_purple, 0.10), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (each one gets a "candy button" identity)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.14), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Pin: neon teal + a tiny lime zing (feels like "power" or "lock")
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, col_checkbox_on, 0.08), border : merge_color(col_checkbox_on, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, col_checkbox_on, 0.20), border_hover : col_checkbox_on, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(merge_color(_btn_bg, col_checkbox_on, 0.28), _acid_lime, 0.06),
		border_pressed : _acid_lime, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// Close: candy-pink warning instead of dull red
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, _candy_pink, 0.16), border : merge_color(_candy_pink, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _candy_pink, 0.30), border_hover : _candy_pink, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _candy_pink, 0.46),
		border_pressed : _candy_pink, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_candy_pink, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : col_checkbox_on, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(col_checkbox_on, col_text, 0.10), box_on_pressed : merge_color(col_checkbox_on, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(col_checkbox_on, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : col_hover_row_alt,
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, col_accent, 0.18)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : col_checkbox_on, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : col_checkbox_on, caret_char : "|", caret_blink_ms : 490,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, _soda_purple, 0.14),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (make them feel like "floating candy UI chips")
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(16, 22, 30), col_accent, 0.14),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, _soda_purple, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, col_checkbox_on, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeToxicTerminal()
/// @desc Acid terminal green with rogue magenta highlights.
/// @return {Struct.EchoChamberThemeToxicTerminal}
function EchoChamberThemeToxicTerminal() : EchoChamberTheme() constructor {
	// Base palette (go for "leaking reactor terminal" with a magenta glitch, not a standard green UI)
	col_window_bg		= make_color_rgb(2, 10, 10);		// blackened coolant
	col_panel_bg		= make_color_rgb(8, 20, 18);		// algae-teal sludge
	col_text			= make_color_rgb(210, 255, 218);	// phosphor green
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(150, 255, 110);	// toxic lime (primary accent)
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(106, 152, 126);	// dead fern
	col_muted_strong	= make_color_rgb(150, 190, 160);	// readable hints
	col_error			= make_color_rgb(255, 64, 140);	// dangerous magenta-red
	
	col_hover_row		= make_color_rgb(10, 34, 30);		// wet scanline
	col_hover_row_alt	= make_color_rgb(14, 50, 40);		// selected glow
	
	col_menu_bg			= make_color_rgb(4, 14, 14);		// deeper pit
	col_menu_hover		= make_color_rgb(10, 36, 32);		// hover pop
	
	// Make label hover feel like "glitch ink" rather than just another green rectangle
	col_label_hover_bg	= make_color_rgb(60, 10, 52);		// rogue magenta stain
	
	col_checkbox_off	= make_color_rgb(2, 10, 10);
	col_checkbox_on		= make_color_rgb(255, 64, 212);	// rogue magenta (the theme's personality)
	
	// Extra "toxic terminal" colors for spicy moments
	var _trace_cyan		= make_color_rgb(80, 255, 240);	// PCB trace glow
	var _hazard_yellow	= make_color_rgb(255, 230, 90);	// caution tape pop
	var _rogue_magenta	= col_checkbox_on;
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.42);
	
	// Buttons: sludge base, lime hover, magenta "glitch" on press
	var _btn_bg			= make_color_rgb(10, 26, 22);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _rogue_magenta, 0.10);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: calmer background so the checkbox reads clean
	var _toggle_bg		= make_color_rgb(8, 22, 20);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, _toggle_hover_mix);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, _rogue_magenta, 0.10);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	// Dropdowns: darker well, strong hover, and an obvious open state
	var _dropdown_bg	= make_color_rgb(6, 18, 18);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, _dropdown_hover_mix);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, _rogue_magenta, 0.10);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	// Text input: active focus goes rogue magenta, selection is cyan-glitch
	var _ti_bg			= make_color_rgb(4, 16, 16);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, _ti_hover_mix);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, _rogue_magenta, 0.16);
	
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.28);
	
	var _ti_sel_bg		= merge_color(_ti_bg, _trace_cyan, 0.22);
	_ti_sel_bg			= merge_color(_ti_sel_bg, _rogue_magenta, 0.06);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: lime fill, magenta knob, track is dim sludge
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.44);
	var _slider_fill	= col_accent;
	var _slider_knob	= _rogue_magenta;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, col_text, 0.08),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (borders dimmed so lime stays "dangerous" rather than constant)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (slightly different hue so it reads as "hardware bezel")
	header_styles._default	= { bg : make_color_rgb(6, 24, 22), border : _bd_dim, bg_alpha : 1 };
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (each gets its own "terminal hardware" vibe)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.14), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Pin: hazard yellow feels like a physical latch
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, _hazard_yellow, 0.10), border : merge_color(_hazard_yellow, col_panel_bg, 0.35), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _hazard_yellow, 0.22), border_hover : _hazard_yellow, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _hazard_yellow, 0.36),
		border_pressed : _hazard_yellow, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_hazard_yellow, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// Close: rogue magenta feels like "corruption", not a boring red X
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, _rogue_magenta, 0.18), border : merge_color(_rogue_magenta, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _rogue_magenta, 0.32), border_hover : _rogue_magenta, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _rogue_magenta, 0.48),
		border_pressed : _rogue_magenta, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_rogue_magenta, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : _rogue_magenta, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(_rogue_magenta, col_text, 0.10), box_on_pressed : merge_color(_rogue_magenta, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(_rogue_magenta, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.20,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : merge_color(col_hover_row_alt, _rogue_magenta, 0.10),
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, _rogue_magenta, 0.12)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : _rogue_magenta, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : _trace_cyan, caret_char : "|", caret_blink_ms : 470,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, col_accent, 0.12),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders (lime fill, magenta knob, track feels like dirty glass)
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (make them feel like toxic glass with a magenta glitch)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(6, 24, 22), _rogue_magenta, 0.10),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.12),
		border : merge_color(_bd_dim, _rogue_magenta, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, _rogue_magenta, 0.10),
		border : merge_color(_bd_dim, _trace_cyan, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeSunsetGlitch()
/// @desc Sunset oranges colliding with cyan and grape.
/// @return {Struct.EchoChamberThemeSunsetGlitch}
function EchoChamberThemeSunsetGlitch() : EchoChamberTheme() constructor {
	// Base palette (aim for "sunset heat + CRT cyan glitch + grape bruising")
	col_window_bg		= make_color_rgb(16, 8, 22);		// deep plum void
	col_panel_bg		= make_color_rgb(28, 16, 34);		// warm violet charcoal
	col_text			= make_color_rgb(255, 242, 226);	// sun-bleached paper
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 150, 70);	// sunset orange
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(190, 150, 160);	// dusty rose-gray
	col_muted_strong	= make_color_rgb(224, 176, 178);	// warmer hints
	col_error			= make_color_rgb(255, 72, 104);	// hot coral-red
	
	col_hover_row		= make_color_rgb(44, 20, 50);		// grape glow
	col_hover_row_alt	= make_color_rgb(66, 22, 74);		// selected: more neon grape
	
	col_menu_bg			= make_color_rgb(20, 10, 28);		// deeper plum
	col_menu_hover		= make_color_rgb(54, 18, 62);		// hover pop
	
	// Labels get a "glitch bruise" instead of more orange
	col_label_hover_bg	= make_color_rgb(22, 46, 72);		// cyan-infected shadow
	
	col_checkbox_off	= make_color_rgb(16, 8, 22);
	
	// Glitch colors (the "collision" part)
	var _glitch_cyan	= make_color_rgb(70, 245, 255);	// CRT cyan spike
	var _grape			= make_color_rgb(170, 84, 255);	// neon grape
	var _laser_pink		= make_color_rgb(255, 80, 210);	// punch pink
	var _acid_yellow	= make_color_rgb(255, 236, 92);	// brief "static" highlight
	
	col_checkbox_on		= _glitch_cyan;
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states (hover/pressed/disabled/etc)
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	// Buttons: warm base, orange hover, cyan press "glitch snap"
	var _btn_bg			= make_color_rgb(40, 18, 46);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _glitch_cyan, 0.12);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: grape base so the cyan checkbox feels like corruption leaking in
	var _toggle_bg		= make_color_rgb(34, 16, 42);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, _grape, 0.14);
	_toggle_bg_hover	= merge_color(_toggle_bg_hover, col_accent, 0.06);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, _glitch_cyan, 0.10);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	// Dropdowns: darker well, brighter hover, open state leans cyan
	var _dropdown_bg	= make_color_rgb(28, 14, 40);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, _grape, 0.16);
	_dropdown_bg_hover	= merge_color(_dropdown_bg_hover, col_accent, 0.08);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, _glitch_cyan, 0.12);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	// Text input: active focus goes cyan, selection mixes orange + cyan (like scrambled pixels)
	var _ti_bg			= make_color_rgb(22, 10, 32);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, _grape, 0.12);
	_ti_bg_hover		= merge_color(_ti_bg_hover, col_accent, 0.06);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, _glitch_cyan, 0.18);
	
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.28);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_accent, 0.20);
	_ti_sel_bg			= merge_color(_ti_sel_bg, _glitch_cyan, 0.16);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: orange fill, cyan knob, track feels like dim sunset haze
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.44);
	var _slider_fill	= col_accent;
	var _slider_knob	= _glitch_cyan;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, _glitch_cyan, 0.06),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (dim border so orange stays special)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (sunset band with a cyan crack running through it)
	header_styles._default	= {
		bg : merge_color(make_color_rgb(44, 18, 52), _glitch_cyan, 0.06),
		border : _bd_dim,
		bg_alpha : 1
	};
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (each has a distinct "glitch hardware" identity)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, _grape, 0.08), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, _grape, 0.10), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, _grape, 0.10),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, _glitch_cyan, 0.10), border : merge_color(_glitch_cyan, col_panel_bg, 0.32), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _glitch_cyan, 0.22), border_hover : _glitch_cyan, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(merge_color(_btn_bg, _glitch_cyan, 0.30), _acid_yellow, 0.06),
		border_pressed : _acid_yellow, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_glitch_cyan, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, _laser_pink, 0.16), border : merge_color(_laser_pink, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _laser_pink, 0.30), border_hover : _laser_pink, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _laser_pink, 0.46),
		border_pressed : _laser_pink, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_laser_pink, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : _glitch_cyan, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(_glitch_cyan, col_text, 0.10), box_on_pressed : merge_color(_glitch_cyan, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(_glitch_cyan, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.20,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : merge_color(col_hover_row_alt, _glitch_cyan, 0.08),
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, _grape, 0.14)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : _glitch_cyan, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : _glitch_cyan, caret_char : "|", caret_blink_ms : 475,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, col_accent, 0.10),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders (sunset fill, cyan knob, track is dim bruised violet)
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (floaty glass: warm base with cyan hairline fractures)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(34, 14, 44), _glitch_cyan, 0.06),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, _glitch_cyan, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, _grape, 0.10),
		border : merge_color(_bd_dim, col_accent, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeBubblegumTerminal()
/// @desc Bubblegum pink UI with teal statement nodes.
/// @return {Struct.EchoChamberThemeBubblegumTerminal}
function EchoChamberThemeBubblegumTerminal() : EchoChamberTheme() constructor {
	// Base palette (bubblegum glass + teal coolant)
	col_window_bg		= make_color_rgb(10, 12, 18);		// deep ink
	col_panel_bg		= make_color_rgb(18, 20, 30);		// soft midnight slate
	col_text			= make_color_rgb(246, 244, 252);	// frosted white
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 118, 206);	// bubblegum pink
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(176, 160, 196);	// lavender gray
	col_muted_strong	= make_color_rgb(214, 186, 226);	// cotton hint
	col_error			= make_color_rgb(255, 92, 128);	// strawberry alarm
	
	col_hover_row		= make_color_rgb(28, 22, 46);		// plum hover
	col_hover_row_alt	= make_color_rgb(40, 26, 64);		// brighter plum select
	
	col_menu_bg			= make_color_rgb(14, 14, 26);		// deeper well
	col_menu_hover		= make_color_rgb(34, 22, 56);		// candy hover
	
	// Make label hover feel like "bubblegum sticker" (not just another purple block)
	col_label_hover_bg	= make_color_rgb(70, 20, 58);		// sticky berry
	
	col_checkbox_off	= make_color_rgb(10, 12, 18);
	
	// Extra candy colors (the "teal terminal" part lives here)
	var _mint_teal		= make_color_rgb(80, 255, 232);	// mint neon
	var _aqua_teal		= make_color_rgb(70, 220, 255);	// brighter cyan-teal
	var _soda_purple	= make_color_rgb(170, 95, 255);	// grape fizz
	var _lemon_glow		= make_color_rgb(255, 238, 92);	// tiny sparkle highlight
	
	col_checkbox_on		= _mint_teal;
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	// Buttons: gum base, pink hover, teal snap on press
	var _btn_bg			= make_color_rgb(36, 22, 52);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _mint_teal, 0.10);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: calmer bg, checkbox is mint teal (reads like "coolant power")
	var _toggle_bg			= make_color_rgb(22, 18, 34);
	var _toggle_bd			= _bd_dim;
	var _toggle_tx			= _ink;
	var _toggle_hover_mix	= 0.13;
	var _toggle_press_mix	= 0.24;
	var _toggle_bg_hover	= merge_color(_toggle_bg, col_accent, 0.10);
	_toggle_bg_hover		= merge_color(_toggle_bg_hover, _mint_teal, 0.06);
	var _toggle_bg_press	= merge_color(_toggle_bg_hover, _mint_teal, 0.12);
	_toggle_bg_press		= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	
	var _toggle_bg_dis		= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis		= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis		= col_text_dim;
	
	// Dropdowns: darker well, hover feels like glossy candy, open leans teal
	var _dropdown_bg		= make_color_rgb(20, 18, 34);
	var _dropdown_bd		= _bd_dim;
	var _dropdown_tx		= _ink;
	var _dropdown_hover_mix	= 0.20;
	var _dropdown_press_mix	= 0.30;
	var _dropdown_bg_hover	= merge_color(_dropdown_bg, col_accent, 0.14);
	_dropdown_bg_hover		= merge_color(_dropdown_bg_hover, _aqua_teal, 0.06);
	var _dropdown_bg_press	= merge_color(_dropdown_bg_hover, _mint_teal, 0.12);
	_dropdown_bg_press		= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	
	var _dropdown_bg_dis	= merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis	= merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis	= col_text_dim;
	
	// Text input: active focus is teal, selection is candy-pink + teal mix, caret is mint
	var _ti_bg				= make_color_rgb(14, 14, 26);
	var _ti_bd				= _bd_dim;
	var _ti_tx				= col_text;
	var _ti_hover_mix		= 0.12;
	var _ti_press_mix		= 0.22;
	var _ti_bg_hover		= merge_color(_ti_bg, col_accent, 0.10);
	_ti_bg_hover			= merge_color(_ti_bg_hover, _aqua_teal, 0.06);
	var _ti_bg_press		= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active		= merge_color(_ti_bg, _mint_teal, 0.16);
	
	var _ti_bg_dis			= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis			= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis			= col_text_dim;
	
	var _ti_bg_ro			= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid		= merge_color(_ti_bg, col_error, 0.28);
	
	var _ti_sel_bg			= merge_color(_ti_bg, col_accent, 0.18);
	_ti_sel_bg				= merge_color(_ti_sel_bg, _mint_teal, 0.14);
	var _ti_sel_bg_inactive	= merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: pink fill, teal knob, track is dim plum
	var _slider_track		= merge_color(col_panel_bg, col_window_bg, 0.44);
	var _slider_fill		= col_accent;
	var _slider_knob		= _mint_teal;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, _mint_teal, 0.06),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (dim border so pink stays special)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (bubblegum glass with a faint teal fracture line)
	header_styles._default	= {
		bg		: merge_color(make_color_rgb(28, 20, 46), _aqua_teal, 0.06),
		border	: _bd_dim,
		bg_alpha : 1
	};
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (cute but still readable)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, col_window_bg, 0.14), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, col_window_bg, 0.08), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, col_window_bg, 0.08),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Pin: teal + tiny lemon sparkle (feels like "locked on")
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, _mint_teal, 0.08), border : merge_color(_mint_teal, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _mint_teal, 0.20), border_hover : _mint_teal, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(merge_color(_btn_bg, _mint_teal, 0.28), _lemon_glow, 0.06),
		border_pressed : _lemon_glow, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_mint_teal, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// Close: soda-purple instead of boring red (still distinct)
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, _soda_purple, 0.16), border : merge_color(_soda_purple, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _soda_purple, 0.30), border_hover : _soda_purple, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _soda_purple, 0.46),
		border_pressed : _soda_purple, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_soda_purple, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : _mint_teal, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(_mint_teal, col_text, 0.10), box_on_pressed : merge_color(_mint_teal, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(_mint_teal, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : merge_color(col_hover_row_alt, _mint_teal, 0.08),
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, _mint_teal, 0.12)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : _mint_teal, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : _mint_teal, caret_char : "|", caret_blink_ms : 485,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, col_accent, 0.10),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (bubblegum glass with teal edge-lighting)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(22, 18, 36), col_accent, 0.14),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.14),
		border : merge_color(_bd_dim, _mint_teal, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, _soda_purple, 0.08),
		border : merge_color(_bd_dim, _mint_teal, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
}

/// @func EchoChamberThemeMangoMint()
/// @desc Warm mango chrome with mint green graph.
/// @return {Struct.EchoChamberThemeMangoMint}
function EchoChamberThemeMangoMint() : EchoChamberTheme() constructor {
	// Base palette (mango chrome over dark coffee, with mint "signal glow")
	col_window_bg		= make_color_rgb(16, 10, 7);		// dark coffee
	col_panel_bg		= make_color_rgb(26, 18, 12);		// roasted bean
	col_text			= make_color_rgb(252, 242, 226);	// warm cream
	col_text_dim		= merge_color(col_text, col_panel_bg, 0.55);
	
	col_accent			= make_color_rgb(255, 182, 92);	// mango
	col_accent_dim		= merge_color(col_accent, col_panel_bg, 0.55);
	
	col_muted			= make_color_rgb(192, 166, 138);	// toasted sand
	col_muted_strong	= make_color_rgb(226, 194, 156);	// honey hint
	col_error			= make_color_rgb(255, 92, 78);		// hot guava
	
	// Mango theme "surprise": mint is the secondary power color
	var _mint			= make_color_rgb(92, 255, 190);	// mint glow
	var _aqua_mint		= make_color_rgb(84, 230, 220);	// cooler mint
	var _chrome_gold	= make_color_rgb(255, 232, 160);	// chrome highlight
	var _chili_red		= make_color_rgb(255, 64, 64);		// spicy close button
	
	col_checkbox_off	= make_color_rgb(16, 10, 7);
	col_checkbox_on		= _mint;
	
	// Hover/selection (make selection feel like "mint circuitry" on warm metal)
	col_hover_row		= merge_color(make_color_rgb(48, 30, 22), _aqua_mint, 0.06);
	col_hover_row_alt	= merge_color(make_color_rgb(56, 34, 24), _mint, 0.12);
	
	col_menu_bg			= make_color_rgb(20, 12, 8);
	col_menu_hover		= merge_color(make_color_rgb(34, 20, 14), _mint, 0.06);
	
	// Label hover should look like a chrome highlight, not just "brighter brown"
	col_label_hover_bg	= merge_color(make_color_rgb(56, 30, 18), _chrome_gold, 0.10);
	
	// -------------------------------------------------------------------------
	// Derived colors for richer interaction states
	var _ink			= col_text;
	
	var _bd_main		= col_accent;
	var _bd_dim			= merge_color(col_accent, col_panel_bg, 0.40);
	
	// Buttons: bronze base, mango hover, mint snap on press (like a signal spike)
	var _btn_bg			= make_color_rgb(44, 26, 18);
	var _btn_bd			= _bd_dim;
	var _btn_tx			= _ink;
	var _btn_hover_mix	= 0.18;
	var _btn_press_mix	= 0.30;
	var _btn_bg_hover	= merge_color(_btn_bg, col_accent, _btn_hover_mix);
	var _btn_bg_press	= merge_color(_btn_bg_hover, _mint, 0.10);
	_btn_bg_press		= merge_color(_btn_bg_press, _btn_tx, _btn_press_mix);
	
	var _btn_bg_dis		= merge_color(_btn_bg, col_panel_bg, 0.64);
	var _btn_bd_dis		= merge_color(_btn_bd, col_panel_bg, 0.64);
	var _btn_tx_dis		= col_text_dim;
	
	// Toggles: calmer base so the mint checkbox reads clearly
	var _toggle_bg		= make_color_rgb(30, 20, 14);
	var _toggle_bd		= _bd_dim;
	var _toggle_tx		= _ink;
	var _toggle_hover_mix = 0.13;
	var _toggle_press_mix = 0.24;
	var _toggle_bg_hover = merge_color(_toggle_bg, col_accent, 0.10);
	_toggle_bg_hover	= merge_color(_toggle_bg_hover, _mint, 0.06);
	var _toggle_bg_press = merge_color(_toggle_bg_hover, _mint, 0.12);
	_toggle_bg_press	= merge_color(_toggle_bg_press, _toggle_tx, _toggle_press_mix);
	
	var _toggle_bg_dis	= merge_color(_toggle_bg, col_panel_bg, 0.64);
	var _toggle_bd_dis	= merge_color(_toggle_bd, col_panel_bg, 0.64);
	var _toggle_tx_dis	= col_text_dim;
	
	// Dropdowns: darker well, glossy hover, open state leans mint
	var _dropdown_bg	= make_color_rgb(26, 18, 12);
	var _dropdown_bd	= _bd_dim;
	var _dropdown_tx	= _ink;
	var _dropdown_hover_mix = 0.20;
	var _dropdown_press_mix = 0.30;
	var _dropdown_bg_hover = merge_color(_dropdown_bg, col_accent, 0.14);
	_dropdown_bg_hover	= merge_color(_dropdown_bg_hover, _aqua_mint, 0.06);
	var _dropdown_bg_press = merge_color(_dropdown_bg_hover, _mint, 0.12);
	_dropdown_bg_press	= merge_color(_dropdown_bg_press, _dropdown_tx, _dropdown_press_mix);
	
	var _dropdown_bg_dis = merge_color(_dropdown_bg, col_panel_bg, 0.64);
	var _dropdown_bd_dis = merge_color(_dropdown_bd, col_panel_bg, 0.64);
	var _dropdown_tx_dis = col_text_dim;
	
	// Text input: active focus is mint, selection mixes mango + mint (like a glowing trace)
	var _ti_bg			= make_color_rgb(22, 16, 12);
	var _ti_bd			= _bd_dim;
	var _ti_tx			= col_text;
	var _ti_hover_mix	= 0.12;
	var _ti_press_mix	= 0.22;
	var _ti_bg_hover	= merge_color(_ti_bg, col_accent, 0.10);
	_ti_bg_hover		= merge_color(_ti_bg_hover, _aqua_mint, 0.06);
	var _ti_bg_press	= merge_color(_ti_bg_hover, _ti_tx, _ti_press_mix);
	var _ti_bg_active	= merge_color(_ti_bg, _mint, 0.16);
	
	var _ti_bg_dis		= merge_color(_ti_bg, col_panel_bg, 0.64);
	var _ti_bd_dis		= merge_color(_ti_bd, col_panel_bg, 0.64);
	var _ti_tx_dis		= col_text_dim;
	
	var _ti_bg_ro		= merge_color(_ti_bg, col_panel_bg, 0.12);
	var _ti_bg_invalid	= merge_color(_ti_bg, col_error, 0.28);
	
	var _ti_sel_bg		= merge_color(_ti_bg, col_accent, 0.18);
	_ti_sel_bg			= merge_color(_ti_sel_bg, _mint, 0.14);
	var _ti_sel_bg_inactive = merge_color(_ti_sel_bg, _ti_bg, 0.55);
	
	// Sliders: mango fill, mint knob, track is dark cocoa glass
	var _slider_track	= merge_color(col_panel_bg, col_window_bg, 0.44);
	var _slider_fill	= col_accent;
	var _slider_knob	= _mint;
	
	// -------------------------------------------------------------------------
	// List rows (full set, including disabled)
	list_row_styles = {
		_default : {
			bg_normal		: col_panel_bg,
			bg_hover		: col_hover_row,
			bg_selected		: col_hover_row_alt,
			bg_pressed		: merge_color(col_hover_row, _mint, 0.06),
			text_normal		: col_text,
			text_hover		: col_text,
			text_selected	: col_text,
			text_pressed	: col_text,
			bg_disabled		: merge_color(col_panel_bg, col_window_bg, 0.35),
			text_disabled	: col_text_dim
		}
	};

	// -------------------------------------------------------------------------
	// Panels and windows (dim border so mango feels like "chrome trim", not a constant neon tube)
	panel_styles._default	= { bg : col_panel_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.menu		= { bg : col_menu_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };
	panel_styles.overlay	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1, border_alpha : 1 };

	window_styles._default	= { bg : col_window_bg, border : _bd_dim, bg_alpha : 1 };
	
	// Header bar (a warmer band with a faint chrome highlight)
	header_styles._default	= {
		bg		: merge_color(make_color_rgb(42, 26, 18), _chrome_gold, 0.08),
		border	: _bd_dim,
		bg_alpha : 1
	};
	
	// -------------------------------------------------------------------------
	// Buttons (full interaction set)
	button_styles._default = {
		bg : _btn_bg, border : _btn_bd, text : _btn_tx, bg_alpha : 0.95, align : "center",
		bg_hover : _btn_bg_hover, border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : _btn_bg_press,
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Window chrome buttons (each has a "hardware" identity)
	button_styles.__window_minimize = {
		bg : merge_color(_btn_bg, _chrome_gold, 0.06), border : _btn_bd, text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg_hover, _chrome_gold, 0.06), border_hover : _bd_main, text_hover : _btn_tx,
		pressed_mix : _btn_press_mix, bg_pressed : merge_color(_btn_bg_press, _chrome_gold, 0.04),
		border_pressed : _bd_main, text_pressed : _btn_tx,
		bg_disabled : _btn_bg_dis, border_disabled : _btn_bd_dis, text_disabled : _btn_tx_dis
	};
	
	// Pin: mint latch with a chrome sparkle
	button_styles.__window_pin = {
		bg : merge_color(_btn_bg, _mint, 0.08), border : merge_color(_mint, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _mint, 0.20), border_hover : _mint, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(merge_color(_btn_bg, _mint, 0.28), _chrome_gold, 0.06),
		border_pressed : _chrome_gold, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_mint, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// Close: chili red (distinct, spicy, still fits warm palette)
	button_styles.__window_close = {
		bg : merge_color(_btn_bg, _chili_red, 0.14), border : merge_color(_chili_red, col_panel_bg, 0.30), text : _btn_tx, bg_alpha : 1, align : "center",
		bg_hover : merge_color(_btn_bg, _chili_red, 0.30), border_hover : _chili_red, text_hover : _btn_tx,
		pressed_mix : 0.34, bg_pressed : merge_color(_btn_bg, _chili_red, 0.46),
		border_pressed : _chili_red, text_pressed : _btn_tx,
		bg_disabled : merge_color(_btn_bg, col_panel_bg, 0.70), border_disabled : merge_color(_chili_red, col_panel_bg, 0.70), text_disabled : _btn_tx_dis
	};
	
	// -------------------------------------------------------------------------
	// Toggles (full checkbox knobs + disabled)
	toggle_styles._default = {
		bg : _toggle_bg, border : _toggle_bd, text : _toggle_tx, bg_alpha : 0.9,
		bg_hover : _toggle_bg_hover, border_hover : _bd_main, text_hover : _toggle_tx,
		pressed_mix : _toggle_press_mix, bg_pressed : _toggle_bg_press,
		border_pressed : _bd_main, text_pressed : _toggle_tx,
		
		bg_disabled : _toggle_bg_dis, border_disabled : _toggle_bd_dis, text_disabled : _toggle_tx_dis,
		
		box_on : _mint, box_off : col_checkbox_off,
		box_border : _toggle_bd, box_border_hover : _bd_main, box_border_pressed : _bd_main,
		box_on_hover : merge_color(_mint, col_text, 0.10), box_on_pressed : merge_color(_mint, col_text, 0.18),
		box_off_hover : merge_color(col_checkbox_off, col_text, 0.10), box_off_pressed : merge_color(col_checkbox_off, col_text, 0.18),
		box_on_disabled : merge_color(_mint, col_panel_bg, 0.64),
		box_off_disabled : merge_color(col_checkbox_off, col_panel_bg, 0.64),
		box_border_disabled : merge_color(_toggle_bd, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Dropdowns (including overlay/search colors)
	dropdown_styles._default = {
		bg : _dropdown_bg, border : _dropdown_bd, text : _dropdown_tx, bg_alpha : 0.9, align : "center",
		bg_hover : _dropdown_bg_hover, border_hover : _bd_main, text_hover : _dropdown_tx,
		pressed_mix : _dropdown_press_mix, bg_pressed : _dropdown_bg_press,
		border_pressed : _bd_main, text_pressed : _dropdown_tx, open_mix : 0.18,
		bg_disabled : _dropdown_bg_dis, border_disabled : _dropdown_bd_dis, text_disabled : _dropdown_tx_dis,
		
		overlay_bg : col_window_bg, overlay_border : _bd_dim, overlay_bg_alpha : 0.97,
		overlay_row_bg : col_panel_bg,
		overlay_row_hover : col_hover_row,
		overlay_row_selected : merge_color(col_hover_row_alt, _mint, 0.08),
		overlay_row_pressed : merge_color(col_hover_row, col_text, 0.08),
		
		overlay_text : col_text,
		overlay_text_hover : col_text,
		overlay_text_selected : col_text,
		overlay_text_pressed : col_text,
		
		overlay_search_bg : merge_color(col_panel_bg, col_window_bg, 0.10),
		overlay_search_border : _bd_dim,
		overlay_search_hover_bg : merge_color(col_panel_bg, col_text, 0.16),
		overlay_search_text : col_text,
		overlay_search_placeholder : merge_color(col_muted_strong, _mint, 0.12)
	};
	
	// -------------------------------------------------------------------------
	// Text inputs (active/readonly/invalid/selection/caret)
	textinput_styles._default = {
		bg : _ti_bg, border : _ti_bd, text : _ti_tx, bg_alpha : 0.95, align : "left",
		bg_hover : _ti_bg_hover, border_hover : _bd_main, text_hover : _ti_tx,
		pressed_mix : _ti_press_mix, bg_pressed : _ti_bg_press,
		border_pressed : _bd_main, text_pressed : _ti_tx,
		
		bg_active : _ti_bg_active, border_active : _mint, text_active : _ti_tx,
		
		bg_disabled : _ti_bg_dis, border_disabled : _ti_bd_dis, text_disabled : _ti_tx_dis,
		
		bg_readonly : _ti_bg_ro, border_readonly : _ti_bd, text_readonly : _ti_tx,
		
		bg_invalid : _ti_bg_invalid, border_invalid : col_error, text_invalid : _ti_tx,
		
		selection_bg : _ti_sel_bg, selection_text : _ti_tx,
		selection_bg_inactive : _ti_sel_bg_inactive, selection_text_inactive : _ti_tx,
		
		caret_color : _mint, caret_char : "|", caret_blink_ms : 490,
		caret_width : 1, caret_height : 0,
		caret_inset_x : 0, caret_inset_y : 0,
		
		placeholder : merge_color(col_muted_strong, col_accent, 0.10),
		placeholder_alpha : 0.58
	};
	
	// -------------------------------------------------------------------------
	// Sliders
	slider_styles._default = {
		track_bg : _slider_track,
		track_fill : _slider_fill,
		knob : _slider_knob,
		
		track_bg_hover : merge_color(_slider_track, col_text, 0.12),
		track_fill_hover : merge_color(_slider_fill, col_text, 0.12),
		knob_hover : merge_color(_slider_knob, col_text, 0.10),
		
		track_bg_pressed : merge_color(_slider_track, col_text, 0.16),
		track_fill_pressed : merge_color(_slider_fill, col_text, 0.16),
		knob_pressed : merge_color(_slider_knob, col_text, 0.16),
		
		track_bg_disabled : merge_color(_slider_track, col_panel_bg, 0.42),
		track_fill_disabled : merge_color(_slider_fill, col_panel_bg, 0.64),
		knob_disabled : merge_color(_slider_knob, col_panel_bg, 0.64)
	};
	
	// -------------------------------------------------------------------------
	// Popups, tooltips, toasts (warm glass with mint edge-lighting)
	popup_styles._default = {
		bg : col_window_bg,
		border : _bd_dim,
		bg_alpha : 1,
		header_bg : merge_color(make_color_rgb(34, 22, 16), col_accent, 0.14),
		header_alpha : 1
	};
	
	tooltip_styles._default = {
		bg : merge_color(col_menu_bg, col_accent, 0.12),
		border : merge_color(_bd_dim, _mint, 0.10),
		bg_alpha : 0.92,
		text : col_text
	};
	
	toast_styles._default = {
		bg : merge_color(col_menu_bg, _mint, 0.06),
		border : merge_color(_bd_dim, col_accent, 0.12),
		bg_alpha : 0.92,
		text : col_text
	};
}

