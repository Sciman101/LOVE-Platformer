local Class = require 'src.class'
local Tilemap = require 'src.tilemap'

local Scene = Class('Scene')

-- Constructor
function Scene.new(inst,w,h,s,actions)
	
	inst.tilemap = Tilemap(math.ceil(w/s),math.ceil(h/s),s)
	inst.entities = {}
	inst.actions = actions
	
end

-- Add a new entity and return it's ID
function Scene:addEntity(ent)
	for i=1,#self.entities+1 do
		if self.entities[i] == nil then
			self.entities[i] = ent
			self.entities[i].scene = self
			return i
		end
	end
	return -1 -- Unable to insert entity for some reason
end

-- Get entity by id
function Scene:getEntity(id)
	if id > 0 and id <= #self.entities then
		return self.entities[id]
	end
	return nil
end

-- Remove an entity by it's id
function Scene:removeEntity(id)
	if id > 0 and id <= #self.entities then
		self.entities[id] = nil
	end
end

-- Process the scene
function Scene:update(dt)
	-- Process entities
	for i=1,#self.entities+1 do
		if self.entities[i] ~= nil then
			self.entities[i]:update(dt)
		end
	end
end

-- Draw the scene
function Scene:draw()
	if self.tilemap then self.tilemap:draw() end
	for i=1,#self.entities+1 do
		if self.entities[i] ~= nil then
			self.entities[i]:draw()
		end
	end
end

return Scene