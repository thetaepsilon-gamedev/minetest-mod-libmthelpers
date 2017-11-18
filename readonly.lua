-- modhelpers.readonly: defensive copying of objects to prevent modifications to shared objects.
-- use to clone "template objects" (such as tables of helper functions),
-- so that users of the cloned table cannot modify a shared instance of the table and therefore affect other users.

local readonly = {}
local mkfnexploder = modhelpers.check.mkfnexploder

-- used to be here, now aliased from tableutils for compatibilty
readonly.shallowcopy = modhelpers.tableutils.shallowcopy

_deps.curry = {}
_deps.curry.mkfnexploder = mkfnexploder
readonly.curry = dofile(_mod.moduledir.."partial_applicatives.lua")

return readonly
