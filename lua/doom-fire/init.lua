local colors = require("doom-fire.colors")
local utils = require("doom-fire.utils")

local M = {}

local default_opts = { show_color_vals = false }
local namespace = vim.api.nvim_create_namespace("doom")

local function do_fire(w, h, output_buf)
	local lines = {}
	local hl_colors = {}
	for y = 0, h do
		local row = ""
		for x = 0, w do
			local idx = y * w + x
			local below = idx + w
			local decay = math.floor(math.random() * 4)
			local below_val = below >= w * h and 36 or output_buf[below]

			output_buf[idx - decay] = math.max(below_val - decay, 0)
			hl_colors[idx] = "Doom" .. output_buf[idx - decay] + 1

			if M.options.show_color_vals then
				row = row .. string.format("%02d", output_buf[idx - decay])
			else
				row = row .. "  "
			end
		end
		table.insert(lines, row)
	end

	return {
		lines = lines,
		hl_colors = hl_colors,
	}
end

local function draw(buffer, w, h, output_buf)
	local r = do_fire(w, h, output_buf)
	local lines = r.lines
	local hl_colors = r.hl_colors

	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)

	local x_scale = M.options.show_color_vals and 2 or 1

	for y = 0, h do
		local row = lines[y + 1]
		local cell_count = math.floor(#row / x_scale)
		for x = 0, cell_count - 1 do
			local idx = y * w + x
			local col = x * x_scale
			vim.api.nvim_buf_set_extmark(buffer, namespace, y, col, {
				end_col = col + x_scale,
				hl_group = hl_colors[idx],
			})
		end
	end
end

function M.run()
	local buffer = vim.api.nvim_create_buf(false, true)
	local x_scale = M.options.show_color_vals and 2 or 1
	local width = math.floor(vim.o.columns * 0.5 / x_scale)
	local height = math.floor(vim.o.lines * 0.5)
	local pix_buf = utils.init_buf(width, height, 36)

	local timer = utils.setInterval(100, function()
		vim.schedule(function()
			draw(buffer, width, height, pix_buf)
		end)
	end)

	local window = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = width * x_scale,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width * x_scale) / 2),
		style = "minimal",
		border = "none",
	})

	-- Prevent buffer from lingering if user closes some other way
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(window, true)
		timer:stop()
		timer:close()

		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buffer,
			once = true,
			callback = function()
				if vim.api.nvim_win_is_valid(window) then
					vim.api.nvim_win_close(window, true)
				end
			end,
		})
	end, { buffer = buffer, nowait = true })

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buffer,
		callback = function()
			timer:stop()
			timer:close()
		end,
	})

	return buffer, window
end

function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", default_opts, user_opts or {})
	colors.define_colors(colors.doom, "Doom")
end

return M
