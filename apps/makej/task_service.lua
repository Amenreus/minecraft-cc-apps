local Listener = require("lib.gui.listener")

local TaskService = {}
TaskService.__index = TaskService
setmetatable(TaskService, { __index = Listener })

local defaults = {}
defaults.events = {
    taskAdded = "task_added",
    taskRemoved = "task_removed"
}
defaults.values = {
    user = "None",
    state = "New"
}

local function initListeners(o)
    o:on("task_update", {
        id = "task_update",
        handler = function(updateDto)
            if not updateDto then return end
            o:updateTask(updateDto)
        end,
        propagate = false
    })
end

function TaskService:new()
    local o = {}
    setmetatable(o, self)
    o.tasks = {}
    o.idCounter = 0
    o.autoSave = false
    initListeners(o)
    o:setVisual(false)
    return o
end


function TaskService:addTask(task)
    if type(task) ~= "table" then
        return
    end
    if type(task.name) ~= "string" then
        return
    end
    task.id = tostring(self:nextId())
    task.solver = defaults.values.user
    task.state = defaults.values.state
    table.insert(self.tasks, task)
    if self.autoSave then
        self:persist()
    end
    os.queueEvent(defaults.events.taskAdded, task)
end

function TaskService:removeTask(id)
    if type(id) ~= "number" or id < 1 then
        return
    end
    for i = 1, #self.tasks do
        if self.tasks[i].id == id then
            table.remove(self.tasks, i)
            break
        end
    end

    if self.autoSave then
        self:persist()
    end

    os.queueEvent(defaults.events.taskRemoved, id)
end

function TaskService:list()
    return self.tasks
end

function TaskService:updateTask(updateDto)
    if not updateDto then return end

    local indexes = {
        "name",
        "desc",
        "solver",
        "state"
    }

    for i = 1, #self.tasks do
        if self.tasks[i].id == updateDto.id then
            for _, index in ipairs(indexes) do
                if updateDto[index] ~= nil then
                    self.tasks[i][index] = updateDto[index]
                end
            end
        end
    end

    if self.autoSave then
        self:persist()
    end
end

---@private
function TaskService:nextId()
    self.idCounter = self.idCounter + 1
    return self.idCounter
end

function TaskService:setPersistenceLocation(file)
    self.persistenceFile = file
end

function TaskService:persist()
    if type(self.persistenceFile) ~= "string" then return false, "Could not persist tasks. Location not set." end
    if #self.tasks == 0 then return true, "No data to save." end
    local serrTable = { lastId = self.idCounter, tasks = self.tasks }
    local outputString = textutils.serialize(serrTable, {compact = true})
    local file = fs.open(self.persistenceFile, "w")
    file.write(outputString)
    file.close()
    return true
end

function TaskService:restore()
    if type(self.persistenceFile) ~= "string" then return false, "Could not restore tasks. Location not set. Could not restore." end
    if not fs.exists(self.persistenceFile) then return false, "File with task data does not exist. Could not restore." end

    local file = fs.open(self.persistenceFile, "r")

    local serTasks = file.readLine()
    file.close()

    if not serTasks then return false, "Task file is empty. Could not restore." end

    local deserialized = textutils.unserialize(serTasks)
    if type(deserialized) ~= "table" or type(deserialized.lastId) ~= "number" or type(deserialized.tasks) ~= "table" then return false, "Serialized data corrupted. Could not restore." end

    self.tasks = deserialized.tasks
    self.idCounter = deserialized.lastId
    os.queueEvent("task_restored")
    return true
end

---@param bool boolean
function TaskService:setAutoSave(bool)
    if type(bool) == "boolean" then
        self.autoSave = bool
    end
end

return TaskService