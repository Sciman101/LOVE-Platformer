require 'entity'
require 'tilemap'
require 'scene'

local canvas
local keys = {}
local keys_prev = {}

local debugInfo = false
local currentTile = 1

-- Define tile drawing nonsense
local scene = Scene:new()
scene.tilemap = Tilemap:new(40,23,16)

-- Define the player
local player = Entity:new(320,180,16,love.graphics.newImage('player16.png'),tilemap)
player.coyoteTime = 0
player.jumpBuffer = 0
player.moveSpeed = 128
player.jumpSpeed = 350
player.acc = 500
scene:addEntity(player)

-- Add boxes
scene:addEntity(Entity:new(64,180,16,love.graphics.newImage('red16.png'),tilemap))
scene:addEntity(Entity:new(64,180-16,16,love.graphics.newImage('red16.png'),tilemap))
scene:addEntity(Entity:new(64,180-32,16,love.graphics.newImage('red16.png'),tilemap))
-- Define player loop
function player:update(dt)
	
	-- Horizontal movement
	if keys.d then
		self.vx = math.min(self.vx + self.acc * dt,self.moveSpeed)
		self.facing = 1
	elseif keys.a then
		self.vx = math.max(self.vx - self.acc * dt,-self.moveSpeed)
		self.facing = -1
	end
	self.flipX = self.facing ~= 1
	
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
	
	if self.coyoteTime > 0 then
		self.coyoteTime = math.max(self.coyoteTime - dt,0)
	end
	
	-- Call 'super'
	getmetatable(self).update(self,dt)
	
end
function player:onTileCollision(tile)
	if tile == 2 then print('dead') end
end
function player:onGroundedStateChange(state)
	if not state then
		self.coyoteTime = 0.05
	end
end

-- Setup game
function love.load()
	canvas = love.graphics.newCanvas(640,360)
	canvas:setFilter( "nearest", "nearest" )
	love.graphics.setDefaultFilter('nearest', 'nearest', 0)
	
	-- Setup tilemap
	for x=1, scene.tilemap.width do
		for y=1, scene.tilemap.height do
			if x == 1 or y == 1 or x == scene.tilemap.width or y == scene.tilemap.height then
				scene.tilemap:setTile(x,y,1)
			end
		end
	end
	-- Load tiles
	scene.tilemap.tiles = {
		love.graphics.newImage("metal16.png"),
		love.graphics.newImage("red16.png")
	}
	-- Redraw the tilemap canvas
	scene.tilemap:refresh()
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
	if debugInfo then
		x = x/2
		y = y/2
		if love.mouse.isDown(1,2) then
			if love.mouse.isDown(1) then
				scene.tilemap:setTilePixel(x,y,currentTile,true)
			elseif love.mouse.isDown(2) then
				scene.tilemap:setTilePixel(x,y,0,true)
			end
		end
	end
end
-- DEBUG CODE change selected tile type
function love.wheelmoved(x,y)
	if debugInfo then
		currentTile = currentTile + 1
		if currentTile > #scene.tilemap.tiles then currentTile = 1 end
		if currentTile < 1 then currentTile = #scene.tilemap.tiles end
	end
end

-- Update player and key data
function love.update(dt)
	scene:update(dt)
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
	scene:draw()

	-- Debug info
	if debugInfo then
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
		love.graphics.print("Player Motion: ("..tostring(player.vx)..","..tostring(player.vy)..")", 10, 22)
		love.graphics.print("Jump Buffer: "..tostring(player.jumpBuffer), 10, 34)
		love.graphics.print("Coyote Time: "..tostring(player.coyoteTime), 10, 46)
		love.graphics.print("Grounded : "..tostring(player.grounded)..","..tostring(player.wasGrounded), 10, 58)
		
		local tileX = math.floor(love.mouse.getX() / 2 / scene.tilemap.size) * scene.tilemap.size
		local tileY = math.floor(love.mouse.getY() / 2 / scene.tilemap.size) * scene.tilemap.size
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.draw(scene.tilemap.tiles[currentTile],tileX,tileY)
		love.graphics.setColor(1,1,1,1)
	end
	
	-- Reset canvas and draw scaled up
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,2)
end