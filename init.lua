modhelpers = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
minetest.log("info", modname.." initialising at path "..modpath)

-- FIXME: does this change on non-unixlike targets
local dirpathsep = "/"



-- pretty-print co-ordinates
modhelpers.coords = dofile(modpath..dirpathsep.."coords.lua")

-- pretty object printing
modhelpers.prettyprint = dofile(modpath..dirpathsep.."prettyprint.lua")



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


local posbias = function(pos, x, y, z)
	return { x=pos.x + x, y=pos.y + y, z=pos.z + z}
end
modhelpers.posbias = posbias

-- flooring alone isn't appropriate when the block at X contains coords of X-1.
local pos_center_on_node = function(pos)
	return tablefilter(posbias(pos, 0.5, 0.5, 0.5), math.floor)
end
modhelpers.pos_center_on_node = pos_center_on_node

-- reverse Y correction applied above here,
-- as the player's .5 Y when standing on a block actually rounds down to what we want.
local playerstoodnode = function(playerref)
	return pos_center_on_node(posbias(playerref:get_pos(), 0.0, -0.5, 0.0))
end
modhelpers.playerstoodnode = playerstoodnode

modhelpers.getstoodnode = function(playerref)
	local pos = playerstoodnode(playerref)
	return { data = minetest.get_node(pos), pos = pos }
end



-- sanity type checking helpers
local check = dofile(modpath..dirpathsep.."checkers.lua")
modhelpers.check = check
local rangecheck = check.range



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
