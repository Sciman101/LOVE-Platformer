local Class = require 'src.class'
local Layer = require 'src.scene.layer.layer'

-- Define tile data layer
-- The tile data layer isn't actually rendered - it's just a grid of integers
local TileGraphicsLayer = Class('TileGraphicsLayer')
TileGraphicsLayer:extends(Layer)

-- Default constructor. No real behaviour
function TileGraphicsLayer.new(inst,layerData,layerDefs,scene)
    inst.super.new(inst,layerData,scene)

    -- Define data
    inst.width = layerData.__cWid
    inst.height = layerData.__cHei
    inst.tileSize = layerData.__gridSize

    -- Done!

end

function TileGraphicsLayer:draw(dt)
    for x=1,self.width do
        for y=1,self.height do
        end
    end
end

return TileGraphicsLayer