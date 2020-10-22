local Class = require 'src.class'
local Entity = require 'src.entity.entity'

local EntityPlayer = Class('EntityPlayer')
EntityPlayer:extends(Entity)

-- Constructor
function EntityPlayer.new(inst,x,y,size,sprite)
	inst.super.new(inst,x,y,size,sprite)

	-- Entity type
	inst.type = 'player'

	-- Player properties
	inst.coyoteTime = 0
	inst.jumpBuffer = 0
	inst.moveSpeed = 128
	inst.jumpSpeed = 350
	inst.acc = 500
end

function EntityPlayer:update(dt)
	-- Horizontal movement
	if self.scene.actions:getAction('right') then
		self.vx = math.min(self.vx + self.acc * dt,self.moveSpeed)
		self.facing = 1
	elseif self.scene.actions:getAction('left') then
		self.vx = math.max(self.vx - self.acc * dt,-self.moveSpeed)
		self.facing = -1
	end
	self.flipX = self.facing ~= 1

	-- Jumping
	if self.scene.actions:getActionPressed('jump') then
		self.jumpBuffer = 0.05
	elseif self.vy < 0 and self.scene.actions:getActionReleased('jump') then
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
	self.super.update(self,dt)
end

function EntityPlayer:onGroundedStateChange(state)
	if not state then
		self.coyoteTime = 0.05
	end
end

return EntityPlayer