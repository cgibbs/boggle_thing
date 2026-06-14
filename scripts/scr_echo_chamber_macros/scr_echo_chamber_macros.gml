#macro ECHO_UI_ACTION_CANCEL	"echo.ui.cancel"
#macro ECHO_UI_ACTION_ACCEPT	"echo.ui.accept"
#macro ECHO_UI_ACTION_TAB_NEXT	"echo.ui.tab_next"
#macro ECHO_UI_ACTION_TAB_PREV	"echo.ui.tab_prev"
#macro ECHO_UI_ACTION_NAV_UP	"echo.ui.nav_up"
#macro ECHO_UI_ACTION_NAV_DOWN	"echo.ui.nav_down"
#macro ECHO_UI_ACTION_PAGE_UP	"echo.ui.page_up"
#macro ECHO_UI_ACTION_PAGE_DOWN "echo.ui.page_down"
#macro ECHO_UI_ACTION_HOME		"echo.ui.home"
#macro ECHO_UI_ACTION_END		"echo.ui.end"
#macro ECHO_UI_ACTION_RESTORE_WINDOWS "echo.ui.restore_windows"

#macro ECHO_UI_BIND_CANCEL		new EchoChamberInputBindingKey(vk_escape)
#macro ECHO_UI_BIND_ACCEPT		new EchoChamberInputBindingFunc(function() { return keyboard_check(vk_control) && keyboard_check_released(ord("E")); })
#macro ECHO_UI_BIND_TAB_NEXT	new EchoChamberInputBindingFunc(function() { return keyboard_check_pressed(vk_tab) && !keyboard_check(vk_shift); })
#macro ECHO_UI_BIND_TAB_PREV	new EchoChamberInputBindingFunc(function() { return keyboard_check_pressed(vk_tab) && keyboard_check(vk_shift); })
#macro ECHO_UI_BIND_NAV_UP		new EchoChamberInputBindingKey(vk_up)
#macro ECHO_UI_BIND_NAV_DOWN	new EchoChamberInputBindingKey(vk_down)
#macro ECHO_UI_BIND_PAGE_UP		new EchoChamberInputBindingKey(vk_pageup)
#macro ECHO_UI_BIND_PAGE_DOWN	new EchoChamberInputBindingKey(vk_pagedown)
#macro ECHO_UI_BIND_HOME		new EchoChamberInputBindingKey(vk_home)
#macro ECHO_UI_BIND_END			new EchoChamberInputBindingKey(vk_end)
#macro ECHO_UI_BIND_RESTORE_WINDOWS new EchoChamberInputBindingKey(vk_f12)

// Text input modes (Echo Chamber text inputs / areas).
#macro ECHO_TEXTMODE_TEXT			0
#macro ECHO_TEXTMODE_INT			1
#macro ECHO_TEXTMODE_FLOAT			2
#macro ECHO_TEXTMODE_IDENTIFIER	3
#macro ECHO_TEXTMODE_PATH			4
#macro ECHO_TEXTMODE_CODE			5
#macro ECHO_TEXTMODE_PASSWORD		6

/// @desc Dock position for debug UI panels.
enum eEchoChamberDock {
	FILL,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

/// @desc Collapse direction / capability for panels.
enum eEchoChamberCollapse {
	NONE,
	TO_LEFT,
	TO_RIGHT,
	TO_TOP,
	TO_BOTTOM
}

/// @desc Size policy for docked panels.
enum eEchoChamberPanelSizeMode {
	FIXED,
	FIT_CONTENT
}

/// @desc Flow direction for panel child controls.
enum eEchoChamberPanelFlow {
	ROW,
	COLUMN
}

/// @desc Placement options for panel-drawn field labels.
enum eEchoChamberFieldLabelPlacement {
	AUTO,
	LEADING,
	ABOVE,
	NONE,
	//TRAILING,
	//BELOW
}

/// @desc Input check type for Echo Chamber input actions.
enum eEchoChamberInputCheck {
	PRESSED,
	DOWN,
	RELEASED
}

/// @desc Binding kind for Echo Chamber input actions.
enum eEchoChamberInputBindKind {
	KEY,
	FUNC,
	BLOCK
}
