-- abstract breadth-first graph mapping.
-- unlike a breadth-first *search* which terminates when finding a success state,
-- this algorithm attempts to exhaustively map a graph of connected neighbours (up to a limit).
-- otherwise though this is as generic as the algorithm example found on wikipedia.
local newqueue = _deps.bfmap.newqueue

local checkfn = function(f, label, callername)
	if type(f) ~= "function" then
		error(callername..label.." expected to be a function, got "..tostring(f))
	end
end

local dname_new = "bfmap.new() "
-- helpers for callbacks in the code below.
-- returns default stub implementations so the code doesn't have to go "if callback ..." all the time.
-- I wonder if luaJIT can optimise these out when encountered...
local stub = function()
end
local passthrough = function(vertex)
	return true
end
local callback_or_missing = function(t, key, default)
	local fn = t[key]
	if fn ~= nil then
		checkfn(fn, "callback "..key, dname_new)
		return fn
	else
		return default
	end
end

return {
	-- set up the initial state of the search.
	-- requires an initial graph vertex and a successor function.
	-- the successor function understands how to interpret the vertex data structure.
	-- the successor function, when invoked with a vertex as it's sole argument,
	-- must return the vertexes connected to the provided one.
	-- the successor is allowed to return the previously visited node just fine,
	-- as the algorithm checks for already visited nodes anyway.
	-- hasher must return a unique string representation of a vertex.
	-- hash collisions will result in a vertex being incorrectly skipped.
	-- supported callbacks:
	--	testvertex: additional test stage when frontier is popped from queue.
	--	if it returns false the frontier vertex is simply discarded.
	--	visitor: called when vertex is added to the visited list.
	-- if initial is nil, advance() below is guaranteed to return false on first invocation.
	new = function(initial, successor, hasher, callbacks)
		-- note that queues reject nil items,
		-- so if initial is nil the queue will be empty.
		-- this gives us the behaviour for advance() as stated above.
		checkfn(successor, "successor", dname_new)
		checkfn(hasher, "hasher", dname_new)

		if (callbacks ~= nil) then
			if type(callbacks) ~= "table" then
				error(dname_new.."callbacks expected to be nil or a table")
			end
		else
			callbacks = {}
		end
		local testvertex = callback_or_missing(callbacks, "testvertex", passthrough)
		local visitor = callback_or_missing(callbacks, "visitor", stub)

		-- now onto the actual algorith data/code
		local self = {
			-- frontier list.
			-- will be checked in FIFO order as discovered when advanced.
			frontiers = newqueue(),
			-- discovered node list, hashed by the hasher function.
			-- already-visited nodes are checked for in successor vertexes.
			visited = {},
		}
		-- add initial vertex to start off process
		self.frontiers.enqueue(initial)
		local interface = {
			advance = function()
				local frontier = self.frontiers.next()
				-- if the frontier list is empty, we're done.
				if frontier == nil then return false end

				if testvertex(frontier) then
					-- get successors of this vertex
					local successors = successor(frontier)
					-- check each result, and insert into frontiers if not already visited
					for index, vertex in ipairs(successors) do
						local hash = hasher(vertex)
						if not self.visited[hash] then
							self.frontiers.enqueue(vertex)
						end
					end
					-- mark this node visited
					visitor(frontier)
					self.visited[hasher(frontier)] = true
				end

				return true
			end
		}
		return interface
	end
}
