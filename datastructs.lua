local datastructs = {}
local datastructs.new = {}
local datastructs.selftest = {}

-- a "set" structure.
-- allows adding objects, removing them by value, and iterating through them.
datastructs.new.set = function()
	local unique = function(val) return type(val).."!"..tostring(val) end
	local entries = {}

	-- check if an entry is present without inserting it; returns true if so.
	local test = function(v)
		local key = unique(v)
		local exists = (entries[key] ~= nil)
		return exists
	end

	return {
		-- returns true if object was added, false if duplicate insertion
		add = function(v)
			local key = unique(v)
			local isnew = (entries[key] == nil)
			if isnew then entries[key] = v end
			return isnew
		end,
		-- returns true if item was removed, false if it didn't exist
		remove = function(v)
			local didexist = test(v)
			if didexist then entries[key] = nil end
			return didexist
		end,
		ismember = test	-- see above
	}
end



local mkassert = modhelpers.check.mkassert

-- maybe I could make this runnable outside MT...
datastructs.selftest.set = function()
	-- this should shadow the lua built-in with one that has a caller name included.
	local assert = mkassert("modhelpers.datastructs.selftest.set()")
	set = datastructs.new.set()
	local t = {}

	local notexists = "object should not be considered present if not previously inserted"
	assert(not set.ismember(t), notexists)
	assert(not set.remove(t), notexists)

	assert(set.add(t), "object should be newly inserted")
	assert(set.ismember(t), "object should be member after being inserted")
	assert(set.remove(t), "object should have been removed after being inserted")
end



return datastructs
