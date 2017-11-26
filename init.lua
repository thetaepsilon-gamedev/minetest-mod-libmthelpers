local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local componentbase = "com.github.thetaepsilon.minetest.libmthelpers"

-- FIXME: does this change on non-unixlike targets
local dirpathsep = "/"
modpath = modpath..dirpathsep



-- sub-components to register, and their origin files.
local regtable = {
	-- except where noted, all of the below are portable and can be loaded outside MT.
	{ "prettyprint" },
	{ "iterators" },
	{ "tableutils" },
	{ "coords" },
	-- portable, though stoodnode expects the interface of an objectref.
	{ "playerpos" },
	{ "check", "checkers" },	-- filename doesn't fit pattern
	{ "facedir" },
	{ "stats" },
	{ "readonly" },
	-- this module sits in a subdirectory due to the length of code
	{ "datastructs", nil, true },
	{ "continuations" },
	{ "profiling" },
}

-- see below: a plain list of just component names
local subs = {}
for _, entry in ipairs(regtable) do
	local componentname = entry[1]
	table.insert(subs, componentname)
	local scriptname = entry[2]
	local isdir = entry[3]
	scriptname = (scriptname or componentname)

	local scriptpath = ""
	if isdir then
		local scriptdir = modpath..scriptname..dirpathsep
		scriptpath = scriptdir.."module.lua"
	else
		scriptpath = modpath..dirpathsep..scriptname..".lua"
	end

	local component = dofile(scriptpath)
	modns.register(componentbase.."."..componentname, component)
end

-- test usage of the modns parent-namespace helper
local master = modns.mk_parent_ns_noauto(subs, componentbase, ".")
modns.register(componentbase, master, false)
