/*********************************************************************************************************

FATE v1.0.1 by RefresherTowel Games

Docs: https://refreshertowel.github.io/docs/fate/
Discord: https://discord.gg/tafsfNAzWm
More Libraries: https://refreshertowel.itch.io/
Fate's Itch Page: https://refreshertowel.itch.io/fate

Fate is a weighted drop system built to scale from small beginner projects to complex production-quality
games. With inbuilt presets to get you started and advanced customization to allow you to bend Fate
into any shape you want, I'm hoping it will be helpful to everyone.

Be sure to check out the documentation, as I have tried to make it thorough and it should guide you
through the process of learning how to use Fate from beginner to advanced level.

If you like Fate, consider checking out my other libraries, I'm sure there's something else
you'll be able to find that'll help you make your games even faster!

Oh, and don't forget to leave a rating and a review on Fate's itch page if you enjoy using it,
and be sure to follow me on itch to stay up to date with all the libraries I make!

**********************************************************************************************************/

///@func	FateEntry()
///@desc	Base Fate entry with weight and hook lifecycle support.
function FateEntry() constructor {
	static __entry_counter = 0;
	__entry_counter++;
	entry_id = __entry_counter;
	insertion_order = -1;
	enabled = true;
	weight = 1;
	guaranteed = false;
	guaranteed_priority = 0;
	unique = false;
	unique_key = undefined;
	
	static SetEnabled = function(_enabled = true) {
		enabled = __FateSanitizeBool(_enabled, false);
		return self;
	}
	
	static GetEnabled = function() {
		return enabled;
	}
	
	static SetWeight = function(_weight) {
		weight = __FateSanitizeWeight(_weight, 0);
		return self;
	}
	
	static GetWeight = function() {
		return weight;
	}
	
	static SetGuaranteed = function(_guaranteed = true) {
		guaranteed = __FateSanitizeBool(_guaranteed, false);
		return self;
	}
	
	static GetGuaranteed = function() {
		return guaranteed;
	}
	
	static SetGuaranteedPriority = function(_priority = 0) {
		guaranteed_priority = __FateSanitizePriority(_priority, 0);
		return self;
	}
	
	static GetGuaranteedPriority = function() {
		return guaranteed_priority;
	}
	
	static SetUnique = function(_unique = true) {
		unique = __FateSanitizeBool(_unique, false);
		return self;
	}
	
	static GetUnique = function() {
		return unique;
	}
	
	static SetUniqueKey = function(_key = undefined) {
		unique_key = _key;
		return self;
	}
	
	static GetUniqueKey = function() {
		return unique_key;
	}
	
	static ResolveForRoll = function(_context) {
		return {
			enabled: enabled,
			weight: weight,
			guaranteed: guaranteed,
			guaranteed_priority: guaranteed_priority,
			unique: unique,
			unique_key: unique_key
		};
	}
	
	static OnSelected = function(_context, _event) {}
	
	static OnRollFinished = function(_context, _summary) {}
	
	///@ignore
	static __SetInsertionOrder = function(_order) {
		insertion_order = _order;
		return self;
	}
}

///@func	FateTable(entries)
///@param	{Array<Struct.FateEntry>}	_entries
///@desc	Weighted selection table with guaranteed, uniqueness, and hook support.
function FateTable(_entries = []) : FateEntry() constructor {
	static __table_counter = 0;
	__table_counter++;
	table_id = __table_counter;
	entries = [];
	_next_insertion_order = 0;
	strictness_mode = FateStrictness.DEBUG;
	construct_entries = true;
	last_roll_diagnostics = {};
	policies = [];
	_next_policy_order = 0;
	
	static SetStrictness = function(_mode) {
		strictness_mode = __FateSanitizeStrictness(_mode, FateStrictness.DEBUG);
		return self;
	}
	
	static GetStrictness = function() {
		return strictness_mode;
	}
	
	static SetConstructEntries = function(_construct = true) {
		construct_entries = __FateSanitizeBool(_construct, false);
		return self;
	}
	
	static GetConstructEntries = function() {
		return construct_entries;
	}
	
	static GetTableId = function() {
		return table_id;
	}
	
	static GetLastRollDiagnostics = function() {
		return last_roll_diagnostics;
	}
	
	static AddEntry = function(_entry) {
		if (!is_instanceof(_entry, FateEntry)) {
			__FateReport(strictness_mode, $"Fate.AddEntry rejected non FateEntry on table {table_id}");
			return self;
		}
		if (is_instanceof(_entry, FateTable)) {
			__FateReport(strictness_mode, $"Fate.AddEntry rejected direct FateTable on table {table_id}. Wrap nested tables with FateTableEntry.");
			return self;
		}
		_entry.__SetInsertionOrder(_next_insertion_order);
		_next_insertion_order++;
		array_push(entries, _entry);
		return self;
	}
	
	static ClearEntries = function() {
		array_resize(entries, 0);
		_next_insertion_order = 0;
		return self;
	}
	
	static GetEntries = function() {
		var _count = array_length(entries);
		var _copy = array_create(_count);
		for (var i = 0; i < _count; i++) {
			_copy[i] = entries[i];
		}
		return _copy;
	}
	
	static AddPolicy = function(_policy) {
		var _policy_record = __FateCreatePolicyRecord(_policy, _next_policy_order, strictness_mode, table_id);
		if (_policy_record == undefined) {
			return self;
		}
		array_push(policies, _policy_record);
		_next_policy_order++;
		return self;
	}
	
	static ClearPolicies = function() {
		array_resize(policies, 0);
		_next_policy_order = 0;
		return self;
	}
	
	static GetPolicies = function() {
		var _count = array_length(policies);
		var _copy = array_create(_count);
		for (var i = 0; i < _count; i++) {
			_copy[i] = policies[i].policy;
		}
		return _copy;
	}
	
	static EnablePity = function(_target_entries, _hard_at = 90, _soft_start = 75, _soft_step = 0.06, _scope_context_key = undefined) {
		var _target_matcher = __FateBeginnerResolveEntryMatcherMethod(_target_entries, strictness_mode, table_id, "Fate.EnablePity", "target_entries");
		if (!is_callable(_target_matcher)) {
			return self;
		}
		
		var _scope_key_fn = __FateBeginnerResolveScopeKeyMethod(_scope_context_key, strictness_mode, table_id, "Fate.EnablePity");
		var _policy_opts = {
			target_matcher: _target_matcher,
			hard_at: __FateSanitizeRollCount(_hard_at, 90),
			soft_start: __FateSanitizeRollCount(_soft_start, 75),
			soft_step: __FateSanitizeWeight(_soft_step, 0.06)
		};
		if (_scope_key_fn != undefined) {
			_policy_opts.scope_key = _scope_key_fn;
		}
		
		AddPolicy(new FatePityPolicy(_policy_opts));
		return self;
	}
	
	static EnableRateUp = function(_featured_entries, _rate_up_mult = 1.5, _hard_at = undefined, _reset_on_any_hit = false, _scope_context_key = undefined) {
		var _is_featured = __FateBeginnerResolveEntryMatcherMethod(_featured_entries, strictness_mode, table_id, "Fate.EnableRateUp", "featured_entries");
		if (!is_callable(_is_featured)) {
			return self;
		}
		
		var _hard_at_value = undefined;
		if (_hard_at != undefined) {
			if (__FateIsFiniteReal(_hard_at)) {
				_hard_at_value = max(0, floor(_hard_at));
			}
			else {
				__FateReport(strictness_mode, $"Fate.EnableRateUp ignored invalid hard_at on table {table_id}");
			}
		}
		
		var _scope_key_fn = __FateBeginnerResolveScopeKeyMethod(_scope_context_key, strictness_mode, table_id, "Fate.EnableRateUp");
		var _policy_opts = {
			is_featured: _is_featured,
			rate_up_mult: __FateSanitizeWeight(_rate_up_mult, 1.5),
			hard_at: _hard_at_value,
			reset_mode: __FateSanitizeBool(_reset_on_any_hit, false) ? "any_hit" : "featured_hit"
		};
		if (_scope_key_fn != undefined) {
			_policy_opts.scope_key = _scope_key_fn;
		}
		
		AddPolicy(new FateFeaturedRateUpPolicy(_policy_opts));
		return self;
	}
	
	static EnableDuplicateProtection = function(_window = 1, _mode = "penalize", _penalty_mult = 0.25, _key_mode = "entry_id", _intra_roll_unique = true) {
		var _mode_value = "penalize";
		if (is_string(_mode)) {
			if (_mode == "penalize") {
				_mode_value = _mode;
			}
			else if (_mode == "exclude") {
				_mode_value = _mode;
			}
			else {
				__FateReport(strictness_mode, $"Fate.EnableDuplicateProtection received invalid mode on table {table_id}; expected penalize or exclude");
			}
		}
		else if (_mode != undefined) {
			__FateReport(strictness_mode, $"Fate.EnableDuplicateProtection received invalid mode type on table {table_id}");
		}
		
		var _entry_key = __FateBeginnerResolveDuplicateKeyMethod(_key_mode, strictness_mode, table_id, "Fate.EnableDuplicateProtection");
		if (!is_callable(_entry_key)) {
			return self;
		}
		
		var _policy_opts = {
			entry_key: _entry_key,
			window: __FateSanitizeRollCount(_window, 1),
			mode: _mode_value,
			penalty_mult: __FateSanitizeWeight(_penalty_mult, 0.25),
			intra_roll_unique: __FateSanitizeBool(_intra_roll_unique, true)
		};
		AddPolicy(new FateDuplicateProtectionPolicy(_policy_opts));
		return self;
	}
	
	static EnableBatchGuarantee = function(_target_entries, _min_count = 1, _roll_count_at_least = 10, _soft_mult = 1, _allow_bypass_filters = true) {
		var _matcher = __FateBeginnerResolveEntryMatcherMethod(_target_entries, strictness_mode, table_id, "Fate.EnableBatchGuarantee", "target_entries");
		if (!is_callable(_matcher)) {
			return self;
		}
		
		var _policy_opts = {
			matcher: _matcher,
			min_count: __FateSanitizeRollCount(_min_count, 1),
			only_when_roll_count_at_least: __FateSanitizeRollCount(_roll_count_at_least, 10),
			soft_mult: __FateSanitizeWeight(_soft_mult, 1),
			allow_bypass_filters: __FateSanitizeBool(_allow_bypass_filters, true)
		};
		AddPolicy(new FateBatchGuaranteePolicy(_policy_opts));
		return self;
	}
	
	static EnableTenPullGuarantee = function(_target_entries, _min_count = 1, _soft_mult = 1, _allow_bypass_filters = true, _roll_count = 10) {
		return EnableBatchGuarantee(_target_entries, _min_count, _roll_count, _soft_mult, _allow_bypass_filters);
	}
	
	static EnableStandardGachaRules = function(_five_star_entries, _featured_entries = undefined, _pity_hard_at = 90, _pity_soft_start = 75, _rate_up_mult = 1.5) {
		var _policy_count_before = array_length(policies);
		EnablePity(_five_star_entries, _pity_hard_at, _pity_soft_start, 0, undefined);
		if (array_length(policies) <= _policy_count_before) {
			return self;
		}
		
		if (_featured_entries != undefined) {
			EnableRateUp(_featured_entries, _rate_up_mult, undefined, false, undefined);
		}
		return self;
	}
	
	static ValidateConfig = function(_opts = undefined) {
		var _report = __FateValidationCreateReport(table_id);
		
		for (var i = 0; i < array_length(entries); i++) {
			var _entry = entries[i];
			if (!is_instanceof(_entry, FateEntry)) {
				__FateValidationAddIssue(_report, "error", "table_config_entry_not_fate_entry", $"entries[{i}]", "Entry is not a FateEntry", table_id, undefined, undefined);
				continue;
			}
			if (is_instanceof(_entry, FateTable)) {
				__FateValidationAddIssue(_report, "error", "table_config_entry_direct_table", $"entries[{i}]", "Direct FateTable entries are not allowed", table_id, undefined, undefined);
			}
		}
		
		for (var i = 0; i < array_length(policies); i++) {
			var _policy_record = policies[i];
			var _policy = _policy_record.policy;
			var _policy_name = _policy_record.policy_name;
			var _path = $"policies[{i}]";
			
			if (!is_struct(_policy)) {
				__FateValidationAddIssue(_report, "error", "policy_config_not_struct", _path, "Policy value is not a struct", table_id, i, _policy_name);
				continue;
			}
			
			var _resolve = _policy[$ "ResolveForRoll"];
			if (!is_callable(_resolve)) {
				__FateValidationAddIssue(_report, "error", "policy_config_missing_resolve", $"{_path}.ResolveForRoll", "Policy is missing ResolveForRoll", table_id, i, _policy_name);
			}
			
			var _selected = _policy[$ "OnSelected"];
			if (!is_callable(_selected)) {
				__FateValidationAddIssue(_report, "error", "policy_config_missing_selected", $"{_path}.OnSelected", "Policy is missing OnSelected", table_id, i, _policy_name);
			}
			
			var _finished = _policy[$ "OnRollFinished"];
			if (!is_callable(_finished)) {
				__FateValidationAddIssue(_report, "error", "policy_config_missing_finished", $"{_path}.OnRollFinished", "Policy is missing OnRollFinished", table_id, i, _policy_name);
			}
			
			if (is_callable(_policy[$ "GetPolicyId"])) {
				var _policy_id = _policy.GetPolicyId();
				if (!__FateIsFiniteReal(_policy_id)) {
					__FateValidationAddIssue(_report, "warning", "policy_config_bad_id", $"{_path}.GetPolicyId", "GetPolicyId should return a finite real", table_id, i, _policy_name);
				}
			}

			if (is_callable(_policy[$ "GetPolicyName"])) {
				var _resolved_name = _policy.GetPolicyName();
				if (!is_string(_resolved_name)) {
					__FateValidationAddIssue(_report, "warning", "policy_config_bad_name", $"{_path}.GetPolicyName", "GetPolicyName should return a string", table_id, i, _policy_name);
				}
				else if (string_length(_resolved_name) <= 0) {
					__FateValidationAddIssue(_report, "warning", "policy_config_empty_name", $"{_path}.GetPolicyName", "GetPolicyName should not return an empty string", table_id, i, _policy_name);
				}
			}

			if (is_callable(_policy[$ "GetPriority"])) {
				var _resolved_priority = _policy.GetPriority();
				if (!__FateIsFiniteReal(_resolved_priority)) {
					__FateValidationAddIssue(_report, "warning", "policy_config_bad_priority", $"{_path}.GetPriority", "GetPriority should return a finite real", table_id, i, _policy_name);
				}
			}

			if (is_callable(_policy[$ "ValidateForTable"])) {
				var _valid_for_table = _policy.ValidateForTable(FateStrictness.SILENT, table_id);
				if (!is_bool(_valid_for_table)) {
					__FateValidationAddIssue(_report, "error", "policy_config_bad_validate_return", $"{_path}.ValidateForTable", "ValidateForTable must return a bool", table_id, i, _policy_name);
				}
				else if (!_valid_for_table) {
					__FateValidationAddIssue(_report, "error", "policy_config_rejected", $"{_path}.ValidateForTable", "ValidateForTable rejected this policy for the table", table_id, i, _policy_name);
				}
			}
		}
		
		return _report;
	}
	
	static ValidateState = function(_state, _opts = undefined) {
		var _report = __FateValidationCreateReport(table_id);
		if (!is_struct(_state)) {
			__FateValidationAddIssue(_report, "error", "table_state_not_struct", "state", "State must be a struct", table_id, undefined, undefined);
			return _report;
		}
		
		var _format = _state[$ "format"];
		if (!is_string(_format)) {
			__FateValidationAddIssue(_report, "error", "table_state_bad_format_type", "state.format", "format must be a string", table_id, undefined, undefined);
		}
		else if (_format != "fate_table_state") {
			__FateValidationAddIssue(_report, "error", "table_state_bad_format", "state.format", "format must be fate_table_state", table_id, undefined, undefined);
		}
		
		var _version = _state[$ "version"];
		if (!__FateIsFiniteReal(_version)) {
			__FateValidationAddIssue(_report, "error", "table_state_bad_version_type", "state.version", "version must be a finite real", table_id, undefined, undefined);
		}
		else if (floor(_version) != 1) {
			__FateValidationAddIssue(_report, "error", "table_state_unsupported_version", "state.version", $"version {floor(_version)} is not supported", table_id, undefined, undefined);
		}
		
		var _raw_policy_states = _state[$ "policies"];
		if (!is_array(_raw_policy_states)) {
			__FateValidationAddIssue(_report, "error", "table_state_bad_policies_array", "state.policies", "policies must be an array", table_id, undefined, undefined);
		}
		
		if (_report.error_count > 0) {
			return _report;
		}
		
		var _sanitized_policy_states = [];
		var _policy_count = array_length(policies);
		var _saved_policy_count = array_length(_raw_policy_states);
		for (var i = 0; i < _policy_count; i++) {
			var _policy_record = policies[i];
			var _policy_name = _policy_record.policy_name;
			var _policy_path = $"state.policies[{i}]";
			var _sanitized_policy_state = {};
			var _policy_entry = undefined;
			if (i < _saved_policy_count) {
				_policy_entry = _raw_policy_states[i];
			}
			
			if (!is_struct(_policy_entry)) {
				__FateValidationAddIssue(_report, "warning", "policy_state_missing_or_invalid", _policy_path, "Missing or invalid policy entry, default state will be used", table_id, i, _policy_name);
			}
			else {
				var _saved_index = _policy_entry[$ "index"];
				if (_saved_index != undefined) {
					if (!__FateIsFiniteReal(_saved_index)) {
						__FateValidationAddIssue(_report, "warning", "policy_state_bad_index_type", $"{_policy_path}.index", "index should be a finite real", table_id, i, _policy_name);
					}
					else if (floor(_saved_index) != i) {
						__FateValidationAddIssue(_report, "warning", "policy_state_index_mismatch", $"{_policy_path}.index", $"index mismatch, expected {i}", table_id, i, _policy_name);
					}
				}
				
				var _saved_name = _policy_entry[$ "policy_name"];
				if (_saved_name != undefined) {
					if (!is_string(_saved_name)) {
						__FateValidationAddIssue(_report, "warning", "policy_state_bad_name_type", $"{_policy_path}.policy_name", "policy_name should be a string", table_id, i, _policy_name);
					}
					else if (_saved_name != _policy_name) {
						__FateValidationAddIssue(_report, "warning", "policy_state_name_mismatch", $"{_policy_path}.policy_name", $"policy name mismatch, expected {_policy_name}", table_id, i, _policy_name);
					}
				}
				
				var _saved_state = _policy_entry[$ "state"];
				if (_saved_state != undefined) {
					if (!is_struct(_saved_state)) {
						__FateValidationAddIssue(_report, "warning", "policy_state_bad_payload", $"{_policy_path}.state", "state payload should be a struct", table_id, i, _policy_name);
					}
					else {
						_sanitized_policy_state = _saved_state;
					}
				}
			}
			
			if (_policy_name == "fate_pity") {
				var _miss_counts = _sanitized_policy_state[$ "miss_counts"];
				if (_miss_counts != undefined) {
					if (!is_struct(_miss_counts)) {
						__FateValidationAddIssue(_report, "warning", "pity_state_bad_miss_counts", $"{_policy_path}.state.miss_counts", "miss_counts should be a struct", table_id, i, _policy_name);
					}
				}
				_sanitized_policy_state = {
					miss_counts: __FateStateSanitizeCountMap(_miss_counts)
				};
			}
			else if (_policy_name == "fate_duplicate_protection") {
				var _history = _sanitized_policy_state[$ "history_by_scope"];
				if (_history != undefined) {
					if (!is_struct(_history)) {
						__FateValidationAddIssue(_report, "warning", "dup_state_bad_history", $"{_policy_path}.state.history_by_scope", "history_by_scope should be a struct", table_id, i, _policy_name);
					}
				}
				_sanitized_policy_state = {
					history_by_scope: __FateStateSanitizeStringArrayMap(_history)
				};
			}
			else if (_policy_name == "fate_batch_guarantee") {
				_sanitized_policy_state = {};
			}
			else if (_policy_name == "fate_featured_rate_up") {
				var _miss_counts = _sanitized_policy_state[$ "miss_counts"];
				if (_miss_counts != undefined) {
					if (!is_struct(_miss_counts)) {
						__FateValidationAddIssue(_report, "warning", "featured_state_bad_miss_counts", $"{_policy_path}.state.miss_counts", "miss_counts should be a struct", table_id, i, _policy_name);
					}
				}
				_sanitized_policy_state = {
					miss_counts: __FateStateSanitizeCountMap(_miss_counts)
				};
			}
			
			array_push(_sanitized_policy_states, {
				index: i,
				policy_id: _policy_record.policy_id,
				policy_name: _policy_name,
				state_version: 1,
				state: _sanitized_policy_state
			});
		}
		
		for (var i = _policy_count; i < _saved_policy_count; i++) {
			var _extra_entry = _raw_policy_states[i];
			var _extra_name = $"index_{i}";
			if (is_struct(_extra_entry)) {
				var _extra_policy_name = _extra_entry[$ "policy_name"];
				if (is_string(_extra_policy_name)) {
					if (string_length(_extra_policy_name) > 0) {
						_extra_name = _extra_policy_name;
					}
				}
			}
			__FateValidationAddIssue(_report, "warning", "policy_state_extra_ignored", $"state.policies[{i}]", $"Extra policy state {_extra_name} was ignored", table_id, i, _extra_name);
		}
		
		var _strictness_raw = _state[$ "strictness_mode"];
		var _construct_raw = _state[$ "construct_entries"];
		var _sanitized_strictness = __FateSanitizeStrictness(_strictness_raw, strictness_mode);
		var _sanitized_construct_entries = __FateSanitizeBool(_construct_raw, construct_entries);
		if (_strictness_raw != undefined) {
			if (_sanitized_strictness != _strictness_raw) {
				__FateValidationAddIssue(_report, "warning", "table_state_strictness_sanitized", "state.strictness_mode", "strictness_mode was sanitized", table_id, undefined, undefined);
			}
		}
		if (_construct_raw != undefined) {
			if (!is_bool(_construct_raw)) {
				__FateValidationAddIssue(_report, "warning", "table_state_construct_entries_sanitized", "state.construct_entries", "construct_entries was sanitized", table_id, undefined, undefined);
			}
		}
		
		_report.sanitized_state = {
			format: "fate_table_state",
			version: 1,
			table_id: table_id,
			strictness_mode: _sanitized_strictness,
			construct_entries: _sanitized_construct_entries,
			policies: _sanitized_policy_states
		};
		return _report;
	}
	
	static GetState = function() {
		var _policy_states = [];
		for (var i = 0; i < array_length(policies); i++) {
			var _policy_record = policies[i];
			var _policy_state = {};
			if (is_callable(_policy_record.policy[$ "GetState"])) {
				_policy_state = _policy_record.policy.GetState();
				if (!is_struct(_policy_state)) {
					__FateReport(strictness_mode, $"Fate.GetState received invalid GetState return value from policy {_policy_record.policy_name} on table {table_id}");
					_policy_state = {};
				}
			}
			array_push(_policy_states, {
				index: i,
				policy_id: _policy_record.policy_id,
				policy_name: _policy_record.policy_name,
				state_version: 1,
				state: _policy_state
			});
		}
		return {
			format: "fate_table_state",
			version: 1,
			table_id: table_id,
			strictness_mode: strictness_mode,
			construct_entries: construct_entries,
			policies: _policy_states
		};
	}
	
	static SetState = function(_state) {
		var _validation = ValidateState(_state);
		__FateValidationReportIssues(strictness_mode, _validation.issues);
		var _sanitized = _validation.sanitized_state;
		if (!is_struct(_sanitized)) {
			return self;
		}
		
		strictness_mode = _sanitized[$ "strictness_mode"];
		construct_entries = _sanitized[$ "construct_entries"];
		
		var _policy_states = _sanitized[$ "policies"];
		for (var i = 0; i < array_length(policies); i++) {
			var _policy_state = {};
			var _policy_entry = _policy_states[i];
			if (is_struct(_policy_entry)) {
				var _entry_state = _policy_entry[$ "state"];
				if (is_struct(_entry_state)) {
					_policy_state = _entry_state;
				}
			}
			var _policy_record = policies[i];
			if (is_callable(_policy_record.policy[$ "SetState"])) {
				_policy_record.policy.SetState(_policy_state);
			}
		}
		return self;
	}
	
	///@ignore
	static __CreateRollScope = function(_capture_rich_data = false) {
		var _capture = __FateSanitizeBool(_capture_rich_data, false);
		var _scope = {
			roll_id: __FateNextRollId(),
			invalid_rng_draws: 0,
			unique_tokens: [],
			policy_scope_state: {},
			policy_resolve_calls: 0,
			policy_selected_calls: 0,
			policy_finished_calls: 0,
			policy_diagnostics: {
				directive_struct_count: 0,
				invalid_directive_fields: 0,
				hard_force_active_count: 0,
				hard_force_mode: "none",
				hard_force_winner_policy_id: undefined,
				hard_force_winner_policy_name: undefined,
				hard_force_forced_entry_count: 0,
				soft_modified_entry_count: 0,
				hard_excluded_entry_count: 0
			},
			capture_rich_data: _capture,
			rich_selected_events: undefined,
			rich_table_summaries: undefined
		};
		if (_capture) {
			_scope.rich_selected_events = [];
			_scope.rich_table_summaries = [];
		}
		return _scope;
	}
	
	///@ignore
	static __CreatePolicyDirectiveState = function() {
		var _policy_count = array_length(policies);
		var _hard_force_sets = array_create(_policy_count);
		for (var i = 0; i < _policy_count; i++) {
			_hard_force_sets[i] = [];
		}
		return {
			hard_force_sets: _hard_force_sets,
			hard_force_active_count: 0,
			hard_force_mode: "none",
			hard_force_winner_policy_id: undefined,
			hard_force_winner_policy_name: undefined,
			hard_force_allowed_ids: [],
			hard_force_forced_entry_count: 0,
			directive_struct_count: 0,
			invalid_directive_fields: 0,
			soft_modified_entry_count: 0,
			hard_excluded_entry_count: 0
		};
	}

	///@ignore
	static __AccumulatePolicyDiagnostics = function(_roll_scope, _policy_state) {
		var _diagnostics = _roll_scope.policy_diagnostics;
		_diagnostics.directive_struct_count += _policy_state.directive_struct_count;
		_diagnostics.invalid_directive_fields += _policy_state.invalid_directive_fields;
		_diagnostics.soft_modified_entry_count += _policy_state.soft_modified_entry_count;
		_diagnostics.hard_excluded_entry_count += _policy_state.hard_excluded_entry_count;
		if (_policy_state.hard_force_active_count > 0) {
			_diagnostics.hard_force_active_count++;
			_diagnostics.hard_force_mode = _policy_state.hard_force_mode;
			_diagnostics.hard_force_winner_policy_id = _policy_state.hard_force_winner_policy_id;
			_diagnostics.hard_force_winner_policy_name = _policy_state.hard_force_winner_policy_name;
			_diagnostics.hard_force_forced_entry_count = _policy_state.hard_force_forced_entry_count;
		}
	}

	///@ignore
	static __ApplyPolicyDirectives = function(_records, _policy_state) {
		var _active_force_policy_indexes = [];
		for (var i = 0; i < array_length(policies); i++) {
			var _force_set = _policy_state.hard_force_sets[i];
			if (array_length(_force_set) > 0) {
				array_push(_active_force_policy_indexes, i);
			}
		}
		
		_policy_state.hard_force_active_count = array_length(_active_force_policy_indexes);
		var _hard_force_allowed_ids = [];
		if (_policy_state.hard_force_active_count > 0) {
			var _first_force_policy_index = _active_force_policy_indexes[0];
			var _first_force_set = _policy_state.hard_force_sets[_first_force_policy_index];
			for (var i = 0; i < array_length(_first_force_set); i++) {
				array_push(_hard_force_allowed_ids, _first_force_set[i]);
			}
			
			if (_policy_state.hard_force_active_count == 1) {
				_policy_state.hard_force_mode = "single";
				_policy_state.hard_force_winner_policy_id = policies[_first_force_policy_index].policy_id;
				_policy_state.hard_force_winner_policy_name = policies[_first_force_policy_index].policy_name;
			}
			else {
				var _intersection = _hard_force_allowed_ids;
				for (var i = 1; i < array_length(_active_force_policy_indexes); i++) {
					var _force_policy_index = _active_force_policy_indexes[i];
					var _force_policy_set = _policy_state.hard_force_sets[_force_policy_index];
					var _next_intersection = [];
					for (var j = 0; j < array_length(_intersection); j++) {
						var _entry_id = _intersection[j];
						if (array_contains(_force_policy_set, _entry_id)) {
							array_push(_next_intersection, _entry_id);
						}
					}
					_intersection = _next_intersection;
				}
				
				if (array_length(_intersection) > 0) {
					_hard_force_allowed_ids = _intersection;
					_policy_state.hard_force_mode = "intersection";
				}
				else {
					var _winner_policy_index = _first_force_policy_index;
					for (var i = 1; i < array_length(_active_force_policy_indexes); i++) {
						var _candidate_policy_index = _active_force_policy_indexes[i];
						var _winner_policy = policies[_winner_policy_index];
						var _candidate_policy = policies[_candidate_policy_index];
						if (_candidate_policy.policy_priority > _winner_policy.policy_priority) {
							_winner_policy_index = _candidate_policy_index;
						}
						else if (_candidate_policy.policy_priority == _winner_policy.policy_priority) {
							if (_candidate_policy.registration_order < _winner_policy.registration_order) {
								_winner_policy_index = _candidate_policy_index;
							}
						}
					}
					_hard_force_allowed_ids = [];
					var _winner_set = _policy_state.hard_force_sets[_winner_policy_index];
					for (var i = 0; i < array_length(_winner_set); i++) {
						array_push(_hard_force_allowed_ids, _winner_set[i]);
					}
					_policy_state.hard_force_mode = "priority";
					_policy_state.hard_force_winner_policy_id = policies[_winner_policy_index].policy_id;
					_policy_state.hard_force_winner_policy_name = policies[_winner_policy_index].policy_name;
				}
			}
		}
		
		_policy_state.hard_force_allowed_ids = _hard_force_allowed_ids;
		_policy_state.hard_force_forced_entry_count = array_length(_hard_force_allowed_ids);
		
		var _soft_modified_entry_count = 0;
		var _hard_excluded_entry_count = 0;
		for (var i = 0; i < array_length(_records); i++) {
			var _record = _records[i];
			var _has_soft_mod = (_record.policy_weight_mult != 1);
			if (_record.policy_weight_add != 0) {
				_has_soft_mod = true;
			}
			if (_record.policy_weight_override != undefined) {
				_has_soft_mod = true;
			}
			if (_has_soft_mod) {
				_soft_modified_entry_count++;
			}
			
			if (_record.policy_hard_excluded) {
				_hard_excluded_entry_count++;
			}
			
			var _enabled = _record.resolved.enabled;
			if (array_length(_hard_force_allowed_ids) > 0) {
				if (!array_contains(_hard_force_allowed_ids, _record.entry.entry_id)) {
					_enabled = false;
				}
			}
			if (_record.policy_hard_excluded) {
				_enabled = false;
			}
			_record.resolved.enabled = _enabled;
			
			var _weight = _record.resolved.weight;
			if (_record.policy_weight_override != undefined) {
				_weight = _record.policy_weight_override;
			}
			else {
				_weight = (_weight * _record.policy_weight_mult) + _record.policy_weight_add;
			}
			_record.resolved.weight = __FateSanitizeWeight(_weight, 0);
			_record.was_eligible = _record.resolved.enabled && (_record.resolved.guaranteed || _record.resolved.weight > 0);
		}
		
		_policy_state.soft_modified_entry_count = _soft_modified_entry_count;
		_policy_state.hard_excluded_entry_count = _hard_excluded_entry_count;
	}
	
	///@ignore
	static __NotifyPolicyResolveHooks = function(_context, _record, _roll_scope, _table_call_id, _nested_depth, _parent_entry_id, _requested_count, _selection_index, _selected_count_so_far, _remaining_slots, _policy_state) {
		var _policy_count = array_length(policies);
		if (_policy_count <= 0) {
			return;
		}
		var _event = {
			hook: "resolve_for_roll",
			roll_id: _roll_scope.roll_id,
			table_call_id: _table_call_id,
			table_id: table_id,
			entry: _record.entry,
			entry_id: _record.entry.entry_id,
			insertion_order: _record.entry.insertion_order,
			parent_entry_id: _parent_entry_id,
			nested_depth: _nested_depth,
			requested_count: _requested_count,
			selection_index: _selection_index,
			selected_count_so_far: _selected_count_so_far,
			remaining_slots: _remaining_slots,
			slots_remaining_including_current: _remaining_slots,
			resolved: _record.resolved
		};
		for (var i = 0; i < _policy_count; i++) {
			var _policy_record = policies[i];
			var _resolve_result = _policy_record.policy.ResolveForRoll(_context, _event);
			_roll_scope.policy_resolve_calls++;
			if (_resolve_result == undefined) {
				continue;
			}
			
			if (!is_struct(_resolve_result)) {
				_policy_state.invalid_directive_fields++;
				__FateReport(strictness_mode, $"Fate policy {_policy_record.policy_name} returned invalid ResolveForRoll payload on table {table_id}, call {_table_call_id}");
				continue;
			}
			
			_policy_state.directive_struct_count++;
			var _directive = __FateSanitizePolicyDirective(_resolve_result, strictness_mode, table_id, _table_call_id, _policy_record.policy_name);
			_policy_state.invalid_directive_fields += _directive.invalid_fields;
			
			if (_directive.hard_force) {
				array_push(_policy_state.hard_force_sets[i], _record.entry.entry_id);
			}
			if (_directive.hard_exclude) {
				_record.policy_hard_excluded = true;
			}
			
			_record.policy_weight_mult *= _directive.weight_mult;
			_record.policy_weight_add += _directive.weight_add;
			if (_directive.weight_override != undefined) {
				_record.policy_weight_override = _directive.weight_override;
			}
			if (_directive.selected_via != undefined) {
				_record.policy_selected_via = _directive.selected_via;
			}
		}
	}
	
	///@ignore
	static __NotifyPolicySelectedHooks = function(_context, _event, _roll_scope) {
		var _policy_count = array_length(policies);
		if (_policy_count <= 0) {
			return;
		}
		for (var i = 0; i < _policy_count; i++) {
			var _policy_record = policies[i];
			_policy_record.policy.OnSelected(_context, _event);
			_roll_scope.policy_selected_calls++;
		}
	}
	
	///@ignore
	static __NotifyPolicyFinishedHooks = function(_context, _summary, _roll_scope) {
		var _policy_count = array_length(policies);
		if (_policy_count <= 0) {
			return;
		}
		for (var i = 0; i < _policy_count; i++) {
			var _policy_record = policies[i];
			_policy_record.policy.OnRollFinished(_context, _summary);
			_roll_scope.policy_finished_calls++;
		}
	}
	
	///@ignore
	static __BuildResolvedRecords = function(_context, _roll_scope, _table_call_id, _nested_depth, _parent_entry_id, _requested_count, _selection_index, _selected_count_so_far, _remaining_slots, _policy_state) {
		var _records = [];
		for (var i = 0; i < array_length(entries); i++) {
			var _entry = entries[i];
			var _resolved = __FateResolveEntry(_entry, _context, strictness_mode, table_id, _table_call_id);
			var _record = {
				entry: _entry,
				resolved: _resolved,
				selected_count: 0,
				selected_guaranteed: false,
				selected_weighted: false,
				was_eligible: _resolved.enabled && (_resolved.guaranteed || _resolved.weight > 0),
				policy_hard_excluded: false,
				policy_weight_mult: 1,
				policy_weight_add: 0,
				policy_weight_override: undefined,
				policy_selected_via: undefined
			};
			__NotifyPolicyResolveHooks(_context, _record, _roll_scope, _table_call_id, _nested_depth, _parent_entry_id, _requested_count, _selection_index, _selected_count_so_far, _remaining_slots, _policy_state);
			array_push(_records, _record);
		}
		__ApplyPolicyDirectives(_records, _policy_state);
		return _records;
	}
	
	///@ignore
	static __ApplySelection = function(_record, _source, _results, _selection_index, _context, _rng, _roll_scope, _nested_depth, _parent_entry_id, _table_call_id, _requested_count, _policy_selected_events) {
		var _selected_via = _source;
		if (_record.policy_selected_via != undefined) {
			_selected_via = _record.policy_selected_via;
		}
		var _event = {
			hook: "on_selected",
			roll_id: _roll_scope.roll_id,
			table_call_id: _table_call_id,
			table_id: table_id,
			entry: _record.entry,
			entry_id: _record.entry.entry_id,
			insertion_order: _record.entry.insertion_order,
			parent_entry_id: _parent_entry_id,
			requested_count: _requested_count,
			selection_index: _selection_index,
			selected_count_so_far: _selection_index + 1,
			source: _source,
			selected_via: _selected_via,
			resolved: _record.resolved,
			nested_depth: _nested_depth
		};
		_record.entry.OnSelected(_context, _event);
		array_push(_policy_selected_events, _event);
		if (_roll_scope.capture_rich_data) {
			array_push(_roll_scope.rich_selected_events, _event);
		}
		__NotifyPolicySelectedHooks(_context, _event, _roll_scope);
		
		if (is_instanceof(_record.entry, FateTableEntry)) {
			var _child_table = _record.entry.GetTable();
			if (is_instanceof(_child_table, FateTable)) {
				var _base_count = _record.entry.GetCount();
				var _child_count = _base_count;
				if (_record.resolved.nested_count != undefined) {
					_child_count = _record.resolved.nested_count;
				}
				_child_count = __FateSanitizeNestedCount(_child_count, _base_count);
				var _child_outcome = _child_table.__RollInternal(_child_count, _context, _rng, _roll_scope, _nested_depth + 1, _record.entry.entry_id);
				_results = array_concat(_results, _child_outcome.results);
			}
			else {
				__FateReport(strictness_mode, $"Fate table entry has invalid nested table on table {table_id}, call {_table_call_id}");
			}
		}
		else if (is_instanceof(_record.entry, FateCreatorEntry)) {
			if (construct_entries) {
				var _created = _record.entry.__Instantiate(_record.resolved.creator_args);
				if (_created != undefined) {
					array_push(_results, _created);
				}
				else {
					__FateReport(strictness_mode, $"Fate creator entry failed instantiation on table {table_id}, call {_table_call_id}");
				}
			}
			else {
				array_push(_results, _record.entry);
			}
		}
		else {
			array_push(_results, _record.entry);
		}
		
		_selection_index++;
		return {
			results: _results,
			selection_index: _selection_index
		};
	}
	
	///@ignore
	static __RollInternal = function(_count, _context, _rng, _roll_scope, _nested_depth, _parent_entry_id) {
		var _requested_count = __FateSanitizeRollCount(_count, 1);
		var _table_call_id = __FateNextTableCallId();
		var _initial_policy_state = __CreatePolicyDirectiveState();
		var _records = __BuildResolvedRecords(_context, _roll_scope, _table_call_id, _nested_depth, _parent_entry_id, _requested_count, 0, 0, _requested_count, _initial_policy_state);
		__AccumulatePolicyDiagnostics(_roll_scope, _initial_policy_state);
		var _guaranteed_records = [];

		for (var i = 0; i < array_length(_records); i++) {
			var _record = _records[i];
			if (!_record.resolved.enabled) {
				continue;
			}
			if (_record.resolved.guaranteed) {
				array_push(_guaranteed_records, _record);
			}
		}

		_guaranteed_records = __FateSortGuaranteedRecords(_guaranteed_records);
		
		var _results = [];
		var _selection_index = 0;
		var _selected_count = 0;
		var _remaining_slots = _requested_count;
		var _exhausted_reason = "none";
		var _policy_selected_events = [];
		
		for (var i = 0; i < array_length(_guaranteed_records); i++) {
			if (_remaining_slots <= 0) {
				_exhausted_reason = "slot_cap";
				break;
			}
			var _record = _guaranteed_records[i];
			if (!__FateTryConsumeUnique(_roll_scope, _record)) {
				continue;
			}
			_record.selected_count++;
			_record.selected_guaranteed = true;
			_selected_count++;
			_remaining_slots--;
			var _selection_outcome = __ApplySelection(_record, "guaranteed", _results, _selection_index, _context, _rng, _roll_scope, _nested_depth, _parent_entry_id, _table_call_id, _requested_count, _policy_selected_events);
			_results = _selection_outcome.results;
			_selection_index = _selection_outcome.selection_index;
		}

		while (_remaining_slots > 0) {
			var _step_policy_state = __CreatePolicyDirectiveState();
			var _step_records = __BuildResolvedRecords(_context, _roll_scope, _table_call_id, _nested_depth, _parent_entry_id, _requested_count, _selection_index, _selected_count, _remaining_slots, _step_policy_state);
			__AccumulatePolicyDiagnostics(_roll_scope, _step_policy_state);

			var _active_records = [];
			var _total_weight = 0;
			var _blocked_unique = 0;
			for (var i = 0; i < array_length(_step_records); i++) {
				var _step_record = _step_records[i];
				if (!_step_record.resolved.enabled) {
					continue;
				}
				if (_step_record.resolved.guaranteed) {
					continue;
				}
				if (_step_record.resolved.weight <= 0) {
					continue;
				}
				if (_step_record.resolved.unique) {
					var _token = __FateUniqueToken(_step_record);
					if (array_contains(_roll_scope.unique_tokens, _token)) {
						_blocked_unique++;
						continue;
					}
				}
				array_push(_active_records, _step_record);
				_total_weight += _step_record.resolved.weight;
			}

			if (array_length(_active_records) <= 0) {
				if (_blocked_unique > 0) {
					_exhausted_reason = "uniqueness_exhausted";
				}
				else {
					_exhausted_reason = "pool_empty";
				}
				break;
			}
			if (_total_weight <= 0) {
				_exhausted_reason = "pool_empty";
				break;
			}
			
			var _unit = __FateRngNextUnit(_rng, strictness_mode, _roll_scope, table_id, _table_call_id);
			var _hit = _unit * _total_weight;
			var _running_total = 0;
			var _hit_record = _active_records[array_length(_active_records) - 1];
			for (var i = 0; i < array_length(_active_records); i++) {
				var _candidate = _active_records[i];
				_running_total += _candidate.resolved.weight;
				if (_hit < _running_total) {
					_hit_record = _candidate;
					break;
				}
			}
			
			if (!__FateTryConsumeUnique(_roll_scope, _hit_record)) {
				_exhausted_reason = "uniqueness_exhausted";
				break;
			}
			
			_hit_record.selected_count++;
			_hit_record.selected_weighted = true;
			_selected_count++;
			_remaining_slots--;
			var _weighted_outcome = __ApplySelection(_hit_record, "weighted", _results, _selection_index, _context, _rng, _roll_scope, _nested_depth, _parent_entry_id, _table_call_id, _requested_count, _policy_selected_events);
			_results = _weighted_outcome.results;
			_selection_index = _weighted_outcome.selection_index;
			for (var i = 0; i < array_length(_records); i++) {
				var _summary_record = _records[i];
				if (_summary_record.entry.entry_id == _hit_record.entry.entry_id) {
					_summary_record.selected_count++;
					_summary_record.selected_weighted = true;
					_summary_record.was_eligible = _summary_record.was_eligible || _hit_record.was_eligible;
					break;
				}
			}
		}
		
		for (var i = 0; i < array_length(_records); i++) {
			var _record = _records[i];
			var _selected_via = "none";
			if (_record.selected_guaranteed && _record.selected_weighted) {
				_selected_via = "mixed";
			}
			else if (_record.selected_guaranteed) {
				_selected_via = "guaranteed";
			}
			else if (_record.selected_weighted) {
				_selected_via = "weighted";
			}
			var _summary = {
				roll_id: _roll_scope.roll_id,
				table_call_id: _table_call_id,
				table_id: table_id,
				entry_id: _record.entry.entry_id,
				nested_depth: _nested_depth,
				selected_count: _record.selected_count,
				was_selected: _record.selected_count > 0,
				selected_via: _selected_via,
				was_eligible: _record.was_eligible,
				exhausted_reason: _exhausted_reason,
				resolved: _record.resolved,
				total_requested: _requested_count,
				total_selected: _selected_count
			};
			_record.entry.OnRollFinished(_context, _summary);
		}
		
		var _policy_summary = {
			hook: "on_roll_finished",
			roll_id: _roll_scope.roll_id,
			table_call_id: _table_call_id,
			table_id: table_id,
			parent_entry_id: _parent_entry_id,
			nested_depth: _nested_depth,
			requested_count: _requested_count,
			selected_count: _selected_count,
			result_count: array_length(_results),
			missing_slots: max(0, _requested_count - _selected_count),
			is_partial: _selected_count < _requested_count,
			is_empty: _selected_count <= 0,
			exhausted_reason: _exhausted_reason,
			selected_events: _policy_selected_events,
			selected_event_count: array_length(_policy_selected_events)
		};
		__NotifyPolicyFinishedHooks(_context, _policy_summary, _roll_scope);
		if (_roll_scope.capture_rich_data) {
			array_push(_roll_scope.rich_table_summaries, _policy_summary);
		}
		
		return {
			results: _results,
			selected_count: _selected_count,
			exhausted_reason: _exhausted_reason,
			table_call_id: _table_call_id
		};
	}
	
	///@ignore
	static __BuildPreviewData = function(_count, _context) {
		var _requested_count = __FateSanitizeRollCount(_count, 1);
		var _table_call_id = __FateNextTableCallId();
		var _preview_scope = {
			roll_id: __FateNextRollId(),
			unique_tokens: [],
			policy_resolve_calls: 0,
			policy_selected_calls: 0,
			policy_finished_calls: 0
		};
		var _policy_state = __CreatePolicyDirectiveState();
		var _records = __BuildResolvedRecords(_context, _preview_scope, _table_call_id, 0, undefined, _requested_count, 0, 0, _requested_count, _policy_state);
		var _guaranteed_records = [];
		var _weighted_records = [];
		for (var i = 0; i < array_length(_records); i++) {
			var _record = _records[i];
			_record.selected_guaranteed = false;
			_record.weighted_probability = 0;
			if (!_record.resolved.enabled) {
				continue;
			}
			if (_record.resolved.guaranteed) {
				array_push(_guaranteed_records, _record);
			}
			else if (_record.resolved.weight > 0) {
				array_push(_weighted_records, _record);
			}
		}
		
		_guaranteed_records = __FateSortGuaranteedRecords(_guaranteed_records);
		
		var _remaining_slots = _requested_count;
		var _guaranteed_selected_count = 0;
		var _exhausted_reason = "none";
		
		for (var i = 0; i < array_length(_guaranteed_records); i++) {
			if (_remaining_slots <= 0) {
				_exhausted_reason = "slot_cap";
				break;
			}
			var _record = _guaranteed_records[i];
			if (!__FateTryConsumeUnique(_preview_scope, _record)) {
				continue;
			}
			_record.selected_guaranteed = true;
			_guaranteed_selected_count++;
			_remaining_slots--;
		}
		
		var _weighted_slots = _remaining_slots;
		if (_weighted_slots > 0) {
			var _active_weighted = [];
			var _active_total_weight = 0;
			var _blocked_unique = 0;
			for (var i = 0; i < array_length(_weighted_records); i++) {
				var _record = _weighted_records[i];
				if (_record.resolved.unique) {
					var _token = __FateUniqueToken(_record);
					if (array_contains(_preview_scope.unique_tokens, _token)) {
						_blocked_unique++;
						continue;
					}
				}
				array_push(_active_weighted, _record);
				_active_total_weight += _record.resolved.weight;
			}
			if (array_length(_active_weighted) <= 0) {
				if (_blocked_unique > 0) {
					_exhausted_reason = "uniqueness_exhausted";
				}
				else {
					_exhausted_reason = "pool_empty";
				}
			}
			else if (_active_total_weight <= 0) {
				_exhausted_reason = "pool_empty";
			}
			else {
				for (var i = 0; i < array_length(_active_weighted); i++) {
					var _record = _active_weighted[i];
					_record.weighted_probability = _record.resolved.weight / _active_total_weight;
				}
			}
		}
		
		var _resolved_entries = [];
		for (var i = 0; i < array_length(_records); i++) {
			var _record = _records[i];
			array_push(_resolved_entries, {
				entry_id: _record.entry.entry_id,
				insertion_order: _record.entry.insertion_order,
				enabled: _record.resolved.enabled,
				weight: _record.resolved.weight,
				guaranteed: _record.resolved.guaranteed,
				guaranteed_priority: _record.resolved.guaranteed_priority,
				unique: _record.resolved.unique,
				unique_key: _record.resolved.unique_key,
				selected_in_guaranteed_phase: _record.selected_guaranteed,
				weighted_probability: _record.weighted_probability
			});
		}
		
		return {
			roll_id: undefined,
			table_id: table_id,
			requested_count: _requested_count,
			resolved_entries: _resolved_entries,
			guaranteed_selected_count: _guaranteed_selected_count,
			weighted_slots: _weighted_slots,
			exhausted_reason: _exhausted_reason
		};
	}
	
	///@ignore
	static __BuildRollSummary = function(_requested_count, _outcome, _roll_scope) {
		var _result_count = array_length(_outcome.results);
		var _missing_slots = max(0, _requested_count - _outcome.selected_count);
		return {
			roll_id: _roll_scope.roll_id,
			table_id: table_id,
			root_table_call_id: _outcome.table_call_id,
			requested_count: _requested_count,
			selected_count: _outcome.selected_count,
			result_count: _result_count,
			missing_slots: _missing_slots,
			is_partial: _outcome.selected_count < _requested_count,
			is_empty: _outcome.selected_count <= 0,
			exhausted_reason: _outcome.exhausted_reason
		};
	}
	
	///@ignore
	static __BuildRollDiagnostics = function(_roll_scope, _outcome) {
		var _policy_diagnostics = _roll_scope.policy_diagnostics;
		return {
			roll_id: _roll_scope.roll_id,
			table_id: table_id,
			table_call_id: _outcome.table_call_id,
			invalid_rng_draws: _roll_scope.invalid_rng_draws,
			exhausted_reason: _outcome.exhausted_reason,
			registered_policy_count: array_length(policies),
			policy_resolve_calls: _roll_scope.policy_resolve_calls,
			policy_selected_calls: _roll_scope.policy_selected_calls,
			policy_finished_calls: _roll_scope.policy_finished_calls,
			policy_directive_struct_count: _policy_diagnostics.directive_struct_count,
			policy_invalid_directive_fields: _policy_diagnostics.invalid_directive_fields,
			policy_hard_force_active_count: _policy_diagnostics.hard_force_active_count,
			policy_hard_force_mode: _policy_diagnostics.hard_force_mode,
			policy_hard_force_winner_policy_id: _policy_diagnostics.hard_force_winner_policy_id,
			policy_hard_force_winner_policy_name: _policy_diagnostics.hard_force_winner_policy_name,
			policy_hard_forced_entry_count: _policy_diagnostics.hard_force_forced_entry_count,
			policy_soft_modified_entry_count: _policy_diagnostics.soft_modified_entry_count,
			policy_hard_excluded_entry_count: _policy_diagnostics.hard_excluded_entry_count
		};
	}
	
	static Roll = function(_count = 1, _context = undefined, _rng = undefined) {
		var _requested_count = __FateSanitizeRollCount(_count, 1);
		var _resolved_rng = __FateResolveRng(_rng);
		var _roll_scope = __CreateRollScope();
		var _outcome = __RollInternal(_requested_count, _context, _resolved_rng, _roll_scope, 0, undefined);
		last_roll_diagnostics = __BuildRollDiagnostics(_roll_scope, _outcome);
		return _outcome.results;
	}
	
	///@func	RollDetailed(_count, _context, _rng)
	///@desc	Rolls the table and returns results with roll metadata, diagnostics, and policy event traces.
	///@param	{Real}	_count
	///@param	{Any}	_context
	///@param	{Struct}	_rng
	///@return	{Struct}
	static RollDetailed = function(_count = 1, _context = undefined, _rng = undefined) {
		var _requested_count = __FateSanitizeRollCount(_count, 1);
		var _resolved_rng = __FateResolveRng(_rng);
		var _roll_scope = __CreateRollScope(true);
		var _outcome = __RollInternal(_requested_count, _context, _resolved_rng, _roll_scope, 0, undefined);
		var _diagnostics = __BuildRollDiagnostics(_roll_scope, _outcome);
		last_roll_diagnostics = _diagnostics;
		return {
			results: _outcome.results,
			roll: __BuildRollSummary(_requested_count, _outcome, _roll_scope),
			diagnostics: _diagnostics,
			selected_events: _roll_scope.rich_selected_events,
			table_summaries: _roll_scope.rich_table_summaries
		};
	}
	
	static Preview = function(_count = 1, _context = undefined) {
		return __BuildPreviewData(_count, _context);
	}
	
	static GetEntryProbability = function(_entry, _context = undefined) {
		if (!is_instanceof(_entry, FateEntry)) {
			return 0;
		}
		var _preview = __BuildPreviewData(1, _context);
		for (var i = 0; i < array_length(_preview.resolved_entries); i++) {
			var _resolved_entry = _preview.resolved_entries[i];
			if (_resolved_entry.entry_id == _entry.entry_id) {
				if (_resolved_entry.selected_in_guaranteed_phase) {
					return 1;
				}
				return _resolved_entry.weighted_probability;
			}
		}
		return 0;
	}
	
	static GetValueProbability = function(_value, _context = undefined) {
		var _preview = __BuildPreviewData(1, _context);
		var _chance = 0;
		for (var i = 0; i < array_length(entries); i++) {
			var _entry = entries[i];
			var _resolved_entry = _preview.resolved_entries[i];
			var _entry_probability = _resolved_entry.weighted_probability;
			if (_resolved_entry.selected_in_guaranteed_phase) {
				_entry_probability = 1;
			}
			if (is_instanceof(_entry, FateValueEntry)) {
				if (_entry.GetValue() == _value) {
					_chance += _entry_probability;
				}
			}
			else if (_entry == _value) {
				_chance += _entry_probability;
			}
		}
		return _chance;
	}
	
	for (var i = 0; i < array_length(_entries); i++) {
		AddEntry(_entries[i]);
	}
}

///@func	FateValueEntry(value)
///@param	{Any}	_value
///@desc	Fate entry wrapper for plain value payloads.
function FateValueEntry(_value) : FateEntry() constructor {
	value = _value;
	
	static SetValue = function(_value) {
		value = _value;
		return self;
	}
	
	static GetValue = function() {
		return value;
	}
}

///@func	FateTableEntry(table, count)
///@param	{Struct.FateTable}	_table
///@param	{Real}	_count
///@desc	Fate entry wrapper for nested table selection.
function FateTableEntry(_table, _count = 1) : FateEntry() constructor {
	table = _table;
	count = __FateSanitizeNestedCount(_count, 1);
	
	static SetTable = function(_table) {
		table = _table;
		return self;
	}
	
	static GetTable = function() {
		return table;
	}
	
	static SetCount = function(_count = 1) {
		count = __FateSanitizeNestedCount(_count, 1);
		return self;
	}
	
	static GetCount = function() {
		return count;
	}
	
	static ResolveForRoll = function(_context) {
		return {
			enabled: enabled,
			weight: weight,
			guaranteed: guaranteed,
			guaranteed_priority: guaranteed_priority,
			unique: unique,
			unique_key: unique_key,
			nested_count: count
		};
	}
}

///@func	FateCreatorEntry(constructor, args)
///@param	{Any}	_ctor
///@param	{Any}	_args
///@desc	Fate entry that instantiates a new value when selected.
function FateCreatorEntry(_ctor, _args = undefined) : FateEntry() constructor {
	ctor = _ctor;
	args = _args;
	
	static SetConstructor = function(_ctor) {
		ctor = _ctor;
		return self;
	}
	
	static GetConstructor = function() {
		return ctor;
	}
	
	static SetArgs = function(_args = undefined) {
		args = _args;
		return self;
	}
	
	static GetArgs = function() {
		return args;
	}
	
	static ResolveForRoll = function(_context) {
		return {
			enabled: enabled,
			weight: weight,
			guaranteed: guaranteed,
			guaranteed_priority: guaranteed_priority,
			unique: unique,
			unique_key: unique_key,
			creator_args: args
		};
	}
	
	///@ignore
	static __Instantiate = function(_override_args = undefined) {
		var _final_args = args;
		if (_override_args != undefined) {
			_final_args = _override_args;
		}
		if (object_exists(ctor)) {
			return instance_create_depth(0, 0, 0, ctor, _final_args);
		}
		if (is_callable(ctor)) {
			return new ctor(_final_args);
		}
		return undefined;
	}
}

///@func	FateRng(seed)
///@param	{Real}	_seed
///@desc	Seeded deterministic RNG for Fate that returns unit values in [0,1).
function FateRng(_seed) constructor {
	seed = __FateSanitizeSeed(_seed, 0);
	static __u32_mod = 4294967296.0;
	static __lcg_mult = 1664525.0;
	static __lcg_inc = 1013904223.0;

	static NextUnit = function() {
		var _next_seed = ((seed + 0.0) * __lcg_mult) + __lcg_inc;
		_next_seed = _next_seed mod __u32_mod;
		if (_next_seed < 0) {
			_next_seed += __u32_mod;
		}
		seed = floor(_next_seed);
		return seed / __u32_mod;
	}
	
	static GetState = function() {
		return {
			seed: seed
		};
	}
	
	static SetState = function(_state) {
		if (is_struct(_state)) {
			seed = __FateSanitizeSeed(_state[$ "seed"], 0);
		}
		return self;
	}
}

///@func	FateRollValues(table, count, context, rng)
///@param	{Struct.FateTable}	_table
///@param	{Real}	_count
///@param	{Any}	_context
///@param	{Any}	_rng
///@desc	Beginner helper that rolls a table and returns raw values in `data.values`.
///@return	{Struct}
function FateRollValues(_table, _count = 1, _context = undefined, _rng = undefined) {
	if (!is_instanceof(_table, FateTable)) {
		return __FateWrapResult(false, "invalid_table", {
			values: [],
			entries: [],
			non_value_count: 0
			}, "roll");
	}
	
	var _entries = _table.Roll(_count, _context, _rng);
	if (!is_array(_entries)) {
		return __FateWrapResult(false, "roll_failed", {
			values: [],
			entries: [],
			non_value_count: 0
			}, "roll");
	}
	
	var _values = [];
	var _non_value_count = 0;
	for (var i = 0; i < array_length(_entries); i++) {
		var _entry = _entries[i];
		var _value = _entry;
		if (is_instanceof(_entry, FateValueEntry)) {
			_value = _entry.GetValue();
		}
		else {
			_non_value_count++;
		}
		array_push(_values, _value);
	}
	
	var _code = "rolled_values";
	if (_non_value_count > 0) {
		_code = "rolled_values_with_non_value_entries";
	}
	return __FateWrapResult(true, _code, {
		values: _values,
		entries: _entries,
		non_value_count: _non_value_count
		}, "roll");
}

///@func	FateTrackTable(key, table)
///@param	{String}	_key
///@param	{Struct.FateTable}	_table
///@desc	Beginner helper that tracks a table key for snapshot save/load.
///@return	{Struct}
function FateTrackTable(_key, _table) {
	return FateAdvancedRegisterTableState(_key, _table);
}

///@func	FateUntrackTable(key)
///@param	{String}	_key
///@desc	Beginner helper that removes a tracked table key.
///@return	{Struct}
function FateUntrackTable(_key) {
	return FateAdvancedUnregisterTableState(_key);
}

///@func	FateListTrackedTables()
///@desc	Beginner helper that returns tracked table keys in `data.keys`.
///@return	{Struct}
function FateListTrackedTables() {
	return FateAdvancedGetRegisteredTableStateKeys();
}

///@func	FateSaveSnapshotFile(filename)
///@param	{String}	_filename
///@desc	Beginner helper that saves all tracked table state to a snapshot file.
///@return	{Struct}
function FateSaveSnapshotFile(_filename) {
	return FateAdvancedSaveRegisteredTableStatesFile(_filename);
}

///@func	FateLoadSnapshotFile(filename)
///@param	{String}	_filename
///@desc	Beginner helper that loads a snapshot file and restores tracked tables.
///@return	{Struct}
function FateLoadSnapshotFile(_filename) {
	return FateAdvancedLoadRegisteredTableStatesFile(_filename);
}

///@func	FateAdvancedSaveStateFile(filename, state)
///@param	{String}	_filename
///@param	{Struct}	_state
///@desc	Saves a Fate state struct to a JSON file.
///@return	{Struct}
function FateAdvancedSaveStateFile(_filename, _state) {
	if (!is_string(_filename)) {
		return __FateWrapResult(false, "invalid_filename_type", {
			filename: _filename
			}, "file");
	}
	if (string_length(_filename) <= 0) {
		return __FateWrapResult(false, "invalid_filename_empty", {
			filename: _filename
			}, "file");
	}
	if (!is_struct(_state)) {
		return __FateWrapResult(false, "invalid_state", {
			filename: _filename
			}, "file");
	}
	var _file = file_text_open_write(_filename);
	if (_file == -1) {
		return __FateWrapResult(false, "open_failed", {
			filename: _filename
			}, "file");
	}
	file_text_write_string(_file, json_stringify(_state, false));
	var _closed = file_text_close(_file);
	if (is_bool(_closed)) {
		if (!_closed) {
			return __FateWrapResult(false, "close_failed", {
				filename: _filename
				}, "file");
		}
	}
	return __FateWrapResult(true, "saved", {
		filename: _filename
		}, "file");
}

///@func	FateAdvancedLoadStateFile(filename)
///@param	{String}	_filename
///@desc	Loads a Fate state struct from a JSON file.
///@return	{Struct}
function FateAdvancedLoadStateFile(_filename) {
	if (!is_string(_filename)) {
		return __FateWrapResult(false, "invalid_filename_type", {
			filename: _filename
			}, "file");
	}
	if (string_length(_filename) <= 0) {
		return __FateWrapResult(false, "invalid_filename_empty", {
			filename: _filename
			}, "file");
	}
	if (!file_exists(_filename)) {
		return __FateWrapResult(false, "file_missing", {
			filename: _filename
			}, "file");
	}
	var _file = file_text_open_read(_filename);
	if (_file == -1) {
		return __FateWrapResult(false, "open_failed", {
			filename: _filename
			}, "file");
	}
	var _json = "";
	while (!file_text_eof(_file)) {
		_json += file_text_readln(_file);
	}
	var _closed = file_text_close(_file);
	if (is_bool(_closed)) {
		if (!_closed) {
			return __FateWrapResult(false, "close_failed", {
				filename: _filename
				}, "file");
		}
	}
	if (string_length(_json) <= 0) {
		return __FateWrapResult(false, "empty_file", {
			filename: _filename
			}, "file");
	}
	var _state = json_parse(_json);
	if (!is_struct(_state)) {
		return __FateWrapResult(false, "state_not_struct", {
			filename: _filename
			}, "file");
	}
	return __FateWrapResult(true, "loaded", {
		filename: _filename,
		state: _state
		}, "file");
}

///@func	FateAdvancedRegisterTableState(key, table, opts)
///@param	{String}	_key
///@param	{Struct.FateTable}	_table
///@param	{Struct}	_opts
///@desc	Registers a table for snapshot persistence under a stable key using a weak reference.
///@return	{Struct}
function FateAdvancedRegisterTableState(_key, _table, _opts = undefined) {
	if (!is_string(_key)) {
		return __FateWrapResult(false, "invalid_key", {
			key: _key,
			replaced: false
			}, "registry_mutation");
	}
	if (string_length(_key) <= 0) {
		return __FateWrapResult(false, "invalid_key", {
			key: _key,
			replaced: false
			}, "registry_mutation");
	}
	if (!is_instanceof(_table, FateTable)) {
		return __FateWrapResult(false, "invalid_table", {
			key: _key,
			replaced: false
			}, "registry_mutation");
	}
	
	var _allow_replace = false;
	if (is_struct(_opts)) {
		_allow_replace = __FateSanitizeBool(_opts[$ "allow_replace"], false);
	}
	
	var _store = __FateRegisteredTablesStore();
	var _registry = _store.tables;
	var _existing_ref = _registry[$ _key];
	if (_existing_ref != undefined) {
		var _existing_table = __FateResolveRegisteredTable(_existing_ref);
		if (is_instanceof(_existing_table, FateTable)) {
			if (_existing_table == _table) {
				return __FateWrapResult(true, "already_registered_same", {
					key: _key,
					replaced: false
					}, "registry_mutation");
			}
			if (!_allow_replace) {
				return __FateWrapResult(false, "duplicate_key_conflict", {
					key: _key,
					replaced: false
					}, "registry_mutation");
			}
			_registry[$ _key] = weak_ref_create(_table);
			return __FateWrapResult(true, "replaced", {
				key: _key,
				replaced: true
				}, "registry_mutation");
		}
	}
	
	_registry[$ _key] = weak_ref_create(_table);
	return __FateWrapResult(true, "registered", {
		key: _key,
		replaced: false
		}, "registry_mutation");
}

///@func	FateAdvancedUnregisterTableState(key)
///@param	{String}	_key
///@desc	Removes a previously registered state key from the registry.
///@return	{Struct}
function FateAdvancedUnregisterTableState(_key) {
	if (!is_string(_key)) {
		return __FateWrapResult(false, "invalid_key", {
			key: _key,
			removed: false
			}, "registry_mutation");
	}
	if (string_length(_key) <= 0) {
		return __FateWrapResult(false, "invalid_key", {
			key: _key,
			removed: false
			}, "registry_mutation");
	}
	
	var _store = __FateRegisteredTablesStore();
	var _registry = _store.tables;
	var _existing_ref = _registry[$ _key];
	if (_existing_ref == undefined) {
		return __FateWrapResult(false, "not_found", {
			key: _key,
			removed: false
			}, "registry_mutation");
	}
	
	struct_remove(_registry, _key);
	return __FateWrapResult(true, "unregistered", {
		key: _key,
		removed: true
		}, "registry_mutation");
}

///@func	FateAdvancedGetRegisteredTableStateKeys()
///@desc	Returns a wrapper result with current registry keys in `data.keys`.
///@return	{Struct}
function FateAdvancedGetRegisteredTableStateKeys() {
	var _store = __FateRegisteredTablesStore();
	return __FateWrapResult(true, "keys_listed", {
		keys: struct_get_names(_store.tables)
		}, "registry_keys");
}

///@func	FateAdvancedPruneRegisteredTableStates()
///@desc	Prunes dead or invalid registered table references and returns prune counters in `data`.
///@return	{Struct}
function FateAdvancedPruneRegisteredTableStates() {
	var _resolved = __FateBuildRegisteredTableMap(true);
	return __FateWrapResult(true, "pruned", {
		registered_count: _resolved.registered_count,
		live_count: _resolved.live_count,
		pruned_dead_count: _resolved.pruned_dead_count
		}, "prune");
}

///@func	FateAdvancedCaptureRegisteredTableStates(opts)
///@param	{Struct}	_opts
///@desc	Captures state for all registered live tables and returns bundle/report in `data`.
///@return	{Struct}
function FateAdvancedCaptureRegisteredTableStates(_opts = undefined) {
	var _prune_dead = true;
	if (is_struct(_opts)) {
		_prune_dead = __FateSanitizeBool(_opts[$ "prune_dead"], true);
	}
	
	var _resolved = __FateBuildRegisteredTableMap(_prune_dead);
	var _capture = FateAdvancedCaptureTableStates(_resolved.table_map);
	var _state = undefined;
	if (is_struct(_capture.data)) {
		_state = _capture.data[$ "state"];
	}
	return __FateWrapResult(_capture.ok, _capture.code, {
		state: _state,
		report: {
			registered_count: _resolved.registered_count,
			live_count: _resolved.live_count,
			captured_count: _resolved.live_count,
			pruned_dead_count: _resolved.pruned_dead_count
		}
		}, "capture");
}

///@func	FateAdvancedRestoreRegisteredTableStates(bundle_state, opts)
///@param	{Struct}	_bundle_state
///@param	{Struct}	_opts
///@desc	Restores all registered live tables from the bundle and returns counters in `data`.
///@return	{Struct}
function FateAdvancedRestoreRegisteredTableStates(_bundle_state, _opts = undefined) {
	var _prune_dead = true;
	if (is_struct(_opts)) {
		_prune_dead = __FateSanitizeBool(_opts[$ "prune_dead"], true);
	}
	
	var _resolved = __FateBuildRegisteredTableMap(_prune_dead);
	var _restore = FateAdvancedRestoreTableStates(_resolved.table_map, _bundle_state);
	var _data = {};
	if (is_struct(_restore.data)) {
		_data = _restore.data;
	}
	_data.registered_count = _resolved.registered_count;
	_data.live_count = _resolved.live_count;
	_data.pruned_dead_count = _resolved.pruned_dead_count;
	return __FateWrapResult(_restore.ok, _restore.code, _data, "restore");
}

///@func	FateAdvancedSaveRegisteredTableStatesFile(filename, opts)
///@param	{String}	_filename
///@param	{Struct}	_opts
///@desc	Captures registered table state, saves JSON, and returns nested capture/save results in `data`.
///@return	{Struct}
function FateAdvancedSaveRegisteredTableStatesFile(_filename, _opts = undefined) {
	var _capture = FateAdvancedCaptureRegisteredTableStates(_opts);
	if (!_capture.ok) {
		return __FateWrapResult(false, _capture.code, {
			filename: _filename,
			capture: _capture
			}, "pipeline");
	}
	var _capture_data = _capture.data;
	var _state = undefined;
	if (is_struct(_capture_data)) {
		_state = _capture_data[$ "state"];
	}
	if (!is_struct(_state)) {
		return __FateWrapResult(false, "capture_state_missing", {
			filename: _filename,
			capture: _capture
			}, "pipeline");
	}
	var _save = FateAdvancedSaveStateFile(_filename, _state);
	if (!_save.ok) {
		return __FateWrapResult(false, _save.code, {
			filename: _filename,
			capture: _capture,
			save: _save
			}, "pipeline");
	}
	return __FateWrapResult(true, "saved", {
		filename: _filename,
		capture: _capture,
		save: _save
		}, "pipeline");
}

///@func	FateAdvancedLoadRegisteredTableStatesFile(filename, opts)
///@param	{String}	_filename
///@param	{Struct}	_opts
///@desc	Loads a JSON snapshot, restores matching registered tables, and returns nested load/restore results in `data`.
///@return	{Struct}
function FateAdvancedLoadRegisteredTableStatesFile(_filename, _opts = undefined) {
	var _load = FateAdvancedLoadStateFile(_filename);
	if (!_load.ok) {
		return __FateWrapResult(false, _load.code, {
			filename: _filename,
			load: _load,
			restore: FateAdvancedRestoreRegisteredTableStates(undefined, _opts)
			}, "pipeline");
	}
	var _state = undefined;
	if (is_struct(_load.data)) {
		_state = _load.data[$ "state"];
	}
	var _restore = FateAdvancedRestoreRegisteredTableStates(_state, _opts);
	if (!_restore.ok) {
		return __FateWrapResult(false, _restore.code, {
			filename: _filename,
			load: _load,
			restore: _restore
			}, "pipeline");
	}
	return __FateWrapResult(true, "loaded_and_restored", {
		filename: _filename,
		load: _load,
		restore: _restore
		}, "pipeline");
}

///@func	FateAdvancedCaptureTableStates(table_map)
///@param	{Struct}	_table_map
///@desc	Captures state for multiple Fate tables and returns bundle/counters in `data`.
///@return	{Struct}
function FateAdvancedCaptureTableStates(_table_map) {
	if (!is_struct(_table_map)) {
		return __FateWrapResult(false, "invalid_table_map", {
			state: {
				format: "fate_tables_state",
				version: 1,
				tables: {}
			},
			captured_count: 0,
			skipped_count: 0
			}, "capture");
	}
	var _tables_state = {};
	var _captured_count = 0;
	var _skipped_count = 0;
	var _keys = struct_get_names(_table_map);
	for (var i = 0; i < array_length(_keys); i++) {
		var _key = _keys[i];
		var _table = _table_map[$ _key];
		if (is_instanceof(_table, FateTable)) {
			_tables_state[$ _key] = _table.GetState();
			_captured_count++;
		}
		else {
			_skipped_count++;
		}
	}
	return __FateWrapResult(true, "captured", {
		state: {
			format: "fate_tables_state",
			version: 1,
			tables: _tables_state
		},
		captured_count: _captured_count,
		skipped_count: _skipped_count
		}, "capture");
}

///@func	FateAdvancedRestoreTableStates(table_map, bundle_state)
///@param	{Struct}	_table_map
///@param	{Struct}	_bundle_state
///@desc	Restores multiple Fate tables from a bundle and returns restore counters in `data`.
///@return	{Struct}
function FateAdvancedRestoreTableStates(_table_map, _bundle_state) {
	var _report = {
		attempted_count: 0,
		applied_count: 0,
		invalid_count: 0,
		missing_count: 0,
		skipped_count: 0
	};
	if (!is_struct(_table_map)) {
		return __FateWrapResult(false, "invalid_table_map", _report, "restore");
	}
	if (!is_struct(_bundle_state)) {
		return __FateWrapResult(false, "invalid_bundle_state", _report, "restore");
	}
	var _tables_state = _bundle_state[$ "tables"];
	if (!is_struct(_tables_state)) {
		return __FateWrapResult(false, "invalid_bundle_tables", _report, "restore");
	}
	var _keys = struct_get_names(_table_map);
	for (var i = 0; i < array_length(_keys); i++) {
		var _key = _keys[i];
		var _table = _table_map[$ _key];
		if (!is_instanceof(_table, FateTable)) {
			_report.skipped_count++;
			continue;
		}
		_report.attempted_count++;
		var _state = _tables_state[$ _key];
		if (!is_struct(_state)) {
			_report.missing_count++;
			continue;
		}
		var _validation = _table.ValidateState(_state);
		if (!is_struct(_validation)) {
			_report.invalid_count++;
			continue;
		}
		
		var _issues = _validation[$ "issues"];
		if (is_array(_issues)) {
			__FateValidationReportIssues(_table.GetStrictness(), _issues);
		}
		
		var _sanitized_state = _validation[$ "sanitized_state"];
		if (!is_struct(_sanitized_state)) {
			_report.invalid_count++;
			continue;
		}
		_table.SetState(_sanitized_state);
		_report.applied_count++;
	}
	var _code = "restored";
	if ((_report.invalid_count > 0) || (_report.missing_count > 0) || (_report.skipped_count > 0)) {
		_code = "restored_with_issues";
	}
	return __FateWrapResult(true, _code, _report, "restore");
}

///@func	FateAdvancedValidateTableConfig(table, opts)
///@param	{Struct.FateTable}	_table
///@param	{Struct}	_opts
///@desc	Validates a Fate table configuration and returns a structured report.
///@return	{Struct}
function FateAdvancedValidateTableConfig(_table, _opts = undefined) {
	if (!is_instanceof(_table, FateTable)) {
		var _report = __FateValidationCreateReport(undefined);
		__FateValidationAddIssue(_report, "error", "table_config_not_table", "table", "Value must be a FateTable", undefined, undefined, undefined);
		return _report;
	}
	if (!is_callable(_table[$ "ValidateConfig"])) {
		var _report = __FateValidationCreateReport(_table.GetTableId());
		__FateValidationAddIssue(_report, "error", "table_config_missing_method", "table.ValidateConfig", "Table is missing ValidateConfig", _table.GetTableId(), undefined, undefined);
		return _report;
	}
	return _table.ValidateConfig(_opts);
}

///@func	FateAdvancedValidateTableState(table, state, opts)
///@param	{Struct.FateTable}	_table
///@param	{Struct}	_state
///@param	{Struct}	_opts
///@desc	Validates a Fate table state payload and returns a structured report.
///@return	{Struct}
function FateAdvancedValidateTableState(_table, _state, _opts = undefined) {
	if (!is_instanceof(_table, FateTable)) {
		var _report = __FateValidationCreateReport(undefined);
		__FateValidationAddIssue(_report, "error", "table_state_not_table", "table", "Value must be a FateTable", undefined, undefined, undefined);
		return _report;
	}
	if (!is_callable(_table[$ "ValidateState"])) {
		var _report = __FateValidationCreateReport(_table.GetTableId());
		__FateValidationAddIssue(_report, "error", "table_state_missing_method", "table.ValidateState", "Table is missing ValidateState", _table.GetTableId(), undefined, undefined);
		return _report;
	}
	return _table.ValidateState(_state, _opts);
}
