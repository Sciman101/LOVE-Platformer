local commands = {}

-- Echo command
commands.echo = setmetatable({
    desc = 'Prints every parameter passed to it',
    usage = 'echo <message> <message 2> <...>'
},{
    __call = function(self,args)
        for i,v in ipairs(args) do
            if i ~= 1 then
                Console.log(v)
            end
        end
    end
})
commands.ecto = setmetatable({
    desc = 'Prints every parameter passed to it',
    usage = 'ecto <message> <message 2> <...>'
},{
    __call = function(self,args)
        for i,v in ipairs(args) do
            if i ~= 1 then
                Console.log(v)
            end
        end
    end
})

-- Console clear command
commands.clear = setmetatable({
    desc = 'Clear the console',
    usage = 'clear'
},{
    __call = function(self,...)
        Console.count = 0
    end
})

-- Quit game command
commands.quit = setmetatable({
    desc = 'Quit the game',
    usage = 'quit'
},{
    __call = function(self,...)
        love.event.quit()
    end
})

-- Help command
commands.help = setmetatable({
    desc = 'Show command list, or show help for an individual command',
    usage = 'help [command]'
},{
    __call = function(self,args)
        if #args == 1 then
            -- Just display command list
            local list = 'Command list:\n'
            for cmd, val in pairs(commands) do
                list = list .. cmd .. ' - ' .. val.desc .. '\n'
            end
            Console.log(list)
        elseif #args >= 2 then
            -- Display info for specific command
            local cmd = commands[args[2]]
            if cmd then
                Console.log(args[2] .. '\n' .. cmd.desc .. '\n' .. cmd.usage)
            else
                Console.log('Unknown command ' .. arg[1])
            end
        end
    end
})

return commands