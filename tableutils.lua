local tableutils = {}

tableutils.filter = function(table, f)
	local ret = {}
	for key, value in pairs(table) do
		ret[key] = f(value)
	end
	return ret
end

tableutils.grep = function(table, f)
	local ret = {}
	for key, value in pairs(table) do
		if f(key) then ret[key] = value end 
	end
	return ret
end

tableutils.shallowcopy = function(input)
	-- table is the only type that this works for, can't truly duplicate a userdata from lua code.
	if type(input) ~= "table" then error("only tables can be shallow copied") end

	local ret = {}
	for k, v in pairs(input) do
		ret[k] = v
	end

	return ret
end

-- overlay values onto a table provided by a caller,
-- without clobbering their values if it's held by the caller for re-use.
-- resulting table will see the overlay table's values override the base table.
-- WARNING: does not work correctly with anything using pairs() or ipairs()!
tableutils.overlay = function(t, o)
	local result = {}
	local meta = {
		__index = function(tbl, key)
			local result = o[key]
			if result == nil then
				result = t[key]
			end
			return result
		end
	}
	setmetatable(result, meta)
	return result
end

-- search for a value in a table.
-- returns found key or nil.
-- optionally takes a comparator argument.
tableutils.search = function(t, v, comp)
	if comp == nil then comp = function(a, b) return a == b end end
	local result = nil
	for key, value in pairs(t) do
		if comp(value, v) then
			result = key
			break
		end
	end
	return result
end

return tableutils
