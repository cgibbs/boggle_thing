///@func	FatePityPolicy(opts)
///@param	{Struct}	_opts
///@desc	Pity policy with soft and hard pity behavior driven by per-scope miss counters.
function FatePityPolicy(_opts = undefined) constructor {
	policy_id = __FateNextPolicyId();
	policy_name = "fate_pity";
	policy_priority = 0;
	target_matcher = undefined;
	scope_key_fn = undefined;
	soft_start = 0;
	soft_step = 0;
	hard_at = undefined;
	reset_mode = "target_hit";
	miss_counts = {};

	if (is_struct(_opts)) {
		var _target_matcher = _opts[$ "target_matcher"];
		if (is_callable(_target_matcher)) {
			target_matcher = _target_matcher;
		}
		
		var _scope_key_fn = _opts[$ "scope_key"];
		if (is_callable(_scope_key_fn)) {
			scope_key_fn = _scope_key_fn;
		}
		
		var _soft_start = _opts[$ "soft_start"];
		if (__FateIsFiniteReal(_soft_start)) {
			soft_start = max(0, floor(_soft_start));
		}
		
		var _soft_step = _opts[$ "soft_step"];
		if (__FateIsFiniteReal(_soft_step)) {
			soft_step = max(0, _soft_step);
		}
		
		var _hard_at = _opts[$ "hard_at"];
		if (_hard_at != undefined) {
			if (__FateIsFiniteReal(_hard_at)) {
				hard_at = max(0, floor(_hard_at));
			}
		}
		
		var _reset_mode = _opts[$ "reset_mode"];
		if (is_string(_reset_mode)) {
			if (_reset_mode == "any_hit") {
				reset_mode = _reset_mode;
			}
			else if (_reset_mode == "target_hit") {
				reset_mode = _reset_mode;
			}
			else if (_reset_mode == "never") {
				reset_mode = _reset_mode;
			}
		}
		
		var _policy_name = _opts[$ "policy_name"];
		if (is_string(_policy_name)) {
			if (string_length(_policy_name) > 0) {
				policy_name = _policy_name;
			}
		}
		
		var _policy_priority = _opts[$ "priority"];
		if (__FateIsFiniteReal(_policy_priority)) {
			policy_priority = _policy_priority;
		}
	}
	
	///@ignore
	static __ResolveScopeKey = function(_context) {
		var _scope_key = "global";
		if (is_callable(scope_key_fn)) {
			var _resolved = scope_key_fn(_context);
			if (_resolved != undefined) {
				_scope_key = _resolved;
			}
		}
		return string(_scope_key);
	}
	
	///@ignore
	static __GetMissCount = function(_scope_key_string) {
		var _misses = miss_counts[$ _scope_key_string];
		if (__FateIsFiniteReal(_misses)) {
			return max(0, floor(_misses));
		}
		return 0;
	}
	
	///@ignore
	static __SetMissCount = function(_scope_key_string, _misses) {
		miss_counts[$ _scope_key_string] = max(0, floor(_misses));
	}

	///@ignore
	static __MatchesTarget = function(_entry, _context) {
		if (!is_callable(target_matcher)) {
			return false;
		}
		return __FateSanitizeBool(target_matcher(_entry, _context), false);
	}

	///@ignore
	static __ApplySelectedEntry = function(_scope_key_string, _entry, _context) {
		var _misses = __GetMissCount(_scope_key_string);
		var _matches = __MatchesTarget(_entry, _context);

		if (reset_mode == "any_hit") {
			__SetMissCount(_scope_key_string, 0);
			return;
		}

		if (reset_mode == "target_hit") {
			if (_matches) {
				__SetMissCount(_scope_key_string, 0);
			}
			else {
				__SetMissCount(_scope_key_string, _misses + 1);
			}
			return;
		}

		if (reset_mode == "never") {
			__SetMissCount(_scope_key_string, _misses + 1);
			return;
		}
	}

	static GetPolicyId = function() {
		return policy_id;
	}
	
	static GetPolicyName = function() {
		return policy_name;
	}
	
	static GetPriority = function() {
		return policy_priority;
	}
	
	static ValidateForTable = function(_strictness, _table_id) {
		if (!is_callable(target_matcher)) {
			__FateReport(_strictness, $"FatePityPolicy requires a callable target_matcher on table {_table_id}");
			return false;
		}
		return true;
	}
	
	static ResolveForRoll = function(_context, _event) {
		var _scope_key_string = __ResolveScopeKey(_context);
		var _misses = __GetMissCount(_scope_key_string);
		var _matches = __MatchesTarget(_event.entry, _context);
		
		if (!_matches) {
			return undefined;
		}
		
		if (__FateIsFiniteReal(hard_at)) {
			if (_misses >= hard_at) {
				return {
					hard_force: true,
					selected_via: "pity_hard"
				};
			}
		}
		
		if (soft_step > 0) {
			if (_misses >= soft_start) {
				var _soft_steps = (_misses - soft_start) + 1;
				var _weight_add = soft_step * _soft_steps;
				return {
					weight_add: _weight_add,
					selected_via: "pity_soft"
				};
			}
		}
		
		return undefined;
	}
	
	static OnSelected = function(_context, _event) {
		var _scope_key_string = __ResolveScopeKey(_context);
		__ApplySelectedEntry(_scope_key_string, _event.entry, _context);
	}

	static OnRollFinished = function(_context, _summary) {}

	static GetState = function() {
		return {
			miss_counts: __FateStateSanitizeCountMap(miss_counts)
		};
	}
	
	static SetState = function(_state) {
		if (!is_struct(_state)) {
			return self;
		}
		miss_counts = __FateStateSanitizeCountMap(_state[$ "miss_counts"]);
		return self;
	}

	static ResetScope = function(_scope_key = "global") {
		var _scope_key_string = string(_scope_key);
		__SetMissCount(_scope_key_string, 0);
		return self;
	}

	static ResetAll = function() {
		miss_counts = {};
		return self;
	}
}

///@func	FateDuplicateProtectionPolicy(opts)
///@param	{Struct}	_opts
///@desc	Duplicate protection policy with recent-hit window and penalize or exclude modes.
function FateDuplicateProtectionPolicy(_opts = undefined) constructor {
	policy_id = __FateNextPolicyId();
	policy_name = "fate_duplicate_protection";
	policy_priority = 0;
	entry_key_fn = undefined;
	scope_key_fn = undefined;
	window_size = 0;
	mode = "penalize";
	penalty_mult = 0.25;
	intra_roll_unique = true;
	owned_check_fn = undefined;
	owned_penalty_mult = 0.5;
	history_by_scope = {};
	in_roll_seen_by_scope = {};
	
	if (is_struct(_opts)) {
		var _entry_key = _opts[$ "entry_key"];
		if (is_callable(_entry_key)) {
			entry_key_fn = _entry_key;
		}
		
		var _scope_key = _opts[$ "scope_key"];
		if (is_callable(_scope_key)) {
			scope_key_fn = _scope_key;
		}
		
		var _window = _opts[$ "window"];
		if (__FateIsFiniteReal(_window)) {
			window_size = max(0, floor(_window));
		}
		
		var _mode = _opts[$ "mode"];
		if (is_string(_mode)) {
			if (_mode == "penalize") {
				mode = _mode;
			}
			else if (_mode == "exclude") {
				mode = _mode;
			}
		}
		
		var _penalty_mult = _opts[$ "penalty_mult"];
		if (__FateIsFiniteReal(_penalty_mult)) {
			penalty_mult = max(0, _penalty_mult);
		}
		
		var _intra_roll_unique = _opts[$ "intra_roll_unique"];
		if (is_bool(_intra_roll_unique)) {
			intra_roll_unique = _intra_roll_unique;
		}
		
		var _owned_check = _opts[$ "owned_check"];
		if (is_callable(_owned_check)) {
			owned_check_fn = _owned_check;
		}
		
		var _owned_penalty_mult = _opts[$ "owned_penalty_mult"];
		if (__FateIsFiniteReal(_owned_penalty_mult)) {
			owned_penalty_mult = max(0, _owned_penalty_mult);
		}
		
		var _policy_name = _opts[$ "policy_name"];
		if (is_string(_policy_name)) {
			if (string_length(_policy_name) > 0) {
				policy_name = _policy_name;
			}
		}
		
		var _policy_priority = _opts[$ "priority"];
		if (__FateIsFiniteReal(_policy_priority)) {
			policy_priority = _policy_priority;
		}
	}
	
	///@ignore
	static __ResolveScopeKey = function(_context) {
		var _scope_key = "global";
		if (is_callable(scope_key_fn)) {
			var _resolved = scope_key_fn(_context);
			if (_resolved != undefined) {
				_scope_key = _resolved;
			}
		}
		return string(_scope_key);
	}
	
	///@ignore
	static __ResolveEntryKey = function(_entry, _context) {
		if (!is_callable(entry_key_fn)) {
			return undefined;
		}
		var _raw_key = entry_key_fn(_entry, _context);
		if (_raw_key == undefined) {
			return undefined;
		}
		return string(_raw_key);
	}
	
	///@ignore
	static __GetHistory = function(_scope_key_string) {
		var _history = history_by_scope[$ _scope_key_string];
		if (is_array(_history)) {
			return _history;
		}
		_history = [];
		history_by_scope[$ _scope_key_string] = _history;
		return _history;
	}
	
	///@ignore
	static __TrimHistory = function(_history) {
		if (window_size <= 0) {
			return [];
		}
		var _count = array_length(_history);
		if (_count <= window_size) {
			return _history;
		}
		var _trimmed = [];
		var _start = _count - window_size;
		for (var i = _start; i < _count; i++) {
			array_push(_trimmed, _history[i]);
		}
		return _trimmed;
	}
	
	///@ignore
	static __GetRollSeen = function(_scope_key_string, _roll_id, _create = true) {
		var _scope_rolls = in_roll_seen_by_scope[$ _scope_key_string];
		if (!is_struct(_scope_rolls)) {
			if (!_create) {
				return undefined;
			}
			_scope_rolls = {};
			in_roll_seen_by_scope[$ _scope_key_string] = _scope_rolls;
		}
		var _roll_key = string(_roll_id);
		var _seen = _scope_rolls[$ _roll_key];
		if (is_array(_seen)) {
			return _seen;
		}
		if (!_create) {
			return undefined;
		}
		_seen = [];
		_scope_rolls[$ _roll_key] = _seen;
		return _seen;
	}
	
	///@ignore
	static __ClearRollSeen = function(_scope_key_string, _roll_id) {
		var _scope_rolls = in_roll_seen_by_scope[$ _scope_key_string];
		if (!is_struct(_scope_rolls)) {
			return;
		}
		var _roll_key = string(_roll_id);
		_scope_rolls[$ _roll_key] = undefined;
	}
	
	static GetPolicyId = function() {
		return policy_id;
	}
	
	static GetPolicyName = function() {
		return policy_name;
	}
	
	static GetPriority = function() {
		return policy_priority;
	}
	
	static ValidateForTable = function(_strictness, _table_id) {
		if (!is_callable(entry_key_fn)) {
			__FateReport(_strictness, $"FateDuplicateProtectionPolicy requires a callable entry_key on table {_table_id}");
			return false;
		}
		return true;
	}
	
	static ResolveForRoll = function(_context, _event) {
		var _scope_key_string = __ResolveScopeKey(_context);
		var _entry_key = __ResolveEntryKey(_event.entry, _context);
		var _blocked = false;
		
		if (_entry_key != undefined) {
			var _history = __GetHistory(_scope_key_string);
			if (array_contains(_history, _entry_key)) {
				_blocked = true;
			}
			
			if (intra_roll_unique) {
				if (__FateIsFiniteReal(_event.roll_id)) {
					var _roll_id = floor(_event.roll_id);
					var _seen = __GetRollSeen(_scope_key_string, _roll_id, false);
					if (is_array(_seen)) {
						if (array_contains(_seen, _entry_key)) {
							_blocked = true;
						}
					}
				}
			}
		}
		
		var _hard_exclude = false;
		var _weight_mult = 1;
		var _selected_via = undefined;
		
		if (_blocked) {
			if (mode == "exclude") {
				if (_event.resolved.guaranteed) {
					_selected_via = "guarantee_bypass_dup_protect";
				}
				else {
					_hard_exclude = true;
				}
			}
			else if (mode == "penalize") {
				_weight_mult *= penalty_mult;
			}
		}
		
		if (is_callable(owned_check_fn)) {
			var _owned = __FateSanitizeBool(owned_check_fn(_event.entry, _context), false);
			if (_owned) {
				_weight_mult *= owned_penalty_mult;
			}
		}
		
		var _has_weight_mult = (_weight_mult != 1);
		if (_hard_exclude || _has_weight_mult || _selected_via != undefined) {
			return {
				hard_exclude: _hard_exclude,
				weight_mult: _weight_mult,
				selected_via: _selected_via
			};
		}
		
		return undefined;
	}
	
	static OnSelected = function(_context, _event) {
		if (!intra_roll_unique) {
			return;
		}
		if (!__FateIsFiniteReal(_event.roll_id)) {
			return;
		}
		var _scope_key_string = __ResolveScopeKey(_context);
		var _entry_key = __ResolveEntryKey(_event.entry, _context);
		if (_entry_key == undefined) {
			return;
		}
		var _roll_id = floor(_event.roll_id);
		var _seen = __GetRollSeen(_scope_key_string, _roll_id, true);
		if (!array_contains(_seen, _entry_key)) {
			array_push(_seen, _entry_key);
		}
	}
	
	static OnRollFinished = function(_context, _summary) {
		var _scope_key_string = __ResolveScopeKey(_context);
		var _history = __GetHistory(_scope_key_string);
		for (var i = 0; i < array_length(_summary.selected_events); i++) {
			var _selected_event = _summary.selected_events[i];
			var _entry_key = __ResolveEntryKey(_selected_event.entry, _context);
			if (_entry_key != undefined) {
				array_push(_history, _entry_key);
			}
		}
		
		_history = __TrimHistory(_history);
		history_by_scope[$ _scope_key_string] = _history;
		
		if (__FateIsFiniteReal(_summary.roll_id)) {
			if (_summary.nested_depth == 0) {
				var _roll_id = floor(_summary.roll_id);
				__ClearRollSeen(_scope_key_string, _roll_id);
			}
		}
	}
	
	static GetState = function() {
		var _history = {};
		var _scope_keys = struct_get_names(history_by_scope);
		for (var i = 0; i < array_length(_scope_keys); i++) {
			var _scope_key = _scope_keys[i];
			var _values = history_by_scope[$ _scope_key];
			if (is_array(_values)) {
				_history[$ _scope_key] = variable_clone(_values);
			}
		}
		return {
			history_by_scope: _history
		};
	}
	
	static SetState = function(_state) {
		if (!is_struct(_state)) {
			return self;
		}
		history_by_scope = __FateStateSanitizeStringArrayMap(_state[$ "history_by_scope"], window_size);
		in_roll_seen_by_scope = {};
		return self;
	}
	
	static ResetScope = function(_scope_key = "global") {
		var _scope_key_string = string(_scope_key);
		history_by_scope[$ _scope_key_string] = [];
		in_roll_seen_by_scope[$ _scope_key_string] = {};
		return self;
	}
	
	static ResetAll = function() {
		history_by_scope = {};
		in_roll_seen_by_scope = {};
		return self;
	}
}

///@func	FateBatchGuaranteePolicy(opts)
///@param	{Struct}	_opts
///@desc	Batch guarantee policy that boosts matcher odds and can hard force when every slot must match.
function FateBatchGuaranteePolicy(_opts = undefined) constructor {
	policy_id = __FateNextPolicyId();
	policy_name = "fate_batch_guarantee";
	policy_priority = 0;
	matcher_fn = undefined;
	min_count = 1;
	only_when_roll_count_at_least = 2;
	soft_mult = 1;
	allow_bypass_filters = true;
	call_state = {};
	
	if (is_struct(_opts)) {
		var _matcher = _opts[$ "matcher"];
		if (is_callable(_matcher)) {
			matcher_fn = _matcher;
		}
		
		var _min_count = _opts[$ "min_count"];
		if (__FateIsFiniteReal(_min_count)) {
			min_count = max(0, floor(_min_count));
		}
		
		var _roll_count_min = _opts[$ "only_when_roll_count_at_least"];
		if (__FateIsFiniteReal(_roll_count_min)) {
			only_when_roll_count_at_least = max(0, floor(_roll_count_min));
		}
		
		var _soft_mult = _opts[$ "soft_mult"];
		if (__FateIsFiniteReal(_soft_mult)) {
			soft_mult = max(0, _soft_mult);
		}
		
		var _allow_bypass = _opts[$ "allow_bypass_filters"];
		if (is_bool(_allow_bypass)) {
			allow_bypass_filters = _allow_bypass;
		}
		
		var _policy_name = _opts[$ "policy_name"];
		if (is_string(_policy_name)) {
			if (string_length(_policy_name) > 0) {
				policy_name = _policy_name;
			}
		}
		
		var _policy_priority = _opts[$ "priority"];
		if (__FateIsFiniteReal(_policy_priority)) {
			policy_priority = _policy_priority;
		}
	}
	
	///@ignore
	static __Matches = function(_entry, _context) {
		if (!is_callable(matcher_fn)) {
			return false;
		}
		return __FateSanitizeBool(matcher_fn(_entry, _context), false);
	}
	
	///@ignore
	static __CallStateKey = function(_roll_id, _table_call_id) {
		return $"{_roll_id}|{_table_call_id}";
	}
	
	///@ignore
	static __GetCallState = function(_roll_id, _table_call_id) {
		var _key = __CallStateKey(_roll_id, _table_call_id);
		var _state = call_state[$ _key];
		if (is_struct(_state)) {
			return _state;
		}
		_state = {
			matched_so_far: 0
		};
		call_state[$ _key] = _state;
		return _state;
	}

	///@ignore
	static __GetMatchedSoFar = function(_roll_id, _table_call_id) {
		var _key = __CallStateKey(_roll_id, _table_call_id);
		var _state = call_state[$ _key];
		if (!is_struct(_state)) {
			return 0;
		}
		var _matched = _state[$ "matched_so_far"];
		if (__FateIsFiniteReal(_matched)) {
			return max(0, floor(_matched));
		}
		return 0;
	}

	static GetPolicyId = function() {
		return policy_id;
	}
	
	static GetPolicyName = function() {
		return policy_name;
	}
	
	static GetPriority = function() {
		return policy_priority;
	}
	
	static ValidateForTable = function(_strictness, _table_id) {
		if (!is_callable(matcher_fn)) {
			__FateReport(_strictness, $"FateBatchGuaranteePolicy requires a callable matcher on table {_table_id}");
			return false;
		}
		return true;
	}
	
	static ResolveForRoll = function(_context, _event) {
		if (!__Matches(_event.entry, _context)) {
			return undefined;
		}
		
		var _requested_count = max(0, floor(_event.requested_count));
		if (_requested_count < only_when_roll_count_at_least) {
			return undefined;
		}
		
		var _need = min_count;
		if (_need <= 0) {
			return undefined;
		}

		if (!__FateIsFiniteReal(_event.roll_id)) {
			return undefined;
		}
		if (!__FateIsFiniteReal(_event.table_call_id)) {
			return undefined;
		}

		var _roll_id = floor(_event.roll_id);
		var _table_call_id = floor(_event.table_call_id);
		var _matched_so_far = __GetMatchedSoFar(_roll_id, _table_call_id);
		var _need_remaining = max(0, _need - _matched_so_far);

		if (_need_remaining <= 0) {
			return undefined;
		}

		var _slots_remaining = max(0, floor(_event.slots_remaining_including_current));
		if (_slots_remaining <= 0) {
			return undefined;
		}

		if (allow_bypass_filters) {
			if (_need_remaining >= _slots_remaining) {
				return {
					hard_force: true,
					selected_via: "batch_guarantee_hard"
				};
			}
		}
		
		if (soft_mult != 1) {
			return {
				weight_mult: soft_mult
			};
		}
		
		return undefined;
	}
	
	static OnSelected = function(_context, _event) {
		if (!__FateIsFiniteReal(_event.roll_id)) {
			return;
		}
		if (!__FateIsFiniteReal(_event.table_call_id)) {
			return;
		}
		var _roll_id = floor(_event.roll_id);
		var _table_call_id = floor(_event.table_call_id);
		var _state = __GetCallState(_roll_id, _table_call_id);
		if (__Matches(_event.entry, _context)) {
			_state.matched_so_far++;
		}
	}
	
	static OnRollFinished = function(_context, _summary) {
		var _key = __CallStateKey(_summary.roll_id, _summary.table_call_id);
		call_state[$ _key] = undefined;
	}
	
	static GetState = function() {
		return {};
	}
	
	static SetState = function(_state) {
		call_state = {};
		return self;
	}
	
	static ResetAll = function() {
		call_state = {};
		return self;
	}
}

///@func	FateFeaturedRateUpPolicy(opts)
///@param	{Struct}	_opts
///@desc	Featured rate-up policy with soft multiplier and optional hard featured guarantee.
function FateFeaturedRateUpPolicy(_opts = undefined) constructor {
	policy_id = __FateNextPolicyId();
	policy_name = "fate_featured_rate_up";
	policy_priority = 0;
	is_featured_fn = undefined;
	scope_key_fn = undefined;
	rate_up_mult = 1;
	hard_at = undefined;
	reset_mode = "featured_hit";
	miss_counts = {};

	if (is_struct(_opts)) {
		var _is_featured = _opts[$ "is_featured"];
		if (is_callable(_is_featured)) {
			is_featured_fn = _is_featured;
		}
		
		var _scope_key = _opts[$ "scope_key"];
		if (is_callable(_scope_key)) {
			scope_key_fn = _scope_key;
		}
		
		var _rate_up_mult = _opts[$ "rate_up_mult"];
		if (__FateIsFiniteReal(_rate_up_mult)) {
			rate_up_mult = max(0, _rate_up_mult);
		}
		
		var _hard_at = _opts[$ "hard_at"];
		if (_hard_at != undefined) {
			if (__FateIsFiniteReal(_hard_at)) {
				hard_at = max(0, floor(_hard_at));
			}
		}
		
		var _policy_priority = _opts[$ "priority"];
		if (__FateIsFiniteReal(_policy_priority)) {
			policy_priority = _policy_priority;
		}
		
		var _reset_mode = _opts[$ "reset_mode"];
		if (is_string(_reset_mode)) {
			if (_reset_mode == "featured_hit") {
				reset_mode = _reset_mode;
			}
			else if (_reset_mode == "any_hit") {
				reset_mode = _reset_mode;
			}
			else if (_reset_mode == "never") {
				reset_mode = _reset_mode;
			}
		}
		
		var _policy_name = _opts[$ "policy_name"];
		if (is_string(_policy_name)) {
			if (string_length(_policy_name) > 0) {
				policy_name = _policy_name;
			}
		}
	}
	
	///@ignore
	static __ResolveScopeKey = function(_context) {
		var _scope_key = "global";
		if (is_callable(scope_key_fn)) {
			var _resolved = scope_key_fn(_context);
			if (_resolved != undefined) {
				_scope_key = _resolved;
			}
		}
		return string(_scope_key);
	}
	
	///@ignore
	static __IsFeatured = function(_entry, _context) {
		if (!is_callable(is_featured_fn)) {
			return false;
		}
		return __FateSanitizeBool(is_featured_fn(_entry, _context), false);
	}
	
	///@ignore
	static __GetMissCount = function(_scope_key_string) {
		var _misses = miss_counts[$ _scope_key_string];
		if (__FateIsFiniteReal(_misses)) {
			return max(0, floor(_misses));
		}
		return 0;
	}
	
	///@ignore
	static __SetMissCount = function(_scope_key_string, _misses) {
		miss_counts[$ _scope_key_string] = max(0, floor(_misses));
	}

	///@ignore
	static __ApplySelectedEntry = function(_scope_key_string, _entry, _context) {
		var _misses = __GetMissCount(_scope_key_string);
		var _is_featured = __IsFeatured(_entry, _context);

		if (reset_mode == "any_hit") {
			__SetMissCount(_scope_key_string, 0);
			return;
		}

		if (reset_mode == "featured_hit") {
			if (_is_featured) {
				__SetMissCount(_scope_key_string, 0);
			}
			else {
				__SetMissCount(_scope_key_string, _misses + 1);
			}
			return;
		}

		if (reset_mode == "never") {
			__SetMissCount(_scope_key_string, _misses + 1);
			return;
		}
	}

	static GetPolicyId = function() {
		return policy_id;
	}
	
	static GetPolicyName = function() {
		return policy_name;
	}
	
	static GetPriority = function() {
		return policy_priority;
	}
	
	static ValidateForTable = function(_strictness, _table_id) {
		if (!is_callable(is_featured_fn)) {
			__FateReport(_strictness, $"FateFeaturedRateUpPolicy requires a callable is_featured on table {_table_id}");
			return false;
		}
		return true;
	}
	
	static ResolveForRoll = function(_context, _event) {
		var _scope_key_string = __ResolveScopeKey(_context);
		var _misses = __GetMissCount(_scope_key_string);
		var _is_featured = __IsFeatured(_event.entry, _context);
		
		if (!_is_featured) {
			return undefined;
		}
		
		if (__FateIsFiniteReal(hard_at)) {
			if (_misses >= hard_at) {
				return {
					hard_force: true,
					selected_via: "featured_hard"
				};
			}
		}
		
		if (rate_up_mult != 1) {
			return {
				weight_mult: rate_up_mult,
				selected_via: "featured_rate_up"
			};
		}
		
		return undefined;
	}
	
	static OnSelected = function(_context, _event) {
		var _scope_key_string = __ResolveScopeKey(_context);
		__ApplySelectedEntry(_scope_key_string, _event.entry, _context);
	}

	static OnRollFinished = function(_context, _summary) {}

	static GetState = function() {
		return {
			miss_counts: __FateStateSanitizeCountMap(miss_counts)
		};
	}
	
	static SetState = function(_state) {
		if (!is_struct(_state)) {
			return self;
		}
		miss_counts = __FateStateSanitizeCountMap(_state[$ "miss_counts"]);
		return self;
	}

	static ResetScope = function(_scope_key = "global") {
		var _scope_key_string = string(_scope_key);
		__SetMissCount(_scope_key_string, 0);
		return self;
	}

	static ResetAll = function() {
		miss_counts = {};
		return self;
	}
}

///@ignore
function __FateCreatePolicyRecord(_policy, _registration_order, _strictness, _table_id) {
	if (!is_struct(_policy)) {
		__FateReport(_strictness, $"Fate.AddPolicy rejected non-policy value on table {_table_id}");
		return undefined;
	}
	
	if (!is_callable(_policy[$ "ResolveForRoll"])) {
		__FateReport(_strictness, $"Fate.AddPolicy rejected policy without ResolveForRoll on table {_table_id}");
		return undefined;
	}

	if (!is_callable(_policy[$ "OnSelected"])) {
		__FateReport(_strictness, $"Fate.AddPolicy rejected policy without OnSelected on table {_table_id}");
		return undefined;
	}

	if (!is_callable(_policy[$ "OnRollFinished"])) {
		__FateReport(_strictness, $"Fate.AddPolicy rejected policy without OnRollFinished on table {_table_id}");
		return undefined;
	}

	if (is_callable(_policy[$ "ValidateForTable"])) {
		var _valid = _policy.ValidateForTable(_strictness, _table_id);
		if (!is_bool(_valid)) {
			__FateReport(_strictness, $"Fate.AddPolicy received invalid ValidateForTable return value on table {_table_id}");
			return undefined;
		}
		if (!_valid) {
			return undefined;
		}
	}

	var _policy_id = undefined;
	if (is_callable(_policy[$ "GetPolicyId"])) {
		var _id_value = _policy.GetPolicyId();
		if (__FateIsFiniteReal(_id_value)) {
			_policy_id = floor(_id_value);
		}
		else {
			__FateReport(_strictness, $"Fate.AddPolicy received invalid GetPolicyId return value on table {_table_id}");
		}
	}
	_policy_id ??= __FateNextPolicyId();

	var _policy_name = undefined;
	if (is_callable(_policy[$ "GetPolicyName"])) {
		var _name_value = _policy.GetPolicyName();
		if (is_string(_name_value)) {
			_policy_name = _name_value;
		}
		else {
			__FateReport(_strictness, $"Fate.AddPolicy received invalid GetPolicyName return value on table {_table_id}");
		}
	}
	_policy_name ??= $"policy_{_policy_id}";

	var _policy_priority = 0;
	if (is_callable(_policy[$ "GetPriority"])) {
		var _priority_value = _policy.GetPriority();
		if (__FateIsFiniteReal(_priority_value)) {
			_policy_priority = _priority_value;
		}
		else {
			__FateReport(_strictness, $"Fate.AddPolicy received invalid GetPriority return value on table {_table_id}");
		}
	}
	
	return {
		policy: _policy,
		policy_id: _policy_id,
		policy_name: _policy_name,
		policy_priority: _policy_priority,
		registration_order: _registration_order
	};
}

///@ignore
function __FateSanitizePolicyDirective(_directive, _strictness, _table_id, _table_call_id, _policy_name) {
	var _invalid_fields = 0;
	var _hard_force = false;
	var _hard_exclude = false;
	var _weight_mult = 1;
	var _weight_add = 0;
	var _weight_override = undefined;
	var _selected_via = undefined;
	
	var _raw_hard_force = _directive[$ "hard_force"];
	if (_raw_hard_force != undefined) {
		if (is_bool(_raw_hard_force)) {
			_hard_force = _raw_hard_force;
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid hard_force directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	var _raw_hard_exclude = _directive[$ "hard_exclude"];
	if (_raw_hard_exclude != undefined) {
		if (is_bool(_raw_hard_exclude)) {
			_hard_exclude = _raw_hard_exclude;
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid hard_exclude directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	var _raw_weight_mult = _directive[$ "weight_mult"];
	if (_raw_weight_mult != undefined) {
		if (__FateIsFiniteReal(_raw_weight_mult)) {
			if (_raw_weight_mult >= 0) {
				_weight_mult = _raw_weight_mult;
			}
			else {
				_invalid_fields++;
				__FateReport(_strictness, $"Fate policy {_policy_name} returned negative weight_mult directive on table {_table_id}, call {_table_call_id}");
			}
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid weight_mult directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	var _raw_weight_add = _directive[$ "weight_add"];
	if (_raw_weight_add != undefined) {
		if (__FateIsFiniteReal(_raw_weight_add)) {
			_weight_add = _raw_weight_add;
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid weight_add directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	var _raw_weight_override = _directive[$ "weight_override"];
	if (_raw_weight_override != undefined) {
		if (__FateIsFiniteReal(_raw_weight_override)) {
			if (_raw_weight_override >= 0) {
				_weight_override = _raw_weight_override;
			}
			else {
				_invalid_fields++;
				__FateReport(_strictness, $"Fate policy {_policy_name} returned negative weight_override directive on table {_table_id}, call {_table_call_id}");
			}
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid weight_override directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	var _raw_selected_via = _directive[$ "selected_via"];
	if (_raw_selected_via != undefined) {
		if (is_string(_raw_selected_via)) {
			if (string_length(_raw_selected_via) > 0) {
				_selected_via = _raw_selected_via;
			}
			else {
				_invalid_fields++;
				__FateReport(_strictness, $"Fate policy {_policy_name} returned empty selected_via directive on table {_table_id}, call {_table_call_id}");
			}
		}
		else {
			_invalid_fields++;
			__FateReport(_strictness, $"Fate policy {_policy_name} returned invalid selected_via directive on table {_table_id}, call {_table_call_id}");
		}
	}
	
	return {
		hard_force: _hard_force,
		hard_exclude: _hard_exclude,
		weight_mult: _weight_mult,
		weight_add: _weight_add,
		weight_override: _weight_override,
		selected_via: _selected_via,
		invalid_fields: _invalid_fields
	};
}
