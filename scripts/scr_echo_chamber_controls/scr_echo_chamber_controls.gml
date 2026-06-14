/// @func EchoChamberControlBase(_id)
/// @desc Base type for all debug UI controls.
/// @param {Any} _id
/// @return {Struct.EchoChamberControlBase}
function EchoChamberControlBase(_id) constructor {
	id       = string(_id);
	label    = "";
	tooltip  = "";
	style_id = "_default";
	visible  = true;
	enabled  = true;
	preferred_width = -1;
	preferred_height = -1;
	fill_width = false;
	padding_x = -1;
	padding_y = -1;
	margin_x  = -1;
	margin_y  = -1;
	field_label = "";
	field_label_placement = eEchoChamberFieldLabelPlacement.AUTO;
	field_label_style_id = "_default";
	field_label_gap = -1;
	field_label_width = -1;
	field_label_align = "auto";
	field_label_enabled = true;

	owner_root   = undefined;
	owner_window = undefined;
	owner_panel  = undefined;

	/// @desc Get the owning root for this control (if attached).
	/// @return {Struct.EchoChamberRoot}
	static GetRoot = function() {
		return owner_root;
	};

	/// @desc Get the owning window for this control (if attached).
	/// @return {Struct.EchoChamberWindow}
	static GetWindow = function() {
		return owner_window;
	};

	/// @desc Get the owning panel for this control (if attached).
	/// @return {Struct.EchoChamberPanel}
	static GetPanel = function() {
		return owner_panel;
	};

	/// @desc Set a preferred pixel width for this control when arranged in a row panel.
	/// @param {Real} _width
	static SetPreferredWidth = function(_width) {
		preferred_width = max(0, _width);
		return self;
	};

	/// @desc Set a preferred pixel height for this control.
	/// @param {Real} _height
	/// @return {Struct.EchoChamberControlBase}
	static SetPreferredHeight = function(_height) {
		preferred_height = max(0, _height);
		return self;
	};

	/// @desc Set whether this control fills the available row width.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberControlBase}
	static SetFillWidth = function(_flag) {
		fill_width = (_flag == true);
		return self;
	};

	/// @desc Set inner padding for this control.
	/// @param {Real} _x
	/// @param {Real} [_y]
	/// @return {Struct.EchoChamberControlBase}
	static SetPadding = function(_x, _y = undefined) {
		padding_x = max(0, _x);
		padding_y = max(0, _y ?? _x);
		return self;
	};

	/// @desc Set outer margin for this control.
	/// @param {Real} _x
	/// @param {Real} [_y]
	/// @return {Struct.EchoChamberControlBase}
	static SetMargin = function(_x, _y = undefined) {
		margin_x = max(0, _x);
		margin_y = max(0, _y ?? _x);
		return self;
	};

	/// @desc Set the control's caption label (drawn by controls that have built-in captions).
	/// @param {Any} _text
	/// @return {Struct.EchoChamberControlBase}
	static SetLabel = function(_text) {
		label = string(_text);
		return self;
	};

	/// @desc Set the control's caption label (alias of SetLabel).
	/// @param {Any} _text
	/// @return {Struct.EchoChamberControlBase}
	static SetCaption = function(_text) {
		label = string(_text);
		return self;
	};

	/// @desc Set the panel-drawn field label text for this control.
	/// @param {Any} _text
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabel = function(_text) {
		field_label = string(_text);
		if (string_length(field_label) > 0) {
			field_label_enabled = true;
		}
		return self;
	};

	/// @desc Set where this control's field label is drawn.
	/// @param {eEchoChamberFieldLabelPlacement} _placement
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelPlacement = function(_placement) {
		switch (_placement) {
			case eEchoChamberFieldLabelPlacement.LEADING:
			case eEchoChamberFieldLabelPlacement.ABOVE:
			case eEchoChamberFieldLabelPlacement.NONE:
				//case eEchoChamberFieldLabelPlacement.TRAILING:
				//case eEchoChamberFieldLabelPlacement.BELOW:
				field_label_placement = _placement;
			break;

			default:
				field_label_placement = eEchoChamberFieldLabelPlacement.AUTO;
			break;
		}
		return self;
	};

	/// @desc Set field label spacing from the control body in pixels (-1 uses panel/theme defaults).
	/// @param {Real} _px
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelGap = function(_px) {
		if (_px < 0) {
			field_label_gap = -1;
		}
		else {
			field_label_gap = max(0, _px);
		}
		return self;
	};

	/// @desc Set field label width in pixels for leading labels (-1 uses panel/theme defaults).
	/// @param {Real} _px
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelWidth = function(_px) {
		if (_px < 0) {
			field_label_width = -1;
		}
		else {
			field_label_width = max(0, _px);
		}
		return self;
	};

	/// @desc Set field label text style key (looked up in theme.label_styles).
	/// @param {Any} _style_id
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelStyleKey = function(_style_id) {
		field_label_style_id = string(_style_id);
		return self;
	};

	/// @desc Set field label alignment ("left", "center", "right", or "auto").
	/// @param {Any} _align
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelAlign = function(_align) {
		var _v = string_lower(string(_align));
		if (_v != "left" && _v != "center" && _v != "right") {
			_v = "auto";
		}
		field_label_align = _v;
		return self;
	};

	/// @desc Enable or disable panel-drawn field labels for this control.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberControlBase}
	static SetFieldLabelEnabled = function(_flag) {
		field_label_enabled = (_flag == true);
		return self;
	};

	/// @desc Set the control tooltip (shown on hover where supported).
	/// @param {Any} _text
	/// @return {Struct.EchoChamberControlBase}
	static SetTooltip = function(_text) {
		tooltip = string(_text);
		return self;
	};

	/// @desc Set the theme style key for this control (e.g. button/toggle/dropdown styles).
	/// @param {Any} _style
	/// @return {Struct.EchoChamberControlBase}
	static SetControlStyleKey = function(_style) {
		style_id = string(_style);
		return self;
	};

	/// @desc Show or hide this control.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberControlBase}
	static SetVisible = function(_flag) {
		visible = (_flag == true);
		return self;
	};

	/// @desc Enable or disable this control (disabled controls should not accept input).
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberControlBase}
	static SetEnabled = function(_flag) {
		enabled = (_flag == true);
		return self;
	};

	/// @desc Override: process input and draw using the given rect.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		// abstract base
	};

	/// @ignore
	/// @desc Internal: return the natural content size for this control (used for auto width when preferred_width is not set).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _row_h
	/// @return {Struct,Undefined} { w, h } or undefined when not measurable
	static __GetContentSize = function(_root, _panel, _row_h) {
		return undefined;
	};

	/// @ignore
	/// @desc Internal: resolve padding X using local override or theme defaults.
	/// @param {Struct.EchoChamberRoot} _root
	/// @return {Real}
	static __ResolvePaddingX = function(_root) {
		var _pad = padding_x;
		if (_pad < 0) {
			_pad = _root.default_control_padding_x;
		}
		return max(0, _pad);
	};

	/// @ignore
	/// @desc Internal: resolve padding Y using local override or theme defaults.
	/// @param {Struct.EchoChamberRoot} _root
	/// @return {Real}
	static __ResolvePaddingY = function(_root) {
		var _pad = padding_y;
		if (_pad < 0) {
			_pad = _root.default_control_padding_y;
		}
		return max(0, _pad);
	};
}

/// @func EchoChamberLabel(_id)
/// @desc Non-interactive text label.
/// @param {Any} _id
/// @return {Struct.EchoChamberLabel}
function EchoChamberLabel(_id) : EchoChamberControlBase(_id) constructor {
	text      = "";
	align     = "left";   // "left"/"center"/"right"
	use_small = false;    // use font_small instead of font_body
	bind_text_struct = undefined;
	bind_text_key    = "";
	bind_text_fn     = undefined;

	/// @desc Set the label text.
	/// @param {Any} _text
	/// @return {Struct.EchoChamberLabel}
	static SetText = function(_text) {
		text = string(_text);
		return self;
	};

	/// @desc Bind the label text to a struct field or getter function.
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberLabel}
	static BindText = function(_source, _key_or_fn = undefined) {
		if (is_callable(_source)) {
			bind_text_fn = _source;
			bind_text_struct = undefined;
			bind_text_key = "";
			return self;
		}
		else if (is_struct(_source)) {
			bind_text_struct = _source;
			bind_text_key = is_undefined(_key_or_fn) ? "" : string(_key_or_fn);
			bind_text_fn = undefined;
		}
		return self;
	};

	/// @desc Set text alignment ("left", "center", or "right").
	/// @param {String} _align
	/// @return {Struct.EchoChamberLabel}
	static SetAlign = function(_align) {
		align = _align;
		return self;
	};

	/// @desc Switch between the body font and small font.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberLabel}
	static UseSmallFont = function(_flag) {
		use_small = _flag;
		return self;
	};

	/// @ignore
	/// @desc Internal: return the current bound text.
	/// @return {String}
	static __GetBoundText = function() {
		var _value = undefined;
		if (is_callable(bind_text_fn)) {
			_value = bind_text_fn();
		}
		else if (bind_text_key != "") {
			_value = bind_text_struct[$ bind_text_key];
		}
		if (!is_undefined(_value)) {
			text = string(_value);
		}
		return text;
	};

	/// @ignore
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (!is_struct(_root) || !is_struct(_root.theme)) {
			return undefined;
		}
		var _styles = _root.theme.label_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];
		var _font = _st[$ "font"];
		if (is_undefined(_font)) {
			_font = use_small ? _root.theme.font_small : _root.theme.font_body;
		}
		var _s = __GetBoundText();
		var _pad_x = __ResolvePaddingX(_root);
		var _w = _root.__MeasureTextWidth(_s, _font) + (_pad_x * 2);
		return { w: _w, h: _row_h };
	};

	/// @desc Draw the label within the given rect.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _width  = _x2 - _x1;
		var _height = _y2 - _y1;

		var _styles = _root.theme.label_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];
		var _font = _st[$ "font"];
		if (is_undefined(_font)) {
			_font = use_small ? _root.theme.font_small : _root.theme.font_body;
		}

		var _old_font = draw_get_font();
		draw_set_font(_font);
		var _tx_col = _st[$ "text"] ?? _root.theme.col_text;
		var _tx_alpha = _st[$ "text_alpha"] ?? 1;
		var _tx_disabled = _st[$ "text_disabled"] ?? _root.theme.col_text_dim;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha;
		if (!enabled) {
			_tx_col = _tx_disabled;
			_tx_alpha = _tx_disabled_alpha;
		}
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_tx_alpha);
		draw_set_color(_tx_col);

		var _text_str = __GetBoundText();
		var _max_w = max(0, _width);
		var _draw_str;

		_draw_str = __TrimTextToWidth(_text_str, _max_w, _font);

		var _text_h = string_height(_draw_str);
		var _ty = _y1 + (_height - _text_h) * 0.5;

		var _tx;
		var _pad_x = __ResolvePaddingX(_root);
		if (align == "right") {
			_tx = _x2 - _pad_x - string_width(_draw_str);
		}
		else if (align == "center") {
			_tx = _x1 + (_width - string_width(_draw_str)) * 0.5;
		}
		else {
			_tx = _x1 + _pad_x;
		}

		draw_text(_tx, _ty, _draw_str);
		draw_set_alpha(_old_alpha);
		draw_set_font(_old_font);
	};
}

/// @func EchoChamberTextBox(_id)
/// @desc Non-interactive text box that wraps text to its width.
/// @param {Any} _id
/// @return {Struct.EchoChamberTextBox}
function EchoChamberTextBox(_id) : EchoChamberControlBase(_id) constructor {
	text        = "";
	align       = "left";  // "left"/"center"/"right"
	use_small   = false;
	padding_x   = -1;
	padding_y   = -1;
	fill_width  = true;
	bind_text_struct = undefined;
	bind_text_key    = "";
	bind_text_fn     = undefined;
	__wrap_cache_text = "";
	__wrap_cache_w    = -1;
	__wrap_cache_font = -1;
	__wrap_cache_lines = [];

	/// @desc Set the text content for this box.
	/// @param {Any} _text
	/// @return {Struct.EchoChamberTextBox}
	static SetText = function(_text) {
		text = string(_text);
		return self;
	};

	/// @desc Bind the text content to a struct field or getter function.
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberTextBox}
	static BindText = function(_source, _key_or_fn = undefined) {
		if (is_callable(_source)) {
			bind_text_fn = _source;
			bind_text_struct = undefined;
			bind_text_key = "";
			return self;
		}
		else if (is_struct(_source)) {
			bind_text_struct = _source;
			bind_text_key = is_undefined(_key_or_fn) ? "" : string(_key_or_fn);
			bind_text_fn = undefined;
		}
		return self;
	};

	/// @desc Set text alignment ("left", "center", "right").
	/// @param {String} _align
	/// @return {Struct.EchoChamberTextBox}
	static SetAlign = function(_align) {
		align = string(_align);
		return self;
	};

	/// @desc Use the smaller theme font for this box.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextBox}
	static UseSmallFont = function(_flag) {
		use_small = (_flag == true);
		return self;
	};

	/// @desc Set inner padding for the text box.
	/// @param {Real} _x
	/// @param {Real} [_y]
	/// @return {Struct.EchoChamberTextBox}
	static SetPadding = function(_x, _y = undefined) {
		padding_x = max(0, _x);
		padding_y = max(0, _y ?? _x);
		return self;
	};

	/// @desc Set whether this box fills the available row width.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextBox}
	static SetFillWidth = function(_flag) {
		fill_width = (_flag == true);
		return self;
	};

	/// @ignore
	/// @desc Internal: return the current bound text.
	/// @return {String}
	static __GetBoundText = function() {
		var _value = undefined;
		if (is_callable(bind_text_fn)) {
			_value = bind_text_fn();
		}
		else if (bind_text_key != "") {
			_value = bind_text_struct[$ bind_text_key];
		}
		if (!is_undefined(_value)) {
			text = string(_value);
		}
		return text;
	};

	/// @ignore
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return undefined;
		}
		var _s = __GetBoundText();
		var _font = use_small ? _root.theme.font_small : _root.theme.font_body;
		var _old = draw_get_font();
		draw_set_font(_font);
		var _segments = [];
		var _cur = "";
		var _len = string_length(_s);
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_s, _i);
			if (_ch == "\n") {
				array_push(_segments, _cur);
				_cur = "";
			}
			else {
				_cur += _ch;
			}
		}
		array_push(_segments, _cur);
		var _max_w = 0;
		var _seg_len = array_length(_segments);
		for (var _j = 0; _j < _seg_len; _j++) {
			var _w = string_width(string(_segments[_j]));
			if (_w > _max_w) _max_w = _w;
		}
		draw_set_font(_old);
		var _px = __ResolvePaddingX(_root);
		var _py = __ResolvePaddingY(_root);
		var _h = max(_row_h, (string_height("Ag") + (_py * 2)));
		draw_set_font(_old);
		return { w: _max_w + (_px * 2), h: _h };
	};

	/// @ignore
	static __WrapTextLines = function(_text, _max_w, _font) {
		var _old = draw_get_font();
		draw_set_font(_font);

		var _lines = [];
		var _s = string(_text);
		var _segments = [];
		var _cur = "";
		var _len = string_length(_s);
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_s, _i);
			if (_ch == "\n") {
				array_push(_segments, _cur);
				_cur = "";
			}
			else {
				_cur += _ch;
			}
		}
		array_push(_segments, _cur);

		var _seg_len = array_length(_segments);
		for (var _si = 0; _si < _seg_len; _si++) {
			var _seg = string(_segments[_si]);
			var _words = [];
			var _tok = "";
			var _l2 = string_length(_seg);
			for (var _j = 1; _j <= _l2; _j++) {
				var _ch2 = string_char_at(_seg, _j);
				if (_ch2 == " " || _ch2 == "\t") {
					if (_tok != "") {
						array_push(_words, _tok);
						_tok = "";
					}
				}
				else {
					_tok += _ch2;
				}
			}
			if (_tok != "") array_push(_words, _tok);

			if (array_length(_words) <= 0) {
				array_push(_lines, "");
				continue;
			}

			var _line = "";
			var _wlen = array_length(_words);
			for (var _wi = 0; _wi < _wlen; _wi++) {
				var _w = string(_words[_wi]);
				var _test = (_line == "") ? _w : (_line + " " + _w);
				if (string_width(_test) <= _max_w) {
					_line = _test;
				}
				else {
					if (_line != "") {
						array_push(_lines, _line);
						_line = _w;
					}
					else {
						array_push(_lines, __TrimTextToWidth(_w, _max_w, _font));
						_line = "";
					}
				}
			}
			if (_line != "") array_push(_lines, _line);
		}

		draw_set_font(_old);
		return _lines;
	};

	/// @ignore
	static __GetDesiredHeightForWidth = function(_root, _panel, _width) {
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return undefined;
		}
		var _font = use_small ? _root.theme.font_small : _root.theme.font_body;
		var _px = __ResolvePaddingX(_root);
		var _py = __ResolvePaddingY(_root);
		var _inner_w = max(0, _width - (_px * 2));
		if (_inner_w <= 0) {
			return string_height("Ag") + (_py * 2);
		}

		var _current_text = __GetBoundText();
		var _cache_hit = (_current_text == __wrap_cache_text && _inner_w == __wrap_cache_w && _font == __wrap_cache_font);
		if (!_cache_hit) {
			__wrap_cache_text = _current_text;
			__wrap_cache_w = _inner_w;
			__wrap_cache_font = _font;
			__wrap_cache_lines = __WrapTextLines(_current_text, _inner_w, _font);
		}

		var _old = draw_get_font();
		draw_set_font(_font);
		var _line_h = string_height("Ag");
		draw_set_font(_old);
		return max(_line_h, array_length(__wrap_cache_lines) * _line_h) + (_py * 2);
	};

	/// @desc Draw the text box.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _styles = _root.theme.textinput_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_col = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_col = _st[$ "border"] ?? _root.theme.col_accent;
		var _tx_col = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha = _st[$ "bg_alpha"] ?? 0.9;
		var _bd_alpha = _st[$ "border_alpha"] ?? 1;
		var _tx_alpha = _st[$ "text_alpha"] ?? 1;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_col;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_col;
		var _tx_disabled = _st[$ "text_disabled"] ?? _tx_col;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha;

		if (!enabled) {
			_bg_col = _bg_disabled;
			_bd_col = _bd_disabled;
			_tx_col = _tx_disabled;
			_bg_alpha = _bg_disabled_alpha;
			_bd_alpha = _bd_disabled_alpha;
			_tx_alpha = _tx_disabled_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		var _font = use_small ? _root.theme.font_small : _root.theme.font_body;
		var _px = __ResolvePaddingX(_root);
		var _py = __ResolvePaddingY(_root);
		var _inner_w = max(0, (_x2 - _x1) - (_px * 2));
		var _inner_h = max(0, (_y2 - _y1) - (_py * 2));

		if (_inner_w <= 0 || _inner_h <= 0) return;

		var _current_text = __GetBoundText();
		var _cache_hit = (_current_text == __wrap_cache_text && _inner_w == __wrap_cache_w && _font == __wrap_cache_font);
		if (!_cache_hit) {
			__wrap_cache_text = _current_text;
			__wrap_cache_w = _inner_w;
			__wrap_cache_font = _font;
			__wrap_cache_lines = __WrapTextLines(_current_text, _inner_w, _font);
		}

		var _old_font = draw_get_font();
		draw_set_font(_font);
		draw_set_color(_tx_col);
		draw_set_alpha(_tx_alpha);
		var _line_h = string_height("Ag");
		var _max_lines = floor(_inner_h / max(1, _line_h));
		var _count = min(array_length(__wrap_cache_lines), _max_lines);
		var _yy = _y1 + _py;
		for (var _i = 0; _i < _count; _i++) {
			var _line = __wrap_cache_lines[_i];
			var _tx = _x1 + _px;
			if (align == "center") {
				_tx = _x1 + ((_x2 - _x1) - string_width(_line)) * 0.5;
			}
			else if (align == "right") {
				_tx = _x2 - _px - string_width(_line);
			}
			draw_text(_tx, _yy, _line);
			_yy += _line_h;
		}
		draw_set_alpha(_old_alpha);
		draw_set_font(_old_font);
	};
}

/// @func EchoChamberButton(_id)
/// @desc Clickable button.
/// @param {Any} _id
/// @return {Struct.EchoChamberButton}
function EchoChamberButton(_id) : EchoChamberControlBase(_id) constructor {
	on_click = undefined;
	bind_label_struct = undefined;
	bind_label_key    = "";
	bind_label_fn     = undefined;

	/// @desc Set a callback to run when the button is activated (click or Enter while focused).
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberButton}
	static OnClick = function(_fn) {
		if (is_callable(_fn)) {
			on_click = _fn;
		}
		return self;
	};

	/// @desc Bind the button label to a struct field or getter function.
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberButton}
	static BindLabel = function(_source, _key_or_fn = undefined) {
		if (is_callable(_source)) {
			bind_label_fn = _source;
			bind_label_struct = undefined;
			bind_label_key = "";
			return self;
		}
		else if (is_struct(_source)) {
			bind_label_struct = _source;
			bind_label_key = is_undefined(_key_or_fn) ? "" : string(_key_or_fn);
			bind_label_fn = undefined;
		}
		return self;
	};

	/// @ignore
	/// @desc Internal: return the current bound label.
	/// @return {String}
	static __GetBoundLabel = function() {
		var _value = undefined;
		if (is_callable(bind_label_fn)) {
			_value = bind_label_fn();
		}
		else if (bind_label_key != "") {
			_value = bind_label_struct[$ bind_label_key];
		}
		if (!is_undefined(_value)) {
			label = string(_value);
		}
		return label;
	};

	/// @ignore
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (!is_struct(_root) || !is_struct(_root.theme)) {
			return undefined;
		}
		var _s = string(__GetBoundLabel());
		var _pad_x = __ResolvePaddingX(_root);
		var _w = _root.__MeasureTextWidth(_s, _root.theme.font_body) + (_pad_x * 2) + 8;
		return { w: _w, h: _row_h };
	};

	/// @desc Process input and draw the button.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _hover = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}


		// Resolve style
		var _styles = _root.theme.button_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _tx_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.95;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _tx_alpha_base = _st[$ "text_alpha"] ?? 1;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _tx_disabled = _st[$ "text_disabled"] ?? _tx_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha_base;
		var _bg_hover = _st[$ "bg_hover"] ?? _st[$ "hover"] ?? merge_color(_bg_base, _tx_base, 0.15);
		var _bd_hover = _st[$ "border_hover"] ?? _bd_base;
		var _tx_hover = _st[$ "text_hover"] ?? _tx_base;
		var _bg_hover_alpha = _st[$ "bg_hover_alpha"] ?? _bg_alpha_base;
		var _bd_hover_alpha = _st[$ "border_hover_alpha"] ?? _bd_alpha_base;
		var _tx_hover_alpha = _st[$ "text_hover_alpha"] ?? _tx_alpha_base;
		var _bg_pressed = _st[$ "bg_pressed"] ?? _bg_hover;
		var _bd_pressed = _st[$ "border_pressed"] ?? _bd_hover;
		var _tx_pressed = _st[$ "text_pressed"] ?? _tx_hover;
		var _bg_pressed_alpha = _st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha;
		var _bd_pressed_alpha = _st[$ "border_pressed_alpha"] ?? _bd_hover_alpha;
		var _tx_pressed_alpha = _st[$ "text_pressed_alpha"] ?? _tx_hover_alpha;

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _tx_alpha = _tx_alpha_base;
		if (!enabled) {
			_bg_col = _bg_disabled;
			_bd_col = _bd_disabled;
			_tx_col = _tx_disabled;
			_bg_alpha = _bg_disabled_alpha;
			_bd_alpha = _bd_disabled_alpha;
			_tx_alpha = _tx_disabled_alpha;
		}
		else if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_tx_col = _tx_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
		}
		else if (_hover && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_tx_col = _tx_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		// Label
		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);
		draw_set_color(_tx_col);
		draw_set_alpha(_tx_alpha);

		var _label_str = string(__GetBoundLabel());
		var _pad_x = __ResolvePaddingX(_root);
		var _max_w = max(0, (_x2 - _x1) - _pad_x * 2);
		var _draw_str;
		_draw_str = __TrimTextToWidth(_label_str, _max_w, _root.theme.font_body);

		var _text_h = string_height(_draw_str);
		var _ty = _y1 + ((_y2 - _y1) - _text_h) * 0.5;
		var _tx = _x1 + ((_x2 - _x1) - string_width(_draw_str)) * 0.5;
		draw_text(_tx, _ty, _draw_str);
		draw_set_alpha(_old_alpha);

		draw_set_font(_old_font);

		// Keyboard activate (Enter)
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled) {
			if (is_callable(on_click)) {
				on_click();
			}
		}

		// Click
		if (_hover && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			_root.ConsumeMouse();
			_root.FocusControl(id, _rect);
			if (is_callable(on_click)) {
				on_click();
			}
		}

		// Tooltip
		if (_hover && string_length(tooltip) > 0) {
			_root.RequestTooltip(id, tooltip, _mx, _my);
		}
	};
}

/// @func EchoChamberSlider(_id)
/// @desc Horizontal slider control.
/// @param {Any} _id
/// @return {Struct.EchoChamberSlider}
function EchoChamberSlider(_id) : EchoChamberControlBase(_id) constructor {
	min_value = 0;
	max_value = 1;
	step      = 0;         // 0 = no snapping
	bind_struct = undefined;
	bind_key    = "";
	bind_get_fn = undefined;
	bind_set_fn = undefined;
	on_change   = undefined;

	/// @desc Set the slider range.
	/// @param {Real} _min
	/// @param {Real} _max
	/// @return {Struct.EchoChamberSlider}
	static SetRange = function(_min, _max) {
		min_value = _min;
		max_value = _max;
		return self;
	};

	/// @desc Set step snapping size (0 disables snapping).
	/// @param {Real} _step
	/// @return {Struct.EchoChamberSlider}
	static SetStep = function(_step) {
		step = _step;
		return self;
	};

	/// @desc Bind the slider value to a struct field or getter/setter functions.
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberSlider}
	static BindValue = function(_source, _key_or_fn = undefined) {
		if (is_callable(_source)) {
			bind_get_fn = _source;
			bind_set_fn = is_callable(_key_or_fn) ? _key_or_fn : undefined;
			bind_struct = undefined;
			bind_key    = "";
			return self;
		}
		else if (is_struct(_source)) {
			bind_struct = _source;
			bind_key    = is_undefined(_key_or_fn) ? "" : string(_key_or_fn);
			bind_get_fn = undefined;
			bind_set_fn = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs when the value changes.
	/// @param {Function} _fn function(_value)
	/// @return {Struct.EchoChamberSlider}
	static OnChange = function(_fn) {
		if (is_callable(_fn)) {
			on_change = _fn;
		}
		return self;
	};

	/// @ignore
	static __GetValue = function() {
		var _v = undefined;
		if (is_callable(bind_get_fn)) {
			_v = bind_get_fn();
		}
		else if (bind_key != "") {
			_v = bind_struct[$ bind_key];
		}
		return is_undefined(_v) ? min_value : _v;
	};

	/// @ignore
	static __SetValue = function(_v) {
		if (step != 0) {
			_v = round(_v / step) * step;
		}
		_v = clamp(_v, min_value, max_value);
		if (is_callable(bind_set_fn)) {
			bind_set_fn(_v);
		}
		else if (bind_key != "") {
			bind_struct[$ bind_key] = _v;
		}
		if (is_callable(on_change)) {
			on_change(_v);
		}
	};

	/// @desc Process input and draw the slider.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _value = __GetValue();

		var _hover = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		var _styles = _root.theme.slider_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _track_base = _st[$ "track_bg"] ?? _root.theme.col_panel_bg;
		var _fill_base = _st[$ "track_fill"] ?? _root.theme.col_accent;
		var _knob_base = _st[$ "knob"] ?? _root.theme.col_text;
		var _track_alpha_base = _st[$ "track_bg_alpha"] ?? 1;
		var _fill_alpha_base = _st[$ "track_fill_alpha"] ?? 1;
		var _knob_alpha_base = _st[$ "knob_alpha"] ?? 1;
		var _track_disabled = _st[$ "track_bg_disabled"] ?? _track_base;
		var _fill_disabled = _st[$ "track_fill_disabled"] ?? _fill_base;
		var _knob_disabled = _st[$ "knob_disabled"] ?? _knob_base;
		var _track_disabled_alpha = _st[$ "track_bg_disabled_alpha"] ?? _track_alpha_base;
		var _fill_disabled_alpha = _st[$ "track_fill_disabled_alpha"] ?? _fill_alpha_base;
		var _knob_disabled_alpha = _st[$ "knob_disabled_alpha"] ?? _knob_alpha_base;

		var _track_hover = _st[$ "track_bg_hover"] ?? merge_color(_track_base, _root.theme.col_text, 0.12);
		var _fill_hover = _st[$ "track_fill_hover"] ?? merge_color(_fill_base, _root.theme.col_text, 0.12);
		var _knob_hover = _st[$ "knob_hover"] ?? merge_color(_knob_base, _root.theme.col_text, 0.12);
		var _track_hover_alpha = _st[$ "track_bg_hover_alpha"] ?? _track_alpha_base;
		var _fill_hover_alpha = _st[$ "track_fill_hover_alpha"] ?? _fill_alpha_base;
		var _knob_hover_alpha = _st[$ "knob_hover_alpha"] ?? _knob_alpha_base;

		var _track_pressed = _st[$ "track_bg_pressed"] ?? _track_hover;
		var _fill_pressed = _st[$ "track_fill_pressed"] ?? _fill_hover;
		var _knob_pressed = _st[$ "knob_pressed"] ?? _knob_hover;
		var _track_pressed_alpha = _st[$ "track_bg_pressed_alpha"] ?? _track_hover_alpha;
		var _fill_pressed_alpha = _st[$ "track_fill_pressed_alpha"] ?? _fill_hover_alpha;
		var _knob_pressed_alpha = _st[$ "knob_pressed_alpha"] ?? _knob_hover_alpha;

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _track_col = _track_base;
		var _fill_col = _fill_base;
		var _knob_col = _knob_base;
		var _track_alpha = _track_alpha_base;
		var _fill_alpha = _fill_alpha_base;
		var _knob_alpha = _knob_alpha_base;
		if (!enabled) {
			_track_col = _track_disabled;
			_fill_col = _fill_disabled;
			_knob_col = _knob_disabled;
			_track_alpha = _track_disabled_alpha;
			_fill_alpha = _fill_disabled_alpha;
			_knob_alpha = _knob_disabled_alpha;
		}
		else if (_pressed) {
			_track_col = _track_pressed;
			_fill_col = _fill_pressed;
			_knob_col = _knob_pressed;
			_track_alpha = _track_pressed_alpha;
			_fill_alpha = _fill_pressed_alpha;
			_knob_alpha = _knob_pressed_alpha;
		}
		else if (_hover && enabled) {
			_track_col = _track_hover;
			_fill_col = _fill_hover;
			_knob_col = _knob_hover;
			_track_alpha = _track_hover_alpha;
			_fill_alpha = _fill_hover_alpha;
			_knob_alpha = _knob_hover_alpha;
		}

		// Track
		var _track_h = max(4, (_y2 - _y1) * 0.25);
		var _track_y = _y1 + ((_y2 - _y1) - _track_h) * 0.5;

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_track_alpha);
		draw_set_color(_track_col);
		draw_rectangle(_x1, _track_y, _x2, _track_y + _track_h, false);
		draw_set_alpha(_old_alpha);

		// Fill
		var _t = (max_value <= min_value) ? 0 : clamp((_value - min_value) / (max_value - min_value), 0, 1);
		var _fill_x2 = lerp(_x1, _x2, _t);
		draw_set_alpha(_fill_alpha);
		draw_set_color(_fill_col);
		draw_rectangle(_x1, _track_y, _fill_x2, _track_y + _track_h, false);
		draw_set_alpha(_old_alpha);

		// Knob
		var _knob_r = max(6, (_y2 - _y1) * 0.35);
		var _knob_x = _fill_x2;
		var _knob_y = _y1 + (_y2 - _y1) * 0.5;
		draw_set_alpha(_knob_alpha);
		draw_set_color(_knob_col);
		draw_circle(_knob_x, _knob_y, _knob_r, false);
		draw_set_alpha(_old_alpha);

		// Drag to change
		if (_hover && _root.mouse_l_down && !_root.mouse_consumed && enabled) {
			var _len = max(1, (_x2 - _x1));
			var _tt = clamp((_mx - _x1) / _len, 0, 1);
			var _new_val = lerp(min_value, max_value, _tt);
			__SetValue(_new_val);
			_root.FocusControl(id, _rect);
			_root.ConsumeMouse();
		}

		// Tooltip
		if (_hover && string_length(tooltip) > 0) {
			_root.RequestTooltip(id, tooltip, _mx, _my);
		}
	};
}

/// @func EchoChamberToggle(_id)
/// @desc Checkbox-style toggle.
/// @param {Any} _id
/// @return {Struct.EchoChamberToggle}
function EchoChamberToggle(_id) : EchoChamberControlBase(_id) constructor {
	bind_struct = undefined;
	bind_key    = "";
	bind_get_fn = undefined;
	bind_set_fn = undefined;
	on_change   = undefined;

	/// @desc Bind the toggle state to a struct field or getter/setter functions.
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberToggle}
	static BindBool = function(_source, _key_or_fn = undefined) {
		if (is_callable(_source)) {
			bind_get_fn = _source;
			bind_set_fn = is_callable(_key_or_fn) ? _key_or_fn : undefined;
			bind_struct = undefined;
			bind_key    = "";
			return self;
		}
		else if (is_struct(_source)) {
			bind_struct = _source;
			bind_key    = is_undefined(_key_or_fn) ? "" : string(_key_or_fn);
			bind_get_fn = undefined;
			bind_set_fn = undefined;
		}
		return self;
	};

	/// @desc Bind the toggle state (alias of BindBool).
	/// @param {Struct,Function} _source
	/// @param {String,Function} [_key_or_fn]
	/// @return {Struct.EchoChamberToggle}
	static BindValue = function(_source, _key_or_fn = undefined) {
		return BindBool(_source, _key_or_fn);
	};

	/// @desc Set a callback that runs when the value changes.
	/// @param {Function} _fn function(_value)
	/// @return {Struct.EchoChamberToggle}
	static OnChange = function(_fn) {
		if (is_callable(_fn)) {
			on_change = _fn;
		}
		return self;
	};

	/// @ignore
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (!is_struct(_root) || !is_struct(_root.theme)) {
			return undefined;
		}
		var _box_size = min(_row_h - 4, 14);
		if (_box_size < 0) {
			_box_size = 0;
		}
		var _s = string(label);
		var _text_w = _root.__MeasureTextWidth(_s, _root.theme.font_body);
		var _w = 4 + _box_size + 6 + _text_w + 6;
		return { w: _w, h: _row_h };
	};

	/// @ignore
	static __GetValue = function() {
		var _v = undefined;
		if (is_callable(bind_get_fn)) {
			_v = bind_get_fn();
		}
		else if (bind_key != "") {
			_v = bind_struct[$ bind_key];
		}
		return is_undefined(_v) ? false : _v;
	};

	/// @ignore
	static __SetValue = function(_v) {
		if (is_callable(bind_set_fn)) {
			bind_set_fn(_v);
		}
		else if (bind_key != "") {
			bind_struct[$ bind_key] = _v;
		}
		if (is_callable(on_change)) {
			on_change(_v);
		}
	};

	/// @desc Process input and draw the toggle.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _width  = _x2 - _x1;
		var _height = _y2 - _y1;

		var _value = __GetValue();
		var _hover = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		// Style
		var _styles = _root.theme.toggle_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _tx_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.9;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _tx_alpha_base = _st[$ "text_alpha"] ?? 1;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _tx_disabled = _st[$ "text_disabled"] ?? _tx_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha_base;
		var _bg_hover = _st[$ "bg_hover"] ?? merge_color(_bg_base, _tx_base, 0.12);
		var _bd_hover = _st[$ "border_hover"] ?? _bd_base;
		var _tx_hover = _st[$ "text_hover"] ?? _tx_base;
		var _bg_hover_alpha = _st[$ "bg_hover_alpha"] ?? _bg_alpha_base;
		var _bd_hover_alpha = _st[$ "border_hover_alpha"] ?? _bd_alpha_base;
		var _tx_hover_alpha = _st[$ "text_hover_alpha"] ?? _tx_alpha_base;
		var _bg_pressed = _st[$ "bg_pressed"] ?? _bg_hover;
		var _bd_pressed = _st[$ "border_pressed"] ?? _bd_hover;
		var _tx_pressed = _st[$ "text_pressed"] ?? _tx_hover;
		var _bg_pressed_alpha = _st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha;
		var _bd_pressed_alpha = _st[$ "border_pressed_alpha"] ?? _bd_hover_alpha;
		var _tx_pressed_alpha = _st[$ "text_pressed_alpha"] ?? _tx_hover_alpha;

		var _box_off = _st[$ "box_off"] ?? _root.theme.col_checkbox_off;
		var _box_on = _st[$ "box_on"] ?? _root.theme.col_checkbox_on;
		var _box_border = _st[$ "box_border"] ?? _bd_base;
		var _box_off_alpha = _st[$ "box_off_alpha"] ?? 1;
		var _box_on_alpha = _st[$ "box_on_alpha"] ?? 1;
		var _box_border_alpha_base = _st[$ "box_border_alpha"] ?? 1;
		var _box_off_disabled = _st[$ "box_off_disabled"] ?? _box_off;
		var _box_on_disabled = _st[$ "box_on_disabled"] ?? _box_on;
		var _box_border_disabled = _st[$ "box_border_disabled"] ?? _box_border;
		var _box_off_disabled_alpha = _st[$ "box_off_disabled_alpha"] ?? _box_off_alpha;
		var _box_on_disabled_alpha = _st[$ "box_on_disabled_alpha"] ?? _box_on_alpha;
		var _box_border_disabled_alpha = _st[$ "box_border_disabled_alpha"] ?? _box_border_alpha_base;
		var _box_off_hover = _st[$ "box_off_hover"] ?? _box_off;
		var _box_on_hover = _st[$ "box_on_hover"] ?? _box_on;
		var _box_border_hover = _st[$ "box_border_hover"] ?? _box_border;
		var _box_off_hover_alpha = _st[$ "box_off_hover_alpha"] ?? _box_off_alpha;
		var _box_on_hover_alpha = _st[$ "box_on_hover_alpha"] ?? _box_on_alpha;
		var _box_border_hover_alpha = _st[$ "box_border_hover_alpha"] ?? _box_border_alpha_base;
		var _box_off_pressed = _st[$ "box_off_pressed"] ?? _box_off_hover;
		var _box_on_pressed = _st[$ "box_on_pressed"] ?? _box_on_hover;
		var _box_border_pressed = _st[$ "box_border_pressed"] ?? _box_border_hover;
		var _box_off_pressed_alpha = _st[$ "box_off_pressed_alpha"] ?? _box_off_hover_alpha;
		var _box_on_pressed_alpha = _st[$ "box_on_pressed_alpha"] ?? _box_on_hover_alpha;
		var _box_border_pressed_alpha = _st[$ "box_border_pressed_alpha"] ?? _box_border_hover_alpha;

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _tx_alpha = _tx_alpha_base;
		var _box_bg_col = _box_off;
		var _box_fill_col = _box_on;
		var _box_border_col = _box_border;
		var _box_bg_alpha = _box_off_alpha;
		var _box_fill_alpha = _box_on_alpha;
		var _box_border_alpha = _box_border_alpha_base;
		if (!enabled) {
			_bg_col = _bg_disabled;
			_bd_col = _bd_disabled;
			_tx_col = _tx_disabled;
			_box_bg_col = _box_off_disabled;
			_box_fill_col = _box_on_disabled;
			_box_border_col = _box_border_disabled;
			_bg_alpha = _bg_disabled_alpha;
			_bd_alpha = _bd_disabled_alpha;
			_tx_alpha = _tx_disabled_alpha;
			_box_bg_alpha = _box_off_disabled_alpha;
			_box_fill_alpha = _box_on_disabled_alpha;
			_box_border_alpha = _box_border_disabled_alpha;
		}
		else if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_tx_col = _tx_pressed;
			_box_bg_col = _box_off_pressed;
			_box_fill_col = _box_on_pressed;
			_box_border_col = _box_border_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
			_box_bg_alpha = _box_off_pressed_alpha;
			_box_fill_alpha = _box_on_pressed_alpha;
			_box_border_alpha = _box_border_pressed_alpha;
		}
		else if (_hover && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_tx_col = _tx_hover;
			_box_bg_col = _box_off_hover;
			_box_fill_col = _box_on_hover;
			_box_border_col = _box_border_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
			_box_bg_alpha = _box_off_hover_alpha;
			_box_fill_alpha = _box_on_hover_alpha;
			_box_border_alpha = _box_border_hover_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		// Checkbox box
		var _box_size = min(_height - 4, 14);
		var _box_x1   = _x1 + 4;
		var _box_y1   = _y1 + (_height - _box_size) * 0.5;
		var _box_x2   = _box_x1 + _box_size;
		var _box_y2   = _box_y1 + _box_size;

		draw_set_alpha(_box_bg_alpha);
		draw_set_color(_box_bg_col);
		draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
		draw_set_alpha(_box_border_alpha);
		draw_set_color(_box_border_col);
		draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);
		draw_set_alpha(_old_alpha);

		if (_value) {
			draw_set_alpha(_box_fill_alpha);
			draw_set_color(_box_fill_col);
			draw_rectangle(_box_x1 + 1, _box_y1 + 2, _box_x2 - 2, _box_y2 - 2, false);
			draw_set_alpha(_old_alpha);
		}

		// Label
		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);
		draw_set_color(_tx_col);
		draw_set_alpha(_tx_alpha);

		var _label_str = string(label);
		var _max_w = max(0, _width - (_box_size + 10));
		var _draw_str;
		_draw_str = __TrimTextToWidth(_label_str, _max_w, _root.theme.font_body);

		var _text_h = string_height(_draw_str);
		var _ty     = _y1 + (_height - _text_h) * 0.5;
		var _tx     = _box_x2 + 6;
		draw_text(_tx, _ty, _draw_str);
		draw_set_alpha(_old_alpha);

		draw_set_font(_old_font);

		// Keyboard activate (Enter)
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled) {
			__SetValue(!__GetValue());
		}


		// Click
		if (_hover && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			__SetValue(!_value);
			_root.FocusControl(id, _rect);
			_root.ConsumeMouse();
		}

		// Tooltip
		if (_hover && string_length(tooltip) > 0) {
			_root.RequestTooltip(id, tooltip, _mx, _my);
		}
	};
}

/// @func EchoChamberTextInput(_id)
/// @desc Single-line text input.
/// @param {Any} _id
/// @return {Struct.EchoChamberTextInput}
function EchoChamberTextInput(_id) : EchoChamberControlBase(_id) constructor {
	bind_struct  = undefined;
	bind_key     = "";
	placeholder  = "";
	on_change    = undefined;  // fired when losing focus, or each frame if you want
	on_live_change = undefined; // fired while typing (optional)
	on_submit    = undefined; // fired when edit is submitted
	on_cancel    = undefined; // fired when edit is cancelled
	on_focus     = undefined; // fired when edit starts
	on_blur      = undefined; // fired when edit ends
	live_change_rate_ms = 0;
	read_only    = false;
	max_length   = 0;
	allow_chars  = "";
	deny_chars   = "";
	numeric_only = false;
	numeric_allow_decimal = false;
	numeric_allow_negative = false;
	select_all_on_focus = false;
	filter_fn = undefined;
	transforms = [];
	auto_trim = false;
	auto_upper = false;
	auto_lower = false;
	text_align = "auto";
	invalid = false;

	validation_message = "";
	validation_kind = "error"; // "error"|"warn"|"info"
	validation_visible = false;
	validation_display = "auto"; // "inline"|"tooltip"|"auto"

	input_mode = ECHO_TEXTMODE_TEXT;
	tab_inserts = false;
	tab_use_spaces = false;
	tab_spaces = 4;
	auto_indent = false;
	password_mask = false;
	password_mask_char = "*";
	password_allow_copy = false;

	skin_bg_sprite = -1;
	skin_bg_subimg = 0;
	skin_border_sprite = -1;
	skin_border_subimg = 0;
	skin_caret_sprite = -1;
	skin_caret_subimg = 0;
	skin_grip_sprite = -1;
	skin_grip_subimg = 0;
	skin_expand_sprite = -1;
	skin_expand_subimg = 0;

	skin_tint_enabled = false;
	skin_tint_color = c_white;
	skin_tint_alpha_mul = 1;

	force_size_kind = "none"; // "bg"|"border"|"custom"
	force_size_sprite = -1;
	force_size_scale = 1;
	force_size_lock_w = true;
	force_size_lock_h = true;

	__force_prev_stored = false;
	__force_prev_pref_w = 0;
	__force_prev_pref_h = 0;
	__force_prev_fill_width = false;
	__force_prev_lock_w = true;
	__force_prev_lock_h = true;

	/// @desc Bind this text input to a struct field.
	/// @param {Struct} _struct
	/// @param {String} _key
	/// @return {Struct.EchoChamberTextInput}
	static BindText = function(_struct, _key) {
		if (is_struct(_struct)) {
			bind_struct = _struct;
			bind_key    = string(_key);
		}
		return self;
	};

	/// @desc Set the placeholder text shown when empty and not active.
	/// @param {Any} _text
	/// @return {Struct.EchoChamberTextInput}
	static SetPlaceholder = function(_text) {
		placeholder = string(_text);
		return self;
	};

	/// @desc Set a callback that runs when text is committed.
	/// @param {Function} _fn function(_text)
	/// @return {Struct.EchoChamberTextInput}
	static OnChange = function(_fn) {
		if (is_callable(_fn)) {
			on_change = _fn;
		}
		else {
			on_change = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs when text is submitted (committed edit).
	/// @param {Function} _fn function(_text)
	/// @return {Struct.EchoChamberTextInput}
	static OnSubmit = function(_fn) {
		if (is_callable(_fn)) {
			on_submit = _fn;
		}
		else {
			on_submit = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs when text editing is cancelled.
	/// @param {Function} _fn function(_text, _initial_text)
	/// @return {Struct.EchoChamberTextInput}
	static OnCancel = function(_fn) {
		if (is_callable(_fn)) {
			on_cancel = _fn;
		}
		else {
			on_cancel = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs when this text input gains editing focus.
	/// @param {Function} _fn function(_text)
	/// @return {Struct.EchoChamberTextInput}
	static OnFocus = function(_fn) {
		if (is_callable(_fn)) {
			on_focus = _fn;
		}
		else {
			on_focus = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs when this text input loses editing focus.
	/// @param {Function} _fn function(_text, _was_cancelled)
	/// @return {Struct.EchoChamberTextInput}
	static OnBlur = function(_fn) {
		if (is_callable(_fn)) {
			on_blur = _fn;
		}
		else {
			on_blur = undefined;
		}
		return self;
	};

	/// @desc Set a callback that runs while the user edits text (typing, delete, paste, undo/redo).
	/// @param {Function} _fn function(_text)
	/// @return {Struct.EchoChamberTextInput}
	static OnLiveChange = function(_fn) {
		if (is_callable(_fn)) {
			on_live_change = _fn;
		}
		else {
			on_live_change = undefined;
		}
		return self;
	};

	/// @desc Set a throttle rate for the live change callback (0 = no throttling).
	/// @param {Real} _ms
	/// @return {Struct.EchoChamberTextInput}
	static SetLiveChangeRateMs = function(_ms) {
		live_change_rate_ms = max(0, _ms);
		return self;
	};

	/// @desc Convenience: set live change callback and rate in one call.
	/// @param {Function} _fn function(_text)
	/// @param {Real} [_rate_ms]
	/// @return {Struct.EchoChamberTextInput}
	static SetOnLiveChange = function(_fn, _rate_ms = 0) {
		OnLiveChange(_fn);
		SetLiveChangeRateMs(_rate_ms);
		return self;
	};

	/// @desc Set whether this text input is read-only.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetReadOnly = function(_flag) {
		read_only = (_flag == true);
		return self;
	};

	/// @desc Set the maximum number of characters allowed (0 = unlimited).
	/// @param {Real} _len
	/// @return {Struct.EchoChamberTextInput}
	static SetMaxLength = function(_len) {
		max_length = max(0, _len);
		return self;
	};

	/// @desc Restrict input to the characters in the given string (empty = allow all).
	/// @param {String} _chars
	/// @return {Struct.EchoChamberTextInput}
	static SetAllowedChars = function(_chars) {
		allow_chars = string(_chars);
		return self;
	};

	/// @desc Reject any characters contained in the given string.
	/// @param {String} _chars
	/// @return {Struct.EchoChamberTextInput}
	static SetDeniedChars = function(_chars) {
		deny_chars = string(_chars);
		return self;
	};

	/// @desc Restrict input to numeric characters.
	/// @param {Bool} _flag
	/// @param {Bool} [_allow_decimal]
	/// @param {Bool} [_allow_negative]
	/// @return {Struct.EchoChamberTextInput}
	static SetNumericOnly = function(_flag, _allow_decimal = false, _allow_negative = false) {
		numeric_only = (_flag == true);
		numeric_allow_decimal = (_allow_decimal == true);
		numeric_allow_negative = (_allow_negative == true);
		return self;
	};

	/// @desc Select all text when the input gains focus.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetSelectAllOnFocus = function(_flag) {
		select_all_on_focus = (_flag == true);
		return self;
	};

	/// @desc Set a filter function that can mutate inserted text.
	/// @param {Function} _fn function(_insert_text)
	/// @return {Struct.EchoChamberTextInput}
	static SetFilter = function(_fn) {
		if (is_callable(_fn)) {
			filter_fn = _fn;
		}
		else {
			filter_fn = undefined;
		}
		return self;
	};

	/// @desc Add a text transform function applied before SetFilter and built-in validators.
	/// @param {Function} _fn function(_insert_text)
	/// @return {Struct.EchoChamberTextInput}
	static AddTransform = function(_fn) {
		if (is_callable(_fn)) {
			array_push(transforms, _fn);
		}
		return self;
	};

	/// @desc Clear all transform functions.
	/// @return {Struct.EchoChamberTextInput}
	static ClearTransforms = function() {
		transforms = [];
		return self;
	};

	/// @desc Enable or disable automatic trim of inserted text.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetAutoTrim = function(_flag) {
		auto_trim = (_flag == true);
		return self;
	};

	/// @desc Enable or disable automatic uppercase transform.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetAutoUpper = function(_flag) {
		auto_upper = (_flag == true);
		if (auto_upper) {
			auto_lower = false;
		}
		return self;
	};

	/// @desc Enable or disable automatic lowercase transform.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetAutoLower = function(_flag) {
		auto_lower = (_flag == true);
		if (auto_lower) {
			auto_upper = false;
		}
		return self;
	};

	/// @desc Set horizontal text alignment ("left", "center", "right", or "auto").
	/// @param {Any} _align
	/// @return {Struct.EchoChamberTextInput}
	static SetTextAlign = function(_align) {
		var _v = string_lower(string(_align));
		if (_v != "left" && _v != "center" && _v != "right") {
			_v = "auto";
		}
		text_align = _v;
		return self;
	};

	/// @ignore
	/// @desc Internal: resolve horizontal text alignment.
	/// @param {Struct.EchoChamberRoot} _root
	/// @return {String}
	static __ResolveTextAlign = function(_root) {
		var _align = string_lower(string(text_align));
		if (_align != "left" && _align != "center" && _align != "right") {
			var _styles = _root.theme.textinput_styles;
			var _st = _styles[$ style_id] ?? _styles[$ "_default"];
			_align = string_lower(string(_st[$ "align"] ?? "left"));
		}
		if (_align != "left" && _align != "center" && _align != "right") {
			_align = "left";
		}
		return _align;
	};

	/// @ignore
	/// @desc Internal: resolve text draw x + scroll info for a text viewport.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _x1
	/// @param {Real} _x2
	/// @param {String} _text
	/// @param {Struct} _config
	/// @param {Bool} _active
	/// @return {Struct}
	static __ResolveTextViewport = function(_root, _x1, _x2, _text, _config, _active) {
		var _view_w = max(0, _x2 - _x1);
		var _text_w = _root.__TextInputMeasureVisualWidth(_text, _root.theme.font_body, _config);
		var _align = __ResolveTextAlign(_root);
		var _overflow = (_text_w > _view_w);
		var _scroll_x = 0;
		var _text_x = _x1;
		if (_overflow) {
			if (_active) {
				_scroll_x = clamp(_root.text_scroll_x, 0, max(0, _text_w - _view_w));
			}
			_text_x = _x1 - _scroll_x;
		}
		else if (_align == "center") {
			_text_x = _x1 + max(0, (_view_w - _text_w) * 0.5);
		}
		else if (_align == "right") {
			_text_x = _x2 - _text_w;
		}
		return {
			x : _text_x,
			scroll_x : _scroll_x,
			view_w : _view_w,
			text_w : _text_w,
			overflow : _overflow
		};
	};

	/// @desc Mark this text input as invalid for styling.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetInvalid = function(_flag) {
		invalid = (_flag == true);
		return self;
	};

	/// @desc Set a validation message and kind to show to the user.
	/// @param {Any} _message
	/// @param {String} [_kind] "error"|"warn"|"info"
	/// @return {Struct.EchoChamberTextInput}
	static SetValidationMessage = function(_message, _kind = "error") {
		validation_message = string(_message);
		validation_kind = string(_kind);
		validation_visible = (string_length(validation_message) > 0);
		return self;
	};

	/// @desc Clear any validation message.
	/// @return {Struct.EchoChamberTextInput}
	static ClearValidationMessage = function() {
		validation_message = "";
		validation_visible = false;
		return self;
	};

	/// @desc Show or hide validation messaging.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetValidationVisible = function(_flag) {
		validation_visible = (_flag == true);
		return self;
	};

	/// @desc Set how the validation message is displayed ("inline", "tooltip", or "auto").
	/// @param {String} _mode
	/// @return {Struct.EchoChamberTextInput}
	static SetValidationDisplay = function(_mode) {
		validation_display = string(_mode);
		return self;
	};

	/// @desc Set the input mode (TEXT/INT/FLOAT/IDENTIFIER/PATH/CODE/PASSWORD).
	/// @param {Real} _mode
	/// @return {Struct.EchoChamberTextInput}
	static SetInputMode = function(_mode) {
		input_mode = _mode;
		if (input_mode == ECHO_TEXTMODE_INT) {
			numeric_only = true;
			numeric_allow_decimal = false;
			numeric_allow_negative = true;
			tab_inserts = false;
			password_mask = false;
			auto_indent = false;
		}
		else if (input_mode == ECHO_TEXTMODE_FLOAT) {
			numeric_only = true;
			numeric_allow_decimal = true;
			numeric_allow_negative = true;
			tab_inserts = false;
			password_mask = false;
			auto_indent = false;
		}
		else if (input_mode == ECHO_TEXTMODE_PASSWORD) {
			numeric_only = false;
			tab_inserts = false;
			password_mask = true;
			auto_indent = false;
		}
		else if (input_mode == ECHO_TEXTMODE_CODE) {
			numeric_only = false;
			tab_inserts = true;
			auto_indent = true;
			password_mask = false;
		}
		else {
			numeric_only = false;
			tab_inserts = false;
			password_mask = false;
			auto_indent = false;
		}
		return self;
	};

	/// @desc Convenience: set input mode to INT.
	/// @return {Struct.EchoChamberTextInput}
	static SetInputModeInt = function() {
		return SetInputMode(ECHO_TEXTMODE_INT);
	};

	/// @desc Convenience: set input mode to FLOAT.
	/// @return {Struct.EchoChamberTextInput}
	static SetInputModeFloat = function() {
		return SetInputMode(ECHO_TEXTMODE_FLOAT);
	};

	/// @desc Convenience: set input mode to CODE.
	/// @return {Struct.EchoChamberTextInput}
	static SetInputModeCode = function() {
		return SetInputMode(ECHO_TEXTMODE_CODE);
	};

	/// @desc Convenience: set input mode to PASSWORD.
	/// @return {Struct.EchoChamberTextInput}
	static SetInputModePassword = function(_allow_copy = false) {
		password_allow_copy = (_allow_copy == true);
		return SetInputMode(ECHO_TEXTMODE_PASSWORD);
	};

	/// @desc Enable or disable Tab insertion while editing (disables Tab focus cycling when active).
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetTabInserts = function(_flag) {
		tab_inserts = (_flag == true);
		return self;
	};

	/// @desc Set whether Tab inserts spaces instead of a tab character.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextInput}
	static SetTabUsesSpaces = function(_flag) {
		tab_use_spaces = (_flag == true);
		return self;
	};

	/// @desc Set how many spaces are inserted when Tab uses spaces.
	/// @param {Real} _count
	/// @return {Struct.EchoChamberTextInput}
	static SetTabSpaces = function(_count) {
		tab_spaces = max(0, floor(_count));
		return self;
	};

	/// @desc Set the background sprite for this input (-1 to clear).
	/// @param {Any} _spr
	/// @param {Real} [_subimg]
	/// @return {Struct.EchoChamberTextInput}
	static SetBackgroundSprite = function(_spr, _subimg = 0) {
		skin_bg_sprite = (_spr == -1 || sprite_exists(_spr)) ? _spr : -1;
		skin_bg_subimg = max(0, floor(_subimg));
		if (__force_prev_stored && force_size_kind == "bg") {
			__ApplyForceSizeNow(undefined);
		}
		return self;
	};

	/// @desc Set the border sprite for this input (-1 to clear).
	/// @param {Any} _spr
	/// @param {Real} [_subimg]
	/// @return {Struct.EchoChamberTextInput}
	static SetBorderSprite = function(_spr, _subimg = 0) {
		skin_border_sprite = (_spr == -1 || sprite_exists(_spr)) ? _spr : -1;
		skin_border_subimg = max(0, floor(_subimg));
		if (__force_prev_stored && force_size_kind == "border") {
			__ApplyForceSizeNow(undefined);
		}
		return self;
	};

	/// @desc Set the caret sprite for this input (-1 to clear).
	/// @param {Any} _spr
	/// @param {Real} [_subimg]
	/// @return {Struct.EchoChamberTextInput}
	static SetCaretSprite = function(_spr, _subimg = 0) {
		skin_caret_sprite = (_spr == -1 || sprite_exists(_spr)) ? _spr : -1;
		skin_caret_subimg = max(0, floor(_subimg));
		return self;
	};

	/// @desc Set the TextArea resize grip sprite (-1 to clear).
	/// @param {Any} _spr
	/// @param {Real} [_subimg]
	/// @return {Struct.EchoChamberTextInput}
	static SetGripSprite = function(_spr, _subimg = 0) {
		skin_grip_sprite = (_spr == -1 || sprite_exists(_spr)) ? _spr : -1;
		skin_grip_subimg = max(0, floor(_subimg));
		return self;
	};

	/// @desc Set the TextArea expand button sprite (-1 to clear).
	/// @param {Any} _spr
	/// @param {Real} [_subimg]
	/// @return {Struct.EchoChamberTextInput}
	static SetExpandSprite = function(_spr, _subimg = 0) {
		skin_expand_sprite = (_spr == -1 || sprite_exists(_spr)) ? _spr : -1;
		skin_expand_subimg = max(0, floor(_subimg));
		return self;
	};

	/// @desc Enable or disable extra skin tint multiplication for sprites.
	/// @param {Bool} _enabled
	/// @param {Real} [_col]
	/// @param {Real} [_alpha_mul]
	/// @return {Struct.EchoChamberTextInput}
	static SetSkinTint = function(_enabled, _col = c_white, _alpha_mul = 1) {
		skin_tint_enabled = (_enabled == true);
		skin_tint_color = is_real(_col) ? _col : c_white;
		skin_tint_alpha_mul = max(0, _alpha_mul);
		return self;
	};

	/// @desc Force this control size to match the current background sprite.
	/// @param {Real} [_scale]
	/// @param {Bool} [_lock_w]
	/// @param {Bool} [_lock_h]
	/// @return {Struct.EchoChamberTextInput}
	static SetForceSizeFromBackgroundSprite = function(_scale = 1, _lock_w = true, _lock_h = true) {
		__StoreForceSizePrevIfNeeded();
		force_size_kind = "bg";
		force_size_sprite = -1;
		force_size_scale = max(0, _scale);
		force_size_lock_w = (_lock_w == true);
		force_size_lock_h = (_lock_h == true);
		__ApplyForceSizeNow(undefined);
		return self;
	};

	/// @desc Force this control size to match the current border sprite.
	/// @param {Real} [_scale]
	/// @param {Bool} [_lock_w]
	/// @param {Bool} [_lock_h]
	/// @return {Struct.EchoChamberTextInput}
	static SetForceSizeFromBorderSprite = function(_scale = 1, _lock_w = true, _lock_h = true) {
		__StoreForceSizePrevIfNeeded();
		force_size_kind = "border";
		force_size_sprite = -1;
		force_size_scale = max(0, _scale);
		force_size_lock_w = (_lock_w == true);
		force_size_lock_h = (_lock_h == true);
		__ApplyForceSizeNow(undefined);
		return self;
	};

	/// @desc Force this control size to match a sprite asset.
	/// @param {Any} _spr
	/// @param {Real} [_scale]
	/// @param {Bool} [_lock_w]
	/// @param {Bool} [_lock_h]
	/// @return {Struct.EchoChamberTextInput}
	static SetForceSizeFromSprite = function(_spr, _scale = 1, _lock_w = true, _lock_h = true) {
		if (_spr == -1 || !sprite_exists(_spr)) {
			return self;
		}
		__StoreForceSizePrevIfNeeded();
		force_size_kind = "custom";
		force_size_sprite = _spr;
		force_size_scale = max(0, _scale);
		force_size_lock_w = (_lock_w == true);
		force_size_lock_h = (_lock_h == true);
		__ApplyForceSizeNow(undefined);
		return self;
	};

	/// @desc Clear forced sizing and restore previous layout sizing.
	/// @return {Struct.EchoChamberTextInput}
	static ClearForceSize = function() {
		if (__force_prev_stored) {
			preferred_width = __force_prev_pref_w;
			preferred_height = __force_prev_pref_h;
			fill_width = __force_prev_fill_width;
		}
		force_size_kind = "none";
		force_size_sprite = -1;
		force_size_scale = 1;
		force_size_lock_w = true;
		force_size_lock_h = true;
		__force_prev_stored = false;
		__force_prev_lock_w = true;
		__force_prev_lock_h = true;
		return self;
	};

	/// @ignore
	static __PreLayout = function(_root, _panel, _width) {
		if (force_size_kind != "none") {
			__ApplyForceSizeNow(_root);
		}
	};

	/// @ignore
	static __MulColor = function(_a, _b) {
		var _ar = colour_get_red(_a);
		var _ag = colour_get_green(_a);
		var _ab = colour_get_blue(_a);
		var _br = colour_get_red(_b);
		var _bg = colour_get_green(_b);
		var _bb = colour_get_blue(_b);
		return make_colour_rgb(
		round((_ar * _br) / 255),
		round((_ag * _bg) / 255),
		round((_ab * _bb) / 255)
		);
	};

	/// @ignore
	static __ApplySkinTint = function(_col, _alpha) {
		var _c = _col;
		var _a = _alpha;
		if (skin_tint_enabled) {
			_c = __MulColor(_c, skin_tint_color);
			_a *= skin_tint_alpha_mul;
		}
		return { col: _c, alpha: _a };
	};

	/// @ignore
	static __StoreForceSizePrevIfNeeded = function() {
		if (__force_prev_stored) {
			return;
		}
		__force_prev_pref_w = preferred_width;
		__force_prev_pref_h = preferred_height;
		__force_prev_fill_width = (fill_width == true);
		__force_prev_lock_w = (force_size_lock_w == true);
		__force_prev_lock_h = (force_size_lock_h == true);
		__force_prev_stored = true;
	};

	/// @ignore
	static __ResolveForceSizeSprite = function(_root) {
		var _spr = -1;
		if (force_size_kind == "bg") {
			_spr = skin_bg_sprite;
			if (_spr < 0 && is_struct(_root) && is_instanceof(_root, EchoChamberRoot)) {
				var _styles = _root.theme.textinput_styles;
				var _st = _styles[$ style_id] ?? _styles[$ "_default"];
				_spr = _st[$ "input_bg_sprite"] ?? -1;
			}
		}
		else if (force_size_kind == "border") {
			_spr = skin_border_sprite;
			if (_spr < 0 && is_struct(_root) && is_instanceof(_root, EchoChamberRoot)) {
				var _styles = _root.theme.textinput_styles;
				var _st = _styles[$ style_id] ?? _styles[$ "_default"];
				_spr = _st[$ "input_border_sprite"] ?? -1;
			}
		}
		else if (force_size_kind == "custom") {
			_spr = force_size_sprite;
		}
		return _spr;
	};

	/// @ignore
	static __ApplyForceSizeNow = function(_root) {
		if (!__force_prev_stored) {
			__StoreForceSizePrevIfNeeded();
		}

		var _spr = __ResolveForceSizeSprite(_root);
		if (_spr < 0) return;

		if (!sprite_exists(_spr)) {
			return;
		}

		var _lock_w = (force_size_lock_w == true);
		var _lock_h = (force_size_lock_h == true);

		var _scale = force_size_scale;
		if (!is_real(_scale) || _scale <= 0) {
			_scale = 1;
		}

		var _w = max(0, round(sprite_get_width(_spr) * _scale));
		var _h = max(0, round(sprite_get_height(_spr) * _scale));

		// Switching lock flags: restore previous sizing once when unlocking.
		if (__force_prev_lock_w && !_lock_w) {
			preferred_width = __force_prev_pref_w;
			fill_width = __force_prev_fill_width;
		}
		if (__force_prev_lock_h && !_lock_h) {
			preferred_height = __force_prev_pref_h;
		}

		// Only touch locked dimensions during layout.
		if (_lock_w) {
			preferred_width = _w;
			fill_width = false;
		}

		if (_lock_h) {
			preferred_height = _h;
		}

		__force_prev_lock_w = _lock_w;
		__force_prev_lock_h = _lock_h;
	};

	/// @ignore
	static __GetDesiredHeightForWidth = function(_root, _panel, _width) {
		var _h = 0;
		if (is_instanceof(_panel, EchoChamberPanel) && _panel.row_height > 0) {
			_h = _panel.row_height;
		}
		else if (is_instanceof(_root, EchoChamberRoot)) {
			_h = _root.default_row_height;
		}

		var _msg = string(validation_message);
		if (!validation_visible || string_length(_msg) <= 0) {
			return _h;
		}

		var _mode = string(validation_display);
		if (_mode == "tooltip") {
			return _h;
		}

		var _styles = _root.theme.textinput_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _gap = max(0, _st[$ "validation_gap"] ?? 4);
		var _font = _st[$ "validation_font"] ?? _root.theme.font_small;

		var _pad_x = __ResolvePaddingX(_root);
		var _mw = max(0, _width - (_pad_x * 2));

		var _old = draw_get_font();
		draw_set_font(_font);
		var _mh = string_height_ext(_msg, -1, _mw);
		draw_set_font(_old);

		return _h + _gap + _mh;
	};

	static __GetValue = function() {
		if (is_struct(bind_struct) && bind_key != "") {
			var _v = bind_struct[$ bind_key];
			return is_undefined(_v) ? "" : string(_v);
		}
		return "";
	};

	static __SetValue = function(_v) {
		if (is_struct(bind_struct) && bind_key != "") {
			bind_struct[$ bind_key] = string(_v);
		}
		if (is_callable(on_change)) {
			on_change(string(_v));
		}
	};

	/// @desc Process input and draw the text input control.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _hover  = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;
		var _active = _root.IsActiveTextInput(id);
		if (!enabled && _active) {
			_root.BlurTextInput(id);
			_active = false;
		}

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		var _config = {
			read_only : read_only,
			max_length : max_length,
			allow_chars : allow_chars,
			deny_chars : deny_chars,
			numeric_only : numeric_only,
			numeric_allow_decimal : numeric_allow_decimal,
			numeric_allow_negative : numeric_allow_negative,
			select_all_on_focus : select_all_on_focus,
			transformers : transforms,
			auto_trim : auto_trim,
			auto_upper : auto_upper,
			auto_lower : auto_lower,
			filter_fn : filter_fn,
			on_live_change : on_live_change,
			on_submit : on_submit,
			on_cancel : on_cancel,
			on_focus : on_focus,
			on_blur : on_blur,
			live_change_rate_ms : live_change_rate_ms,
			input_mode : input_mode,
			tab_inserts : tab_inserts,
			tab_use_spaces : tab_use_spaces,
			tab_spaces : tab_spaces,
			auto_indent : auto_indent,
			password_mask : password_mask,
			password_mask_char : password_mask_char,
			password_allow_copy : password_allow_copy
		};

		if (_active) {
			_root.text_input_config = _config;
		}

		// Keyboard: start editing when focused and Enter is pressed.
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled && !_active) {
			var _current_kb = __GetValue();
			_root.FocusTextInput(id, _current_kb, placeholder, method(self, function(_final) {
				self.__SetValue(_final);
			}), _config);
			_active = true;
		}

		// Click handling: focus and consume clicks while active
		if (_hover && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			_root.FocusControl(id, _rect);
			var _label_proxy_click = (_root.__field_label_proxy_click_id == id);
			var _activated_this_click = false;
			if (!_active) {
				var _current = __GetValue();
				_root.FocusTextInput(id, _current, placeholder, method(self, function(_final) {
					self.__SetValue(_final);
				}), _config);
				_active = true;
				_activated_this_click = true;
			}
			if (_active && !_label_proxy_click) {
				var _pad_x = __ResolvePaddingX(_root);
				var _tx1 = _x1 + _pad_x;
				var _tx2 = _x2 - _pad_x;
				var _text_for_caret = _root.GetActiveText();
				if (password_mask) {
					var _mc = string(password_mask_char);
					if (string_length(_mc) <= 0) _mc = "*";
					_mc = string_char_at(_mc, 1);
					_text_for_caret = string_repeat(_mc, string_length(_text_for_caret));
				}
				var _vp_l = __ResolveTextViewport(_root, _tx1, _tx2, _text_for_caret, _config, true);
				var _local_x = _mx - _vp_l.x;
				var _caret_index = _root.__TextInputIndexFromX(_text_for_caret, _root.theme.font_body, _local_x, _config);
				var _skip_click_select = (_activated_this_click && (_config[$ "select_all_on_focus"] == true) && !keyboard_check(vk_shift));
				if (!_skip_click_select) {
					var _click_count = _root.__TextInputRegisterClick(id, _caret_index);
					_root.__TextInputBeginMouseSelection(_caret_index, keyboard_check(vk_shift), _click_count);
				}
				else if (!_label_proxy_click) {
					_root.__TextInputRegisterClick(id, _caret_index);
				}
			}
			_root.ConsumeMouse();
		}

		// Right click: open context menu.
		if (_hover && _root.mouse_r_pressed && !_root.mouse_consumed && enabled) {
			_root.FocusControl(id, _rect);
			if (!_active) {
				var _current_r = __GetValue();
				_root.FocusTextInput(id, _current_r, placeholder, method(self, function(_final) {
					self.__SetValue(_final);
				}), _config);
				_active = true;
			}

			if (_active) {
				var _pad_xr = __ResolvePaddingX(_root);
				var _tx1r = _x1 + _pad_xr;
				var _tx2r = _x2 - _pad_xr;
				var _map_text = _root.GetActiveText();
				if (password_mask) {
					var _mc = string(password_mask_char);
					if (string_length(_mc) <= 0) _mc = "*";
					_mc = string_char_at(_mc, 1);
					_map_text = string_repeat(_mc, string_length(_map_text));
				}
				var _vp_r = __ResolveTextViewport(_root, _tx1r, _tx2r, _map_text, _config, true);
				var _local_xr = _mx - _vp_r.x;
				var _caret_r = _root.__TextInputIndexFromX(_map_text, _root.theme.font_body, _local_xr, _config);

				var _inside_sel = false;
				if (_root.__TextInputHasSelection()) {
					var _r = _root.__TextInputGetSelectionRange();
					_inside_sel = (_caret_r >= _r.start && _caret_r < _r._end);
				}

				if (!_inside_sel) {
					_root.__TextInputSetCaret(_caret_r, false);
				}

				var _has_sel = _root.__TextInputHasSelection();
				var _read = (read_only == true);
				var _undo_ok = !_read && is_array(_root.text_undo_stack) && array_length(_root.text_undo_stack) > 0;
				var _redo_ok = !_read && is_array(_root.text_redo_stack) && array_length(_root.text_redo_stack) > 0;
				var _clip = clipboard_get_text();
				var _clip_ok = !_read && !is_undefined(_clip) && string_length(string(_clip)) > 0;
				var _copy_ok = _has_sel && (!password_mask || password_allow_copy);
				var _cut_ok = _has_sel && !_read && (!password_mask || password_allow_copy);

				var _items = [];
				array_push(_items, { label: "Undo", enabled: _undo_ok, shortcut: "Ctrl+Z", on_click: method({ root: _root }, function() { root.__TextInputUndo(); }) });
				array_push(_items, { label: "Redo", enabled: _redo_ok, shortcut: "Ctrl+Y", on_click: method({ root: _root }, function() { root.__TextInputRedo(); }) });
				array_push(_items, { is_separator: true });
				array_push(_items, { label: "Cut", enabled: _cut_ok, shortcut: "Ctrl+X", on_click: method({ root: _root }, function() { root.__TextInputCutSelection(); }) });
				array_push(_items, { label: "Copy", enabled: _copy_ok, shortcut: "Ctrl+C", on_click: method({ root: _root }, function() { root.__TextInputCopySelection(); }) });
				array_push(_items, { label: "Paste", enabled: _clip_ok, shortcut: "Ctrl+V", on_click: method({ root: _root, cfg: _config }, function() { root.__TextInputPasteClipboard(cfg); }) });
				array_push(_items, { is_separator: true });
				array_push(_items, { label: "Select All", enabled: true, shortcut: "Ctrl+A", on_click: method({ root: _root }, function() { root.__TextInputSelectAll(); }) });

				_root.OpenContextMenu(_items, _mx, _my, owner_window, style_id);
			}

			_root.ConsumeMouse();
		}

		if (_active && _root.text_mouse_selecting && _root.text_mouse_select_id == id && !_root.mouse_l_pressed) {
			var _pad_x2 = __ResolvePaddingX(_root);
			var _tx1b = _x1 + _pad_x2;
			var _tx2b = _x2 - _pad_x2;
			var _clamped_x = clamp(_mx, _tx1b, _tx2b);
			var _drag_text = _root.GetActiveText();
			if (password_mask) {
				var _mc = string(password_mask_char);
				if (string_length(_mc) <= 0) _mc = "*";
				_mc = string_char_at(_mc, 1);
				_drag_text = string_repeat(_mc, string_length(_drag_text));
			}
			var _vp_d = __ResolveTextViewport(_root, _tx1b, _tx2b, _drag_text, _config, true);
			var _local_x2 = _clamped_x - _vp_d.x;
			var _drag_index = _root.__TextInputIndexFromX(_drag_text, _root.theme.font_body, _local_x2, _config);
			_root.__TextInputUpdateMouseSelection(_drag_index);
		}

		// While active, register our rect so the root can detect click-outside blur on the next click.
		if (_active) {
			_root.__SetActiveTextInputRect(id, _rect);
		}

		// Pull content
		var _display_text = "";
		var _stored = __GetValue();
		var _is_placeholder = false;
		if (_active) {
			_display_text = _root.GetActiveText();
		}
		else if (string_length(_stored) <= 0) {
			_display_text = placeholder;
			_is_placeholder = true;
		}
		else {
			_display_text = _stored;
		}

		if (password_mask && !_is_placeholder) {
			var _mc = string(password_mask_char);
			if (string_length(_mc) <= 0) _mc = "*";
			_mc = string_char_at(_mc, 1);
			var _lenm = string_length(_display_text);
			_display_text = (_lenm > 0) ? string_repeat(_mc, _lenm) : "";
		}

		// Style
		var _styles = _root.theme.textinput_styles;

		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _txt_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.95;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _txt_alpha_base = _st[$ "text_alpha"] ?? 1;
		var _ph_col   = _st[$ "placeholder"] ?? make_color_rgb(150, 160, 180);
		var _ph_alpha = _st[$ "placeholder_alpha"] ?? 0.6;

		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _txt_disabled = _st[$ "text_disabled"] ?? _txt_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _txt_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _txt_alpha_base;

		var _bg_readonly = _st[$ "bg_readonly"] ?? _bg_base;
		var _bd_readonly = _st[$ "border_readonly"] ?? _bd_base;
		var _txt_readonly = _st[$ "text_readonly"] ?? _txt_base;
		var _bg_readonly_alpha = _st[$ "bg_readonly_alpha"] ?? _bg_alpha_base;
		var _bd_readonly_alpha = _st[$ "border_readonly_alpha"] ?? _bd_alpha_base;
		var _txt_readonly_alpha = _st[$ "text_readonly_alpha"] ?? _txt_alpha_base;

		var _bg_invalid = _st[$ "bg_invalid"] ?? _bg_base;
		var _bd_invalid = _st[$ "border_invalid"] ?? _bd_base;
		var _txt_invalid = _st[$ "text_invalid"] ?? _txt_base;
		var _bg_invalid_alpha = _st[$ "bg_invalid_alpha"] ?? _bg_alpha_base;
		var _bd_invalid_alpha = _st[$ "border_invalid_alpha"] ?? _bd_alpha_base;
		var _txt_invalid_alpha = _st[$ "text_invalid_alpha"] ?? _txt_alpha_base;

		var _pressed_mix = _st[$ "pressed_mix"] ?? 0.22;
		var _state_override = false;
		if (!enabled) {
			_bg_base = _bg_disabled;
			_bd_base = _bd_disabled;
			_txt_base = _txt_disabled;
			_bg_alpha_base = _bg_disabled_alpha;
			_bd_alpha_base = _bd_disabled_alpha;
			_txt_alpha_base = _txt_disabled_alpha;
			_state_override = true;
		}
		else if (invalid) {
			_bg_base = _bg_invalid;
			_bd_base = _bd_invalid;
			_txt_base = _txt_invalid;
			_bg_alpha_base = _bg_invalid_alpha;
			_bd_alpha_base = _bd_invalid_alpha;
			_txt_alpha_base = _txt_invalid_alpha;
			_state_override = true;
		}
		else if (read_only) {
			_bg_base = _bg_readonly;
			_bd_base = _bd_readonly;
			_txt_base = _txt_readonly;
			_bg_alpha_base = _bg_readonly_alpha;
			_bd_alpha_base = _bd_readonly_alpha;
			_txt_alpha_base = _txt_readonly_alpha;
			_state_override = true;
		}

		var _bg_hover = _state_override ? merge_color(_bg_base, _txt_base, 0.12) : (_st[$ "bg_hover"] ?? merge_color(_bg_base, _txt_base, 0.12));
		var _bd_hover = _state_override ? _bd_base : (_st[$ "border_hover"] ?? _bd_base);
		var _txt_hover = _state_override ? _txt_base : (_st[$ "text_hover"] ?? _txt_base);
		var _bg_hover_alpha = _state_override ? _bg_alpha_base : (_st[$ "bg_hover_alpha"] ?? _bg_alpha_base);
		var _bd_hover_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_hover_alpha"] ?? _bd_alpha_base);
		var _txt_hover_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_hover_alpha"] ?? _txt_alpha_base);

		var _bg_active = _state_override ? merge_color(_bg_base, _txt_base, 0.2) : (_st[$ "bg_active"] ?? merge_color(_bg_base, _txt_base, 0.2));
		var _bd_active = _state_override ? _bd_base : (_st[$ "border_active"] ?? _bd_base);
		var _txt_active = _state_override ? _txt_base : (_st[$ "text_active"] ?? _txt_base);
		var _bg_active_alpha = _state_override ? _bg_alpha_base : (_st[$ "bg_active_alpha"] ?? _bg_alpha_base);
		var _bd_active_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_active_alpha"] ?? _bd_alpha_base);
		var _txt_active_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_active_alpha"] ?? _txt_alpha_base);

		var _bg_pressed = _state_override ? merge_color(_bg_hover, _txt_base, _pressed_mix) : (_st[$ "bg_pressed"] ?? merge_color(_bg_hover, _txt_base, _pressed_mix));
		var _bd_pressed = _state_override ? _bd_base : (_st[$ "border_pressed"] ?? _bd_hover);
		var _txt_pressed = _state_override ? _txt_base : (_st[$ "text_pressed"] ?? _txt_hover);
		var _bg_pressed_alpha = _state_override ? _bg_hover_alpha : (_st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha);
		var _bd_pressed_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_pressed_alpha"] ?? _bd_hover_alpha);
		var _txt_pressed_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_pressed_alpha"] ?? _txt_hover_alpha);

		var _sel_bg = _st[$ "selection_bg"] ?? merge_color(_txt_base, _bg_base, 0.35);
		var _sel_text = _st[$ "selection_text"] ?? _txt_base;
		var _sel_bg_inactive = _st[$ "selection_bg_inactive"] ?? _sel_bg;
		var _sel_text_inactive = _st[$ "selection_text_inactive"] ?? _sel_text;
		var _sel_bg_alpha = _st[$ "selection_bg_alpha"] ?? 1;
		var _sel_text_alpha = _st[$ "selection_text_alpha"] ?? _txt_alpha_base;
		var _sel_bg_inactive_alpha = _st[$ "selection_bg_inactive_alpha"] ?? _sel_bg_alpha;
		var _sel_text_inactive_alpha = _st[$ "selection_text_inactive_alpha"] ?? _sel_text_alpha;

		var _caret_col = _st[$ "caret_color"] ?? _txt_base;
		var _caret_alpha = _st[$ "caret_alpha"] ?? 1;
		var _caret_char = _st[$ "caret_char"] ?? "|";
		var _caret_blink_ms = _st[$ "caret_blink_ms"] ?? 520;
		var _caret_w = max(1, _st[$ "caret_width"] ?? 1);
		var _caret_h = _st[$ "caret_height"] ?? 0;
		var _caret_inset_x = _st[$ "caret_inset_x"] ?? 0;
		var _caret_inset_y = _st[$ "caret_inset_y"] ?? 0;

		var _validation_msg = string(validation_message);
		var _show_validation = validation_visible && string_length(_validation_msg) > 0;
		var _validation_mode = string(validation_display);

		var _validation_gap = max(0, _st[$ "validation_gap"] ?? 4);
		var _validation_alpha = _st[$ "validation_alpha"] ?? 0.9;
		var _validation_font = _st[$ "validation_font"] ?? _root.theme.font_small;

		var _validation_col = _st[$ "validation_error"] ?? _root.theme.col_error;
		if (validation_kind == "warn") {
			_validation_col = _st[$ "validation_warn"] ?? _validation_col;
		}
		else if (validation_kind == "info") {
			_validation_col = _st[$ "validation_info"] ?? _validation_col;
		}

		var _w = max(0, _x2 - _x1);
		var _desired = __GetDesiredHeightForWidth(_root, _panel, _w);
		var _use_inline = false;
		if (_show_validation) {
			if (_validation_mode == "inline") {
				_use_inline = true;
			}
			else if (_validation_mode == "tooltip") {
				_use_inline = false;
			}
			else {
				_use_inline = ((_y2 - _y1) >= (_desired - 0.01));
			}
		}

		var _msg_h = 0;
		var _msg_area = 0;
		if (_show_validation && _use_inline) {
			var _pad_xm = __ResolvePaddingX(_root);
			var _mw = max(0, _w - (_pad_xm * 2));
			var _oldf = draw_get_font();
			draw_set_font(_validation_font);
			_msg_h = string_height_ext(_validation_msg, -1, _mw);
			draw_set_font(_oldf);
			_msg_area = _validation_gap + _msg_h;
		}

		var _y2_body = _y2;
		if (_show_validation && _use_inline) {
			_y2_body = max(_y1, _y2 - _msg_area);
		}

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _txt_col = _txt_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _txt_alpha = _txt_alpha_base;
		if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_txt_col = _txt_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_txt_alpha = _txt_pressed_alpha;
		}
		else if (_active) {
			_bg_col = _bg_active;
			_bd_col = _bd_active;
			_txt_col = _txt_active;
			_bg_alpha = _bg_active_alpha;
			_bd_alpha = _bd_active_alpha;
			_txt_alpha = _txt_active_alpha;
		}
		else if (_hover && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_txt_col = _txt_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_txt_alpha = _txt_hover_alpha;
		}

		// Background
		var _old_alpha = draw_get_alpha();

		var _w_draw = max(0, _x2 - _x1);
		var _h_draw = max(0, _y2_body - _y1);

		var _bg_spr = skin_bg_sprite;
		var _bg_sub = skin_bg_subimg;
		if (_bg_spr < 0) {
			_bg_spr = _st[$ "input_bg_sprite"] ?? -1;
			_bg_sub = 0;
		}
		var _bd_spr = skin_border_sprite;
		var _bd_sub = skin_border_subimg;
		if (_bd_spr < 0) {
			_bd_spr = _st[$ "input_border_sprite"] ?? -1;
			_bd_sub = 0;
		}

		if (_bg_spr != -1 && sprite_exists(_bg_spr)) {
			var _tbg = __ApplySkinTint(_bg_col, _old_alpha * _bg_alpha);
			draw_sprite_stretched_ext(_bg_spr, _bg_sub, _x1, _y1, _w_draw, _h_draw, _tbg.col, _tbg.alpha);
		}
		else {
			draw_set_alpha(_old_alpha * _bg_alpha);
			draw_set_color(_bg_col);
			draw_rectangle(_x1, _y1, _x2, _y2_body, false);
		}

		if (_bd_spr != -1 && sprite_exists(_bd_spr)) {
			var _tbd = __ApplySkinTint(_bd_col, _old_alpha * _bd_alpha);
			draw_sprite_stretched_ext(_bd_spr, _bd_sub, _x1, _y1, _w_draw, _h_draw, _tbd.col, _tbd.alpha);
		}
		else {
			draw_set_alpha(_old_alpha * _bd_alpha);
			draw_set_color(_bd_col);
			draw_rectangle(_x1, _y1, _x2, _y2_body, true);
		}
		draw_set_alpha(_old_alpha);

		// Text
		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);

		var _pad_x3 = __ResolvePaddingX(_root);
		var _tx1c = _x1 + _pad_x3;
		var _tx2c = _x2 - _pad_x3;
		var _text_h = string_height("Hg");
		var _ty     = _y1 + ((_y2_body - _y1) - _text_h) * 0.5;
		var _display_text_draw = _root.__TextInputExpandTabsVisual(_display_text, _config);

		var _vp = __ResolveTextViewport(_root, _tx1c, _tx2c, _display_text, _config, _active);
		var _text_w = _vp.text_w;
		var _view_w = _vp.view_w;
		var _scroll_x = _vp.scroll_x;
		var _text_x = _vp.x;
		var _caret_px = 0;
		if (_active) {
			var _caret_index = _root.text_caret_index;
			var _prefix = (_caret_index > 0) ? string_copy(_display_text, 1, _caret_index) : "";
			_caret_px = (_caret_index > 0) ? _root.__TextInputMeasureVisualWidth(_prefix, _root.theme.font_body, _config) : 0;
			if (_vp.overflow) {
				var _pad_scroll = 2;
				if (_caret_px - _scroll_x < _pad_scroll) {
					_scroll_x = max(0, _caret_px - _pad_scroll);
				}
				else if (_caret_px - _scroll_x > (_view_w - _pad_scroll)) {
					_scroll_x = min(max(0, _text_w - _view_w), _caret_px - (_view_w - _pad_scroll));
				}
				_root.text_scroll_x = _scroll_x;
				_text_x = _tx1c - _scroll_x;
			}
			else {
				_root.text_scroll_x = 0;
			}
		}

		_root.PushClipRect(_tx1c, _y1, _tx2c, _y2_body);

		if (_active && _root.__TextInputHasSelection() && !_is_placeholder) {
			var _range = _root.__TextInputGetSelectionRange();
			var _sel_prefix = (_range.start > 0) ? string_copy(_display_text, 1, _range.start) : "";
			var _sel_suffix = (_range._end > 0) ? string_copy(_display_text, 1, _range._end) : "";
			var _sel_x1 = _text_x + _root.__TextInputMeasureVisualWidth(_sel_prefix, _root.theme.font_body, _config);
			var _sel_x2 = _text_x + _root.__TextInputMeasureVisualWidth(_sel_suffix, _root.theme.font_body, _config);
			if (_sel_x2 < _sel_x1) {
				var _tmp = _sel_x1;
				_sel_x1 = _sel_x2;
				_sel_x2 = _tmp;
			}
			var _sel_bg_col = _active ? _sel_bg : _sel_bg_inactive;
			var _sel_bg_alpha_use = _active ? _sel_bg_alpha : _sel_bg_inactive_alpha;
			draw_set_alpha(_old_alpha * _sel_bg_alpha_use);
			draw_set_color(_sel_bg_col);
			draw_rectangle(_sel_x1, _ty, _sel_x2, _ty + _text_h, false);
			draw_set_alpha(_old_alpha);
		}

		if (_is_placeholder) {
			draw_set_color(_ph_col);
			draw_set_alpha(_old_alpha * _txt_alpha * _ph_alpha);
		}
		else {
			draw_set_color(_txt_col);
			draw_set_alpha(_old_alpha * _txt_alpha);
		}
		draw_text(_text_x, _ty, _display_text_draw);
		draw_set_alpha(_old_alpha);

		if (_active && _root.__TextInputHasSelection() && !_is_placeholder) {
			var _range2 = _root.__TextInputGetSelectionRange();
			var _sel_prefix2 = (_range2.start > 0) ? string_copy(_display_text, 1, _range2.start) : "";
			var _sel_suffix2 = (_range2._end > 0) ? string_copy(_display_text, 1, _range2._end) : "";
			var _sel_x1b = _text_x + _root.__TextInputMeasureVisualWidth(_sel_prefix2, _root.theme.font_body, _config);
			var _sel_x2b = _text_x + _root.__TextInputMeasureVisualWidth(_sel_suffix2, _root.theme.font_body, _config);
			if (_sel_x2b < _sel_x1b) {
				var _tmp2 = _sel_x1b;
				_sel_x1b = _sel_x2b;
				_sel_x2b = _tmp2;
			}
			_root.PushClipRect(_sel_x1b, _y1, _sel_x2b, _y2);
			var _sel_text_col = _active ? _sel_text : _sel_text_inactive;
			var _sel_text_alpha_use = _active ? _sel_text_alpha : _sel_text_inactive_alpha;
			draw_set_alpha(_old_alpha * _sel_text_alpha_use);
			draw_set_color(_sel_text_col);
			draw_text(_text_x, _ty, _display_text_draw);
			draw_set_alpha(_old_alpha);
			_root.PopClipRect();
		}

		if (_active && !read_only && !_is_placeholder) {
			if (_caret_blink_ms > 0) {
				if ((current_time - _root.text_caret_blink_time) >= _caret_blink_ms) {
					_root.text_caret_visible = !_root.text_caret_visible;
					_root.text_caret_blink_time = current_time;
				}
			}
			var _show_caret = (_caret_blink_ms <= 0) || _root.text_caret_visible;
			if (_show_caret) {
				var _caret_x = _text_x + _caret_px + _caret_inset_x;
				var _caret_height = (_caret_h > 0) ? _caret_h : _text_h;
				var _caret_y = _ty + ((_text_h - _caret_height) * 0.5) + _caret_inset_y;

				var _caret_spr = skin_caret_sprite;
				var _caret_sub = skin_caret_subimg;
				if (_caret_spr < 0) {
					_caret_spr = _st[$ "input_caret_sprite"] ?? -1;
					_caret_sub = 0;
				}

				if (_caret_spr != -1 && sprite_exists(_caret_spr)) {
					var _tcr = __ApplySkinTint(_caret_col, _old_alpha * _caret_alpha);
					draw_sprite_stretched_ext(_caret_spr, _caret_sub, _caret_x, _caret_y, _caret_w, _caret_height, _tcr.col, _tcr.alpha);
				}
				else {
					draw_set_alpha(_old_alpha * _caret_alpha);
					draw_set_color(_caret_col);
					if (string_length(_caret_char) > 0) {
						draw_text(_caret_x, _ty + _caret_inset_y, _caret_char);
					}
					else {
						draw_rectangle(_caret_x, _caret_y, _caret_x + _caret_w, _caret_y + _caret_height, false);
					}
				}
				draw_set_alpha(_old_alpha);
			}
		}

		_root.PopClipRect();

		draw_set_font(_old_font);

		// Validation message
		if (_show_validation) {
			var _need_tip = (_validation_mode == "tooltip") || (!_use_inline) || ((_validation_mode == "inline") && ((_y2 - _y1) < (_desired - 0.01)));
			var _tip = "";
			if (_need_tip) {
				_tip = _validation_msg;
				if (string_length(tooltip) > 0) {
					_tip += "\n\n" + string(tooltip);
				}
			}
			if (_use_inline) {
				var _oldf2 = draw_get_font();
				var _oldc2 = draw_get_colour();
				var _olda2 = draw_get_alpha();
				draw_set_font(_validation_font);
				draw_set_color(_validation_col);
				draw_set_alpha(_olda2 * _validation_alpha);
				var _pad_xv = __ResolvePaddingX(_root);
				var _vx = _x1 + _pad_xv;
				var _vw2 = max(0, (_x2 - _x1) - (_pad_xv * 2));
				_root.PushClipRect(_x1, _y1, _x2, _y2);
				draw_text_ext(_vx, _y2_body + _validation_gap, _validation_msg, -1, _vw2);
				_root.PopClipRect();
				draw_set_alpha(_olda2);
				draw_set_color(_oldc2);
				draw_set_font(_oldf2);
			}
			if (_hover && string_length(_tip) > 0) {
				_root.RequestTooltip(id, _tip, _mx, _my);
			}
		}

		if (_hover && string_length(tooltip) > 0) {
			if (!_show_validation) {
				_root.RequestTooltip(id, tooltip, _mx, _my);
			}
		}
	};
}

/// @func EchoChamberTextArea(_id)
/// @desc Multi-line text area with vertical scrolling.
/// @param {Any} _id
/// @return {Struct.EchoChamberTextArea}
function EchoChamberTextArea(_id) : EchoChamberTextInput(_id) constructor {
	wrap = true;
	tab_inserts = true;
	visible_rows = 6;
	preferred_height = 0;
	min_height = 48;
	max_height = 0; // 0 = unlimited
	resizable = true;
	show_resize_grip = true;

	scroll_state = new EchoChamberScrollState(id + "_scroll");
	overlay_scroll_state = new EchoChamberScrollState(id + "_overlay_scroll");

	__resize_dragging = false;
	__resize_start_my = 0;
	__resize_start_h = 0;

	use_overlay_editor = true;
	overlay_open = false;
	overlay_working_text = "";
	overlay_text_id = id + "_overlay_text";
	overlay_rect_last = undefined;
	__editor_original_text = "";
	__editor_title = "Edit text";

	__draw_layout = undefined;
	__draw_text_rect = undefined;
	__draw_font = undefined;
	__draw_is_placeholder = false;
	__draw_active = false;
	__draw_state = undefined;
	__draw_config = undefined;

	/// @ignore
	static __CommitFinal = function(_final) {
		__SetValue(_final);
	};

	/// @ignore
	static __CloseOverlay = function(_root) {
		overlay_open = false;
		overlay_rect_last = undefined;
		if (is_struct(_root) && _root.active_overlay_owner_id == id) {
			_root.ClearActiveOverlayOwner();
		}
	};

	/// @ignore
	static __OverlayCancel = function(_root) {
		if (!is_struct(_root)) return;
		__CloseOverlay(_root);
		_root.CancelTextInput(id);
	};

	/// @ignore
	static __OverlayDone = function(_root) {
		if (!is_struct(_root)) return;
		__CloseOverlay(_root);
		_root.BlurTextInput(id);
	};

	/// @ignore
	static __OpenOverlayEditorFromMenu = function(_root, _config) {
		if (!use_overlay_editor) return;
		if (!is_instanceof(_root, EchoChamberRoot)) return;

		__editor_original_text = _root.IsActiveTextInput(id) ? _root.GetActiveText() : __GetValue();
		overlay_open = true;
		_root.SetActiveOverlayOwner(id);
		overlay_scroll_state.scroll_y = 0;
		overlay_scroll_state.dragging = false;
		overlay_scroll_state.drag_offset_y = 0;

		if (!_root.IsActiveTextInput(id)) {
			_root.FocusTextInput(id, __editor_original_text, placeholder, method(self, __CommitFinal), _config);
		}
	};

	/// @ignore
	static __GetEditorStyleValue = function(_editor_style, _editor_default, _key, _fallback) {
		var _value = undefined;
		if (is_struct(_editor_style)) {
			_value = _editor_style[$ _key];
		}
		if (is_undefined(_value) && is_struct(_editor_default)) {
			_value = _editor_default[$ _key];
		}
		if (is_undefined(_value)) {
			_value = _fallback;
		}
		return _value;
	};

	/// @ignore
	static __DrawOverlay = function(_root) {
		if (!overlay_open) {
			return;
		}
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return;
		}
		var _input_enabled = !_root.IsContextMenuOpen();
		if (_input_enabled) {
			_root.SetActiveOverlayOwner(id);
		}

		// Esc closes (Cancel).
		if (_input_enabled && _root.__ConsumeOverlayCloseRequest(id)) {
			__OverlayCancel(_root);
			return;
		}

		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();

		var _styles = _root.theme.textinput_styles;
		var _st_default = _styles[$ "_default"];
		var _st_style = _styles[$ style_id];
		if (!is_struct(_st_style)) {
			_st_style = _st_default;
		}
		var _editor_style = is_struct(_st_style) ? (_st_style[$ "editor"]) : undefined;
		var _editor_default = is_struct(_st_default) ? (_st_default[$ "editor"]) : undefined;

		var _config = _root.text_input_config;
		if (!is_struct(_config)) {
			_config = {
				multiline : true,
				wrap : wrap,
				tab_inserts : tab_inserts,
				tab_use_spaces : tab_use_spaces,
				tab_spaces : tab_spaces,
				view_w : 0,
				view_h : 0,
				font : _root.theme.font_body,
				scroll_state : overlay_scroll_state,
				read_only : read_only,
				max_length : max_length,
				allow_chars : allow_chars,
				deny_chars : deny_chars,
				numeric_only : numeric_only,
				numeric_allow_decimal : numeric_allow_decimal,
				numeric_allow_negative : numeric_allow_negative,
				select_all_on_focus : select_all_on_focus,
				transformers : transforms,
				auto_trim : auto_trim,
				auto_upper : auto_upper,
				auto_lower : auto_lower,
				filter_fn : filter_fn,
				on_live_change : on_live_change,
				on_submit : on_submit,
				on_cancel : on_cancel,
				on_focus : on_focus,
				on_blur : on_blur,
				live_change_rate_ms : live_change_rate_ms,
				input_mode : input_mode,
				auto_indent : auto_indent,
				password_mask : password_mask,
				password_mask_char : password_mask_char,
				password_allow_copy : password_allow_copy
			};
		}

		var _pr = overlay_rect_last;
		if (!is_struct(_pr)) {
			var _margin = __GetEditorStyleValue(_editor_style, _editor_default, "viewport_margin", 16);
			var _min_w = __GetEditorStyleValue(_editor_style, _editor_default, "min_width", 320);
			var _max_w = __GetEditorStyleValue(_editor_style, _editor_default, "max_width", 720);
			var _min_h = __GetEditorStyleValue(_editor_style, _editor_default, "min_height", 240);
			var _max_h = __GetEditorStyleValue(_editor_style, _editor_default, "max_height", 480);
			if (_max_w < _min_w) {
				_max_w = _min_w;
			}
			if (_max_h < _min_h) {
				_max_h = _min_h;
			}
			var _pw = clamp(max(0, _gw - (_margin * 2)), _min_w, _max_w);
			var _ph = clamp(max(0, _gh - (_margin * 2)), _min_h, _max_h);
			var _px1 = floor((_gw - _pw) * 0.5);
			var _py1 = floor((_gh - _ph) * 0.5);
			_pr = { x1: _px1, y1: _py1, x2: _px1 + _pw, y2: _py1 + _ph };
			overlay_rect_last = _pr;
		}

		// Dim background (full screen)
		var _old_a = draw_get_alpha();
		var _dim_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "dim_alpha", 0.55);
		var _dim_color = __GetEditorStyleValue(_editor_style, _editor_default, "dim_color", c_black);
		draw_set_alpha(_old_a * _dim_alpha);
		draw_set_color(_dim_color);
		draw_rectangle(0, 0, _gw, _gh, false);
		draw_set_alpha(_old_a);

		// Panel
		var _x1 = _pr.x1;
		var _y1 = _pr.y1;
		var _x2 = _pr.x2;
		var _y2 = _pr.y2;

		var _bg = __GetEditorStyleValue(_editor_style, _editor_default, "panel_bg", _root.theme.col_window_bg);
		var _bd = __GetEditorStyleValue(_editor_style, _editor_default, "panel_border", _root.theme.col_accent);
		var _bg_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "panel_bg_alpha", 0.96);
		var _bd_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "panel_border_alpha", 1);
		draw_set_alpha(_old_a * _bg_alpha);
		draw_set_color(_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_a * _bd_alpha);
		draw_set_color(_bd);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_a);

		var _pad = __GetEditorStyleValue(_editor_style, _editor_default, "padding", 12);
		var _gap = __GetEditorStyleValue(_editor_style, _editor_default, "gap", 8);
		var _row_h = max(__GetEditorStyleValue(_editor_style, _editor_default, "row_min_height", 18), _root.default_row_height);
		var _btn_h = _row_h;
		var _btn_w = __GetEditorStyleValue(_editor_style, _editor_default, "button_width", 72);
		var _btn_bg = __GetEditorStyleValue(_editor_style, _editor_default, "button_bg", merge_color(_bg, _root.theme.col_text, 0.08));
		var _btn_hover = __GetEditorStyleValue(_editor_style, _editor_default, "button_bg_hover", merge_color(_btn_bg, _root.theme.col_text, 0.12));
		var _btn_border = __GetEditorStyleValue(_editor_style, _editor_default, "button_border", _bd);
		var _btn_bg_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "button_bg_alpha", 1);
		var _btn_border_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "button_border_alpha", 1);
		var _btn_text = __GetEditorStyleValue(_editor_style, _editor_default, "button_text", _root.theme.col_text);
		var _btn_text_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "button_text_alpha", 1);
		var _btn_cancel_inset_x = __GetEditorStyleValue(_editor_style, _editor_default, "button_cancel_inset_x", 12);
		var _btn_done_inset_x = __GetEditorStyleValue(_editor_style, _editor_default, "button_done_inset_x", 18);
		var _title_font = __GetEditorStyleValue(_editor_style, _editor_default, "title_font", _root.theme.font_body);
		var _title_text = __GetEditorStyleValue(_editor_style, _editor_default, "title_text", _root.theme.col_text);
		var _title_text_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "title_text_alpha", 1);
		var _editor_bg = __GetEditorStyleValue(_editor_style, _editor_default, "editor_bg", merge_color(_bg, _root.theme.col_text, 0.05));
		var _editor_border = __GetEditorStyleValue(_editor_style, _editor_default, "editor_border", _bd);
		var _editor_bg_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "editor_bg_alpha", 1);
		var _editor_border_alpha = __GetEditorStyleValue(_editor_style, _editor_default, "editor_border_alpha", 1);
		var _editor_inner_padding = __GetEditorStyleValue(_editor_style, _editor_default, "editor_inner_padding", 6);
		var _editor_scrollbar_extra_w = __GetEditorStyleValue(_editor_style, _editor_default, "editor_scrollbar_extra_w", 2);

		var _btn_y2 = _y2 - _pad;
		var _btn_y1 = _btn_y2 - _btn_h;
		var _btn_done_x2 = _x2 - _pad;
		var _btn_done_x1 = _btn_done_x2 - _btn_w;
		var _btn_cancel_x2 = _btn_done_x1 - _gap;
		var _btn_cancel_x1 = _btn_cancel_x2 - _btn_w;

		var _title_y = _y1 + _pad;
		var _editor_y1 = _title_y + _row_h + _gap;
		var _editor_y2 = _btn_y1 - _gap;
		var _editor_x1 = _x1 + _pad;
		var _editor_x2 = _x2 - _pad;

		// Click outside -> Done (commit).
		var _inside = (_root.mx >= _x1 && _root.mx <= _x2 && _root.my >= _y1 && _root.my <= _y2);
		if (_input_enabled && !_inside && _root.mouse_l_pressed && !_root.mouse_consumed) {
			_root.ConsumeMouse();
			__OverlayDone(_root);
			return;
		}

		// Block wheel from falling through.
		if (_input_enabled && _root.wheel_delta != 0 && !_root.wheel_consumed) {
			_root.ConsumeWheel();
		}

		// Title + buttons
		var _old_font = draw_get_font();
		draw_set_font(_title_font);
		draw_set_alpha(_old_a * _title_text_alpha);
		draw_set_color(_title_text);
		draw_text(_x1 + _pad, _title_y, __editor_title);
		draw_set_alpha(_old_a);

		var _hover_done = _root.HitTestRect(_btn_done_x1, _btn_y1, _btn_done_x2, _btn_y2);
		var _hover_cancel = _root.HitTestRect(_btn_cancel_x1, _btn_y1, _btn_cancel_x2, _btn_y2);

		var _btn_col = _hover_cancel ? _btn_hover : _btn_bg;
		draw_set_alpha(_old_a * _btn_bg_alpha);
		draw_set_color(_btn_col);
		draw_rectangle(_btn_cancel_x1, _btn_y1, _btn_cancel_x2, _btn_y2, false);
		draw_set_alpha(_old_a * _btn_border_alpha);
		draw_set_color(_btn_border);
		draw_rectangle(_btn_cancel_x1, _btn_y1, _btn_cancel_x2, _btn_y2, true);
		draw_set_alpha(_old_a * _btn_text_alpha);
		draw_set_color(_btn_text);
		draw_text(_btn_cancel_x1 + _btn_cancel_inset_x, _btn_y1 + floor((_btn_h - string_height("Ag")) * 0.5), "Cancel");

		_btn_col = _hover_done ? _btn_hover : _btn_bg;
		draw_set_alpha(_old_a * _btn_bg_alpha);
		draw_set_color(_btn_col);
		draw_rectangle(_btn_done_x1, _btn_y1, _btn_done_x2, _btn_y2, false);
		draw_set_alpha(_old_a * _btn_border_alpha);
		draw_set_color(_btn_border);
		draw_rectangle(_btn_done_x1, _btn_y1, _btn_done_x2, _btn_y2, true);
		draw_set_alpha(_old_a * _btn_text_alpha);
		draw_set_color(_btn_text);
		draw_text(_btn_done_x1 + _btn_done_inset_x, _btn_y1 + floor((_btn_h - string_height("Ag")) * 0.5), "Done");
		draw_set_alpha(_old_a);

		if (_input_enabled && _root.mouse_l_pressed && !_root.mouse_consumed) {
			if (_hover_done) {
				_root.ConsumeMouse();
				__OverlayDone(_root);
				draw_set_font(_old_font);
				return;
			}
			else if (_hover_cancel) {
				_root.ConsumeMouse();
				__OverlayCancel(_root);
				draw_set_font(_old_font);
				return;
			}
		}

		// Editor chrome
		var _ed_rect = { x1: _editor_x1, y1: _editor_y1, x2: _editor_x2, y2: _editor_y2 };
		var _ed_inner = { x1: _ed_rect.x1 + 1, y1: _ed_rect.y1 + 1, x2: _ed_rect.x2 - 1, y2: _ed_rect.y2 - 1 };
		draw_set_alpha(_old_a * _editor_bg_alpha);
		draw_set_color(_editor_bg);
		draw_rectangle(_ed_rect.x1, _ed_rect.y1, _ed_rect.x2, _ed_rect.y2, false);
		draw_set_alpha(_old_a * _editor_border_alpha);
		draw_set_color(_editor_border);
		draw_rectangle(_ed_rect.x1, _ed_rect.y1, _ed_rect.x2, _ed_rect.y2, true);
		draw_set_alpha(_old_a);

		var _sb_w = _root.theme.scrollbar_w + _editor_scrollbar_extra_w;
		var _text_rect = { x1: _ed_inner.x1 + _editor_inner_padding, y1: _ed_inner.y1 + _editor_inner_padding, x2: max(_ed_inner.x1 + _editor_inner_padding, _ed_inner.x2 - _editor_inner_padding - _sb_w), y2: _ed_inner.y2 - _editor_inner_padding };
		var _scroll_rect = { x1: _ed_inner.x1 + _editor_inner_padding, y1: _ed_inner.y1 + _editor_inner_padding, x2: _ed_inner.x2 - _editor_inner_padding, y2: _ed_inner.y2 - _editor_inner_padding };
		_config[$ "view_w"] = max(0, _text_rect.x2 - _text_rect.x1);
		_config[$ "view_h"] = max(0, _text_rect.y2 - _text_rect.y1);
		_config[$ "font"] = _root.theme.font_body;
		_config[$ "scroll_state"] = overlay_scroll_state;
		_config[$ "wrap"] = wrap;

		// Keep focus on the same text input id while overlay is open.
		if (_input_enabled && !_root.IsActiveTextInput(id)) {
			_root.FocusTextInput(id, __GetValue(), placeholder, method(self, __CommitFinal), _config);
		}

		// Mouse caret/selection inside editor.
		var _in_editor = (_root.mx >= _text_rect.x1 && _root.mx <= _text_rect.x2 && _root.my >= _text_rect.y1 && _root.my <= _text_rect.y2);
		if (_input_enabled && _in_editor && _root.mouse_l_pressed && !_root.mouse_consumed) {
			var _view_w = max(0, _text_rect.x2 - _text_rect.x1);
			var _layout = _root.__TextAreaGetActiveLayout(_root.theme.font_body, wrap, _view_w, _config);
			var _local_x = (_root.mx - _text_rect.x1) + (wrap ? 0 : _root.text_scroll_x);
			var _local_y = (_root.my - _text_rect.y1) + overlay_scroll_state.scroll_y;
			var _caret_index = _root.__TextAreaIndexFromPoint(_layout, _root.theme.font_body, _local_x, _local_y, _config);
			var _click_count = _root.__TextInputRegisterClick(id, _caret_index);
			_root.__TextInputBeginMouseSelection(_caret_index, keyboard_check(vk_shift), _click_count);
			_root.ConsumeMouse();
		}

		// Right click: open context menu inside overlay editor.
		if (_input_enabled && _in_editor && _root.mouse_r_pressed && !_root.mouse_consumed) {
			var _view_w_r = max(0, _text_rect.x2 - _text_rect.x1);
			var _layout_r = _root.__TextAreaGetActiveLayout(_root.theme.font_body, wrap, _view_w_r, _config);
			var _local_xr = (_root.mx - _text_rect.x1) + (wrap ? 0 : _root.text_scroll_x);
			var _local_yr = (_root.my - _text_rect.y1) + overlay_scroll_state.scroll_y;
			var _caret_r = _root.__TextAreaIndexFromPoint(_layout_r, _root.theme.font_body, _local_xr, _local_yr, _config);

			var _inside_sel = false;
			if (_root.__TextInputHasSelection()) {
				var _r = _root.__TextInputGetSelectionRange();
				_inside_sel = (_caret_r >= _r.start && _caret_r < _r._end);
			}
			if (!_inside_sel) {
				_root.__TextInputSetCaret(_caret_r, false);
			}

			var _has_sel = _root.__TextInputHasSelection();
			var _read = (read_only == true);
			var _undo_ok = !_read && is_array(_root.text_undo_stack) && array_length(_root.text_undo_stack) > 0;
			var _redo_ok = !_read && is_array(_root.text_redo_stack) && array_length(_root.text_redo_stack) > 0;
			var _clip = clipboard_get_text();
			var _clip_ok = !_read && !is_undefined(_clip) && string_length(string(_clip)) > 0;
			var _copy_ok = _has_sel && (!password_mask || password_allow_copy);
			var _cut_ok = _has_sel && !_read && (!password_mask || password_allow_copy);

			var _cfg = _config;

			var _items = [];
			array_push(_items, { label: "Undo", enabled: _undo_ok, shortcut: "Ctrl+Z", on_click: method({ root: _root }, function() { root.__TextInputUndo(); }) });
			array_push(_items, { label: "Redo", enabled: _redo_ok, shortcut: "Ctrl+Y", on_click: method({ root: _root }, function() { root.__TextInputRedo(); }) });
			array_push(_items, { is_separator: true });
			array_push(_items, { label: "Cut", enabled: _cut_ok, shortcut: "Ctrl+X", on_click: method({ root: _root }, function() { root.__TextInputCutSelection(); }) });
			array_push(_items, { label: "Copy", enabled: _copy_ok, shortcut: "Ctrl+C", on_click: method({ root: _root }, function() { root.__TextInputCopySelection(); }) });
			array_push(_items, { label: "Paste", enabled: _clip_ok, shortcut: "Ctrl+V", on_click: method({ root: _root, cfg: _cfg }, function() { root.__TextInputPasteClipboard(cfg); }) });
			array_push(_items, { is_separator: true });
			array_push(_items, { label: "Select All", enabled: true, shortcut: "Ctrl+A", on_click: method({ root: _root }, function() { root.__TextInputSelectAll(); }) });

			array_push(_items, { is_separator: true });

			var _indent_ok = !_read && (tab_inserts == true);
			array_push(_items, { label: "Indent", enabled: _indent_ok, shortcut: "Tab", on_click: method({ root: _root, cfg: _cfg }, function() { root.__TextAreaIndentSelection(cfg); }) });
			array_push(_items, { label: "Outdent", enabled: _indent_ok, shortcut: "Shift+Tab", on_click: method({ root: _root, cfg: _cfg }, function() { root.__TextAreaOutdentSelection(cfg); }) });
			array_push(_items, { is_separator: true });

			var _me = self;
			array_push(_items, { label: (wrap ? "Disable wrap" : "Enable wrap"), enabled: true, on_click: method({ ta: _me }, function() { ta.SetWrap(!ta.wrap); }) });

			_root.OpenContextMenu(_items, _root.mx, _root.my, owner_window, style_id);
			_root.ConsumeMouse();
		}

		if (_input_enabled && _root.text_mouse_selecting && _root.text_mouse_select_id == id && !_root.mouse_l_pressed) {
			var _clamped_x = clamp(_root.mx, _text_rect.x1, _text_rect.x2);
			var _clamped_y = clamp(_root.my, _text_rect.y1, _text_rect.y2);
			var _view_w2 = max(0, _text_rect.x2 - _text_rect.x1);
			var _layout2 = _root.__TextAreaGetActiveLayout(_root.theme.font_body, wrap, _view_w2, _config);
			var _local_x2 = (_clamped_x - _text_rect.x1) + (wrap ? 0 : _root.text_scroll_x);
			var _local_y2 = (_clamped_y - _text_rect.y1) + overlay_scroll_state.scroll_y;
			var _drag_index = _root.__TextAreaIndexFromPoint(_layout2, _root.theme.font_body, _local_x2, _local_y2, _config);
			_root.__TextInputUpdateMouseSelection(_drag_index);
		}

		// Draw multiline content with scrollbar.
		var _view_w3 = max(0, _text_rect.x2 - _text_rect.x1);
		var _layout3 = _root.__TextAreaGetActiveLayout(_root.theme.font_body, wrap, _view_w3, _config);
		var _line_h = is_struct(_layout3) ? (_layout3.line_h ?? string_height("Ag")) : string_height("Ag");
		var _line_count = (is_struct(_layout3) && is_array(_layout3.lines)) ? array_length(_layout3.lines) : 0;
		var _content_h = max(max(0, _text_rect.y2 - _text_rect.y1), _line_count * _line_h);

		_styles = _root.theme.textinput_styles;
		var _st_in = _styles[$ style_id] ?? _styles[$ "_default"];

		var _txt_col = _st_in[$ "text"] ?? _root.theme.col_text;
		var _txt_alpha = _st_in[$ "text_alpha"] ?? 1;
		var _ph_col = _st_in[$ "placeholder"] ?? _txt_col;
		var _ph_alpha = _st_in[$ "placeholder_alpha"] ?? 0.55;

		var _sel_bg = _st_in[$ "selection_bg"] ?? merge_color(_txt_col, _root.theme.col_panel_bg, 0.35);
		var _sel_text = _st_in[$ "selection_text"] ?? _txt_col;
		var _sel_bg_inactive = _st_in[$ "selection_bg_inactive"] ?? _sel_bg;
		var _sel_text_inactive = _st_in[$ "selection_text_inactive"] ?? _sel_text;
		var _sel_bg_alpha = _st_in[$ "selection_bg_alpha"] ?? 1;
		var _sel_text_alpha = _st_in[$ "selection_text_alpha"] ?? _txt_alpha;
		var _sel_bg_inactive_alpha = _st_in[$ "selection_bg_inactive_alpha"] ?? _sel_bg_alpha;
		var _sel_text_inactive_alpha = _st_in[$ "selection_text_inactive_alpha"] ?? _sel_text_alpha;

		var _caret_col = _st_in[$ "caret_color"] ?? _txt_col;
		var _caret_alpha = _st_in[$ "caret_alpha"] ?? 1;
		var _caret_char = _st_in[$ "caret_char"] ?? "|";
		var _caret_blink_ms = _st_in[$ "caret_blink_ms"] ?? 520;
		var _caret_w = max(1, _st_in[$ "caret_width"] ?? 1);
		var _caret_h = _st_in[$ "caret_height"] ?? 0;
		var _caret_inset_x = _st_in[$ "caret_inset_x"] ?? 0;
		var _caret_inset_y = _st_in[$ "caret_inset_y"] ?? 0;

		__draw_layout = _layout3;
		__draw_text_rect = _text_rect;
		__draw_font = _root.theme.font_body;
		__draw_is_placeholder = false;
		__draw_active = true;
		__draw_config = _config;
		__draw_state = {
			txt_col : _txt_col,
			txt_alpha : _txt_alpha,
			ph_col : _ph_col,
			ph_alpha : _ph_alpha,
			sel_bg : _sel_bg,
			sel_text : _sel_text,
			sel_bg_inactive : _sel_bg_inactive,
			sel_text_inactive : _sel_text_inactive,
			sel_bg_alpha : _sel_bg_alpha,
			sel_text_alpha : _sel_text_alpha,
			sel_bg_inactive_alpha : _sel_bg_inactive_alpha,
			sel_text_inactive_alpha : _sel_text_inactive_alpha,
			caret_col : _caret_col,
			caret_alpha : _caret_alpha,
			caret_char : _caret_char,
			caret_blink_ms : _caret_blink_ms,
			caret_w : _caret_w,
			caret_h : _caret_h,
			caret_inset_x : _caret_inset_x,
			caret_inset_y : _caret_inset_y
		};

		_root.DrawScrollArea(overlay_scroll_state, _scroll_rect, _content_h, method(self, __DrawScrollContent));

		// Consume clicks inside the panel even if they hit no element.
		if (_input_enabled && _inside && (_root.mouse_l_pressed || _root.mouse_r_pressed) && !_root.mouse_consumed) {
			_root.ConsumeMouse();
		}

		draw_set_font(_old_font);
	};

	/// @ignore
	static __DrawScrollContent = function(_root, _rect, _scroll_y) {
		var _layout = __draw_layout;
		if (!is_struct(_layout) || !is_array(_layout.lines)) {
			return;
		}

		var _text_rect = __draw_text_rect;
		if (!is_struct(_text_rect)) {
			return;
		}

		var _font = __draw_font;
		var _st = __draw_state;
		if (!is_struct(_st)) {
			return;
		}

		var _active = (__draw_active == true);
		var _is_placeholder = (__draw_is_placeholder == true);
		var _config = __draw_config;

		var _line_h = _layout.line_h ?? string_height("Ag");
		var _lines = _layout.lines;
		var _count = array_length(_lines);
		if (_count <= 0) {
			return;
		}

		var _old_alpha = draw_get_alpha();
		var _old_font = draw_get_font();
		draw_set_font(_font);

		var _scroll_x = (_active && wrap != true) ? _root.text_scroll_x : 0;
		var _text_x = _text_rect.x1 - _scroll_x;

		_root.PushClipRect(_text_rect.x1, _text_rect.y1, _text_rect.x2, _text_rect.y2);

		var _has_sel = _active && _root.__TextInputHasSelection() && !_is_placeholder;
		var _range = _has_sel ? _root.__TextInputGetSelectionRange() : { start: 0, _end: 0 };

		var _first = floor(_scroll_y / max(1, _line_h));
		_first = clamp(_first, 0, _count - 1);

		for (var _i = _first; _i < _count; _i++) {
			var _ln = _lines[_i];
			if (!is_struct(_ln)) continue;

			var _yy = _text_rect.y1 + (_i * _line_h) - _scroll_y;
			if (_yy > _text_rect.y2) {
				break;
			}

			var _line_text = string(_ln.text);
			var _line_start = _ln.start;
			var _line_end = _line_start + _ln.len;

			// Selection background
			if (_has_sel) {
				var _s = clamp(_range.start, _line_start, _line_end);
				var _e = clamp(_range._end, _line_start, _line_end);
				if (_e > _s) {
					var _sa = _s - _line_start;
					var _ea = _e - _line_start;
					var _pre_a = (_sa > 0) ? string_copy(_line_text, 1, _sa) : "";
					var _pre_b = (_ea > 0) ? string_copy(_line_text, 1, _ea) : "";
					var _x1s = _text_x + ((_sa > 0) ? _root.__TextInputMeasureVisualWidth(_pre_a, _font, _config) : 0);
					var _x2s = _text_x + ((_ea > 0) ? _root.__TextInputMeasureVisualWidth(_pre_b, _font, _config) : 0);
					if (_x2s < _x1s) {
						var _tmp = _x1s;
						_x1s = _x2s;
						_x2s = _tmp;
					}
					var _sel_bg_col = _active ? _st.sel_bg : _st.sel_bg_inactive;
					var _sel_bg_alpha_use = _active ? _st.sel_bg_alpha : _st.sel_bg_inactive_alpha;
					draw_set_alpha(_old_alpha * _sel_bg_alpha_use);
					draw_set_color(_sel_bg_col);
					draw_rectangle(_x1s, _yy, _x2s, _yy + _line_h, false);
					draw_set_alpha(_old_alpha);
				}
			}

			// Text
			var _line_draw = string(_ln[$ "text_draw"] ?? _root.__TextInputExpandTabsVisual(_line_text, _config));
			if (_is_placeholder) {
				draw_set_color(_st.ph_col);
				draw_set_alpha(_old_alpha * _st.txt_alpha * _st.ph_alpha);
			}
			else {
				draw_set_color(_st.txt_col);
				draw_set_alpha(_old_alpha * _st.txt_alpha);
			}
			draw_text(_text_x, _yy, _line_draw);
			draw_set_alpha(_old_alpha);

			// Selection text
			if (_has_sel) {
				var _s2 = clamp(_range.start, _line_start, _line_end);
				var _e2 = clamp(_range._end, _line_start, _line_end);
				if (_e2 > _s2) {
					var _sa2 = _s2 - _line_start;
					var _ea2 = _e2 - _line_start;
					var _pre_a2 = (_sa2 > 0) ? string_copy(_line_text, 1, _sa2) : "";
					var _pre_b2 = (_ea2 > 0) ? string_copy(_line_text, 1, _ea2) : "";
					var _x1t = _text_x + ((_sa2 > 0) ? _root.__TextInputMeasureVisualWidth(_pre_a2, _font, _config) : 0);
					var _x2t = _text_x + ((_ea2 > 0) ? _root.__TextInputMeasureVisualWidth(_pre_b2, _font, _config) : 0);
					if (_x2t < _x1t) {
						var _tmp2 = _x1t;
						_x1t = _x2t;
						_x2t = _tmp2;
					}
					_root.PushClipRect(_x1t, _yy, _x2t, _yy + _line_h);
					var _sel_text_col = _active ? _st.sel_text : _st.sel_text_inactive;
					var _sel_text_alpha_use = _active ? _st.sel_text_alpha : _st.sel_text_inactive_alpha;
					draw_set_alpha(_old_alpha * _sel_text_alpha_use);
					draw_set_color(_sel_text_col);
					draw_text(_text_x, _yy, _line_draw);
					draw_set_alpha(_old_alpha);
					_root.PopClipRect();
				}
			}
		}

		// Caret
		if (_active && !read_only && !_is_placeholder) {
			if (_st.caret_blink_ms > 0) {
				if ((current_time - _root.text_caret_blink_time) >= _st.caret_blink_ms) {
					_root.text_caret_visible = !_root.text_caret_visible;
					_root.text_caret_blink_time = current_time;
				}
			}
			var _show_caret = (_st.caret_blink_ms <= 0) || _root.text_caret_visible;
			if (_show_caret) {
				var _li = _root.__TextAreaFindLineAtIndex(_layout, _root.text_caret_index);
				_li = clamp(_li, 0, _count - 1);
				var _ln2 = _lines[_li];
				var _local_i = clamp(_root.text_caret_index - _ln2.start, 0, _ln2.len);
				var _prefix = (_local_i > 0) ? string_copy(_ln2.text, 1, _local_i) : "";
				var _caret_px = (_local_i > 0) ? _root.__TextInputMeasureVisualWidth(_prefix, _font, _config) : 0;
				var _caret_x = _text_x + _caret_px + _st.caret_inset_x;
				var _caret_y_base = _text_rect.y1 + (_li * _line_h) - _scroll_y;
				var _caret_height = (_st.caret_h > 0) ? _st.caret_h : _line_h;
				var _caret_y = _caret_y_base + ((_line_h - _caret_height) * 0.5) + _st.caret_inset_y;

				var _caret_spr = skin_caret_sprite;
				var _caret_sub = skin_caret_subimg;
				if (_caret_spr < 0 && is_instanceof(_root, EchoChamberRoot)) {
					var _styles = _root.theme.textinput_styles;
					var _st_style = _styles[$ style_id] ?? _styles[$ "_default"];
					_caret_spr = _st_style[$ "input_caret_sprite"] ?? -1;
					_caret_sub = 0;
				}

				if (_caret_spr != -1 && sprite_exists(_caret_spr)) {
					var _tcr = __ApplySkinTint(_st.caret_col, _old_alpha * _st.caret_alpha);
					draw_sprite_stretched_ext(_caret_spr, _caret_sub, _caret_x, _caret_y, _st.caret_w, _caret_height, _tcr.col, _tcr.alpha);
				}
				else {
					draw_set_alpha(_old_alpha * _st.caret_alpha);
					draw_set_color(_st.caret_col);
					if (string_length(_st.caret_char) > 0) {
						draw_text(_caret_x, _caret_y_base + _st.caret_inset_y, _st.caret_char);
					}
					else {
						draw_rectangle(_caret_x, _caret_y, _caret_x + _st.caret_w, _caret_y + _caret_height, false);
					}
				}
				draw_set_alpha(_old_alpha);
			}
		}

		_root.PopClipRect();

		draw_set_font(_old_font);
		draw_set_alpha(_old_alpha);
	};

	/// @desc Enable or disable word wrapping.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextArea}
	static SetWrap = function(_flag) {
		wrap = (_flag == true);
		return self;
	};

	/// @desc Set how many rows should be visible (derives height from font line height).
	/// @param {Real} _rows
	/// @return {Struct.EchoChamberTextArea}
	static SetVisibleRows = function(_rows) {
		var _r = floor(_rows);
		if (_r > 0) {
			visible_rows = _r;
			preferred_height = 0;
		}
		return self;
	};

	/// @desc Set the minimum pixel height.
	/// @param {Real} _px
	/// @return {Struct.EchoChamberTextArea}
	static SetMinHeight = function(_px) {
		min_height = max(0, _px);
		return self;
	};

	/// @desc Set the maximum pixel height (0 = unlimited).
	/// @param {Real} _px
	/// @return {Struct.EchoChamberTextArea}
	static SetMaxHeight = function(_px) {
		max_height = max(0, _px);
		return self;
	};

	/// @desc Enable or disable the resize grip.
	/// @param {Bool} _flag
	/// @param {Real} [_min_h]
	/// @param {Real} [_max_h]
	/// @return {Struct.EchoChamberTextArea}
	static SetResizable = function(_flag, _min_h = 0, _max_h = 0) {
		resizable = (_flag == true);
		if (is_real(_min_h) && _min_h > 0) {
			min_height = _min_h;
		}
		if (is_real(_max_h) && _max_h > 0) {
			max_height = _max_h;
		}
		return self;
	};

	/// @desc Enable or disable the overlay editor affordance.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberTextArea}
	static SetUseOverlayEditor = function(_flag) {
		use_overlay_editor = (_flag == true);
		return self;
	};

	/// @ignore
	static __GetDesiredHeightForWidth = function(_root, _panel, _width) {
		var _h = 0;
		if (preferred_height > 0) {
			_h = preferred_height;
		}
		else if (visible_rows > 0 && is_instanceof(_root, EchoChamberRoot)) {
			var _font = _root.theme.font_body;
			var _old = draw_get_font();
			draw_set_font(_font);
			var _line_h = string_height("Ag");
			draw_set_font(_old);
			var _py = __ResolvePaddingY(_root);
			_h = (visible_rows * _line_h) + (_py * 2);
		}
		else if (is_instanceof(_panel, EchoChamberPanel) && _panel.row_height > 0) {
			_h = _panel.row_height;
		}
		else if (is_instanceof(_root, EchoChamberRoot)) {
			_h = _root.default_row_height;
		}

		_h = max(_h, min_height);
		if (max_height > 0) {
			_h = min(_h, max_height);
		}

		var _msg = string(validation_message);
		if (!validation_visible || string_length(_msg) <= 0) {
			return _h;
		}

		var _mode = string(validation_display);
		if (_mode == "tooltip") {
			return _h;
		}

		var _styles = _root.theme.textinput_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _gap = max(0, _st[$ "validation_gap"] ?? 4);
		var _font = _st[$ "validation_font"] ?? _root.theme.font_small;

		var _pad_x = __ResolvePaddingX(_root);
		var _mw = max(0, _width - (_pad_x * 2));

		var _old = draw_get_font();
		draw_set_font(_font);
		var _mh = string_height_ext(_msg, -1, _mw);
		draw_set_font(_old);

		return _h + _gap + _mh;
	};

	/// @desc Process input and draw the text area control.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _hover = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;
		var _active = _root.IsActiveTextInput(id);
		if (!enabled && _active) {
			_root.BlurTextInput(id);
			_active = false;
		}

		// If the editor was committed/blured externally (e.g. Ctrl+E), close any open overlay.
		if (overlay_open && !_active) {
			overlay_open = false;
			overlay_rect_last = undefined;
			if (_root.active_overlay_owner_id == id) {
				_root.ClearActiveOverlayOwner();
			}
		}

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		// Expand button (overlay editor)
		var _exp_sz = 14;
		var _exp_x2 = _x2 - 3;
		var _exp_x1 = _exp_x2 - _exp_sz;
		var _exp_y1 = _y1 + 3;
		var _exp_y2 = _exp_y1 + _exp_sz;
		var _exp_hover = false;
		if (use_overlay_editor && enabled) {
			_exp_hover = (_mx >= _exp_x1 && _mx <= _exp_x2 && _my >= _exp_y1 && _my <= _exp_y2);
		}

		var _styles = _root.theme.textinput_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _txt_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.9;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _txt_alpha_base = _st[$ "text_alpha"] ?? 1;

		var _ph_col = _st[$ "placeholder"] ?? _txt_base;
		var _ph_alpha = _st[$ "placeholder_alpha"] ?? 0.55;

		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _txt_disabled = _st[$ "text_disabled"] ?? _txt_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _txt_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _txt_alpha_base;

		var _bg_readonly = _st[$ "bg_readonly"] ?? _bg_base;
		var _bd_readonly = _st[$ "border_readonly"] ?? _bd_base;
		var _txt_readonly = _st[$ "text_readonly"] ?? _txt_base;
		var _bg_readonly_alpha = _st[$ "bg_readonly_alpha"] ?? _bg_alpha_base;
		var _bd_readonly_alpha = _st[$ "border_readonly_alpha"] ?? _bd_alpha_base;
		var _txt_readonly_alpha = _st[$ "text_readonly_alpha"] ?? _txt_alpha_base;

		var _bg_invalid = _st[$ "bg_invalid"] ?? _bg_base;
		var _bd_invalid = _st[$ "border_invalid"] ?? _bd_base;
		var _txt_invalid = _st[$ "text_invalid"] ?? _txt_base;
		var _bg_invalid_alpha = _st[$ "bg_invalid_alpha"] ?? _bg_alpha_base;
		var _bd_invalid_alpha = _st[$ "border_invalid_alpha"] ?? _bd_alpha_base;
		var _txt_invalid_alpha = _st[$ "text_invalid_alpha"] ?? _txt_alpha_base;

		var _pressed_mix = _st[$ "pressed_mix"] ?? 0.22;
		var _state_override = false;
		if (!enabled) {
			_bg_base = _bg_disabled;
			_bd_base = _bd_disabled;
			_txt_base = _txt_disabled;
			_bg_alpha_base = _bg_disabled_alpha;
			_bd_alpha_base = _bd_disabled_alpha;
			_txt_alpha_base = _txt_disabled_alpha;
			_state_override = true;
		}
		else if (invalid) {
			_bg_base = _bg_invalid;
			_bd_base = _bd_invalid;
			_txt_base = _txt_invalid;
			_bg_alpha_base = _bg_invalid_alpha;
			_bd_alpha_base = _bd_invalid_alpha;
			_txt_alpha_base = _txt_invalid_alpha;
			_state_override = true;
		}
		else if (read_only) {
			_bg_base = _bg_readonly;
			_bd_base = _bd_readonly;
			_txt_base = _txt_readonly;
			_bg_alpha_base = _bg_readonly_alpha;
			_bd_alpha_base = _bd_readonly_alpha;
			_txt_alpha_base = _txt_readonly_alpha;
			_state_override = true;
		}

		var _bg_hover = _state_override ? merge_color(_bg_base, _txt_base, 0.12) : (_st[$ "bg_hover"] ?? merge_color(_bg_base, _txt_base, 0.12));
		var _bd_hover = _state_override ? _bd_base : (_st[$ "border_hover"] ?? _bd_base);
		var _txt_hover = _state_override ? _txt_base : (_st[$ "text_hover"] ?? _txt_base);
		var _bg_hover_alpha = _state_override ? _bg_alpha_base : (_st[$ "bg_hover_alpha"] ?? _bg_alpha_base);
		var _bd_hover_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_hover_alpha"] ?? _bd_alpha_base);
		var _txt_hover_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_hover_alpha"] ?? _txt_alpha_base);

		var _bg_active = _state_override ? merge_color(_bg_base, _txt_base, 0.2) : (_st[$ "bg_active"] ?? merge_color(_bg_base, _txt_base, 0.2));
		var _bd_active = _state_override ? _bd_base : (_st[$ "border_active"] ?? _bd_base);
		var _txt_active = _state_override ? _txt_base : (_st[$ "text_active"] ?? _txt_base);
		var _bg_active_alpha = _state_override ? _bg_alpha_base : (_st[$ "bg_active_alpha"] ?? _bg_alpha_base);
		var _bd_active_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_active_alpha"] ?? _bd_alpha_base);
		var _txt_active_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_active_alpha"] ?? _txt_alpha_base);

		var _bg_pressed = _state_override ? merge_color(_bg_hover, _txt_base, _pressed_mix) : (_st[$ "bg_pressed"] ?? merge_color(_bg_hover, _txt_base, _pressed_mix));
		var _bd_pressed = _state_override ? _bd_base : (_st[$ "border_pressed"] ?? _bd_hover);
		var _txt_pressed = _state_override ? _txt_base : (_st[$ "text_pressed"] ?? _txt_hover);
		var _bg_pressed_alpha = _state_override ? _bg_hover_alpha : (_st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha);
		var _bd_pressed_alpha = _state_override ? _bd_alpha_base : (_st[$ "border_pressed_alpha"] ?? _bd_hover_alpha);
		var _txt_pressed_alpha = _state_override ? _txt_alpha_base : (_st[$ "text_pressed_alpha"] ?? _txt_hover_alpha);

		var _sel_bg = _st[$ "selection_bg"] ?? merge_color(_txt_base, _bg_base, 0.35);
		var _sel_text = _st[$ "selection_text"] ?? _txt_base;
		var _sel_bg_inactive = _st[$ "selection_bg_inactive"] ?? _sel_bg;
		var _sel_text_inactive = _st[$ "selection_text_inactive"] ?? _sel_text;
		var _sel_bg_alpha = _st[$ "selection_bg_alpha"] ?? 1;
		var _sel_text_alpha = _st[$ "selection_text_alpha"] ?? _txt_alpha_base;
		var _sel_bg_inactive_alpha = _st[$ "selection_bg_inactive_alpha"] ?? _sel_bg_alpha;
		var _sel_text_inactive_alpha = _st[$ "selection_text_inactive_alpha"] ?? _sel_text_alpha;

		var _caret_col = _st[$ "caret_color"] ?? _txt_base;
		var _caret_alpha = _st[$ "caret_alpha"] ?? 1;
		var _caret_char = _st[$ "caret_char"] ?? "|";
		var _caret_blink_ms = _st[$ "caret_blink_ms"] ?? 520;
		var _caret_w = max(1, _st[$ "caret_width"] ?? 1);
		var _caret_h = _st[$ "caret_height"] ?? 0;
		var _caret_inset_x = _st[$ "caret_inset_x"] ?? 0;
		var _caret_inset_y = _st[$ "caret_inset_y"] ?? 0;

		var _validation_msg = string(validation_message);
		var _show_validation = validation_visible && string_length(_validation_msg) > 0;
		var _validation_mode = string(validation_display);

		var _validation_gap = max(0, _st[$ "validation_gap"] ?? 4);
		var _validation_alpha = _st[$ "validation_alpha"] ?? 0.9;
		var _validation_font = _st[$ "validation_font"] ?? _root.theme.font_small;

		var _validation_col = _st[$ "validation_error"] ?? _root.theme.col_error;
		if (validation_kind == "warn") {
			_validation_col = _st[$ "validation_warn"] ?? _validation_col;
		}
		else if (validation_kind == "info") {
			_validation_col = _st[$ "validation_info"] ?? _validation_col;
		}

		var _w_total = max(0, _x2 - _x1);
		var _desired = __GetDesiredHeightForWidth(_root, _panel, _w_total);
		var _use_inline = false;
		if (_show_validation) {
			if (_validation_mode == "inline") {
				_use_inline = true;
			}
			else if (_validation_mode == "tooltip") {
				_use_inline = false;
			}
			else {
				_use_inline = ((_y2 - _y1) >= (_desired - 0.01));
			}
		}

		var _msg_h = 0;
		var _msg_area = 0;
		if (_show_validation && _use_inline) {
			var _pad_xm = __ResolvePaddingX(_root);
			var _mw = max(0, _w_total - (_pad_xm * 2));
			var _oldf = draw_get_font();
			draw_set_font(_validation_font);
			_msg_h = string_height_ext(_validation_msg, -1, _mw);
			draw_set_font(_oldf);
			_msg_area = _validation_gap + _msg_h;
		}

		var _y2_body = _y2;
		if (_show_validation && _use_inline) {
			_y2_body = max(_y1, _y2 - _msg_area);
		}

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _txt_col = _txt_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _txt_alpha = _txt_alpha_base;
		if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_txt_col = _txt_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_txt_alpha = _txt_pressed_alpha;
		}
		else if (_active) {
			_bg_col = _bg_active;
			_bd_col = _bd_active;
			_txt_col = _txt_active;
			_bg_alpha = _bg_active_alpha;
			_bd_alpha = _bd_active_alpha;
			_txt_alpha = _txt_active_alpha;
		}
		else if (_hover && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_txt_col = _txt_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_txt_alpha = _txt_hover_alpha;
		}

		// Background
		var _old_alpha = draw_get_alpha();

		var _w_draw = max(0, _x2 - _x1);
		var _h_draw = max(0, _y2_body - _y1);

		var _bg_spr = skin_bg_sprite;
		var _bg_sub = skin_bg_subimg;
		if (_bg_spr < 0) {
			_bg_spr = _st[$ "input_bg_sprite"] ?? -1;
			_bg_sub = 0;
		}
		var _bd_spr = skin_border_sprite;
		var _bd_sub = skin_border_subimg;
		if (_bd_spr < 0) {
			_bd_spr = _st[$ "input_border_sprite"] ?? -1;
			_bd_sub = 0;
		}

		if (_bg_spr != -1 && sprite_exists(_bg_spr)) {
			var _tbg = __ApplySkinTint(_bg_col, _old_alpha * _bg_alpha);
			draw_sprite_stretched_ext(_bg_spr, _bg_sub, _x1, _y1, _w_draw, _h_draw, _tbg.col, _tbg.alpha);
		}
		else {
			draw_set_alpha(_old_alpha * _bg_alpha);
			draw_set_color(_bg_col);
			draw_rectangle(_x1, _y1, _x2, _y2_body, false);
		}

		if (_bd_spr != -1 && sprite_exists(_bd_spr)) {
			var _tbd = __ApplySkinTint(_bd_col, _old_alpha * _bd_alpha);
			draw_sprite_stretched_ext(_bd_spr, _bd_sub, _x1, _y1, _w_draw, _h_draw, _tbd.col, _tbd.alpha);
		}
		else {
			draw_set_alpha(_old_alpha * _bd_alpha);
			draw_set_color(_bd_col);
			draw_rectangle(_x1, _y1, _x2, _y2_body, true);
		}
		draw_set_alpha(_old_alpha);

		// Layout rects
		var _font = _root.theme.font_body;
		var _old_font = draw_get_font();
		draw_set_font(_font);

		var _pad_x = __ResolvePaddingX(_root);
		var _pad_y = __ResolvePaddingY(_root);
		var _ix1 = _x1 + _pad_x;
		var _iy1 = _y1 + _pad_y;
		var _ix2 = _x2 - _pad_x;
		var _iy2 = _y2_body - _pad_y;
		if (_ix2 < _ix1) _ix2 = _ix1;
		if (_iy2 < _iy1) _iy2 = _iy1;

		var _sb_w = _root.theme.scrollbar_w + 2;
		var _tx2 = _ix2 - _sb_w;
		if (_tx2 < _ix1) _tx2 = _ix1;

		var _scroll_rect = { x1: _ix1, y1: _iy1, x2: _ix2, y2: _iy2 };
		var _text_rect = { x1: _ix1, y1: _iy1, x2: _tx2, y2: _iy2 };
		var _view_w = max(0, _text_rect.x2 - _text_rect.x1);
		var _view_h = max(0, _text_rect.y2 - _text_rect.y1);

		var _config = {
			multiline : true,
			wrap : wrap,
			tab_inserts : tab_inserts,
			tab_use_spaces : tab_use_spaces,
			tab_spaces : tab_spaces,
			view_w : _view_w,
			view_h : _view_h,
			font : _font,
			scroll_state : scroll_state,
			read_only : read_only,
			max_length : max_length,
			allow_chars : allow_chars,
			deny_chars : deny_chars,
			numeric_only : numeric_only,
			numeric_allow_decimal : numeric_allow_decimal,
			numeric_allow_negative : numeric_allow_negative,
			select_all_on_focus : select_all_on_focus,
			transformers : transforms,
			auto_trim : auto_trim,
			auto_upper : auto_upper,
			auto_lower : auto_lower,
			filter_fn : filter_fn,
			on_live_change : on_live_change,
			on_submit : on_submit,
			on_cancel : on_cancel,
			on_focus : on_focus,
			on_blur : on_blur,
			live_change_rate_ms : live_change_rate_ms,
			input_mode : input_mode,
			auto_indent : auto_indent,
			password_mask : password_mask,
			password_mask_char : password_mask_char,
			password_allow_copy : password_allow_copy
		};

		if (_active) {
			_root.text_input_config = _config;
		}

		// Expand click opens overlay editor.
		if (_exp_hover && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			__editor_original_text = _active ? _root.GetActiveText() : __GetValue();
			overlay_open = true;
			_root.SetActiveOverlayOwner(id);
			overlay_scroll_state.scroll_y = 0;
			overlay_scroll_state.dragging = false;
			overlay_scroll_state.drag_offset_y = 0;
			if (!_active) {
				_root.FocusTextInput(id, __editor_original_text, placeholder, method(self, __CommitFinal), _config);
				_active = true;
			}
			_root.ConsumeMouse();
		}

		// Keyboard: start editing when focused and Accept is pressed.
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled && !_active) {
			var _current_kb = __GetValue();
			_root.FocusTextInput(id, _current_kb, placeholder, method(self, __CommitFinal), _config);
			_active = true;
		}

		// Click handling
		if (_hover && _root.mouse_l_pressed && !_root.mouse_consumed && enabled && !_exp_hover && !overlay_open) {
			_root.FocusControl(id, _rect);
			var _activated_this_click = false;
			if (!_active) {
				var _current = __GetValue();
				_root.FocusTextInput(id, _current, placeholder, method(self, __CommitFinal), _config);
				_active = true;
				_activated_this_click = true;
			}
			if (_active) {
				var _scroll_y = scroll_state.scroll_y;
				var _local_x = (_mx - _text_rect.x1) + (_config.wrap ? 0 : _root.text_scroll_x);
				var _local_y = (_my - _text_rect.y1) + _scroll_y;
				var _layout = _root.__TextAreaGetActiveLayout(_font, wrap, _view_w);
				var _caret_index = _root.__TextAreaIndexFromPoint(_layout, _font, _local_x, _local_y, _config);
				var _skip_click_select = (_activated_this_click && (_config[$ "select_all_on_focus"] == true) && !keyboard_check(vk_shift));
				if (!_skip_click_select) {
					var _click_count = _root.__TextInputRegisterClick(id, _caret_index);
					_root.__TextInputBeginMouseSelection(_caret_index, keyboard_check(vk_shift), _click_count);
				}
				else {
					_root.__TextInputRegisterClick(id, _caret_index);
				}
			}
			_root.ConsumeMouse();
		}

		// Right click: open context menu.
		if (_hover && _root.mouse_r_pressed && !_root.mouse_consumed && enabled && !overlay_open) {
			_root.FocusControl(id, _rect);
			if (!_active) {
				var _current_r = __GetValue();
				_root.FocusTextInput(id, _current_r, placeholder, method(self, __CommitFinal), _config);
				_active = true;
			}

			if (_active) {
				var _scroll_y3 = scroll_state.scroll_y;
				var _local_x3 = (_mx - _text_rect.x1) + (_config.wrap ? 0 : _root.text_scroll_x);
				var _local_y3 = (_my - _text_rect.y1) + _scroll_y3;
				var _layout3 = _root.__TextAreaGetActiveLayout(_font, wrap, _view_w);
				var _caret_index3 = _root.__TextAreaIndexFromPoint(_layout3, _font, _local_x3, _local_y3, _config);

				var _inside_sel = false;
				if (_root.__TextInputHasSelection()) {
					var _r = _root.__TextInputGetSelectionRange();
					_inside_sel = (_caret_index3 >= _r.start && _caret_index3 < _r._end);
				}

				if (!_inside_sel) {
					_root.__TextInputSetCaret(_caret_index3, false);
				}

				var _has_sel = _root.__TextInputHasSelection();
				var _read = (read_only == true);
				var _undo_ok = !_read && is_array(_root.text_undo_stack) && array_length(_root.text_undo_stack) > 0;
				var _redo_ok = !_read && is_array(_root.text_redo_stack) && array_length(_root.text_redo_stack) > 0;
				var _clip = clipboard_get_text();
				var _clip_ok = !_read && !is_undefined(_clip) && string_length(string(_clip)) > 0;
				var _copy_ok = _has_sel && (!password_mask || password_allow_copy);
				var _cut_ok = _has_sel && !_read && (!password_mask || password_allow_copy);

				var _items = [];
				array_push(_items, { label: "Undo", enabled: _undo_ok, shortcut: "Ctrl+Z", on_click: method({ root: _root }, function() { root.__TextInputUndo(); }) });
				array_push(_items, { label: "Redo", enabled: _redo_ok, shortcut: "Ctrl+Y", on_click: method({ root: _root }, function() { root.__TextInputRedo(); }) });
				array_push(_items, { is_separator: true });
				array_push(_items, { label: "Cut", enabled: _cut_ok, shortcut: "Ctrl+X", on_click: method({ root: _root }, function() { root.__TextInputCutSelection(); }) });
				array_push(_items, { label: "Copy", enabled: _copy_ok, shortcut: "Ctrl+C", on_click: method({ root: _root }, function() { root.__TextInputCopySelection(); }) });
				array_push(_items, { label: "Paste", enabled: _clip_ok, shortcut: "Ctrl+V", on_click: method({ root: _root, cfg: _config }, function() { root.__TextInputPasteClipboard(cfg); }) });
				array_push(_items, { is_separator: true });
				array_push(_items, { label: "Select All", enabled: true, shortcut: "Ctrl+A", on_click: method({ root: _root }, function() { root.__TextInputSelectAll(); }) });

				array_push(_items, { is_separator: true });

				var _indent_ok = !_read && (tab_inserts == true);
				array_push(_items, { label: "Indent", enabled: _indent_ok, shortcut: "Tab", on_click: method({ root: _root, cfg: _config }, function() { root.__TextAreaIndentSelection(cfg); }) });
				array_push(_items, { label: "Outdent", enabled: _indent_ok, shortcut: "Shift+Tab", on_click: method({ root: _root, cfg: _config }, function() { root.__TextAreaOutdentSelection(cfg); }) });
				array_push(_items, { is_separator: true });
				array_push(_items, { label: (wrap ? "Disable wrap" : "Enable wrap"), enabled: true, on_click: method(self, function() { self.SetWrap(!self.wrap); }) });
				var _me = self;
				array_push(_items, { label: "Open editor", enabled: (use_overlay_editor == true), on_click: method({ ta: _me, root: _root, cfg: _config }, function() { ta.__OpenOverlayEditorFromMenu(root, cfg); }) });

				_root.OpenContextMenu(_items, _mx, _my, owner_window, style_id);
			}

			_root.ConsumeMouse();
		}

		// Drag selection
		if (_active && _root.text_mouse_selecting && _root.text_mouse_select_id == id && !_root.mouse_l_pressed) {
			var _scroll_y2 = scroll_state.scroll_y;
			var _clamped_x = clamp(_mx, _text_rect.x1, _text_rect.x2);
			var _clamped_y = clamp(_my, _text_rect.y1, _text_rect.y2);
			var _local_x2 = (_clamped_x - _text_rect.x1) + (_config.wrap ? 0 : _root.text_scroll_x);
			var _local_y2 = (_clamped_y - _text_rect.y1) + _scroll_y2;
			var _layout2 = _root.__TextAreaGetActiveLayout(_font, wrap, _view_w);
			var _drag_index = _root.__TextAreaIndexFromPoint(_layout2, _font, _local_x2, _local_y2, _config);
			_root.__TextInputUpdateMouseSelection(_drag_index);
		}

		// While active, register our rect so the root can detect click-outside blur on the next click.
		// When overlay is open, expand to the overlay rect so clicks inside the panel do not trigger blur pre-pass.
		if (_active) {
			if (overlay_open && is_struct(overlay_rect_last)) {
				_root.__SetActiveTextInputRect(id, overlay_rect_last);
			}
			else {
				_root.__SetActiveTextInputRect(id, _rect);
			}
		}

		// Resize grip
		var _grip_sz = _root.theme.window_resize_grip_size ?? 12;
		var _grip_x1 = _x2 - _grip_sz;
		var _grip_y1 = _y2_body - _grip_sz;
		var _grip_hover = false;
		var _force_lock_h = (__force_prev_stored && force_size_kind != "none" && (force_size_lock_h == true));
		if (_force_lock_h) {
			__resize_dragging = false;
		}
		if (resizable && show_resize_grip && enabled && !_force_lock_h) {
			_grip_hover = (_mx >= _grip_x1 && _mx <= _x2 && _my >= _grip_y1 && _my <= _y2_body);
		}

		if (__resize_dragging) {
			if (!_root.mouse_l_down) {
				__resize_dragging = false;
			}
			else if (enabled && visible) {
				var _delta = _my - __resize_start_my;
				var _next_h = __resize_start_h + _delta;
				_next_h = max(_next_h, min_height);
				if (max_height > 0) {
					_next_h = min(_next_h, max_height);
				}
				preferred_height = _next_h;
				_root.ConsumeMouse();
				_root.ConsumeWheel();
			}
			else {
				__resize_dragging = false;
			}
		}
		else if (_grip_hover && _root.mouse_l_pressed && !_root.mouse_consumed) {
			__resize_dragging = true;
			__resize_start_my = _my;
			__resize_start_h = max(0, _y2 - _y1);
			if (preferred_height > 0) {
				__resize_start_h = preferred_height;
			}
			_root.ConsumeMouse();
			_root.ConsumeWheel();
		}

		// Content
		var _display_text = "";
		var _stored = __GetValue();
		var _is_placeholder = false;
		if (_active) {
			_display_text = _root.GetActiveText();
		}
		else if (string_length(_stored) <= 0) {
			_display_text = placeholder;
			_is_placeholder = true;
		}
		else {
			_display_text = _stored;
		}

		if (password_mask && !_is_placeholder && !_active) {
			var _mc = string(password_mask_char);
			if (string_length(_mc) <= 0) _mc = "*";
			_mc = string_char_at(_mc, 1);
			var _lenm = string_length(_display_text);
			_display_text = (_lenm > 0) ? string_repeat(_mc, _lenm) : "";
		}

		var _layout_draw = _active
		? _root.__TextAreaGetActiveLayout(_font, wrap, _view_w)
		: _root.__TextAreaBuildLayout(_display_text, _font, wrap, _view_w, _config);

		var _line_h = is_struct(_layout_draw) ? (_layout_draw.line_h ?? string_height("Ag")) : string_height("Ag");
		var _line_count = (is_struct(_layout_draw) && is_array(_layout_draw.lines)) ? array_length(_layout_draw.lines) : 0;
		var _content_h = max(_view_h, _line_count * _line_h);

		__draw_layout = _layout_draw;
		__draw_text_rect = _text_rect;
		__draw_font = _font;
		__draw_is_placeholder = _is_placeholder;
		__draw_active = _active;
		__draw_config = _config;
		__draw_state = {
			txt_col : _txt_col,
			txt_alpha : _txt_alpha,
			ph_col : _ph_col,
			ph_alpha : _ph_alpha,
			sel_bg : _sel_bg,
			sel_text : _sel_text,
			sel_bg_inactive : _sel_bg_inactive,
			sel_text_inactive : _sel_text_inactive,
			sel_bg_alpha : _sel_bg_alpha,
			sel_text_alpha : _sel_text_alpha,
			sel_bg_inactive_alpha : _sel_bg_inactive_alpha,
			sel_text_inactive_alpha : _sel_text_inactive_alpha,
			caret_col : _caret_col,
			caret_alpha : _caret_alpha,
			caret_char : _caret_char,
			caret_blink_ms : _caret_blink_ms,
			caret_w : _caret_w,
			caret_h : _caret_h,
			caret_inset_x : _caret_inset_x,
			caret_inset_y : _caret_inset_y
		};

		_root.DrawScrollArea(scroll_state, _scroll_rect, _content_h, method(self, __DrawScrollContent));

		// Expand button draw
		if (use_overlay_editor && enabled) {
			var _exp_spr = skin_expand_sprite;
			var _exp_sub = skin_expand_subimg;
			if (_exp_spr < 0) {
				_exp_spr = _st[$ "textarea_expand_sprite"] ?? -1;
				_exp_sub = 0;
			}

			if (_exp_spr != -1 && sprite_exists(_exp_spr)) {
				var _btn_bg = merge_color(_bg_col, _txt_col, _exp_hover ? 0.18 : 0.08);
				var _a = _old_alpha * (_exp_hover ? 0.95 : 0.75);
				var _texp = __ApplySkinTint(_btn_bg, _a);
				draw_sprite_stretched_ext(_exp_spr, _exp_sub, _exp_x1, _exp_y1, max(0, _exp_x2 - _exp_x1), max(0, _exp_y2 - _exp_y1), _texp.col, _texp.alpha);
			}
			else {
				var _btn_bg2 = merge_color(_bg_col, _txt_col, _exp_hover ? 0.18 : 0.08);
				draw_set_alpha(_old_alpha * (_exp_hover ? 0.95 : 0.75));
				draw_set_color(_btn_bg2);
				draw_rectangle(_exp_x1, _exp_y1, _exp_x2, _exp_y2, false);
				draw_set_alpha(_old_alpha);
				draw_set_color(_bd_col);
				draw_rectangle(_exp_x1, _exp_y1, _exp_x2, _exp_y2, true);
				draw_set_color(_txt_col);
				draw_text(_exp_x1 + 4, _exp_y1 + 1, "...");
			}
		}

		// Resize grip draw
		if (resizable && show_resize_grip && enabled && !_force_lock_h) {
			var _grip_spr = skin_grip_sprite;
			var _grip_sub = skin_grip_subimg;
			if (_grip_spr < 0) {
				_grip_spr = _st[$ "textarea_grip_sprite"] ?? -1;
				_grip_sub = 0;
			}

			var _grip_col = merge_color(_bd_col, _txt_col, _grip_hover ? 0.35 : 0.15);
			var _a_grip = _old_alpha * (_grip_hover ? 0.95 : 0.65);

			if (_grip_spr != -1 && sprite_exists(_grip_spr)) {
				var _tgr = __ApplySkinTint(_grip_col, _a_grip);
				draw_sprite_stretched_ext(_grip_spr, _grip_sub, _grip_x1, _grip_y1, _grip_sz, _grip_sz, _tgr.col, _tgr.alpha);
			}
			else {
				draw_set_alpha(_a_grip);
				draw_set_color(_grip_col);
				for (var i = 0; i < 3; i++) {
					var _ox = 3 + (i * 3);
					draw_line(_x2 - _ox, _y2_body - 2, _x2 - 2, _y2_body - _ox);
				}
				draw_set_alpha(_old_alpha);
			}
		}

		draw_set_font(_old_font);

		// Validation message
		if (_show_validation) {
			var _need_tip = (_validation_mode == "tooltip") || (!_use_inline) || ((_validation_mode == "inline") && ((_y2 - _y1) < (_desired - 0.01)));
			var _tip = "";
			if (_need_tip) {
				_tip = _validation_msg;
				if (string_length(tooltip) > 0) {
					_tip += "\n\n" + string(tooltip);
				}
			}
			if (_use_inline) {
				var _oldf2 = draw_get_font();
				var _oldc2 = draw_get_colour();
				var _olda2 = draw_get_alpha();
				draw_set_font(_validation_font);
				draw_set_color(_validation_col);
				draw_set_alpha(_olda2 * _validation_alpha);
				var _pad_xv = __ResolvePaddingX(_root);
				var _vx = _x1 + _pad_xv;
				var _vw2 = max(0, (_x2 - _x1) - (_pad_xv * 2));
				_root.PushClipRect(_x1, _y1, _x2, _y2);
				draw_text_ext(_vx, _y2_body + _validation_gap, _validation_msg, -1, _vw2);
				_root.PopClipRect();
				draw_set_alpha(_olda2);
				draw_set_color(_oldc2);
				draw_set_font(_oldf2);
			}
			if (_hover && string_length(_tip) > 0) {
				_root.RequestTooltip(id, _tip, _mx, _my);
			}
		}

		// Queue overlay draw (after windows)
		if (overlay_open) {
			if (!_root.IsContextMenuOpen()) {
				_root.SetActiveOverlayOwner(id);
			}

			var _gw = display_get_gui_width();
			var _gh = display_get_gui_height();
			var _margin = 16;
			var _pw = min(720, max(0, _gw - (_margin * 2)));
			var _ph = min(480, max(0, _gh - (_margin * 2)));
			_pw = max(320, _pw);
			_ph = max(240, _ph);
			var _px1 = floor((_gw - _pw) * 0.5);
			var _py1 = floor((_gh - _ph) * 0.5);
			overlay_rect_last = { x1: _px1, y1: _py1, x2: _px1 + _pw, y2: _py1 + _ph };

			// While overlay is open, update root config to use the overlay editor viewport sizes.
			var _pad2 = 12;
			var _row_h2 = max(18, _root.default_row_height);
			var _btn_h2 = _row_h2;
			var _gap2 = 8;
			var _btn_y1o = overlay_rect_last.y2 - _pad2 - _btn_h2;
			var _editor_y1o = overlay_rect_last.y1 + _pad2 + _row_h2 + _gap2;
			var _editor_y2o = _btn_y1o - _gap2;
			var _editor_x1o = overlay_rect_last.x1 + _pad2 + 7;
			var _editor_x2o = overlay_rect_last.x2 - _pad2 - 7;
			var _sb_w2 = _root.theme.scrollbar_w + 2;
			var _view_w2 = max(0, (_editor_x2o - _editor_x1o) - _sb_w2);
			var _view_h2 = max(0, (_editor_y2o - _editor_y1o));

			var _config_overlay = {
				multiline : true,
				wrap : wrap,
				tab_inserts : tab_inserts,
				tab_use_spaces : tab_use_spaces,
				tab_spaces : tab_spaces,
				view_w : _view_w2,
				view_h : _view_h2,
				font : _font,
				scroll_state : overlay_scroll_state,
				read_only : read_only,
				max_length : max_length,
				allow_chars : allow_chars,
				deny_chars : deny_chars,
				numeric_only : numeric_only,
				numeric_allow_decimal : numeric_allow_decimal,
				numeric_allow_negative : numeric_allow_negative,
				select_all_on_focus : select_all_on_focus,
				transformers : transforms,
				auto_trim : auto_trim,
				auto_upper : auto_upper,
				auto_lower : auto_lower,
				filter_fn : filter_fn,
				on_live_change : on_live_change,
				on_submit : on_submit,
				on_cancel : on_cancel,
				on_focus : on_focus,
				on_blur : on_blur,
				live_change_rate_ms : live_change_rate_ms,
				input_mode : input_mode,
				auto_indent : auto_indent,
				password_mask : password_mask,
				password_mask_char : password_mask_char,
				password_allow_copy : password_allow_copy
			};

			if (_active) {
				_root.text_input_config = _config_overlay;
				_root.__TextAreaEnsureCaretVisible(_config_overlay);
			}

			_root.QueueOverlay(id, method(self, __DrawOverlay));
		}

		if (_hover && string_length(tooltip) > 0) {
			if (!_show_validation) {
				_root.RequestTooltip(id, tooltip, _mx, _my);
			}
		}
	};
}

/// @func EchoChamberSeparator(_id)
/// @desc Non-interactive separator line.
/// @param {Any} _id
/// @return {Struct.EchoChamberSeparator}
function EchoChamberSeparator(_id) : EchoChamberControlBase(_id) constructor {
	orientation = "horizontal"; // "horizontal" or "vertical"

	/// @desc Set separator orientation ("horizontal" or "vertical").
	/// @param {String} _ori
	/// @return {Struct.EchoChamberSeparator}
	static SetOrientation = function(_ori) {
		orientation = _ori;
		return self;
	};

	/// @desc Draw the separator line within the given rect.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _styles = _root.theme.separator_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _line_col = _st[$ "line"] ?? _root.theme.col_accent;
		var _line_alpha = _st[$ "line_alpha"] ?? 1;
		var _line_disabled = _st[$ "line_disabled"] ?? _root.theme.col_accent_dim;
		var _line_disabled_alpha = _st[$ "line_disabled_alpha"] ?? _line_alpha;
		if (!enabled) {
			_line_col = _line_disabled;
			_line_alpha = _line_disabled_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_line_alpha);
		draw_set_color(_line_col);

		if (orientation == "vertical") {
			var _cx = (_x1 + _x2) * 0.5;
			draw_line(_cx, _y1, _cx, _y2);
		}
		else {
			var _cy = (_y1 + _y2) * 0.5;
			draw_line(_x1, _cy, _x2, _cy);
		}
		draw_set_alpha(_old_alpha);
	};
}

/// @func EchoChamberListView(_id)
/// @desc Virtualized list view control for very large row counts. Draws and hit-tests only visible rows.
/// @param {Any} _id
/// @return {Struct.EchoChamberListView}
function EchoChamberListView(_id) : EchoChamberControlBase(_id) constructor {
	row_h	= 18;
	preferred_height = -1;
	visible_rows = -1;
	auto_height_max_rows = 0;
	auto_width_max_rows = 0;
	fill_width = false;

	selected_index	= -1;
	hover_index		= -1;

	auto_scroll_to_bottom	= false;

	// Internal auto-follow state (used by auto_scroll_to_bottom)
	__follow_paused			= false;
	__follow_was_near_bottom	= true;
	__follow_threshold_px		= 0;
	__last_view_h			= 0;
	__last_content_h		= 0;
	__last_max_scroll		= 0;
	__last_near_bottom		= true;

	count_getter	= undefined;	// function() -> count
	row_drawer		= undefined;	// function(index, rect, is_selected, is_hover) -> draws content only
	row_measure_fn	= undefined;	// function(index, root, panel) -> String or Real (pixels)
	on_select		= undefined;	// function(index)
	on_activate		= undefined;	// function(index)
	on_double_click	= undefined;	// function(index)
	on_right_click	= undefined;	// function(index, x, y)

	double_click_ms		= 350;
	__last_click_ms		= -1000000000;
	__last_click_index	= -1;

	scroll_state	= new EchoChamberScrollState(id + "_scroll");

	/// @desc Set the fixed row height in pixels.
	/// @param {Real} _h
	static SetRowHeight = function(_h) {
		row_h = max(4, floor(_h));
		return self;
	};

	/// @desc Set how many rows should be visible (derives height from row height).
	/// @param {Real} _rows
	/// @return {Struct.EchoChamberListView}
	static SetVisibleRows = function(_rows) {
		var _count = floor(_rows);
		if (_count > 0) {
			visible_rows = _count;
			auto_height_max_rows = 0;
		}
		else {
			visible_rows = -1;
		}
		return self;
	};

	/// @desc Auto-size to the current row count, clamped to a maximum number of rows.
	/// @param {Real} _max_rows
	/// @return {Struct.EchoChamberListView}
	static SetAutoHeightFromCount = function(_max_rows) {
		auto_height_max_rows = max(0, floor(_max_rows));
		if (auto_height_max_rows > 0) {
			visible_rows = -1;
		}
		return self;
	};

	/// @desc Auto-size width to row content, sampling up to the given number of rows (0 disables).
	/// @param {Real} _max_rows
	/// @return {Struct.EchoChamberListView}
	static SetAutoWidthFromContent = function(_max_rows) {
		auto_width_max_rows = max(0, floor(_max_rows));
		return self;
	};

	/// @desc Set whether this list view fills available row width.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberListView}
	static SetFillWidth = function(_flag) {
		fill_width = (_flag == true);
		return self;
	};

	/// @desc Set the preferred pixel height for this list view (used by FitToContent).
	/// @param {Real} _h
	/// @return {Struct.EchoChamberListView}
	static SetPreferredHeight = function(_h) {
		preferred_height = max(0, _h);
		return self;
	};

	/// @desc Set a preferred pixel width for this list view.
	/// @param {Real} _w
	/// @return {Struct.EchoChamberListView}
	static SetPreferredWidth = function(_w) {
		preferred_width = max(0, _w);
		return self;
	};

	/// @desc Provide a function that returns row text or pixel width (used for auto width).
	/// @param {Function} _fn function(_index, _root, _panel) -> String or Real
	/// @return {Struct.EchoChamberListView}
	static SetRowMeasure = function(_fn) {
		if (is_callable(_fn)) {
			row_measure_fn = _fn;
		}
		else {
			row_measure_fn = undefined;
		}
		return self;
	};

	/// @desc Provide a function that returns the current number of rows.
	/// @param {Function} _fn function() -> Real
	static SetCountGetter = function(_fn) {
		if (is_callable(_fn)) {
			count_getter = _fn;
		}
		return self;
	};

	/// @desc Provide a function that draws a row's content. Background is drawn by the control.
	/// @param {Function} _fn function(_index, _rect, _is_selected, _is_hover)
	static SetRowDrawer = function(_fn) {
		if (is_callable(_fn)) {
			row_drawer = _fn;
		}
		return self;
	};

	/// @desc Callback when selection changes.
	/// @param {Function} _fn function(_index)
	static SetOnSelect = function(_fn) {
		on_select = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Callback when the active row is activated (Enter key).
	/// @param {Function} _fn function(_index)
	static SetOnActivate = function(_fn) {
		on_activate = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Callback when a row is double clicked (fast action).
	/// @param {Function} _fn function(_index)
	static SetOnDoubleClick = function(_fn) {
		on_double_click = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Callback when a row is right clicked (context menu). Use _index=-1 for empty space.
	/// @param {Function} _fn function(_index, _x, _y)
	static SetOnRightClick = function(_fn) {
		on_right_click = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Enable or disable auto-scroll-to-bottom behavior.
	/// @param {Bool} _enabled
	static SetAutoScroll = function(_enabled) {
		auto_scroll_to_bottom = (_enabled == true);

		// When enabling, do not force a snap immediately unless we were already near bottom.
		// When disabling, clear pause so a later enable behaves predictably.
		if (!auto_scroll_to_bottom) {
			__follow_paused = false;
			__follow_was_near_bottom = false;
		}

		return self;
	};

	/// @desc Scroll the list to the bottom and resume auto-follow (if enabled).
	/// @return {Struct.EchoChamberListView}
	static JumpToBottom = function() {
		__follow_paused = false;
		__follow_was_near_bottom = true;
		if (is_instanceof(scroll_state, EchoChamberScrollState)) {
			// Use a huge value; clamp occurs in DrawScrollArea.
			scroll_state.scroll_y = infinity;
		}
		return self;
	};

	/// @desc Returns true if the list is currently near the bottom (based on the last draw).
	/// @return {Bool}
	static IsNearBottom = function() {
		return (__last_near_bottom == true);
	};

	/// @desc Returns true if auto-follow is currently paused due to user scroll.
	/// @return {Bool}
	static IsAutoFollowPaused = function() {
		return (__follow_paused == true);
	};

	/// @desc Return the current selected row index (or -1).
	/// @return {Real}
	static GetSelectedIndex = function() {
		return selected_index;
	};

	/// @desc Set the selected row index (clamped to range). Use -1 to clear selection.
	/// @param {Real} _index
	static SetSelectedIndex = function(_index) {
		selected_index = floor(_index);
		return self;
	};

	/// @ignore
	/// @func __GetCount()
	/// @return {Real}
	static __GetCount = function() {
		if (is_callable(count_getter)) {
			var _c = floor(count_getter());
			return max(0, _c);
		}
		return 0;
	};

	/// @ignore
	/// @func __ClampSelection(_count)
	/// @param {Real} _count
	static __ClampSelection = function(_count) {
		if (_count <= 0) {
			selected_index = -1;
			return;
		}
		if (selected_index < 0) return;
		selected_index = clamp(selected_index, 0, _count - 1);
	};

	/// @ignore
	/// @func __GetContentSize(_root, _panel, _row_h)
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _row_h
	/// @return {Struct,Undefined}
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (auto_width_max_rows <= 0) return undefined;
		if (!is_instanceof(_root, EchoChamberRoot)) return undefined;
		if (!is_instanceof(_panel, EchoChamberPanel)) return undefined;
		if (!is_callable(row_measure_fn)) return undefined;
		var _count = __GetCount();
		if (_count <= 0) return undefined;

		var _limit = min(_count, auto_width_max_rows);
		var _max_w = 0;
		for (var _i = 0; _i < _limit; _i++) {
			var _val = row_measure_fn(_i, _root, _panel);
			if (is_undefined(_val)) continue;
			var _w = 0;
			if (is_real(_val)) {
				_w = _val;
			}
			else {
				_w = _root.__MeasureTextWidth(string(_val), _root.theme.font_body);
			}
			if (_w > _max_w) _max_w = _w;
		}

		if (_max_w <= 0) return undefined;

		var _pad_x = __ResolvePaddingX(_root);
		var _view_rows = 0;
		if (preferred_height > 0) {
			_view_rows = floor(preferred_height / max(1, row_h));
		}
		else if (visible_rows > 0) {
			_view_rows = visible_rows;
		}
		else if (auto_height_max_rows > 0) {
			_view_rows = min(_count, auto_height_max_rows);
		}

		var _scroll_w = 0;
		if (_view_rows > 0 && _count > _view_rows) {
			_scroll_w = _root.theme.scrollbar_w + 2;
		}

		var _w_total = _max_w + (_pad_x * 2) + _scroll_w;
		return { w: _w_total, h: _row_h };
	};

	/// @ignore
	/// @func __GetDesiredHeightForWidth(_root, _panel, _width)
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _width
	/// @return {Real}
	static __GetDesiredHeightForWidth = function(_root, _panel, _width) {
		if (preferred_height > 0) {
			return preferred_height;
		}
		if (visible_rows > 0) {
			return row_h * visible_rows;
		}
		if (auto_height_max_rows > 0) {
			var _count = __GetCount();
			var _rows = min(_count, auto_height_max_rows);
			return row_h * max(1, _rows);
		}
		var _row = row_h;
		if (_row <= 0) {
			_row = _panel.row_height > 0 ? _panel.row_height : _root.default_row_height;
		}
		return _row;
	};

	/// @ignore
	/// @func __ScrollIndexIntoView(_index, _scroll_y, _view_h)
	/// @param {Real} _index
	/// @param {Real} _scroll_y
	/// @param {Real} _view_h
	/// @return {Real}
	static __ScrollIndexIntoView = function(_index, _scroll_y, _view_h) {
		if (_index < 0) return _scroll_y;
		var _top = _index * row_h;
		var _bot = _top + row_h;
		if (_top < _scroll_y) {
			_scroll_y = _top;
		}
		else if (_bot > _scroll_y + _view_h) {
			_scroll_y = _bot - _view_h;
		}
		return _scroll_y;
	};

	/// @desc Process input and draw the list view.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;
		if (!is_struct(_root)) return;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _view_h = max(0, _y2 - _y1);

		var _styles = _root.theme.list_row_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_normal = _st[$ "bg_normal"] ?? _root.theme.col_panel_bg;
		var _bg_hover = _st[$ "bg_hover"] ?? _root.theme.col_hover_row;
		var _bg_selected = _st[$ "bg_selected"] ?? _root.theme.col_hover_row_alt;
		var _bg_pressed = _st[$ "bg_pressed"] ?? _bg_hover;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_normal;

		var _bg_normal_alpha = _st[$ "bg_normal_alpha"] ?? 1;
		var _bg_hover_alpha = _st[$ "bg_hover_alpha"] ?? _bg_normal_alpha;
		var _bg_selected_alpha = _st[$ "bg_selected_alpha"] ?? _bg_normal_alpha;
		var _bg_pressed_alpha = _st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_normal_alpha;

		var _tx_normal = _st[$ "text_normal"] ?? _root.theme.col_text;
		var _tx_hover = _st[$ "text_hover"] ?? _tx_normal;
		var _tx_selected = _st[$ "text_selected"] ?? _tx_normal;
		var _tx_pressed = _st[$ "text_pressed"] ?? _tx_hover;
		var _tx_disabled = _st[$ "text_disabled"] ?? _root.theme.col_text_dim;

		var _tx_normal_alpha = _st[$ "text_normal_alpha"] ?? 1;
		var _tx_hover_alpha = _st[$ "text_hover_alpha"] ?? _tx_normal_alpha;
		var _tx_selected_alpha = _st[$ "text_selected_alpha"] ?? _tx_normal_alpha;
		var _tx_pressed_alpha = _st[$ "text_pressed_alpha"] ?? _tx_hover_alpha;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_normal_alpha;

		if (!enabled) {
			_bg_normal = _bg_disabled;
			_bg_hover = _bg_disabled;
			_bg_selected = _bg_disabled;
			_bg_pressed = _bg_disabled;
			_bg_normal_alpha = _bg_disabled_alpha;
			_bg_hover_alpha = _bg_disabled_alpha;
			_bg_selected_alpha = _bg_disabled_alpha;
			_bg_pressed_alpha = _bg_disabled_alpha;
			_tx_normal = _tx_disabled;
			_tx_hover = _tx_disabled;
			_tx_selected = _tx_disabled;
			_tx_pressed = _tx_disabled;
			_tx_normal_alpha = _tx_disabled_alpha;
			_tx_hover_alpha = _tx_disabled_alpha;
			_tx_selected_alpha = _tx_disabled_alpha;
			_tx_pressed_alpha = _tx_disabled_alpha;
		}

		// Base background fill
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_normal_alpha);
		draw_set_color(_bg_normal);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);

		var _count = __GetCount();
		__ClampSelection(_count);

		var _content_h = _count * row_h;

		// Auto-follow to bottom (does not fight the user)
		var _max_scroll = max(0, _content_h - _view_h);
		__follow_threshold_px = max(2, row_h * 2);
		__last_view_h = _view_h;
		__last_content_h = _content_h;
		__last_max_scroll = _max_scroll;

		var _scroll_y_pre = is_instanceof(scroll_state, EchoChamberScrollState) ? scroll_state.scroll_y : 0;
		var _near_bottom_pre = ((_max_scroll - _scroll_y_pre) <= __follow_threshold_px);

		if (!auto_scroll_to_bottom) {
			__follow_paused = false;
			__follow_was_near_bottom = _near_bottom_pre;
		}
		else {
			// Follow only if we were already near bottom (previous frame) or still near bottom now.
			if (!__follow_paused && (__follow_was_near_bottom || _near_bottom_pre)) {
				scroll_state.scroll_y = _max_scroll;
			}
		}

		var _focused = _root.IsControlFocused(id);

		// Keyboard navigation (when focused)
		if (_focused && enabled && _count > 0) {
			var _page = max(1, floor(_view_h / max(1, row_h)));

			// If no selection yet, seed on navigation
			var _nav_home = _root.InputPressed(ECHO_UI_ACTION_HOME);
			var _nav_end = _root.InputPressed(ECHO_UI_ACTION_END);
			var _nav_page_up = _root.InputPressed(ECHO_UI_ACTION_PAGE_UP);
			var _nav_page_down = _root.InputPressed(ECHO_UI_ACTION_PAGE_DOWN);
			var _nav_up = _root.InputPressed(ECHO_UI_ACTION_NAV_UP);
			var _nav_down = _root.InputPressed(ECHO_UI_ACTION_NAV_DOWN);
			var _nav_pressed = _nav_up || _nav_down || _nav_page_up || _nav_page_down || _nav_home || _nav_end;

			// Note: do NOT force-scroll the selection into view every frame, or the user cannot scroll
			// away from a selected row. Only scroll-to-selection when selection changes via keyboard.
			if (_nav_pressed) {
				var _prev = selected_index;

				if (selected_index < 0) {
					selected_index = 0;
				}

				if (_nav_home) {
					selected_index = 0;
				}
				else if (_nav_end) {
					selected_index = _count - 1;
				}
				else if (_nav_page_up) {
					selected_index -= _page;
				}
				else if (_nav_page_down) {
					selected_index += _page;
				}
				else if (_nav_up) {
					selected_index -= 1;
				}
				else if (_nav_down) {
					selected_index += 1;
				}

				selected_index = clamp(selected_index, 0, _count - 1);

				// Scroll selection into view only when selection changes via keyboard navigation.
				if (_prev != selected_index) {
					if (is_instanceof(scroll_state, EchoChamberScrollState)) {
						scroll_state.scroll_y = __ScrollIndexIntoView(selected_index, scroll_state.scroll_y, _view_h);
					}
					if (is_callable(on_select)) {
						on_select(selected_index);
					}
				}
			}

			if (_root.InputPressed(ECHO_UI_ACTION_ACCEPT) && is_callable(on_activate) && selected_index >= 0) {
				on_activate(selected_index);
			}
		}

		var _scroll_before_draw = is_instanceof(scroll_state, EchoChamberScrollState) ? scroll_state.scroll_y : 0;

		var _self = self;
		_root.DrawScrollArea(scroll_state, _rect, _content_h,
		method({
			owner: _self, count: _count,
			view_h: _view_h, content_h: _content_h,
			bg_normal: _bg_normal, bg_hover: _bg_hover,
			bg_selected: _bg_selected, bg_pressed: _bg_pressed,
			bg_normal_alpha: _bg_normal_alpha, bg_hover_alpha: _bg_hover_alpha,
			bg_selected_alpha: _bg_selected_alpha, bg_pressed_alpha: _bg_pressed_alpha,
			tx_normal: _tx_normal, tx_hover: _tx_hover,
			tx_selected: _tx_selected, tx_pressed: _tx_pressed,
			tx_normal_alpha: _tx_normal_alpha, tx_hover_alpha: _tx_hover_alpha,
			tx_selected_alpha: _tx_selected_alpha, tx_pressed_alpha: _tx_pressed_alpha
		},	__DrawScroll));

		var _scroll_after_draw = _scroll_before_draw;
		if (is_instanceof(scroll_state, EchoChamberScrollState)) {
			_scroll_after_draw = scroll_state.scroll_y;
		}

		var _near_bottom_after = ((_max_scroll - _scroll_after_draw) <= __follow_threshold_px);
		__last_near_bottom = _near_bottom_after;
		__follow_was_near_bottom = _near_bottom_after;

		// Pause auto-follow if the user scrolls up.
		if (auto_scroll_to_bottom && is_instanceof(scroll_state, EchoChamberScrollState)
		&& scroll_state.user_scrolled_this_frame) {
			if (_scroll_after_draw < _scroll_before_draw - 0.5) {
				__follow_paused = true;
			}
		}

		// Resume auto-follow only once the user returns to the actual bottom.
		// (Using "near bottom" here makes it difficult to break auto-follow with small wheel scrolls.)
		if (auto_scroll_to_bottom && __follow_paused && _scroll_after_draw >= _max_scroll - 0.5) {
			__follow_paused = false;
		}
	};

	/// @ignore
	static __DrawScroll = function(_r, _inner, _scroll_y) {
		var _count = count,
		_view_h = view_h,
		_content_h = content_h,
		_bg_normal = bg_normal,
		_bg_hover = bg_hover,
		_bg_selected = bg_selected,
		_bg_pressed = bg_pressed,
		_bg_normal_alpha = bg_normal_alpha,
		_bg_hover_alpha = bg_hover_alpha,
		_bg_selected_alpha = bg_selected_alpha,
		_bg_pressed_alpha = bg_pressed_alpha,
		_tx_normal = tx_normal,
		_tx_hover = tx_hover,
		_tx_selected = tx_selected,
		_tx_pressed = tx_pressed,
		_tx_normal_alpha = tx_normal_alpha,
		_tx_hover_alpha = tx_hover_alpha,
		_tx_selected_alpha = tx_selected_alpha,
		_tx_pressed_alpha = tx_pressed_alpha;

		with (owner) {
			var _mx = _r.mx;
			var _my = _r.my;

			var _inside = (_mx >= _inner.x1 && _mx <= _inner.x2 && _my >= _inner.y1 && _my <= _inner.y2);

			// Compute visible range (virtualization)
			var _first = 0;
			if (_count > 0) {
				_first = floor(_scroll_y / max(1, row_h));
				_first = clamp(_first, 0, _count - 1);
			}
			var _visible_count = ceil(_view_h / max(1, row_h)) + 1;
			var _last = (_count <= 0) ? -1 : min(_count - 1, _first + _visible_count);

			// Compute hover index in O(1)
			var _hover_idx = -1;
			if (_inside && enabled && _count > 0) {
				_hover_idx = floor((_my - _inner.y1 + _scroll_y) / max(1, row_h));
				if (_hover_idx < 0 || _hover_idx >= _count) {
					_hover_idx = -1;
				}
			}
			hover_index = _hover_idx;

			// Click inside list -> focus, selection, optional double click action
			if (_inside && _r.mouse_l_pressed && !_r.mouse_consumed && enabled) {
				_r.FocusControl(id, _inner);

				var _clicked_idx = _hover_idx;
				var _is_double = false;

				if (_clicked_idx >= 0) {
					var _now_ms = floor(get_timer() / 1000);
					if (_clicked_idx == __last_click_index && (_now_ms - __last_click_ms) <= double_click_ms) {
						_is_double = true;
					}
					__last_click_ms = _now_ms;
					__last_click_index = _clicked_idx;

					if (_clicked_idx != selected_index) {
						selected_index = _clicked_idx;
						if (is_callable(on_select)) {
							on_select(selected_index);
						}
					}

					if (_is_double && is_callable(on_double_click)) {
						on_double_click(_clicked_idx);
					}
				}
				else {
					__last_click_index = -1;
				}

				_r.ConsumeMouse();
			}


			// Right click inside list -> focus, selection, context action
			if (_inside && _r.mouse_r_pressed && !_r.mouse_consumed && enabled) {
				_r.FocusControl(id, _inner);

				var _clicked_idx = _hover_idx;

				if (_clicked_idx >= 0) {
					if (_clicked_idx != selected_index) {
						selected_index = _clicked_idx;
						if (is_callable(on_select)) {
							on_select(selected_index);
						}
					}
				}
				else {
					// Right click on empty space
					__last_click_index = -1;
				}

				if (is_callable(on_right_click)) {
					on_right_click(_clicked_idx, _r.mx, _r.my);
				}

				_r.ConsumeMouse();
			}
			// Determine content width that avoids drawing under the scrollbar (text area only)
			var _bar_w = _r.theme.scrollbar_w;
			var _needs_bar = (_content_h > _view_h);
			var _content_x2 = _needs_bar ? (_inner.x2 - _bar_w - 2) : _inner.x2;

			var _pad_x = __ResolvePaddingX(_r);

			var _old_font = draw_get_font();
			draw_set_font(_r.theme.font_body);

			var _pressed_idx = -1;
			if (_inside && _r.mouse_l_down && enabled) {
				_pressed_idx = _hover_idx;
			}

			for (var _i = _first; _i <= _last; _i++) {
				var _ry1 = _inner.y1 + (_i * row_h) - _scroll_y;
				var _ry2 = _ry1 + row_h;

				var _is_sel = (_i == selected_index);
				var _is_hover = (_i == _hover_idx);
				var _is_pressed = (_i == _pressed_idx);

				var _bg = _bg_normal;
				var _tx = _tx_normal;
				var _bg_alpha = _bg_normal_alpha;
				var _tx_alpha = _tx_normal_alpha;
				if (_is_pressed) {
					_bg = _bg_pressed;
					_tx = _tx_pressed;
					_bg_alpha = _bg_pressed_alpha;
					_tx_alpha = _tx_pressed_alpha;
				}
				else if (_is_sel) {
					_bg = _bg_selected;
					_tx = _tx_selected;
					_bg_alpha = _bg_selected_alpha;
					_tx_alpha = _tx_selected_alpha;
				}
				else if (_is_hover) {
					_bg = _bg_hover;
					_tx = _tx_hover;
					_bg_alpha = _bg_hover_alpha;
					_tx_alpha = _tx_hover_alpha;
				}

				var _old_alpha = draw_get_alpha();
				draw_set_alpha(_bg_alpha);
				draw_set_color(_bg);
				draw_rectangle(_inner.x1, _ry1, _inner.x2, _ry2, false);
				draw_set_alpha(_old_alpha);

				// Content draw (no background)
				if (is_callable(row_drawer)) {
					draw_set_alpha(_tx_alpha);
					draw_set_color(_tx);

					var _row_rect = {
						x1 : _inner.x1 + _pad_x,
						y1 : _ry1,
						x2 : _content_x2 - _pad_x,
						y2 : _ry2
					};
					row_drawer(_i, _row_rect, _is_sel, _is_hover);
					draw_set_alpha(_old_alpha);
				}
			}

			draw_set_font(_old_font);
		}
	};
}

/// @func EchoChamberDropdownBase(_id)
/// @desc Base dropdown control. Variants override selection and row behavior.
/// @param {Any} _id
/// @return {Struct.EchoChamberDropdownBase}
function EchoChamberDropdownBase(_id) : EchoChamberControlBase(_id) constructor {
	options         = [];
	selected_index  = 0;
	unfold_direction = "down";   // "up" / "down"
	is_open         = false;
	use_selected_label_when_closed = true;

	overlay_max_height = 240; // max overlay height in pixels; overlay becomes scrollable above this.
	overlay_scroll_y   = 0;
	overlay_hover_index = 0;
	overlay_scroll_dragging = false;  // true while dragging the overlay scrollbar thumb
	overlay_scroll_drag_offset_y = 0; // mouse_y - thumb_y1 at drag start


	// Virtuals that variants override
	/// @desc Return the selected option index.
	/// @return {Real}
	static GetSelectedIndex = function() {
		return selected_index;
	};

	/// @desc Set the selected option index (clamped to the available option range).
	/// @param {Real} _idx
	static SetSelectedIndex = function(_idx) {
		selected_index = clamp(_idx, 0, max(0, array_length(options) - 1));
	};

	/// @desc Draw a single row inside the dropdown overlay.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _row_index
	/// @param {Struct} _row_rect {x1,y1,x2,y2}
	/// @param {Bool} _hover
	/// @param {Bool} _selected
	static DrawOverlayRow = function(_root, _row_index, _row_rect, _hover, _selected) {
		var _x1 = _row_rect.x1;
		var _y1 = _row_rect.y1;
		var _x2 = _row_rect.x2;
		var _y2 = _row_rect.y2;

		var _styles = _root.theme.dropdown_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "overlay_row_bg"] ?? _root.theme.col_panel_bg;
		var _bg_hover = _st[$ "overlay_row_hover"] ?? _root.theme.col_hover_row;
		var _bg_selected = _st[$ "overlay_row_selected"] ?? _root.theme.col_hover_row_alt;
		var _bg_pressed = _st[$ "overlay_row_pressed"] ?? _bg_hover;
		var _bg_base_alpha = _st[$ "overlay_row_bg_alpha"] ?? 1;
		var _bg_hover_alpha = _st[$ "overlay_row_hover_alpha"] ?? _bg_base_alpha;
		var _bg_selected_alpha = _st[$ "overlay_row_selected_alpha"] ?? _bg_base_alpha;
		var _bg_pressed_alpha = _st[$ "overlay_row_pressed_alpha"] ?? _bg_hover_alpha;

		var _tx_base = _st[$ "overlay_text"] ?? _root.theme.col_text;
		var _tx_hover = _st[$ "overlay_text_hover"] ?? _tx_base;
		var _tx_selected = _st[$ "overlay_text_selected"] ?? _tx_base;
		var _tx_pressed = _st[$ "overlay_text_pressed"] ?? _tx_hover;
		var _tx_base_alpha = _st[$ "overlay_text_alpha"] ?? 1;
		var _tx_hover_alpha = _st[$ "overlay_text_hover_alpha"] ?? _tx_base_alpha;
		var _tx_selected_alpha = _st[$ "overlay_text_selected_alpha"] ?? _tx_base_alpha;
		var _tx_pressed_alpha = _st[$ "overlay_text_pressed_alpha"] ?? _tx_hover_alpha;

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_base_alpha;
		var _tx_alpha = _tx_base_alpha;
		if (_pressed) {
			_bg_col = _bg_pressed;
			_tx_col = _tx_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
		}
		else if (_selected) {
			_bg_col = _bg_selected;
			_tx_col = _tx_selected;
			_bg_alpha = _bg_selected_alpha;
			_tx_alpha = _tx_selected_alpha;
		}
		else if (_hover && enabled) {
			_bg_col = _bg_hover;
			_tx_col = _tx_hover;
			_bg_alpha = _bg_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);

		draw_set_alpha(_tx_alpha);
		draw_set_color(_tx_col);

		// Use the actual option text, not the dropdown's label
		var _option_str = "";
		if (is_array(options) && _row_index >= 0 && _row_index < array_length(options)) {
			_option_str = string(options[_row_index]);
		}

		var _max_w = _x2 - _x1 - 8;
		var _draw_str = __TrimTextToWidth(_option_str, _max_w, _root.theme.font_body);

		var _text_y = _y1 + ((_y2 - _y1) - string_height(_draw_str)) * 0.5;
		draw_text(_x1 + 4, _text_y, _draw_str);
		draw_set_alpha(_old_alpha);
	};


	/// @desc Handle a click on a row in the overlay (default selects and closes).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _row_index
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Real} _mx
	/// @param {Real} _my
	static OnOverlayRowClick = function(_root, _row_index, _rect, _mx, _my) {
		// default: single select and close
		var _old = GetSelectedIndex();
		if (_row_index != _old) {
			SetSelectedIndex(_row_index);
		}
		is_open = false;
		_root.ClearActiveOverlayOwner();
	};

	// Helpers to configure the control (these do not need overriding)
	/// @desc Set the dropdown option labels array.
	/// @param {Array<String>} _array
	/// @return {Struct.EchoChamberDropdownBase}
	static SetOptions = function(_array) {
		options = is_array(_array) ? _array : [];
		return self;
	};

	/// @desc Set the dropdown unfold direction ("up" or "down").
	/// @param {String} _dir
	/// @return {Struct.EchoChamberDropdownBase}
	static SetUnfoldDirection = function(_dir) {
		unfold_direction = (_dir == "up") ? "up" : "down";
		return self;
	};

	/// @desc Set whether the base label shows the selected option while closed.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberDropdownBase}
	static SetUseSelectedLabelWhenClosed = function(_flag) {
		use_selected_label_when_closed = _flag;
		return self;
	};

	/// @ignore
	static __GetContentSize = function(_root, _panel, _row_h) {
		if (!is_struct(_root) || !is_struct(_root.theme)) {
			return undefined;
		}
		if (!is_array(options) || array_length(options) <= 0) {
			return undefined;
		}

		var _idx = clamp(GetSelectedIndex(), 0, array_length(options) - 1);
		var _label_str;
		if (!use_selected_label_when_closed && string_length(label) > 0) {
			_label_str = string(label);
		}
		else {
			_label_str = string(options[_idx]);
		}

		var _font = _root.theme.font_body;
		var _max_text_w = _root.__MeasureTextWidth(_label_str, _font);

		var _len = array_length(options);
		for (var _i = 0; _i < _len; _i++) {
			var _opt = string(options[_i]);
			var _w0 = _root.__MeasureTextWidth(_opt, _font);
			if (_w0 > _max_text_w) {
				_max_text_w = _w0;
			}
		}

		// Some dropdown variants store their row labels separately (e.g. toggle menus).
		var _items = self[$ "items"];
		if (is_array(_items)) {
			var _ilen = array_length(_items);
			for (var _ii = 0; _ii < _ilen; _ii++) {
				var _it = _items[_ii];
				var _lbl = is_struct(_it) ? _it[$ "label"] : undefined;
				var _lbl_str = is_undefined(_lbl) ? "" : string(_lbl);
				var _w1 = _root.__MeasureTextWidth(_lbl_str, _font);
				if (_w1 > _max_text_w) {
					_max_text_w = _w1;
				}
			}
		}

		// 4px left padding, 16px reserved for arrow/right padding.
		var _w = _max_text_w + 4 + 16;
		return { w: _w, h: _row_h };
	};


	/// @desc Set the maximum pixel height for the dropdown overlay. If the option list exceeds this height, it becomes scrollable.
	/// @param {Real} _height
	/// @return {Struct.EchoChamberDropdownBase}
	static SetOverlayMaxHeight = function(_height) {
		overlay_max_height = max(0, _height);
		return self;
	};

	// Big ProcessAndDraw that all variants reuse
	/// @desc Process input and draw the dropdown (and overlay if open).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _count = array_length(options);
		if (_count <= 0) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _row_h = _panel.row_height;
		if (_row_h <= 0) _row_h = _root.default_row_height;

		var _idx = clamp(GetSelectedIndex(), 0, _count - 1);
		var _mx  = _root.mx;
		var _my  = _root.my;

		// Overlay rect (scrollable when content exceeds max height)
		var _ov_x1 = _x1;
		var _ov_x2 = _x2;
		var _total_h = _row_h * _count;
		var _view_h = _total_h;
		if (overlay_max_height > 0) {
			_view_h = min(_view_h, overlay_max_height);
		}
		var _max_scroll = max(0, _total_h - _view_h);
		overlay_scroll_y = clamp(overlay_scroll_y, 0, _max_scroll);
		var _ov_y1, _ov_y2;
		if (unfold_direction == "up") {
			_ov_y2 = _y1;
			_ov_y1 = _ov_y2 - _view_h;
		}
		else {
			_ov_y1 = _y2;
			_ov_y2 = _ov_y1 + _view_h;
		}

		// Handle overlay clicks if open
		if (is_open) {
			_root.SetActiveOverlayOwner(id);

			// Esc (or other callers) may request that the active overlay closes.
			if (_root.__ConsumeOverlayCloseRequest(id)) {
				is_open = false;
				overlay_scroll_dragging = false;
				_root.ClearActiveOverlayOwner();
			}

			// Keep hover index in range while open.
			overlay_hover_index = clamp(overlay_hover_index, 0, _count - 1);

			// Keyboard navigation while open.
			var _used_keyboard_nav = false;
			if (is_open && enabled && _root.active_overlay_owner_id == id) {
				var _nav_up = _root.InputPressed(ECHO_UI_ACTION_NAV_UP);
				var _nav_down = _root.InputPressed(ECHO_UI_ACTION_NAV_DOWN);
				var _accept = _root.InputPressed(ECHO_UI_ACTION_ACCEPT);

				if (_nav_up) {
					overlay_hover_index = max(0, overlay_hover_index - 1);
					_used_keyboard_nav = true;
				}
				if (_nav_down) {
					overlay_hover_index = min(_count - 1, overlay_hover_index + 1);
					_used_keyboard_nav = true;
				}
				if (_used_keyboard_nav) {
					var _row_top = overlay_hover_index * _row_h;
					if (_row_top < overlay_scroll_y) {
						overlay_scroll_y = _row_top;
					}
					else if ((_row_top + _row_h) > (overlay_scroll_y + _view_h)) {
						overlay_scroll_y = (_row_top + _row_h) - _view_h;
					}
					overlay_scroll_y = clamp(overlay_scroll_y, 0, _max_scroll);
				}
				if (_accept && is_open) {
					var _row_y1_kb = _ov_y1 + (_row_h * overlay_hover_index) - overlay_scroll_y;
					var _row_y2_kb = _row_y1_kb + _row_h;
					OnOverlayRowClick(_root, overlay_hover_index, { x1: _ov_x1, y1: _row_y1_kb, x2: _ov_x2, y2: _row_y2_kb }, _mx, _my);
					_used_keyboard_nav = true;
				}
			}

			if (is_open) {
				var _inside_overlay = (_mx >= _ov_x1 && _mx <= _ov_x2 && _my >= _ov_y1 && _my <= _ov_y2);
				var _inside_base    = (_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _y2);
				// Mouse hover updates the hover index unless we just used keyboard navigation.
				if (_inside_overlay && !_used_keyboard_nav) {
					var _y_in_hover = (_my - _ov_y1) + overlay_scroll_y;
					overlay_hover_index = clamp(floor(_y_in_hover / _row_h), 0, _count - 1);
				}

				var _has_scroll     = (_max_scroll > 0);

				// Stop dragging when mouse is released
				if (!_root.mouse_l_down) {
					overlay_scroll_dragging = false;
				}

				// Thumb dragging (works even if the mouse leaves the overlay while held)
				if (overlay_scroll_dragging && enabled && _has_scroll && !_root.mouse_consumed) {
					var _m_drag = _root.__CalcScrollbarMetrics(_ov_x1, _ov_y1, _ov_x2, _ov_y2, _total_h, overlay_scroll_y);
					overlay_scroll_y = _root.__ScrollbarScrollFromMouse(_m_drag, _my, overlay_scroll_drag_offset_y);
					overlay_scroll_y = clamp(overlay_scroll_y, 0, _max_scroll);
					_root.ConsumeMouse();
				}

				// Wheel scroll inside overlay
				if (_inside_overlay && _root.wheel_delta != 0 && !_root.wheel_consumed && enabled) {
					var _step = max(8, _row_h);
					overlay_scroll_y = clamp(overlay_scroll_y - (_root.wheel_delta * _step), 0, _max_scroll);
					_root.ConsumeWheel();
				}

				if (_root.mouse_l_pressed && !_root.mouse_consumed) {
					if (_inside_overlay && enabled) {
						var _handled = false;

						// Scrollbar click: thumb drag start or track page jump
						if (_has_scroll) {
							var _m_click = _root.__CalcScrollbarMetrics(_ov_x1, _ov_y1, _ov_x2, _ov_y2, _total_h, overlay_scroll_y);
							var _in_track = (_mx >= _m_click.track_x1 && _mx <= _m_click.track_x2 && _my >= _m_click.track_y1 && _my <= _m_click.track_y2);
							if (_in_track) {
								_handled = true;
								if (_my >= _m_click.handle_y1 && _my <= _m_click.handle_y2) {
									overlay_scroll_dragging = true;
									overlay_scroll_drag_offset_y = _my - _m_click.handle_y1;
								}
								else {
									if (_my < _m_click.handle_y1) {
										overlay_scroll_y = clamp(overlay_scroll_y - _m_click.view_h, 0, _max_scroll);
									}
									else {
										overlay_scroll_y = clamp(overlay_scroll_y + _m_click.view_h, 0, _max_scroll);
									}
								}
								_root.ConsumeMouse();
							}
						}

						// Option click (only if we did not click the scrollbar)
						if (!_handled) {
							var _y_in = (_my - _ov_y1) + overlay_scroll_y;
							var _row_index = floor(_y_in / _row_h);
							_row_index = clamp(_row_index, 0, _count - 1);
							var _row_y1 = _ov_y1 + (_row_h * _row_index) - overlay_scroll_y;
							var _row_y2 = _row_y1 + _row_h;
							OnOverlayRowClick(_root, _row_index, { x1: _ov_x1, y1: _row_y1, x2: _ov_x2, y2: _row_y2 }, _mx, _my);
							_root.ConsumeMouse();
						}
					}
					else if (!_inside_base) {
						is_open = false;
						overlay_scroll_dragging = false;
						_root.ClearActiveOverlayOwner();
						_root.ConsumeMouse();
					}
				}
			}
		}

		// Base hover and toggle open/close
		var _hover_base = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		// Keyboard: open when focused and Enter is pressed.
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled && !is_open) {
			is_open = true;
			_root.SetActiveOverlayOwner(id);
		}

		if (_hover_base && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			_root.FocusControl(id, _rect);
			is_open = !is_open;
			overlay_scroll_dragging = false;
			overlay_scroll_drag_offset_y = 0;
			if (is_open) {
				_root.SetActiveOverlayOwner(id);
				overlay_scroll_y = clamp((_idx * _row_h) - (_view_h * 0.5), 0, _max_scroll);
				overlay_hover_index = _idx;
			}
			else {
				_root.ClearActiveOverlayOwner();
			}
			_root.ConsumeMouse();
		}

		// Style
		var _styles = _root.theme.dropdown_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];
		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _tx_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.9;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _tx_alpha_base = _st[$ "text_alpha"] ?? 1;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _tx_disabled = _st[$ "text_disabled"] ?? _tx_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha_base;
		var _bg_hover = _st[$ "bg_hover"] ?? _st[$ "hover"] ?? merge_color(_bg_base, _tx_base, 0.15);
		var _bd_hover = _st[$ "border_hover"] ?? _bd_base;
		var _tx_hover = _st[$ "text_hover"] ?? _tx_base;
		var _bg_hover_alpha = _st[$ "bg_hover_alpha"] ?? _bg_alpha_base;
		var _bd_hover_alpha = _st[$ "border_hover_alpha"] ?? _bd_alpha_base;
		var _tx_hover_alpha = _st[$ "text_hover_alpha"] ?? _tx_alpha_base;
		var _bg_pressed = _st[$ "bg_pressed"] ?? _bg_hover;
		var _bd_pressed = _st[$ "border_pressed"] ?? _bd_hover;
		var _tx_pressed = _st[$ "text_pressed"] ?? _tx_hover;
		var _bg_pressed_alpha = _st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha;
		var _bd_pressed_alpha = _st[$ "border_pressed_alpha"] ?? _bd_hover_alpha;
		var _tx_pressed_alpha = _st[$ "text_pressed_alpha"] ?? _tx_hover_alpha;
		var _bg_open = _st[$ "bg_open"];
		var _bd_open = _st[$ "border_open"];
		var _tx_open = _st[$ "text_open"];
		var _bg_open_alpha = _st[$ "bg_open_alpha"];
		var _bd_open_alpha = _st[$ "border_open_alpha"];
		var _tx_open_alpha = _st[$ "text_open_alpha"];
		var _open_mix = _st[$ "open_mix"] ?? 0.15;

		var _pressed = _hover_base && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _tx_alpha = _tx_alpha_base;
		if (!enabled) {
			_bg_col = _bg_disabled;
			_bd_col = _bd_disabled;
			_tx_col = _tx_disabled;
			_bg_alpha = _bg_disabled_alpha;
			_bd_alpha = _bd_disabled_alpha;
			_tx_alpha = _tx_disabled_alpha;
		}
		else if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_tx_col = _tx_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
		}
		else if (_hover_base && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_tx_col = _tx_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
		}

		if (is_open && enabled && !_pressed) {
			if (is_undefined(_bg_open)) {
				_bg_col = merge_color(_bg_col, _tx_col, _open_mix);
			}
			else {
				_bg_col = _bg_open;
				if (!is_undefined(_bd_open)) {
					_bd_col = _bd_open;
				}
				if (!is_undefined(_tx_open)) {
					_tx_col = _tx_open;
				}
			}
			if (!is_undefined(_bg_open_alpha)) {
				_bg_alpha = _bg_open_alpha;
			}
			if (!is_undefined(_bd_open_alpha)) {
				_bd_alpha = _bd_open_alpha;
			}
			if (!is_undefined(_tx_open_alpha)) {
				_tx_alpha = _tx_open_alpha;
			}
		}

		// Draw base
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		// Base label
		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);
		draw_set_color(_tx_col);
		draw_set_alpha(_tx_alpha);

		var _label_str;
		if (!use_selected_label_when_closed && string_length(label) > 0) {
			_label_str = string(label);
		}
		else {
			_label_str = string(options[_idx]);
		}

		var _avail_w = max(0, (_x2 - _x1) - 16);
		var _draw_str = __TrimTextToWidth(_label_str, _avail_w, _root.theme.font_body);

		var _text_h = string_height(_draw_str);
		var _ty     = _y1 + ((_y2 - _y1) - _text_h) * 0.5;
		var _tx     = _x1 + 4;
		draw_text(_tx, _ty, _draw_str);

		// Arrow
		var _arrow_cx = _x2 - 9;
		var _arrow_cy = _y1 + (_y2 - _y1) * 0.5;
		draw_set_color(_tx_col);
		draw_triangle(_arrow_cx - 3, _arrow_cy - 2, _arrow_cx + 3, _arrow_cy - 2, _arrow_cx, _arrow_cy + 2, false);
		draw_set_alpha(_old_alpha);

		draw_set_font(_old_font);

		// Tooltip on base, only when closed
		if (_hover_base && string_length(tooltip) > 0 && !is_open) {
			_root.RequestTooltip(id, tooltip, _root.mx, _root.my);
		}

		// Draw overlay rows if open (visual only; click already handled)
		if (is_open) {
			var _overlay_rect = { x1: _ov_x1, y1: _ov_y1, x2: _ov_x2, y2: _ov_y2 };
			var _row_height_copy = _row_h;
			var _count_copy = _count;
			var _selected_copy = _idx;
			var _hover_idx_copy = overlay_hover_index;
			var _overlay_h_copy = _view_h;
			var _scroll_y_copy  = overlay_scroll_y;
			var _self = self;
			var _owner_win = _panel.owner_window;
			var _overlay_draw = method({_self, _overlay_rect, _count_copy, _row_height_copy, _selected_copy, _hover_idx_copy, _overlay_h_copy, _scroll_y_copy}, __DrawOverlay);
			_root.QueueOverlay(id, _overlay_draw, _overlay_rect, _owner_win);
			if (!_root.mouse_consumed) {
				if (_mx >= _overlay_rect.x1 && _mx <= _overlay_rect.x2 && _my >= _overlay_rect.y1 && _my <= _overlay_rect.y2) {
					_root.ConsumeMouse();
				}
			}
		}
	};

	/// @ignore
	static __DrawOverlay = function(_root_draw) {
		var _px1 = _overlay_rect.x1;
		var _py1 = _overlay_rect.y1;
		var _px2 = _overlay_rect.x2;
		var _py2 = _overlay_rect.y2;
		var _styles = _root_draw.theme.dropdown_styles;
		var _st = _styles[$ _self.style_id] ?? _styles[$ "_default"];
		var _bg_p = _st[$ "overlay_bg"] ?? _root_draw.theme.col_window_bg;
		var _bd_p = _st[$ "overlay_border"] ?? _root_draw.theme.col_accent;
		var _bg_alpha = _st[$ "overlay_bg_alpha"] ?? 0.95;
		var _bd_alpha = _st[$ "overlay_border_alpha"] ?? 1;
		var _old_alpha2 = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_p);
		draw_rectangle(_px1, _py1, _px2, _py2, false);
		draw_set_alpha(_old_alpha2);
		var _scroll = _scroll_y_copy;
		var _total_h2 = _row_height_copy * _count_copy;
		var _start = floor(_scroll / _row_height_copy);
		var _offset = _scroll - (_start * _row_height_copy);
		var _visible_rows = ceil((_overlay_h_copy + _offset) / _row_height_copy) + 1;
		var _end = min(_count_copy, _start + _visible_rows);
		for (var _oi = _start; _oi < _end; _oi++) {
			var _ry1 = _py1 + (_row_height_copy * (_oi - _start)) - _offset;
			var _ry2 = _ry1 + _row_height_copy;
			var _row_rect = { x1: _px1, y1: _ry1, x2: _px2, y2: _ry2 };
			var _mouse_inside_overlay = (_root_draw.mx >= _px1 && _root_draw.mx <= _px2 && _root_draw.my >= _py1 && _root_draw.my <= _py2);
			var _hover_row = false;
			if (_mouse_inside_overlay) {
				_hover_row = (_root_draw.mx >= _px1 && _root_draw.mx <= _px2 && _root_draw.my >= _ry1 && _root_draw.my <= _ry2);
			}
			else {
				_hover_row = (_oi == _hover_idx_copy);
			}
			var _is_sel = (_oi == _selected_copy);
			_self.DrawOverlayRow(_root_draw, _oi, _row_rect, _hover_row, _is_sel);
		}
		if (_total_h2 > _overlay_h_copy) {
			_root_draw.__DrawScrollbar(_px1, _py1, _px2, _py2, _total_h2, _scroll);
		}
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_p);
		draw_rectangle(_px1, _py1, _px2, _py2, true);
		draw_set_alpha(_old_alpha2);
	};
}

/// @func EchoChamberDropdownSelect(_id)
/// @desc Dropdown variant that binds a selected index to a struct field.
/// @param {Any} _id
/// @return {Struct.EchoChamberDropdownSelect}
function EchoChamberDropdownSelect(_id) : EchoChamberDropdownBase(_id) constructor {
	bind_struct = undefined;
	bind_key    = "";
	on_change   = undefined;

	/// @desc Bind the selected index to a struct field.
	/// @param {Struct} _struct
	/// @param {String} _key
	/// @return {Struct.EchoChamberDropdownSelect}
	static BindIndex = function(_struct, _key) {
		if (is_struct(_struct)) {
			bind_struct = _struct;
			bind_key    = string(_key);
		}
		return self;
	};

	/// @desc Set a callback that runs when selection changes.
	/// @param {Function} _fn function(_index, _value)
	/// @return {Struct.EchoChamberDropdownSelect}
	static OnChange = function(_fn) {
		if (is_callable(_fn)) {
			on_change = _fn;
		}
		return self;
	};

	/// @desc Return the selected option index.
	/// @return {Real}
	static GetSelectedIndex = function() {
		if (is_struct(bind_struct) && bind_key != "") {
			var _v = bind_struct[$ bind_key];
			return is_undefined(_v) ? selected_index : _v;
		}
		return selected_index;
	};

	/// @desc Set the selected option index and update the bound field (if configured).
	/// @param {Real} _idx
	static SetSelectedIndex = function(_idx) {
		_idx = clamp(_idx, 0, max(0, array_length(options) - 1));
		selected_index = _idx;
		if (is_struct(bind_struct) && bind_key != "") {
			bind_struct[$ bind_key] = _idx;
		}
	};

	/// @desc Handle a click on an overlay row (select, fire OnChange, then close).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _row_index
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Real} _mx
	/// @param {Real} _my
	static OnOverlayRowClick = function(_root, _row_index, _rect, _mx, _my) {
		var _old = GetSelectedIndex();
		if (_row_index != _old) {
			SetSelectedIndex(_row_index);
			if (is_callable(on_change)) {
				var _val = options[_row_index];
				on_change(_row_index, _val);
			}
		}
		is_open = false;
		_root.ClearActiveOverlayOwner();
	};

	// ProcessAndDraw stays inherited from base.
}

/// @func EchoChamberDropdownToggleMenu(_id)
/// @desc Dropdown variant that shows a checklist menu that stays open.
/// @param {Any} _id
/// @return {Struct.EchoChamberDropdownToggleMenu}
function EchoChamberDropdownToggleMenu(_id) : EchoChamberDropdownBase(_id) constructor {
	// Each item: { label, bind_struct, bind_key }
	items         = [];
	on_any_change = undefined;

	use_selected_label_when_closed = false;

	/// @desc Set the toggle menu items and rebuild the overlay option count.
	/// @param {Array<Struct>} _items Each item: {label, bind_struct, bind_key}
	/// @return {Struct.EchoChamberDropdownToggleMenu}
	static SetItems = function(_items) {
		items   = is_array(_items) ? _items : [];
		options = array_create(array_length(items), ""); // base uses length only
		return self;
	};

	/// @desc Set a callback that runs after any item is toggled.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberDropdownToggleMenu}
	static OnAnyChange = function(_fn) {
		if (is_callable(_fn)) {
			on_any_change = _fn;
		}
		return self;
	};

	/// @desc Return a selected index placeholder (toggle menus do not have a single selected row).
	/// @return {Real}
	static GetSelectedIndex = function() {
		// meaningless for toggle menu; base just needs something
		return 0;
	};

	/// @desc No-op for toggle menus (kept for base compatibility).
	/// @param {Real} _idx
	static SetSelectedIndex = function(_idx) {
		// no-op
	};

	/// @desc Draw a checklist row in the overlay.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _row_index
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Bool} _hover
	/// @param {Bool} _is_selected
	static DrawOverlayRow = function(_root, _row_index, _rect, _hover, _is_selected) {
		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _styles = _root.theme.dropdown_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "overlay_row_bg"] ?? _root.theme.col_panel_bg;
		var _bg_hover = _st[$ "overlay_row_hover"] ?? _root.theme.col_hover_row;
		var _bg_pressed = _st[$ "overlay_row_pressed"] ?? _bg_hover;
		var _bg_base_alpha = _st[$ "overlay_row_bg_alpha"] ?? 1;
		var _bg_hover_alpha = _st[$ "overlay_row_hover_alpha"] ?? _bg_base_alpha;
		var _bg_pressed_alpha = _st[$ "overlay_row_pressed_alpha"] ?? _bg_hover_alpha;

		var _tx_base = _st[$ "overlay_text"] ?? _root.theme.col_text;
		var _tx_hover = _st[$ "overlay_text_hover"] ?? _tx_base;
		var _tx_pressed = _st[$ "overlay_text_pressed"] ?? _tx_hover;
		var _tx_base_alpha = _st[$ "overlay_text_alpha"] ?? 1;
		var _tx_hover_alpha = _st[$ "overlay_text_hover_alpha"] ?? _tx_base_alpha;
		var _tx_pressed_alpha = _st[$ "overlay_text_pressed_alpha"] ?? _tx_hover_alpha;

		var _pressed = _hover && _root.mouse_l_down && enabled;
		var _bg = _bg_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_base_alpha;
		var _tx_alpha = _tx_base_alpha;
		if (_pressed) {
			_bg = _bg_pressed;
			_tx_col = _tx_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
		}
		else if (_hover) {
			_bg = _bg_hover;
			_tx_col = _tx_hover;
			_bg_alpha = _bg_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);

		var _h        = _y2 - _y1;
		var _box_size = min(_h - 6, 14);
		var _box_x1   = _x1 + 4;
		var _box_y1   = _y1 + (_h - _box_size) * 0.5;
		var _box_x2   = _box_x1 + _box_size;
		var _box_y2   = _box_y1 + _box_size;

		var _item    = items[_row_index];
		var _checked = false;
		if (is_struct(_item)) {
			var _bs = _item[$ "bind_struct"];
			var _bk = _item[$ "bind_key"];
			if (is_struct(_bs) && !is_undefined(_bk) && string_length(string(_bk)) > 0) {
				_checked = (_bs[$ _bk] == true);
			}
		}

		// box
		var _toggle_styles = _root.theme.toggle_styles;
		var _toggle_st = _toggle_styles[$ style_id] ?? _toggle_styles[$ "_default"];
		var _box_off = _toggle_st[$ "box_off"] ?? _root.theme.col_checkbox_off;
		var _box_on = _toggle_st[$ "box_on"] ?? _root.theme.col_checkbox_on;
		var _box_border = _toggle_st[$ "box_border"] ?? _root.theme.col_text;
		var _box_off_alpha = _toggle_st[$ "box_off_alpha"] ?? 1;
		var _box_on_alpha = _toggle_st[$ "box_on_alpha"] ?? 1;
		var _box_border_alpha = _toggle_st[$ "box_border_alpha"] ?? 1;
		var _box_off_hover = _toggle_st[$ "box_off_hover"] ?? _box_off;
		var _box_on_hover = _toggle_st[$ "box_on_hover"] ?? _box_on;
		var _box_border_hover = _toggle_st[$ "box_border_hover"] ?? _box_border;
		var _box_off_hover_alpha = _toggle_st[$ "box_off_hover_alpha"] ?? _box_off_alpha;
		var _box_on_hover_alpha = _toggle_st[$ "box_on_hover_alpha"] ?? _box_on_alpha;
		var _box_border_hover_alpha = _toggle_st[$ "box_border_hover_alpha"] ?? _box_border_alpha;
		var _box_off_pressed = _toggle_st[$ "box_off_pressed"] ?? _box_off_hover;
		var _box_on_pressed = _toggle_st[$ "box_on_pressed"] ?? _box_on_hover;
		var _box_border_pressed = _toggle_st[$ "box_border_pressed"] ?? _box_border_hover;
		var _box_off_pressed_alpha = _toggle_st[$ "box_off_pressed_alpha"] ?? _box_off_hover_alpha;
		var _box_on_pressed_alpha = _toggle_st[$ "box_on_pressed_alpha"] ?? _box_on_hover_alpha;
		var _box_border_pressed_alpha = _toggle_st[$ "box_border_pressed_alpha"] ?? _box_border_hover_alpha;

		var _box_bg_col = _box_off;
		var _box_fill_col = _box_on;
		var _box_border_col = _box_border;
		var _box_bg_alpha = _box_off_alpha;
		var _box_fill_alpha = _box_on_alpha;
		var _box_border_alpha_use = _box_border_alpha;
		if (_pressed) {
			_box_bg_col = _box_off_pressed;
			_box_fill_col = _box_on_pressed;
			_box_border_col = _box_border_pressed;
			_box_bg_alpha = _box_off_pressed_alpha;
			_box_fill_alpha = _box_on_pressed_alpha;
			_box_border_alpha_use = _box_border_pressed_alpha;
		}
		else if (_hover) {
			_box_bg_col = _box_off_hover;
			_box_fill_col = _box_on_hover;
			_box_border_col = _box_border_hover;
			_box_bg_alpha = _box_off_hover_alpha;
			_box_fill_alpha = _box_on_hover_alpha;
			_box_border_alpha_use = _box_border_hover_alpha;
		}

		draw_set_alpha(_box_bg_alpha);
		draw_set_color(_box_bg_col);
		draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
		draw_set_alpha(_box_border_alpha_use);
		draw_set_color(_box_border_col);
		draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);
		draw_set_alpha(_old_alpha);

		if (_checked) {
			draw_set_alpha(_box_fill_alpha);
			draw_set_color(_box_fill_col);
			draw_rectangle(_box_x1 + 2, _box_y1 + 2, _box_x2 - 2, _box_y2 - 2, false);
			draw_set_alpha(_old_alpha);
		}

		// label
		draw_set_alpha(_tx_alpha);
		draw_set_color(_tx_col);
		draw_set_font(_root.theme.font_body);

		var _lbl = is_struct(_item) ? string(_item[$ "label"] ?? "") : "";
		var _max_w = max(0, (_x2 - _x1) - (_box_size + 10));
		var _draw = __TrimTextToWidth(_lbl, _max_w, _root.theme.font_body);

		var _text_h = string_height(_draw);
		var _ty     = _y1 + (_h - _text_h) * 0.5;
		var _tx     = _box_x2 + 6;
		draw_text(_tx, _ty, _draw);
		draw_set_alpha(_old_alpha);
	};

	/// @desc Toggle the clicked item, fire OnAnyChange, and keep the menu open.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _row_index
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Real} _mx
	/// @param {Real} _my
	static OnOverlayRowClick = function(_root, _row_index, _rect, _mx, _my) {
		var _item = items[_row_index];
		if (is_struct(_item)) {
			var _bs = _item[$ "bind_struct"];
			var _bk = _item[$ "bind_key"];
			if (is_struct(_bs) && !is_undefined(_bk) && string_length(string(_bk)) > 0) {
				_bs[$ _bk] = !(_bs[$ _bk] == true);
			}
		}
		if (is_callable(on_any_change)) {
			on_any_change();
		}
		// important: DO NOT close here, menu stays open
	};
}



/// @ignore
/// @func EchoChamberMachinePicker(_id)
/// @desc Dropdown-style machine picker with search field at top, used in Statement Lens.
/// @param {Any} _id
/// @return {Struct.EchoChamberMachinePicker}
function EchoChamberMachinePicker(_id) : EchoChamberControlBase(_id) constructor {
	// Who provides the machine list?
	// This should be a function: function(_filter_string) -> { labels, index_map, selected_index }
	list_builder      = undefined;

	// What to do when the user picks a machine (we will pass it the "real" index from index_map)
	on_select_machine = undefined;

	// Visual / behaviour bits
	unfold_direction  = "down";   // "up" or "down"
	is_open           = false;

	// Search state
	search_text       = "";
	search_control_id = id + "_search";

	// Internal cached list for current frame (from list_builder)
	labels                = [];
	index_map             = [];
	selected_filtered_idx = 0;

	/// @desc Set a function that provides the list of machines based on the current filter text.
	/// @param {Function} _fn function(_filter_string) -> Struct {labels, index_map, selected_index}
	/// @return {Struct.EchoChamberMachinePicker}
	static SetListBuilder = function(_fn) {
		if (is_callable(_fn)) {
			list_builder = _fn;
		}
		return self;
	};

	/// @desc Set a callback that runs when the user selects a machine.
	/// @param {Function} _fn function(_real_index)
	/// @return {Struct.EchoChamberMachinePicker}
	static OnSelect = function(_fn) {
		if (is_callable(_fn)) {
			on_select_machine = _fn;
		}
		return self;
	};

	/// @desc Set the overlay unfold direction ("up" or "down").
	/// @param {String} _dir
	/// @return {Struct.EchoChamberMachinePicker}
	static SetUnfoldDirection = function(_dir) {
		unfold_direction = (_dir == "up") ? "up" : "down";
		return self;
	};

	static __RefreshList = function() {
		labels    = [];
		index_map = [];
		selected_filtered_idx = 0;

		if (!is_callable(list_builder)) {
			return;
		}

		var _res = list_builder(search_text);
		if (!is_struct(_res)) {
			return;
		}

		var _labels = _res[$ "labels"];
		if (is_array(_labels)) {
			labels = _labels;
		}
		var _index_map = _res[$ "index_map"];
		if (is_array(_index_map)) {
			index_map = _index_map;
		}
		var _selected = _res[$ "selected_index"];
		if (!is_undefined(_selected)) {
			selected_filtered_idx = clamp(_selected, 0, max(0, array_length(labels) - 1));
		}
	};

	static __CloseOverlay = function(_root) {
		is_open = false;
		if (!is_undefined(_root)) {
			_root.ClearActiveOverlayOwner();
			// If the search box had focus, blur it
			if (!is_undefined(_root.text_focus_id) && _root.text_focus_id == search_control_id) {
				_root.BlurTextInput(search_control_id);
			}
		}
	};

	/// @desc Process input and draw the picker (and overlay if open).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static ProcessAndDraw = function(_root, _panel, _rect) {
		if (!visible) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _row_h = _panel.row_height;
		if (_row_h <= 0) _row_h = _root.default_row_height;

		// Rebuild list for current search text
		__RefreshList();
		var _count = array_length(labels);

		// If no machines, just draw a disabled-looking button and bail
		if (_count <= 0) {
			var _styles_empty = _root.theme.dropdown_styles;
			var _st_empty = _styles_empty[$ style_id] ?? _styles_empty[$ "_default"];
			var _bg_empty = _st_empty[$ "bg_disabled"] ?? _st_empty[$ "bg"] ?? _root.theme.col_panel_bg;
			var _bd_empty = _st_empty[$ "border_disabled"] ?? _st_empty[$ "border"] ?? _root.theme.col_accent;
			var _tx_empty = _st_empty[$ "text_disabled"] ?? _st_empty[$ "text"] ?? _root.theme.col_text_dim;
			var _bg_empty_alpha = _st_empty[$ "bg_disabled_alpha"] ?? (_st_empty[$ "bg_alpha"] ?? 0.9);
			var _bd_empty_alpha = _st_empty[$ "border_disabled_alpha"] ?? (_st_empty[$ "border_alpha"] ?? 1);
			var _tx_empty_alpha = _st_empty[$ "text_disabled_alpha"] ?? (_st_empty[$ "text_alpha"] ?? 1);
			var _old_alpha_empty = draw_get_alpha();
			draw_set_alpha(_bg_empty_alpha);
			draw_set_color(_bg_empty);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
			draw_set_alpha(_bd_empty_alpha);
			draw_set_color(_bd_empty);
			draw_rectangle(_x1, _y1, _x2, _y2, true);
			draw_set_alpha(_old_alpha_empty);

			var _old_font = draw_get_font();
			draw_set_font(_root.theme.font_body);
			draw_set_alpha(_tx_empty_alpha);
			draw_set_color(_tx_empty);
			var _txt = "None";
			var _tw = string_width(_txt);
			var _th = string_height(_txt);
			var _tx = _x1 + ((_x2 - _x1) - _tw) * 0.5;
			var _ty = _y1 + ((_y2 - _y1) - _th) * 0.5;
			draw_text(_tx, _ty, _txt);
			draw_set_alpha(_old_alpha_empty);
			draw_set_font(_old_font);
			return;
		}

		// We have at least one machine
		var _sel_idx = clamp(selected_filtered_idx, 0, _count - 1);
		var _label_cur = string(labels[_sel_idx]);

		// Base hover and click
		var _hover_base = _root.HitTestRect(_x1, _y1, _x2, _y2) && enabled;

		if (enabled) {
			_root.RegisterFocusable(id, _rect);
		}

		// Keyboard: open when focused and Enter is pressed.
		if (_root.IsControlFocused(id) && _root.InputPressed(ECHO_UI_ACTION_ACCEPT) && enabled && !is_open) {
			is_open = true;
			_root.SetActiveOverlayOwner(id);
		}

		// Style (reuse dropdown styles)
		var _styles = _root.theme.dropdown_styles;
		var _st = _styles[$ style_id] ?? _styles[$ "_default"];

		var _bg_base = _st[$ "bg"] ?? _root.theme.col_panel_bg;
		var _bd_base = _st[$ "border"] ?? _root.theme.col_accent;
		var _tx_base = _st[$ "text"] ?? _root.theme.col_text;
		var _bg_alpha_base = _st[$ "bg_alpha"] ?? 0.9;
		var _bd_alpha_base = _st[$ "border_alpha"] ?? 1;
		var _tx_alpha_base = _st[$ "text_alpha"] ?? 1;
		var _bg_disabled = _st[$ "bg_disabled"] ?? _bg_base;
		var _bd_disabled = _st[$ "border_disabled"] ?? _bd_base;
		var _tx_disabled = _st[$ "text_disabled"] ?? _tx_base;
		var _bg_disabled_alpha = _st[$ "bg_disabled_alpha"] ?? _bg_alpha_base;
		var _bd_disabled_alpha = _st[$ "border_disabled_alpha"] ?? _bd_alpha_base;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha_base;
		var _bg_hover = _st[$ "bg_hover"] ?? _st[$ "hover"] ?? merge_color(_bg_base, _tx_base, 0.15);
		var _bd_hover = _st[$ "border_hover"] ?? _bd_base;
		var _tx_hover = _st[$ "text_hover"] ?? _tx_base;
		var _bg_hover_alpha = _st[$ "bg_hover_alpha"] ?? _bg_alpha_base;
		var _bd_hover_alpha = _st[$ "border_hover_alpha"] ?? _bd_alpha_base;
		var _tx_hover_alpha = _st[$ "text_hover_alpha"] ?? _tx_alpha_base;
		var _bg_pressed = _st[$ "bg_pressed"] ?? _bg_hover;
		var _bd_pressed = _st[$ "border_pressed"] ?? _bd_hover;
		var _tx_pressed = _st[$ "text_pressed"] ?? _tx_hover;
		var _bg_pressed_alpha = _st[$ "bg_pressed_alpha"] ?? _bg_hover_alpha;
		var _bd_pressed_alpha = _st[$ "border_pressed_alpha"] ?? _bd_hover_alpha;
		var _tx_pressed_alpha = _st[$ "text_pressed_alpha"] ?? _tx_hover_alpha;
		var _bg_open = _st[$ "bg_open"];
		var _bd_open = _st[$ "border_open"];
		var _tx_open = _st[$ "text_open"];
		var _bg_open_alpha = _st[$ "bg_open_alpha"];
		var _bd_open_alpha = _st[$ "border_open_alpha"];
		var _tx_open_alpha = _st[$ "text_open_alpha"];
		var _open_mix = _st[$ "open_mix"] ?? 0.15;

		var _pressed = _hover_base && _root.mouse_l_down && enabled;
		var _bg_col = _bg_base;
		var _bd_col = _bd_base;
		var _tx_col = _tx_base;
		var _bg_alpha = _bg_alpha_base;
		var _bd_alpha = _bd_alpha_base;
		var _tx_alpha = _tx_alpha_base;
		if (!enabled) {
			_bg_col = _bg_disabled;
			_bd_col = _bd_disabled;
			_tx_col = _tx_disabled;
			_bg_alpha = _bg_disabled_alpha;
			_bd_alpha = _bd_disabled_alpha;
			_tx_alpha = _tx_disabled_alpha;
		}
		else if (_pressed) {
			_bg_col = _bg_pressed;
			_bd_col = _bd_pressed;
			_tx_col = _tx_pressed;
			_bg_alpha = _bg_pressed_alpha;
			_bd_alpha = _bd_pressed_alpha;
			_tx_alpha = _tx_pressed_alpha;
		}
		else if (_hover_base && enabled) {
			_bg_col = _bg_hover;
			_bd_col = _bd_hover;
			_tx_col = _tx_hover;
			_bg_alpha = _bg_hover_alpha;
			_bd_alpha = _bd_hover_alpha;
			_tx_alpha = _tx_hover_alpha;
		}

		if (is_open && enabled && !_pressed) {
			if (is_undefined(_bg_open)) {
				_bg_col = merge_color(_bg_col, _tx_col, _open_mix);
			}
			else {
				_bg_col = _bg_open;
				if (!is_undefined(_bd_open)) {
					_bd_col = _bd_open;
				}
				if (!is_undefined(_tx_open)) {
					_tx_col = _tx_open;
				}
			}
			if (!is_undefined(_bg_open_alpha)) {
				_bg_alpha = _bg_open_alpha;
			}
			if (!is_undefined(_bd_open_alpha)) {
				_bd_alpha = _bd_open_alpha;
			}
			if (!is_undefined(_tx_open_alpha)) {
				_tx_alpha = _tx_open_alpha;
			}
		}

		// Base button background
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		// Base label
		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);
		draw_set_color(_tx_col);
		draw_set_alpha(_tx_alpha);

		var _avail_w = max(0, (_x2 - _x1) - 16);
		var _draw_lbl = __TrimTextToWidth(_label_cur, _avail_w, _root.theme.font_body);

		var _text_h = string_height(_draw_lbl);
		var _ty     = _y1 + ((_y2 - _y1) - _text_h) * 0.5;
		var _tx     = _x1 + 4;
		draw_text(_tx, _ty, _draw_lbl);

		// Arrow
		var _arrow_cx = _x2 - 9;
		var _arrow_cy = _y1 + (_y2 - _y1) * 0.5;
		draw_set_color(_tx_col);
		draw_triangle(_arrow_cx - 3, _arrow_cy - 2, _arrow_cx + 3, _arrow_cy - 2, _arrow_cx, _arrow_cy + 2, false);
		draw_set_alpha(_old_alpha);

		draw_set_font(_old_font);

		// Tooltip on base
		if (_hover_base && string_length(tooltip) > 0 && !is_open) {
			_root.RequestTooltip(id, tooltip, _mx, _my);
		}

		// Toggle open / close
		if (_hover_base && _root.mouse_l_pressed && !_root.mouse_consumed && enabled) {
			_root.FocusControl(id, _rect);
			is_open = !is_open;
			if (is_open) {
				_root.SetActiveOverlayOwner(id);
			}
			else {
				__CloseOverlay(_root);
			}
			_root.ConsumeMouse();
		}

		// Compute overlay rect: search row + list rows
		var _search_h = _row_h;
		var _list_h   = _row_h * _count;
		var _ov_x1    = _x1;
		var _ov_x2    = _x2;
		var _ov_y1, _ov_y2;

		if (unfold_direction == "up") {
			_ov_y2 = _y1;
			_ov_y1 = _ov_y2 - (_search_h + _list_h);
		}
		else {
			_ov_y1 = _y2;
			_ov_y2 = _ov_y1 + (_search_h + _list_h);
		}

		// Overlay interaction and drawing
		if (is_open) {
			_root.SetActiveOverlayOwner(id);

			// Honor overlay close requests (Esc).
			if (_root.__ConsumeOverlayCloseRequest(id)) {
				__CloseOverlay(_root);
			}
			if (!is_open) {
				return;
			}

			var _inside_overlay = (_mx >= _ov_x1 && _mx <= _ov_x2 && _my >= _ov_y1 && _my <= _ov_y2);
			var _inside_base    = (_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _y2);

			// Search row rect
			var _sx1 = _ov_x1;
			var _sy1 = _ov_y1;
			var _sx2 = _ov_x2;
			var _sy2 = _sy1 + _search_h;

			// List rect start
			var _lx1 = _ov_x1;
			var _ly1 = _sy2;
			var _lx2 = _ov_x2;
			var _ly2 = _ov_y2;

			// Search box input
			var _hover_search = (_mx >= _sx1 && _mx <= _sx2 && _my >= _sy1 && _my <= _sy2);

			var _search_active = (!is_undefined(_root.text_focus_id) && _root.text_focus_id == search_control_id);

			// Handle click to focus / blur search
			if (_root.mouse_l_pressed && !_root.mouse_consumed) {
				if (_hover_search && enabled) {
					_root.FocusTextInput(search_control_id, search_text, "Filter...");
					_search_active = true;
					_root.ConsumeMouse();
				}
				else if (_mx >= _lx1 && _mx <= _lx2 && _my >= _ly1 && _my <= _ly2 && enabled) {
					var _row_index = floor((_my - _ly1) / max(0.0001, _row_h));
					_row_index = clamp(_row_index, 0, _count - 1);
					if (_row_index >= 0 && _row_index < array_length(index_map)) {
						var _machine_index = index_map[_row_index];
						if (is_callable(on_select_machine)) {
							on_select_machine(_machine_index);
						}
					}
					__CloseOverlay(_root);
					_root.ConsumeMouse();
				}
				else if (!_inside_base && !_inside_overlay) {
					// Clicked outside everything -> close
					__CloseOverlay(_root);
					_root.ConsumeMouse();
				}
			}

			// Update search text from root while active
			if (_search_active) {
				search_text = _root.GetActiveText();
			}

			// Queue overlay draw after windows so it is always on top.
			var _overlay_rect = { x1: _ov_x1, y1: _ov_y1, x2: _ov_x2, y2: _ov_y2 };
			var _self = self;
			var _draw_overlay = method({
				owner      : _self,
				rect       : _overlay_rect,
				row_h      : _row_h,
				search_h   : _search_h,
				sel_idx    : _sel_idx
			}, __DrawOverlay);
			_root.QueueOverlay(id, _draw_overlay, _overlay_rect);

			// Finally, prevent underlying UI from seeing mouse while inside overlay
			if (!_root.mouse_consumed && _inside_overlay) {
				_root.ConsumeMouse();
			}
		}
	};

	/// @ignore
	static __DrawOverlay = function(_r) {
		var _o = owner;
		if (!is_struct(_o)) {
			return;
		}

		var _mx2 = _r.mx;
		var _my2 = _r.my;

		var _styles = _r.theme.dropdown_styles;
		var _st = _styles[$ _o.style_id] ?? _styles[$ "_default"];

		var _ov_x1b = rect.x1;
		var _ov_y1b = rect.y1;
		var _ov_x2b = rect.x2;
		var _ov_y2b = rect.y2;

		// Background
		var _bg_panel = _st[$ "overlay_bg"] ?? _r.theme.col_window_bg;
		var _bd_panel = _st[$ "overlay_border"] ?? _r.theme.col_accent;
		var _bg_alpha = _st[$ "overlay_bg_alpha"] ?? 0.95;
		var _bd_alpha = _st[$ "overlay_border_alpha"] ?? 1;
		var _old_alpha2 = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_panel);
		draw_rectangle(_ov_x1b, _ov_y1b, _ov_x2b, _ov_y2b, false);
		draw_set_alpha(_bd_alpha);
		draw_set_color(_bd_panel);
		draw_rectangle(_ov_x1b, _ov_y1b, _ov_x2b, _ov_y2b, true);
		draw_set_alpha(_old_alpha2);

		// Search row rect
		var _sx1b = _ov_x1b;
		var _sy1b = _ov_y1b;
		var _sx2b = _ov_x2b;
		var _sy2b = _sy1b + search_h;

		// List rect start
		var _lx1b = _ov_x1b;
		var _ly1b = _sy2b;
		var _lx2b = _ov_x2b;
		var _ly2b = _ov_y2b;

		// Search box visuals
		var _hover_search2 = (_mx2 >= _sx1b && _mx2 <= _sx2b && _my2 >= _sy1b && _my2 <= _sy2b);

		var _search_bg = _st[$ "overlay_search_bg"] ?? _r.theme.col_panel_bg;
		var _search_hover_bg = _st[$ "overlay_search_hover_bg"] ?? merge_color(_search_bg, _r.theme.col_text, 0.2);
		var _search_border = _st[$ "overlay_search_border"] ?? _bd_panel;
		var _search_text = _st[$ "overlay_search_text"] ?? _r.theme.col_text;
		var _search_placeholder = _st[$ "overlay_search_placeholder"] ?? _r.theme.col_muted;
		var _search_bg_alpha = _st[$ "overlay_search_bg_alpha"] ?? 1;
		var _search_hover_bg_alpha = _st[$ "overlay_search_hover_bg_alpha"] ?? _search_bg_alpha;
		var _search_border_alpha = _st[$ "overlay_search_border_alpha"] ?? _bd_alpha;
		var _search_text_alpha = _st[$ "overlay_search_text_alpha"] ?? 1;
		var _search_placeholder_alpha = _st[$ "overlay_search_placeholder_alpha"] ?? _search_text_alpha;

		var _bg_search = _hover_search2 ? _search_hover_bg : _search_bg;
		var _bg_search_alpha = _hover_search2 ? _search_hover_bg_alpha : _search_bg_alpha;
		draw_set_alpha(_bg_search_alpha);
		draw_set_color(_bg_search);
		draw_rectangle(_sx1b, _sy1b, _sx2b, _sy2b, false);
		draw_set_alpha(_search_border_alpha);
		draw_set_color(_search_border);
		draw_rectangle(_sx1b, _sy1b, _sx2b, _sy2b, true);
		draw_set_alpha(_old_alpha2);

		// Draw search text
		var _old_font_s = draw_get_font();
		draw_set_font(_r.theme.font_body);
		draw_set_alpha(_search_text_alpha);
		draw_set_color(_search_text);

		var _search_display = (string_length(_o.search_text) > 0) ? _o.search_text : "Filter...";
		if (string_length(_o.search_text) <= 0) {
			draw_set_alpha(_search_placeholder_alpha);
			draw_set_color(_search_placeholder);
		}

		var _pad_x = _o.__ResolvePaddingX(_r);
		var _max_sw = max(0, (_sx2b - _sx1b) - _pad_x * 2);
		var _draw_search = __TrimTextToWidth(_search_display, _max_sw, _r.theme.font_body);

		var _sh = string_height(_draw_search);
		var _sty = _sy1b + (search_h - _sh) * 0.5;
		var _stx = _sx1b + _pad_x;
		draw_text(_stx, _sty, _draw_search);
		draw_set_alpha(_old_alpha2);
		draw_set_font(_old_font_s);

		// Draw list rows (visual only; clicks handled in the control)
		var _row_bg = _st[$ "overlay_row_bg"] ?? _r.theme.col_panel_bg;
		var _row_hover = _st[$ "overlay_row_hover"] ?? _r.theme.col_hover_row;
		var _row_selected = _st[$ "overlay_row_selected"] ?? _r.theme.col_hover_row_alt;
		var _row_pressed = _st[$ "overlay_row_pressed"] ?? _row_hover;
		var _row_text = _st[$ "overlay_text"] ?? _r.theme.col_text;
		var _row_text_hover = _st[$ "overlay_text_hover"] ?? _row_text;
		var _row_text_selected = _st[$ "overlay_text_selected"] ?? _row_text;
		var _row_text_pressed = _st[$ "overlay_text_pressed"] ?? _row_text_hover;
		var _row_bg_alpha = _st[$ "overlay_row_bg_alpha"] ?? 1;
		var _row_hover_alpha = _st[$ "overlay_row_hover_alpha"] ?? _row_bg_alpha;
		var _row_selected_alpha = _st[$ "overlay_row_selected_alpha"] ?? _row_bg_alpha;
		var _row_pressed_alpha = _st[$ "overlay_row_pressed_alpha"] ?? _row_hover_alpha;
		var _row_text_alpha = _st[$ "overlay_text_alpha"] ?? 1;
		var _row_text_hover_alpha = _st[$ "overlay_text_hover_alpha"] ?? _row_text_alpha;
		var _row_text_selected_alpha = _st[$ "overlay_text_selected_alpha"] ?? _row_text_alpha;
		var _row_text_pressed_alpha = _st[$ "overlay_text_pressed_alpha"] ?? _row_text_hover_alpha;

		var _count2 = array_length(_o.labels);
		var _sel2 = clamp(sel_idx, 0, max(0, _count2 - 1));
		for (var _i = 0; _i < _count2; _i++) {
			var _ry1 = _ly1b + row_h * _i;
			var _ry2 = _ry1 + row_h;

			var _hover_row = (_mx2 >= _lx1b && _mx2 <= _lx2b && _my2 >= _ry1 && _my2 <= _ry2);
			var _pressed_row = _hover_row && _r.mouse_l_down;
			var _is_sel    = (_i == _sel2);

			var _bg_row = _row_bg;
			var _tx_row = _row_text;
			_bg_alpha = _row_bg_alpha;
			var _tx_alpha = _row_text_alpha;
			if (_pressed_row) {
				_bg_row = _row_pressed;
				_tx_row = _row_text_pressed;
				_bg_alpha = _row_pressed_alpha;
				_tx_alpha = _row_text_pressed_alpha;
			}
			else if (_is_sel) {
				_bg_row = _row_selected;
				_tx_row = _row_text_selected;
				_bg_alpha = _row_selected_alpha;
				_tx_alpha = _row_text_selected_alpha;
			}
			else if (_hover_row) {
				_bg_row = _row_hover;
				_tx_row = _row_text_hover;
				_bg_alpha = _row_hover_alpha;
				_tx_alpha = _row_text_hover_alpha;
			}

			draw_set_alpha(_bg_alpha);
			draw_set_color(_bg_row);
			draw_rectangle(_lx1b, _ry1, _lx2b, _ry2, false);
			draw_set_alpha(_tx_alpha);

			draw_set_color(_tx_row);
			draw_set_font(_r.theme.font_body);

			var _opt_str = string(_o.labels[_i]);
			var _max_w = max(0, (_lx2b - _lx1b) - _pad_x * 2);
			var _draw_lbl_row = __TrimTextToWidth(_opt_str, _max_w, _r.theme.font_body);

			var _th2 = string_height(_draw_lbl_row);
			var _ty2 = _ry1 + (row_h - _th2) * 0.5;
			var _tx2 = _lx1b + _pad_x;
			draw_text(_tx2, _ty2, _draw_lbl_row);
			draw_set_alpha(_old_alpha2);
		}
	}
}
