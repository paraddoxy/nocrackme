--[[
    TOLKAHACK LOADER
    Загружает ThUI1 + ThUI2 + ThUI3 с GitHub
--]]

local BASE_URL = "https://raw.githubusercontent.com/paraddoxy/nocrackme/main/"

local PARTS = {
    "ThUI1.lua",
    "ThUI2.lua",
    "ThUI3.lua",
}

local function fetchPart(name)
    local url = BASE_URL .. name
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not code or code == "" then
        return nil, "не удалось скачать " .. name
    end
    -- GitHub может вернуть 404-страницу — проверяем по размеру
    if #code < 50 then
        return nil, "файл пустой или не найден: " .. name
    end
    return code
end

local function runPart(name)
    local code, err = fetchPart(name)
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

print("[LOADER] Загружаю Tolkahack с GitHub...")

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

-- Запуск частей по очереди
local success = 0
for _, part in ipairs(PARTS) do
    if runPart(part) then
        success = success + 1
        print("[LOADER] OK — " .. part)
    else
        warn("[LOADER] FAIL — " .. part)
    end
    task.wait(0.15)
end

if success == #PARTS then
    print("[LOADER] Tolkahack загружен! (" .. success .. "/" .. #PARTS .. ")")
else
    warn("[LOADER] Загружено только " .. success .. " из " .. #PARTS .. " частей")
end
