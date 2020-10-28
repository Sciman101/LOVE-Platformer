local commands = {}

-- Echo command
commands.echo = {
    func = function(params)
        local i
        for i=2,#params do
            Console.log(params[i])
        end
    end,
    desc = 'Prints every parameter passed to it',
    usage = 'echo <message> <message 2> <...>'
}

-- Console clear command
commands.clear = {
    func = function(params)
        Console.count = 0
    end,
    desc = 'Clears the console',
    usage = 'clear'
}

-- Quit game command
commands.quit = {
    func = function(params)
        love.event.quit()
    end,
    desc = 'Closes the game',
    usage = 'quit'
}

-- Help command
commands.help = {
    func = function(params)
        if #params == 1 then
            -- Just display command list
            local list = 'Command list:\n'
            for cmd, val in pairs(commands) do
                list = list .. cmd .. ' - ' .. val.desc .. '\n'
            end
            Console.log(list)
        elseif #params >= 2 then
            -- Display info for specific command
            local cmd = commands[params[1]]
            if cmd then
                Console.log(params[1] .. '\n' .. cmd.desc .. '\n' .. cmd.usage)
            else
                Console.log('Unknown command ' .. params[1])
            end
        end
    end,
    desc = 'Show command list, or show help for an individual command',
    usage = 'help [command]'
}


return commands