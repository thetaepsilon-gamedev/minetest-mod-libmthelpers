local datastructs = {}
datastructs.new = {}
datastructs.selftest = {}

local moduledir = _mod.moduledir



-- FIFO queue structure
local qi = dofile(moduledir.."queue.lua")
datastructs.new.queue = qi.new

-- mutual exclusion lock.
-- used in the set structures to provide transactional batch add/removes.
local mklock = dofile(moduledir.."mutex.lua")
datastructs.new.mutex = mklock



-- a "set" structure.
-- allows adding objects, removing them by value, and iterating through them.
_deps.tableset = {}
_deps.tableset.iterators = modhelpers.iterators
local tsi = dofile(moduledir.."tableset.lua")
datastructs.tableset = tsi
-- backwards compat aliases...
datastructs.new.tableset = tsi.new
datastructs.new.generic_set = tsi.mk_generic

-- alias to old set for backwards compat...
datastructs.new.set = tsi.mk_unique



return datastructs
