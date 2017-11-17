-- modhelpers.readonly: defensive copying of objects to prevent modifications to shared objects.
-- use to clone "template objects" (such as tables of helper functions),
-- so that users of the cloned table cannot modify a shared instance of the table and therefore affect other users.

local readonly = {}
local mkfnexploder = modhelpers.check.mkfnexploder



-- used to be here, now aliased from tableutils for compatibilty
readonly.shallowcopy = modhelpers.tableutils.shallowcopy

-- "curries" a table method function into a closure.
-- the function implicitly retains a handle to the original table,
-- and can be passed around invididually.
local curry = function(tbl, m)
	return function(...)
		return m(tbl, ...)
	end
end
readonly.currymethod = curry

local check_curryobject = mkfnexploder("curryobject()")
-- curry a list of methods from an existing table.
local curryobject = function(tbl, list)
	local check = check_curryobject
	local result = {}
	for _, key in ipairs(list) do
		local m = tbl[key]
		check(m, "table method "..tostring(key))
		result[key] = curry(tbl, m)
	end
	return result
end
readonly.curryobject = curryobject

return readonly
