-- https://yal.cc/love2d-simple-logger/
Console = {
    --OUTPUT
    lines = {},
    line_styles = {},
    -- Predefined 
    styles = {
        info = {r=1,g=1,b=1},
        warn = {r=0.8,g=0.8,b=0.05},
        error = {r=0.9,g=0.1,b=0.1}
    },
    count = 0,
    limit = 32,
    --INPUT
    consoleLine = '',
    --GENERIC
    visible = false,
    commands = require 'src.debug.commands',
    suggestedCommands = {},
    suggestedCommandIndex = 0,
    commandHistory = {},
    commandHistoryIndex = 0
}


function Console.print(message,source)
    if source == nil then source = 'info' end
    local msg = '[' .. string.upper(source) .. '] ' .. message

    -- Print to actual console
    print(msg)

    if Console.count > Console.limit then
        -- Scroll
        table.remove(Console.lines, 1)
		table.remove(Console.line_styles, 1)
    else
        -- Increment message count
        Console.count = Console.count + 1
    end
    -- Add to list
    Console.lines[Console.count] = msg
    Console.line_styles[Console.count] = Console.styles[source]
end


-- Specific logging functions
function Console.log(message) Console.print(message,'info') end
function Console.warn(message) Console.print(message,'warn') end
function Console.error(message) Console.print(message,'error') end


-- Called when a key is pressed
function Console.keypressed(key)
    if not Console.visible then return end
    -- Backspace
    if key == 'backspace' then
        Console.consoleLine = Console.consoleLine:sub(1,#Console.consoleLine-1)
        -- Get out of history thing
        Console.commandHistoryIndex = 0
        -- Find new suggestions
        Console:findSuggestions()

    elseif key == 'return' then
        -- Execute current command
        if #Console.consoleLine == 0 then return end

        -- Split command into parameters
        local args = {}
        Console.consoleLine:gsub("[^%s]+", function(str) table.insert(args, str) end)

        -- Make sure the command exists
        if #args >= 1 and Console.commands[args[1]] then
            Console.commands[args[1]](args)
        else
            Console.log("Unknown command " .. args[1])
        end
        table.insert(Console.commandHistory,1,Console.consoleLine)
        Console.commandHistoryIndex = 0
        -- Clear console line
        Console.consoleLine = ''
        Console:findSuggestions()

    elseif key == 'up' or key == 'down' then
        -- Scroll through history
        local i = Console.commandHistoryIndex
        if key == 'up' then i = i + 1
        elseif key == 'down' then i = i - 1 end
        -- Clamp
        if i < 0 then i = 0 
        elseif i > #Console.commandHistory then i = #Console.commandHistory end
        -- Update
        if i ~= 0 then
            Console.consoleLine = Console.commandHistory[i]
        else
            Console.consoleLine = ''
        end
        Console.commandHistoryIndex = i
    
    elseif key == 'tab' then
        -- Autocomplete
        local i = Console.suggestedCommandIndex
        i = i + 1
        if i > #Console.suggestedCommands then
            i = 0
            Console.consoleLine = ''
        else
            Console.consoleLine = Console.suggestedCommands[i]
        end
        
        Console.suggestedCommandIndex = i

    elseif key == 'c' or key == 'v' or key == 'x' then
        -- Check for modifier key
        if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
            -- Copy or paste text
            if key == 'v' then 
                Console.consoleLine = love.system.getClipboardText()
            elseif (key == 'c' or key == 'x') and #Console.consoleLine > 0 then
                love.system.setClipboardText(Console.consoleLine)
                Console.log('Console line copied to clipboard')
                -- Cut
                if key == 'x' then
                    Console.consoleLine = ''
                    Console:findSuggestions()
                end
            end
        end
    end
end
function Console.textinput(text)
    if not Console.visible then return end
    Console.consoleLine = Console.consoleLine .. text
    Console:findSuggestions()
end

-- Find suggested commands based on input
function Console:findSuggestions()
    -- Clear table
    self.suggestedCommands = {}

    -- Do we have anything to work with?
    if self.consoleLine ~= '' then
        for k,cmd in pairs(self.commands) do
            if string.find(k,self.consoleLine) == 1 then
                table.insert(self.suggestedCommands,k)
            end
        end
    end

    -- Move cursor
    if self.suggestedCommandIndex > #self.suggestedCommands then
        self.suggestedCommandIndex = 0
    end
end


-- Actually draw the console
function Console.draw(x,y)
    if Console.visible then

        -- Throw a background on there so it's more bearable to look at
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle('fill',0,0,love.graphics.getDimensions())

        local textObj = love.graphics.newText(love.graphics.getFont(),'')

        local i, s, z, yoff
        yoff = 0
        -- default position parameters:
        if (x == nil) then x = 16 end
        if (y == nil) then y = 16 end
        -- draw lines:
        for i = 0, Console.count do

            -- Draw normal line
            if i ~= 0 then
                z = Console.lines[i] -- string to draw
                s = Console.line_styles[i]
            else
            -- Draw console stuff
                z = '> ' .. Console.consoleLine
                s = Console.styles.info
            end

            textObj:set(z)

            -- choose white/black outline:
            if ((s.r < 0.6) and (s.g < 0.6) and (s.b < 0.6)) then
                love.graphics.setColor(1,1,1)
            else
                love.graphics.setColor(0, 0, 0)
            end
            -- draw outline:
            love.graphics.draw(textObj, x + 1, y + yoff)
            love.graphics.draw(textObj, x - 1, y + yoff)
            love.graphics.draw(textObj, x, y + 1  + yoff)
            love.graphics.draw(textObj, x, y - 1  + yoff)
            -- draw color:
            love.graphics.setColor(s.r, s.g, s.b)
            love.graphics.draw(textObj, x, y  + yoff)
            -- concatenate prefix:
            yoff = yoff + textObj:getHeight() + 2
            if i == 0 then yoff = yoff + 16 end
        end

        -- Draw suggested commands
        if #Console.suggestedCommands > 0 and Console.commandHistoryIndex == 0 then
            yoff = textObj:getHeight()
            for i=1,#Console.suggestedCommands do
                textObj:set(Console.suggestedCommands[i])
                love.graphics.setColor(0,0,0,0.9)
                love.graphics.rectangle('fill',x,y+yoff,textObj:getDimensions())

                if i == Console.suggestedCommandIndex then
                    love.graphics.setColor(1,1,0)
                else
                    love.graphics.setColor(1,1,1)
                end

                love.graphics.draw(textObj, x, y  + yoff)
                yoff = yoff + textObj:getHeight() + 2
            end
        end

        love.graphics.setColor(1,1,1)
        textObj:release()
    end
end