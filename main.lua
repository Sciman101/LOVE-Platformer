local Actions = require 'src/actions'
local Entity = require 'src/entity/entity'
local EntityPlayer = require 'src/entity/entityPlayer'
local Tilemap = require 'src/tilemap'
local Scene = require 'src/scene'

local canvas

local debugInfo = false
local currentTile = 1

-- Define input bindings
local actions = Actions()
actions:bind('d','right')
actions:bind('a','left')
actions:bind('space','jump')
actions:bind('`','console')

-- Define tile drawing nonsense
local scene = Scene(640,360,16,actions)

-- Define the player
local player = EntityPlayer(320,180,16,love.graphics.newImage('assets/player16.png'),tilemap)
scene:addEntity(player)

-- Add boxes
scene:addEntity(Entity(64,180,16,love.graphics.newImage('assets/red16.png'),tilemap))
scene:addEntity(Entity(64,180-16,16,love.graphics.newImage('assets/red16.png'),tilemap))
scene:addEntity(Entity(64,180-32,16,love.graphics.newImage('assets/red16.png'),tilemap))

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
		love.graphics.newImage("assets/metal16.png")
	}
	-- Redraw the tilemap canvas
	scene.tilemap:refresh()
end

-- Update custom key table
function love.keypressed(key)
	actions:keyStateChanged(key,true)
end
function love.keyreleased(key)
	actions:keyStateChanged(key,false)
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
	actions:update()
end

-- Draw scene
function love.draw()
	-- Draw to canvas so we can scale the game's graphics
	love.graphics.setCanvas(canvas)
	
	-- Do normal drawing here
	love.graphics.clear(0,0,0)
	scene:draw()

	-- Debug info
	if debugInfo then
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