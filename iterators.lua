-- convienience functions for working with iterators.

local iterators = {}

-- producers an object wrapping a coroutine in an object to yield an iterator closure.
-- the iterator works as outlined in the lua docs to work with the generic for-loop;
-- returns nil to stop, non-nil for a next value.
iterators.mkiterator = function(coroutinefn, arg)
	local started = false
	local co = coroutine.create(coroutinefn)
	local breaker = false
	return function()
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
end

iterators.mktableiterator = function(t)
	local tableco = function(t) for k, v in pairs(t) do coroutine.yield({k, v}) end end
	return iterators.mkiterator(tableco, t)
end

return iterators
