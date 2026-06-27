enum FateStrictness {
	SILENT,
	DEBUG,
	ERROR
}

///@ignore
function __FateNextRollId() {
	static __counter = 0;
	__counter++;
	return __counter;
}

///@ignore
function __FateNextTableCallId() {
	static __counter = 0;
	__counter++;
	return __counter;
}

///@ignore
function __FateNextPolicyId() {
	static __counter = 0;
	__counter++;
	return __counter;
}

///@ignore
function __FateIsFiniteReal(_value) {
	if (is_int32(_value)) {
		return true;
	}
	if (is_int64(_value)) {
		return true;
	}
	if (!is_real(_value)) {
		return false;
	}
	if (_value != _value) {
		return false;
	}
	if (_value == infinity) {
		return false;
	}
	if (_value == -infinity) {
		return false;
	}
	return true;
}

///@ignore
function __FateSanitizeBool(_value, _default = false) {
	if (is_bool(_value)) {
		return _value;
	}
	return _default;
}

///@ignore
function __FateSanitizeWeight(_value, _default = 0) {
	if (!__FateIsFiniteReal(_value)) {
		return _default;
	}
	if (_value < 0) {
		return _default;
	}
	return _value;
}

///@ignore
function __FateSanitizePriority(_value, _default = 0) {
	if (!__FateIsFiniteReal(_value)) {
		return _default;
	}
	return _value;
}

///@ignore
function __FateSanitizeRollCount(_value, _default = 1) {
	if (!__FateIsFiniteReal(_value)) {
		return _default;
	}
	var _count = floor(_value);
	if (_count < 0) {
		_count = 0;
	}
	return _count;
}

///@ignore
function __FateSanitizeNestedCount(_value, _default = 1) {
	if (!__FateIsFiniteReal(_value)) {
		return _default;
	}
	var _count = floor(_value);
	if (_count < 1) {
		_count = 1;
	}
	return _count;
}

///@ignore
function __FateSanitizeStrictness(_value, _default = FateStrictness.DEBUG) {
	if (_value == FateStrictness.SILENT) {
		return _value;
	}
	else if (_value == FateStrictness.DEBUG) {
		return _value;
	}
	else if (_value == FateStrictness.ERROR) {
		return _value;
	}
	return _default;
}

///@ignore
function __FateSanitizeSeed(_value, _default = 0) {
	static __u32_mod = 4294967296.0;
	var _seed = _default;
	if (__FateIsFiniteReal(_value)) {
		_seed = floor(_value);
	}
	_seed = (_seed + 0.0) mod __u32_mod;
	if (_seed < 0) {
		_seed += __u32_mod;
	}
	return floor(_seed);
}

///@ignore
function __FateReport(_strictness, _message) {
	if (_strictness == FateStrictness.ERROR) {
		show_error(_message, true);
		return false;
	}
	if (_strictness == FateStrictness.DEBUG) {
		show_debug_message(_message);
	}
	return false;
}

///@ignore
function __FateSanitizeReturnKind(_kind, _default = "generic") {
	if (!is_string(_kind)) {
		return _default;
	}
	if (string_length(_kind) <= 0) {
		return _default;
	}
	return _kind;
}

///@ignore
function __FateDefaultRng() {
	static __default_rng = {
		NextUnit: function() {
			var _value = random(1);
			if (_value >= 1) {
				_value = 0.9999999999999999;
			}
			if (_value < 0) {
				_value = 0;
			}
			return _value;
		}
	};
	return __default_rng;
}

///@ignore
function __FateResolveRng(_rng) {
	if (!is_struct(_rng)) {
		return __FateDefaultRng();
	}
	var _next = _rng[$ "NextUnit"];
	if (!is_callable(_next)) {
		return __FateDefaultRng();
	}
	return _rng;
}

///@ignore
function __FateIsValidUnit(_value) {
	if (!__FateIsFiniteReal(_value)) {
		return false;
	}
	if (_value < 0) {
		return false;
	}
	if (_value >= 1) {
		return false;
	}
	return true;
}

///@ignore
function __FateRngNextUnit(_rng, _strictness, _roll_scope, _table_id, _table_call_id) {
	var _value = _rng.NextUnit();
	if (is_struct(_rng)) {
		if (is_instanceof(_rng, FateRng)) {
			if (is_callable(_rng[$ "GetState"])) {
				var _rng_state = _rng.GetState();
				if (is_struct(_rng_state)) {
					var _seed = __FateSanitizeSeed(_rng_state[$ "seed"], 0);
					return (_seed + 0.0) / 4294967296.0;
				}
			}
		}
	}
	if (__FateIsValidUnit(_value)) {
		return _value;
	}
	_roll_scope[$ "invalid_rng_draws"] += 1;
	__FateReport(_strictness, $"Fate RNG returned invalid value for table {_table_id}, table call {_table_call_id}");
	var _fallback = __FateDefaultRng().NextUnit();
	if (__FateIsValidUnit(_fallback)) {
		return _fallback;
	}
	return 0;
}

///@ignore
function __FateUniqueToken(_record) {
	var _unique_key = _record.resolved.unique_key;
	if (_unique_key != undefined) {
		return _unique_key;
	}
	return _record.entry.entry_id;
}

///@ignore
function __FateTryConsumeUnique(_roll_scope, _record) {
	if (!_record.resolved.unique) {
		return true;
	}
	var _token = __FateUniqueToken(_record);
	if (array_contains(_roll_scope.unique_tokens, _token)) {
		return false;
	}
	array_push(_roll_scope.unique_tokens, _token);
	return true;
}

///@ignore
function __FateSortGuaranteedRecords(_records) {
	var _count = array_length(_records);
	for (var i = 0; i < _count - 1; i++) {
		for (var j = i + 1; j < _count; j++) {
			var _left = _records[i];
			var _right = _records[j];
			var _swap = false;
			if (_right.resolved.guaranteed_priority > _left.resolved.guaranteed_priority) {
				_swap = true;
			}
			else if (_right.resolved.guaranteed_priority == _left.resolved.guaranteed_priority) {
				if (_right.entry.insertion_order < _left.entry.insertion_order) {
					_swap = true;
				}
			}
			if (_swap) {
				var _temp = _records[i];
				_records[i] = _records[j];
				_records[j] = _temp;
			}
		}
	}
	return _records;
}

///@ignore
function __FateStateSanitizeCountMap(_source) {
	var _map = {};
	if (!is_struct(_source)) {
		return _map;
	}
	var _names = struct_get_names(_source);
	for (var i = 0; i < array_length(_names); i++) {
		var _name = _names[i];
		var _value = _source[$ _name];
		if (__FateIsFiniteReal(_value)) {
			_map[$ string(_name)] = max(0, floor(_value));
		}
	}
	return _map;
}

///@ignore
function __FateStateSanitizeRollMap(_source) {
	var _map = {};
	if (!is_struct(_source)) {
		return _map;
	}
	var _names = struct_get_names(_source);
	for (var i = 0; i < array_length(_names); i++) {
		var _name = _names[i];
		var _value = _source[$ _name];
		if (__FateIsFiniteReal(_value)) {
			_map[$ string(_name)] = floor(_value);
		}
	}
	return _map;
}

///@ignore
function __FateStateSanitizeStringArrayMap(_source, _max_per_scope = undefined) {
	var _map = {};
	if (!is_struct(_source)) {
		return _map;
	}
	var _names = struct_get_names(_source);
	for (var i = 0; i < array_length(_names); i++) {
		var _name = _names[i];
		var _values = _source[$ _name];
		if (!is_array(_values)) {
			continue;
		}
		var _clean = [];
		for (var j = 0; j < array_length(_values); j++) {
			var _value = _values[j];
			if (_value != undefined) {
				array_push(_clean, string(_value));
			}
		}
		if (__FateIsFiniteReal(_max_per_scope)) {
			var _limit = max(0, floor(_max_per_scope));
			if (_limit == 0) {
				_clean = [];
			}
			else {
				var _clean_count = array_length(_clean);
				if (_clean_count > _limit) {
					var _trimmed = [];
					var _start = _clean_count - _limit;
					for (var k = _start; k < _clean_count; k++) {
						array_push(_trimmed, _clean[k]);
					}
					_clean = _trimmed;
				}
			}
		}
		_map[$ string(_name)] = _clean;
	}
	return _map;
}

///@ignore
function __FateValidationCreateReport(_table_id = undefined) {
	return {
		ok: true,
		error_count: 0,
		warning_count: 0,
		issues: [],
		sanitized_state: undefined,
		table_id: _table_id
	};
}

///@ignore
function __FateValidationAddIssue(_report, _severity, _code, _path, _message, _table_id = undefined, _policy_index = undefined, _policy_name = undefined) {
	var _normalized_severity = "error";
	if (_severity == "warning") {
		_normalized_severity = "warning";
	}
	
	if (_normalized_severity == "error") {
		_report.error_count++;
		_report.ok = false;
	}
	else {
		_report.warning_count++;
	}
	
	array_push(_report.issues, {
		severity: _normalized_severity,
		code: string(_code),
		path: string(_path),
		message: string(_message),
		table_id: _table_id,
		policy_index: _policy_index,
		policy_name: _policy_name
	});
}

///@ignore
function __FateValidationReportIssues(_strictness, _issues) {
	for (var i = 0; i < array_length(_issues); i++) {
		var _issue = _issues[i];
		var _severity = _issue[$ "severity"];
		var _code = _issue[$ "code"];
		var _path = _issue[$ "path"];
		var _message = _issue[$ "message"];
		var _text = $"Fate validation [{_severity}] {_code}";
		if (string_length(_path) > 0) {
			_text += $" at {_path}";
		}
		if (string_length(_message) > 0) {
			_text += $": {_message}";
		}
		
		if (_severity == "error") {
			__FateReport(_strictness, _text);
		}
		else if (_strictness == FateStrictness.DEBUG) {
			show_debug_message(_text);
		}
	}
}

///@ignore
function __FateResolveEntry(_entry, _context, _strictness, _table_id, _table_call_id) {
	var _raw = _entry.ResolveForRoll(_context);
	if (!is_struct(_raw)) {
		__FateReport(_strictness, $"Fate ResolveForRoll must return a struct for table {_table_id}, table call {_table_call_id}");
		_raw = {};
	}
	
	var _enabled_raw = _raw[$ "enabled"];
	var _enabled = _entry.GetEnabled();
	if (_enabled_raw != undefined) {
		if (is_bool(_enabled_raw)) {
			_enabled = _enabled_raw;
		}
		else {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid enabled value for table {_table_id}, table call {_table_call_id}");
		}
	}
	
	var _weight_raw = _raw[$ "weight"];
	var _weight = _entry.GetWeight();
	if (_weight_raw != undefined) {
		if (__FateIsFiniteReal(_weight_raw)) {
			if (_weight_raw >= 0) {
				_weight = _weight_raw;
			}
			else {
				__FateReport(_strictness, $"Fate ResolveForRoll provided negative weight for table {_table_id}, table call {_table_call_id}");
			}
		}
		else {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid weight for table {_table_id}, table call {_table_call_id}");
		}
	}
	
	var _guaranteed_raw = _raw[$ "guaranteed"];
	var _guaranteed = _entry.GetGuaranteed();
	if (_guaranteed_raw != undefined) {
		if (is_bool(_guaranteed_raw)) {
			_guaranteed = _guaranteed_raw;
		}
		else {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid guaranteed value for table {_table_id}, table call {_table_call_id}");
		}
	}
	
	var _priority_raw = _raw[$ "guaranteed_priority"];
	var _guaranteed_priority = _entry.GetGuaranteedPriority();
	if (_priority_raw != undefined) {
		if (__FateIsFiniteReal(_priority_raw)) {
			_guaranteed_priority = _priority_raw;
		}
		else {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid guaranteed priority for table {_table_id}, table call {_table_call_id}");
		}
	}
	
	var _unique_raw = _raw[$ "unique"];
	var _unique = _entry.GetUnique();
	if (_unique_raw != undefined) {
		if (is_bool(_unique_raw)) {
			_unique = _unique_raw;
		}
		else {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid unique value for table {_table_id}, table call {_table_call_id}");
		}
	}
	
	var _nested_count = _raw[$ "nested_count"];
	if (_nested_count != undefined) {
		if (!__FateIsFiniteReal(_nested_count)) {
			__FateReport(_strictness, $"Fate ResolveForRoll provided invalid nested count for table {_table_id}, table call {_table_call_id}");
			_nested_count = 1;
		}
		_nested_count = __FateSanitizeNestedCount(_nested_count, 1);
	}
	
	return {
		enabled: _enabled,
		weight: _weight,
		guaranteed: _guaranteed,
		guaranteed_priority: _guaranteed_priority,
		unique: _unique,
		unique_key: (_raw[$ "unique_key"] != undefined) ? _raw[$ "unique_key"] : _entry.GetUniqueKey(),
		nested_count: _nested_count,
		creator_args: _raw[$ "creator_args"]
	};
}

///@ignore
function __FateBeginnerTryAddEntryToIdMap(_entry_id_map, _entry, _strictness, _table_id, _api_name, _path) {
	if (!is_instanceof(_entry, FateEntry)) {
		__FateReport(_strictness, $"{_api_name} requires FateEntry values in {_path} on table {_table_id}");
		return false;
	}
	if (is_instanceof(_entry, FateTable)) {
		__FateReport(_strictness, $"{_api_name} does not accept FateTable values in {_path} on table {_table_id}. Use FateTableEntry.");
		return false;
	}
	
	var _entry_id = _entry.entry_id;
	if (!__FateIsFiniteReal(_entry_id)) {
		__FateReport(_strictness, $"{_api_name} found an entry without a valid entry_id in {_path} on table {_table_id}");
		return false;
	}
	
	_entry_id_map[$ string(floor(_entry_id))] = true;
	return true;
}

///@ignore
function __FateBeginnerCollectEntryIdMap(_entries, _strictness, _table_id, _api_name, _arg_name) {
	var _entry_id_map = {};
	var _valid_count = 0;
	
	if (is_instanceof(_entries, FateEntry)) {
		if (__FateBeginnerTryAddEntryToIdMap(_entry_id_map, _entries, _strictness, _table_id, _api_name, _arg_name)) {
			_valid_count++;
		}
	}
	else if (is_array(_entries)) {
		for (var i = 0; i < array_length(_entries); i++) {
			var _entry = _entries[i];
			if (__FateBeginnerTryAddEntryToIdMap(_entry_id_map, _entry, _strictness, _table_id, _api_name, $"{_arg_name}[{i}]")) {
				_valid_count++;
			}
		}
	}
	else {
		__FateReport(_strictness, $"{_api_name} requires {_arg_name} to be a FateEntry or Array<FateEntry> on table {_table_id}");
		return undefined;
	}
	
	if (_valid_count <= 0) {
		__FateReport(_strictness, $"{_api_name} requires at least one valid FateEntry in {_arg_name} on table {_table_id}");
		return undefined;
	}
	
	return _entry_id_map;
}

///@ignore
function __FateBeginnerEntrySetMatcher(_entry_id_map) constructor {
	entry_id_map = {};
	if (is_struct(_entry_id_map)) {
		var _names = struct_get_names(_entry_id_map);
		for (var i = 0; i < array_length(_names); i++) {
			var _name = _names[i];
			entry_id_map[$ string(_name)] = true;
		}
	}
	
	static Matches = function(_entry, _context) {
		if (!is_instanceof(_entry, FateEntry)) {
			return false;
		}
		var _entry_id = _entry.entry_id;
		if (!__FateIsFiniteReal(_entry_id)) {
			return false;
		}
		return __FateSanitizeBool(entry_id_map[$ string(floor(_entry_id))], false);
	}
}

///@ignore
function __FateBeginnerResolveEntryMatcherMethod(_entries, _strictness, _table_id, _api_name, _arg_name) {
	var _entry_id_map = __FateBeginnerCollectEntryIdMap(_entries, _strictness, _table_id, _api_name, _arg_name);
	if (!is_struct(_entry_id_map)) {
		return undefined;
	}
	
	var _matcher_scope = new __FateBeginnerEntrySetMatcher(_entry_id_map);
	return method(_matcher_scope, _matcher_scope.Matches);
}

///@ignore
function __FateBeginnerContextScopeResolver(_context_key) constructor {
	context_key = string(_context_key);
	
	static Resolve = function(_context) {
		if (!is_struct(_context)) {
			return undefined;
		}
		return _context[$ context_key];
	}
}

///@ignore
function __FateBeginnerResolveScopeKeyMethod(_scope_context_key, _strictness, _table_id, _api_name) {
	if (_scope_context_key == undefined) {
		return undefined;
	}
	if (!is_string(_scope_context_key)) {
		__FateReport(_strictness, $"{_api_name} ignored invalid scope_context_key type on table {_table_id}");
		return undefined;
	}
	if (string_length(_scope_context_key) <= 0) {
		__FateReport(_strictness, $"{_api_name} ignored empty scope_context_key on table {_table_id}");
		return undefined;
	}
	
	var _resolver_scope = new __FateBeginnerContextScopeResolver(_scope_context_key);
	return method(_resolver_scope, _resolver_scope.Resolve);
}

///@ignore
function __FateBeginnerDuplicateKeyByEntryIdResolver() constructor {
	static Resolve = function(_entry, _context) {
		if (!is_instanceof(_entry, FateEntry)) {
			return undefined;
		}
		var _entry_id = _entry.entry_id;
		if (!__FateIsFiniteReal(_entry_id)) {
			return undefined;
		}
		return floor(_entry_id);
	}
}

///@ignore
function __FateBeginnerDuplicateKeyByUniqueKeyResolver() constructor {
	static Resolve = function(_entry, _context) {
		if (!is_instanceof(_entry, FateEntry)) {
			return undefined;
		}
		var _unique_key = _entry.GetUniqueKey();
		if (_unique_key != undefined) {
			return _unique_key;
		}
		var _entry_id = _entry.entry_id;
		if (!__FateIsFiniteReal(_entry_id)) {
			return undefined;
		}
		return floor(_entry_id);
	}
}

///@ignore
function __FateBeginnerResolveDuplicateKeyMethod(_key_mode, _strictness, _table_id, _api_name) {
	var _resolved_key_mode = "entry_id";
	if (is_string(_key_mode)) {
		if (_key_mode == "entry_id") {
			_resolved_key_mode = _key_mode;
		}
		else if (_key_mode == "unique_key") {
			_resolved_key_mode = _key_mode;
		}
		else {
			__FateReport(_strictness, $"{_api_name} received invalid key_mode on table {_table_id}; expected entry_id or unique_key");
		}
	}
	else if (_key_mode != undefined) {
		__FateReport(_strictness, $"{_api_name} received invalid key_mode type on table {_table_id}");
	}
	
	var _resolver_scope = undefined;
	if (_resolved_key_mode == "unique_key") {
		_resolver_scope = new __FateBeginnerDuplicateKeyByUniqueKeyResolver();
	}
	else {
		_resolver_scope = new __FateBeginnerDuplicateKeyByEntryIdResolver();
	}
	return method(_resolver_scope, _resolver_scope.Resolve);
}

///@ignore
function __FateRegisteredTablesStore() {
	static _store = {
		tables: {}
	};
	return _store;
}

///@ignore
function __FateResolveRegisteredTable(_weak_ref) {
	if (weak_ref_alive(_weak_ref) != true) {
		return undefined;
	}
	var _table = _weak_ref.ref;
	if (is_instanceof(_table, FateTable)) {
		return _table;
	}
	return undefined;
}

///@ignore
function __FateBuildRegisteredTableMap(_prune_dead = true) {
	var _store = __FateRegisteredTablesStore();
	var _registry = _store.tables;
	var _table_map = {};
	var _keys = struct_get_names(_registry);
	var _report = {
		registered_count: array_length(_keys),
		live_count: 0,
		pruned_dead_count: 0,
		table_map: _table_map
	};
	
	var _prune = __FateSanitizeBool(_prune_dead, true);
	for (var i = 0; i < array_length(_keys); i++) {
		var _key = _keys[i];
		var _weak_ref = _registry[$ _key];
		var _table = __FateResolveRegisteredTable(_weak_ref);
		if (is_instanceof(_table, FateTable)) {
			_table_map[$ _key] = _table;
			_report.live_count++;
			continue;
		}
		if (_prune) {
			struct_remove(_registry, _key);
			_report.pruned_dead_count++;
		}
	}
	return _report;
}
