Tilemap = {
	
	-- Set a tile by position
	setTile = function(self,x,y,t,update)
		if x > 0 and y > 0 and x <= self.width and y <= self.height then
			if self.data[y][x] ~= t then
				self.data[y][x] = t
				if update then 
					self:refresh()
				end
			end
		end
	end,
	
	-- Set a tile via pixel position
	setTilePixel = function(self,x,y,tile,update)
		local tileX = math.floor(x / self.size) + 1
		local tileY = math.floor(y / self.size) + 1
		self:setTile(tileX,tileY,tile,update)
	end,
	
	-- Get a tile by position
	getTile = function(self,x,y)
		if x > 0 and y > 0 and x <= self.width and y <= self.height then
			return self.data[y][x]
		else
			return -1 -- -1 is different than 0 - it means 'OOB'
		end
	end,
	
	-- Get a tile via pixel position
	getTilePixel = function(self,x,y)
		local tileX = math.floor(x / self.size) + 1
		local tileY = math.floor(y / self.size) + 1
		return self:getTile(tileX,tileY)
	end,
	
	-- Redraw the canvas
	refresh = function(self)
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
	end,
	
	-- Draw to screen
	draw = function(self)
		love.graphics.draw(self.canvas,0,0)
	end
}
Tilemap.__index = Tilemap

-- Define constructor
function Tilemap:new(w,h,s)
	local tm = setmetatable({},Tilemap)
	
	tm.width = w or 8
	tm.height = h or w or 8
	tm.size = s or 16	
	tm.canvas = love.graphics.newCanvas(tm.width * tm.size,tm.height * tm.size)
	tm.tiles = {}
	tm.data = {}
	
	-- Populate data with empty fields
	for y=1, tm.height do
		tm.data[y] = {}
		for x=1, tm.width do
			tm.data[y][x] = 0 -- 0 corresponds to an empty tile
		end
	end
	
	return tm
end