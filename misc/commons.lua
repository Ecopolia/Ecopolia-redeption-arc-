function hex(hex)
    if #hex <= 6 then
        hex = hex .. "FF"
    end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255}
    return color
end

function stripTags(text)
    return text:gsub("%[.-%]", "")
end

function ManualtransitionOut()
    G.TRANSITION = 1
    Timer.tween(2, G, {
        TRANSITION = 0
    }, 'in-out-cubic', function()
        G.TRANSITION = 0
    end)
end

function ManualtransitionIn()
    G.TRANSITION = 0
    Timer.tween(2, G, {
        TRANSITION = 1
    }, 'in-out-cubic', function()
        G.TRANSITION = 1
    end)
end

function math.round(n, deci)
    deci = 10 ^ (deci or 0)
    return math.floor(n * deci + .5) / deci
end

function printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. ":")
            printTable(v, indent .. "  ")
        else
            print(indent .. k .. ": " .. tostring(v))
        end
    end
end

function formatPlaytime(seconds)
    if not seconds then
        return "00:00:00"
    end
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    seconds = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local random = math.random
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function findbyid(array, id)
    for key, value in ipairs(array) do 
        if value.id == id then
            return value
        end
    end
end