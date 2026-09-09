-- Steal An Egg | Custom Speed & Auto-Farm Script
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Steal An Egg | Delta Hub", HidePremium = false, SaveConfig = false, IntroText = "Steal An Egg"})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CustomSpeed = 0
local AutoSteps = false

-- 1. НАСТРОЙКА СКОРОСТИ (0 = Обычная, 1-50000 = Настраиваемая)
local SpeedTab = Window:MakeTab({Name = "Скорость", Icon = "rbxassetid://4483345998", PremiumOnly = false})

SpeedTab:AddSlider({
    Name = "Уровень Скорости",
    Min = 0,
    Max = 50000,
    Default = 0,
    Color = Color3.fromRGB(0, 255, 128),
    Increment = 100,
    ValueName = "Speed",
    Callback = function(Value)
        CustomSpeed = Value
    end    
})

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if CustomSpeed > 0 then
                    LocalPlayer.Character.Humanoid.WalkSpeed = CustomSpeed
                end
            end
        end)
    end
end)

-- 2. АВТО-ФАРМ ШАГОВ (БЕЗ ДОРОЖКИ)
local FarmTab = Window:MakeTab({Name = "Авто-Фарм", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FarmTab:AddToggle({
    Name = "Авто-фарм шагов (без беговой дорожки)",
    Default = false,
    Callback = function(Value)
        AutoSteps = Value
        task.spawn(function()
            while AutoSteps do
                task.wait(0.05)
                pcall(function()
                    -- Отправка сигналов тренировки напрямую на сервер
                    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                        if v:IsA("RemoteEvent") and (string.find(v.Name:lower(), "train") or string.find(v.Name:lower(), "step") or string.find(v.Name:lower(), "treadmill") or string.find(v.Name:lower(), "addspeed")) then
                            v:FireServer()
                        end
                    end
                    -- Эмуляция движения для качания шагов
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid:Move(Vector3.new(0.05, 0, 0.05), true)
                    end
                end)
            end
        end)
    end
})

-- 3. ТЕЛЕПОРТ К МОЩНЫМ / МУТИРОВАННЫМ ЯЙЦАМ
local TPTab = Window:MakeTab({Name = "Телепорты", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local function TeleportToRareEgg()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local foundEgg = nil
    local rareKeywords = {"titan", "mutant", "rainbow", "spirit", "cherry", "colossus", "giant", "huge", "gold", "shattered"}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objName = obj.Name:lower()
            for _, kw in pairs(rareKeywords) do
                if string.find(objName, kw) and (string.find(objName, "egg") or string.find(objName, "nest")) then
                    foundEgg = obj
                    break
                end
            end
        end
        if foundEgg then break end
    end
    
    if foundEgg then
        local targetCFrame = foundEgg:IsA("Model") and foundEgg:GetPivot() or foundEgg.CFrame
        hrp.CFrame = targetCFrame + Vector3.new(0, 4, 0)
        OrionLib:MakeNotification({Name = "Успех", Content = "ТП к яйцу: " .. foundEgg.Name, Time = 3})
    else
        OrionLib:MakeNotification({Name = "Ошибка", Content = "Мощное яйцо не найдено!", Time = 3})
    end
end

TPTab:AddButton({
    Name = "ТП к мутантному яйцу",
    Callback = function()
        TeleportToRareEgg()
    end
})

OrionLib:Init()
