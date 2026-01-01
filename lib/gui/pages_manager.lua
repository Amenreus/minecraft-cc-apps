local Container = require("lib.gui.container")

local PagesManager = {}
PagesManager.__index = PagesManager
setmetatable(PagesManager, { __index = Container })

local function initListeners(o)
    o:on("set_page", {
        id = "set_page",
        handler = function(name, pageData)
            o:setPage(name)
            if type(pageData) == "table" then
                o.selected:setDataSource(pageData)
            else
                o.selected:setDataSource(nil)
            end
            os.queueEvent("page_updated")
            os.queueEvent("refresh")
        end,
        propagate = false
    })
end


function PagesManager:new(o)
    o = o or {}
    setmetatable(o, self)
    initListeners(o)
    return o
end

function PagesManager:addPage(name, component, select)
    local pages = self.pages
    if not pages then
        pages = {}
        self.pages = pages
    end

    pages[name] = component

    if not self.selected then
        self.selected = component
    end

    if select then
        self.selected = component
        self:measure()
    end
end

function PagesManager:removePage(name)
    local pages = self.pages
    if not pages then return end

    local page = pages[name]
    if not page then return end

    pages[name] = nil

    if self.selected == page then self.selected = nil end
end

function PagesManager:setPage(name)
    local pages = self.pages
    if not pages then return end

    local page = pages[name]
    if not page then return end

    self.selected = page
    self:measure()
end

function PagesManager:onEvent(eventName, ...)
    if not self:dispatchSelf(eventName, ...) then
        return
    end

    local page = self.selected
    if not page then return end

    page:onEvent(eventName, ...)
end

function PagesManager:measure()
    if not self.selected then
        self.width = 0
        self.height = 0
        return 0, 0
    end

    local page = self.selected
    return page:measure()
end

function PagesManager:drawComponent(term, pos)
    local page = self.selected
    if not page then return end

    local absXPos, absYPos = self:getAbsPos(pos)
    page:draw(term, { xPos = absXPos, yPos = absYPos})
end

return PagesManager