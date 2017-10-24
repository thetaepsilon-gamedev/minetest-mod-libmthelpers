local algorithms = {}
algorithms.new = {}
local dir = _mod.moduledir

_deps.bfmap = {
	newqueue = modhelpers.datastructs.new.queue
}
local bfmap = dofile(dir.."bfmap.lua")
algorithms.new.bfmap = bfmap.new
_deps.bfmap = nil



-- an example use of the breadth-first map utility: a "node virus".
-- takes a victim node name and a replacement node.
-- vertexes are node positions, the successor function returns any neighbours which are the victim node.
-- the visitor function swaps the node with the replacement.
local centerpos = modhelpers.playerpos.center_on_node
local hasher = function(vertex) return minetest.hash_node_position(centerpos(vertex)) end

local formatvec = modhelpers.coords.format
local make_node_virus = function(initialpos, offsets, victimname, replacement, markernode, debugger, localdebugger)
	local successor = function(vertex)
		--debugger("node virus successor")
		--debugger("vertex="..formatvec(vertex))
		local results = {}
		for _, offset in ipairs(offsets) do
			local pos = vector.add(vertex, offset)
			local nodename = minetest.get_node(pos).name
			if nodename == victimname then
				table.insert(results, pos)
			else
				if localdebugger then localdebugger("REJECTED victim node, pos="..formatvec(pos).." name="..nodename) end
			end
		end
		return results
	end

	local markerfn = nil
	local testvertex = nil
	if markernode then
		markerfn = function(pos) minetest.swap_node(pos, markernode) end
	else
		-- only enable if not using a marker node
		testvertex = function(pos) return minetest.get_node(pos).name == victimname end
	end
	local visitor = function(pos) minetest.swap_node(pos, replacement) end

	return algorithms.new.bfmap(initialpos, successor, hasher, {
		visitor=visitor,
		debugger=debugger,
		markfrontier=markerfn,
		testvertex = testvertex,
	}, {
	})
end
algorithms.make_node_virus = make_node_virus

local offsets = modhelpers.coords.adjacent_offsets
--local offsets = {x=0,y=-1,z=0}
algorithms.node_virus = algorithms.node_virus = function(initialpos, victimname, replacement, markernode, debugger, localdebugger)
	return make_node_virus(initialpos, offsets, victimname, replacement, markernode, debugger, localdebugger)
end



return algorithms
