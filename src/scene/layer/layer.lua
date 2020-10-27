local Class = require 'src.class'

local Layer = Class('SceneLayer')

-- Default constructor. No real behaviour
function Layer.new(inst,layerData,levelDefs,scene)
    inst.scene = scene

    -- Define basic layer properties
    inst.width = layerData.__cWid
    inst.height = layerData.__cHei
    inst.tileSize = layerData.__gridSize

    inst.offX = layerData.pxOffsetX
    inst.offY = layerData.pxOffsetY

    inst.name = layerData.__identifier
end

function Layer:update(dt)
end

function Layer:draw(dt)
end

return Layer