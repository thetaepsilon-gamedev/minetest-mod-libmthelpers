local stats={}

local nodes_by_modname = function()
	local results={}
	for key, _ in pairs(minetest.registered_nodes) do
		local start,_ = string.find(key, ":") 
		if start ~= nil then
			local modname=string.sub(key, 1, start-1)
			local currentcount=results[modname]

			if currentcount == nil then
				currentcount = 1
			else
				currentcount = currentcount + 1
			end

			results[modname] = currentcount
		end
	end
	return results
end
stats.nodes_by_modname = nodes_by_modname

local show_nodes_by_modname = function(printer)
	for name, value in pairs(nodes_by_modname()) do
		printer(name..": "..tostring(value))
	end
end
stats.show_nodes_by_modname = show_nodes_by_modname

return stats
