local qi = dofile("queue.lua")

local queue = qi.new()
assert(queue.size() == 0, "queue should have size zero when new")

local items = { 1, 34, 453, 6 }

local testordering = function(items)
	local total = #items
	for index, item in ipairs(items) do
		queue.enqueue(item)
		assert(queue.size() == index, "queue should have size "..tostring(index).." after inserting that many items")
	end
	for index, expected in ipairs(items) do
		local actual = queue.next()
		assert(expected == actual, "queue should return objects in order of insertion")
		local expectedsize = (total - index)
		assert(queue.size() == expectedsize, "queue should have size "..tostring(expectedsize).." after "..tostring(total).." removals and "..tostring(index).."removals")
	end
end
testordering(items)

-- can't hurt to spam it... right?
for i = 1, 100, 1 do
	local result = queue.next()
	assert(result == nil, "empty run #"..tostring(i)..": empty queue should return nil")
	assert(queue.size() == 0, "empty queue should have zero size")
end

testordering({45, 5656, 4, 567, 564})

print("queue tests completed")
