/// @func EchoChamberInputBinding()
/// @desc Base binding type for Echo Chamber input actions.
/// @return {Struct.EchoChamberInputBinding}
function EchoChamberInputBinding() constructor {
	kind = eEchoChamberInputBindKind.BLOCK;
}

/// @func EchoChamberInputBindingKey(_key, [_check], [_ctrl], [_alt], [_shift])
/// @desc Keyboard binding for an Echo Chamber input action.
/// @param {Real} _key Keyboard keycode (vk_* or ord()).
/// @param {Real} [_check] Input check type (pressed/down/released).
/// @param {Bool} [_ctrl] Require Ctrl to be held.
/// @param {Bool} [_alt] Require Alt to be held.
/// @param {Bool} [_shift] Require Shift to be held.
/// @return {Struct.EchoChamberInputBinding}
function EchoChamberInputBindingKey(_key, _check = eEchoChamberInputCheck.PRESSED, _ctrl = false, _alt = false, _shift = false) : EchoChamberInputBinding() constructor {
	kind  = eEchoChamberInputBindKind.KEY;
	key   = _key;
	check = _check;
	ctrl  = (_ctrl == true);
	alt   = (_alt == true);
	shift = (_shift == true);
}

/// @func EchoChamberInputBindingFunc(_fn)
/// @desc Function binding for an Echo Chamber input action.
/// @param {Function} _fn Function that returns true when the action should fire.
/// @return {Struct.EchoChamberInputBinding}
function EchoChamberInputBindingFunc(_fn) : EchoChamberInputBinding() constructor {
	kind = eEchoChamberInputBindKind.FUNC;
	fn   = _fn;
}

/// @func EchoChamberInputBindingBlock()
/// @desc Binding that blocks an action from inheriting from its parent context.
/// @return {Struct.EchoChamberInputBinding}
function EchoChamberInputBindingBlock() : EchoChamberInputBinding() constructor {
	kind = eEchoChamberInputBindKind.BLOCK;
}

/// @func EchoChamberInputContext(_id)
/// @desc Input context for Echo Chamber actions (supports inheritance).
/// @param {String} _id Context id.
/// @return {Struct.EchoChamberInputContext}
function EchoChamberInputContext(_id) constructor {
	id        = string(_id);
	parent_id = undefined;
	bindings  = {};

	/// @desc Set the parent context id for inheritance.
	/// @param {String} _parent_id
	/// @return {Struct.EchoChamberInputContext}
	static SetParent = function(_parent_id) {
		var _parent = is_undefined(_parent_id) ? undefined : string(_parent_id);
		if (!is_undefined(_parent) && _parent == id) {
			return self;
		}
		parent_id = _parent;
		return self;
	};

	/// @desc Get the binding for an action id (or undefined if none).
	/// @param {String} _action_id
	/// @return {Struct.EchoChamberInputBinding}
	static GetBinding = function(_action_id) {
		return bindings[$ string(_action_id)];
	};

	/// @desc Bind an action to a binding instance.
	/// @param {String} _action_id
	/// @param {Struct.EchoChamberInputBinding} _binding
	/// @return {Struct.EchoChamberInputContext}
	static BindAction = function(_action_id, _binding) {
		if (!is_instanceof(_binding, EchoChamberInputBinding)) {
			return self;
		}
		bindings[$ string(_action_id)] = _binding;
		return self;
	};

	/// @desc Bind an action to a keyboard key.
	/// @param {String} _action_id
	/// @param {Real} _key Keyboard keycode (vk_* or ord()).
	/// @param {Real} [_check] Input check type (pressed/down/released).
	/// @param {Bool} [_ctrl] Require Ctrl to be held.
	/// @param {Bool} [_alt] Require Alt to be held.
	/// @param {Bool} [_shift] Require Shift to be held.
	/// @return {Struct.EchoChamberInputContext}
	static BindKey = function(_action_id, _key, _check = eEchoChamberInputCheck.PRESSED, _ctrl = false, _alt = false, _shift = false) {
		var _binding = new EchoChamberInputBindingKey(_key, _check, _ctrl, _alt, _shift);
		return BindAction(_action_id, _binding);
	};

	/// @desc Bind an action to a custom function.
	/// @param {String} _action_id
	/// @param {Function} _fn Function that returns true when the action should fire.
	/// @return {Struct.EchoChamberInputContext}
	static BindFunc = function(_action_id, _fn) {
		if (!is_callable(_fn)) {
			return self;
		}
		var _binding = new EchoChamberInputBindingFunc(_fn);
		return BindAction(_action_id, _binding);
	};

	/// @desc Bind an action to a blocker (prevents inheritance).
	/// @param {String} _action_id
	/// @return {Struct.EchoChamberInputContext}
	static BindBlock = function(_action_id) {
		var _binding = new EchoChamberInputBindingBlock();
		return BindAction(_action_id, _binding);
	};

	/// @desc Clear a local action binding (falls back to parent context).
	/// @param {String} _action_id
	/// @return {Struct.EchoChamberInputContext}
	static ClearAction = function(_action_id) {
		bindings[$ string(_action_id)] = undefined;
		return self;
	};
}
