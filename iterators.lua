-- convienience functions for working with iterators.

local iterators = {}

-- producers an object wrapping a coroutine in an object on which you can call .next().
-- the coroutine function should "return" (by either coroutine.yield() or normal return)
-- a non-nil object to continue running, nil to stop.
-- the coroutine will only be supplied a single parameter.
-- only a single object will be passed through to the return value of .next().
-- no return values will be visible to coroutine.yield in the function.
iterators.mkiterator = function(coroutinefn, arg)
	local started = false
	local co = coroutine.create(coroutinefn)
	local breaker = false
	return {
		next = function()
			if breaker then return nil end
			local continuing
			local result
			if not started then
				continuing, result = coroutine.resume(co, arg)
			else
				continuing, result = coroutine.resume(co)
			end
			if not continuing or result == nil then breaker = true end
			return result
		end
	}
end

iterators.mktableiterator = function(t)
	local tableco = function(t) for k, v in pairs(t) do coroutine.yield({k, v}) end end
	return iterators.mkiterator(tableco, t)
end

return iterators
