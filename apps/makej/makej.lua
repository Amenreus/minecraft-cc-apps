-- config
local solvers = {"Amenreus", "Tlapka"}
local taskStates = {"New", "In Progress", "Done"}
local monitorSide = "right"
local dataFolder = "data"
local autoSave = true
local autoLoad = true
local termScale = 0.5

-- const
local programName = "Make-J"
local version = "1.0.0"
local taskFile = "tasks.tbl"

-- imports
package.path = package.path..";/?"..";/?.lua"
local GuiUtils = require("lib.gui.gui_utils")
local Window = require("lib.gui.window")
local PagesManager = require("lib.gui.pages_manager")
local HBox = require("lib.gui.hbox")
local EventListener = require("lib.gui.event_listener")
local TaskManager = require("apps.makej.task_manager")
local TaskService = require("apps.makej.task_service")
local DetailPage = require("apps.makej.detail_page")
local Console = require("apps.makej.console")

-- program globals
local window
local taskService
local eventListener
local console

-- func
local function preInit()
    term.clear()
    term.setCursorPos(1,1)
    print("Initializing program", programName,"("..version..")")
end

local function postInit()
    if type(autoLoad) == "boolean" and autoLoad then
        taskService:restore()
    end
    os.queueEvent("refresh")
    print("Running program", programName,"("..version..")")
end

local function initWindow()
    local monitor = peripheral.wrap(monitorSide)
    local windowInstance = Window:new()
    if type(termScale) ~= "number" then termScale = 1 end
    windowInstance:setId("window")
    windowInstance:setTerminal(monitor)
    windowInstance:setTextScale(termScale)
    windowInstance:setBackground(colors.black)
    windowInstance:setPosition(1, 1)
    return windowInstance
end

local function initRouter()
    local controller = PagesManager:new()
    controller:setId("router")
    return controller
end

local function initTaskManager()
    local usersDto = {
        props = { "text", "color", "colorText" },
        text = { "None", table.unpack(solvers) },
        color = { colors.red, colors.cyan, colors.green },
        defaults = {
            color = colors.red,
            colorText = colors.black
        }
    }

    local statesDto = {
        props = { "text", "color" },
        text = taskStates,
        color = { colors.red, colors.yellow, colors.green },
        defaults = {}
    }

    local users = GuiUtils.convertArrayToStates(usersDto)
    local states = GuiUtils.convertArrayToStates(statesDto)

    local manager = TaskManager:new()
    manager:setId("taskManager")
    manager:setDefaultStateStates(states)
    manager:setDefaultUserStates(users)
    manager:setHeaderColors(colors.black)
    manager:setColumnWidths({user = 10, state = 11})
    manager:setStretch(true)
    return manager
end

local function initIndex()
    local index = HBox:new()
    index:setId("index")
    index:setSpacing(2)
    return index
end

local function initDetail()
    local detailPage = DetailPage:new()
    detailPage:setId("detail")
    local x, y = window:getSize()
    detailPage:setSize(x,y)
    return detailPage
end

local function initConsole()
    console = Console:new()

    console:addCommand("add", function(...)
        local args = {...}
        local task = { name = args[1], desc = args[2]}
        taskService:addTask(task)
    end)

    console:addCommand("list", function(compact)
        print(textutils.serialize(taskService:list(), {compact = compact or false}))
    end)

    console:addCommand("cls", function()
        term.clear()
        term.setCursorPos(1,1)
    end)

    console:addCommand("save", function()
        local saved, msg = taskService:persist()
        if not saved then print(msg) else print("Saved") end
    end)

    console:addCommand("load", function()
        local saved, msg = taskService:restore()
        if not saved then print(msg) else print("Restored") end
    end)

    console:addCommand("refresh", function()
        os.queueEvent("refresh")
    end)
end

local function initBackend()
    print("Initializing backend...")
    taskService = TaskService:new()
    taskService:setPersistenceLocation(fs.combine(dataFolder, taskFile))
    taskService:setAutoSave(autoSave)
    eventListener = EventListener:new()
end

local function initGui()
    print("Initializing GUI...")
    window = initWindow()
    local router = initRouter()

    local taskManager = initTaskManager()
    taskManager:setTaskService(taskService)

    local index = initIndex()
    index:addChild(taskManager)
    router:addPage("index", index)

    local detail = initDetail()
    router:addPage("detail", detail)

    window:addChild(router)
end

local function bindComponents()
    eventListener:register("window", window)
    eventListener:register("taskService", taskService)
end

-- main
local function main()
    preInit()
    initBackend()
    initGui()
    bindComponents()
    initConsole()
    postInit()

    parallel.waitForAny(
            function() eventListener:start() end,
            function() console:handleInputs() end
    )

    window:clear()
    eventListener:stop()
    console:stop()
    taskService:persist()
end

main()