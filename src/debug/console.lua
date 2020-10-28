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
    commands = require 'src.debug.commands'
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
    elseif key == 'return' then
        -- Execute current command

        -- Split command into parameters
        local args = {}
        local str
        for str in Console.consoleLine:gmatch("[^%s]+") do
            table.insert(args,str)
        end

        -- Make sure the command exists
        if #args >= 1 and Console.commands[args[1]] then

            Console.commands[args[1]].func(args)

        else
            Console.log("Unknown command " .. args[1])
        end
        -- Clear console line
        Console.consoleLine = ''
    end
end
function Console.textinput(text)
    if not Console.visible then return end
    if text ~= '`' then
        Console.consoleLine = Console.consoleLine .. text
    end
end

-- Actually draw the console
function Console.draw(x,y)
    if Console.visible then

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
            yoff = yoff + textObj:getHeight()
        end

        love.graphics.setColor(1,1,1)
        textObj:release()
    end
end