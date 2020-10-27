local Class = require 'src.class'

local Layer = Class('SceneLayer')

-- Default constructor. No real behaviour
function Layer.new(inst,layerData,levelDefs,scene)
    inst.scene = scene
end

function Layer:update(dt)
end

function Layer:draw(dt)
end

return Layer