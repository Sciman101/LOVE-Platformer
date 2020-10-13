local canvas
local keys = {}
local keys_prev = {}

local debugInfo = false

-- Define tile drawing nonsense
tilemap = {
	data = {},
	tiles = {},
	width = 40,
	height = 23,
	size = 16,
	canvas = nil
}
-- Define tilemap functions
function tilemap:setup(w,h,s)
	self.width = w
	self.height = h or w
	self.size = s or 16
	self.canvas = love.graphics.newCanvas(self.width * self.size,self.height * self.size)
end
function tilemap:redraw()
	love.graphics.setCanvas(tilemap.canvas)
	love.graphics.clear(0,0,0,0)
	local t = 0
	for x=1, self.width do
		for y=1, self.height do
			t = self.data[x][y]
			if t ~= 0 then love.graphics.draw(self.tiles[t],(x-1)*self.size,(y-1)*self.size) end
		end
	end
	love.graphics.setCanvas()
end
function tilemap:checkPixel(x,y)
	local tileX = math.floor(x / self.size) + 1
	local tileY = math.floor(y / self.size) + 1
	if tileX > 0 and tileY > 0 and tileX <= self.width and tileY <= self.height then
		return self.data[tileX][tileY]
	else
		return -1
	end
end

-- Define the player
player = {
	-- Basic properties
	x = 320-16,
	y = 180-16,
	size=16,
	vx = 0,
	vy = 0,
	facing = 1,
	-- Movement
	gravity = 500,
	moveSpeed = 128,
	jumpSpeed = 350,
	acc = 500,
	fric = 5,
	grounded = false,
	wasGrounded = false,
	sprite = love.graphics.newImage("player16.png"),
	-- Quality of life
	jumpBuffer = 0,
	coyoteTime = 0
}
-- Define player loop
function player:update(dt)
	-- Gravity
	self.vy = self.vy + self.gravity * dt
	
	-- Horizontal movement
	if keys.right then
		self.vx = math.min(self.vx + self.acc * dt,self.moveSpeed)
		self.facing = 1
	elseif keys.left then
		self.vx = math.max(self.vx - self.acc * dt,-self.moveSpeed)
		self.facing = -1
	elseif self.grounded then
		self.vx = self.vx - self.vx * dt * self.fric
		if math.abs(self.vx) <= dt then self.vx = 0 end
	end
	
	-- Jumping
	if keys.space and not keys_prev.space then
		self.jumpBuffer = 0.05
	elseif self.vy < 0 and not keys.space and keys_prev.space then
		self.vy = self.vy * 0.5
	end
	-- Jumping is buffered for a tenth of a second
	if self.jumpBuffer > 0 then
		if self.grounded or self.coyoteTime > 0 then
			self.vy = -self.jumpSpeed
			self.jumpBuffer = 0
			self.coyoteTime = 0
		end
		self.jumpBuffer = math.max(0,self.jumpBuffer-dt)
	end
	
	
	-- Check for collisions
	-- Horizontal
	local colTile = self:checkMove(self.vx * dt,0)
	if colTile ~= 0 then
		self.x = math.floor(self.x / tilemap.size + 0.5) * tilemap.size
		self.vx = 0
	end
	self.x = self.x + self.vx * dt
	
	-- Vertical
	colTile = self:checkMove(0,self.vy * dt)
	self.grounded = false
	if colTile ~= 0 then
		self.y = math.floor(self.y / tilemap.size + 0.5) * tilemap.size
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
end
function player:draw()
	local px = self.x
	if self.facing == -1 then px = px + self.size end
	love.graphics.draw(self.sprite,px,self.y,0,self.facing,1)
end
function player:checkMove(dx,dy)
	-- Check for collisions
	local xCol = 0
	local yCol = 0
	-- Horizontal
	if dx ~= 0 then
		local xSide = dx > 0 and self.x + self.size or self.x
		xCol = tilemap:checkPixel(xSide + dx,self.y+1)
		if xCol == 0 then xCol = tilemap:checkPixel(xSide + dx,self.y+self.size-1) end
	end
	-- Vertical
	if dy ~= 0 then
		local ySide = dy > 0 and self.y + self.size or self.y
		yCol = tilemap:checkPixel(self.x+1,ySide+dy)
		if yCol == 0 then yCol = tilemap:checkPixel(self.x+self.size-1,ySide+dy) end
	end
	
	if xCol ~= 0 then
		return xCol
	else
		return yCol
	end
end

-- Setup game
function love.load()
	canvas = love.graphics.newCanvas(640,360)
	canvas:setFilter( "nearest", "nearest" )
	love.graphics.setDefaultFilter('nearest', 'nearest', 0)
	
	-- Setup tilemap
	tilemap:setup(40,23,16)
	for x=1, tilemap.width do
		tilemap.data[x] = {}
		for y=1, tilemap.height do
			if x == 1 or y == 1 or x == tilemap.width or y == tilemap.height then
				tilemap.data[x][y] = 1
			else
				tilemap.data[x][y] = 0
			end
		end
	end
	-- Load tiles
	tilemap.tiles = {
		love.graphics.newImage("metal16.png")
	}
	-- Redraw the tilemap canvas
	tilemap:redraw()
end

-- Update custom key table
function love.keypressed(key)

	if key == '`' then
		debugInfo = not debugInfo
	end

	keys[key] = true
end
function love.keyreleased(key)
	keys[key] = false
end

-- DEBUG CODE to draw walls
function love.mousemoved(x,y)
	if love.mouse.isDown(1,2) then
		local tileX = math.floor(x / 2 / tilemap.size) + 1
		local tileY = math.floor(y / 2 / tilemap.size) + 1
		if tileX > 0 and tileY > 0 and tileX <= tilemap.width and tileY <= tilemap.height then
			if love.mouse.isDown(1) then
				tilemap.data[tileX][tileY] = 1
			elseif love.mouse.isDown(2) then
				tilemap.data[tileX][tileY] = 0
			end
			tilemap:redraw()
		end
	end
end

-- Update player and key data
function love.update(dt)
	player:update(dt)
	-- Update prev keys
	for key, value in pairs(keys) do
		keys_prev[key] = value
	end
end

-- Draw scene
function love.draw()
	love.graphics.setCanvas(canvas)
	
	-- Do normal drawing here
	love.graphics.clear(0,0,0)
	love.graphics.draw(tilemap.canvas,0,0)
	player:draw()
	
	-- local tx = math.floor(player.x / tilemap.size) * tilemap.size
	-- local ty = math.floor(player.y / tilemap.size) * tilemap.size
	-- love.graphics.rectangle('line',tx,ty,tilemap.size,tilemap.size)
	-- love.graphics.print(tilemap.checkPixel(player.x,player.y),tx,ty)
	
	if debugInfo then 
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
		love.graphics.print("Player Motion: ("..tostring(player.vx)..","..tostring(player.vy)..")", 10, 22)
		love.graphics.print("Jump Buffer: "..tostring(player.jumpBuffer), 10, 34)
		love.graphics.print("Coyote Time: "..tostring(player.coyoteTime), 10, 46)
		love.graphics.print("Grounded : "..tostring(player.grounded)..","..tostring(player.wasGrounded), 10, 58)
	end
	
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,2)
end