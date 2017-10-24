local algorithms = {}
algorithms.new = {}
local dir = _mod.moduledir

_deps.bfmap = {
	newqueue = modhelpers.datastructs.new.queue
}
local bfmap = dofile(dir.."bfmap.lua")
algorithms.new.bfmap = bfmap.new
_deps.bfmap = nil

return algorithms
