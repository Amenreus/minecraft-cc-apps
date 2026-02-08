local version = "1.0.0"

print("Pochodne verze " .. version)
print("Pokladam pochodne, sleduj!")

while true do
    for i = 1,4 do

        -- Kontrola mista pred sebou
        while turtle.detect() do
            print("Neflakej se a kopej, nemam kam jet!")
            sleep(10)
        end
        
        -- Kontrola paliva
        while turtle.getFuelLevel() < 1 do
            print("Doslo palivo")
            for j = 1,16 do
                turtle.select(j)
                turtle.refuel()
            end
            if turtle.getFuelLevel() < 1 then
                print("Potrebovat nakrmit!")
                sleep(10)
            end
        end
        
        -- Umisteni pochodne
        if i == 1 then
            slotsChecked = 0
            while turtle.getItemCount() < 1 do
                turtle.select((turtle.getSelectedSlot() % 16) + 1)
                slotsChecked = slotsChecked + 1
                if slotsChecked >= 16 then
                    slotsChecked = 0
                    print("Potrebuju vic pochodni!")
                    sleep(10)
                end
            end
            while not turtle.placeDown() do
                print("Hej, neco mi tam dole prekazi, dej to pryc!")
                print("... nebo tam neco chybi, proste mi nejde polozit ta zatracena pochoden!")
                sleep(10)
            end
        end

        -- Pohyb vpred
        while not turtle.forward() do
            print("Prekazis, uhni!")
            sleep(10)
        end
    end
end
