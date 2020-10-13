Tilemap = {

	prototype = {
		data = {},
		tiles = {},
		width = 8,
		height = 8,
		size = 16,
		canvas = nil
	},
	__index = function(self,x) -- Able to get tiles from raw index accessor
		if type(x) == 'number' then
			if x > 0 and x <= self.width then
				return data[x]
			else
				return -1
			end
		else
			return prototype[x]
		end
	end,
	__metatable = nil,
	
	-- Constructor
	new = function(self,w,h,s)
		local tm = {width=w or prototype.width,height=h or w or prototype.width,size=s or prototype.size}
		tm.canvas = love.graphics.newCanvas(tm.width * tm.size,tm.height * tm.size)
		
		-- Populate data with empty fields
		for x=1, tm.width do
			tm.data[x] = {}
			for y=1, tm.height do
				if x == 1 or y == 1 or x == tm.width or y == tm.height then
				tilemap.data[x][y] = 0 -- 0 corresponds to an empty tile
			end
		end
		
		setmetatable(tm,Tilemap)
		return tm
	end,
	
	-- Set a tile by position
	setTile = function(self,x,y,t)
		if x > 0 and y > 0 and x <= self.width and y <= self.height then
			self.data[x][y] = t
		end
	end,
	
	-- Get a tile by position
	getTile = function(self,x,y)
		if x > 0 and y > 0 and x <= self.width and y <= self.height then
			return self.data[x][y]
		else
			return -1 -- -1 is different than 0 - it means 'OOB'
		end
	end,
	
	-- Get a tile via pixel position
	getTilePixel = function(self,x,y)
		local tileX = math.floor(x / self.size) + 1
		local tileY = math.floor(y / self.size) + 1
		return self:getTile(x,y)
	end,
	
	-- Redraw the canvas
	redraw = function(self)
		love.graphics.setCanvas(self.canvas)
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

}