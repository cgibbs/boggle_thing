///@ignore
function __FateReturn(_ok, _code, _data = undefined, _kind = "generic") constructor {
	ok = __FateSanitizeBool(_ok, false);
	code = string(_code);
	data = _data;
	kind = __FateSanitizeReturnKind(_kind, "generic");

	static IsOk = function() {
		return ok;
	}

	static IsError = function() {
		return !ok;
	}

	static GetCode = function() {
		return code;
	}

	static CodeIs = function(_code_to_match) {
		return (code == string(_code_to_match));
	}

	static GetData = function() {
		return data;
	}

	static GetReturnKind = function() {
		return kind;
	}
}

///@ignore
function FateRollReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "roll") constructor {
	static GetDrops = function() {
		var _values = [];
		if (is_struct(data)) {
			var _raw_values = data[$ "values"];
			if (is_array(_raw_values)) {
				_values = _raw_values;
			}
		}
		return _values;
	}

	static GetDropCount = function() {
		return array_length(GetDrops());
	}

	static GetDrop = function(_index, _default = undefined) {
		if (!__FateIsFiniteReal(_index)) {
			return _default;
		}
		var _values = GetDrops();
		var _i = floor(_index);
		if (_i < 0) {
			return _default;
		}
		if (_i >= array_length(_values)) {
			return _default;
		}
		return _values[_i];
	}

	static PeekFirstDrop = function(_default = undefined) {
		return GetDrop(0, _default);
	}

	static GetFirstDrop = function(_default = undefined) {
		return PeekFirstDrop(_default);
	}

	static PopFirstDrop = function(_default = undefined) {
		if (!is_struct(data)) {
			return _default;
		}
		var _values = data[$ "values"];
		if (!is_array(_values)) {
			return _default;
		}
		if (array_length(_values) <= 0) {
			return _default;
		}
		var _drop = _values[0];
		array_delete(_values, 0, 1);
		data[$ "values"] = _values;
		return _drop;
	}

	static RemoveFirstDrop = function(_default = undefined) {
		return PopFirstDrop(_default);
	}

	static GetEntries = function() {
		var _entries = [];
		if (is_struct(data)) {
			var _raw_entries = data[$ "entries"];
			if (is_array(_raw_entries)) {
				_entries = _raw_entries;
			}
		}
		return _entries;
	}

	static GetNonValueCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "non_value_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}
}

///@ignore
function FateFileReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "file") constructor {
	static GetFilename = function() {
		if (is_struct(data)) {
			var _filename = data[$ "filename"];
			if (_filename != undefined) {
				return string(_filename);
			}
		}
		return "";
	}

	static HasState = function() {
		if (!is_struct(data)) {
			return false;
		}
		return is_struct(data[$ "state"]);
	}

	static GetState = function(_default = undefined) {
		if (HasState()) {
			return data[$ "state"];
		}
		return _default;
	}
}

///@ignore
function FateRegistryMutationReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "registry_mutation") constructor {
	static GetKey = function() {
		if (is_struct(data)) {
			var _key = data[$ "key"];
			if (_key != undefined) {
				return string(_key);
			}
		}
		return "";
	}

	static WasReplaced = function() {
		if (is_struct(data)) {
			return __FateSanitizeBool(data[$ "replaced"], false);
		}
		return false;
	}

	static WasRemoved = function() {
		if (is_struct(data)) {
			return __FateSanitizeBool(data[$ "removed"], false);
		}
		return false;
	}

	static WasMutated = function() {
		if (!ok) {
			return false;
		}
		if (WasReplaced()) {
			return true;
		}
		if (WasRemoved()) {
			return true;
		}
		return ((code == "registered") || (code == "unregistered"));
	}
}

///@ignore
function FateRegistryKeysReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "registry_keys") constructor {
	static GetKeys = function() {
		if (is_struct(data)) {
			var _keys = data[$ "keys"];
			if (is_array(_keys)) {
				return _keys;
			}
		}
		return [];
	}

	static GetKeyCount = function() {
		return array_length(GetKeys());
	}

	static HasKey = function(_key) {
		return array_contains(GetKeys(), string(_key));
	}
}

///@ignore
function FatePruneReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "prune") constructor {
	static GetRegisteredCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "registered_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetLiveCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "live_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetPrunedDeadCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "pruned_dead_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}
}

///@ignore
function FateCaptureReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "capture") constructor {
	static HasState = function() {
		if (!is_struct(data)) {
			return false;
		}
		return is_struct(data[$ "state"]);
	}

	static GetState = function(_default = undefined) {
		if (HasState()) {
			return data[$ "state"];
		}
		return _default;
	}

	static GetTablesMap = function(_default = undefined) {
		var _state = GetState(undefined);
		if (is_struct(_state)) {
			var _tables = _state[$ "tables"];
			if (is_struct(_tables)) {
				return _tables;
			}
		}
		return _default;
	}

	static GetCapturedCount = function() {
		if (is_struct(data)) {
			var _captured = data[$ "captured_count"];
			if (__FateIsFiniteReal(_captured)) {
				return max(0, floor(_captured));
			}

			var _report = data[$ "report"];
			if (is_struct(_report)) {
				_captured = _report[$ "captured_count"];
				if (__FateIsFiniteReal(_captured)) {
					return max(0, floor(_captured));
				}
			}
		}
		return 0;
	}

	static GetSkippedCount = function() {
		if (is_struct(data)) {
			var _skipped = data[$ "skipped_count"];
			if (__FateIsFiniteReal(_skipped)) {
				return max(0, floor(_skipped));
			}
		}
		return 0;
	}

	static GetReport = function() {
		if (is_struct(data)) {
			var _report = data[$ "report"];
			if (is_struct(_report)) {
				return _report;
			}
		}
		return {
			captured_count: GetCapturedCount(),
			skipped_count: GetSkippedCount()
		};
	}
}

///@ignore
function FateRestoreReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "restore") constructor {
	static GetAttemptedCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "attempted_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetAppliedCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "applied_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetInvalidCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "invalid_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetMissingCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "missing_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetSkippedCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "skipped_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static HadIssues = function() {
		if (GetInvalidCount() > 0) {
			return true;
		}
		if (GetMissingCount() > 0) {
			return true;
		}
		if (GetSkippedCount() > 0) {
			return true;
		}
		return false;
	}

	static GetRegisteredCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "registered_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetLiveCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "live_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}

	static GetPrunedDeadCount = function() {
		if (is_struct(data)) {
			var _count = data[$ "pruned_dead_count"];
			if (__FateIsFiniteReal(_count)) {
				return max(0, floor(_count));
			}
		}
		return 0;
	}
}

///@ignore
function FatePipelineReturn(_ok, _code, _data = undefined) : __FateReturn(_ok, _code, _data, "pipeline") constructor {
	static GetFilename = function() {
		if (is_struct(data)) {
			var _filename = data[$ "filename"];
			if (_filename != undefined) {
				return string(_filename);
			}
		}
		return "";
	}

	static GetCaptureResult = function() {
		if (is_struct(data)) {
			var _capture = data[$ "capture"];
			if (is_struct(_capture)) {
				return _capture;
			}
		}
		return undefined;
	}

	static GetSaveResult = function() {
		if (is_struct(data)) {
			var _save = data[$ "save"];
			if (is_struct(_save)) {
				return _save;
			}
		}
		return undefined;
	}

	static GetLoadResult = function() {
		if (is_struct(data)) {
			var _load = data[$ "load"];
			if (is_struct(_load)) {
				return _load;
			}
		}
		return undefined;
	}

	static GetRestoreResult = function() {
		if (is_struct(data)) {
			var _restore = data[$ "restore"];
			if (is_struct(_restore)) {
				return _restore;
			}
		}
		return undefined;
	}

	static AllNestedOk = function() {
		var _any = false;
		var _all_ok = true;

		var _capture = GetCaptureResult();
		if (is_struct(_capture)) {
			_any = true;
			if (!__FateSanitizeBool(_capture[$ "ok"], false)) {
				_all_ok = false;
			}
		}

		var _save = GetSaveResult();
		if (is_struct(_save)) {
			_any = true;
			if (!__FateSanitizeBool(_save[$ "ok"], false)) {
				_all_ok = false;
			}
		}

		var _load = GetLoadResult();
		if (is_struct(_load)) {
			_any = true;
			if (!__FateSanitizeBool(_load[$ "ok"], false)) {
				_all_ok = false;
			}
		}

		var _restore = GetRestoreResult();
		if (is_struct(_restore)) {
			_any = true;
			if (!__FateSanitizeBool(_restore[$ "ok"], false)) {
				_all_ok = false;
			}
		}

		if (!_any) {
			return false;
		}
		return _all_ok;
	}
}

///@ignore
function __FateReturnCtorForKind(_kind) {
	if (_kind == "roll") {
		return FateRollReturn;
	}
	if (_kind == "file") {
		return FateFileReturn;
	}
	if (_kind == "registry_mutation") {
		return FateRegistryMutationReturn;
	}
	if (_kind == "registry_keys") {
		return FateRegistryKeysReturn;
	}
	if (_kind == "prune") {
		return FatePruneReturn;
	}
	if (_kind == "capture") {
		return FateCaptureReturn;
	}
	if (_kind == "restore") {
		return FateRestoreReturn;
	}
	if (_kind == "pipeline") {
		return FatePipelineReturn;
	}
	return __FateReturn;
}

///@ignore
function __FateWrapResult(_ok, _code, _data = undefined, _kind = "generic") {
	var _kind_name = __FateSanitizeReturnKind(_kind, "generic");
	var _ctor = __FateReturnCtorForKind(_kind_name);
	if (_ctor == __FateReturn) {
		return new __FateReturn(_ok, _code, _data, _kind_name);
	}
	return new _ctor(_ok, _code, _data);
}