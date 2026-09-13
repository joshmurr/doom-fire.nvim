local M = {}

M.setInterval = function(interval, callback)
	local timer = vim.uv.new_timer()
	timer:start(interval, interval, function()
		callback()
	end)
	return timer
end

M.init_buf = function(width, height, get_val)
	local buf = {}
	for i = 0, width * height do
		buf[i] = get_val(i)
	end
	return buf
end

return M
