-- modhelpers.readonly: defensive copying of objects to prevent modifications to shared objects.
-- use to clone "template objects" (such as tables of helper functions),
-- so that users of the cloned table cannot modify a shared instance of the table and therefore affect other users.

local readonly = {}

readonly.shallowcopy = function(input)
	-- table is the only type that needs this protection, can't duplicate a userdata from lua code...
	-- all other types are immutable values.
	if type(input) ~= "table" then error("only tables can be shallow copied") end

	local ret = {}
	for k, v in pairs(input) do
		ret[k] = v
	end

	return ret
end

return readonly
