local Listener = require("lib.gui.listener")

local EventListener = {}
EventListener.__index = EventListener
setmetatable(EventListener, { __index = Listener })

function EventListener:new(o)
    o = o or {}
    setmetatable(o, self)
    o.listeners = {}
    return o
end

---@param id string component identifier
---@param listener table component listening to events
function EventListener:register(id, listener)
    if not id or not listener then return end
    self:log("Registering listener", id)
    table.insert(self.listeners, {id = id, handler = listener})
end

function EventListener:start()
    self.running = true

    self:log("Event listener started.")

    while self.running do
        self:log("Pulling event...")
        local ev

        if self.eventFilter == nil then
            ev = { os.pullEvent() }
        else
            ev = { os.pullEvent(table.unpack(self.eventFilter)) }
        end

        self:log("Event caught: "..ev[1])
        local type = ev[1]

        for _, listener in ipairs(self.listeners) do
            listener.handler:onEvent(type, table.unpack(ev, 2))
        end
    end
    self:log("Event listener stopped.")
end

function EventListener:log(...)
    if self.debug then print(...) end
end

function EventListener:stop()
    if not self.running then return end

    self:log("Stopping event listener...")
    self.running = false;
    os.queueEvent("__stop__") -- notify self:start to stop blocking and end gracefully
end

return EventListener