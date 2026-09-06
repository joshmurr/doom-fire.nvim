local M = {}

M.setInterval = function(interval, callback)
	local timer = vim.uv.new_timer()
	timer:start(interval, interval, function()
		callback()
	end)
	return timer
end

return M
