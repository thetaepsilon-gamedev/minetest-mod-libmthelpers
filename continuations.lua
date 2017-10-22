local continuations = {}

-- run a function/closure repeatedly on an event loop.
-- the closure is expected to take bounded time,
-- record it's state somewhere if desired,
-- then continue running when called again.
-- this is done by repeatedly re-enqueing a wrapper function on the event loop.
-- return false to request no further invocation.
local missingdebugger = function(msg) end
local getdebugger = function(opts, dname)
	local debugger = opts.debugger
	local result = missingdebugger
	dname = tostring(dname).." "
	if type(debugger) == "function" then
		result = function(msg)
			debugger(dname..msg)
		end
	end
	return result
end
local loop_repeat = function(enqueuer, closure, opts)
	local dname = "loop_repeat()"
	if type(opts) ~= "table" then opts = {} end

	local delay = opts.delay
	if delay == nil then delay = 0 end
	local initialdelay = opts.initialdelay
	if initialdelay == nil then initialdelay = 0 end
	local debugger = getdebugger(opts, dname)

	local loop = {}
	local callback = function()
		debugger("callback entry")
		if closure() then
			debugger("restarting closure")
			enqueuer(delay, loop.callback)
		else
			debugger("closure requested termination")
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
local loop_batch = function(enqueuer, opts, callback, iterator, maxbatch)
	local dname = "loop_batch()"
	local debugger = getdebugger(opts, dname)
	local batch_process = function()
		local sname = "batch_process() "
		debugger(sname.."callback entry")
		local count = 0
		local stop = false
		while true do
			local nextitem = iterator()
			debugger(sname.."nextitem="..tostring(nextitem))
			if nextitem == nil then
				debugger(sname.."stopping due to iterator end")
				stop = true
				break
			end
			if not callback(nextitem) then
				debugger(sname.."stopping as callback returned false")
				stop = true
				break
			end
			count = count + 1
			-- don't run over, but still request to run again
			if count >= maxbatch then
				debugger(sname.."halting loop due to limit")
				break
			end
		end
		local result = not stop
		debugger(sname.."result="..tostring(result))
		return result
	end
	loop_repeat(enqueuer, batch_process, opts)
end
continuations.loop_batch = loop_batch

-- helper over array-like tables, see iterators.lua
local mkarrayiterator = modhelpers.iterators.mkarrayiterator
continuations.loop_batch_array = function(enqueuer, opts, callback, array, maxbatch)
	local iterator = mkarrayiterator(array)
	loop_batch(enqueuer, opts, callback, iterator, maxbatch)
end



return continuations
