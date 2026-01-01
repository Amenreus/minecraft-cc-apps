local Component = require "lib.gui.component"
local GuiUtils = require("lib.gui.gui_utils")

local Button = {
    text = "Button",
    width = 6,
    height = 1,
    color = colors.red,
    colorPressed = colors.green,
    colorDisabled = colors.lightGray,
    colorText = colors.black,
    alignmentHorizontal = GuiUtils.alignment.horizontal.center,
    alignmentVertical = GuiUtils.alignment.vertical.center,
    pressed = false,
}

Button.dataSourceProps = {
    text = "text",
    color = "color",
    colorPressed = "colorPressed",
    colorDisabled = "colorDisabled",
    colorText = "colorText",
    alignmentHorizontal = "alignmentHorizontal",
    alignmentVertical = "alignmentVertical"
}

Button.__index = Button
setmetatable(Button, {__index = Component})

local function getColorPropNameByState(btn)
    if not btn then return nil end
    if btn.enabled then
        if btn.pressed then return btn.dataSourceProps.colorPressed end
        return btn.dataSourceProps.color
    end
    return btn.dataSourceProps.colorDisabled
end

function Button:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Button:extractDataSource()
    local data = {}
    for _, prop in pairs(self.dataSourceProps) do
        data[prop] = self[prop]
    end
    return data
end

function Button:setText(text, fit)
    self.text = text or ""
    if fit == true then
        self.width = string.len(text)
    end
end

function Button:setColor(color)
    color = color or colors.red
    self.color = color
end

function Button:setColorPressed(color)
    color = color or colors.green
    self.colorPressed = color
end

function Button:setColorDisabled(color)
    color = color or colors.gray
    self.colorDisabled = color
end

function Button:getText()
    return self:getProp(self.dataSourceProps.text)
end

function Button:getColor()
    if self.enabled then
        if self.pressed then
            return self.colorPressed
        else
            return self.color
        end
    else
        return self.colorDisabled
    end
end

function Button:getTextColor()
    return self.colorText
end

function Button:pack(spacing)
    spacing = math.max(0, spacing or 0)

    self.height = 1 -- Buttons are not multi-line yet

    local text = self:getProp(self.dataSourceProps.text)
    if not text or text:len() == 0 then
        self.width = 1 + spacing
    else
        self.width = text:len() + spacing
    end
end

function Button:onEvent(eventName, ...)
    if not self.enabled and not self.visible then return end

    if not self:handleBounds(eventName, ...) then
        return
    end

    if self:isPointerEvent(eventName) then
        self.pressed = true
        self:redraw()
        sleep(0.1)
        self.pressed = false
        self:redraw()
    end
    self:dispatchSelf(eventName, ...)
end

---@param term {...} term object passed down for drawing
---@param pos { xPos:number, yPos:number, xOffset:number, yOffset:number } position override
function Button:drawComponent(term, pos)

    if not self.visible then return end

    local absXPos, absYPos = self:getAbsPos(pos)
    term.setBackgroundColor(self:getProp(getColorPropNameByState(self)))
    term.setTextColor(self:getProp(self.dataSourceProps.colorText))
    local text = GuiUtils.fitStringToComponent(self, self:getProp(self.dataSourceProps.text))

    if self.height > 1 then --TODO add support for vertical text alignment
        local stringVertPos = math.floor(self.height/2)
        local emptyString = string.rep(" ", self.width)
        for i = 1, self.height do
            term.setCursorPos(absXPos, absYPos + i - 1)
            if i == stringVertPos then
                term.write(text)
            else
                term.write(emptyString)
            end
        end
    else
        term.setCursorPos(absXPos, absYPos)
        term.write(text)
    end
end

return Button