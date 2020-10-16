Entity = {

	-- Collision checking function
	checkTilemapMove = function(self,dx,dy)
		-- Check for collisions
		local xCol = 0
		local yCol = 0
		
		local tmap = self.scene.tilemap
		
		-- Horizontal
		if dx ~= 0 then
			local xSide = dx > 0 and self.x + self.size or self.x
			xCol = tmap:getTilePixel(xSide + dx,self.y+1)
			if xCol == 0 then xCol = tmap:getTilePixel(xSide + dx,self.y+self.size-1) end
		end
		-- Vertical
		if dy ~= 0 then
			local ySide = dy > 0 and self.y + self.size or self.y
			yCol = tmap:getTilePixel(self.x+1,ySide+dy)
			if yCol == 0 then yCol = tmap:getTilePixel(self.x+self.size-1,ySide+dy) end
		end
		
		-- Priopritize horizontal collisions
		if xCol ~= 0 then
			return xCol
		else -- If not, then return vertical collision
			return yCol
		end
	end,
	
	-- Attempt to actually move a distance
	tryMove = function(self,dx,dy)
		
		-- If we're not even moving, don't bother
		if dx == 0 and dy == 0 then return false, false end
		
		self.touching.right = false
		self.touching.left = false
		self.touching.top = false
		self.touching.bottom = false
	
		-- Move everything resting on top of us
		for i=1,#self.carrying do
			self.carrying[i]:tryMove(dx,dy)
		end
	
		-- Check for collisions
		-- Horizontal
		local colTile = self:checkTilemapMove(dx,0)
		if colTile ~= 0 then
			self.x = math.floor(self.x / self.scene.tilemap.size + 0.5) * self.scene.tilemap.size
			-- Update collision info
			self.touching.right = dx > 0
			self.touching.left = dx < 0
			dx = 0
		end
		self:onTileCollision(colTile)
		
		-- Vertical
		colTile = self:checkTilemapMove(0,dy)
		self.grounded = false
		if colTile ~= 0 then
			self.y = math.floor(self.y / self.scene.tilemap.size + 0.5) * self.scene.tilemap.size
			-- Update collision info
			self.touching.bottom = dy > 0
			self.touching.up = dy < 0
			dy = 0
		end
		self:onTileCollision(colTile)
		
		-- Check entity collisions
		for i, ent in ipairs(self.scene.entities) do
			if ent ~= self and self:overlapsEntity(ent,dx,dy) then
			
				-- Horizontal collision
				if self:overlapsEntity(ent,dx,0) then
					if not ent:push(dx,0) then
						local xs = dx > 0 and 1 or -1
						-- Nudge towards it
						while not self:overlapsEntity(ent,xs,0) do
							self.x = self.x + xs
						end
						-- Update collision info
						self.touching.right = dx > 0
						self.touching.left = dx < 0
						dx = 0
					end
				end
				
				-- Vertical collision
				if self:overlapsEntity(ent,0,dy) then
					local ys = dy > 0 and 1 or -1
					-- Nudge towards it
					while not self:overlapsEntity(ent,0,ys) do
						self.y = self.y + ys
					end
					-- Update collision info
					self.touching.bottom = dy > 0
					self.touching.up = dy < 0
					
					-- Are we on something?
					if self.touching.bottom then
						if self.floor ~= ent then
							self:removeFromFloor()
							-- We're on top of something now
							self.floor = ent
							-- Add to list
							table.insert(self.floor.carrying,self)
						end
					end
					
					dy = 0
				end
			
			end
		end
		
		-- Actually move
		self.x = self.x + dx
		self.y = self.y + dy
		
		-- Returns if we were able to move in the specified direction
		return dx ~= 0, dy ~= 0
	
	end,
	
	removeFromFloor = function(self)
		if self.floor ~= nil then
			-- Remove us from the floor's carrying list
			for i=1,#self.floor.carrying do
				if self.floor.carrying[i] == self then
					table.remove(self.floor.carrying,i)
					break
				end
			end
		end
	end,
	
	-- Main update loop
	update = function(self,dt)
	
		self.vy = self.vy + self.gravity * dt
		
		-- Friction
		if self.grounded then
			self.vx = self.vx - self.vx * dt * self.fric
			if math.abs(self.vx) <= dt then self.vx = 0 end
		end
	
		-- Attempt to move
		local xPass, yPass = self:tryMove(self.vx * dt, self.vy * dt)
		if not xPass then self.vx = 0 end
		if not yPass then self.vy = 0 end
		
		-- Update grounded state
		self.grounded = self.touching.bottom
		
		-- Update grounded state
		if self.grounded and not self.wasGrounded then
			self:onGroundedStateChange(true)
		elseif not self.grounded and self.wasGrounded then
			self:onGroundedStateChange(false)
			self:removeFromFloor()
		end
		
		-- Update past grounded
		self.wasGrounded = self.grounded
	
	end,
	
	-- Attempt to be pushed
	push = function(self,dx,dy)
		-- Attempt to move in the direction specified
		local xPass, yPass = self:tryMove(dx,dy)
		-- Return whether we moved successfully
		return (xPass or dx == 0) and (yPass or dy == 0)
	end,
	
	-- Check if we overlap another entity
	overlapsEntity = function(self,other,x,y)
		x = x or 0
		y = y or 0
		return (self.x+x < other.x + other.size and other.x < self.x+self.size+x and self.y+y < other.y+other.size and other.y < self.y+self.size+y)
	end,
	
	-- Called when we hit a tile
	onTileCollision = function(self,tile)
		-- By default, do nothing
	end,
	
	-- Called when our grounded state changed
	onGroundedStateChange = function(self, state)
		-- true - we just landed
		-- false - we just left the ground
	end,
	
	-- Drawing function
	draw = function(self)
		local px = self.x
		local py = self.y
		if self.flipX then px = px + self.size end
		if self.flipY then py = py + self.size end
		love.graphics.draw(self.sprite,px,py,0,self.flipX and -1 or 1,self.flipY and -1 or 1)
	end
}
Entity.__index = Entity

-- Constructor
function Entity:new(x,y,size,sprite)
	local ent = setmetatable({},Entity)
	
	-- Position/velocity
	ent.x = x or 0
	ent.y = y or 0
	ent.vx = 0
	ent.vy = 0
	-- Physical properties
	ent.size = size or 16
	ent.gravity = 600
	ent.fric = 2
	ent.touching = {right=false,left=false,top=false,bottom=false}
	ent.grounded = false
	ent.wasGrounded = false
	-- Visuals
	ent.sprite = sprite
	ent.flipX = false
	ent.flipY = false
	-- Reference to game logic
	ent.scene = nil
	-- Stacking
	ent.carrying = {} -- What's on top of us
	ent.floor = nil -- What's below us
	
	return ent
end