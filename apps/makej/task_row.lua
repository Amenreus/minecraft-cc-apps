local HBox = require("lib.gui.hbox")
local Button = require("lib.gui.button")
local StateButton = require("lib.gui.state_button")
local GuiUtils = require("lib.gui.gui_utils")

local TaskRow = {}
TaskRow.__index = TaskRow
setmetatable(TaskRow, { __index = HBox })

TaskRow.idConstants = {
    stateBtn = "stateBtn",
    taskBtn = "taskBtn",
    userBtn = "userBtn"
}

local function mapArrayToStates(array)
    local result = {}
    for i = 1, #array do
        table.insert(result, { stateId = tostring(array[i]), text = array[i] })
    end
    return result
end

local function setupGui(o)
    local taskBtn = Button:new()
    taskBtn:setId(TaskRow.idConstants.taskBtn)

    local userBtn = StateButton:new()
    userBtn:setId(TaskRow.idConstants.userBtn)

    local stateBtn = StateButton:new()
    stateBtn:setId(TaskRow.idConstants.stateBtn)

    o:addNamedChild(o.idConstants.taskBtn, taskBtn)
    o:addNamedChild(o.idConstants.userBtn, userBtn)
    o:addNamedChild(o.idConstants.stateBtn, stateBtn)
    o:setSpacing(1)
end

local function initListeners(o)
    o.taskBtn:on("monitor_touch", {
        id = "show_detail",
        handler = function()
            os.queueEvent("set_page", "detail", o.taskData)
        end
    })

    o.userBtn:on("monitor_touch", {
        id = "monitor_touch",
        handler = function()
            o.userBtn:nextState()
            o.taskData.solver = o.userBtn:getProp("text")
            o.userBtn:redraw()
            os.queueEvent("task_update", { id = o.taskData.id, solver = o.taskData.solver })
        end
    })

    o.stateBtn:on("monitor_touch", {
        id = "monitor_touch",
        handler = function()
            o.stateBtn:nextState()
            o.taskData.state = o.stateBtn:getProp("text")
            o.stateBtn:redraw()
            os.queueEvent("task_update", { id = o.taskData.id, state = o.taskData.state })
        end
    })
end

function TaskRow:new()
    local o = HBox:new()
    setmetatable(o, self)
    o.id = "taskRow"
    setupGui(o)
    initListeners(o)
    self.stretch = false
    return o
end

---@param w number|{stateBtn:number|string, usrBtn:number|string, stateBtn:number|string}
function TaskRow:setChildrenWidth(w)
    local columns = {
        self.idConstants.taskBtn,
        self.idConstants.userBtn,
        self.idConstants.stateBtn,
    }

    local function apply(col, value)
        local child = self[col]
        if not child then
            return
        end

        if value == "p" or value == "pack" then
            child:pack()
        elseif type(value) == "number" and value > 0 then
            child:setSize(value, nil)
        end
    end

    if type(w) == "number" then
        for _, col in ipairs(columns) do
            apply(col, w)
        end

    elseif type(w) == "table" then
        for _, col in ipairs(columns) do
            apply(col, w[col])
        end
    end
end

function TaskRow:setTaskStates(states)
    if not states or type(states) ~= "table" then
        return
    end
    self.stateBtn.states = mapArrayToStates(states)
    self.stateBtn:pack(2)
end

function TaskRow:setUsers(users)
    if not users or type(users) ~= "table" then
        return
    end
    self.usrBtn.states = mapArrayToStates(users)
    self.usrBtn:pack(2)
end

function TaskRow:setStretch(bool)
    if type(bool) == "boolean" then
        self.stretch = bool
    end
end

---@param task { id:number, name:string, desc:string, solver:string, state:string }
function TaskRow:setTask(task)
    self.taskData = task
    self.taskBtn:setText(task.name)
    self.taskBtn.alignmentHorizontal = GuiUtils.alignment.horizontal.left
    self.userBtn:setStateByProp(Button.dataSourceProps.text, task.solver)
    self.stateBtn:setStateByProp(Button.dataSourceProps.text, task.state)
end

function TaskRow:drawComponent(term, pos)
    if self.stretch then
        local x = term.getSize()
        local absX = self:getAbsPos(pos)
        local sizeOfOthers = self.userBtn.width + self.stateBtn.width + 2
        local remainingSpace = x - absX - sizeOfOthers
        self.taskBtn:setSize(remainingSpace)
    end
    HBox.drawComponent(self,term,pos)
end

--TODO DataSource overrides

return TaskRow