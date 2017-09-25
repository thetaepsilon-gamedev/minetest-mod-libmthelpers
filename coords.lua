local coords = {}

coords.format = function(vec, sep, start, tail)
	sep = sep or ","
	start = start or "("
	tail = tail or ")"

	local coord = function(val)
		local valtype = type(val)
		local ret = ""
		if valtype == nil then
			ret = "???"
		elseif valtype == "number" then
			ret = tostring(val)
		else
			ret = "<NaN>"
		end
		return ret
	end

	return start..coord(vec.x)..sep..coord(vec.y)..sep..coord(vec.z)..tail
end

return coords
