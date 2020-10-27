local Class = require 'src.class'
local SceneLayer = require 'src.scene.layer.layer'

-- Define entity holding layer
local EntityLayer = Class('TileDataLayer')
EntityLayer:extends(TileGraphicsLayer)

-- Default constructor. No real behaviour
function EntityLayer.new(inst,layerData,levelDefs,scene)
    SceneLayer.new(inst,layerData,levelDefs,scene)
    -- TODO implement entity layer
end

function EntityLayer:update(dt)
end

function EntityLayer:draw(dt)
end

return EntityLayer