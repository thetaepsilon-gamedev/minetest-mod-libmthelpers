local interface = {}

local iterators = _deps.tableset.iterators
local mk_value_iterator = iterators.mk_value_iterator

-- generic table which takes a "hash function" to calculate keys.
-- the hash function is expected to produce a "compare equal" quality:
-- for the same value, the hash result must be the same.
-- two values which are considered equal for this hasher
-- (but do not compare directly, e.g. coordinate tables with the same values but different addresses)
-- must also map to the same hash value.
local mk_generic = function(hasher)
	local entries = {}
	local size = 0

	-- check if an entry is present without inserting it; returns true if so.
	local test = function(v)
		local exists = (entries[hasher(v)] ~= nil)
		return exists
	end

	local interface = {}

	-- returns true if object was added, false if duplicate insertion
	interface.add = function(v)
		local hash = hasher(v)
		local isnew = (entries[hash] == nil)
		if isnew then
			entries[hash] = v
			size = size + 1
		end
		return isnew
	end

	-- returns true if item was removed, false if it didn't exist
	interface.remove = function(v)
		local hash = hasher(v)
		local didexist = (entries[hash] ~= nil)
		if didexist then
			entries[hash] = nil
			size = size - 1
		end
		return didexist
	end

	interface.ismember = test -- see above

	interface.size = function()
		return size
	end

	interface.iterator = function()
		return mk_value_iterator(entries)
	end
	
	return interface
end
interface.mk_generic = mk_generic

-- simplified version of the set data structure for working with table or userdata handles;
-- it is assumed that inserted values do not alias inside the table (think 0 and "0").
-- hasher is a no-op and passes keys directly to the table to let it do hashing on values internally.
interface.new = function()
	return mk_generic(function(v) return v end)
end

return interface
