local Class = require 'src.class'
local Tilemap = require 'src.tilemap'
local json = require 'src.thirdparty.json'

local Scene = Class('Scene')

-- Define layer classes to use with LEd layer types
local LAYER_TYPES = {
	IntGrid = require 'src.scene.layer.tileDataLayer',
	Tiles = require 'src.scene.layer.tileGraphicsLayer',
	AutoLayer = require 'src.scene.layer.tileGraphicsLayer',
	Entities = require 'src.scene.layer.entityLayer'
}

-- Constructor
function Scene.new(inst,path,identifier)

	inst.layers = {}
	inst.width = nil
	inst.height = nil
	inst.sceneName = "Unloaded Scene"

	-- Try and load file
	local sceneFile = love.filesystem.newFile(path)

	local ok, err = sceneFile:open('r')
	if ok then

		-- Read file into JSON
		local sceneJson, size = sceneFile:read()
		sceneFile:close() -- No longer need that
		-- Decode raw string into JSON
		local sceneData = json.decode(sceneJson)

		-- Find the level
		local levelFound = false
		for k,level in pairs(sceneData.levels) do
			if level.identifier == identifier then
				inst:loadLEdTable(level,sceneData.defs)
				levelFound = true
				return
			end
		end
	
		if not levelFound then
			Console.error("Level " .. identifier .. " not present in " .. path)
		end

	else
		Console.error(err)
	end
end

-- Load scene from table
function Scene:loadLEdTable(level,defs)

	-- Get some data on the scene
	self.width = level.pxWid
	self.height = level.pxHei
	self.sceneName = level.identifier

	-- Iterate over layers
	for i, layer in ipairs(level.layerInstances) do

		-- Add layer
		local layerType = layer.__type
		if LAYER_TYPES[layerType] then
			-- Create layer
			local layerInst = LAYER_TYPES[layerType](layer,defs,self)
			table.insert(self.layers,layerInst)
		else
			Console.error("Unknown layer type " .. layerType)
		end

	end

	Console.log("Loaded scene '" .. level.identifier .. "'")

end

-- Process the scene
function Scene:update(dt)
end

-- Draw the scene
function Scene:draw()
	-- Draw layers
	for i, layer in ipairs(self.layers) do
		layer:draw()
	end
end

return Scene