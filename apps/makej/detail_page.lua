local Container = require("lib.gui.container")
local Label = require("lib.gui.label")
local Button = require("lib.gui.button")
local GuiUtils = require("lib.gui.gui_utils")

local DetailPage = {}
DetailPage.__index = DetailPage
setmetatable(DetailPage, {__index = Container})

DetailPage.idConstant = {
    pageName = "pageName",
    taskName = "taskName",
    taskNameVal = "taskNameVal",
    taskId = "taskId",
    taskIdVal = "taskIdVal",
    solver = "solver",
    solverVal = "solverVal",
    state = "state",
    stateVal = "stateVal",
    desc = "desc",
    descVal = "descVal",
    retBtn = "retBtn"
}

local function initGui(o)
    local pageName = Label:new()
    pageName:setId(DetailPage.idConstant.pageName)
    pageName:setText("TASK DETAIL",true)

    local retBtn = Button:new()
    retBtn:setId(DetailPage.idConstant.retBtn)
    retBtn:setText("<= Return", true)

    local taskName = Label:new()
    taskName:setId(DetailPage.idConstant.taskName)
    taskName:setText("Name:", true)
    local taskNameVal = Label:new()
    taskNameVal:setId(DetailPage.idConstant.taskNameVal)

    local taskId = Label:new()
    taskId:setId(DetailPage.idConstant.taskId)
    taskId:setText("ID:", true)
    local taskIdVal = Label:new()
    taskIdVal:setId(DetailPage.idConstant.taskIdVal)

    local solver = Label:new()
    solver:setId(DetailPage.idConstant.solver)
    solver:setText("Solver:", true)
    local solverVal = Label:new()
    solverVal:setId(DetailPage.idConstant.solverVal)

    local state = Label:new()
    state:setId(DetailPage.idConstant.state)
    state:setText("State:", true)
    local stateVal = Label:new()
    stateVal:setId(DetailPage.idConstant.stateVal)

    local desc = Label:new()
    desc:setId(DetailPage.idConstant.desc)
    desc:setText("Description:", true)
    local descVal = Label:new()
    descVal:setId(DetailPage.idConstant.descVal)

    o:addNamedChild(DetailPage.idConstant.pageName, pageName)
    o:addNamedChild(DetailPage.idConstant.taskName, taskName)
    o:addNamedChild(DetailPage.idConstant.taskNameVal, taskNameVal)
    o:addNamedChild(DetailPage.idConstant.taskId, taskId)
    o:addNamedChild(DetailPage.idConstant.taskIdVal, taskIdVal)
    o:addNamedChild(DetailPage.idConstant.solver, solver)
    o:addNamedChild(DetailPage.idConstant.solverVal, solverVal)
    o:addNamedChild(DetailPage.idConstant.state, state)
    o:addNamedChild(DetailPage.idConstant.stateVal, stateVal)
    o:addNamedChild(DetailPage.idConstant.desc, desc)
    o:addNamedChild(DetailPage.idConstant.descVal, descVal)
    o:addNamedChild(DetailPage.idConstant.retBtn, retBtn)
end

local function initListeners(o)
    o.retBtn:on("monitor_touch", {
        id = "return",
        handler = function()
            os.queueEvent("set_page", "index")
        end
    })
end

function DetailPage:new()
    local o = {}
    setmetatable(o, self)
    initGui(o)
    initListeners(o)
    return o
end

local function getNewPos(pos, x, y)
    return { xPos = pos.xPos + x, yPos = pos.yPos + y}
end

function DetailPage:drawComponent(term, pos)
    local tw, th = term.getSize()

    local line1 = 0
    local line2 = 2
    local line3 = 4
    local line4 = 6
    local line5 = 8

    self.pageName:draw(term, pos)
    self.retBtn:draw(term, getNewPos(pos, tw - self.retBtn.width, line1))

    self.taskName:draw(term, getNewPos(pos, 0, line2))
    self.taskNameVal:setText(self.datasource.name, true)
    self.taskNameVal:draw(term, getNewPos(pos, self.taskName.width + 1, line2))

    self.taskIdVal:setText(self.datasource.id, true)
    self.taskIdVal:draw(term, getNewPos(pos, tw - self.taskIdVal.width, line2))
    self.taskId:draw(term, getNewPos( pos,tw - self.taskIdVal.width - self.taskId.width, line2))

    self.solver:draw(term, getNewPos(pos, 0, line3))
    self.solverVal:setText(self.datasource.solver, true)
    self.solverVal:draw(term, getNewPos(pos, self.solver.width + 1, line3))

    self.stateVal:setText(self.datasource.state, true)
    self.stateVal:draw(term, getNewPos(pos, tw - self.stateVal.width, line3))
    self.state:draw(term, getNewPos(pos, tw - self.stateVal.width - self.state.width, line3))

    self.desc:draw(term, getNewPos(pos, 0, line4))
    self.descVal.alignmentVertical = GuiUtils.alignment.vertical.top
    self.descVal:setMultiline(true)
    self.descVal:setSize(tw, th-line5)
    self.descVal:setText(self.datasource.desc or "No description")
    self.descVal:draw(term, getNewPos(pos, 0, line5))
end

return DetailPage