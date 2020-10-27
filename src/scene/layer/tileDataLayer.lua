local Class = require 'src.class'
local Layer = require 'src.scene.layer.layer'

-- Define tile data layer
-- The tile data layer isn't actually rendered - it's just a grid of integers
local TileDataLayer = Class('TileDataLayer')
TileDataLayer:extends(Layer)

-- Default constructor. No real behaviour
function TileDataLayer.new(inst,layerData,scene)
    inst.super.new(inst,layerData,scene)

    -- Define data
    inst.data = {}
    inst.width = layerData.__cWid
    inst.height = layerData.__cHei
    inst.tileSize = layerData.__gridSize

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

    -- Done!

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
	local tileX = math.floor(x / self.tileSize) + 1
	local tileY = math.floor(y / self.tileSize) + 1
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
	local tileX = math.floor(x / self.tileSize) + 1
	local tileY = math.floor(y / self.tileSize) + 1
	self:setTile(tileX,tileY,tile,update)
end

function TileDataLayer:draw(dt)
    -- DEBUG DRAW
    for x=1,self.width do
        for y=1,self.height do
            if self:getTile(x,y) >= 0 then
                love.graphics.rectangle('line',(x-1)*self.tileSize,(y-1)*self.tileSize,self.tileSize,self.tileSize)
            end
        end
    end
end

return TileDataLayer