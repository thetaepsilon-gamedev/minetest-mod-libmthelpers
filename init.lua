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
modpath = modpath..dirpathsep
_mod.modpath = modpath



-- sub-components to register, and their origin files.
-- note that some components depend on others here,
-- accessed by using the modhelpers global.
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
	-- this module has not yet been vetted to be MT-independent.
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
	_mod.moduledir = nil
	if isdir then
		local scriptdir = modpath..scriptname..dirpathsep
		scriptpath = scriptdir.."module.lua"
		-- temporarily set module subdirectory so script can see it
		-- why is there not a way to pass arguments to dofile()!?
		_mod.moduledir = scriptdir
	else
		scriptpath = modpath..dirpathsep..scriptname..".lua"
		_mod.moduledir = modpath
	end

	local component = dofile(scriptpath)
	modhelpers[componentname] = component
	modns.register(componentbase.."."..componentname, component)
end

-- test usage of the modns parent-namespace helper
local master = modns.mk_parent_ns_noauto(subs, componentbase, ".")
modhelpers = master
modns.register(componentbase, modhelpers, false)

_mod = nil
_deps = nil
