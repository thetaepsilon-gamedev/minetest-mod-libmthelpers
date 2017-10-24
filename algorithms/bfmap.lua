-- abstract breadth-first graph mapping.
-- unlike a breadth-first *search* which terminates when finding a success state,
-- this algorithm attempts to exhaustively map a graph of connected neighbours (up to a limit).
-- otherwise though this is as generic as the algorithm example found on wikipedia.
local newqueue = _deps.bfmap.newqueue

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
	new = function(initial, successor, hasher)
		-- not implemented...
		error("bfmap.new() not yet implemented!")
	end
}
