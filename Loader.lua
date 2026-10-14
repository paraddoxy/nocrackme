--[[
    TOLKAHACK LOADER
    Загружает ThUI1 + ThUI2 + ThUI3 в один скрипт
--]]

local PARTS = {"ThUI1.lua", "ThUI2.lua", "ThUI3.lua"}
local FOLDER = "" -- если файлы лежат в Takay/ — поменяй на "Takay/"

local function loadPart(name)
    local path = FOLDER .. name
    if not isfile(path) then
        return nil, "файл не найден: " .. path
    end
    local ok, code = pcall(readfile, path)
    if not ok then return nil, "не удалось прочитать" end
    return code
end

local function runPart(name)
    local code, err = loadPart(name)
    if not code then
        warn("[LOADER] " .. name .. " — " .. tostring(err))
        return false
    end
    local fn, err2 = loadstring(code, name)
    if not fn then
        warn("[LOADER] " .. name .. " синтаксис: " .. tostring(err2))
        return false
    end
    local ok, err3 = pcall(fn)
    if not ok then
        warn("[LOADER] " .. name .. " ошибка: " .. tostring(err3))
        return false
    end
    return true
end

print("[LOADER] Загружаю Tolkahack...")

-- Очистка старых запусков
pcall(function()
    if getgenv().TK then
        if getgenv().TK.gui then getgenv().TK.gui:Destroy() end
        if getgenv().TK.wmGui then getgenv().TK.wmGui:Destroy() end
        if getgenv().TK.sushiGui then getgenv().TK.sushiGui:Destroy() end
        if getgenv().TK.keyGui then getgenv().TK.keyGui:Destroy() end
    end
end)
getgenv().TK = nil

-- Запуск
local success = 0
for _, part in ipairs(PARTS) do
    if runPart(part) then
        success = success + 1
        print("[LOADER] OK " .. part)
    else
        warn("[LOADER] FAIL " .. part)
    end
    task.wait(0.1)
end

if success == #PARTS then
    print("[LOADER] Tolkahack загружен! (" .. success .. "/" .. #PARTS .. ")")
else
    warn("[LOADER] Загружено только " .. success .. " из " .. #PARTS .. " частей")
end
