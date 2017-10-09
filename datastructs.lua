local datastructs = {}
datastructs.new = {}
datastructs.selftest = {}

local mkiterator = modhelpers.iterators.mkiterator

local iterate_values_co = function(t) for _, v in pairs(t) do coroutine.yield(v) end end

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
			if didexist then entries[unique(v)] = nil end
			return didexist
		end,
		ismember = test, -- see above
		iterator = function()
			return mkiterator(iterate_values_co, entries)
		end,
	}
end



local mkassert = modhelpers.check.mkassert
local listequal = modhelpers.check.listequaltest

local collect_iterator = function(it, results)
	while true do
		local result = it()
		if result ~= nil then
			table.insert(results, result)
		else
			break
		end
	end
end

local collect_set = function(set)
	local results = {}
	collect_iterator(set.iterator(), results)
	return results
end

-- maybe I could make this runnable outside MT...
datastructs.selftest.set = function()
	-- this should shadow the lua built-in with one that has a caller name included.
	local name = "modhelpers.datastructs.selftest.set()"
	local assert = mkassert(name)
	local set = datastructs.new.set()
	local t = {}
	local collected = nil

	assert(#collect_set(set) == 0, "new set should return zero elements")

	local notexists = "object should not be considered present if not previously inserted"
	assert(not set.ismember(t), notexists)
	assert(not set.remove(t), notexists)

	assert(set.add(t), "object should be newly inserted")
	assert(set.ismember(t), "object should be member after being inserted")
	collected = collect_set(set)
	assert(#collected == 1, "set should return one element after insertion")
	assert(collected[1] == t, "sole item of set should be the inserted element")
	assert(set.remove(t), "object should have been removed after being inserted")
	assert(#collect_set(set) == 0, "set should return zero elements after removal")

	local oldelement = "item should not be present if added then removed"
	assert(not set.remove(t), oldelement)
	assert(not set.ismember(t), oldelement)

	local newelement = "set should be able to accept a new element"
	assert(set.add(1), newelement)
	assert(set.add(2), newelement)
	assert(set.add(3), newelement)
	assert(#collect_set(set) == 3, "set should contain three elements after three insertions")
	assert(set.remove(2), "object should have been removed")
	assert(#collect_set(set) == 2, "set should contain two elements after three insertions and one removal")

	assert(not set.remove(4), notexists)
	assert(not set.ismember(4), notexists)

	return name.." self-tests completed"
end



return datastructs
