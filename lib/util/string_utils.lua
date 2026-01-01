local StringUtils = {}

function StringUtils.split(inputString, separator)
    separator = separator or '%s'
    local t={}
    for field,s in string.gmatch(inputString, "([^"..separator.."]*)("..separator.."?)") do
        table.insert(t,field)
        if s=="" then
            return t
        end
    end
end

function StringUtils.splitLines(text, length)
    if type(text) ~= "string" then return nil end
    if type(length) ~= "number" or length < 1 then return nil end

    local words = StringUtils.split(text)
    local result = {}

    local line = ""
    local len = 0

    for i = 1, #words do
        local word = words[i]
        local wordLen = #word

        if wordLen > length then
            print("Word [", word,"] is longer than a requested line length! Using fallback.")
            if len > 0 then
                table.insert(result, line)
            end
            table.insert(result, word)
            line = ""
            len = 0
        end

        local extra = (len == 0) and wordLen or (wordLen + 1)

        if len + extra <= length then
            if len == 0 then
                line = word
                len = wordLen
            else
                line = line .. " " .. word
                len = len + wordLen + 1
            end
        else
            table.insert(result, line)
            line = word
            len = wordLen
        end
    end

    if line ~= "" then
        table.insert(result, line)
    end

    return result
end

return StringUtils