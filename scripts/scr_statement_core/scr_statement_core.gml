/* -------------------------------------------------------------------------------------------------
STATEMENT by RefresherTowel Games

v1.3.7

Docs: https://refreshertowel.github.io/docs/statement/
Discord: https://discord.gg/8spFZdyvkb
More Libraries: https://refreshertowel.itch.io/

Welcome to Statement, a flexible and feature-filled state machine framework for GameMaker.

Note: Statement ships with Echo, a minimalist debug logging framework (and debug UI builder),included
for free.

Be sure to check out the documentation, as it is thorough and should guide you through the process
of learning how to use Statement effectively.

If you like Statement, consider checking out my other libraries, I'm sure there's something else
you'll be able to find that'll help you make your games even faster!
------------------------------------------------------------------------------------------------- */


/// @func Statement(_id)
/// @desc Creates a state machine bound to the given owner instance or struct.
/// @param {Id.Instance,Struct} _id The owner that the states and events will operate on.
/// @return {Struct.Statement}
function Statement(_id) constructor {
	owner					= _id;
	states					= {};
	states_array			= [];
	state					= undefined;
	
	// Submachine hosting + start behavior
	auto_enter_first_state	= true;
	initial_state_name		= undefined;
	reset_mode				= eStatementResetMode.RESET_ON_EXIT;
	parent_machine			= undefined;
	parent_state			= undefined;
	__paused_by_host		= false;
	__paused_by_parent		= false;
	__runtime_stopping		= false;
	inherited_time_scale	= 1;
	inherit_pause			= true;
	inherit_time_scale		= false;
	
	// State records
	previous_states			= [];
	previous_state			= undefined;
	history_limit			= 32;
	state_stack				= [];
	
	// State timer
	state_age				= 0;
	update_accumulator		= 0;
	last_effective_dt		= 1;
	
	// Queued state support
	queue_auto_process		= true;
	queued_state_name		= undefined;
	queued_state_force		= false;
	queued_state_pending	= false;
	queued_state_data		= undefined;
	
	// Transition payload support
	last_transition_data	= undefined;
	
	// Global transition hooks
	__any_enter_hooks		= [];
	__any_exit_hooks		= [];
	__any_transition_hooks	= [];
	
	// Time scaling
	time_scale              = 1;
	update_mode				= eStatementUpdateMode.ACCUMULATED;
	
	// Suspends state machine operations
	paused					= false;
	
	if (!variable_global_exists("__statement_default_update_mode")) {
		global.__statement_default_update_mode = eStatementUpdateMode.ACCUMULATED;
	}
	update_mode = __StatementNormalizeUpdateMode(global.__statement_default_update_mode);
	
	if (STATEMENT_DEBUG) {
		debug_enabled            = true;
		debug_name               = undefined;
		debug_tag                = undefined;
		debug_edges              = [];   // array of edge records
		debug_state_stats        = {};   // name -> { entry_count, total_frames, last_enter_tick, error info }
		debug_tick_counter       = 0;
		debug_transition_history = []; // ring buffer of recent transitions
		debug_history_limit      = 256;
		debug_error_behavior     = eStatementErrorBehavior.PAUSE;
		debug_log_errors_to_file = false;
		if (!variable_global_exists("__statement_time_scale")) {
			global.__statement_time_scale = 1;
		}
		
		if (!variable_global_exists("__statement_machines")) {
			global.__statement_machines = [];
		}	
		array_push(global.__statement_machines, weak_ref_create(self));
		
		if (!variable_global_exists("__statement_debug_pause_all")) {
			global.__statement_debug_pause_all = false;
		}
	}
	
	/// @desc	Clears all states, the current state, previous states, the state stack and the queued state.
	/// @return	{Struct.Statement}
	static ClearStates = function() {
		states				= {};
		states_array		= [];
		state				= undefined;
		initial_state_name	= undefined;
		__paused_by_host		= false;
		__runtime_stopping	= false;
		
		// State records
		previous_states		= [];
		previous_state		= undefined;
		history_limit		= 32;
		state_stack			= [];
		
		// State timer
		state_age			= 0;
		update_accumulator	= 0;
		last_effective_dt	= 1;
		
		// Queued state support
		queue_auto_process		= true;
		queued_state_name		= undefined;
		queued_state_force		= false;
		queued_state_pending	= false;
		queued_state_data		= undefined;
		
		// Transition payload support
		last_transition_data	= undefined;
		
		return self;
	}
	
	/// @desc   Sets which state name should be treated as the initial state when the machine starts or is reset.
	/// @param  {String} _name
	/// @return {Struct.Statement}
	static SetInitialState = function(_name) {
		initial_state_name = string(_name);
		return self;
	};
	
	/// @desc   Set how this machine behaves when its host state exits.
	/// @param  {Constant.eStatementResetMode} _mode
	/// @return {Struct.Statement}
	static SetResetMode = function(_mode) {
		reset_mode = __StatementNormalizeResetMode(_mode);
		return self;
	};
	
	/// @desc   Control whether this machine inherits pause state from its parent machine (if any).
	/// @param  {Bool} _enabled
	/// @return {Struct.Statement}
	static SetInheritPause = function(_enabled) {
		inherit_pause = (_enabled == true);
		return self;
	};
	
	/// @desc   Control whether this machine inherits time scaling from its parent machine (if any).
	/// @param  {Bool} _enabled
	/// @return {Struct.Statement}
	static SetInheritTimeScale = function(_enabled) {
		inherit_time_scale = (_enabled == true);
		return self;
	};
	
	/// @ignore
	/// @desc Start the machine if it has not yet entered an initial state.
	static __StartIfNeeded = function() {
		if (__runtime_stopping) {
			return;
		}
		if (!is_undefined(state)) {
			return;
		}
		if (is_undefined(initial_state_name)) {
			if (array_length(states_array) > 0) {
				initial_state_name = states_array[0].name;
			}
		}
		if (!is_undefined(initial_state_name)) {
			var _initial_state = states[$ initial_state_name];
			if (!is_undefined(_initial_state)) {
				ChangeState(initial_state_name);
			}
		}
	};
	
	/// @ignore
	/// @desc Propagate pause state into the active submachine chain (best-effort).
	static __PropagatePauseToChildren = function(_paused) {
		if (!inherit_pause) {
			return;
		}
		if (is_undefined(state)) {
			return;
		}
		if (!state.HasSubMachine()) {
			return;
		}
		var _sub = state.GetSubMachine();
		if (_paused) {
			if (!_sub.paused) {
				_sub.paused = true;
				_sub.__paused_by_parent = true;
			}
		}
		else {
			if (_sub.__paused_by_parent) {
				_sub.__paused_by_parent = false;
				if (_sub.__paused_by_host) {
					// keep paused
				}
				else {
					_sub.paused = false;
				}
			}
		}
		_sub.__PropagatePauseToChildren(_paused);
	};
	
	/// @ignore
	/// @desc Stop runtime processing, optionally running EXIT on the current state. Does not clear states.
	/// @param {Bool} _run_exit
	static __StopRuntime = function(_run_exit) {
		// Clear any queued state change.
		queued_state_name		= undefined;
		queued_state_force		= false;
		queued_state_pending	= false;
		queued_state_data		= undefined;
		
		__paused_by_host = false;
		__paused_by_parent = false;
		
		if (is_undefined(state)) {
			return;
		}
		
		__runtime_stopping = true;
		
		// Child-first: if the active state hosts a submachine, stop it before we run this state's EXIT.
		if (state.HasSubMachine()) {
			var _sub = state.GetSubMachine();
			_sub.__StopRuntime(true);
		}
		
		if (_run_exit) {
			RunState(eStatementEvents.EXIT);
		}
		
		state = undefined;
		
		// Reset runtime records for deterministic restarts.
		previous_states	= [];
		previous_state	= undefined;
		state_stack		= [];
		state_age		= 0;
		update_accumulator = 0;
		last_transition_data = undefined;
		
		__runtime_stopping = false;
	};
	
	/// @desc   Sets the maximum number of previous states to keep in history. Use 0 or a negative value for unlimited history.
	/// @param  {Real} limit  Maximum number of previous states to retain.
	/// @return {Struct.Statement}
	static SetHistoryLimit = function(_limit) {
		history_limit = _limit;
		return self;
	}
	
	/// @desc	Returns the number of entries currently in the previous states history
	/// @return	{Real}
	static GetHistoryCount = function() {
		return array_length(previous_states);
	}
	
	/// @desc	Returns the state stored in the previous states history at the supplied index. Returns -1
	///			if the index isn't valid.
	/// @param	{Real}	index	The array index you wish to retrieve from the previous states array
	/// @return {Struct.StatementState,Undefined}
	static GetHistoryAt = function(_index) {
		if (_index < 0 || _index >= array_length(previous_states)) {
			EchoDebugWarn($"[STATEMENT] - Attempting to retrieve previous states history at an invalid index: {_index}!");
			return undefined;
		}
		return previous_states[_index];
	}
	
	/// @desc   Clears the previous states history without affecting the current state.
	/// @return {Struct.Statement}
	static ClearHistory = function() {
		previous_states = [];
		previous_state  = undefined;
		return self;
	}
	
	/// @desc   Returns whether the state at the given depth in history matches the supplied name.
	///         Depth 1 checks the most recent previous state, 2 checks the one before that, etc.
	/// @param  {String} name   The state name to compare against.
	/// @param  {Real}   [_depth] The history depth to check (1 = most recent). Defaults to 1.
	/// @return {Bool}
	static WasPreviouslyInState = function(_name, _depth = 1) {
		var _len = array_length(previous_states);
		if (_len <= 0) {
			return false;
		}
		
		if (_depth <= 0) {
			_depth = 1;
		}
		
		var _index = _len - _depth;
		if (_index < 0 || _index >= _len) {
			return false;
		}
		
		var _prev = previous_states[_index];
		return (_prev.name == _name);
	}
	
	
	/// @desc   Enables or disables automatic processing of queued state changes in Update().
	/// @param  {Bool} enabled  True to process queued states automatically in Update, false to require manual ProcessQueuedState calls.
	/// @return {Struct.Statement}
	static SetQueueAutoProcessing = function(_enabled) {
		queue_auto_process = _enabled;
		return self;
	}
	
	
	///@desc   Gets a state by name, or the current state if no name is supplied.
	///@param  {String} [_name]  Optional state name to look up.
	///@return {Struct.StatementState,Undefined}
	static GetState = function(_state_name = undefined) {
		// No name supplied: return current state (may be undefined)
		if (is_undefined(_state_name)) {
			return state;
		}
		
		// Named lookup
		var _found = states[$ _state_name];
		if (!is_undefined(_found)) {
			return _found;
		}
		
		EchoDebugWarn("[STATEMENT] - GetState() could not find a state named " + string(_state_name));
		return undefined;
	}
	
	
	/// @desc   Adds a StatementState to this state machine. The first state added becomes the active state.
	/// @param  {Struct.StatementState} state  The state to add.
	/// @return {Struct.Statement}
	static AddState = function(_state) {
		if (!is_instanceof(_state, StatementState)) {
			EchoDebugSevere("[STATEMENT] - Trying to add a non-state to the state machine. No action taken.");
			return self;
		}
		
		_state.state_machine = self;
		if (_state.HasSubMachine()) {
			var _sub = _state.GetSubMachine();
			_sub.parent_machine = self;
			_sub.parent_state = _state;
		}
		var _name = _state.name;
		
		var _existing = states[$ _name];
		if (!is_undefined(_existing)) {
			EchoDebugWarn("[STATEMENT] - State '" + string(_name) + "' exists in state machine, replacing it.");
		}
		
		states[$ _name] = _state;
		array_push(states_array, _state);
		
		// First-added state becomes the default initial state unless specified otherwise.
		if (is_undefined(initial_state_name)) {
			initial_state_name = _name;
		}
		
		if (STATEMENT_DEBUG) {
			if (debug_enabled) {
				// Register any existing declarative transitions and manual links on this state.
				if (is_array(_state.transitions)) {
					var _t_len = array_length(_state.transitions);
					for (var _ti = 0; _ti < _t_len; _ti++) {
						var _tr = _state.transitions[_ti];
						var _target_name = _tr.target_name;
						__DebugGetOrCreateEdge(_name, _target_name, eStatementDebugEdgeKind.DECLARATIVE);
					}
				}
				
				var _links = _state.debug_manual_links;
				if (is_array(_links)) {
					var _l_len = array_length(_links);
					for (var _li = 0; _li < _l_len; _li++) {
						var _link_name = _links[_li];
						if (is_string(_link_name)) {
							__DebugGetOrCreateEdge(_name, _link_name, eStatementDebugEdgeKind.MANUAL);
						}
					}
				}
			}
		}
		
		
		// If this is the first state, optionally auto-enter it (default behavior).
		if (auto_enter_first_state && is_undefined(state)) {
			__StartIfNeeded();
		}
		
		return self;
	}
	
	/// @desc   Creates a state from a template and adds it to this state machine.
	/// @param  {Struct.StatementStateTemplate} template  The template to build from.
	/// @param  {Any}    [_config] Optional config to assign to the created state.
	/// @param  {String} [_name] Optional override for the state's name.
	/// @param  {Bool}   [_clone] Optional override for config cloning.
	/// @return {Struct.Statement}
	static AddStateTemplate = function(_template, _config = undefined, _name = undefined, _clone = undefined) {
		if (!is_instanceof(_template, StatementStateTemplate)) {
			EchoDebugSevere("[STATEMENT] - Trying to add a non-template to the state machine. No action taken.");
			return self;
		}
		
		var _state = _template.Build(owner, _config, _name, _clone);
		if (!is_instanceof(_state, StatementState)) {
			return self;
		}
		
		return AddState(_state);
	}
	
	/// @desc   Changes to the named state, optionally forcing the transition even if the current state disallows exiting.
	/// @param  {String} name    The name of the target state.
	/// @param  {Any}    [_data]  Optional payload to associate with this transition.
	/// @param  {Bool}   [_force] If true, ignore the current state's can_exit flag.
	/// @return {Struct.StatementState,Undefined} The active state after the call, or undefined if the target name does not exist.
	static ChangeState = function(_name, _data = undefined, _force = false, _debug_meta = undefined) {
		if (__runtime_stopping) {
			return state;
		}
		var _target = states[$ _name];
		if (is_undefined(_target)) {
			EchoDebugSevere("[STATEMENT] - Trying to change to a non-existent state named " + string(_name) + "!");
			return undefined;
		}
		
		// Any manual ChangeState should clear a previously queued transition.
		queued_state_name		= undefined;
		queued_state_force		= false;
		queued_state_pending	= false;
		queued_state_data		= undefined;
		
		// No change required
		if (state == _target) {
			return state;
		}
		
		var _via_queue = false;
		var _via_push  = false;
		var _via_pop   = false;
		var _via_debug = false;
		if (is_struct(_debug_meta)) {
			_via_queue = _debug_meta[$ "via_queue"] ?? _via_queue;
			_via_push = _debug_meta[$ "via_push"] ?? _via_push;
			_via_pop = _debug_meta[$ "via_pop"] ?? _via_pop;
			_via_debug = _debug_meta[$ "via_debug"] ?? _via_debug;
		}
		var _meta = {
			via_queue : _via_queue,
			via_push  : _via_push,
			via_pop   : _via_pop,
			via_debug : _via_debug
		};
		
		// Respect can_exit only when there is an active state.
		// Additionally, allow an optional submachine gate to prevent exit until a submachine condition passes.
		if (!is_undefined(state) && !_force) {
			if (!state.can_exit) {
				return state;
			}
			if (state.HasSubMachine()) {
				var _req = state.__sub_exit_required_state;
				if (is_string(_req) && string_length(_req) > 0) {
					var _sub_gate = state.GetSubMachine();
					if (!_sub_gate.IsInState(_req)) {
						return state;
					}
				}
				var _pred = state.__sub_exit_predicate;
				if (is_callable(_pred)) {
					var _sub_gate2 = state.GetSubMachine();
					if (!_pred(_sub_gate2)) {
						return state;
					}
				}
			}
		}
		
		// Leaving the old state: update history and run EXIT
		if (!is_undefined(state)) {
			previous_state = state;
			array_push(previous_states, state);
			
			// Host lifecycle: ensure any hosted submachine is handled before the host EXIT runs.
			if (state.HasSubMachine()) {
				var _sub_m = state.GetSubMachine();
				if (_sub_m.reset_mode == eStatementResetMode.RESET_ON_EXIT) {
					_sub_m.__StopRuntime(true);
				}
				else {
					// REMEMBER and RESET_ON_ENTER both suspend on exit.
					if (!_sub_m.paused) {
						_sub_m.paused = true;
						_sub_m.__paused_by_host = true;
					}
				}
				
				// Host callback (optional)
				var _exit_cb = state.on_submachine_exit;
				if (is_callable(_exit_cb)) {
					_exit_cb(_sub_m);
				}
			}
			
			// Reset the state-specific timer for the state, only works if one has been started previously
			state.TimerSet(0);
			state.TimerPause();
			
			// Enforce history limit if set (>0)
			if (history_limit > 0) {
				var _len = array_length(previous_states);
				if (_len > history_limit) {
					var _extra = _len - history_limit;
					array_delete(previous_states, 0, _extra);
				}
			}
			
			// EXIT on the old state
			RunState(eStatementEvents.EXIT);
			
			// If EXIT changed the active state, honour that transition and stop.
			if (state != previous_state) {
				return state;
			}
		}
		
		// Switch to new state
		var _from_state = state;
		if (!is_undefined(_from_state) && array_length(__any_exit_hooks) > 0) {
			__RunHookList(__any_exit_hooks, _from_state, _target, _data, _force, _meta);
		}
		
		state = _target;
		last_transition_data = _data;
		
		if (STATEMENT_DEBUG) {
			if (debug_enabled) {
				// previous_state already points at the state we just left (if any).
				__DebugOnStateEntered(previous_state, state, _data, _force, _via_queue, _via_push, _via_pop, _via_debug);
			}
		}
		
		if (array_length(__any_transition_hooks) > 0) {
			__RunHookList(__any_transition_hooks, _from_state, state, _data, _force, _meta);
		}
		
		// Run the callable state changed hook if applicable
		if (is_callable(__OnStateChanged)) {
			__OnStateChanged(previous_state, last_transition_data);
		}
		
		// Reset the state machine timer since we have entered a new state
		state_age = 0;
		if (array_length(__any_enter_hooks) > 0) {
			__RunHookList(__any_enter_hooks, state, _from_state, _data, _force, _meta);
		}
		
		// ENTER on the new state
		var _entered = state;
		RunState(eStatementEvents.ENTER);
		
		// Host lifecycle: start/resume submachine only if we are still in the entered state.
		if (state == _entered && state.HasSubMachine()) {
			var _sub_enter = state.GetSubMachine();
			// If configured, inherit time scale from parent (multiplies child's own time_scale).
			if (_sub_enter.inherit_time_scale) {
				_sub_enter.inherited_time_scale = time_scale;
			}
			else {
				_sub_enter.inherited_time_scale = 1;
			}
			
			// RESET_ON_ENTER: restart fresh every time the host is entered.
			if (_sub_enter.reset_mode == eStatementResetMode.RESET_ON_ENTER) {
				_sub_enter.__StopRuntime(true);
			}
			
			if (_sub_enter.__paused_by_host) {
				_sub_enter.__paused_by_host = false;
				if (!_sub_enter.__paused_by_parent) {
					_sub_enter.paused = false;
				}
			}
			_sub_enter.__StartIfNeeded();
			
			// Host callback (optional)
			var _enter_cb = state.on_submachine_enter;
			if (is_callable(_enter_cb)) {
				_enter_cb(_sub_enter);
			}
		}
		
		// Start the state-specific timer for the new state, if one has been previously started
		if (state == _entered) {
			state.TimerRestart();
		}
		
		return state;
	}
	
	
	/// @ignore
	__OnStateChanged = undefined;
	
	/// @ignore
	static __RunHookList = function(_hooks, _from_state, _to_state, _data, _force, _meta) {
		var _len = array_length(_hooks);
		for (var i = 0; i < _len; i++) {
			var _fn = _hooks[i];
			_fn(_from_state, _to_state, _data, _force, _meta);
		}
	}
	
	/// @desc	Allows you to set a hook that will run whenever the state changes. You should manually handle
	///			the scope of the provided function using method(). Runs after the Exit function of the
	///			previous state and after the current state has switched to the new one, but before the new
	///			state runs its Enter function. The hook is called as fn(previous_state, data), where data
	///			is the payload passed to the transition (if any).
	/// @param	{Function}	function
	static SetStateChangeBehaviour = function(_function) {
		__OnStateChanged = _function;
	}
	
	/// @desc Adds a hook that runs whenever any state exits.
	/// @param {Function} function The hook: fn(from_state, to_state, data, force, meta).
	/// @return {Struct.Statement}
	static AddAnyExitHook = function(_function) {
		if (!is_callable(_function)) {
			EchoDebugSevere("[STATEMENT] - AddAnyExitHook on " + __GetOwnerDebugDesc() + " requires a callable function.");
			return self;
		}
		
		var _self = owner;
		if (instance_exists(owner)) {
			_self = owner.id;
		}
		array_push(__any_exit_hooks, method(_self, _function));
		return self;
	}
	
	/// @desc Adds a hook that runs whenever any state enters.
	/// @param {Function} function The hook: fn(to_state, from_state, data, force, meta).
	/// @return {Struct.Statement}
	static AddAnyEnterHook = function(_function) {
		if (!is_callable(_function)) {
			EchoDebugSevere("[STATEMENT] - AddAnyEnterHook on " + __GetOwnerDebugDesc() + " requires a callable function.");
			return self;
		}
		
		var _self = owner;
		if (instance_exists(owner)) {
			_self = owner.id;
		}
		array_push(__any_enter_hooks, method(_self, _function));
		return self;
	}
	
	/// @desc Adds a hook that runs whenever any transition occurs.
	/// @param {Function} function The hook: fn(from_state, to_state, data, force, meta).
	/// @return {Struct.Statement}
	static AddAnyTransitionHook = function(_function) {
		if (!is_callable(_function)) {
			EchoDebugSevere("[STATEMENT] - AddAnyTransitionHook on " + __GetOwnerDebugDesc() + " requires a callable function.");
			return self;
		}
		
		var _self = owner;
		if (instance_exists(owner)) {
			_self = owner.id;
		}
		array_push(__any_transition_hooks, method(_self, _function));
		return self;
	}
	
	/// @desc Clears all any-exit hooks on this machine.
	/// @return {Struct.Statement}
	static ClearAnyExitHooks = function() {
		__any_exit_hooks = [];
		return self;
	}
	
	/// @desc Clears all any-enter hooks on this machine.
	/// @return {Struct.Statement}
	static ClearAnyEnterHooks = function() {
		__any_enter_hooks = [];
		return self;
	}
	
	/// @desc Clears all any-transition hooks on this machine.
	/// @return {Struct.Statement}
	static ClearAnyTransitionHooks = function() {
		__any_transition_hooks = [];
		return self;
	}
	
	/// @desc   Queues a state change to be processed later, typically at the start of Update().
	/// @param  {String} name    The name of the target state.
	/// @param  {Any}    [_data]  Optional payload to associate with this queued transition.
	/// @param  {Bool}   [_force] If true, ignore the current state's can_exit flag when the queue is processed.
	/// @return {Struct.Statement}
	static QueueState = function(_name, _data = undefined, _force = false) {
		if (__runtime_stopping) {
			return self;
		}
		var _queued = states[$ _name];
		if (is_undefined(_queued)) {
			EchoDebugWarn("[STATEMENT] - QueueState() called with non-existent state name " + string(_name) + ".");
			return self;
		}
		
		queued_state_name    = _name;
		queued_state_force   = _force;
		queued_state_pending = true;
		queued_state_data    = _data;
		
		return self;
	}
	
	/// @desc   Processes any pending queued state change immediately.
	/// @return {Struct.StatementState,Undefined} The active state after processing, or undefined if there was no queued state or the transition failed.
	static ProcessQueuedState = function() {
		if (__runtime_stopping) {
			return state;
		}
		if (!queued_state_pending) {
			return state;
		}
		
		var _name  = queued_state_name;
		var _force = queued_state_force;
		var _data  = queued_state_data;
		
		// If we cannot exit yet (and we are not forcing), leave the queue intact.
		if (!is_undefined(state) && !state.can_exit && !_force) {
			return state;
		}
		
		// Clear the queue before attempting the change so this is always one-shot.
		queued_state_name    = undefined;
		queued_state_force   = false;
		queued_state_pending = false;
		queued_state_data    = undefined;
		
		// Delegate to ChangeState; this will respect can_exit and may return undefined.
		return ChangeState(_name, _data, _force, { via_queue : true });
	}
	
	/// @desc   Returns whether there is currently a queued state change pending.
	/// @return {Bool}
	static HasQueuedState = function() {
		return queued_state_pending;
	}
	
	/// @desc   Returns the name of the queued state, if any.
	/// @return {String,Undefined}
	static GetQueuedStateName = function() {
		return queued_state_pending ? queued_state_name : undefined;
	}
	
	/// @desc   Returns the payload associated with the queued state, if any.
	/// @return {Any,Undefined}
	static GetQueuedStateData = function() {
		return queued_state_pending ? queued_state_data : undefined;
	}
	
	
	/// @desc   Clears any pending queued state change without processing it.
	/// @return {Struct.Statement}
	static ClearQueuedState = function() {
		queued_state_name		= undefined;
		queued_state_force		= false;
		queued_state_pending	= false;
		queued_state_data		= undefined;
		return self;
	}
	
	/// @func	PushState(name, data, forced)
	/// @desc   Pushes the current state onto an internal stack and changes to the named state. Useful for temporary states like menus or cutscenes.
	/// @param  {String} name    The name of the target state.
	/// @param  {Any}    [_data]  Optional payload to associate with this transition.
	/// @param  {Bool}   [_force] If true, ignore the current state's can_exit flag.
	/// @return {Struct.StatementState,Undefined} The active state after the call, or undefined if the target name does not exist.
	static PushState = function(_name, _data = undefined, _force = false) {
		var _current = state;
		var _result  = ChangeState(_name, _data, _force, { via_push : true });
		
		if (is_undefined(_result)) {
			return _result;
		}
		
		if (!is_undefined(_current) && _result != _current) {
			array_push(state_stack, _current);
		}
		
		return _result;
	}
	
	/// @desc   Pops the most recently pushed state from the internal stack and changes back to it.
	/// @param  {Any}  [_data]  Optional payload to associate with this transition.
	/// @param  {Bool} [_force] If true, ignore the current state's can_exit flag when popping.
	/// @return {Struct.StatementState,Undefined} The active state after the call, or undefined if there is no state to pop.
	static PopState = function(_data = undefined, _force = false) {
		var _len = array_length(state_stack);
		if (_len <= 0) {
			EchoDebugInfo("[STATEMENT] - PopState() called but the state stack is empty.");
			return state;
		}
		
		var _idx    = _len - 1;
		var _target = state_stack[_idx];
		array_delete(state_stack, _idx, 1);
		
		// Ensure the target state still exists on this machine
		var _exists = states[$ _target.name];
		if (is_undefined(_exists)) {
			EchoDebugWarn("[STATEMENT] - PopState() target '" + string(_target.name) + "' no longer exists on this state machine.");
			return state;
		}
		
		return ChangeState(_target.name, _data, _force, { via_pop : true });
	}
	
	/// @desc   Returns the number of entries currently on the state stack.
	/// @return {Real}
	static GetStateStackDepth = function() {
		return array_length(state_stack);
	}
	
	/// @desc   Returns the most recently pushed state on the stack without popping it.
	/// @return {Struct.StatementState,Undefined}
	static PeekStateStack = function() {
		var _len = array_length(state_stack);
		if (_len <= 0) {
			return undefined;
		}
		
		var _idx = _len - 1;
		var _target = state_stack[_idx];
		
		return _target;
	}
	
	/// @desc   Clears all entries from the state stack without changing the current state.
	/// @return {Struct.Statement}
	static ClearStateStack = function() {
		state_stack = [];
		return self;
	}
	
	
	/// @desc   Convenience helper to change back to the most recent previous state (single step).
	/// @param  {Any}  [_data]  Optional payload to associate with this transition.
	/// @param  {Bool} [_force] If true, ignore the current state's can_exit flag when changing back.
	/// @return {Struct.StatementState,Undefined} The active state after the call, or undefined if there is no previous state recorded.
	static PreviousState = function(_data = undefined, _force = false) {
		if (!is_undefined(previous_state)) {
			return ChangeState(previous_state.name, _data, _force);
		}
		return undefined;
	}
	
	/// @desc   Returns the name of the current state, if any.
	/// @return {String,Undefined}
	static GetStateName = function() {
		return is_undefined(state) ? undefined : state.name;
	}
	
	/// @desc Returns the active submachine of the current state, if any.
	/// @return {Struct.Statement,Undefined}
	static GetChildMachine = function() {
		if (is_undefined(state)) {
			return undefined;
		}
		if (!state.HasSubMachine()) {
			return undefined;
		}
		return state.GetSubMachine();
	};
	
	/// @desc Returns the active child state of the current state's submachine, if any.
	/// @return {Struct.StatementState,Undefined}
	static GetChildState = function() {
		var _sub = GetChildMachine();
		if (is_undefined(_sub)) {
			return undefined;
		}
		return _sub.GetState();
	};
	
	/// @desc Returns true if this machine matches a nested state path like "A/B/C".
	/// @param {String} _path
	/// @return {Bool}
	static IsInPath = function(_path) {
		if (!is_string(_path)) {
			return false;
		}
		var _p = string(_path);
		if (string_length(_p) <= 0) {
			return false;
		}
		
		var _raw_parts = string_split(_p, "/");
		var _raw_len = array_length(_raw_parts);
		if (_raw_len <= 0) {
			return false;
		}
		
		var _parts = [];
		for (var _ri = 0; _ri < _raw_len; _ri++) {
			var _seg0 = string_trim(string(_raw_parts[_ri]));
			if (string_length(_seg0) > 0) {
				array_push(_parts, _seg0);
			}
		}
		var _len = array_length(_parts);
		if (_len <= 0) {
			return false;
		}
		
		var _m = self;
		for (var _i = 0; _i < _len; _i++) {
			var _seg = _parts[_i];
			if (is_undefined(_m.state) || _m.state.name != _seg) {
				return false;
			}
			if (_i < _len - 1) {
				if (_m.state.HasSubMachine()) {
					_m = _m.state.GetSubMachine();
				}
				else {
					return false;
				}
			}
		}
		return true;
	};
	
	/// @desc   Returns whether the current state matches the supplied name or state struct.
	/// @param  {String,Struct.StatementState} state  The name or state to check against.
	/// @return {Bool}
	static IsInState = function(_state_or_state_struct) {
		// No active state: cannot be "in" anything.
		if (is_undefined(state)) {
			return false;
		}
		
		// String: compare by name.
		if (is_string(_state_or_state_struct)) {
			return (state.name == _state_or_state_struct);
		}
		
		// Struct: compare by identity.
		if (is_instanceof(_state_or_state_struct, StatementState)) {
			return (state == _state_or_state_struct);
		}
		
		// Unsupported type: warn and return false.
		EchoDebugWarn("[STATEMENT] - IsInState() called with an unsupported argument type: " + string(_state_or_state_struct));
		return false;
	}
	
	/// @desc   Enables or disables processing of this state machine in Update(). When paused, queued
	///         transitions, state STEP events and declarative transitions are not processed, and the
	///         state age does not advance. Draw() and manual state changes are unaffected.
	/// @param  {Bool} paused  True to pause, false to resume.
	/// @return {Struct.Statement}
	static SetPaused = function(_paused) {
		paused = _paused;
		__PropagatePauseToChildren(paused);
		return self;
	}
	
	/// @desc   Returns whether this state machine is currently paused.
	/// @return {Bool}
	static IsPaused = function() {
		return paused;
	}
	
	
	/// @desc   Ensures that the current state matches the supplied name. If it is already active, no transition occurs.
	/// @param  {String} name   The name of the target state.
	/// @param  {Any}    [_data] Optional payload to associate with this transition if a change is required.
	/// @param  {Bool}   [_force] If true, ignore the current state's can_exit flag.
	/// @return {Struct.StatementState,Undefined} The active state after the call.
	static EnsureState = function(_name, _data = undefined, _force = false) {
		if (is_undefined(state)) {
			// No active state yet: just change to the requested state.
			return ChangeState(_name, _data, _force);
		}
		
		if (state.name == _name) {
			// Already in this state: no transition, payload is ignored.
			return state;
		}
		
		return ChangeState(_name, _data, _force);
	}
	
	
	///	@desc	Returns the scaled time since the state has been entered (respects time scale).
	/// @return	{Real}
	static GetStateTime = function() {
		return state_age;
	}
	
	/// @desc	Sets the age of the current state to the provided value. Setting this manually rewrites the
	///			data about how long the current state has been running.
	/// @param	{Real}	time	What you want to replace the current state age with
	/// @return	{Struct.Statement}
	static SetStateTime = function(_time) {
		state_age = _time;
		return self;
	}
	
	/// @desc   Drives the current state using a delta-based accumulator. The supplied delta is scaled
	///         by the machine time scale and global time scale, advances state_age, and runs STEP /
	///         declarative transitions once per whole accumulated tick (>=1). When paused, no
	///         processing occurs. Fractional deltas advance timers/age without running STEP.
	/// @param  {Real} [_dt] Delta to apply (unscaled). Defaults to 1.
	/// @return {Any,Undefined} The value returned by the last STEP handler run this call, or undefined
	///                         if no STEP ran or there is no active state.
	static UpdateDelta = function(_dt = 1) {
		// When paused, freeze automatic processing: no queue, no STEP, no declarative transitions,
		// and do not advance the state age.
		if (paused) {
			return undefined;
		}
		
		if (STATEMENT_DEBUG && debug_enabled) {
			if (variable_global_exists("__statement_debug_pause_all")) {
				if (global.__statement_debug_pause_all) {
					return undefined;
				}
			}
		}
		
		// Safety: cap nested update recursion to avoid infinite loops if a cycle is created accidentally.
		if (!variable_global_exists("__statement_update_depth")) {
			global.__statement_update_depth = 0;
		}
		global.__statement_update_depth++;
		if (global.__statement_update_depth > 64) {
			global.__statement_update_depth--;
			return undefined;
		}
		
		try {
			__StartIfNeeded();
			
			var _dt_raw = max(0, _dt);
			
			// Effective delta time based on machine + global scale
			var _dt_effective = _dt_raw * time_scale * inherited_time_scale;
			if (variable_global_exists("__statement_time_scale")) {
				_dt_effective *= global.__statement_time_scale;
			}
			
			last_effective_dt = _dt_effective;
			
			// Advance state age even if no STEP executes this frame
			if (!is_undefined(state)) {
				state_age += _dt_effective;
			}
			
			var _mode = update_mode;
			
			if (_mode == eStatementUpdateMode.PER_FRAME) {
				update_accumulator = 0;
				
				if (queue_auto_process) {
					ProcessQueuedState();
				}
				
				if (is_undefined(state)) {
					global.__statement_update_depth--;
					return undefined;
				}
				
				if (paused) {
					global.__statement_update_depth--;
					return undefined;
				}
				if (STATEMENT_DEBUG && debug_enabled) {
					if (variable_global_exists("__statement_debug_pause_all")) {
						if (global.__statement_debug_pause_all) {
							global.__statement_update_depth--;
							return undefined;
						}
					}
				}
				
				var _pf_before = state;
				var _pf_result = RunState(eStatementEvents.STEP);
				
				// Submachine update (only if still in the same host state after STEP)
				if (!is_undefined(state) && state == _pf_before && state.HasSubMachine()) {
					var _sub_pf = state.GetSubMachine();
					if (!_sub_pf.paused) {
						if (_sub_pf.inherit_time_scale) {
							_sub_pf.inherited_time_scale = time_scale;
						}
						_sub_pf.__StartIfNeeded();
						_sub_pf.UpdateDelta(_dt_raw);
					}
				}
				
				if (!is_undefined(state) && state == _pf_before) {
					// Evaluate declarative transitions only for the state that ran STEP this tick.
					EvaluateTransitions();
				}
				
				if (STATEMENT_DEBUG && debug_enabled) {
					debug_tick_counter++;
					
					if (!is_undefined(state)) {
						var _pf_stats = __DebugGetOrCreateStateStats(state.name);
						if (!is_undefined(_pf_stats)) {
							_pf_stats.total_frames += _dt_effective;
						}
					}
				}
				
				global.__statement_update_depth--;
				return _pf_result;
			}
			
			update_accumulator += _dt_effective;
			
			var _state_result = undefined;
			var _tick_safety = 0;
			var _remaining_dt = _dt_effective;
			
			while (update_accumulator >= 1) {
				// Respect pauses that may have been set mid-loop
				if (paused) {
					break;
				}
				if (STATEMENT_DEBUG && debug_enabled) {
					if (variable_global_exists("__statement_debug_pause_all")) {
						if (global.__statement_debug_pause_all) {
							break;
						}
					}
				}
				
				// If there is no active state, do not spam RunState warnings; bail out of the loop.
				if (is_undefined(state)) {
					break;
				}
				
				if (queue_auto_process) {
					ProcessQueuedState();
				}
				
				var _before = state;
				_state_result = RunState(eStatementEvents.STEP);
				
				// Submachine update (only if still in the same host state after STEP)
				if (!is_undefined(state) && state == _before && state.HasSubMachine()) {
					var _sub = state.GetSubMachine();
					if (!_sub.paused) {
						if (_sub.inherit_time_scale) {
							_sub.inherited_time_scale = time_scale;
						}
						_sub.__StartIfNeeded();
						_sub.UpdateDelta(1);
					}
				}
				
				if (!is_undefined(state) && state == _before) {
					// Evaluate declarative transitions after STEP, only for the state that ran STEP.
					EvaluateTransitions();
				}
				
				if (STATEMENT_DEBUG && debug_enabled) {
					debug_tick_counter++;
					
					if (!is_undefined(state)) {
						var _stats = __DebugGetOrCreateStateStats(state.name);
						if (!is_undefined(_stats)) {
							var _step_dt = min(1, _remaining_dt);
							_stats.total_frames += _step_dt;
						}
					}
				}
				
				update_accumulator -= 1;
				_remaining_dt = max(0, _remaining_dt - 1);
				_tick_safety++;
				if (_tick_safety > 1024) {
					break;
				}
			}
			
			// Attribute any leftover fractional dt to the current state for debug stats.
			if (STATEMENT_DEBUG && debug_enabled && _remaining_dt > 0) {
				if (!is_undefined(state)) {
					var _stats_frac = __DebugGetOrCreateStateStats(state.name);
					if (!is_undefined(_stats_frac)) {
						_stats_frac.total_frames += _remaining_dt;
					}
				}
			}
			
			global.__statement_update_depth--;
			return _state_result;
		}
		catch (_err_depth) {
			global.__statement_update_depth--;
			throw _err_depth;
		}
	}
	
	/// @desc   Drives the current state with a fixed delta of 1 (legacy convenience wrapper).
	/// @return {Any,Undefined} The value returned by the state's update handler, or undefined if the
	///                         event is not implemented or there is no active state.
	static Update = function() {
		return UpdateDelta(1);
	}
	
	/// @desc	[Optional] Use this in the Draw Event to handle any drawing required for the state
	/// @return	{Any,Undefined} The value returned by the event handler, or undefined if the event is not implemented or there is no active state.
	static Draw = function() {
		return RunState(eStatementEvents.DRAW);
	}
	
	/// @ignore
	static __StateEventToString = function(_state_event) {
		switch (_state_event) {
			case eStatementEvents.ENTER: return "Enter";
			case eStatementEvents.EXIT:  return "Exit";
			case eStatementEvents.STEP:  return "Step";
			case eStatementEvents.DRAW:  return "Draw";
			default: return "Unknown";
		}
	};
	
	/// @desc   Runs the given event on the current state, if it is implemented.
	/// @param  {Real} event  One of eStateEvents.
	/// @return {Any,Undefined} The value returned by the event handler, or undefined if the
	///                         event is not implemented or there is no active state.
	static RunState = function(_state_event) {
		if (is_undefined(state)) {
			EchoDebugSevere("[STATEMENT] - Trying to run a state event when there is no active state on this machine.");
			return undefined;
		}
		
		if (!state.HasStateEvent(_state_event)) {
			// No handler for this event on this state: do nothing.
			return undefined;
		}
		
		try {
			var _handler = state.state_event[_state_event];
			
			if (is_array(_handler)) {
				var _ret = undefined;
				var _len = array_length(_handler);
				for (var _i = 0; _i < _len; _i++) {
					_ret = _handler[_i]();
				}
				return _ret;
			}
			
			return _handler();
		}
		catch (_err) {
			if (STATEMENT_DEBUG && debug_enabled) {
				__DebugRecordStateError(state.name, __StateEventToString(_state_event), _err);
				if (debug_error_behavior == eStatementErrorBehavior.RETHROW) {
					throw _err;
				}
			} 
			else {
				throw _err;
			}
		}
	}
	
	/// @desc   Evaluates any declarative transitions defined on the current state and changes state
	///         if one of them passes. Transitions are evaluated in the order they were added, and the
	///         first condition that returns true will be taken.
	/// @return {Struct.StatementState,Undefined} The active state after evaluation, or undefined if there is no active state.
	static EvaluateTransitions = function() {
		if (is_undefined(state)) {
			return undefined;
		}
		
		// If the current state does not support declarative transitions, do nothing.
		if (!is_callable(state.EvaluateTransitions)) {
			return state;
		}
		
		var _transition;
		if (STATEMENT_DEBUG && debug_enabled) {
			try {
				_transition = state.EvaluateTransitions();
			} catch (_err_eval) {
				__DebugRecordStateError(state.name, "EvaluateTransitions", _err_eval);
				if (debug_error_behavior == eStatementErrorBehavior.RETHROW) {
					throw _err_eval;
				}
				return state;
			}
		} 
		else {
			_transition = state.EvaluateTransitions();
		}
		
		if (is_undefined(_transition)) {
			// No transition fired; remain in the current state.
			return state;
		}
		
		var _target_name	= _transition.target_name;
		var _force			= _transition.force;
		var _data			= _transition.data;
		
		return ChangeState(_target_name, _data, _force);
	}
	
	/// @desc   Removes a state by name from this state machine.
	/// @param  {String} name  The name of the state to remove.
	/// @return {Struct.Statement}
	static RemoveState = function(_name) {
		var _removed = states[$ _name];
		if (is_undefined(_removed)) {
			EchoDebugWarn("[STATEMENT] - Trying to remove a non-existent state named " + string(_name) + " from the state machine.");
			return self;
		}
		variable_struct_remove(states, _name);
		
		// Remove from states_array as well
		var _len = array_length(states_array);
		for (var i = _len - 1; i >= 0; i--) {
			if (states_array[i] == _removed) {
				array_delete(states_array, i, 1);
			}
		}
		
		// Clear active / previous references if they pointed at the removed state
		if (state == _removed) {
			state = undefined;
		}
		
		if (previous_state == _removed) {
			previous_state = undefined;
		}
		
		_removed.TimerKill();
		
		return self;
	}
	
	
	/// @ignore
	/// @desc Get a stable owner description for debug output (handles structs and destroyed instances).
	/// @return {String}
	static __GetOwnerDebugDesc = function() {
		if (is_struct(owner)) {
			return "struct";
		}
		else if (instance_exists(owner)) {
			return $"{string(owner.id)} object type {object_get_name(owner.object_index)}";
		}
		else if (owner == noone) {
			return "noone";
		}
		else {
			return "(destroyed instance)";
		}
	};
	
	
	/// @desc   EchoDebug helper: prints all state names registered on this state machine.
	/// @return {Struct.Statement}
	static PrintStateNames = function() {
		var _names = variable_struct_get_names(states);
		var _count = variable_struct_names_count(states);
		
		for (var i = 0; i < _count; i++) {
			var _st = states[$ _names[i]];
			EchoDebugInfo("[STATEMENT] - State registered: " + string(_st.name));
		}
		
		return self;
	}
	
	/// @desc   EchoDebug helper: Prints a one-line debug description (at the INFO debug level) of this state machine, including owner, current
	///         state, previous state, age, queued state, stack depth and history count.
	static DebugDescribe = function() {
		var _owner_desc = __GetOwnerDebugDesc();
		
		var _state_name      = is_undefined(state)			? "undefined"				: string(state.name);
		var _prev_name       = is_undefined(previous_state) ? "undefined"				: string(previous_state.name);
		var _queued_name     = queued_state_pending			? string(queued_state_name) : "none";
		var _stack_depth     = array_length(state_stack);
		var _history_count   = array_length(previous_states);
		
		var _desc = "[STATEMENT] - owner=" + _owner_desc
		+ " state="          + _state_name
		+ " previous="       + _prev_name
		+ " age="            + string(state_age)
		+ " queued="         + _queued_name
		+ " stack_depth="    + string(_stack_depth)
		+ " history_count="  + string(_history_count);
		
		EchoDebugInfo(_desc);
	}
	
	/// @desc   EchoDebug helper: prints the previous state history for this machine, from most
	///         recent backwards. Optionally limit how many entries are printed.
	/// @param  {Real} [_limit]  Maximum number of history entries to print (1 = most recent only).
	///                         Use 0 or a negative value to print all entries.
	/// @return {Struct.Statement}
	static PrintStateHistory = function(_limit = 0) {
		var _len = array_length(previous_states);
		if (_len <= 0) {
			EchoDebugInfo("[STATEMENT] - PrintStateHistory() - history is empty.");
			return self;
		}
		
		var _max = _len;
		if (_limit > 0 && _limit < _len) {
			_max = _limit;
		}
		
		// Optional: print a one-line summary first.
		DebugDescribe();
		EchoDebugInfo("[STATEMENT] - State history (most recent first):");
		
		var _index = _len - 1;
		var _i     = 0;
		repeat (_max) {
			var _entry    = previous_states[_index];
			var _name_str = _entry.name;
			var _str = string_repeat("-", min(20, _i + 1));
			_str += $" #{string(_i)} = {_name_str}";
			EchoDebugInfo(_str);
			
			_index--;
			_i++;
		}
		
		return self;
	}
	
	
	/// @desc   Returns the name of the most recent previous state in the history, if any.
	/// @return {String,Undefined}
	static GetPreviousStateName = function() {
		var _len = array_length(previous_states);
		if (_len > 0) {
			var _prev = previous_states[_len - 1];
			return _prev.name;
		}
		return undefined;
	}
	
	/// @desc   Returns the payload associated with the last successful state transition, if any.
	/// @return {Any,Undefined}
	static GetLastTransitionData = function() {
		return last_transition_data;
	}
	
	/// @desc	Clears out all remaining state-specifc timers for the State Machine, only necessary if
	///			you have manually started timers for any of the individual states.
	static Destroy = function() {
		var _state_names = struct_get_names(states);
		var i = -1;
		repeat (array_length(_state_names)) {
			var _state = states[$ _state_names[++i]];
			_state.TimerKill();
		}
		i = array_length(previous_states);
		repeat (i) {
			var _state = previous_states[--i];
			_state.TimerKill();
		}
	}
	
	/// @ignore
	/// @desc	Ensure there is a stats record for a state name.
	/// @param	{String}	_state_name The name of the state to create stats for.
	static __DebugGetOrCreateStateStats = function(_state_name) {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		
		var _stats = debug_state_stats[$ _state_name];
		if (is_undefined(_stats)) {
			debug_state_stats[$ _state_name] = {
				entry_count     : 0,
				total_frames    : 0,
				last_enter_tick : 0
			};
			_stats = debug_state_stats[$ _state_name];
		}
		
		return _stats;
	};
	
	/// @ignore
	/// @desc Ensure there is an edge record.
	/// @param	{String}	_from_name	The state the edge is coming from.
	/// @param	{String}	_to_name	The state the edge is going to.
	/// @param	{Real}		_kind		One of the eStatementDebugEdgeKind values.
	static __DebugGetOrCreateEdge = function(_from_name, _to_name, _kind) {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		
		var _len = array_length(debug_edges);
		for (var _i = 0; _i < _len; _i++) {
			var _edge = debug_edges[_i];
			if (_edge.from_name == _from_name && _edge.to_name == _to_name) {
				// Optionally update kind if I decide I want DECLARATIVE to "win", etc.
				if (is_undefined(_edge[$ "last_error_tick"])) {
					_edge.last_error_tick    = 0;
					_edge.last_error_message = "";
					_edge.last_error_context = "";
					_edge.has_error          = false;
				}
				if (is_undefined(_edge[$ "debug_break_triggered"])) {
					_edge.debug_break_triggered = false;
				}
				if (is_undefined(_edge[$ "last_break_triggered_tick"])) {
					_edge.last_break_triggered_tick = 0;
				}
				return _edge;
			}
		}
		
		var _edge = {
			from_name        : _from_name,
			to_name          : _to_name,
			kind             : _kind,
			created_tick     : debug_tick_counter,
			first_fired_tick : 0,
			hits             : 0,
			last_payload     : undefined,
			last_force       : false,
			last_fired_tick  : 0,
			debug_break_triggered : false,
			last_break_triggered_tick : 0,
			last_error_tick    : 0,
			last_error_message : "",
			last_error_context : "",
			has_error          : false
			// via_queue / via_push / via_pop can be added later here
		};
		
		array_push(debug_edges, _edge);
		return _edge;
	};
	
	/// @ignore
	/// @desc Append an error entry to disk if enabled.
	static __DebugLogErrorToFile = function(_context, _state_name, _event_label, _from_name, _to_name, _message) {
		if (!debug_log_errors_to_file) {
			return;
		}
		var _fh = file_text_open_append("debug_statement_errors.log");
		if (_fh < 0) {
			return;
		}
		file_text_write_string(_fh, "tick=" + string(debug_tick_counter));
		file_text_write_string(_fh, " | context=" + string(_context));
		file_text_write_string(_fh, " | machine=" + string(debug_name));
		file_text_write_string(_fh, " | state=" + string(_state_name));
		file_text_write_string(_fh, " | event=" + string(_event_label));
		file_text_write_string(_fh, " | from=" + string(_from_name));
		file_text_write_string(_fh, " | to=" + string(_to_name));
		file_text_write_string(_fh, " | msg=" + string(_message));
		file_text_writeln(_fh);
		file_text_close(_fh);
	};
	
	/// @ignore
	/// @desc Record an error against a state (and optionally pause/log).
	static __DebugRecordStateError = function(_state_name, _event_label, _message) {
		var _stats = __DebugGetOrCreateStateStats(_state_name);
		if (!is_undefined(_stats)) {
			_stats.last_error_tick    = debug_tick_counter;
			_stats.last_error_message = string(_message);
			_stats.last_error_event   = string(_event_label);
			_stats.has_error          = true;
		}
		
		__DebugLogErrorToFile("state_event", _state_name, _event_label, undefined, undefined, _message);
		
		if (debug_error_behavior == eStatementErrorBehavior.PAUSE) {
			paused = true;
		}
	};
	
	/// @ignore
	/// @desc Record an error against an edge (condition etc.).
	static __DebugRecordEdgeError = function(_from_name, _to_name, _kind, _context, _message) {
		var _edge = __DebugGetOrCreateEdge(_from_name, _to_name, _kind);
		if (!is_undefined(_edge)) {
			_edge.last_error_tick    = debug_tick_counter;
			_edge.last_error_message = string(_message);
			_edge.last_error_context = string(_context);
			_edge.has_error          = true;
		}
		
		__DebugLogErrorToFile(_context, _from_name, "", _from_name, _to_name, _message);
		
		if (debug_error_behavior == eStatementErrorBehavior.PAUSE) {
			paused = true;
		}
	};
	
	/// @ignore
	/// @desc	Called whenever a state is *entered* successfully.
	/// @param	{String}	_from_state	The state that was exited.
	/// @param	{String}	_to_state	The state that was entered.
	/// @param	{Any}		_data		The payload between them.
	/// @param	{Boolean}	_force		Whether the transition was forced.
	static __DebugOnStateEntered = function(_from_state, _to_state, _data, _force, _via_queue = false, _via_push = false, _via_pop = false, _via_debug = false) {
		if (!STATEMENT_DEBUG) {
			return;
		}
		
		if (!debug_enabled) {
			return;
		}
		
		if (is_undefined(_to_state)) {
			return;
		}
		
		// State stats
		var _name  = _to_state.name;
		var _stats = __DebugGetOrCreateStateStats(_name);
		if (!is_undefined(_stats)) {
			_stats.entry_count++;
			_stats.last_enter_tick = debug_tick_counter;
		}
		
		// Observed edge from previous state, if any
		if (!is_undefined(_from_state)) {
			var _from_name = _from_state.name;
			var _to_name   = _to_state.name;
			
			var _edge = __DebugGetOrCreateEdge(_from_name, _to_name, eStatementDebugEdgeKind.OBSERVED);
			if (!is_undefined(_edge)) {
				_edge.hits++;
				_edge.last_payload = _data;
				_edge.last_force   = _force;
				_edge.last_fired_tick = debug_tick_counter;
				if (_via_debug) {
					_edge.debug_created = true;
				}
				
				if (_edge[$ "debug_break_on_transition"] == true) {
					_edge.debug_break_triggered = true;
					_edge.last_break_triggered_tick = debug_tick_counter;
					paused = true;
				}
				
				if (_edge.first_fired_tick <= 0) {
					_edge.first_fired_tick = debug_tick_counter;
				}
			}
		}
		
		// Transition history ring buffer
		var _record = {
			from_name : is_undefined(_from_state) ? undefined : _from_state.name,
			to_name   : _name,
			tick      : debug_tick_counter,
			payload   : _data,
			force     : _force,
			via_queue : _via_queue,
			via_push  : _via_push,
			via_pop   : _via_pop
		};
		
		array_push(debug_transition_history, _record);
		
		if (debug_history_limit > 0) {
			var _len_hist = array_length(debug_transition_history);
			if (_len_hist > debug_history_limit) {
				var _extra = _len_hist - debug_history_limit;
				array_delete(debug_transition_history, 0, _extra);
			}
		}
		
		// Breakpoint support (if the state opted in)
		if (_to_state[$ "debug_break_on_enter"] == true) {
			paused = true;
		}
	};
	
	/// @desc Enable or disable debug tracking for this machine.
	/// @return {Struct.Statement}
	static SetDebugEnabled = function(_enabled) {
		if (STATEMENT_DEBUG) {
			debug_enabled = _enabled;
		}
		return self;
	};
	
	/// @desc Returns whether debug tracking is enabled for this machine.
	/// @return {Bool}
	static IsDebugEnabled = function() {
		if (!STATEMENT_DEBUG) {
			return false;
		}
		return debug_enabled;
	};
	
	/// @desc Assign a friendly name for this machine in debug UIs.
	/// @param {String} name
	/// @return {Struct.Statement}
	static SetDebugName = function(_name) {
		if (STATEMENT_DEBUG) {
			debug_name = _name;
		}
		return self;
	};
	
	/// @desc Set per-machine time scale (affects state age, timers, and debug stats).
	/// @param {Real} scale
	/// @return {Struct.Statement}
	static SetTimeScale = function(_scale) {
		time_scale = max(0, _scale);
		return self;
	};
	
	/// @desc Get per-machine time scale.
	/// @return {Real}
	static GetTimeScale = function() {
		return time_scale;
	};
	
	/// @desc Get global time scale.
	/// @return {Real}
	static GetGlobalTimeScale = function() {
		if (variable_global_exists("__statement_time_scale")) {
			return global.__statement_time_scale;
		}
		return 1;
	};
	
	/// @desc Set how UpdateDelta processes the machine (accumulated ticks or per-frame).
	/// @param {Constant.eStatementUpdateMode} mode One of eStatementUpdateMode.
	/// @return {Struct.Statement}
	static SetUpdateMode = function(_mode) {
		update_mode = __StatementNormalizeUpdateMode(_mode);
		if (update_mode == eStatementUpdateMode.ACCUMULATED) {
			update_accumulator = clamp(update_accumulator, 0, 1);
		} else {
			update_accumulator = 0;
		}
		return self;
	};
	
	/// @desc Get the current update mode for this machine.
	/// @return {Constant.eStatementUpdateMode}
	static GetUpdateMode = function() {
		return update_mode;
	};
	
	/// @ignore
	/// @desc Effective delta time for this machine (time_scale * global scale).
	static __GetEffectiveDelta = function() {
		return max(0, last_effective_dt);
	};
	
	/// @desc Assign a tag (or comma-separated tags) for grouping/filtering in debug UIs.
	/// @param {String} tag
	/// @return {Struct.Statement}
	static DebugTag = function(_tag) {
		if (STATEMENT_DEBUG) {
			debug_tag = _tag;
		}
		return self;
	};
	
	/// @desc Get the debug tag string, if set.
	/// @return {String,Undefined}
	static GetDebugTag = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		return debug_tag;
	};
	
	/// @desc Pause this machine for debug purposes.
	/// @return {Struct.Statement}
	static DebugPause = function() {
		if (STATEMENT_DEBUG) {
			paused = true;
		}
		return self;
	};
	
	/// @desc Resume this machine from a debug pause.
	/// @return {Struct.Statement}
	static DebugResume = function() {
		if (STATEMENT_DEBUG) {
			paused = false;
			
			// Clear breakpoint-triggered markers (so the UI returns to "ready" state).
			var _len = array_length(debug_edges);
			for (var _i = 0; _i < _len; _i++) {
				var _e = debug_edges[_i];
				_e.debug_break_triggered = false;
			}
		}
		return self;
	};
	
	/// @desc Run exactly one Update tick while paused, then re-pause.
	/// @return {Any,Undefined}
	static DebugStep = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		
		var _old_paused = paused;
		var _old_global = variable_global_exists("__statement_debug_pause_all") ? global.__statement_debug_pause_all : false;
		
		paused = false;
		global.__statement_debug_pause_all = false;
		
		var _result = Update();
		
		// Re-apply pause after stepping (always paused after a debug step)
		paused = true;
		if (variable_global_exists("__statement_debug_pause_all")) {
			global.__statement_debug_pause_all = _old_global;
		}
		
		return _result;
	};
	
	/// @desc Get the friendly debug name, or a fallback based on the owner.
	/// @return {String,Undefined}
	static GetDebugName = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		
		if (!is_undefined(debug_name)) {
			return debug_name;
		}
		
		// Fallback: reuse the owner description from DebugDescribe
		return __GetOwnerDebugDesc();
	};
	
	/// @desc Jump to a state from debug tooling, using that state's debug payload if set.
	/// @param {String} name
	/// @param {Bool}   [_force]
	/// @return {Struct.StatementState,Undefined}
	static DebugJumpToState = function(_name, _force = false) {
		if (!STATEMENT_DEBUG) {
			return state;
		}
		
		var _target = GetState(_name);
		if (is_undefined(_target)) {
			return state;
		}
		
		var _payload = _target.debug_default_payload;
		
		return ChangeState(_name, _payload, _force, { via_debug : true });
	};
	
	/// @desc Get a snapshot of this machine's debug graph: states + edges.
	/// @return {Struct,Undefined} A struct { states, edges } or undefined if debug disabled.
	static GetDebugGraph = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		
		if (!debug_enabled) {
			return undefined;
		}
		
		return {
			states : states_array,
			edges  : debug_edges
		};
	};
	
	/// @desc Get the per-state debug stats map.
	/// @return {Struct,Undefined}
	static GetDebugStateStats = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		return debug_state_stats;
	};
	
	/// @desc Get the recent transition history records.
	/// @return {Array,Undefined}
	static GetDebugTransitionHistory = function() {
		if (!STATEMENT_DEBUG) {
			return undefined;
		}
		return debug_transition_history;
	};
	
	/// @desc Clear any recorded transition history entries.
	/// @return {Struct.Statement}
	static ClearDebugTransitionHistory = function() {
		if (STATEMENT_DEBUG) {
			debug_transition_history = [];
		}
		return self;
	};
	
	/// @func DebugSetErrorBehavior(behavior)
	/// @desc Set how the machine reacts to caught errors: PAUSE (default) or RETHROW.
	/// @param {Constant.eStatementErrorBehavior} behavior
	/// @return {Struct.Statement}
	static DebugSetErrorBehavior = function(_behavior) {
		if (STATEMENT_DEBUG) {
			debug_error_behavior = _behavior;
		}
		return self;
	};
	
	/// @func DebugSetLogErrorsToFile(log_to_file)
	/// @desc Control whether caught errors append to debug_statement_errors.log before optional rethrow.
	/// @param {Bool} log_to_file
	/// @return {Struct.Statement}
	static DebugSetLogErrorsToFile = function(_log_to_file) {
		if (STATEMENT_DEBUG) {
			debug_log_errors_to_file = _log_to_file;
		}
		return self;
	};
	
	/// @desc Alias for IsInState.
	/// @param {String,Struct.StatementState} _state_or_state_struct
	/// @return {Bool}
	static IsIn = function(_state_or_state_struct) {
		return IsInState(_state_or_state_struct);
	};
	
	/// @desc Alias for GetStateName.
	/// @return {String,Undefined}
	static GetCurrentStateName = function() {
		return GetStateName();
	};
	
	
}

/// @func StatementState(_id, _name)
/// @desc Creates a state struct bound to the given owner and registered by name.
/// @param {Id.Instance,Struct} _id The instance or struct the state belongs to.
/// @param {String} _name The unique name of the state within its machine.
/// @return {Struct.StatementState}
function StatementState(_id, _name) constructor {
	
	if (!instance_exists(_id) && !is_struct(_id)) {
		EchoDebugSevere($"[STATEMENT] - Trying to create a state without supplying a valid id (supplied id is ${_id})!");
		return undefined;
	}
	
	state_machine	= noone;
	owner			= _id;
	name			= _name;
	template_name	= undefined;
	config			= undefined;
	config_clone	= true;
	state_timer		= 0;
	timer_counter	= undefined;
	state_event		= [];
	can_exit		= true;
	transitions     = [];
	
	// Optional submachine hosting (for hierarchical / nested state machines)
	submachine		= undefined;
	submachine_name	= "";
	on_submachine_enter = undefined;
	on_submachine_exit  = undefined;
	__sub_exit_required_state = undefined;
	__sub_exit_predicate      = undefined;
	
	/// @desc Create and attach a submachine to this state (becoming a host state).
	/// @param {String} [_name] Optional friendly name for this submachine (used for debug UIs).
	/// @return {Struct.Statement}
	static CreateSubMachine = function(_name = undefined) {
		if (!is_undefined(submachine)) {
			return submachine;
		}
		
		submachine = new Statement(owner);
		submachine.auto_enter_first_state = false;
		if (is_instanceof(state_machine, Statement)) {
			submachine.parent_machine = state_machine;
		}
		else {
			submachine.parent_machine = undefined;
		}
		submachine.parent_state = self;
		
		submachine_name = is_undefined(_name) ? name : string(_name);
		return submachine;
	};
	
	/// @desc Returns true if this state currently hosts a submachine.
	/// @return {Bool}
	static HasSubMachine = function() {
		return !is_undefined(submachine);
	};
	
	/// @desc Returns the hosted submachine, if any.
	/// @return {Struct.Statement,Undefined}
	static GetSubMachine = function() {
		return is_undefined(submachine) ? undefined : submachine;
	};
	
	/// @desc Set a callback that runs when this host state enters and its submachine is started/resumed.
	/// @param {Function} _fn function(submachine)
	/// @return {Struct.StatementState}
	static OnSubmachineEnter = function(_fn) {
		on_submachine_enter = is_callable(_fn) ? _fn : undefined;
		return self;
	};
	
	/// @desc Set a callback that runs when this host state exits and its submachine is suspended/stopped.
	/// @param {Function} _fn function(submachine)
	/// @return {Struct.StatementState}
	static OnSubmachineExit = function(_fn) {
		on_submachine_exit = is_callable(_fn) ? _fn : undefined;
		return self;
	};
	
	/// @desc Prevent this host state from exiting (unless forced) until the submachine is in the given state.
	/// @param {String} _state_name
	/// @return {Struct.StatementState}
	static LockExitUntilSubIn = function(_state_name) {
		__sub_exit_predicate = undefined;
		__sub_exit_required_state = string(_state_name);
		return self;
	};
	
	/// @desc Prevent this host state from exiting (unless forced) while the predicate returns false for the submachine.
	/// @param {Function} _fn function(submachine)->Bool
	/// @return {Struct.StatementState}
	static LockExitWhileSubNot = function(_fn) {
		__sub_exit_required_state = undefined;
		__sub_exit_predicate = is_callable(_fn) ? _fn : undefined;
		return self;
	};
	
	if (STATEMENT_DEBUG) {
		debug_manual_links    = [];
		debug_default_payload = undefined;
		debug_break_on_enter  = false;
		debug_tag             = undefined;
		debug_event_names     = {};
	}
	
	/// @ignore
	static __StateSetup = function() {
		var i = -1;
		repeat(eStatementEvents.NUM) {
			++i;
			state_event[i] = -1;
		}
	}
	
	__StateSetup();
	
	/// @desc Sets whether this state allows exiting normally. If it is set to true, exiting the state can happen normally. If set to false then changing out of this state requires the use of the _force argument in the state changing functions
	/// @param {Boolean} can_exit Whether this state can be exited normally or requires force
	/// @return {Struct.StatementState}
	static SetCanExit = function(_can_exit) {
		can_exit = _can_exit;
		return self;
	}
	
	/// @desc Marks this state as non-interruptible (cannot exit unless forced).
	/// @return {Struct.StatementState}
	static LockExit = function() {
		can_exit = false;
		return self;
	}
	
	/// @desc Marks this state as interruptible again.
	/// @return {Struct.StatementState}
	static UnlockExit = function() {
		can_exit = true;
		return self;
	}
	
	/// @desc Sets config data for this state, optionally cloning the input.
	/// @param {Any} config
	/// @param {Bool} [_clone] If set, overrides this state's config_clone default.
	/// @return {Struct.StatementState}
	static SetConfig = function(_config, _clone = undefined) {
		var _do_clone = config_clone;
		if (_clone == true) {
			_do_clone = true;
		}
		else if (_clone == false) {
			_do_clone = false;
		}
		
		if (_do_clone && !is_undefined(_config)) {
			config = variable_clone(_config);
		}
		else {
			config = _config;
		}
		
		return self;
	}
	
	/// @desc Returns this state's config data, if any.
	/// @return {Any,Undefined}
	static GetConfig = function() {
		return config;
	}
	
	/// @ignore
	static __TimerInit = function() {
		if (!time_source_exists(timer_counter)) {
			timer_counter = time_source_create(time_source_game, 1, time_source_units_frames, method(self, function() {
				if (state_machine.paused) {
					return;
				}
				var _dt = state_machine.__GetEffectiveDelta();
				state_timer += _dt;
			}), [], -1);
		}
	}
	
	/// @desc	Starts up the state-specific timer.
	/// @return	{Struct.StatementState}
	static TimerStart = function() {
		if (!is_instanceof(state_machine, Statement)) {
			EchoDebugSevere("[STATEMENT] - TimerStart requires the state to be added to a Statement machine.");
			return self;
		}
		__TimerInit();
		state_timer = 0;
		time_source_start(timer_counter);
		array_push(global.__statement_timers, timer_counter);
		return self;
	}
	
	/// @desc	Sets the state-specific timer to the supplied value.
	/// @param	{Real}	time	The time to set the timer to
	/// @return	{Struct.StatementState}
	static TimerSet = function(_time) {
		state_timer = _time;
		return self;
	}
	
	/// @desc	Gets the current value of the state-specific timer
	/// @return	{Real}
	static TimerGet = function() {
		return state_timer;
	}
	
	/// @desc	Pauses the state-specific timer
	/// @return	{Struct.StatementState}
	static TimerPause = function() {
		if (time_source_exists(timer_counter)) {
			time_source_pause(timer_counter);
		}
		return self;
	}
	
	/// @desc	Restarts the state-specific timer after it has been paused
	/// @return {Struct.StatementState}
	static TimerRestart = function() {
		if (time_source_exists(timer_counter)) {
			time_source_start(timer_counter);
		}
		return self;
	}
	
	/// @desc Kills the state-specific timer (can be recreated with TimerStart())
	/// @return {Struct.StatementState}
	static TimerKill = function() {
		if (time_source_exists(timer_counter)) {
			var i = array_length(global.__statement_timers);
			repeat (i) {
				if (global.__statement_timers[--i] == timer_counter) {
					array_delete(global.__statement_timers, i, 1);
				}
			}
			time_source_destroy(timer_counter, true);
			
		}
		return self;
	}
	
	/// @desc	Binds a function to the owner that the state will run when it becomes the active state
	/// @param	{Function}	function
	/// @return	{Struct.StatementState}
	static AddEnter = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.ENTER, _function, _mode);
	}
	
	/// @desc	Binds a function to the owner that the state will run continuously while active
	/// @param	{Function}	function
	/// @return	{Struct.StatementState}
	static AddUpdate = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.STEP, _function, _mode);
	}
	
	/// @desc	Binds a function to the owner that the state will run when it stops being the active state
	/// @param	{Function}	function
	/// @return	{Struct.StatementState}
	static AddExit = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.EXIT, _function, _mode);
	}
	
	/// @desc	Binds a function to the owner that the state will run continuously while active, intended for the Draw Event
	/// @param	{Function}	function
	/// @return	{Struct.StatementState}
	static AddDraw = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.DRAW, _function, _mode);
	}
	
	/// @desc   Binds a handler function to one of this state's events.
	/// @param  {Real}     event     One of eStateEvents.
	/// @param  {Function} function  The function to call for this event.
	/// @return {Struct.StatementState}
	static AddStateEvent = function(_event, _function, _mode = eStatementBindMode.REPLACE) {
		var _owner_id;
		if (is_struct(owner)) {
			_owner_id = "struct";
		}
		else if (instance_exists(owner)) {
			_owner_id = $"${string(owner.id)} object type ${owner.object_index}";
		}
		else if (owner == noone) {
			_owner_id = "noone";
		}
		else {
			_owner_id = $"${string(owner)} (destroyed instance)";
		}
		
		if (!is_int64(_event)) {
			EchoDebugSevere($"[STATEMENT] - State {name} (from {_owner_id}) is trying to add a state event type that is not an enum!");
			return self;
		}
		
		if (_event < 0 || _event >= eStatementEvents.NUM) {
			EchoDebugSevere($"[STATEMENT] - State {name} (from {_owner_id}) is trying to add a state event with out-of-range index {string(_event)}.");
			return self;
		}
		
		var _self = owner;
		if (instance_exists(owner)) {
			_self = owner.id;
		}
		
		var _bind_mode = _mode;
		if (!is_int64(_bind_mode)) {
			_bind_mode = eStatementBindMode.REPLACE;
		}
		if ((_bind_mode != eStatementBindMode.REPLACE) && (_bind_mode != eStatementBindMode.APPEND) && (_bind_mode != eStatementBindMode.PREPEND)) {
			_bind_mode = eStatementBindMode.REPLACE;
		}
		
		var _handler = method(_self, _function);
		
		if (_bind_mode == eStatementBindMode.REPLACE) {
			state_event[_event] = _handler;
			return self;
		}
		
		var _existing = state_event[_event];
		if (_existing == -1) {
			state_event[_event] = _handler;
			return self;
		}
		
		if (!is_array(_existing)) {
			_existing = [_existing];
		}
		
		if (_bind_mode == eStatementBindMode.APPEND) {
			array_push(_existing, _handler);
		}
		else {
			var _len = array_length(_existing);
			array_resize(_existing, _len + 1);
			for (var _i = _len; _i > 0; _i--) {
				_existing[_i] = _existing[_i - 1];
			}
			_existing[0] = _handler;
		}
		
		state_event[_event] = _existing;
		return self;
	}
	
	/// @desc   Returns whether this state has an implementation for the given event index.
	/// @param  {Real} event  One of eStateEvents.
	/// @return {Bool}
	static HasStateEvent = function(_event) {
		if (_event >= array_length(state_event) || _event < 0) {
			return false;
		}
		var _handler = state_event[_event];
		if (_handler == -1) {
			return false;
		}
		if (is_array(_handler)) {
			return array_length(_handler) > 0;
		}
		return true;
	}
	
	/// @desc   Adds a declarative transition from this state to another state on the same machine.
	///         The condition is evaluated each Update while this state is active; when it returns
	///         true, the state machine will change to the target state.
	/// @param  {String}   target_name  The name of the target state.
	/// @param  {Function} condition    A function on the owner that returns true when the transition should fire. The transition data is passed in as the first argument.
	/// @param  {Any}      [_data]       Transition data you want to pass through to the next state.
	/// @param  {Bool}     [_force]      If true, ignore the current state's can_exit flag when this transition fires.
	/// @return {Struct.StatementState}
	static AddTransition = function(_target_name, _condition, _data = undefined, _force = false) {
		var _owner_id;
		if (is_struct(owner)) {
			_owner_id = "struct";
		}
		else if (instance_exists(owner)) {
			_owner_id = $"${string(owner.id)} object type ${owner.object_index}";
		}
		else if (owner == noone) {
			_owner_id = "noone";
		}
		else {
			_owner_id = $"${string(owner)} (destroyed instance)";
		}
		
		if (!is_string(_target_name)) {
			EchoDebugSevere($"[STATEMENT] - State {name} (from {_owner_id}) is trying to add a transition with a non-string target name!");
			return self;
		}
		
		if (!is_callable(_condition)) {
			EchoDebugSevere($"[STATEMENT] - State {name} (from {_owner_id}) is trying to add a transition with a non-callable condition!");
			return self;
		}
		
		var _record = {
			target_name : _target_name,
			condition   : method(owner, _condition),
			force       : _force,
			data        : _data,
		};
		
		array_push(transitions, _record);
		
		if (STATEMENT_DEBUG) {
			if (is_instanceof(state_machine, Statement) && state_machine.debug_enabled) {
				state_machine.__DebugGetOrCreateEdge(name, _target_name, eStatementDebugEdgeKind.DECLARATIVE);
			}
		}
		
		return self;
	}
	
	/// @desc   Clears all declarative transitions defined on this state.
	/// @return {Struct.StatementState}
	static ClearTransitions = function() {
		transitions = [];
		return self;
	}
	
	/// @desc   Evaluates this state's declarative transitions and returns the first one whose condition is true.
	/// @return {Struct,Undefined} A struct { target_name, condition, force } if a transition should occur, otherwise undefined.
	static EvaluateTransitions = function() {
		var _len = array_length(transitions);
		if (_len <= 0) {
			return undefined;
		}
		
		for (var _i = 0; _i < _len; _i++) {
			var _tr = transitions[_i];
			
			var _cond = _tr.condition;
			
			var _passed = false;
			if (STATEMENT_DEBUG && state_machine.debug_enabled) {
				try {
					_passed = _cond(_tr.data);
				}
				catch (_err_cond) {
					state_machine.__DebugRecordEdgeError(name, _tr.target_name, eStatementDebugEdgeKind.DECLARATIVE, "condition", _err_cond);
					if (state_machine.debug_error_behavior == eStatementErrorBehavior.RETHROW) {
						throw _err_cond;
					}
					return undefined;
				}
			}
			else {
				_passed = _cond(_tr.data);
			}
			
			if (_passed) {
				// Return the full record so the machine can read target_name / force.
				return _tr;
			}
		}
		
		return undefined;
	}
	
	/// @desc Declare a debug-only link from this state to another state for the visualiser.
	/// @param {String} target_name
	/// @return {Struct.StatementState}
	static DebugLinkTo = function(_target_name) {
		if (STATEMENT_DEBUG) {
			if (!is_string(_target_name)) {
				return self;
			}
			
			array_push(debug_manual_links, _target_name);
			
			if (is_instanceof(state_machine, Statement) && state_machine.debug_enabled) {
				state_machine.__DebugGetOrCreateEdge(name, _target_name, eStatementDebugEdgeKind.MANUAL);
			}
		}
		return self;
	};
	
	/// @desc Set a default payload used when jumping to this state via debug tools.
	/// @param {Any} payload
	/// @return {Struct.StatementState}
	static DebugPayload = function(_payload) {
		if (STATEMENT_DEBUG) {
			debug_default_payload = _payload;
		}
		return self;
	};
	
	/// @desc Enable or disable "break on enter" for this state in debug builds.
	/// @param {Bool} [_break_on_enter] Defaults to true.
	/// @return {Struct.StatementState}
	static DebugBreakOnEnter = function(_break_on_enter = true) {
		if (STATEMENT_DEBUG) {
			debug_break_on_enter = _break_on_enter;
		}
		return self;
	};
	
	/// @desc Assign a tag (or comma-separated tags) for grouping/filtering in debug UIs.
	/// @param {String} _tag
	/// @return {Struct.StatementState}
	static DebugTag = function(_tag) {
		if (STATEMENT_DEBUG) {
			debug_tag = _tag;
		}
		return self;
	};
}

/// @func StatementStateTemplate(_name)
/// @desc Defines a reusable template for building StatementState instances.
/// @param {String} _name The template name (used as the default state name).
/// @return {Struct.StatementStateTemplate}
function StatementStateTemplate(_name) constructor {
	if (!is_string(_name)) {
		EchoDebugSevere("[STATEMENT] - Trying to create a state template with a non-string name!");
		return undefined;
	}
	
	name = _name;
	template_event = [];
	transitions = [];
	config_clone = true;
	
	if (STATEMENT_DEBUG) {
		debug_manual_links    = [];
		debug_default_payload = undefined;
		debug_break_on_enter  = false;
		debug_tag             = undefined;
	}
	
	/// @ignore
	static __TemplateSetup = function() {
		var i = -1;
		repeat(eStatementEvents.NUM) {
			++i;
			template_event[i] = -1;
		}
	}
	
	__TemplateSetup();
	
	/// @desc Control whether config is deep-cloned when building states from this template.
	/// @param {Bool} _enabled
	/// @return {Struct.StatementStateTemplate}
	static SetConfigClone = function(_enabled) {
		config_clone = (_enabled == true);
		return self;
	}
	
	/// @desc Bind a handler function to one of this template's events.
	/// @param  {Real}     _event     One of eStatementEvents.
	/// @param  {Function} _function  The function to call for this event.
	/// @return {Struct.StatementStateTemplate}
	static AddStateEvent = function(_event, _function, _mode = eStatementBindMode.REPLACE) {
		if (!is_int64(_event)) {
			EchoDebugSevere($"[STATEMENT] - Template {name} is trying to add a state event type that is not an enum!");
			return self;
		}
		
		if (_event < 0 || _event >= eStatementEvents.NUM) {
			EchoDebugSevere($"[STATEMENT] - Template {name} is trying to add a state event with out-of-range index {string(_event)}.");
			return self;
		}
		
		if (!is_callable(_function)) {
			EchoDebugSevere($"[STATEMENT] - Template {name} is trying to add a state event with a non-callable handler.");
			return self;
		}
		
		var _bind_mode = _mode;
		if (!is_int64(_bind_mode)) {
			_bind_mode = eStatementBindMode.REPLACE;
		}
		if ((_bind_mode != eStatementBindMode.REPLACE) && (_bind_mode != eStatementBindMode.APPEND) && (_bind_mode != eStatementBindMode.PREPEND)) {
			_bind_mode = eStatementBindMode.REPLACE;
		}
		
		if (_bind_mode == eStatementBindMode.REPLACE) {
			template_event[_event] = _function;
			return self;
		}
		
		var _existing = template_event[_event];
		if (_existing == -1) {
			template_event[_event] = _function;
			return self;
		}
		
		if (!is_array(_existing)) {
			_existing = [_existing];
		}
		
		if (_bind_mode == eStatementBindMode.APPEND) {
			array_push(_existing, _function);
		}
		else {
			var _len = array_length(_existing);
			array_resize(_existing, _len + 1);
			for (var _i = _len; _i > 0; _i--) {
				_existing[_i] = _existing[_i - 1];
			}
			_existing[0] = _function;
		}
		
		template_event[_event] = _existing;
		return self;
	}
	
	/// @desc Bind a handler function for the Enter event.
	/// @param {Function} _function
	/// @return {Struct.StatementStateTemplate}
	static AddEnter = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.ENTER, _function, _mode);
	}
	
	/// @desc Bind a handler function for the Update/Step event.
	/// @param {Function} _function
	/// @return {Struct.StatementStateTemplate}
	static AddUpdate = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.STEP, _function, _mode);
	}
	
	/// @desc Bind a handler function for the Exit event.
	/// @param {Function} _function
	/// @return {Struct.StatementStateTemplate}
	static AddExit = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.EXIT, _function, _mode);
	}
	
	/// @desc Bind a handler function for the Draw event.
	/// @param {Function} _function
	/// @return {Struct.StatementStateTemplate}
	static AddDraw = function(_function, _mode = eStatementBindMode.REPLACE) {
		return AddStateEvent(eStatementEvents.DRAW, _function, _mode);
	}
	
	/// @desc   Adds a declarative transition from this template to another state name.
	/// @param  {String}   _target_name  The name of the target state.
	/// @param  {Function} _condition    A function on the owner that returns true when the transition should fire. The transition data is passed in as the first argument.
	/// @param  {Any}      [_data]       Transition data to pass through to the next state.
	/// @param  {Bool}     [_force]      If true, ignore the current state's can_exit flag when this transition fires.
	/// @return {Struct.StatementStateTemplate}
	static AddTransition = function(_target_name, _condition, _data = undefined, _force = false) {
		if (!is_string(_target_name)) {
			EchoDebugSevere($"[STATEMENT] - Template {name} is trying to add a transition with a non-string target name!");
			return self;
		}
		
		if (!is_callable(_condition)) {
			EchoDebugSevere($"[STATEMENT] - Template {name} is trying to add a transition with a non-callable condition!");
			return self;
		}
		
		var _record = {
			target_name : _target_name,
			condition   : _condition,
			force       : _force,
			data        : _data,
		};
		
		array_push(transitions, _record);
		return self;
	}
	
	/// @desc   Clears all declarative transitions defined on this template.
	/// @return {Struct.StatementStateTemplate}
	static ClearTransitions = function() {
		transitions = [];
		return self;
	}
	
	/// @desc Declare a debug-only link from this template to another state for the visualiser.
	/// @param {String} _target_name
	/// @return {Struct.StatementStateTemplate}
	static DebugLinkTo = function(_target_name) {
		if (STATEMENT_DEBUG) {
			if (!is_string(_target_name)) {
				return self;
			}
			
			array_push(debug_manual_links, _target_name);
		}
		return self;
	};
	
	/// @desc Set a default payload used when jumping to this state via debug tools.
	/// @param {Any} _payload
	/// @return {Struct.StatementStateTemplate}
	static DebugPayload = function(_payload) {
		if (STATEMENT_DEBUG) {
			debug_default_payload = _payload;
		}
		return self;
	};
	
	/// @desc Enable or disable "break on enter" for this state in debug builds.
	/// @param {Bool} [_break_on_enter] Defaults to true.
	/// @return {Struct.StatementStateTemplate}
	static DebugBreakOnEnter = function(_break_on_enter = true) {
		if (STATEMENT_DEBUG) {
			debug_break_on_enter = _break_on_enter;
		}
		return self;
	};
	
	/// @desc Assign a tag (or comma-separated tags) for grouping/filtering in debug UIs.
	/// @param {String} _tag
	/// @return {Struct.StatementStateTemplate}
	static DebugTag = function(_tag) {
		if (STATEMENT_DEBUG) {
			debug_tag = _tag;
		}
		return self;
	};
	
	/// @desc Builds a new StatementState instance from this template.
	/// @param {Id.Instance,Struct} _owner The instance or struct the state belongs to.
	/// @param {Any}    [_config] Optional config to assign to the created state.
	/// @param {String} [_name] Optional override for the state's name.
	/// @param {Bool}   [_clone] Optional override for config cloning.
	/// @return {Struct.StatementState,Undefined}
	static Build = function(_owner, _config = undefined, _name = undefined, _clone = undefined) {
		var _state_name = is_undefined(_name) ? name : string(_name);
		var _state = new StatementState(_owner, _state_name);
		if (!is_instanceof(_state, StatementState)) {
			return undefined;
		}
		
		_state.template_name = name;
		_state.config_clone = config_clone;
		
		if (!is_undefined(_config) || !is_undefined(_clone)) {
			_state.SetConfig(_config, _clone);
		}
		
		var i = -1;
		repeat(eStatementEvents.NUM) {
			++i;
			var _event = int64(i);
			var _fn = template_event[i];
			if (_fn != -1) {
				if (is_array(_fn)) {
					var _len2 = array_length(_fn);
					for (var _j = 0; _j < _len2; _j++) {
						_state.AddStateEvent(_event, _fn[_j], eStatementBindMode.APPEND);
					}
				}
				else {
					_state.AddStateEvent(_event, _fn, eStatementBindMode.APPEND);
				}
			}
		}
		
		var _t_len = array_length(transitions);
		for (var t = 0; t < _t_len; t++) {
			var _tr = transitions[t];
			_state.AddTransition(_tr.target_name, _tr.condition, _tr.data, _tr.force);
		}
		
		if (STATEMENT_DEBUG) {
			if (!is_undefined(debug_tag)) {
				_state.DebugTag(debug_tag);
			}
			
			if (!is_undefined(debug_default_payload)) {
				_state.DebugPayload(debug_default_payload);
			}
			
			if (debug_break_on_enter) {
				_state.DebugBreakOnEnter(debug_break_on_enter);
			}
			
			var _l_len = array_length(debug_manual_links);
			for (var l = 0; l < _l_len; l++) {
				var _link = debug_manual_links[l];
				if (is_string(_link)) {
					_state.DebugLinkTo(_link);
				}
			}
		}
		
		return _state;
	};
}

/// @func StatementStateKillTimers()
/// @desc Destroys all state timers registered in the global __statement_timers array.
/// @return {Undefined}
function StatementStateKillTimers() {
	var i = array_length(global.__statement_timers);
	repeat (array_length(global.__statement_timers)) {
		--i;
		if (time_source_exists(global.__statement_timers[i])) {
			time_source_destroy(global.__statement_timers[i], true);
		}
		array_delete(global.__statement_timers, i, 1);
	}
}

global.__statement_timers = [];

/// @func StatementSetDefaultUpdateMode(mode)
/// @desc Sets the global default update mode used by newly created Statement machines.
/// @param {Constant.eStatementUpdateMode} mode One of eStatementUpdateMode.
function StatementSetDefaultUpdateMode(_mode) {
	var _normalized = __StatementNormalizeUpdateMode(_mode);
	global.__statement_default_update_mode = _normalized;
}

/// @func StatementGetDefaultUpdateMode()
/// @desc Returns the global default update mode that future Statement machines will use.
/// @return {Constant.eStatementUpdateMode}
function StatementGetDefaultUpdateMode() {
	if (!variable_global_exists("__statement_default_update_mode")) {
		global.__statement_default_update_mode = eStatementUpdateMode.ACCUMULATED;
	}
	return global.__statement_default_update_mode;
}

/// @ignore
function __StatementNormalizeUpdateMode(_mode) {
	if (_mode == eStatementUpdateMode.PER_FRAME) {
		return eStatementUpdateMode.PER_FRAME;
	}
	return eStatementUpdateMode.ACCUMULATED;
}

/// @ignore
function __StatementNormalizeResetMode(_mode) {
	if (_mode == eStatementResetMode.REMEMBER) {
		return eStatementResetMode.REMEMBER;
	}
	if (_mode == eStatementResetMode.RESET_ON_ENTER) {
		return eStatementResetMode.RESET_ON_ENTER;
	}
	return eStatementResetMode.RESET_ON_EXIT;
}

/// @desc Set global time scale for all Statement machines (multiplies per-machine scale).
/// @param {Real} scale
function StatementSetGlobalTimeScale(_scale) {
	// Use macro to keep consistent
	STATEMENT_TIME_GLOBAL_SCALE = max(0, _scale);
};
