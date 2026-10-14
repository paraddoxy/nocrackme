ocal function loadLibrary()
    local G = getgenv()
    
    G.TK = G.TK or {}
    G.TK.Players = game:GetService("Players")
    G.TK.RunService = game:GetService("RunService")
    G.TK.UIS = game:GetService("UserInputService")
    G.TK.Lighting = game:GetService("Lighting")
    G.TK.Tween = game:GetService("TweenService")
    G.TK.plr = G.TK.Players.LocalPlayer
    G.TK.cam = workspace.CurrentCamera
    G.TK.mouse = G.TK.plr:GetMouse()
    
    G.TK.VERSION = "v1.8"
    G.TK.EXECUTOR = "Unknown"
    pcall(function()
        if identifyexecutor then G.TK.EXECUTOR = identifyexecutor() end
    end)
    
    
    print("[TK] Library loaded")
end

loadLibrary()
