local interface = {}

-- simplified version of the set data structure for working with table or userdata handles;
-- it is assumed that inserted values do not alias inside the table (think 0 and "0").
local new = function()
	local entries = {}
	local size = 0

	-- check if an entry is present without inserting it; returns true if so.
	local test = function(v)
		local exists = (entries[v] ~= nil)
		return exists
	end

	local interface = {}

	-- returns true if object was added, false if duplicate insertion
	interface.add = function(v)
		local isnew = (entries[v] == nil)
		if isnew then
			entries[v] = v
			size = size + 1
		end
		return isnew
	end

	-- returns true if item was removed, false if it didn't exist
	interface.remove = function(v)
		local didexist = test(v)
		if didexist then
			entries[v] = nil
			size = size - 1
		end
		return didexist
	end

	interface.ismember = test -- see above

	interface.size = function()
		return size
	end
	
	return interface
end
interface.new = new

return interface
