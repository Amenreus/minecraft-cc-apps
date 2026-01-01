local Button = require("lib.gui.button")

local StateButton = {}
StateButton.__index = StateButton
setmetatable(StateButton, { __index = Button })

function StateButton:new()
    local o = Button:new()
    setmetatable(o, self)

    o.states = {}
    o.stateIndex = 1
    local defaultState = o:extractDataSource()
    defaultState.stateId = "default"
    o:addState(defaultState)

    return o
end

---@param state { stateId:string, ... }
function StateButton:addState(state)
    if not state or type(state) ~= "table" then return end
    table.insert(self.states, state)
end

function StateButton:getProp(name)
    if not name or name:len() == 0 then return nil end
    local state = self:getCurrentState()
    if not state[name] then return self[name] end
    return state[name]
end

function StateButton:nextState()
    -- handle empty states
    local states = self:getStates()
    if #states == 0 then
        return
    end

    -- handle overflow
    if self.stateIndex >= #states then
        self.stateIndex = 1
        return
    end

    -- normal increment
    self.stateIndex = self.stateIndex + 1
end

function StateButton:previousState()
    -- handle empty states
    local states = self:getStates()
    if #states == 0 then
        return
    end

    -- handle overflow
    if self.stateIndex <= 1 then
        self.stateIndex = #states
        return
    end

    -- normal increment
    self.stateIndex = self.stateIndex - 1
end

function StateButton:setStates(states)
    if type(states) ~= "table" or #states == 0 then return end
    self.states = states
end

function StateButton:setState(index)
    if not index or type(index) ~= "number" then
        return
    end
    local states = self:getStates()

    if index < 1 or index > #states then
        return
    end
    self.stateIndex = index
end

function StateButton:setStateByProp(propName, value)
    if not propName or propName == "" then return end
    if not value or type(value) ~= "string" then return end

    local states = self:getStates()
    for i = 1, #states do
        local propVal = states[i][propName]
        if propVal == value then
            self.stateIndex = i
        end
    end
end

function StateButton:getCurrentState()
    local states = self:getStates()
    if self.stateIndex > 0 and self.stateIndex <= #states  then
        return states[self.stateIndex]
    else
        return nil
    end
end

function StateButton:getStates()
    local dsData = self:getDataSourceData()
    if dsData == nil or dsData.states == nil then return self.states end
    return dsData.states
end

function StateButton:setDataSource(ds)
    if self.datasource == ds then return end
    self.datasource = ds
    self.stateIndex = 1
end

function StateButton:pack(spacing)
    spacing = math.max(0, spacing or 0)

    self.height = 1 -- Buttons are not multi-line yet

    local states = self:getStates()
    local maxLen = 1

    for i = 1, #states do
        maxLen = math.max(maxLen, states[i].text:len())
    end

    self.width = maxLen + spacing
end

return StateButton