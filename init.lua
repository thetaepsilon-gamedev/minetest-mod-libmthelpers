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
local tableutils = dofile(modpath..dirpathsep.."tableutils.lua")
modhelpers.tableutils = tableutils

--player positioning helpers
modhelpers.playerpos = dofile(modpath..dirpathsep.."playerpos.lua")

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
