local Console = {}
Console.__index = Console

function Console:new()
    local o = {}
    setmetatable(o, self)
    o.run = true
    o.commands = {}

    o.commands["exit"] = function() o.run = false end

    return o
end

function Console:handleInputs()
    while self.run do
        local input = read()
        local command = self.parse(input)

        if self.commands[command[1]] ~= nil then
            self.commands[command[1]](table.unpack(command, 2))
        else
            print("Unknown command.")
        end
    end
end

function Console:addCommand(name, handler)
    if not name or type(handler) ~= "function" then return end
    self.commands[name] = handler
end

function Console.parse(str)
    if type(str) ~= "string" or str == "" then return nil end

    local tokens = {}
    local token
    local longToken = false
    local length = #str
    local current
    local tStart = 1

    for tEnd = 1, length do
        current = string.byte(str, tEnd)

        if current == 32 and not longToken then -- whitespace
            if tEnd > tStart then
                token = string.sub(str, tStart, tEnd -1)
                table.insert(tokens, token)
                tStart = tEnd + 1
            else
                tStart = tEnd + 1
            end
        elseif current == 34 then -- quotation mark
            if longToken then
                longToken = false
                token = string.sub(str, tStart, tEnd-1)
                table.insert(tokens, token)
                tStart = tEnd + 1
            else
                tStart = tEnd + 1
                longToken = true
            end
        elseif tEnd == length then
            if tStart <= tEnd then
                token = string.sub(str, tStart, tEnd)
                table.insert(tokens, token)
            end
        end
    end
    return tokens
end

function Console:stop()
    self.run = false
end

return Console