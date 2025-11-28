-- conf
local inputSide = "top" -- top or bottom
local outputSide = "bottom" -- top or bottom
local inputSlot = 1
local outputSlot = 2
local inputItem = "minecraft:dirt"
local outputItem = "minecraft:clay"

-- var
local version = "1.0.0"

-- prog
local function eject(outputSlot, outputSide)
    local selectedSlot = turtle.getSelectedSlot()
    local pushed = false
    turtle.select(outputSlot)

    repeat
        if outputSide == "top" then
            pushed = turtle.dropUp()
        else
            pushed = turtle.dropDown()
        end

        if turtle.getItemCount() ~= 0 then -- turtle pushed part of the stack but some items were left
            pushed = false
            sleep(1)
        end
    until pushed

    turtle.select(selectedSlot)
end

local function suck(inputSlot, inputSide)
    local selectedSlot = turtle.getSelectedSlot()
    turtle.select(inputSlot)
    if inputSide == "top" then
        turtle.suckUp()
    else
        turtle.suckDown()
    end
    turtle.select(selectedSlot)
end

local function getInputItem(inputItem, inputSide, inputSlot)
    while true do
        turtle.select(inputSlot)
        local itemDetail = turtle.getItemDetail()
        if itemDetail ~= nil then -- item present
            if itemDetail.name == inputItem then -- unknown item found
                break  -- correct item, end
            else
                error("Predmet neodpovida pozadovanemu vstupu. Sprav to!")
            end
        else
            suck(inputSlot, inputSide)
            sleep(1)
        end
    end
end

local function switchRoutine(outputItem, outputSide, outputSlot)
    while true do
        local isPresent, itemDetail = turtle.inspect()
        if isPresent then
            if itemDetail.name == outputItem then
                turtle.dig()
                turtle.place()
                eject(outputSlot, outputSide)
            end
        else
            turtle.place()
        end

        if turtle.getItemCount() == 0 then
            break
        else
            turtle.turnRight()
            sleep(1)
        end
    end
end

-- main
print("Running CLAYMAN "..version)
while true do
    getInputItem(inputItem, inputSide, inputSlot)

    switchRoutine(outputItem, outputSide, outputSlot)

    sleep(1)
end
