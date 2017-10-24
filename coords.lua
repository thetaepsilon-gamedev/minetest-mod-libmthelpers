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

coords.adjacent_offsets = {
	{x= 1,y= 0,z= 0},
	{x=-1,y= 0,z= 0},
	{x= 0,y= 1,z= 0},
	{x= 0,y=-1,z= 0},
	{x= 0,y= 0,z= 1},
	{x= 0,y= 0,z=-1},
}

return coords
