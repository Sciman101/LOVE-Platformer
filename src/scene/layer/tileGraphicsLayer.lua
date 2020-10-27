local Class = require 'src.class'
local Layer = require 'src.scene.layer.layer'

-- Define tile graphics layer
-- This layer doesnt do collision checking and is soley responsible for rendering a level's tiles
-- to the screen
local TileGraphicsLayer = Class('TileGraphicsLayer')
TileGraphicsLayer:extends(Layer)

-- Default constructor. No real behaviour
function TileGraphicsLayer.new(inst,layerData,levelDefs,scene)
    Layer.new(inst,layerData,levelDef,scene)

    -- Tile drawing
    inst.gfxData = {}
    inst.tileSet = nil
    inst.gfxCanvas = nil

     -- Check for gridTiles            or autoLayerTiles
    if #layerData.gridTiles > 0 or #layerData.autoLayerTiles > 0 then
        inst.gfxCanvas = love.graphics.newCanvas(inst.width*inst.tileSize,inst.height*inst.tileSize)
        inst.gfxData = layerData.gridTiles
        if #inst.gfxData <= 0 then inst.gfxData = layerData.autoLayerTiles end
        -- Find tileset
        -- First, find layer definition
        local tilesetUid = nil
        for i, layerDef in ipairs(levelDefs.layers) do
            if layerDef.identifier == layerData.__identifier then
                tilesetUid = layerDef.autoTilesetDefUid or layerDef.tilesetUid
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
        else
            print('Error loading tileset')
        end
    end

end

-- Redraw the GFX canvas
function TileGraphicsLayer:redrawGfxCanvas()
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
function TileGraphicsLayer:draw(dt)
    if self.gfxCanvas then
        love.graphics.draw(self.gfxCanvas,self.offX,self.offY)
    end
end

return TileGraphicsLayer