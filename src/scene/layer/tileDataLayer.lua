local Class = require 'src.class'
local TileGraphicsLayer = require 'src.scene.layer.tileGraphicsLayer'

-- Define tile data layer
-- The tile data layer isn't rendered by default, and only holds a grid of integers used for collision
-- checking or other purposes
-- UNLESS the autotile rules are defined
local TileDataLayer = Class('TileDataLayer')
TileDataLayer:extends(TileGraphicsLayer)

-- Default constructor. No real behaviour
function TileDataLayer.new(inst,layerData,levelDefs,scene)
    TileGraphicsLayer.new(inst,layerData,levelDefs,scene)

    -- Define data
    inst.data = {}

    -- Populate data table with -1 values
    for x=1,inst.width do
        for y=1,inst.height do
            inst.data[(y-1)*inst.width+x] = -1
        end
    end
    -- Add relevant tiles
    local count = 0
    for i, tile in ipairs(layerData.intGrid) do
        inst.data[tile.coordId+1] = tile.v
        count = count + 1
    end

end

-- Ensure a tile position is within bounds
function TileDataLayer:verifyTilePos(x,y)
    return x > 0 and y > 0 and x <= self.width and y <= self.height
end

-- Get the integer id of a tile at a position
function TileDataLayer:getTile(x,y)
    if self:verifyTilePos(x,y) then
        -- Grab tile data
        return self.data[(y-1)*self.width+x]
    else
        -- whereas -1 is just 'empty space', -2 means 'out of bounds'
        return -2
    end
end

-- Get a tile via pixel position
function TileDataLayer:getTilePixel(x,y)
	local tileX = math.floor((x-self.offX) / self.tileSize) + 1
	local tileY = math.floor((y-self.offY) / self.tileSize) + 1
	return self:getTile(tileX,tileY)
end

-- Set the integer id of a tile at a position
function TileDataLayer:setTile(x,y,id)
    if self:verifyTilePos(x,y) and id > -2 then
        -- Set tile data
        self.data[(y-1)*self.width+x] = id
    end
end

-- Set a tile via pixel position
function TileDataLayer:setTilePixel(x,y,tile,update)
	local tileX = math.floor((x-self.offX) / self.tileSize) + 1
	local tileY = math.floor((y-self.offY) / self.tileSize) + 1
	self:setTile(tileX,tileY,tile,update)
end

return TileDataLayer