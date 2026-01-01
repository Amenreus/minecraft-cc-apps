local Listener = {
    visual = true
}
Listener.__index = Listener

Listener.pointerEvents = {
    mouse_click = true,
    mouse_drag = true,
    monitor_touch = true
}

---@param eventName string
---@param opts { id string, handler function, propagate boolean}
function Listener:on(eventName, opts)
    assert(type(eventName) == "string", "eventName must be string")
    assert(type(opts) == "table", "options must be table")
    assert(type(opts.handler) == "function", "handler is required".."["..(self.id or "nil").."]")

    local listeners = self.listeners
    if not listeners then
        listeners = {}
        self.listeners = listeners
    end

    self.listeners[eventName] = self.listeners[eventName] or {}
    table.insert(self.listeners[eventName], opts)
end

function Listener:off(eventName, id)
    assert(type(eventName) == "string", "eventName must be string")

    local listeners = self.listeners[eventName]
    if not listeners then return end

    if id == nil then
        self.listeners[eventName] = nil
        return
    end

    for i = #listeners, 1, -1 do
        if listeners[i].id == id then
            table.remove(listeners, i)
        end
    end

    if #listeners == 0 then
        self.listeners[eventName] = nil
    end
end

function Listener:hasListeners(event)
    return self.listeners
            and self.listeners[event]
            and #self.listeners[event] > 0
end

function Listener:isPointerEvent(eventName)
    return self.pointerEvents[eventName] or false
end

function Listener:addPointerEvent(name)
    if type(name) ~= string then return end
    self.pointerEvents[name] = true
end

function Listener:removePointerEvent(name)
    if type(name) ~= string then return end
    self.pointerEvents[name] = nil
end

function Listener:handleBounds(eventName, ...)
    if not self.visual then return true end
    local evArgs = {...}
    local x, y = evArgs[2], evArgs[3]

    if self:isPointerEvent(eventName) then
        local pos = self.lastDraw and self.lastDraw.pos or {xPos=0, yPos=0}
        if not self:testBounds(pos, x, y) then
            return false
        end
    end
    return true
end

function Listener:dispatchSelf(eventName, ...)
    local list = self.listeners and self.listeners[eventName]
    if not list then return true end

    local listeners = self.listeners[eventName]
    if listeners then
        for _, item in ipairs(listeners) do
            item.handler(...)
            if item.propagate == false then return false end
        end
    end
    return true
end

function Listener:onEvent(eventName, ...)
    if not self:handleBounds(eventName, ...) then
        return
    end

    if not self:dispatchSelf(eventName, ...) then
        return
    end

    if self.children then
        for _, child in ipairs(self.children) do
            child:onEvent(eventName, ...)
        end
    end
end

function Listener:addFilter(eventName)
    local filter = self.eventFilter
    if not filter then
        filter = {}
        self.eventFilter = filter
    end

    table.insert(filter, eventName)
end

function Listener:removeFilter(eventName)
    local filter = self.eventFilter
    if not filter then return end

    for i = #filter, 1, -1 do
        if filter[i] == eventName then
            table.remove(filter, i)
        end
    end
end

function Listener:setVisual(b)
    if type(b) == "boolean" then self.visual = b end
end

function Listener:getVisual()
    return self.visual
end

return Listener