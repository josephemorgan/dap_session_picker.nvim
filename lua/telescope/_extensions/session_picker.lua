return require("telescope").register_extension({
	exports = {
		session_picker = require("session_picker").dap_sessions,
	},
})
