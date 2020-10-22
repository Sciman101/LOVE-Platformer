local Class = require 'src.class'

local Actions = Class('Actions')

-- Constructor
function Actions.new(inst)
	inst.binds = {}
	inst.actions = {}
	inst.actions_prev = {}
end

-- When a key is pressed or released
function Actions:keyStateChanged(key,state)
	local act = self.binds[key]
	if act then
		self.actions[act] = state
	end
end

-- Update previous key states
function Actions:update()
	for k,v in pairs(self.actions) do
		self.actions_prev[k] = v
	end
end

-- Bind a key to an action
function Actions:bind(key, action)
	self.binds[key] = action
end

-- Get state of action
function Actions:getAction(action)
	return self.actions[action]
end
function Actions:getActionPressed(action)
	return self.actions[action] and not self.actions_prev[action]
end
function Actions:getActionReleased(action)
	return not self.actions[action] and self.actions_prev[action]
end

return Actions