if (STATEMENT_DEBUG) {
	if (!variable_global_exists("__statement_machines")) {
		global.__statement_machines = [];
	}
	
	if (!variable_global_exists("__statement_lens")) {
		global.__statement_lens = new StatementLens();
	}
}

/// @func StatementLens()
/// @desc Debug visualiser for Statement machines (drawn in GUI space).
/// @return {Struct.StatementLens}
function StatementLens() constructor {
	visible             = true;

	// Which machine are we currently inspecting
	machine_index       = 0;
	machine             = undefined;
	
	// View mode (FULL/RADIAL use the same "full graph" renderer, EGO is special)
	mode                = eStatementLensMode.FULL;

	// Which full-graph layout we use when not in EGO (FULL vs RADIAL vs CLOUD)
	full_layout_mode    = eStatementLensMode.FULL;

	// Overlay mode: extra visual layers (heatmap etc)
	overlay_mode        = eStatementLensOverlay.NONE;
	heat_metric         = eStatementHeatMetric.TIME;
	
	// Camera (world space)
	camera_x              = 0;
	camera_y              = 0;
	camera_zoom           = 1;
	target_camera_x       = 0;
	target_camera_y       = 0;
	target_camera_zoom    = 1;
	camera_zoom_min       = 0.25;
	camera_zoom_max       = 3;
	camera_zoom_step      = 0.1;
	camera_manual_override = false; // set to true when user drags/zooms

	is_dragging_camera        = false;
	drag_camera_start_mouse_x = 0;
	drag_camera_start_mouse_y = 0;
	drag_camera_start_x       = 0;
	drag_camera_start_y       = 0;
	
	// Simple layout store: filled with __DebugNode() structs
	node_layout         = {};
	
	// For detecting when to rebuild layout
	last_machine        = undefined;
	last_state_count    = 0;
	last_layout_mode    = eStatementLensMode.FULL;

	
	// Animation / behaviour config
	lerp_speed_pos      = 0.2;
	lerp_speed_zoom     = 0.2;
	lock_to_active      = true;
	allow_click_to_jump = true;
	force_transitions   = false; // if true, DebugJumpToState uses _force = true

	ego_lerp_speed      = 0.25;  // how fast ego layout slides to new positions
	
	// Node / drawing config
	node_radius         = 16;
	node_hit_radius     = 12;
	
	// Visibility toggles
	show_edges          = true;
	show_labels         = true;
	show_observed_only  = false;
	show_debug_edges    = true;
	show_decl_edges     = true;
	show_manual_edges   = true;
	show_observed_edges = true;
	show_history_edges  = true;
	show_history_sparks = true;
	
	edge_filter_active_only = false;
	edge_filter_recent_ticks = 0; // 0 = disabled
	
	// Edge styling (theme-driven; tile size kept here for UV scaling)
	edge_tile_screen           = 32; // pixels per repeated pattern along the edge

	// Layout animation / relaxation
	layout_lerp_speed          = 0.01;          // slow drift when fully settled
	layout_relax_frames_total  = game_get_speed(gamespeed_fps) * 10;            // how many frames to run the "jostle" sim
	layout_relax_frames_left   = 0;
	layout_min_distance        = node_radius * 5; // desired spacing between nodes in world units
	layout_separation_strength = 0.05;          // how strongly nodes push apart
	layout_anchor_strength     = 0.08;          // how strongly nodes get pulled toward their circle target
	
	// Cloud (force-directed) layout parameters
	cloud_repulsion_strength = 5000;  // how strongly nodes repel each other
	cloud_spring_strength    = 0.005;  // how strongly edges pull states together
	cloud_center_strength    = 0.002;  // pull toward origin to keep graph centered
	cloud_damping            = 0.5;  // velocity damping (0..1)
	
	// Window placement (GUI space)
	window_x      = 32;
	window_y      = 32;
	window_w      = 1000;
	window_h      = 500;
	window_min_w  = 320;
	window_min_h  = 200;
	
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	if (_gui_w > 0) {
		var _max_w = max(window_min_w, _gui_w - window_x - 16);
		window_w = clamp(window_w, window_min_w, _max_w);
	}
	if (_gui_h > 0) {
		var _max_h = max(window_min_h, _gui_h - window_y - 16);
		window_h = clamp(window_h, window_min_h, _max_h);
	}

	is_dragging_window  = false;
	drag_offset_x       = 0;
	drag_offset_y       = 0;

	is_resizing_window  = false;
	resize_start_w      = 0;
	resize_start_h      = 0;
	resize_start_mouse_x = 0;
	resize_start_mouse_y = 0;
	
	// Debug UI theme (used for consistent colours/metrics in standalone drawing helpers)
	ui_theme	= undefined;
	
	// History spark config
	history_spark_speed = 140; // world units per second (layout space)
	history_spark_count = 2;   // simultaneous sparks running along the path
	
	// Info panel scrolling
	info_scroll_y      = 0;
	info_scroll_speed  = 16;   // pixels per wheel notch
	info_scroll_max    = 0;    // updated each draw

	// Info panel data (Echo Chamber list view)
	info_lines     = [];
	info_line_meta = [];
	last_graph     = undefined;
	
	// Transition history render + hover
	history_records          = [];
	history_hover_from_name  = undefined;
	history_hover_to_name    = undefined;
	history_hover_tick       = -1;
	history_spark_distance   = 0;
	history_spark_prev_time  = current_time;
	history_spark_total_prev = 0;
	
	// Heat decay cache (for heatmap smoothing)
	heat_decay_rate    = 0; // 0 = no decay, 0.9 = strong decay toward zero
	heat_cache_states  = {};
	heat_cache_edges   = {};
		
	// State search (quick search palette)
	search_query            = "";
	search_results          = [];
	search_selected_index   = -1;
	search_focus_state_name = undefined;
		
	// State inspector popup (RMB on node)
	inspect_is_open     = false;
	inspect_state_name  = undefined;
	inspect_anchor_x    = 0;
	inspect_anchor_y    = 0;
	inspect_width       = 260;
	inspect_height      = 260;
	inspect_tag_editing = false;
	inspect_scroll_y    = 0;
	inspect_rect_cached = undefined;
	inspect_pending_wheel = 0;
	
	// Paused banner (drawn in graph panel)
	pause_banner_resumed_time_ms = -1;
	pause_banner_resumed_hold_ms = 700;
	pause_banner_resumed_fade_ms = 2200;
	
	// Edge inspector popup (RMB on edge)
	edge_inspect_is_open   = false;
	edge_inspect_from_name = undefined;
	edge_inspect_to_name   = undefined;
	edge_inspect_anchor_x  = 0;
	edge_inspect_anchor_y  = 0;
	edge_inspect_width     = 260;
	edge_inspect_height    = 180;
	edge_inspect_rect_cached = undefined;
	edge_inspect_edge_ref  = undefined;
		
	// Machine picker state
	machine_filter_query   = "";
	machine_filter_show_instances = true;
	machine_filter_show_structs   = true;
	machine_filter_active_only    = false;
		
	// Camera/layout bookmarks
	bookmarks = [];
		
	// Ego layout tracking
	last_ego_center_name = undefined;
	ego_selected_name     = undefined;
	ego_selected_side     = undefined; // "out" or "in"
	ego_selected_out_idx  = -1;
	ego_selected_in_idx   = -1;
	
	ui_theme = new EchoChamberTheme();
	ui_theme.RefreshMetrics();
	
	/// @ignore
	/// @desc Refresh cached machine pointer from the global list.
	static __RefreshMachine = function() {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		if (!variable_global_exists("__statement_machines")) {
			machine = undefined;
			return;
		}
		
		var _machines = global.__statement_machines;
		var _count    = array_length(_machines);
		
		if (_count <= 0) {
			machine = undefined;
			return;
		}
		
		if (machine_index < 0) {
			machine_index = 0;
		}
		if (machine_index >= _count) {
			machine_index = _count - 1;
		}
		
		// Walk the registry until we find a live machine, or conclude there are none
		var _loops       = 0;
		var _found       = undefined;
		
		while (_loops < _count) {
			var _entry   = _machines[machine_index];
			var _machine = __StatementDebugDerefMachineEntry(_entry);
			
			if (is_struct(_machine)) {
				_found = _machine;
				break;
			}
			
			machine_index++;
			if (machine_index >= _count) {
				machine_index = 0;
			}
			
			_loops++;
		}
		
		machine = _found;
	};

	
	/// @ignore
	/// @desc Cycle to the next machine in the global list.
	static __NextMachine = function() {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		machine_index++;
		__RefreshMachine();
		__RebuildLayout();
	};
	
	/// @ignore
	/// @desc Cycle to the previous machine in the global list.
	static __PrevMachine = function() {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		machine_index--;
		__RefreshMachine();
		__RebuildLayout();
	};
	
	/// @ignore
	/// @desc Try to focus on machines owned by a specific instance/struct.
	static __FocusOwner = function(_owner) {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		if (!variable_global_exists("__statement_machines")) {
			return;
		}
		
		var _machines = global.__statement_machines;
		var _count    = array_length(_machines);
		
		for (var _i = 0; _i < _count; _i++) {
			var _entry = _machines[_i];
			var _m     = __StatementDebugDerefMachineEntry(_entry);
			
			if (!is_struct(_m)) {
				continue;
			}
			
			if (_m.owner == _owner) {
				machine_index = _i;
				__RefreshMachine();
				__RebuildLayout();
				return;
			}
		}
	};

	
	/// @desc Set visibility of the visualiser.
	/// @param {Bool} _visible True to show the visualiser, false to hide it.
	/// @return {Struct.StatementLens}
	static SetVisible = function(_visible) {
		visible = _visible;
		return self;
	};
	
	/// @desc Whether the visualiser is visible.
	/// @return {Bool}
	static IsVisible = function() {
		return visible;
	};
	
	/// @ignore
	/// @desc Set visualiser mode (FULL / RADIAL / EGO).
	static __SetMode = function(_mode) {
		if (mode == _mode) {
			return self;
		}
		
		mode = _mode;
		
		if (mode == eStatementLensMode.EGO) {
			// Reset ego layout so the first frame in EGO seeds positions.
			var _keys  = variable_struct_get_names(node_layout);
			var _count = variable_struct_names_count(node_layout);
			
			for (var _i = 0; _i < _count; _i++) {
				var _key  = _keys[_i];
				var _node = node_layout[$ _key];
				
				if (variable_struct_exists(_node, "ego_initialized")) {
					_node.ego_initialized = false;
				}
			}
		} 
		else {
			// Remember which full-graph layout we are using and rebuild.
			full_layout_mode = mode;
			__RebuildLayout();
		}
		
		return self;
	};
	
	/// @ignore
	/// @desc Toggle between EGO and the last full-graph layout (FULL / RADIAL).
	static __ToggleMode = function() {
		if (mode == eStatementLensMode.EGO) {
			// Return to whichever full layout was last active.
			__SetMode(full_layout_mode);
		} 
		else {
			// Remember current full layout and switch to EGO.
			full_layout_mode = mode;
			__SetMode(eStatementLensMode.EGO);
		}
		
		return self;
	};
	
	/// @ignore
	/// @desc Center the camera target on the machine's active state.
	/// @param {Bool} [snap]  If true, also snap the camera immediately to the target.
	static __CenterCameraOnActive = function(_snap = false) {
		if (!STATEMENT_DEBUG) {
			return;
		}

		if (is_undefined(machine)) {
			last_graph = undefined;
			return;
		}
		if (is_undefined(machine.state)) {
			return;
		}

		var _name = machine.state.name;
		if (!variable_struct_exists(node_layout, _name)) {
			return;
		}

		var _node = node_layout[$ _name];

		if (mode == eStatementLensMode.EGO) {
			// Ego view: active state is treated as world origin (0, 0).
			// Keep the camera centered on that origin.
			target_camera_x = 0;
			target_camera_y = 0;
		} 
		else {
			// Full view: use the relaxed circular layout position.
			target_camera_x = _node.x;
			target_camera_y = _node.y;
		}

		if (_snap) {
			camera_x = target_camera_x;
			camera_y = target_camera_y;
		}
	};
	
	/// @ignore
	/// @desc Apply themed colors to a single node.
	static __ApplyNodeTheme = function(_node) {
		if (!is_struct(_node)) {
			return;
		}
		
		var _stmt = (is_instanceof(ui_theme, EchoChamberTheme) ? ui_theme.statement : undefined);
		if (!is_struct(_stmt)) {
			return;
		}
		
		var _col_text = ui_theme.col_text;
		
		if (variable_struct_exists(_stmt, "node_base_col")) {
			_node.col_fill = _stmt.node_base_col;
		}
		_node.col_outline = _col_text;
		
		if (variable_struct_exists(_stmt, "node_active_col")) {
			_node.active_col_fill    = _stmt.node_active_col;
			_node.active_col_outline = _col_text;
		}
		
		if (variable_struct_exists(_stmt, "node_prev_col")) {
			_node.prev_col_fill    = _stmt.node_prev_col;
			_node.prev_col_outline = _col_text;
		}
	};
	
	/// @ignore
	/// @desc Apply themed colors across all nodes in the current layout.
	static __ApplyThemeToNodes = function() {
		if (!is_struct(node_layout)) {
			return;
		}
		var _keys  = variable_struct_get_names(node_layout);
		var _count = variable_struct_names_count(node_layout);
		for (var _i = 0; _i < _count; _i++) {
			var _key  = _keys[_i];
			var _node = node_layout[$ _key];
			__ApplyNodeTheme(_node);
		}
	};
	
	/// @ignore
	/// @desc Build or rebuild a layered layout for all states (rooted + barycentric).
	static __RebuildLayout = function() {
		if (!STATEMENT_DEBUG) {
			return;
		}
	
		if (is_undefined(machine)) {
			node_layout              = {};
			last_state_count         = 0;
			last_machine             = undefined;
			layout_relax_frames_left = 0;
			return;
		}
	
		var _graph = machine.GetDebugGraph();
		if (is_undefined(_graph)) {
			node_layout              = {};
			last_state_count         = 0;
			last_machine             = machine;
			layout_relax_frames_left = 0;
			return;
		}
		
		// CLOUD: use a dedicated seeding function and skip the layered layout
		if (full_layout_mode == eStatementLensMode.CLOUD) {
			__RebuildLayoutCloud(_graph);
			return;
		}
		
		// RADIAL: place states evenly around a circle
		if (full_layout_mode == eStatementLensMode.RADIAL) {
			__RebuildLayoutRadial(_graph);
			return;
		}
	
		var _states       = _graph.states;
		var _edges        = _graph.edges;
		var _state_count  = array_length(_states);
		var _is_new_machine = (machine != last_machine);
	
		// Only reuse old positions when we are rebuilding for the same machine.
		var _old_layout = _is_new_machine ? undefined : node_layout;
	
		node_layout      = {};
		last_state_count = _state_count;
		last_machine     = machine;
	
		if (_state_count <= 0) {
			layout_relax_frames_left = 0;
			return;
		}
	
		// -------------------------------------------------------------------------
		// 1) Build incoming / outgoing adjacency lists by state name
		// -------------------------------------------------------------------------
		var _incoming = {};
		var _outgoing = {};
	
		for (var _i = 0; _i < _state_count; _i++) {
			var _st   = _states[_i];
			var _name = _st.name;
			_incoming[$ _name] = [];
			_outgoing[$ _name] = [];
		}
	
		var _edge_count = array_length(_edges);
		for (var _e = 0; _e < _edge_count; _e++) {
			var _edge = _edges[_e];
			var _from = _edge.from_name;
			var _to   = _edge.to_name;
		
			if (!variable_struct_exists(_incoming, _to)) {
				continue;
			}
			if (!variable_struct_exists(_outgoing, _from)) {
				continue;
			}
		
			array_push(_incoming[$ _to], _from);
			array_push(_outgoing[$ _from], _to);
		}
	
		// -------------------------------------------------------------------------
		// 2) Choose a root for the main component
		// -------------------------------------------------------------------------
		var _root_candidates = [];
		var _names_all       = variable_struct_get_names(_incoming);
		var _names_count     = variable_struct_names_count(_incoming);
	
		for (var _ni = 0; _ni < _names_count; _ni++) {
			var _nm   = _names_all[_ni];
			var _in_a = _incoming[$ _nm];
			if (array_length(_in_a) <= 0) {
				array_push(_root_candidates, _nm);
			}
		}
	
		var _start_name;
		if (array_length(_root_candidates) > 0) {
			_start_name = _root_candidates[0];
		} 
		else if (!is_undefined(machine.state)) {
			_start_name = machine.state.name;
		} 
		else {
			_start_name = _states[0].name;
		}
	
		// -------------------------------------------------------------------------
		// 3) BFS layering with possible extra "islands" to the right
		// -------------------------------------------------------------------------
		var _layer_map = {};  // name -> layer index
		var _layers    = [];  // array of [names]
		var _queue     = [];
		var _front     = 0;
	
		// Seed first root
		_layer_map[$ _start_name] = 0;
		_layers[0] = [];
		array_push(_layers[0], _start_name);
		array_push(_queue, _start_name);
	
		while (true) {
			// BFS from all queued roots
			while (_front < array_length(_queue)) {
				var _cur        = _queue[_front];
				_front++;
			
				var _cur_layer  = _layer_map[$ _cur];
				var _next_layer = _cur_layer + 1;
			
				if (!variable_struct_exists(_outgoing, _cur)) {
					continue;
				}
			
				var _outs     = _outgoing[$ _cur];
				var _outs_len = array_length(_outs);
				for (var _oi = 0; _oi < _outs_len; _oi++) {
					var _child = _outs[_oi];
				
					if (!variable_struct_exists(_layer_map, _child)) {
						_layer_map[$ _child] = _next_layer;
					
						if (array_length(_layers) <= _next_layer || is_undefined(_layers[_next_layer])) {
							_layers[_next_layer] = [];
						}
						array_push(_layers[_next_layer], _child);
						array_push(_queue, _child);
					}
				}
			}
		
			// Look for any state not yet assigned to a layer
			var _next_unassigned = undefined;
			for (var _si = 0; _si < _state_count; _si++) {
				var _st2   = _states[_si];
				var _name2 = _st2.name;
				if (!variable_struct_exists(_layer_map, _name2)) {
					_next_unassigned = _name2;
					break;
				}
			}
		
			if (is_undefined(_next_unassigned)) {
				break;
			}
		
			// Start a new island to the right
			var _new_layer_index = array_length(_layers);
			_layer_map[$ _next_unassigned] = _new_layer_index;
			_layers[_new_layer_index] = [];
			array_push(_layers[_new_layer_index], _next_unassigned);
			array_push(_queue, _next_unassigned);
		}
	
		// -------------------------------------------------------------------------
		// 4) Compute target positions:
		//    X from layer index, Y from barycenter of parents, then centered stack
		// -------------------------------------------------------------------------
		var _tick         = machine.debug_tick_counter;
		var _y_by_name    = {};  // name -> target_y
	
		var _base_x       = 0;
		var _x_step       = layout_min_distance * 2;
		var _vert_spacing = layout_min_distance;
	
		var _layer_count = array_length(_layers);
	
		for (var _layer = 0; _layer < _layer_count; _layer++) {
			if (is_undefined(_layers[_layer])) {
				continue;
			}
		
			var _names_layer = _layers[_layer];
			var _layer_len   = array_length(_names_layer);
			if (_layer_len <= 0) {
				continue;
			}
		
			// Build entries (name + desired_y)
			var _entries = [];
			for (var _li = 0; _li < _layer_len; _li++) {
				var _nm_layer  = _names_layer[_li];
				var _desired_y = 0;
			
				if (_layer == 0) {
					// First layer: give a quick spread; we will re-center anyway.
					var _offset = (_li - (_layer_len - 1) * 0.5) * _vert_spacing;
					_desired_y  = _offset;
				} 
				else {
					// Barycenter of parents in previous layer
					var _parents      = _incoming[$ _nm_layer];
					var _sum_y        = 0;
					var _parent_count = 0;
					var _p_len        = array_length(_parents);
				
					for (var _pi = 0; _pi < _p_len; _pi++) {
						var _pname = _parents[_pi];
						if (!variable_struct_exists(_layer_map, _pname)) {
							continue;
						}
						if (_layer_map[$ _pname] != _layer - 1) {
							continue;
						}
						if (!variable_struct_exists(_y_by_name, _pname)) {
							continue;
						}
						_sum_y += _y_by_name[$ _pname];
						_parent_count++;
					}
				
					if (_parent_count > 0) {
						_desired_y = _sum_y / _parent_count;
					} 
					else {
						_desired_y = 0;
					}
				}
			
				_entries[_li] = {
					name      : _nm_layer,
					desired_y : _desired_y
				};
			}
		
			// Sort by desired_y so nodes line up under/among their parents
			for (var _a = 0; _a < _layer_len - 1; _a++) {
				for (var _b = _a + 1; _b < _layer_len; _b++) {
					if (_entries[_b].desired_y < _entries[_a].desired_y) {
						var _tmp     = _entries[_a];
						_entries[_a] = _entries[_b];
						_entries[_b] = _tmp;
					}
				}
			}
		
			// Compute average desired_y for this layer
			var _sum_desired = 0;
			for (var _ei = 0; _ei < _layer_len; _ei++) {
				_sum_desired += _entries[_ei].desired_y;
			}
			var _mean_y = _sum_desired / _layer_len;
		
			// Center a stack of equally spaced nodes around _mean_y
			var _total_span = _vert_spacing * max(0, _layer_len - 1);
			var _first_y    = _mean_y - _total_span * 0.5;
		
			for (var _ei2 = 0; _ei2 < _layer_len; _ei2++) {
				var _entry2     = _entries[_ei2];
				var _name_final = _entry2.name;
			
				var _target_x = _base_x + _x_step * _layer;
				var _target_y = _first_y + _vert_spacing * _ei2;
			
				_y_by_name[$ _name_final] = _target_y;
			
				var _x_cur;
				var _y_cur;
				var _vx_cur;
				var _vy_cur;
				var _disc;
			
				if (is_struct(_old_layout) && variable_struct_exists(_old_layout, _name_final)) {
					var _old = _old_layout[$ _name_final];
					_x_cur  = _old.x;
					_y_cur  = _old.y;
					_vx_cur = _old.vx;
					_vy_cur = _old.vy;
					_disc   = _old.discovered_tick;
				} 
				else {
					_x_cur  = _target_x;
					_y_cur  = _target_y;
					_vx_cur = 0;
					_vy_cur = 0;
					_disc   = _tick;
				}
			
				node_layout[$ _name_final] = new __DebugNode(
					_name_final,
					_x_cur, _y_cur,
					_vx_cur, _vy_cur,
					_target_x, _target_y,
					_disc
				);
			}
		}
	
		// Clear inspector when switching to a new machine
		if (_is_new_machine) {
			inspect_is_open    = false;
			inspect_state_name = undefined;
			edge_inspect_is_open   = false;
			edge_inspect_from_name = undefined;
			edge_inspect_to_name   = undefined;
			edge_inspect_edge_ref  = undefined;
		}
			
		// Run a short relaxation phase so nodes can jostle into place
		__ApplyThemeToNodes();
		layout_relax_frames_left = layout_relax_frames_total;
		
		// Snap camera to the current state once when rebuilding.
		camera_manual_override = false;
		__CenterCameraOnActive(true);
	};
	
	/// @ignore
	/// @desc Per-frame update: layout, camera follow, and node relaxation.
	static __Update = function() {
		if (!STATEMENT_DEBUG) {
			return;
		}
	
		if (!visible) {
			return;
		}
	
		__RefreshMachine();
	
		if (is_undefined(machine)) {
			return;
		}
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	
		var _graph = machine.GetDebugGraph();
		if (is_undefined(_graph)) {
			last_graph = undefined;
			return;
		}
		last_graph = _graph;
	
		var _states      = _graph.states;
		var _state_count = array_length(_states);
	
		if (machine != last_machine || _state_count != last_state_count) {
			__RebuildLayout();
		}
		
		// Auto-follow active state when locked; manual override is ignored while locked.
		if (lock_to_active) {
			camera_manual_override = false;
			__CenterCameraOnActive(false);
		}
	
		// Smoothly move camera toward its target (applies to both FULL and EGO).
		var _t_pos  = lerp_speed_pos;
		var _t_zoom = lerp_speed_zoom;
	
		camera_x    = lerp(camera_x,    target_camera_x, _t_pos);
		camera_y    = lerp(camera_y,    target_camera_y, _t_pos);
		camera_zoom = lerp(camera_zoom, target_camera_zoom, _t_zoom);
			
		// Layout relaxation and anchoring for nodes.
		var _node_keys  = variable_struct_get_names(node_layout);
		var _node_count = variable_struct_names_count(node_layout);
	
		if (_node_count > 0) {
			if (full_layout_mode == eStatementLensMode.CLOUD) {
				// Continuous force-directed layout
				__UpdateCloudLayout(_graph, _node_keys, _node_count);
			} 
			else {
				// Existing layered layout relax/settle behaviour
				if (layout_relax_frames_left > 0) {
					// Short-lived "boid-ish" phase: nodes push apart if too close and are pulled toward their targets.
					var _min_dist     = layout_min_distance;
					var _min_dist_sq  = _min_dist * _min_dist;
					var _sep_strength = layout_separation_strength;
					var _anchor_t     = layout_anchor_strength;
				
					// Pairwise separation
					for (var _i = 0; _i < _node_count; _i++) {
						var _key_i = _node_keys[_i];
						var _ni    = node_layout[$ _key_i];
					
						for (var _j = _i + 1; _j < _node_count; _j++) {
							var _key_j = _node_keys[_j];
							var _nj    = node_layout[$ _key_j];
						
							var _dx = _nj.x - _ni.x;
							var _dy = _nj.y - _ni.y;
							var _dist_sq = _dx * _dx + _dy * _dy;
						
							if (_dist_sq <= 0) {
								continue;
							}
						
							if (_dist_sq < _min_dist_sq) {
								var _dist    = sqrt(_dist_sq);
								var _overlap = _min_dist - _dist;
								if (_overlap > 0) {
									var _push = _overlap * _sep_strength;
									var _nx   = _dx / _dist;
									var _ny   = _dy / _dist;
								
									// Move each node half the push in opposite directions.
									_ni.x -= _nx * _push * 0.5;
									_ni.y -= _ny * _push * 0.5;
									_nj.x += _nx * _push * 0.5;
									_nj.y += _ny * _push * 0.5;
								}
							}
						}
					}
				
					// Pull nodes back toward their circle targets.
					for (var _k = 0; _k < _node_count; _k++) {
						var _key_k = _node_keys[_k];
						var _nk    = node_layout[$ _key_k];

						_nk.x = lerp(_nk.x, _nk.target_x, _anchor_t);
						_nk.y = lerp(_nk.y, _nk.target_y, _anchor_t);
					}
				
					layout_relax_frames_left--;
				
					// When relaxation finishes, lock the final positions in as the new targets.
					if (layout_relax_frames_left <= 0) {
						for (var _m = 0; _m < _node_count; _m++) {
							var _key_m = _node_keys[_m];
							var _nm    = node_layout[$ _key_m];
						
							_nm.target_x = _nm.x;
							_nm.target_y = _nm.y;
						}
					}
				} 
				else {
					// Settled: just keep nodes very close to their (now relaxed) targets.
					var _t_layout = layout_lerp_speed;
					for (var _n = 0; _n < _node_count; _n++) {
						var _key  = _node_keys[_n];
						var _node = node_layout[$ _key];
					
						_node.x = lerp(_node.x, _node.target_x, _t_layout);
						_node.y = lerp(_node.y, _node.target_y, _t_layout);
					}
				}
			}
		}
	};
	
	/// @ignore
	/// @desc Per-frame force-directed layout update for CLOUD mode.
	/// @param	{Struct}	_graph
	/// @param	{Struct}	_node_keys
	/// @param	{Real}	_node_count
	static __UpdateCloudLayout = function(_graph, _node_keys, _node_count) {
		if (_node_count <= 0) {
			return;
		}
		
		var _nodes = node_layout;
		
		// Build index lookup for edges
		var _index_by_name = {};
		for (var _i = 0; _i < _node_count; _i++) {
			var _key = _node_keys[_i];
			_index_by_name[$ _key] = _i;
		}
		
		var _forces_x = array_create(_node_count, 0);
		var _forces_y = array_create(_node_count, 0);
		
		var _repel_k   = cloud_repulsion_strength;
		var _spring_k  = cloud_spring_strength;
		var _center_k  = cloud_center_strength;
		var _damping   = cloud_damping;
		var _min_dist  = layout_min_distance;
		
		// 1) Node-node repulsion
		for (var _a = 0; _a < _node_count; _a++) {
			var _key_a = _node_keys[_a];
			var _na    = _nodes[$ _key_a];
			
			for (var _b = _a + 1; _b < _node_count; _b++) {
				var _key_b = _node_keys[_b];
				var _nb    = _nodes[$ _key_b];
				
				var _dx = _nb.x - _na.x;
				var _dy = _nb.y - _na.y;
				var _dist_sq = _dx * _dx + _dy * _dy;
				
				if (_dist_sq <= 0) {
					// Nudge apart if perfectly overlapping
					_dx = random_range(-1, 1);
					_dy = random_range(-1, 1);
					_dist_sq = _dx * _dx + _dy * _dy;
				}
				
				var _dist = sqrt(_dist_sq);
				if (_dist <= 0) {
					continue;
				}
				
				// Repulsive force drops with distance squared
				var _inv_dist_sq = 1 / _dist_sq;
				var _force_mag   = _repel_k * _inv_dist_sq;
				
				// Optional clamp so it does not explode at very short distances
				var _max_force = _repel_k / (_min_dist * _min_dist);
				if (_force_mag > _max_force) {
					_force_mag = _max_force;
				}
				
				var _nx = _dx / _dist;
				var _ny = _dy / _dist;
				
				var _fx = _nx * _force_mag;
				var _fy = _ny * _force_mag;
				
				_forces_x[_a] -= _fx;
				_forces_y[_a] -= _fy;
				_forces_x[_b] += _fx;
				_forces_y[_b] += _fy;
			}
		}
		
		// 2) Edge springs (pull connected states together around a target length)
		var _edges      = _graph.edges;
		var _edge_count = array_length(_edges);
		var _target_len = _min_dist * 1.5;
		
		for (var _e = 0; _e < _edge_count; _e++) {
			var _edge = _edges[_e];
			
			var _from_name = _edge.from_name;
			var _to_name   = _edge.to_name;
			
			if (!variable_struct_exists(_index_by_name, _from_name)) {
				continue;
			}
			if (!variable_struct_exists(_index_by_name, _to_name)) {
				continue;
			}
			
			var _ia = _index_by_name[$ _from_name];
			var _ib = _index_by_name[$ _to_name];
			
			var _key_a2 = _node_keys[_ia];
			var _key_b2 = _node_keys[_ib];
			
			var _na2 = _nodes[$ _key_a2];
			var _nb2 = _nodes[$ _key_b2];
			
			var _dx2 = _nb2.x - _na2.x;
			var _dy2 = _nb2.y - _na2.y;
			var _dist2_sq = _dx2 * _dx2 + _dy2 * _dy2;
			
			if (_dist2_sq <= 0) {
				continue;
			}
			
			var _dist2 = sqrt(_dist2_sq);
			var _nx2   = _dx2 / _dist2;
			var _ny2   = _dy2 / _dist2;
			
			var _stretch    = _dist2 - _target_len;
			var _force_mag2 = _spring_k * _stretch;
			
			var _fx2 = _nx2 * _force_mag2;
			var _fy2 = _ny2 * _force_mag2;
			
			_forces_x[_ia] += _fx2;
			_forces_y[_ia] += _fy2;
			_forces_x[_ib] -= _fx2;
			_forces_y[_ib] -= _fy2;

		}
		
		// 3) Soft pull toward origin to keep cluster centered
		for (var _i2 = 0; _i2 < _node_count; _i2++) {
			var _key_c = _node_keys[_i2];
			var _nc    = _nodes[$ _key_c];
			
			_forces_x[_i2] += -_nc.x * _center_k;
			_forces_y[_i2] += -_nc.y * _center_k;
		}
		
		// 4) Integrate velocities and positions
		for (var _i3 = 0; _i3 < _node_count; _i3++) {
			var _key_n = _node_keys[_i3];
			var _nn    = _nodes[$ _key_n];
			
			_nn.vx = (_nn.vx + _forces_x[_i3]) * _damping;
			_nn.vy = (_nn.vy + _forces_y[_i3]) * _damping;
			
			_nn.x += _nn.vx;
			_nn.y += _nn.vy;
			
			// Keep target positions in sync so other code (camera, etc.) can rely on them.
			_nn.target_x = _nn.x;
			_nn.target_y = _nn.y;
		}
	};
	
	/// @ignore
	/// @desc Build initial positions for CLOUD layout:
	///       all nodes start collapsed on the current active state's position,
	///       then the force sim pushes them apart.
	/// @param {Struct}	_graph
	static __RebuildLayoutCloud = function(_graph) {
		var _states      = _graph.states;
		var _state_count = array_length(_states);
		
		var _is_new_machine = (machine != last_machine);
		var _old_layout     = node_layout; // may be from FULL/RADIAL or previous CLOUD
		
		node_layout      = {};
		last_state_count = _state_count;
		last_machine     = machine;
		
		if (_state_count <= 0) {
			layout_relax_frames_left = 0;
			return;
		}
		
		var _tick = machine.debug_tick_counter;
		
		// Seed nodes in "cloud space":
		//   - active state at (0, 0)
		//   - all other states on a small ring around it
		var _active_name = undefined;
		if (!is_undefined(machine.state)) {
			_active_name = machine.state.name;
		}

		var _ring_radius = 10;//max(layout_min_distance, 10);
		var _ring_count  = max(1, _state_count - 1);
		var _angle_step  = (_ring_count > 0) ? (360 / _ring_count) : 0;
		var _ring_index  = 0;

		for (var _i = 0; _i < _state_count; _i++) {
			var _st   = _states[_i];
			var _name = _st.name;

			var _x_cur;
			var _y_cur;

			if (!is_undefined(_active_name) && _name == _active_name) {
				// Active node at the origin
				_x_cur = 0;
				_y_cur = 0;
			} 
			else {
				// Other nodes distributed around a ring
				var _angle = _angle_step * _ring_index;
				_ring_index++;

				_x_cur = lengthdir_x(_ring_radius, _angle);
				_y_cur = lengthdir_y(_ring_radius, _angle);
			}

			var _vx_cur = 0;
			var _vy_cur = 0;
			var _disc   = _tick;

			node_layout[$ _name] = new __DebugNode(
				_name,
				_x_cur, _y_cur,
				_vx_cur, _vy_cur,
				_x_cur, _y_cur,
				_disc
			);
		}
	
		// For cloud we do not use the layered relax phase.
		__ApplyThemeToNodes();
		layout_relax_frames_left = 0;
	
		// Center camera on the active node (at 0,0 in cloud space)
		camera_manual_override = false;
		__CenterCameraOnActive(true);
		
		//// Determine collapse origin: previous position of the active state if possible,
		//// otherwise just use (0, 0).
		//var _center_x = 0;
		//var _center_y = 0;
		
		//if (!_is_new_machine && is_struct(_old_layout) && !is_undefined(machine.state)) {
		//	var _center_name = machine.state.name;
		//	if (variable_struct_exists(_old_layout, _center_name)) {
		//		var _old_center_node = _old_layout[$ _center_name];
		//		_center_x = _old_center_node.x;
		//		_center_y = _old_center_node.y;
		//	}
		//}
		
		//// If there is no active state at all, optionally fall back to the
		//// first state's old position (if available), just to stay near the
		//// previous framing. This is purely cosmetic.
		//if (_center_x == 0 && _center_y == 0) {
		//	if (!_is_new_machine && is_struct(_old_layout) && _state_count > 0) {
		//		var _fallback_name = _states[0].name;
		//		if (variable_struct_exists(_old_layout, _fallback_name)) {
		//			var _old_fallback = _old_layout[$ _fallback_name];
		//			_center_x = _old_fallback.x;
		//			_center_y = _old_fallback.y;
		//		}
		//	}
		//}
		
		//// Seed every node exactly at the collapse origin so the cloud
		//// "explodes" out of the active state when forces are applied.
		//var _dir_inc = 360 / _state_count;
		//var _offset_base = 50;
		//for (var _i = 0; _i < _state_count; _i++) {
		//	var _st   = _states[_i];
		//	var _name = _st.name;
			
		//	var _offset = _offset_base;
		//	var _dir = _dir_inc * _i;
		//	var _x_cur  = _center_x + lengthdir_x(_offset, _dir);
		//	var _y_cur  = _center_y + lengthdir_y(_offset, _dir);
		//	var _vx_cur = 0;
		//	var _vy_cur = 0;
		//	var _disc   = _tick;
			
		//	node_layout[$ _name] = new __DebugNode(
		//		_name,
		//		_x_cur, _y_cur,
		//		_vx_cur, _vy_cur,
		//		_center_x, _center_y,
		//		_disc
		//	);
		//}
		
		// New machine -> clear inspector
		if (_is_new_machine) {
			inspect_is_open    = false;
			inspect_state_name = undefined;
		}
			
		__ApplyThemeToNodes();
			
	};
	
	/// @ignore
	/// @desc Build positions using a simple radial layout (evenly spaced circle).
	static __RebuildLayoutRadial = function(_graph) {
		if (is_undefined(_graph)) {
			return;
		}
		
		var _states      = _graph.states;
		var _state_count = array_length(_states);
		
		var _is_new_machine = (machine != last_machine);
		var _old_layout     = _is_new_machine ? undefined : node_layout;
		
		node_layout      = {};
		last_state_count = _state_count;
		last_machine     = machine;
		
		if (_state_count <= 0) {
			layout_relax_frames_left = 0;
			return;
		}
		
		var _tick        = machine.debug_tick_counter;
		var _radius_base = layout_min_distance * max(3, sqrt(_state_count) * 2);
		var _active_name = (!is_undefined(machine.state) ? machine.state.name : undefined);
		
		for (var _i = 0; _i < _state_count; _i++) {
			var _st   = _states[_i];
			var _name = _st.name;
			
			var _angle;
			if (!is_undefined(_active_name) && _name == _active_name) {
				_angle = 0;
			} 
			else {
				_angle = (2 * pi) * (_i / _state_count);
			}
			
			var _target_x = cos(_angle) * _radius_base;
			var _target_y = sin(_angle) * _radius_base;
			
			var _x_cur = _target_x;
			var _y_cur = _target_y;
			var _vx_cur = 0;
			var _vy_cur = 0;
			var _disc   = _tick;
			
			if (is_struct(_old_layout) && variable_struct_exists(_old_layout, _name)) {
				var _old = _old_layout[$ _name];
				_x_cur  = _old.x;
				_y_cur  = _old.y;
				_vx_cur = _old.vx;
				_vy_cur = _old.vy;
				_disc   = _old.discovered_tick;
			}
			
			node_layout[$ _name] = new __DebugNode(
				_name,
				_x_cur, _y_cur,
				_vx_cur, _vy_cur,
				_target_x, _target_y,
				_disc
			);
		}
		
		layout_relax_frames_left = layout_relax_frames_total;
		
		if (_is_new_machine) {
			inspect_is_open    = false;
			inspect_state_name = undefined;
		}
	};

	
	/// @ignore
	/// @desc Helper to fetch or create a debug node for a given state name.
	static __GetOrCreateNode = function(_state_name) {
		if (!variable_struct_exists(node_layout, _state_name)) {
			var _tick = machine.debug_tick_counter;
			node_layout[$ _state_name] = new __DebugNode(_state_name, 0, 0, 0, 0, 0, 0, _tick);
		}
		return node_layout[$ _state_name];
	};
	
	/// @ignore
	/// @desc Helper: smoothly move a state's ego layout position toward a target.
	static __UpdateEgoNodePosition = function(_state_name, _target_wx, _target_wy) {
		var _node = __GetOrCreateNode(_state_name);
		
		// Snap to target each frame in EGO layout so left/right stay aligned.
		_node.ego_x          = _target_wx;
		_node.ego_y          = _target_wy;
		_node.ego_initialized = true;
		
		return _node;
	};

	/// @ignore
	/// @desc Draw the full machine graph inside the given rect and return clicked state name, if any.
	static __DrawFullGraph = function(_graph, _left, _top, _width, _height, _allow_input, _root = undefined) {
		var _mx = 0;
		var _my = 0;
		var _states = _graph.states;
		var _edges  = _graph.edges;
		
		var _l_pressed = false;
		var _r_pressed = false;
		var _mouse_consumed = false;
		
		if (is_struct(_root)) {
			_mx = _root.mx;
			_my = _root.my;
			_l_pressed = _root.mouse_l_pressed;
			_r_pressed = _root.mouse_r_pressed;
			_mouse_consumed = _root.mouse_consumed;
		}
		else {
			_mx = device_mouse_x_to_gui(0);
			_my = device_mouse_y_to_gui(0);
			_l_pressed = mouse_check_button_pressed(mb_left);
			_r_pressed = mouse_check_button_pressed(mb_right);
			_mouse_consumed = false;
		}
	
		 // Heatmap stats (if overlay enabled)
	    var _stats       = machine.GetDebugStateStats();
	    var _use_heatmap = (overlay_mode == eStatementLensOverlay.HEATMAP) && !is_undefined(_stats);
		var _use_visits  = (heat_metric == eStatementHeatMetric.VISITS);
	    var _max_metric  = 0;
	    var _max_edge_hits = 0;
	    
	    if (_use_heatmap) {
	        // Node heat: based on total_frames per state (or entry_count when using visit heat).
	        var _state_count_for_max = array_length(_states);
	        for (var _si_max = 0; _si_max < _state_count_for_max; _si_max++) {
	            var _st_max   = _states[_si_max];
	            var _name_max = _st_max.name;
	            
	            if (!variable_struct_exists(_stats, _name_max)) {
	                continue;
	            }
	            
	            var _s_max = _stats[$ _name_max];
				var _val = _use_visits ? _s_max.entry_count : _s_max.total_frames;
	            if (_val > _max_metric) {
	                _max_metric = _val;
	            }
	        }
	    }
    
	    // Edge heat: based on how many times a transition has fired (edge.hits).
	    if (overlay_mode == eStatementLensOverlay.HEATMAP) {
	        var _edge_count_for_max = array_length(_edges);
	        for (var _ei_max = 0; _ei_max < _edge_count_for_max; _ei_max++) {
	            var _edge_max = _edges[_ei_max];
	            if (is_struct(_edge_max) && variable_struct_exists(_edge_max, "hits")) {
	                if (_edge_max.hits > _max_edge_hits) {
	                    _max_edge_hits = _edge_max.hits;
	                }
	            }
	        }
	    }
	
		var _cx = _left + _width  * 0.5;
		var _cy = _top  + _height * 0.5;
		
		var _rmb_hit_node = false;
		var _rmb_hit_edge = false;
		var _hovered_edge = undefined;
		var _hovered_edge_dist_sq = -1;
	
		var _current_state_name   = (!is_undefined(machine.state)          ? machine.state.name           : undefined);
		var _previous_state_name  = (!is_undefined(machine.previous_state) ? machine.previous_state.name  : undefined);
		var _queued_state_name    = (machine.HasQueuedState()              ? machine.GetQueuedStateName() : undefined);
	
		// First pass: determine which node (if any) is hovered
		var _hovered_name = undefined;
		if (_allow_input) {
			var _state_count_hover = array_length(_states);
			for (var _hi = 0; _hi < _state_count_hover; _hi++) {
				var _hst   = _states[_hi];
				var _hname = _hst.name;
			
				if (!variable_struct_exists(node_layout, _hname)) {
					continue;
				}
			
				var _hnode = node_layout[$ _hname];
				var _hsx   = _cx + (_hnode.x - camera_x) * camera_zoom;
				var _hsy   = _cy + (_hnode.y - camera_y) * camera_zoom;
			
				var _dx_h   = _mx - _hsx;
				var _dy_h   = _my - _hsy;
				var _dist_h = sqrt(_dx_h * _dx_h + _dy_h * _dy_h);
				if (_dist_h <= max(node_hit_radius * camera_zoom, 8)) {
					_hovered_name = _hname;
					// No break: last hit wins if overlapping
				}
			}
		}
	
		// Draw edges (styled) with hover + heat alpha
		var _edge_count = array_length(_edges);
		for (var _ei = 0; _ei < _edge_count; _ei++) {
			var _edge = _edges[_ei];
			var _from = _edge.from_name;
			var _to   = _edge.to_name;
			var _kind = is_struct(_edge) && variable_struct_exists(_edge, "kind") ? _edge.kind : eStatementDebugEdgeKind.DECLARATIVE;
			var _debug_created = (is_struct(_edge) && variable_struct_exists(_edge, "debug_created") && _edge.debug_created);
			
			if (!__EdgeVisibleByFilter(_kind, _debug_created)) {
				continue;
			}
			if (!__EdgePassesScope(_from, _to, _edge)) {
				continue;
			}
		
			if (!variable_struct_exists(node_layout, _from)) {
				continue;
			}
			if (!variable_struct_exists(node_layout, _to)) {
				continue;
			}
			
			// Visibility toggle: if edges are hidden, only draw edges touching the hovered node.
			if (!show_edges) {
				if (is_undefined(_hovered_name)) {
					continue;
				}
				if (_from != _hovered_name && _to != _hovered_name) {
					continue;
				}
			}
		
			var _n_from = node_layout[$ _from];
			var _n_to   = node_layout[$ _to];
		
			var _sx1 = _cx + (_n_from.x - camera_x) * camera_zoom;
			var _sy1 = _cy + (_n_from.y - camera_y) * camera_zoom;
			var _sx2 = _cx + (_n_to.x   - camera_x) * camera_zoom;
			var _sy2 = _cy + (_n_to.y   - camera_y) * camera_zoom;
		
			var _style = eStatementDebugEdgeStyle.STRUCTURAL;
		
			// Last transition: previous -> current
			if (!is_undefined(_previous_state_name) && !is_undefined(_current_state_name)) {
				if (_from == _previous_state_name && _to == _current_state_name) {
					_style = eStatementDebugEdgeStyle.LAST_TRANSITION;
				}
			}
		
			// Queued transition: current -> queued
			if (!is_undefined(_current_state_name) && !is_undefined(_queued_state_name)) {
				if (_from == _current_state_name && _to == _queued_state_name) {
					_style = eStatementDebugEdgeStyle.QUEUED;
				}
			}
		
			var _edge_alpha = 1;

		    // Hover isolation for edges: fade edges that do not touch hovered node
		    if (!is_undefined(_hovered_name)) {
		        if (_from != _hovered_name && _to != _hovered_name) {
		            _edge_alpha *= 0.25;
		        }
		    }
        
		    var _begin_alpha = _edge_alpha;
		    var _end_alpha   = _edge_alpha;
        
		    // Heatmap fading for edges: if both endpoints are unvisited, fade strongly
		    if (_use_heatmap) {
		        var _from_visited = false;
		        var _to_visited   = false;
            
		        if (variable_struct_exists(_stats, _from)) {
		            var _sf = _stats[$ _from];
		            if (_sf.total_frames > 0 || _sf.entry_count > 0) {
		                _from_visited = true;
		            }
		        }
		        if (variable_struct_exists(_stats, _to)) {
		            var _st = _stats[$ _to];
		            if (_st.total_frames > 0 || _st.entry_count > 0) {
		                _to_visited = true;
		            }
		        }
            
		        if (!(_from_visited || _to_visited)) {
		            _begin_alpha *= 0.15;
		            _end_alpha   *= 0.15;
		        }
		        else if (_from_visited && !_to_visited) {
		            _end_alpha *= 0.15;
		        }
		    }
        
		    // Edge heat factor: based on how often this specific transition has fired.
			var _edge_heat = 0;
			if (overlay_mode == eStatementLensOverlay.HEATMAP) {
		        if (_max_edge_hits > 0 && is_struct(_edge) && variable_struct_exists(_edge, "hits")) {
		            if (_edge.hits > 0) {
		                _edge_heat = clamp(_edge.hits / _max_edge_hits, 0, 1);
		            }
		        }
		    }
			if (_use_heatmap && is_struct(_edge)) {
				var _edge_key = __EdgeKey(_from, _to);
				_edge_heat = __ApplyHeatDecay(heat_cache_edges, _edge_key, _edge_heat);
			}
		
			var _style_cfg = __ResolveEdgeStyle(_style);
			if (_debug_created) {
				_style_cfg = __ResolveEdgeDebugStyle(_style_cfg);
			}
			if (is_struct(_edge) && variable_struct_exists(_edge, "has_error") && _edge.has_error) {
				_style_cfg.color = ui_theme.col_error;
			}
		    __DrawEdgeStyled(_sx1, _sy1, _sx2, _sy2, _style, _begin_alpha, _end_alpha, _edge_heat, 1, _style_cfg);
			
			if (is_struct(_edge) && _edge[$ "debug_break_on_transition"] == true) {
				__DrawEdgeBreakpointMarks(_sx1, _sy1, _sx2, _sy2, _style_cfg, _begin_alpha, _end_alpha, 1, _edge);
			}
			
			// Edge hover hit test (screen space)
			if (_allow_input && !(is_struct(_root) && _root.mouse_consumed)) {
				var _dist_sq = __DistancePointToSegment(_mx, _my, _sx1, _sy1, _sx2, _sy2);
				var _hit_r   = __EdgeHitRadiusPx(_style_cfg, 1);
				if (_dist_sq <= _hit_r * _hit_r) {
					if (_hovered_edge_dist_sq < 0 || _dist_sq < _hovered_edge_dist_sq) {
						_hovered_edge_dist_sq = _dist_sq;
						_hovered_edge = {
							from  : _from,
							to    : _to,
							style : _style,
							edge  : _edge
						};
					}
				}
			}
		}
	
		// History trail overlay (oldest -> newest)
		if (show_history_edges || show_history_sparks) {
			var _hist = history_records;
			var _hist_len = array_length(_hist);
			var _hist_segments = [];
			if (_hist_len > 0) {
				var _start_idx = 0;
				var _span      = max(1, _hist_len - _start_idx - 1);
			
				for (var _hi = _start_idx; _hi < _hist_len; _hi++) {
					var _rec = _hist[_hi];
					if (is_undefined(_rec.from_name) || is_undefined(_rec.to_name)) {
						continue;
					}
					if (!variable_struct_exists(node_layout, _rec.from_name)) {
						continue;
					}
					if (!variable_struct_exists(node_layout, _rec.to_name)) {
						continue;
					}
				
					var _n_from = node_layout[$ _rec.from_name];
					var _n_to   = node_layout[$ _rec.to_name];
				
					var _sxh1 = _cx + (_n_from.x - camera_x) * camera_zoom;
					var _syh1 = _cy + (_n_from.y - camera_y) * camera_zoom;
					var _sxh2 = _cx + (_n_to.x   - camera_x) * camera_zoom;
					var _syh2 = _cy + (_n_to.y   - camera_y) * camera_zoom;
				
					var _t_age    = (_hi - _start_idx) / _span;
					var _alpha_h  = max(0.02, power(0.5, (_span - (_hi - _start_idx) - 1)) * 2);
					_alpha_h = clamp(_alpha_h, 0.1, 1);
					var _thick_h  = lerp(0.5, 1, _t_age);
					var _is_newest = (_hi == _hist_len - 1);
				
					if (_is_newest) {
						_alpha_h  = max(_alpha_h, 1);
						_thick_h  = max(_thick_h, 1);
					}
					
					if (show_history_edges) {
						__DrawEdgeStyled(_sxh1, _syh1, _sxh2, _syh2, eStatementDebugEdgeStyle.HISTORY, _alpha_h, _alpha_h, 0, _thick_h);
					}
					
					if (show_history_sparks) {
						var _seg_len = point_distance(_n_from.x, _n_from.y, _n_to.x, _n_to.y);
						if (_seg_len > 0) {
							array_push(_hist_segments, {
								wx1 : _n_from.x, wy1 : _n_from.y,
								wx2 : _n_to.x,   wy2 : _n_to.y,
								len : _seg_len
							});
						}
					}
				}
				
				if (show_history_sparks) {
					__DrawHistorySparks(_hist_segments, _cx, _cy);
				}
			}
		}

		// Draw nodes
		var _node_clicked_name = undefined;
		var _state_count       = array_length(_states);
	
		for (var _si = 0; _si < _state_count; _si++) {
			var _st   = _states[_si];
			var _name = _st.name;
		
			if (!variable_struct_exists(node_layout, _name)) {
				continue;
			}
		
			var _node = node_layout[$ _name];
			var _sx   = _cx + (_node.x - camera_x) * camera_zoom;
			var _sy   = _cy + (_node.y - camera_y) * camera_zoom;
		
			var _is_active = (!is_undefined(machine.state)          && machine.state.name          == _name);
			var _is_prev   = (!is_undefined(machine.previous_state) && machine.previous_state.name == _name);
		
			// Heat factor and visited flag
			var _heat    = 0;
			var _visited = false;
			if (_use_heatmap && variable_struct_exists(_stats, _name)) {
				var _s = _stats[$ _name];
				var _metric_val = _use_visits ? _s.entry_count : _s.total_frames;
				_visited = (_s.total_frames > 0 || _s.entry_count > 0);
				
				if (_max_metric > 0 && _metric_val > 0) {
					_heat = clamp(_metric_val / _max_metric, 0, 1);
				}
			}
			
			// Alpha from heatmap: heavily dim unvisited nodes
			var _heat_alpha = 1;
			if (_use_heatmap && !_visited) {
				_heat_alpha = 0.15;
			}
		
			// Alpha from hover isolation: dim everything except hovered node
			var _hover_alpha = 1;
			if (!is_undefined(_hovered_name) && _hovered_name != _name) {
				_hover_alpha = ui_theme.statement.node_hover_dim;
			}
		
			var _final_alpha = _heat_alpha * _hover_alpha;
		
			var _show_label_node = show_labels || (!is_undefined(_hovered_name) && _hovered_name == _name);
			var _heat_key = string(_name);
			var _heat_final = (_use_heatmap) ? __ApplyHeatDecay(heat_cache_states, _heat_key, _heat) : _heat;
			__DrawNode(_sx, _sy, _node, _is_active, _is_prev, _heat_final, _final_alpha, _show_label_node);
			if (!is_undefined(_stats) && variable_struct_exists(_stats, _name)) {
				var _s_err = _stats[$ _name];
				if (is_struct(_s_err) && variable_struct_exists(_s_err, "has_error") && _s_err.has_error) {
					__DrawErrorBadge(_sx, _sy, _node.radius * camera_zoom);
				}
			}

			// Host badge for states that own a submachine
			if (is_callable(_st.HasSubMachine) && _st.HasSubMachine()) {
				__DrawSubmachineBadge(_sx, _sy, _node.radius * camera_zoom);
			}
		
			// Hit detection for LMB (jump) and RMB (inspect)
			if (_allow_input && (_l_pressed || _r_pressed)) {
				var _dx   = _mx - _sx;
				var _dy   = _my - _sy;
				var _dist = sqrt(_dx * _dx + _dy * _dy);
				if (_dist <= max(node_hit_radius * camera_zoom, 8)) {
					// LMB -> jump to state
					if (_l_pressed) {
						_node_clicked_name = _name;
						if (is_struct(_root)) {
							_root.ConsumeMouse();
						}
					}
					
					// RMB inspector is handled by the Echo-hosted controller; legacy path only.
					if (!is_struct(_root)) {
						if (_r_pressed) {
							_rmb_hit_node = true;
						
							if (inspect_is_open && inspect_state_name == _name) {
								// Clicking the same state again closes the inspector
								inspect_is_open    = false;
								inspect_state_name = undefined;
							} 
							else {
								// Close any edge inspector when focusing a state node
								edge_inspect_is_open    = false;
								edge_inspect_edge_ref   = undefined;
								edge_inspect_from_name  = undefined;
								edge_inspect_to_name    = undefined;
								inspect_is_open    = true;
								inspect_state_name = _name;
								inspect_anchor_x   = _mx;
								inspect_anchor_y   = _my;
							}
						}
					}
				}
			}
		}
	
		// If RMB was pressed inside the graph this frame but did not hit any node,
		// either open the edge inspector (if hovering an edge) or clear inspectors.
		if (!is_struct(_root)) {
			if (_allow_input && _r_pressed && !_rmb_hit_node) {
				var _inside_graph = (_mx >= _left && _mx <= _left + _width &&
								     _my >= _top  && _my <= _top  + _height);
			
				if (!is_undefined(_hovered_edge)) {
					edge_inspect_is_open   = true;
					edge_inspect_from_name = _hovered_edge.from;
					edge_inspect_to_name   = _hovered_edge.to;
					edge_inspect_edge_ref  = _hovered_edge.edge;
					edge_inspect_anchor_x  = _mx;
					edge_inspect_anchor_y  = _my;
					_rmb_hit_edge          = true;
				
					// Close state inspector when focusing an edge
					inspect_is_open    = false;
					inspect_state_name = undefined;
				} 
				else if (_inside_graph) {
					inspect_is_open        = false;
					inspect_state_name     = undefined;
					edge_inspect_is_open   = false;
					edge_inspect_from_name = undefined;
					edge_inspect_to_name   = undefined;
					edge_inspect_edge_ref  = undefined;
				}
			}
		}
	
		return _node_clicked_name;

	};
	
	/// @ignore
	/// @desc Draw a single state node, with optional overlay factor (heatmap etc).
	static __DrawNode = function(_sx, _sy, _node, _is_active, _is_prev, _overlay_factor = eStatementLensOverlay.NONE, _alpha = 1, _show_label = true) {
		var _name        = _node.name;
		var _col_fill    = _node.col_fill;
		var _col_outline = _node.col_outline;
		var _label_top_y = undefined;
	
		// Base color / radius animation by state role
		if (_is_active) {
			_col_fill    = _node.active_col_fill;
			_col_outline = _node.active_col_outline;
			_node.radius = lerp(_node.radius, _node.active_radius_target, 0.1);
		
			var _i               = -1;
			var _num             = 3;
			var _ring_max_size   = (_node.active_radius_target * 4);
			var _radius_portion  = _ring_max_size / _num;
			draw_set_color(_col_outline);
			repeat (3) {
				_i++;
				var _ping_radius = (_radius_portion * _i + current_time * 0.01) mod _ring_max_size;
				draw_set_alpha(1 - (_ping_radius / _ring_max_size));
				draw_circle(_sx, _sy, _ping_radius, true);
			}
		}
		else if (_is_prev) {
			_col_fill    = _node.prev_col_fill;
			_col_outline = _node.prev_col_outline;
			_node.radius = lerp(_node.radius, _node.prev_radius_target, 0.1);
		}
		else {
			_node.radius = lerp(_node.radius, _node.radius_target, 0.1);
		}
	
		// Apply overlay effects (currently heatmap)
		if (overlay_mode == eStatementLensOverlay.HEATMAP) {
			var _t = clamp(_overlay_factor, 0, 1);
			if (_t > 0) {
				// Heat gradient: cold -> hot
				var _heat_cold = ui_theme.statement.heat_cold_col;
				var _heat_hot  = ui_theme.statement.heat_hot_col;
				var _heat_col  = merge_color(_heat_cold, _heat_hot, _t);
			
				// Set base colors toward heat color
				_col_fill    = _heat_col;
				_col_outline = merge_color(_heat_col, c_white, 0.25);
			}
		}
	
		var _r = _node.radius * camera_zoom;
	
		// Combined alpha (hover fade, unvisited fade, etc)
		var _final_alpha = clamp(_alpha, 0, 1);
		draw_set_alpha(_final_alpha);
	
		// Node body
		draw_set_color(_col_fill);
		draw_circle(_sx, _sy, _r, false);
	
		// Node outline
		draw_set_color(_col_outline);
		draw_circle(_sx, _sy, _r + 2, true);
		
		// Breakpoint badge ("Break on enter")
		var _break_on_enter = false;
		var _template_name = undefined;
		if (is_struct(machine)) {
			var _st_bp = machine.GetState(_name);
			if (is_instanceof(_st_bp, StatementState)) {
				_break_on_enter = (_st_bp[$ "debug_break_on_enter"] == true);
				_template_name = _st_bp[$ "template_name"];
			}
		}
	
		if (_show_label) {
			// Label background
			var _text_margin = 2;
			var _label_str   = string(_name);
			var _text_w      = string_width(_label_str)  + _text_margin * 2;
			var _text_h      = string_height(_label_str) + _text_margin * 2;
		
			var _tx  = _sx;
			var _ty  = _sy - _r;
			var _bx1 = _tx - _text_w * 0.5;
			var _bx2 = _bx1 + _text_w;
			var _by1 = _ty - _text_h;
			var _by2 = _ty;
			
			_label_top_y = _by1;
		
			draw_set_color(ui_theme.statement.label_hover_bg);
			draw_set_alpha(_final_alpha * ui_theme.statement.label_bg_alpha);
			draw_rectangle(_bx1, _by1, _bx2, _by2, false);
		
			// Label text
			draw_set_alpha(_final_alpha);
			draw_set_color(ui_theme.statement.label_text_col);
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_text(_tx, _ty, _label_str);
			draw_set_halign(_halign);
			draw_set_valign(_valign);
		}
		
		if (_break_on_enter) {
			var _old_font_bp = draw_get_font();
			draw_set_font(ui_theme.font_small);
			var _old_halign_bp = draw_get_halign();
			var _old_valign_bp = draw_get_valign();
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			
			var _ex_h = string_height("!");
			var _by = _sy - _r - 6 - (_ex_h * 0.5);
			if (!is_undefined(_label_top_y)) {
				_by = _label_top_y - 4 - (_ex_h * 0.5);
			}
			
			draw_set_color(make_color_rgb(255, 40, 40));
			draw_set_alpha(_final_alpha);
			draw_text(_sx, _by, "!");
			
			draw_set_alpha(1);
			draw_set_halign(_old_halign_bp);
			draw_set_valign(_old_valign_bp);
			draw_set_font(_old_font_bp);
		}

		if (is_string(_template_name) && string_length(_template_name) > 0) {
			__DrawTemplateBadge(_sx, _sy, _r, _final_alpha);
		}
	
		// Restore alpha
		draw_set_alpha(1);
	};

	/// @ignore
	/// @desc Draw a small error badge near a node position.
	static __DrawErrorBadge = function(_sx, _sy, _radius_screen) {
		var _badge_r = max(6, _radius_screen * 0.6);
		var _bx = _sx + _radius_screen * 0.75;
		var _by = _sy - _radius_screen * 0.75;
		var _old_font = draw_get_font();
		draw_set_color(ui_theme.col_error);
		draw_circle(_bx, _by, _badge_r, false);
		draw_set_color(ui_theme.col_text);
		draw_set_font(ui_theme.font_small);
		var _halign = draw_get_halign();
		var _valign = draw_get_valign();
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_bx, _by, "!");
		draw_set_font(_old_font);
		draw_set_halign(_halign);
		draw_set_valign(_valign);
	};

	/// @ignore
	/// @desc Draw a small submachine badge near a node position.
	static __DrawSubmachineBadge = function(_sx, _sy, _radius_screen) {
		var _badge_r = max(6, _radius_screen * 0.55);
		var _bx = _sx + _radius_screen * 0.75;
		var _by = _sy + _radius_screen * 0.75;
		var _old_font = draw_get_font();
		draw_set_color(ui_theme.col_accent);
		draw_circle(_bx, _by, _badge_r, false);
		draw_set_color(ui_theme.col_text);
		draw_set_font(ui_theme.font_small);
		var _halign = draw_get_halign();
		var _valign = draw_get_valign();
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_bx, _by, "S");
		draw_set_font(_old_font);
		draw_set_halign(_halign);
		draw_set_valign(_valign);
	};

	/// @ignore
	/// @desc Draw a small template badge near a node position.
	static __DrawTemplateBadge = function(_sx, _sy, _radius_screen, _alpha = 1) {
		var _badge_r = max(6, _radius_screen * 0.55);
		var _bx = _sx - _radius_screen * 0.75;
		var _by = _sy + _radius_screen * 0.75;

		var _badge_col = ui_theme.col_accent;
		if (is_instanceof(ui_theme, EchoChamberTheme)) {
			if (variable_struct_exists(ui_theme, "statement") && is_struct(ui_theme.statement)) {
				var _stmt = ui_theme.statement;
				if (variable_struct_exists(_stmt, "node_template_badge_col")) {
					_badge_col = _stmt.node_template_badge_col;
				}
			}
		}

		var _old_alpha = draw_get_alpha();
		draw_set_alpha(clamp(_alpha, 0, 1));
		draw_set_color(_badge_col);
		draw_primitive_begin(pr_trianglefan);
		draw_vertex(_bx, _by - _badge_r);
		draw_vertex(_bx + _badge_r, _by);
		draw_vertex(_bx, _by + _badge_r);
		draw_vertex(_bx - _badge_r, _by);
		draw_vertex(_bx, _by - _badge_r);
		draw_primitive_end();

		draw_set_color(ui_theme.col_text);
		draw_primitive_begin(pr_linestrip);
		draw_vertex(_bx, _by - _badge_r);
		draw_vertex(_bx + _badge_r, _by);
		draw_vertex(_bx, _by + _badge_r);
		draw_vertex(_bx - _badge_r, _by);
		draw_vertex(_bx, _by - _badge_r);
		draw_primitive_end();

		var _old_font = draw_get_font();
		draw_set_font(ui_theme.font_small);
		var _halign = draw_get_halign();
		var _valign = draw_get_valign();
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_bx, _by, "T");
		draw_set_font(_old_font);
		draw_set_halign(_halign);
		draw_set_valign(_valign);
		draw_set_alpha(_old_alpha);
	};
	
	/// @ignore
	/// @desc Ensure a config struct exists and has required fields.
	/// @param {Struct} _cfg
	/// @param {Real} _default_thickness
	/// @param {Constant.Colour} _default_color
	/// @param {Asset.GMSprite} _default_sprite
	/// @param {Real} _default_scroll
	/// @return {Struct}
	static _NormalizeCfg = function(_cfg, _default_thickness, _default_color, _default_sprite, _default_scroll) {
		if (!is_struct(_cfg)) {
			_cfg = {};
		}
				
		if (!variable_struct_exists(_cfg, "sprite")) {
			_cfg.sprite = _default_sprite;
		}
		if (!variable_struct_exists(_cfg, "color")) {
			_cfg.color = _default_color;
		}
		if (!variable_struct_exists(_cfg, "scroll")) {
			_cfg.scroll = _default_scroll;
		}
				
		if (!variable_struct_exists(_cfg, "thickness")) {
			if (sprite_exists(_cfg.sprite)) {
				_cfg.thickness = sprite_get_height(_cfg.sprite);
			}
			else {
				_cfg.thickness = _default_thickness;
			}
		}
				
		return _cfg;
	};
	
	/// @ignore
	/// @desc Draw a styled edge in screen space between two points.
	static __EnsureStatementEdgeThemeDefaults = function() {
		if (!is_instanceof(ui_theme, EchoChamberTheme)) {
			return;
		}
		if (!variable_struct_exists(ui_theme, "statement") || !is_struct(ui_theme.statement)) {
			ui_theme.statement = {};
		}
			
		var _stmt = ui_theme.statement;
		if (variable_struct_exists(_stmt, "__edge_styles_normalized") && _stmt.__edge_styles_normalized) {
			return;
		}
			
		var _spr_structural = EchoChamberThemeTryGetSprite("spr_dotted_line");
		var _spr_last       = EchoChamberThemeTryGetSprite("spr_dashed_line");
		var _spr_queued     = EchoChamberThemeTryGetSprite("spr_solid_line");
		var _spr_history    = EchoChamberThemeTryGetSprite("spr_dotted_line");
		var _spr_debug      = EchoChamberThemeTryGetSprite("spr_dashed_line");
			
		_stmt.edge_structural      = _NormalizeCfg(variable_struct_exists(_stmt, "edge_structural")      ? _stmt.edge_structural      : undefined, 10, c_ltgray, _spr_structural, 0);
		_stmt.edge_last_transition = _NormalizeCfg(variable_struct_exists(_stmt, "edge_last_transition") ? _stmt.edge_last_transition : undefined, 6,  c_white,  _spr_last,       1.5);
		_stmt.edge_queued          = _NormalizeCfg(variable_struct_exists(_stmt, "edge_queued")          ? _stmt.edge_queued          : undefined, 10, c_aqua,   _spr_queued,     1.0);
		_stmt.edge_history         = _NormalizeCfg(variable_struct_exists(_stmt, "edge_history")         ? _stmt.edge_history         : undefined, 6,  make_color_rgb(120, 120, 160), _spr_history, 0.5);
		_stmt.edge_debug           = _NormalizeCfg(variable_struct_exists(_stmt, "edge_debug")           ? _stmt.edge_debug           : undefined, 8,  make_color_rgb(220, 90, 200), _spr_debug, 0.8);
			
		_stmt.__edge_styles_normalized = true;
	};
	
	/// @ignore
	static __ResolveEdgeStyle = function(_style) {
		__EnsureStatementEdgeThemeDefaults();
			
		var _theme_stmt = (is_instanceof(ui_theme, EchoChamberTheme)
			&& variable_struct_exists(ui_theme, "statement")
			&& is_struct(ui_theme.statement))
			? ui_theme.statement
			: {};
			
		switch (_style) {
			case eStatementDebugEdgeStyle.LAST_TRANSITION:
				return (variable_struct_exists(_theme_stmt, "edge_last_transition") ? _theme_stmt.edge_last_transition : _theme_stmt.edge_structural);
				
			case eStatementDebugEdgeStyle.QUEUED:
				return (variable_struct_exists(_theme_stmt, "edge_queued") ? _theme_stmt.edge_queued : _theme_stmt.edge_structural);
				
			case eStatementDebugEdgeStyle.HISTORY:
				return (variable_struct_exists(_theme_stmt, "edge_history") ? _theme_stmt.edge_history : _theme_stmt.edge_structural);
				
			default:
				return (variable_struct_exists(_theme_stmt, "edge_structural") ? _theme_stmt.edge_structural : { thickness: 10, color: c_ltgray, sprite: -1, scroll: 0 });
		}
	};
	
	/// @ignore
	/// @desc Resolve debug-created edge styling (observed edges made via debug jumps).
	static __ResolveEdgeDebugStyle = function(_fallback_cfg = undefined) {
		__EnsureStatementEdgeThemeDefaults();
		var _theme_stmt = is_instanceof(ui_theme, EchoChamberTheme) ? ui_theme.statement : undefined;
		if (!is_undefined(_theme_stmt) && is_struct(_theme_stmt) && variable_struct_exists(_theme_stmt, "edge_debug")) {
			return _theme_stmt.edge_debug;
		}
		if (is_struct(_fallback_cfg)) {
			return _fallback_cfg;
		}
		return __ResolveEdgeStyle(eStatementDebugEdgeStyle.STRUCTURAL);
	};
	
	/// @ignore
	/// @desc Return whether an edge of the given kind/debug flag should be shown based on filters.
	static __EdgeVisibleByFilter = function(_kind, _is_debug) {
		if (show_observed_only) {
			return (_kind == eStatementDebugEdgeKind.OBSERVED) && (show_debug_edges || !_is_debug);
		}
		
		switch (_kind) {
			case eStatementDebugEdgeKind.DECLARATIVE:
				if (!show_decl_edges) return false;
			break;
			case eStatementDebugEdgeKind.MANUAL:
				if (!show_manual_edges) return false;
			break;
			case eStatementDebugEdgeKind.OBSERVED:
				if (!show_observed_edges) return false;
				if (_is_debug && !show_debug_edges) return false;
			break;
		}
		return true;
	};
		
	/// @ignore
	/// @desc Additional scope filtering: active-only and recent tick window.
	static __EdgePassesScope = function(_from, _to, _edge_ref) {
		if (edge_filter_active_only) {
			if (is_undefined(machine) || is_undefined(machine.state) || is_undefined(machine.state.name)) {
				return false;
			}
			var _active = machine.state.name;
			if (_from != _active && _to != _active) {
				return false;
			}
		}
			
		if (edge_filter_recent_ticks > 0) {
			var _last_tick = 0;
			if (is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "last_fired_tick")) {
				_last_tick = _edge_ref.last_fired_tick;
			}
			if (_last_tick <= 0) {
				return false;
			}
			var _tick_now = (is_struct(machine) && variable_struct_exists(machine, "debug_tick_counter")) ? machine.debug_tick_counter : 0;
			if (_tick_now - _last_tick > edge_filter_recent_ticks) {
				return false;
			}
		}
			
		return true;
	};

	/// @ignore
	/// @desc Apply decay smoothing to a heat value keyed in the given cache struct.
	static __ApplyHeatDecay = function(_cache, _key, _raw_heat) {
		if (heat_decay_rate <= 0) {
			if (is_struct(_cache)) {
				_cache[$ _key] = _raw_heat;
			}
			return _raw_heat;
		}
		var _prev = 0;
		if (is_struct(_cache) && variable_struct_exists(_cache, _key)) {
			_prev = _cache[$ _key];
		}
		// Higher decay means lose heat faster: retain = (1 - decay_rate).
		var _retain = max(0, 1 - heat_decay_rate);
		var _decayed = _prev * _retain;
		var _val = max(0, _raw_heat + _decayed);
		if (is_struct(_cache)) {
			_cache[$ _key] = _val;
		}
		return _val;
	};
	
	/// @ignore
	/// @desc Capture current camera + filters into a bookmark slot.
	static __SaveBookmark = function(_index) {
		if (_index < 0) return;
		var _nearest_label = __NearestStateToCamera();
		bookmarks[_index] = {
			camera_x : target_camera_x,
			camera_y : target_camera_y,
			camera_zoom : target_camera_zoom,
			show_edges : show_edges,
			show_labels : show_labels,
			show_observed_only : show_observed_only,
			show_debug_edges : show_debug_edges,
			show_decl_edges : show_decl_edges,
			show_manual_edges : show_manual_edges,
			show_observed_edges : show_observed_edges,
			edge_filter_active_only : edge_filter_active_only,
			edge_filter_recent_ticks : edge_filter_recent_ticks,
			overlay_mode : overlay_mode,
			heat_metric : heat_metric,
			mode : mode,
			full_layout_mode : full_layout_mode,
			label : is_undefined(_nearest_label) ? ("Bookmark " + string(_index + 1)) : _nearest_label
		};
	};
	
	/// @ignore
	/// @desc Restore camera + filters from a bookmark slot if present.
	static __LoadBookmark = function(_index) {
		if (_index < 0) return;
		if (!is_array(bookmarks)) return;
		if (_index >= array_length(bookmarks)) return;
		var _bm = bookmarks[_index];
		if (!is_struct(_bm)) return;
		
		target_camera_x    = _bm.camera_x;
		target_camera_y    = _bm.camera_y;
		target_camera_zoom = _bm.camera_zoom;
		camera_manual_override = true;
		
		show_edges          = _bm.show_edges;
		show_labels         = _bm.show_labels;
		show_observed_only  = _bm.show_observed_only;
		show_debug_edges    = _bm.show_debug_edges;
		show_decl_edges     = _bm.show_decl_edges;
		show_manual_edges   = _bm.show_manual_edges;
		show_observed_edges = _bm.show_observed_edges;
		edge_filter_active_only = _bm.edge_filter_active_only;
		edge_filter_recent_ticks = _bm.edge_filter_recent_ticks;
		overlay_mode        = _bm.overlay_mode;
		heat_metric         = _bm.heat_metric;
		var _old_mode = mode;
		mode               = _bm.mode;
		full_layout_mode   = _bm.full_layout_mode;
		
		if (_old_mode != mode) {
			if (mode == eStatementLensMode.EGO) {
				// force ego reinit
				last_ego_center_name = undefined;
			} 
			else {
				__RebuildLayout();
			}
		}
	};
	
	/// @ignore
	/// @desc Find the state name nearest to the camera target in current layout (or undefined).
	static __NearestStateToCamera = function() {
		if (is_undefined(node_layout)) {
			return undefined;
		}
		var _keys = variable_struct_get_names(node_layout);
		var _count = variable_struct_names_count(node_layout);
		if (_count <= 0) return undefined;
		
		var _tx = target_camera_x;
		var _ty = target_camera_y;
		var _best = undefined;
		var _best_d2 = -1;
		
		for (var _i = 0; _i < _count; _i++) {
			var _k = _keys[_i];
			var _n = node_layout[$ _k];
			var _nx = (mode == eStatementLensMode.EGO) ? _n.ego_x : _n.x;
			var _ny = (mode == eStatementLensMode.EGO) ? _n.ego_y : _n.y;
			var _dx = _nx - _tx;
			var _dy = _ny - _ty;
			var _d2 = _dx * _dx + _dy * _dy;
			if (_best_d2 < 0 || _d2 < _best_d2) {
				_best_d2 = _d2;
				_best = _k;
			}
		}
		return _best;
	};
	
	/// @ignore
	/// @desc Compute hit radius in screen space for an edge style.
	static __EdgeHitRadiusPx = function(_style_cfg, _thickness_scale = 1) {
		__EnsureStatementEdgeThemeDefaults();
		var _thickness = is_struct(_style_cfg) ? _style_cfg.thickness : 6;
		var _thickness_px = max(1, _thickness * max(0.05, _thickness_scale) * camera_zoom);
		return max(8, _thickness_px * 0.65);
	};
	
	/// @ignore
	/// @desc Distance squared from point to line segment.
	static __DistancePointToSegment = function(_px, _py, _x1, _y1, _x2, _y2) {
		var _dx = _x2 - _x1;
		var _dy = _y2 - _y1;
		var _len_sq = _dx * _dx + _dy * _dy;
		if (_len_sq <= 0) {
			var _dx0 = _px - _x1;
			var _dy0 = _py - _y1;
			return _dx0 * _dx0 + _dy0 * _dy0;
		}
		
		var _t = ((_px - _x1) * _dx + (_py - _y1) * _dy) / _len_sq;
		_t = clamp(_t, 0, 1);
		
		var _cx = _x1 + _dx * _t;
		var _cy = _y1 + _dy * _t;
		var _dpx = _px - _cx;
		var _dpy = _py - _cy;
		return _dpx * _dpx + _dpy * _dpy;
	};
	
	/// @ignore
	/// @desc Compose a key for edge lookup.
	static __EdgeKey = function(_from, _to) {
		return string(_from) + "->" + string(_to);
	};
	
	/// @ignore
	/// @desc Lookup an edge struct by from/to in a map.
	static __LookupEdge = function(_edge_map, _from, _to) {
		var _key = __EdgeKey(_from, _to);
		if (variable_struct_exists(_edge_map, _key)) {
			return _edge_map[$ _key];
		}
		return undefined;
	};
	
	/// @ignore
	/// @desc Measure the vertical space needed for the edge inspector body (including header + padding).
	static __MeasureEdgeInspectorHeight = function(_width, _edge_ref = undefined, _from = undefined, _to = undefined) {
		var _old_font = draw_get_font();
		draw_set_font(ui_theme.font_body);
		
		var _pad = ui_theme.pad_y;
		var _content_w = max(1, _width - ui_theme.pad_x * 2);
		
		var _kind_val = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "kind") ? _edge_ref.kind : eStatementDebugEdgeKind.DECLARATIVE;
		var _kind_str = __EdgeKindToString(_kind_val);
		var _hits     = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "hits") ? _edge_ref.hits : 0;
		var _first    = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "first_fired_tick") ? _edge_ref.first_fired_tick : 0;
		var _last_force = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "last_force") ? _edge_ref.last_force : false;
		var _debug_created = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "debug_created") ? _edge_ref.debug_created : false;
		var _err_tick = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "last_error_tick") ? _edge_ref.last_error_tick : 0;
		var _err_msg  = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "last_error_message") ? _edge_ref.last_error_message : "";
		
		var _cond_desc   = "Condition: (n/a)";
		var _decl_force_line = undefined;
		var _source_hint = "Source: unknown";
		
		if (_kind_val == eStatementDebugEdgeKind.DECLARATIVE) {
			_source_hint = "Source: declarative transition";
			_cond_desc   = "Condition: callable";
			if (is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "condition_callable")) {
				_cond_desc = _edge_ref.condition_callable ? "Condition: callable" : "Condition: missing / non-callable";
			}
			var _force_flag = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "force") ? _edge_ref.force : false;
			_decl_force_line = "Transition force flag: " + (_force_flag ? "yes" : "no");
		} 
		else if (_kind_val == eStatementDebugEdgeKind.MANUAL) {
			_source_hint = "Source: manual debug link";
			_cond_desc   = "Condition: (manual link)";
		} 
		else if (_kind_val == eStatementDebugEdgeKind.OBSERVED) {
			_source_hint = "Source: observed transition (runtime)";
			_cond_desc   = "Condition: (observed at runtime)";
		}
		
		var _payload_val = is_struct(_edge_ref) ? _edge_ref[$ "last_payload"] : undefined;
		var _payload_str = __FormatPayloadLabel(_payload_val);
		
		var _lines = [];
		array_push(_lines, "Kind: " + _kind_str);
		array_push(_lines, "Hits: " + string(_hits));
		var _first_str = (_first > 0) ? string(_first) : "never";
		array_push(_lines, "First fired tick: " + _first_str);
		array_push(_lines, "Last force: " + (_last_force ? "yes" : "no"));
		array_push(_lines, "Debug-created: " + (_debug_created ? "yes" : "no"));
		if (_err_tick > 0) {
			array_push(_lines, "Last error tick: " + string(_err_tick));
			array_push(_lines, "Last error: " + string(_err_msg));
		}
		array_push(_lines, _cond_desc);
		if (!is_undefined(_decl_force_line)) {
			array_push(_lines, _decl_force_line);
		}
		array_push(_lines, _source_hint);
		array_push(_lines, "Last payload: " + _payload_str);
		array_push(_lines, "Source line: (not available)");
		
		var _body_h = 0;
		var _line_count = array_length(_lines);
		for (var _li = 0; _li < _line_count; _li++) {
			_body_h += string_height_ext(_lines[_li], -1, _content_w) + _pad;
		}
		
		// Space for breakpoint toggle row
		_body_h += ui_theme.row_toolbar_h + _pad;
		
		// Header height from Popup helper logic
		var _header_h = max(ui_theme.row_toolbar_h, string_height("Hg") + ui_theme.pad_y * 2);
		var _total = _header_h + _pad + _body_h + _pad;
		
		draw_set_font(_old_font);
		return _total;
	};
	
	/// @ignore
	/// @desc Human-readable edge kind.
	static __EdgeKindToString = function(_kind) {
		switch (_kind) {
			case eStatementDebugEdgeKind.DECLARATIVE: return "Declarative";
			case eStatementDebugEdgeKind.MANUAL:      return "Manual link";
			case eStatementDebugEdgeKind.OBSERVED:    return "Observed";
			default:                                  return "Unknown";
		}
	};

	/// @ignore
	/// @desc Format payload values for debug UI without expanding large structs.
	static __FormatPayloadLabel = function(_payload) {
		if (is_undefined(_payload)) {
			return "(none)";
		}
		if (is_instanceof(_payload, Statement)) {
			var _get_name = _payload[$ "GetDebugName"];
			var _name = is_callable(_get_name) ? _get_name() : undefined;
			if (is_undefined(_name)) {
				return "(Statement machine)";
			}
			var _name_str = string(_name);
			if (string_length(_name_str) <= 0) {
				return "(Statement machine)";
			}
			return "(Statement machine: " + _name_str + ")";
		}
		else if (is_instanceof(_payload, StatementState)) {
			var _state_name = _payload[$ "name"];
			if (is_undefined(_state_name)) {
				return "(Statement state)";
			}
			var _state_name_str = string(_state_name);
			if (string_length(_state_name_str) <= 0) {
				return "(Statement state)";
			}
			return "(Statement state: " + _state_name_str + ")";
		}
		else if (is_struct(_payload)) {
			var _struct_name = _payload[$ "name"];
			if (!is_undefined(_struct_name)) {
				var _struct_name_str = string(_struct_name);
				if (string_length(_struct_name_str) > 0) {
					return "(Struct: " + _struct_name_str + ")";
				}
			}
			return "(Struct)";
		}
		else if (is_array(_payload)) {
			return "(Array len=" + string(array_length(_payload)) + ")";
		}

		var _out = string(_payload);
		var _len = string_length(_out);
		if (_len <= 0) {
			return "(none)";
		}
		if (_len > 120) {
			return string_copy(_out, 1, 120) + " [truncated]";
		}
		if (string_pos("recursive struct found", string_lower(_out)) > 0) {
			return "(Struct)";
		}
		return _out;
	};

	/// @ignore
	/// @desc Format debug name values without expanding large structs.
	static __FormatDebugName = function(_value, _fallback = "Machine") {
		if (is_undefined(_value)) {
			return _fallback;
		}
		if (is_instanceof(_value, Statement)) {
			return "(Statement machine)";
		}
		if (is_instanceof(_value, StatementState)) {
			return "(Statement state)";
		}
		if (is_struct(_value)) {
			var _name = _value[$ "name"];
			if (!is_undefined(_name)) {
				var _name_str = string(_name);
				if (string_length(_name_str) > 0) {
					return _name_str;
				}
			}
			return "(Struct)";
		}
		if (is_array(_value)) {
			return "(Array)";
		}

		var _out = string(_value);
		var _len = string_length(_out);
		if (_len <= 0) {
			return _fallback;
		}
		if (_len > 80) {
			return string_copy(_out, 1, 80) + " [truncated]";
		}
		if (string_pos("recursive struct found", string_lower(_out)) > 0) {
			return "(Struct)";
		}
		return _out;
	};
	
	/// @ignore
	/// @desc Draw a styled edge in screen space between two points.
	static __DrawEdgeStyled = function(_sx1, _sy1, _sx2, _sy2, _style, _alpha_begin = 1, _alpha_end = 1, _heat_factor = 0, _thickness_scale = 1, _style_cfg = undefined) {
		var _dx  = _sx2 - _sx1;
		var _dy  = _sy2 - _sy1;
		var _len = sqrt(_dx * _dx + _dy * _dy);
		if (_len <= 0) {
			return;
		}
	    
		__EnsureStatementEdgeThemeDefaults();
		var _cfg = is_struct(_style_cfg) ? _style_cfg : __ResolveEdgeStyle(_style);
		var _thickness    = _cfg.thickness;
		var _color        = _cfg.color;
		var _sprite       = _cfg.sprite;
		var _scroll_speed = _cfg.scroll;
    
	    // When the HEATMAP overlay is active, recolor edges along the same cold->hot
	    // gradient that nodes use, based on the supplied heat factor.
	    if (overlay_mode == eStatementLensOverlay.HEATMAP) {
	        var _t_heat = clamp(_heat_factor, 0, 1);
	        if (_t_heat > 0) {
	            var _heat_cold = ui_theme.statement.heat_cold_col;
	            var _heat_hot  = ui_theme.statement.heat_hot_col;
	            var _heat_col  = merge_color(_heat_cold, _heat_hot, _t_heat);
	            _color = _heat_col;
	        }
	    }
	    // Interpret thickness as "world" thickness and scale into screen pixels.
	    var _thickness_px = max(1, _thickness * max(0.05, _thickness_scale) * camera_zoom);
    
	    // Fallback: simple line if no sprite is configured
	    if (_sprite < 0) {
	        var _old_alpha_line = draw_get_alpha();
	        draw_set_alpha((_alpha_begin + _alpha_end) * 0.5);
	        draw_set_color(_color);
	        draw_line_width(_sx1, _sy1, _sx2, _sy2, _thickness_px);
	        draw_set_alpha(_old_alpha_line);
	        return;
	    }
		
		// Normal (perpendicular) for thickness
		var _inv_len = 1 / _len;
		var _nx      = -_dy * _inv_len;
		var _ny      =  _dx * _inv_len;
		
		var _half_thick = _thickness_px * 0.5;
		var _ox         = _nx * _half_thick;
		var _oy         = _ny * _half_thick;
		
		var _tile_width = sprite_get_width(_sprite);
		
		// Scroll phase in "tiles"
		var _tile_size = max(1, _tile_width * camera_zoom);
		var _time      = current_time / 1000;
		var _phase_t  = -_scroll_speed * _time;
		_phase_t     -= floor(_phase_t);  // keep 0..1
		var _phase_px = _phase_t * _tile_size;
		
		var _tex = sprite_get_texture(_sprite, 0);
		
		// We walk along the line in segments of tile_size pixels.
		// Each segment is one quad with UV 0..1 so the sprite repeats.
		var _pos = -_phase_px;
		
		var _alpha_diff = _alpha_end - _alpha_begin;
		
		while (_pos < _len) {
			var _seg_start_raw = _pos;
			var _seg_end_raw   = _pos + _tile_size;

			var _seg_start = _seg_start_raw;
			var _seg_end   = _seg_end_raw;

			if (_seg_end <= 0) {
				_pos += _tile_size;
				continue;
			}

			if (_seg_start < 0)		_seg_start = 0;
			if (_seg_end > _len)	_seg_end = _len;

			var _t0 = _seg_start / _len;
			var _t1 = _seg_end   / _len;

			var _ex1 = _sx1 + _dx * _t0;
			var _ey1 = _sy1 + _dy * _t0;
			var _ex2 = _sx1 + _dx * _t1;
			var _ey2 = _sy1 + _dy * _t1;

			var _x1_top = _ex1 + _ox;
			var _y1_top = _ey1 + _oy;
			var _x1_bot = _ex1 - _ox;
			var _y1_bot = _ey1 - _oy;

			var _x2_top = _ex2 + _ox;
			var _y2_top = _ey2 + _oy;
			var _x2_bot = _ex2 - _ox;
			var _y2_bot = _ey2 - _oy;

			var _alpha0 = _alpha_begin + _alpha_diff * _t0;
			var _alpha1 = _alpha_begin + _alpha_diff * _t1;

			// IMPORTANT: compute U from unclamped tile segment
			var _u0 = (_seg_start - _seg_start_raw) / _tile_size;
			var _u1 = (_seg_end   - _seg_start_raw) / _tile_size;

			_u0 = clamp(_u0, 0, 1);
			_u1 = clamp(_u1, 0, 1);

			draw_primitive_begin_texture(pr_trianglestrip, _tex);
			draw_vertex_texture_color(_x1_top, _y1_top, _u0, 0, _color, _alpha0);
			draw_vertex_texture_color(_x1_bot, _y1_bot, _u0, 1, _color, _alpha0);
			draw_vertex_texture_color(_x2_top, _y2_top, _u1, 0, _color, _alpha1);
			draw_vertex_texture_color(_x2_bot, _y2_bot, _u1, 1, _color, _alpha1);
			draw_primitive_end();

			_pos += _tile_size;
		}
	}

	/// @ignore
	/// @desc Draw repeated red exclamation marks along the "top" side of an edge segment.
	static __DrawEdgeBreakpointMarks = function(_sx1, _sy1, _sx2, _sy2, _style_cfg, _alpha_begin = 1, _alpha_end = 1, _thickness_scale = 1, _edge_ref = undefined) {
		var _dx  = _sx2 - _sx1;
		var _dy  = _sy2 - _sy1;
		var _len = sqrt(_dx * _dx + _dy * _dy);
		if (_len <= 0) {
			return;
		}
		
		__EnsureStatementEdgeThemeDefaults();
		var _cfg = is_struct(_style_cfg) ? _style_cfg : __ResolveEdgeStyle(eStatementDebugEdgeStyle.STRUCTURAL);
		var _thickness = is_struct(_cfg) && variable_struct_exists(_cfg, "thickness") ? _cfg.thickness : 6;
		var _thickness_px = max(1, _thickness * max(0.05, _thickness_scale) * camera_zoom);
		
		var _inv_len = 1 / _len;
		var _nx = -_dy * _inv_len;
		var _ny =  _dx * _inv_len;
		
		// Place marks above the edge (normal direction) with padding.
		// Because the text is rotated along the edge, its height projects onto the normal,
		// so include half the glyph height in the offset to keep a clean buffer.
		var _pad_px = 3;
		
		var _angle = point_direction(_sx1, _sy1, _sx2, _sy2);
		
		var _old_font = draw_get_font();
		draw_set_font(ui_theme.font_small);
		var _old_halign = draw_get_halign();
		var _old_valign = draw_get_valign();
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _breakpoint_glyph = ".";
		var _breakpoint_text = "BREAKPOINT READY";
		var _breakpoint_col = make_color_rgb(255, 40, 40);
		if (is_struct(_edge_ref) && _edge_ref[$ "debug_break_triggered"] == true) {
			_breakpoint_col = merge_colour(c_white, make_color_rgb(255, 40, 40), 0.5 + sin(current_time / 100) * 0.5 );
			_breakpoint_glyph = "!";
			_breakpoint_text = "BREAKPOINT TRIGGERED";
		}
		
		var _glyph_half_h = string_height(_breakpoint_glyph) * 0.5;
		var _off = (_thickness_px * 0.5) + _pad_px + _glyph_half_h;
		
		var _off_x = lengthdir_x(_off, _angle - 90);
		var _off_y = lengthdir_y(_off, _angle - 90);
		
		var _step = max(8, string_width(_breakpoint_glyph) + 8);
		var _count = max(1, floor(_len / _step) + 1);
		
		var _text_w = string_width(_breakpoint_text);
		var _reserve_half = (_text_w * 0.5) + _step;
		var _draw_glyphs = (_len >= (_text_w + (_step * 2)));
		
		draw_set_color(_breakpoint_col);
		
		if (_draw_glyphs) {
			for (var _i = 0; _i < _count; _i++) {
				var _t = (_count <= 1) ? 0.5 : (_i / (_count - 1));
				var _dist = _t * _len;
				if (abs(_dist - (_len * 0.5)) <= _reserve_half) {
					continue;
				}
				
				var _x = _sx1 + _dx * _t + _off_x;
				var _y = _sy1 + _dy * _t + _off_y;
				var _a = lerp(_alpha_begin, _alpha_end, _t);
				
				draw_set_alpha(clamp(_a, 0, 1));
				draw_text_transformed(_x, _y, _breakpoint_glyph, 1, -1, _angle);
			}
		}
		
		// Always draw the center text, even if the edge is too short.
		var _t_mid = 0.5;
		var _x_mid = _sx1 + _dx * _t_mid + _off_x;
		var _y_mid = _sy1 + _dy * _t_mid + _off_y;
		var _a_mid = lerp(_alpha_begin, _alpha_end, _t_mid);
		draw_set_alpha(clamp(_a_mid, 0, 1));
		draw_text_transformed(_x_mid, _y_mid, _breakpoint_text, -1, -1, _angle);
		
		draw_set_alpha(1);
		draw_set_halign(_old_halign);
		draw_set_valign(_old_valign);
		draw_set_font(_old_font);
	};
	
	/// @ignore
	/// @desc Draw animated sparks running along the supplied history segments (world-space positions).
	static __DrawHistorySparks = function(_segments, _cx, _cy) {
		var _seg_count = array_length(_segments);
		if (_seg_count <= 0) {
			return;
		}
		
		var _total_len = 0;
		for (var _si = 0; _si < _seg_count; _si++) {
			_total_len += _segments[_si].len;
		}
		if (_total_len <= 0) {
			return;
		}
		
		var _spark_count = max(1, history_spark_count);
		var _theme_stmt = is_instanceof(ui_theme, EchoChamberTheme) ? ui_theme.statement : undefined;
		var _spark_sprite = (!is_undefined(_theme_stmt) ? _theme_stmt.history_spark_sprite : -1);
		var _spark_col = ui_theme.col_text;
		if (is_struct(_theme_stmt) && variable_struct_exists(_theme_stmt, "edge_history")) {
			var _cfg_h = _theme_stmt.edge_history;
			if (is_struct(_cfg_h) && variable_struct_exists(_cfg_h, "color")) {
				_spark_col = _cfg_h.color;
			}
		}
		
		// Update base distance with frame time and adjust when total length changes.
		var _now_ms = current_time;
		var _dt_s   = max(0, (_now_ms - history_spark_prev_time) / 1000);
		history_spark_prev_time = _now_ms;
		
		var _base = history_spark_distance;
		if (history_spark_total_prev > 0) {
			var _ratio = (_base <= 0) ? 0 : (_base / history_spark_total_prev);
			_base = _ratio * _total_len;
		}
		
		_base += history_spark_speed * _dt_s;
		if (_total_len > 0) {
			_base = _base mod _total_len;
		}
		
		history_spark_distance   = _base;
		history_spark_total_prev = _total_len;
		
		var _phase_gap = _total_len / _spark_count;
		
		for (var _si2 = 0; _si2 < _spark_count; _si2++) {
			var _dist = (_base + _phase_gap * _si2) mod _total_len;
			
			var _accum = 0;
			var _seg_index = -1;
			for (var _sj = 0; _sj < _seg_count; _sj++) {
				var _seg_len = _segments[_sj].len;
				if (_dist <= _accum + _seg_len) {
					_seg_index = _sj;
					break;
				}
				_accum += _seg_len;
			}
			
			if (_seg_index < 0) {
				continue;
			}
			
			var _seg = _segments[_seg_index];
			var _local_t = (_seg.len <= 0) ? 0 : clamp((_dist - _accum) / _seg.len, 0, 1);
			
			var _wx = lerp(_seg.wx1, _seg.wx2, _local_t);
			var _wy = lerp(_seg.wy1, _seg.wy2, _local_t);
			
			var _sx = _cx + (_wx - camera_x) * camera_zoom;
			var _sy = _cy + (_wy - camera_y) * camera_zoom;
				
			var _ang = radtodeg(arctan2(_seg.wy2 - _seg.wy1, _seg.wx2 - _seg.wx1));
				
			if (_spark_sprite >= 0) {
				draw_sprite_ext(_spark_sprite, 0, _sx, _sy, 1, 1, _ang, _spark_col, 1);
			} 
			else {
				var _r = 4 * camera_zoom;
				draw_set_color(_spark_col);
				draw_circle(_sx, _sy, _r, false);
			}
		}
	};
	
	/// @ignore
	/// @desc Draw an ego-centered view around the current state in the given rect, return clicked state name, if any.
	static __DrawEgoGraph = function(_graph, _left, _top, _width, _height, _allow_input, _root = undefined) {
		var _mx = 0;
		var _my = 0;
		var _states = _graph.states;
		var _edges  = _graph.edges;
		
		var _l_pressed = false;
		var _r_pressed = false;
		var _mouse_consumed = false;
		
		if (is_struct(_root)) {
			_mx = _root.mx;
			_my = _root.my;
			_l_pressed = _root.mouse_l_pressed;
			_r_pressed = _root.mouse_r_pressed;
			_mouse_consumed = _root.mouse_consumed;
		}
		else {
			_mx = device_mouse_x_to_gui(0);
			_my = device_mouse_y_to_gui(0);
			_l_pressed = mouse_check_button_pressed(mb_left);
			_r_pressed = mouse_check_button_pressed(mb_right);
			_mouse_consumed = false;
		}
	
		var _cx = _left + _width  * 0.5;
	    var _cy = _top  + _height * 0.5;
        
	    var _rmb_hit_node = false;
		var _rmb_hit_edge = false;
		var _hovered_edge = undefined;
		var _hovered_edge_dist_sq = -1;
		
		// Build edge lookup for hover/inspector data.
		var _edge_lookup = {};
		var _edge_lookup_count = array_length(_edges);
		for (var _eli = 0; _eli < _edge_lookup_count; _eli++) {
			var _e_lookup = _edges[_eli];
			if (is_struct(_e_lookup) && variable_struct_exists(_e_lookup, "from_name") && variable_struct_exists(_e_lookup, "to_name")) {
				_edge_lookup[$ __EdgeKey(_e_lookup.from_name, _e_lookup.to_name)] = _e_lookup;
			}
		}
    
	    // Edge heat: max hits across all edges for normalizing ego view colors.
	    var _max_edge_hits = 0;
	    if (overlay_mode == eStatementLensOverlay.HEATMAP) {
	        var _edge_count_for_max = array_length(_edges);
	        for (var _ei_max = 0; _ei_max < _edge_count_for_max; _ei_max++) {
	            var _edge_max = _edges[_ei_max];
	            if (is_struct(_edge_max) && variable_struct_exists(_edge_max, "hits")) {
	                if (_edge_max.hits > _max_edge_hits) {
	                    _max_edge_hits = _edge_max.hits;
	                }
	            }
	        }
	    }

	
		var _center_state = machine.state;
		if (is_undefined(_center_state)) {
			// No active state: fall back to full graph in same rect
			return __DrawFullGraph(_graph, _left, _top, _width, _height, _allow_input, _root);
		}
	
		var _center_name         = _center_state.name;
		var _current_state_name  = _center_name;
		var _previous_state_name = (!is_undefined(machine.previous_state) ? machine.previous_state.name  : undefined);
		var _queued_state_name   = (machine.HasQueuedState()               ? machine.GetQueuedStateName() : undefined);

		// If the center changed, invalidate ego positions so they are recomputed for the new focus.
		if (last_ego_center_name != _center_name) {
			var _keys_reset  = variable_struct_get_names(node_layout);
			var _count_reset = variable_struct_names_count(node_layout);
			for (var _ri = 0; _ri < _count_reset; _ri++) {
				var _rk = _keys_reset[_ri];
				if (variable_struct_exists(node_layout, _rk)) {
					var _node_reset = node_layout[$ _rk];
					if (is_struct(_node_reset) && variable_struct_exists(_node_reset, "ego_initialized")) {
						_node_reset.ego_initialized = false;
					}
				}
			}
			last_ego_center_name = _center_name;
		}
	
		var _ego_lists = __BuildEgoNeighborLists(_graph, _center_name, show_observed_only, show_debug_edges, show_decl_edges, show_manual_edges, show_observed_edges);
		var _out_names = _ego_lists.out_names;
		var _in_names  = _ego_lists.in_names;
	
		// Heatmap stats for center and first-ring neighbors
		var _stats       = machine.GetDebugStateStats();
		var _use_heatmap = (overlay_mode == eStatementLensOverlay.HEATMAP) && !is_undefined(_stats);
		var _use_visits  = (heat_metric == eStatementHeatMetric.VISITS);
		var _max_metric  = 0;

		if (_use_heatmap) {
			// Center
			if (variable_struct_exists(_stats, _center_name)) {
				var _s_center_max = _stats[$ _center_name];
				var _val_c = _use_visits ? _s_center_max.entry_count : _s_center_max.total_frames;
				_max_metric = max(_max_metric, _val_c);
			}
	
			// Outgoing neighbors
			var _out_count_max = array_length(_out_names);
			for (var _oi_max = 0; _oi_max < _out_count_max; _oi_max++) {
				var _name_out_max = _out_names[_oi_max];
				if (variable_struct_exists(_stats, _name_out_max)) {
					var _s_out_max = _stats[$ _name_out_max];
					var _val_o = _use_visits ? _s_out_max.entry_count : _s_out_max.total_frames;
					_max_metric = max(_max_metric, _val_o);
				}
			}
	
			// Incoming neighbors
			var _in_count_max = array_length(_in_names);
			for (var _ii_max = 0; _ii_max < _in_count_max; _ii_max++) {
				var _name_in_max = _in_names[_ii_max];
				if (variable_struct_exists(_stats, _name_in_max)) {
					var _s_in_max = _stats[$ _name_in_max];
					var _val_i = _use_visits ? _s_in_max.entry_count : _s_in_max.total_frames;
					_max_metric = max(_max_metric, _val_i);
				}
			}
		}

		// Layout parameters in "ego world" space around the center at (0,0).
		var _out_count = array_length(_out_names);
		var _in_count  = array_length(_in_names);
		var _max_side  = max(1, max(_out_count, _in_count));

		// Vertical spacing scales with available height and number of nodes per side.
		var _vertical_spacing = max(48, _height / (_max_side + 1));
		
		// Horizontal offset derived from label widths and a BFS-like base gap.
		var _old_font_measure = draw_get_font();
		draw_set_font(ui_theme.font_body);
		var _max_label_w = 0;
		if (show_labels) {
			_max_label_w = max(_max_label_w, string_width(_center_name));
			for (var _mw_o = 0; _mw_o < _out_count; _mw_o++) {
				_max_label_w = max(_max_label_w, string_width(_out_names[_mw_o]));
			}
			for (var _mw_i = 0; _mw_i < _in_count; _mw_i++) {
				_max_label_w = max(_max_label_w, string_width(_in_names[_mw_i]));
			}
		}
		draw_set_font(_old_font_measure);
		
		var _base_gap    = layout_min_distance * 2;
		var _label_gap   = _max_label_w + node_radius * 3 + ui_theme.pad_x * 2;
		var _side_offset = max(_base_gap, _label_gap, _width * 0.3);
	
		// Smooth ego positions for center and its neighbors
		var _node_center = __UpdateEgoNodePosition(_center_name, 0, 0);
	
		for (var _oi2 = 0; _oi2 < _out_count; _oi2++) {
			var _name_o   = _out_names[_oi2];
			var _offset_o = (_oi2 - (_out_count - 1) * 0.5) * _vertical_spacing;
			__UpdateEgoNodePosition(_name_o, _side_offset, _offset_o);
		}
	
		for (var _ii2 = 0; _ii2 < _in_count; _ii2++) {
			var _name_i   = _in_names[_ii2];
			var _offset_i = (_ii2 - (_in_count - 1) * 0.5) * _vertical_spacing;
			__UpdateEgoNodePosition(_name_i, -_side_offset, _offset_i);
		}
	
		// Now convert ego world positions to screen using the camera.
		var _center_sx = _cx + (_node_center.ego_x - camera_x) * camera_zoom;
		var _center_sy = _cy + (_node_center.ego_y - camera_y) * camera_zoom;
	
		// Determine hovered node (center + neighbors)
		var _hovered_name = undefined;
		if (_allow_input) {
			// Center
			var _dx_c_h   = _mx - _center_sx;
			var _dy_c_h   = _my - _center_sy;
			var _dist_c_h = sqrt(_dx_c_h * _dx_c_h + _dy_c_h * _dy_c_h);
			if (_dist_c_h <= max(node_hit_radius * camera_zoom, 8)) {
				_hovered_name = _center_name;
			}
		
			// Outgoing
			for (var _oi_h = 0; _oi_h < _out_count; _oi_h++) {
				var _name_out_h = _out_names[_oi_h];
				var _node_out_h = __GetOrCreateNode(_name_out_h);
			
				var _sx_o_h = _cx + (_node_out_h.ego_x - camera_x) * camera_zoom;
				var _sy_o_h = _cy + (_node_out_h.ego_y - camera_y) * camera_zoom;
			
				var _dx_o_h   = _mx - _sx_o_h;
				var _dy_o_h   = _my - _sy_o_h;
				var _dist_o_h = sqrt(_dx_o_h * _dx_o_h + _dy_o_h * _dy_o_h);
				if (_dist_o_h <= max(node_hit_radius * camera_zoom, 8)) {
					_hovered_name = _name_out_h;
				}
			}
		
			// Incoming
			for (var _ii_h = 0; _ii_h < _in_count; _ii_h++) {
				var _name_in_h = _in_names[_ii_h];
				var _node_in_h = __GetOrCreateNode(_name_in_h);
			
				var _sx_i_h = _cx + (_node_in_h.ego_x - camera_x) * camera_zoom;
				var _sy_i_h = _cy + (_node_in_h.ego_y - camera_y) * camera_zoom;
			
				var _dx_i_h   = _mx - _sx_i_h;
				var _dy_i_h   = _my - _sy_i_h;
				var _dist_i_h = sqrt(_dx_i_h * _dx_i_h + _dy_i_h * _dy_i_h);
				if (_dist_i_h <= max(node_hit_radius * camera_zoom, 8)) {
					_hovered_name = _name_in_h;
				}
			}
		}
		
		// If no mouse hover, fall back to keyboard-selected neighbor (so labels/highlights show)
		if (is_undefined(_hovered_name) && !is_undefined(ego_selected_name)) {
			_hovered_name = ego_selected_name;
		}
	
		// Draw edges from center to outgoing states (styled + hover + heat fade)
		for (var _oi3 = 0; _oi3 < _out_count; _oi3++) {
			var _name_out = _out_names[_oi3];
			
			if (!show_edges) {
				if (is_undefined(_hovered_name)) {
					continue;
				}
				// Only draw edges if the hovered node is either the center or this neighbor.
				if (_hovered_name != _center_name && _hovered_name != _name_out) {
					continue;
				}
			}
			
			var _node_out = __GetOrCreateNode(_name_out);
		
			var _sx_o = _cx + (_node_out.ego_x - camera_x) * camera_zoom;
			var _sy_o = _cy + (_node_out.ego_y - camera_y) * camera_zoom;
		
			var _from  = _center_name;
			var _to    = _name_out;
			var _style = eStatementDebugEdgeStyle.STRUCTURAL;
			var _edge_ref = __LookupEdge(_edge_lookup, _from, _to);
			var _kind_out = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "kind") ? _edge_ref.kind : eStatementDebugEdgeKind.DECLARATIVE;
			var _debug_created_out = is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "debug_created") && _edge_ref.debug_created;
			
			if (!__EdgeVisibleByFilter(_kind_out, _debug_created_out)) {
				continue;
			}
		
			// Last transition: previous -> current
			if (!is_undefined(_previous_state_name) && !is_undefined(_current_state_name)) {
				if (_from == _previous_state_name && _to == _current_state_name) {
					_style = eStatementDebugEdgeStyle.LAST_TRANSITION;
				}
			}
		
			// Queued transition: current -> queued
			if (!is_undefined(_current_state_name) && !is_undefined(_queued_state_name)) {
				if (_from == _current_state_name && _to == _queued_state_name) {
					_style = eStatementDebugEdgeStyle.QUEUED;
				}
			}
		
			var _edge_alpha_out = 1;
        
	        // Hover fade for edges
	        if (!is_undefined(_hovered_name)) {
	            if (_hovered_name != _center_name && _hovered_name != _name_out) {
	                _edge_alpha_out *= 0.25;
	            }
	        }
        
	        var _begin_alpha = _edge_alpha_out;
	        var _end_alpha   = _edge_alpha_out;
        
	        // Heat fade for edges
	        if (_use_heatmap) {
	            var _from_visited = false;
	            var _to_visited   = false;
            
	            if (!is_undefined(_stats) && variable_struct_exists(_stats, _center_name)) {
	                var _sf = _stats[$ _center_name];
	                if (_sf.total_frames > 0 || _sf.entry_count > 0) {
	                    _from_visited = true;
	                }
	            }
	            if (!is_undefined(_stats) && variable_struct_exists(_stats, _name_out)) {
	                var _st = _stats[$ _name_out];
	                if (_st.total_frames > 0 || _st.entry_count > 0) {
	                    _to_visited = true;
	                }
	            }
            
	            if (!(_from_visited || _to_visited)) {
	                _begin_alpha *= 0.15;
	                _end_alpha   *= 0.15;
	            }
	            else if (_from_visited && !_to_visited) {
	                _end_alpha *= 0.15;
	            }
	        }
        
	        // Edge heat factor for center -> out transition
	        var _edge_heat = 0;
			var _edge_has_err = false;
			var _edge_hits, _edge_count;
	        if (overlay_mode == eStatementLensOverlay.HEATMAP && _max_edge_hits > 0) {
	            _edge_hits = 0;
				if (is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "hits")) {
					_edge_hits = _edge_ref.hits;
					_edge_has_err = (is_struct(_edge_ref) && variable_struct_exists(_edge_ref, "has_error") && _edge_ref.has_error);
				} 
				else {
					_edge_count = array_length(_edges);
		            for (var _ei_h = 0; _ei_h < _edge_count; _ei_h++) {
		                var _edge_h = _edges[_ei_h];
		                if (_edge_h.from_name == _center_name && _edge_h.to_name == _name_out) {
		                    _edge_hits = _edge_h.hits;
							_edge_has_err = (is_struct(_edge_h) && variable_struct_exists(_edge_h, "has_error") && _edge_h.has_error);
		                    break;
		                }
		            }
				}
				if (_edge_hits <= 0) {
					_begin_alpha *= 0.15;
					_end_alpha   *= 0.15;
				}
				if (_edge_hits > 0) {
	                _edge_heat = clamp(_edge_hits / _max_edge_hits, 0, 1);
	            }
	        }
		
			if (!__EdgePassesScope(_from, _to, _edge_ref)) {
				continue;
			}
				
			var _style_cfg = __ResolveEdgeStyle(_style);
			if (_debug_created_out) {
				_style_cfg = __ResolveEdgeDebugStyle(_style_cfg);
			}
			if (_edge_has_err) {
				_style_cfg.color = ui_theme.col_error;
			}
		    __DrawEdgeStyled(_center_sx, _center_sy, _sx_o, _sy_o, _style, _begin_alpha, _end_alpha, _edge_heat, 1, _style_cfg);
			
			if (is_struct(_edge_ref) && _edge_ref[$ "debug_break_on_transition"] == true) {
				__DrawEdgeBreakpointMarks(_center_sx, _center_sy, _sx_o, _sy_o, _style_cfg, _begin_alpha, _end_alpha, 1, _edge_ref);
			}
			
				if (_allow_input && !(is_struct(_root) && _root.mouse_consumed)) {
					var _dist_sq = __DistancePointToSegment(_mx, _my, _center_sx, _center_sy, _sx_o, _sy_o);
					var _hit_r   = __EdgeHitRadiusPx(_style_cfg, 1);
					if (_dist_sq <= _hit_r * _hit_r) {
						if (_hovered_edge_dist_sq < 0 || _dist_sq < _hovered_edge_dist_sq) {
						_hovered_edge_dist_sq = _dist_sq;
						_hovered_edge = {
							from  : _from,
							to    : _to,
							style : _style,
							edge  : _edge_ref
						};
					}
				}
			}
		}
	
		// Draw edges from incoming states to center
		for (var _ii3 = 0; _ii3 < _in_count; _ii3++) {
			var _name_in = _in_names[_ii3];
			
			if (!show_edges) {
				if (is_undefined(_hovered_name)) {
					continue;
				}
				// Only draw edges if the hovered node is either the center or this neighbor.
				if (_hovered_name != _center_name && _hovered_name != _name_in) {
					continue;
				}
			}
			
			var _node_in = __GetOrCreateNode(_name_in);
		
			var _sx_i = _cx + (_node_in.ego_x - camera_x) * camera_zoom;
			var _sy_i = _cy + (_node_in.ego_y - camera_y) * camera_zoom;
		
			var _from  = _name_in;
			var _to    = _center_name;
			var _style = eStatementDebugEdgeStyle.STRUCTURAL;
			var _edge_ref_in = __LookupEdge(_edge_lookup, _from, _to);
			var _kind_in = is_struct(_edge_ref_in) && variable_struct_exists(_edge_ref_in, "kind") ? _edge_ref_in.kind : eStatementDebugEdgeKind.DECLARATIVE;
			var _debug_created_in = is_struct(_edge_ref_in) && variable_struct_exists(_edge_ref_in, "debug_created") && _edge_ref_in.debug_created;
			
			if (!__EdgeVisibleByFilter(_kind_in, _debug_created_in)) {
				continue;
			}
		
			// Last transition: previous -> current
			if (!is_undefined(_previous_state_name) && !is_undefined(_current_state_name)) {
				if (_from == _previous_state_name && _to == _current_state_name) {
					_style = eStatementDebugEdgeStyle.LAST_TRANSITION;
				}
			}
		
			// Queued transition: current -> queued
			if (!is_undefined(_current_state_name) && !is_undefined(_queued_state_name)) {
				if (_from == _current_state_name && _to == _queued_state_name) {
					_style = eStatementDebugEdgeStyle.QUEUED;
				}
			}
		
			var _edge_alpha_in = 1;
        
	        // Hover fade for edges
	        if (!is_undefined(_hovered_name)) {
	            if (_hovered_name != _center_name && _hovered_name != _name_in) {
	                _edge_alpha_in *= 0.25;
	            }
	        }
        
	        var _begin_alpha = _edge_alpha_in;
	        var _end_alpha   = _edge_alpha_in;
        
	        // Heat fade for edges (optional, still based on node visitation)
	        if (_use_heatmap) {
	            var _from_visited = false;
	            var _to_visited   = false;
            
	            if (!is_undefined(_stats) && variable_struct_exists(_stats, _name_in)) {
	                var _sf = _stats[$ _name_in];
	                if (_sf.total_frames > 0 || _sf.entry_count > 0) {
	                    _from_visited = true;
	                }
	            }
	            if (!is_undefined(_stats) && variable_struct_exists(_stats, _center_name)) {
	                var _st = _stats[$ _center_name];
	                if (_st.total_frames > 0 || _st.entry_count > 0) {
	                    _to_visited = true;
	                }
	            }
            
	            if (!(_from_visited || _to_visited)) {
	                _begin_alpha *= 0.15;
	                _end_alpha   *= 0.15;
	            }
	            else if (_from_visited && !_to_visited) {
	                _end_alpha *= 0.15;
	            }
	        }
        
	        // Edge heat factor for in neighbor -> center transition
	        var _edge_heat = 0;
	        if (overlay_mode == eStatementLensOverlay.HEATMAP && _max_edge_hits > 0) {
	            var _edge_hits = 0;
				if (is_struct(_edge_ref_in) && variable_struct_exists(_edge_ref_in, "hits")) {
					_edge_hits = _edge_ref_in.hits;
				} 
				else {
			        var _edge_count = array_length(_edges);
			        for (var _ei_h2 = 0; _ei_h2 < _edge_count; _ei_h2++) {
			            var _edge_h2 = _edges[_ei_h2];
			            if (_edge_h2.from_name == _name_in && _edge_h2.to_name == _center_name) {
			                _edge_hits = _edge_h2.hits;
			                break;
			            }
			        }
				}
		        if (_edge_hits > 0) {
		            _edge_heat = clamp(_edge_hits / _max_edge_hits, 0, 1);
		        }
		    }
			if (_use_heatmap) {
				var _edge_key_in = __EdgeKey(_from, _to);
				_edge_heat = __ApplyHeatDecay(heat_cache_edges, _edge_key_in, _edge_heat);
			}

			if (!__EdgePassesScope(_from, _to, _edge_ref_in)) {
				continue;
			}

			var _edge_has_err_in = (is_struct(_edge_ref_in) && variable_struct_exists(_edge_ref_in, "has_error") && _edge_ref_in.has_error);
			if (!_edge_has_err_in) {
				var _edge_count_err_in = array_length(_edges);
				for (var _ei_err_in = 0; _ei_err_in < _edge_count_err_in; _ei_err_in++) {
					var _edge_err_in = _edges[_ei_err_in];
					if (_edge_err_in.from_name == _from && _edge_err_in.to_name == _to) {
						_edge_has_err_in = (is_struct(_edge_err_in) && variable_struct_exists(_edge_err_in, "has_error") && _edge_err_in.has_error);
						break;
					}
				}
			}

			var _style_cfg = __ResolveEdgeStyle(_style);
			if (_debug_created_in) {
				_style_cfg = __ResolveEdgeDebugStyle(_style_cfg);
			}
			if (_edge_has_err_in) {
				_style_cfg.color = ui_theme.col_error;
			}
			__DrawEdgeStyled(_sx_i, _sy_i, _center_sx, _center_sy, _style, _begin_alpha, _end_alpha, _edge_heat, 1, _style_cfg);
			
			if (is_struct(_edge_ref_in) && _edge_ref_in[$ "debug_break_on_transition"] == true) {
				__DrawEdgeBreakpointMarks(_sx_i, _sy_i, _center_sx, _center_sy, _style_cfg, _begin_alpha, _end_alpha, 1, _edge_ref_in);
			}
		
			if (_allow_input && !(is_struct(_root) && _root.mouse_consumed)) {
				var _dist_sq_i = __DistancePointToSegment(_mx, _my, _sx_i, _sy_i, _center_sx, _center_sy);
				var _hit_r_i   = __EdgeHitRadiusPx(_style_cfg, 1);
				if (_dist_sq_i <= _hit_r_i * _hit_r_i) {
					if (_hovered_edge_dist_sq < 0 || _dist_sq_i < _hovered_edge_dist_sq) {
						_hovered_edge_dist_sq = _dist_sq_i;
						_hovered_edge = {
							from  : _from,
							to    : _to,
							style : _style,
							edge  : _edge_ref_in
						};
					}
				}
			}
		}
		draw_set_alpha(1);
		
		// History trail overlay in ego view (only for nodes with ego positions)
		var _hist = history_records;
		var _hist_len = array_length(_hist);
		var _hist_segments = [];
		if (_hist_len > 0) {
			var _start_idx = 0;
			var _span      = max(1, _hist_len - _start_idx - 1);
			
			for (var _hi = _start_idx; _hi < _hist_len; _hi++) {
				var _rec = _hist[_hi];
				if (is_undefined(_rec.from_name) || is_undefined(_rec.to_name)) {
					continue;
				}
				if (!variable_struct_exists(node_layout, _rec.from_name)) {
					continue;
				}
				if (!variable_struct_exists(node_layout, _rec.to_name)) {
					continue;
				}
				
				var _n_from = node_layout[$ _rec.from_name];
				var _n_to   = node_layout[$ _rec.to_name];
				
				if (!_n_from.ego_initialized || !_n_to.ego_initialized) {
					continue;
				}
				
				var _sxh1 = _cx + (_n_from.ego_x - camera_x) * camera_zoom;
				var _syh1 = _cy + (_n_from.ego_y - camera_y) * camera_zoom;
				var _sxh2 = _cx + (_n_to.ego_x   - camera_x) * camera_zoom;
				var _syh2 = _cy + (_n_to.ego_y   - camera_y) * camera_zoom;
				
				var _t_age     = (_hi - _start_idx) / _span;
				var _alpha_h   = max(0.05, power(0.75, (_span - (_hi - _start_idx) - 1)) * 1.4);
				_alpha_h = clamp(_alpha_h, 0.15, 1);
				var _thick_h   = lerp(0.5, 1, _t_age);
				var _is_newest = (_hi == _hist_len - 1);
				
				if (_is_newest) {
					_alpha_h = max(_alpha_h, 1);
					_thick_h = max(_thick_h, 1);
				}
				
				__DrawEdgeStyled(_sxh1, _syh1, _sxh2, _syh2, eStatementDebugEdgeStyle.HISTORY, _alpha_h, _alpha_h, 0, _thick_h);
				
				var _seg_len = point_distance(_n_from.ego_x, _n_from.ego_y, _n_to.ego_x, _n_to.ego_y);
				if (_seg_len > 0) {
					array_push(_hist_segments, {
						wx1 : _n_from.ego_x, wy1 : _n_from.ego_y,
						wx2 : _n_to.ego_x,   wy2 : _n_to.ego_y,
						len : _seg_len
					});
				}
			}
			
			__DrawHistorySparks(_hist_segments, _cx, _cy);
		}
	
		// Nodes + hit detection
		var _node_clicked_name = undefined;
	
		var _is_prev_center = (!is_undefined(machine.previous_state) && machine.previous_state.name == _center_name);
	
		// Center heat / visited / alpha
		var _heat_center    = 0;
		var _visited_center = false;
		if (_use_heatmap && variable_struct_exists(_stats, _center_name)) {
			var _s_center = _stats[$ _center_name];
			_visited_center = (_s_center.total_frames > 0 || _s_center.entry_count > 0);
			var _metric_val_c = _use_visits ? _s_center.entry_count : _s_center.total_frames;
			if (_max_metric > 0 && _metric_val_c > 0) {
				_heat_center = clamp(_metric_val_c / _max_metric, 0, 1);
			}
		}
		var _heat_alpha_center  = (_use_heatmap && !_visited_center) ? 0.15 : 1;
		var _hover_alpha_center = (!is_undefined(_hovered_name) && _hovered_name != _center_name) ? 0.25 : 1;
		var _alpha_center       = _heat_alpha_center * _hover_alpha_center;
		
		// Center node (active state)
		var _show_label_center = show_labels || (!is_undefined(_hovered_name) && _hovered_name == _center_name);
		__DrawNode(_center_sx, _center_sy, _node_center, true, _is_prev_center, _heat_center, _alpha_center, _show_label_center);
		if (!is_undefined(_stats) && variable_struct_exists(_stats, _center_name)) {
			var _s_err_c = _stats[$ _center_name];
			if (is_struct(_s_err_c) && variable_struct_exists(_s_err_c, "has_error") && _s_err_c.has_error) {
				__DrawErrorBadge(_center_sx, _center_sy, _node_center.radius * camera_zoom);
			}
		}
		
		// Click detection for center
		if (_allow_input && (_l_pressed || _r_pressed)) {
			var _dx_c   = _mx - _center_sx;
			var _dy_c   = _my - _center_sy;
			var _dist_c = sqrt(_dx_c * _dx_c + _dy_c * _dy_c);
			if (_dist_c <= max(node_hit_radius * camera_zoom, 8)) {
				if (_l_pressed) {
					_node_clicked_name = _center_name;
					if (is_struct(_root)) {
						_root.ConsumeMouse();
					}
				}
				
				// RMB inspector is handled by the Echo-hosted controller; legacy path only.
				if (!is_struct(_root)) {
					if (_r_pressed) {
						_rmb_hit_node = true;
						
						if (inspect_is_open && inspect_state_name == _center_name) {
							inspect_is_open    = false;
							inspect_state_name = undefined;
						} 
						else {
							edge_inspect_is_open    = false;
							edge_inspect_edge_ref   = undefined;
							edge_inspect_from_name  = undefined;
							edge_inspect_to_name    = undefined;
							inspect_is_open    = true;
							inspect_state_name = _center_name;
							inspect_anchor_x   = _mx;
							inspect_anchor_y   = _my;
						}
					}
				}
			}
		}
	
		// Outgoing nodes (right side)
		for (var _oi4 = 0; _oi4 < _out_count; _oi4++) {
			var _name_out2 = _out_names[_oi4];
			var _node_out2 = __GetOrCreateNode(_name_out2);
		
			var _sx_o2 = _cx + (_node_out2.ego_x - camera_x) * camera_zoom;
			var _sy_o2 = _cy + (_node_out2.ego_y - camera_y) * camera_zoom;
		
			var _is_prev_out = (!is_undefined(machine.previous_state) && machine.previous_state.name == _name_out2);
		
			var _heat_out    = 0;
			var _visited_out = false;
			if (_use_heatmap && variable_struct_exists(_stats, _name_out2)) {
				var _s_out = _stats[$ _name_out2];
				_visited_out = (_s_out.total_frames > 0 || _s_out.entry_count > 0);
				var _metric_val_o = _use_visits ? _s_out.entry_count : _s_out.total_frames;
				if (_max_metric > 0 && _metric_val_o > 0) {
					_heat_out = clamp(_metric_val_o / _max_metric, 0, 1);
				}
			}
			var _heat_alpha_out  = (_use_heatmap && !_visited_out) ? 0.15 : 1;
			var _hover_alpha_out = (!is_undefined(_hovered_name) && _hovered_name != _name_out2) ? 0.25 : 1;
			var _alpha_out       = _heat_alpha_out * _hover_alpha_out;
		
			var _show_label_out = show_labels || (!is_undefined(_hovered_name) && _hovered_name == _name_out2);
			__DrawNode(_sx_o2, _sy_o2, _node_out2, false, _is_prev_out, _heat_out, _alpha_out, _show_label_out);
			if (!is_undefined(_stats) && variable_struct_exists(_stats, _name_out2)) {
				var _s_err_o = _stats[$ _name_out2];
				if (is_struct(_s_err_o) && variable_struct_exists(_s_err_o, "has_error") && _s_err_o.has_error) {
					__DrawErrorBadge(_sx_o2, _sy_o2, _node_out2.radius * camera_zoom);
				}
			}
	
			
			if (_allow_input && (_l_pressed || _r_pressed)) {
				var _dx_o   = _mx - _sx_o2;
				var _dy_o   = _my - _sy_o2;
				var _dist_o = sqrt(_dx_o * _dx_o + _dy_o * _dy_o);
				if (_dist_o <= max(node_hit_radius * camera_zoom, 8)) {
					if (_l_pressed) {
						_node_clicked_name = _name_out2;
						if (is_struct(_root)) {
							_root.ConsumeMouse();
						}
					}
					
					if (!is_struct(_root)) {
						if (_r_pressed) {
							_rmb_hit_node = true;
						
							if (inspect_is_open && inspect_state_name == _center_name) {
								inspect_is_open    = false;
								inspect_state_name = undefined;
							} 
							else {
								edge_inspect_is_open    = false;
								edge_inspect_edge_ref   = undefined;
								edge_inspect_from_name  = undefined;
								edge_inspect_to_name    = undefined;
								inspect_is_open    = true;
								inspect_state_name = _center_name;
								inspect_anchor_x   = _mx;
								inspect_anchor_y   = _my;
							}
						}
					}
				}
			}
		}
	
		// Incoming nodes (left side)
		for (var _ii4 = 0; _ii4 < _in_count; _ii4++) {
			var _name_in2 = _in_names[_ii4];
			var _node_in2 = __GetOrCreateNode(_name_in2);
		
			var _sx_i2 = _cx + (_node_in2.ego_x - camera_x) * camera_zoom;
			var _sy_i2 = _cy + (_node_in2.ego_y - camera_y) * camera_zoom;
		
			var _is_prev_in = (!is_undefined(machine.previous_state) && machine.previous_state.name == _name_in2);
		
			var _heat_in    = 0;
			var _visited_in = false;
			if (_use_heatmap && variable_struct_exists(_stats, _name_in2)) {
				var _s_in = _stats[$ _name_in2];
				_visited_in = (_s_in.total_frames > 0 || _s_in.entry_count > 0);
				var _metric_val_i = _use_visits ? _s_in.entry_count : _s_in.total_frames;
				if (_max_metric > 0 && _metric_val_i > 0) {
					_heat_in = clamp(_metric_val_i / _max_metric, 0, 1);
				}
			}
			var _heat_alpha_in  = (_use_heatmap && !_visited_in) ? 0.15 : 1;
			var _hover_alpha_in = (!is_undefined(_hovered_name) && _hovered_name != _name_in2) ? 0.25 : 1;
			var _alpha_in       = _heat_alpha_in * _hover_alpha_in;
		
			var _show_label_in = show_labels || (!is_undefined(_hovered_name) && _hovered_name == _name_in2);
			__DrawNode(_sx_i2, _sy_i2, _node_in2, false, _is_prev_in, _heat_in, _alpha_in, _show_label_in);
			if (!is_undefined(_stats) && variable_struct_exists(_stats, _name_in2)) {
				var _s_err_i = _stats[$ _name_in2];
				if (is_struct(_s_err_i) && variable_struct_exists(_s_err_i, "has_error") && _s_err_i.has_error) {
					__DrawErrorBadge(_sx_i2, _sy_i2, _node_in2.radius * camera_zoom);
				}
			}
			
			if (_allow_input && (_l_pressed || _r_pressed)) {
				var _dx_i   = _mx - _sx_i2;
				var _dy_i   = _my - _sy_i2;
				var _dist_i = sqrt(_dx_i * _dx_i + _dy_i * _dy_i);
				if (_dist_i <= max(node_hit_radius * camera_zoom, 8)) {
					if (_l_pressed) {
						_node_clicked_name = _name_in2;
						if (is_struct(_root)) {
							_root.ConsumeMouse();
						}
					}
					
					if (!is_struct(_root)) {
						if (_r_pressed) {
							_rmb_hit_node = true;
						
							if (inspect_is_open && inspect_state_name == _center_name) {
								inspect_is_open    = false;
								inspect_state_name = undefined;
							} 
							else {
								edge_inspect_is_open    = false;
								edge_inspect_edge_ref   = undefined;
								edge_inspect_from_name  = undefined;
								edge_inspect_to_name    = undefined;
								inspect_is_open    = true;
								inspect_state_name = _center_name;
								inspect_anchor_x   = _mx;
								inspect_anchor_y   = _my;
							}
						}
					}
				}
			}
		}
	
		draw_set_alpha(1);
		
		// RMB on empty space inside the ego graph clears inspectors; RMB on an edge opens the edge inspector.
		if (!is_struct(_root)) {
			if (_allow_input && _r_pressed && !_rmb_hit_node) {
				var _inside_graph = (_mx >= _left && _mx <= _left + _width
					&&                 _my >= _top  && _my <= _top  + _height);
			
				if (!is_undefined(_hovered_edge)) {
					edge_inspect_is_open   = true;
					edge_inspect_from_name = _hovered_edge.from;
					edge_inspect_to_name   = _hovered_edge.to;
					edge_inspect_edge_ref  = _hovered_edge.edge;
					edge_inspect_anchor_x  = _mx;
					edge_inspect_anchor_y  = _my;
					_rmb_hit_edge          = true;
				
					inspect_is_open    = false;
					inspect_state_name = undefined;
				} 
				else if (_inside_graph) {
					inspect_is_open        = false;
					inspect_state_name     = undefined;
					edge_inspect_is_open   = false;
					edge_inspect_from_name = undefined;
					edge_inspect_to_name   = undefined;
					edge_inspect_edge_ref  = undefined;
				}
			}
		}
	
		return _node_clicked_name;

	};
	
	/// @ignore
	/// @desc Compute inspector popup rect if open; returns undefined if not open.
	static __ComputeInspectorRect = function(_root_left, _root_top, _root_right, _root_bottom) {
		if (!inspect_is_open) {
			return undefined;
		}
		if (is_undefined(inspect_state_name)) {
			return undefined;
		}
		
		var _w = inspect_width;
		var _h = inspect_height;
		
		var _x = inspect_anchor_x + 12;
		var _y = inspect_anchor_y + 12;
		
		var _margin = 8;
		if (_x + _w > _root_right - _margin) {
			_x = _root_right - _margin - _w;
		}
		if (_x < _root_left + _margin) {
			_x = _root_left + _margin;
		}
		if (_y + _h > _root_bottom - _margin) {
			_y = _root_bottom - _margin - _h;
		}
		if (_y < _root_top + _margin) {
			_y = _root_top + _margin;
		}
		
		return { x : _x, y : _y, w : _w, h : _h };
	};
	
	/// @ignore
	/// @desc Compute edge inspector popup rect if open; returns undefined if not open.
	static __ComputeEdgeInspectorRect = function(_root_left, _root_top, _root_right, _root_bottom) {
		if (!edge_inspect_is_open) {
			return undefined;
		}
		if (is_undefined(edge_inspect_from_name) || is_undefined(edge_inspect_to_name)) {
			return undefined;
		}
		
		var _w = edge_inspect_width;
		
		// Try to pull the edge ref so we can measure actual wrapped height (payload, etc).
		var _edge_ref_measure = edge_inspect_edge_ref;
		if (is_undefined(_edge_ref_measure)) {
			var _graph_measure = machine.GetDebugGraph();
			if (!is_undefined(_graph_measure)) {
				var _edges_measure = _graph_measure.edges;
				var _len_measure = array_length(_edges_measure);
				var _map_measure = {};
				for (var _emi = 0; _emi < _len_measure; _emi++) {
					var _e_meas = _edges_measure[_emi];
					if (is_struct(_e_meas) && variable_struct_exists(_e_meas, "from_name") && variable_struct_exists(_e_meas, "to_name")) {
						_map_measure[$ __EdgeKey(_e_meas.from_name, _e_meas.to_name)] = _e_meas;
					}
				}
				_edge_ref_measure = __LookupEdge(_map_measure, edge_inspect_from_name, edge_inspect_to_name);
			}
		}
		
		var _h = max(edge_inspect_height, __MeasureEdgeInspectorHeight(edge_inspect_width, _edge_ref_measure, edge_inspect_from_name, edge_inspect_to_name));
		
		var _x = edge_inspect_anchor_x + 12;
		var _y = edge_inspect_anchor_y + 12;
		
		var _margin = 8;
		if (_x + _w > _root_right - _margin) {
			_x = _root_right - _margin - _w;
		}
		if (_x < _root_left + _margin) {
			_x = _root_left + _margin;
		}
		if (_y + _h > _root_bottom - _margin) {
			_y = _root_bottom - _margin - _h;
		}
		if (_y < _root_top + _margin) {
			_y = _root_top + _margin;
		}
		
		return { x : _x, y : _y, w : _w, h : _h };
	};
	
	/// @ignore
	/// @desc Draw machine info and per-state stats in the side panel.
	static __DrawInfoPanel = function(_graph, _left, _top, _width, _height, _root = undefined) {
		var _margin_x    = 6;
		var _margin_y    = 4;
		var _view_top    = _top;
		var _view_bottom = _top + _height;
		var _x           = _left + _margin_x;
		var _y_content   = _top + _margin_y;
		var _y_draw      = _y_content - info_scroll_y;
		var _max_w       = _width - _margin_x * 2;
		var _mx = 0;
		var _my = 0;
		var _l_pressed = false;
		
		if (is_struct(_root)) {
			_mx = _root.mx;
			_my = _root.my;
			_l_pressed = _root.mouse_l_pressed;
		}
		else {
			_mx = device_mouse_x_to_gui(0);
			_my = device_mouse_y_to_gui(0);
			_l_pressed = mouse_check_button_pressed(mb_left);
		}
		
		draw_set_color(ui_theme.col_text);
	
		// Basic machine info
		var _owner_desc;
		if (instance_exists(machine.owner)) {
			_owner_desc = "$" + string(machine.owner.id) + " " + object_get_name(machine.owner.object_index);
		} 
		else {
			_owner_desc = "struct";
		}
	
		var _state_name  = machine.GetStateName();
		var _prev_name   = machine.GetPreviousStateName();
		var _queued_name = machine.HasQueuedState() ? machine.GetQueuedStateName() : "none";
		var _age         = machine.GetStateTime();
		var _stack_depth = machine.GetStateStackDepth();
		var _hist_count  = machine.GetHistoryCount();
	
		var _owner_str   = $"Owner: {_owner_desc}";
		var _line_h      = string_height_ext(_owner_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _owner_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;

		var _path_str = "Path: " + __BuildMachinePath(machine);
		_line_h = string_height_ext(_path_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _path_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _current_str = $"Current: {_state_name}";
		_line_h = string_height_ext(_current_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _current_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _prev_str = $"Previous: {_prev_name}";
		_line_h = string_height_ext(_prev_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _prev_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _queued_str = $"Queued: {_queued_name}";
		_line_h = string_height_ext(_queued_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _queued_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _age_str = $"State age: {_age}";
		_line_h = string_height_ext(_age_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _age_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _stack_str = $"Stack depth: {_stack_depth}";
		_line_h = string_height_ext(_stack_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _stack_str, -1, _max_w);
		}
		_y_draw    += _line_h;
		_y_content += _line_h;
	
		var _hist_str = $"History count: {_hist_count}";
		_line_h = string_height_ext(_hist_str, -1, _max_w);
		if (_y_draw + _line_h >= _view_top && _y_draw <= _view_bottom) {
			draw_text_ext(_x, _y_draw, _hist_str, -1, _max_w);
		}
		_y_draw    += _line_h * 2;
		_y_content += _line_h * 2;
	
		// Transition history list (newest first)
		var _history = history_records;
		var _hist_len = array_length(_history);
		var _row_h_hist = string_height("Ag");
	
		if (_hist_len > 0) {
			var _label_hist = "Recent transitions:";
			var _label_h    = string_height(_label_hist);
			if (_y_draw + _label_h >= _view_top && _y_draw <= _view_bottom) {
				draw_text(_x, _y_draw, _label_hist);
			}
			_y_draw    += _label_h;
			_y_content += _label_h;
	
			for (var _hi = _hist_len - 1; _hi >= 0; _hi--) {
				var _rec = _history[_hi];
	
				var _from_name = is_undefined(_rec.from_name) ? "(start)" : _rec.from_name;
				var _to_name   = is_undefined(_rec.to_name) ? "(none)" : _rec.to_name;
	
				var _flags = [];
				if (_rec.force) {
					array_push(_flags, "force");
				}
				if (_rec.via_queue) {
					array_push(_flags, "queue");
				}
				if (_rec.via_push) {
					array_push(_flags, "push");
				}
				if (_rec.via_pop) {
					array_push(_flags, "pop");
				}
	
				var _flag_str = "";
				var _flag_count = array_length(_flags);
				if (_flag_count > 0) {
					_flag_str = " (flags: ";
					for (var _fi = 0; _fi < _flag_count; _fi++) {
						if (_fi > 0) {
							_flag_str += ", ";
						}
						_flag_str += _flags[_fi];
					}
					_flag_str += ")";
				}

				var _line_hist = "Tick " + string(_rec.tick) + ": " + _from_name + " -> " + _to_name + _flag_str;
				var _payload_raw = __FormatPayloadLabel(_rec[$ "payload"]);
				var _payload_line = "Payload: " + _payload_raw;
				var _payload_h = string_height_ext(_payload_line, -1, _max_w);
			
				var _row_y1    = _y_draw;
				var _row_y2    = _row_y1 + _row_h_hist + _payload_h;

				var _row_hover = (_mx >= _left && _mx <= _left + _width && _my >= _row_y1 && _my <= _row_y2);
				if (_row_hover) {
					draw_set_color(ui_theme.statement.history_hover_col);
					draw_rectangle(_left, _row_y1, _left + _width, _row_y2, false);
	
					history_hover_from_name = _rec.from_name;
					history_hover_to_name   = _rec.to_name;
					history_hover_tick      = _rec.tick;
	
					// Optional: LMB centers camera on the midpoint of this edge if both nodes exist.
					if (_l_pressed && !(is_struct(_root) && _root.mouse_consumed)) {
						var _node_from = (!is_undefined(_rec.from_name) && variable_struct_exists(node_layout, _rec.from_name)) ? node_layout[$ _rec.from_name] : undefined;
						var _node_to   = (!is_undefined(_rec.to_name)   && variable_struct_exists(node_layout, _rec.to_name))   ? node_layout[$ _rec.to_name]   : undefined;
	
					if (!is_undefined(_node_to)) {
						var _tx;
						var _ty;
						if (!is_undefined(_node_from)) {
							if (mode == eStatementLensMode.EGO) {
								_tx = (_node_from.ego_x + _node_to.ego_x) * 0.5;
								_ty = (_node_from.ego_y + _node_to.ego_y) * 0.5;
							} 
							else {
								_tx = (_node_from.x + _node_to.x) * 0.5;
								_ty = (_node_from.y + _node_to.y) * 0.5;
							}
						} 
						else {
							if (mode == eStatementLensMode.EGO) {
								_tx = _node_to.ego_x;
								_ty = _node_to.ego_y;
							} 
							else {
								_tx = _node_to.x;
								_ty = _node_to.y;
							}
						}
	
							target_camera_x        = _tx;
							target_camera_y        = _ty;
							camera_manual_override = true;
							if (is_struct(_root)) {
								_root.ConsumeMouse();
							}
						}
					}
	
					draw_set_color(ui_theme.col_text);
				}
	
				if (_row_y2 >= _view_top && _row_y1 <= _view_bottom) {
					draw_text(_x, _y_draw, _line_hist);
					// Payload preview directly beneath
					var _py = _y_draw + _row_h_hist;
					var _old_font_hist = draw_get_font();
					draw_set_font(ui_theme.font_small);
					draw_set_color(ui_theme.col_muted);
					var _payload_trim = __TrimTextToWidth(_payload_line, _max_w, ui_theme.font_small);
					draw_text_ext(_x, _py, _payload_trim, -1, _max_w);
					draw_set_font(_old_font_hist);
				}

				_y_draw    += _row_h_hist + _payload_h;
				_y_content += _row_h_hist + _payload_h;
			}

			_y_draw    += _row_h_hist * 0.5;
			_y_content += _row_h_hist * 0.5;
		}
	
		// Per-state stats (entries / time)
		var _stats = machine.GetDebugStateStats();
		if (!is_undefined(_stats)) {
			var _label_states = "States:";
			var _label_states_h = string_height(_label_states);
			if (_y_draw + _label_states_h >= _view_top && _y_draw <= _view_bottom) {
				draw_text(_x, _y_draw, _label_states);
			}
			_y_draw    += _label_states_h;
			_y_content += _label_states_h;
	
			var _states = _graph.states;
			var _count  = array_length(_states);
			for (var _i = 0; _i < _count; _i++) {
				var _st   = _states[_i];
				var _name = _st.name;
	
				if (!variable_struct_exists(_stats, _name)) {
					continue;
				}
	
				var _s = _stats[$ _name];
				var _line_state = _name + "  e:" + string(_s.entry_count) + "  t:" + string(_s.total_frames);
				var _line_state_h = string_height(_line_state);
	
				if (_y_draw + _line_state_h >= _view_top && _y_draw <= _view_bottom) {
					draw_text(_x + 8, _y_draw, _line_state);
				}
	
				_y_draw    += _line_state_h;
				_y_content += _line_state_h;
			}
		}
	
		info_scroll_max = max(0, _y_content - (_top + _height));
	};

	/// @ignore
	/// @desc Build line data for the Echo Chamber info list view.
	static __BuildInfoLines = function(_graph) {
		info_lines = [];
		info_line_meta = [];

		if (!is_struct(machine)) {
			return;
		}

		var _owner = machine.owner;
		var _owner_desc = "";
		if (is_struct(_owner)) {
			_owner_desc = "struct";
		}
		else if (instance_exists(_owner)) {
			_owner_desc = "$" + string(_owner.id) + " " + object_get_name(_owner.object_index);
		}
		else if (_owner == noone) {
			_owner_desc = "noone";
		}
		else {
			_owner_desc = "$" + string(_owner) + " (destroyed instance)";
		}

		array_push(info_lines, "Owner: " + _owner_desc);
		array_push(info_line_meta, undefined);

		var _path = __BuildMachinePath(machine);
		array_push(info_lines, "Path: " + _path);
		array_push(info_line_meta, undefined);

		var _state_name  = machine.GetStateName();
		var _prev_name   = machine.GetPreviousStateName();
		var _queued_name = machine.HasQueuedState() ? machine.GetQueuedStateName() : "none";
		var _age         = machine.GetStateTime();
		var _stack_depth = machine.GetStateStackDepth();
		var _hist_count  = machine.GetHistoryCount();

		array_push(info_lines, "Current: " + string(_state_name));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "Previous: " + string(_prev_name));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "Queued: " + string(_queued_name));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "State age: " + string(_age));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "Stack depth: " + string(_stack_depth));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "History count: " + string(_hist_count));
		array_push(info_line_meta, undefined);
		array_push(info_lines, "");
		array_push(info_line_meta, { kind: "spacer" });

		var _history = history_records;
		var _hist_len = array_length(_history);
		if (_hist_len > 0) {
			array_push(info_lines, "Recent transitions:");
			array_push(info_line_meta, { kind: "header" });

			for (var _hi = _hist_len - 1; _hi >= 0; _hi--) {
				var _rec = _history[_hi];
				var _from_name = is_undefined(_rec.from_name) ? "(start)" : _rec.from_name;
				var _to_name   = is_undefined(_rec.to_name) ? "(none)" : _rec.to_name;

				var _flags = [];
				if (_rec.force) {
					array_push(_flags, "force");
				}
				if (_rec.via_queue) {
					array_push(_flags, "queue");
				}
				if (_rec.via_push) {
					array_push(_flags, "push");
				}
				if (_rec.via_pop) {
					array_push(_flags, "pop");
				}

				var _flag_str = "";
				var _flag_count = array_length(_flags);
				if (_flag_count > 0) {
					_flag_str = " (flags: ";
					for (var _fi = 0; _fi < _flag_count; _fi++) {
						if (_fi > 0) {
							_flag_str += ", ";
						}
						_flag_str += _flags[_fi];
					}
					_flag_str += ")";
				}

				var _line_hist = "Tick " + string(_rec.tick) + ": " + _from_name + " -> " + _to_name + _flag_str;
				array_push(info_lines, _line_hist);
				array_push(info_line_meta, {
					kind: "history",
					from_name: _rec.from_name,
					to_name: _rec.to_name,
					tick: _rec.tick,
					small: false
				});

				var _payload_raw = __FormatPayloadLabel(_rec[$ "payload"]);
				var _payload_line = "Payload: " + _payload_raw;
				array_push(info_lines, _payload_line);
				array_push(info_line_meta, {
					kind: "history",
					from_name: _rec.from_name,
					to_name: _rec.to_name,
					tick: _rec.tick,
					small: true
				});
			}

			array_push(info_lines, "");
			array_push(info_line_meta, { kind: "spacer" });
		}

		var _stats = machine.GetDebugStateStats();
		if (!is_undefined(_stats) && is_struct(_graph)) {
			array_push(info_lines, "States:");
			array_push(info_line_meta, { kind: "header" });

			var _states = _graph.states;
			var _count  = array_length(_states);
			for (var _i = 0; _i < _count; _i++) {
				var _st = _states[_i];
				if (!is_struct(_st)) {
					continue;
				}
				var _name = _st[$ "name"];
				if (is_undefined(_name)) {
					continue;
				}
				var _s = _stats[$ _name];
				if (is_undefined(_s)) {
					continue;
				}

				var _line_state = string(_name) + "  e:" + string(_s.entry_count) + "  t:" + string(_s.total_frames);
				array_push(info_lines, _line_state);
				array_push(info_line_meta, { kind: "state" });
			}
		}
	};

	/// @ignore
	/// @desc Center the camera on a history edge midpoint (if nodes exist).
	static __CenterCameraOnHistoryEdge = function(_from_name, _to_name) {
		if (is_undefined(_to_name)) {
			return;
		}

		var _node_to = node_layout[$ _to_name];
		if (is_undefined(_node_to)) {
			return;
		}

		var _node_from = undefined;
		if (!is_undefined(_from_name)) {
			_node_from = node_layout[$ _from_name];
		}

		var _tx;
		var _ty;
		if (!is_undefined(_node_from)) {
			if (mode == eStatementLensMode.EGO) {
				_tx = (_node_from.ego_x + _node_to.ego_x) * 0.5;
				_ty = (_node_from.ego_y + _node_to.ego_y) * 0.5;
			}
			else {
				_tx = (_node_from.x + _node_to.x) * 0.5;
				_ty = (_node_from.y + _node_to.y) * 0.5;
			}
		}
		else {
			if (mode == eStatementLensMode.EGO) {
				_tx = _node_to.ego_x;
				_ty = _node_to.ego_y;
			}
			else {
				_tx = _node_to.x;
				_ty = _node_to.y;
			}
		}

		target_camera_x        = _tx;
		target_camera_y        = _ty;
		camera_manual_override = true;
	};
	
	/// @ignore
	/// @desc Draw a highlight overlay for the hovered transition history entry.
	static __DrawHistoryHoverOverlay = function(_left, _top, _width, _height) {
		if (is_undefined(history_hover_from_name) || is_undefined(history_hover_to_name)) {
			return;
		}
		if (history_hover_tick < 0) {
			return;
		}
		
		if (!variable_struct_exists(node_layout, history_hover_from_name)) {
			return;
		}
		if (!variable_struct_exists(node_layout, history_hover_to_name)) {
			return;
		}
		
		var _node_from = node_layout[$ history_hover_from_name];
		var _node_to   = node_layout[$ history_hover_to_name];
		
		if (mode == eStatementLensMode.EGO) {
			if (!_node_from.ego_initialized || !_node_to.ego_initialized) {
				return;
			}
		}
		
		var _cx = _left + _width  * 0.5;
		var _cy = _top  + _height * 0.5;
		
		var _sx1;
		var _sy1;
		var _sx2;
		var _sy2;
		
		if (mode == eStatementLensMode.EGO) {
			_sx1 = _cx + (_node_from.ego_x - camera_x) * camera_zoom;
			_sy1 = _cy + (_node_from.ego_y - camera_y) * camera_zoom;
			_sx2 = _cx + (_node_to.ego_x   - camera_x) * camera_zoom;
			_sy2 = _cy + (_node_to.ego_y   - camera_y) * camera_zoom;
		} 
		else {
			_sx1 = _cx + (_node_from.x - camera_x) * camera_zoom;
			_sy1 = _cy + (_node_from.y - camera_y) * camera_zoom;
			_sx2 = _cx + (_node_to.x   - camera_x) * camera_zoom;
			_sy2 = _cy + (_node_to.y   - camera_y) * camera_zoom;
		}
		
		__DrawEdgeStyled(_sx1, _sy1, _sx2, _sy2, eStatementDebugEdgeStyle.HISTORY, 1, 1, 0, 1.35);
	};
	
	/// @ignore
	static __BuildEgoNeighborLists = function(_graph, _center_name, _observed_only = false, _allow_debug = true, _allow_decl = true, _allow_manual = true, _allow_observed = true) {
		var _out_names = [];
		var _in_names  = [];
	
		if (is_undefined(_graph) || is_undefined(_center_name)) {
			return { out_names : _out_names, in_names : _in_names };
		}
		
		var _edges = _graph.edges;
		var _edge_count = array_length(_edges);
		for (var _ei = 0; _ei < _edge_count; _ei++) {
			var _edge = _edges[_ei];
			var _from = _edge.from_name;
			var _to   = _edge.to_name;
			var _kind = is_struct(_edge) && variable_struct_exists(_edge, "kind") ? _edge.kind : eStatementDebugEdgeKind.DECLARATIVE;
			var _is_debug = is_struct(_edge) && variable_struct_exists(_edge, "debug_created") && _edge.debug_created;
		
			if (_observed_only) {
				if (_kind != eStatementDebugEdgeKind.OBSERVED) {
					continue;
				}
			}
		
			if (!_allow_debug && _is_debug) {
				continue;
			}
		
			if (_kind == eStatementDebugEdgeKind.DECLARATIVE && !_allow_decl) {
				continue;
			}
			if (_kind == eStatementDebugEdgeKind.MANUAL && !_allow_manual) {
				continue;
			}
			if (_kind == eStatementDebugEdgeKind.OBSERVED && !_allow_observed) {
				continue;
			}
			
			if (_from == _center_name && _to != _center_name) {
				var _exists_out = false;
				var _out_len = array_length(_out_names);
				for (var _oi = 0; _oi < _out_len; _oi++) {
					if (_out_names[_oi] == _to) {
						_exists_out = true;
						break;
					}
				}
				if (!_exists_out) {
					array_push(_out_names, _to);
				}
			}
			
			if (_to == _center_name && _from != _center_name) {
				var _exists_in = false;
				var _in_len = array_length(_in_names);
				for (var _ii = 0; _ii < _in_len; _ii++) {
					if (_in_names[_ii] == _from) {
						_exists_in = true;
						break;
					}
				}
				if (!_exists_in) {
					array_push(_in_names, _from);
				}
			}
		}
		
		return {
			out_names : _out_names,
			in_names  : _in_names
		};
	};
	

	/// @ignore
	/// @desc Build filtered machine list with labels and index map.
	static __BuildMachinePath = function(_m) {
		if (!is_struct(_m)) {
			return "(none)";
		}

		var _cur = _m;
		var _chain = [];
		var _safety = 0;

		while (is_struct(_cur) && variable_struct_exists(_cur, "parent_machine") && is_struct(_cur.parent_machine)) {
			var _seg = "";
			var _ps = variable_struct_exists(_cur, "parent_state") ? _cur.parent_state : undefined;
			if (is_struct(_ps)) {
				if (variable_struct_exists(_ps, "submachine_name") && string_length(string(_ps.submachine_name)) > 0) {
					_seg = string(_ps.submachine_name);
				}
				else if (variable_struct_exists(_ps, "name")) {
					_seg = string(_ps.name);
				}
			}
			if (_seg == "") _seg = "(sub)";
			array_push(_chain, _seg);

			_cur = _cur.parent_machine;
			_safety++;
			if (_safety > 64) {
				break;
			}
		}

		var _root_name = "Machine";
		if (is_struct(_cur) && is_callable(_cur.GetDebugName)) {
			var _nm = _cur.GetDebugName();
			_root_name = __FormatDebugName(_nm, _root_name);
		}

		var _path = _root_name;
		var _seg_path = "";
		for (var _i = array_length(_chain) - 1; _i >= 0; _i--) {
			if (_seg_path != "") {
				_seg_path += ".";
			}
			_seg_path += string(_chain[_i]);
		}
		if (_seg_path != "") {
			_path += " :: " + _seg_path;
		}

		return _path;
	};
	
	/// @ignore
	static __BuildMachineList = function() {
		if (!variable_global_exists("__statement_machines")) {
			return { labels : ["(none)"], index_map : [-1], selected_index : 0 };
		}

		var _machines = global.__statement_machines;
		var _machine_labels = [];
		var _machine_index_map = [];
		
		var _machines_count = array_length(_machines);
		var _query_raw = machine_filter_query;
		var _query_tokens = string_split(string_lower(_query_raw), ",");
		var _has_query = false;
		var _tokens_clean = [];
		var _tlen = array_length(_query_tokens);
		for (var _qi = 0; _qi < _tlen; _qi++) {
			var _tok = string_trim(_query_tokens[_qi]);
			if (string_length(_tok) > 0) {
				array_push(_tokens_clean, _tok);
				_has_query = true;
			}
		}
		
		for (var _mi = 0; _mi < _machines_count; _mi++) {
			var _entry = _machines[_mi];
			var _m = __StatementDebugDerefMachineEntry(_entry);
			if (!is_struct(_m)) {
				continue;
			}
				
			var _owner = _m.owner;
			var _owner_is_struct = is_struct(_owner);
				
			if (!machine_filter_show_instances && !_owner_is_struct) {
				continue;
			}
			if (!machine_filter_show_structs && _owner_is_struct) {
				continue;
			}
			if (machine_filter_active_only && is_undefined(_m.state)) {
				continue;
			}
				
			var _label = __BuildMachinePath(_m);
			
			var _tag_raw = is_callable(_m.GetDebugTag) ? _m.GetDebugTag() : undefined;
			var _tag_append = "";
			if (!is_undefined(_tag_raw) && string_length(string(_tag_raw)) > 0) {
				_tag_append = " [" + string(_tag_raw) + "]";
			}
			
			if (_owner_is_struct) {
				_label += " (struct)";
			}
			else if (instance_exists(_owner)) {
				_label += " (" + object_get_name(_owner.object_index) + ")";
			} 
			else if (_owner == noone) {
				_label += " (noone)";
			}
			else {
				_label += " (destroyed instance)";
			}
			
			_label += _tag_append;
			
			if (_has_query) {
				var _label_lower = string_lower(_label);
				
				var _tag_tokens = [];
				if (!is_undefined(_tag_raw)) {
					var _split_tags = string_split(string_lower(string(_tag_raw)), ",");
					var _split_len = array_length(_split_tags);
					for (var _ti = 0; _ti < _split_len; _ti++) {
						var _tag_piece = string_trim(_split_tags[_ti]);
						if (string_length(_tag_piece) > 0) {
							array_push(_tag_tokens, _tag_piece);
						}
					}
				}
				
				var _match = false;
				var _tok_len2 = array_length(_tokens_clean);
				for (var _tk = 0; _tk < _tok_len2; _tk++) {
					var _q = _tokens_clean[_tk];
					if (string_pos(_q, _label_lower) > 0) {
						_match = true;
						break;
					}
					var _tag_len2 = array_length(_tag_tokens);
					for (var _tj = 0; _tj < _tag_len2; _tj++) {
						if (string_pos(_q, _tag_tokens[_tj]) > 0) {
							_match = true;
							break;
						}
					}
					if (_match) {
						break;
					}
				}
				
				if (!_match) {
					continue;
				}
			}
			
			array_push(_machine_labels, _label);
			array_push(_machine_index_map, _mi);
		}
		
		if (array_length(_machine_labels) <= 0) {
			_machine_labels = ["(none)"];
			_machine_index_map = [-1];
		}
		
		var _selected_filtered_index = 0;
		var _filtered_len = array_length(_machine_index_map);
		for (var _fi = 0; _fi < _filtered_len; _fi++) {
			if (_machine_index_map[_fi] == machine_index) {
				_selected_filtered_index = _fi;
				break;
			}
		}
		
		return {
			labels         : _machine_labels,
			index_map      : _machine_index_map,
			selected_index : _selected_filtered_index
		};
	};
}

/// @ignore
/// @desc Internal layout node used by the visualiser.
function __DebugNode(_name, _x, _y, _vx, _vy, _target_x, _target_y, _tick) constructor {
	name			= _name;
	x               = _x;
	y               = _y;
	vx              = 0;
	vy              = 0;
	target_x		= _target_x;
	target_y		= _target_y;
	discovered_tick = _tick;
		
	col_fill			= c_white;
	col_outline			= c_gray;
	active_col_fill		= c_lime;
	active_col_outline	= c_white;
	prev_col_fill		= c_yellow;
	prev_col_outline	= c_white;
		
	active_radius_target	= 10;
	radius_target			= 3;
	prev_radius_target		= 5;
		
	radius					= 0;
	
	// Ego layout (used only in EGO mode)
	ego_x          = 0;
	ego_y          = 0;
	ego_initialized = false;
}

/// @func StatementLensGet()
/// @desc Returns the reference to the Statement visualiser
function StatementLensGet() {
	if (STATEMENT_DEBUG) {
		if (variable_global_exists("__statement_lens")) {
			return global.__statement_lens;
		}
	}
}

/// @desc Ensures that the Lens global variables exists and refreshes the machines for the visualiser.
function StatementLensInit() {
	if (STATEMENT_DEBUG) {
		if (!variable_global_exists("__statement_machines")) {
			global.__statement_machines = [];
		}
		if (!variable_global_exists("__statement_lens")) {
			global.__statement_lens = new StatementLens();
		}
		var _v = global.__statement_lens;
		_v.__RefreshMachine();
	}
}

/// @func StatementLensUpdate()
/// @desc Update hook for the Statement visualiser (call from a Step event when STATEMENT_DEBUG is enabled).
function StatementLensUpdate() {
	if (STATEMENT_DEBUG) {
		StatementLensInit();
	}
}

/// @func StatementLensInputPressed(_action_id)
/// @desc Returns true if a Statement Lens action is pressed in the active Echo Chamber input context.
/// @param {String} _action_id
/// @return {Bool}
function StatementLensInputPressed(_action_id) {
	var _root = undefined;
	if (variable_global_exists("__statement_lens_controller")) {
		var _ctrl = global.__statement_lens_controller;
		if (is_instanceof(_ctrl, __StatementLensController)) {
			_root = _ctrl.root;
		}
	}
	if (!is_instanceof(_root, EchoChamberRoot)) {
		if (variable_global_exists("__statement_lens_root")) {
			_root = global.__statement_lens_root;
		}
	}
	if (!is_instanceof(_root, EchoChamberRoot)) {
		return false;
	}
	return _root.InputPressed(_action_id);
}

/// @func StatementLensDraw()
/// @desc Draw hook for the Statement visualiser (call from a Draw GUI event when STATEMENT_DEBUG is enabled).
function StatementLensDraw() {
	if (STATEMENT_DEBUG) {
		StatementLensInit();
		
		if (!variable_global_exists("__statement_lens_root") || !is_struct(global.__statement_lens_root)) {
			global.__statement_lens_root = new EchoChamberRoot(new EchoChamberTheme());
		}
		
		StatementLensOpen(global.__statement_lens_root);
		global.__statement_lens_root.RunDesktop();
	}
}

/// @func StatementLensOpen(_ui_root)
/// @desc Open or create the Statement Lens window inside the Echo Debug UI desktop.
/// @param {Struct.EchoChamberRoot} _ui_root
/// @return {Struct.EchoChamberWindow}
function StatementLensOpen(_ui_root) {
	if (!STATEMENT_DEBUG) {
		return undefined;
	}
	if (!is_struct(_ui_root)) {
		return undefined;
	}
	
	// Ensure the legacy visualiser exists (we reuse its graph + info rendering for M1).
	// Important: do NOT reset the machine registry here.
	if (!variable_global_exists("__statement_machines")) {
		global.__statement_machines = [];
	}
	if (!variable_global_exists("__statement_lens")) {
		global.__statement_lens = new StatementLens();
	}
	StatementDebugPruneRegistry(true);
	global.__statement_lens.__RefreshMachine();
	
	var _ctrl = undefined;
	if (variable_global_exists("__statement_lens_controller")) {
		_ctrl = global.__statement_lens_controller;
		if (!is_struct(_ctrl) || _ctrl.root != _ui_root) {
			_ctrl = undefined;
		}
	}
	
	if (!is_struct(_ctrl)) {
		_ctrl = new __StatementLensController(_ui_root);
		global.__statement_lens_controller = _ctrl;
	}
	
	return _ctrl.__Open();
}

/// @ignore
/// @func __StatementLensController(_root)
/// @desc Internal controller for hosting Statement Lens inside Echo Debug UI.
function __StatementLensController(_root) constructor {
	root = _root;
	win  = undefined;
	
	toolbar_panel = undefined;
	content_panel = undefined;
	graph_panel   = undefined;
	info_panel    = undefined;
	info_list     = undefined;
	
	__draw_stamp = -1;
	
	info_scroll = new EchoChamberScrollState("statement_lens_info_scroll");
	
	state = {
		mode_index : 0,
		overlay_index : 0,
		edge_scope_index : 0,
		break_on_enter : false
	};

	input_context_id = "statement_lens";
	input_defaults_bound = false;
	
	ctrl_picker = undefined;
	ctrl_btn_up = undefined;
	ctrl_toggle_instances = undefined;
	ctrl_toggle_structs   = undefined;
	ctrl_toggle_active    = undefined;
	ctrl_toggle_names     = undefined;
	ctrl_dd_mode          = undefined;
	ctrl_dd_overlay       = undefined;
	ctrl_menu_edges       = undefined;
	ctrl_dd_edge_scope    = undefined;
	ctrl_btn_bookmarks    = undefined;
	ctrl_btn_pause        = undefined;
	ctrl_btn_step         = undefined;
	ctrl_toggle_force     = undefined;
	ctrl_toggle_break     = undefined;
	ctrl_toggle_cam_lock  = undefined;
	ctrl_btn_center       = undefined;
	ctrl_btn_options      = undefined;
	ctrl_lbl_decay        = undefined;
	ctrl_slider_decay     = undefined;
	ctrl_btn_search       = undefined;
	
	overlay_panel = new EchoChamberPanel("statement_lens_overlay_panel", eEchoChamberDock.FILL);
	
	// Search overlay
	search_open          = false;
	search_query         = "";
	search_results       = [];
	search_selected_i    = -1;
	search_scroll        = new EchoChamberScrollState("statement_lens_search_scroll");
	search_input         = new EchoChamberTextInput("statement_lens_search_input");
	
	// Inspectors (RMB)
	inspect_state_open   = false;
	inspect_state_name   = undefined;
	inspect_state_anchor_x = 0;
	inspect_state_anchor_y = 0;
	inspect_state_scroll = new EchoChamberScrollState("statement_lens_state_inspector_scroll");
	
	inspect_edge_open    = false;
	inspect_edge_from    = undefined;
	inspect_edge_to      = undefined;
	inspect_edge_anchor_x = 0;
	inspect_edge_anchor_y = 0;
	inspect_edge_scroll  = new EchoChamberScrollState("statement_lens_edge_inspector_scroll");
	
	last_graph_rect      = undefined;
	
	/// @ignore
	static __EnsureBuilt = function() {
		if (!is_struct(root)) {
			return;
		}
		
		var _self = self;
		
		overlay_panel.row_height = max(18, root.default_row_height);
		overlay_panel.padding = 0;
		overlay_panel.gap = 4;
		overlay_panel.flow = "column";
		
		// Create or re-find the window by stable id.
		win = root.FindWindow("statement_lens");
		if (!is_struct(win)) {
			win = new EchoChamberWindow("statement_lens");
			win.SetTitle("Statement Lens");
			win.SetMinSize(560, 320);
			win.SetRect(64, 64, 64 + 1100, 64 + 650);
			root.RegisterWindow(win);
			win.ApplyTheme(new EchoChamberThemeMidnightNeon());
		}

		win.SetInputContext(input_context_id);
		if (!input_defaults_bound) {
			__BindInputDefaults();
			input_defaults_bound = true;
		}
		
		var _v = StatementLensGet();
		
		// Panels: toolbar (TOP), content container (FILL) with graph (FILL) + info (RIGHT, fixed).
		toolbar_panel = new EchoChamberPanel("statement_lens_toolbar", eEchoChamberDock.TOP);
		toolbar_panel.SetSizeMode(eEchoChamberPanelSizeMode.FIT_CONTENT);
		toolbar_panel.flow = "row";
		toolbar_panel.SetPanelStyleKey("toolbar");
		toolbar_panel.padding = 4;
		toolbar_panel.gap = 4;
		
		// Machine picker + quick filters
		ctrl_picker = new EchoChamberMachinePicker("statement_lens_machine_picker")
			.SetTooltip("Pick a Statement machine to inspect.")
			.SetControlStyleKey("_default")
			.SetListBuilder(function(_filter_string) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return { labels : ["(none)"], index_map : [-1], selected_index : 0 };
				}
				var _prev = _vis.machine_filter_query;
				_vis.machine_filter_query = string(_filter_string);
				var _res = _vis.__BuildMachineList();
				_vis.machine_filter_query = _prev;
				return _res;
			})
			.OnSelect(function(_machine_index) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				if (_machine_index < 0) {
					return;
				}
				_vis.machine_index = _machine_index;
				_vis.__RefreshMachine();
				_vis.__RebuildLayout();
			});
		//ctrl_picker.SetPreferredWidth(320);
		
		ctrl_btn_up = new EchoChamberButton("statement_lens_up")
			.SetLabel("Up")
			.SetTooltip("Go to the parent machine.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				if (!is_struct(_vis.machine)) {
					return;
				}
				if (!variable_struct_exists(_vis.machine, "parent_machine") || !is_struct(_vis.machine.parent_machine)) {
					return;
				}
				
				var _parent = _vis.machine.parent_machine;
				if (variable_global_exists("__statement_machines")) {
					var _reg = global.__statement_machines;
					var _rlen = array_length(_reg);
					for (var _ri = 0; _ri < _rlen; _ri++) {
						var _m2 = __StatementDebugDerefMachineEntry(_reg[_ri]);
						if (is_struct(_m2) && _m2 == _parent) {
							_vis.machine_index = _ri;
							_vis.__RefreshMachine();
							_vis.__RebuildLayout();
							break;
						}
					}
				}
			}));
		//ctrl_btn_up.SetPreferredWidth(44);
		
		ctrl_toggle_instances = new EchoChamberToggle("statement_lens_filter_instances")
			.SetLabel("Instances")
			.SetTooltip("Show machines owned by game object instances.")
			.BindBool(_v, "machine_filter_show_instances");
		//ctrl_toggle_instances.SetPreferredWidth(92);
		
		ctrl_toggle_structs = new EchoChamberToggle("statement_lens_filter_structs")
			.SetLabel("Structs")
			.SetTooltip("Show machines owned by structs.")
			.BindBool(_v, "machine_filter_show_structs");
		//ctrl_toggle_structs.SetPreferredWidth(72);
		
		ctrl_toggle_active = new EchoChamberToggle("statement_lens_filter_active")
			.SetLabel("Active")
			.SetTooltip("Hide machines that have no current state.")
			.BindBool(_v, "machine_filter_active_only");
		//ctrl_toggle_active.SetPreferredWidth(70);
		
		// Layout + overlay
		ctrl_dd_mode = new EchoChamberDropdownSelect("statement_lens_mode")
			.SetTooltip("Switch how states are laid out in the graph.")
			.SetOptions(["FULL", "RADIAL", "CLOUD", "EGO"])
			.BindIndex(state, "mode_index")
			.OnChange(function(_idx, _val) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				var _new_mode = eStatementLensMode.FULL;
				switch (_idx) {
					case 0: _new_mode = eStatementLensMode.FULL; break;
					case 1: _new_mode = eStatementLensMode.RADIAL; break;
					case 2: _new_mode = eStatementLensMode.CLOUD; break;
					default: _new_mode = eStatementLensMode.EGO; break;
				}
				_vis.__SetMode(_new_mode);
			});
		//ctrl_dd_mode.SetPreferredWidth(84);
		
		ctrl_dd_overlay = new EchoChamberDropdownSelect("statement_lens_overlay")
			.SetTooltip("Pick an overlay (none or heatmap) for the graph.")
			.SetOptions(["NONE", "HEAT: TIME", "HEAT: VISITS"])
			.BindIndex(state, "overlay_index")
			.OnChange(function(_idx, _val) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				
				switch (_idx) {
					case 0:
						_vis.overlay_mode = eStatementLensOverlay.NONE;
						_vis.heat_metric  = eStatementHeatMetric.TIME;
					break;
					case 1:
						_vis.overlay_mode = eStatementLensOverlay.HEATMAP;
						_vis.heat_metric  = eStatementHeatMetric.TIME;
					break;
					case 2:
						_vis.overlay_mode = eStatementLensOverlay.HEATMAP;
						_vis.heat_metric  = eStatementHeatMetric.VISITS;
					break;
				}
			});
		//ctrl_dd_overlay.SetPreferredWidth(110);
		
		// Graph visibility toggles
		ctrl_toggle_names = new EchoChamberToggle("statement_lens_show_names")
			.SetLabel("Names")
			.SetTooltip("Show state names on the graph.")
			.BindBool(_v, "show_labels");
		//ctrl_toggle_names.SetPreferredWidth(60);
		
		ctrl_menu_edges = new EchoChamberDropdownToggleMenu("statement_lens_edge_menu")
			.SetLabel("Edges")
			.SetTooltip("Choose which edge types are drawn.")
			.SetItems([
				{ label : "Edges: All",         bind_struct : _v, bind_key : "show_edges" },
				{ label : "Declarative",        bind_struct : _v, bind_key : "show_decl_edges" },
				{ label : "Manual",             bind_struct : _v, bind_key : "show_manual_edges" },
				{ label : "Observed",           bind_struct : _v, bind_key : "show_observed_edges" },
				{ label : "Debug edges",        bind_struct : _v, bind_key : "show_debug_edges" },
				{ label : "History lines",      bind_struct : _v, bind_key : "show_history_edges" },
				{ label : "History sparks",     bind_struct : _v, bind_key : "show_history_sparks" },
				{ label : "Observed only",      bind_struct : _v, bind_key : "show_observed_only" }
			]);
		//ctrl_menu_edges.SetPreferredWidth(96);
		
		ctrl_dd_edge_scope = new EchoChamberDropdownSelect("statement_lens_edge_scope")
			.SetTooltip("Filter edges to recent or active ones.")
			.SetOptions(["Edges: All", "Edges: Active", "Edges: Last 50", "Edges: Last 500", "Edges: Last 5000"])
			.BindIndex(state, "edge_scope_index")
			.OnChange(function(_idx, _val) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				switch (_idx) {
					case 0:
						_vis.edge_filter_active_only = false;
						_vis.edge_filter_recent_ticks = 0;
					break;
					case 1:
						_vis.edge_filter_active_only = true;
						_vis.edge_filter_recent_ticks = 0;
					break;
					case 2:
						_vis.edge_filter_active_only = false;
						_vis.edge_filter_recent_ticks = 50;
					break;
					case 3:
						_vis.edge_filter_active_only = false;
						_vis.edge_filter_recent_ticks = 500;
					break;
					default:
						_vis.edge_filter_active_only = false;
						_vis.edge_filter_recent_ticks = 5000;
					break;
				}
			});
		//ctrl_dd_edge_scope.SetPreferredWidth(120);
		
		// Bookmarks (context menu)
		ctrl_btn_bookmarks = new EchoChamberButton("statement_lens_bookmarks")
			.SetLabel("Bookmarks")
			.SetTooltip("Save or load camera/bookmark presets.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				var _items = [];
				for (var _i = 0; _i < 6; _i++) {
					var _slot = _i + 1;
					array_push(_items, {
						label : "Load Slot " + string(_slot),
						on_click : method({ _vis, _i }, function() { _vis.__LoadBookmark(_i); })
					});
					array_push(_items, {
						label : "Save Slot " + string(_slot),
						on_click : method({ _vis, _i }, function() { _vis.__SaveBookmark(_i); })
					});
					if (_i != 5) {
						array_push(_items, { is_separator : true });
					}
				}
				root.OpenContextMenu(_items, root.mx, root.my, win);
			}));
		//ctrl_btn_bookmarks.SetPreferredWidth(92);
		
		// Runtime controls
		ctrl_btn_pause = new EchoChamberButton("statement_lens_pause")
			.SetLabel("Pause")
			.SetTooltip("Pause or resume this machine.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis) || !is_struct(_vis.machine)) {
					return;
				}
				var _m = _vis.machine;
				if (!variable_global_exists("__statement_debug_pause_all")) {
					global.__statement_debug_pause_all = false;
				}
				var _pause_all_flag = (variable_global_exists("__statement_debug_pause_all") ? global.__statement_debug_pause_all : false);
				var _is_paused = _m.paused || _pause_all_flag;
				if (_is_paused) {
					_m.DebugResume();
					_vis.pause_banner_resumed_time_ms = current_time;
				}
				else {
					_m.DebugPause();
				}
			}));
		//ctrl_btn_pause.SetPreferredWidth(62);
		
		ctrl_btn_step = new EchoChamberButton("statement_lens_step")
			.SetLabel("Step")
			.SetTooltip("Advance one tick while paused.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis) || !is_struct(_vis.machine)) {
					return;
				}
				_vis.machine.DebugStep();
			}));
		//ctrl_btn_step.SetPreferredWidth(52);
		
		ctrl_toggle_force = new EchoChamberToggle("statement_lens_force")
			.SetLabel("Force")
			.SetTooltip("Allow debug jumps to ignore exit locks.")
			.BindBool(_v, "force_transitions");
		//ctrl_toggle_force.SetPreferredWidth(64);
		
		ctrl_toggle_break = new EchoChamberToggle("statement_lens_break")
			.SetLabel("Break")
			.SetTooltip("Pause when the active state is entered.")
			.BindBool(state, "break_on_enter")
			.OnChange(method(_self, function(_v_new) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis) || !is_struct(_vis.machine) || !is_struct(_vis.machine.state)) {
					return;
				}
				_vis.machine.state.debug_break_on_enter = (_v_new == true);
			}));
		//ctrl_toggle_break.SetPreferredWidth(60);
		
		ctrl_toggle_cam_lock = new EchoChamberToggle("statement_lens_cam_lock")
			.SetLabel("Camera Lock")
			.SetTooltip("Keep camera centered on the active state.")
			.BindBool(_v, "lock_to_active")
			.OnChange(method(_self, function(_v_new) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				if (_v_new) {
					_vis.camera_manual_override = false;
					_vis.__CenterCameraOnActive(true);
				}
			}));
		//ctrl_toggle_cam_lock.SetPreferredWidth(110);
		
		ctrl_btn_center = new EchoChamberButton("statement_lens_center")
			.SetLabel("Center")
			.SetTooltip("Snap the camera to the active state.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				_vis.camera_manual_override = false;
				_vis.__CenterCameraOnActive(true);
			}));
		//ctrl_btn_center.SetPreferredWidth(64);
		
		ctrl_btn_options = new EchoChamberButton("statement_lens_options")
			.SetLabel("Options")
			.SetTooltip("General settings.")
			.OnClick(method(_self, function() {
				var _vis = StatementLensGet();
				if (!is_struct(_vis)) {
					return;
				}
				if (!variable_global_exists("__statement_debug_pause_all")) {
					global.__statement_debug_pause_all = false;
				}
				
				var _pause_all_flag = (variable_global_exists("__statement_debug_pause_all") ? global.__statement_debug_pause_all : false);
				
				var _items = [
					{
						label : (_vis.allow_click_to_jump ? "[x] " : "[ ] ") + "Click to Change State",
						on_click :	method({
										_vis
									}, function() { _vis.allow_click_to_jump = !_vis.allow_click_to_jump; })
					},
					{
						label : (_pause_all_flag ? "[x] " : "[ ] ") + "Global Pause All States",
						on_click :	method({
										_pause_all_flag
									}, function() { global.__statement_debug_pause_all = !_pause_all_flag; })
					},
					{ is_separator : true },
					{
						label : "Prune State Machines",
						on_click : function() {
							var _pruned = StatementDebugPruneRegistry(true);
							if (_pruned > 0) {
								EchoDebugInfo("[Statement] Pruned " + string(_pruned) + " dead debug machine(s).");
							}
							else {
								EchoDebugInfo("[Statement] Pruned registry; no dead machines were found.");
							}
								}
						}
				];
				
				self.root.OpenContextMenu(_items, self.root.mx, self.root.my, self.win);
			}));
		//ctrl_btn_options.SetPreferredWidth(72);
		
		ctrl_lbl_decay = new EchoChamberLabel("statement_lens_decay_label")
			.UseSmallFont(true)
			.SetText("Decay");
		//ctrl_lbl_decay.SetPreferredWidth(40);
		
		ctrl_slider_decay = new EchoChamberSlider("statement_lens_decay")
			.SetTooltip("Heat decay rate (0 = none, higher = faster fade).")
			.SetRange(0, 0.95)
			.BindValue(_v, "heat_decay_rate");
		//ctrl_slider_decay.SetPreferredWidth(110);
		
		ctrl_btn_search = new EchoChamberButton("statement_lens_search")
			.SetLabel("Search")
			.SetTooltip("Search states in this machine.")
			.OnClick(method(_self, function() {
				self.__OpenSearch();
			}));
		//ctrl_btn_search.SetPreferredWidth(70);
		
		// Add controls in a sensible order for the toolbar.
		toolbar_panel.AddControl(ctrl_picker);
		toolbar_panel.AddControl(ctrl_btn_up);
		toolbar_panel.AddControl(ctrl_toggle_instances);
		toolbar_panel.AddControl(ctrl_toggle_structs);
		toolbar_panel.AddControl(ctrl_toggle_active);
		toolbar_panel.AddControl(ctrl_dd_mode);
		toolbar_panel.AddControl(ctrl_dd_overlay);
		toolbar_panel.AddControl(ctrl_toggle_names);
		toolbar_panel.AddControl(ctrl_menu_edges);
		toolbar_panel.AddControl(ctrl_dd_edge_scope);
		toolbar_panel.AddControl(ctrl_btn_bookmarks);
		toolbar_panel.AddControl(ctrl_btn_pause);
		toolbar_panel.AddControl(ctrl_btn_step);
		toolbar_panel.AddControl(ctrl_toggle_force);
		toolbar_panel.AddControl(ctrl_toggle_break);
		toolbar_panel.AddControl(ctrl_toggle_cam_lock);
		toolbar_panel.AddControl(ctrl_btn_center);
		toolbar_panel.AddControl(ctrl_btn_options);
		toolbar_panel.AddControl(ctrl_btn_search);
		toolbar_panel.AddControl(ctrl_lbl_decay);
		toolbar_panel.AddControl(ctrl_slider_decay);
		
		toolbar_panel.content_draw = method(self, __SyncToolbarFromVisualiser);
		
		content_panel = new EchoChamberPanel("statement_lens_content", eEchoChamberDock.FILL);
		content_panel.padding = 0;
		content_panel.gap = 0;
		content_panel.flow = "row";
		content_panel.SetPanelStyleKey("panel");
		
		graph_panel = new EchoChamberPanel("statement_lens_graph", eEchoChamberDock.FILL);
		graph_panel.padding = 0;
		graph_panel.gap = 0;
		graph_panel.SetPanelStyleKey("panel");
		
		info_panel = new EchoChamberPanel("statement_lens_info", eEchoChamberDock.RIGHT);
		info_panel.SetSizeMode(eEchoChamberPanelSizeMode.FIXED);
		info_panel.size = 320;
		info_panel.collapse_mode = eEchoChamberCollapse.TO_RIGHT;
		info_panel.SetPanelStyleKey("panel");

		info_list = new EchoChamberListView("statement_lens_info_list");
		if (is_instanceof(root, EchoChamberRoot)) {
			info_list.SetRowHeight(max(14, root.default_row_height));
		}
		info_list.SetCountGetter(method(_self, function() {
			var _vis = StatementLensGet();
			if (!is_struct(_vis)) {
				return 0;
			}
			return array_length(_vis.info_lines);
		}));
		info_list.SetRowDrawer(method(_self, function(_index, _rect, _is_selected, _is_hover) {
			var _vis = StatementLensGet();
			if (!is_struct(_vis)) {
				return;
			}
			var _lines = _vis.info_lines;
			if (!is_array(_lines)) {
				return;
			}
			if (_index < 0 || _index >= array_length(_lines)) {
				return;
			}

			var _line = _lines[_index];
			var _meta = _vis.info_line_meta;
			var _m = is_array(_meta) ? _meta[_index] : undefined;

			if (_is_hover && is_struct(_m)) {
				if (_m.kind == "history") {
					_vis.history_hover_from_name = _m.from_name;
					_vis.history_hover_to_name   = _m.to_name;
					_vis.history_hover_tick      = _m.tick;
				}
			}

			var _theme = _vis.ui_theme;
			if (!is_instanceof(_theme, EchoChamberTheme)) {
				_theme = is_instanceof(root, EchoChamberRoot) ? root.theme : undefined;
			}

			var _use_small = is_struct(_m) && ((_m[$ "small"] ?? false) == true);
			var _use_muted = _use_small;

			var _old_font = draw_get_font();
			if (is_struct(_theme)) {
				if (_use_small) {
					draw_set_font(_theme.font_small);
				}
				else {
					draw_set_font(_theme.font_body);
				}
				if (_use_muted) {
					draw_set_color(_theme.col_muted);
				}
				else {
					draw_set_color(_theme.col_text);
				}
			}

			var _font = draw_get_font();
			var _max_w = max(0, _rect.x2 - _rect.x1);
			var _draw_str = __TrimTextToWidth(string(_line), _max_w, _font);
			var _text_h = string_height(_draw_str);
			var _ty = _rect.y1 + ((_rect.y2 - _rect.y1) - _text_h) * 0.5;
			draw_text(_rect.x1, _ty, _draw_str);
			draw_set_font(_old_font);
		}));
		info_list.SetOnSelect(method(_self, function(_index) {
			var _vis = StatementLensGet();
			if (!is_struct(_vis)) {
				return;
			}
			var _meta = _vis.info_line_meta;
			if (!is_array(_meta)) {
				return;
			}
			if (_index < 0 || _index >= array_length(_meta)) {
				return;
			}
			var _m = _meta[_index];
			if (!is_struct(_m)) {
				return;
			}
			if (_m.kind != "history") {
				return;
			}
			_vis.__CenterCameraOnHistoryEdge(_m.from_name, _m.to_name);
		}));
		
		graph_panel.content_draw = method(self, __DrawGraphPanel);
		info_panel.content_draw  = method(self, __DrawInfoPanel);
		
		content_panel.AddChildPanel(graph_panel);
		content_panel.AddChildPanel(info_panel);
		
		// Replace any existing panels with the same IDs if already present.
		win.panels = [];
		win.AddPanel(toolbar_panel);
		win.AddPanel(content_panel);
	};

	/// @ignore
	static __BindInputDefaults = function() {
		if (!is_instanceof(root, EchoChamberRoot)) {
			return;
		}
		var _ctx = root.CreateInputContext(input_context_id);
		if (!is_instanceof(_ctx, EchoChamberInputContext)) {
			return;
		}

		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_CLOSE_INSPECTOR))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_CLOSE_INSPECTOR, STATEMENT_LENS_BIND_CLOSE_INSPECTOR);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_PREV_MACHINE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_PREV_MACHINE, STATEMENT_LENS_BIND_PREV_MACHINE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_NEXT_MACHINE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_NEXT_MACHINE, STATEMENT_LENS_BIND_NEXT_MACHINE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_TOGGLE_MODE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_TOGGLE_MODE, STATEMENT_LENS_BIND_TOGGLE_MODE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_RIGHT))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_RIGHT, STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_RIGHT);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_LEFT))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_LEFT, STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_LEFT);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_UP))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_UP, STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_UP);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_DOWN))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_DOWN, STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_DOWN);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_EGO_MODE_SELECT_STATE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_EGO_MODE_SELECT_STATE, STATEMENT_LENS_BIND_EGO_MODE_SELECT_STATE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_OPEN_SEARCH_PALETTE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_OPEN_SEARCH_PALETTE, STATEMENT_LENS_BIND_OPEN_SEARCH_PALETTE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_CLOSE_SEARCH_PALETTE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_CLOSE_SEARCH_PALETTE, STATEMENT_LENS_BIND_CLOSE_SEARCH_PALETTE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_SCROLL_UP_SEARCH_PALETTE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_SCROLL_UP_SEARCH_PALETTE, STATEMENT_LENS_BIND_SCROLL_UP_SEARCH_PALETTE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_SCROLL_DOWN_SEARCH_PALETTE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_SCROLL_DOWN_SEARCH_PALETTE, STATEMENT_LENS_BIND_SCROLL_DOWN_SEARCH_PALETTE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_ACCEPT_SEARCH_PALETTE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_ACCEPT_SEARCH_PALETTE, STATEMENT_LENS_BIND_ACCEPT_SEARCH_PALETTE);
		}
		if (is_undefined(_ctx.GetBinding(STATEMENT_LENS_ACTION_CENTER_CAMERA_ON_STATE))) {
			_ctx.BindAction(STATEMENT_LENS_ACTION_CENTER_CAMERA_ON_STATE, STATEMENT_LENS_BIND_CENTER_CAMERA_ON_STATE);
		}
	};
	
	/// @ignore
	static __OpenSearch = function() {
		search_open = true;
		var _vis = StatementLensGet();
		if (is_struct(_vis)) {
			search_query = string(_vis.search_query);
		}
		search_selected_i = -1;
		search_scroll.scroll_y = 0;
		root.FocusTextInput(search_input.id, search_query, "Search states");
		root.SetActiveOverlayOwner("statement_lens_search_overlay");
	};
	
	/// @ignore
	static __CloseSearch = function() {
		search_open = false;
		if (!is_undefined(root.active_overlay_owner_id) && root.active_overlay_owner_id == "statement_lens_search_overlay") {
			root.ClearActiveOverlayOwner();
		}
		if (root.IsActiveTextInput(search_input.id)) {
			root.BlurTextInput(search_input.id);
		}
	};
	
	/// @ignore
	static __UpdateSearchResults = function(_vis, _graph) {
		search_results = [];
		if (!is_struct(_graph) || !is_struct(_vis)) {
			return;
		}
		
		var _q = string_lower(string(search_query));
		var _states = _graph.states;
		var _len = array_length(_states);
		
		if (string_length(_q) <= 0) {
			return;
		}
		
		for (var _i = 0; _i < _len; _i++) {
			var _st = _states[_i];
			if (!is_struct(_st) || !variable_struct_exists(_st, "name")) {
				continue;
			}
			var _name = string(_st.name);
			if (string_pos(_q, string_lower(_name)) > 0) {
				array_push(search_results, _name);
			}
		}
		
		if (array_length(search_results) <= 0) {
			search_selected_i = -1;
		}
		else if (search_selected_i < 0) {
			search_selected_i = 0;
		}
		else if (search_selected_i >= array_length(search_results)) {
			search_selected_i = array_length(search_results) - 1;
		}
	};
	
	/// @ignore
	/// @desc Make a safe-ish id fragment from a value (ASCII, no spaces).
	static __SafeId = function(_v) {
		var _s = string(_v);
		var _out = "";
		var _len = string_length(_s);
		for (var _i = 1; _i <= _len; _i++) {
			var _ch = string_char_at(_s, _i);
			var _ok = false;
			
			var _ord = ord(_ch);
			if (_ord >= ord("a") && _ord <= ord("z")) _ok = true;
			else if (_ord >= ord("A") && _ord <= ord("Z")) _ok = true;
			else if (_ord >= ord("0") && _ord <= ord("9")) _ok = true;
			else if (_ch == "_") _ok = true;
			
			if (_ok) {
				_out += _ch;
			}
			else {
				_out += "_";
			}
		}
		return _out;
	};
	
	/// @ignore
	static __CloseStateInspector = function() {
		inspect_state_open = false;
		inspect_state_name = undefined;
		if (!is_undefined(root.active_overlay_owner_id) && root.active_overlay_owner_id == "statement_lens_state_inspector") {
			root.ClearActiveOverlayOwner();
		}
	};
	
	/// @ignore
	static __CloseEdgeInspector = function() {
		inspect_edge_open = false;
		inspect_edge_from = undefined;
		inspect_edge_to   = undefined;
		if (!is_undefined(root.active_overlay_owner_id) && root.active_overlay_owner_id == "statement_lens_edge_inspector") {
			root.ClearActiveOverlayOwner();
		}
	};
	
	/// @ignore
	static __DistancePointSegmentSq = function(_px, _py, _ax, _ay, _bx, _by) {
		var _abx = _bx - _ax;
		var _aby = _by - _ay;
		var _apx = _px - _ax;
		var _apy = _py - _ay;
		var _den = (_abx * _abx + _aby * _aby);
		if (_den <= 0) {
			var _dx0 = _px - _ax;
			var _dy0 = _py - _ay;
			return _dx0 * _dx0 + _dy0 * _dy0;
		}
		var _t = (_apx * _abx + _apy * _aby) / _den;
		_t = clamp(_t, 0, 1);
		var _cx = _ax + _abx * _t;
		var _cy = _ay + _aby * _t;
		var _dx = _px - _cx;
		var _dy = _py - _cy;
		return _dx * _dx + _dy * _dy;
	};
	
	/// @ignore
	static __GraphHitTest = function(_vis, _graph, _rect) {
		if (!is_struct(_vis) || !is_struct(_graph) || !is_struct(_rect)) {
			return { node: undefined, edge: undefined, edge_from: undefined, edge_to: undefined };
		}
		
		var _mx = root.mx;
		var _my = root.my;
		
		if (_mx < _rect.x1 || _mx > _rect.x2 || _my < _rect.y1 || _my > _rect.y2) {
			return { node: undefined, edge: undefined, edge_from: undefined, edge_to: undefined };
		}
		
		var _w = _rect.x2 - _rect.x1;
		var _h = _rect.y2 - _rect.y1;
		var _cx = _rect.x1 + _w * 0.5;
		var _cy = _rect.y1 + _h * 0.5;
		
		var _zoom = _vis.camera_zoom;
		
		var _states = _graph.states;
		var _edges  = _graph.edges;
		
		// Node hit test (last hit wins, matches legacy behavior)
		var _node_hit = undefined;
		var _hit_r = max(_vis.node_hit_radius * _zoom, 8);
		var _hit_r_sq = _hit_r * _hit_r;
		
		var _slen = array_length(_states);
		for (var _si = 0; _si < _slen; _si++) {
			var _st = _states[_si];
			if (!is_struct(_st) || !variable_struct_exists(_st, "name")) {
				continue;
			}
			var _name = _st.name;
			if (!variable_struct_exists(_vis.node_layout, _name)) {
				continue;
			}
			var _n = _vis.node_layout[$ _name];
			
			var _nx = (_vis.mode == eStatementLensMode.EGO) ? _n.ego_x : _n.x;
			var _ny = (_vis.mode == eStatementLensMode.EGO) ? _n.ego_y : _n.y;
			
			var _sx = _cx + (_nx - _vis.camera_x) * _zoom;
			var _sy = _cy + (_ny - _vis.camera_y) * _zoom;
			
			var _dx = _mx - _sx;
			var _dy = _my - _sy;
			var _d2 = _dx * _dx + _dy * _dy;
			if (_d2 <= _hit_r_sq) {
				_node_hit = _name;
			}
		}
		
		if (!is_undefined(_node_hit)) {
			return { node: _node_hit, edge: undefined, edge_from: undefined, edge_to: undefined };
		}
		
		// Edge hit test (closest wins)
		var _best_edge = undefined;
		var _best_from = undefined;
		var _best_to   = undefined;
		var _best_d2   = -1;
		var _thresh = 7;
		var _thresh_sq = _thresh * _thresh;
		
		var _elen = array_length(_edges);
		for (var _ei = 0; _ei < _elen; _ei++) {
			var _e = _edges[_ei];
			if (!is_struct(_e) || !variable_struct_exists(_e, "from_name") || !variable_struct_exists(_e, "to_name")) {
				continue;
			}
			var _from = _e.from_name;
			var _to   = _e.to_name;
			if (!variable_struct_exists(_vis.node_layout, _from)) continue;
			if (!variable_struct_exists(_vis.node_layout, _to)) continue;
			
			var _nf = _vis.node_layout[$ _from];
			var _nt = _vis.node_layout[$ _to];
			
			var _fx = (_vis.mode == eStatementLensMode.EGO) ? _nf.ego_x : _nf.x;
			var _fy = (_vis.mode == eStatementLensMode.EGO) ? _nf.ego_y : _nf.y;
			var _tx = (_vis.mode == eStatementLensMode.EGO) ? _nt.ego_x : _nt.x;
			var _ty = (_vis.mode == eStatementLensMode.EGO) ? _nt.ego_y : _nt.y;
			
			var _sx1 = _cx + (_fx - _vis.camera_x) * _zoom;
			var _sy1 = _cy + (_fy - _vis.camera_y) * _zoom;
			var _sx2 = _cx + (_tx - _vis.camera_x) * _zoom;
			var _sy2 = _cy + (_ty - _vis.camera_y) * _zoom;
			
			var _d2 = __DistancePointSegmentSq(_mx, _my, _sx1, _sy1, _sx2, _sy2);
			if (_d2 <= _thresh_sq) {
				if (_best_d2 < 0 || _d2 < _best_d2) {
					_best_d2 = _d2;
					_best_edge = _e;
					_best_from = _from;
					_best_to   = _to;
				}
			}
		}
		
		return { node: undefined, edge: _best_edge, edge_from: _best_from, edge_to: _best_to };
	};
	
	/// @ignore
	static __MaybeOpenInspectorFromRmb = function(_root, _vis, _graph, _rect) {
		if (!_root.mouse_r_pressed || _root.mouse_consumed) {
			return;
		}
		if (!is_struct(_vis) || !is_struct(_graph)) {
			return;
		}
		if (!is_undefined(_root.active_overlay_owner_id)) {
			return;
		}
		if (!is_undefined(_root.text_focus_id)) {
			return;
		}
		
		var _hit = __GraphHitTest(_vis, _graph, _rect);
		if (!is_undefined(_hit.node)) {
			inspect_edge_open = false;
			inspect_state_open = true;
			inspect_state_name = _hit.node;
			inspect_state_anchor_x = _root.mx;
			inspect_state_anchor_y = _root.my;
			inspect_state_scroll.scroll_y = 0;
			_root.SetActiveOverlayOwner("statement_lens_state_inspector");
			_root.ConsumeMouse();
			return;
		}
		
		if (is_struct(_hit.edge) && !is_undefined(_hit.edge_from) && !is_undefined(_hit.edge_to)) {
			inspect_state_open = false;
			inspect_edge_open = true;
			inspect_edge_from = _hit.edge_from;
			inspect_edge_to   = _hit.edge_to;
			inspect_edge_anchor_x = _root.mx;
			inspect_edge_anchor_y = _root.my;
			inspect_edge_scroll.scroll_y = 0;
			_root.SetActiveOverlayOwner("statement_lens_edge_inspector");
			_root.ConsumeMouse();
			return;
		}
	};
	
	/// @ignore
	static __QueueStateInspectorOverlay = function(_root, _vis) {
		if (!inspect_state_open) {
			return;
		}
		if (!is_struct(_vis) || !is_struct(_vis.machine)) {
			__CloseStateInspector();
			return;
		}
		if (is_undefined(inspect_state_name)) {
			__CloseStateInspector();
			return;
		}
		
		var _st = _vis.machine.GetState(inspect_state_name);
		if (!is_struct(_st)) {
			__CloseStateInspector();
			return;
		}
		
		_root.SetActiveOverlayOwner("statement_lens_state_inspector");
		if (_root.__ConsumeOverlayCloseRequest("statement_lens_state_inspector")) {
			__CloseStateInspector();
			return;
		}
		
		var _w = 360;
		var _h = 420;
		var _x1 = inspect_state_anchor_x + 12;
		var _y1 = inspect_state_anchor_y + 12;
		var _gui_w = display_get_gui_width();
		var _gui_h = display_get_gui_height();
		var _x2 = min(_gui_w - 8, _x1 + _w);
		var _y2 = min(_gui_h - 8, _y1 + _h);
		_x1 = max(8, _x2 - _w);
		_y1 = max(8, _y2 - _h);
		
		var _rect = { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
		var _pad = 6;
		var _row_h = max(18, _root.default_row_height);
		var _self = self;
		var _draw = method({
			owner: _self,
			rect: _rect,
			pad: _pad,
			row_h: _row_h,
			state_name: inspect_state_name
		}, function(_r) {
			var _rect = rect;
			var _x1 = _rect.x1;
			var _y1 = _rect.y1;
			var _x2 = _rect.x2;
			var _y2 = _rect.y2;
			
			var _inside = (_r.mx >= _x1 && _r.mx <= _x2 && _r.my >= _y1 && _r.my <= _y2);
			if ((_r.mouse_l_pressed || _r.mouse_r_pressed) && !_inside && !_r.mouse_consumed) {
				owner.__CloseStateInspector();
				_r.ConsumeMouse();
				return;
			}
			
			// Panel + border
			draw_set_color(_r.theme.col_window_bg);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
			draw_set_color(_r.theme.col_accent);
			draw_rectangle(_x1, _y1, _x2, _y2, true);
			
			// Header
			var _old_font = draw_get_font();
			draw_set_font(_r.theme.font_header);
			draw_set_color(_r.theme.col_text);
			var _title = "State: " + string(state_name);
			draw_text(_x1 + pad, _y1 + pad, _title);
			var _header_height = string_height(_title);
			draw_set_font(_old_font);
			
			// Close box
			var _cx2 = _x2 - pad;
			var _cx1 = _cx2 - 18;
			var _cy1 = _y1 + pad;
			var _cy2 = _cy1 + 18;
			var _hover_close = (_r.mx >= _cx1 && _r.mx <= _cx2 && _r.my >= _cy1 && _r.my <= _cy2);
			draw_set_color(_hover_close ? _r.theme.col_hover_row : _r.theme.col_panel_bg);
			draw_rectangle(_cx1, _cy1, _cx2, _cy2, false);
			draw_set_color(_r.theme.col_accent);
			draw_rectangle(_cx1, _cy1, _cx2, _cy2, true);
			draw_set_color(_r.theme.col_text);
			draw_text(_cx1 + 6, _cy1 + 1, "X");
			if (_hover_close && _r.mouse_l_pressed && !_r.mouse_consumed) {
				owner.__CloseStateInspector();
				_r.ConsumeMouse();
				return;
			}
			
			// Body scroll area
			var _body = { x1: _x1 + pad, y1: _y1 + pad + _header_height, x2: _x2 - pad, y2: _y2 - pad };
			
			// Approx content height: base lines + transitions
			var _vis = StatementLensGet();
			var _machine = is_struct(_vis) ? _vis.machine : undefined;
			var _ins = is_struct(_machine) ? _machine.GetState(state_name) : undefined;
			var _tcount = (is_struct(_ins) && variable_struct_exists(_ins, "transitions")) ? array_length(_ins.transitions) : 0;
			var _content_h = (row_h * (20 + _tcount)) + 80;
			
			_r.DrawScrollArea(owner.inspect_state_scroll, _body, _content_h, method({
				owner,
				state_name,
				row_h
			}, function(_r2, _rr, _sy) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis) || !is_struct(_vis.machine)) {
					return;
				}
				
				var _machine = _vis.machine;
				var _ins_state = _machine.GetState(state_name);
				if (!is_struct(_ins_state)) {
					return;
				}
				
				var _x = _rr.x1;
				var _y = _rr.y1 - _sy;
				var _max_w = _rr.x2 - _rr.x1;
				
				// Stats summary (simple, non-wrapped)
				var _is_active = (is_struct(_machine.state) && _machine.state.name == state_name);
				var _is_prev = (is_struct(_machine.previous_state) && _machine.previous_state.name == state_name);
				
				var _entries = 0;
				var _frames = 0;
				var _stats = _machine.GetDebugStateStats();
				if (is_struct(_stats) && variable_struct_exists(_stats, state_name)) {
					var _s = _stats[$ state_name];
					_entries = _s.entry_count;
					_frames = _s.total_frames;
				}
				
				draw_set_font(_r2.theme.font_body);
				draw_set_color(_r2.theme.col_text);
				
				draw_text(_x, _y, "Active: " + (_is_active ? "yes" : "no")); _y += row_h;
				draw_text(_x, _y, "Previous: " + (_is_prev ? "yes" : "no")); _y += row_h;
				draw_text(_x, _y, "Entries: " + string(_entries)); _y += row_h;
				draw_text(_x, _y, "Total frames: " + string(_frames)); _y += row_h;
				
				var _template_name = _ins_state[$ "template_name"];
				if (is_string(_template_name) && string_length(_template_name) > 0) {
					draw_text(_x, _y, "Template: " + string(_template_name)); _y += row_h;
				}
				
				var _cfg_value = undefined;
				var _get_cfg = _ins_state[$ "GetConfig"];
				if (is_callable(_get_cfg)) {
					_cfg_value = _get_cfg();
				}
				else if (variable_struct_exists(_ins_state, "config")) {
					_cfg_value = _ins_state.config;
				}
				var _cfg_label = __FormatPayloadLabel(_cfg_value);
				draw_text(_x, _y, "Config: " + _cfg_label); _y += row_h;
				_y += 6;
				
				// Open submachine
				if (is_callable(_ins_state.HasSubMachine) && _ins_state.HasSubMachine()) {
					var _sub = _ins_state.GetSubMachine();
					if (is_struct(_sub)) {
						var _label = "Open submachine";
						if (variable_struct_exists(_ins_state, "submachine_name") && string_length(string(_ins_state.submachine_name)) > 0) {
							_label = "Open submachine: " + string(_ins_state.submachine_name);
						}
						var _btn = new EchoChamberButton("statement_lens_open_sub_" + owner.__SafeId(state_name))
							.SetLabel(_label)
							.OnClick(method({
										owner,
										_sub
									}, function() {
								var _vis = StatementLensGet();
								if (!is_struct(_vis)) {
									return;
								}
								if (variable_global_exists("__statement_machines")) {
									var _reg = global.__statement_machines;
									var _rlen = array_length(_reg);
									for (var _ri = 0; _ri < _rlen; _ri++) {
										var _m2 = __StatementDebugDerefMachineEntry(_reg[_ri]);
										if (is_struct(_m2) && _m2 == _sub) {
											_vis.machine_index = _ri;
											_vis.__RefreshMachine();
											_vis.__RebuildLayout();
											break;
										}
									}
								}
								owner.__CloseStateInspector();
							}));
						_btn.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
						_y += row_h + 6;
					}
				}
				
				// Tag edit
				draw_set_color(_r2.theme.col_text);
				draw_text(_x, _y, "Tag:"); _y += row_h;
				
				var _current_tag = variable_struct_exists(_ins_state, "debug_tag") ? string(_ins_state.debug_tag) : "";
				var _bind = { v: _current_tag };
				var _tag = new EchoChamberTextInput("statement_lens_state_tag_" + owner.__SafeId(state_name))
					.SetPlaceholder("tag1,tag2")
					.BindText(_bind, "v")
					.OnChange(	method({
									_ins_state
								}, function(_final) {
						_ins_state.debug_tag = string(_final);
					}));
				_tag.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
				_y += row_h + 6;
				
				// Break on enter
				var _break_flag = (_ins_state[$ "debug_break_on_enter"] == true);
				var _b = { v: _break_flag };
				var _tog_break = new EchoChamberToggle("statement_lens_break_on_enter_" + owner.__SafeId(state_name))
					.SetLabel("Break on enter")
					.BindBool(_b, "v")
					.OnChange(	method({
									_ins_state
								}, function(_v_new) {
						_ins_state.debug_break_on_enter = (_v_new == true);
					}));
				_tog_break.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
				_y += row_h + 2;
				
				// Can exit
				var _ce = { v: (_ins_state.can_exit == true) };
				var _tog_ce = new EchoChamberToggle("statement_lens_can_exit_" + owner.__SafeId(state_name))
					.SetLabel("Can exit")
					.BindBool(_ce, "v")
					.OnChange(	method({
									_ins_state
								}, function(_v_new) {
						_ins_state.can_exit = (_v_new == true);
					}));
				_tog_ce.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
				_y += row_h + 8;
				
				// Transitions
				if (variable_struct_exists(_ins_state, "transitions")) {
					draw_set_color(_r2.theme.col_text);
					draw_text(_x, _y, "Transitions:"); _y += row_h;
					
					var _transitions = _ins_state.transitions;
					var _tlen = array_length(_transitions);
					
					for (var _ti = 0; _ti < _tlen; _ti++) {
						var _tr = _transitions[_ti];
						if (!is_struct(_tr) || !variable_struct_exists(_tr, "target_name")) {
							continue;
						}
						var _target = _tr.target_name;
						
						var _line_y1 = _y;
						draw_set_color(_r2.theme.col_text);
						draw_text(_x + 4, _line_y1 + 3, "-> " + string(_target));
						
						var _edge = _machine.__DebugGetOrCreateEdge(_ins_state.name, _target, eStatementDebugEdgeKind.DECLARATIVE);
						var _break_edge = (is_struct(_edge) && _edge[$ "debug_break_on_transition"] == true);
						
						var _bw = 72;
						var _fw = 72;
						var _x2 = _rr.x2;
						
						// Force
						var _force = (_tr.force == true);
						var _bf = { v: _force };
						var _tog_force = new EchoChamberToggle("statement_lens_tr_force_" + owner.__SafeId(state_name) + "_" + string(_ti))
							.SetLabel("Force")
							.BindBool(_bf, "v")
							.OnChange(	method({
									_tr, _transitions, _ti
								}, function(_v_new) {
								_tr.force = (_v_new == true);
								_transitions[_ti] = _tr;
							}));
						_tog_force.SetPreferredWidth(_fw);
						_tog_force.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x2 - _fw, y1: _line_y1, x2: _x2, y2: _line_y1 + row_h });
						
						// Break (edge)
						var _bb = { v: _break_edge };
						var _tog_bedge = new EchoChamberToggle("statement_lens_tr_break_" + owner.__SafeId(state_name) + "_" + string(_ti))
							.SetLabel("Break")
							.BindBool(_bb, "v")
							.OnChange(	method({
									_edge
								}, function(_v_new) {
								if (is_struct(_edge)) {
									_edge.debug_break_on_transition = (_v_new == true);
								}
							}));
						_tog_bedge.SetPreferredWidth(_bw);
						_tog_bedge.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x2 - _fw - 4 - _bw, y1: _line_y1, x2: _x2 - _fw - 4, y2: _line_y1 + row_h });
						
						_y += row_h + 2;
					}
				}
			}));
			
			if (_inside && !_r.mouse_consumed) {
				_r.ConsumeMouse();
			}
		});
		
		_root.QueueOverlay("statement_lens_state_inspector", _draw, _rect, win);
	};
	
	/// @ignore
	static __QueueEdgeInspectorOverlay = function(_root, _vis) {
		if (!inspect_edge_open) {
			return;
		}
		if (!is_struct(_vis) || !is_struct(_vis.machine)) {
			__CloseEdgeInspector();
			return;
		}
		if (is_undefined(inspect_edge_from) || is_undefined(inspect_edge_to)) {
			__CloseEdgeInspector();
			return;
		}
		
		_root.SetActiveOverlayOwner("statement_lens_edge_inspector");
		if (_root.__ConsumeOverlayCloseRequest("statement_lens_edge_inspector")) {
			__CloseEdgeInspector();
			return;
		}
		
		var _w = 360;
		var _h = 300;
		var _x1 = inspect_edge_anchor_x + 12;
		var _y1 = inspect_edge_anchor_y + 12;
		var _gui_w = display_get_gui_width();
		var _gui_h = display_get_gui_height();
		var _x2 = min(_gui_w - 8, _x1 + _w);
		var _y2 = min(_gui_h - 8, _y1 + _h);
		_x1 = max(8, _x2 - _w);
		_y1 = max(8, _y2 - _h);
		
		var _rect = { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
		var _pad = 6;
		var _row_h = max(18, _root.default_row_height);
		
		var _from_name = inspect_edge_from;
		var _to_name   = inspect_edge_to;
		
		var _self = self;
		var _draw = method({
			owner: _self,
			rect: _rect,
			pad: _pad,
			row_h: _row_h,
			from_name: _from_name,
			to_name: _to_name
		}, function(_r) {
			var _rect = rect;
			var _x1 = _rect.x1;
			var _y1 = _rect.y1;
			var _x2 = _rect.x2;
			var _y2 = _rect.y2;
			
			var _inside = (_r.mx >= _x1 && _r.mx <= _x2 && _r.my >= _y1 && _r.my <= _y2);
			if ((_r.mouse_l_pressed || _r.mouse_r_pressed) && !_inside && !_r.mouse_consumed) {
				owner.__CloseEdgeInspector();
				_r.ConsumeMouse();
				return;
			}
			
			draw_set_color(_r.theme.col_window_bg);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
			draw_set_color(_r.theme.col_accent);
			draw_rectangle(_x1, _y1, _x2, _y2, true);
			
			var _old_font = draw_get_font();
			draw_set_font(_r.theme.font_header);
			draw_set_color(_r.theme.col_text);
			draw_text(_x1 + pad, _y1 + pad, "Edge");
			var _header_height = string_height("Edge");
			draw_set_font(_old_font);
			
			var _body = { x1: _x1 + pad, y1: _y1 + pad + _header_height, x2: _x2 - pad, y2: _y2 - pad };
			var _content_h = 900;
			
			_r.DrawScrollArea(owner.inspect_edge_scroll, _body, _content_h, method({
				owner,
				from_name,
				to_name,
				row_h
			}, function(_r2, _rr, _sy) {
				var _vis = StatementLensGet();
				if (!is_struct(_vis) || !is_struct(_vis.machine)) {
					return;
				}
				
				var _m = _vis.machine;
				var _g = _m.GetDebugGraph();
				if (is_undefined(_g)) {
					return;
				}
				
				// Find the edge struct for current graph (may be rebuilt)
				var _edge = undefined;
				var _edges = _g.edges;
				var _elen = array_length(_edges);
				for (var _ei = 0; _ei < _elen; _ei++) {
					var _e = _edges[_ei];
					if (!is_struct(_e)) continue;
					if (_e.from_name == from_name && _e.to_name == to_name) {
						_edge = _e;
						break;
					}
				}
				
				var _x = _rr.x1;
				var _y = _rr.y1 - _sy;
				
				draw_set_font(_r2.theme.font_body);
				draw_set_color(_r2.theme.col_text);
				
				draw_text(_x, _y, string(from_name) + " -> " + string(to_name)); _y += row_h + 4;
				
				if (!is_struct(_edge)) {
					draw_set_color(_r2.theme.col_muted);
					draw_text(_x, _y, "(edge not found)"); 
					return;
				}
				
				var _kind_val = variable_struct_exists(_edge, "kind") ? _edge.kind : eStatementDebugEdgeKind.DECLARATIVE;
				draw_text(_x, _y, "Kind: " + _vis.__EdgeKindToString(_kind_val)); _y += row_h;
				var _hits = variable_struct_exists(_edge, "hits") ? _edge.hits : 0;
				draw_text(_x, _y, "Hits: " + string(_hits)); _y += row_h;
				
				var _break_flag = (_edge[$ "debug_break_on_transition"] == true);
				var _b = { v: _break_flag };
				var _tog = new EchoChamberToggle("statement_lens_edge_break_" + owner.__SafeId(from_name) + "_" + owner.__SafeId(to_name))
					.SetLabel("Break on transition")
					.BindBool(_b, "v")
					.OnChange(method({ _edge }, function(_v_new) {
						_edge.debug_break_on_transition = (_v_new == true);
					}));
				_tog.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
				_y += row_h + 6;
				
				// Declarative transition force (if we can find it)
				if (_kind_val == eStatementDebugEdgeKind.DECLARATIVE) {
					var _from_state = _m.GetState(from_name);
					if (is_struct(_from_state) && variable_struct_exists(_from_state, "transitions")) {
						var _trs = _from_state.transitions;
						var _tlen = array_length(_trs);
						for (var _ti = 0; _ti < _tlen; _ti++) {
							var _tr = _trs[_ti];
							if (!is_struct(_tr)) continue;
							if (_tr.target_name != to_name) continue;
							
							var _force = (_tr.force == true);
							var _bf = { v: _force };
							var _tog_force = new EchoChamberToggle("statement_lens_edge_force_" + owner.__SafeId(from_name) + "_" + owner.__SafeId(to_name))
								.SetLabel("Force (declared)")
								.BindBool(_bf, "v")
								.OnChange(	method({
												_tr, _trs, _ti
											},function(_v_new) {
									_tr.force = (_v_new == true);
									_trs[_ti] = _tr;
								}));
							_tog_force.ProcessAndDraw(_r2, owner.overlay_panel, { x1: _x, y1: _y, x2: _rr.x2, y2: _y + row_h });
							break;
						}
					}
				}
				
				// Last error (if present)
				var _err_tick = variable_struct_exists(_edge, "last_error_tick") ? _edge.last_error_tick : 0;
				var _err_msg  = variable_struct_exists(_edge, "last_error_message") ? string(_edge.last_error_message) : "";
				if (_err_tick > 0 || string_length(_err_msg) > 0) {
					_y += row_h;
					draw_set_color(_r2.theme.col_text);
					draw_text(_x, _y, "Last error tick: " + string(_err_tick)); _y += row_h;
					draw_set_color(_r2.theme.col_muted);
					draw_text(_x, _y, _err_msg);
				}
			}));
			
			if (_inside && !_r.mouse_consumed) {
				_r.ConsumeMouse();
			}
		});
		
		_root.QueueOverlay("statement_lens_edge_inspector", _draw, _rect, win);
	};
	
	/// @ignore
	static __QueueSearchOverlay = function(_root, _vis) {
		if (!search_open) {
			return;
		}
		if (!is_struct(last_graph_rect)) {
			return;
		}
		if (!is_struct(_vis) || !is_struct(_vis.machine)) {
			return;
		}
		
		var _graph = _vis.machine.GetDebugGraph();
		if (is_undefined(_graph)) {
			return;
		}
		
		_root.SetActiveOverlayOwner("statement_lens_search_overlay");
		if (_root.__ConsumeOverlayCloseRequest("statement_lens_search_overlay")) {
			__CloseSearch();
			return;
		}
		
		// Live query while focused
		if (_root.IsActiveTextInput(search_input.id)) {
			search_query = _root.GetActiveText();
		}
		
		__UpdateSearchResults(_vis, _graph);
		
		var _pad = 6;
		var _row_h = max(18, _root.default_row_height);
		var _max_rows = 8;
		var _count = array_length(search_results);
		var _rows = min(_count, _max_rows);
		
		var _w = 320;
		var _h = (_row_h * 2) + (_row_h * _rows) + (_pad * 2);
		var _x1 = last_graph_rect.x1 + 8;
		var _y1 = last_graph_rect.y1 + 8;
		var _x2 = min(last_graph_rect.x2 - 8, _x1 + _w);
		var _y2 = min(last_graph_rect.y2 - 8, _y1 + _h);
		var _rect = { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
		
		var _self = self;
		var _draw = method({
			owner: _self,
			root: _root,
			rect: _rect,
			pad: _pad,
			_row_h
		}, function(_r) {
			var _rect = rect;
			var _pad = pad;
			var _x1 = _rect.x1;
			var _y1 = _rect.y1;
			var _x2 = _rect.x2;
			var _y2 = _rect.y2;
			
			// Click-out close
			var _inside = (_r.mx >= _x1 && _r.mx <= _x2 && _r.my >= _y1 && _r.my <= _y2);
			if ((_r.mouse_l_pressed || _r.mouse_r_pressed) && !_inside && !_r.mouse_consumed) {
				owner.__CloseSearch();
				_r.ConsumeMouse();
				return;
			}
			
			// Panel
			draw_set_color(_r.theme.col_window_bg);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
			draw_set_color(_r.theme.col_accent);
			draw_rectangle(_x1, _y1, _x2, _y2, true);
			
			// Title
			var _old_font = draw_get_font();
			draw_set_font(_r.theme.font_body);
			draw_set_color(_r.theme.col_text);
			draw_text(_x1 + _pad, _y1 + _pad, "Search state:");
			
			// Search input control
			var _input_rect = { x1: _x1 + _pad, y1: _y1 + _pad + _row_h, x2: _x2 - _pad, y2: _y1 + _pad + _row_h * 2 };
			owner.search_input
				.SetPlaceholder("type to search")
				.BindText(owner, "search_query")
				.OnChange(method({ owner }, function(_final) {
					owner.search_query = string(_final);
				}));
			owner.search_input.ProcessAndDraw(_r, owner.overlay_panel, _input_rect);
			
			// Results list
			var _list_rect = { x1: _x1 + _pad, y1: _input_rect.y2 + 4, x2: _x2 - _pad, y2: _y2 - _pad };
			
			var _content_h = _row_h * max(1, array_length(owner.search_results));
			_r.DrawScrollArea(owner.search_scroll, _list_rect, _content_h, method({ owner, _row_h }, function(_r2, _rr, _sy) {
				var _start = floor(_sy / _row_h);
				var _off = _sy - (_start * _row_h);
				var _visible = ceil((_rr.y2 - _rr.y1 + _off) / _row_h) + 1;
				var _end = min(array_length(owner.search_results), _start + _visible);
				
				for (var _i = _start; _i < _end; _i++) {
					var _ry1 = _rr.y1 + (_row_h * (_i - _start)) - _off;
					var _ry2 = _ry1 + _row_h;
					var _hover = (_r2.mx >= _rr.x1 && _r2.mx <= _rr.x2 && _r2.my >= _ry1 && _r2.my <= _ry2);
					var _sel = (_i == owner.search_selected_i);
					
					var _bg = _r2.theme.col_panel_bg;
					if (_sel) _bg = _r2.theme.col_hover_row_alt;
					if (_hover) _bg = _r2.theme.col_hover_row;
					draw_set_color(_bg);
					draw_rectangle(_rr.x1, _ry1, _rr.x2, _ry2, false);
					
					draw_set_color(_r2.theme.col_text);
					var _name = string(owner.search_results[_i]);
					draw_text(_rr.x1 + 4, _ry1 + max(0, (_row_h - string_height(_name)) * 0.5), _name);
					
					if (_hover && _r2.mouse_l_pressed && !_r2.mouse_consumed) {
						owner.search_selected_i = _i;
						owner.__AcceptSearchSelection();
						_r2.ConsumeMouse();
					}
				}
			}));
			
			draw_set_font(_old_font);
			
			// Consume mouse inside overlay
			if (_inside && !_r.mouse_consumed) {
				_r.ConsumeMouse();
			}
		});
		
		_root.QueueOverlay("statement_lens_search_overlay", _draw, _rect, win);
		
		// Keyboard navigation
		var _rc = array_length(search_results);
		if (_rc > 0) {
			if (STATEMENT_LENS_INPUT_SCROLL_UP_SEARCH_PALETTE) {
				search_selected_i--;
				if (search_selected_i < 0) search_selected_i = _rc - 1;
			}
			if (STATEMENT_LENS_INPUT_SCROLL_DOWN_SEARCH_PALETTE) {
				search_selected_i++;
				if (search_selected_i >= _rc) search_selected_i = 0;
			}
			if (STATEMENT_LENS_INPUT_ACCEPT_SEARCH_PALETTE) {
				__AcceptSearchSelection();
			}
		}
	};
	
	/// @ignore
	static __AcceptSearchSelection = function() {
		var _vis = StatementLensGet();
		if (!is_struct(_vis) || !is_struct(_vis.machine)) {
			return;
		}
		if (search_selected_i < 0 || search_selected_i >= array_length(search_results)) {
			return;
		}
		
		var _name = search_results[search_selected_i];
		_vis.search_focus_state_name = _name;
		
		// Ensure full layout for global view if needed.
		if (_vis.mode == eStatementLensMode.EGO) {
			_vis.__SetMode(eStatementLensMode.FULL);
		}
		
		if (variable_struct_exists(_vis.node_layout, _name)) {
			var _node = _vis.node_layout[$ _name];
			_vis.target_camera_x = _node.x;
			_vis.target_camera_y = _node.y;
			_vis.camera_manual_override = true;
		}
	};
	
	/// @ignore
	static __SyncToolbarFromVisualiser = function(_root, _rect) {
		var _vis = StatementLensGet();
		if (!is_struct(_vis)) {
			return;
		}
		if (!variable_global_exists("__statement_debug_pause_all")) {
			global.__statement_debug_pause_all = false;
		}
		
		// Sync dropdown indices from current visualiser state.
		var _mi = 0;
		switch (_vis.mode) {
			case eStatementLensMode.FULL: _mi = 0; break;
			case eStatementLensMode.RADIAL: _mi = 1; break;
			case eStatementLensMode.CLOUD: _mi = 2; break;
			default: _mi = 3; break;
		}
		state.mode_index = _mi;
		
		var _oi = 0;
		if (_vis.overlay_mode == eStatementLensOverlay.HEATMAP) {
			_oi = (_vis.heat_metric == eStatementHeatMetric.VISITS) ? 2 : 1;
		}
		state.overlay_index = _oi;
		
		var _si = 0;
		if (_vis.edge_filter_active_only) {
			_si = 1;
		}
		else if (_vis.edge_filter_recent_ticks == 50) {
			_si = 2;
		}
		else if (_vis.edge_filter_recent_ticks == 500) {
			_si = 3;
		}
		else if (_vis.edge_filter_recent_ticks == 5000) {
			_si = 4;
		}
		state.edge_scope_index = _si;
		
		// Break toggle reflects active state's flag (if any).
		var _bp = false;
		if (is_struct(_vis.machine) && is_struct(_vis.machine.state)) {
			var _st = _vis.machine.state;
			_bp = (_st[$ "debug_break_on_enter"] == true);
		}
		state.break_on_enter = _bp;
		
		// Pause button label should reflect current machine state (and global pause-all).
		if (is_struct(ctrl_btn_pause)) {
			var _pause_all_flag = (variable_global_exists("__statement_debug_pause_all") ? global.__statement_debug_pause_all : false);
			var _is_paused = false;
			if (is_struct(_vis.machine)) {
				_is_paused = _vis.machine.paused || _pause_all_flag;
			}
			ctrl_btn_pause.label = _is_paused ? "Resume" : "Pause";
		}
		
		// Up button is only meaningful on submachines.
		if (is_struct(ctrl_btn_up)) {
			var _can_up = is_struct(_vis.machine) && variable_struct_exists(_vis.machine, "parent_machine") && is_struct(_vis.machine.parent_machine);
			ctrl_btn_up.visible = (_can_up == true);
		}
		
		// Heat decay controls visible only for heatmap.
		var _show_decay = (_vis.overlay_mode == eStatementLensOverlay.HEATMAP);
		if (is_struct(ctrl_lbl_decay)) ctrl_lbl_decay.visible = _show_decay;
		if (is_struct(ctrl_slider_decay)) ctrl_slider_decay.visible = _show_decay;
	};
	
	/// @ignore
	static __BeginSharedDraw = function() {
		var _v = StatementLensGet();
		if (!is_struct(_v)) {
			return undefined;
		}
			
		// Reset per-frame caches once.
		if (__draw_stamp != current_time) {
			__draw_stamp = current_time;
				
			_v.__Update();
				
			if (!is_undefined(_v.machine)) {
				_v.history_records = _v.machine.GetDebugTransitionHistory();
				if (is_undefined(_v.history_records)) {
					_v.history_records = [];
				}
			}
			else {
				_v.history_records = [];
			}

			_v.__BuildInfoLines(_v.last_graph);
				
			_v.history_hover_from_name = undefined;
			_v.history_hover_to_name   = undefined;
			_v.history_hover_tick      = -1;
		}
		
		return _v;
	};
	
	/// @ignore
	static __DrawGraphPanel = function(_root, _rect) {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		var _v = __BeginSharedDraw();
		if (!is_struct(_v)) {
			return;
		}
		if (is_undefined(_v.machine)) {
			return;
		}
		
		var _graph = _v.machine.GetDebugGraph();
		if (is_undefined(_graph)) {
			return;
		}
		
		last_graph_rect = _rect;
		
		// ---------------------------------------------------------------------
		// Graph camera input (Echo input snapshot)
		// ---------------------------------------------------------------------
		var _over_graph = _root.HitTestRect(_rect.x1, _rect.y1, _rect.x2, _rect.y2);
			var _focus_block = (!is_undefined(_root.text_focus_id));
		var _overlay_block = (!is_undefined(_root.active_overlay_owner_id) || _root.IsContextMenuOpen());

		if (search_open && STATEMENT_LENS_INPUT_CLOSE_SEARCH_PALETTE) {
			__CloseSearch();
		}
		if ((inspect_state_open || inspect_edge_open) && STATEMENT_LENS_INPUT_CLOSE_INSPECTOR) {
			__CloseStateInspector();
			__CloseEdgeInspector();
		}
		
		// Recenter on active state (keyboard driven)
		if (!_focus_block && !_overlay_block) {
			if (STATEMENT_LENS_INPUT_PREV_MACHINE) {
				_v.__PrevMachine();
			}
			if (STATEMENT_LENS_INPUT_NEXT_MACHINE) {
				_v.__NextMachine();
			}
			if (STATEMENT_LENS_INPUT_TOGGLE_MODE) {
				_v.__ToggleMode();
			}
			if (!search_open && STATEMENT_LENS_INPUT_OPEN_SEARCH_PALETTE) {
				__OpenSearch();
			}
			if (STATEMENT_LENS_INPUT_CENTER_CAMERA_ON_STATE) {
				_v.camera_manual_override = false;
				_v.__CenterCameraOnActive(true);
			}
		}
		
		// Mouse wheel zoom
		if (_over_graph && !_overlay_block && !_focus_block && !_root.wheel_consumed && _root.wheel_delta != 0) {
			_v.camera_manual_override = true;
			var _old_zoom = _v.target_camera_zoom;
			var _zoom_mul = 1 + _v.camera_zoom_step * _root.wheel_delta;
			_v.target_camera_zoom = clamp(_old_zoom * _zoom_mul, _v.camera_zoom_min, _v.camera_zoom_max);
			_root.ConsumeWheel();
		}
		
		// Middle mouse drag to pan camera
		if (_over_graph && !_overlay_block && !_focus_block && !_root.mouse_consumed && _root.mouse_m_pressed) {
			_v.is_dragging_camera        = true;
			_v.camera_manual_override    = true;
			_v.drag_camera_start_mouse_x = _root.mx;
			_v.drag_camera_start_mouse_y = _root.my;
			_v.drag_camera_start_x       = _v.target_camera_x;
			_v.drag_camera_start_y       = _v.target_camera_y;
			_root.ConsumeMouse();
		}
		
		if (_v.is_dragging_camera) {
			if (!_root.mouse_m_down) {
				_v.is_dragging_camera = false;
			}
			else {
				var _dx_pixels = _root.mx - _v.drag_camera_start_mouse_x;
				var _dy_pixels = _root.my - _v.drag_camera_start_mouse_y;
				
				_v.target_camera_x = _v.drag_camera_start_x - (_dx_pixels / max(0.0001, _v.camera_zoom)) * 0.5;
				_v.target_camera_y = _v.drag_camera_start_y - (_dy_pixels / max(0.0001, _v.camera_zoom)) * 0.5;
				_root.ConsumeMouse();
			}
		}
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var _w = max(0, _rect.x2 - _rect.x1);
		var _h = max(0, _rect.y2 - _rect.y1);
		
		var _allow_input = _over_graph && !_overlay_block && !_focus_block && !_root.mouse_consumed;
		
		// RMB inspectors should open before node click logic.
		__MaybeOpenInspectorFromRmb(_root, _v, _graph, _rect);
		_allow_input = _allow_input && !_root.mouse_consumed;
		
		var _clicked_name = undefined;
		if (_v.mode == eStatementLensMode.EGO) {
			_clicked_name = _v.__DrawEgoGraph(_graph, _rect.x1, _rect.y1, _w, _h, _allow_input, _root);
		}
		else {
			_clicked_name = _v.__DrawFullGraph(_graph, _rect.x1, _rect.y1, _w, _h, _allow_input, _root);
		}
		
		// Handle click-to-jump for graph nodes.
		if (!is_undefined(_clicked_name) && _allow_input && _v.allow_click_to_jump) {
			_v.machine.DebugJumpToState(_clicked_name, _v.force_transitions);
			if (_v.lock_to_active) {
				_v.__CenterCameraOnActive();
			}
		}
		
		// If a history row is hovered in the info panel, overlay a highlight on the graph.
		if (!is_undefined(_v.history_hover_from_name) && !is_undefined(_v.history_hover_to_name)) {
			_v.__DrawHistoryHoverOverlay(_rect.x1, _rect.y1, _w, _h);
		}
		
		// ---------------------------------------------------------------------
		// PAUSED banner (and RESUMED fade-out)
		// ---------------------------------------------------------------------
		if (!variable_global_exists("__statement_debug_pause_all")) {
			global.__statement_debug_pause_all = false;
		}
		var _pause_all_flag = global.__statement_debug_pause_all;
		var _is_paused = (_v.machine.paused || _pause_all_flag);
		
		var _banner_text = undefined;
		var _banner_alpha = 0;
		if (_is_paused) {
			_banner_text = "STATE MACHINE PAUSED";
			_banner_alpha = 1;
			_v.pause_banner_resumed_time_ms = -1;
		}
		else if (_v.pause_banner_resumed_time_ms >= 0) {
			var _elapsed = current_time - _v.pause_banner_resumed_time_ms;
			if (_elapsed < (_v.pause_banner_resumed_hold_ms + _v.pause_banner_resumed_fade_ms)) {
				_banner_text = "STATE MACHINE RESUMED";
				if (_elapsed <= _v.pause_banner_resumed_hold_ms) {
					_banner_alpha = 1;
				}
				else {
					_banner_alpha = 1 - ((_elapsed - _v.pause_banner_resumed_hold_ms) / max(1, _v.pause_banner_resumed_fade_ms));
				}
			}
			else {
				_v.pause_banner_resumed_time_ms = -1;
			}
		}
		
		if (!is_undefined(_banner_text) && _banner_alpha > 0) {
			var _banner_h = max(22, _root.theme.row_header_h);
			var _bx1 = _rect.x1;
			var _by1 = _rect.y1;
			var _bx2 = _rect.x2;
			var _by2 = min(_rect.y2, _by1 + _banner_h);
			
			var _old_alpha = draw_get_alpha();
			var _old_font = draw_get_font();
			var _old_halign = draw_get_halign();
			var _old_valign = draw_get_valign();
			
			// Background (semi-transparent white)
			draw_set_alpha(0.65 * _banner_alpha);
			draw_set_color(c_white);
			draw_rectangle(_bx1, _by1, _bx2, _by2, false);
			
			// Text (black, centered)
			draw_set_alpha(1 * _banner_alpha);
			draw_set_color(c_black);
			draw_set_font(_root.theme.font_header);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text((_bx1 + _bx2) * 0.5, (_by1 + _by2) * 0.5, _banner_text);
			
			draw_set_alpha(_old_alpha);
			draw_set_color(c_white);
			draw_set_font(_old_font);
			draw_set_halign(_old_halign);
			draw_set_valign(_old_valign);
		}
		
		// Queue overlays anchored to the graph panel.
		__QueueSearchOverlay(_root, _v);
		__QueueStateInspectorOverlay(_root, _v);
		__QueueEdgeInspectorOverlay(_root, _v);
	};
	
	/// @ignore
	static __DrawInfoPanel = function(_root, _rect) {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		var _v = __BeginSharedDraw();
		if (!is_struct(_v)) {
			return;
		}
		if (is_undefined(_v.machine)) {
			return;
		}

		if (!is_instanceof(info_list, EchoChamberListView)) {
			return;
		}

		info_list.ProcessAndDraw(_root, info_panel, _rect);
		};
		
	/// @ignore
	/// @desc Show the Statement Lens window and bring it to the front.
	/// @return {Struct.EchoChamberWindow,Undefined}
	static __Open = function() {
		__EnsureBuilt();
		if (!is_struct(win)) {
			return undefined;
		}
		
		win.visible = true;
		root.BringWindowToFront(win);
		return win;
	};
}

/// @ignore
/// @desc Internal helper: turn a registry entry into a live Statement machine or undefined.
function __StatementDebugDerefMachineEntry(_entry) {
	if (!is_struct(_entry)) {
		return undefined;
	}
	
	// weakref wrapper -> resolve to its target, without keeping it alive
	if (instanceof(_entry) == "weakref") {
		if (weak_ref_alive(_entry) == true) {
			var _m = _entry.ref;
			return is_struct(_m) ? _m : undefined;
		}
		return undefined;
	}
	
	// Otherwise treat the entry itself as the machine (legacy direct refs)
	return _entry;
}

/// @func StatementDebugPruneRegistry()
/// @desc Removes dead entries from the global Statement debug registry.
///       Optionally, can also remove machines whose owner instance has been destroyed.
/// @return {Real} Number of entries removed.
function StatementDebugPruneRegistry(_prune_destroyed_owners = false) {
	if (!STATEMENT_DEBUG) {
		return 0;
	}
	
	if (!variable_global_exists("__statement_machines")) {
		return 0;
	}
	
	var _old    = global.__statement_machines;
	var _len    = array_length(_old);
	if (_len <= 0) {
		return 0;
	}
	
	var _new    = [];
	var _pruned = 0;
	
	for (var _i = 0; _i < _len; _i++) {
		var _entry   = _old[_i];
		var _machine = __StatementDebugDerefMachineEntry(_entry);
		
		// Drop any entry whose machine is no longer alive
		if (!is_struct(_machine)) {
			_pruned++;
			continue;
		}
		
		// Optionally drop machines whose owner is a destroyed instance (struct owners are always kept).
		if (_prune_destroyed_owners) {
			var _owner = _machine.owner;
			if (!is_struct(_owner)) {
				if (_owner != noone && !instance_exists(_owner)) {
					_pruned++;
					continue;
				}
			}
		}
		
		// Keep the original entry (weakref or strong)
		array_push(_new, _entry);
	}
	
	global.__statement_machines = _new;
	return _pruned;
}

/// @ignore
/// @func __StatementDebugGetMachines()
/// @desc Returns the list of live Statement machines tracked for debugging.
/// @return {Array<Struct.Statement>}
function __StatementDebugGetMachines() {
	if (!STATEMENT_DEBUG) {
		return [];
	}
	
	if (!variable_global_exists("__statement_machines")) {
		return [];
	}
	
	var _result   = [];
	var _machines = global.__statement_machines;
	var _len      = array_length(_machines);
	
	for (var _i = 0; _i < _len; _i++) {
		var _m = __StatementDebugDerefMachineEntry(_machines[_i]);
		if (!is_struct(_m)) {
			continue;
		}
		array_push(_result, _m);
	}
	
	return _result;
}

/// @ignore
/// @func __StatementDebugFindMachinesForOwner(_owner)
/// @desc Finds Statement machines bound to a specific owner instance/struct.
/// @param {Id.Instance,Struct} _owner Owner to search for.
/// @return {Array<Struct.Statement>}
function __StatementDebugFindMachinesForOwner(_owner) {
	if (!STATEMENT_DEBUG) {
		return [];
	}
	
	var _result   = [];
	var _machines = __StatementDebugGetMachines();
	var _len      = array_length(_machines);
	
	for (var _i = 0; _i < _len; _i++) {
		var _m = _machines[_i];
		if (!is_struct(_m)) {
			continue;
		}
		if (_m.owner == _owner) {
			array_push(_result, _m);
		}
	}
	
	return _result;
}

function EchoChamberThemeStatement() : EchoChamberTheme() constructor {
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
}