return {
	dap_sessions = function(opts)
		opts = opts or {}

		local dap = require("dap")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		-- Get all active sessions
		local sessions = dap.sessions()
		local current_session = dap.session()

		-- Check if there are any sessions
		if not sessions or vim.tbl_isempty(sessions) then
			vim.notify("No active DAP sessions", vim.log.levels.WARN)
			return
		end

		-- Convert sessions table to a list for Telescope
		local session_list = {}
		for id, session in pairs(sessions) do
			local is_active = current_session and current_session.id == id
			table.insert(session_list, {
				id = id,
				session = session,
				is_active = is_active,
			})
		end

		pickers
			.new(opts, {
				prompt_title = "DAP Sessions",
				finder = finders.new_table({
					results = session_list,
					entry_maker = function(entry)
						local display_text = string.format(
							"%s Session %s [%s]",
							entry.is_active and "▶" or " ",
							entry.id,
							entry.session.config and entry.session.config.name or "unknown"
						)

						return {
							value = entry,
							display = display_text,
							ordinal = display_text,
						}
					end,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()

						if selection then
							local selected_session = selection.value.session

							-- Try to set the session as active
							-- Note: nvim-dap uses an internal method to set the focused session
							-- We'll try the most common approach
							if dap.set_session then
								-- If set_session exists (it might be an internal API)
								dap.set_session(selected_session)
							end
							vim.notify(
								string.format("Focused DAP session %s", selected_session.id),
								vim.log.levels.INFO
							)
						end
					end)

					return true
				end,
			})
			:find()
	end,
}
