return require("telescope").register_extension({
	exports = {
		dap_sessions = require("session_picker").dap_sessions,
	},
})
