local Container = require("lib.gui.container")

local Window = {
    color = colors.black,
    scale = 1
}
Window.__index = Window
setmetatable(Window, { __index = Container })

local function initListeners(o)
    o:on("refresh", {
        id = "refresh",
        handler = function() o:draw(o:getTerm()) end,
        propagate = false,
    })
    o:on("measure", {
        id = "measure",
        handler = function() o:measure() end
    })
    o:on("monitor_resize", {
        id = "monitor_resize",
        handler = function()
            local x, y = o.term.getSize()
            o:setSize(x,y)
            os.queueEvent("refresh")
        end,
        propagate = false
    })
end

function Window:new(o)
    o = o or {}
    setmetatable(o, self)
    initListeners(o)
    return o
end

function Window:setTerminal(term)
    assert(type(term) == "table", "Invalid argument: term must be set to terminal object")
    self.term = term
    self:measure()
end

function Window:clear()
    if not self.term then return end
    self.term.setBackgroundColor(self.color)
    self.term.clear()
    self.term.setCursorPos(1,1)
end

function Window:setTextScale(scale)
    if not scale or type(scale) ~= "number" or scale < 0.5 then return end
    self.scale = scale
    if self.term ~= nil then self.term.setTextScale(scale) end
end

function Window:setBackground(color)
    color = color or colors.black
    self.color = color
end

function Window:getTerm()
    return self.term
end

function Window:measure()
    local w,h = self.term.getSize()
    self.width = w
    self.height = h
    return w,h
end

function Window:drawComponent(term, pos)
    assert(term ~= nil, "Terminal is not set. Window can't be rendered")
    term.setTextScale(self.scale)
    term.setBackgroundColor(self.color)
    term.clear()
    term.setCursorPos(1,1)
    Container.drawComponent(self, term, pos)
end

return Window