local continuations = {}

-- run a function/closure repeatedly on an event loop.
-- the closure is expected to take bounded time,
-- record it's state somewhere if desired,
-- then continue running when called again.
-- this is done by repeatedly re-enqueing a wrapper function on the event loop
local loop_repeat = function(enqueuer, closure, delay, initialdelay)
	if initialdelay == nil then initialdelay = delay end
	local loop = {}
	local callback = function()
		closure()
		enqueuer(delay, loop.callback)
	end
	loop.callback = callback
	enqueuer(initialdelay, callback)
end
continuations.event_loop_repeat = loop_repeat

-- enqueue wrapper and helper utilising the MT api's minetest.after routine
local mt = function(delay, callback) minetest.after(delay, callback) end
continuations.minetest_enqueuer = mt
continuations.minetest_loop_repeat = function(closure, delay, initialdelay)
	loop_repeat(mt, closure, delay, initialdelay)
end

return continuations
