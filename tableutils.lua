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

return tableutils
