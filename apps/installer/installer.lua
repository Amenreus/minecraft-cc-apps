local tArgs = {...}

local downloaderUrl = "https://raw.githubusercontent.com/Amenreus/minecraft-cc-apps/refs/heads/main/lib/util/downloader.lua"
local repoUrl = "https://raw.githubusercontent.com/Amenreus/minecraft-cc-apps/refs/heads"
local manifest = {
    file = "manifest.lua",
    repoPath = "main"
}

package.path = package.path..";/?"..";/?.lua"
local downloaderLoaded, Downloader = pcall(require,"lib.util.downloader")
local downloader

local function initDownloader()
    if not downloaderLoaded then
        local request = assert(http.get(downloaderUrl), "Couldn't connect to repository.")
        local content = request.readAll()
        request.close()
        local chunk = assert(load(content,"Installer", "t", _G), "Unable to load downloader library!")
        Downloader = chunk()
    end

    downloader = Downloader:new()
    downloader:setRepoUrl(repoUrl)
    downloader:addManifest(manifest)
end

local function printMenu()
    print("Interactive mode not supported yet. Please, use \"wget run\" and pass apps you want as a parameter")
    -- print("Choose an app to install")
    --TODO Implement
end

local function main(args)
    assert(http, "Http module is not enabled in CC:T config.")
    initDownloader()

    if #args > 0 then
        -- automatic mode
        downloader:downloadApps(args)
    else
        -- interactive mode
        printMenu()
    end
end

main(tArgs)