local continuations = {}

-- run a function/closure repeatedly on an event loop.
-- the closure is expected to take bounded time,
-- record it's state somewhere if desired,
-- then continue running when called again.
-- this is done by repeatedly re-enqueing a wrapper function on the event loop.
-- return false to request no further invocation.
local loop_repeat = function(enqueuer, closure, opts)
	if type(opts) ~= "table" then opts = {} end

	local delay = opts.delay
	if delay == nil then delay = 0 end
	local initialdelay = opts.initialdelay
	if initialdelay == nil then initialdelay = 0 end

	local loop = {}
	local callback = function()
		if closure() then
			enqueuer(delay, loop.callback)
		end
	end
	loop.callback = callback
	enqueuer(initialdelay, callback)
end
continuations.event_loop_repeat = loop_repeat

-- enqueue wrapper and helper utilising the MT api's minetest.after routine
local mt = function(delay, callback) minetest.after(delay, callback) end
continuations.minetest_enqueuer = mt
continuations.minetest_loop_repeat = function(closure, opts)
	loop_repeat(mt, closure, opts)
end



-- batches several repeated operations up to a limit.
-- this currently only works on invocation count basis, not elapsed time,
-- so this should be used either with a conservative batch count,
-- or a relatively predictable processing function.
local loop_batch = function(enqueuer, callback, iterator, maxbatch)
	local opts = { delay = 0, initialdelay = 0 }
	local batch_process = function()
		local count = 0
		local stop = false
		while true do
			local nextitem = iterator()
			if nextitem == nil then
				stop = true
				break
			end
			if not callback(nextitem) then
				stop = true
				break
			end
			count = count + 1
			-- don't run over, but still request to run again
			if count >= maxbatch then break end
		end
		return not stop
	end
	loop_repeat(enqueuer, batch_process, opts)
end
continuations.loop_batch = loop_batch

-- helper over array-like tables, see iterators.lua
local mkarrayiterator = modhelpers.iterators.mkarrayiterator
continuations.loop_batch_array = function(enqueuer, callback, array, maxbatch)
	local iterator = mkarrayiterator(array)
	loop_batch(enqueuer, callback, iterator, maxbatch)
end



return continuations
