local Component = require("lib.gui.component")
local Container = {}
Container.__index = Container
setmetatable(Container, {__index = Component})

function Container:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Container:addChild(child)
    if type(child) ~= "table" then error("child must be a table", 2) end

    local children = rawget(self, "children")
    if not children then
        children = {}
        self.children = children
    end

    if self.datasource then
        child:setDataSource(self.datasource)
    end

    children[#children + 1] = child
end

function Container:addNamedChild(name, child)
    if type(name) ~= "string" or name == "" then
        error("Name must be a non-empty string")
    end

    if rawget(self, name) ~= nil then
        error("Child with name '" .. name .. "' already exists")
    end

    self:addChild(child)
    rawset(self, name, child)
end

function Container:getChild(id)
    if not id or type(id) ~= "string" or id == "" then return nil end
    for i = 1, #self.children do
        local cid = self.children[i]
        if cid.id == id then return cid end
    end
    return nil
end

function Container:removeChild(id, name)
    if not id or type(id) ~= "string" or id == "" then return end
    local children = self.children
    if not children then return end

    for i = #children, 1, -1 do
        if children[i].id == id then
            local named = name and rawget(self, name)
            if named ~= nil and named == children[i] then
                rawset(self, name, nil)
            end
            table.remove(children, i)
        end
    end

    if #children == 0 then
        self.children = nil
    end
end

function Container:setDataSource(ds)
    Component.setDataSource(self, ds)

    if not self.children then return end

    for _, child in pairs(self.children) do
        child:setDataSource(ds)
    end
end

function Container:drawComponent(term, pos)
    local absXPos, absYPos = self:getAbsPos(pos)

    self:measure()

    for i = 1, #self.children do
        self.children[i]:draw(term, { xPos = absXPos, yPos = absYPos })
    end
end

return Container