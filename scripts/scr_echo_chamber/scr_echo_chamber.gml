/*
Echo Chamber is a fully featured debug UI creator that comes packaged with Echo.
I have been working on it in the background for awhile now, and it's finally come
to fruition. If you want to learn how to use it, I would recommend reading
the docs: refreshertowel.github.io/docs/echo/echo_chamber/

Note: Echo Chamber is the newest thing I have built, and this means it's less battle-tested
than the other products I have. So if you encounter any bugs or strange behaviours, please
make sure to report them either on the discord or the github issues page for Echo:
https://github.com/RefresherTowel/Echo/issues
*/


/// @func EchoChamberRoot(_theme)
/// @desc Root container for debug UI panels and controls.
/// @param {Struct.EchoChamberTheme} _theme
/// @return {Struct.EchoChamberRoot}
function EchoChamberRoot(_theme) constructor {
	// Theme + basic metrics
	if (is_instanceof(_theme, EchoChamberTheme)) {
		theme = _theme;
	}
	else {
		theme = new EchoChamberTheme();
	}
	theme.RefreshMetrics();

	// Input snapshot
	mx              = 0;
	my              = 0;
	mouse_l_down    = false;
	mouse_l_pressed = false;
	mouse_r_down    = false;
	mouse_r_pressed = false;
	mouse_m_down    = false;
	mouse_m_pressed = false;
	wheel_delta     = 0;

	mouse_consumed  = false;
	wheel_consumed  = false;

	key_escape_pressed = false;
	key_enter_pressed  = false;
	key_up_pressed     = false;
	key_down_pressed   = false;
	key_pageup_pressed = false;
	key_pagedown_pressed = false;
	key_home_pressed = false;
	key_end_pressed = false;

	key_tab_pressed	= false;
	key_shift_down	= false;

	// Input action contexts (rebindable controls)
	input_contexts = {};
	input_default_context_id = "__echo_chamber_global";
	input_contexts[$ input_default_context_id] = new EchoChamberInputContext(input_default_context_id);

	// Keyboard focus window (used for Tab focus navigation when no control is focused)
	keyboard_focus_window	= undefined;

	// Per-frame focusable registry (for Tab navigation)
	focusable_ids		= [];
	focusable_windows	= [];
	focusable_x1		= [];
	focusable_y1		= [];
	focusable_x2		= [];
	focusable_y2		= [];
	focusable_count		= 0;


	overlay_close_requested = false;

	control_focus_id = undefined;
	control_focus_rect_last = undefined;
	control_focus_window = undefined;

	text_focus_id  = undefined;
	text_buffer    = "";
	text_initial_value = "";
	text_placeholder = "";
	text_source    = undefined;  // function that returns current text, default uses keyboard_string
	text_seed      = undefined;  // function to seed keyboard_string on focus
	text_commit    = undefined;  // optional: function(final_text) called on blur
	text_submit    = undefined;  // optional: function(final_text) called on submit commit
	text_cancel    = undefined;  // optional: function(cancelled_text, initial_text) called on cancel
	text_focus_cb  = undefined;  // optional: function(current_text) called when text input gains focus
	text_blur_cb   = undefined;  // optional: function(last_text, was_cancelled) called when text input loses focus
	text_focus_rect_last = undefined; // last known rect for active text input
	text_focus_window = undefined;
	text_input_config = undefined;
	text_caret_index = 0;
	text_selection_anchor = -1;
	text_scroll_x = 0;
	text_scroll_y = 0;
	text_preferred_x = 0;
	text_preferred_x_valid = false;
	text_caret_visible = true;
	text_caret_blink_time = 0;
	text_double_click_ms = 320;
	text_last_click_time = 0;
	text_last_click_index = -1;
	text_last_click_id = undefined;
	text_last_click_count = 0;
	text_last_char = "";
	text_last_char_key = 0;
	text_mouse_selecting = false;
	text_mouse_select_id = undefined;
	text_mouse_select_mode = "char"; // "char" | "word" | "all"
	text_mouse_select_base_start = -1;
	text_mouse_select_base_end = -1;
	text_undo_stack = [];
	text_redo_stack = [];
	text_undo_limit = 64;
	text_key_repeat_next = {};
	text_key_repeat_delay_ms = 350;
	text_key_repeat_rate_ms = 40;
	text_edit_gen = 0;
	text_layout_cache = undefined;
	text_layout_cache_id = undefined;
	text_layout_cache_gen = -1;
	text_layout_cache_wrap = false;
	text_layout_cache_view_w = 0;
	text_layout_cache_font = undefined;
	text_layout_cache_password_mask = false;
	text_layout_cache_password_char = "*";
	text_layout_cache_tab_spaces = 4;
	text_live_dirty = false;
	text_live_next_at = 0;


	// Panels (top-level)
	panels = [];

	// Registered windows (multi-window desktop usage)
	windows = [];
	mouse_capture_window = undefined;
	modal_window = undefined;
	window_min_visible_titlebar_w = 32;
	window_min_visible_titlebar_h = 12;

	// Persistence (layout + visibility)
	persistence_file = "echo_debug_ui.ini";
	persistence_section = "EchoEchoChamber";
	persistence_version = 2;

	// Overlay render queue (dropdowns, popups)
	overlays = [];
	overlays_drawn = false;

	// Tooltip state (control-id based, not text+pixel)
	tooltip_control_id  = undefined;
	tooltip_text        = "";
	tooltip_anchor_x    = 0;
	tooltip_anchor_y    = 0;
	tooltip_delay_ms    = 350;
	tooltip_start_time  = 0;
	tooltip_visible     = false;
	tooltip_requested_this_frame = false;
	tooltip_owner_window = undefined;

	// Toast state (copy feedback)
	toast_text				= "";
	toast_start_time		= 0;
	toast_until_time		= 0;
	toast_duration_ms		= 650;
	toast_fade_ms			= 160;
	toast_max_preview_chars	= 80;

	// Overlay ownership (e.g. an open dropdown)
	active_overlay_owner_id = undefined;
	active_overlay_owner_window = undefined;
	active_overlay_rect = undefined;
	__field_label_proxy_click_id = undefined;

	// Context menu overlay (generic)
	context_menu_open			= false;
	context_menu_owner_id		= "__EchoChamber_context_menu";
	context_menu_owner_window	= undefined;

	context_menu_items			= [];
	context_menu_item_count		= 0;

	context_menu_x				= 0;
	context_menu_y				= 0;
	context_menu_w				= 0;
	context_menu_h				= 0;
	context_menu_pad			= 0;
	context_menu_row_h			= 0;
	context_menu_sep_h			= 0;
	context_menu_rect			= undefined;
	context_menu_style_id		= "_default";

	context_menu_hover_i		= -1;
	context_menu_key_i			= -1;

	context_menu_open_time		= 0;


	// Panel splitter dragging (dock resize)
	panel_split_dragging = false;
	panel_split_drag_panel = undefined;
	panel_split_drag_dock = eEchoChamberDock.FILL;
	panel_split_drag_start_m = 0;
	panel_split_drag_start_size = 0;
	panel_split_drag_sign = 1;

	// Internal: current window context while drawing controls
	__current_window = undefined;

	// Internal: focus click consumption (consume clicks on empty window space without blocking control clicks)
	__pending_focus_window   = undefined;
	__pending_focus_consume  = false;

	// Internal: input suppression stack (used to draw controls without input while an overlay is open)
	__input_suppress_stack = [];

	// Internal: clip (scissor) stack
	__clip_stack = [];
	__clip_stack_len = 0;

	// Internal: theme override stack (scoped window themes)
	__theme_stack = [];

	// Default layout hints (theme-driven, with fallbacks)
	default_control_width = theme.default_control_width;
	default_control_max_width = theme.default_control_max_width;
	default_row_height    = theme.default_row_height;
	default_padding       = theme.default_padding;
	default_gap           = theme.gap;
	default_control_padding_x = theme[$ "control_padding_x"] ?? theme[$ "pad_x"] ?? 0;
	default_control_padding_y = theme[$ "control_padding_y"] ?? theme[$ "pad_y"] ?? 0;
	default_control_margin_x  = theme[$ "control_margin_x"] ?? 0;
	default_control_margin_y  = theme[$ "control_margin_y"] ?? 0;

	/// @ignore
	/// @func __ApplyThemeDefaults()
	/// @desc Pull skinnable defaults from the current theme (with fallbacks).
	static __ApplyThemeDefaults = function() {
		// Layout metrics
		default_control_width = theme.default_control_width;
		default_control_max_width = theme.default_control_max_width;
		default_gap = theme.gap;
		default_padding = theme.default_padding;
		default_row_height = theme.default_row_height;
		default_control_padding_x = theme[$ "control_padding_x"] ?? theme[$ "pad_x"] ?? 0;
		default_control_padding_y = theme[$ "control_padding_y"] ?? theme[$ "pad_y"] ?? 0;
		default_control_margin_x = theme[$ "control_margin_x"] ?? 0;
		default_control_margin_y = theme[$ "control_margin_y"] ?? 0;

		// Tooltip behavior
		tooltip_delay_ms = theme.tooltip_delay_ms;
	};

	/// @ignore
	/// @desc Internal: apply theme overrides to a control.
	/// @param {Struct.EchoChamberControlBase} _ctrl
	static __ApplyThemeToControl = function(_ctrl) {
		var _apply = _ctrl[$ "ApplyTheme"];
		if (is_callable(_apply)) {
			_apply(_ctrl, self);
		}
	};

	/// @ignore
	/// @desc Internal: reset panel theme defaults recursively and apply control theme overrides.
	/// @param {Struct.EchoChamberPanel} _panel
	static __ClearPanelThemeDefaults = function(_panel) {
		_panel.__theme_defaults_applied = false;
		var _controls = _panel[$ "children_controls"];
		if (is_array(_controls)) {
			var _clen = array_length(_controls);
			for (var _ci = 0; _ci < _clen; _ci++) {
				__ApplyThemeToControl(_controls[_ci]);
			}
		}
		var _children = _panel[$ "children_panels"];
		if (is_array(_children)) {
			var _len = array_length(_children);
			for (var _i = 0; _i < _len; _i++) {
				__ClearPanelThemeDefaults(_children[_i]);
			}
		}
	};

	/// @ignore
	/// @func __PushThemeOverride(_theme)
	/// @desc Internal: swap the root theme + defaults for a scoped override.
	/// @param {Struct.EchoChamberTheme} _theme
	/// @return {Bool}
	static __PushThemeOverride = function(_theme) {
		if (!is_instanceof(_theme, EchoChamberTheme)) {
			return false;
		}
		var _entry = {
			theme: theme,
			default_control_width: default_control_width,
			default_control_max_width: default_control_max_width,
			default_row_height: default_row_height,
			default_padding: default_padding,
			default_gap: default_gap,
			default_control_padding_x: default_control_padding_x,
			default_control_padding_y: default_control_padding_y,
			default_control_margin_x: default_control_margin_x,
			default_control_margin_y: default_control_margin_y,
			tooltip_delay_ms: tooltip_delay_ms
		};
		array_push(__theme_stack, _entry);
		theme = _theme;
		__ApplyThemeDefaults();
		return true;
	};

	/// @ignore
	/// @func __PopThemeOverride()
	/// @desc Internal: restore the root theme + defaults after a scoped override.
	static __PopThemeOverride = function() {
		var _len = array_length(__theme_stack);
		if (_len <= 0) {
			return;
		}
		var _entry = __theme_stack[_len - 1];
		array_delete(__theme_stack, _len - 1, 1);
		theme = _entry[$ "theme"];
		default_control_width = _entry[$ "default_control_width"];
		default_control_max_width = _entry[$ "default_control_max_width"];
		default_row_height = _entry[$ "default_row_height"];
		default_padding = _entry[$ "default_padding"];
		default_gap = _entry[$ "default_gap"];
		default_control_padding_x = _entry[$ "default_control_padding_x"];
		default_control_padding_y = _entry[$ "default_control_padding_y"];
		default_control_margin_x = _entry[$ "default_control_margin_x"];
		default_control_margin_y = _entry[$ "default_control_margin_y"];
		tooltip_delay_ms = _entry[$ "tooltip_delay_ms"];
	};

	/// @ignore
	/// @func __PushWindowTheme(_window)
	/// @desc Internal: apply a window theme override (if any) to the root.
	/// @param {Struct.EchoChamberWindow} _window
	/// @return {Bool}
	static __PushWindowTheme = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return false;
		}
		var _theme = _window.theme_override;
		return __PushThemeOverride(_theme);
	};

	/// @ignore
	/// @func __BindDefaultInputActions()
	/// @desc Register default input bindings for core UI actions.
	static __BindDefaultInputActions = function() {
		var _ctx = input_contexts[$ input_default_context_id];
		if (!is_instanceof(_ctx, EchoChamberInputContext)) {
			return;
		}

		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_CANCEL))) {
			_ctx.BindAction(ECHO_UI_ACTION_CANCEL, ECHO_UI_BIND_CANCEL);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_ACCEPT))) {
			_ctx.BindAction(ECHO_UI_ACTION_ACCEPT, ECHO_UI_BIND_ACCEPT);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_TAB_NEXT))) {
			_ctx.BindAction(ECHO_UI_ACTION_TAB_NEXT, ECHO_UI_BIND_TAB_NEXT);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_TAB_PREV))) {
			_ctx.BindAction(ECHO_UI_ACTION_TAB_PREV, ECHO_UI_BIND_TAB_PREV);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_NAV_UP))) {
			_ctx.BindAction(ECHO_UI_ACTION_NAV_UP, ECHO_UI_BIND_NAV_UP);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_NAV_DOWN))) {
			_ctx.BindAction(ECHO_UI_ACTION_NAV_DOWN, ECHO_UI_BIND_NAV_DOWN);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_PAGE_UP))) {
			_ctx.BindAction(ECHO_UI_ACTION_PAGE_UP, ECHO_UI_BIND_PAGE_UP);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_PAGE_DOWN))) {
			_ctx.BindAction(ECHO_UI_ACTION_PAGE_DOWN, ECHO_UI_BIND_PAGE_DOWN);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_HOME))) {
			_ctx.BindAction(ECHO_UI_ACTION_HOME, ECHO_UI_BIND_HOME);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_END))) {
			_ctx.BindAction(ECHO_UI_ACTION_END, ECHO_UI_BIND_END);
		}
		if (is_undefined(_ctx.GetBinding(ECHO_UI_ACTION_RESTORE_WINDOWS))) {
			_ctx.BindAction(ECHO_UI_ACTION_RESTORE_WINDOWS, ECHO_UI_BIND_RESTORE_WINDOWS);
		}
	};

	/// @desc Apply a new theme and reapply defaults across windows and panels.
	/// @param {Struct.EchoChamberTheme} _theme
	/// @return {Struct.EchoChamberRoot}
	static ApplyTheme = function(_theme) {
		if (!is_instanceof(_theme, EchoChamberTheme)) {
			return self;
		}

		theme = _theme;
		var _refresh = theme[$ "RefreshMetrics"];
		if (is_callable(_refresh)) {
			method(theme, _refresh)();
		}

		__ApplyThemeDefaults();

		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _win = windows[_i];
			var _pushed = __PushWindowTheme(_win);
			_win.__theme_defaults_applied = false;
			var _win_apply = _win[$ "ApplyTheme"];
			if (is_callable(_win_apply)) {
				_win_apply(_win, self);
			}
			var _panels = _win[$ "panels"];
			if (is_array(_panels)) {
				var _plen = array_length(_panels);
				for (var _pi = 0; _pi < _plen; _pi++) {
					__ClearPanelThemeDefaults(_panels[_pi]);
				}
			}

			__ApplyThemeDefaultsToWindow(_win);
			var _apply_panels = _win[$ "__ApplyThemeDefaultsToPanels"];
			if (is_callable(_apply_panels)) {
				_apply_panels(self);
			}
			if (_pushed) {
				__PopThemeOverride();
			}
		}

		return self;
	};

	/// @ignore
	/// @func __MeasureTextWidth(_text, _font)
	/// @desc Internal helper for measuring text width using a specific font.
	/// @param {Any} _text
	/// @param {Asset.GMFont} _font
	/// @return {Real}
	static __MeasureTextWidth = function(_text, _font) {
		var _old_font = draw_get_font();
		draw_set_font(_font);
		var _w = string_width(string(_text));
		draw_set_font(_old_font);
		return _w;
	};

	__ApplyThemeDefaults();
	__BindDefaultInputActions();

	/// @desc Snapshot mouse and wheel for this frame.
	static BeginFrame = function() {
		var _mx_raw = device_mouse_x_to_gui(0);
		var _my_raw = device_mouse_y_to_gui(0);

		mx              = _mx_raw;
		my              = _my_raw;
		mouse_l_down    = mouse_check_button(mb_left);
		mouse_l_pressed = mouse_check_button_pressed(mb_left);
		mouse_r_down    = mouse_check_button(mb_right);
		mouse_r_pressed = mouse_check_button_pressed(mb_right);
		mouse_m_down    = mouse_check_button(mb_middle);
		mouse_m_pressed = mouse_check_button_pressed(mb_middle);
		wheel_delta     = mouse_wheel_up() - mouse_wheel_down();

		key_escape_pressed = keyboard_check_pressed(vk_escape);
		key_enter_pressed = keyboard_check_pressed(vk_enter);
		key_up_pressed = keyboard_check_pressed(vk_up);
		key_down_pressed = keyboard_check_pressed(vk_down);
		key_pageup_pressed = keyboard_check_pressed(vk_pageup);
		key_pagedown_pressed = keyboard_check_pressed(vk_pagedown);
		key_home_pressed = keyboard_check_pressed(vk_home);
		key_end_pressed = keyboard_check_pressed(vk_end);
		key_tab_pressed	= keyboard_check_pressed(vk_tab);
		key_shift_down	= keyboard_check(vk_shift);


		overlay_close_requested = false;

		mouse_consumed  = false;
		wheel_consumed  = false;
		__input_suppress_stack = [];
		__current_window = undefined;
		__ClipResetFrame();
		overlays        = [];
		overlays_drawn  = false;

		// Reset tooltip visibility; we will decide again this frame.
		tooltip_visible = false;
		tooltip_requested_this_frame = false;

		// Reset per-frame focusable registry for Tab navigation.
		focusable_count		= 0;


		__pending_focus_window  = undefined;
		__pending_focus_consume = false;
	};

	/// @desc Get the default input context id used for global actions.
	/// @return {String}
	static GetDefaultInputContextId = function() {
		return input_default_context_id;
	};

	/// @desc Bind a core Echo Chamber action in the default input context.
	/// @param {String} _action_id
	/// @param {Struct.EchoChamberInputBinding} _binding
	/// @return {Struct.EchoChamberRoot}
	static BindCoreInputAction = function(_action_id, _binding) {
		var _ctx = input_contexts[$ input_default_context_id];
		if (!is_instanceof(_ctx, EchoChamberInputContext)) {
			return self;
		}
		if (!is_instanceof(_binding, EchoChamberInputBinding)) {
			return self;
		}
		_ctx.BindAction(_action_id, _binding);
		return self;
	};

	/// @desc Get an input context by id.
	/// @param {String} _id
	/// @return {Struct.EchoChamberInputContext}
	static GetInputContext = function(_id) {
		var _id_str = string(_id);
		if (string_length(_id_str) <= 0) {
			return undefined;
		}
		return input_contexts[$ _id_str];
	};

	/// @desc Create or return an input context by id. If no parent is specified, it inherits from the default context.
	/// @param {String} _id
	/// @param {String} [_parent_id]
	/// @return {Struct.EchoChamberInputContext}
	static CreateInputContext = function(_id, _parent_id = undefined) {
		var _id_str = string(_id);
		if (string_length(_id_str) <= 0) {
			return undefined;
		}

		var _created = false;
		var _ctx = input_contexts[$ _id_str];
		if (is_undefined(_ctx)) {
			_ctx = new EchoChamberInputContext(_id_str);
			input_contexts[$ _id_str] = _ctx;
			_created = true;
		}

		if (!is_undefined(_parent_id)) {
			_ctx.SetParent(_parent_id);
		}
		else if (_created && _id_str != input_default_context_id && is_undefined(_ctx.parent_id)) {
			_ctx.parent_id = input_default_context_id;
		}

		return _ctx;
	};

	/// @desc Remove an input context by id (only if unused by any window).
	/// @param {String} _id
	/// @return {Bool}
	static RemoveInputContext = function(_id) {
		var _id_str = string(_id);
		if (string_length(_id_str) <= 0) {
			return false;
		}
		if (_id_str == input_default_context_id) {
			return false;
		}
		var _ctx = input_contexts[$ _id_str];
		if (!is_instanceof(_ctx, EchoChamberInputContext)) {
			return false;
		}
		var _wlen = array_length(windows);
		for (var _wi = 0; _wi < _wlen; _wi++) {
			if (windows[_wi].input_context_id == _id_str) {
				return false;
			}
		}
		input_contexts[$ _id_str] = undefined;
		return true;
	};

	/// @desc Check whether an action is pressed in the active input context.
	/// @param {String} _action_id
	/// @param {Struct.EchoChamberWindow} [_window]
	/// @return {Bool}
	static InputPressed = function(_action_id, _window = undefined) {
		return __InputCheck(_action_id, eEchoChamberInputCheck.PRESSED, _window, true);
	};

	/// @desc Check whether an action is held down in the active input context.
	/// @param {String} _action_id
	/// @param {Struct.EchoChamberWindow} [_window]
	/// @return {Bool}
	static InputDown = function(_action_id, _window = undefined) {
		return __InputCheck(_action_id, eEchoChamberInputCheck.DOWN, _window, true);
	};

	/// @desc Check whether an action was released in the active input context.
	/// @param {String} _action_id
	/// @param {Struct.EchoChamberWindow} [_window]
	/// @return {Bool}
	static InputReleased = function(_action_id, _window = undefined) {
		return __InputCheck(_action_id, eEchoChamberInputCheck.RELEASED, _window, true);
	};

	/// @ignore
	/// @func __InputCheck(_action_id, _check, _window, _require_focus)
	/// @desc Internal: evaluate an input action with focus gating.
	/// @param {String} _action_id
	/// @param {Real} _check
	/// @param {Struct.EchoChamberWindow} _window
	/// @param {Bool} _require_focus
	/// @return {Bool}
	static __InputCheck = function(_action_id, _check, _window = undefined, _require_focus = true) {
		var _action_str = string(_action_id);
		if (string_length(_action_str) <= 0) {
			return false;
		}

		var _ctx_id = __GetInputContextIdForWindow(_window, _require_focus);
		var _binding = __ResolveInputBinding(_ctx_id, _action_str);
		if (is_undefined(_binding)) {
			return false;
		}

		return __EvalInputBinding(_binding, _check);
	};

	/// @ignore
	/// @func __GetInputContextIdForWindow(_window, _require_focus)
	/// @desc Internal: resolve a context id for a window (with focus gating).
	/// @param {Struct.EchoChamberWindow} _window
	/// @param {Bool} _require_focus
	/// @return {String}
	static __GetInputContextIdForWindow = function(_window = undefined, _require_focus = true) {
		var _win = _window;
		if (is_undefined(_win)) {
			_win = __current_window;
		}
		if (is_undefined(_win)) {
			_win = keyboard_focus_window;
		}
		if (is_undefined(_win)) {
			_win = active_overlay_owner_window;
		}

		if (!is_undefined(_win) && _require_focus) {
			if (!__IsWindowInputFocused(_win)) {
				_win = undefined;
			}
		}

		if (!is_undefined(_win)) {
			var _ctx_id = _win.input_context_id;
			if (!is_undefined(_ctx_id) && string_length(_ctx_id) > 0) {
				return _ctx_id;
			}
		}

		return input_default_context_id;
	};

	/// @ignore
	/// @func __IsWindowInputFocused(_window)
	/// @desc Internal: return true if a window should own keyboard input this frame.
	/// @param {Struct.EchoChamberWindow} _window
	/// @return {Bool}
	static __IsWindowInputFocused = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return false;
		}
		if (is_instanceof(modal_window, EchoChamberWindow)) {
			return _window == modal_window;
		}
		return (_window == keyboard_focus_window) || (_window == active_overlay_owner_window);
	};

	/// @ignore
	/// @func __ResolveInputBinding(_context_id, _action_id)
	/// @desc Internal: resolve an action binding through the context parent chain.
	/// @param {String} _context_id
	/// @param {String} _action_id
	/// @return {Struct.EchoChamberInputBinding}
	static __ResolveInputBinding = function(_context_id, _action_id) {
		var _ctx_id = _context_id;
		var _guard = 0;
		while (!is_undefined(_ctx_id) && _guard < 32) {
			var _ctx = input_contexts[$ _ctx_id];
			if (is_undefined(_ctx)) {
				return undefined;
			}
			var _binding = _ctx.bindings[$ _action_id];
			if (!is_undefined(_binding)) {
				return _binding;
			}
			_ctx_id = _ctx.parent_id;
			_guard++;
		}
		return undefined;
	};

	/// @ignore
	/// @func __EvalInputBinding(_binding, _check)
	/// @desc Internal: evaluate a binding for the requested check type.
	/// @param {Struct.EchoChamberInputBinding} _binding
	/// @param {Real} _check
	/// @return {Bool}
	static __EvalInputBinding = function(_binding, _check) {
		switch (_binding.kind) {
			case eEchoChamberInputBindKind.KEY:
				if (_binding.check != _check) {
				return false;
			}
				if (_binding.ctrl && !keyboard_check(vk_control)) {
				return false;
			}
				if (_binding.alt && !keyboard_check(vk_alt)) {
				return false;
			}
				if (_binding.shift && !keyboard_check(vk_shift)) {
				return false;
			}
				switch (_check) {
				case eEchoChamberInputCheck.PRESSED: return keyboard_check_pressed(_binding.key);
				case eEchoChamberInputCheck.DOWN: return keyboard_check(_binding.key);
				case eEchoChamberInputCheck.RELEASED: return keyboard_check_released(_binding.key);
			}
			return false;
			case eEchoChamberInputBindKind.FUNC:
			return _binding.fn();
			case eEchoChamberInputBindKind.BLOCK:
			return false;
		}
		return false;
	};

	/// @desc Add a top-level panel to the root.
	/// @param {Struct.EchoChamberPanel} _panel
	/// @return {Struct.EchoChamberPanel}
	static AddPanel = function(_panel) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return undefined;
		}
		__AssignOwnershipToPanelRecursive(_panel, undefined);
		array_push(panels, _panel);
		return _panel;
	};

	/// @desc Create and register a floating debug window.
	/// @param {Any} _id
	/// @return {Struct.EchoChamberWindow}
	static CreateWindow = function(_id) {
		var _win = new EchoChamberWindow(_id);
		var _pushed = __PushWindowTheme(_win);
		__ApplyThemeDefaultsToWindow(_win);
		if (_pushed) {
			__PopThemeOverride();
		}
		RegisterWindow(_win);
		return _win;
	};


	/// @ignore
	/// @func __ApplyThemeDefaultsToWindow(_window)
	/// @desc Apply theme-driven chrome metrics to a window (once).
	/// @param {Struct.EchoChamberWindow} _window
	static __ApplyThemeDefaultsToWindow = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return;
		}
		if (_window.__theme_defaults_applied) {
			return;
		}

		var _t = theme;
		// Window padding
		_window.SetPadding(_t.window_padding);
		_window.SetMargin(_t[$ "window_margin_x"] ?? 0, _t[$ "window_margin_y"] ?? 0);

		// Titlebar height
		if (_window.titlebar_auto) {
			_window.titlebar_height = _t.window_titlebar_h;
		}

		// Resize grip size
		_window.SetResizeGripSize(_t.window_resize_grip_size);

		_window.__theme_defaults_applied = true;
	};

	/// @ignore
	/// @func __PurgeOverlaysByOwnerId(_owner_id, _owner_window)
	/// @desc Internal: remove queued overlays for a given owner id (optionally scoped to a window).
	/// @param {Any} _owner_id
	/// @param {Struct.EchoChamberWindow} [_owner_window]
	static __PurgeOverlaysByOwnerId = function(_owner_id, _owner_window = undefined) {
		var _id_str = string(_owner_id);
		if (string_length(_id_str) <= 0) {
			return;
		}
		var _len = array_length(overlays);
		if (_len <= 0) {
			return;
		}
		var _match_window = is_instanceof(_owner_window, EchoChamberWindow);
		var _filtered = [];
		for (var _i = 0; _i < _len; _i++) {
			var _entry = overlays[_i];
			if (_entry[$ "owner_id"] == _id_str) {
				if (_match_window) {
					if (_entry[$ "owner_window"] == _owner_window) {
						continue;
					}
				}
				else {
					continue;
				}
			}
			array_push(_filtered, _entry);
		}
		overlays = _filtered;
	};

	/// @ignore
	/// @func __CleanupControlState(_control_id, _owner_window)
	/// @desc Internal: clear focus/tooltip/overlay state for a removed control.
	/// @param {Any} _control_id
	/// @param {Struct.EchoChamberWindow} [_owner_window]
	static __CleanupControlState = function(_control_id, _owner_window = undefined) {
		var _id_str = string(_control_id);
		if (string_length(_id_str) <= 0) {
			return;
		}

		if (!is_undefined(text_focus_id) && text_focus_id == _id_str) {
			BlurTextInput(_id_str);
		}
		if (!is_undefined(control_focus_id) && control_focus_id == _id_str) {
			if (is_undefined(_owner_window) || is_undefined(control_focus_window) || control_focus_window == _owner_window) {
				BlurControlFocus(_id_str);
			}
		}
		if (!is_undefined(tooltip_control_id) && tooltip_control_id == _id_str) {
			if (is_undefined(_owner_window) || is_undefined(tooltip_owner_window) || tooltip_owner_window == _owner_window) {
				tooltip_control_id = undefined;
				tooltip_text = "";
				tooltip_visible = false;
				tooltip_requested_this_frame = false;
				tooltip_owner_window = undefined;
			}
		}
		if (!is_undefined(active_overlay_owner_id) && active_overlay_owner_id == _id_str) {
			if (is_undefined(_owner_window) || is_undefined(active_overlay_owner_window) || active_overlay_owner_window == _owner_window) {
				ClearActiveOverlayOwner();
			}
		}
		__PurgeOverlaysByOwnerId(_id_str, _owner_window);
	};

	/// @ignore
	/// @func __DetachPanelRecursive(_panel)
	/// @desc Internal: clear owner pointers for a panel tree (panel -> controls -> child panels).
	/// @param {Struct.EchoChamberPanel} _panel
	static __DetachPanelRecursive = function(_panel) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return;
		}
		_panel.owner_root   = undefined;
		_panel.owner_window = undefined;
		_panel.owner_panel  = undefined;

		var _clen = array_length(_panel.children_controls);
		for (var _ci = 0; _ci < _clen; _ci++) {
			var _ctrl = _panel.children_controls[_ci];
			__CleanupControlState(_ctrl.id, _panel.owner_window);
			_ctrl.owner_root   = undefined;
			_ctrl.owner_window = undefined;
			_ctrl.owner_panel  = undefined;
		}

		var _plen = array_length(_panel.children_panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _child = _panel.children_panels[_pi];
			_child.owner_root   = undefined;
			_child.owner_window = undefined;
			_child.owner_panel  = undefined;
			__DetachPanelRecursive(_child);
		}
	};

	/// @desc Register an externally created window instance.
	/// @param {Struct.EchoChamberWindow} _window
	static RegisterWindow = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return undefined;
		}
		var _pushed = __PushWindowTheme(_window);
		__ApplyThemeDefaultsToWindow(_window);
		if (_pushed) {
			__PopThemeOverride();
		}
		_window.owner_root = self;
		if (!is_undefined(_window.input_context_id)) {
			CreateInputContext(_window.input_context_id, _window.input_context_parent_id);
		}
		_window.__AssignOwnershipAll();
		if (_window.fit_to_content_on_add) {
			_window.__FitToContent(self, _window.fit_to_content_pending_respect);
			if (array_length(_window.panels) > 0) {
				_window.fit_to_content_on_add = false;
				_window.fit_to_content_pending_root = undefined;
				_window.fit_to_content_pending_respect = true;
			}
		}
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			if (windows[_i] == _window) {
				return _window;
			}
		}
		array_push(windows, _window);
		return _window;
	};

	/// @desc Find a registered window by id.
	/// @param {Any} _id
	/// @return {Struct.EchoChamberWindow}
	static FindWindow = function(_id) {
		var _id_str = string(_id);
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _w = windows[_i];
			if (_w.id == _id_str) {
				return _w;
			}
		}
		return undefined;
	};

	/// @desc Find a control by id across all registered windows.
	/// @param {Any} _id
	/// @return {Struct.EchoChamberControlBase}
	static FindControl = function(_id) {
		var _id_str = string(_id);
		if (string_length(_id_str) <= 0) {
			return undefined;
		}
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _w = windows[_i];
			var _found = _w.FindControl(_id_str);
			if (!is_undefined(_found)) {
				return _found;
			}
		}
		return undefined;
	};

	/// @ignore
	/// @desc Internal: return a window id string (or "none").
	/// @param {Struct.EchoChamberWindow} _window
	/// @return {String}
	static __GetWindowIdString = function(_window) {
		if (is_instanceof(_window, EchoChamberWindow)) {
			return _window.id;
		}
		return "none";
	};

	/// @ignore
	/// @desc Internal: return a dock name.
	/// @param {eEchoChamberDock} _dock
	/// @return {String}
	static __GetDockName = function(_dock) {
		switch (_dock) {
			case eEchoChamberDock.TOP: return "TOP";
			case eEchoChamberDock.BOTTOM: return "BOTTOM";
			case eEchoChamberDock.LEFT: return "LEFT";
			case eEchoChamberDock.RIGHT: return "RIGHT";
			case eEchoChamberDock.FILL: return "FILL";
		}
		return "UNKNOWN";
	};

	/// @ignore
	/// @desc Internal: dump a panel tree to the debug log.
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {String} _indent
	static __DumpPanelTree = function(_panel, _indent) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return;
		}
		var _flow_str = (_panel.flow == eEchoChamberPanelFlow.COLUMN) ? "COLUMN" : "ROW";
		var _dock_str = __GetDockName(_panel.dock);
		var _scroll = _panel.scroll_enabled ? " scroll" : "";
		var _p_line = _indent + "Panel id=" + _panel.id
		+ " dock=" + _dock_str
		+ " flow=" + _flow_str
		+ " controls=" + string(array_length(_panel.children_controls))
		+ " panels=" + string(array_length(_panel.children_panels))
		+ _scroll;
		EchoDebugInfo(_p_line, "EchoUI");

		var _clen = array_length(_panel.children_controls);
		for (var _ci = 0; _ci < _clen; _ci++) {
			var _c = _panel.children_controls[_ci];
			EchoDebugInfo(_indent + "  Control id=" + _c.id, "EchoUI");
		}

		var _plen = array_length(_panel.children_panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			__DumpPanelTree(_panel.children_panels[_pi], _indent + "  ");
		}
	};

	/// @desc Dump the current UI tree and focus/overlay state to the debug log.
	/// @return {Struct.EchoChamberRoot}
	static DumpUI = function() {
		EchoDebugInfo("Echo UI dump:", "EchoUI");

		var _win_count = array_length(windows);
		EchoDebugInfo("Windows=" + string(_win_count), "EchoUI");
		EchoDebugInfo("Focus keyboard=" + __GetWindowIdString(keyboard_focus_window)
		+ " control_window=" + __GetWindowIdString(control_focus_window)
		+ " control_id=" + (is_undefined(control_focus_id) ? "none" : string(control_focus_id))
		+ " modal=" + __GetWindowIdString(modal_window),
		"EchoUI");
		EchoDebugInfo("Overlay active=" + (is_undefined(active_overlay_owner_id) ? "none" : string(active_overlay_owner_id))
		+ " window=" + __GetWindowIdString(active_overlay_owner_window)
		+ " tooltip=" + __GetWindowIdString(tooltip_owner_window)
		+ " context_menu=" + __GetWindowIdString(context_menu_owner_window),
		"EchoUI");

		var _olen = array_length(overlays);
		EchoDebugInfo("Overlays=" + string(_olen), "EchoUI");
		for (var _oi = 0; _oi < _olen; _oi++) {
			var _entry = overlays[_oi];
			var _oid = is_undefined(_entry.owner_id) ? "none" : string(_entry.owner_id);
			EchoDebugInfo("  Overlay owner_id=" + _oid
			+ " window=" + __GetWindowIdString(_entry.owner_window),
			"EchoUI");
		}

		for (var _wi = 0; _wi < _win_count; _wi++) {
			var _w = windows[_wi];
			var _w_line = "Window id=" + _w.id
			+ " visible=" + string(_w.visible)
			+ " minimized=" + string(_w.is_minimized)
			+ " panels=" + string(array_length(_w.panels));
			EchoDebugInfo(_w_line, "EchoUI");

			var _plen = array_length(_w.panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				__DumpPanelTree(_w.panels[_pi], "  ");
			}
		}
		return self;
	};

	/// @desc Remove a registered window and detach its panels/controls.
	/// @param {Any} _window_or_id
	/// @return {Bool}
	static RemoveWindow = function(_window_or_id) {
		var _win = undefined;
		if (is_instanceof(_window_or_id, EchoChamberWindow)) {
			_win = _window_or_id;
		}
		else {
			_win = FindWindow(_window_or_id);
		}
		if (!is_instanceof(_win, EchoChamberWindow)) {
			return false;
		}

		var _len = array_length(windows);
		var _removed = false;
		for (var _i = 0; _i < _len; _i++) {
			if (windows[_i] == _win) {
				array_delete(windows, _i, 1);
				_removed = true;
				break;
			}
		}
		if (!_removed) {
			return false;
		}

		if (modal_window == _win) {
			ClearModalWindow();
		}
		if (mouse_capture_window == _win) {
			mouse_capture_window = undefined;
		}
		if (__current_window == _win) {
			__current_window = undefined;
		}
		if (__pending_focus_window == _win) {
			__pending_focus_window = undefined;
			__pending_focus_consume = false;
		}

		var _focus_match = (control_focus_window == _win) || (keyboard_focus_window == _win);
		if (_focus_match) {
			if (!is_undefined(text_focus_id)) {
				BlurTextInput(text_focus_id);
			}
			BlurControlFocus(undefined);
			__SetKeyboardFocusWindow(undefined);
		}

		if (tooltip_owner_window == _win) {
			tooltip_control_id = undefined;
			tooltip_text = "";
			tooltip_visible = false;
			tooltip_requested_this_frame = false;
			tooltip_owner_window = undefined;
		}

		if (active_overlay_owner_window == _win) {
			ClearActiveOverlayOwner();
		}
		if (context_menu_owner_window == _win) {
			CloseContextMenu();
		}

		var _olen = array_length(overlays);
		if (_olen > 0) {
			var _filtered = [];
			for (var _oi = 0; _oi < _olen; _oi++) {
				var _entry = overlays[_oi];
				if (_entry[$ "owner_window"] != _win) {
					array_push(_filtered, _entry);
				}
			}
			overlays = _filtered;
		}

		var _ctx_id = _win.input_context_id;
		if (!is_undefined(_ctx_id)) {
			var _ctx_str = string(_ctx_id);
			if (string_length(_ctx_str) > 0 && _ctx_str != input_default_context_id) {
				var _used = false;
				var _wlen = array_length(windows);
				for (var _wi = 0; _wi < _wlen; _wi++) {
					var _probe = windows[_wi];
					if (_probe.input_context_id == _ctx_str) {
						_used = true;
						break;
					}
				}
				if (!_used) {
					input_contexts[$ _ctx_str] = undefined;
				}
			}
		}

		var _plen = array_length(_win.panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			__DetachPanelRecursive(_win.panels[_pi]);
		}
		_win.owner_root = undefined;

		return true;
	};


	/// @desc Bring a window to the front of the z-order.
	/// @param {Any} _window_or_id
	static BringWindowToFront = function(_window_or_id) {
		var _window = _window_or_id;
		if (!is_instanceof(_window, EchoChamberWindow)) {
			_window = FindWindow(_window_or_id);
		}
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return;
		}
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			if (windows[_i] == _window) {
				array_delete(windows, _i, 1);
				array_push(windows, _window);
				__SetKeyboardFocusWindow(_window);
				return;
			}
		}
	};

	/// @desc Bring a window to the front by id.
	/// @param {Any} _id
	/// @return {Struct.EchoChamberWindow}
	static BringWindowToFrontById = function(_id) {
		var _win = FindWindow(_id);
		if (!is_instanceof(_win, EchoChamberWindow)) {
			return undefined;
		}
		BringWindowToFront(_win);
		return _win;
	};

	/// @desc Send a window to the back of the z-order.
	/// @param {Any} _window_or_id
	/// @return {Bool}
	static SendWindowToBack = function(_window_or_id) {
		var _win = _window_or_id;
		if (!is_instanceof(_win, EchoChamberWindow)) {
			_win = FindWindow(_window_or_id);
		}
		if (!is_instanceof(_win, EchoChamberWindow)) {
			return false;
		}
		if (modal_window == _win) {
			BringWindowToFront(_win);
			return true;
		}
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			if (windows[_i] == _win) {
				array_delete(windows, _i, 1);
				break;
			}
		}
		var _new = [];
		array_push(_new, _win);
		var _len2 = array_length(windows);
		for (var _j = 0; _j < _len2; _j++) {
			array_push(_new, windows[_j]);
		}
		windows = _new;
		return true;
	};

	/// @desc Set a window's z-order index (0 = back, last = front).
	/// @param {Any} _window_or_id
	/// @param {Real} _index
	/// @return {Bool}
	static SetWindowZIndex = function(_window_or_id, _index) {
		var _win = _window_or_id;
		if (!is_instanceof(_win, EchoChamberWindow)) {
			_win = FindWindow(_window_or_id);
		}
		if (!is_instanceof(_win, EchoChamberWindow)) {
			return false;
		}
		var _len = array_length(windows);
		var _idx = clamp(floor(_index), 0, max(0, _len - 1));
		if (modal_window == _win) {
			_idx = max(0, _len - 1);
		}
		var _removed_index = -1;
		for (var _i = 0; _i < _len; _i++) {
			if (windows[_i] == _win) {
				_removed_index = _i;
				array_delete(windows, _i, 1);
				break;
			}
		}
		if (_removed_index < 0) {
			return false;
		}
		if (_removed_index < _idx) {
			_idx -= 1;
		}
		var _len2 = array_length(windows);
		_idx = clamp(_idx, 0, _len2);
		var _new = [];
		for (var _j = 0; _j < _len2; _j++) {
			if (_j == _idx) {
				array_push(_new, _win);
			}
			array_push(_new, windows[_j]);
		}
		if (_idx >= _len2) {
			array_push(_new, _win);
		}
		windows = _new;
		if (_idx >= array_length(windows) - 1) {
			__SetKeyboardFocusWindow(_win);
		}
		return true;
	};

	/// @desc Set the modal window (blocks input to other windows).
	/// @param {Any} _window_or_id
	/// @return {Bool}
	static SetModalWindow = function(_window_or_id) {
		if (is_undefined(_window_or_id)) {
			return ClearModalWindow();
		}
		var _win = _window_or_id;
		if (!is_instanceof(_win, EchoChamberWindow)) {
			_win = FindWindow(_window_or_id);
		}
		if (!is_instanceof(_win, EchoChamberWindow)) {
			return false;
		}
		if (modal_window == _win) {
			BringWindowToFront(_win);
			return true;
		}
		modal_window = _win;
		if (mouse_capture_window != _win) {
			mouse_capture_window = undefined;
		}
		if (active_overlay_owner_window != _win) {
			ClearActiveOverlayOwner();
		}
		if (context_menu_owner_window != _win) {
			CloseContextMenu();
		}
		if (tooltip_owner_window != _win) {
			tooltip_control_id = undefined;
			tooltip_text = "";
			tooltip_visible = false;
			tooltip_requested_this_frame = false;
			tooltip_owner_window = undefined;
		}
		var _focus_other = (is_struct(control_focus_window) && control_focus_window != _win)
		|| (is_struct(keyboard_focus_window) && keyboard_focus_window != _win);
		if (_focus_other) {
			if (!is_undefined(text_focus_id)) {
				BlurTextInput(text_focus_id);
			}
			BlurControlFocus(undefined);
		}
		BringWindowToFront(_win);
		__SetKeyboardFocusWindow(_win);
		return true;
	};

	/// @desc Clear the modal window (if any).
	/// @return {Bool}
	static ClearModalWindow = function() {
		if (!is_instanceof(modal_window, EchoChamberWindow)) {
			modal_window = undefined;
			return false;
		}
		modal_window = undefined;
		return true;
	};

	/// @desc Get the current modal window (if any).
	/// @return {Struct.EchoChamberWindow}
	static GetModalWindow = function() {
		return modal_window;
	};

	/// @desc Bring all windows back into view so their title bars remain accessible.
	/// @return {Struct.EchoChamberRoot}
	static BringWindowsBack = function() {
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _win = windows[_i];
			_win.__EnsureTitlebarVisible(window_min_visible_titlebar_w, window_min_visible_titlebar_h, false);
		}
		return self;
	};


	/// @desc Set the INI filename used for saving and loading UI layout state.
	/// @param {String} _filename
	/// @return {Struct.EchoChamberRoot}
	static SetPersistenceFile = function(_filename) {
		persistence_file = string(_filename);
		return self;
	};

	/// @desc Set the INI section prefix used for saving and loading UI layout state.
	/// @param {String} _section
	/// @return {Struct.EchoChamberRoot}
	static SetPersistenceSection = function(_section) {
		persistence_section = string(_section);
		return self;
	};

	/// @ignore
	/// @func __PersistSplitString(_text, _sep_char)
	/// @desc Internal: split a string by a single character separator. Returns an array of strings.
	/// @param {String} _text
	/// @param {String} _sep_char
	/// @return {Array<String>}
	static __PersistSplitString = function(_text, _sep_char) {
		var _s = string(_text);
		var _sep = string(_sep_char);
		var _out = [];
		if (_s == "") {
			return _out;
		}
		var _cur = "";
		var _len = string_length(_s);
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_s, _i);
			if (_ch == _sep) {
				array_push(_out, _cur);
				_cur = "";
			}
			else {
				_cur += _ch;
			}
		}
		array_push(_out, _cur);
		return _out;
	};

	/// @ignore
	/// @func __PersistFindWindowById(_id)
	/// @desc Internal: find a registered window by id string.
	/// @param {String} _id
	/// @return {Struct.EchoChamberWindow}
	static __PersistFindWindowById = function(_id) {
		var _sid = string(_id);
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _w = windows[_i];
			if (_w.id == _sid) {
				return _w;
			}
		}
		return undefined;
	};

	/// @ignore
	/// @func __PersistSavePanelRecursive(_base_sec, _panel, _path)
	/// @desc Internal: save panel state (and children) to INI.
	/// @param {String} _base_sec
	/// @param {Struct.EchoChamberPanel} _panel
	static __PersistSavePanelRecursive = function(_base_sec, _panel, _path) {
		var _pid = string(_panel.id);
		var _psec = string(_base_sec) + ".panelpath." + string(_path);
		var _psec_legacy = string(_base_sec) + ".panel." + _pid;
		ini_write_real(_psec, "collapsed", _panel.collapsed ? 1 : 0);
		ini_write_real(_psec_legacy, "collapsed", _panel.collapsed ? 1 : 0);
		if (_panel.size_mode == eEchoChamberPanelSizeMode.FIXED) {
			ini_write_real(_psec, "size", _panel.size);
			ini_write_real(_psec_legacy, "size", _panel.size);
		}
		if (_panel.is_container) {
			var _cl = array_length(_panel.children_panels);
			for (var _ci = 0; _ci < _cl; _ci++) {
				var _child = _panel.children_panels[_ci];
				var _child_path = string(_path) + "/" + string(_child.id);
				__PersistSavePanelRecursive(_base_sec, _child, _child_path);
			}
		}
	};

	/// @ignore
	/// @func __PersistLoadPanelRecursive(_base_sec, _panel, _path)
	/// @desc Internal: load panel state (and children) from INI.
	/// @param {String} _base_sec
	/// @param {Struct.EchoChamberPanel} _panel
	static __PersistLoadPanelRecursive = function(_base_sec, _panel, _path) {
		var _pid = string(_panel.id);
		var _psec = string(_base_sec) + ".panelpath." + string(_path);
		var _psec_legacy = string(_base_sec) + ".panel." + _pid;
		var _col = ini_read_real(_psec, "collapsed", -1);
		if (_col < 0) {
			_col = ini_read_real(_psec_legacy, "collapsed", _panel.collapsed ? 1 : 0);
		}
		_panel.collapsed = (_col != 0);
		if (_panel.size_mode == eEchoChamberPanelSizeMode.FIXED) {
			var _sz = ini_read_real(_psec, "size", -1);
			if (_sz < 0) {
				_sz = ini_read_real(_psec_legacy, "size", _panel.size);
			}
			_panel.SetSize(_sz);
		}
		if (_panel.is_container) {
			var _cl = array_length(_panel.children_panels);
			for (var _ci = 0; _ci < _cl; _ci++) {
				var _child = _panel.children_panels[_ci];
				var _child_path = string(_path) + "/" + string(_child.id);
				__PersistLoadPanelRecursive(_base_sec, _child, _child_path);
			}
		}
	};

	/// @desc Save window layout, z-order, and panel state to an INI file.
	/// @return {Bool}
	static SaveLayout = function() {
		var _file = string(persistence_file);
		if (_file == "") {
			return false;
		}
		var _root_sec = string(persistence_section);
		if (_root_sec == "") {
			_root_sec = "EchoEchoChamber";
		}
		// Collect window ids in current z-order (back-to-front).
		var _ids = [];
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _w = windows[_i];
			array_push(_ids, _w.id);
		}
		var _order = "";
		var _id_len = array_length(_ids);
		for (var _j = 0; _j < _id_len; _j++) {
			_order += _ids[_j];
			if (_j < _id_len - 1) {
				_order += "|";
			}
		}
		ini_open(_file);
		ini_write_real(_root_sec, "version", persistence_version);
		ini_write_string(_root_sec, "window_order", _order);
		ini_write_real(_root_sec, "window_count", _id_len);
		for (var _k = 0; _k < _len; _k++) {
			var _win = windows[_k];
			var _sec = _root_sec + ".window." + _win.id;
			var _x1 = _win.rect.x1;
			var _y1 = _win.rect.y1;
			var _w = _win.rect.x2 - _win.rect.x1;
			var _h = _win.rect.y2 - _win.rect.y1;
			ini_write_real(_sec, "x1", _x1);
			ini_write_real(_sec, "y1", _y1);
			ini_write_real(_sec, "w", _w);
			ini_write_real(_sec, "h", _h);
			ini_write_real(_sec, "visible", _win.visible ? 1 : 0);
			ini_write_real(_sec, "minimized", _win.is_minimized ? 1 : 0);
			ini_write_real(_sec, "pinned", _win.is_pinned ? 1 : 0);
			ini_write_real(_sec, "restore_h", _win.is_minimized ? _win.restore_height : _h);
			var _panels = _win.panels;
			var _plen = array_length(_panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				__PersistSavePanelRecursive(_sec, _panels[_pi], string(_panels[_pi].id));
			}
		}
		ini_close();
		return true;
	};

	/// @desc Load window layout, z-order, and panel state from an INI file. Windows and panels must already be created/registered before calling this.
	/// @return {Bool}
	static LoadLayout = function() {
		var _file = string(persistence_file);
		if (_file == "") {
			return false;
		}
		if (!file_exists(_file)) {
			return false;
		}
		var _root_sec = string(persistence_section);
		if (_root_sec == "") {
			_root_sec = "EchoEchoChamber";
		}
		ini_open(_file);
		var _order = ini_read_string(_root_sec, "window_order", "");
		// Apply per-window state.
		var _len = array_length(windows);
		for (var _k = 0; _k < _len; _k++) {
			var _win = windows[_k];
			var _sec = _root_sec + ".window." + _win.id;
			var _cur_x1 = _win.rect.x1;
			var _cur_y1 = _win.rect.y1;
			var _cur_w = _win.rect.x2 - _win.rect.x1;
			var _cur_h = _win.rect.y2 - _win.rect.y1;
			var _x1 = ini_read_real(_sec, "x1", _cur_x1);
			var _y1 = ini_read_real(_sec, "y1", _cur_y1);
			var _w = ini_read_real(_sec, "w", _cur_w);
			var _h = ini_read_real(_sec, "h", _cur_h);
			_win.SetRect(_x1, _y1, _x1 + _w, _y1 + _h);
			var _vis = ini_read_real(_sec, "visible", _win.visible ? 1 : 0);
			_win.SetVisible(_vis != 0);
			// Window chrome state
			var _pinned = ini_read_real(_sec, "pinned", _win.is_pinned ? 1 : 0);
			_win.is_pinned = (_pinned != 0);
			var _restore_h = ini_read_real(_sec, "restore_h", _cur_h);
			_win.restore_height = _restore_h;
			var _min = ini_read_real(_sec, "minimized", _win.is_minimized ? 1 : 0);
			if (_min != 0) {
				// Restore the full height first, then apply minimized so restore_height remains meaningful.
				_win.is_minimized = false;
				_win.SetRect(_x1, _y1, _x1 + _w, _y1 + _restore_h);
				_win.restore_height = _restore_h;
				_win.SetMinimized(true);
			}
			else {
				_win.is_minimized = false;
			}
			// Panels.
			var _panels = _win.panels;
			var _plen = array_length(_panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				__PersistLoadPanelRecursive(_sec, _panels[_pi], string(_panels[_pi].id));
			}
		}
		// Restore z-order (back-to-front order stored left-to-right).
		if (_order != "") {
			var _ids = __PersistSplitString(_order, "|");
			var _new = [];
			var _id_len = array_length(_ids);
			for (var _oi = 0; _oi < _id_len; _oi++) {
				var _wid = _ids[_oi];
				var _wfound = __PersistFindWindowById(_wid);
				// avoid duplicates
				var _already = false;
				var _nl = array_length(_new);
				for (var _ni = 0; _ni < _nl; _ni++) {
					if (_new[_ni] == _wfound) {
						_already = true;
						break;
					}
				}
				if (!_already && !is_undefined(_wfound)) {
					array_push(_new, _wfound);
				}
			}
			// Append any windows not listed in the file.
			for (var _ai = 0; _ai < _len; _ai++) {
				var _w2 = windows[_ai];
				var _found = false;
				var _nl2 = array_length(_new);
				for (var _ni2 = 0; _ni2 < _nl2; _ni2++) {
					if (_new[_ni2] == _w2) {
						_found = true;
						break;
					}
				}
				if (!_found) {
					array_push(_new, _w2);
				}
			}
			windows = _new;
		}
		ini_close();
		return true;
	};

	/// @desc Capture the mouse for a window interaction (drag/resize).
	/// @param {Struct.EchoChamberWindow} _window
	static SetMouseCapture = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return;
		}
		mouse_capture_window = _window;
	};

	/// @desc Release mouse capture if owned by the given window.
	/// @param {Struct.EchoChamberWindow} _window
	static ClearMouseCapture = function(_window) {
		if (mouse_capture_window == _window) {
			mouse_capture_window = undefined;
		}
	};

	/// @ignore
	/// @func __SetKeyboardFocusWindow(_window)
	/// @desc Internal: update keyboard focus window and fire focus/blur callbacks.
	/// @param {Struct.EchoChamberWindow} _window
	static __SetKeyboardFocusWindow = function(_window) {
		var _prev = keyboard_focus_window;
		if (_prev == _window) {
			return;
		}
		if (is_instanceof(_prev, EchoChamberWindow)) {
			var _blur = _prev[$ "on_blur"];
			if (is_callable(_blur)) {
				_blur();
			}
		}
		keyboard_focus_window = _window;
		if (is_instanceof(_window, EchoChamberWindow)) {
			var _focus = _window[$ "on_focus"];
			if (is_callable(_focus)) {
				_focus();
			}
		}
	};

	/// @ignore
	/// @func __RequestFocusConsume(_window)
	/// @desc Internal: mark that a window focus click occurred this frame. If no control consumes the click during drawing, the root will consume it after windows draw.
	/// @param {Struct.EchoChamberWindow} _window
	static __RequestFocusConsume = function(_window) {
		if (!is_instanceof(_window, EchoChamberWindow)) {
			return;
		}
		__pending_focus_window  = _window;
		__pending_focus_consume = true;
	};

	/// @ignore
	/// @func __EnsureWindowsVisible()
	/// @desc Internal: snap any windows with fully offscreen title bars back into view.
	static __EnsureWindowsVisible = function() {
		var _len = array_length(windows);
		for (var _i = 0; _i < _len; _i++) {
			var _win = windows[_i];
			if (!_win.visible) {
				continue;
			}
			if (_win.is_dragging || _win.is_resizing) {
				continue;
			}
			_win.__EnsureTitlebarVisible(window_min_visible_titlebar_w, window_min_visible_titlebar_h, true);
		}
	};

	/// @desc Run the managed desktop: capture input, process the active window, draw all windows, then draw overlays and tooltip.
	static RunDesktop = function() {

		var _halign = draw_get_halign();
		var _valign = draw_get_valign();
		var _font = draw_get_font();
		var _alpha = draw_get_alpha();
		var _col = draw_get_colour();

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(c_white);

		BeginFrame();
		__field_label_proxy_click_id = undefined;
		__UpdatePanelSplitterDrag();
		__EnsureWindowsVisible();
		// Keyboard UX:
		// - Cancel closes menus/overlays first, otherwise cancels the active text input edit.
		// - Accept submits the active text input (except while a context menu is open).
		if (self.InputPressed(ECHO_UI_ACTION_CANCEL)) {
			if (IsContextMenuOpen()) {
				CloseContextMenu();
			}
			else if (!is_undefined(active_overlay_owner_id)) {
				RequestCloseOverlay();
			}
			else if (!is_undefined(text_focus_id)) {
				CancelTextInput(text_focus_id);
			}
		}
		if (self.InputPressed(ECHO_UI_ACTION_ACCEPT)) {
			if (!IsContextMenuOpen() && !is_undefined(text_focus_id)) {
				BlurTextInput(text_focus_id);
			}
		}
		if (self.InputPressed(ECHO_UI_ACTION_RESTORE_WINDOWS)) {
			BringWindowsBack();
		}

		// Text input pre-blur:
		// If a text input is active and the user clicks outside its last known rect,
		// blur it now so other controls can see the committed value this frame.
		if (!is_undefined(text_focus_id) && mouse_l_pressed) {
			// Do not pre-blur while a modal overlay is open (context menus, etc). The overlay
			// should be able to operate on the active selection/caret without losing focus.
			if (is_undefined(active_overlay_owner_id)) {
				var _keep_focus = false;
				if (is_struct(text_focus_rect_last)) {
					_keep_focus = HitTestRect(text_focus_rect_last.x1, text_focus_rect_last.y1, text_focus_rect_last.x2, text_focus_rect_last.y2);
				}
				if (!_keep_focus) {
					BlurTextInput(text_focus_id);
				}
			}
		}

		__UpdateActiveTextInput();

		if (is_instanceof(modal_window, EchoChamberWindow)) {
			if (!modal_window.visible) {
				ClearModalWindow();
			}
			else {
				var _win_count_pre = array_length(windows);
				if (_win_count_pre > 0 && windows[_win_count_pre - 1] != modal_window) {
					BringWindowToFront(modal_window);
				}
			}
		}
		var _win_count = array_length(windows);

		// Determine the active window for this frame:
		// - If a window has captured the mouse (drag/resize), it stays active.
		// - Otherwise, pick the topmost visible window under the cursor.
		var _cursor_window = mouse_capture_window;
		// Modal windows: lock interactions to the modal window if set.
		if (is_instanceof(modal_window, EchoChamberWindow)) {
			_cursor_window = modal_window;
		}
		// Modal overlays: if an overlay is open, lock interactions to its owner window so overlays can be clicked even outside the window rect.
		if (!is_undefined(active_overlay_owner_id)) {
			// If a modal window exists, only allow overlays owned by that modal window.
			if (is_instanceof(modal_window, EchoChamberWindow)) {
				if (!is_struct(active_overlay_owner_window) || active_overlay_owner_window != modal_window) {
					ClearActiveOverlayOwner();
				}
			}

			if (!is_undefined(active_overlay_owner_id)) {
				if (is_struct(active_overlay_owner_window) && active_overlay_owner_window.visible) {
					_cursor_window = active_overlay_owner_window;
				}
				else {
					ClearActiveOverlayOwner();
				}
			}
		}

		if (is_undefined(_cursor_window)) {
			for (var _j = _win_count - 1; _j >= 0; _j--) {
				var _probe = windows[_j];
				if (!_probe.visible) {
					continue;
				}
				if (_probe.ContainsPoint(mx, my)) {
					_cursor_window = _probe;
					break;
				}
			}
		}

		// Only the active window should process window-level interactions (drag, resize, focus).
		if (!is_undefined(_cursor_window) && _cursor_window.visible) {
			// Do not allow window drag/resize/focus changes while a modal overlay is open.
			if (is_undefined(active_overlay_owner_id)) {
				var _pushed = __PushWindowTheme(_cursor_window);
				_cursor_window.ProcessWindowInteractions(self);
				if (_pushed) {
					__PopThemeOverride();
				}
			}
		}

		// Draw windows back-to-front. Block mouse/wheel input for non-active windows.
		for (var _k = 0; _k < _win_count; _k++) {
			var _draw_win = windows[_k];
			if (!_draw_win.visible) {
				continue;
			}
			var _force_block = (!is_undefined(_cursor_window) && _cursor_window != _draw_win);
			var _block = _force_block;
			var _prev_mouse = mouse_consumed;
			var _prev_wheel = wheel_consumed;
			if (_block) {
				mouse_consumed = true;
				wheel_consumed = true;
			}
			var _draw_pushed = __PushWindowTheme(_draw_win);
			_draw_win.Draw(self);
			if (_draw_pushed) {
				__PopThemeOverride();
			}
			if (_block) {
				mouse_consumed = _prev_mouse;
				wheel_consumed = _prev_wheel;
			}
		}

		// Tab focus navigation across controls
		__ProcessTabFocus();

		__QueueContextMenuOverlay();
		DrawOverlays();

		// If a click occurred inside the active window but no control or overlay consumed it,
		// consume it now so it does not fall through to anything else.
		if (__pending_focus_consume && __pending_focus_window == _cursor_window && mouse_l_pressed && !mouse_consumed) {
			ConsumeMouse();
		}
		__pending_focus_consume = false;
		__pending_focus_window  = undefined;

		if (is_instanceof(modal_window, EchoChamberWindow)) {
			if ((mouse_l_pressed || mouse_r_pressed) && !mouse_consumed) {
				ConsumeMouse();
			}
			if (wheel_delta != 0 && !wheel_consumed) {
				ConsumeWheel();
			}
		}

		// Tooltip lifecycle: if no control requested a tooltip this frame, clear previous tooltip state.
		if (!tooltip_requested_this_frame) {
			tooltip_control_id = undefined;
			tooltip_text = "";
			tooltip_visible = false;
			tooltip_owner_window = undefined;
		}

		DrawTooltip();
		DrawToast();
		__ClipResetFrame();

		draw_set_halign(_halign);
		draw_set_valign(_valign);
		draw_set_font(_font);
		draw_set_alpha(_alpha);
		draw_set_colour(_col);

	};

	/// @desc Consume mouse input for all remaining controls this frame.
	static ConsumeMouse = function() {
		mouse_consumed = true;
	};

	/// @desc Consume mouse wheel for all remaining scroll regions.
	static ConsumeWheel = function() {
		wheel_consumed = true;
	};

	/// @ignore
	/// @func __ClampScroll(_scroll_y, _content_h, _view_h)
	/// @desc Internal: clamp a scroll offset to a content/view range.
	/// @param {Real} _scroll_y
	/// @param {Real} _content_h
	/// @param {Real} _view_h
	/// @return {Real}
	static __ClampScroll = function(_scroll_y, _content_h, _view_h) {
		var _max_scroll = max(0, _content_h - _view_h);
		return clamp(_scroll_y, 0, _max_scroll);
	};
	/// @ignore
	/// @func __CalcScrollbarMetrics(_x1, _y1, _x2, _y2, _content_h, _scroll_y)
	/// @desc Internal: compute vertical scrollbar track/thumb geometry for the given view rect and content height.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	/// @param {Real} _content_h
	/// @param {Real} _scroll_y
	/// @return {Struct}
	static __CalcScrollbarMetrics = function(_x1, _y1, _x2, _y2, _content_h, _scroll_y) {
		var _view_h = max(0, _y2 - _y1);
		var _bar_w = theme.scrollbar_w;
		var _track_x2 = _x2 - 1;
		var _track_x1 = _track_x2 - _bar_w;
		var _track_y1 = _y1 + 1;
		var _track_y2 = _y2 - 1;
		var _track_h  = max(0, _track_y2 - _track_y1);
		var _max_scroll = max(0, _content_h - _view_h);
		var _handle_h = (_view_h * _view_h) / max(1, _content_h);
		_handle_h = clamp(_handle_h, 12, _track_h);
		var _travel = max(0, _track_h - _handle_h);
		var _t = (_max_scroll <= 0) ? 0 : (_scroll_y / _max_scroll);
		var _handle_y1 = _track_y1 + (_t * _travel);
		var _handle_y2 = _handle_y1 + _handle_h;
		return {
			view_h: _view_h,
			max_scroll: _max_scroll,
			track_x1: _track_x1, track_y1: _track_y1,
			track_x2: _track_x2, track_y2: _track_y2,
			handle_y1: _handle_y1, handle_y2: _handle_y2,
			handle_h: _handle_h,
			travel: _travel
		};
	};

	/// @ignore
	/// @func __ScrollbarScrollFromMouse(_metrics, _mouse_y, _drag_offset_y)
	/// @desc Internal: convert a mouse Y position into a scroll offset, using scrollbar geometry and a stored drag offset.
	/// @param {Struct} _metrics
	/// @param {Real} _mouse_y
	/// @param {Real} _drag_offset_y
	/// @return {Real}
	static __ScrollbarScrollFromMouse = function(_metrics, _mouse_y, _drag_offset_y) {
		if (!is_struct(_metrics)) return 0;
		var _travel = _metrics.travel;
		if (_travel <= 0) return 0;
		var _t = (_mouse_y - _metrics.track_y1 - _drag_offset_y) / _travel;
		_t = clamp(_t, 0, 1);
		return _t * _metrics.max_scroll;
	};


	/// @ignore
	/// @func __DrawScrollbar(_x1, _y1, _x2, _y2, _content_h, _scroll_y, _scroll_state)
	/// @desc Internal: draw a vertical scrollbar inside the given rect.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	/// @param {Real} _content_h
	/// @param {Real} _scroll_y
	static __DrawScrollbar = function(_x1, _y1, _x2, _y2, _content_h, _scroll_y, _scroll_state = undefined) {
		var _view_h = max(0, _y2 - _y1);
		if (_content_h <= _view_h) {
			return;
		}
		var _bar_w = theme.scrollbar_w;
		var _track_x2 = _x2 - 1;
		var _track_x1 = _track_x2 - _bar_w;
		var _track_y1 = _y1 + 1;
		var _track_y2 = _y2 - 1;

		var _max_scroll = max(0, _content_h - _view_h);
		var _handle_h = (_view_h * _view_h) / max(1, _content_h);
		_handle_h = clamp(_handle_h, 12, _view_h - 2);
		var _t = (_max_scroll <= 0) ? 0 : (_scroll_y / _max_scroll);
		var _handle_y1 = _track_y1 + (_t * max(0, (_track_y2 - _track_y1) - _handle_h));
		var _handle_y2 = _handle_y1 + _handle_h;

		var _styles = theme.scrollbar_styles;
		var _st = _styles[$ "_default"] ?? _styles;

		var _track_bg = _st[$ "track_bg"] ?? merge_color(theme.col_window_bg, theme.col_panel_bg, 0.5);
		var _track_bg_alpha = _st[$ "track_bg_alpha"] ?? 0.35;
		var _track_bg_hover = _st[$ "track_bg_hover"] ?? _track_bg;
		var _track_bg_hover_alpha = _st[$ "track_bg_hover_alpha"] ?? _track_bg_alpha;
		var _track_border = _st[$ "track_border"] ?? theme.col_accent;
		var _track_border_alpha = _st[$ "track_border_alpha"] ?? 1;

		var _handle_bg = _st[$ "handle_bg"] ?? theme.col_accent;
		var _handle_bg_alpha = _st[$ "handle_bg_alpha"] ?? 0.85;
		var _handle_bg_hover = _st[$ "handle_bg_hover"] ?? _handle_bg;
		var _handle_bg_hover_alpha = _st[$ "handle_bg_hover_alpha"] ?? _handle_bg_alpha;
		var _handle_bg_pressed = _st[$ "handle_bg_pressed"] ?? _handle_bg_hover;
		var _handle_bg_pressed_alpha = _st[$ "handle_bg_pressed_alpha"] ?? _handle_bg_hover_alpha;
		var _handle_border = _st[$ "handle_border"];
		var _handle_border_alpha = _st[$ "handle_border_alpha"] ?? 0;

		var _dragging = false;
		if (is_instanceof(_scroll_state, EchoChamberScrollState)) {
			_dragging = (_scroll_state.dragging == true);
		}

		var _hover_track = (mx >= _track_x1 && mx <= _track_x2 && my >= _track_y1 && my <= _track_y2);
		var _hover_handle = (mx >= _track_x1 && mx <= _track_x2 && my >= _handle_y1 && my <= _handle_y2);
		var _pressed_handle = _dragging || (_hover_handle && mouse_l_down);

		var _track_col = _hover_track ? _track_bg_hover : _track_bg;
		var _track_alpha = _hover_track ? _track_bg_hover_alpha : _track_bg_alpha;

		var _handle_col = _handle_bg;
		var _handle_alpha = _handle_bg_alpha;
		if (_pressed_handle) {
			_handle_col = _handle_bg_pressed;
			_handle_alpha = _handle_bg_pressed_alpha;
		}
		else if (_hover_handle) {
			_handle_col = _handle_bg_hover;
			_handle_alpha = _handle_bg_hover_alpha;
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_track_alpha);
		draw_set_color(_track_col);
		draw_rectangle(_track_x1, _track_y1, _track_x2, _track_y2, false);

		draw_set_alpha(_track_border_alpha);
		draw_set_color(_track_border);
		draw_rectangle(_track_x1, _track_y1, _track_x2, _track_y2, true);

		draw_set_alpha(_handle_alpha);
		draw_set_color(_handle_col);
		draw_rectangle(_track_x1 + 1, _handle_y1, _track_x2 - 1, _handle_y2, false);

		if (_handle_border_alpha > 0 && !is_undefined(_handle_border)) {
			draw_set_alpha(_handle_border_alpha);
			draw_set_color(_handle_border);
			draw_rectangle(_track_x1 + 1, _handle_y1, _track_x2 - 1, _handle_y2, true);
		}
		draw_set_alpha(_old_alpha);
	};

	/// @func DrawScrollArea(_scroll_state, _rect, _content_h, _draw_fn)
	/// @desc Draw a scrollable clipped region and handle mouse wheel scrolling when hovered. Includes scrollbar thumb dragging and track page jumps.
	/// @param {Struct.EchoChamberScrollState} _scroll_state
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Real} _content_h Total content height in pixels.
	/// @param {Function} _draw_fn function(_root, _rect, _scroll_y)
	static DrawScrollArea = function(_scroll_state, _rect, _content_h, _draw_fn) {
		if (!is_struct(_rect)) return;
		if (!is_callable(_draw_fn)) return;

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		var _view_h = max(0, _y2 - _y1);
		var _has_state = is_instanceof(_scroll_state, EchoChamberScrollState);
		var _scroll_y = _has_state ? _scroll_state.scroll_y : 0;

		_scroll_y = __ClampScroll(_scroll_y, _content_h, _view_h);

		// Per-call flag: did the user scroll this frame (wheel or scrollbar interactions)
		if (_has_state) {
			_scroll_state.user_scrolled_this_frame = false;
		}

		var _hover = (mx >= _x1 && mx <= _x2 && my >= _y1 && my <= _y2);

		// Wheel scroll when hovered
		if (_hover && wheel_delta != 0 && !wheel_consumed) {
			var _step = max(8, default_row_height);
			_scroll_y = __ClampScroll(_scroll_y - (wheel_delta * _step), _content_h, _view_h);
			if (_has_state) {
				_scroll_state.user_scrolled_this_frame = true;
			}
			ConsumeWheel();
		}

		// Scrollbar interactions (thumb drag + track page jump)
		var _max_scroll = max(0, _content_h - _view_h);
		if (_max_scroll > 0 && _has_state) {

			if (_scroll_state.dragging) {
				if (mouse_l_down) {
					var _m = __CalcScrollbarMetrics(_x1, _y1, _x2, _y2, _content_h, _scroll_y);
					_scroll_y = __ScrollbarScrollFromMouse(_m, my, _scroll_state.drag_offset_y);
					_scroll_y = __ClampScroll(_scroll_y, _content_h, _view_h);
					_scroll_state.user_scrolled_this_frame = true;
					ConsumeMouse();
				}
				else {
					_scroll_state.dragging = false;
				}
			}
			else if (mouse_l_pressed && !mouse_consumed) {
				var _m2 = __CalcScrollbarMetrics(_x1, _y1, _x2, _y2, _content_h, _scroll_y);
				var _in_track = (mx >= _m2.track_x1 && mx <= _m2.track_x2 && my >= _m2.track_y1 && my <= _m2.track_y2);
				if (_in_track) {
					if (my >= _m2.handle_y1 && my <= _m2.handle_y2) {
						_scroll_state.dragging = true;
						_scroll_state.drag_offset_y = my - _m2.handle_y1;
					}
					else {
						// Page jump by one view height
						if (my < _m2.handle_y1) {
							_scroll_y -= _m2.view_h;
						}
						else {
							_scroll_y += _m2.view_h;
						}
						_scroll_y = __ClampScroll(_scroll_y, _content_h, _view_h);
					}
					_scroll_state.user_scrolled_this_frame = true;
					ConsumeMouse();
				}
			}
		}

		if (_has_state) {
			_scroll_state.scroll_y = _scroll_y;
		}

		PushClipRect(_x1, _y1, _x2, _y2);
		_draw_fn(self, _rect, _scroll_y);
		PopClipRect();

		__DrawScrollbar(_x1, _y1, _x2, _y2, _content_h, _scroll_y, _scroll_state);
	};

	/// @ignore
	/// @func __PushInputSuppression()
	/// @desc Internal: temporarily suppress mouse and wheel input by forcing consumed flags. Use __PopInputSuppression to restore.
	static __PushInputSuppression = function() {
		var _token = { mouse: mouse_consumed, wheel: wheel_consumed };
		array_push(__input_suppress_stack, _token);
		mouse_consumed = true;
		wheel_consumed = true;
		return _token;
	};

	/// @ignore
	/// @func __PopInputSuppression()
	/// @desc Internal: restore input consumption flags after __PushInputSuppression.
	static __PopInputSuppression = function() {
		var _len = array_length(__input_suppress_stack);
		if (_len <= 0) {
			return;
		}
		var _token = __input_suppress_stack[_len - 1];
		array_delete(__input_suppress_stack, _len - 1, 1);
		if (is_struct(_token)) {
			mouse_consumed = _token[$ "mouse"] ?? mouse_consumed;
			wheel_consumed = _token[$ "wheel"] ?? wheel_consumed;
		}
	};

	/// @ignore
	/// @func __ClipResetFrame()
	/// @desc Internal: reset scissor state for a new frame (disable scissor and clear clip stack).
	static __ClipResetFrame = function() {
		__clip_stack = [];
		__clip_stack_len = 0;
		__ClipResetTarget();
	};

	/// @ignore
	/// @func __ClipIntersectRects(_a, _b)
	/// @desc Internal: intersect two rect structs {x1,y1,x2,y2}.
	/// @param {Struct} _a
	/// @param {Struct} _b
	/// @return {Struct}
	static __ClipIntersectRects = function(_a, _b) {
		var _x1 = max(_a.x1, _b.x1);
		var _y1 = max(_a.y1, _b.y1);
		var _x2 = min(_a.x2, _b.x2);
		var _y2 = min(_a.y2, _b.y2);
		if (_x2 < _x1) _x2 = _x1;
		if (_y2 < _y1) _y2 = _y1;
		return { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
	};

	/// @ignore
	/// @func __ClipApplyTop()
	/// @desc Internal: apply the current top-of-stack scissor rect.
	static __ClipUseBrowserHostedMapping = function() {
		return (os_browser != browser_not_a_browser)
		|| (os_type == os_gxgames)
		|| (os_type == os_operagx);
	};

	static __ClipGetTargetMetrics = function() {
		var _window_w = max(1, window_get_width());
		var _window_h = max(1, window_get_height());
		if (__ClipUseBrowserHostedMapping()) {
			var _gui_w = max(1, display_get_gui_width());
			var _gui_h = max(1, display_get_gui_height());
			return {
				target_x1: 0,
				target_y1: 0,
				target_w: _gui_w,
				target_h: _gui_h,
				clip_max_w: _gui_w,
				clip_max_h: _gui_h
			};
		}

		var _target_x1 = 0;
		var _target_y1 = 0;
		var _target_w = _window_w;
		var _target_h = _window_h;
		var _a = application_get_position();
		if (is_array(_a) && array_length(_a) >= 4) {
			_target_x1 = _a[0];
			_target_y1 = _a[1];
			_target_w = max(1, _a[2] - _a[0]);
			_target_h = max(1, _a[3] - _a[1]);
		}

		return {
			target_x1: _target_x1,
			target_y1: _target_y1,
			target_w: _target_w,
			target_h: _target_h,
			clip_max_w: _window_w,
			clip_max_h: _window_h
		};
	};

	static __ClipResetTarget = function() {
		var _metrics = __ClipGetTargetMetrics();
		if (__ClipUseBrowserHostedMapping()) {
			gpu_set_scissor(_metrics.target_x1, _metrics.target_y1, _metrics.target_w, _metrics.target_h);
		}
		else {
			gpu_set_scissor(0, 0, window_get_width(), window_get_height());
		}
	};

	static __ClipComputeScissorRect = function(_rect) {
		var _gx1 = min(_rect.x1, _rect.x2);
		var _gy1 = min(_rect.y1, _rect.y2);
		var _gx2 = max(_rect.x1, _rect.x2);
		var _gy2 = max(_rect.y1, _rect.y2);

		var _gui_w = display_get_gui_width();
		var _gui_h = display_get_gui_height();
		var _metrics = __ClipGetTargetMetrics();
		var _target_x1 = _metrics.target_x1;
		var _target_y1 = _metrics.target_y1;
		var _target_w = _metrics.target_w;
		var _target_h = _metrics.target_h;

		var _scale_x = (_gui_w > 0) ? (_target_w / _gui_w) : 1;
		var _scale_y = (_gui_h > 0) ? (_target_h / _gui_h) : 1;

		var _x1 = floor(_target_x1 + (_gx1 * _scale_x)) - 1;
		var _y1 = floor(_target_y1 + (_gy1 * _scale_y)) - 1;
		var _x2 = ceil(_target_x1 + (_gx2 * _scale_x)) + 1;
		var _y2 = ceil(_target_y1 + (_gy2 * _scale_y)) + 1;

		if (_x1 < 0) _x1 = 0;
		if (_y1 < 0) _y1 = 0;
		if (_x2 > _metrics.clip_max_w) _x2 = _metrics.clip_max_w;
		if (_y2 > _metrics.clip_max_h) _y2 = _metrics.clip_max_h;

		return {
			x: _x1,
			y: _y1,
			w: max(0, _x2 - _x1),
			h: max(0, _y2 - _y1)
		};
	};

	static __ClipApplyTop = function() {
		if (__clip_stack_len <= 0) {
			__ClipResetTarget();
			return;
		}
		var _r = __clip_stack[__clip_stack_len - 1];
		if (!is_struct(_r)) {
			__ClipResetTarget();
			return;
		}
		var _scissor = __ClipComputeScissorRect(_r);
		gpu_set_scissor(_scissor.x, _scissor.y, _scissor.w, _scissor.h);
	};

	/// @func PushClipRect(_x1, _y1, _x2, _y2)
	/// @desc Push a clip rectangle. Any existing clip will be intersected with this one.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	static PushClipRect = function(_x1, _y1, _x2, _y2) {
		var _nx1 = min(_x1, _x2);
		var _ny1 = min(_y1, _y2);
		var _nx2 = max(_x1, _x2);
		var _ny2 = max(_y1, _y2);
		var _rect = { x1: _nx1, y1: _ny1, x2: _nx2, y2: _ny2 };
		if (__clip_stack_len > 0) {
			var _top = __clip_stack[__clip_stack_len - 1];
			if (is_struct(_top)) {
				_rect = __ClipIntersectRects(_top, _rect);
			}
		}
		array_push(__clip_stack, _rect);
		__clip_stack_len++;
		__ClipApplyTop();
	};

	/// @func PopClipRect()
	/// @desc Pop the most recently pushed clip rectangle.
	static PopClipRect = function() {
		if (__clip_stack_len <= 0) {
			__ClipResetTarget();
			return;
		}
		array_delete(__clip_stack, __clip_stack_len - 1, 1);
		__clip_stack_len--;
		__ClipApplyTop();
	};


	/// @func HitTestRect(_x1, _y1, _x2, _y2)
	/// @desc Simple hit test for a rect, respecting mouse_consumed and the current clip region.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	/// @return {Bool}
	static HitTestRect = function(_x1, _y1, _x2, _y2) {
		if (mouse_consumed) {
			return false;
		}
		// Respect the current clip rect so controls cannot interact outside visible panel/window bounds.
		if (__clip_stack_len > 0) {
			var _clip = __clip_stack[__clip_stack_len - 1];
			if (is_struct(_clip)) {
				if (mx < _clip.x1 || mx > _clip.x2 || my < _clip.y1 || my > _clip.y2) {
					return false;
				}
			}
		}
		return (mx >= _x1 && mx <= _x2 && my >= _y1 && my <= _y2);
	};

	/// @desc Request a tooltip for a given control id.
	/// @param {String} _control_id
	/// @param {String} _text
	/// @param {Real} _anchor_x
	/// @param {Real} _anchor_y
	static RequestTooltip = function(_control_id, _text, _anchor_x, _anchor_y) {
		// If a modal overlay is active and this is not the owner, ignore.
		if (!is_undefined(active_overlay_owner_id)) {
			if (_control_id != active_overlay_owner_id) {
				return;
			}
		}

		tooltip_requested_this_frame = true;
		tooltip_owner_window = is_instanceof(__current_window, EchoChamberWindow)
		? __current_window
		: undefined;

		var _id = string(_control_id);
		if (_id != tooltip_control_id) {
			tooltip_control_id = _id;
			tooltip_start_time = current_time;
			tooltip_visible    = false;
		}
		tooltip_text     = string(_text);
		tooltip_anchor_x = _anchor_x;
		tooltip_anchor_y = _anchor_y;
	};

	/// @ignore
	/// @func __SetCurrentWindow(_window)
	/// @desc Set the current window context while drawing controls. This allows overlays to be associated with the window that created them.
	/// @param {Any} _window
	static __SetCurrentWindow = function(_window) {
		__current_window = _window;
	};

	/// @desc Mark a control as owning a modal overlay (e.g. a dropdown).
	/// @param {String} _control_id
	static SetActiveOverlayOwner = function(_control_id) {
		var _id = is_undefined(_control_id) ? undefined : string(_control_id);
		if (is_undefined(_id)) {
			active_overlay_owner_id     = undefined;
			active_overlay_owner_window = undefined;
			active_overlay_rect         = undefined;
			return;
		}
		// If another window is force-blocked this frame, do not allow it to steal overlay ownership.
		if (mouse_consumed && !is_undefined(active_overlay_owner_id) && _id != active_overlay_owner_id) {
			return;
		}
		active_overlay_owner_id = _id;
		if (is_struct(__current_window)) {
			active_overlay_owner_window = __current_window;
		}
	};

	/// @desc Clear the active overlay (if any).
	static ClearActiveOverlayOwner = function() {
		active_overlay_owner_id     = undefined;
		active_overlay_owner_window = undefined;
		active_overlay_rect         = undefined;
		overlay_close_requested     = false;
	};


	/// @desc Request the currently active overlay (if any) to close.
	/// @note Overlay owner controls should honor this during their ProcessAndDraw.
	static RequestCloseOverlay = function() {
		overlay_close_requested = true;
	};

	/// @ignore
	/// @func __ConsumeOverlayCloseRequest(_owner_id)
	/// @desc Returns true if a close request is pending for the current active overlay owner id. Consumes the request.
	/// @param {Any} _owner_id
	/// @return {Bool}
	static __ConsumeOverlayCloseRequest = function(_owner_id) {
		if (!overlay_close_requested) {
			return false;
		}
		if (is_undefined(active_overlay_owner_id)) {
			overlay_close_requested = false;
			return false;
		}
		if (string(_owner_id) != active_overlay_owner_id) {
			return false;
		}
		overlay_close_requested = false;
		return true;
	};

	/// @ignore
	/// @func __NormalizeRect(_rect)
	/// @desc Normalize an optional rect argument into a {x1,y1,x2,y2} struct.
	/// @param {Any} _rect
	/// @return {Any} Returns a rect struct or undefined.
	static __NormalizeRect = function(_rect) {
		if (!is_struct(_rect)) {
			return undefined;
		}
		var _x1 = _rect[$ "x1"];
		var _y1 = _rect[$ "y1"];
		var _x2 = _rect[$ "x2"];
		var _y2 = _rect[$ "y2"];
		if (is_undefined(_x1) || is_undefined(_y1) || is_undefined(_x2) || is_undefined(_y2)) {
			return undefined;
		}
		return { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
	};

	/// @desc Queue an overlay draw callback. Overlays are drawn after all windows.
	/// @param {Any} _owner_id
	/// @param {Function} _draw_fn
	/// @param {Any} [_rect] Optional rect struct {x1,y1,x2,y2} for hit testing.
	/// @param {Any} [_owner_window] Optional owner window reference (Struct.EchoChamberWindow).
	static QueueOverlay = function(_owner_id, _draw_fn, _rect = undefined, _owner_window = undefined) {
		if (!is_callable(_draw_fn)) {
			return;
		}
		var _resolved_owner_window = is_struct(_owner_window) ? _owner_window : __current_window;
		var _entry = {
			owner_id     : is_undefined(_owner_id) ? undefined : string(_owner_id),
			draw_fn      : _draw_fn,
			rect         : __NormalizeRect(_rect),
			owner_window : is_struct(_resolved_owner_window) ? _resolved_owner_window : undefined
		};
		array_push(overlays, _entry);
		// Cache the most recent overlay rect for the active owner.
		if (!is_undefined(active_overlay_owner_id) && _entry.owner_id == active_overlay_owner_id) {
			active_overlay_rect = _entry.rect;
			if (is_struct(_entry.owner_window)) {
				active_overlay_owner_window = _entry.owner_window;
			}
		}
	};

	/// @desc Open a context menu overlay at a screen position.
	/// @param {Array} _items Array of item structs:
	///		- { label:String, on_click:Function, enabled:Bool (optional), shortcut:String (optional) }
	///		- { is_separator:true } for separators
	/// @param {Real} _x
	/// @param {Real} _y
	/// @param {Any} _owner_window Optional owning window reference.
	/// @param {String} [_style_id] Optional textinput style id for menu theming.
	static OpenContextMenu = function(_items, _x, _y, _owner_window, _style_id = "_default") {
		if (!is_array(_items)) {
			return;
		}

		context_menu_items		= _items;
		context_menu_item_count	= array_length(_items);

		if (context_menu_item_count <= 0) {
			CloseContextMenu();
			return;
		}

		context_menu_open		= true;
		context_menu_x			= _x;
		context_menu_y			= _y;
		context_menu_open_time	= current_time;
		context_menu_style_id	= string(_style_id);
		if (string_length(context_menu_style_id) <= 0) {
			context_menu_style_id = "_default";
		}

		context_menu_owner_window = is_struct(_owner_window)
		? _owner_window
		: (is_struct(__current_window) ? __current_window : undefined);

		context_menu_hover_i	= -1;
		context_menu_key_i		= __ContextMenuFindFirstSelectable();

		overlay_close_requested = false;

		SetActiveOverlayOwner(context_menu_owner_id);
		if (is_struct(context_menu_owner_window)) {
			active_overlay_owner_window = context_menu_owner_window;
		}

		var _pushed = __PushWindowTheme(context_menu_owner_window);
		__ContextMenuRecalcRect();
		if (_pushed) {
			__PopThemeOverride();
		}
	};

	/// @desc Close the active context menu overlay (if open).
	static CloseContextMenu = function() {
		context_menu_open		= false;
		context_menu_items		= [];
		context_menu_item_count	= 0;
		context_menu_hover_i	= -1;
		context_menu_key_i		= -1;
		context_menu_rect		= undefined;
		context_menu_style_id	= "_default";

		if (!is_undefined(active_overlay_owner_id) && active_overlay_owner_id == context_menu_owner_id) {
			ClearActiveOverlayOwner();
		}
	};

	/// @desc Returns true if the context menu overlay is open.
	/// @return {Bool}
	static IsContextMenuOpen = function() {
		return context_menu_open;
	};

	/// @ignore
	/// @func __QueueContextMenuOverlay()
	/// @desc Internal: queues the context menu overlay if open.
	static __QueueContextMenuOverlay = function() {
		if (!context_menu_open) {
			return;
		}
		var _pushed = __PushWindowTheme(context_menu_owner_window);
		if (!is_struct(context_menu_rect)) {
			__ContextMenuRecalcRect();
		}
		if (_pushed) {
			__PopThemeOverride();
		}
		QueueOverlay(context_menu_owner_id, method(self, __ContextMenuDrawOverlay), context_menu_rect, context_menu_owner_window);
	};

	/// @ignore
	/// @func __ContextMenuFindFirstSelectable()
	/// @desc Internal: finds the first enabled non-separator item index.
	/// @return {Real}
	static __ContextMenuFindFirstSelectable = function() {
		for (var _i = 0; _i < context_menu_item_count; _i++) {
			var _it = context_menu_items[_i];
			if (!is_struct(_it)) continue;

			var _sep = (_it[$ "is_separator"] ?? false);
			if (_sep) continue;

			var _en = (_it[$ "enabled"] ?? true);
			_en = (_en == true);
			if (!_en) continue;

			return _i;
		}
		return -1;
	};

	/// @ignore
	/// @func __ContextMenuMoveKeySelection(_dir)
	/// @desc Internal: move keyboard selection by +/-1, skipping separators/disabled.
	/// @param {Real} _dir
	static __ContextMenuMoveKeySelection = function(_dir) {
		if (context_menu_item_count <= 0) return;

		var _i = context_menu_key_i;
		if (_i < 0) _i = __ContextMenuFindFirstSelectable();
		if (_i < 0) return;

		for (var _step = 0; _step < context_menu_item_count; _step++) {
			_i += _dir;
			if (_i < 0) _i = context_menu_item_count - 1;
			if (_i >= context_menu_item_count) _i = 0;

			var _it = context_menu_items[_i];
			if (!is_struct(_it)) continue;

			var _sep = (_it[$ "is_separator"] ?? false);
			if (_sep) continue;

			var _en = (_it[$ "enabled"] ?? true);
			_en = (_en == true);
			if (!_en) continue;

			context_menu_key_i = _i;
			return;
		}
	};

	/// @ignore
	/// @func __ContextMenuResolveMenuTheme()
	/// @desc Internal: resolve active textinput menu style + _default fallback.
	static __ContextMenuResolveMenuTheme = function() {
		var _styles = theme[$ "textinput_styles"];
		var _default_style = is_struct(_styles) ? (_styles[$ "_default"]) : undefined;
		var _style = is_struct(_styles) ? (_styles[$ context_menu_style_id]) : undefined;
		if (!is_struct(_style)) {
			_style = _default_style;
		}
		var _menu = is_struct(_style) ? (_style[$ "menu"]) : undefined;
		var _menu_default = is_struct(_default_style) ? (_default_style[$ "menu"]) : undefined;
		return {
			menu : _menu,
			menu_default : _menu_default
		};
	};

	/// @ignore
	/// @func __ContextMenuGetMenuValue(_menus, _key, _fallback)
	/// @desc Internal: return menu style value with _default fallback.
	/// @param {Struct} _menus
	/// @param {String} _key
	/// @param {Any} _fallback
	/// @return {Any}
	static __ContextMenuGetMenuValue = function(_menus, _key, _fallback) {
		var _value = undefined;
		if (is_struct(_menus)) {
			var _menu = _menus[$ "menu"];
			if (is_struct(_menu)) {
				_value = _menu[$ _key];
			}
			if (is_undefined(_value)) {
				var _menu_default = _menus[$ "menu_default"];
				if (is_struct(_menu_default)) {
					_value = _menu_default[$ _key];
				}
			}
		}
		if (is_undefined(_value)) {
			_value = _fallback;
		}
		return _value;
	};

	/// @ignore
	/// @func __ContextMenuGetItemHeight(_it)
	/// @desc Internal: returns pixel height for an item.
	/// @param {Any} _it
	/// @return {Real}
	static __ContextMenuGetItemHeight = function(_it) {
		if (is_struct(_it) && (_it[$ "is_separator"] ?? false)) {
			return max(1, context_menu_sep_h);
		}
		return context_menu_row_h;
	};

	/// @ignore
	/// @func __ContextMenuRecalcRect()
	/// @desc Internal: calculate width/height and clamp to GUI bounds.
	static __ContextMenuRecalcRect = function() {
		var _menus = __ContextMenuResolveMenuTheme();

		var _pad = __ContextMenuGetMenuValue(_menus, "padding", theme[$ "context_menu_padding"] ?? default_padding);
		context_menu_pad = _pad;

		var _row_h = __ContextMenuGetMenuValue(_menus, "row_height", theme[$ "context_menu_row_h"] ?? default_row_height);
		if (_row_h <= 0) {
			_row_h = default_row_height;
		}
		context_menu_row_h = _row_h;

		var _sep_h = __ContextMenuGetMenuValue(_menus, "separator_height", 0);
		if (_sep_h <= 0) {
			_sep_h = max(6, floor(_row_h * 0.5));
		}
		context_menu_sep_h = _sep_h;

		var _font = __ContextMenuGetMenuValue(_menus, "font", theme.font_small);
		var _shortcut_gap = __ContextMenuGetMenuValue(_menus, "shortcut_gap", 24);

		var _old_font = draw_get_font();
		draw_set_font(_font);

		var _max_w = 0;
		var _total_h = 0;

		for (var _i = 0; _i < context_menu_item_count; _i++) {
			var _it = context_menu_items[_i];
			if (!is_struct(_it)) continue;

			var _h = __ContextMenuGetItemHeight(_it);
			_total_h += _h;

			if (_it[$ "is_separator"] ?? false) {
				continue;
			}

			var _label = string(_it[$ "label"] ?? "");
			var _shortcut = string(_it[$ "shortcut"] ?? "");

			var _w = string_width(_label);
			if (string_length(_shortcut) > 0) {
				_w += _shortcut_gap + string_width(_shortcut);
			}
			if (_w > _max_w) {
				_max_w = _w;
			}
		}

		draw_set_font(_old_font);

		var _min_w = __ContextMenuGetMenuValue(_menus, "min_width", theme[$ "context_menu_min_w"] ?? 140);
		var _max_w_cap = __ContextMenuGetMenuValue(_menus, "max_width", theme[$ "context_menu_max_w"] ?? 520);
		if (_min_w < 0) {
			_min_w = 0;
		}
		if (_max_w_cap < _min_w) {
			_max_w_cap = _min_w;
		}

		var _w_final = clamp(_max_w + _pad * 2, _min_w, _max_w_cap);
		var _h_final = _total_h + _pad * 2;

		context_menu_w = _w_final;
		context_menu_h = _h_final;

		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();
		var _margin = __ContextMenuGetMenuValue(_menus, "viewport_margin", 4);

		var _x1 = context_menu_x;
		var _y1 = context_menu_y;

		if (_x1 + _w_final > _gw - _margin) {
			_x1 = max(_margin, _gw - _margin - _w_final);
		}
		if (_y1 + _h_final > _gh - _margin) {
			_y1 = max(_margin, _gh - _margin - _h_final);
		}

		context_menu_x = _x1;
		context_menu_y = _y1;
		context_menu_rect = { x1: _x1, y1: _y1, x2: _x1 + _w_final, y2: _y1 + _h_final };
	};

	/// @ignore
	/// @func __ContextMenuDrawOverlay(_root)
	/// @desc Internal: draw + input handling for the context menu overlay.
	/// @param {Struct.EchoChamberRoot} _root
	static __ContextMenuDrawOverlay = function(_root) {
		if (!context_menu_open) {
			return;
		}

		// Honor overlay close requests (Esc).
		if (_root.__ConsumeOverlayCloseRequest(context_menu_owner_id)) {
			CloseContextMenu();
			return;
		}

		if (!is_struct(context_menu_rect)) {
			__ContextMenuRecalcRect();
			if (!is_struct(context_menu_rect)) return;
		}

		var _r = context_menu_rect;
		var _x1 = _r.x1;
		var _y1 = _r.y1;
		var _x2 = _r.x2;
		var _y2 = _r.y2;

		var _mx = _root.mx;
		var _my = _root.my;

		var _inside = (_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _y2);

		// Close on click-out (consume the click so it does not hit underlying UI).
		if (_root.mouse_l_pressed && !_inside && !_root.mouse_consumed) {
			CloseContextMenu();
			_root.ConsumeMouse();
			return;
		}
		if (_root.mouse_r_pressed && !_inside && !_root.mouse_consumed) {
			CloseContextMenu();
			_root.ConsumeMouse();
			return;
		}

		// Keyboard navigation
		if (_root.InputPressed(ECHO_UI_ACTION_NAV_DOWN, context_menu_owner_window)) {
			__ContextMenuMoveKeySelection(1);
		}
		if (_root.InputPressed(ECHO_UI_ACTION_NAV_UP, context_menu_owner_window)) {
			__ContextMenuMoveKeySelection(-1);
		}

		var _menus = __ContextMenuResolveMenuTheme();
		var _font = __ContextMenuGetMenuValue(_menus, "font", _root.theme.font_small);
		var _panel_bg = __ContextMenuGetMenuValue(_menus, "panel_bg", _root.theme.col_window_bg);
		var _panel_bg_alpha = __ContextMenuGetMenuValue(_menus, "panel_bg_alpha", 1);
		var _panel_border = __ContextMenuGetMenuValue(_menus, "panel_border", _root.theme.col_accent);
		var _panel_border_alpha = __ContextMenuGetMenuValue(_menus, "panel_border_alpha", 1);
		var _row_bg = __ContextMenuGetMenuValue(_menus, "item_bg", _root.theme.col_window_bg);
		var _row_bg_alpha = __ContextMenuGetMenuValue(_menus, "item_bg_alpha", 1);
		var _row_bg_hover = __ContextMenuGetMenuValue(_menus, "item_hover_bg", _root.theme.col_hover_row);
		var _row_bg_hover_alpha = __ContextMenuGetMenuValue(_menus, "item_hover_bg_alpha", 1);
		var _text_col = __ContextMenuGetMenuValue(_menus, "item_text", _root.theme.col_text);
		var _text_alpha = __ContextMenuGetMenuValue(_menus, "item_text_alpha", 1);
		var _text_hot = __ContextMenuGetMenuValue(_menus, "item_text_hot", _root.theme.col_text);
		var _text_hot_alpha = __ContextMenuGetMenuValue(_menus, "item_text_hot_alpha", 1);
		var _text_disabled_alpha = __ContextMenuGetMenuValue(_menus, "item_text_disabled_alpha", 0.45);
		var _separator_color = __ContextMenuGetMenuValue(_menus, "separator_color", _root.theme.col_accent);
		var _separator_alpha = __ContextMenuGetMenuValue(_menus, "separator_alpha", 1);
		var _item_inset_x = __ContextMenuGetMenuValue(_menus, "item_inset_x", 0);

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_old_alpha * _panel_bg_alpha);
		draw_set_color(_panel_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha * _panel_border_alpha);
		draw_set_color(_panel_border);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);

		// Font
		var _old_font = draw_get_font();
		draw_set_font(_font);
		var _text_h = string_height("Ag");

		var _pad = context_menu_pad;
		var _cy = _y1 + _pad;

		context_menu_hover_i = -1;

		for (var _i = 0; _i < context_menu_item_count; _i++) {
			var _it = context_menu_items[_i];
			if (!is_struct(_it)) {
				continue;
			}

			var _h = __ContextMenuGetItemHeight(_it);
			var _row_y1 = _cy;
			var _row_y2 = _cy + _h;

			var _sep = (_it[$ "is_separator"] ?? false);

			if (_sep) {
				var _ly = floor((_row_y1 + _row_y2) * 0.5);
				draw_set_alpha(_old_alpha * _separator_alpha);
				draw_set_color(_separator_color);
				draw_line(_x1 + _pad, _ly, _x2 - _pad, _ly);
				draw_set_alpha(_old_alpha);
				_cy = _row_y2;
				continue;
			}

			var _en = (_it[$ "enabled"] ?? true);
			_en = (_en == true);

			var _row_inside = (_inside && _my >= _row_y1 && _my <= _row_y2);

			if (_row_inside && _en) {
				context_menu_hover_i = _i;
				context_menu_key_i = _i;
			}

			var _is_hot = (_i == context_menu_hover_i) || (_i == context_menu_key_i);

			var _bg_use = _is_hot ? _row_bg_hover : _row_bg;
			var _bg_alpha_use = _is_hot ? _row_bg_hover_alpha : _row_bg_alpha;
			draw_set_alpha(_old_alpha * _bg_alpha_use);
			if (_is_hot) {
				draw_set_color(_bg_use);
				draw_rectangle(_x1 + 1, _row_y1, _x2 - 1, _row_y2, false);
			}
			else {
				draw_set_color(_bg_use);
				draw_rectangle(_x1 + 1, _row_y1, _x2 - 1, _row_y2, false);
			}
			draw_set_alpha(_old_alpha);

			var _label = string(_it[$ "label"] ?? "");
			var _shortcut = string(_it[$ "shortcut"] ?? "");

			var _text_col_use = _is_hot ? _text_hot : _text_col;
			var _text_alpha_use = _is_hot ? _text_hot_alpha : _text_alpha;
			if (!_en) {
				_text_alpha_use *= _text_disabled_alpha;
			}
			draw_set_color(_text_col_use);
			draw_set_alpha(_old_alpha * _text_alpha_use);

			var _text_y = _row_y1 + max(0, floor((_h - _text_h) * 0.5));
			draw_text(_x1 + _pad + _item_inset_x, _text_y, _label);

			if (string_length(_shortcut) > 0) {
				var _sw = string_width(_shortcut);
				draw_text(_x2 - _pad - _item_inset_x - _sw, _text_y, _shortcut);
			}

			draw_set_alpha(_old_alpha);

			// Click activates (consume either way)
			if (_root.mouse_l_pressed && _row_inside && !_root.mouse_consumed) {
				_root.ConsumeMouse();

				var _on_click = _it[$ "on_click"];
				if (_en && is_callable(_on_click)) {
					_on_click();
					CloseContextMenu();
					draw_set_font(_old_font);
					return;
				}
			}

			_cy = _row_y2;
		}

		// Consume clicks inside the menu even if they hit no row (padding).
		if (_inside && (_root.mouse_l_pressed || _root.mouse_r_pressed) && !_root.mouse_consumed) {
			_root.ConsumeMouse();
		}

		// Enter activates keyboard selection
		if (_root.InputPressed(ECHO_UI_ACTION_ACCEPT, context_menu_owner_window) && context_menu_key_i >= 0) {
			var _it = context_menu_items[context_menu_key_i];
			if (is_struct(_it)) {
				var _en = (_it[$ "enabled"] ?? true);
				_en = (_en == true);

				var _on_click = _it[$ "on_click"];
				if (_en && is_callable(_on_click)) {
					_on_click();
					CloseContextMenu();
				}
			}
		}

		draw_set_font(_old_font);
	};

	/// @desc Draw all queued overlays once per frame.
	static DrawOverlays = function() {
		if (overlays_drawn) {
			return;
		}
		overlays_drawn = true;
		var _len = array_length(overlays);
		for (var _i = 0; _i < _len; _i++) {
			var _entry = overlays[_i];
			if (!is_struct(_entry)) {
				continue;
			}
			var _fn = _entry[$ "draw_fn"];
			if (!is_callable(_fn)) {
				continue;
			}
			var _owner_window = _entry[$ "owner_window"];
			var _prev_window = __current_window;
			if (is_instanceof(_owner_window, EchoChamberWindow)) {
				__current_window = _owner_window;
			}
			var _pushed = __PushWindowTheme(_owner_window);
			var _r = _entry[$ "rect"];
			if (is_struct(_r)) {
				PushClipRect(_r.x1, _r.y1, _r.x2 + 1, _r.y2 + 1);
				_fn(self);
				PopClipRect();
			}
			else {
				_fn(self);
			}
			if (_pushed) {
				__PopThemeOverride();
			}
			__current_window = _prev_window;
		}
		overlays = [];
	};

	/// @desc Dock + collapse layout. Assigns rects to all top-level panels.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	static LayoutPanels = function(_x1, _y1, _x2, _y2) {
		__EchoChamberAssignPanelRects(self, panels, _x1, _y1, _x2, _y2);
	};

	/// @desc Draw simple tooltip for the current tooltip_control_id (if delay elapsed).
	static DrawTooltip = function() {
		if (is_undefined(tooltip_control_id)) {
			return;
		}
		if (string_length(tooltip_text) <= 0) {
			return;
		}
		var _pushed = __PushWindowTheme(tooltip_owner_window);
		var _elapsed = current_time - tooltip_start_time;
		if (_elapsed < tooltip_delay_ms) {
			if (_pushed) {
				__PopThemeOverride();
			}
			return;
		}

		tooltip_visible = true;

		var _pad = theme[$ "tooltip_padding"] ?? default_padding;
		var _old_font = draw_get_font();
		draw_set_font(theme.font_small);

		var _text_w = string_width(tooltip_text);
		var _text_h = string_height(tooltip_text);

		var _box_w = _text_w + _pad * 2;
		var _box_h = _text_h + _pad * 2;

		var _x1 = tooltip_anchor_x + 12;
		var _y1 = tooltip_anchor_y + 12;
		var _x2 = _x1 + _box_w;
		var _y2 = _y1 + _box_h;

		var _st = theme.tooltip_styles[$ "_default"];
		var _bg_col = _st[$ "bg"] ?? theme.col_window_bg;
		var _border_col = _st[$ "border"] ?? theme.col_accent;
		var _bg_alpha = _st[$ "bg_alpha"] ?? 0.9;
		var _text_col = _st[$ "text"] ?? theme.col_text;

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);

		draw_set_color(_border_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);

		draw_set_color(_text_col);
		draw_text(_x1 + _pad, _y1 + _pad, tooltip_text);

		draw_set_font(_old_font);
		if (_pushed) {
			__PopThemeOverride();
		}
	};

	/// @ignore
	/// @func __ToastPreviewFromText(_text)
	/// @desc Internal: build a short one-line preview string for a toast.
	/// @param {Any} _text
	/// @return {String}
	static __ToastPreviewFromText = function(_text) {
		var _s = is_undefined(_text) ? "" : string(_text);
		_s = string_replace_all(_s, "\r", " ");
		_s = string_replace_all(_s, "\n", " ");
		_s = string_replace_all(_s, "\t", " ");
		_s = string_trim(_s);
		if (string_length(_s) <= 0) {
			return "(empty)";
		}
		var _max_chars = toast_max_preview_chars;
		if (_max_chars <= 0) _max_chars = 80;
		if (string_length(_s) > _max_chars) {
			_s = string_copy(_s, 1, _max_chars);
			_s = _s + "...";
		}
		return _s;
	};

	/// @desc Show a short toast message (non-blocking).
	/// @param {Any} _text
	/// @param {Real} _duration_ms Optional duration in milliseconds.
	static ShowToast = function(_text, _duration_ms) {
		toast_text = is_undefined(_text) ? "" : string(_text);
		if (string_length(toast_text) <= 0) {
			toast_until_time = 0;
			return;
		}
		toast_start_time = current_time;
		var _dur = toast_duration_ms;
		if (is_real(_duration_ms)) {
			_dur = _duration_ms;
		}
		toast_until_time = toast_start_time + max(0, _dur);
	};

	/// @desc Copy text to clipboard and show a toast confirmation.
	/// @param {Any} _text
	/// @param {Any} _toast_text Optional toast text (otherwise uses "Copied: <preview>").
	/// @param {Real} _duration_ms Optional duration in milliseconds.
	static CopyToClipboard = function(_text, _toast_text, _duration_ms) {
		var _s = is_undefined(_text) ? "" : string(_text);
		clipboard_set_text(_s);
		if (is_undefined(_toast_text)) {
			ShowToast("Copied: " + __ToastPreviewFromText(_s), _duration_ms);
		}
		else {
			ShowToast(_toast_text, _duration_ms);
		}
	};

	/// @ignore
	/// @func DrawToast()
	/// @desc Internal: draw the current toast (if active).
	static DrawToast = function() {
		if (toast_until_time <= 0) {
			return;
		}
		var _now = current_time;
		if (_now >= toast_until_time) {
			toast_until_time = 0;
			return;
		}
		if (string_length(toast_text) <= 0) {
			return;
		}

		var _pad = theme[$ "toast_padding"] ?? theme[$ "tooltip_padding"] ?? default_padding;
		var _old_font = draw_get_font();
		draw_set_font(theme.font_small);

		var _text_w = string_width(toast_text);
		var _text_h = string_height(toast_text);
		var _box_w = _text_w + _pad * 2;
		var _box_h = _text_h + _pad * 2;

		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();
		var _margin = theme[$ "toast_margin"] ?? 12;
		var _x2 = _gw - _margin;
		var _y2 = _gh - _margin;
		var _x1 = _x2 - _box_w;
		var _y1 = _y2 - _box_h;
		_x1 = max(_margin, _x1);
		_y1 = max(_margin, _y1);
		_x2 = _x1 + _box_w;
		_y2 = _y1 + _box_h;

		var _st = theme[$ "toast_styles"];
		if (is_undefined(_st)) {
			_st = theme.tooltip_styles[$ "_default"];
		}
		else {
			_st = _st[$ "_default"];
		}
		var _bg_col = _st[$ "bg"] ?? theme.col_window_bg;
		var _border_col = _st[$ "border"] ?? theme.col_accent;
		var _bg_alpha = _st[$ "bg_alpha"] ?? 0.9;
		var _text_col = _st[$ "text"] ?? theme.col_text;

		var _fade_ms = toast_fade_ms;
		if (_fade_ms <= 0) _fade_ms = 160;
		var _alpha_mul = 1.0;
		var _remain = toast_until_time - _now;
		if (_remain < _fade_ms) {
			_alpha_mul = clamp(_remain / _fade_ms, 0, 1);
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_alpha * _alpha_mul);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha * _alpha_mul);
		draw_set_color(_border_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_color(_text_col);
		draw_text(_x1 + _pad, _y1 + _pad, toast_text);
		draw_set_alpha(_old_alpha);
		draw_set_font(_old_font);
	};

	/// @desc Convenience: draw a basic panel background.
	/// @param {Struct.EchoChamberPanel} _panel
	static DrawPanelBackground = function(_panel) {
		var _x1 = _panel.rect.x1;
		var _y1 = _panel.rect.y1;
		var _x2 = _panel.rect.x2;
		var _y2 = _panel.rect.y2;

		var _key = _panel.style_key ?? "_default";

		var _styles = theme.panel_styles;
		var _st = _styles[$ _key] ?? _styles[$ "_default"];
		var _bg = _st[$ "bg"] ?? theme.col_panel_bg;
		var _bd = _st[$ "border"] ?? theme.col_accent;
		var _bg_a = _st[$ "bg_alpha"] ?? 0.95;
		var _bd_a = _st[$ "border_alpha"] ?? 1;

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_bg_a);
		draw_set_color(_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha * _bd_a);

		draw_set_color(_bd);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		draw_set_alpha(_old_alpha);
	};

	/// @desc Draw a collapse handle for a panel (if it supports collapsing).
	/// @param {Struct.EchoChamberPanel} _panel
	static DrawPanelCollapseHandle = function(_panel) {
		if (_panel.collapse_mode == eEchoChamberCollapse.NONE) {
			return;
		}

		var _x1 = _panel.rect.x1;
		var _y1 = _panel.rect.y1;
		var _x2 = _panel.rect.x2;
		var _y2 = _panel.rect.y2;

		var _handle_x1, _handle_y1, _handle_x2, _handle_y2;
		var _size = theme[$ "panel_collapse_handle_size"] ?? 8;

		switch (_panel.collapse_mode) {
			case eEchoChamberCollapse.TO_TOP:
				_handle_x1 = _x1;
				_handle_x2 = _x2;
				_handle_y2 = _y2;
				_handle_y1 = _handle_y2 - _size;
			break;

			case eEchoChamberCollapse.TO_BOTTOM:
				_handle_x1 = _x1;
				_handle_x2 = _x2;
				_handle_y1 = _y1;
				_handle_y2 = _y1 + _size;
			break;

			case eEchoChamberCollapse.TO_LEFT:
				_handle_y1 = _y1;
				_handle_y2 = _y2;
				_handle_x2 = _x2;
				_handle_x1 = _handle_x2 - _size;
			break;

			case eEchoChamberCollapse.TO_RIGHT:
				_handle_y1 = _y1;
				_handle_y2 = _y2;
				_handle_x1 = _x1;
				_handle_x2 = _x1 + _size;
			break;

			default:
			return;
		}

		var _hover = HitTestRect(_handle_x1, _handle_y1, _handle_x2, _handle_y2);

		var _old_alpha = draw_get_alpha();
		var _base_col  = theme.col_panel_bg;
		var _border    = theme.col_accent;

		if (_hover && !mouse_consumed) {
			_base_col = merge_color(_base_col, theme.col_text, 0.25);
		}

		draw_set_alpha(0.9);
		draw_set_color(_base_col);
		draw_rectangle(_handle_x1, _handle_y1, _handle_x2, _handle_y2, false);
		draw_set_alpha(_old_alpha);

		draw_set_color(_border);
		draw_rectangle(_handle_x1, _handle_y1, _handle_x2, _handle_y2, true);

		// Simple glyph
		var _cx = (_handle_x1 + _handle_x2) * 0.5;
		var _cy = (_handle_y1 + _handle_y2) * 0.5;
		draw_set_color(theme.col_text);

		if (_panel.collapse_mode == eEchoChamberCollapse.TO_TOP || _panel.collapse_mode == eEchoChamberCollapse.TO_BOTTOM) {
			// vertical arrow
			var _dy = 3;
			draw_line(_cx, _cy - _dy, _cx, _cy + _dy);
		}
		else {
			// horizontal arrow
			var _dx = 3;
			draw_line(_cx - _dx, _cy, _cx + _dx, _cy);
		}

		// Handle click
		if (_hover && mouse_l_pressed && !mouse_consumed) {
			_panel.collapsed = !_panel.collapsed;
			ConsumeMouse();
		}
	};

	/// @func SetTextInputSource(_fn)
	/// @desc Set a function that returns the current active text input string. If not set, keyboard_string is used.
	/// @param {Function} _fn
	static SetTextInputSource = function(_fn) {
		if (is_callable(_fn)) {
			text_source = _fn;
		}
	};

	/// @func SetTextInputSeed(_fn)
	/// @desc Set a function that seeds the active text input string when focusing. If not set, keyboard_string is used.
	/// @param {Function} _fn
	static SetTextInputSeed = function(_fn) {
		if (is_callable(_fn)) {
			text_seed = _fn;
		}
	};

	/// @ignore
	/// @func __TextInputResetCaretBlink()
	/// @desc Internal: reset caret blink timer and show the caret.
	static __TextInputResetCaretBlink = function() {
		text_caret_visible = true;
		text_caret_blink_time = current_time;
	};

	/// @ignore
	/// @func __TextInputClampIndices()
	/// @desc Internal: clamp caret and selection anchor to the buffer length.
	static __TextInputClampIndices = function() {
		var _len = string_length(text_buffer);
		text_caret_index = clamp(text_caret_index, 0, _len);
		if (text_selection_anchor >= 0) {
			text_selection_anchor = clamp(text_selection_anchor, 0, _len);
		}
	};

	/// @ignore
	/// @func __TextInputHasSelection()
	/// @desc Internal: return true when a non-empty selection exists.
	/// @return {Bool}
	static __TextInputHasSelection = function() {
		return (text_selection_anchor >= 0 && text_selection_anchor != text_caret_index);
	};

	/// @ignore
	/// @func __TextInputGetSelectionRange()
	/// @desc Internal: return selection start/end indices (0-based).
	/// @return {Struct}
	static __TextInputGetSelectionRange = function() {
		if (!__TextInputHasSelection()) {
			return { start: text_caret_index, _end: text_caret_index };
		}
		var _s = min(text_selection_anchor, text_caret_index);
		var _e = max(text_selection_anchor, text_caret_index);
		return { start: _s, _end: _e };
	};

	/// @ignore
	/// @func __TextInputClearSelection()
	/// @desc Internal: clear any active selection.
	static __TextInputClearSelection = function() {
		text_selection_anchor = -1;
	};

	/// @ignore
	/// @func __TextInputSetCaret(_index, _extend_selection)
	/// @desc Internal: set caret index and optionally extend selection.
	/// @param {Real} _index
	/// @param {Bool} _extend_selection
	static __TextInputSetCaretEx = function(_index, _extend_selection, _update_preferred_x = true) {
		var _len = string_length(text_buffer);
		var _next = clamp(_index, 0, _len);
		if (_extend_selection) {
			if (text_selection_anchor < 0) {
				text_selection_anchor = text_caret_index;
			}
		}
		else {
			text_selection_anchor = -1;
		}
		text_caret_index = _next;
		__TextInputResetCaretBlink();

		if (_update_preferred_x) {
			__TextAreaUpdatePreferredXFromCaret(text_input_config);
		}
	};

	/// @ignore
	/// @func __TextInputSetCaret(_index, _extend_selection)
	/// @desc Internal: set caret index and optionally extend selection.
	/// @param {Real} _index
	/// @param {Bool} _extend_selection
	static __TextInputSetCaret = function(_index, _extend_selection) {
		__TextInputSetCaretEx(_index, _extend_selection, true);
	};

	/// @ignore
	/// @func __TextInputSelectAll()
	/// @desc Internal: select the entire buffer.
	static __TextInputSelectAll = function() {
		text_selection_anchor = 0;
		text_caret_index = string_length(text_buffer);
		__TextInputResetCaretBlink();
		__TextAreaUpdatePreferredXFromCaret(text_input_config);
	};

	/// @ignore
	/// @func __TextInputGetSelectedText()
	/// @desc Internal: return the selected substring (or empty).
	/// @return {String}
	static __TextInputGetSelectedText = function() {
		if (!__TextInputHasSelection()) return "";
		var _range = __TextInputGetSelectionRange();
		var _len = _range._end - _range.start;
		if (_len <= 0) return "";
		return string_copy(text_buffer, _range.start + 1, _len);
	};

	/// @ignore
	/// @func __TextInputIsWordChar(_ch)
	/// @desc Internal: return true if a character is treated as a word glyph.
	/// @param {String} _ch
	/// @return {Bool}
	static __TextInputIsWordChar = function(_ch) {
		if (string_length(_ch) <= 0) return false;
		var _code = ord(_ch);
		if (_code >= 48 && _code <= 57) return true;
		if (_code >= 65 && _code <= 90) return true;
		if (_code >= 97 && _code <= 122) return true;
		return (_code == 95);
	};

	/// @ignore
	/// @func __TextInputFindWordStart(_text, _index)
	/// @desc Internal: find the word start to the left of the caret.
	/// @param {String} _text
	/// @param {Real} _index
	/// @return {Real}
	static __TextInputFindWordStart = function(_text, _index) {
		var _len = string_length(_text);
		var _i = clamp(_index, 0, _len);
		while (_i > 0) {
			var _ch = string_char_at(_text, _i);
			if (__TextInputIsWordChar(_ch)) break;
			_i--;
		}
		while (_i > 0) {
			var _ch2 = string_char_at(_text, _i);
			if (!__TextInputIsWordChar(_ch2)) break;
			_i--;
		}
		return _i;
	};

	/// @ignore
	/// @func __TextInputFindWordEnd(_text, _index)
	/// @desc Internal: find the word end to the right of the caret.
	/// @param {String} _text
	/// @param {Real} _index
	/// @return {Real}
	static __TextInputFindWordEnd = function(_text, _index) {
		var _len = string_length(_text);
		var _i = clamp(_index, 0, _len);
		while (_i < _len) {
			var _ch = string_char_at(_text, _i + 1);
			if (__TextInputIsWordChar(_ch)) break;
			_i++;
		}
		while (_i < _len) {
			var _ch2 = string_char_at(_text, _i + 1);
			if (!__TextInputIsWordChar(_ch2)) break;
			_i++;
		}
		return _i;
	};

	/// @ignore
	/// @func __TextInputGetWordRange(_text, _index)
	/// @desc Internal: return the word range surrounding an index.
	/// @param {String} _text
	/// @param {Real} _index
	/// @return {Struct}
	static __TextInputGetWordRange = function(_text, _index) {
		var _len = string_length(_text);
		if (_len <= 0) return { start: 0, _end: 0 };
		var _i = clamp(_index, 0, _len - 1);
		var _ch = string_char_at(_text, _i + 1);
		if (!__TextInputIsWordChar(_ch)) {
			return { start: _i, _end: _i + 1 };
		}
		var _start = __TextInputFindWordStart(_text, _i);
		var _end = __TextInputFindWordEnd(_text, _i + 1);
		return { start: _start, _end: _end };
	};

	/// @ignore
	/// @func __TextInputIndexFromX(_text, _font, _x, [_config])
	/// @desc Internal: convert a local X offset into a caret index.
	/// @param {String} _text
	/// @param {Asset.GMFont} _font
	/// @param {Real} _x
	/// @param {Struct} [_config]
	/// @return {Real}
	static __TextInputIndexFromX = function(_text, _font, _x, _config = undefined) {
		var _len = string_length(_text);
		if (_len <= 0) return 0;
		var _old_font = draw_get_font();
		draw_set_font(_font);
		var _local_x = max(0, _x);
		var _acc = 0;
		var _idx = _len;
		var _tab_w = string_width(__TextInputGetVisualTabToken(_config));
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_text, _i);
			var _w = (_ch == "\t") ? _tab_w : string_width(_ch);
			if (_local_x < (_acc + (_w * 0.5))) {
				_idx = _i - 1;
				break;
			}
			_acc += _w;
		}
		draw_set_font(_old_font);
		return clamp(_idx, 0, _len);
	};

	/// @ignore
	/// @func __TextInputKeyRepeat(_key)
	/// @desc Internal: return true when a key should repeat for text editing.
	/// @param {Real} _key
	/// @return {Bool}
	static __TextInputKeyRepeat = function(_key) {
		var _key_str = string(_key);
		if (!keyboard_check(_key)) {
			text_key_repeat_next[$ _key_str] = undefined;
			return false;
		}
		if (keyboard_check_pressed(_key)) {
			text_key_repeat_next[$ _key_str] = current_time + text_key_repeat_delay_ms;
			return true;
		}
		var _next = text_key_repeat_next[$ _key_str];
		if (is_undefined(_next)) {
			text_key_repeat_next[$ _key_str] = current_time + text_key_repeat_delay_ms;
			return false;
		}
		if (current_time >= _next) {
			text_key_repeat_next[$ _key_str] = current_time + text_key_repeat_rate_ms;
			return true;
		}
		return false;
	};

	/// @ignore
	/// @func __TextInputPushUndo()
	/// @desc Internal: push current state into the undo stack.
	static __TextInputPushUndo = function() {
		if (text_undo_limit <= 0) return;
		var _entry = { text: text_buffer, caret: text_caret_index, anchor: text_selection_anchor };
		array_push(text_undo_stack, _entry);
		var _len = array_length(text_undo_stack);
		if (_len > text_undo_limit) {
			array_delete(text_undo_stack, 0, _len - text_undo_limit);
		}
		text_redo_stack = [];
	};

	/// @ignore
	/// @func __TextInputUndo()
	/// @desc Internal: restore the previous undo state.
	static __TextInputUndo = function() {
		var _len = array_length(text_undo_stack);
		if (_len <= 0) return;
		var _entry = text_undo_stack[_len - 1];
		array_delete(text_undo_stack, _len - 1, 1);
		var _redo = { text: text_buffer, caret: text_caret_index, anchor: text_selection_anchor };
		array_push(text_redo_stack, _redo);
		if (is_struct(_entry)) {
			text_buffer = string(_entry[$ "text"]);
			text_caret_index = _entry[$ "caret"] ?? 0;
			text_selection_anchor = _entry[$ "anchor"] ?? -1;
			__TextInputClampIndices();
			__TextInputResetCaretBlink();
			if (!is_callable(text_source)) {
				keyboard_string = text_buffer;
			}
			__TextInputMarkEdited(text_input_config);
		}
	};

	/// @ignore
	/// @func __TextInputRedo()
	/// @desc Internal: restore the next redo state.
	static __TextInputRedo = function() {
		var _len = array_length(text_redo_stack);
		if (_len <= 0) return;
		var _entry = text_redo_stack[_len - 1];
		array_delete(text_redo_stack, _len - 1, 1);
		var _undo = { text: text_buffer, caret: text_caret_index, anchor: text_selection_anchor };
		array_push(text_undo_stack, _undo);
		if (is_struct(_entry)) {
			text_buffer = string(_entry[$ "text"]);
			text_caret_index = _entry[$ "caret"] ?? 0;
			text_selection_anchor = _entry[$ "anchor"] ?? -1;
			__TextInputClampIndices();
			__TextInputResetCaretBlink();
			if (!is_callable(text_source)) {
				keyboard_string = text_buffer;
			}
			__TextInputMarkEdited(text_input_config);
		}
	};

	/// @ignore
	/// @func __TextInputReplaceRange(_start, _end, _insert)
	/// @desc Internal: replace a range with new text.
	/// @param {Real} _start
	/// @param {Real} _end
	/// @param {String} _insert
	/// @return {Bool}
	static __TextInputReplaceRange = function(_start, _end, _insert) {
		var _text = text_buffer;
		var _len = string_length(_text);
		var _s = clamp(_start, 0, _len);
		var _e = clamp(_end, 0, _len);
		if (_e < _s) {
			var _tmp = _s;
			_s = _e;
			_e = _tmp;
		}
		var _before = (_s > 0) ? string_copy(_text, 1, _s) : "";
		var _after = (_e < _len) ? string_copy(_text, _e + 1, _len - _e) : "";
		var _next = _before + string(_insert) + _after;
		if (_next == _text) {
			text_caret_index = _s + string_length(_insert);
			__TextInputClearSelection();
			return false;
		}
		__TextInputPushUndo();
		text_buffer = _next;
		text_caret_index = _s + string_length(_insert);
		text_selection_anchor = -1;
		__TextInputResetCaretBlink();
		if (!is_callable(text_source)) {
			keyboard_string = text_buffer;
		}
		__TextInputMarkEdited(text_input_config);
		return true;
	};

	/// @ignore
	/// @func __TextInputFilterInsert(_insert, _range, _config)
	/// @desc Internal: filter inserted text through constraints.
	/// @param {String} _insert
	/// @param {Struct} _range
	/// @param {Struct} _config
	/// @return {String}
	static __TextInputFilterInsert = function(_insert, _range, _config) {
		var _raw = string(_insert);
		if (!is_struct(_range)) return _raw;

		var _transforms = is_struct(_config) ? _config[$ "transformers"] : undefined;
		if (is_array(_transforms)) {
			var _tlen = array_length(_transforms);
			for (var _ti = 0; _ti < _tlen; _ti++) {
				var _transform = _transforms[_ti];
				if (!is_callable(_transform)) {
					continue;
				}
				_raw = string(_transform(_raw));
			}
		}
		if (is_struct(_config)) {
			if (_config[$ "auto_trim"] == true) {
				_raw = string_trim(_raw);
			}
			if (_config[$ "auto_upper"] == true && _config[$ "auto_lower"] != true) {
				_raw = string_upper(_raw);
			}
			else if (_config[$ "auto_lower"] == true) {
				_raw = string_lower(_raw);
			}
		}

		var _filter_fn = is_struct(_config) ? _config[$ "filter_fn"] : undefined;
		if (is_callable(_filter_fn)) {
			_raw = string(_filter_fn(_raw));
		}
		if (string_length(_raw) <= 0) return "";

		var _multiline = is_struct(_config) ? (_config[$ "multiline"] == true) : false;
		if (_multiline) {
			_raw = string_replace_all(_raw, "\r\n", "\n");
			_raw = string_replace_all(_raw, "\r", "\n");
		}

		var _allow = is_struct(_config) ? string(_config[$ "allow_chars"] ?? "") : "";
		var _deny = is_struct(_config) ? string(_config[$ "deny_chars"] ?? "") : "";
		var _numeric = is_struct(_config) ? (_config[$ "numeric_only"] == true) : false;
		var _allow_decimal = is_struct(_config) ? (_config[$ "numeric_allow_decimal"] == true) : false;
		var _allow_negative = is_struct(_config) ? (_config[$ "numeric_allow_negative"] == true) : false;
		var _mode = is_struct(_config) ? (_config[$ "input_mode"] ?? ECHO_TEXTMODE_TEXT) : ECHO_TEXTMODE_TEXT;

		var _base_text = text_buffer;
		var _base_len = string_length(_base_text);
		var _sel_len = _range._end - _range.start;
		var _head = (_range.start > 0) ? string_copy(_base_text, 1, _range.start) : "";
		var _tail = (_range._end < _base_len) ? string_copy(_base_text, _range._end + 1, _base_len - _range._end) : "";
		var _base = _head + _tail;
		var _has_decimal = (string_pos(".", _base) > 0);
		var _has_minus = (string_pos("-", _base) > 0);

		var _out = "";
		var _raw_len = string_length(_raw);
		for (var _i = 1; _i <= _raw_len; _i++) {
			var _ch = string_char_at(_raw, _i);

			if (!_multiline) {
				if (_ch == "\r" || _ch == "\n") continue;

				// Tabs are optional in single-line (default off).
				if (_ch == "\t") {
					var _tab_ok = is_struct(_config) ? (_config[$ "tab_inserts"] == true) : false;
					if (_tab_ok) {
						var _spaces = is_struct(_config) ? (_config[$ "tab_use_spaces"] == true) : false;
						if (_spaces) {
							var _count = is_struct(_config) ? (_config[$ "tab_spaces"] ?? 4) : 4;
							_count = max(0, floor(_count));
							if (_count > 0) _out += string_repeat(" ", _count);
						}
						else {
							_out += _ch;
						}
					}
					continue;
				}
			}
			else {
				// Preserve newline as a structural character (do not filter it through allow/deny/numeric).
				if (_ch == "\n") {
					_out += _ch;
					continue;
				}

				// Tabs are optional in multiline (default off).
				if (_ch == "\t") {
					var _tab_ok2 = is_struct(_config) ? (_config[$ "tab_inserts"] == true) : false;
					if (_tab_ok2) {
						var _spaces2 = is_struct(_config) ? (_config[$ "tab_use_spaces"] == true) : false;
						if (_spaces2) {
							var _count2 = is_struct(_config) ? (_config[$ "tab_spaces"] ?? 4) : 4;
							_count2 = max(0, floor(_count2));
							if (_count2 > 0) _out += string_repeat(" ", _count2);
						}
						else {
							_out += _ch;
						}
					}
					continue;
				}

				// CR is normalized earlier, but ignore defensively.
				if (_ch == "\r") continue;
			}

			// Mode layer (built-in).
			if (_mode == ECHO_TEXTMODE_IDENTIFIER) {
				var _code2 = ord(_ch);
				var _ok = false;
				if (_ch == "_") {
					_ok = true;
				}
				else if (_code2 >= 48 && _code2 <= 57) {
					var _leading = (_range.start <= 0 && string_length(_out) <= 0);
					_ok = !_leading;
				}
				else if ((_code2 >= 65 && _code2 <= 90) || (_code2 >= 97 && _code2 <= 122)) {
					_ok = true;
				}
				if (!_ok) continue;
			}
			else if (_mode == ECHO_TEXTMODE_PATH) {
				var _code2 = ord(_ch);
				var _ok = false;
				if (_ch == " " || _ch == "_" || _ch == "/" || _ch == "\\" || _ch == ":" || _ch == "-" || _ch == ".") {
					_ok = true;
				}
				else if (_code2 >= 48 && _code2 <= 57) {
					_ok = true;
				}
				else if ((_code2 >= 65 && _code2 <= 90) || (_code2 >= 97 && _code2 <= 122)) {
					_ok = true;
				}
				if (!_ok) continue;
			}

			if (string_length(_allow) > 0 && string_pos(_ch, _allow) <= 0) continue;
			if (string_length(_deny) > 0 && string_pos(_ch, _deny) > 0) continue;

			if (_numeric) {
				if (_ch == ".") {
					if (!_allow_decimal || _has_decimal) continue;
					_has_decimal = true;
				}
				else if (_ch == "-") {
					if (!_allow_negative) continue;
					if (string_length(_out) > 0) continue;
					if (_range.start > 0) continue;
					if (_has_minus) continue;
					_has_minus = true;
				}
				else {
					var _code = ord(_ch);
					if (_code < 48 || _code > 57) continue;
				}
			}

			_out += _ch;
		}

		var _max_len = is_struct(_config) ? (_config[$ "max_length"] ?? 0) : 0;
		if (is_real(_max_len) && _max_len > 0) {
			var _base_len2 = _base_len - _sel_len;
			var _room = _max_len - _base_len2;
			if (_room <= 0) return "";
			if (string_length(_out) > _room) {
				_out = string_copy(_out, 1, _room);
			}
		}

		return _out;
	};

	/// @ignore
	/// @func __TextInputInsertText(_insert, _config)
	/// @desc Internal: insert filtered text at the caret/selection.
	/// @param {String} _insert
	/// @param {Struct} _config
	/// @return {Bool}
	static __TextInputInsertText = function(_insert, _config) {
		var _range = __TextInputGetSelectionRange();
		var _filtered = __TextInputFilterInsert(_insert, _range, _config);
		if (string_length(_filtered) <= 0) return false;
		return __TextInputReplaceRange(_range.start, _range._end, _filtered);
	};

	/// @ignore
	/// @func __TextInputDeleteSelection()
	/// @desc Internal: delete the active selection.
	/// @return {Bool}
	static __TextInputDeleteSelection = function() {
		if (!__TextInputHasSelection()) return false;
		var _range = __TextInputGetSelectionRange();
		return __TextInputReplaceRange(_range.start, _range._end, "");
	};

	/// @ignore
	/// @func __TextInputDeleteChar(_dir)
	/// @desc Internal: delete a single character (dir -1 backspace, dir 1 delete).
	/// @param {Real} _dir
	/// @return {Bool}
	static __TextInputDeleteChar = function(_dir) {
		var _len = string_length(text_buffer);
		if (_dir < 0) {
			if (text_caret_index <= 0) return false;
			return __TextInputReplaceRange(text_caret_index - 1, text_caret_index, "");
		}
		if (text_caret_index >= _len) return false;
		return __TextInputReplaceRange(text_caret_index, text_caret_index + 1, "");
	};

	/// @ignore
	/// @func __TextInputDeleteWord(_dir)
	/// @desc Internal: delete a word to the left/right of the caret.
	/// @param {Real} _dir
	/// @return {Bool}
	static __TextInputDeleteWord = function(_dir) {
		if (_dir < 0) {
			var _start = __TextInputFindWordStart(text_buffer, text_caret_index);
			return __TextInputReplaceRange(_start, text_caret_index, "");
		}
		var _end = __TextInputFindWordEnd(text_buffer, text_caret_index);
		return __TextInputReplaceRange(text_caret_index, _end, "");
	};

	/// @ignore
	/// @func __TextInputMoveCaret(_delta, _extend_selection)
	/// @desc Internal: move caret by a delta.
	/// @param {Real} _delta
	/// @param {Bool} _extend_selection
	static __TextInputMoveCaret = function(_delta, _extend_selection) {
		__TextInputSetCaret(text_caret_index + _delta, _extend_selection);
	};

	/// @ignore
	/// @func __TextInputMoveCaretWord(_dir, _extend_selection)
	/// @desc Internal: move caret by word.
	/// @param {Real} _dir
	/// @param {Bool} _extend_selection
	static __TextInputMoveCaretWord = function(_dir, _extend_selection) {
		var _next = text_caret_index;
		if (_dir < 0) {
			_next = __TextInputFindWordStart(text_buffer, text_caret_index);
		}
		else {
			_next = __TextInputFindWordEnd(text_buffer, text_caret_index);
		}
		__TextInputSetCaret(_next, _extend_selection);
	};

	/// @ignore
	/// @func __TextInputBumpGen()
	/// @desc Internal: bump the edit generation counter and invalidate cached layout.
	static __TextInputBumpGen = function() {
		text_edit_gen += 1;
		text_layout_cache = undefined;
		text_layout_cache_id = undefined;
		text_layout_cache_gen = -1;
		text_layout_cache_wrap = false;
		text_layout_cache_view_w = 0;
		text_layout_cache_font = undefined;
		text_layout_cache_password_mask = false;
		text_layout_cache_password_char = "*";
		text_layout_cache_tab_spaces = 4;
	};

	/// @ignore
	/// @func __TextInputMarkEdited(_config)
	/// @desc Internal: mark the active buffer as edited (gen bump + live change scheduling).
	/// @param {Struct} _config
	static __TextInputMarkEdited = function(_config) {
		__TextInputBumpGen();

		// Preferred column should track the caret after edits (typing/cut/paste/undo/redo).
		__TextAreaUpdatePreferredXFromCaret(_config);

		// Auto-scroll to caret for multiline editors.
		__TextAreaEnsureCaretVisible(_config);

		// Live change callback (optional, throttled).
		var _fn = is_struct(_config) ? _config[$ "on_live_change"] : undefined;
		if (!is_callable(_fn)) {
			return;
		}
		var _rate = is_struct(_config) ? (_config[$ "live_change_rate_ms"] ?? 0) : 0;
		if (!is_real(_rate)) _rate = 0;
		_rate = max(0, _rate);

		if (_rate <= 0) {
			_fn(string(GetActiveText()));
			text_live_dirty = false;
			text_live_next_at = 0;
		}
		else {
			text_live_dirty = true;
			if (text_live_next_at <= 0 || current_time >= text_live_next_at) {
				text_live_next_at = current_time + _rate;
			}
		}
	};

	/// @ignore
	/// @func __TextInputPumpLiveChange(_config)
	/// @desc Internal: deliver a pending live change callback when throttled.
	/// @param {Struct} _config
	static __TextInputPumpLiveChange = function(_config) {
		if (!text_live_dirty) {
			return;
		}
		var _fn = is_struct(_config) ? _config[$ "on_live_change"] : undefined;
		if (!is_callable(_fn)) {
			text_live_dirty = false;
			text_live_next_at = 0;
			return;
		}
		var _rate = is_struct(_config) ? (_config[$ "live_change_rate_ms"] ?? 0) : 0;
		if (!is_real(_rate)) _rate = 0;
		_rate = max(0, _rate);
		if (_rate <= 0) {
			_fn(string(GetActiveText()));
			text_live_dirty = false;
			text_live_next_at = 0;
			return;
		}
		if (text_live_next_at > 0 && current_time < text_live_next_at) {
			return;
		}
		_fn(string(GetActiveText()));
		text_live_dirty = false;
		text_live_next_at = current_time + _rate;
	};

	/// @ignore
	/// @func __TextInputCopySelection()
	/// @desc Internal: copy selection to clipboard.
	static __TextInputCopySelection = function() {
		if (is_struct(text_input_config) && text_input_config[$ "password_mask"] == true && text_input_config[$ "password_allow_copy"] != true) {
			return;
		}
		var _sel = __TextInputGetSelectedText();
		if (string_length(_sel) <= 0) return;
		clipboard_set_text(_sel);
	};

	/// @ignore
	/// @func __TextInputCutSelection()
	/// @desc Internal: cut selection to clipboard.
	static __TextInputCutSelection = function() {
		if (is_struct(text_input_config) && text_input_config[$ "password_mask"] == true && text_input_config[$ "password_allow_copy"] != true) {
			return;
		}
		if (!__TextInputHasSelection()) return;
		__TextInputCopySelection();
		__TextInputDeleteSelection();
	};

	/// @ignore
	/// @func __TextInputPasteClipboard(_config)
	/// @desc Internal: paste clipboard text at the caret.
	/// @param {Struct} _config
	static __TextInputPasteClipboard = function(_config) {
		var _clip = clipboard_get_text();
		if (is_undefined(_clip)) return;
		__TextInputInsertText(string(_clip), _config);
	};

	/// @ignore
	/// @func __TextInputGetTabToken(_config)
	/// @desc Internal: resolve the tab insertion token (tab or spaces).
	/// @param {Struct} _config
	/// @return {String}
	static __TextInputGetTabToken = function(_config) {
		var _spaces = is_struct(_config) ? (_config[$ "tab_use_spaces"] == true) : false;
		if (_spaces) {
			var _count = is_struct(_config) ? (_config[$ "tab_spaces"] ?? 4) : 4;
			_count = max(0, floor(_count));
			if (_count <= 0) return "";
			return string_repeat(" ", _count);
		}
		return "\t";
	};

	/// @ignore
	/// @func __TextInputGetVisualTabToken(_config)
	/// @desc Internal: resolve visual tab width as N spaces (always spaces).
	/// @param {Struct} _config
	/// @return {String}
	static __TextInputGetVisualTabToken = function(_config) {
		var _count = is_struct(_config) ? (_config[$ "tab_spaces"] ?? 4) : 4;
		_count = max(1, floor(_count));
		return string_repeat(" ", _count);
	};

	/// @ignore
	/// @func __TextInputExpandTabsVisual(_text, _config)
	/// @desc Internal: replace literal tabs with visual spaces for drawing only.
	/// @param {String} _text
	/// @param {Struct} _config
	/// @return {String}
	static __TextInputExpandTabsVisual = function(_text, _config) {
		var _s = string(_text);
		if (string_pos("\t", _s) <= 0) {
			return _s;
		}
		return string_replace_all(_s, "\t", __TextInputGetVisualTabToken(_config));
	};

	/// @ignore
	/// @func __TextInputMeasureVisualWidth(_text, _font, _config)
	/// @desc Internal: measure text width where tabs use tab_spaces visual width.
	/// @param {String} _text
	/// @param {Asset.GMFont} _font
	/// @param {Struct} _config
	/// @return {Real}
	static __TextInputMeasureVisualWidth = function(_text, _font, _config) {
		var _s = string(_text);
		if (string_length(_s) <= 0) {
			return 0;
		}

		var _old_font = draw_get_font();
		draw_set_font(_font);

		var _tab_w = 0;
		if (string_pos("\t", _s) > 0) {
			_tab_w = string_width(__TextInputGetVisualTabToken(_config));
		}

		var _w = 0;
		var _n = string_length(_s);
		for (var i = 1; i <= _n; i++) {
			var _ch = string_char_at(_s, i);
			if (_ch == "\t") {
				_w += _tab_w;
			}
			else {
				_w += string_width(_ch);
			}
		}

		draw_set_font(_old_font);
		return _w;
	};

	/// @ignore
	/// @func __TextAreaFindLogicalLineStart(_text, _pos)
	/// @desc Internal: find the logical line start (0-based) for a caret position.
	/// @param {String} _text
	/// @param {Real} _pos
	/// @return {Real}
	static __TextAreaFindLogicalLineStart = function(_text, _pos) {
		var _s = string(_text);
		var _len = string_length(_s);
		var _i = clamp(floor(_pos), 0, _len);
		while (_i > 0) {
			if (string_char_at(_s, _i) == "\n") {
				break;
			}
			_i -= 1;
		}
		return _i;
	};

	/// @ignore
	/// @func __TextAreaFindLogicalLineEnd(_text, _pos)
	/// @desc Internal: find the logical line end (0-based, exclusive) for a caret position.
	/// @param {String} _text
	/// @param {Real} _pos
	/// @return {Real}
	static __TextAreaFindLogicalLineEnd = function(_text, _pos) {
		var _s = string(_text);
		var _len = string_length(_s);
		var _i = clamp(floor(_pos), 0, _len);
		while (_i < _len) {
			if (string_char_at(_s, _i + 1) == "\n") {
				break;
			}
			_i += 1;
		}
		return _i;
	};

	/// @ignore
	/// @func __TextInputApplyEdit(_next_text, _next_caret, _next_anchor)
	/// @desc Internal: apply a text edit as a single undo step.
	/// @param {String} _next_text
	/// @param {Real} _next_caret
	/// @param {Real} _next_anchor
	/// @return {Bool}
	static __TextInputApplyEdit = function(_next_text, _next_caret, _next_anchor) {
		var _next = string(_next_text);
		if (_next == text_buffer) {
			return false;
		}
		__TextInputPushUndo();
		text_buffer = _next;
		text_caret_index = _next_caret;
		text_selection_anchor = _next_anchor;
		__TextInputClampIndices();
		__TextInputResetCaretBlink();
		if (!is_callable(text_source)) {
			keyboard_string = text_buffer;
		}
		__TextInputMarkEdited(text_input_config);
		return true;
	};

	/// @ignore
	/// @func __TextAreaInsertTabToken(_config)
	/// @desc Internal: insert the tab token at the caret/selection.
	/// @param {Struct} _config
	/// @return {Bool}
	static __TextAreaInsertTabToken = function(_config) {
		var _token = __TextInputGetTabToken(_config);
		if (string_length(_token) <= 0) return false;
		return __TextInputInsertText(_token, _config);
	};

	/// @ignore
	/// @func __TextAreaIndentSelection(_config)
	/// @desc Internal: indent selection or current line (CODE mode).
	/// @param {Struct} _config
	/// @return {Bool}
	static __TextAreaIndentSelection = function(_config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			return __TextAreaInsertTabToken(_config);
		}

		var _token = __TextInputGetTabToken(_config);
		var _tok_len = string_length(_token);
		if (_tok_len <= 0) return false;

		var _text = text_buffer;
		var _len = string_length(_text);

		var _caret = text_caret_index;
		var _anchor = text_selection_anchor;

		var _starts = [];

		if (__TextInputHasSelection()) {
			var _range = __TextInputGetSelectionRange();
			var _end_for_lines = _range._end;
			if (_end_for_lines > 0 && string_char_at(_text, _end_for_lines) == "\n") {
				_end_for_lines = max(0, _end_for_lines - 1);
			}

			var _pos = __TextAreaFindLogicalLineStart(_text, _range.start);
			while (_pos <= _end_for_lines) {
				array_push(_starts, _pos);

				var _found = false;
				for (var i = _pos; i < _len; i++) {
					if (string_char_at(_text, i + 1) == "\n") {
						_pos = i + 1;
						_found = true;
						break;
					}
				}
				if (!_found) break;
			}
		}
		else {
			array_push(_starts, __TextAreaFindLogicalLineStart(_text, _caret));
		}

		var _n = array_length(_starts);
		if (_n <= 0) return false;

		var _next = _text;
		for (var _i = _n - 1; _i >= 0; _i--) {
			var _at = _starts[_i];
			_at = clamp(_at, 0, string_length(_next));
			var _before = (_at > 0) ? string_copy(_next, 1, _at) : "";
			var _after = string_copy(_next, _at + 1, string_length(_next) - _at);
			_next = _before + _token + _after;

			if (_caret >= _at) _caret += _tok_len;
			if (_anchor >= 0 && _anchor >= _at) _anchor += _tok_len;
		}

		return __TextInputApplyEdit(_next, _caret, _anchor);
	};

	/// @ignore
	/// @func __TextAreaOutdentSelection(_config)
	/// @desc Internal: outdent selection or current line (CODE mode).
	/// @param {Struct} _config
	/// @return {Bool}
	static __TextAreaOutdentSelection = function(_config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			return false;
		}

		var _text = text_buffer;
		var _len = string_length(_text);
		if (_len <= 0) return false;

		var _tab_spaces = is_struct(_config) ? (_config[$ "tab_spaces"] ?? 4) : 4;
		_tab_spaces = max(0, floor(_tab_spaces));

		var _caret = text_caret_index;
		var _anchor = text_selection_anchor;

		var _starts = [];

		if (__TextInputHasSelection()) {
			var _range = __TextInputGetSelectionRange();
			var _end_for_lines = _range._end;
			if (_end_for_lines > 0 && string_char_at(_text, _end_for_lines) == "\n") {
				_end_for_lines = max(0, _end_for_lines - 1);
			}

			var _pos = __TextAreaFindLogicalLineStart(_text, _range.start);
			while (_pos <= _end_for_lines) {
				array_push(_starts, _pos);

				var _found = false;
				for (var i = _pos; i < _len; i++) {
					if (string_char_at(_text, i + 1) == "\n") {
						_pos = i + 1;
						_found = true;
						break;
					}
				}
				if (!_found) break;
			}
		}
		else {
			array_push(_starts, __TextAreaFindLogicalLineStart(_text, _caret));
		}

		var _n = array_length(_starts);
		if (_n <= 0) return false;

		var _next = _text;
		var _changed = false;

		for (var _i = _n - 1; _i >= 0; _i--) {
			var _at = clamp(_starts[_i], 0, string_length(_next));
			if (_at >= string_length(_next)) continue;

			var _rem = 0;
			var _ch = string_char_at(_next, _at + 1);
			if (_ch == "\t") {
				_rem = 1;
			}
			else if (_ch == " " && _tab_spaces > 0) {
				while (_rem < _tab_spaces && (_at + _rem) < string_length(_next) && string_char_at(_next, _at + _rem + 1) == " ") {
					_rem += 1;
				}
			}

			if (_rem <= 0) continue;

			var _before = (_at > 0) ? string_copy(_next, 1, _at) : "";
			var _after = string_copy(_next, _at + _rem + 1, string_length(_next) - (_at + _rem));
			_next = _before + _after;
			_changed = true;

			if (_caret > _at) {
				if (_caret >= _at + _rem) _caret -= _rem;
				else _caret = _at;
			}
			if (_anchor >= 0 && _anchor > _at) {
				if (_anchor >= _at + _rem) _anchor -= _rem;
				else _anchor = _at;
			}
		}

		if (!_changed) return false;
		return __TextInputApplyEdit(_next, _caret, _anchor);
	};

	/// @ignore
	/// @func __TextAreaInsertAutoIndentNewline(_config)
	/// @desc Internal: insert a newline (and optional auto-indent) for multiline editors.
	/// @param {Struct} _config
	/// @return {Bool}
	static __TextAreaInsertAutoIndentNewline = function(_config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			return false;
		}

		var _mode = _config[$ "input_mode"] ?? ECHO_TEXTMODE_TEXT;
		if (_mode != ECHO_TEXTMODE_CODE || _config[$ "auto_indent"] != true) {
			return __TextInputInsertText("\n", _config);
		}

		var _token = __TextInputGetTabToken(_config);
		var _text = text_buffer;
		var _caret = text_caret_index;

		var _ls = __TextAreaFindLogicalLineStart(_text, _caret);
		var _le = __TextAreaFindLogicalLineEnd(_text, _caret);
		var _line = (_le > _ls) ? string_copy(_text, _ls + 1, _le - _ls) : "";
		var _line_before = (_caret > _ls) ? string_copy(_text, _ls + 1, _caret - _ls) : "";
		var _line_scan = _line_before;
		if (string_length(_line_scan) <= 0) {
			_line_scan = _line;
		}

		// Gather indentation prefix (spaces/tabs) from text before caret.
		var _indent = "";
		var _ln = string_length(_line_scan);
		var _has_non_ws = false;
		for (var i = 1; i <= _ln; i++) {
			var _ch = string_char_at(_line_scan, i);
			if (_ch == " " || _ch == "\t") {
				_indent += _ch;
			}
			else {
				_has_non_ws = true;
				break;
			}
		}
		if (!_has_non_ws) {
			_indent = "";
		}

		// Optional extra indent if the current line ends with "{" (ignoring whitespace).
		var _extra_token = _token;
		if (string_pos("\t", _indent) > 0) {
			_extra_token = "\t";
		}

		var _extra = "";
		if (_has_non_ws) {
			for (var k = _ln; k >= 1; k--) {
				var _c3 = string_char_at(_line_scan, k);
				if (_c3 == " " || _c3 == "\t") {
					continue;
				}
				if (_c3 == "{") {
					_extra = _extra_token;
				}
				break;
			}
		}

		return __TextInputInsertText("\n" + _indent + _extra, _config);
	};

	/// @ignore
	/// @func __TextInputRegisterClick(_id, _index)
	/// @desc Internal: register a text click and return the click count (1/2/3) for this burst.
	/// @param {Any} _id
	/// @param {Real} _index
	/// @return {Real}
	static __TextInputRegisterClick = function(_id, _index) {
		var _id_str = string(_id);
		var _click_count = 1;
		if (text_last_click_id == _id_str && (current_time - text_last_click_time) <= text_double_click_ms) {
			_click_count = text_last_click_count + 1;
			if (_click_count > 3) {
				_click_count = 1;
			}
		}
		text_last_click_time = current_time;
		text_last_click_index = _index;
		text_last_click_id = _id_str;
		text_last_click_count = _click_count;
		return _click_count;
	};

	/// @ignore
	/// @func __TextInputBeginMouseSelection(_index, _shift_down, _click_count)
	/// @desc Internal: start mouse selection tracking.
	/// @param {Real} _index
	/// @param {Bool} _shift_down
	/// @param {Real} _click_count
	static __TextInputBeginMouseSelection = function(_index, _shift_down, _click_count = 1) {
		var _count = max(1, floor(_click_count));
		if (_count >= 3) {
			__TextInputSelectAll();
			text_mouse_select_mode = "all";
			text_mouse_select_base_start = 0;
			text_mouse_select_base_end = string_length(text_buffer);
		}
		else if (_count == 2) {
			var _range = __TextInputGetWordRange(text_buffer, _index);
			text_selection_anchor = _range.start;
			text_caret_index = _range._end;
			__TextInputResetCaretBlink();
			text_mouse_select_mode = "word";
			text_mouse_select_base_start = _range.start;
			text_mouse_select_base_end = _range._end;
		}
		else {
			__TextInputSetCaret(_index, _shift_down);
			if (!_shift_down) {
				text_selection_anchor = text_caret_index;
			}
			text_mouse_select_mode = "char";
			text_mouse_select_base_start = text_selection_anchor;
			if (text_mouse_select_base_start < 0) {
				text_mouse_select_base_start = text_caret_index;
			}
			text_mouse_select_base_end = text_caret_index;
		}
		__TextAreaUpdatePreferredXFromCaret(text_input_config);
		text_mouse_selecting = true;
		text_mouse_select_id = text_focus_id;
	};

	/// @ignore
	/// @func __TextInputUpdateMouseSelection(_index)
	/// @desc Internal: update mouse drag selection.
	/// @param {Real} _index
	static __TextInputUpdateMouseSelection = function(_index) {
		var _len = string_length(text_buffer);
		var _next = clamp(_index, 0, _len);
		var _mode = string_lower(string(text_mouse_select_mode));
		if (_mode == "all") {
			__TextInputResetCaretBlink();
			return;
		}
		if (_mode == "word") {
			var _base_s = text_mouse_select_base_start;
			var _base_e = text_mouse_select_base_end;
			if (_base_s < 0 || _base_e < _base_s) {
				_mode = "char";
			}
			else {
				var _range = __TextInputGetWordRange(text_buffer, _next);
				if (_range.start >= _base_e) {
					text_selection_anchor = _base_s;
					text_caret_index = _range._end;
				}
				else if (_range._end <= _base_s) {
					text_selection_anchor = _base_e;
					text_caret_index = _range.start;
				}
				else {
					text_selection_anchor = _base_s;
					text_caret_index = _base_e;
				}
				__TextInputResetCaretBlink();
				__TextAreaUpdatePreferredXFromCaret(text_input_config);
				return;
			}
		}
		if (text_selection_anchor < 0) {
			text_selection_anchor = text_caret_index;
		}
		text_caret_index = _next;
		__TextInputResetCaretBlink();
		__TextAreaUpdatePreferredXFromCaret(text_input_config);
	};

	/// @ignore
	/// @func __TextAreaBuildLayout(_text, _font, _wrap, _view_w, [_config])
	/// @desc Internal: build a cached visual-line layout for multiline editing.
	/// @param {String} _text
	/// @param {Asset.GMFont} _font
	/// @param {Bool} _wrap
	/// @param {Real} _view_w
	/// @param {Struct} [_config]
	/// @return {Struct}
	static __TextAreaBuildLayout = function(_text, _font, _wrap, _view_w, _config = undefined) {
		var _s = string(_text);
		var _len = string_length(_s);

		var _old = draw_get_font();
		draw_set_font(_font);
		var _line_h = string_height("Ag");

		var _lines = [];
		var _pos = 0;
		var _wrap_on = (_wrap == true) && (_view_w > 0);
		var _tab_w = string_width(__TextInputGetVisualTabToken(_config));

		while (_pos < _len) {
			// Find end of logical line (newline is not included).
			var _logical_end = _pos;
			while (_logical_end < _len) {
				var _ch = string_char_at(_s, _logical_end + 1);
				if (_ch == "\n") {
					break;
				}
				_logical_end++;
			}

			// Wrap the logical segment into visual lines.
			if (_logical_end <= _pos) {
				array_push(_lines, { start: _pos, len: 0, text: "", text_draw: "" });
			}
			else if (!_wrap_on) {
				var _seg_len = _logical_end - _pos;
				var _seg = string_copy(_s, _pos + 1, _seg_len);
				array_push(_lines, { start: _pos, len: _seg_len, text: _seg, text_draw: __TextInputExpandTabsVisual(_seg, _config) });
			}
			else {
				var _seg_pos = _pos;
				while (_seg_pos < _logical_end) {
					var _line_start = _seg_pos;
					var _line_w = 0;
					var _last_break = -1;
					var _i = _seg_pos;

					while (_i < _logical_end) {
						var _ch2 = string_char_at(_s, _i + 1);
						var _cw = (_ch2 == "\t") ? _tab_w : string_width(_ch2);

						if ((_i > _line_start) && (_line_w + _cw > _view_w)) {
							break;
						}

						_line_w += _cw;
						if (_ch2 == " ") {
							_last_break = _i + 1;
						}
						_i++;
					}

					var _break_at = _i;
					if (_break_at <= _line_start) {
						_break_at = _line_start + 1;
					}
					else if (_last_break > _line_start && _last_break < _break_at) {
						_break_at = _last_break;
					}

					var _take = _break_at - _line_start;
					var _seg2 = (_take > 0) ? string_copy(_s, _line_start + 1, _take) : "";
					array_push(_lines, { start: _line_start, len: _take, text: _seg2, text_draw: __TextInputExpandTabsVisual(_seg2, _config) });

					_seg_pos = _break_at;
				}
			}

			// Skip newline if present.
			if (_logical_end < _len && string_char_at(_s, _logical_end + 1) == "\n") {
				_pos = _logical_end + 1;
			}
			else {
				_pos = _logical_end;
			}
		}

		// Ensure a trailing empty line if the buffer ends with a newline.
		if (_len <= 0) {
			array_push(_lines, { start: 0, len: 0, text: "", text_draw: "" });
		}
		else if (string_char_at(_s, _len) == "\n") {
			array_push(_lines, { start: _len, len: 0, text: "", text_draw: "" });
		}

		var _content_h = array_length(_lines) * _line_h;

		draw_set_font(_old);

		return {
			line_h: _line_h,
			lines: _lines,
			content_h: _content_h
		};
	};

	/// @ignore
	/// @func __TextAreaGetActiveLayout(_font, _wrap, _view_w)
	/// @desc Internal: get (or rebuild) the cached active multiline layout.
	/// @param {Asset.GMFont} _font
	/// @param {Bool} _wrap
	/// @param {Real} _view_w
	/// @return {Struct,Undefined}
	static __TextAreaGetActiveLayout = function(_font, _wrap, _view_w) {
		if (is_undefined(text_focus_id)) {
			return undefined;
		}
		var _id = text_focus_id;
		var _gen = text_edit_gen;
		var _wrap2 = (_wrap == true);
		var _vw = max(0, _view_w);

		var _mask_on = false;
		var _mask_char = "*";
		if (is_struct(text_input_config) && text_input_config[$ "password_mask"] == true) {
			_mask_on = true;
			_mask_char = string(text_input_config[$ "password_mask_char"] ?? "*");
			if (string_length(_mask_char) <= 0) _mask_char = "*";
			_mask_char = string_char_at(_mask_char, 1);
		}
		var _tab_spaces = 4;
		if (is_struct(text_input_config)) {
			_tab_spaces = text_input_config[$ "tab_spaces"] ?? 4;
		}
		_tab_spaces = max(1, floor(_tab_spaces));

		var _hit = is_struct(text_layout_cache)
		&& text_layout_cache_id == _id
		&& text_layout_cache_gen == _gen
		&& text_layout_cache_wrap == _wrap2
		&& text_layout_cache_view_w == _vw
		&& text_layout_cache_font == _font
		&& text_layout_cache_password_mask == _mask_on
		&& text_layout_cache_password_char == _mask_char
		&& text_layout_cache_tab_spaces == _tab_spaces;

		if (_hit) {
			return text_layout_cache;
		}

		var _src = _mask_on ? string_repeat(_mask_char, string_length(text_buffer)) : text_buffer;

		var _layout = __TextAreaBuildLayout(_src, _font, _wrap2, _vw, text_input_config);
		text_layout_cache = _layout;
		text_layout_cache_id = _id;
		text_layout_cache_gen = _gen;
		text_layout_cache_wrap = _wrap2;
		text_layout_cache_view_w = _vw;
		text_layout_cache_font = _font;
		text_layout_cache_password_mask = _mask_on;
		text_layout_cache_password_char = _mask_char;
		text_layout_cache_tab_spaces = _tab_spaces;
		return _layout;
	};

	/// @ignore
	/// @func __TextAreaFindLineAtIndex(_layout, _index)
	/// @desc Internal: find the visual line index containing a caret index.
	/// @param {Struct} _layout
	/// @param {Real} _index
	/// @return {Real}
	static __TextAreaFindLineAtIndex = function(_layout, _index) {
		if (!is_struct(_layout)) return 0;
		var _lines = _layout[$ "lines"];
		if (!is_array(_lines)) return 0;
		var _count = array_length(_lines);
		if (_count <= 0) return 0;

		var _idx = _index;
		for (var _i = 0; _i < _count; _i++) {
			var _ln = _lines[_i];
			if (!is_struct(_ln)) continue;
			var _s = _ln[$ "start"] ?? 0;
			var _e = _s + (_ln[$ "len"] ?? 0);
			if (_idx < _s) {
				return max(0, _i - 1);
			}
			if (_idx <= _e) {
				return _i;
			}
		}
		return _count - 1;
	};

	/// @ignore
	/// @func __TextAreaIndexFromPoint(_layout, _font, _local_x, _local_y, [_config])
	/// @desc Internal: convert local X/Y offsets into a caret index for multiline editors.
	/// @param {Struct} _layout
	/// @param {Asset.GMFont} _font
	/// @param {Real} _local_x
	/// @param {Real} _local_y
	/// @param {Struct} [_config]
	/// @return {Real}
	static __TextAreaIndexFromPoint = function(_layout, _font, _local_x, _local_y, _config = undefined) {
		if (!is_struct(_layout)) return 0;
		var _lines = _layout[$ "lines"];
		if (!is_array(_lines)) return 0;
		var _count = array_length(_lines);
		if (_count <= 0) return 0;

		var _line_h = _layout[$ "line_h"] ?? 0;
		if (_line_h <= 0) _line_h = string_height("Ag");
		var _li = floor(max(0, _local_y) / max(1, _line_h));
		_li = clamp(_li, 0, _count - 1);

		var _ln = _lines[_li];
		if (!is_struct(_ln)) return 0;
		var _txt = string(_ln[$ "text"] ?? "");
		var _off = __TextInputIndexFromX(_txt, _font, _local_x, _config);
		return (_ln[$ "start"] ?? 0) + _off;
	};

	/// @ignore
	/// @func __TextAreaUpdatePreferredXFromCaret(_config)
	/// @desc Internal: update preferred X (column) tracking from the current caret position.
	/// @param {Struct} _config
	static __TextAreaUpdatePreferredXFromCaret = function(_config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			text_preferred_x = 0;
			text_preferred_x_valid = false;
			return;
		}

		var _font = _config[$ "font"] ?? theme.font_body;
		var _wrap = (_config[$ "wrap"] ?? true);
		var _view_w = _config[$ "view_w"] ?? 0;
		var _layout = __TextAreaGetActiveLayout(_font, _wrap, _view_w);
		if (!is_struct(_layout)) {
			text_preferred_x = 0;
			text_preferred_x_valid = false;
			return;
		}

		var _li = __TextAreaFindLineAtIndex(_layout, text_caret_index);
		var _lines = _layout.lines;
		if (!is_array(_lines) || _li < 0 || _li >= array_length(_lines)) {
			text_preferred_x = 0;
			text_preferred_x_valid = false;
			return;
		}
		var _ln = _lines[_li];
		var _s = _ln.start;
		var _local_i = clamp(text_caret_index - _s, 0, _ln.len);
		var _prefix = (_local_i > 0) ? string_copy(_ln.text, 1, _local_i) : "";
		text_preferred_x = (_local_i > 0) ? __TextInputMeasureVisualWidth(_prefix, _font, _config) : 0;
		text_preferred_x_valid = true;
	};

	/// @ignore
	/// @func __TextAreaGetScrollY(_config)
	/// @param {Struct} _config
	/// @return {Real}
	static __TextAreaGetScrollY = function(_config) {
		var _st = is_struct(_config) ? _config[$ "scroll_state"] : undefined;
		if (is_instanceof(_st, EchoChamberScrollState)) {
			return _st.scroll_y;
		}
		return text_scroll_y;
	};

	/// @ignore
	/// @func __TextAreaSetScrollY(_config, _y)
	/// @param {Struct} _config
	/// @param {Real} _y
	static __TextAreaSetScrollY = function(_config, _y) {
		var _st = is_struct(_config) ? _config[$ "scroll_state"] : undefined;
		if (is_instanceof(_st, EchoChamberScrollState)) {
			_st.scroll_y = _y;
			return;
		}
		text_scroll_y = _y;
	};

	/// @ignore
	/// @func __TextAreaEnsureCaretVisible(_config)
	/// @desc Internal: auto-scroll multiline editor so the caret stays visible.
	/// @param {Struct} _config
	static __TextAreaEnsureCaretVisible = function(_config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			return;
		}

		var _font = _config[$ "font"] ?? theme.font_body;
		var _wrap = (_config[$ "wrap"] ?? true);
		var _view_w = max(0, _config[$ "view_w"] ?? 0);
		var _view_h = max(0, _config[$ "view_h"] ?? 0);
		if (_view_h <= 0) {
			return;
		}

		var _layout = __TextAreaGetActiveLayout(_font, _wrap, _view_w);
		if (!is_struct(_layout)) {
			return;
		}

		var _lines = _layout.lines;
		var _count = is_array(_lines) ? array_length(_lines) : 0;
		if (_count <= 0) {
			return;
		}

		var _line_h = _layout.line_h;
		var _li = __TextAreaFindLineAtIndex(_layout, text_caret_index);
		_li = clamp(_li, 0, _count - 1);

		var _top = _li * _line_h;
		var _bot = _top + _line_h;

		var _scroll_y = __TextAreaGetScrollY(_config);
		if (_top < _scroll_y) {
			_scroll_y = _top;
		}
		else if (_bot > (_scroll_y + _view_h)) {
			_scroll_y = _bot - _view_h;
		}

		_scroll_y = __ClampScroll(_scroll_y, _layout.content_h, _view_h);
		__TextAreaSetScrollY(_config, _scroll_y);

		// Horizontal scroll only when wrapping is disabled.
		if (_wrap != true && _view_w > 0) {
			var _ln = _lines[_li];
			var _s = _ln.start;
			var _local_i = clamp(text_caret_index - _s, 0, _ln.len);
			var _prefix = (_local_i > 0) ? string_copy(_ln.text, 1, _local_i) : "";
			var _caret_x = (_local_i > 0) ? __TextInputMeasureVisualWidth(_prefix, _font, _config) : 0;
			var _line_w = __TextInputMeasureVisualWidth(_ln.text, _font, _config);

			var _scroll_x = clamp(text_scroll_x, 0, max(0, _line_w - _view_w));
			var _pad = 2;
			if (_caret_x - _scroll_x < _pad) {
				_scroll_x = max(0, _caret_x - _pad);
			}
			else if (_caret_x - _scroll_x > (_view_w - _pad)) {
				_scroll_x = min(max(0, _line_w - _view_w), _caret_x - (_view_w - _pad));
			}
			text_scroll_x = _scroll_x;
		}
		else {
			text_scroll_x = 0;
		}
	};

	/// @ignore
	/// @func __TextAreaMoveCaretVertical(_dir, _extend_selection, _config)
	/// @desc Internal: move caret up/down by one visual line (multiline only).
	/// @param {Real} _dir -1 up, +1 down
	/// @param {Bool} _extend_selection
	/// @param {Struct} _config
	static __TextAreaMoveCaretVertical = function(_dir, _extend_selection, _config) {
		if (!is_struct(_config) || _config[$ "multiline"] != true) {
			return;
		}

		var _font = _config[$ "font"] ?? theme.font_body;
		var _wrap = (_config[$ "wrap"] ?? true);
		var _view_w = _config[$ "view_w"] ?? 0;
		var _layout = __TextAreaGetActiveLayout(_font, _wrap, _view_w);
		if (!is_struct(_layout)) {
			return;
		}

		var _lines = _layout.lines;
		var _count = is_array(_lines) ? array_length(_lines) : 0;
		if (_count <= 0) {
			return;
		}

		if (!text_preferred_x_valid) {
			__TextAreaUpdatePreferredXFromCaret(_config);
		}
		var _px = text_preferred_x_valid ? text_preferred_x : 0;

		var _cur = __TextAreaFindLineAtIndex(_layout, text_caret_index);
		var _next = clamp(_cur + _dir, 0, _count - 1);
		if (_next == _cur) {
			return;
		}

		var _ln = _lines[_next];
		var _off = __TextInputIndexFromX(_ln.text, _font, _px, _config);
		var _idx = _ln.start + _off;

		__TextInputSetCaretEx(_idx, _extend_selection, false);
		__TextAreaEnsureCaretVisible(_config);
	};

	/// @ignore
	/// @func __TextInputEndMouseSelection()
	/// @desc Internal: end mouse drag selection.
	static __TextInputEndMouseSelection = function() {
		text_mouse_selecting = false;
		text_mouse_select_id = undefined;
		text_mouse_select_mode = "char";
		text_mouse_select_base_start = -1;
		text_mouse_select_base_end = -1;
		if (!__TextInputHasSelection()) {
			text_selection_anchor = -1;
		}
	};

	/// @ignore
	/// @func __UpdateActiveTextInput()
	/// @desc Internal: handle keyboard input for the active text input.
	static __UpdateActiveTextInput = function() {
		if (is_undefined(text_focus_id)) return;
		if (is_struct(text_focus_window) && !__IsWindowInputFocused(text_focus_window)) return;

		if (text_mouse_selecting && !mouse_l_down) {
			__TextInputEndMouseSelection();
		}

		var _external_source = is_callable(text_source);
		if (_external_source) {
			var _prev = text_buffer;
			text_buffer = string(text_source());
			if (text_buffer != _prev) {
				__TextInputBumpGen();
			}
			__TextInputClampIndices();
		}

		var _config = text_input_config;
		var _read_only = is_struct(_config) ? (_config[$ "read_only"] == true) : false;
		if (_external_source) {
			_read_only = true;
		}
		if (context_menu_open) {
			return;
		}

		var _ctrl = keyboard_check(vk_control);
		var _shift = keyboard_check(vk_shift);
		var _multiline = is_struct(_config) ? (_config[$ "multiline"] == true) : false;

		if (_ctrl) {
			if (keyboard_check_pressed(ord("A"))) {
				__TextInputSelectAll();
				return;
			}
			if (keyboard_check_pressed(ord("C"))) {
				__TextInputCopySelection();
				return;
			}
			if (keyboard_check_pressed(ord("X")) && !_read_only) {
				__TextInputCutSelection();
				return;
			}
			if (keyboard_check_pressed(ord("V")) && !_read_only) {
				__TextInputPasteClipboard(_config);
				return;
			}
			if (keyboard_check_pressed(ord("Z")) && !_read_only) {
				if (_shift) {
					__TextInputRedo();
				}
				else {
					__TextInputUndo();
				}
				return;
			}
			if (keyboard_check_pressed(ord("Y")) && !_read_only) {
				__TextInputRedo();
				return;
			}
		}

		if (__TextInputKeyRepeat(vk_left)) {
			if (_ctrl) {
				__TextInputMoveCaretWord(-1, _shift);
			}
			else {
				__TextInputMoveCaret(-1, _shift);
			}
		}
		if (__TextInputKeyRepeat(vk_right)) {
			if (_ctrl) {
				__TextInputMoveCaretWord(1, _shift);
			}
			else {
				__TextInputMoveCaret(1, _shift);
			}
		}

		if (_multiline) {
			if (__TextInputKeyRepeat(vk_up)) {
				__TextAreaMoveCaretVertical(-1, _shift, _config);
			}
			if (__TextInputKeyRepeat(vk_down)) {
				__TextAreaMoveCaretVertical(1, _shift, _config);
			}
		}

		if (keyboard_check_pressed(vk_home)) {
			if (_multiline && !_ctrl) {
				var _font = _config[$ "font"] ?? theme.font_body;
				var _wrap = (_config[$ "wrap"] ?? true);
				var _view_w = _config[$ "view_w"] ?? 0;
				var _layout = __TextAreaGetActiveLayout(_font, _wrap, _view_w);
				if (is_struct(_layout) && is_array(_layout.lines)) {
					var _li = __TextAreaFindLineAtIndex(_layout, text_caret_index);
					var _ln = _layout.lines[_li];
					__TextInputSetCaret(_ln.start, _shift);
					__TextAreaEnsureCaretVisible(_config);
				}
				else {
					__TextInputSetCaret(0, _shift);
				}
			}
			else {
				__TextInputSetCaret(0, _shift);
			}
		}
		if (keyboard_check_pressed(vk_end)) {
			if (_multiline && !_ctrl) {
				var _font2 = _config[$ "font"] ?? theme.font_body;
				var _wrap2 = (_config[$ "wrap"] ?? true);
				var _view_w2 = _config[$ "view_w"] ?? 0;
				var _layout2 = __TextAreaGetActiveLayout(_font2, _wrap2, _view_w2);
				if (is_struct(_layout2) && is_array(_layout2.lines)) {
					var _li2 = __TextAreaFindLineAtIndex(_layout2, text_caret_index);
					var _ln2 = _layout2.lines[_li2];
					__TextInputSetCaret(_ln2.start + _ln2.len, _shift);
					__TextAreaEnsureCaretVisible(_config);
				}
				else {
					__TextInputSetCaret(string_length(text_buffer), _shift);
				}
			}
			else {
				__TextInputSetCaret(string_length(text_buffer), _shift);
			}
		}

		if (!_read_only) {
			if (_multiline) {
				if (__TextInputKeyRepeat(vk_enter)) {
					__TextAreaInsertAutoIndentNewline(_config);
				}
			}

			if (is_struct(_config) && _config[$ "tab_inserts"] == true) {
				if (__TextInputKeyRepeat(vk_tab)) {
					var _mode = _config[$ "input_mode"] ?? ECHO_TEXTMODE_TEXT;
					if (_multiline && _mode == ECHO_TEXTMODE_CODE) {
						if (_shift) {
							__TextAreaOutdentSelection(_config);
						}
						else {
							__TextAreaIndentSelection(_config);
						}
					}
					else {
						__TextAreaInsertTabToken(_config);
					}
				}
			}

			if (__TextInputKeyRepeat(vk_backspace)) {
				if (__TextInputHasSelection()) {
					__TextInputDeleteSelection();
				}
				else if (_ctrl) {
					__TextInputDeleteWord(-1);
				}
				else {
					__TextInputDeleteChar(-1);
				}
			}
			if (__TextInputKeyRepeat(vk_delete)) {
				if (__TextInputHasSelection()) {
					__TextInputDeleteSelection();
				}
				else if (_ctrl) {
					__TextInputDeleteWord(1);
				}
				else {
					__TextInputDeleteChar(1);
				}
			}

			var _ch = keyboard_lastchar;
			if (string_length(_ch) > 0 && !_ctrl && !keyboard_check(vk_alt)) {
				var _code = ord(_ch);
				if (_code >= 32) {
					if (_ch != text_last_char) {
						text_last_char = _ch;
						text_last_char_key = keyboard_lastkey;
					}
					var _key = text_last_char_key;
					if (_key > 0 && __TextInputKeyRepeat(_key)) {
						__TextInputInsertText(_ch, _config);
					}
				}
			}
		}

		__TextInputPumpLiveChange(_config);
	};

	/// @func FocusTextInput(_id, _initial_text, _placeholder, [_commit_fn], [_config])
	/// @desc Focus a text input by id and seed its initial content. Optional _commit_fn is called with the final string on blur.
	/// @param {Any} _id
	/// @param {String} _initial_text
	/// @param {String} _placeholder
	/// @param {Function} [_commit_fn]
	/// @param {Struct} [_config]
	static FocusTextInput = function(_id, _initial_text, _placeholder, _commit_fn = undefined, _config = undefined) {
		var _new_id = string(_id);

		// If another text input was active, blur it first (commit).
		if (!is_undefined(text_focus_id) && text_focus_id != _new_id) {
			BlurTextInput(text_focus_id);
		}

		text_focus_id            = _new_id;
		text_buffer              = string(_initial_text);
		text_initial_value       = text_buffer;
		text_placeholder         = string(_placeholder);
		text_commit              = is_callable(_commit_fn) ? _commit_fn : undefined;
		text_submit              = (is_struct(_config) && is_callable(_config[$ "on_submit"])) ? _config[$ "on_submit"] : undefined;
		text_cancel              = (is_struct(_config) && is_callable(_config[$ "on_cancel"])) ? _config[$ "on_cancel"] : undefined;
		text_focus_cb            = (is_struct(_config) && is_callable(_config[$ "on_focus"])) ? _config[$ "on_focus"] : undefined;
		text_blur_cb             = (is_struct(_config) && is_callable(_config[$ "on_blur"])) ? _config[$ "on_blur"] : undefined;
		text_focus_rect_last     = undefined;
		text_focus_window        = is_struct(__current_window) ? __current_window : keyboard_focus_window;
		text_input_config        = is_struct(_config) ? _config : {};
		text_caret_index         = string_length(text_buffer);
		text_selection_anchor    = -1;
		text_scroll_x            = 0;
		text_scroll_y            = 0;
		text_preferred_x         = 0;
		text_preferred_x_valid   = false;
		text_mouse_selecting     = false;
		text_mouse_select_id     = undefined;
		text_mouse_select_mode   = "char";
		text_mouse_select_base_start = -1;
		text_mouse_select_base_end = -1;
		text_key_repeat_next     = {};
		text_last_char           = "";
		text_last_char_key       = 0;
		text_undo_stack          = [];
		text_redo_stack          = [];
		text_edit_gen            = 0;
		text_layout_cache        = undefined;
		text_layout_cache_id     = undefined;
		text_layout_cache_gen    = -1;
		text_layout_cache_wrap   = false;
		text_layout_cache_view_w = 0;
		text_layout_cache_font   = undefined;
		text_layout_cache_password_mask = false;
		text_layout_cache_password_char = "*";
		text_layout_cache_tab_spaces = 4;
		text_live_dirty          = false;
		text_live_next_at        = 0;

		if (is_callable(text_seed)) {
			text_seed(text_buffer);
		}
		else {
			keyboard_string = text_buffer;
		}

		if (is_struct(text_input_config) && text_input_config[$ "select_all_on_focus"] == true) {
			__TextInputSelectAll();
		}
		else {
			__TextInputResetCaretBlink();
		}
		__TextAreaUpdatePreferredXFromCaret(text_input_config);
		if (is_callable(text_focus_cb)) {
			text_focus_cb(string(text_buffer));
		}
	};

	/// @func BlurTextInput(_id)
	/// @desc Blur a focused text input by id. Returns the final string (after syncing from the text source).
	/// @param {Any} _id
	/// @param {Bool} [_cancel]
	/// @return {String}
	static BlurTextInput = function(_id, _cancel = false) {
		if (is_undefined(text_focus_id)) return "";
		if (string(_id) != text_focus_id) return "";

		// Sync out from the active source if provided.
		if (is_callable(text_source)) {
			text_buffer = string(text_source());
		}

		var _final = string(text_buffer);
		var _initial = string(text_initial_value);
		var _was_cancel = (_cancel == true);

		// Clear focus state before committing.
		text_focus_id            = undefined;
		text_placeholder         = "";
		text_initial_value       = "";
		text_focus_rect_last     = undefined;
		text_focus_window        = undefined;
		text_input_config        = undefined;
		text_caret_index         = 0;
		text_selection_anchor    = -1;
		text_scroll_x            = 0;
		text_scroll_y            = 0;
		text_preferred_x         = 0;
		text_preferred_x_valid   = false;
		text_mouse_selecting     = false;
		text_mouse_select_id     = undefined;
		text_mouse_select_mode   = "char";
		text_mouse_select_base_start = -1;
		text_mouse_select_base_end = -1;
		text_key_repeat_next     = {};
		text_last_char           = "";
		text_last_char_key       = 0;
		text_edit_gen            = 0;
		text_layout_cache        = undefined;
		text_layout_cache_id     = undefined;
		text_layout_cache_gen    = -1;
		text_layout_cache_wrap   = false;
		text_layout_cache_view_w = 0;
		text_layout_cache_font   = undefined;
		text_layout_cache_password_mask = false;
		text_layout_cache_password_char = "*";
		text_layout_cache_tab_spaces = 4;
		text_live_dirty          = false;
		text_live_next_at        = 0;

		var _commit = text_commit;
		var _submit = text_submit;
		var _cancel_fn = text_cancel;
		var _blur = text_blur_cb;
		text_commit = undefined;
		text_submit = undefined;
		text_cancel = undefined;
		text_focus_cb = undefined;
		text_blur_cb = undefined;

		if (!_was_cancel && is_callable(_commit)) {
			_commit(_final);
		}
		if (!_was_cancel && is_callable(_submit)) {
			_submit(_final);
		}
		if (_was_cancel && is_callable(_cancel_fn)) {
			_cancel_fn(_final, _initial);
		}
		if (is_callable(_blur)) {
			_blur(_final, _was_cancel);
		}

		return _final;
	};

	/// @func CancelTextInput(_id)
	/// @desc Cancel and blur a focused text input by id. Discards active edits and does not commit.
	/// @param {Any} _id
	/// @return {String}
	static CancelTextInput = function(_id) {
		return BlurTextInput(_id, true);
	};

	/// @func IsActiveTextInput(_id)
	/// @desc Returns true if the given id is the currently focused text input.
	/// @param {Any} _id
	/// @return {Bool}
	static IsActiveTextInput = function(_id) {
		return (!is_undefined(text_focus_id) && text_focus_id == string(_id));
	};

	/// @func GetActiveText()
	/// @desc Return the current active text string while a text input is focused.
	/// @return {String}
	static GetActiveText = function() {
		if (is_callable(text_source)) {
			return string(text_source());
		}
		return string(text_buffer);
	};

	/// @func GetTextBuffer()
	/// @desc Return the last committed text buffer for the active text input.
	/// @return {String}
	static GetTextBuffer = function() {
		return string(text_buffer);
	};

	/// @ignore
	/// @func __SetActiveTextInputRect(_id, _rect)
	/// @desc Internal: store the screen rect for the active text input, used to detect click-outside blur.
	/// @param {Any} _id
	/// @param {Struct} _rect
	static __SetActiveTextInputRect = function(_id, _rect) {
		if (is_undefined(text_focus_id)) return;
		if (string(_id) != text_focus_id) return;
		var _norm = __NormalizeRect(_rect);
		if (is_struct(_norm)) {
			text_focus_rect_last = _norm;
		}
	};

	/// @func FocusControl(_id, _rect)
	/// @desc Give keyboard focus to a non-text control by id. This focus is separate from text input focus.
	/// @param {Any} _id
	/// @param {Struct} _rect {x1,y1,x2,y2}
	static FocusControl = function(_id, _rect) {
		__SetControlFocusDirect(_id, _rect, is_struct(__current_window) ? __current_window : undefined);
	};

	/// @func IsControlFocused(_id)
	/// @desc Returns true if the given control id currently owns keyboard focus (and no text input is active).
	/// @param {Any} _id
	/// @return {Bool}
	static IsControlFocused = function(_id) {
		if (is_undefined(control_focus_id)) return false;
		if (!is_undefined(text_focus_id)) return false;

		var _probe = string(_id);
		if (_probe != control_focus_id) return false;

		// Modal overlay gate: only the overlay owner should receive keys while an overlay is open.
		if (!is_undefined(active_overlay_owner_id) && active_overlay_owner_id != _probe) {
			return false;
		}

		// Window gate: prevent a focused control in one window from reacting while drawing another window.
		if (is_struct(control_focus_window) && is_struct(__current_window) && control_focus_window != __current_window) {
			return false;
		}

		return true;
	};

	/// @func BlurControlFocus(_id)
	/// @desc Blur (clear) keyboard focus from a control by id.
	/// @param {Any} _id
	/// @return {Bool}
	static BlurControlFocus = function(_id) {
		if (is_undefined(control_focus_id)) return false;

		if (!is_undefined(_id) && string(_id) != control_focus_id) {
			return false;
		}

		control_focus_id = undefined;
		control_focus_rect_last = undefined;
		control_focus_window = undefined;
		return true;
	};

	/// @desc Register a focusable control for Tab navigation.
	/// @param {Any} _id
	/// @param {Struct} _rect
	static RegisterFocusable = function(_id, _rect) {
		if (is_undefined(_id)) return;
		if (!is_struct(_rect)) return;
		var _x1 = _rect[$ "x1"];
		var _y1 = _rect[$ "y1"];
		var _x2 = _rect[$ "x2"];
		var _y2 = _rect[$ "y2"];
		if (is_undefined(_x1) || is_undefined(_y1) || is_undefined(_x2) || is_undefined(_y2)) return;

		var _idx = focusable_count;

		if (_idx >= array_length(focusable_ids)) {
			array_push(focusable_ids, string(_id));
			array_push(focusable_windows, is_struct(__current_window) ? __current_window : undefined);
			array_push(focusable_x1, _x1);
			array_push(focusable_y1, _y1);
			array_push(focusable_x2, _x2);
			array_push(focusable_y2, _y2);
		}
		else {
			focusable_ids[_idx] = string(_id);
			focusable_windows[_idx] = is_struct(__current_window) ? __current_window : undefined;
			focusable_x1[_idx] = _x1;
			focusable_y1[_idx] = _y1;
			focusable_x2[_idx] = _x2;
			focusable_y2[_idx] = _y2;
		}

		focusable_count		= _idx + 1;
	};

	/// @ignore
	/// @func __SetControlFocusDirect(_id, _rect, _window)
	/// @desc Internal: set control focus without relying on __current_window.
	/// @param {Any} _id
	/// @param {Struct} _rect
	/// @param {Struct.EchoChamberWindow} _window
	static __SetControlFocusDirect = function(_id, _rect, _window) {
		control_focus_id = is_undefined(_id) ? undefined : string(_id);
		control_focus_window = _window;
		__SetKeyboardFocusWindow(control_focus_window);

		control_focus_rect_last = undefined;
		if (is_struct(_rect)) {
			var _x1 = _rect[$ "x1"];
			var _y1 = _rect[$ "y1"];
			var _x2 = _rect[$ "x2"];
			var _y2 = _rect[$ "y2"];
			if (!is_undefined(_x1) && !is_undefined(_y1) && !is_undefined(_x2) && !is_undefined(_y2)) {
				control_focus_rect_last = { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
			}
		}
	};

	/// @ignore
	/// @func __ProcessTabFocus()
	/// @desc Internal: handle Tab and Shift+Tab focus cycling for this frame.
	static __ProcessTabFocus = function() {
		// If an active text editor opts into Tab insertion, do not steal Tab for focus cycling.
		if (!is_undefined(text_focus_id)) {
			var _cfg = text_input_config;
			if (is_struct(_cfg) && _cfg[$ "tab_inserts"] == true && _cfg[$ "read_only"] != true) {
				return;
			}
		}

		var _tab_next = self.InputPressed(ECHO_UI_ACTION_TAB_NEXT, keyboard_focus_window);
		var _tab_prev = self.InputPressed(ECHO_UI_ACTION_TAB_PREV, keyboard_focus_window);
		if (!_tab_next && !_tab_prev) return;
		if (focusable_count <= 0) return;

		// Do not tab-cycle while a modal overlay is open.
		if (!is_undefined(active_overlay_owner_id)) return;

		var _target_window = is_struct(control_focus_window) ? control_focus_window : (is_struct(keyboard_focus_window) ? keyboard_focus_window : undefined);

		if (is_undefined(_target_window)) {
			// Fallback: topmost window if present.
			var _wlen = array_length(windows);
			if (_wlen > 0) _target_window = windows[_wlen - 1];
		}

		var _cur = is_undefined(control_focus_id) ? "" : string(control_focus_id);
		var _cur_i = -1;
		var _first_i = -1;
		var _last_i = -1;

		for (var _i = 0; _i < focusable_count; _i++) {
			if (!is_undefined(_target_window)) {
				if (focusable_windows[_i] != _target_window) continue;
			}
			else {
				if (!is_undefined(focusable_windows[_i])) continue;
			}

			if (_first_i < 0) _first_i = _i;
			_last_i = _i;

			if (_cur_i < 0 && string(focusable_ids[_i]) == _cur) _cur_i = _i;
		}

		if (_first_i < 0) return;

		var _next_i = -1;
		var _rev = _tab_prev;

		if (_cur_i < 0) {
			_next_i = _rev ? _last_i : _first_i;
		}
		else if (!_rev) {
			for (var _j = _cur_i + 1; _j < focusable_count; _j++) {
				if (!is_undefined(_target_window)) {
					if (focusable_windows[_j] != _target_window) continue;
				}
				else {
					if (!is_undefined(focusable_windows[_j])) continue;
				}
				_next_i = _j;
				break;
			}
			if (_next_i < 0) _next_i = _first_i;
		}
		else {
			for (var _j = _cur_i - 1; _j >= 0; _j--) {
				if (!is_undefined(_target_window)) {
					if (focusable_windows[_j] != _target_window) continue;
				}
				else {
					if (!is_undefined(focusable_windows[_j])) continue;
				}
				_next_i = _j;
				break;
			}
			if (_next_i < 0) _next_i = _last_i;
		}

		if (_next_i < 0) return;

		// Commit and blur any active text input before moving focus.
		if (!is_undefined(text_focus_id)) {
			BlurTextInput(text_focus_id);
		}

		var _rect = {
			x1: focusable_x1[_next_i],
			y1: focusable_y1[_next_i],
			x2: focusable_x2[_next_i],
			y2: focusable_y2[_next_i]
		};

		__SetControlFocusDirect(focusable_ids[_next_i], _rect, focusable_windows[_next_i]);
	};


	/// @ignore
	/// @func __UpdatePanelSplitterDrag()
	/// @desc Internal: update an active panel splitter drag (dock resize) for this frame.
	static __UpdatePanelSplitterDrag = function() {
		if (!panel_split_dragging) return;
		if (!mouse_l_down) {
			panel_split_dragging = false;
			panel_split_drag_panel = undefined;
			return;
		}
		var _p = panel_split_drag_panel;
		if (_p.size_mode != eEchoChamberPanelSizeMode.FIXED) {
			panel_split_dragging = false;
			panel_split_drag_panel = undefined;
			return;
		}
		var _dock = panel_split_drag_dock;
		var _m = ((_dock == eEchoChamberDock.TOP) || (_dock == eEchoChamberDock.BOTTOM)) ? my : mx;
		var _delta = _m - panel_split_drag_start_m;
		var _new_size = panel_split_drag_start_size + (_delta * panel_split_drag_sign);
		var _min = 0;
		var _max = 1048576;
		_min = max(0, _p.min_size);
		_max = max(_min, _p.max_size);
		_new_size = clamp(_new_size, _min, _max);
		_p.SetSize(_new_size);
		ConsumeMouse();
		ConsumeWheel();
	};

	/// @ignore
	/// @func __DrawAndProcessPanelSplitters(_panels, _x1, _y1, _x2, _y2)
	/// @desc Internal: draw and process splitter handles for docked FIXED panels (recurses into container panels).
	/// @param {Array} _panels
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	static __DrawAndProcessPanelSplitters = function(_panels, _x1, _y1, _x2, _y2) {
		if (!is_array(_panels)) return;

		// Do not allow panel resizing while a modal overlay is open.
		if (!is_undefined(active_overlay_owner_id)) return;

		var _hit_sz = max(2, theme[$ "panel_splitter_hit_size"] ?? 6);
		var _draw_sz = max(1, theme[$ "panel_splitter_draw_size"] ?? 2);
		var _hit_half = _hit_sz * 0.5;
		var _draw_half = _draw_sz * 0.5;

		var _len = array_length(_panels);
		for (var _i = 0; _i < _len; _i++) {
			var _p = _panels[_i];

			// Recurse into container panels after handling this panel's own splitter.
			var _is_container = _p.is_container;
			var _has_children = _is_container && is_array(_p.children_panels);

			// Splitters: only for docked FIXED panels, and not while collapsed.
			if (_p.size_mode == eEchoChamberPanelSizeMode.FIXED
			&& _p.dock != eEchoChamberDock.FILL
			&& !_p.collapsed) {

				var _dock = _p.dock;
				var _hx1 = 0;
				var _hy1 = 0;
				var _hx2 = 0;
				var _hy2 = 0;

				switch (_dock) {
					case eEchoChamberDock.TOP:
						_hx1 = _p.rect.x1;
						_hx2 = _p.rect.x2;
						var _by = _p.rect.y2;
						_hy1 = _by - _hit_half;
						_hy2 = _by + _hit_half;
					break;
					case eEchoChamberDock.BOTTOM:
						_hx1 = _p.rect.x1;
						_hx2 = _p.rect.x2;
						var _by2 = _p.rect.y1;
						_hy1 = _by2 - _hit_half;
						_hy2 = _by2 + _hit_half;
					break;
					case eEchoChamberDock.LEFT:
						_hy1 = _p.rect.y1;
						_hy2 = _p.rect.y2;
						var _bx = _p.rect.x2;
						_hx1 = _bx - _hit_half;
						_hx2 = _bx + _hit_half;
					break;
					case eEchoChamberDock.RIGHT:
						_hy1 = _p.rect.y1;
						_hy2 = _p.rect.y2;
						var _bx2 = _p.rect.x1;
						_hx1 = _bx2 - _hit_half;
						_hx2 = _bx2 + _hit_half;
					break;
				}

				// Clamp handle rect to the given bounds.
				if (_hx1 < _x1) _hx1 = _x1;
				if (_hy1 < _y1) _hy1 = _y1;
				if (_hx2 > _x2) _hx2 = _x2;
				if (_hy2 > _y2) _hy2 = _y2;

				var _active = panel_split_dragging && (panel_split_drag_panel == _p);
				var _hover = (!_active && !mouse_consumed) ? HitTestRect(_hx1, _hy1, _hx2, _hy2) : false;

				// Draw (thin) splitter line.
				var _col = theme.col_accent;
				var _alpha = 0.4;
				if (_hover) {
					_col = merge_color(_col, theme.col_text, 0.25);
					_alpha = 0.8;
				}
				else if (_active) {
					_col = merge_color(_col, theme.col_text, 0.35);
					_alpha = 0.9;
				}
				var _old_a = draw_get_alpha();
				draw_set_alpha(_alpha);
				draw_set_color(_col);

				switch (_dock) {
					case eEchoChamberDock.TOP:
					case eEchoChamberDock.BOTTOM:
						var _ly = (_dock == eEchoChamberDock.TOP) ? _p.rect.y2 : _p.rect.y1;
						draw_rectangle(_hx1, _ly - _draw_half, _hx2, _ly + _draw_half, false);
					break;
					case eEchoChamberDock.LEFT:
					case eEchoChamberDock.RIGHT:
						var _lx = (_dock == eEchoChamberDock.LEFT) ? _p.rect.x2 : _p.rect.x1;
						draw_rectangle(_lx - _draw_half, _hy1, _lx + _draw_half, _hy2, false);
					break;
				}
				draw_set_alpha(_old_a);

				if (_hover) {
					RequestTooltip("__panel_split:" + _p.id, "Drag to resize", mx, my);
				}

				// Start drag.
				if (_hover && mouse_l_pressed && !mouse_consumed && !panel_split_dragging) {
					panel_split_dragging = true;
					panel_split_drag_panel = _p;
					panel_split_drag_dock = _dock;
					panel_split_drag_start_size = _p.size;
					panel_split_drag_start_m = ((_dock == eEchoChamberDock.TOP) || (_dock == eEchoChamberDock.BOTTOM)) ? my : mx;
					panel_split_drag_sign = ((_dock == eEchoChamberDock.BOTTOM) || (_dock == eEchoChamberDock.RIGHT)) ? -1 : 1;
					ConsumeMouse();
				}
			}

			// Recurse into container panel content area.
			if (_has_children && !_p.collapsed) {
				var _pad = max(0, _p.padding);
				var _ix1 = _p.rect.x1 + _pad;
				var _iy1 = _p.rect.y1 + _pad;
				var _ix2 = _p.rect.x2 - _pad;
				var _iy2 = _p.rect.y2 - _pad;
				if (_ix2 < _ix1) _ix2 = _ix1;
				if (_iy2 < _iy1) _iy2 = _iy1;

				PushClipRect(_ix1, _iy1, _ix2, _iy2);
				__DrawAndProcessPanelSplitters(_p.children_panels, _ix1, _iy1, _ix2, _iy2);
				PopClipRect();
			}
		}
	};
}

/// @func EchoChamberWindow(_id)
/// @desc Floating debug window that owns a collection of docked panels.
/// @param {Any} _id
/// @return {Struct.EchoChamberWindow}
function EchoChamberWindow(_id) constructor {
	id                = string(_id);
	title             = "";
	visible           = true;
	rect              = { x1: 0, y1: 0, x2: 320, y2: 200 };
	window_style_key  = "_default";
	header_style_key  = "_default";
	chrome_button_style_key = undefined;
	theme_override    = undefined;
	__theme_defaults_applied = false;
	panels            = [];
	owner_root        = undefined;
	input_context_id  = undefined;
	input_context_parent_id = undefined;
	is_dragging       = false;
	is_resizing       = false;
	drag_offset_x     = 0;
	drag_offset_y     = 0;
	resize_start_w    = 0;
	resize_start_h    = 0;
	resize_start_mouse_x = 0;
	resize_start_mouse_y = 0;
	resize_start_x1 = 0;
	resize_start_x2 = 0;
	resize_start_y1 = 0;
	resize_edge_x = 0;
	resize_edge_y = 0;

	// Window chrome buttons
	show_close_button    = true;
	show_minimize_button = true;
	show_pin_button      = false;

	is_minimized   = false;
	restore_height = rect.y2 - rect.y1;
	is_pinned      = false;
	on_close       = undefined;
	on_move        = undefined;
	on_resize      = undefined;
	on_show        = undefined;
	on_hide        = undefined;
	on_focus       = undefined;
	on_blur        = undefined;
	on_minimize    = undefined;
	on_restore     = undefined;
	fit_to_content_on_add = false;
	fit_to_content_pending_root = undefined;
	fit_to_content_pending_respect = true;
	auto_fit = false;
	layout_batch_depth = 0;
	layout_batch_pending_fit = false;
	layout_batch_pending_root = undefined;
	layout_batch_pending_respect = false;
	user_set_rect = false;
	user_set_min  = false;
	user_set_max  = false;
	max_width = 0;
	max_height = 0;
	margin_x = 0;
	margin_y = 0;

	/// @desc Set the window title text.
	/// @param {Any} _title
	/// @return {Struct.EchoChamberWindow}
	static SetTitle = function(_title) {
		title = string(_title);
		return self;
	};

	/// @desc Set the input context id used for this window.
	/// @param {String} _context_id
	/// @param {String} [_parent_id]
	/// @return {Struct.EchoChamberWindow}
	static SetInputContext = function(_context_id, _parent_id = undefined) {
		if (is_undefined(_context_id)) {
			input_context_id = undefined;
			input_context_parent_id = undefined;
			return self;
		}
		input_context_id = string(_context_id);
		input_context_parent_id = is_undefined(_parent_id) ? undefined : string(_parent_id);
		if (is_instanceof(owner_root, EchoChamberRoot)) {
			owner_root.CreateInputContext(input_context_id, input_context_parent_id);
		}
		return self;
	};

	/// @desc Swap the window input context and remove the old context if it is unused.
	/// @param {String} _context_id
	/// @param {String} [_parent_id]
	/// @return {Struct.EchoChamberWindow}
	static SwapInputContext = function(_context_id, _parent_id = undefined) {
		var _old_id = input_context_id;
		SetInputContext(_context_id, _parent_id);
		if (is_instanceof(owner_root, EchoChamberRoot) && !is_undefined(_old_id)) {
			owner_root.RemoveInputContext(_old_id);
		}
		return self;
	};

	/// @desc Set the window style key (for theme.window_styles).
	/// @param {String} _key
	/// @return {Struct.EchoChamberWindow}
	static SetWindowStyleKey = function(_key) {
		window_style_key = string(_key);
		return self;
	};

	/// @desc Set the header style key (for theme.header_styles).
	/// @param {String} _key
	/// @return {Struct.EchoChamberWindow}
	static SetHeaderStyleKey = function(_key) {
		header_style_key = string(_key);
		return self;
	};

	/// @desc Set the chrome button style key (for theme.button_styles).
	/// @param {String} _key
	/// @return {Struct.EchoChamberWindow}
	static SetChromeButtonStyleKey = function(_key) {
		chrome_button_style_key = string(_key);
		return self;
	};

	/// @ignore
	/// @desc Internal: apply theme overrides to a control.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	static __ApplyThemeToControl = function(_root, _ctrl) {
		var _apply = _ctrl[$ "ApplyTheme"];
		if (is_callable(_apply)) {
			_apply(_ctrl, _root);
		}
	};

	/// @ignore
	/// @desc Internal: reset panel theme defaults recursively and apply control theme overrides.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	static __ClearPanelThemeDefaults = function(_root, _panel) {
		_panel.__theme_defaults_applied = false;
		var _controls = _panel[$ "children_controls"];
		if (is_array(_controls)) {
			var _clen = array_length(_controls);
			for (var _ci = 0; _ci < _clen; _ci++) {
				__ApplyThemeToControl(_root, _controls[_ci]);
			}
		}
		var _children = _panel[$ "children_panels"];
		if (is_array(_children)) {
			var _len = array_length(_children);
			for (var _i = 0; _i < _len; _i++) {
				__ClearPanelThemeDefaults(_root, _children[_i]);
			}
		}
	};

	/// @desc Apply a theme override to this window and its children (does not affect other windows).
	/// @param {Struct.EchoChamberTheme} _theme Pass undefined to clear the override.
	/// @return {Struct.EchoChamberWindow}
	static ApplyTheme = function(_theme) {
		if (is_instanceof(_theme, EchoChamberWindow)) {
			return self;
		}
		if (is_undefined(_theme)) {
			return ClearThemeOverride();
		}
		if (!is_instanceof(_theme, EchoChamberTheme)) {
			return self;
		}

		theme_override = _theme;
		__theme_defaults_applied = false;
		var _refresh = _theme[$ "RefreshMetrics"];
		if (is_callable(_refresh)) {
			method(theme_override, _refresh)();
		}

		var _root = owner_root;
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return self;
		}

		var _pushed = _root.__PushWindowTheme(self);
		var _plen = array_length(panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			__ClearPanelThemeDefaults(_root, panels[_pi]);
		}
		_root.__ApplyThemeDefaultsToWindow(self);
		__ApplyThemeDefaultsToPanels(_root);
		if (_pushed) {
			_root.__PopThemeOverride();
		}
		return self;
	};

	/// @desc Clear the theme override for this window and reapply root defaults.
	/// @return {Struct.EchoChamberWindow}
	static ClearThemeOverride = function() {
		theme_override = undefined;
		__theme_defaults_applied = false;

		var _root = owner_root;
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return self;
		}

		var _pushed = _root.__PushWindowTheme(self);
		var _plen = array_length(panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			__ClearPanelThemeDefaults(_root, panels[_pi]);
		}
		_root.__ApplyThemeDefaultsToWindow(self);
		__ApplyThemeDefaultsToPanels(_root);
		if (_pushed) {
			_root.__PopThemeOverride();
		}
		return self;
	};

	/// @desc Set the content padding for this window.
	/// @param {Real} _value
	/// @return {Struct.EchoChamberWindow}
	static SetPadding = function(_value) {
		padding = max(0, _value);
		return self;
	};

	/// @desc Set the outer margin for this window in GUI-space.
	/// @param {Real} _x
	/// @param {Real} [_y]
	/// @return {Struct.EchoChamberWindow}
	static SetMargin = function(_x, _y = undefined) {
		margin_x = max(0, _x);
		margin_y = max(0, _y ?? _x);
		return self;
	};

	/// @desc Set the titlebar height for this window.
	/// @param {Real} _value
	/// @return {Struct.EchoChamberWindow}
	static SetTitlebarHeight = function(_value) {
		titlebar_height = max(0, _value);
		titlebar_auto = false;
		return self;
	};

	/// @desc Set whether the titlebar height is driven by the current theme.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberWindow}
	static SetTitlebarAuto = function(_flag) {
		titlebar_auto = (_flag == true);
		if (titlebar_auto) {
			var _theme = theme_override;
			if (!is_instanceof(_theme, EchoChamberTheme)) {
				var _root = owner_root;
				if (is_instanceof(_root, EchoChamberRoot)) {
					_theme = _root.theme;
				}
			}
			if (is_instanceof(_theme, EchoChamberTheme)) {
				titlebar_height = _theme.window_titlebar_h;
			}
		}
		return self;
	};

	/// @desc Set the resize grip size for this window.
	/// @param {Real} _value
	/// @return {Struct.EchoChamberWindow}
	static SetResizeGripSize = function(_value) {
		resize_grip_size = max(0, _value);
		return self;
	};


	/// @desc Show or hide this window.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberWindow}
	static SetVisible = function(_flag) {
		var _want = (_flag == true);
		if (_want == visible) {
			return self;
		}
		visible = _want;
		if (!_want && is_instanceof(owner_root, EchoChamberRoot)) {
			if (owner_root.modal_window == self) {
				owner_root.ClearModalWindow();
			}
			if (owner_root.mouse_capture_window == self) {
				owner_root.ClearMouseCapture(self);
			}
			if (owner_root.active_overlay_owner_window == self) {
				owner_root.ClearActiveOverlayOwner();
			}
			if (owner_root.context_menu_owner_window == self) {
				owner_root.CloseContextMenu();
			}
			if (owner_root.tooltip_owner_window == self) {
				owner_root.tooltip_control_id = undefined;
				owner_root.tooltip_text = "";
				owner_root.tooltip_visible = false;
				owner_root.tooltip_requested_this_frame = false;
				owner_root.tooltip_owner_window = undefined;
			}
			var _focus_match = (owner_root.control_focus_window == self) || (owner_root.keyboard_focus_window == self);
			if (_focus_match) {
				if (!is_undefined(owner_root.text_focus_id)) {
					owner_root.BlurTextInput(owner_root.text_focus_id);
				}
				owner_root.BlurControlFocus(undefined);
				owner_root.__SetKeyboardFocusWindow(undefined);
			}
		}
		if (_want) {
			if (is_instanceof(owner_root, EchoChamberRoot)) {
				__EnsureTitlebarVisible(owner_root.window_min_visible_titlebar_w, owner_root.window_min_visible_titlebar_h, true);
			}
			if (is_callable(on_show)) {
				on_show();
			}
		}
		else {
			if (is_callable(on_hide)) {
				on_hide();
			}
		}
		return self;
	};

	/// @desc Configure which chrome buttons are shown in the window header.
	/// @param {Bool} _show_close
	/// @param {Bool} _show_minimize
	/// @param {Bool} _show_pin
	/// @return {Struct.EchoChamberWindow}
	static SetShowChromeButtons = function(_show_close, _show_minimize, _show_pin) {
		show_close_button    = (_show_close != 0);
		show_minimize_button = (_show_minimize != 0);
		show_pin_button      = (_show_pin != 0);
		return self;
	};

	/// @desc Set a callback that runs when the window is closed via the close button.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnClose = function(_fn) {
		on_close = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window position changes.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnMove = function(_fn) {
		on_move = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window size changes.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnResize = function(_fn) {
		on_resize = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window becomes visible.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnShow = function(_fn) {
		on_show = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window is hidden.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnHide = function(_fn) {
		on_hide = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window receives keyboard focus.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnFocus = function(_fn) {
		on_focus = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window loses keyboard focus.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnBlur = function(_fn) {
		on_blur = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window is minimized.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnMinimize = function(_fn) {
		on_minimize = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Set a callback that runs when the window is restored from minimized state.
	/// @param {Function} _fn
	/// @return {Struct.EchoChamberWindow}
	static OnRestore = function(_fn) {
		on_restore = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Close the window (sets visible to false). If an on_close callback exists, it is called.
	static Close = function() {
		if (visible) {
			SetVisible(false);
		}
		if (is_callable(on_close)) {
			on_close();
		}
	};

	/// @desc Set whether the window is pinned (disables dragging and resizing).
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberWindow}
	static SetPinned = function(_flag) {
		is_pinned = (_flag != 0);
		// If we are currently dragging/resizing, cancel it.
		if (is_pinned) {
			is_dragging = false;
			is_resizing = false;
			if (is_struct(owner_root)) {
				owner_root.ClearMouseCapture(self);
			}
		}
		return self;
	};

	/// @desc Toggle pinned state.
	/// @return {Struct.EchoChamberWindow}
	static TogglePinned = function() {
		return SetPinned(!is_pinned);
	};

	/// @ignore
	/// @func __GetMinimizedHeight()
	/// @desc Internal: compute the minimized window height.
	/// @return {Real}
	static __GetMinimizedHeight = function() {
		var _h = titlebar_height + (padding * 2) + 2;
		var _theme = theme_override;
		if (!is_instanceof(_theme, EchoChamberTheme)) {
			var _r = owner_root;
			if (is_instanceof(_r, EchoChamberRoot)) {
				_theme = _r.theme;
			}
		}
		if (is_instanceof(_theme, EchoChamberTheme)) {
			_h = _theme.window_minimized_h;
		}
		return max(12, _h);
	};

	/// @ignore
	/// @func __ClampTitlebarPosition(_x1, _y1, _min_w, _min_h)
	/// @desc Internal: clamp a window position so a minimum titlebar strip stays visible.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _min_w
	/// @param {Real} _min_h
	/// @return {Struct}
	static __ClampTitlebarPosition = function(_x1, _y1, _min_w, _min_h) {
		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();
		if (_gw <= 0 || _gh <= 0) {
			return { x: _x1, y: _y1 };
		}
		var _w = rect.x2 - rect.x1;
		var _h = rect.y2 - rect.y1;
		var _tb_h = max(0, titlebar_height);
		var _vis_w = min(_w, max(1, _min_w));
		var _vis_h = max(1, _min_h);
		var _mx = max(0, margin_x);
		var _my = max(0, margin_y);
		var _min_x = -(_w - _vis_w) + _mx;
		var _max_x = (_gw - _vis_w) - _mx;
		var _min_y = 0;
		var _max_y = 0;
		if (_tb_h > 0) {
			_vis_h = min(_tb_h, _vis_h);
			_min_y = -(_tb_h - _vis_h) + _my;
			_max_y = (_gh - _vis_h) - _my;
		}
		else {
			_vis_h = min(_h, _vis_h);
			_min_y = -(_h - _vis_h) + _my;
			_max_y = (_gh - _vis_h) - _my;
		}
		return { x: clamp(_x1, _min_x, _max_x), y: clamp(_y1, _min_y, _max_y) };
	};

	/// @ignore
	/// @func __EnsureTitlebarVisible(_min_w, _min_h, _only_if_offscreen)
	/// @desc Internal: move the window so its title bar remains reachable.
	/// @param {Real} _min_w
	/// @param {Real} _min_h
	/// @param {Bool} _only_if_offscreen
	/// @return {Bool}
	static __EnsureTitlebarVisible = function(_min_w, _min_h, _only_if_offscreen) {
		var _gw = display_get_gui_width();
		var _gh = display_get_gui_height();
		if (_gw <= 0 || _gh <= 0) {
			return false;
		}
		var _tb_h = max(0, titlebar_height);
		var _x1 = rect.x1;
		var _y1 = rect.y1;
		var _x2 = rect.x2;
		var _y2 = (_tb_h > 0) ? (_y1 + _tb_h) : rect.y2;
		if (_only_if_offscreen) {
			if (!(_x2 <= 0 || _x1 >= _gw || _y2 <= 0 || _y1 >= _gh)) {
				return false;
			}
		}
		var _pos = __ClampTitlebarPosition(_x1, _y1, _min_w, _min_h);
		if (_pos.x == _x1 && _pos.y == _y1) {
			return false;
		}
		var _w = rect.x2 - rect.x1;
		var _h = rect.y2 - rect.y1;
		__SetRectDirect(_pos.x, _pos.y, _pos.x + _w, _pos.y + _h);
		return true;
	};

	/// @desc Set whether the window is minimized (collapses content; only the title bar remains).
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberWindow}
	static SetMinimized = function(_flag) {
		var _want = (_flag != 0);
		if (_want == is_minimized) {
			return self;
		}
		var _old_x1 = rect.x1;
		var _old_y1 = rect.y1;
		var _old_x2 = rect.x2;
		var _old_y2 = rect.y2;
		// If this window owns a modal overlay, clear it now.
		if (is_instanceof(owner_root, EchoChamberRoot) && owner_root.active_overlay_owner_window == self) {
			owner_root.ClearActiveOverlayOwner();
		}
		if (_want) {
			restore_height = rect.y2 - rect.y1;
			is_minimized = true;
			rect.y2 = rect.y1 + __GetMinimizedHeight();
		}
		else {
			is_minimized = false;
			var _h = max(min_height, restore_height);
			if (max_height > 0) _h = min(_h, max_height);
			rect.y2 = rect.y1 + _h;
		}
		__NotifyMoveResize(_old_x1, _old_y1, _old_x2, _old_y2);
		if (_want) {
			if (is_callable(on_minimize)) {
				on_minimize();
			}
		}
		else {
			if (is_callable(on_restore)) {
				on_restore();
			}
		}
		return self;
	};

	/// @desc Toggle minimized state.
	/// @return {Struct.EchoChamberWindow}
	static ToggleMinimized = function() {
		return SetMinimized(!is_minimized);
	};


	/// @desc Set the window rectangle in GUI-space. Size is clamped to min_width/min_height.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	/// @return {Struct.EchoChamberWindow}
	static SetRect = function(_x1, _y1, _x2, _y2) {
		user_set_rect = true;
		fit_to_content_on_add = false;
		fit_to_content_pending_root = undefined;
		fit_to_content_pending_respect = true;
		__SetRectDirect(_x1, _y1, _x2, _y2);
		return self;
	};

	/// @desc Set the window position without changing its size.
	/// @param {Real} _x
	/// @param {Real} _y
	/// @return {Struct.EchoChamberWindow}
	static SetPosition = function(_x, _y) {
		var _w = rect.x2 - rect.x1;
		var _h = rect.y2 - rect.y1;
		__SetRectDirect(_x, _y, _x + _w, _y + _h);
		return self;
	};

	/// @desc Get the current window width.
	/// @return {Real}
	static GetWidth = function() {
		return rect.x2 - rect.x1;
	};

	/// @desc Get the current window height.
	/// @return {Real}
	static GetHeight = function() {
		return rect.y2 - rect.y1;
	};

	/// @ignore
	/// @func __NotifyMoveResize(_old_x1, _old_y1, _old_x2, _old_y2)
	/// @desc Internal: fire move/resize callbacks after a rect change.
	/// @param {Real} _old_x1
	/// @param {Real} _old_y1
	/// @param {Real} _old_x2
	/// @param {Real} _old_y2
	static __NotifyMoveResize = function(_old_x1, _old_y1, _old_x2, _old_y2) {
		var _moved = (rect.x1 != _old_x1) || (rect.y1 != _old_y1);
		var _old_w = _old_x2 - _old_x1;
		var _old_h = _old_y2 - _old_y1;
		var _new_w = rect.x2 - rect.x1;
		var _new_h = rect.y2 - rect.y1;
		var _resized = (_old_w != _new_w) || (_old_h != _new_h);
		if (_moved) {
			if (is_callable(on_move)) {
				on_move();
			}
		}
		if (_resized) {
			if (is_callable(on_resize)) {
				on_resize();
			}
		}
	};

	/// @ignore
	/// @func __SetRectDirect(_x1, _y1, _x2, _y2)
	/// @desc Internal: assign window rect without marking user overrides.
	/// @param {Real} _x1
	/// @param {Real} _y1
	/// @param {Real} _x2
	/// @param {Real} _y2
	static __SetRectDirect = function(_x1, _y1, _x2, _y2) {
		var _old_x1 = rect.x1;
		var _old_y1 = rect.y1;
		var _old_x2 = rect.x2;
		var _old_y2 = rect.y2;
		var _nx1 = min(_x1, _x2);
		var _ny1 = min(_y1, _y2);
		var _nx2 = max(_x1, _x2);
		var _ny2 = max(_y1, _y2);
		if (max_width > 0) {
			var _max_x2 = _nx1 + max_width;
			if (_nx2 > _max_x2) _nx2 = _max_x2;
		}
		if (max_height > 0) {
			var _max_y2 = _ny1 + max_height;
			if (_ny2 > _max_y2) _ny2 = _max_y2;
		}
		rect.x1 = _nx1;
		rect.y1 = _ny1;
		rect.x2 = max(_nx1 + min_width, _nx2);
		var _min_h = is_minimized ? __GetMinimizedHeight() : min_height;
		rect.y2 = max(_ny1 + _min_h, _ny2);
		__NotifyMoveResize(_old_x1, _old_y1, _old_x2, _old_y2);
	};

	/// @desc Set minimum width and height for this window.
	/// @param {Real} _w
	/// @param {Real} _h
	/// @return {Struct.EchoChamberWindow}
	static SetMinSize = function(_w, _h) {
		min_width  = max(64, _w);
		min_height = max(64, _h);
		if (max_width > 0 && max_width < min_width) max_width = min_width;
		if (max_height > 0 && max_height < min_height) max_height = min_height;
		user_set_min = true;
		return self;
	};

	/// @ignore
	/// @func __SetMinSizeDirect(_w, _h)
	/// @desc Internal: set min size without marking user overrides.
	/// @param {Real} _w
	/// @param {Real} _h
	static __SetMinSizeDirect = function(_w, _h) {
		min_width  = max(64, _w);
		min_height = max(64, _h);
		if (max_width > 0 && max_width < min_width) max_width = min_width;
		if (max_height > 0 && max_height < min_height) max_height = min_height;
	};

	/// @desc Set maximum width and height for this window (0 means no max).
	/// @param {Real} _w
	/// @param {Real} _h
	/// @return {Struct.EchoChamberWindow}
	static SetMaxSize = function(_w, _h) {
		max_width  = max(0, _w);
		max_height = max(0, _h);
		if (max_width > 0 && max_width < min_width) max_width = min_width;
		if (max_height > 0 && max_height < min_height) max_height = min_height;
		user_set_max = true;
		return self;
	};

	/// @desc Add a top-level panel to this window.
	/// @param {Struct.EchoChamberPanel} _panel
	/// @return {Struct.EchoChamberPanel}
	static AddPanel = function(_panel) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return undefined;
		}
		__AssignOwnershipToPanelRecursive(_panel, undefined);
		array_push(panels, _panel);
		if (layout_batch_depth > 0) {
			var _r = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
			var _respect = fit_to_content_on_add ? fit_to_content_pending_respect : false;
			__QueueLayoutBatchFit(_r, _respect);
			if (fit_to_content_on_add) {
				fit_to_content_on_add = false;
				fit_to_content_pending_root = undefined;
				fit_to_content_pending_respect = true;
			}
		}
		else if (fit_to_content_on_add) {
			var _r2 = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
			__FitToContent(_r2, fit_to_content_pending_respect);
			fit_to_content_on_add = false;
			fit_to_content_pending_root = undefined;
			fit_to_content_pending_respect = true;
		}
		else if (auto_fit) {
			var _r3 = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
			__FitToContent(_r3, false);
		}
		return _panel;
	};

	/// @desc Remove a panel from this window (top-level or nested).
	/// @param {Any} _panel_or_id
	/// @return {Bool}
	static RemovePanel = function(_panel_or_id) {
		var _panel = undefined;
		if (is_instanceof(_panel_or_id, EchoChamberPanel)) {
			_panel = _panel_or_id;
		}
		else {
			_panel = FindPanel(_panel_or_id);
		}
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return false;
		}

		if (is_instanceof(_panel.owner_panel, EchoChamberPanel)) {
			return _panel.owner_panel.RemoveChildPanel(_panel);
		}

		var _len = array_length(panels);
		var _removed = false;
		for (var _i = 0; _i < _len; _i++) {
			if (panels[_i] == _panel) {
				array_delete(panels, _i, 1);
				_removed = true;
				break;
			}
		}
		if (!_removed) {
			return false;
		}

		if (is_instanceof(owner_root, EchoChamberRoot)) {
			owner_root.__DetachPanelRecursive(_panel);
		}
		else {
			__DetachPanelLocal(_panel);
		}

		if (layout_batch_depth > 0) {
			__QueueLayoutBatchFit(owner_root, false);
		}
		else if (auto_fit) {
			var _r3 = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
			__FitToContent(_r3, false);
		}

		return true;
	};

	/// @desc Remove all panels from this window.
	static ClearPanels = function() {
		var _plen = array_length(panels);
		if (_plen <= 0) {
			return;
		}

		if (is_instanceof(owner_root, EchoChamberRoot)) {
			for (var _pi = 0; _pi < _plen; _pi++) {
				owner_root.__DetachPanelRecursive(panels[_pi]);
			}
		}
		else {
			for (var _pi2 = 0; _pi2 < _plen; _pi2++) {
				__DetachPanelLocal(panels[_pi2]);
			}
		}

		panels = [];
		if (layout_batch_depth > 0) {
			__QueueLayoutBatchFit(owner_root, false);
		}
		else if (auto_fit) {
			var _r4 = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
			__FitToContent(_r4, false);
		}
	};

	/// @ignore
	/// @func __DetachPanelLocal(_panel)
	/// @desc Internal: detach a panel tree without root context.
	/// @param {Struct.EchoChamberPanel} _panel
	static __DetachPanelLocal = function(_panel) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return;
		}
		_panel.owner_root   = undefined;
		_panel.owner_window = undefined;
		_panel.owner_panel  = undefined;

		var _clen = array_length(_panel.children_controls);
		for (var _ci = 0; _ci < _clen; _ci++) {
			var _ctrl = _panel.children_controls[_ci];
			_ctrl.owner_root   = undefined;
			_ctrl.owner_window = undefined;
			_ctrl.owner_panel  = undefined;
		}

		var _plen = array_length(_panel.children_panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _child = _panel.children_panels[_pi];
			__DetachPanelLocal(_child);
		}
	};

	/// @ignore
	/// @func __OffsetPanelRectRecursive(_panel, _dx, _dy)
	/// @desc Internal: offset panel rects (including nested child panels) by a delta.
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _dx
	/// @param {Real} _dy
	static __OffsetPanelRectRecursive = function(_panel, _dx, _dy) {
		_panel.rect.x1 += _dx;
		_panel.rect.y1 += _dy;
		_panel.rect.x2 += _dx;
		_panel.rect.y2 += _dy;

		if (_panel.is_container) {
			var _plen = array_length(_panel.children_panels);
			for (var i = 0; i < _plen; i++) {
				var _child = _panel.children_panels[i];
				__OffsetPanelRectRecursive(_child, _dx, _dy);
			}
		}
	};

	/// @ignore
	/// @func __AssignOwnershipAll()
	/// @desc Internal: assign owner pointers to all panels and controls currently in this window.
	static __AssignOwnershipAll = function() {
		var _plen = array_length(panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _p = panels[_pi];
			__AssignOwnershipToPanelRecursive(_p, undefined);
		}
	};

	/// @ignore
	/// @func __AssignOwnershipToPanelRecursive(_panel, _parent_panel)
	/// @desc Internal: assign owner pointers to a panel tree (panel -> controls -> child panels).
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct.EchoChamberPanel} _parent_panel
	static __AssignOwnershipToPanelRecursive = function(_panel, _parent_panel) {
		_panel.owner_root   = owner_root;
		_panel.owner_window = self;
		_panel.owner_panel  = _parent_panel;

		// Controls
		var _clen = array_length(_panel.children_controls);
		for (var _ci = 0; _ci < _clen; _ci++) {
			var _ctrl = _panel.children_controls[_ci];
			_ctrl.owner_root   = owner_root;
			_ctrl.owner_window = self;
			_ctrl.owner_panel  = _panel;
		}

		// Child panels (container panels)
		var _plen2 = array_length(_panel.children_panels);
		for (var _pj = 0; _pj < _plen2; _pj++) {
			var _child = _panel.children_panels[_pj];
			__AssignOwnershipToPanelRecursive(_child, _panel);
		}
	};

	/// @desc Find a panel in this window by id (searches nested container panels too).
	/// @param {Any} _id
	/// @return {Struct.EchoChamberPanel}
	static FindPanel = function(_id) {
		var _id_str = string(_id);
		var _plen = array_length(panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _p = panels[_pi];
			var _found = __FindPanelRecursive(_p, _id_str);
			if (!is_undefined(_found)) {
				return _found;
			}
		}
		return undefined;
	};

	/// @desc Find a control in this window by id (searches nested panels too).
	/// @param {Any} _id
	/// @return {Struct.EchoChamberControlBase}
	static FindControl = function(_id) {
		var _id_str = string(_id);
		if (string_length(_id_str) <= 0) {
			return undefined;
		}
		var _plen = array_length(panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _p = panels[_pi];
			var _found = _p.FindControl(_id_str);
			if (!is_undefined(_found)) {
				return _found;
			}
		}
		return undefined;
	};

	/// @desc Move a control to another panel in this window.
	/// @param {Any} _control_or_id
	/// @param {Any} _panel_or_id
	/// @param {Real} [_index]
	/// @return {Bool}
	static MoveControlToPanel = function(_control_or_id, _panel_or_id, _index = undefined) {
		var _panel = _panel_or_id;
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			_panel = FindPanel(_panel_or_id);
		}
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return false;
		}
		var _control = _control_or_id;
		if (!is_instanceof(_control, EchoChamberControlBase)) {
			_control = FindControl(_control_or_id);
		}
		if (!is_instanceof(_control, EchoChamberControlBase)) {
			return false;
		}
		if (!is_instanceof(_control.owner_panel, EchoChamberPanel)) {
			return false;
		}
		return _control.owner_panel.MoveControlToPanel(_control, _panel, _index);
	};

	/// @ignore
	/// @func __FindPanelRecursive(_panel, _id_str)
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {String} _id_str
	/// @return {Struct.EchoChamberPanel}
	static __FindPanelRecursive = function(_panel, _id_str) {
		if (_panel.id == _id_str) {
			return _panel;
		}
		var _len = array_length(_panel.children_panels);
		for (var _i = 0; _i < _len; _i++) {
			var _child = _panel.children_panels[_i];
			var _found = __FindPanelRecursive(_child, _id_str);
			if (!is_undefined(_found)) {
				return _found;
			}
		}
		return undefined;
	};

	/// @desc Returns true if a point is inside this window's current rectangle (and the window is visible).
	/// @param {Real} _x
	/// @param {Real} _y
	/// @return {Bool}
	static ContainsPoint = function(_x, _y) {
		if (!visible) {
			return false;
		}
		return (_x >= rect.x1 && _x <= rect.x2 && _y >= rect.y1 && _y <= rect.y2);
	};

	/// @ignore
	/// @func __GetContentRect()
	/// @desc Internal: get the drawable content rect inside chrome and padding.
	/// @return {Struct} {x1,y1,x2,y2}
	static __GetContentRect = function() {
		var _pad = padding;
		var _content = {
			x1 : rect.x1 + _pad,
			y1 : rect.y1 + titlebar_height + _pad,
			x2 : rect.x2 - _pad,
			y2 : rect.y2 - _pad
		};
		return _content;
	};

	/// @ignore
	/// @func __GetHeaderButtonLayout(_root)
	/// @desc Internal: compute header button rectangles and title clipping boundary.
	/// @param {Struct.EchoChamberRoot} _root
	/// @return {Struct}
	static __GetHeaderButtonLayout = function(_root) {
		var _btn_gap = 2;
		var _btn_sz  = max(12, titlebar_height - 6);
		var _close_lbl   = "X";
		var _min_lbl     = "-";
		var _restore_lbl = "+";
		var _pin_lbl     = "P";
		var _unpin_lbl   = "P";
		if (is_instanceof(_root, EchoChamberRoot)) {
			var _t = _root.theme;
			_btn_gap = _t[$ "window_button_gap"] ?? _btn_gap;
			_btn_sz = _t[$ "window_button_size"] ?? _btn_sz;
			if (_btn_sz <= 0) _btn_sz = max(12, titlebar_height - 6);
			_close_lbl = string(_t[$ "window_button_close_label"] ?? _close_lbl);
			_min_lbl = string(_t[$ "window_button_minimize_label"] ?? _min_lbl);
			_restore_lbl = string(_t[$ "window_button_restore_label"] ?? _restore_lbl);
			_pin_lbl = string(_t[$ "window_button_pin_label"] ?? _pin_lbl);
			_unpin_lbl = string(_t[$ "window_button_unpin_label"] ?? _unpin_lbl);
		}
		var _x2 = rect.x2 - padding;
		var _y1 = rect.y1;
		var _btn_y1 = _y1 + (titlebar_height - _btn_sz) * 0.5;
		var _btn_y2 = _btn_y1 + _btn_sz;
		var _style_close = "__window_close";
		var _style_min = "__window_minimize";
		var _style_pin = "__window_pin";
		if (!is_undefined(chrome_button_style_key)) {
			_style_close = chrome_button_style_key;
			_style_min = chrome_button_style_key;
			_style_pin = chrome_button_style_key;
		}
		var _layout = {
			btn_size: _btn_sz,
			btn_gap: _btn_gap,
			title_max_x: _x2,
			close_rect: undefined,
			min_rect: undefined,
			pin_rect: undefined,
			close_label: _close_lbl,
			min_label: _min_lbl,
			restore_label: _restore_lbl,
			pin_label: _pin_lbl,
			unpin_label: _unpin_lbl,
			style_close: _style_close,
			style_min: _style_min,
			style_pin: _style_pin
		};
		var _cur_x2 = _x2;
		if (show_close_button) {
			var _r0 = { x1: _cur_x2 - _btn_sz, y1: _btn_y1, x2: _cur_x2, y2: _btn_y2 };
			_layout.close_rect = _r0;
			_cur_x2 = _r0.x1 - _btn_gap;
		}
		if (show_minimize_button) {
			var _r1 = { x1: _cur_x2 - _btn_sz, y1: _btn_y1, x2: _cur_x2, y2: _btn_y2 };
			_layout.min_rect = _r1;
			_cur_x2 = _r1.x1 - _btn_gap;
		}
		if (show_pin_button) {
			var _r2 = { x1: _cur_x2 - _btn_sz, y1: _btn_y1, x2: _cur_x2, y2: _btn_y2 };
			_layout.pin_rect = _r2;
			_cur_x2 = _r2.x1 - _btn_gap;
		}
		_layout.title_max_x = _cur_x2;
		return _layout;
	};

	/// @ignore
	/// @func __DrawHeaderButton(_root, _rect, _label, _style_key, _active)
	/// @desc Internal: draw a window header button.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct} _rect
	/// @param {String} _label
	/// @param {String} _style_key
	/// @param {Bool} _active
	static __DrawHeaderButton = function(_root, _rect, _label, _style_key, _active) {
		if (!is_struct(_rect)) return;
		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;
		var _hover = is_struct(_root) && _root.HitTestRect(_x1, _y1, _x2, _y2);
		var _styles = is_struct(_root.theme) && !is_undefined(_root.theme[$ "button_styles"])
		? _root.theme.button_styles
		: undefined;
		var _st = is_struct(_styles) && !is_undefined(_styles[$ _style_key])
		? _styles[$ _style_key]
		: (is_struct(_styles) ? _styles[$ "_default"] : undefined);
		var _bg_col = is_struct(_st) && _st[$ "bg"]     ? _st.bg     : _root.theme.col_panel_bg;
		var _bd_col = is_struct(_st) && _st[$ "border"] ? _st.border : _root.theme.col_accent;
		var _tx_col = is_struct(_st) && _st[$ "text"]   ? _st.text   : _root.theme.col_text;
		if (_active) {
			_bg_col = merge_color(_bg_col, _root.theme.col_accent, 0.25);
		}
		if (_hover) {
			_bg_col = merge_color(_bg_col, _tx_col, 0.15);
		}
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(0.95);
		draw_set_color(_bg_col);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);
		draw_set_color(_bd_col);
		draw_rectangle(_x1, _y1, _x2, _y2, true);
		var _old_font = draw_get_font();
		var _font = _root.theme.font_body;
		if (is_struct(_root.theme) && !is_undefined(_root.theme[$ "font_header"])) {
			_font = _root.theme[$ "font_header"];
		}
		draw_set_font(_font);
		draw_set_color(_tx_col);
		var _s = string(_label);
		var _tw = string_width(_s);
		var _th = string_height(_s);
		var _tx = _x1 + ((_x2 - _x1) - _tw) * 0.5;
		var _ty = _y1 + ((_y2 - _y1) - _th) * 0.5;
		draw_text(_tx, _ty, _s);
		draw_set_font(_old_font);
	};


	/// @ignore
	/// @func __ApplyThemeDefaultsToPanels(_root)
	/// @desc Apply theme-driven panel metrics (once) for all panels in this window.
	/// @param {Struct.EchoChamberRoot} _root
	static __ApplyThemeDefaultsToPanels = function(_root) {
		if (!is_instanceof(_root, EchoChamberRoot)) {
			return;
		}
		var _t = _root.theme;
		var _len = array_length(panels);
		for (var _i = 0; _i < _len; _i++) {
			var _p = panels[_i];
			__ApplyThemeDefaultsToPanelRecursive(_t, _p, _root);
		}
	};

	/// @ignore
	/// @func __ApplyThemeDefaultsToPanelRecursive(_theme, _panel, _root)
	/// @param {Struct.EchoChamberTheme} _theme
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Struct.EchoChamberRoot} _root
	static __ApplyThemeDefaultsToPanelRecursive = function(_theme, _panel, _root) {
		if (_panel.__theme_defaults_applied) {
			// Still recurse into children if any
			if (_panel.is_container) {
				var _cl = array_length(_panel.children_panels);
				for (var _ci = 0; _ci < _cl; _ci++) {
					__ApplyThemeDefaultsToPanelRecursive(_theme, _panel.children_panels[_ci], _root);
				}
			}
			return;
		}

		var _pad = _theme.panel_padding;
		var _gap = _theme.panel_gap;
		var _row_h = _theme.panel_row_height;
		var _collapsed = _theme.panel_collapsed_size;
		var _margin_x = _theme[$ "panel_margin_x"] ?? 0;
		var _margin_y = _theme[$ "panel_margin_y"] ?? 0;
		var _field_label_placement = _theme[$ "field_label_placement"] ?? eEchoChamberFieldLabelPlacement.AUTO;
		var _field_label_gap = _theme[$ "field_label_gap"] ?? 6;
		var _field_label_width = _theme[$ "field_label_width"] ?? -1;
		var _field_label_min_width = _theme[$ "field_label_min_width"] ?? 60;
		var _field_label_max_width = _theme[$ "field_label_max_width"] ?? 220;
		var _field_label_style_id = _theme[$ "field_label_style_id"] ?? "_field";
		var _field_label_align_leading = _theme[$ "field_label_align_leading"] ?? "right";
		var _field_label_align_above = _theme[$ "field_label_align_above"] ?? "left";
		_panel.SetPadding(_pad);
		_panel.SetMargin(_margin_x, _margin_y);
		_panel.SetGap(_gap);
		_panel.SetRowHeight(_row_h);
		_panel.SetCollapsedSize(_collapsed);
		if (!_panel.__field_label_placement_user_set) {
			_panel.field_label_placement = _field_label_placement;
		}
		if (!_panel.__field_label_gap_user_set) {
			_panel.field_label_gap = (_field_label_gap < 0) ? -1 : max(0, _field_label_gap);
		}
		if (!_panel.__field_label_width_user_set) {
			_panel.field_label_width = (_field_label_width < 0) ? -1 : max(0, _field_label_width);
		}
		if (!_panel.__field_label_width_clamp_user_set) {
			_panel.field_label_min_width = max(0, _field_label_min_width);
			_panel.field_label_max_width = max(_panel.field_label_min_width, _field_label_max_width);
		}
		if (!_panel.__field_label_style_user_set) {
			_panel.field_label_style_id = string(_field_label_style_id);
		}
		_panel.field_label_align_leading = string(_field_label_align_leading);
		_panel.field_label_align_above = string(_field_label_align_above);

		_panel.__theme_defaults_applied = true;

		if (_panel.is_container) {
			var _cl2 = array_length(_panel.children_panels);
			for (var _ci2 = 0; _ci2 < _cl2; _ci2++) {
				__ApplyThemeDefaultsToPanelRecursive(_theme, _panel.children_panels[_ci2], _root);
			}
		}
	};

	/// @ignore
	/// @func __MeasurePanelDesiredContentSize(_root, _panel)
	/// @desc Internal: measure a panel's desired content size (controls or child panels).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @return {Struct} {w,h}
	static __MeasurePanelDesiredContentSize = function(_root, _panel) {
		if (_panel.is_container) {
			return __MeasureDockedPanelsDesiredSize(_root, _panel.children_panels);
		}

		var _row_h = _panel.row_height > 0 ? _panel.row_height : _root.default_row_height;
		var _gap = _panel.gap;
		var _inner_w_hint = max(_root.default_control_width, _root.default_control_max_width);
		var _field_label_col_w = _panel.__ResolveFieldLabelColumnWidth(_root, _inner_w_hint);

		var _visible = 0;
		var _len = array_length(_panel.children_controls);

		if (_panel.flow == eEchoChamberPanelFlow.COLUMN) {
			var _max_w = 0;
			for (var _i = 0; _i < _len; _i++) {
				var _ctrl = _panel.children_controls[_i];
				if (!_ctrl.visible) continue;
				_visible++;
				var _w = _panel.__ResolveControlDesiredWidth(_root, _ctrl, _row_h, _inner_w_hint, _field_label_col_w);
				if (_w > _max_w) _max_w = _w;
			}
			_field_label_col_w = _panel.__ResolveFieldLabelColumnWidth(_root, _max_w);
			var _h = 0;
			if (_visible > 0) {
				for (var _j = 0; _j < _len; _j++) {
					var _ctrl_h = _panel.children_controls[_j];
					if (!_ctrl_h.visible) continue;
					var _h_row = _panel.__ResolveControlDesiredHeight(_root, _ctrl_h, _row_h, _max_w, _field_label_col_w);
					if (_h > 0) _h += _gap;
					_h += _h_row;
				}
			}
			else {
				_h = _row_h;
			}
			return { w: _max_w, h: _h };
		}

		var _sum_w = 0;
		var _content_h = 0;
		var _has_row = false;
		var _row_h_cur = _row_h;
		var _row_w_cur = 0;
		var _max_row_w = 0;

		for (var _k = 0; _k < _len; _k++) {
			var _ctrl_row = _panel.children_controls[_k];
			if (!_ctrl_row.visible) continue;
			_visible++;
			var _fill = (_ctrl_row[$ "fill_width"] == true);
			var _w_row = _panel.__ResolveControlDesiredWidth(_root, _ctrl_row, _row_h, _inner_w_hint, _field_label_col_w);
			if (_fill) {
				if (_has_row) {
					if (_content_h > 0) _content_h += _gap;
					_content_h += _row_h_cur;
					if (_row_w_cur > _max_row_w) _max_row_w = _row_w_cur;
					_has_row = false;
					_row_h_cur = _row_h;
					_row_w_cur = 0;
				}
				if (_content_h > 0) _content_h += _gap;
				_content_h += _panel.__ResolveControlDesiredHeight(_root, _ctrl_row, _row_h, _w_row, _field_label_col_w);
				if (_w_row > _max_row_w) _max_row_w = _w_row;
			}
			else {
				if (_row_w_cur > 0) _row_w_cur += _gap;
				_row_w_cur += _w_row;
				var _h_row = _panel.__ResolveControlDesiredHeight(_root, _ctrl_row, _row_h, _w_row, _field_label_col_w);
				if (_h_row > _row_h_cur) _row_h_cur = _h_row;
				_has_row = true;
			}
		}
		if (_has_row) {
			if (_content_h > 0) _content_h += _gap;
			_content_h += _row_h_cur;
			if (_row_w_cur > _max_row_w) _max_row_w = _row_w_cur;
		}
		if (_visible <= 0) _content_h = _row_h;
		return { w: _max_row_w, h: _content_h };
	};

	/// @ignore
	/// @func __MeasurePanelContentHeightForWidth(_root, _panel, _inner_w)
	/// @desc Internal: measure a panel's content height for a given inner width (used for scrolling).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _inner_w
	/// @return {Real}
	static __MeasurePanelContentHeightForWidth = function(_root, _panel, _inner_w) {
		if (_panel.is_container) {
			var _content = __MeasurePanelDesiredContentSize(_root, _panel);
			return _content.h;
		}

		var _row_h = _panel.row_height > 0 ? _panel.row_height : _root.default_row_height;
		var _gap = _panel.gap;
		var _inner_w2 = max(0, _inner_w);
		var _field_label_col_w = _panel.__ResolveFieldLabelColumnWidth(_root, _inner_w2);
		var _len = array_length(_panel.children_controls);
		var _visible = 0;

		if (_panel.flow == eEchoChamberPanelFlow.COLUMN) {
			var _h = 0;
			for (var i = 0; i < _len; i++) {
				var _ctrl = _panel.children_controls[i];
				if (!_ctrl.visible) {
					continue;
				}
				_visible += 1;
				var _h_row = _panel.__ResolveControlDesiredHeight(_root, _ctrl, _row_h, _inner_w2, _field_label_col_w);
				if (_h > 0) {
					_h += _gap;
				}
				_h += _h_row;
			}
			if (_visible <= 0) {
				_h = _row_h;
			}
			return _h;
		}

		var _content_h = 0;
		var _row_w = 0;
		var _has_row = false;
		var _row_h_cur = _row_h;
		for (var j = 0; j < _len; j++) {
			var _ctrl_row = _panel.children_controls[j];
			if (!_ctrl_row.visible) {
				continue;
			}
			_visible += 1;
			var _fill = (_ctrl_row[$ "fill_width"] == true);
			if (_fill) {
				if (_has_row) {
					if (_content_h > 0) {
						_content_h += _gap;
					}
					_content_h += _row_h_cur;
					_row_w = 0;
					_has_row = false;
					_row_h_cur = _row_h;
				}
				if (_content_h > 0) {
					_content_h += _gap;
				}
				_content_h += _panel.__ResolveControlDesiredHeight(_root, _ctrl_row, _row_h, _inner_w2, _field_label_col_w);
			}
			else {
				var _desired_w = _panel.__ResolveControlDesiredWidth(_root, _ctrl_row, _row_h, _inner_w2, _field_label_col_w);
				var _needs_gap = (_row_w > 0);
				var _avail_row_w = max(0, _inner_w2 - _row_w - (_needs_gap ? _gap : 0));
				if (_avail_row_w <= 0 || (_needs_gap && _desired_w > _avail_row_w)) {
					if (_has_row) {
						if (_content_h > 0) {
							_content_h += _gap;
						}
						_content_h += _row_h_cur;
					}
					_row_w = 0;
					_has_row = false;
					_needs_gap = false;
					_avail_row_w = max(0, _inner_w2);
					_row_h_cur = _row_h;
				}
				if (_needs_gap) {
					_row_w += _gap;
				}
				var _use_w = (_avail_row_w <= 0) ? 0 : min(_desired_w, _avail_row_w);
				_row_w += _use_w;
				var _h_row = _panel.__ResolveControlDesiredHeight(_root, _ctrl_row, _row_h, _use_w, _field_label_col_w);
				if (_h_row > _row_h_cur) {
					_row_h_cur = _h_row;
				}
				_has_row = true;
			}
		}
		if (_has_row) {
			if (_content_h > 0) {
				_content_h += _gap;
			}
			_content_h += _row_h_cur;
		}
		if (_visible <= 0) {
			_content_h = _row_h;
		}
		return _content_h;
	};

	/// @ignore
	/// @func __MeasurePanelDesiredOuterSize(_root, _panel)
	/// @desc Internal: measure a panel's desired outer size (content + padding).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberPanel} _panel
	/// @return {Struct} {w,h}
	static __MeasurePanelDesiredOuterSize = function(_root, _panel) {
		var _content = __MeasurePanelDesiredContentSize(_root, _panel);
		var _pad = max(0, _panel.padding);
		var _margin_x = max(0, _panel.margin_x);
		var _margin_y = max(0, _panel.margin_y);
		var _handle_w = 0;
		var _handle_h = 0;
		if (_panel.collapse_mode != eEchoChamberCollapse.NONE && !_panel.collapsed) {
			var _handle_size = _root.theme[$ "panel_collapse_handle_size"] ?? 0;
			_handle_size = max(0, _handle_size);
			if (_handle_size > 0) {
				if (_panel.collapse_mode == eEchoChamberCollapse.TO_LEFT || _panel.collapse_mode == eEchoChamberCollapse.TO_RIGHT) {
					_handle_w = _handle_size;
				}
				else {
					_handle_h = _handle_size;
				}
			}
		}
		return { w: _content.w + _pad * 2 + _margin_x * 2 + _handle_w, h: _content.h + _pad * 2 + _margin_y * 2 + _handle_h };
	};

	/// @ignore
	/// @func __MeasureDockedPanelsDesiredSize(_root, _panels)
	/// @desc Internal: measure desired content size for a docked panel set.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Array<Struct.EchoChamberPanel>} _panels
	/// @return {Struct} {w,h}
	static __MeasureDockedPanelsDesiredSize = function(_root, _panels) {
		var _top_h = 0;
		var _bottom_h = 0;
		var _left_w = 0;
		var _right_w = 0;

		var _top_w = 0;
		var _bottom_w = 0;
		var _left_h = 0;
		var _right_h = 0;

		var _fill_w = 0;
		var _fill_h = 0;

		var _len = array_length(_panels);
		for (var _i = 0; _i < _len; _i++) {
			var _p = _panels[_i];
			var _outer = __MeasurePanelDesiredOuterSize(_root, _p);
			var _fixed = (_p.size_mode == eEchoChamberPanelSizeMode.FIXED);
			var _thick_w = _fixed ? max(_p.size, _outer.w) : _outer.w;
			var _thick_h = _fixed ? max(_p.size, _outer.h) : _outer.h;

			switch (_p.dock) {
				case eEchoChamberDock.TOP:
					_top_h += _thick_h;
					if (_outer.w > _top_w) _top_w = _outer.w;
				break;
				case eEchoChamberDock.BOTTOM:
					_bottom_h += _thick_h;
					if (_outer.w > _bottom_w) _bottom_w = _outer.w;
				break;
				case eEchoChamberDock.LEFT:
					_left_w += _thick_w;
					if (_outer.h > _left_h) _left_h = _outer.h;
				break;
				case eEchoChamberDock.RIGHT:
					_right_w += _thick_w;
					if (_outer.h > _right_h) _right_h = _outer.h;
				break;
				case eEchoChamberDock.FILL:
					if (_outer.w > _fill_w) _fill_w = _outer.w;
					if (_outer.h > _fill_h) _fill_h = _outer.h;
				break;
			}
		}

		var _w = max(_left_w + _right_w + _fill_w, _top_w, _bottom_w);
		var _h = max(_top_h + _bottom_h + _fill_h, _left_h, _right_h);
		return { w: _w, h: _h };
	};

	/// @ignore
	/// @desc Internal: queue a FitToContent for the end of the layout batch.
	/// @param {Struct.EchoChamberRoot} [_root]
	/// @param {Bool} [_respect_user]
	/// @return {Bool}
	static __QueueLayoutBatchFit = function(_root = undefined, _respect_user = false) {
		if (layout_batch_depth <= 0) {
			return false;
		}
		layout_batch_pending_fit = true;
		if (is_instanceof(_root, EchoChamberRoot)) {
			layout_batch_pending_root = _root;
		}
		else if (is_undefined(layout_batch_pending_root) && is_instanceof(owner_root, EchoChamberRoot)) {
			layout_batch_pending_root = owner_root;
		}
		if (_respect_user) {
			layout_batch_pending_respect = true;
		}
		return true;
	};

	/// @desc Begin a layout batch (defers FitToContent calls until EndLayoutBatch).
	/// @return {Struct.EchoChamberWindow}
	static BeginLayoutBatch = function() {
		layout_batch_depth += 1;
		return self;
	};

	/// @desc End a layout batch and apply any deferred FitToContent.
	/// @return {Struct.EchoChamberWindow}
	static EndLayoutBatch = function() {
		if (layout_batch_depth <= 0) {
			layout_batch_depth = 0;
			return self;
		}
		layout_batch_depth -= 1;
		if (layout_batch_depth > 0) {
			return self;
		}
		if (layout_batch_pending_fit) {
			var _r = is_undefined(owner_root) ? layout_batch_pending_root : owner_root;
			var _respect = layout_batch_pending_respect;
			layout_batch_pending_fit = false;
			layout_batch_pending_root = undefined;
			layout_batch_pending_respect = false;
			__FitToContent(_r, _respect);
		}
		return self;
	};

	/// @desc Set whether this window auto-fits to content after layout changes.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberWindow}
	static SetAutoFit = function(_flag) {
		auto_fit = (_flag == true);
		if (auto_fit) {
			if (layout_batch_depth > 0) {
				__QueueLayoutBatchFit(owner_root, false);
			}
			else {
				var _r = is_undefined(owner_root) ? fit_to_content_pending_root : owner_root;
				__FitToContent(_r, false);
			}
		}
		return self;
	};

	/// @desc Resize this window to fit its panels' content.
	/// @param {Struct.EchoChamberRoot} [_root]
	/// @return {Struct.EchoChamberWindow}
	static FitToContent = function(_root = undefined) {
		return __FitToContent(_root, false);
	};

	/// @ignore
	/// @func __FitToContent(_root, _respect_user)
	/// @desc Internal: resize this window to fit its panels' content.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Bool} _respect_user
	static __FitToContent = function(_root, _respect_user) {
		if (layout_batch_depth > 0) {
			__QueueLayoutBatchFit(_root, _respect_user);
			return self;
		}
		if (array_length(panels) <= 0) {
			fit_to_content_on_add = true;
			fit_to_content_pending_root = _root;
			fit_to_content_pending_respect = _respect_user;
			return self;
		}
		if (_respect_user && user_set_rect) {
			return self;
		}
		var _r = is_undefined(_root) ? owner_root : _root;
		if (!is_instanceof(_r, EchoChamberRoot)) {
			return self;
		}

		var _pushed = _r.__PushWindowTheme(self);
		_r.__ApplyThemeDefaultsToWindow(self);
		__ApplyThemeDefaultsToPanels(_r);
		if (_pushed) {
			_r.__PopThemeOverride();
		}

		var _content = __MeasureDockedPanelsDesiredSize(_r, panels);
		var _w = _content.w + (padding * 2);
		var _h = _content.h + (padding * 2) + titlebar_height;
		_w = max(0, _w);
		_h = max(0, _h);

		var _title_str = string(title);
		var _old_font = draw_get_font();
		var _font_header = _r.theme.font_header ?? _r.theme.font_body;
		draw_set_font(_font_header);
		var _title_w = string_width(_title_str);
		draw_set_font(_old_font);

		var _btn_gap = 4;
		var _btn_sz = 14;
		_btn_gap = _r.theme.window_button_gap ?? _btn_gap;
		_btn_sz = _r.theme.window_button_size ?? _btn_sz;
		if (_btn_sz <= 0) {
			_btn_sz = max(12, titlebar_height - 6);
		}
		var _btn_count = 0;
		if (show_close_button) {
			_btn_count += 1;
		}
		if (show_minimize_button) {
			_btn_count += 1;
		}
		if (show_pin_button) {
			_btn_count += 1;
		}
		var _btn_w = (_btn_count > 0) ? (_btn_count * (_btn_sz + _btn_gap)) : 0;
		var _title_required = _title_w + _btn_w + (padding * 2);
		var _title_cap = max(0, display_get_gui_width() - 64);
		if (_title_cap > 0) {
			_title_required = min(_title_required, _title_cap);
		}
		if (_title_required > 0) {
			_w = max(_w, _title_required);
		}
		if (user_set_min) {
			_w = max(_w, min_width);
			_h = max(_h, min_height);
		}
		if (user_set_max) {
			if (max_width > 0) _w = min(_w, max_width);
			if (max_height > 0) _h = min(_h, max_height);
		}

		if (!user_set_min && !user_set_max) {
			__SetMinSizeDirect(_w, _h);
		}
		__SetRectDirect(rect.x1, rect.y1, rect.x1 + _w, rect.y1 + _h);
		return self;
	};


	/// @desc Layout this window's panels into the current content rect.
	/// @param {Struct.EchoChamberRoot} _root
	static LayoutPanels = function(_root) {
		var _content = __GetContentRect();
		__EchoChamberAssignPanelRects(_root, panels, _content.x1, _content.y1, _content.x2, _content.y2);
	};

	/// @ignore
	/// @func __IsPanelCollapseHandleHit(_panel, _mx, _my, _size)
	/// @param {Struct.EchoChamberPanel} _panel
	/// @param {Real} _mx
	/// @param {Real} _my
	/// @param {Real} _size
	/// @return {Bool}
	static __IsPanelCollapseHandleHit = function(_panel, _mx, _my, _size) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return false;
		}
		if (_panel.collapse_mode != eEchoChamberCollapse.NONE) {
			var _x1 = _panel.rect.x1;
			var _y1 = _panel.rect.y1;
			var _x2 = _panel.rect.x2;
			var _y2 = _panel.rect.y2;
			var _hx1, _hy1, _hx2, _hy2;
			switch (_panel.collapse_mode) {
				case eEchoChamberCollapse.TO_TOP:
					_hx1 = _x1;
					_hx2 = _x2;
					_hy2 = _y2;
					_hy1 = _hy2 - _size;
				break;
				case eEchoChamberCollapse.TO_BOTTOM:
					_hx1 = _x1;
					_hx2 = _x2;
					_hy1 = _y1;
					_hy2 = _y1 + _size;
				break;
				case eEchoChamberCollapse.TO_LEFT:
					_hy1 = _y1;
					_hy2 = _y2;
					_hx2 = _x2;
					_hx1 = _hx2 - _size;
				break;
				case eEchoChamberCollapse.TO_RIGHT:
					_hy1 = _y1;
					_hy2 = _y2;
					_hx1 = _x1;
					_hx2 = _x1 + _size;
				break;
			}
			if (_mx >= _hx1 && _mx <= _hx2 && _my >= _hy1 && _my <= _hy2) {
				return true;
			}
		}
		if (_panel.is_container && is_array(_panel.children_panels)) {
			var _len = array_length(_panel.children_panels);
			for (var _i = 0; _i < _len; _i++) {
				if (__IsPanelCollapseHandleHit(_panel.children_panels[_i], _mx, _my, _size)) {
					return true;
				}
			}
		}
		return false;
	};

	/// @ignore
	/// @func __IsAnyCollapseHandleHit(_root, _mx, _my)
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _mx
	/// @param {Real} _my
	/// @return {Bool}
	static __IsAnyCollapseHandleHit = function(_root, _mx, _my) {
		var _size = _root.theme[$ "panel_collapse_handle_size"] ?? 8;
		var _len = array_length(panels);
		for (var _i = 0; _i < _len; _i++) {
			if (__IsPanelCollapseHandleHit(panels[_i], _mx, _my, _size)) {
				return true;
			}
		}
		return false;
	};

	/// @desc Handle mouse interactions for dragging/resizing and chrome button clicks.
	/// @param {Struct.EchoChamberRoot} _root
	static ProcessWindowInteractions = function(_root) {
		if (!visible) {
			return;
		}
		var _mx = _root.mx;
		var _my = _root.my;
		var _x1 = rect.x1;
		var _y1 = rect.y1;
		var _x2 = rect.x2;
		var _y2 = rect.y2;
		var _header_y2 = _y1 + titlebar_height;
		if (is_dragging) {
			if (!_root.mouse_l_down) {
				is_dragging = false;
				_root.ClearMouseCapture(self);
				__EnsureTitlebarVisible(_root.window_min_visible_titlebar_w, _root.window_min_visible_titlebar_h, true);
				return;
			}
			var _old_x1 = rect.x1;
			var _old_y1 = rect.y1;
			var _old_x2 = rect.x2;
			var _old_y2 = rect.y2;
			var _w = _x2 - _x1;
			var _h = _y2 - _y1;
			var _nx1 = _mx - drag_offset_x;
			var _ny1 = _my - drag_offset_y;
			var _min_w = _root.window_min_visible_titlebar_w;
			var _min_h = _root.window_min_visible_titlebar_h;
			var _pos = __ClampTitlebarPosition(_nx1, _ny1, _min_w, _min_h);
			rect.x1 = _pos.x;
			rect.y1 = _pos.y;
			rect.x2 = _pos.x + _w;
			rect.y2 = _pos.y + _h;
			__NotifyMoveResize(_old_x1, _old_y1, _old_x2, _old_y2);
			_root.ConsumeMouse();
			return;
		}
		if (is_resizing) {
			if (!_root.mouse_l_down) {
				is_resizing = false;
				_root.ClearMouseCapture(self);
				return;
			}
			var _old_x1r = rect.x1;
			var _old_y1r = rect.y1;
			var _old_x2r = rect.x2;
			var _old_y2r = rect.y2;
			var _new_w = resize_start_w;
			var _new_h = resize_start_h;
			if (resize_edge_x < 0) {
				_new_w = resize_start_w - (_mx - resize_start_mouse_x);
			}
			else if (resize_edge_x > 0) {
				_new_w = resize_start_w + (_mx - resize_start_mouse_x);
			}
			if (resize_edge_y > 0) {
				_new_h = resize_start_h + (_my - resize_start_mouse_y);
			}
			_new_w = max(min_width, _new_w);
			_new_h = max(min_height, _new_h);
			if (max_width > 0) _new_w = min(_new_w, max_width);
			if (max_height > 0) _new_h = min(_new_h, max_height);
			var _new_x1 = resize_start_x1;
			var _new_x2 = resize_start_x2;
			var _new_y1 = resize_start_y1;
			var _new_y2 = _new_y1 + _new_h;
			if (resize_edge_x < 0) {
				_new_x1 = resize_start_x2 - _new_w;
				_new_x2 = resize_start_x2;
			}
			else if (resize_edge_x > 0) {
				_new_x1 = resize_start_x1;
				_new_x2 = resize_start_x1 + _new_w;
			}
			rect.x1 = _new_x1;
			rect.x2 = _new_x2;
			rect.y1 = _new_y1;
			rect.y2 = _new_y2;
			user_set_rect = true;
			__NotifyMoveResize(_old_x1r, _old_y1r, _old_x2r, _old_y2r);
			_root.ConsumeMouse();
			return;
		}
		var _header_hit = (_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _header_y2);
		var _layout = __GetHeaderButtonLayout(_root);

		// Header button clicks (before drag)
		if (_root.mouse_l_pressed && !_root.mouse_consumed) {
			if (is_struct(_layout.close_rect)) {
				var _r0 = _layout.close_rect;
				if (_mx >= _r0.x1 && _mx <= _r0.x2 && _my >= _r0.y1 && _my <= _r0.y2) {
					_root.BringWindowToFront(self);
					Close();
					_root.ConsumeMouse();
					return;
				}
			}
			if (is_struct(_layout.min_rect)) {
				var _r1 = _layout.min_rect;
				if (_mx >= _r1.x1 && _mx <= _r1.x2 && _my >= _r1.y1 && _my <= _r1.y2) {
					_root.BringWindowToFront(self);
					ToggleMinimized();
					_root.ConsumeMouse();
					return;
				}
			}
			if (is_struct(_layout.pin_rect)) {
				var _r2 = _layout.pin_rect;
				if (_mx >= _r2.x1 && _mx <= _r2.x2 && _my >= _r2.y1 && _my <= _r2.y2) {
					_root.BringWindowToFront(self);
					TogglePinned();
					_root.ConsumeMouse();
					return;
				}
			}
		}

		// Drag (header)
		if (!is_pinned && _header_hit && _root.mouse_l_pressed && !_root.mouse_consumed) {
			is_dragging = true;
			drag_offset_x = _mx - _x1;
			drag_offset_y = _my - _y1;
			_root.SetMouseCapture(self);
			_root.BringWindowToFront(self);
			_root.ConsumeMouse();
			return;
		}

		// Resize (edges + bottom corners, but not top)
		var _grip = resize_grip_size;
		var _edge_x = 0;
		var _edge_y = 0;
		if (_mx >= _x1 && _mx <= _x1 + _grip) {
			_edge_x = -1;
		}
		else if (_mx >= _x2 - _grip && _mx <= _x2) {
			_edge_x = 1;
		}
		if (_my >= _y2 - _grip && _my <= _y2) {
			_edge_y = 1;
		}
		var _resize_hit = (_edge_x != 0) || (_edge_y != 0);
		if (_resize_hit && __IsAnyCollapseHandleHit(_root, _mx, _my)) {
			_resize_hit = false;
		}
		if (!is_pinned && !is_minimized && _resize_hit && _root.mouse_l_pressed && !_root.mouse_consumed) {
			is_resizing = true;
			resize_start_w = max(min_width, _x2 - _x1);
			resize_start_h = max(min_height, _y2 - _y1);
			resize_start_mouse_x = _mx;
			resize_start_mouse_y = _my;
			resize_start_x1 = _x1;
			resize_start_x2 = _x2;
			resize_start_y1 = _y1;
			resize_edge_x = _edge_x;
			resize_edge_y = _edge_y;
			_root.SetMouseCapture(self);
			_root.BringWindowToFront(self);
			_root.ConsumeMouse();
			return;
		}

		// Focus click (anywhere in window)
		if ((_mx >= _x1 && _mx <= _x2 && _my >= _y1 && _my <= _y2) && _root.mouse_l_pressed && !_root.mouse_consumed) {
			_root.__RequestFocusConsume(self);
			_root.BringWindowToFront(self);
		}
	};

	/// @desc Draw the window chrome and all owned panels.
	/// @param {Struct.EchoChamberRoot} _root
	static Draw = function(_root) {
		if (!visible) {
			return;
		}
		_root.__SetCurrentWindow(self);

		// Ensure theme-driven metrics are applied for this window and its panels.
		_root.__ApplyThemeDefaultsToWindow(self);
		__ApplyThemeDefaultsToPanels(_root);

		var _x1 = rect.x1;
		var _y1 = rect.y1;
		var _x2 = rect.x2;
		var _y2 = rect.y2;
		_root.PushClipRect(_x1, _y1, _x2, _y2);
		var _theme = _root.theme;
		var _header_y2 = _y1 + titlebar_height;

		// Window style
		var _wst = undefined;
		if (is_instanceof(_theme, EchoChamberTheme)) {
			var _styles = _theme.window_styles;
			if (is_struct(_styles)) {
				_wst = _styles[$ window_style_key];
				if (is_undefined(_wst)) {
					_wst = _styles[$ "_default"];
				}
			}
		}
		var _w_bg = is_struct(_wst) ? (_wst[$ "bg"] ?? _theme.col_window_bg) : _theme.col_window_bg;
		var _w_bd = is_struct(_wst) ? (_wst[$ "border"] ?? _theme.col_accent) : _theme.col_accent;
		var _w_a  = is_struct(_wst) ? (_wst[$ "bg_alpha"] ?? 0.95) : 0.95;

		// Header style
		var _hst = undefined;
		if (is_instanceof(_theme, EchoChamberTheme)) {
			var _hstyles = _theme.header_styles;
			if (is_struct(_hstyles)) {
				_hst = _hstyles[$ header_style_key];
				if (is_undefined(_hst)) {
					_hst = _hstyles[$ "_default"];
				}
			}
		}
		var _h_bg = is_struct(_hst) ? (_hst[$ "bg"] ?? _theme.col_panel_bg) : _theme.col_panel_bg;
		var _h_bd = is_struct(_hst) ? (_hst[$ "border"] ?? _theme.col_accent) : _theme.col_accent;
		var _h_a  = is_struct(_hst) ? (_hst[$ "bg_alpha"] ?? 1) : 1;
		var _title_col = is_struct(_hst) ? (_hst[$ "text"] ?? _theme.col_text) : _theme.col_text;

		// Draw window background
		var _old_alpha = draw_get_alpha();
		draw_set_alpha(_w_a);
		draw_set_color(_w_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		draw_set_alpha(_old_alpha);

		draw_set_color(_w_bd);
		draw_rectangle(_x1, _y1, _x2, _y2, true);

		// Draw header
		draw_set_alpha(_h_a);
		draw_set_color(_h_bg);
		draw_rectangle(_x1, _y1, _x2, _header_y2, false);
		draw_set_alpha(_old_alpha);

		draw_set_color(_h_bd);
		draw_rectangle(_x1, _y1, _x2, _header_y2, true);

		// Header buttons (layout + draw)
		var _layout = __GetHeaderButtonLayout(_root);

		// Title text (trim to avoid header buttons)
		var _old_font = draw_get_font();
		var _font_header = _theme.font_header ?? _theme.font_body;
		draw_set_font(_font_header);
		draw_set_color(_title_col);
		var _title_str = string(title);
		var _title_left = _x1 + padding;
		var _title_right = max(_title_left, _layout.title_max_x);
		var _max_w = max(0, _title_right - _title_left);
		var _draw_title = __TrimTextToWidth(_title_str, _max_w, _font_header);
		var _text_h = string_height(_draw_title);
		var _title_y = _y1 + (titlebar_height - _text_h) * 0.5;
		draw_text(_title_left, _title_y, _draw_title);
		draw_set_font(_old_font);

		// Draw chrome buttons
		if (is_struct(_layout.close_rect)) {
			__DrawHeaderButton(_root, _layout.close_rect, _layout.close_label, _layout.style_close, false);
			if (_root.HitTestRect(_layout.close_rect.x1, _layout.close_rect.y1, _layout.close_rect.x2, _layout.close_rect.y2)) {
				_root.RequestTooltip("__window_close:" + id, "Close", _root.mx, _root.my);
			}
		}
		if (is_struct(_layout.min_rect)) {
			var _lbl_min = is_minimized ? _layout.restore_label : _layout.min_label;
			__DrawHeaderButton(_root, _layout.min_rect, _lbl_min, _layout.style_min, is_minimized);
			if (_root.HitTestRect(_layout.min_rect.x1, _layout.min_rect.y1, _layout.min_rect.x2, _layout.min_rect.y2)) {
				_root.RequestTooltip("__window_min:" + id, is_minimized ? "Restore" : "Minimize", _root.mx, _root.my);
			}
		}
		if (is_struct(_layout.pin_rect)) {
			var _lbl_pin = is_pinned ? _layout.unpin_label : _layout.pin_label;
			__DrawHeaderButton(_root, _layout.pin_rect, _lbl_pin, _layout.style_pin, is_pinned);
			if (_root.HitTestRect(_layout.pin_rect.x1, _layout.pin_rect.y1, _layout.pin_rect.x2, _layout.pin_rect.y2)) {
				_root.RequestTooltip("__window_pin:" + id, is_pinned ? "Unpin" : "Pin", _root.mx, _root.my);
			}
		}

		// Panels (skip when minimized)
		if (!is_minimized) {
			LayoutPanels(_root);
			// Give dock splitters first chance at clicks so controls overlapping the splitter hit zone cannot steal the drag.
			var _content2 = __GetContentRect();
			_root.__DrawAndProcessPanelSplitters(panels, _content2.x1, _content2.y1, _content2.x2, _content2.y2);
			var _plen = array_length(panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				var _p = panels[_pi];
				_p.Draw(_root);
			}
			_root.__DrawAndProcessPanelSplitters(panels, _content2.x1, _content2.y1, _content2.x2, _content2.y2);
		}

		_root.PopClipRect();
		_root.__SetCurrentWindow(undefined);
	};
	
	// Default window sizing metrics.
	SetMinSize(0, 0);
	SetPadding(8);
	SetResizeGripSize(14);
	titlebar_height = 0;
	titlebar_auto   = true;
}

/// @func EchoChamberPanel(_id, _dock)
/// @desc Layout panel docked to an edge or fill.
/// @param {Any} _id
/// @param {eEchoChamberDock} _dock
/// @return {Struct.EchoChamberPanel}
function EchoChamberPanel(_id, _dock) constructor {
	id             = string(_id);
	dock           = _dock;
	owner_root     = undefined;
	owner_window   = undefined;
	owner_panel    = undefined;
	collapse_mode  = eEchoChamberCollapse.NONE;
	collapsed      = false;

	rect = { x1: 0, y1: 0, x2: 0, y2: 0 };

	style_key  = "_default";
	__theme_defaults_applied = false;
	flow       = eEchoChamberPanelFlow.ROW;
	content_draw = undefined;
	min_size   = 0;
	max_size   = 1048576;
	margin_x   = 0;
	margin_y   = 0;
	field_label_placement = eEchoChamberFieldLabelPlacement.AUTO;
	field_label_gap = 6;
	field_label_width = -1;
	field_label_min_width = 60;
	field_label_max_width = 220;
	field_label_align_leading = "right";
	field_label_align_above = "left";
	field_label_style_id = "_field";
	__field_label_placement_user_set = false;
	__field_label_gap_user_set = false;
	__field_label_width_user_set = false;
	__field_label_width_clamp_user_set = false;
	__field_label_style_user_set = false;

	children_controls = [];
	children_panels   = []; // for container-style panels later
	is_container      = false;
	scroll_enabled    = false;
	scroll_state      = undefined;

	/// @ignore
	/// @desc Internal: mark the owning window for a batched FitToContent.
	/// @param {Bool} [_respect_user]
	/// @return {Bool}
	static __MarkWindowLayoutDirty = function(_respect_user = false) {
		if (!is_instanceof(owner_window, EchoChamberWindow)) {
			return false;
		}
		var _win = owner_window;
		var _r = is_instanceof(_win.owner_root, EchoChamberRoot)
		? _win.owner_root
		: _win.fit_to_content_pending_root;
		if (_win.layout_batch_depth > 0) {
			return _win.__QueueLayoutBatchFit(_r, _respect_user);
		}
		if (_win.auto_fit) {
			_win.__FitToContent(_r, _respect_user);
			return true;
		}
		return false;
	};

	/// @desc Add a control to this panel.
	/// @param {Struct.EchoChamberControlBase} _control
	static AddControl = function(_control) {
		if (!is_instanceof(_control, EchoChamberControlBase)) {
			return undefined;
		}
		_control.owner_root   = owner_root;
		_control.owner_window = owner_window;
		_control.owner_panel  = self;
		array_push(children_controls, _control);
		var _win = owner_window;
		if (is_instanceof(_win, EchoChamberWindow) && _win.layout_batch_depth > 0) {
			var _respect = _win.fit_to_content_on_add ? _win.fit_to_content_pending_respect : false;
			__MarkWindowLayoutDirty(_respect);
			if (_win.fit_to_content_on_add) {
				_win.fit_to_content_on_add = false;
				_win.fit_to_content_pending_root = undefined;
				_win.fit_to_content_pending_respect = true;
			}
		}
		else if (!is_undefined(_win) && _win.fit_to_content_on_add) {
			var _r = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r, _win.fit_to_content_pending_respect);
			_win.fit_to_content_on_add = false;
			_win.fit_to_content_pending_root = undefined;
			_win.fit_to_content_pending_respect = true;
		}
		else if (!is_undefined(_win) && _win.auto_fit) {
			var _r2 = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r2, false);
		}
		return _control;
	};

	/// @ignore
	/// @desc Internal: insert a control at a specific index (clamped).
	/// @param {Struct.EchoChamberControlBase} _control
	/// @param {Real} _index
	static __InsertControlAt = function(_control, _index) {
		var _len = array_length(children_controls);
		var _idx = floor(_index ?? _len);
		_idx = clamp(_idx, 0, _len);
		if (_idx >= _len) {
			array_push(children_controls, _control);
			return;
		}
		array_push(children_controls, children_controls[_len - 1]);
		for (var _i = _len - 1; _i > _idx; _i--) {
			children_controls[_i] = children_controls[_i - 1];
		}
		children_controls[_idx] = _control;
	};

	/// @desc Insert a control at a specific index (clamped).
	/// @param {Struct.EchoChamberControlBase} _control
	/// @param {Real} _index
	/// @return {Struct.EchoChamberControlBase}
	static InsertControl = function(_control, _index) {
		if (!is_instanceof(_control, EchoChamberControlBase)) {
			return undefined;
		}
		if (is_instanceof(_control.owner_panel, EchoChamberPanel) && _control.owner_panel != self) {
			_control.owner_panel.RemoveControl(_control);
		}
		_control.owner_root   = owner_root;
		_control.owner_window = owner_window;
		_control.owner_panel  = self;
		__InsertControlAt(_control, _index);

		var _win = owner_window;
		if (is_instanceof(_win, EchoChamberWindow) && _win.layout_batch_depth > 0) {
			var _respect = _win.fit_to_content_on_add ? _win.fit_to_content_pending_respect : false;
			__MarkWindowLayoutDirty(_respect);
			if (_win.fit_to_content_on_add) {
				_win.fit_to_content_on_add = false;
				_win.fit_to_content_pending_root = undefined;
				_win.fit_to_content_pending_respect = true;
			}
		}
		else if (!is_undefined(_win) && _win.fit_to_content_on_add) {
			var _r = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r, _win.fit_to_content_pending_respect);
			_win.fit_to_content_on_add = false;
			_win.fit_to_content_pending_root = undefined;
			_win.fit_to_content_pending_respect = true;
		}
		else if (!is_undefined(_win) && _win.auto_fit) {
			var _r2 = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r2, false);
		}
		return _control;
	};

	/// @desc Reorder a direct control to a specific index (clamped).
	/// @param {Any} _control_or_id
	/// @param {Real} _index
	/// @return {Bool}
	static MoveControl = function(_control_or_id, _index) {
		var _id_str = "";
		if (is_instanceof(_control_or_id, EchoChamberControlBase)) {
			_id_str = string(_control_or_id.id);
		}
		else {
			_id_str = string(_control_or_id);
		}
		if (string_length(_id_str) <= 0) {
			return false;
		}

		var _len = array_length(children_controls);
		var _from = -1;
		for (var _i = 0; _i < _len; _i++) {
			if (children_controls[_i].id == _id_str) {
				_from = _i;
				break;
			}
		}
		if (_from < 0) {
			return false;
		}
		var _control = children_controls[_from];
		array_delete(children_controls, _from, 1);
		__InsertControlAt(_control, _index);
		__MarkWindowLayoutDirty(false);
		return true;
	};

	/// @desc Move a control to another panel (direct or nested in this panel).
	/// @param {Any} _control_or_id
	/// @param {Struct.EchoChamberPanel} _target_panel
	/// @param {Real} [_index]
	/// @return {Bool}
	static MoveControlToPanel = function(_control_or_id, _target_panel, _index = undefined) {
		if (!is_instanceof(_target_panel, EchoChamberPanel)) {
			return false;
		}
		var _control = undefined;
		if (is_instanceof(_control_or_id, EchoChamberControlBase)) {
			_control = _control_or_id;
		}
		else {
			_control = FindControl(_control_or_id);
		}
		if (!is_instanceof(_control, EchoChamberControlBase)) {
			return false;
		}
		if (!RemoveControl(_control)) {
			return false;
		}
		_target_panel.InsertControl(_control, _index);
		return true;
	};

	/// @desc Reorder direct controls using a list of ids (unlisted items keep their relative order at the end).
	/// @param {Array<Any>} _ids
	/// @return {Struct.EchoChamberPanel}
	static SetControlOrder = function(_ids) {
		if (!is_array(_ids)) {
			return self;
		}
		var _used = {};
		var _result = [];

		var _id_len = array_length(_ids);
		for (var _i = 0; _i < _id_len; _i++) {
			var _id_str = string(_ids[_i]);
			if (string_length(_id_str) <= 0) {
				continue;
			}
			var _clen = array_length(children_controls);
			for (var _c = 0; _c < _clen; _c++) {
				var _ctrl = children_controls[_c];
				if (_ctrl.id == _id_str && is_undefined(_used[$ _id_str])) {
					array_push(_result, _ctrl);
					_used[$ _id_str] = true;
					break;
				}
			}
		}

		var _len = array_length(children_controls);
		for (var _j = 0; _j < _len; _j++) {
			var _ctrl = children_controls[_j];
			if (is_undefined(_used[$ _ctrl.id])) {
				array_push(_result, _ctrl);
				_used[$ _ctrl.id] = true;
			}
		}

		children_controls = _result;
		__MarkWindowLayoutDirty(false);
		return self;
	};

	/// @desc Remove a control from this panel (direct or nested).
	/// @param {Any} _control_or_id
	/// @return {Bool}
	static RemoveControl = function(_control_or_id) {
		var _control = undefined;
		var _id_str = "";
		if (is_instanceof(_control_or_id, EchoChamberControlBase)) {
			_control = _control_or_id;
			_id_str = string(_control.id);
		}
		else {
			_id_str = string(_control_or_id);
		}
		if (string_length(_id_str) <= 0) {
			return false;
		}

		var _len = array_length(children_controls);
		for (var _i = 0; _i < _len; _i++) {
			var _c = children_controls[_i];
			if (_c == _control || _c.id == _id_str) {
				array_delete(children_controls, _i, 1);
				if (is_instanceof(owner_root, EchoChamberRoot)) {
					owner_root.__CleanupControlState(_c.id, owner_window);
				}
				_c.owner_root   = undefined;
				_c.owner_window = undefined;
				_c.owner_panel  = undefined;
				__MarkWindowLayoutDirty(false);
				return true;
			}
		}

		if (is_container) {
			var _plen = array_length(children_panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				if (children_panels[_pi].RemoveControl(_control_or_id)) {
					return true;
				}
			}
		}

		return false;
	};

	/// @desc Remove all direct controls from this panel.
	/// @return {Struct.EchoChamberPanel}
	static ClearControls = function() {
		var _len = array_length(children_controls);
		for (var _i = 0; _i < _len; _i++) {
			var _c = children_controls[_i];
			if (is_instanceof(owner_root, EchoChamberRoot)) {
				owner_root.__CleanupControlState(_c.id, owner_window);
			}
			_c.owner_root   = undefined;
			_c.owner_window = undefined;
			_c.owner_panel  = undefined;
		}
		children_controls = [];
		__MarkWindowLayoutDirty(false);
		return self;
	};

	/// @desc Add a child panel (for panel container usage).
	/// @param {Struct.EchoChamberPanel} _panel
	static AddChildPanel = function(_panel) {
		is_container = true;
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return undefined;
		}
		_panel.owner_root   = owner_root;
		_panel.owner_window = owner_window;
		_panel.owner_panel  = self;
		array_push(children_panels, _panel);
		var _win = owner_window;
		if (is_instanceof(_win, EchoChamberWindow) && _win.layout_batch_depth > 0) {
			var _respect = _win.fit_to_content_on_add ? _win.fit_to_content_pending_respect : false;
			__MarkWindowLayoutDirty(_respect);
			if (_win.fit_to_content_on_add) {
				_win.fit_to_content_on_add = false;
				_win.fit_to_content_pending_root = undefined;
				_win.fit_to_content_pending_respect = true;
			}
		}
		else if (!is_undefined(_win) && _win.fit_to_content_on_add) {
			var _r = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r, _win.fit_to_content_pending_respect);
			_win.fit_to_content_on_add = false;
			_win.fit_to_content_pending_root = undefined;
			_win.fit_to_content_pending_respect = true;
		}
		else if (!is_undefined(_win) && _win.auto_fit) {
			var _r2 = is_undefined(_win.owner_root) ? _win.fit_to_content_pending_root : _win.owner_root;
			_win.__FitToContent(_r2, false);
		}
		return _panel;
	};

	/// @desc Remove a child panel from this panel (direct or nested).
	/// @param {Any} _panel_or_id
	/// @return {Bool}
	static RemoveChildPanel = function(_panel_or_id) {
		var _panel = undefined;
		var _id_str = "";
		if (is_instanceof(_panel_or_id, EchoChamberPanel)) {
			_panel = _panel_or_id;
			_id_str = string(_panel.id);
		}
		else {
			_id_str = string(_panel_or_id);
		}
		if (string_length(_id_str) <= 0) {
			return false;
		}

		var _len = array_length(children_panels);
		for (var _i = 0; _i < _len; _i++) {
			var _p = children_panels[_i];
			if (_p == _panel || _p.id == _id_str) {
				array_delete(children_panels, _i, 1);
				if (is_instanceof(owner_root, EchoChamberRoot)) {
					owner_root.__DetachPanelRecursive(_p);
				}
				else {
					__DetachPanelLocal(_p);
				}
				is_container = array_length(children_panels) > 0;
				__MarkWindowLayoutDirty(false);
				return true;
			}
		}

		if (is_container) {
			var _len2 = array_length(children_panels);
			for (var _j = 0; _j < _len2; _j++) {
				if (children_panels[_j].RemoveChildPanel(_panel_or_id)) {
					return true;
				}
			}
		}

		return false;
	};

	/// @desc Remove all child panels from this panel.
	/// @return {Struct.EchoChamberPanel}
	static ClearChildPanels = function() {
		var _plen = array_length(children_panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _panel = children_panels[_pi];
			if (is_instanceof(owner_root, EchoChamberRoot)) {
				owner_root.__DetachPanelRecursive(_panel);
			}
			else {
				__DetachPanelLocal(_panel);
			}
		}
		children_panels = [];
		is_container = false;
		__MarkWindowLayoutDirty(false);
		return self;
	};

	/// @ignore
	/// @func __DetachPanelLocal(_panel)
	/// @desc Internal: detach a panel tree without root context.
	/// @param {Struct.EchoChamberPanel} _panel
	static __DetachPanelLocal = function(_panel) {
		if (!is_instanceof(_panel, EchoChamberPanel)) {
			return;
		}
		_panel.owner_root   = undefined;
		_panel.owner_window = undefined;
		_panel.owner_panel  = undefined;

		var _clen = array_length(_panel.children_controls);
		for (var _ci = 0; _ci < _clen; _ci++) {
			var _ctrl = _panel.children_controls[_ci];
			_ctrl.owner_root   = undefined;
			_ctrl.owner_window = undefined;
			_ctrl.owner_panel  = undefined;
		}

		var _plen = array_length(_panel.children_panels);
		for (var _pi = 0; _pi < _plen; _pi++) {
			var _child = _panel.children_panels[_pi];
			__DetachPanelLocal(_child);
		}
	};

	/// @desc Find a direct or nested control within this panel by id.
	/// @param {Any} _id
	/// @return {Struct.EchoChamberControlBase}
	static FindControl = function(_id) {
		var _id_str = string(_id);
		var _len = array_length(children_controls);
		for (var _i = 0; _i < _len; _i++) {
			var _c = children_controls[_i];
			if (_c.id == _id_str) {
				return _c;
			}
		}
		// Search child panels if this is a container
		if (is_container) {
			var _plen = array_length(children_panels);
			for (var _pi = 0; _pi < _plen; _pi++) {
				var _p = children_panels[_pi];
				var _found = _p.FindControl(_id_str);
				if (!is_undefined(_found)) {
					return _found;
				}
			}
		}
		return undefined;
	};

	/// @desc Configure how this panel resolves its dock size.
	/// @param {eEchoChamberPanelSizeMode} _mode
	static SetSizeMode = function(_mode) {
		if (_mode == eEchoChamberPanelSizeMode.FIT_CONTENT) {
			size_mode = eEchoChamberPanelSizeMode.FIT_CONTENT;
		}
		else {
			size_mode = eEchoChamberPanelSizeMode.FIXED;
		}
		return self;
	};

	/// @desc Set dock thickness when using fixed sizing.
	/// @param {Real} _value
	static SetSize = function(_value) {
		size = max(0, _value);
		if (max_size < size) {
			max_size = size;
		}
		return self;
	};

	/// @desc Set how child controls flow within the panel.
	/// @param {eEchoChamberPanelFlow} _flow_mode
	static SetFlowMode = function(_flow_mode) {
		if (_flow_mode == eEchoChamberPanelFlow.COLUMN) {
			flow = eEchoChamberPanelFlow.COLUMN;
		}
		else {
			flow = eEchoChamberPanelFlow.ROW;
		}
		return self;
	};

	/// @desc Set whether this panel scrolls its contents vertically when content overflows.
	/// @param {Bool} _flag
	/// @return {Struct.EchoChamberPanel}
	static SetScrollable = function(_flag) {
		scroll_enabled = (_flag == true);
		if (scroll_enabled && !is_instanceof(scroll_state, EchoChamberScrollState)) {
			scroll_state = new EchoChamberScrollState("__panel_scroll:" + id);
		}
		return self;
	};

	/// @desc Assign a scroll state for this panel (used when scrollable).
	/// @param {Struct.EchoChamberScrollState} _state
	/// @return {Struct.EchoChamberPanel}
	static SetScrollState = function(_state) {
		if (!is_instanceof(_state, EchoChamberScrollState)) {
			return self;
		}
		scroll_state = _state;
		return self;
	};

	/// @desc Set panel content padding.
	/// @param {Real} _value
	static SetPadding = function(_value) {
		padding = max(0, _value);
		return self;
	};

	/// @desc Set panel outer margin in GUI-space.
	/// @param {Real} _x
	/// @param {Real} [_y]
	/// @return {Struct.EchoChamberPanel}
	static SetMargin = function(_x, _y = undefined) {
		margin_x = max(0, _x);
		margin_y = max(0, _y ?? _x);
		return self;
	};

	/// @desc Set panel control gap spacing.
	/// @param {Real} _value
	static SetGap = function(_value) {
		gap = max(0, _value);
		return self;
	};

	/// @desc Set panel row height for controls.
	/// @param {Real} _value
	static SetRowHeight = function(_value) {
		row_height = max(0, _value);
		return self;
	};

	/// @desc Set the default field label placement for controls in this panel.
	/// @param {eEchoChamberFieldLabelPlacement} _placement
	/// @return {Struct.EchoChamberPanel}
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
		__field_label_placement_user_set = true;
		return self;
	};

	/// @desc Set the default field label gap for this panel.
	/// @param {Real} _px
	/// @return {Struct.EchoChamberPanel}
	static SetFieldLabelGap = function(_px) {
		if (_px < 0) {
			field_label_gap = -1;
		}
		else {
			field_label_gap = max(0, _px);
		}
		__field_label_gap_user_set = true;
		return self;
	};

	/// @desc Set the default field label column width for this panel (-1 uses auto width).
	/// @param {Real} _px
	/// @return {Struct.EchoChamberPanel}
	static SetFieldLabelWidth = function(_px) {
		if (_px < 0) {
			field_label_width = -1;
		}
		else {
			field_label_width = max(0, _px);
		}
		__field_label_width_user_set = true;
		return self;
	};

	/// @desc Set min/max clamp values for the auto field label column width.
	/// @param {Real} _min_px
	/// @param {Real} _max_px
	/// @return {Struct.EchoChamberPanel}
	static SetFieldLabelWidthClamp = function(_min_px, _max_px) {
		field_label_min_width = max(0, _min_px);
		var _max_v = is_undefined(_max_px) ? field_label_min_width : _max_px;
		field_label_max_width = max(field_label_min_width, _max_v);
		__field_label_width_clamp_user_set = true;
		return self;
	};

	/// @desc Set the panel default field label style key.
	/// @param {Any} _style_id
	/// @return {Struct.EchoChamberPanel}
	static SetFieldLabelStyleKey = function(_style_id) {
		field_label_style_id = string(_style_id);
		__field_label_style_user_set = true;
		return self;
	};

	/// @desc Set collapsed dock thickness for this panel.
	/// @param {Real} _value
	static SetCollapsedSize = function(_value) {
		collapsed_size = max(0, _value);
		return self;
	};

	/// @desc Set the panel collapse mode.
	/// @param {eEchoChamberCollapse} _mode
	static SetCollapseMode = function(_mode) {
		switch (_mode) {
			case eEchoChamberCollapse.TO_LEFT:
			case eEchoChamberCollapse.TO_RIGHT:
			case eEchoChamberCollapse.TO_TOP:
			case eEchoChamberCollapse.TO_BOTTOM:
				collapse_mode = _mode;
			break;

			default:
				collapse_mode = eEchoChamberCollapse.NONE;
			break;
		}
		return self;
	};

	/// @desc Set whether this panel is collapsed.
	/// @param {Bool} _value
	static SetCollapsed = function(_value) {
		collapsed = (_value == true);
		return self;
	};


	/// @desc Set the panel style key (for theme.panel_styles).
	/// @param {String} _key
	/// @return {Struct.EchoChamberPanel}
	static SetPanelStyleKey = function(_key) {
		style_key = string(_key);
		return self;
	};


	/// @desc Set minimum dock thickness when using fit-to-content.
	/// @param {Real} _value
	static SetMinSize = function(_value) {
		min_size = max(0, _value);
		if (max_size < min_size) {
			max_size = min_size;
		}
		return self;
	};

	/// @desc Set maximum dock thickness when using fit-to-content.
	/// @param {Real} _value
	static SetMaxSize = function(_value) {
		max_size = max(min_size, _value);
		return self;
	};

	/// @desc Assign a custom content drawer for this panel.
	/// @param {Function} _fn
	static SetContentDrawer = function(_fn) {
		content_draw = is_callable(_fn) ? _fn : undefined;
		return self;
	};

	/// @desc Get panel thickness based on collapsed state.
	/// @return {Real}
	static GetThickness = function() {
		if (collapsed && collapse_mode != eEchoChamberCollapse.NONE) {
			return collapsed_size;
		}
		return size;
	};

	/// @desc Resolve actual thickness for layout considering size mode.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _avail_width
	/// @param {Real} _avail_height
	static ResolveThickness = function(_root, _avail_width, _avail_height) {
		var _margin_x = max(0, margin_x);
		var _margin_y = max(0, margin_y);
		var _margin_thick = 0;
		if (dock == eEchoChamberDock.TOP || dock == eEchoChamberDock.BOTTOM) {
			_margin_thick = _margin_y * 2;
		}
		else if (dock == eEchoChamberDock.LEFT || dock == eEchoChamberDock.RIGHT) {
			_margin_thick = _margin_x * 2;
		}
		if (collapsed && collapse_mode != eEchoChamberCollapse.NONE) {
			var _handle_size = 0;
			if (is_instanceof(_root, EchoChamberRoot)) {
				_handle_size = _root.theme[$ "panel_collapse_handle_size"] ?? 8;
			}
			return max(collapsed_size, _handle_size) + _margin_thick;
		}
		if (size_mode != eEchoChamberPanelSizeMode.FIT_CONTENT) {
			return size + _margin_thick;
		}
		var _measured = size;
		if (dock == eEchoChamberDock.TOP || dock == eEchoChamberDock.BOTTOM) {
			_measured = __MeasureRowFitThickness(_root, _avail_width);
		}
		else if (dock == eEchoChamberDock.LEFT || dock == eEchoChamberDock.RIGHT) {
			_measured = __MeasureColumnFitThickness(_root);
		}
		_measured = clamp(_measured, min_size, max_size);
		return _measured + _margin_thick;
	};

	/// @ignore
	/// @func __HasFieldLabel(_ctrl)
	/// @desc Internal: returns true when the control should render a panel-level field label.
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Bool}
	static __HasFieldLabel = function(_ctrl) {
		if (!is_instanceof(_ctrl, EchoChamberControlBase)) {
			return false;
		}
		if (_ctrl[$ "field_label_enabled"] != true) {
			return false;
		}
		var _text = string(_ctrl[$ "field_label"] ?? "");
		return string_length(_text) > 0;
	};

	/// @ignore
	/// @func __ResolveFieldLabelGap(_root, _ctrl)
	/// @desc Internal: resolve label gap from control, panel, then theme defaults.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Real}
	static __ResolveFieldLabelGap = function(_root, _ctrl) {
		var _gap = _ctrl[$ "field_label_gap"] ?? -1;
		if (_gap < 0) {
			_gap = field_label_gap;
		}
		if (_gap < 0) {
			_gap = _root.theme[$ "field_label_gap"] ?? 6;
		}
		return max(0, _gap);
	};

	/// @ignore
	/// @func __ResolveFieldLabelStyle(_root, _ctrl)
	/// @desc Internal: resolve the active style map for a field label.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Struct}
	static __ResolveFieldLabelStyle = function(_root, _ctrl) {
		var _styles = _root.theme.label_styles;
		var _style_id = string(_ctrl[$ "field_label_style_id"] ?? "");
		if (_style_id == "_default") {
			_style_id = string(field_label_style_id);
		}
		if (string_length(_style_id) <= 0) {
			_style_id = string(field_label_style_id);
		}
		if (string_length(_style_id) <= 0) {
			_style_id = string(_root.theme[$ "field_label_style_id"] ?? "_field");
		}
		var _st = _styles[$ _style_id] ?? _styles[$ "_default"];
		if (!is_struct(_st)) {
			_st = _styles[$ "_default"];
		}
		return _st;
	};

	/// @ignore
	/// @func __ResolveFieldLabelFont(_root, _ctrl)
	/// @desc Internal: resolve the font used for this control's field label.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Asset.GMFont}
	static __ResolveFieldLabelFont = function(_root, _ctrl) {
		var _st = __ResolveFieldLabelStyle(_root, _ctrl);
		return _st[$ "font"] ?? _root.theme.font_small;
	};

	/// @ignore
	/// @func __MeasureFieldLabelTextWidth(_root, _ctrl)
	/// @desc Internal: measure field label text width with style font and horizontal padding.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Real}
	static __MeasureFieldLabelTextWidth = function(_root, _ctrl) {
		if (!__HasFieldLabel(_ctrl)) {
			return 0;
		}
		var _text = string(_ctrl[$ "field_label"]);
		var _font = __ResolveFieldLabelFont(_root, _ctrl);
		var _pad_x = max(0, _root.default_control_padding_x);
		return _root.__MeasureTextWidth(_text, _font) + (_pad_x * 2);
	};

	/// @ignore
	/// @func __MeasureFieldLabelLineHeight(_root, _ctrl)
	/// @desc Internal: measure one field label line height for above placement.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @return {Real}
	static __MeasureFieldLabelLineHeight = function(_root, _ctrl) {
		var _font = __ResolveFieldLabelFont(_root, _ctrl);
		var _old_font = draw_get_font();
		draw_set_font(_font);
		var _h = string_height("Ag");
		draw_set_font(_old_font);
		var _pad_y = max(0, _root.default_control_padding_y);
		_h += (_pad_y * 2);
		var _min_h = max(10, (_root.default_row_height * 0.5));
		return max(_min_h, _h);
	};

	/// @ignore
	/// @func __ClampFieldLabelWidth(_root, _width, _inner_w)
	/// @desc Internal: clamp a label width to panel/theme min/max and optional ratio constraints.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _width
	/// @param {Real} _inner_w
	/// @return {Real}
	static __ClampFieldLabelWidth = function(_root, _width, _inner_w) {
		var _min_w = field_label_min_width;
		if (_min_w < 0) {
			_min_w = _root.theme[$ "field_label_min_width"] ?? 0;
		}
		var _max_w = field_label_max_width;
		if (_max_w < 0) {
			_max_w = _root.theme[$ "field_label_max_width"] ?? 0;
		}
		var _ratio = _root.theme[$ "field_label_max_ratio"] ?? 0.4;
		if (_ratio > 0 && _inner_w > 0) {
			var _ratio_max = _inner_w * _ratio;
			if (_max_w <= 0) {
				_max_w = _ratio_max;
			}
			else {
				_max_w = min(_max_w, _ratio_max);
			}
		}
		if (_max_w > 0 && _max_w < _min_w) {
			_max_w = _min_w;
		}
		var _out = max(0, _width);
		if (_out < _min_w) {
			_out = _min_w;
		}
		if (_max_w > 0 && _out > _max_w) {
			_out = _max_w;
		}
		return _out;
	};

	/// @ignore
	/// @func __ResolveLeadingFieldLabelWidth(_root, _ctrl, _inner_w, _label_col_w)
	/// @desc Internal: resolve leading label column width for one control.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Real} _inner_w
	/// @param {Real} [_label_col_w]
	/// @return {Real}
	static __ResolveLeadingFieldLabelWidth = function(_root, _ctrl, _inner_w, _label_col_w = -1) {
		var _w = _ctrl[$ "field_label_width"] ?? -1;
		if (_w < 0) {
			_w = field_label_width;
		}
		if (_w < 0) {
			_w = _label_col_w;
		}
		if (_w < 0) {
			_w = __MeasureFieldLabelTextWidth(_root, _ctrl);
		}
		return __ClampFieldLabelWidth(_root, _w, _inner_w);
	};

	/// @ignore
	/// @func __ResolveFieldLabelPlacement(_root, _ctrl, _inner_w, _label_col_w)
	/// @desc Internal: resolve effective field label placement for a control.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Real} _inner_w
	/// @param {Real} [_label_col_w]
	/// @return {eEchoChamberFieldLabelPlacement}
	static __ResolveFieldLabelPlacement = function(_root, _ctrl, _inner_w, _label_col_w = -1) {
		if (!__HasFieldLabel(_ctrl)) {
			return eEchoChamberFieldLabelPlacement.NONE;
		}

		var _placement = _ctrl[$ "field_label_placement"] ?? eEchoChamberFieldLabelPlacement.AUTO;
		//if (_placement == eEchoChamberFieldLabelPlacement.TRAILING) {
		//	_placement = eEchoChamberFieldLabelPlacement.LEADING;
		//}
		//else if (_placement == eEchoChamberFieldLabelPlacement.BELOW) {
		//	_placement = eEchoChamberFieldLabelPlacement.ABOVE;
		//}
		if (_placement != eEchoChamberFieldLabelPlacement.AUTO) {
			return _placement;
		}

		_placement = field_label_placement;
		//if (_placement == eEchoChamberFieldLabelPlacement.TRAILING) {
		//	_placement = eEchoChamberFieldLabelPlacement.LEADING;
		//}
		//else if (_placement == eEchoChamberFieldLabelPlacement.BELOW) {
		//	_placement = eEchoChamberFieldLabelPlacement.ABOVE;
		//}
		if (_placement != eEchoChamberFieldLabelPlacement.AUTO) {
			return _placement;
		}

		_placement = _root.theme[$ "field_label_placement"] ?? eEchoChamberFieldLabelPlacement.AUTO;
		//if (_placement == eEchoChamberFieldLabelPlacement.TRAILING) {
		//	_placement = eEchoChamberFieldLabelPlacement.LEADING;
		//}
		//else if (_placement == eEchoChamberFieldLabelPlacement.BELOW) {
		//	_placement = eEchoChamberFieldLabelPlacement.ABOVE;
		//}
		if (_placement != eEchoChamberFieldLabelPlacement.AUTO) {
			return _placement;
		}

		var _allow_auto = false;
		if (flow == eEchoChamberPanelFlow.COLUMN) {
			_allow_auto = true;
		}
		else if (flow == eEchoChamberPanelFlow.ROW && _ctrl[$ "fill_width"] == true) {
			_allow_auto = true;
		}
		if (!_allow_auto) {
			return eEchoChamberFieldLabelPlacement.NONE;
		}

		if (_inner_w <= 0) {
			return eEchoChamberFieldLabelPlacement.LEADING;
		}

		var _gap = __ResolveFieldLabelGap(_root, _ctrl);
		var _label_w = __ResolveLeadingFieldLabelWidth(_root, _ctrl, _inner_w, _label_col_w);
		var _control_w = max(0, _inner_w - _label_w - _gap);
		var _min_control_w = _root.theme[$ "field_label_auto_min_control_w"] ?? max(80, _root.default_control_width * 0.55);
		if (_control_w < _min_control_w) {
			return eEchoChamberFieldLabelPlacement.ABOVE;
		}
		return eEchoChamberFieldLabelPlacement.LEADING;
	};

	/// @ignore
	/// @func __ResolveFieldLabelAlign(_root, _ctrl, _placement)
	/// @desc Internal: resolve effective field label text alignment.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {eEchoChamberFieldLabelPlacement} _placement
	/// @return {String}
	static __ResolveFieldLabelAlign = function(_root, _ctrl, _placement) {
		var _align = string_lower(string(_ctrl[$ "field_label_align"] ?? "auto"));
		if (_align != "left" && _align != "center" && _align != "right") {
			if (_placement == eEchoChamberFieldLabelPlacement.LEADING) {
				_align = string_lower(string(field_label_align_leading));
				if (_align != "left" && _align != "center" && _align != "right") {
					_align = string_lower(string(_root.theme[$ "field_label_align_leading"] ?? "right"));
				}
			}
			else {
				_align = string_lower(string(field_label_align_above));
				if (_align != "left" && _align != "center" && _align != "right") {
					_align = string_lower(string(_root.theme[$ "field_label_align_above"] ?? "left"));
				}
			}
		}
		if (_align != "left" && _align != "center" && _align != "right") {
			if (_placement == eEchoChamberFieldLabelPlacement.LEADING) {
				_align = "right";
			}
			else {
				_align = "left";
			}
		}
		return _align;
	};

	/// @ignore
	/// @func __ResolveFieldLabelColumnWidth(_root, _inner_w)
	/// @desc Internal: resolve shared leading label column width for this panel.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Real} _inner_w
	/// @return {Real}
	static __ResolveFieldLabelColumnWidth = function(_root, _inner_w) {
		var _fixed_w = field_label_width;
		if (_fixed_w > 0) {
			return __ClampFieldLabelWidth(_root, _fixed_w, _inner_w);
		}

		var _max_w = 0;
		var _len = array_length(children_controls);
		for (var _i = 0; _i < _len; _i++) {
			var _ctrl = children_controls[_i];
			if (!_ctrl.visible || !__HasFieldLabel(_ctrl)) {
				continue;
			}
			var _placement = __ResolveFieldLabelPlacement(_root, _ctrl, _inner_w);
			if (_placement != eEchoChamberFieldLabelPlacement.LEADING) {
				continue;
			}
			var _w = __ResolveLeadingFieldLabelWidth(_root, _ctrl, _inner_w);
			if (_w > _max_w) {
				_max_w = _w;
			}
		}
		return __ClampFieldLabelWidth(_root, _max_w, _inner_w);
	};

	/// @ignore
	/// @func __BuildFieldLabelLayout(_root, _ctrl, _rect, _label_col_w)
	/// @desc Internal: split a control rect into panel label and control body rects.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Struct} _rect
	/// @param {Real} _label_col_w
	/// @return {Struct}
	static __BuildFieldLabelLayout = function(_root, _ctrl, _rect, _label_col_w) {
		var _layout = {
			placement: eEchoChamberFieldLabelPlacement.NONE,
			draw_label: false,
			label_rect: undefined,
			control_rect: _rect
		};
		if (!__HasFieldLabel(_ctrl)) {
			return _layout;
		}

		var _inner_w = max(0, _rect.x2 - _rect.x1);
		var _placement = __ResolveFieldLabelPlacement(_root, _ctrl, _inner_w, _label_col_w);
		_layout.placement = _placement;
		if (_placement == eEchoChamberFieldLabelPlacement.NONE) {
			return _layout;
		}

		var _gap = __ResolveFieldLabelGap(_root, _ctrl);
		var _rect_ctrl = { x1: _rect.x1, y1: _rect.y1, x2: _rect.x2, y2: _rect.y2 };
		if (_placement == eEchoChamberFieldLabelPlacement.LEADING) {
			var _label_w = __ResolveLeadingFieldLabelWidth(_root, _ctrl, _inner_w, _label_col_w);
			_label_w = min(_label_w, max(0, _inner_w - _gap));
			var _label_x2 = _rect.x1 + _label_w;
			_rect_ctrl.x1 = min(_rect.x2, _label_x2 + _gap);
			_layout.label_rect = { x1: _rect.x1, y1: _rect.y1, x2: _label_x2, y2: _rect.y2 };
		}
		else if (_placement == eEchoChamberFieldLabelPlacement.ABOVE) {
			var _label_h = __MeasureFieldLabelLineHeight(_root, _ctrl);
			_label_h = min(_label_h, max(0, (_rect.y2 - _rect.y1) - _gap));
			var _label_y2 = _rect.y1 + _label_h;
			_rect_ctrl.y1 = min(_rect.y2, _label_y2 + _gap);
			_layout.label_rect = { x1: _rect.x1, y1: _rect.y1, x2: _rect.x2, y2: _label_y2 };
		}

		_layout.draw_label = is_struct(_layout.label_rect);
		_layout.control_rect = _rect_ctrl;
		return _layout;
	};

	/// @ignore
	/// @func __HandleFieldLabelInteractions(_root, _ctrl, _layout)
	/// @desc Internal: process click-to-focus for panel field labels.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Struct} _layout
	/// @return {Bool}
	static __HandleFieldLabelInteractions = function(_root, _ctrl, _layout) {
		if (!is_struct(_layout) || _layout[$ "draw_label"] != true) {
			return false;
		}
		var _label_rect = _layout[$ "label_rect"];
		if (!is_struct(_label_rect)) {
			return false;
		}
		if (_ctrl[$ "enabled"] != true) {
			return false;
		}
		if (_root.mouse_l_pressed && !_root.mouse_consumed && _root.HitTestRect(_label_rect.x1, _label_rect.y1, _label_rect.x2, _label_rect.y2)) {
			_root.FocusControl(_ctrl.id, _layout[$ "control_rect"]);
			return true;
		}
		return false;
	};

	/// @ignore
	/// @func __DrawFieldLabel(_root, _ctrl, _layout)
	/// @desc Internal: draw the panel-owned field label and tooltip if truncated.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Struct} _layout
	static __DrawFieldLabel = function(_root, _ctrl, _layout) {
		if (!is_struct(_layout) || _layout[$ "draw_label"] != true) {
			return;
		}
		var _label_rect = _layout[$ "label_rect"];
		if (!is_struct(_label_rect)) {
			return;
		}

		var _st = __ResolveFieldLabelStyle(_root, _ctrl);
		var _font = _st[$ "font"] ?? _root.theme.font_small;
		var _tx_col = _st[$ "text"] ?? _root.theme.col_text_dim;
		var _tx_alpha = _st[$ "text_alpha"] ?? 1;
		var _tx_disabled = _st[$ "text_disabled"] ?? _root.theme.col_text_dim;
		var _tx_disabled_alpha = _st[$ "text_disabled_alpha"] ?? _tx_alpha;
		if (_ctrl[$ "enabled"] != true) {
			_tx_col = _tx_disabled;
			_tx_alpha = _tx_disabled_alpha;
		}

		var _old_font = draw_get_font();
		var _old_alpha = draw_get_alpha();
		draw_set_font(_font);
		draw_set_alpha(_tx_alpha);
		draw_set_color(_tx_col);

		var _pad_x = max(0, _root.default_control_padding_x);
		var _avail_w = max(0, (_label_rect.x2 - _label_rect.x1) - (_pad_x * 2));
		var _label_text = string(_ctrl[$ "field_label"]);
		var _draw_text = __TrimTextToWidth(_label_text, _avail_w, _font);
		var _label_w = string_width(_label_text);
		var _trimmed = (_label_w > _avail_w);
		var _text_h = string_height(_draw_text);
		var _ty = _label_rect.y1 + ((_label_rect.y2 - _label_rect.y1) - _text_h) * 0.5;
		var _align = __ResolveFieldLabelAlign(_root, _ctrl, _layout[$ "placement"]);
		var _tx = _label_rect.x1 + _pad_x;
		if (_align == "center") {
			_tx = _label_rect.x1 + ((_label_rect.x2 - _label_rect.x1) - string_width(_draw_text)) * 0.5;
		}
		else if (_align == "right") {
			_tx = _label_rect.x2 - _pad_x - string_width(_draw_text);
		}

		draw_text(_tx, _ty, _draw_text);
		draw_set_alpha(_old_alpha);
		draw_set_font(_old_font);

		if (_trimmed && _root.HitTestRect(_label_rect.x1, _label_rect.y1, _label_rect.x2, _label_rect.y2)) {
			_root.RequestTooltip(_ctrl.id + "__field_label", _label_text, _root.mx, _root.my);
		}
	};

	/// @ignore
	/// @func __ResolveControlDesiredWidth(_root, _ctrl, _row_h, _inner_w, _label_col_w)
	/// @desc Internal: resolve a control's desired width (preferred width, then content width, then root default).
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Real} _row_h
	/// @param {Real} [_inner_w]
	/// @param {Real} [_label_col_w]
	/// @return {Real}
	static __ResolveControlDesiredWidth = function(_root, _ctrl, _row_h, _inner_w = -1, _label_col_w = -1) {
		var _default_w = _root.default_control_width;
		var _margin_x = _ctrl.margin_x;
		if (_margin_x < 0) {
			_margin_x = _root.default_control_margin_x;
		}
		_margin_x = max(0, _margin_x);

		var _pre = _ctrl[$ "__PreLayout"];
		if (is_callable(_pre)) {
			method(_ctrl, _pre)(_root, self, -1);
		}

		var _body_w = -1;
		var _pref = _ctrl[$ "preferred_width"];
		if (is_real(_pref) && _pref > 0) {
			_body_w = _pref;
		}
		else {
			var _max_w = _root.default_control_max_width;
			var _get_size = method(_ctrl, _ctrl[$ "__GetContentSize"]);
			if (_max_w > 0 && is_callable(_get_size)) {
				var _sz = _get_size(_root, self, _row_h);
				var _w = is_struct(_sz) ? _sz[$ "w"] : undefined;
				if (is_real(_w) && _w > 0) {
					_body_w = min(_w, _max_w);
				}
			}
		}
		if (_body_w <= 0) {
			_body_w = _default_w;
		}

		var _resolved_w = _body_w + (_margin_x * 2);
		var _placement = __ResolveFieldLabelPlacement(_root, _ctrl, _inner_w, _label_col_w);
		if (_placement == eEchoChamberFieldLabelPlacement.LEADING) {
			var _gap = __ResolveFieldLabelGap(_root, _ctrl);
			var _label_w = __ResolveLeadingFieldLabelWidth(_root, _ctrl, max(0, _inner_w), _label_col_w);
			_resolved_w += _label_w + _gap;
		}

		return _resolved_w;
	};

	/// @ignore
	/// @func __ResolveControlDesiredHeight(_root, _ctrl, _row_h, _width, _label_col_w)
	/// @desc Internal: resolve a control's desired height for a given width.
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct.EchoChamberControlBase} _ctrl
	/// @param {Real} _row_h
	/// @param {Real} _width
	/// @param {Real} [_label_col_w]
	/// @return {Real}
	static __ResolveControlDesiredHeight = function(_root, _ctrl, _row_h, _width, _label_col_w = -1) {
		var _margin_x = _ctrl.margin_x;
		if (_margin_x < 0) {
			_margin_x = _root.default_control_margin_x;
		}
		_margin_x = max(0, _margin_x);
		var _margin_y = _ctrl.margin_y;
		if (_margin_y < 0) {
			_margin_y = _root.default_control_margin_y;
		}
		_margin_y = max(0, _margin_y);

		var _inner_w = max(0, _width - (_margin_x * 2));
		var _placement = __ResolveFieldLabelPlacement(_root, _ctrl, _inner_w, _label_col_w);
		var _body_w = _inner_w;
		if (_placement == eEchoChamberFieldLabelPlacement.LEADING) {
			var _gap = __ResolveFieldLabelGap(_root, _ctrl);
			var _label_w = __ResolveLeadingFieldLabelWidth(_root, _ctrl, _inner_w, _label_col_w);
			_body_w = max(0, _inner_w - _label_w - _gap);
		}

		var _pre = _ctrl[$ "__PreLayout"];
		if (is_callable(_pre)) {
			method(_ctrl, _pre)(_root, self, _body_w);
		}

		var _body_h = _row_h;
		var _pref_h = _ctrl[$ "preferred_height"];
		if (is_real(_pref_h) && _pref_h > 0) {
			_body_h = _pref_h;
		}
		else {
			var _get_h = _ctrl[$ "__GetDesiredHeightForWidth"];
			if (is_callable(_get_h)) {
				var _h = method(_ctrl, _get_h)(_root, self, _body_w);
				if (is_real(_h) && _h > 0) {
					_body_h = _h;
				}
			}
		}

		var _resolved_h = _body_h + (_margin_y * 2);
		if (_placement == eEchoChamberFieldLabelPlacement.ABOVE) {
			var _label_h = __MeasureFieldLabelLineHeight(_root, _ctrl);
			var _label_gap = __ResolveFieldLabelGap(_root, _ctrl);
			_resolved_h += _label_h + _label_gap;
		}
		return _resolved_h;
	};

	static __MeasureRowFitThickness = function(_root, _avail_width) {
		var _pad = padding;
		var _line_h = row_height > 0 ? row_height : _root.default_row_height;
		var _gap = gap;
		var _inner_w = max(0, _avail_width - _pad * 2);
		var _field_label_col_w = __ResolveFieldLabelColumnWidth(_root, _inner_w);
		if (flow == eEchoChamberPanelFlow.COLUMN) {
			var _content_h = 0;
			var _visible = 0;
			var _len_col = array_length(children_controls);
			for (var _ci = 0; _ci < _len_col; _ci++) {
				var _ctrl_col = children_controls[_ci];
				if (!_ctrl_col.visible) continue;
				var _h = __ResolveControlDesiredHeight(_root, _ctrl_col, _line_h, _inner_w, _field_label_col_w);
				if (_visible > 0) _content_h += _gap;
				_content_h += _h;
				_visible += 1;
			}
			if (_visible <= 0) _content_h = _line_h;
			return _content_h + _pad * 2;
		}
		else {
			var _len_row = array_length(children_controls);
			if (_inner_w <= 0) {
				var _visible_zero = 0;
				var _content_h0 = 0;
				for (var _zi = 0; _zi < _len_row; _zi++) {
					var _ctrl_zero = children_controls[_zi];
					if (!_ctrl_zero.visible) continue;
					var _h0 = __ResolveControlDesiredHeight(_root, _ctrl_zero, _line_h, 0, _field_label_col_w);
					if (_visible_zero > 0) _content_h0 += _gap;
					_content_h0 += _h0;
					_visible_zero += 1;
				}
				if (_visible_zero <= 0) _content_h0 = _line_h;
				return _content_h0 + _pad * 2;
			}
			else {
				var _row_width = 0;
				var _row_h = _line_h;
				var _content_h = 0;
				var _has_row = false;
				for (var _ri = 0; _ri < _len_row; _ri++) {
					var _ctrl_row = children_controls[_ri];
					if (!_ctrl_row.visible) continue;
					var _fill = (_ctrl_row[$ "fill_width"] == true);
					if (_fill) {
						var _h_fill = __ResolveControlDesiredHeight(_root, _ctrl_row, _line_h, _inner_w, _field_label_col_w);
						if (_has_row) {
							if (_content_h > 0) _content_h += _gap;
							_content_h += _row_h;
							_row_width = 0;
							_row_h = _line_h;
							_has_row = false;
						}
						if (_content_h > 0) _content_h += _gap;
						_content_h += _h_fill;
					}
					else {
						var _desired_w = __ResolveControlDesiredWidth(_root, _ctrl_row, _line_h, _inner_w, _field_label_col_w);
						var _needs_gap = (_row_width > 0);
						var _avail = max(0, _inner_w - _row_width - (_needs_gap ? _gap : 0));
						if (_avail <= 0 || (_needs_gap && _desired_w > _avail)) {
							if (_has_row) {
								if (_content_h > 0) _content_h += _gap;
								_content_h += _row_h;
							}
							_row_width = 0;
							_row_h = _line_h;
							_has_row = false;
							_needs_gap = false;
							_avail = max(0, _inner_w);
						}
						var _use_w = (_avail <= 0) ? 0 : min(_desired_w, _avail);
						if (_needs_gap) _row_width += _gap;
						_row_width += _use_w;
						var _h_row = __ResolveControlDesiredHeight(_root, _ctrl_row, _line_h, _use_w, _field_label_col_w);
						if (_h_row > _row_h) _row_h = _h_row;
						if (_row_width > _inner_w) {
							_row_width = _inner_w;
						}
						_has_row = true;
					}
				}
				if (_has_row) {
					if (_content_h > 0) _content_h += _gap;
					_content_h += _row_h;
				}
				if (_content_h <= 0) _content_h = _line_h;
				return _content_h + _pad * 2;
			}
		}
	};

	static __MeasureColumnFitThickness = function(_root) {
		var _pad = padding;
		var _max_w = 0;
		var _len = array_length(children_controls);
		var _has_visible = false;
		var _row_h = row_height > 0 ? row_height : _root.default_row_height;
		var _inner_w_guess = max(0, _root.default_control_max_width);
		var _field_label_col_w = __ResolveFieldLabelColumnWidth(_root, _inner_w_guess);
		for (var _i = 0; _i < _len; _i++) {
			var _ctrl = children_controls[_i];
			if (!_ctrl.visible) continue;
			_has_visible = true;
			var _desired = __ResolveControlDesiredWidth(_root, _ctrl, _row_h, _inner_w_guess, _field_label_col_w);
			if (_desired > _max_w) {
				_max_w = _desired;
			}
		}
		if (!_has_visible) {
			_max_w = _root.default_control_width;
		}
		return _max_w + _pad * 2;
	};

	/// @desc Draw this panel and its contents (controls or child panels).
	/// @param {Struct.EchoChamberRoot} _root
	static Draw = function(_root) {
		if (!is_struct(_root)) {
			return;
		}

		_root.PushClipRect(rect.x1, rect.y1, rect.x2, rect.y2);
		_root.DrawPanelBackground(self);

		if (!collapsed) {
			var _pad = padding;
			var _gap = gap;
			var _inner_x1 = rect.x1 + _pad;
			var _inner_y1 = rect.y1 + _pad;
			var _inner_x2 = rect.x2 - _pad;
			var _inner_y2 = rect.y2 - _pad;
			var _handle_size = 0;
			if (collapse_mode != eEchoChamberCollapse.NONE) {
				_handle_size = _root.theme[$ "panel_collapse_handle_size"] ?? 0;
				_handle_size = max(0, _handle_size);
			}
			if (_handle_size > 0) {
				switch (collapse_mode) {
					case eEchoChamberCollapse.TO_LEFT:
						_inner_x2 -= _handle_size;
					break;
					case eEchoChamberCollapse.TO_RIGHT:
						_inner_x1 += _handle_size;
					break;
					case eEchoChamberCollapse.TO_TOP:
						_inner_y2 -= _handle_size;
					break;
					case eEchoChamberCollapse.TO_BOTTOM:
						_inner_y1 += _handle_size;
					break;
				}
			}
			if (_inner_x2 < _inner_x1) _inner_x2 = _inner_x1;
			if (_inner_y2 < _inner_y1) _inner_y2 = _inner_y1;

			if (is_container) {
				var _inner_rect = { x1: _inner_x1, y1: _inner_y1, x2: _inner_x2, y2: _inner_y2 };
				if (scroll_enabled) {
					var _view_h = max(0, _inner_y2 - _inner_y1);
					var _view_w = max(0, _inner_x2 - _inner_x1);
					var _scroll_gutter_pad = max(0, _root.theme[$ "scrollbar_gutter_pad"] ?? _root.default_control_padding_x);
					var _scroll_gutter_w = 0;
					var _content_h = other.__MeasurePanelContentHeightForWidth(_root, self, _view_w);
					if (_content_h > _view_h) {
						_scroll_gutter_w = max(0, _root.theme.scrollbar_w) + _scroll_gutter_pad;
						var _content_view_w = max(0, _view_w - _scroll_gutter_w);
						_content_h = other.__MeasurePanelContentHeightForWidth(_root, self, _content_view_w);
					}
					if (_content_h < _view_h) {
						_content_h = _view_h;
					}
					var _content_x2 = max(_inner_x1, _inner_x2 - _scroll_gutter_w);
					var _draw_panels = method({ panel: self, content_h: _content_h, content_x2: _content_x2 }, function(_root, _rect, _scroll_y) {
						var _panel = panel;
						var _content_h = content_h;
						var _content_x2 = content_x2;
						var _layout_y2 = _rect.y1 + _content_h;
						__EchoChamberAssignPanelRects(_root, _panel.children_panels, _rect.x1, _rect.y1, _content_x2, _layout_y2);
						var _plen = array_length(_panel.children_panels);
						if (_scroll_y != 0) {
							for (var i = 0; i < _plen; i++) {
								_panel.__OffsetPanelRectRecursive(_panel.children_panels[i], 0, -_scroll_y);
							}
						}
						for (var j = 0; j < _plen; j++) {
							var _p = _panel.children_panels[j];
							_p.Draw(_root);
						}
						if (_scroll_y != 0) {
							for (var k = 0; k < _plen; k++) {
								_panel.__OffsetPanelRectRecursive(_panel.children_panels[k], 0, _scroll_y);
							}
						}
					});
					_root.DrawScrollArea(scroll_state, _inner_rect, _content_h, _draw_panels);
				}
				else {
					// Child panels are laid out via __EchoChamberAssignPanelRects recursion.
					_root.PushClipRect(_inner_x1, _inner_y1, _inner_x2, _inner_y2);
					var _plen = array_length(children_panels);
					for (var i = 0; i < _plen; i++) {
						var _p2 = children_panels[i];
						_p2.Draw(_root);
					}
					_root.PopClipRect();
				}
			}
			else {
				var _inner_rect2 = { x1: _inner_x1, y1: _inner_y1, x2: _inner_x2, y2: _inner_y2 };
				var _self = self;
				var _draw_controls = method(_self, function(_root, _rect, _scroll_y) {
					var _panel = self;
					var _inner_x1 = _rect.x1;
					var _inner_y1 = _rect.y1;
					var _inner_x2 = _rect.x2;
					var _inner_y2 = _rect.y2;
					var _inner_w_panel = max(0, _inner_x2 - _inner_x1);
					var _gap = _panel.gap;
					var _cur_x = _inner_x1;
					var _cur_y = _inner_y1 - _scroll_y;
					var _max_x = _inner_x2;
					var _row_origin = _inner_x1;
					var _line_h = _panel.row_height > 0 ? _panel.row_height : _root.default_row_height;
					var _row_h_cur = _line_h;
					var _field_label_col_w = _panel.__ResolveFieldLabelColumnWidth(_root, _inner_w_panel);
					var _len = array_length(_panel.children_controls);
					for (var i = 0; i < _len; i++) {
						var _ctrl = _panel.children_controls[i];
						if (!_ctrl.visible) {
							continue;
						}
						var _margin_x = _ctrl.margin_x;
						if (_margin_x < 0) {
							_margin_x = _root.default_control_margin_x;
						}
						_margin_x = max(0, _margin_x);
						var _margin_y = _ctrl.margin_y;
						if (_margin_y < 0) {
							_margin_y = _root.default_control_margin_y;
						}
						_margin_y = max(0, _margin_y);
						var _ctrl_w = 0;
						var _ctrl_h = _line_h;
						var _fill = false;
						if (_panel.flow == eEchoChamberPanelFlow.COLUMN) {
							_ctrl_w = max(0, _inner_x2 - _inner_x1);
							_ctrl_h = _panel.__ResolveControlDesiredHeight(_root, _ctrl, _line_h, _ctrl_w, _field_label_col_w);
						}
						else {
							_fill = (_ctrl[$ "fill_width"] == true);
							if (_fill) {
								if (_cur_x > _row_origin) {
									_cur_x = _row_origin;
									_cur_y += _row_h_cur + _gap;
									_row_h_cur = _line_h;
								}
								_ctrl_w = max(0, _inner_x2 - _inner_x1);
								_ctrl_h = _panel.__ResolveControlDesiredHeight(_root, _ctrl, _line_h, _ctrl_w, _field_label_col_w);
							}
							else {
								var _desired_w = _panel.__ResolveControlDesiredWidth(_root, _ctrl, _line_h, _inner_w_panel, _field_label_col_w);
								var _needs_gap = (_cur_x > _row_origin);
								var _avail_row_w = max(0, _max_x - _cur_x - (_needs_gap ? _gap : 0));
								if (_avail_row_w <= 0 || (_needs_gap && _desired_w > _avail_row_w)) {
									_cur_x = _row_origin;
									_cur_y += _row_h_cur + _gap;
									_row_h_cur = _line_h;
									_needs_gap = false;
									_avail_row_w = max(0, _max_x - _cur_x);
								}
								_ctrl_w = (_avail_row_w <= 0) ? 0 : min(_desired_w, _avail_row_w);
								_ctrl_h = _panel.__ResolveControlDesiredHeight(_root, _ctrl, _line_h, _ctrl_w, _field_label_col_w);
								if (_ctrl_h > _row_h_cur) {
									_row_h_cur = _ctrl_h;
								}
							}
						}
						var _rect_ctrl = undefined;
						var _x_offset = 0;
						if (_panel.flow == eEchoChamberPanelFlow.COLUMN) {
							var _inner_w = max(0, _ctrl_w - (_margin_x * 2));
							var _inner_h = max(0, _ctrl_h - (_margin_y * 2));
							_rect_ctrl = {
								x1: _inner_x1 + _margin_x,
								y1: _cur_y + _margin_y,
								x2: _inner_x1 + _margin_x + _inner_w,
								y2: _cur_y + _margin_y + _inner_h
							};
						}
						else {
							_x_offset = (_cur_x > _row_origin && !_fill) ? _gap : 0;
							var _inner_w2 = max(0, _ctrl_w - (_margin_x * 2));
							var _inner_h2 = max(0, _ctrl_h - (_margin_y * 2));
							_rect_ctrl = {
								x1: _cur_x + _x_offset + _margin_x,
								y1: _cur_y + _margin_y,
								x2: _cur_x + _x_offset + _margin_x + _inner_w2,
								y2: _cur_y + _margin_y + _inner_h2
							};
						}
						if (_rect_ctrl.x1 < _inner_x1) _rect_ctrl.x1 = _inner_x1;
						if (_rect_ctrl.y1 < _inner_y1) _rect_ctrl.y1 = _inner_y1;
						if (_rect_ctrl.x2 > _inner_x2) _rect_ctrl.x2 = _inner_x2;
						if (_rect_ctrl.y2 > _inner_y2) _rect_ctrl.y2 = _inner_y2;
						var _layout = _panel.__BuildFieldLabelLayout(_root, _ctrl, _rect_ctrl, _field_label_col_w);
						var _rect_body = _layout[$ "control_rect"] ?? _rect_ctrl;
						if (_rect_body.x1 < _inner_x1) _rect_body.x1 = _inner_x1;
						if (_rect_body.y1 < _inner_y1) _rect_body.y1 = _inner_y1;
						if (_rect_body.x2 > _inner_x2) _rect_body.x2 = _inner_x2;
						if (_rect_body.y2 > _inner_y2) _rect_body.y2 = _inner_y2;
						var _draw_label = (_layout[$ "draw_label"] == true);
						var _label_rect = _layout[$ "label_rect"];
						if (!is_struct(_label_rect) || _label_rect.x2 <= _label_rect.x1 || _label_rect.y2 <= _label_rect.y1) {
							_draw_label = false;
						}
						var _draw_ctrl = (_rect_body.x2 > _rect_body.x1 && _rect_body.y2 > _rect_body.y1);
						if (_draw_label || _draw_ctrl) {
							var _overlay_id = _root.active_overlay_owner_id;
							var _suppress_input = (!is_undefined(_overlay_id) && _ctrl.id != _overlay_id);
							var _proxy_label_click = false;
							if (_suppress_input) {
								_root.__PushInputSuppression();
							}
							if (_draw_label) {
								_proxy_label_click = _panel.__HandleFieldLabelInteractions(_root, _ctrl, _layout);
								_panel.__DrawFieldLabel(_root, _ctrl, _layout);
							}
							if (_draw_ctrl) {
								var _restore_mouse = false;
								var _old_mx = 0;
								var _old_my = 0;
								var _restore_proxy = false;
								var _old_proxy_id = undefined;
								if (_proxy_label_click && _root.mouse_l_pressed && !_root.mouse_consumed) {
									_old_proxy_id = _root.__field_label_proxy_click_id;
									_root.__field_label_proxy_click_id = _ctrl.id;
									_restore_proxy = true;
									_old_mx = _root.mx;
									_old_my = _root.my;
									_root.mx = (_rect_body.x1 + _rect_body.x2) * 0.5;
									_root.my = (_rect_body.y1 + _rect_body.y2) * 0.5;
									_restore_mouse = true;
								}
								_ctrl.ProcessAndDraw(_root, _panel, _rect_body);
								if (_restore_mouse) {
									_root.mx = _old_mx;
									_root.my = _old_my;
								}
								if (_restore_proxy) {
									_root.__field_label_proxy_click_id = _old_proxy_id;
								}
							}
							if (_suppress_input) {
								_root.__PopInputSuppression();
							}
						}
						if (_panel.flow == eEchoChamberPanelFlow.COLUMN) {
							_cur_y += _ctrl_h + _gap;
						}
						else {
							if (_fill) {
								_cur_x = _row_origin;
								_cur_y += _ctrl_h + _gap;
								_row_h_cur = _line_h;
							}
							else {
								_cur_x = _cur_x + _x_offset + _ctrl_w;
								if (_cur_x > _max_x) {
									_cur_x = _max_x;
								}
							}
						}
					}
				});

				if (scroll_enabled) {
					var _view_h2 = max(0, _inner_y2 - _inner_y1);
					var _view_w2 = max(0, _inner_x2 - _inner_x1);
					var _scroll_gutter_pad2 = max(0, _root.theme[$ "scrollbar_gutter_pad"] ?? _root.default_control_padding_x);
					var _scroll_gutter_w2 = 0;
					var _content_h2 = other.__MeasurePanelContentHeightForWidth(_root, self, _view_w2);
					if (_content_h2 > _view_h2) {
						_scroll_gutter_w2 = max(0, _root.theme.scrollbar_w) + _scroll_gutter_pad2;
						var _content_view_w2 = max(0, _view_w2 - _scroll_gutter_w2);
						_content_h2 = other.__MeasurePanelContentHeightForWidth(_root, self, _content_view_w2);
					}
					if (_content_h2 < _view_h2) {
						_content_h2 = _view_h2;
					}
					if (_scroll_gutter_w2 > 0) {
						var _content_x2_2 = max(_inner_x1, _inner_x2 - _scroll_gutter_w2);
						var _draw_controls_scroll = method({ draw_controls: _draw_controls, content_x2: _content_x2_2 }, function(_root, _rect, _scroll_y) {
							var _draw_controls = draw_controls;
							var _content_x2 = content_x2;
							var _draw_rect = {
								x1: _rect.x1,
								y1: _rect.y1,
								x2: _content_x2,
								y2: _rect.y2
							};
							_draw_controls(_root, _draw_rect, _scroll_y);
						});
						_root.DrawScrollArea(scroll_state, _inner_rect2, _content_h2, _draw_controls_scroll);
					}
					else {
						_root.DrawScrollArea(scroll_state, _inner_rect2, _content_h2, _draw_controls);
					}
				}
				else {
					_draw_controls(_root, _inner_rect2, 0);
				}
			}

			if (is_callable(content_draw)) {
				var _content_rect = {
					x1: _inner_x1,
					y1: _inner_y1,
					x2: _inner_x2,
					y2: _inner_y2
				};
				_root.PushClipRect(_content_rect.x1, _content_rect.y1, _content_rect.x2, _content_rect.y2);
				if (!is_undefined(_root.active_overlay_owner_id)) {
					_root.__PushInputSuppression();
					content_draw(_root, _content_rect);
					_root.__PopInputSuppression();
				}
				else {
					content_draw(_root, _content_rect);
				}
				_root.PopClipRect();
			}
		}

		_root.DrawPanelCollapseHandle(self);
		_root.PopClipRect();
	};
	
	// Default panel sizing metrics.
	SetSize(200);
	SetSizeMode(eEchoChamberPanelSizeMode.FIXED);
	SetPadding(4);
	SetMargin(0);
	SetGap(4);
	SetRowHeight(24);
	SetCollapsedSize(8);
}

/// @func EchoChamberScrollState(_id)
/// @desc Persistent scroll state for a scrollable region.
/// @param {Any} _id
/// @return {Struct.EchoChamberScrollState}
function EchoChamberScrollState(_id) constructor {
	id = string(_id);
	scroll_y = 0;
	dragging = false;      // true while the scrollbar thumb is being dragged
	drag_offset_y = 0;     // mouse_y - thumb_y1 at drag start


	/// @desc Set the scroll offset in pixels.
	/// @param {Real} _y
	static SetScrollY = function(_y) {
		scroll_y = max(0, _y);
		return self;
	};

	/// @desc Scroll by a delta in pixels (positive scrolls down).
	/// @param {Real} _dy
	static ScrollBy = function(_dy) {
		scroll_y = max(0, scroll_y + _dy);
		return self;
	};

	/// @desc Reset scroll to the top.
	static Reset = function() {
		scroll_y = 0;
		return self;
	};
}

/// @func EchoChamberOpenConsole(_ui_root)
/// @desc Open or create the built-in Echo Console window (log history viewer + filters).
/// @param {Struct.EchoChamberRoot} _ui_root
/// @return {Struct.EchoChamberWindow}
function EchoChamberOpenConsole(_ui_root) {
	if (!is_instanceof(_ui_root, EchoChamberRoot)) return undefined;

	var _ctrl = _ui_root[$ "__echo_console_controller"];
	if (!is_instanceof(_ctrl, __EchoConsoleController)) {
		_ctrl = new __EchoConsoleController(_ui_root);
		_ui_root[$ "__echo_console_controller"] = _ctrl;
	}
	return _ctrl.__Open();
}

/// @ignore
/// @func __EchoConsoleController(_root)
/// @desc Internal controller for the built-in Echo Console window.
function __EchoConsoleController(_root) constructor {
	root = _root;
	win  = undefined;

	list_view = undefined;
	gen_status = undefined;

	state = {
		level_labels : [ "NONE", "COMPLETE", "COMPREHENSIVE", "SEVERE_ONLY" ],
		level_values : [ eEchoDebugLevel.NONE, eEchoDebugLevel.COMPLETE, eEchoDebugLevel.COMPREHENSIVE, eEchoDebugLevel.SEVERE_ONLY ],
		level_index  : 0,

		tag_text         : "",
		history_max_text : "",
		search_text      : "",
		search_cache_raw	: "",
		search_cache_lc		: "",
		auto_scroll      : true,

		gen_active			: false,
		gen_total			: 0,
		gen_remaining		: 0,
		gen_emitted			: 0,
		gen_batch_size		: 4000,
		gen_tag				: "STRESS",
		gen_tag_effective	: "STRESS",

		filter_use_indices	: false,
		filter_search_lc	: "",
		filter_tags_text	: "",
		filter_tags			: [],
		filter_level		: -1,
		filter_revision		: -1,
		filter_len		: 0,
		filter_first_seq	: -1,
		filtered_indices	: undefined,

		last_revision : -1,
		last_raw_capture : true,
		entries       : [],

		selected_seq : -1,
		selected_entry_index : -1,

		details_wrap_seq			: -1,
		details_wrap_w			: -1,
		details_wrap_font			: -1,
		details_wrap_level			: -1,
		details_wrap_stack_count	: -1,
		details_wrap_line_h			: 0,
		details_wrap_msg_lines		: [],
		details_wrap_stack_lines	: [],

		scroll_logs    : new EchoChamberScrollState("echo_console_scroll_logs"),
		scroll_details : new EchoChamberScrollState("echo_console_scroll_details")
	};

	/// @ignore
	/// @func __FindWindowById(_id)
	/// @param {String} _id
	/// @return {Struct.EchoChamberWindow}
	static __FindWindowById = function(_id) {
		var _sid = string(_id);
		var _len = array_length(root.windows);
		for (var _i = 0; _i < _len; _i++) {
			if (root.windows[_i].id == _sid) return root.windows[_i];
		}
		return undefined;
	};

	/// @ignore
	/// @func __Trim(_s)
	/// @param {String} _s
	/// @return {String}
	static __Trim = function(_s) {
		var _t = string(_s);
		// Basic ASCII trim (spaces + tabs)
		while (string_length(_t) > 0 && (string_char_at(_t, 1) == " " || string_char_at(_t, 1) == "\t")) {
			_t = string_delete(_t, 1, 1);
		}
		while (string_length(_t) > 0) {
			var _n = string_length(_t);
			var _c = string_char_at(_t, _n);
			if (_c == " " || _c == "\t") {
				_t = string_delete(_t, _n, 1);
			}
			else {
				break;
			}
		}
		return _t;
	};

	/// @ignore
	/// @func __ParseTags(_text)
	/// @param {String} _text
	/// @return {Array<String>}
	static __ParseTags = function(_text) {
		var _raw = string(_text);
		var _out = [];
		var _token = "";
		var _len = string_length(_raw);
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_raw, _i);
			if (_ch == ",") {
				var _t = __Trim(_token);
				if (_t != "") array_push(_out, _t);
				_token = "";
			}
			else {
				_token += _ch;
			}
		}
		var _t2 = __Trim(_token);
		if (_t2 != "") array_push(_out, _t2);
		return _out;
	};

	/// @ignore
	/// @func __SyncFromEcho()
	/// @desc Pull current Echo config into console state when possible.
	static __SyncFromEcho = function() {
		if (!ECHO_DEBUG_ENABLED) return;

		var _lvl = EchoDebugGetLevel(false);
		// Map enum -> dropdown index
		var _idx = 0;
		if (_lvl == eEchoDebugLevel.COMPLETE) _idx = 1;
		else if (_lvl == eEchoDebugLevel.COMPREHENSIVE) _idx = 2;
		else if (_lvl == eEchoDebugLevel.SEVERE_ONLY) _idx = 3;
		else _idx = 0;

		state.level_index = _idx;

		var _hm = EchoDebugGetHistorySize();
		state.history_max_text = string(_hm);
	};

	/// @ignore
	/// @func __RefreshEntriesIfNeeded()
	static __RefreshEntriesIfNeeded = function() {
		if (!ECHO_DEBUG_ENABLED) {
			state.entries = [];
			state.last_revision = -1;
			state.last_raw_capture = true;
			state.selected_seq = -1;
			state.selected_entry_index = -1;
			return;
		}

		var _config = __EchoGetDebugConfig();
		var _use_raw = _config.__GetRawHistoryCapture();
		var _rev = _use_raw ? _config.__GetRawRevision() : EchoDebugGetRevision();
		if (_rev == false) return;

		if (_rev != state.last_revision || _use_raw != state.last_raw_capture) {
			var _hist = _use_raw ? _config.__GetRawStructuredHistory() : EchoDebugGetStructuredHistory();
			if (_use_raw) {
				state.entries = is_array(_hist) ? variable_clone(_hist) : [];
			}
			else {
				state.entries = is_array(_hist) ? _hist : [];
			}
			state.last_revision = _rev;
			state.last_raw_capture = _use_raw;
			state.filter_revision = -1;
			state.filter_use_indices = false;
			state.filtered_indices = undefined;

			// Auto-follow is handled by EchoChamberListView; do not force scroll here.
			__UpdateSelectedEntryIndex();
		}
	};

	/// @ignore
	/// @func __UpdateSelectedEntryIndex()
	/// @return {Bool}
	static __UpdateSelectedEntryIndex = function() {
		var _seq = state.selected_seq;
		if (_seq < 0) {
			state.selected_entry_index = -1;
			return false;
		}

		var _len = array_length(state.entries);
		if (_len <= 0) {
			state.selected_seq = -1;
			state.selected_entry_index = -1;
			return false;
		}

		var _idx = state.selected_entry_index;
		if (_idx >= 0 && _idx < _len) {
			var _e = state.entries[_idx];
			var _seq_val = is_struct(_e) ? _e[$ "seq"] : undefined;
			if (!is_undefined(_seq_val) && _seq_val == _seq) {
				return true;
			}
		}

		// Fast O(1) guess when seq is monotonic and the array is not gapped.
		var _e0 = state.entries[0];
		if (is_struct(_e0)) {
			var _first = _e0[$ "seq"];
			if (!is_undefined(_first)) {
				var _guess = _seq - _first;
				if (_guess >= 0 && _guess < _len) {
					var _eg = state.entries[_guess];
					var _seq_guess = is_struct(_eg) ? _eg[$ "seq"] : undefined;
					if (!is_undefined(_seq_guess) && _seq_guess == _seq) {
						state.selected_entry_index = _guess;
						return true;
					}
				}
			}
		}

		// Fallback: scan only on selection changes or history rebuilds.
		for (var _i = 0; _i < _len; _i++) {
			var _e2 = state.entries[_i];
			if (!is_struct(_e2)) continue;
			var _seq_val = _e2[$ "seq"];
			if (!is_undefined(_seq_val) && _seq_val == _seq) {
				state.selected_entry_index = _i;
				return true;
			}
		}

		state.selected_seq = -1;
		state.selected_entry_index = -1;
		return false;
	};

	/// @ignore
	/// @func __GetActiveLevel()
	/// @return {Real}
	static __GetActiveLevel = function() {
		var _idx = clamp(state.level_index, 0, array_length(state.level_values) - 1);
		return state.level_values[_idx];
	};

	/// @ignore
	/// @func __EntryPassesLevel(_entry, _level)
	/// @param {Struct} _entry
	/// @param {Real} _level
	/// @return {Bool}
	static __EntryPassesLevel = function(_entry, _level) {
		if (_level == eEchoDebugLevel.NONE) return false;
		if (_level == eEchoDebugLevel.COMPLETE) return true;

		var _urg = _entry[$ "urgency"];
		if (is_undefined(_urg)) return false;

		if (_level == eEchoDebugLevel.COMPREHENSIVE) {
			return _urg != eEchoDebugUrgency.INFO;
		}
		if (_level == eEchoDebugLevel.SEVERE_ONLY) {
			return _urg == eEchoDebugUrgency.SEVERE;
		}
		return true;
	};

	/// @ignore
	/// @func __EntryPassesTags(_entry, _tags)
	/// @param {Struct} _entry
	/// @param {Array<String>} _tags
	/// @return {Bool}
	static __EntryPassesTags = function(_entry, _tags) {
		if (!is_array(_tags) || array_length(_tags) <= 0) return true;

		var _entry_tags = _entry[$ "tags"];
		if (!is_array(_entry_tags) || array_length(_entry_tags) <= 0) return false;

		var _tn = array_length(_tags);
		for (var _i = 0; _i < _tn; _i++) {
			if (array_contains(_entry_tags, _tags[_i])) return true;
		}
		return false;
	};

	/// @ignore
	/// @func __EntryAllowsStack(_entry, _level)
	/// @param {Struct} _entry
	/// @param {Real} _level
	/// @return {Bool}
	static __EntryAllowsStack = function(_entry, _level) {
		var _urg = _entry[$ "urgency"];
		if (is_undefined(_urg)) return false;
		if (_urg == eEchoDebugUrgency.SEVERE) return true;
		if (_urg == eEchoDebugUrgency.WARNING && _level == eEchoDebugLevel.COMPLETE) return true;
		return false;
	};

	/// @ignore
	/// @func __EntryGetColour(_entry)
	/// @param {Struct} _entry
	/// @return {Real}
	static __EntryGetColour = function(_entry) {
		var _colour = _entry[$ "colour"];
		if (is_real(_colour)) {
			return _colour;
		}
		return undefined;
	};

	/// @ignore
	/// @func __RefreshFilterCacheIfNeeded()
	static __RefreshFilterCacheIfNeeded = function() {
		var _search_raw = state.search_text;
		if (_search_raw != state.search_cache_raw) {
			state.search_cache_raw = _search_raw;
			state.search_cache_lc = string_lower(_search_raw);
		}
		var _search_lc = state.search_cache_lc;
		var _tag_raw = state.tag_text;
		if (_tag_raw != state.filter_tags_text) {
			state.filter_tags_text = _tag_raw;
			state.filter_tags = __ParseTags(_tag_raw);
		}
		var _tags = state.filter_tags;
		var _level = __GetActiveLevel();

		var _use_filter = (string_length(_search_raw) > 0)
		|| (is_array(_tags) && array_length(_tags) > 0)
		|| (_level != eEchoDebugLevel.COMPLETE);
		if (!_use_filter) {
			if (!state.filter_use_indices
			&& state.filter_search_lc == ""
			&& state.filter_tags_text == ""
			&& state.filter_level == _level) {
				return;
			}

			// Direct mode: do not build or keep a filtered index array.
			state.filter_use_indices = false;
			state.filtered_indices = undefined;
			state.filter_search_lc = "";
			state.filter_tags_text = "";
			state.filter_level = _level;
			return;
		}

		var _rev = state.last_revision;
		var _len = array_length(state.entries);

		var _first_seq = -1;
		if (_len > 0) {
			var _e0 = state.entries[0];
			if (is_struct(_e0)) _first_seq = _e0[$ "seq"] ?? -1;
		}

		var _need = false;
		if (!state.filter_use_indices) _need = true;
		if (state.filter_revision != _rev) _need = true;
		if (state.filter_search_lc != _search_lc) _need = true;
		if (state.filter_tags_text != _tag_raw) _need = true;
		if (state.filter_level != _level) _need = true;

		if (!_need) return;

		var _can_append = false;
		if (state.filter_use_indices
		&& state.filter_search_lc == _search_lc
		&& state.filter_tags_text == _tag_raw
		&& state.filter_level == _level) {
			if (state.filter_first_seq == _first_seq && _len >= state.filter_len) {
				_can_append = true;
			}
		}

		var _indices = state.filtered_indices;
		if (!_can_append || !is_array(_indices)) {
			_indices = [];
		}

		var _start_i = _can_append ? state.filter_len : 0;

		for (var _i = _start_i; _i < _len; _i++) {
			var _e = state.entries[_i];
			if (!is_struct(_e)) continue;

			if (!__EntryPassesLevel(_e, _level)) continue;
			if (!__EntryPassesTags(_e, _tags)) continue;

			if (string_length(_search_lc) > 0) {
				var _hay = string_lower(string(_e[$ "message"] ?? ""));
				if (string_pos(_search_lc, _hay) <= 0) {
					// Also search tags
					var _tags_str = "";
					var _tags_arr = _e[$ "tags"];
					if (is_array(_tags_arr)) {
						var _tn = array_length(_tags_arr);
						for (var _ti = 0; _ti < _tn; _ti++) {
							_tags_str += " " + string(_tags_arr[_ti]);
						}
					}
					if (string_pos(_search_lc, string_lower(_tags_str)) <= 0) {
						continue;
					}
				}
			}

			array_push(_indices, _i);
		}

		state.filtered_indices = _indices;
		state.filter_use_indices = true;
		state.filter_search_lc = _search_lc;
		state.filter_tags_text = _tag_raw;
		state.filter_level = _level;
		state.filter_revision = _rev;
		state.filter_len = _len;
		state.filter_first_seq = _first_seq;
	};

	/// @ignore
	/// @func __WrapTextLines(_text, _max_w, _font)
	/// @param {String} _text
	/// @param {Real} _max_w
	/// @param {Asset.GMFont} _font
	/// @return {Array<String>}
	static __WrapTextLines = function(_text, _max_w, _font) {
		var _old = draw_get_font();
		draw_set_font(_font);

		var _lines = [];
		var _s = string(_text);

		// Split into explicit lines first
		var _cur = "";
		var _len = string_length(_s);
		var _segments = [];
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

			// If segment is empty, keep a blank line
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
						// Single word longer than width: hard cut using existing helper
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
	/// @func __StressStart(_count)
	/// @param {Real} _count
	static __StressStart = function(_count) {
		if (!ECHO_DEBUG_ENABLED) return;

		var _c = max(0, floor(_count));
		if (_c <= 0) return;

		// Stress generation uses WARNING urgency so it appears in both COMPLETE and COMPREHENSIVE.
		// It will not appear in NONE or SEVERE_ONLY.
		var _lvl = EchoDebugGetLevel(false);
		if (_lvl == eEchoDebugLevel.NONE || _lvl == eEchoDebugLevel.SEVERE_ONLY) {
			state.gen_active = false;
			if (is_struct(gen_status)) {
				gen_status.SetText("Gen: blocked by level (set COMPLETE/COMPREHENSIVE)");
			}
			return;
		}

		// If tag filtering is active, emit under an allowed tag so entries actually log.
		// (Echo requires tag overlap when allowed-tags is non-empty.)
		state.gen_tag_effective = state.gen_tag;
		var _allowed = EchoDebugGetTags();
		if (is_array(_allowed) && array_length(_allowed) > 0) {
			state.gen_tag_effective = string(_allowed[0]);
		}

		state.gen_total		= _c;
		state.gen_remaining	= _c;
		state.gen_emitted	= 0;
		state.gen_active	= true;

		// For stress testing, default to following the newest lines.
		state.auto_scroll = true;
		if (is_struct(list_view)) {
			list_view.SetAutoScroll(true);
			list_view.JumpToBottom();
		}

		if (is_struct(gen_status)) {
			gen_status.SetText("Gen: 0/" + string(_c));
		}
	};

	/// @ignore
	/// @func __StressCancel()
	static __StressCancel = function() {
		state.gen_total		= 0;
		state.gen_remaining	= 0;
		state.gen_emitted	= 0;
		state.gen_active	= false;

		if (is_struct(gen_status)) gen_status.SetText("");
	};

	/// @ignore
	/// @func __StressTick()
	static __StressTick = function() {
		if (!state.gen_active) return;

		if (!ECHO_DEBUG_ENABLED) {
			__StressCancel();
			return;
		}

		if (state.gen_remaining <= 0) {
			state.gen_active = false;
			if (is_struct(gen_status)) gen_status.SetText("Gen: done (" + string(state.gen_emitted) + ")");
			return;
		}

		var _batch = min(state.gen_batch_size, state.gen_remaining);
		var _start = state.gen_emitted;
		var _tag = state.gen_tag_effective;

		for (var _i = 0; _i < _batch; _i++) {
			var _n = _start + _i + 1;

			// Keep messages light. Every 10th line is longer to exercise wrapping paths.
			var _msg;
			if ((_n mod 10) == 0) {
				_msg = "Stress line " + string(_n) + " - long message sample: lorem ipsum dolor sit amet consectetur adipiscing elit";
			}
			else {
				_msg = "Stress line " + string(_n);
			}

			EchoDebugWarn(_msg, _tag);
		}

		state.gen_emitted += _batch;
		state.gen_remaining -= _batch;

		if (is_struct(gen_status)) {
			gen_status.SetText("Gen: " + string(state.gen_emitted) + "/" + string(state.gen_total));
		}

		if (state.gen_remaining <= 0) {
			state.gen_active = false;
			if (is_struct(gen_status)) gen_status.SetText("Gen: done (" + string(state.gen_emitted) + ")");
		}
	};

	/// @ignore
	/// @func __EnsureBuilt()
	static __EnsureBuilt = function() {
		if (is_struct(win)) return;

		win = __FindWindowById("echo_console");
		if (!is_struct(win)) {
			win = root.CreateWindow("echo_console")
			.SetTitle("Echo Console")
			.SetRect(32, 32, 840, 520)
			.SetMinSize(520, 320);
		}

		// Panels
		var _p_toolbar = new EchoChamberPanel("echo_console_toolbar", eEchoChamberDock.TOP);
		_p_toolbar.SetSizeMode(eEchoChamberPanelSizeMode.FIT_CONTENT);
		_p_toolbar.SetFlowMode(eEchoChamberPanelFlow.ROW);

		var _p_list = new EchoChamberPanel("echo_console_list", eEchoChamberDock.FILL);
		_p_list.SetSizeMode(eEchoChamberPanelSizeMode.FIXED);
		_p_list.SetFlowMode(eEchoChamberPanelFlow.ROW);

		var _p_details = new EchoChamberPanel("echo_console_details", eEchoChamberDock.BOTTOM);
		_p_details.SetSizeMode(eEchoChamberPanelSizeMode.FIXED);
		_p_details.SetSize(170);
		_p_details.SetFlowMode(eEchoChamberPanelFlow.ROW);

		// Toolbar controls
		var _lbl = new EchoChamberLabel("echo_console_lbl").SetText("Echo");
		_lbl.SetPreferredWidth(54);

		var _dd = new EchoChamberDropdownSelect("echo_console_level")
		.SetLabel("Level")
		.SetOptions(state.level_labels)
		.BindIndex(state, "level_index")
		.OnChange(method(self, function(_idx) {
			if (!ECHO_DEBUG_ENABLED) return;
			var _val = state.level_values[clamp(_idx, 0, array_length(state.level_values) - 1)];
			EchoDebugSetLevel(_val);
		}));
		_dd.SetPreferredWidth(170);

		var _tags = new EchoChamberTextInput("echo_console_tags")
		.BindText(state, "tag_text")
		.SetPlaceholder("Filter tags (comma): UI, Physics");
		_tags.SetPreferredWidth(220);

		var _btn_clear_tags = new EchoChamberButton("echo_console_clear_tags")
		.SetLabel("Clear tags")
		.OnClick(method(self, function() {
			state.tag_text = "";
		}));
		_btn_clear_tags.SetPreferredWidth(92);

		var _hm = new EchoChamberTextInput("echo_console_history_max")
		.BindText(state, "history_max_text")
		.SetPlaceholder("History max (0 = unlimited)")
		.OnChange(method(self, function(_text) {
			if (!ECHO_DEBUG_ENABLED) return;
			var _v = real(_text);
			if (!is_real(_v)) return;
			EchoDebugSetHistorySize(max(0, floor(_v)));
		}));
		_hm.SetPreferredWidth(180);

		var _search = new EchoChamberTextInput("echo_console_search")
		.BindText(state, "search_text")
		.SetPlaceholder("Search")
		.SetPreferredWidth(160);

		var _auto = new EchoChamberToggle("echo_console_auto")
		.SetLabel("Auto")
		.BindBool(state, "auto_scroll")
		.SetPreferredWidth(70);

		var _btn_latest = new EchoChamberButton("echo_console_latest")
		.SetLabel("Latest")
		.SetTooltip("Forces the console to scroll with the latest messages.")
		.OnClick(method(self, function() {
			state.auto_scroll = true;
			if (is_struct(list_view)) {
				list_view.SetAutoScroll(true);
				list_view.JumpToBottom();
			}
			else if (is_instanceof(state.scroll_logs, EchoChamberScrollState)) {
				state.scroll_logs.scroll_y = infinity;
			}
		}));
		_btn_latest.SetPreferredWidth(70);

		var _btn_clear = new EchoChamberButton("echo_console_clear")
		.SetLabel("Clear")
		.OnClick(method(self, function() {
			if (!ECHO_DEBUG_ENABLED) return;
			EchoDebugClearHistory();
		}));
		_btn_clear.SetPreferredWidth(62);

		var _btn_dump = new EchoChamberButton("echo_console_dump")
		.SetLabel("Dump")
		.OnClick(method(self, function() {
			if (!ECHO_DEBUG_ENABLED) return;
			EchoDebugDumpLog();
		}));
		_btn_dump.SetPreferredWidth(62);

		// Stress test helpers (generate large log volumes without per-frame allocations)
		gen_status = new EchoChamberLabel("echo_console_gen_status")
		.UseSmallFont(true)
		.SetText("")
		.SetPreferredWidth(140);

		var _btn_gen_50k = new EchoChamberButton("echo_console_gen_50k")
		.SetLabel("50k")
		.OnClick(method(self, function() {
			__StressStart(50000);
		}));
		_btn_gen_50k.SetPreferredWidth(48);

		var _btn_gen_200k = new EchoChamberButton("echo_console_gen_200k")
		.SetLabel("200k")
		.OnClick(method(self, function() {
			__StressStart(200000);
		}));
		_btn_gen_200k.SetPreferredWidth(56);

		var _btn_gen_1m = new EchoChamberButton("echo_console_gen_1m")
		.SetLabel("1M")
		.OnClick(method(self, function() {
			__StressStart(1000000);
		}));
		_btn_gen_1m.SetPreferredWidth(44);

		var _btn_gen_stop = new EchoChamberButton("echo_console_gen_stop")
		.SetLabel("Stop")
		.OnClick(method(self, function() {
			__StressCancel();
		}));
		_btn_gen_stop.SetPreferredWidth(52);

		_p_toolbar.AddControl(_lbl);
		_p_toolbar.AddControl(_dd);
		_p_toolbar.AddControl(_tags);
		_p_toolbar.AddControl(_btn_clear_tags);
		_p_toolbar.AddControl(_hm);
		_p_toolbar.AddControl(_search);
		_p_toolbar.AddControl(_auto);
		_p_toolbar.AddControl(_btn_latest);
		_p_toolbar.AddControl(_btn_clear);
		_p_toolbar.AddControl(_btn_dump);
		_p_toolbar.AddControl(gen_status);
		_p_toolbar.AddControl(_btn_gen_50k);
		_p_toolbar.AddControl(_btn_gen_200k);
		_p_toolbar.AddControl(_btn_gen_1m);
		_p_toolbar.AddControl(_btn_gen_stop);

		// List view control (virtualized)
		if (!is_struct(list_view)) {
			list_view = new EchoChamberListView("echo_console_list_view");
			list_view.scroll_state = state.scroll_logs;
			list_view.SetCountGetter(method(self, __LogListCount));
			list_view.SetRowDrawer(method(self, __LogListDrawRow));
			list_view.SetOnSelect(method(self, __LogListOnSelect));
			list_view.SetOnActivate(method(self, __LogListOnActivate));
			list_view.SetOnDoubleClick(method(self, __LogListOnDoubleClick));
			list_view.SetOnRightClick(method(self, __LogListOnRightClick));
			list_view.owner_root = root;
			list_view.owner_window = win;
			list_view.owner_panel = _p_list;
		}

		_p_list.content_draw = method(self, __DrawLogList);
		_p_details.content_draw = method(self, __DrawDetails);

		// Replace any existing panels with the same IDs if already present
		win.panels = [];
		win.AddPanel(_p_toolbar);
		win.AddPanel(_p_list);
		win.AddPanel(_p_details);

		__SyncFromEcho();
	};

	/// @ignore
	/// @func Open()
	/// @return {Struct.EchoChamberWindow}
	static __Open = function() {
		__EnsureBuilt();
		if (!is_struct(win)) return undefined;

		win.SetVisible(true);
		root.BringWindowToFront(win);
		return win;
	};

	/// @ignore
	/// @func __LogListCount()
	/// @return {Real}
	static __LogListCount = function() {
		if (state.filter_use_indices && is_array(state.filtered_indices)) {
			return array_length(state.filtered_indices);
		}
		return array_length(state.entries);
	};

	/// @ignore
	/// @func __FindSortedIndex(_arr, _value)
	/// @param {Array<Real>} _arr
	/// @param {Real} _value
	/// @return {Real}
	static __FindSortedIndex = function(_arr, _value) {
		if (!is_array(_arr)) return -1;
		var _target = floor(_value);
		var _lo = 0;
		var _hi = array_length(_arr) - 1;
		while (_lo <= _hi) {
			var _mid = (_lo + _hi) div 2;
			var _v = floor(_arr[_mid]);
			if (_v == _target) return _mid;
			if (_v < _target) {
				_lo = _mid + 1;
			}
			else {
				_hi = _mid - 1;
			}
		}
		return -1;
	};

	/// @ignore
	/// @func __LogListGetSrcIndex(_view_index)
	/// @param {Real} _view_index
	/// @return {Real}
	static __LogListGetSrcIndex = function(_view_index) {
		var _vi = floor(_view_index);
		if (_vi < 0) return -1;
		if (state.filter_use_indices && is_array(state.filtered_indices)) {
			var _vlen = array_length(state.filtered_indices);
			if (_vi >= _vlen) return -1;
			return floor(state.filtered_indices[_vi]);
		}
		return _vi;
	};

	/// @ignore
	/// @func __LogListGetEntry(_view_index)
	/// @param {Real} _view_index
	/// @return {Any}
	static __LogListGetEntry = function(_view_index) {
		var _src_i = __LogListGetSrcIndex(_view_index);
		if (_src_i < 0) return undefined;
		var _len = array_length(state.entries);
		if (_src_i >= _len) return undefined;
		var _e = state.entries[_src_i];
		return is_struct(_e) ? _e : undefined;
	};

	/// @ignore
	/// @func __LogListDrawRow(_index, _rect, _is_selected, _is_hover)
	/// @param {Real} _index
	/// @param {Struct} _rect {x1,y1,x2,y2}
	/// @param {Bool} _is_selected
	/// @param {Bool} _is_hover
	static __LogListDrawRow = function(_index, _rect, _is_selected, _is_hover) {
		var _e = __LogListGetEntry(_index);
		if (!is_struct(_e)) return;
		if (!is_struct(root) || !is_struct(root.theme)) return;

		var _time = string(_e[$ "time_str"] ?? "");
		var _urg  = string(_e[$ "urgency_str"] ?? "");

		var _msg = string(_e[$ "message"] ?? "");
		_msg = string_replace_all(_msg, "\n", " ");

		var _line = $"[{_time}] ({_urg}) {_msg}";
		var _max_w = max(0, (_rect.x2 - _rect.x1));
		var _draw = __TrimTextToWidth(_line, _max_w, root.theme.font_body);
		var _base_col = draw_get_colour();
		var _entry_col = __EntryGetColour(_e);
		if (is_real(_entry_col)) {
			if (_is_selected) {
				_entry_col = merge_color(_entry_col, _base_col, 0.35);
			}
			else if (_is_hover) {
				_entry_col = merge_color(_entry_col, _base_col, 0.2);
			}
			draw_set_color(_entry_col);
		}

		var _row_h = (_rect.y2 - _rect.y1);
		var _ty = _rect.y1 + (_row_h - string_height(_draw)) * 0.5;
		draw_text(_rect.x1, _ty, _draw);
		draw_set_color(_base_col);
	};

	/// @ignore
	/// @func __LogListOnSelect(_index)
	/// @param {Real} _index
	static __LogListOnSelect = function(_index) {
		var _src_i = __LogListGetSrcIndex(_index);
		var _e = undefined;
		var _len = array_length(state.entries);
		if (_src_i >= 0 && _src_i < _len) {
			_e = state.entries[_src_i];
		}

		var _seq = is_struct(_e) ? _e[$ "seq"] : undefined;
		if (!is_undefined(_seq)) {
			state.selected_seq = _seq;
			state.selected_entry_index = _src_i;
		}
		else {
			state.selected_seq = -1;
			state.selected_entry_index = -1;
		}

		if (is_struct(state.scroll_details)) {
			state.scroll_details.scroll_y = 0;
		}
	};

	/// @ignore
	/// @func __LogListOnActivate(_index)
	/// @param {Real} _index
	static __LogListOnActivate = function(_index) {
		__LogListOnSelect(_index);
	};

	/// @ignore
	/// @func __LogListOnDoubleClick(_index)
	/// @param {Real} _index
	static __LogListOnDoubleClick = function(_index) {
		__LogListOnSelect(_index);

		var _e = __LogListGetEntry(_index);
		if (!is_struct(_e)) return;

		var _msg = string(_e[$ "message"] ?? "");
		if (is_struct(root)) {
			root.CopyToClipboard(_msg);
		}
	};

	/// @ignore
	/// @func __LogListOnRightClick(_index, _x, _y)
	/// @param {Real} _index
	/// @param {Real} _x
	/// @param {Real} _y
	static __LogListOnRightClick = function(_index, _x, _y) {
		if (!is_struct(root)) return;
		if (!is_struct(win)) return;

		var _vi = floor(_index);

		// Empty space menu
		if (_vi < 0) {
			var _items = [];

			if (string_length(state.search_text) > 0) {
				array_push(_items, {
					label		: "Clear search",
					on_click	: function() {
						state.search_text = "";
					}
				});
			}

			if (state.selected_seq >= 0) {
				array_push(_items, {
					label		: "Clear selection",
					on_click	: function() {
						state.selected_seq = -1;
						state.selected_entry_index = -1;
					}
				});
			}

			if (array_length(_items) > 0) {
				array_push(_items, { is_separator: true });
			}

			array_push(_items, {
				label		: (state.auto_scroll ? "Disable follow" : "Enable follow"),
				on_click	: function() {
					state.auto_scroll = !state.auto_scroll;
					if (is_struct(list_view)) {
						list_view.SetAutoScroll(state.auto_scroll);
					}
				}
			});

			array_push(_items, {
				label		: "Latest",
				on_click	: function() {
					state.auto_scroll = true;
					if (is_struct(list_view)) {
						list_view.SetAutoScroll(true);
						list_view.JumpToBottom();
					}
					else if (is_instanceof(state.scroll_logs, EchoChamberScrollState)) {
						state.scroll_logs.scroll_y = infinity;
					}
				}
			});

			root.OpenContextMenu(_items, _x, _y, win);
			return;
		}

		// Row menu
		var _e = __LogListGetEntry(_vi);
		if (!is_struct(_e)) return;

		var _msg = string(_e[$ "message"] ?? "");
		var _msg_one = string_replace_all(_msg, "\n", " ");

		var _time = string(_e[$ "time_str"] ?? "");
		var _urg  = string(_e[$ "urgency_str"] ?? "");

		var _tags_str = "";
		var _tags_arr = _e[$ "tags"];
		if (is_array(_tags_arr) && array_length(_tags_arr) > 0) {
			_tags_str = " [";
			var _tn = array_length(_tags_arr);
			for (var _ti = 0; _ti < _tn; _ti++) {
				if (_ti > 0) _tags_str += " | ";
				_tags_str += string(_tags_arr[_ti]);
			}
			_tags_str += "]";
		}

		var _full_line = $"[{_time}] ({_urg}){_tags_str} {_msg_one}";

		var _level = __GetActiveLevel();
		var _stack_arr = _e[$ "stack"];
		var _has_stack = __EntryAllowsStack(_e, _level)
		&& (is_array(_stack_arr) && array_length(_stack_arr) > 0);

		var _items = [];
		array_push(_items, {
			label		: "Copy message",
			on_click	: method({ root, _msg }, function() {
				root.CopyToClipboard(_msg);
			})
		});

		array_push(_items, {
			label		: "Copy full line",
			on_click	: method({ root, _full_line }, function() {
				root.CopyToClipboard(_full_line);
			})
		});

		if (_has_stack) {
			array_push(_items, {
				label		: "Copy stack trace",
				on_click	: method({ _e, root }, function() {
					var _stack = "";
					var _stack_items = _e[$ "stack"];
					var _sn = is_array(_stack_items) ? array_length(_stack_items) : 0;
					for (var _si = 0; _si < _sn; _si++) {
						_stack += string(_stack_items[_si]);
						if (_si < _sn - 1) _stack += "\n";
					}
					root.CopyToClipboard(_stack);
				})
			});
		}

		array_push(_items, { is_separator: true });

		array_push(_items, {
			label		: "Copy debug dump (JSON)",
			on_click	: method({ root, _e }, function() {
				root.CopyToClipboard(json_stringify(_e));
			})
		});

		root.OpenContextMenu(_items, _x, _y, win);
	};

	/// @ignore
	/// @func __DrawLogList(_root, _rect)
	static __DrawLogList = function(_root, _rect) {
		__StressTick();
		__SyncFromEcho();
		__RefreshEntriesIfNeeded();

		if (!is_struct(list_view)) return;

		var _row_h = max(14, _root.default_row_height);
		list_view.SetRowHeight(_row_h);

		__RefreshFilterCacheIfNeeded();

		var _sel_view = -1;
		var _src_sel = state.selected_entry_index;

		if (_src_sel >= 0 && state.selected_seq >= 0) {
			var _elen = array_length(state.entries);
			if (_src_sel >= _elen) {
				_src_sel = -1;
			}
			else {
				var _e_sel = state.entries[_src_sel];
				var _sel_seq = is_struct(_e_sel) ? _e_sel[$ "seq"] : undefined;
				if (is_undefined(_sel_seq) || _sel_seq != state.selected_seq) {
					_src_sel = -1;
				}
			}
		}

		if (_src_sel >= 0) {
			if (state.filter_use_indices && is_array(state.filtered_indices)) {
				_sel_view = __FindSortedIndex(state.filtered_indices, _src_sel);
			}
			else {
				_sel_view = _src_sel;
			}
		}
		list_view.SetAutoScroll(state.auto_scroll);
		list_view.SetSelectedIndex(_sel_view);

		list_view.ProcessAndDraw(_root, undefined, _rect);
	};

	/// @ignore
	/// @func __DrawDetails(_root, _rect)

	/// @ignore
	/// @func __RefreshDetailsWrapCache(_root, _sel, _max_w, _level)
	/// @param {Struct.EchoChamberRoot} _root
	/// @param {Struct} _sel
	/// @param {Real} _max_w
	/// @param {Real} _level
	static __RefreshDetailsWrapCache = function(_root, _sel, _max_w, _level) {
		var _seq = _sel[$ "seq"] ?? -1;
		var _font = _root.theme.font_body;
		var _show_stack = __EntryAllowsStack(_sel, _level);
		var _stack_count = 0;
		var _stack_arr = _sel[$ "stack"];
		if (_show_stack && is_array(_stack_arr)) {
			_stack_count = array_length(_stack_arr);
		}

		if (state.details_wrap_seq == _seq
		&& state.details_wrap_w == _max_w
		&& state.details_wrap_font == _font
		&& state.details_wrap_level == _level
		&& state.details_wrap_stack_count == _stack_count) {
			return;
		}

		state.details_wrap_seq = _seq;
		state.details_wrap_w = _max_w;
		state.details_wrap_font = _font;
		state.details_wrap_level = _level;
		state.details_wrap_stack_count = _stack_count;

		// Cache line height for this font
		var _old = draw_get_font();
		draw_set_font(_font);
		state.details_wrap_line_h = max(10, string_height("Ag"));
		draw_set_font(_old);

		// Message wrap cache
		var _msg = string(_sel[$ "message"] ?? "");
		state.details_wrap_msg_lines = __WrapTextLines(_msg, _max_w, _font);

		// Stack wrap cache (includes label)
		if (_stack_count > 0) {
			var _stack_str = "Stack Trace:\n";
			for (var _si = 0; _si < _stack_count; _si++) {
				_stack_str += string(_stack_arr[_si]);
				if (_si < _stack_count - 1) _stack_str += "\n";
			}
			state.details_wrap_stack_lines = __WrapTextLines(_stack_str, _max_w, _font);
		}
		else {
			state.details_wrap_stack_lines = [];
		}
	};

	static __DrawDetails = function(_root, _rect) {
		__SyncFromEcho();
		__RefreshEntriesIfNeeded();
		var _level = __GetActiveLevel();

		var _x1 = _rect.x1;
		var _y1 = _rect.y1;
		var _x2 = _rect.x2;
		var _y2 = _rect.y2;

		draw_set_color(_root.theme.col_panel_bg);
		draw_rectangle(_x1, _y1, _x2, _y2, false);

		// Find selected entry (cached index; no per-frame scan)
		var _sel = undefined;
		var _len = array_length(state.entries);
		var _sel_i = state.selected_entry_index;

		if (_sel_i >= 0 && _sel_i < _len) {
			var _e = state.entries[_sel_i];
			var _seq = is_struct(_e) ? _e[$ "seq"] : undefined;
			if (!is_undefined(_seq) && _seq == state.selected_seq) {
				_sel = _e;
			}
		}

		if (!is_struct(_sel) && state.selected_seq >= 0) {
			if (__UpdateSelectedEntryIndex()) {
				_sel_i = state.selected_entry_index;
				if (_sel_i >= 0 && _sel_i < _len) {
					var _e2 = state.entries[_sel_i];
					var _seq2 = is_struct(_e2) ? _e2[$ "seq"] : undefined;
					if (!is_undefined(_seq2) && _seq2 == state.selected_seq) {
						_sel = _e2;
					}
				}
			}
		}

		if (!is_struct(_sel)) {
			draw_set_color(_root.theme.col_muted);
			draw_set_font(_root.theme.font_body);
			draw_text(_x1 + _root.theme.pad_x, _y1 + _root.theme.pad_y, "Select a log entry to see details.");
			return;
		}

		var _old_font = draw_get_font();
		draw_set_font(_root.theme.font_body);

		var _pad = _root.theme.pad_x;
		var _inner = { x1: _x1 + _pad, y1: _y1 + _pad, x2: _x2 - _pad, y2: _y2 - _pad };
		var _max_w = max(32, _inner.x2 - _inner.x1);

		var _time = string(_sel[$ "time_str"] ?? "");
		var _urg  = string(_sel[$ "urgency_str"] ?? "");

		var _tags_str = "";
		var _tags_arr = _sel[$ "tags"];
		if (is_array(_tags_arr) && array_length(_tags_arr) > 0) {
			_tags_str = " [";
			var _tn = array_length(_tags_arr);
			for (var _ti = 0; _ti < _tn; _ti++) {
				if (_ti > 0) _tags_str += " | ";
				_tags_str += string(_tags_arr[_ti]);
			}
			_tags_str += "]";
		}

		var _header = $"[{_time}] ({_urg}){_tags_str}";

		__RefreshDetailsWrapCache(_root, _sel, _max_w, _level);

		var _line_h = state.details_wrap_line_h;

		var _content_lines = 1 + 1 + array_length(state.details_wrap_msg_lines);
		if (array_length(state.details_wrap_stack_lines) > 0) {
			_content_lines += 1 + array_length(state.details_wrap_stack_lines);
		}
		var _content_h = _content_lines * _line_h + _pad;

		var _self = self;
		_root.DrawScrollArea(state.scroll_details, _rect, _content_h,
		method({
			line_h: _line_h, sel: _sel,
			header: _header, owner: _self
		},
		function(_r, _inner2, _scroll_y) {
			var _line_h = line_h;
			var _sel = sel;
			var _header = header;
			with (owner) {
				var _yy = _inner2.y1 - _scroll_y;

				var _mx = _r.mx;
				var _my = _r.my;
				var _inside = (_mx >= _inner2.x1 && _mx <= _inner2.x2 && _my >= _inner2.y1 && _my <= _inner2.y2);

				// Right click context in details (message/stack)
				if (_inside && _r.mouse_r_pressed && !_r.mouse_consumed) {
					var _ln = array_length(state.details_wrap_msg_lines);
					var _sn = array_length(state.details_wrap_stack_lines);

					var _base_y = _inner2.y1 - _scroll_y;
					var _msg_y1 = _base_y + (_line_h * 2);
					var _msg_y2 = _msg_y1 + (_ln * _line_h);

					var _stack_y1 = _msg_y2 + _line_h;
					var _stack_y2 = _stack_y1 + (_sn * _line_h);

					var _items = undefined;

					// Message block
					if (_my >= _msg_y1 && _my <= _msg_y2) {
						var _msg = string(_sel[$ "message"] ?? "");
						var _msg_one = string_replace_all(_msg, "\n", " ");

						_items = [];
						array_push(_items, {
							label		: "Copy message",
							on_click	: method({ _r, _msg }, function() {
								_r.CopyToClipboard(_msg);
							})
						});
						array_push(_items, {
							label		: "Copy message (one line)",
							on_click	: method({ _r, _msg_one }, function() {
								_r.CopyToClipboard(_msg_one);
							})
						});
					}
					// Stack block
					else if (_sn > 0 && _my >= _stack_y1 && _my <= _stack_y2) {
						var _stack_line_i = floor((_my - _stack_y1) / _line_h);
						var _stack_line = "";
						if (_stack_line_i >= 0 && _stack_line_i < _sn) {
							_stack_line = string(state.details_wrap_stack_lines[_stack_line_i]);
						}

						var _stack_full = "";
						var _stack_arr = _sel[$ "stack"];
						var _stack_ok = (is_array(_stack_arr) && array_length(_stack_arr) > 0);
						if (_stack_ok) {
							var _n = array_length(_stack_arr);
							for (var _i = 0; _i < _n; _i++) {
								_stack_full += string(_stack_arr[_i]);
								if (_i < _n - 1) _stack_full += "\n";
							}
						}

						_items = [];
						array_push(_items, {
							label		: "Copy stack line",
							enabled		: (string_length(_stack_line) > 0),
							on_click	: method({ _stack_line, _r }, function() {
								if (string_length(_stack_line) <= 0) return;
								_r.CopyToClipboard(_stack_line);
							})
						});
						array_push(_items, {
							label		: "Copy full stack",
							enabled		: _stack_ok,
							on_click	: method({ _stack_ok, _r, _stack_full }, function() {
								if (!_stack_ok) return;
								_r.CopyToClipboard(_stack_full);
							})
						});
					}

					if (is_array(_items) && array_length(_items) > 0) {
						_r.OpenContextMenu(_items, _mx, _my, win);
						_r.ConsumeMouse();
					}
				}
				var _base_col = _r.theme.col_text;
				var _entry_col = __EntryGetColour(_sel);
				var _text_col = is_real(_entry_col) ? _entry_col : _base_col;
				draw_set_color(_text_col);

				// Header (single line, clipped by scissor)
				draw_text(_inner2.x1, _yy, _header);
				_yy += _line_h;

				// Blank line
				_yy += _line_h;

				// Message lines (cached)
				var _ln = array_length(state.details_wrap_msg_lines);
				for (var _li = 0; _li < _ln; _li++) {
					draw_text(_inner2.x1, _yy, state.details_wrap_msg_lines[_li]);
					_yy += _line_h;
				}

				// Stack lines (cached)
				var _sn = array_length(state.details_wrap_stack_lines);
				if (_sn > 0) {
					_yy += _line_h;
					for (var _si = 0; _si < _sn; _si++) {
						draw_text(_inner2.x1, _yy, state.details_wrap_stack_lines[_si]);
						_yy += _line_h;
					}
				}
				draw_set_color(_base_col);
			}
		}));

		draw_set_font(_old_font);
	};
}

/// @ignore
function __EchoChamberAssignPanelRects(_root, _panels, _x1, _y1, _x2, _y2) {
	if (!is_array(_panels)) {
		return;
	}
	var _rem_x1 = _x1;
	var _rem_y1 = _y1;
	var _rem_x2 = _x2;
	var _rem_y2 = _y2;
	var _len = array_length(_panels);
	for (var _i = 0; _i < _len; _i++) {
		var _panel_top = _panels[_i];
		if (_panel_top.dock == eEchoChamberDock.TOP) {
			var _avail_w = max(0, _rem_x2 - _rem_x1);
			var _avail_h = max(0, _rem_y2 - _rem_y1);
			var _t = _panel_top.ResolveThickness(_root, _avail_w, _avail_h);
			_t = clamp(_t, 0, _avail_h);
			var _mx = max(0, _panel_top.margin_x);
			var _my = max(0, _panel_top.margin_y);
			_panel_top.rect.x1 = _rem_x1 + _mx;
			_panel_top.rect.x2 = _rem_x2 - _mx;
			_panel_top.rect.y1 = _rem_y1 + _my;
			_panel_top.rect.y2 = _rem_y1 + _t - _my;
			if (_panel_top.rect.x2 < _panel_top.rect.x1) _panel_top.rect.x2 = _panel_top.rect.x1;
			if (_panel_top.rect.y2 < _panel_top.rect.y1) _panel_top.rect.y2 = _panel_top.rect.y1;
			_rem_y1 += _t;
		}
	}
	for (var _j = 0; _j < _len; _j++) {
		var _panel_bottom = _panels[_j];
		if (_panel_bottom.dock == eEchoChamberDock.BOTTOM) {
			var _avail_w2 = max(0, _rem_x2 - _rem_x1);
			var _avail_h2 = max(0, _rem_y2 - _rem_y1);
			var _tb = _panel_bottom.ResolveThickness(_root, _avail_w2, _avail_h2);
			_tb = clamp(_tb, 0, _avail_h2);
			var _mx2 = max(0, _panel_bottom.margin_x);
			var _my2 = max(0, _panel_bottom.margin_y);
			_panel_bottom.rect.x1 = _rem_x1 + _mx2;
			_panel_bottom.rect.x2 = _rem_x2 - _mx2;
			_panel_bottom.rect.y1 = _rem_y2 - _tb + _my2;
			_panel_bottom.rect.y2 = _rem_y2 - _my2;
			if (_panel_bottom.rect.x2 < _panel_bottom.rect.x1) _panel_bottom.rect.x2 = _panel_bottom.rect.x1;
			if (_panel_bottom.rect.y2 < _panel_bottom.rect.y1) _panel_bottom.rect.y2 = _panel_bottom.rect.y1;
			_rem_y2 -= _tb;
		}
	}
	for (var _k = 0; _k < _len; _k++) {
		var _panel_left = _panels[_k];
		if (_panel_left.dock == eEchoChamberDock.LEFT) {
			var _avail_w3 = max(0, _rem_x2 - _rem_x1);
			var _avail_h3 = max(0, _rem_y2 - _rem_y1);
			var _tl = _panel_left.ResolveThickness(_root, _avail_w3, _avail_h3);
			_tl = clamp(_tl, 0, _avail_w3);
			var _mx3 = max(0, _panel_left.margin_x);
			var _my3 = max(0, _panel_left.margin_y);
			_panel_left.rect.x1 = _rem_x1 + _mx3;
			_panel_left.rect.x2 = _rem_x1 + _tl - _mx3;
			_panel_left.rect.y1 = _rem_y1 + _my3;
			_panel_left.rect.y2 = _rem_y2 - _my3;
			if (_panel_left.rect.x2 < _panel_left.rect.x1) _panel_left.rect.x2 = _panel_left.rect.x1;
			if (_panel_left.rect.y2 < _panel_left.rect.y1) _panel_left.rect.y2 = _panel_left.rect.y1;
			_rem_x1 += _tl;
		}
	}
	for (var _m = 0; _m < _len; _m++) {
		var _panel_right = _panels[_m];
		if (_panel_right.dock == eEchoChamberDock.RIGHT) {
			var _avail_w4 = max(0, _rem_x2 - _rem_x1);
			var _avail_h4 = max(0, _rem_y2 - _rem_y1);
			var _tr = _panel_right.ResolveThickness(_root, _avail_w4, _avail_h4);
			_tr = clamp(_tr, 0, _avail_w4);
			var _mx4 = max(0, _panel_right.margin_x);
			var _my4 = max(0, _panel_right.margin_y);
			_panel_right.rect.x1 = _rem_x2 - _tr + _mx4;
			_panel_right.rect.x2 = _rem_x2 - _mx4;
			_panel_right.rect.y1 = _rem_y1 + _my4;
			_panel_right.rect.y2 = _rem_y2 - _my4;
			if (_panel_right.rect.x2 < _panel_right.rect.x1) _panel_right.rect.x2 = _panel_right.rect.x1;
			if (_panel_right.rect.y2 < _panel_right.rect.y1) _panel_right.rect.y2 = _panel_right.rect.y1;
			_rem_x2 -= _tr;
		}
	}
	for (var _n = 0; _n < _len; _n++) {
		var _panel_fill = _panels[_n];
		if (_panel_fill.dock == eEchoChamberDock.FILL) {
			var _mx5 = max(0, _panel_fill.margin_x);
			var _my5 = max(0, _panel_fill.margin_y);
			_panel_fill.rect.x1 = _rem_x1 + _mx5;
			_panel_fill.rect.x2 = _rem_x2 - _mx5;
			_panel_fill.rect.y1 = _rem_y1 + _my5;
			_panel_fill.rect.y2 = _rem_y2 - _my5;
			if (_panel_fill.rect.x2 < _panel_fill.rect.x1) _panel_fill.rect.x2 = _panel_fill.rect.x1;
			if (_panel_fill.rect.y2 < _panel_fill.rect.y1) _panel_fill.rect.y2 = _panel_fill.rect.y1;
		}
	}
	// Recurse into container panels (nested docking)
	for (var _c = 0; _c < _len; _c++) {
		var _panel_c = _panels[_c];
		if (!_panel_c.is_container) {
			continue;
		}
		if (_panel_c.collapsed && _panel_c.collapse_mode != eEchoChamberCollapse.NONE) {
			continue;
		}
		if (!is_array(_panel_c.children_panels)) {
			continue;
		}
		var _pad = max(0, _panel_c.padding);
		var _ix1 = _panel_c.rect.x1 + _pad;
		var _iy1 = _panel_c.rect.y1 + _pad;
		var _ix2 = _panel_c.rect.x2 - _pad;
		var _iy2 = _panel_c.rect.y2 - _pad;
		if (_ix2 < _ix1) _ix2 = _ix1;
		if (_iy2 < _iy1) _iy2 = _iy1;
		__EchoChamberAssignPanelRects(_root, _panel_c.children_panels, _ix1, _iy1, _ix2, _iy2);
	}
}

/// @ignore
/// @desc Trim text to fit within max width, appending ellipsis if needed.
function __TrimTextToWidth(_text, _max_w, _font) {
	var _old_font = draw_get_font();
	if (!is_undefined(_font)) {
		draw_set_font(_font);
	}

	var _w = string_width(_text);
	if (_w <= _max_w) {
		if (!is_undefined(_font)) {
			draw_set_font(_old_font);
		}
		return _text;
	}

	var _ellipsis = "...";
	var _ell_w = string_width(_ellipsis);
	var _available = max(0, _max_w - _ell_w);
	var _len = string_length(_text);// Mode layer (built-in).
	var _result = _text;
	while (_len > 0) {
		_result = string_copy(_text, 1, _len);
		if (string_width(_result) <= _available) {
			break;
		}
		_len--;
	}
	_result += _ellipsis;

	if (!is_undefined(_font)) {
		draw_set_font(_old_font);
	}

	return _result;
};
