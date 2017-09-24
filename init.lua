modhelpers = {}

--[[
local debugprint = function(msg)
	print("## "..msg)
end
]]
local debugprint = function(msg)
	-- no-op
end



-- pretty-print co-ordinates
modhelpers.formatcoords = function(vec, sep, start, tail)
	sep = sep or ","
	start = start or "("
	tail = tail or ")"
	local coord = function(val)
		valtype = type(val)
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



modhelpers.repstr = function(base, count)
	base = tostring(base)
	count = tonumber(count) or 0
	local ret = ""
	for i = 1, count, 1 do
		ret = ret..base
	end
	return ret
end



-- object pretty printing

-- forward declaration for cyclic recursive calling
local tabletostring

local valuetostring = function(obj, label, level, recurselimit, visited, multiline, indentlevel, indentstr)
	local valtype = type(obj)
	if valtype == "string" then
		return "\""..tostring(obj).."\""
	elseif valtype == "table" then
		debugprint(tostring(obj))
		if level >= recurselimit then
			debugprint(label.." would exceed recursion limit, skipping")
			return tostring(obj)
		else
			local cyclelabel = visited[obj]
			if not cyclelabel then
				-- make a note of this object being visited to avoid cycle loops
				visited[obj] = label
				debugprint(label.." is an unvisited table, recursing.")
				return tabletostring(obj, label, level+1, recurselimit, visited, multiline, indentlevel, indentstr)
			else
				debugprint(label.." already encountered, skipping.")
				return tostring(obj).." -- "..cyclelabel
			end
		end
	else
		return tostring(obj)
	end
end

-- handle tables in particular, calling objtostring() on each.
-- this and the above call each other recursively.
-- NB declared local above
tabletostring = function(t, label, level, recurselimit, visited, multiline, indentlevel, indentstr)
	local recordsep
	if multiline then
		recordsep = "\n" .. modhelpers.repstr(indentstr, indentlevel+1)
	else
		recordsep = " "
	end
	local kvsep = " = "

	local ret = "{"
	local first = true
	for key, value in pairs(t) do
		-- print comma after preceding item if not the first
		if first then first = false else
			ret = ret .. ","
		end
		ret = ret .. recordsep
		local valuestr = valuetostring(value, label.."."..key, level, recurselimit, visited, multiline, indentlevel+1, indentstr)
		ret = ret..key..kvsep..valuestr
	end
	if multiline then
		ret = ret.."\n"..modhelpers.repstr(indentstr, indentlevel)
	else
		ret = ret .. " "
	end
	ret = ret.."}"
	return ret
end

-- format an object in a canonical form for logs etc.
-- note that this is not advisable to call on large tables,
-- such as the minetest global.
-- doing so tends to lead to out-of-memory errors.
modhelpers.formatobj = function(obj, label, recurselimit, multiline, indentstr)
	recurselimit = recurselimit or 4
	return valuetostring(obj, label, 0, recurselimit, {}, multiline, 0, indentstr)
end
-- defaults for multi-line printing.
-- multiple spaces are used as the indent,
-- as chat output via the luacmd mod's print() doesn't give tabs a sane size.
modhelpers.formatobjmultiline = function(obj, label, recurselimit)
	return modhelpers.formatobj(obj, label, recurselimit, true, "    ")
end



-- table utilities

local tablefilter = function(table, f)
	local ret = {}
	for key, value in pairs(table) do
		ret[key] = f(value)
	end
	return ret
end
modhelpers.tablefilter = tablefilter

local tablegrep = function(table, f)
	local ret = {}
	for key, value in pairs(table) do
		if f(key) then ret[key] = value end 
	end
	return ret
end
modhelpers.tablegrep = tablegrep



--player positioning helpers

-- sometimes, I freaking love functional programming techniques
local pos_center_on_node = function(pos)
	return tablefilter(pos, math.floor)
end
modhelpers.pos_center_on_node = pos_center_on_node

local posbias = function(pos, x, y, z)
	return { x=pos.x + x, y=pos.y + y, z=pos.z + z}
end
modhelpers.posbias = posbias

local playerstoodnode = function(playerref)
	return pos_center_on_node(posbias(playerref:get_pos(), 0.5, 0.0, 0.5))
end
modhelpers.playerstoodnode = playerstoodnode

modhelpers.getstoodnode = function(playerref)
	local pos = playerstoodnode(playerref)
	return { data = minetest.get_node(pos), pos = pos }
end

--[[
modhelpers.playerlegnode = function(p) return posbias(playerstoodnode(p), 0, 1, 0) end
modhelpers.playerheadnode = function(p) return posbias(playerstoodnode(p), 0, 2, 0) end
]]
-- not using these because of the potential for the player's size/cbox to change in dev MT versions
-- instead pretend the player is in the "middle" of the block stood in.
-- a possible fix here would be to inspect said properties for these values.
local playerlegnode = function(playerref)
	return pos_center_on_node(posbias(playerref:get_pos(), 0.0, 0.5, 0.0))
end
modhelpers.playerlegnode = playerlegnode



-- sanity type checking helpers
modhelpers.check = {}
local numbercheck = function(val, label, caller)
	local valtype = type(val)
	if (valtype ~= "number") then
		error(caller.."(): non-numerical value passed for "..label)
	end
end
modhelpers.check.number = numbercheck

local integercheck = function(val, label, caller)
	numbercheck(val, label, caller)
	if (val % 1.0 ~= 0.0) then
		error(caller.."(): integer value required for "..label)
	end
end
modhelpers.check.integer = integercheck

local rangecheck = function(val, lower, upper, isinteger, label, caller)
	if isinteger then integercheck(val, label, caller) else numbercheck(val, label, caller) end
	if (val < lower) or (val > upper) then
		error(caller.."(): "..label.." expected value in range "..lower.."-"..upper..", got "..val)
	end
end



-- functions to deal with param2 facedir values

-- for some reason the values that minetest.facedir_to_dir() were returning made bugger-all sense.
-- after sanity checking with the docs at least the docs matched the param2 values I got,
-- so I decided to re-implement this here.
local param2_facedir_split = function(param2)
	local caller="param2_facedir_split"
	-- integercheck(param2, "param2", caller)
	rangecheck(param2, 0, 23, true, "param2", caller)
	local axis = math.floor(param2 / 4)
	local rotation = param2 % 4
	return { axis=axis, rotation=rotation }
end
modhelpers.param2_facedir_split = param2_facedir_split
