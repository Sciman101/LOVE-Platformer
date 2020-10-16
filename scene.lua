Scene = {

	-- Add a new entity and return it's ID
	addEntity = function(self,ent)
		for i=1,#self.entities+1 do
			if self.entities[i] == nil then
				self.entities[i] = ent
				self.entities[i].scene = self
				return i
			end
		end
		return -1 -- Unable to insert entity for some reason
	end,
	
	-- Get entity by id
	getEntity = function(self,id)
		if id > 0 and id <= #self.entities then
			return self.entities[id]
		end
		return nil
	end,
	
	-- Remove an entity by it's id
	removeEntity = function(self,id)
		if id > 0 and id <= #self.entities then
			self.entities[id] = nil
		end
	end,
	
	-- Process the scene
	update = function(self,dt)
		-- Process entities
		for i=1,#self.entities+1 do
			if self.entities[i] ~= nil then
				self.entities[i]:update(dt)
			end
		end
	end,
	
	-- Draw the scene
	draw = function(self)
		if self.tilemap then self.tilemap:draw() end
		for i=1,#self.entities+1 do
			if self.entities[i] ~= nil then
				self.entities[i]:draw()
			end
		end
	end

}
Scene.__index = Scene

-- Constructor
function Scene:new()
	local scene = setmetatable({},Scene)
	
	scene.tilemap = nil
	scene.entities = {}
	
	return scene
end