local Class = require 'src.class'

local Tilemap = Class('Tilemap')

-- Define constructor
function Tilemap.new(inst,w,h,s)
	
	inst.width = w or 8
	inst.height = h or w or 8
	inst.size = s or 16	
	inst.canvas = love.graphics.newCanvas(inst.width * inst.size,inst.height * inst.size)
	inst.tiles = {}
	inst.data = {}
	
	-- Populate data with empty fields
	for y=1, inst.height do
		inst.data[y] = {}
		for x=1, inst.width do
			inst.data[y][x] = 0 -- 0 corresponds to an empty tile
		end
	end

end
	
-- Set a tile by position
function Tilemap:setTile(x,y,t,update)
	if x > 0 and y > 0 and x <= self.width and y <= self.height then
		if self.data[y][x] ~= t then
			self.data[y][x] = t
			if update then 
				self:refresh()
			end
		end
	end
end

-- Set a tile via pixel position
function Tilemap:setTilePixel(x,y,tile,update)
	local tileX = math.floor(x / self.size) + 1
	local tileY = math.floor(y / self.size) + 1
	self:setTile(tileX,tileY,tile,update)
end

-- Get a tile by position
function Tilemap:getTile(x,y)
	if x > 0 and y > 0 and x <= self.width and y <= self.height then
		return self.data[y][x]
	else
		return -1 -- -1 is different than 0 - it means 'OOB'
	end
end

-- Get a tile via pixel position
function Tilemap:getTilePixel(x,y)
	local tileX = math.floor(x / self.size) + 1
	local tileY = math.floor(y / self.size) + 1
	return self:getTile(tileX,tileY)
end

-- Redraw the canvas
function Tilemap:refresh()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0,0,0,0)
	local t = 0
	for y=1, self.height do
		for x=1, self.width do
			t = self.data[y][x]
			if self.tiles[t] ~= nil then love.graphics.draw(self.tiles[t],(x-1)*self.size,(y-1)*self.size) end
		end
	end
	love.graphics.setCanvas()
end

-- Draw to screen
function Tilemap:draw()
	love.graphics.draw(self.canvas,0,0)
end

return Tilemap