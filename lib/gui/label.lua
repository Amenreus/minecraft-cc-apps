local Component = require("lib.gui.component")
local GuiUtils = require("lib.gui.gui_utils")

local Label = {
    text = "Label",
    color = colors.black,
    colorText = colors.white,
    alignmentHorizontal = GuiUtils.alignment.horizontal.left,
    alignmentVertical = GuiUtils.alignment.vertical.top,
    height = 1,
    multiline = false
}

Label.dataSourceProps = {
    text = "text",
    color = "color",
    colorText = "colorText",
    alignmentHorizontal = "alignmentHorizontal",
    alignmentVertical = "alignmentVertical"
}

Label.__index = Label
setmetatable(Label, { __index = Component })

function Label:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Label:setText(text, fit)
    self.text = text or ""
    if type(fit) == "boolean" and fit then
        self.width = string.len(text)
    end
end

function Label:setColor(color)
    color = color or colors.red
    self.color = color
end

function Label:setMultiline(bool)
    if type(bool) == "boolean" then
        self.multiline = bool
    end
end

function Label:pack(spacing)
    if self.multiline and self.height > 1 then return end
    spacing = math.max(0, spacing or 0)

    self.height = 1

    local text = self:getProp(self.dataSourceProps.text)
    if not text or #text == 0 then
        self.width = 1 + spacing
    else
        self.width = #text + spacing
    end
end

function Label:drawInline(term, pos)
    local absXPos, absYPos = self:getAbsPos(pos)
    local text = GuiUtils.fitStringToComponent(self, self:getProp(Label.dataSourceProps.text))
    term.setCursorPos(absXPos, absYPos)
    term.write(text)
end

function Label:drawMultiline(term, pos)
    local absXPos, absYPos = self:getAbsPos(pos)

    local lines = GuiUtils.fitStringToComponentMultiline(self, self:getProp(Label.dataSourceProps.text))

    for i, line in ipairs(lines) do
        term.setCursorPos(absXPos, absYPos + i - 1)
        term.write(line)
    end
end

function Label:drawComponent(term, pos)
    if not self.visible then return end
    term.setBackgroundColor(self:getProp(Label.dataSourceProps.color))
    term.setTextColor(self:getProp(Label.dataSourceProps.colorText))

    if self.multiline and self.height > 1 then
        self:drawMultiline(term, pos)
        return
    else
        self:drawInline(term, pos)
    end
end

return Label