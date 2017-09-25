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

-- facedir helpers
modhelpers.facedir = dofile(modpath..dirpathsep.."facedir.lua")
