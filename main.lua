-- Global stuff
require 'src.debug.console'

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

-- Scenemanager
local sceneManager = require 'src.scene.scenemanager'

-- Define the base scene
local scene

-- Setup game
function love.load()
	canvas = love.graphics.newCanvas(640,360)
	canvas:setFilter( "nearest", "nearest" )
	love.graphics.setDefaultFilter('nearest', 'nearest', 0)

	love.keyboard.setKeyRepeat(true)

	-- Load scene
	scene = Scene('/assets/scenes/test.json','Level')
	
end

-- Update custom key table
function love.keypressed(key, scancode, isrepeat)
	-- Action system
	if not isrepeat then
		actions:keyStateChanged(key,true)
	end
	-- Toggle console
	if actions:getActionPressed('console') then
		Console.visible = not Console.visible
	else
		-- Pass other input to console
		Console.keypressed(key)
	end
end
function love.keyreleased(key)
	actions:keyStateChanged(key,false)
end
-- Feed text input to console
function love.textinput(t)
	if not actions:getActionPressed('console') then
		-- Feed input to console
		Console.textinput(t)
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
	
	-- Draw console
	Console.draw()

	-- Reset canvas and draw scaled up
	love.graphics.setCanvas()
	love.graphics.draw(canvas,0,0,0,2)
end