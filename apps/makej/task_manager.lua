local VBox = require("lib.gui.vbox")
local HBox = require("lib.gui.hbox")
local Label = require("lib.gui.label")
local GuiUtils = require("lib.gui.gui_utils")
local TaskRow = require("apps.makej.task_row")

local TaskManager = {}
TaskManager.__index = TaskManager
setmetatable(TaskManager, { __index = VBox})

local function initGui(o)
    local header = HBox:new()
    header:setId("header")
    local lblTask = Label:new()
    lblTask:setText("Task")
    lblTask:setId("lblTask")
    lblTask.alignmentHorizontal = GuiUtils.alignment.horizontal.center
    local lblUser = Label:new()
    lblUser:setText("Solver")
    lblUser:setId("lblUser")
    lblUser.alignmentHorizontal = GuiUtils.alignment.horizontal.center
    local lblState = Label:new()
    lblState:setText("State")
    lblState:setId("lblState")
    lblState.alignmentHorizontal = GuiUtils.alignment.horizontal.center
    header:addNamedChild("lblTask", lblTask)
    header:addNamedChild("lblUser", lblUser)
    header:addNamedChild("lblState", lblState)
    header:setSpacing(1)
    o:addNamedChild("header", header)
end

local function initListeners(o)
    o:on("task_added", {
        id = "task_added",
        handler = function(task)
            if not task or not task.name then return end
            o:addTask(task)
        end,
        propagate = false
    })
    o:on("task_restored", {
        id = "task_restored",
        handler = function()
            if not o.taskService then return end
            o:clear()
            local taskList = o.taskService:list()
            for _, item in ipairs(taskList) do
                o:addTask(item, false)
            end
            os.queueEvent("refresh")
        end,
        propagate = false
    })
    o:on("page_updated", {
        id = "reload_tasks",
        handler = function()
            if not o.taskService then return end
            o:clear()
            local tasks = o.taskService:list()
            for _, task in ipairs(tasks) do
                o:addTask(task, false)
            end
            os.queueEvent("refresh")
        end,
        propagate = false
    })
end

function TaskManager:new()
    local o = VBox:new()
    setmetatable(o, self)
    o.defaultStates = { user = nil, state = nil }
    o.columnWidth = { taskBtn = 8, userBtn = 8, stateBtn = 8}
    initGui(o)
    initListeners(o)
    return o
end

function TaskManager:setDefaultUserStates(states)
    self.defaultStates.user = states
end

function TaskManager:setDefaultStateStates(states)
    self.defaultStates.state = states
end

---@param color (number|{ task:number, user:number, state:number })
function TaskManager:setHeaderColors(color)
    if not color then return end
    if type(color) == "number" then -- single color for
        self.header.lblTask:setColor(color)
        self.header.lblUser:setColor(color)
        self.header.lblState:setColor(color)
    end

    if type(color) == "table" then
        if type(color.task) == "number" then self.header.lblTask:setColor(color.task) end
        if type(color.user) == "number" then self.header.lblUser:setColor(color.user) end
        if type(color.state) == "number" then self.header.lblState:setColor(color.state) end
    end
end

function TaskManager:setColumnWidths(w)
    if type(w) == "number" and w > 0 then
        self.columnWidth.task = w
        self.columnWidth.user = w
        self.columnWidth.state = w
    end

    if type(w) == "table" then
        if w.task and w.task > 0 then self.columnWidth.taskBtn = w.task end
        if w.user and w.user > 0 then self.columnWidth.userBtn = w.user end
        if w.state and w.state > 0 then self.columnWidth.stateBtn = w.state end
    end

    self.header.lblTask:setSize(self.columnWidth.taskBtn)
    self.header.lblUser:setSize(self.columnWidth.userBtn)
    self.header.lblState:setSize(self.columnWidth.stateBtn)

    if #self.children < 2 then return end

    local widths = {}
    widths[TaskRow.idConstants.taskBtn] = self.columnWidth.taskBtn
    widths[TaskRow.idConstants.userBtn] = self.columnWidth.userBtn
    widths[TaskRow.idConstants.stateBtn] = self.columnWidth.stateBtn

    for i = 2, #self.children do
        self.children[i]:setChildrenWidth(widths)
    end
end

function TaskManager:setTaskService(taskService)
    self.taskService = taskService
end

function TaskManager:measure()
    local cw, ch = VBox.measure(self)
    self.width = cw
    self.height = ch
    return cw,ch
end

function TaskManager:addTask(task, refresh)
    if type(task) ~= "table" then return end
    if type(refresh) ~= "boolean" then refresh = true end

    local taskRow = TaskRow:new()

    taskRow:setStretch(self.stretch)

    if self.defaultStates.user then
        taskRow[taskRow.idConstants.userBtn]:setStates(self.defaultStates.user)
    end

    if self.defaultStates.state then
        taskRow[taskRow.idConstants.stateBtn]:setStates(self.defaultStates.state)
    end

    if self.columnWidth then
        taskRow:setChildrenWidth(self.columnWidth)
    end
    taskRow:setTask(task)

    self:addChild(taskRow)
    if refresh then os.queueEvent("refresh") end
end

function TaskManager:clear()
    for i = #self.children, 2, -1 do
        table.remove(self.children, i)
    end
end

function TaskManager:removeTask(id)
    error("Not yet implemented")
end

function TaskManager:getTask(id)
    error("Not yet implemented")
end

function TaskManager:setStretch(bool)
    if type(bool) == "boolean" then
        self.stretch = bool

        for i = 2, #self.children do
            self.children[i]:setStretch(bool)
        end
        os.queueEvent("refresh")
    end
end

function TaskManager:drawComponent(term, pos)
    if self.stretch then
        local x = term.getSize()
        local absX = self:getAbsPos(pos)
        local sizeOfOthers = self.header.lblUser.width + self.header.lblState.width + 2 --TODO not responsive to changes, fix
        local remainingSpace = x - absX - sizeOfOthers
        self.header.lblTask:setSize(remainingSpace)
    end
    VBox.drawComponent(self, term, pos)
end

return TaskManager