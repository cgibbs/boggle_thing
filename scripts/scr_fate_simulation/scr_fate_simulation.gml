///@func	FateTestSimulate(table, opts)
///@param	{Struct.FateTable}	_table
///@param	{Struct}	_opts
///@desc	Runs deterministic Monte Carlo simulation for a Fate table and returns aggregated results.
///@return	{Struct}
function FateTestSimulate(_table, _opts = undefined) {
	var _report = {
		format: "fate_sim_report",
		version: 1,
		table_id: undefined,
		runs: 0,
		count: 1,
		seed: 1,
		total_rolls: 0,
		total_selected: 0,
		entry_stats: [],
		exhausted_reason_counts: {
			none: 0,
			slot_cap: 0,
			pool_empty: 0,
			uniqueness_exhausted: 0
		},
		diagnostics_totals: undefined,
		selection_totals: undefined,
		result_hash: 0
	};

	if (!is_instanceof(_table, FateTable)) {
		_report.result_hash = __FateSimulationHashReport(_report);
		return _report;
	}

	var _runs = 10000;
	var _count = 1;
	var _seed = 1;
	var _context = undefined;
	var _context_provider = undefined;
	var _restore_state = true;
	var _collect_mode = "basic";

	if (is_struct(_opts)) {
		_runs = __FateSanitizeRollCount(_opts[$ "runs"], _runs);
		_count = __FateSanitizeRollCount(_opts[$ "count"], _count);
		_seed = __FateSanitizeSeed(_opts[$ "seed"], _seed);
		_context = _opts[$ "context"];

		var _provider = _opts[$ "context_provider"];
		if (is_callable(_provider)) {
			_context_provider = _provider;
		}

		_restore_state = __FateSanitizeBool(_opts[$ "restore_state"], _restore_state);
		_collect_mode = __FateSimulationSanitizeCollectMode(_opts[$ "collect_mode"], _collect_mode);
	}
	else {
		_seed = __FateSanitizeSeed(_seed, _seed);
	}

	var _table_id = _table.GetTableId();
	_report.table_id = _table_id;
	_report.runs = _runs;
	_report.count = _count;
	_report.seed = _seed;

	var _entry_stats_by_id = {};
	var _root_entries = _table.GetEntries();
	for (var i = 0; i < array_length(_root_entries); i++) {
		var _entry = _root_entries[i];
		if (!is_instanceof(_entry, FateEntry)) {
			continue;
		}
		var _entry_id = floor(_entry.entry_id);
		var _entry_key = string(_entry_id);
		var _insertion_order = i;
		if (__FateIsFiniteReal(_entry.insertion_order)) {
			_insertion_order = floor(_entry.insertion_order);
		}
		_entry_stats_by_id[$ _entry_key] = {
			entry_id: _entry_id,
			insertion_order: _insertion_order,
			hits: 0,
			hit_rate: 0
		};
	}

	var _diagnostics_totals = undefined;
	if ((_collect_mode == "diagnostics") || (_collect_mode == "full")) {
		_diagnostics_totals = {
			registered_policy_count: 0,
			invalid_rng_draws: 0,
			policy_resolve_calls: 0,
			policy_selected_calls: 0,
			policy_finished_calls: 0,
			policy_directive_struct_count: 0,
			policy_invalid_directive_fields: 0,
			policy_hard_force_active_count: 0,
			policy_hard_forced_entry_count: 0,
			policy_soft_modified_entry_count: 0,
			policy_hard_excluded_entry_count: 0
		};
		_report.diagnostics_totals = _diagnostics_totals;
	}

	var _selection_totals = undefined;
	if (_collect_mode == "full") {
		_selection_totals = {
			selected_via_counts: {},
			selected_events_by_depth: {},
			table_calls_by_depth: {},
			total_selected_events: 0,
			total_table_summaries: 0
		};
		_report.selection_totals = _selection_totals;
	}

	var _saved_state = undefined;
	if (_restore_state) {
		_saved_state = _table.GetState();
	}

	var _rng = new FateRng(_seed);
	for (var i = 0; i < _runs; i++) {
		var _run_context = _context;
		if (is_callable(_context_provider)) {
			_run_context = _context_provider(i);
		}

		var _outcome = _table.RollDetailed(_count, _run_context, _rng);
		_report.total_rolls++;
		_report.total_selected += _outcome.roll.selected_count;

		var _exhausted_reason = _outcome.diagnostics.exhausted_reason;
		if (!is_string(_exhausted_reason)) {
			_exhausted_reason = "none";
		}
		__FateSimulationIncrementCount(_report.exhausted_reason_counts, _exhausted_reason, 1);

		var _selected_events = _outcome.selected_events;
		for (var j = 0; j < array_length(_selected_events); j++) {
			var _event = _selected_events[j];
			if (!is_struct(_event)) {
				continue;
			}

			if ((_event[$ "table_id"] == _table_id) && (_event[$ "nested_depth"] == 0)) {
				var _event_entry_id = _event[$ "entry_id"];
				if (__FateIsFiniteReal(_event_entry_id)) {
					_event_entry_id = floor(_event_entry_id);
					var _event_entry_key = string(_event_entry_id);
					var _entry_stats = _entry_stats_by_id[$ _event_entry_key];
					if (!is_struct(_entry_stats)) {
						var _event_insertion = 0;
						if (__FateIsFiniteReal(_event[$ "insertion_order"])) {
							_event_insertion = floor(_event[$ "insertion_order"]);
						}
						_entry_stats = {
							entry_id: _event_entry_id,
							insertion_order: _event_insertion,
							hits: 0,
							hit_rate: 0
						};
						_entry_stats_by_id[$ _event_entry_key] = _entry_stats;
					}
					_entry_stats.hits++;
				}
			}

			if (is_struct(_selection_totals)) {
				_selection_totals.total_selected_events++;
				var _selected_via = _event[$ "selected_via"];
				if (!is_string(_selected_via)) {
					_selected_via = "unknown";
				}
				__FateSimulationIncrementCount(_selection_totals.selected_via_counts, _selected_via, 1);

				var _event_depth = _event[$ "nested_depth"];
				if (!__FateIsFiniteReal(_event_depth)) {
					_event_depth = 0;
				}
				_event_depth = floor(_event_depth);
				__FateSimulationIncrementCount(_selection_totals.selected_events_by_depth, string(_event_depth), 1);
			}
		}

		var _table_summaries = _outcome.table_summaries;
		if (is_struct(_selection_totals)) {
			for (var j = 0; j < array_length(_table_summaries); j++) {
				var _summary = _table_summaries[j];
				if (!is_struct(_summary)) {
					continue;
				}
				_selection_totals.total_table_summaries++;
				var _summary_depth = _summary[$ "nested_depth"];
				if (!__FateIsFiniteReal(_summary_depth)) {
					_summary_depth = 0;
				}
				_summary_depth = floor(_summary_depth);
				__FateSimulationIncrementCount(_selection_totals.table_calls_by_depth, string(_summary_depth), 1);
			}
		}

		if (is_struct(_diagnostics_totals)) {
			var _diag = _outcome.diagnostics;
			var _registered_policy_count = _diag[$ "registered_policy_count"];
			if (__FateIsFiniteReal(_registered_policy_count)) {
				_diagnostics_totals.registered_policy_count = max(_diagnostics_totals.registered_policy_count, floor(_registered_policy_count));
			}

			_diagnostics_totals.invalid_rng_draws += _diag[$ "invalid_rng_draws"];
			_diagnostics_totals.policy_resolve_calls += _diag[$ "policy_resolve_calls"];
			_diagnostics_totals.policy_selected_calls += _diag[$ "policy_selected_calls"];
			_diagnostics_totals.policy_finished_calls += _diag[$ "policy_finished_calls"];
			_diagnostics_totals.policy_directive_struct_count += _diag[$ "policy_directive_struct_count"];
			_diagnostics_totals.policy_invalid_directive_fields += _diag[$ "policy_invalid_directive_fields"];
			_diagnostics_totals.policy_hard_force_active_count += _diag[$ "policy_hard_force_active_count"];
			_diagnostics_totals.policy_hard_forced_entry_count += _diag[$ "policy_hard_forced_entry_count"];
			_diagnostics_totals.policy_soft_modified_entry_count += _diag[$ "policy_soft_modified_entry_count"];
			_diagnostics_totals.policy_hard_excluded_entry_count += _diag[$ "policy_hard_excluded_entry_count"];
		}
	}

	if (_restore_state) {
		_table.SetState(_saved_state);
	}

	var _entry_stats = [];
	var _entry_stat_names = struct_get_names(_entry_stats_by_id);
	for (var i = 0; i < array_length(_entry_stat_names); i++) {
		var _entry_stat_key = _entry_stat_names[i];
		array_push(_entry_stats, _entry_stats_by_id[$ _entry_stat_key]);
	}
	_entry_stats = __FateSimulationSortEntryStats(_entry_stats);
	for (var i = 0; i < array_length(_entry_stats); i++) {
		var _entry_stat = _entry_stats[i];
		if (_report.total_selected > 0) {
			_entry_stat.hit_rate = _entry_stat.hits / _report.total_selected;
		}
		else {
			_entry_stat.hit_rate = 0;
		}
	}
	_report.entry_stats = _entry_stats;
	_report.result_hash = __FateSimulationHashReport(_report);
	return _report;
}

///@func	FateTestSimulationAssert(sim_report, checks)
///@param	{Struct}	_sim_report
///@param	{Struct}	_checks
///@desc	Validates a simulation report against threshold checks and returns structured assertion failures.
///@return	{Struct}
function FateTestSimulationAssert(_sim_report, _checks = undefined) {
	var _assert_report = {
		ok: true,
		failure_count: 0,
		failures: []
	};

	if (!is_struct(_sim_report)) {
		__FateSimulationAssertAddFailure(_assert_report, "report_not_struct", "report", "struct", _sim_report, "Simulation report must be a struct");
		return _assert_report;
	}

	if (!is_struct(_checks)) {
		return _assert_report;
	}

	var _entry_rate_map = __FateSimulationBuildEntryRateMap(_sim_report);

	var _entry_rate_min = _checks[$ "entry_rate_min"];
	if (_entry_rate_min != undefined) {
		__FateSimulationApplyEntryRateThresholdChecks(_assert_report, _entry_rate_map, _entry_rate_min, "min");
	}

	var _entry_rate_max = _checks[$ "entry_rate_max"];
	if (_entry_rate_max != undefined) {
		__FateSimulationApplyEntryRateThresholdChecks(_assert_report, _entry_rate_map, _entry_rate_max, "max");
	}

	var _exhausted_reason_max = _checks[$ "exhausted_reason_max"];
	if (_exhausted_reason_max != undefined) {
		__FateSimulationApplyExhaustedReasonMaxChecks(_assert_report, _sim_report, _exhausted_reason_max);
	}

	var _expected_hash = _checks[$ "expected_hash"];
	if (_expected_hash != undefined) {
		__FateSimulationApplyExpectedHashCheck(_assert_report, _sim_report, _expected_hash);
	}

	return _assert_report;
}

///@func	FateTestSimulationComposeChecks(bundles, opts)
///@param	{Any}	_bundles
///@param	{Struct}	_opts
///@desc	Composes one or more simulation check bundles into a single checks struct with deterministic merge order.
///@return	{Struct}
function FateTestSimulationComposeChecks(_bundles, _opts = undefined) {
	var _compose_outcome = {
		checks: {
			entry_rate_min: {},
			entry_rate_max: {},
			exhausted_reason_max: {},
			expected_hash: undefined
		},
		composition_warnings: [],
		warning_count: 0
	};

	var _warn_on_override = true;
	if (is_struct(_opts)) {
		var _warn_on_override_opt = _opts[$ "warn_on_override"];
		if (is_bool(_warn_on_override_opt)) {
			_warn_on_override = _warn_on_override_opt;
		}
	}

	if (_bundles == undefined) {
		return _compose_outcome;
	}

	var _bundle_array = [];
	if (is_struct(_bundles)) {
		array_push(_bundle_array, _bundles);
	}
	else if (is_array(_bundles)) {
		_bundle_array = _bundles;
	}
	else {
		__FateSimulationComposeAddWarning(_compose_outcome, "invalid_bundles_type", "bundles", "Bundles input must be a struct or array of structs", "struct|array", _bundles);
		return _compose_outcome;
	}

	for (var i = 0; i < array_length(_bundle_array); i++) {
		var _bundle = _bundle_array[i];
		if (!is_struct(_bundle)) {
			__FateSimulationComposeAddWarning(_compose_outcome, "bundle_not_struct", $"bundles[{i}]", "Bundle must be a struct", "struct", _bundle);
			continue;
		}

		var _entry_rate_min = _bundle[$ "entry_rate_min"];
		if (_entry_rate_min != undefined) {
			__FateSimulationComposeMergeMap(_compose_outcome, _compose_outcome.checks.entry_rate_min, _entry_rate_min, $"bundles[{i}].entry_rate_min", _warn_on_override);
		}

		var _entry_rate_max = _bundle[$ "entry_rate_max"];
		if (_entry_rate_max != undefined) {
			__FateSimulationComposeMergeMap(_compose_outcome, _compose_outcome.checks.entry_rate_max, _entry_rate_max, $"bundles[{i}].entry_rate_max", _warn_on_override);
		}

		var _exhausted_reason_max = _bundle[$ "exhausted_reason_max"];
		if (_exhausted_reason_max != undefined) {
			__FateSimulationComposeMergeMap(_compose_outcome, _compose_outcome.checks.exhausted_reason_max, _exhausted_reason_max, $"bundles[{i}].exhausted_reason_max", _warn_on_override);
		}

		var _expected_hash = _bundle[$ "expected_hash"];
		if (_expected_hash != undefined) {
			var _prev_hash = _compose_outcome.checks.expected_hash;
			if (_warn_on_override) {
				if ((_prev_hash != undefined) && (_prev_hash != _expected_hash)) {
					__FateSimulationComposeAddWarning(_compose_outcome, "compose_override", $"bundles[{i}].expected_hash", "Later bundle overrides earlier check value", _prev_hash, _expected_hash);
				}
			}
			_compose_outcome.checks.expected_hash = _expected_hash;
		}
	}

	return _compose_outcome;
}

///@func	FateTestSimulationRunAndAssert(table, sim_opts, checks, opts)
///@param	{Struct.FateTable}	_table
///@param	{Struct}	_sim_opts
///@param	{Any}	_checks
///@param	{Struct}	_opts
///@desc	Runs simulation and assertions in one call and returns machine-readable CI-friendly output.
///@return	{Struct}
function FateTestSimulationRunAndAssert(_table, _sim_opts = undefined, _checks = undefined, _opts = undefined) {
	var _compose_outcome = FateTestSimulationComposeChecks(_checks, _opts);
	var _sim_report = FateTestSimulate(_table, _sim_opts);
	var _assert_report = FateTestSimulationAssert(_sim_report, _compose_outcome.checks);
	return {
		ok: _assert_report.ok,
		sim_report: _sim_report,
		assert_report: _assert_report,
		checks: _compose_outcome.checks,
		failure_count: _assert_report.failure_count,
		composition_warning_count: _compose_outcome.warning_count,
		composition_warnings: _compose_outcome.composition_warnings,
		summary_lines: __FateSimulationBuildSummaryLines(_sim_report, _assert_report, _compose_outcome)
	};
}

///@func	FateTestSimulationPresetExpectedHash(expected_hash)
///@param	{Any}	_expected_hash
///@desc	Returns a check bundle that asserts a simulation result_hash value.
///@return	{Struct}
function FateTestSimulationPresetExpectedHash(_expected_hash) {
	var _hash = _expected_hash;
	if (__FateIsFiniteReal(_hash)) {
		_hash = floor(_hash);
	}
	return {
		expected_hash: _hash
	};
}

///@func	FateTestSimulationPresetNoExhaustion()
///@desc	Returns a check bundle that requires no early-exhaustion reasons during simulation.
///@return	{Struct}
function FateTestSimulationPresetNoExhaustion() {
	return {
		exhausted_reason_max: {
			slot_cap: 0,
			pool_empty: 0,
			uniqueness_exhausted: 0
		}
	};
}

///@func	FateTestSimulationPresetEntryRateRange(entry_or_entry_id, min_rate, max_rate)
///@param	{Any}	_entry_or_entry_id
///@param	{Any}	_min_rate
///@param	{Any}	_max_rate
///@desc	Returns a check bundle with optional min/max hit-rate bounds for one entry.
///@return	{Struct}
function FateTestSimulationPresetEntryRateRange(_entry_or_entry_id, _min_rate = undefined, _max_rate = undefined) {
	var _bundle = {
		entry_rate_min: {},
		entry_rate_max: {}
	};
	var _entry_key = __FateSimulationResolveEntryKey(_entry_or_entry_id);
	if (!is_string(_entry_key)) {
		return _bundle;
	}

	if (__FateIsFiniteReal(_min_rate)) {
		_bundle.entry_rate_min[$ _entry_key] = clamp(_min_rate, 0, 1);
	}
	if (__FateIsFiniteReal(_max_rate)) {
		_bundle.entry_rate_max[$ _entry_key] = clamp(_max_rate, 0, 1);
	}
	return _bundle;
}

///@func	FateTestSimulationPresetEntryRateBand(entry_or_entry_id, target_rate, tolerance)
///@param	{Any}	_entry_or_entry_id
///@param	{Any}	_target_rate
///@param	{Any}	_tolerance
///@desc	Returns a check bundle with symmetric hit-rate bounds around a target value.
///@return	{Struct}
function FateTestSimulationPresetEntryRateBand(_entry_or_entry_id, _target_rate, _tolerance = 0) {
	if (!__FateIsFiniteReal(_target_rate)) {
		return FateTestSimulationPresetEntryRateRange(_entry_or_entry_id);
	}

	var _tol = 0;
	if (__FateIsFiniteReal(_tolerance)) {
		_tol = abs(_tolerance);
	}
	return FateTestSimulationPresetEntryRateRange(_entry_or_entry_id, _target_rate - _tol, _target_rate + _tol);
}

///@func	FateTestSimulationPresetEntryRateRanges(ranges_map)
///@param	{Struct}	_ranges_map
///@desc	Returns a check bundle for multiple entry rate ranges keyed by entry id string.
///@return	{Struct}
function FateTestSimulationPresetEntryRateRanges(_ranges_map) {
	var _bundle = {
		entry_rate_min: {},
		entry_rate_max: {}
	};
	if (!is_struct(_ranges_map)) {
		return _bundle;
	}

	var _entry_keys = struct_get_names(_ranges_map);
	for (var i = 0; i < array_length(_entry_keys); i++) {
		var _entry_key = _entry_keys[i];
		var _range_spec = _ranges_map[$ _entry_key];
		var _min_rate = undefined;
		var _max_rate = undefined;

		if (is_struct(_range_spec)) {
			_min_rate = _range_spec[$ "min_rate"];
			_min_rate ??= _range_spec[$ "min"];
			_max_rate = _range_spec[$ "max_rate"];
			_max_rate ??= _range_spec[$ "max"];
		}
		else if (is_array(_range_spec)) {
			if (array_length(_range_spec) > 0) {
				_min_rate = _range_spec[0];
			}
			if (array_length(_range_spec) > 1) {
				_max_rate = _range_spec[1];
			}
		}

		var _entry_bundle = FateTestSimulationPresetEntryRateRange(_entry_key, _min_rate, _max_rate);
		var _entry_min = _entry_bundle.entry_rate_min[$ _entry_key];
		var _entry_max = _entry_bundle.entry_rate_max[$ _entry_key];
		if (_entry_min != undefined) {
			_bundle.entry_rate_min[$ _entry_key] = _entry_min;
		}
		if (_entry_max != undefined) {
			_bundle.entry_rate_max[$ _entry_key] = _entry_max;
		}
	}

	return _bundle;
}

///@func	FateTestSimulationPresetEntryRateBands(bands_map)
///@param	{Struct}	_bands_map
///@desc	Returns a check bundle for multiple entry rate bands keyed by entry id string.
///@return	{Struct}
function FateTestSimulationPresetEntryRateBands(_bands_map) {
	var _bundle = {
		entry_rate_min: {},
		entry_rate_max: {}
	};
	if (!is_struct(_bands_map)) {
		return _bundle;
	}

	var _entry_keys = struct_get_names(_bands_map);
	for (var i = 0; i < array_length(_entry_keys); i++) {
		var _entry_key = _entry_keys[i];
		var _band_spec = _bands_map[$ _entry_key];
		var _target_rate = undefined;
		var _tolerance = 0;

		if (is_struct(_band_spec)) {
			_target_rate = _band_spec[$ "target_rate"];
			_target_rate ??= _band_spec[$ "target"];
			var _tol_value = _band_spec[$ "tolerance"];
			if (__FateIsFiniteReal(_tol_value)) {
				_tolerance = _tol_value;
			}
		}
		else if (is_array(_band_spec)) {
			if (array_length(_band_spec) > 0) {
				_target_rate = _band_spec[0];
			}
			if (array_length(_band_spec) > 1) {
				var _array_tol = _band_spec[1];
				if (__FateIsFiniteReal(_array_tol)) {
					_tolerance = _array_tol;
				}
			}
		}
		else if (__FateIsFiniteReal(_band_spec)) {
			_target_rate = _band_spec;
		}

		var _entry_bundle = FateTestSimulationPresetEntryRateBand(_entry_key, _target_rate, _tolerance);
		var _entry_min = _entry_bundle.entry_rate_min[$ _entry_key];
		var _entry_max = _entry_bundle.entry_rate_max[$ _entry_key];
		if (_entry_min != undefined) {
			_bundle.entry_rate_min[$ _entry_key] = _entry_min;
		}
		if (_entry_max != undefined) {
			_bundle.entry_rate_max[$ _entry_key] = _entry_max;
		}
	}

	return _bundle;
}

///@func	FateTestSimulationPresetStrictFairness(entries_map, tolerance)
///@param	{Struct}	_entries_map
///@param	{Any}	_tolerance
///@desc	Returns a symmetric band bundle from normalized expected weights for multiple entries.
///@return	{Struct}
function FateTestSimulationPresetStrictFairness(_entries_map, _tolerance = 0) {
	var _weights_by_entry = {};
	var _total_weight = 0;
	if (!is_struct(_entries_map)) {
		return FateTestSimulationPresetEntryRateBands({});
	}

	var _tol = 0;
	if (__FateIsFiniteReal(_tolerance)) {
		_tol = abs(_tolerance);
	}

	var _keys = struct_get_names(_entries_map);
	for (var i = 0; i < array_length(_keys); i++) {
		var _raw_key = _keys[i];
		var _entry_key = __FateSimulationResolveEntryKey(_raw_key);
		var _entry_spec = _entries_map[$ _raw_key];
		var _weight = undefined;

		if (is_instanceof(_entry_spec, FateEntry)) {
			if (__FateIsFiniteReal(_entry_spec.entry_id)) {
				_entry_key = string(floor(_entry_spec.entry_id));
			}
			_weight = _entry_spec[$ "weight"];
		}
		else if (is_struct(_entry_spec)) {
			var _entry_id = _entry_spec[$ "entry_id"];
			if (__FateIsFiniteReal(_entry_id)) {
				_entry_key = string(floor(_entry_id));
			}

			_weight = _entry_spec[$ "weight"];
			_weight ??= _entry_spec[$ "expected_weight"];
		}
		else if (is_array(_entry_spec)) {
			if (array_length(_entry_spec) > 0) {
				_weight = _entry_spec[0];
			}
		}
		else if (__FateIsFiniteReal(_entry_spec)) {
			_weight = _entry_spec;
		}

		if (!is_string(_entry_key)) {
			continue;
		}
		if (!__FateIsFiniteReal(_weight)) {
			continue;
		}

		_weight = max(0, _weight);
		var _current_weight = _weights_by_entry[$ _entry_key];
		if (__FateIsFiniteReal(_current_weight)) {
			_weights_by_entry[$ _entry_key] = _current_weight + _weight;
		}
		else {
			_weights_by_entry[$ _entry_key] = _weight;
		}
		_total_weight += _weight;
	}

	if (_total_weight <= 0) {
		return FateTestSimulationPresetEntryRateBands({});
	}

	var _bands_map = {};
	var _weight_keys = struct_get_names(_weights_by_entry);
	for (var i = 0; i < array_length(_weight_keys); i++) {
		var _entry_key = _weight_keys[i];
		var _entry_weight = _weights_by_entry[$ _entry_key];
		_bands_map[$ _entry_key] = {
			target_rate: _entry_weight / _total_weight,
			tolerance: _tol
		};
	}

	return FateTestSimulationPresetEntryRateBands(_bands_map);
}

///@ignore
function __FateSimulationBuildSummaryLines(_sim_report, _assert_report, _compose_outcome) {
	var _lines = [];
	var _status = "PASS";
	if (!_assert_report.ok) {
		_status = "FAIL";
	}
	array_push(_lines, $"FateSimulation {_status}: failures={_assert_report.failure_count}, runs={_sim_report.runs}, count={_sim_report.count}, hash={_sim_report.result_hash}");

	var _warnings = _compose_outcome[$ "composition_warnings"];
	for (var i = 0; i < array_length(_warnings); i++) {
		var _warning = _warnings[i];
		array_push(_lines, $"WARN {_warning.code} at {_warning.path}: {_warning.message}");
	}

	var _failures = _assert_report[$ "failures"];
	for (var i = 0; i < array_length(_failures); i++) {
		var _failure = _failures[i];
		array_push(_lines, $"FAIL {_failure.code} at {_failure.path}: {_failure.message} (expected={string(_failure.expected)}, actual={string(_failure.actual)})");
	}

	return _lines;
}

///@ignore
function __FateSimulationResolveEntryKey(_entry_or_entry_id) {
	if (is_instanceof(_entry_or_entry_id, FateEntry)) {
		var _entry_id = _entry_or_entry_id.entry_id;
		if (__FateIsFiniteReal(_entry_id)) {
			return string(floor(_entry_id));
		}
		return undefined;
	}
	if (__FateIsFiniteReal(_entry_or_entry_id)) {
		return string(floor(_entry_or_entry_id));
	}
	if (is_string(_entry_or_entry_id)) {
		return _entry_or_entry_id;
	}
	return undefined;
}

///@ignore
function __FateSimulationComposeAddWarning(_compose_outcome, _code, _path, _message, _previous = undefined, _next = undefined) {
	_compose_outcome.warning_count++;
	array_push(_compose_outcome.composition_warnings, {
		code: string(_code),
		path: string(_path),
		message: string(_message),
		previous: _previous,
		next: _next
	});
}

///@ignore
function __FateSimulationComposeMergeMap(_compose_outcome, _target_map, _source_map, _path_prefix, _warn_on_override) {
	if (!is_struct(_source_map)) {
		__FateSimulationComposeAddWarning(_compose_outcome, "invalid_bundle_field_type", _path_prefix, "Check field must be a struct map", "struct", _source_map);
		return;
	}

	var _keys = __FateSimulationSortStringArray(struct_get_names(_source_map));
	for (var i = 0; i < array_length(_keys); i++) {
		var _key = _keys[i];
		var _next_value = _source_map[$ _key];
		var _prev_value = _target_map[$ _key];
		if (_warn_on_override) {
			if ((_prev_value != undefined) && (_prev_value != _next_value)) {
				__FateSimulationComposeAddWarning(_compose_outcome, "compose_override", $"{_path_prefix}[{_key}]", "Later bundle overrides earlier check value", _prev_value, _next_value);
			}
		}
		_target_map[$ _key] = _next_value;
	}
}

///@ignore
function __FateSimulationSanitizeCollectMode(_value, _default = "basic") {
	if (is_string(_value)) {
		if (_value == "basic") {
			return _value;
		}
		else if (_value == "diagnostics") {
			return _value;
		}
		else if (_value == "full") {
			return _value;
		}
	}
	return _default;
}

///@ignore
function __FateSimulationIncrementCount(_map, _key, _amount = 1) {
	var _key_string = string(_key);
	var _current = _map[$ _key_string];
	var _next = _amount;
	if (__FateIsFiniteReal(_current)) {
		_next += floor(_current);
	}
	_map[$ _key_string] = _next;
}

///@ignore
function __FateSimulationSortStringArray(_values) {
	var _sorted = variable_clone(_values);
	var _count = array_length(_sorted);
	for (var i = 0; i < _count - 1; i++) {
		for (var j = i + 1; j < _count; j++) {
			if (_sorted[j] < _sorted[i]) {
				var _temp = _sorted[i];
				_sorted[i] = _sorted[j];
				_sorted[j] = _temp;
			}
		}
	}
	return _sorted;
}

///@ignore
function __FateSimulationSortEntryStats(_entry_stats) {
	var _sorted = variable_clone(_entry_stats);
	var _count = array_length(_sorted);
	for (var i = 0; i < _count - 1; i++) {
		for (var j = i + 1; j < _count; j++) {
			var _left = _sorted[i];
			var _right = _sorted[j];

			var _left_order = 0;
			var _right_order = 0;
			if (__FateIsFiniteReal(_left[$ "insertion_order"])) {
				_left_order = floor(_left[$ "insertion_order"]);
			}
			if (__FateIsFiniteReal(_right[$ "insertion_order"])) {
				_right_order = floor(_right[$ "insertion_order"]);
			}

			var _left_entry_id = 0;
			var _right_entry_id = 0;
			if (__FateIsFiniteReal(_left[$ "entry_id"])) {
				_left_entry_id = floor(_left[$ "entry_id"]);
			}
			if (__FateIsFiniteReal(_right[$ "entry_id"])) {
				_right_entry_id = floor(_right[$ "entry_id"]);
			}

			var _swap = false;
			if (_right_order < _left_order) {
				_swap = true;
			}
			else if (_right_order == _left_order) {
				if (_right_entry_id < _left_entry_id) {
					_swap = true;
				}
			}

			if (_swap) {
				var _temp = _sorted[i];
				_sorted[i] = _sorted[j];
				_sorted[j] = _temp;
			}
		}
	}
	return _sorted;
}

///@ignore
function __FateSimulationHashReport(_report) {
	var _hash = __FateSimulationHashInit();
	_hash = __FateSimulationHashFeedString(_hash, _report[$ "format"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "version"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "table_id"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "runs"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "count"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "seed"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "total_rolls"]);
	_hash = __FateSimulationHashFeedInt(_hash, _report[$ "total_selected"]);
	_hash = __FateSimulationHashFeedCountMap(_hash, _report[$ "exhausted_reason_counts"]);
	_hash = __FateSimulationHashFeedEntryStats(_hash, _report[$ "entry_stats"]);

	var _diagnostics_totals = _report[$ "diagnostics_totals"];
	if (is_struct(_diagnostics_totals)) {
		_hash = __FateSimulationHashFeedString(_hash, "diag");
		_hash = __FateSimulationHashFeedCountMap(_hash, _diagnostics_totals);
	}
	else {
		_hash = __FateSimulationHashFeedString(_hash, "diag_none");
	}

	var _selection_totals = _report[$ "selection_totals"];
	if (is_struct(_selection_totals)) {
		_hash = __FateSimulationHashFeedString(_hash, "selection");
		_hash = __FateSimulationHashFeedInt(_hash, _selection_totals[$ "total_selected_events"]);
		_hash = __FateSimulationHashFeedInt(_hash, _selection_totals[$ "total_table_summaries"]);
		_hash = __FateSimulationHashFeedCountMap(_hash, _selection_totals[$ "selected_via_counts"]);
		_hash = __FateSimulationHashFeedCountMap(_hash, _selection_totals[$ "selected_events_by_depth"]);
		_hash = __FateSimulationHashFeedCountMap(_hash, _selection_totals[$ "table_calls_by_depth"]);
	}
	else {
		_hash = __FateSimulationHashFeedString(_hash, "selection_none");
	}

	return _hash;
}

///@ignore
function __FateSimulationAssertAddFailure(_assert_report, _code, _path, _expected, _actual, _message) {
	_assert_report.ok = false;
	_assert_report.failure_count++;
	array_push(_assert_report.failures, {
		code: string(_code),
		path: string(_path),
		expected: _expected,
		actual: _actual,
		message: string(_message)
	});
}

///@ignore
function __FateSimulationBuildEntryRateMap(_sim_report) {
	var _entry_rate_map = {};
	if (!is_struct(_sim_report)) {
		return _entry_rate_map;
	}
	var _entry_stats = _sim_report[$ "entry_stats"];
	if (!is_array(_entry_stats)) {
		return _entry_rate_map;
	}
	for (var i = 0; i < array_length(_entry_stats); i++) {
		var _entry_stat = _entry_stats[i];
		if (!is_struct(_entry_stat)) {
			continue;
		}
		var _entry_id = _entry_stat[$ "entry_id"];
		if (!__FateIsFiniteReal(_entry_id)) {
			continue;
		}
		_entry_id = floor(_entry_id);
		var _entry_key = string(_entry_id);
		var _hit_rate = _entry_stat[$ "hit_rate"];
		if (!__FateIsFiniteReal(_hit_rate)) {
			_hit_rate = 0;
		}
		_entry_rate_map[$ _entry_key] = _hit_rate;
	}
	return _entry_rate_map;
}

///@ignore
function __FateSimulationApplyEntryRateThresholdChecks(_assert_report, _entry_rate_map, _thresholds, _mode) {
	var _is_min_mode = (_mode == "min");
	var _check_name = "entry_rate_max";
	if (_is_min_mode) {
		_check_name = "entry_rate_min";
	}

	if (!is_struct(_thresholds)) {
		__FateSimulationAssertAddFailure(_assert_report, $"invalid_check_{_check_name}_type", $"checks.{_check_name}", "struct", _thresholds, $"{_check_name} must be a struct map");
		return;
	}

	var _entry_keys = struct_get_names(_thresholds);
	for (var i = 0; i < array_length(_entry_keys); i++) {
		var _entry_key = _entry_keys[i];
		var _threshold = _thresholds[$ _entry_key];
		if (!__FateIsFiniteReal(_threshold)) {
			__FateSimulationAssertAddFailure(_assert_report, $"invalid_check_{_check_name}_value", $"checks.{_check_name}[{string(_entry_key)}]", "finite real", _threshold, $"{_check_name} value must be a finite real");
			continue;
		}

		var _entry_id_key = string(_entry_key);
		var _actual_rate = _entry_rate_map[$ _entry_id_key];
		if (!__FateIsFiniteReal(_actual_rate)) {
			__FateSimulationAssertAddFailure(_assert_report, "entry_rate_missing", $"checks.{_check_name}[{_entry_id_key}]", _threshold, undefined, "Entry rate check referenced an entry_id that is not present in report.entry_stats");
			continue;
		}

		if (_is_min_mode) {
			if (_actual_rate < _threshold) {
				__FateSimulationAssertAddFailure(_assert_report, "entry_rate_below_min", $"checks.{_check_name}[{_entry_id_key}]", _threshold, _actual_rate, "Entry hit_rate is below minimum threshold");
			}
		}
		else {
			if (_actual_rate > _threshold) {
				__FateSimulationAssertAddFailure(_assert_report, "entry_rate_above_max", $"checks.{_check_name}[{_entry_id_key}]", _threshold, _actual_rate, "Entry hit_rate is above maximum threshold");
			}
		}
	}
}

///@ignore
function __FateSimulationApplyExhaustedReasonMaxChecks(_assert_report, _sim_report, _thresholds) {
	if (!is_struct(_thresholds)) {
		__FateSimulationAssertAddFailure(_assert_report, "invalid_check_exhausted_reason_max_type", "checks.exhausted_reason_max", "struct", _thresholds, "exhausted_reason_max must be a struct map");
		return;
	}

	var _reason_counts = _sim_report[$ "exhausted_reason_counts"];
	var _reason_keys = struct_get_names(_thresholds);
	for (var i = 0; i < array_length(_reason_keys); i++) {
		var _reason_key = _reason_keys[i];
		var _max_count = _thresholds[$ _reason_key];
		if (!__FateIsFiniteReal(_max_count)) {
			__FateSimulationAssertAddFailure(_assert_report, "invalid_check_exhausted_reason_max_value", $"checks.exhausted_reason_max[{string(_reason_key)}]", "finite real", _max_count, "exhausted_reason_max value must be a finite real");
			continue;
		}

		var _actual_count = 0;
		if (is_struct(_reason_counts)) {
			var _raw_count = _reason_counts[$ string(_reason_key)];
			if (__FateIsFiniteReal(_raw_count)) {
				_actual_count = floor(_raw_count);
			}
		}
		var _max_count_floor = floor(_max_count);
		if (_actual_count > _max_count_floor) {
			__FateSimulationAssertAddFailure(_assert_report, "exhausted_reason_above_max", $"checks.exhausted_reason_max[{string(_reason_key)}]", _max_count_floor, _actual_count, "Exhausted reason count exceeded maximum threshold");
		}
	}
}

///@ignore
function __FateSimulationApplyExpectedHashCheck(_assert_report, _sim_report, _expected_hash) {
	if (!__FateIsFiniteReal(_expected_hash)) {
		__FateSimulationAssertAddFailure(_assert_report, "invalid_check_expected_hash", "checks.expected_hash", "finite real", _expected_hash, "expected_hash must be a finite real");
		return;
	}

	var _actual_hash = _sim_report[$ "result_hash"];
	if (!__FateIsFiniteReal(_actual_hash)) {
		__FateSimulationAssertAddFailure(_assert_report, "result_hash_missing", "report.result_hash", floor(_expected_hash), _actual_hash, "Simulation report is missing finite result_hash");
		return;
	}

	var _expected_hash_int = floor(_expected_hash);
	var _actual_hash_int = floor(_actual_hash);
	if (_actual_hash_int != _expected_hash_int) {
		__FateSimulationAssertAddFailure(_assert_report, "result_hash_mismatch", "checks.expected_hash", _expected_hash_int, _actual_hash_int, "Simulation result_hash does not match expected_hash");
	}
}
	
///@ignore
function __FateSimulationHashInit() {
	return 2166136261.0;
}

///@ignore
function __FateSimulationHashFeedInt(_hash, _value) {
	var _int_value = 0;
	if (__FateIsFiniteReal(_value)) {
		_int_value = floor(_value);
	}
	_hash = ((_hash * 1664525) + 1013904223 + _int_value) & $ffffffff;
	if (_hash < 0) {
		_hash += 4294967296.0;
	}
	return _hash;
}

///@ignore
function __FateSimulationHashFeedString(_hash, _value) {
	var _text = string(_value);
	var _len = string_length(_text);
	_hash = __FateSimulationHashFeedInt(_hash, _len);
	for (var i = 1; i <= _len; i++) {
		var _char_code = ord(string_char_at(_text, i));
		_hash = __FateSimulationHashFeedInt(_hash, _char_code);
	}
	return _hash;
}

///@ignore
function __FateSimulationHashFeedCountMap(_hash, _map) {
	if (!is_struct(_map)) {
		return __FateSimulationHashFeedInt(_hash, 0);
	}
	var _names = __FateSimulationSortStringArray(struct_get_names(_map));
	_hash = __FateSimulationHashFeedInt(_hash, array_length(_names));
	for (var i = 0; i < array_length(_names); i++) {
		var _name = _names[i];
		_hash = __FateSimulationHashFeedString(_hash, _name);
		var _value = _map[$ _name];
		_hash = __FateSimulationHashFeedInt(_hash, _value);
	}
	return _hash;
}

///@ignore
function __FateSimulationHashFeedEntryStats(_hash, _entry_stats) {
	if (!is_array(_entry_stats)) {
		return __FateSimulationHashFeedInt(_hash, 0);
	}
	_hash = __FateSimulationHashFeedInt(_hash, array_length(_entry_stats));
	for (var i = 0; i < array_length(_entry_stats); i++) {
		var _entry = _entry_stats[i];
		_hash = __FateSimulationHashFeedInt(_hash, _entry[$ "entry_id"]);
		_hash = __FateSimulationHashFeedInt(_hash, _entry[$ "insertion_order"]);
		_hash = __FateSimulationHashFeedInt(_hash, _entry[$ "hits"]);
	}
	return _hash;
}