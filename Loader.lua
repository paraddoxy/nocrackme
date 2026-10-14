--[[
    TOLKAHACK LOADER
    Загружает все части в один скрипт.
    
    ВАРИАНТ A — локально: положи PART1-3 в workspace/Takay/ и запусти этот файл
    ВАРИАНТ B — с GitHub: залей PART1-3 в репо и замени GITHUB_URL
--]]

local GITHUB_URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПО/main/" -- если используешь GitHub

local MODE = "local" -- "local" или "github"

local PARTS = {"PART1.lua", "PART2.lua", "PART3.lua"}
local FOLDER = "Takay/" -- только для локального режима

local function loadPart(name)
    local code
    if MODE == "github" then
        local ok, res = pcall(function() return game:HttpGet(GITHUB_URL .. name) end)
        if not ok then return nil, "не удалось скачать с GitHub" end
        code = res
    else
        if not isfile(FOLDER .. name) then
            return nil, "файл не найден: " .. FOLDER .. name
        end
        local ok, res = pcall(readfile, FOLDER .. name)
        if not ok then return nil, "не удалось прочитать файл" end
        code = res
    end
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
    if getgenv().TK and getgenv().TK.gui then getgenv().TK.gui:Destroy() end
    if getgenv().TK and getgenv().TK.wmGui then getgenv().TK.wmGui:Destroy() end
    if getgenv().TK and getgenv().TK.sushiGui then getgenv().TK.sushiGui:Destroy() end
    if getgenv().TK and getgenv().TK.keyGui then getgenv().TK.keyGui:Destroy() end
end)
getgenv().TK = nil

-- Запуск
local success = 0
for _, part in ipairs(PARTS) do
    if runPart(part) then
        success = success + 1
        print("[LOADER] ✓ " .. part)
    else
        warn("[LOADER] ✗ " .. part)
    end
    task.wait(0.1)
end

if success == #PARTS then
    print("[LOADER] Tolkahack успешно загружен! (" .. success .. "/" .. #PARTS .. ")")
else
    warn("[LOADER] Загружено только " .. success .. " из " .. #PARTS .. " частей")
end
