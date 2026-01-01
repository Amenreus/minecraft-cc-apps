local Listener = require("lib.gui.listener")

local Component = {
    id = nil,
    xPos = 0,
    yPos = 0,
    width = 1,
    height = 1,
    enabled = true,
    visible = true
}
Component.__index = Component
setmetatable(Component, { __index = Listener })

function Component:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Component:setEnabled(enabled)
    if enabled ~= nil then
        self.enabled = enabled
    end
end

function Component:setVisible(visible)
    if visible ~= nil then
        self.visible = visible
    end
end

function Component:setPosition(xPos, yPos)
    if xPos ~= nil and xPos > 0 then
        self.xPos = xPos
    end

    if yPos ~= nil and yPos > 0 then
        self.yPos = yPos
    end
end

function Component:setSize(width, height)
    if width ~= nil and width > 0 then
        self.width = width
    end

    if height ~= nil and height > 0 then
        self.height = height
    end
end

function Component:getSize()
    return self.width or 0, self.height or 0
end

function Component:setId(id)
    self.id = id or ""
end

function Component:setDataSource(ds)
    self.datasource = ds
end

function Component:hasDataSource()
    return self.datasource ~= nil
end

function Component:getDataSource()
    return self.datasource
end

function Component:hasDataSourceData()
    if self.id == nil or self.id:len() == 0 then return false end
    return self:hasDataSource() and self.datasource[self.id] ~= nil
end

function Component:getDataSourceData()
    if self:hasDataSourceData() then
        return self.datasource[self.id]
    end
    return nil
end

function Component:getProp(name)
    if not name or name:len() == 0 then return nil end
    local ds = self:getDataSourceData()
    if ds and ds[name] ~= nil then
        return ds[name]
    end
    return self[name]
end

--- @private
function Component:draw(term, pos)
    term = term or self.lastDraw.term
    pos = pos or {xPos = 0, yPos = 0}
    self:measure()
    self.lastDraw = { term = term, pos = pos }
    self:drawComponent(term, pos)
end

function Component:drawComponent(term, pos)
    -- default: prevents nil states, safe to override
end

function Component:redraw()
    if self.lastDraw == nil then return end
    self:draw(self.lastDraw.term, self.lastDraw.pos)
end

function Component:measure()
    return self.width or 0, self.height or 0
end

function Component:testBounds(pos, x, y)
    local absXPos, absYPos = self:getAbsPos(pos)
    local right = absXPos + self.width - 1
    local bottom = absYPos + self.height - 1

    if x >= absXPos and x <= right and y >= absYPos and y <= bottom then
        return true
    end
    return false
end

function Component:getAbsPos(parentPos)
    parentPos = parentPos or { xPos = 0, yPos = 0 }

    local x = parentPos.xPos
    local y = parentPos.yPos

    if not parentPos.layoutControlled then
        x = x + (self.xPos or 0)
        y = y + (self.yPos or 0)
    end

    return x, y
end

return Component