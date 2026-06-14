/* -------------------------------------------------------------------------------------------------
ECHO by RefresherTowel Games

v2.3.1

Docs: https://refreshertowel.github.io/docs/echo/
Discord: https://discord.gg/w5NWDBwNta
More Libraries: https://refreshertowel.itch.io/

Welcome to Echo, a lightweight but surprisingly useful debug logger for GameMaker.
Echo now comes with Echo Chamber, a debug UI builder! Create multiple windows with
flowing layouts, and a variety of controls easily. Handles all the painful parts of
making a debug GUI layout for you.

Be sure to check out the documentation, as it is thorough and should guide you through the process
of learning how to use Echo effectively.

If you like Echo, consider checking out my other libraries, I'm sure there's something else
you'll be able to find that'll help you make your games even faster!
------------------------------------------------------------------------------------------------- */


#macro ECHO_DEBUG_ENABLED	1
#macro ECHO_CONSOLE_ENABLED 1
#macro ECHO_CONSOLE_KEY		vk_f1
// This will make the echo console popup on startup
#macro ECHO_LAUNCH_ON_STARTUP 0

enum eEchoDebugLevel {
	NONE,
	SEVERE_ONLY,
	COMPREHENSIVE,
	COMPLETE,
}

enum eEchoDebugUrgency {
	INFO,
	WARNING,
	SEVERE
}

if (ECHO_DEBUG_ENABLED) {
	global.__echo_debug_config = new __EchoDebugConfig();
	if (ECHO_CONSOLE_ENABLED) {
		global.__echo_chamber_root = new EchoChamberRoot(new EchoChamberTheme());
		call_later(1, time_source_units_frames, function() {
			global.__echo_controller = instance_create_depth(0, 0, 0, __obj_echo_controller);
		}, -1);
	}
}

/// @ignore
function __EchoDebugConfig() constructor {
	log_history = [];
	log_history_max = 0;
	debug_level = eEchoDebugLevel.COMPREHENSIVE;
	allowed_tags = []; // empty means allow all

	log_history_struct = [];
	log_revision      = 0;
	log_seq           = 0;

	raw_history_enabled = true;
	log_history_raw = [];
	log_history_struct_raw = [];
	log_revision_raw = 0;
	log_seq_raw = 0;

	/// @ignore
	/// @return	{Real}
	static __GetDebugLevel = function() {
		return debug_level;
	}

	///	@ignore
	/// @param	{Real}	level
	/// @return	{Boolean}
	static __SetDebugLevel = function(_level) {
		if (!is_int64(_level) || _level > eEchoDebugLevel.COMPLETE || _level < eEchoDebugLevel.NONE) {
			show_debug_message($"Attempting to set debug level to an invalid value: {_level}");
			return false;
		}
		debug_level = _level;
		return true;
	}

	/// @ignore
	/// @return {String}
	static __GetDebugLevelAsString = function() {
		switch (debug_level) {
			case eEchoDebugLevel.NONE:         return "NONE";
			case eEchoDebugLevel.SEVERE_ONLY:  return "SEVERE ONLY";
			case eEchoDebugLevel.COMPREHENSIVE:return "COMPREHENSIVE";
			case eEchoDebugLevel.COMPLETE:     return "COMPLETE";
			default:                       return "UNKNOWN";
		}
	}


	/// @ignore
	/// @return {Boolean}
	static __DumpLogHistory = function() {
		var _datetime = date_current_datetime();
		var _y = string(date_get_year(_datetime));
		var _m = string_format(date_get_month(_datetime), 2, 0);
		var _d = string_format(date_get_day(_datetime),   2, 0);
		var _h = string_format(date_get_hour(_datetime),  2, 0);
		var _n = string_format(date_get_minute(_datetime),2, 0);
		var _s = string_format(date_get_second(_datetime),2, 0);

		var _date_str = _y + "-" + _m + "-" + _d + "_" + _h + "-" + _n + "-" + _s;

		var _filename = $"echo_debug_dump-{_date_str}-({get_timer()}).txt";
		var _file     = file_text_open_write(_filename);

		if (_file < 0) {
			show_debug_message($"Error creating debug file '{_filename}'!");
			return false;
		}

		var i = -1;
		repeat (array_length(log_history)) {
			file_text_write_string(_file, log_history[++i]);
			file_text_writeln(_file);
		}
		file_text_close(_file);
		return true;
	}


	/// @ignore
	/// @param	{String} message	The message to add to the debug logs history
	static __LogHistory = function(_message) {
		array_push(log_history, _message);
		if (log_history_max > 0) {
			while (array_length(log_history) > log_history_max) {
				array_delete(log_history, 0, 1);
			}
		}
	}

	/// @ignore
	/// @desc Log a structured entry and formatted line into history (and bump revision).
	/// @param {String} _line
	/// @param {Struct} _entry
	static __LogHistoryEx = function(_line, _entry) {
		array_push(log_history, _line);
		if (is_struct(_entry)) {
			log_seq += 1;
			_entry.seq = log_seq;
			array_push(log_history_struct, _entry);
		}
		if (log_history_max > 0) {
			while (array_length(log_history) > log_history_max) {
				array_delete(log_history, 0, 1);
			}
			while (array_length(log_history_struct) > log_history_max) {
				array_delete(log_history_struct, 0, 1);
			}
		}
		log_revision += 1;
	};

	/// @ignore
	/// @desc Log a structured entry and formatted line into raw history (and bump revision).
	/// @param {String} _line
	/// @param {Struct} _entry
	static __LogRawHistoryEx = function(_line, _entry) {
		array_push(log_history_raw, _line);
		if (is_struct(_entry)) {
			log_seq_raw += 1;
			_entry.seq = log_seq_raw;
			array_push(log_history_struct_raw, _entry);
		}
		if (log_history_max > 0) {
			while (array_length(log_history_raw) > log_history_max) {
				array_delete(log_history_raw, 0, 1);
			}
			while (array_length(log_history_struct_raw) > log_history_max) {
				array_delete(log_history_struct_raw, 0, 1);
			}
		}
		log_revision_raw += 1;
	};

	/// @ignore
	/// @desc Clear both history buffers and bump revision.
	static __ClearHistoryEx = function() {
		log_history = [];
		log_history_struct = [];
		log_history_raw = [];
		log_history_struct_raw = [];
		log_revision += 1;
		log_revision_raw += 1;
	};

	/// @ignore
	/// @return {Real}
	static __GetLogRevision = function() {
		return log_revision;
	};

	/// @ignore
	/// @return {Array<Struct>}
	static __GetStructuredHistory = function() {
		return log_history_struct;
	};

	/// @ignore
	/// @return {Array<Struct>}
	static __GetRawStructuredHistory = function() {
		return log_history_struct_raw;
	};

	/// @ignore
	/// @return {Real}
	static __GetRawRevision = function() {
		return log_revision_raw;
	};


	/// @ignore
	/// @param	{Real}	max	The maximum number of entries allowed in the log history
	/// @return	{Boolean}
	static __SetLogHistoryMax = function(_max) {
		if (!is_real(_max) || _max < 0) {
			show_debug_message($"Attempting to set maximum debug log history length to an invalid value: {_max}!");
			return false;
		}
		log_history_max = floor(_max);
		return true;
	}

	/// @ignore
	/// @return	{Real}
	static __GetLogHistoryMax = function() {
		return log_history_max;
	}

	/// @ignore
	/// @param {Array<String>} _tags Allowed tags; empty means allow all
	/// @return {Boolean}
	static __SetAllowedTags = function(_tags) {
		if (!is_array(_tags)) {
			show_debug_message("Attempting to set Echo allowed tags with a non-array; ignoring.");
			return false;
		}
		allowed_tags = _tags;
		return true;
	}

	/// @ignore
	/// @return {Array<String>}
	static __GetAllowedTags = function() {
		return allowed_tags;
	}

	/// @ignore
	static __ClearAllowedTags = function() {
		allowed_tags = [];
	}

	/// @ignore
	/// @param {Boolean} _enabled
	/// @return {Boolean}
	static __SetRawHistoryCapture = function(_enabled) {
		if (!is_bool(_enabled)) {
			show_debug_message("Attempting to set raw history capture with a non-bool; ignoring.");
			return false;
		}
		raw_history_enabled = _enabled;
		return true;
	}

	/// @ignore
	/// @return {Boolean}
	static __GetRawHistoryCapture = function() {
		return raw_history_enabled;
	}
}

/// @ignore
function __EchoGetDebugConfig() {
	if (!is_instanceof(global.__echo_debug_config, __EchoDebugConfig)) {
		global.__echo_debug_config = new __EchoDebugConfig();
	}
	return global.__echo_debug_config;
}

/// @ignore
/// @return {String}
function __EchoGetDebugUrgencyAsString(_urgency) {
	switch (_urgency) {
		case eEchoDebugUrgency.INFO:	return "INFO";
		case eEchoDebugUrgency.WARNING:	return "WARNING";
		case eEchoDebugUrgency.SEVERE:	return "SEVERE";
		default:					return "UNKNOWN";
	}
}

/// @desc Send a message to the debug logger with a specific urgency level. Returns true if the message meets current debug level critera, false if not.
/// @param	{String}	_message	The message to send to the debug logger
/// @param	{Real}		[_urgency]	The level of urgency of the debug message (pick an entry from the eEchoDebugUrgency enum)
/// @param  {String,Array<String>}    [_tag]       Optional tag or tags to filter on (e.g., "UI", ["Physics","Jump"]). Empty or empty array allows all.
/// @param	{Real}		[_colour]	Optional text colour metadata for structured history / Echo Console display.
/// @return	{Boolean}
function EchoDebug(_message, _urgency = eEchoDebugUrgency.WARNING, _tag = "", _colour = undefined) {
	if (!ECHO_DEBUG_ENABLED) {
		return false;
	}

	var _config = __EchoGetDebugConfig();
	var _debug_level = _config.__GetDebugLevel();
	if (_debug_level == eEchoDebugLevel.NONE) {
		return false;
	}

	var _raw_capture = _config.__GetRawHistoryCapture();
	var _allowed_tags = _config.__GetAllowedTags();
	var _tags_array = [];
	if (is_array(_tag)) {
		_tags_array = _tag;
	}
	else if (_tag != "") {
		_tags_array = [_tag];
	}

	var _debug_urgency_string = __EchoGetDebugUrgencyAsString(_urgency);
	var _debug_title = $"== LOGGING ({_debug_urgency_string}) ==";
	var _message_str = string(_message);
	var _entry_colour = is_real(_colour) ? _colour : undefined;

	var _passes_level = true;
	switch (_debug_level) {
		case eEchoDebugLevel.COMPLETE:
		break;

		case eEchoDebugLevel.COMPREHENSIVE:
			if (_urgency == eEchoDebugUrgency.INFO) _passes_level = false;
		break;

		case eEchoDebugLevel.SEVERE_ONLY:
			if (_urgency != eEchoDebugUrgency.SEVERE) _passes_level = false;
		break;
	}

	var _passes_tags = true;
	// Tag filter: if allowed_tags is non-empty, require any overlap
	if (array_length(_allowed_tags) > 0) {
		_passes_tags = false;
		var _tag_count = array_length(_tags_array);
		for (var _ti = 0; _ti < _tag_count; _ti++) {
			if (array_contains(_allowed_tags, _tags_array[_ti])) {
				_passes_tags = true;
				break;
			}
		}
	}

	var _stack = [];
	var _want_stack = false;
	if (_urgency == eEchoDebugUrgency.SEVERE) {
		_want_stack = true;
	}
	else if (_urgency == eEchoDebugUrgency.WARNING) {
		if (_raw_capture || (_debug_level == eEchoDebugLevel.COMPLETE && _passes_level && _passes_tags)) {
			_want_stack = true;
		}
	}
	if (_want_stack) {
		_stack = debug_get_callstack();
	}
	var _time_str = date_datetime_string(date_current_datetime());
	var _tag_str = "";
	var _tag_num = array_length(_tags_array);
	if (_tag_num > 0) {
		var i = -1;
		_tag_str = " [";
		repeat (_tag_num) {
			_tag_str += _tags_array[++i];
			if (i < _tag_num - 1) {
				_tag_str += " | ";
			}
		}
		_tag_str += " ]";
	}
	if (_raw_capture) {
		var _raw_entry = {
			time_str    : _time_str,
			urgency     : _urgency,
			urgency_str : _debug_urgency_string,
			tags        : variable_clone(_tags_array),
			message     : _message_str,
			stack       : variable_clone(_stack),
			colour      : _entry_colour
		};
		_config.__LogRawHistoryEx($"[{_time_str}] ({_debug_urgency_string}){_tag_str}:\n{_message_str}", _raw_entry);
	}

	if (!_passes_level || !_passes_tags) {
		return false;
	}

	var _include_stack = (_urgency == eEchoDebugUrgency.SEVERE)
	|| (_debug_level == eEchoDebugLevel.COMPLETE && _urgency == eEchoDebugUrgency.WARNING);
	var _debug_message = _message_str;
	if (_include_stack) {
		_debug_message += $"Stack Trace:";
		var i = -1;
		repeat (array_length(_stack)) {
			_debug_message += $"{_stack[++i]}";
		}
	}
	var _stack_out = _include_stack ? _stack : [];
	var _entry = {
		time_str    : _time_str,
		urgency     : _urgency,
		urgency_str : _debug_urgency_string,
		tags        : variable_clone(_tags_array),
		message     : _message_str,
		stack       : variable_clone(_stack_out),
		colour      : _entry_colour
	};
	_config.__LogHistoryEx($"[{_time_str}] ({_debug_urgency_string}){_tag_str}:\n{_debug_message}", _entry);
	show_debug_message(_debug_title + _tag_str + ":\n" + _debug_message);
	return true;
}

/// @desc	Logs a debug message with an INFO urgency level
/// @param {String} _message
/// @param {String,Array<String>} [_tag]
/// @param {Real} [_colour]
function EchoDebugInfo(_message, _tag = "", _colour = undefined)   { return EchoDebug(_message, eEchoDebugUrgency.INFO, _tag, _colour); }

/// @desc	Logs a debug message with a WARNING urgency level
/// @param {String} _message
/// @param {String,Array<String>} [_tag]
/// @param {Real} [_colour]
function EchoDebugWarn(_message, _tag = "", _colour = undefined)   { return EchoDebug(_message, eEchoDebugUrgency.WARNING, _tag, _colour); }

/// @desc	Logs a debug message with a SEVERE urgency level (includes stack trace)
/// @param {String} _message
/// @param {String,Array<String>} [_tag]
/// @param {Real} [_colour]
function EchoDebugSevere(_message, _tag = "", _colour = undefined) { return EchoDebug(_message, eEchoDebugUrgency.SEVERE, _tag, _colour); }

/// @desc	Sets the debug logging level, which determines what urgency criteria messages must meet in order to be logged.
/// @param	{Real}	_level	The level of logging (pick an entry from the eEchoDebugLevel enum)
/// @return	{Boolean}
function EchoDebugSetLevel(_level) {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__SetDebugLevel(_level);
}

/// @desc	Returns the current debug logging level (will be equivalent to one of the entries from the eEchoDebugLevel enum).
/// @param	{Boolean} [_stringify]	Whether to return the debug level as a string, or as the plain real value.
/// @return	{Real,String,Bool} False if debug is disabled.
function EchoDebugGetLevel(_stringify = false) {
	if (!ECHO_DEBUG_ENABLED) return false;
	if (!_stringify) {
		return __EchoGetDebugConfig().__GetDebugLevel();
	}
	return __EchoGetDebugConfig().__GetDebugLevelAsString();
}

/// @desc	Dumps the entire debug log history to a file (file naming convention is "echo_debug_dump-[current_date]-([time_since_game_started]).txt). Returns true if dump succeeded, false if not
/// @return	{Boolean}
function EchoDebugDumpLog() {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__DumpLogHistory();
}

/// @desc	Returns the current maximum number of entries allowed in the debug log history
/// @return	{Real,Bool} False if debug is disabled.
function EchoDebugGetHistorySize() {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__GetLogHistoryMax();
}

/// @desc	Sets the maximum number of entries allowed in the debug log history. Setting it to 0 means there is no limit.
/// @param	{Real}	_max
/// @return	{Boolean}
function EchoDebugSetHistorySize(_max) {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__SetLogHistoryMax(_max);
}

/// @desc Enables or disables raw history capture for the Echo Console.
/// @param {Boolean} _enabled
/// @return {Boolean}
function EchoDebugSetRawHistoryCapture(_enabled) {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__SetRawHistoryCapture(_enabled);
}

/// @desc Clears all entries from the debug log history
/// @return {Boolean} False if debug is disabled, otherwise true after clearing.
function EchoDebugClearHistory() {
	if (!ECHO_DEBUG_ENABLED) return false;
	var _config = __EchoGetDebugConfig();
	_config.__ClearHistoryEx();
	return true;
}

/// @desc Returns a new array filled with the entries from debug log history
/// @return	{Array<String>,Boolean} False if debug is disabled.
function EchoDebugGetHistory() {
	if (!ECHO_DEBUG_ENABLED) return false;
	var _config = __EchoGetDebugConfig();
	return variable_clone(_config.log_history);
}


/// @desc Returns the current log revision number. This increments whenever history changes.
/// @return {Real,Boolean} False if debug is disabled.
function EchoDebugGetRevision() {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__GetLogRevision();
}

/// @desc Returns a new array of structured history entries for UI rendering.
/// @return {Array<Struct>,Boolean} False if debug is disabled.
function EchoDebugGetStructuredHistory() {
	if (!ECHO_DEBUG_ENABLED) return false;
	var _config = __EchoGetDebugConfig();
	return variable_clone(_config.__GetStructuredHistory());
}



/// @desc Sets which tags are allowed to log. An empty array means "allow all".
/// @param {Array<String>} _tags
/// @return {Boolean}
function EchoDebugSetTags(_tags) {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__SetAllowedTags(_tags);
}

/// @desc Clears any tag filter so all tags are allowed.
/// @return {Boolean}
function EchoDebugClearTags() {
	if (!ECHO_DEBUG_ENABLED) return false;
	__EchoGetDebugConfig().__ClearAllowedTags();
	return true;
}

/// @desc Gets the current allowed tags array (empty means "allow all").
/// @return {Array<String>,Boolean}
function EchoDebugGetTags() {
	if (!ECHO_DEBUG_ENABLED) return false;
	return __EchoGetDebugConfig().__GetAllowedTags();
}
