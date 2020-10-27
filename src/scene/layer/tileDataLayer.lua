local Class = require 'src.class'
local Layer = require 'src.scene.layer.layer'

-- Define tile data layer
-- The tile data layer isn't actually rendered - it's just a grid of integers
-- UNLESS the autotile rules are defined
local TileDataLayer = Class('TileDataLayer')
TileDataLayer:extends(Layer)

-- Default constructor. No real behaviour
function TileDataLayer.new(inst,layerData,levelDefs,scene)
    inst.super.new(inst,layerData,scene)

    -- Define data
    inst.data = {}
    inst.width = layerData.__cWid
    inst.height = layerData.__cHei
    inst.tileSize = layerData.__gridSize

    inst.offX = layerData.pxOffsetX
    inst.offY = layerData.pxOffsetY

    -- Autotile drawing
    inst.gfxData = {}
    inst.tileSet = nil
    inst.gfxCanvas = nil

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

    -- Check for autoLayerTiles
    if #layerData.autoLayerTiles then
        inst.gfxCanvas = love.graphics.newCanvas(inst.width*inst.tileSize,inst.height*inst.tileSize)
        inst.gfxData = layerData.autoLayerTiles
        -- Find tileset
        -- First, find layer definition
        local tilesetUid = nil
        for i, layerDef in ipairs(levelDefs.layers) do
            if layerDef.identifier == layerData.__identifier then
                tilesetUid = layerDef.autoTilesetDefUid
                break
            end
        end
        -- Once we have the tileset Uid, find the tileset
        if tilesetUid then
            for i, tileset in ipairs(levelDefs.tilesets) do
                if tileset.uid == tilesetUid then
                    -- Load tileset image
                    -- This assumes scenes are held in /assets/scenes and tileset graphics somewhere in /assets/textures
                    local path, count = string.gsub(tileset.relPath,'%.%.','assets')
                    inst.tileSet = love.graphics.newImage(path)
                    break
                end
            end
        end
        -- Did we find a tileset?
        if inst.tileSet then
            print('Successfully loaded tileset!')
            inst:redrawGfxCanvas()
        end
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

-- Redraw the GFX canvas
function TileDataLayer:redrawGfxCanvas()
    if self.gfxCanvas then
        -- Set canvas target
        love.graphics.setCanvas(self.gfxCanvas)
        love.graphics.clear()

        -- Draw all tiles
        for i, tile in ipairs(self.gfxData) do
            -- Define quad to draw portion of tileset
            local quad = love.graphics.newQuad(tile.src[1],tile.src[2],self.tileSize,self.tileSize,self.tileSet:getDimensions())
            love.graphics.draw(self.tileSet,quad,tile.px[1],tile.px[2])
            -- Free the quad
            quad:release()
        end
        -- Reset canvas
        love.graphics.setCanvas()
    end
end

-- Draw graphics if we have them
function TileDataLayer:draw(dt)
    if self.gfxCanvas then
        love.graphics.draw(self.gfxCanvas,self.offX,self.offY)
    end
end

return TileDataLayer