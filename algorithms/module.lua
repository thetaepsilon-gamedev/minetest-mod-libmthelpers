local algorithms = {}
algorithms.new = {}
local dir = _mod.moduledir

local bfmap_deps = {
	new = {
		queue = modhelpers.datastructs.new.queue,
	},
	increment_counter = modhelpers.stats.increment_counter,
}
local bfmap_factory = dofile(dir.."bfmap.lua")
local bfmap = bfmap_factory(bfmap_deps)
algorithms.new.bfmap = bfmap.new

return algorithms
