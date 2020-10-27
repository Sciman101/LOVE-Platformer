local Actions = require 'src.actions'
local Entity = require 'src.entity.entity'
local EntityPlayer = require 'src.entity.entityPlayer'
local Tilemap = require 'src.tilemap'
local Scene = require 'src.scene.scene'

local canvas

-- Define input bindings
local actions = Actions()
actions:bind('d','right')
actions:bind('a','left')
actions:bind('space','jump')
actions:bind('`','console')

-- Define the base scene
local scene

-- Setup game
function love.load()
	canvas = love.graphics.newCanvas(640,360)
	canvas:setFilter( "nearest", "nearest" )
	love.graphics.setDefaultFilter('nearest', 'nearest', 0)

	-- Load scene
	scene = Scene('/assets/scenes/test.json','Level')
	
end

-- Update custom key table
function love.keypressed(key)
	actions:keyStateChanged(key,true)
end
function love.keyreleased(key)
	actions:keyStateChanged(key,false)
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
	
	-- Reset canvas and draw scaled up
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,2)
end