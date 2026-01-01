local StringUtils = require("lib.util.string_utils")
local GuiUtils = {}

GuiUtils.alignment = {}
GuiUtils.alignment.horizontal = {
    left = "left",
    center = "center",
    right = "right"
}
GuiUtils.alignment.vertical = {
    top = "top",
    center = "center",
    bottom = "bottom"
}

function GuiUtils.fitStringToComponent(component, text)
    local strLen = #text
    local width = component.width
    local hAlignment = component.alignmentHorizontal or GuiUtils.alignment.horizontal.left

    if strLen < width then -- fill the missing gaps with prefix spaces and suffix spaces
        local gapWidth = width-strLen

        if hAlignment == GuiUtils.alignment.horizontal.right then
            return string.rep(" ", gapWidth)..text
        end

        if hAlignment == GuiUtils.alignment.horizontal.center then
            local prefixLen = math.floor(gapWidth / 2)
            local suffixLen = math.ceil(gapWidth / 2)

            return string.rep(" ", prefixLen)..text..string.rep(" ", suffixLen)
        end

        -- alignment is "left" or nil therefore default
        return text..string.rep(" ", gapWidth)
    elseif strLen > width then -- shorten the string to fit the button
        local t = string.sub(text, 1, width)
        return string.sub(t,1, #t - 3).."..."
    else
        return text
    end
end

function GuiUtils.fitStringToComponentMultiline(component, text)
    local vertAlignment = component.alignmentVertical
    local w,h = component:getSize()

    local lines = StringUtils.splitLines(text, w)

    -- reduce lines to height
    --Todo cut lines to height in splitLines()
    if #lines > h then
        lines = { table.unpack(lines, 1, h) }
    end

    -- fit to width
    for i, line in ipairs(lines) do
        lines[i] = GuiUtils.fitStringToComponent(component, line)
    end

    if #lines == h then return lines end

    if vertAlignment == GuiUtils.alignment.vertical.center then
        local hDiff = h - #lines
        local upSpacer = math.floor(hDiff / 2)
        local downSpacer = math.ceil(hDiff / 2)
        local emptyLine = string.rep(" ", w)
        local upFiller = {}

        for _ = 1, upSpacer do -- fill top
            table.insert(upFiller, emptyLine)
        end

        lines = {table.unpack(upFiller), table.unpack(lines)}

        for _ = 1, downSpacer do -- fill bottom
            table.insert(lines, emptyLine)
        end
    elseif vertAlignment == GuiUtils.alignment.vertical.bottom then
        local hDiff = h - #lines
        local emptyLine = string.rep(" ", w)
        local upFiller = {}

        for _ = 1, hDiff do -- fill top
            table.insert(upFiller, emptyLine)
        end

        lines = {table.unpack(upFiller), table.unpack(lines)}
    else
        local hDiff = h - #lines
        local emptyLine = string.rep(" ", w)

        for _ = 1, hDiff do -- fill bottom
            table.insert(lines, emptyLine)
        end
    end
    return lines
end

---@param dtoIn { props:table, defaults:table, ...:table  }
function GuiUtils.convertArrayToStates(dtoIn)
    if not dtoIn or not dtoIn.props then return nil end
    local props = dtoIn.props
    local count = #dtoIn[dtoIn.props[1]]
    local states = {}

    for stateIndex = 1, count do
        local state = {}
        for i = 1, #props do
            state[props[i]] = dtoIn[props[i]] and dtoIn[props[i]][stateIndex] or dtoIn.defaults[props[i]]
        end
        table.insert(states, state)
    end
    return states
end

return GuiUtils