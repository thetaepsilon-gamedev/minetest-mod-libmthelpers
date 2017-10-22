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

return tableutils
