local stats={}

local node_modname = function(key, value)
	local start,_ = string.find(key, ":")
	-- if no colon found, it's probably air, which doesn't really belong to a mod.
	if start ~= nil then
		return string.sub(key, 1, start-1)
	else
		return nil
	end
end



local count_buckets = function(input, bucketfunc)
	local results={}
	local total = 0
	local total_with_nobucket = 0

	for key, value in pairs(input) do
		total_with_nobucket = total_with_nobucket + 1
		local bucket = bucketfunc(key, value)

		if bucket ~= nil then
			total = total + 1
			local currentcount=results[bucket]

			if currentcount == nil then
				currentcount = 1
			else
				currentcount = currentcount + 1
			end

			results[bucket] = currentcount
		end
	end

	return results, { count=total, with_nobucket=total_with_nobucket}
end
stats.count_buckets = count_buckets



local nodes_by_modname = function()
	return count_buckets(minetest.registered_nodes, node_modname)
end
stats.nodes_by_modname = nodes_by_modname

local show_nodes_by_modname = function(printer)
	local results, totals = nodes_by_modname()
	for name, value in pairs(results) do
		printer(name..": "..tostring(value))
	end
	printer("-- total nodes: "..totals.count)
	printer("-- total nodes including nodes without a mod: "..totals.with_nobucket)
end
stats.show_nodes_by_modname = show_nodes_by_modname

return stats
