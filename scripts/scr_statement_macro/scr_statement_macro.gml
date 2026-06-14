// Turns debugging on or off for Statement
#macro STATEMENT_DEBUG 1

// Controls - Rebind as you see fit!
#macro STATEMENT_LENS_BIND_CLOSE_INSPECTOR				new EchoChamberInputBindingKey(vk_escape)
#macro STATEMENT_LENS_BIND_PREV_MACHINE					new EchoChamberInputBindingKey(vk_pageup)
#macro STATEMENT_LENS_BIND_NEXT_MACHINE					new EchoChamberInputBindingKey(vk_pagedown)
#macro STATEMENT_LENS_BIND_TOGGLE_MODE					new EchoChamberInputBindingKey(ord("V"))
#macro STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_RIGHT	new EchoChamberInputBindingKey(vk_right)
#macro STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_LEFT		new EchoChamberInputBindingKey(vk_left)
#macro STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_UP		new EchoChamberInputBindingKey(vk_up)
#macro STATEMENT_LENS_BIND_EGO_MODE_MOVE_STATE_DOWN		new EchoChamberInputBindingKey(vk_down)
#macro STATEMENT_LENS_BIND_EGO_MODE_SELECT_STATE		new EchoChamberInputBindingKey(ord("O"))
#macro STATEMENT_LENS_BIND_OPEN_SEARCH_PALETTE			new EchoChamberInputBindingKey(ord("F"), eEchoChamberInputCheck.PRESSED, true)
#macro STATEMENT_LENS_BIND_CLOSE_SEARCH_PALETTE			new EchoChamberInputBindingKey(vk_escape)
#macro STATEMENT_LENS_BIND_SCROLL_UP_SEARCH_PALETTE		new EchoChamberInputBindingKey(vk_up)
#macro STATEMENT_LENS_BIND_SCROLL_DOWN_SEARCH_PALETTE	new EchoChamberInputBindingKey(vk_down)
#macro STATEMENT_LENS_BIND_ACCEPT_SEARCH_PALETTE		new EchoChamberInputBindingKey(vk_tab)
#macro STATEMENT_LENS_BIND_CENTER_CAMERA_ON_STATE		new EchoChamberInputBindingKey(ord("C"))

// Don't touch these unless you know what you are doing
#macro STATEMENT_LENS_ACTION_CLOSE_INSPECTOR				"statement_lens.close_inspector"
#macro STATEMENT_LENS_ACTION_PREV_MACHINE					"statement_lens.prev_machine"
#macro STATEMENT_LENS_ACTION_NEXT_MACHINE					"statement_lens.next_machine"
#macro STATEMENT_LENS_ACTION_TOGGLE_MODE					"statement_lens.toggle_mode"
#macro STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_RIGHT		"statement_lens.ego_move_right"
#macro STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_LEFT		"statement_lens.ego_move_left"
#macro STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_UP			"statement_lens.ego_move_up"
#macro STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_DOWN		"statement_lens.ego_move_down"
#macro STATEMENT_LENS_ACTION_EGO_MODE_SELECT_STATE			"statement_lens.ego_select_state"
#macro STATEMENT_LENS_ACTION_OPEN_SEARCH_PALETTE			"statement_lens.search_open"
#macro STATEMENT_LENS_ACTION_CLOSE_SEARCH_PALETTE			"statement_lens.search_close"
#macro STATEMENT_LENS_ACTION_SCROLL_UP_SEARCH_PALETTE		"statement_lens.search_scroll_up"
#macro STATEMENT_LENS_ACTION_SCROLL_DOWN_SEARCH_PALETTE		"statement_lens.search_scroll_down"
#macro STATEMENT_LENS_ACTION_ACCEPT_SEARCH_PALETTE			"statement_lens.search_accept"
#macro STATEMENT_LENS_ACTION_CENTER_CAMERA_ON_STATE			"statement_lens.center_camera_on_state"

#macro STATEMENT_LENS_INPUT_CLOSE_INSPECTOR				StatementLensInputPressed(STATEMENT_LENS_ACTION_CLOSE_INSPECTOR)
#macro STATEMENT_LENS_INPUT_PREV_MACHINE				StatementLensInputPressed(STATEMENT_LENS_ACTION_PREV_MACHINE)
#macro STATEMENT_LENS_INPUT_NEXT_MACHINE				StatementLensInputPressed(STATEMENT_LENS_ACTION_NEXT_MACHINE)
#macro STATEMENT_LENS_INPUT_TOGGLE_MODE					StatementLensInputPressed(STATEMENT_LENS_ACTION_TOGGLE_MODE)
#macro STATEMENT_LENS_INPUT_EGO_MODE_MOVE_STATE_RIGHT	StatementLensInputPressed(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_RIGHT)
#macro STATEMENT_LENS_INPUT_EGO_MODE_MOVE_STATE_LEFT	StatementLensInputPressed(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_LEFT)
#macro STATEMENT_LENS_INPUT_EGO_MODE_MOVE_STATE_UP		StatementLensInputPressed(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_UP)
#macro STATEMENT_LENS_INPUT_EGO_MODE_MOVE_STATE_DOWN	StatementLensInputPressed(STATEMENT_LENS_ACTION_EGO_MODE_MOVE_STATE_DOWN)
#macro STATEMENT_LENS_INPUT_EGO_MODE_SELECT_STATE		StatementLensInputPressed(STATEMENT_LENS_ACTION_EGO_MODE_SELECT_STATE)
#macro STATEMENT_LENS_INPUT_OPEN_SEARCH_PALETTE			StatementLensInputPressed(STATEMENT_LENS_ACTION_OPEN_SEARCH_PALETTE)
#macro STATEMENT_LENS_INPUT_CLOSE_SEARCH_PALETTE		StatementLensInputPressed(STATEMENT_LENS_ACTION_CLOSE_SEARCH_PALETTE)
#macro STATEMENT_LENS_INPUT_SCROLL_UP_SEARCH_PALETTE	StatementLensInputPressed(STATEMENT_LENS_ACTION_SCROLL_UP_SEARCH_PALETTE)
#macro STATEMENT_LENS_INPUT_SCROLL_DOWN_SEARCH_PALETTE	StatementLensInputPressed(STATEMENT_LENS_ACTION_SCROLL_DOWN_SEARCH_PALETTE)
#macro STATEMENT_LENS_INPUT_ACCEPT_SEARCH_PALETTE		StatementLensInputPressed(STATEMENT_LENS_ACTION_ACCEPT_SEARCH_PALETTE)
#macro STATEMENT_LENS_INPUT_CENTER_CAMERA_ON_STATE		StatementLensInputPressed(STATEMENT_LENS_ACTION_CENTER_CAMERA_ON_STATE)

#macro STATEMENT_TIME_GLOBAL_SCALE global.__statement_time_scale

enum eStatementEvents {
	ENTER,
	EXIT,
	STEP,
	DRAW,
	NUM
}

enum eStatementDebugEdgeKind {
    DECLARATIVE,
    OBSERVED,
    MANUAL
}

enum eStatementLensOverlay {
	NONE,
	HEATMAP,
}

enum eStatementHeatMetric {
	TIME,
	VISITS,
}

enum eStatementUpdateMode {
	ACCUMULATED,
	PER_FRAME,
}

enum eStatementResetMode {
	RESET_ON_EXIT,
	REMEMBER,
	RESET_ON_ENTER,
}

enum eStatementDebugEdgeStyle {
	STRUCTURAL,
	LAST_TRANSITION,
	QUEUED,
	HISTORY
}

enum eStatementLensMode {
	FULL,
	EGO,
	RADIAL,
	CLOUD,
}

enum eStatementErrorBehavior {
	PAUSE,     // catch, record, pause machine (default)
	RETHROW    // record, then rethrow to crash/propagate
}

enum eStatementBindMode {
	REPLACE,
	APPEND,
	PREPEND,
}
