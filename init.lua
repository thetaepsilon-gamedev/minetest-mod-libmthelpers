modhelpers = {}
_mod = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
minetest.log("info", modname.." initialising at path "..modpath)

local componentbase = "com.github.thetaepsilon.minetest.libmthelpers"

-- FIXME: does this change on non-unixlike targets
local dirpathsep = "/"

local reg = nil
if minetest.global_exists("modns") then reg = modns end

-- sub-components to register, and their origin files.
-- note that some components depend on others here,
-- accessed by using the modhelpers global.
local regtable = {
	{ "coords" },
	{ "prettyprint" },
	{ "tableutils" },
	{ "playerpos" },
	{ "check", "checkers" },	-- filename doesn't fit pattern
	{ "facedir" },
	{ "stats" },
	{ "readonly" },
	{ "iterators" },
	{ "datastructs" },
	{ "continuations" },
}

for _, entry in ipairs(regtable) do
	local componentname = entry[1]
	local scriptname = entry[2]
	local isdir = entry[3]
	scriptname = (scriptname or componentname)

	local scriptpath = ""
	if isdir then
		scriptpath = modpath..dirpathsep..scriptname..dirpathsep.."module.lua"
	else
		scriptpath = modpath..dirpathsep..scriptname..".lua"
	end

	local component = dofile(scriptpath)
	modhelpers[componentname] = component
	if reg then
		modns.register(componentbase.."."..componentname, component)
	end
end

_mod = nil
