Entity = {

	prototype = { -- Prototype instance
		-- Position/velocity
		x = 0,
		y = 0,
		vx = 0,
		vy = 0,
		-- Physical properties
		size = 16,
		gravity = 500,
		fric = 20,
		grounded = false,
		wasGrounded = false,
		-- Visuals
		sprite = nil,
		flipX = false,
		flipY = false,
		-- Reference to game logic
		tilemap = nil
	},
	
	__index = Entity.prototype,
	__metatable = nil,
	
	-- Constructor
	new = function(self,x,y,tilemap,size,sprite)
		local ent = {x=x,y=y,tilemap=tilemap,size=size,sprite=sprite}
		setmetatable(ent,Entity)
		return ent
	end,
	
	-- Collision checking function
	checkMove = function(self,dx,dy)
		-- Check for collisions
		local xCol = 0
		local yCol = 0
		-- Horizontal
		if dx ~= 0 then
			local xSide = dx > 0 and self.x + self.size or self.x
			xCol = self.tilemap:checkPixel(xSide + dx,self.y+1)
			if xCol == 0 then xCol = self.tilemap:checkPixel(xSide + dx,self.y+self.size-1) end
		end
		-- Vertical
		if dy ~= 0 then
			local ySide = dy > 0 and self.y + self.size or self.y
			yCol = self.tilemap:checkPixel(self.x+1,ySide+dy)
			if yCol == 0 then yCol = self.tilemap:checkPixel(self.x+self.size-1,ySide+dy) end
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
		
		-- Vertical
		colTile = self:checkMove(0,self.vy * dt)
		self.grounded = false
		if colTile ~= 0 then
			self.y = math.floor(self.y / self.tilemap.size + 0.5) * self.tilemap.size
			self.grounded = self.vy > 0
			self.vy = 0
		end	
		self.y = self.y + self.vy * dt
		
		
		-- Coyote time
		if self.coyoteTime > 0 then
			self.coyoteTime = self.coyoteTime - dt
		elseif self.wasGrounded and not self.grounded then
			self.coyoteTime = 0.05
		end
		
		-- Update past grounded
		self.wasGrounded = self.grounded
	
	end,
	
	-- Drawing function
	draw = function(self)
		local px = self.x
		local py = self.y
		if self.flipX then px = px + self.size end
		if self.flipY then py = py + self.size end
		love.graphics.draw(self.sprite,px,py,0,self.facing,self.flipX and 1 or -1,self.flipY and 1 or -1)
	end
	

}