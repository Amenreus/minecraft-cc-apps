local Container = require("lib.gui.container")

local VBox = {
    spacing = 0
}
VBox.__index = VBox
setmetatable(VBox, { __index = Container })

function VBox:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function VBox:setSpacing(spacing)
    self.spacing = spacing or 0
end

function VBox:measure()
    local maxWidth = 0
    local totalHeight = 0

    if not self.children then
        self.width = 0
        self.height = 0
        return 0, 0
    end

    for i = 1, #self.children do
        local cw, ch = self.children[i]:measure()

        maxWidth = math.max(maxWidth, cw)
        totalHeight = totalHeight + ch
    end

    if #self.children > 1 then
        totalHeight = totalHeight + self.spacing * (#self.children - 1)
    end

    self.width = maxWidth
    self.height = totalHeight

    return self.width, self.height
end

function VBox:drawComponent(term, pos)
    if not self.children then return end

    self:measure()

    local absXPos, absYPos = self:getAbsPos(pos)

    local cursorY = absYPos

    for i = 1, #self.children do
        local child = self.children[i]

        child:draw(term, { xPos = absXPos, yPos = cursorY, layoutControlled = true })

        cursorY = cursorY + child.height + self.spacing
    end
end

return VBox