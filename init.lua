modhelpers = {}
_mod = {}
-- dependencies table for passing in needed objects to sub-modules
_deps = {}

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
	-- this module sits in a subdirectory due to the length of code
	{ "datastructs", nil, true },
	{ "continuations" },
}

for _, entry in ipairs(regtable) do
	local componentname = entry[1]
	local scriptname = entry[2]
	local isdir = entry[3]
	scriptname = (scriptname or componentname)

	local scriptpath = ""
	_mod.moduledir = nil
	if isdir then
		local scriptdir = modpath..dirpathsep..scriptname..dirpathsep
		scriptpath = scriptdir.."module.lua"
		-- temporarily set module subdirectory so script can see it
		-- why is there not a way to pass arguments to dofile()!?
		_mod.moduledir = scriptdir
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
_deps = nil
