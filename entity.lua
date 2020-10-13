Entity = {

	-- Collision checking function
	checkMove = function(self,dx,dy)
		-- Check for collisions
		local xCol = 0
		local yCol = 0
		-- Horizontal
		if dx ~= 0 then
			local xSide = dx > 0 and self.x + self.size or self.x
			xCol = self.tilemap:getTilePixel(xSide + dx,self.y+1)
			if xCol == 0 then xCol = self.tilemap:getTilePixel(xSide + dx,self.y+self.size-1) end
		end
		-- Vertical
		if dy ~= 0 then
			local ySide = dy > 0 and self.y + self.size or self.y
			yCol = self.tilemap:getTilePixel(self.x+1,ySide+dy)
			if yCol == 0 then yCol = self.tilemap:getTilePixel(self.x+self.size-1,ySide+dy) end
		end
		
		-- Priopritize horizontal collisions
		if xCol ~= 0 then
			return xCol
		else -- If not, then return vertical collision
			return yCol
		end
	end,
	
	-- Main update loop
	update = function(self,dt)
	
		self.vy = self.vy + self.gravity * dt
	
		-- Check for collisions
		-- Horizontal
		local colTile = self:checkMove(self.vx * dt,0)
		if colTile ~= 0 then
			self.x = math.floor(self.x / self.tilemap.size + 0.5) * self.tilemap.size
			self.vx = 0
		end
		self.x = self.x + self.vx * dt
		self:onTileCollision(colTile)
		
		-- Vertical
		colTile = self:checkMove(0,self.vy * dt)
		self.grounded = false
		if colTile ~= 0 then
			self.y = math.floor(self.y / self.tilemap.size + 0.5) * self.tilemap.size
			self.grounded = self.vy > 0
			self.vy = 0
		end	
		self.y = self.y + self.vy * dt
		self:onTileCollision(colTile)
		
		
		-- Update past grounded
		self.wasGrounded = self.grounded
	
	end,
	
	-- Called when we hit a tile
	onTileCollision = function(self,tile)
		-- By default, do nothing
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
function Entity:new(x,y,size,sprite,tilemap)
	local ent = setmetatable({},Entity)
	
	-- Position/velocity
	ent.x = x or 0
	ent.y = y or 0
	ent.vx = 0
	ent.vy = 0
	-- Physical properties
	ent.size = size or 16
	ent.gravity = 500
	ent.fric = 20
	ent.grounded = false
	ent.wasGrounded = false
	-- Visuals
	ent.sprite = sprite
	ent.flipX = false
	ent.flipY = false
	-- Reference to game logic
	ent.tilemap = tilemap
	
	return ent
end