local playerpos = {}



local posbias = function(pos, x, y, z)
	return { x=pos.x + x, y=pos.y + y, z=pos.z + z}
end
playerpos.bias = posbias



-- flooring alone isn't appropriate when the block at X contains coords of X-1.
local tablefilter = modhelpers.tableutils.filter

local pos_center_on_node = function(pos)
	return tablefilter(posbias(pos, 0.5, 0.5, 0.5), math.floor)
end
playerpos.center_on_node = pos_center_on_node



-- reverse the Y correction applied above here,
-- as the player's .5 Y when standing on a block actually rounds down to what we want.
local playerstoodnode = function(playerref)
	return pos_center_on_node(posbias(playerref:get_pos(), 0.0, -0.5, 0.0))
end
playerpos.stoodnode = playerstoodnode



playerpos.getstoodnode = function(playerref)
	local pos = playerstoodnode(playerref)
	return { data = minetest.get_node(pos), pos = pos }
end



playerpos.getstoodmeta = function(playerref)
	local pos = playerstoodnode(playerref)
	return minetest.get_meta(pos):to_table().fields
end



return playerpos
