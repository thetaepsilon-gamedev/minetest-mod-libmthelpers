-- yes, I *know* calling partial application "currying" is incorrect...
local curry = {}
local mkfnexploder = _deps.curry.mkfnexploder

-- partially applies the "self" object of a table method function into a closure.
-- that is, f(self, a, ...) becomes g(a, ...) and "self" is captured by closure scope of the function.
-- the function implicitly retains a handle to the original table,
-- and can be passed around invididually.
local currymethod = function(tbl, m)
	return function(...)
		return m(tbl, ...)
	end
end
curry.method = currymethod

local check_curryobject = mkfnexploder("curryobject()")
-- curry a list of methods from an existing table.
local curryobject = function(tbl, list)
	local check = check_curryobject
	local result = {}
	for _, key in ipairs(list) do
		local m = tbl[key]
		check(m, "table method "..tostring(key))
		result[key] = currymethod(tbl, m)
	end
	return result
end
curry.object = curryobject

return curry
