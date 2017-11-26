local componentbase = "com.github.thetaepsilon.minetest.libmthelpers"



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
	{ "datastructs", nil, true },
	{ "continuations" },
	{ "profiling" },
}

-- see below: a plain list of just component names
local subs = {}
for _, entry in ipairs(regtable) do
	local componentname = entry[1]
	table.insert(subs, componentname)
end

-- test usage of the modns parent-namespace helper
local master = modns.mk_parent_ns_noauto(subs, componentbase, ".")
modns.register(componentbase, master, false)
