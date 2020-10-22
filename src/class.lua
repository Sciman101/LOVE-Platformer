local Class = {}

-- Allows you to create a class by extending another
function Class:extends(parent)
    self.super = parent
    getmetatable(self).__index = parent
    return self
end

-- Check if this ins
function Class:isinstance(instance)
    -- Get the index table for the instance passed
    local meta = getmetatable(instance).__index
    -- While the metatable exists
    while meta do
        -- If it's this class, then yes, it's an instance!
        if meta == self then
            return true
        end
        -- Descend a level deeper
        meta = getmetatable(meta)
        if meta then meta = meta.__index end
    end
    -- Guess not! too bad
    return false
end

-- Class constructor
return function(classname)
    return setmetatable({_name = classname}, {

        __index = Class,
        -- This is called when the table is 'called'
        -- i.e. local ent = Entity()
        __call = function(self,...)
            local inst = setmetatable({}, {
                __index = self, -- Self being the class
                __tostring = function() return ("%s instance"):format(self._name) end
            })

            -- If we have a constuctor, then call it on this thing
            if self.new then
                self.new(inst,...)
            else
                -- Otherwise this class is Wrong
                assert(("Class '%s' is missing a constructor"):format(self._name))
            end
            return inst
        end,
        -- Define the tostring so it's not just a table
        __tostring = function(self)
            return ('Class definition %s'):format(self._name)
        end
    })
end