--- Downloader uses two types of manifests.
---
--- Registry manifest files:
---   File contains information about available applications
---   and paths to their app manifests in the repository.
---   Contract:
---   return = {
---     <app_name> = {
---       file = <manifest_file_name>,
---       repoPath = <path_in_repository>
---     }
---   }
---
--- App manifest files:
---   File contains information about an application
---   and all files required for successful installation and run.
---   Contract:
---   return = {
---     files = {
---       {
---         file = <file_name>,
---         repoPath = <path_in_repository>,
---         path = <path_on_cc_t_disk>
---       }
---     }
---   }

local Downloader = {}
Downloader.__index = Downloader

local basicUrlPattern = "[a-z]*://[^ >,;]*"

---@private
--- Very simple url validation
local function validateUrl(url)
    local matchResult = string.match(url, basicUrlPattern)
    return assert(matchResult, "Provided URL is invalid")
end

function Downloader:new()
    local o = {}
    setmetatable(o, self)
    o.manifests = {}
    return o
end

---@param fileInfo { file:string, repoPath:string}
function Downloader:getAbsoluteUrl(fileInfo)
    if type(fileInfo) ~= "table" then
        error("Invalid argument fileInfo. Expected \"table\", got" .. type(fileInfo))
    end
    return self.repoUrl .. "/" .. fileInfo.repoPath .. "/" .. fileInfo.file --TODO check if any string already contains slashes
end

--- Sets repository url. Common format to support branches is:
--- https://raw.githubusercontent.com/<user>/<repository>/refs/heads
function Downloader:setRepoUrl(repoUrl)
    repoUrl = validateUrl(repoUrl)
    self.repoUrl = repoUrl
end

function Downloader:getRepoUrl()
    return self.repoUrl
end

---@param manifest { file:string, repoPath:string}
function Downloader:addManifest(manifest)
    assert(type(manifest) == "table" and type(manifest.file) == "string" and type(manifest.repoPath) == "string",
            "Invalid argument manifest. Expected \"{ file:string, repoPath:string }\", got " .. type(manifest))
    table.insert(self.manifests, manifest)
end

---@private
---@param fileInfo { file:string, repoPath:string, path:string}
function Downloader:saveFile(fileInfo, content)
    local contentType = type(content)
    assert(type(fileInfo.file) == "string" and type(fileInfo.path) == "string", "Invalid argument: fileInfo has incorrect format. Expected \"{ file:string, repoPath:string }\"")
    assert(#fileInfo.file > 0 and #fileInfo.path > 0, "Invalid argument: fileInfo.file and fileInfo.path has to be not empty string")
    assert(contentType == "string" or contentType == "table", "Invalid argument: convent has invalid type. Expected \"string\" or \"table\", was "..contentType)

    if contentType == "table" then
        content = textutils.serialize(content)
    end

    local cursor = fs.open(fs.combine(fileInfo.path, fileInfo.file),"w")
    cursor.write(content)
    cursor.close()
end

---@private
---@param fileInfo { file:string, repoPath:string, path:string}
function Downloader:downloadFile(fileInfo)
    local url = self:getAbsoluteUrl(fileInfo)
    local request = assert(http.get(url), "Failed to download ".. url)
    local content = request.readAll()
    request.close()
    return content
end

---@private
---@param files { ...:{file:string, repoPath:string, path:string} }
function Downloader:downloadFiles(files)
    assert(type(files) == "table" and #files > 0, "Invalid argument: files type required numerically indexed \"table\", was:" .. type(files))
    for i, fileInfo in ipairs(files) do
        print("Downloading file ["..i .. "/" .. #files .."]:", fileInfo.file)
        local content = self:downloadFile(fileInfo)
        self:saveFile(fileInfo, content)
    end
end

---@private
function Downloader:downloadManifest(manifest)
    local manifestContent = self:downloadFile({ file = manifest.file or "manifest.lua", repoPath = manifest.repoPath }, false)
    manifest.content = load(manifestContent, "manifest: "..manifest.file, "t", {})()
end

---@param app string app name to download
function Downloader:downloadApp(app)
    local argType = type(app)
    assert(argType == "string", "Invalid argument: app type required \"string\", was:" .. type(app))
    print("Downloading app:", app)
    local appManifest

    -- find app in registry manifest
    for _, manifest in ipairs(self.manifests) do
        if manifest.content == nil then
            self:downloadManifest(manifest)
        end

        if manifest.content[app] ~= nil then
            appManifest = manifest.content[app]
            break
        end
    end

    if appManifest == nil then
        print("App", app, "was not found in any root manifest. Skipping...")
        return
    end

    self:downloadManifest(appManifest)

    self:downloadFiles(appManifest.content.files)
    print("Downloading app:", app, "complete")
end

---@param apps { ...:string } table containing string names of apps to download
function Downloader:downloadApps(apps)
    assert(type(apps) == "table", "Invalid argument: apps type required \"table\", was:" .. type(apps))
    for _, app in ipairs(apps) do
        self:downloadApp(app)
    end
end

--- Compiles apps available from registry manifests
function Downloader:getAvailableApps()
    local info = {}

    for _, manifest in ipairs(self.manifests) do
        if manifest.content == nil then
            self:downloadManifest(manifest)
        end
        local apps = {}
        for app,_ in pairs(manifest.content)do
            table.insert(apps, app)
        end
        table.insert(info, apps)
    end

    return info
end

return Downloader