local Container = require("lib.gui.container")

local HBox = {
    spacing = 0
}
HBox.__index = HBox
setmetatable(HBox, { __index = Container })

function HBox:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function HBox:setSpacing(spacing)
    self.spacing = spacing or 0
end

function HBox:measure()
    local totalWidth = 0
    local maxHeight = 0

    if not self.children then
        self.width = 0
        self.height = 0
        return 0, 0
    end

    for i = 1, #self.children do
        local cw, ch = self.children[i]:measure()

        totalWidth = totalWidth + cw
        maxHeight = math.max(maxHeight, ch)
    end

    if #self.children > 1 then
        totalWidth = totalWidth + self.spacing * (#self.children - 1)
    end

    self.width = totalWidth
    self.height = maxHeight

    return self.width, self.height
end

function HBox:drawComponent(term, pos)
    if not self.children then return end

    self:measure()

    local absXPos, absYPos = self:getAbsPos(pos)

    local cursorX = absXPos

    for i = 1, #self.children do
        local child = self.children[i]

        child:draw(term, { xPos = cursorX, yPos = absYPos, layoutControlled = true })

        cursorX = cursorX + child.width + self.spacing
    end
end

return HBox