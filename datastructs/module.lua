local datastructs = {}
datastructs.new = {}
datastructs.selftest = {}

local moduledir = _mod.moduledir



-- FIFO queue structure
local qi = dofile(moduledir.."queue.lua")
datastructs.new.queue = qi.new



-- a "set" structure.
-- allows adding objects, removing them by value, and iterating through them.
_deps.tableset = {}
_deps.tableset.iterators = modhelpers.iterators
local tsi = dofile(moduledir.."tableset.lua")
datastructs.new.tableset = tsi.new

-- alias to old set for backwards compat...
datastructs.new.set = tsi.mk_unique



return datastructs
