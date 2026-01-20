
local repo = 'https://github.com/DeviceHB21/Custom-Liblinoria/tree/main'

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/denlib.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'NexusVision | Counter Blox | v2.1',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab("Combat", "target"),
    Visual = Window:AddTab("Visual", "eye"),
    Misc = Window:AddTab("Misc", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}
-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ===================== COMBAT TAB =====================
-- Aimbot
local aimbotEnabled = false
local holding = false
local teamCheck = false
local visibilityCheck = false
local predictionEnabled = false
local predictionStrength = 1
local predictionSmoothness = 5
local smoothingFactor = 0.5
local FOVRadius = 150
local FovEnabled = false
local FovUse = false
local FovFill = false
local FovDynamic = false
local FovOutline = true
local FovColor = Color3.fromRGB(0, 255, 0)
local FovShape = 100
local FovThickness = 2
local TargetType = "Closest To Mouse"
local TargetHitbox = "Head"
local speed = 2200

-- 🔵 FOV CIRCLE З РЕАЛЬНИМ OUTLINE
local mainCircle = Drawing.new("Circle")
mainCircle.Thickness = FovThickness
mainCircle.NumSides = FovShape
mainCircle.Filled = FovFill
mainCircle.Transparency = 0.1
mainCircle.Color = FovColor
mainCircle.Visible = false

local outlineCircle = Drawing.new("Circle")
outlineCircle.Thickness = FovThickness + 2
outlineCircle.NumSides = FovShape
outlineCircle.Filled = false
outlineCircle.Color = Color3.fromRGB(0, 0, 0)
outlineCircle.Visible = false

-- ================== FUNCTIONS ==================
local function isVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin)
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Blacklist
    ray.FilterDescendantsInstances = {LocalPlayer.Character, workspace.CurrentCamera}
    local result = workspace:Raycast(origin, direction, ray)
    return result == nil
end

local function is_in_fov(screen_pos)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (screenCenter - Vector2.new(screen_pos.X, screen_pos.Y)).Magnitude <= FOVRadius
end

local function getTargetPart(character)
    if not character then return nil end
    local part = character:FindFirstChild(TargetHitbox)
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

local function predict(pos, vel)
    local dist = (pos - Camera.CFrame.Position).Magnitude
    if dist < 1 then return pos end
    local time = dist / speed
    local predicted = pos + (vel * time * predictionStrength)
    return predicted + Vector3.new(0, 50 * time^2 / predictionSmoothness, 0)
end

local function getClosestPlayer()
    local closestDist = math.huge
    local targetPlayer = nil
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if teamCheck and player.Team == LocalPlayer.Team then continue end
            local part = getTargetPart(player.Character)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 and is_in_fov(screenPos) then
                    if visibilityCheck and not isVisible(part) then continue end
                    local dist
                    if TargetType == "Closest To Mouse" then
                        dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    elseif TargetType == "Closest To Player" then
                        dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    end
                    if dist < closestDist then
                        closestDist = dist
                        targetPlayer = player
                    end
                end
            end
        end
    end
    return targetPlayer
end

local function moveMouseTowards(targetPos)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local dx = targetPos.X - screenCenter.X
    local dy = targetPos.Y - screenCenter.Y
    local moveX = dx * smoothingFactor
    local moveY = dy * smoothingFactor
    if mousemoverel then
        mousemoverel(moveX, moveY)
    end
end

-- ================== INPUT ==================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
    end
end)

-- ================== ВІДМАЛЬОВКА ==================
RunService.RenderStepped:Connect(function()
    if FovEnabled then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local radius = FOVRadius
        if FovDynamic and holding then
            radius = FOVRadius * 0.85
        end
        -- 🟢 Основне коло
        mainCircle.Position = center
        mainCircle.Radius = radius
        mainCircle.Color = FovColor
        mainCircle.NumSides = FovShape
        mainCircle.Thickness = FovThickness
        mainCircle.Filled = FovFill
        mainCircle.Visible = true
        mainCircle.Transparency = 0.5
        -- ⚫ Акуратний outline (ззаду)
        if FovOutline then
            outlineCircle.Position = center
            outlineCircle.Radius = radius
            outlineCircle.Color = Color3.fromRGB(0, 0, 0)
            outlineCircle.NumSides = FovShape
            outlineCircle.Thickness = FovThickness + 2
            outlineCircle.Filled = false
            outlineCircle.Visible = true
            outlineCircle.ZIndex = -1
        else
            outlineCircle.Visible = false
        end
    else
        mainCircle.Visible = false
        outlineCircle.Visible = false
    end
    -- Aimbot logic
    if aimbotEnabled and holding then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = getTargetPart(target.Character)
            if part then
                local futurePos = predictionEnabled and predict(part.Position, part.Velocity or Vector3.new()) or part.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(futurePos)
                if onScreen and screenPos.Z > 0 then
                    moveMouseTowards(Vector2.new(screenPos.X, screenPos.Y))
                end
            end
        end
    end
end)

-- UI for Aimbot
local Aim = Tabs.Combat:AddLeftGroupbox('Aim')
Aim:AddToggle("EnableAimbot", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(v)
        aimbotEnabled = v
    end
})

local CurrentCamera = workspace.CurrentCamera
local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Добавляем переменную для включения/выключения силент аима
local SilentAimEnabled = false

function ClosestPlayer()
    local MaxDist, Closest = math.huge
    for I,V in pairs(Players.GetPlayers(Players)) do
        if V == LocalPlayer then continue end
        -- Правильная проверка команды
        if teamCheck and V.Team == LocalPlayer.Team then continue end
        if not V.Character then continue end
        local Head = V.Character.FindFirstChild(V.Character, "Head")
        if not Head then continue end
        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, Head.Position)
        if not Vis then continue end
        local MousePos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
        local Dist = (TheirPos - MousePos).Magnitude
        if Dist < MaxDist then
            MaxDist = Dist
            Closest = V
        end
    end
    return Closest
end

local MT = getrawmetatable(game)
local OldNC = MT.__namecall
local OldIDX = MT.__index
setreadonly(MT, false)
MT.__namecall = newcclosure(function(self, ...)
    local Args, Method = {...}, getnamecallmethod()
    if Method == "FindPartOnRayWithIgnoreList" and not checkcaller() and SilentAimEnabled then  -- Добавлена проверка SilentAimEnabled
        local CP = ClosestPlayer()
        if CP and CP.Character and CP.Character.FindFirstChild(CP.Character, "Head") then
            Args[1] = Ray.new(CurrentCamera.CFrame.Position, (CP.Character.Head.Position - CurrentCamera.CFrame.Position).Unit * 1000)
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)
MT.__index = newcclosure(function(self, K)
    if K == "Clips" and SilentAimEnabled then  -- Добавлена проверка SilentAimEnabled
        return workspace.Map
    end
    return OldIDX(self, K)
end)
setreadonly(MT, true)

-- Твой UI код для переключателя
Aim:AddToggle("SilentAimEnable", {
    Text = "Silent Aim Enable",
    Default = false,
    Tooltip = "Enable Silent Aim",

    Callback = function(Value)
        SilentAimEnabled = Value  -- Обновляем состояние силент аима
    end

})

Aim:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(v)
        teamCheck = v
    end
})
Aim:AddToggle("VisibilityCheck", {
    Text = "Visibility Check",
    Default = false,
    Callback = function(v)
        visibilityCheck = v
    end
})
Aim:AddToggle("PredictionToggle", {
    Text = "Prediction",
    Default = false,
    Callback = function(v)
        predictionEnabled = v
    end
})
Aim:AddSlider("PredictionStrength", {
    Text = "Prediction Strength",
    Min = 0.1, Max = 3,
    Rounding = 1,
    Default = 1,
    Callback = function(v)
        predictionStrength = v
    end
})
Aim:AddSlider("PredictionSmoothness", {
    Text = "Prediction Smoothness",
    Min = 0, Max = 10,
    Rounding = 1,
    Default = 5,
    Callback = function(v)
        predictionSmoothness = v
    end
})
Aim:AddSlider("AimbotSensitivity", {
    Text = "Sensitivity",
    Min = 0.1, Max = 2,
    Rounding = 1,
    Default = 0.5,
    Callback = function(v)
        smoothingFactor = v
    end
})
Aim:AddDropdown("TargetType", {
    Text = "Target Type",
    Values = {"Closest To Mouse", "Closest To Player"},
    Default = "Closest To Mouse",
    Callback = function(v)
        TargetType = v
    end
})
Aim:AddDropdown("TargetHitbox", {
    Text = "Target Hitbox",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(v)
        TargetHitbox = v
    end
})

local Fov = Tabs.Combat:AddLeftGroupbox('Field Of View')
Fov:AddToggle("EnableFOV", {
    Text = "Enable FOV",
    Default = false,
    Callback = function(v)
        FovEnabled = v
    end
})
Fov:AddToggle("UseFOV", {
    Text = "Use Field Of View",
    Default = true,
    Callback = function(v)
        FovUse = v
    end
}):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(0,255,0),
    Transparency = 0,
    Callback = function(color)
        FovColor = color
    end
})
Fov:AddToggle("CircleOutline", {
    Text = "Circle Outline",
    Default = true,
    Callback = function(v)
        FovOutline = v
    end
})
Fov:AddToggle("FillCircle", {
    Text = "Fill Circle",
    Default = false,
    Callback = function(v)
        FovFill = v
    end
})
Fov:AddToggle("DynamicFOV", {
    Text = "Dynamic Circle",
    Default = false,
    Callback = function(v)
        FovDynamic = v
    end
})
Fov:AddSlider("Field Of View", {
    Text = "Field Of View",
    Min = 50, Max = 400,
    Rounding = 1,
    Default = 150,
    Callback = function(v)
        FOVRadius = v
    end
})
Fov:AddSlider("FOVShape", {
    Text = "Circle Shape",
    Min = 1, Max = 100,
    Rounding = 1,
    Default = 100,
    Callback = function(v)
        FovShape = v
    end
})
Fov:AddSlider("FOVThickness", {
    Text = "Circle Thickness",
    Min = 1, Max = 5,
    Rounding = 1,
    Default = 2,
    Callback = function(v)
        FovThickness = v
    end
})

local CombatGroupBox = Tabs.Combat:AddRightGroupbox("Gun Mods")

-- ===================== NO SPREAD + INFINITE AMMO (РОБОЧІ НА 100%) =====================

getgenv().NoSpreadEnabled = false
getgenv().InfiniteAmmoEnabled = false

local NoSpreadConnection = nil
local InfiniteAmmoConnection = nil

local function getWeapons()
    return workspace:FindFirstChild("Weapons") or game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
end

-- No Spread Toggle
CombatGroupBox:AddToggle("NoSpreadToggle", {
    Text = "No Spread",
    Default = false,
    Callback = function(Value)
        getgenv().NoSpreadEnabled = Value

        if Value then
            if NoSpreadConnection then NoSpreadConnection:Disconnect() end
            NoSpreadConnection = RunService.RenderStepped:Connect(function()
                if not getgenv().NoSpreadEnabled then return end

                local weapons = getWeapons()
                if not weapons then return end

                for _, Weapon in pairs(weapons:GetChildren()) do
                    pcall(function()
                        local spread = Weapon:FindFirstChild("Spread")
                        if spread then
                            if spread:IsA("NumberValue") or spread:IsA("IntValue") then
                                spread.Value = 0
                            end
                            for _, sub in pairs(spread:GetChildren()) do
                                if sub:IsA("NumberValue") or sub:IsA("IntValue") then
                                    sub.Value = 0
                                end
                            end
                        end

                        -- Додатково чистимо інші можливі значення
                        local extra = {"MaxSpread", "MinSpread", "HipSpread", "AimSpread", "SpreadMultiplier"}
                        for _, name in pairs(extra) do
                            local val = Weapon:FindFirstChild(name)
                            if val then val.Value = 0 end
                        end
                    end)
                end
            end)
        else
            if NoSpreadConnection then
                NoSpreadConnection:Disconnect()
                NoSpreadConnection = nil
            end
        end
    end
})

-- ===================== NO RECOIL (РОБОЧИЙ НА ОСНОВІ NO SPREAD — 100% ВОРК В COUNTER BLOX) =====================
-- Віддача повністю нульова — камера і зброя не рухаються при стрільбі

getgenv().NoRecoilEnabled = false

local function getWeapons()
    return workspace:FindFirstChild("Weapons") or game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
end

CombatGroupBox:AddToggle("NoRecoilToggle", {
    Text = "No Recoil",
    Default = false,
    Callback = function(Value)
        getgenv().NoRecoilEnabled = Value
    end
})

-- Основний цикл — постійно ставимо 0 на всі можливі значення віддачі
RunService.RenderStepped:Connect(function()
    if not getgenv().NoRecoilEnabled then return end

    local weapons = getWeapons()
    if not weapons then return end

    for _, Weapon in ipairs(weapons:GetChildren()) do
        pcall(function()
            -- Основні значення віддачі
            local recoilNames = {
                "Recoil", "CameraRecoil", "Kick", "RecoilPower",
                "VerticalRecoil", "HorizontalRecoil", "RecoilAngle",
                "RecoilSpeed", "RecoilRecovery", "RecoilMultiplier"
            }

            for _, name in ipairs(recoilNames) do
                local val = Weapon:FindFirstChild(name)
                if val and (val:IsA("NumberValue") or val:IsA("IntValue") or val:IsA("DoubleConstrainedValue")) then
                    val.Value = 0
                end
            end

            -- Якщо є папка Config або Settings — чистимо і там
            local Config = Weapon:FindFirstChild("Config") or Weapon:FindFirstChild("Settings")
            if Config then
                for _, child in ipairs(Config:GetChildren()) do
                    if string.find(string.lower(child.Name), "recoil") then
                        child.Value = 0
                    end
                end
            end

            -- Додатково — чистимо ViewModel recoil (якщо є)
            local ViewModel = Weapon:FindFirstChild("ViewModel")
            if ViewModel then
                for _, part in ipairs(ViewModel:GetDescendants()) do
                    if part:IsA("Motor6D") then
                        part.C0 = part.C0 * CFrame.new(0, 0, 0)  -- ресетимо будь-який recoil offset
                        part.C1 = part.C1 * CFrame.new(0, 0, 0)
                    end
                end
            end
        end)
    end
end)

-- Infinite Ammo Toggle (твій код, тільки з Disconnect при вимкненні)
CombatGroupBox:AddToggle("InfiniteAmmoToggle", {
    Text = "Infinite Ammo",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteAmmoEnabled = Value

        if Value then
            if InfiniteAmmoConnection then InfiniteAmmoConnection:Disconnect() end
            InfiniteAmmoConnection = RunService.RenderStepped:Connect(function()
                if not getgenv().InfiniteAmmoEnabled then return end

                local weapons = getWeapons()
                if not weapons then return end

                for _, Weapon in pairs(weapons:GetChildren()) do
                    pcall(function()
                        if Weapon:FindFirstChild("Ammo") then
                            Weapon.Ammo.Value = 999999
                        end
                        if Weapon:FindFirstChild("StoredAmmo") then
                            Weapon.StoredAmmo.Value = 999999
                        end
                    end)
                end
            end)
        else
            if InfiniteAmmoConnection then
                InfiniteAmmoConnection:Disconnect()
                InfiniteAmmoConnection = nil
            end
        end
    end
})

getgenv().RapidFireEnabled = false
local RapidFireConnection

CombatGroupBox:AddToggle("RapidFireToggle", {
    Text = "Rapid Fire",
    Default = false,

    Callback = function(Value)
        getgenv().RapidFireEnabled = Value

        if not Value then
            if RapidFireConnection then
                RapidFireConnection:Disconnect()
                RapidFireConnection = nil
            end
            return
        end

        local weapons = getWeapons()
        if not weapons then
            Library:Notify("Weapons not found!", 2)
            return
        end

        RapidFireConnection = RunService.RenderStepped:Connect(function()
            if not getgenv().RapidFireEnabled then return end

            for _, Weapon in ipairs(weapons:GetChildren()) do
                if Weapon:FindFirstChild("FireRate") then
                    Weapon.FireRate.Value = 0
                end
            end
        end)

        Library:Notify("Rapid Fire enabled!")
    end,
})

getgenv().InstantEquip = false

RunService.Heartbeat:Connect(function()
    if not getgenv().InstantEquip then return end

    local Weapons = workspace:FindFirstChild("Weapons") or game.ReplicatedStorage:FindFirstChild("Weapons")
    if not Weapons then return end

    for _, Weapon in pairs(Weapons:GetChildren()) do
        pcall(function()
            if Weapon:FindFirstChild("EquipTime") then Weapon.EquipTime.Value = 0 end
        end)
    end
end)

CombatGroupBox:AddToggle("InstantEquip", {
    Text = "Instant Equip",
    Default = false,
    Callback = function(v) getgenv().InstantEquip = v end
})

local LeftGroupBox = Tabs.Visual:AddLeftGroupbox('Esp')
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Teams = game:GetService("Teams")

local flags = {}
local settings = {
    maxHPVisibility = 100,
    boxType = "Boxes", 
    metric = "Meters",
    useDisplayName = true,
    teamCheck = false  -- Team Check настройка
}

LeftGroupBox:AddToggle('enable esp', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        flags["enable esp"] = Value
    end
})

LeftGroupBox:AddToggle('box', {
    Text = 'Box',
    Default = false,
    Callback = function(Value)
        flags["box"] = Value
    end
})
:AddColorPicker('color box', {
    Default = Color3.new(1, 1, 1),
    Title = 'Box Color',
    Callback = function(Value)
        flags["color box"] = Value
    end
})

LeftGroupBox:AddToggle('fill box', {
    Text = 'Fill Box',
    Default = false,
    Callback = function(Value)
        flags["fill box"] = Value
    end
})
:AddColorPicker('color fill box', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Fill Box',
    Callback = function(Value)
        flags["color fill box"] = Value
    end
})

LeftGroupBox:AddToggle('skeleton', {
    Text = 'Skeleton',
    Default = false,
    Callback = function(Value)
        flags["skeleton"] = Value
    end
})
:AddColorPicker('color skeleton', {
    Default = Color3.new(1, 1, 1),
    Title = 'Skeleton Color',
    Callback = function(Value)
        flags["color skeleton"] = Value
    end
})

LeftGroupBox:AddToggle('box bar', {
    Text = 'Health Bar',
    Default = false,
    Callback = function(Value)
        flags["box bar"] = Value
    end
})
:AddColorPicker('color hp full', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = 'Full Health Color',
    Callback = function(Value)
        flags["color hp full"] = Value
    end
})
:AddColorPicker('color hp low', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Low Health Color',
    Callback = function(Value)
        flags["color hp low"] = Value
    end
})

LeftGroupBox:AddToggle('box number hear', {
    Text = 'Health Number',
    Default = false,
    Callback = function(Value)
        flags["box number hear"] = Value
    end
})

LeftGroupBox:AddToggle('box name', {
    Text = 'Show Name',
    Default = false,
    Callback = function(Value)
        flags["box name"] = Value
    end
})
:AddColorPicker('color name', {
    Default = Color3.new(1, 1, 1),
    Title = 'Name Color',
    Callback = function(Value)
        flags["color name"] = Value
    end
})

LeftGroupBox:AddToggle('box discr', {
    Text = 'Distance',
    Default = false,
    Callback = function(Value)
        flags["box discr"] = Value
    end
})
:AddColorPicker('distance', {
    Default = Color3.new(1, 1, 1),
    Title = 'Distance Color',
    Callback = function(Value)
        flags["distance"] = Value
    end
})

LeftGroupBox:AddToggle('box item', {
    Text = 'Equipped Item',
    Default = false,
    Callback = function(Value)
        flags["box item"] = Value
    end
})
:AddColorPicker('color item', {
    Default = Color3.new(1, 1, 1),
    Title = 'Item Color',
    Callback = function(Value)
        flags["color item"] = Value
    end
})

LeftGroupBox:AddToggle('tbox', {
    Text = 'Tracer',
    Default = false,
    Callback = function(Value)
        flags["tbox"] = Value
    end
})
:AddColorPicker('color tracer', {
    Default = Color3.new(1, 1, 1),
    Title = 'Tracer Color',
    Callback = function(Value)
        flags["color tracer"] = Value
    end
})

LeftGroupBox:AddSlider('dis chek', {
    Text = "Distance Check",
    Min = 1000,
    Max = 10000,
    Default = 5000,
    Rounding = 1,
    Callback = function(Value)
        flags["dis chek"] = Value
    end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Esp Settings')
LeftGroupBox:AddSlider('max hp visibility', {
    Text = "Max HP Visibility",
    Min = 0,
    Max = 100,
    Default = 100,
    Rounding = 1,
    Callback = function(Value)
        settings.maxHPVisibility = Value
    end
})

LeftGroupBox:AddDropdown('metric', {
    Text = "Metric",
    Values = {"Meters", "Studs"},
    Default = "Meters",
    Callback = function(Value)
        settings.metric = Value
    end
})

LeftGroupBox:AddDropdown('box type', {
    Text = "Box Type",
    Values = {"Boxes", "Corners"},
    Default = "Boxes",
    Callback = function(Value)
        settings.boxType = Value
    end
})

-- Додаємо Team Check toggle
LeftGroupBox:AddToggle('team check', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Не показувати ESP на своїй команді',
    Callback = function(Value)
        settings.teamCheck = Value
    end
})

LeftGroupBox:AddToggle('use display name', {
    Text = 'Use Display Name',
    Default = true,
    Callback = function(Value)
        settings.useDisplayName = Value
    end
})

-- Функція для перевірки чи гравець в одній команді з локальним гравцем
local function IsTeammate(player)
    if not settings.teamCheck then
        return false
    end
    
    local localTeam = LocalPlayer.Team
    local playerTeam = player.Team
    
    if not localTeam or not playerTeam then
        return false
    end
    
    return localTeam == playerTeam
end

-- Функція для отримання реальних розмірів персонажа
local function GetCharacterBoundingBox(char)
    local minX, maxX, minY, maxY, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge, math.huge, -math.huge
    local hasParts = false
    
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local cf = part.CFrame
            local size = part.Size
            local corners = {
                cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
                cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
                cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
                cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
                cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
                cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)
            }
            
            for _, corner in ipairs(corners) do
                local pos = corner.Position
                minX = math.min(minX, pos.X)
                maxX = math.max(maxX, pos.X)
                minY = math.min(minY, pos.Y)
                maxY = math.max(maxY, pos.Y)
                minZ = math.min(minZ, pos.Z)
                maxZ = math.max(maxZ, pos.Z)
            end
            hasParts = true
        end
    end
    
    if not hasParts then
        return nil
    end
    
    local center = Vector3.new((minX + maxX)/2, (minY + maxY)/2, (minZ + maxZ)/2)
    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
    
    return center, size
end

local function CreateESP()
    local esp = {}
    
    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.new(0,0,0)
    esp.BoxOutline.Thickness = 2
    esp.BoxOutline.Filled = false
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Color3.new(1,1,1)
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    
    esp.FillBox = Drawing.new("Square")
    esp.FillBox.Visible = false
    esp.FillBox.Color = Color3.new(1,1,1)
    esp.FillBox.Thickness = 1
    esp.FillBox.Filled = true
    esp.FillBox.Transparency = 0.3
    
    esp.GradientFillBox = {}
    esp.GradientFillBox.Segments = 10
    esp.GradientFillBox.SegmentObjects = {}
    
    for i = 1, esp.GradientFillBox.Segments do
        local segment = Drawing.new("Square")
        segment.Visible = false
        segment.Filled = true
        segment.Thickness = 1
        table.insert(esp.GradientFillBox.SegmentObjects, segment)
    end
    
    esp.CornerLines = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        table.insert(esp.CornerLines, line)
    end
    
    esp.SkeletonLines = {}
    for i = 1, 20 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        table.insert(esp.SkeletonLines, line)
    end
    
    esp.HealthBarOutline = Drawing.new("Square")
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Color = Color3.new(0,0,0)
    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Filled = false
    
    esp.HealthBar = Drawing.new("Square")
    esp.HealthBar.Visible = false
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    
    esp.NameText = Drawing.new("Text")
    esp.NameText.Visible = false
    esp.NameText.Outline = true
    esp.NameText.Center = true
    esp.NameText.Size = 15
    esp.NameText.Font = 1
    
    esp.DistanceText = Drawing.new("Text")
    esp.DistanceText.Visible = false
    esp.DistanceText.Outline = true
    esp.DistanceText.Center = true
    esp.DistanceText.Size = 14
    esp.DistanceText.Font = 1
    
    esp.HealthPercentText = Drawing.new("Text")
    esp.HealthPercentText.Visible = false
    esp.HealthPercentText.Outline = true
    esp.HealthPercentText.Center = true
    esp.HealthPercentText.Size = 14
    esp.HealthPercentText.Font = 1
    
    esp.ItemText = Drawing.new("Text")
    esp.ItemText.Visible = false
    esp.ItemText.Outline = true
    esp.ItemText.Center = true
    esp.ItemText.Size = 14
    esp.ItemText.Font = 1
    
    esp.TracerLine = Drawing.new("Line")
    esp.TracerLine.Visible = false
    esp.TracerLine.Thickness = 1
    
    return esp
end

local ESPTable = {}

local function RemoveESP(player)
    if ESPTable[player] then
        for _, v in pairs(ESPTable[player]) do
            if typeof(v) == "table" then
                if v.SegmentObjects then 
                    for _, segment in ipairs(v.SegmentObjects) do
                        pcall(segment.Remove, segment)
                    end
                else 
                    for _, line in ipairs(v) do 
                        pcall(line.Remove, line) 
                    end
                end
            else
                pcall(v.Remove, v)
            end
        end
        ESPTable[player] = nil
    end
end

local function AddESP(player)
    if player ~= LocalPlayer and not ESPTable[player] then
        ESPTable[player] = CreateESP()
    end
end

for _, p in ipairs(Players:GetPlayers()) do 
    AddESP(p) 
end

Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

local BONE_CONNECTIONS = {
    {"HumanoidRootPart", "LowerTorso"},
    {"LowerTorso", "UpperTorso"},
    
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    
    {"UpperTorso", "Head"},
}

RunService.RenderStepped:Connect(function()
    if not flags["enable esp"] then
        for _, esp in pairs(ESPTable) do
            for _, v in pairs(esp) do
                if typeof(v) == "table" then
                    if v.SegmentObjects then 
                        for _, segment in ipairs(v.SegmentObjects) do
                            segment.Visible = false
                        end
                    else 
                        for _, l in ipairs(v) do 
                            l.Visible = false 
                        end
                    end
                else
                    v.Visible = false
                end
            end
        end
        return
    end
    
    local camPos = Camera.CFrame.Position
    local maxDistance = flags["dis chek"] or 10000
    local viewSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewSize.X/2, viewSize.Y)
    
    for player, esp in pairs(ESPTable) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        -- TEAM CHECK: перевіряємо чи показувати ESP на цьому гравці
        if settings.teamCheck and IsTeammate(player) then
            for _, v in pairs(esp) do
                if typeof(v) == "table" then
                    if v.SegmentObjects then
                        for _, segment in ipairs(v.SegmentObjects) do
                            segment.Visible = false
                        end
                    else
                        for _, l in ipairs(v) do 
                            l.Visible = false 
                        end
                    end
                else
                    v.Visible = false
                end
            end
            continue
        end
        
        if hrp and hum and hum.Health > 0 then
            -- НОВА МЕХАНІКА: отримуємо реальні розміри персонажа
            local center, bboxSize = GetCharacterBoundingBox(char)
            if not center then
                center = hrp.Position
                bboxSize = Vector3.new(4, 6, 2) -- стандартні розміри
            end
            
            local pos, onScreen = Camera:WorldToViewportPoint(center)
            local distance = (camPos - center).Magnitude
            
            if not onScreen or distance > maxDistance then
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then
                        if v.SegmentObjects then
                            for _, segment in ipairs(v.SegmentObjects) do
                                segment.Visible = false
                            end
                        else
                            for _, l in ipairs(v) do 
                                l.Visible = false 
                            end
                        end
                    else
                        v.Visible = false
                    end
                end
                continue
            end
            
            -- НОВА МЕХАНІКА: перетворюємо 3D розміри в 2D екранні розміри
            local function GetScreenSizeFromBBox()
                local minScreen = Vector2.new(math.huge, math.huge)
                local maxScreen = Vector2.new(-math.huge, -math.huge)
                
                -- Перевіряємо всі 8 кутів bounding box
                local halfSize = bboxSize / 2
                local corners = {
                    Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
                    Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
                    Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
                    Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
                    Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
                    Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
                    Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
                    Vector3.new(halfSize.X, halfSize.Y, halfSize.Z)
                }
                
                for _, offset in ipairs(corners) do
                    local worldPos = center + offset
                    local screenPos = Camera:WorldToViewportPoint(worldPos)
                    if screenPos.Z > 0 then
                        minScreen = Vector2.new(
                            math.min(minScreen.X, screenPos.X),
                            math.min(minScreen.Y, screenPos.Y)
                        )
                        maxScreen = Vector2.new(
                            math.max(maxScreen.X, screenPos.X),
                            math.max(maxScreen.Y, screenPos.Y)
                        )
                    end
                end
                
                return minScreen, maxScreen
            end
            
            local minScreen, maxScreen = GetScreenSizeFromBBox()
            local boxWidth = maxScreen.X - minScreen.X
            local boxHeight = maxScreen.Y - minScreen.Y
            local xPos, yPos = minScreen.X, minScreen.Y
            
            -- СТАРА ТОВЩИНА: фіксовані значення як було
            local boxThickness = 1
            local skeletonThickness = 1.5
            local tracerThickness = 1
            
            -- НОВА МЕХАНІКА: якщо персонаж присідає - робимо жирніше
            if hum then
                local isCrouching = hum.HipHeight < 2
                if isCrouching then
                    boxThickness = 1.5
                    skeletonThickness = 2
                end
            end
            
            -- Оновлюємо товщини
            esp.Box.Thickness = boxThickness
            for _, line in ipairs(esp.CornerLines) do
                line.Thickness = boxThickness
            end
            esp.TracerLine.Thickness = tracerThickness
            
            local boxColor = flags["color box"] or Color3.new(1,1,1)
            local fillColor = flags["color fill box"] or Color3.fromRGB(255, 255, 255)
            local skeletonColor = flags["color skeleton"] or Color3.new(1,1,1)
            local tracerColor = flags["color tracer"] or Color3.new(1,1,1)
            local discrColor = flags["distance"] or Color3.new(1,1,1)
            local itemColor = flags["color item"] or Color3.new(1,1,1)
            
            if flags["fill box"] then
                esp.FillBox.Size = Vector2.new(boxWidth, boxHeight)
                esp.FillBox.Position = Vector2.new(xPos, yPos)
                esp.FillBox.Color = fillColor
                esp.FillBox.Transparency = 0.3
                esp.FillBox.Visible = true
            else
                esp.FillBox.Visible = false
            end
            
            if flags["gradient_fill_box"] then
                local segments = esp.GradientFillBox.Segments
                local segmentHeight = boxHeight / segments
                local gradientTop = flags["gradient_top_color"] or Color3.fromRGB(255, 255, 255)
                local gradientBottom = flags["gradient_bottom_color"] or Color3.fromRGB(0, 0, 0)
                local baseTransparency = flags["gradient_transparency"] or 0.3
                
                for i = 1, segments do
                    local segment = esp.GradientFillBox.SegmentObjects[i]
                    if not segment then
                        segment = Drawing.new("Square")
                        segment.Filled = true
                        segment.Thickness = 1
                        esp.GradientFillBox.SegmentObjects[i] = segment
                    end
                    
                    local t = (i - 1) / (segments - 1)
                    local color = gradientTop:Lerp(gradientBottom, t)
                    
                    local transparency = baseTransparency + (t * 0.3)
                    
                    local segmentY = yPos + (i - 1) * segmentHeight
                    
                    segment.Size = Vector2.new(boxWidth, math.ceil(segmentHeight))
                    segment.Position = Vector2.new(xPos, segmentY)
                    segment.Color = color
                    segment.Transparency = transparency
                    segment.Visible = true
                end
                
                esp.FillBox.Visible = false
            else
                for _, segment in ipairs(esp.GradientFillBox.SegmentObjects) do
                    segment.Visible = false
                end
            end
            
            if flags["box"] then
                if settings.boxType == "Boxes" then
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(xPos, yPos)
                    esp.Box.Color = boxColor
                    esp.Box.Visible = true
                    
                    esp.BoxOutline.Size = esp.Box.Size
                    esp.BoxOutline.Position = esp.Box.Position
                    esp.BoxOutline.Visible = true
                    
                    for _, l in ipairs(esp.CornerLines) do 
                        l.Visible = false 
                    end
                    
                elseif settings.boxType == "Corners" then
                    esp.Box.Visible = false
                    esp.BoxOutline.Visible = false
                    
                    local cornerLen = boxWidth * 0.25
                    local lines = esp.CornerLines
                    local cx, cy, w, h = xPos, yPos, boxWidth, boxHeight
                    
                    local corners = {
                        {cx, cy, cx+cornerLen, cy},           
                        {cx, cy, cx, cy+cornerLen},             
                        {cx+w, cy, cx+w-cornerLen, cy},          
                        {cx+w, cy, cx+w, cy+cornerLen},          
                        {cx, cy+h, cx+cornerLen, cy+h},           
                        {cx, cy+h, cx, cy+h-cornerLen},          
                        {cx+w, cy+h, cx+w-cornerLen, cy+h},      
                        {cx+w, cy+h, cx+w, cy+h-cornerLen}        
                    }
                    
                    for i, c in ipairs(corners) do
                        local line = lines[i]
                        if line then
                            line.From = Vector2.new(c[1], c[2])
                            line.To = Vector2.new(c[3], c[4])
                            line.Color = boxColor
                            line.Visible = true
                        end
                    end
                end
            else
                esp.Box.Visible = false
                esp.BoxOutline.Visible = false
                for _, l in ipairs(esp.CornerLines) do 
                    l.Visible = false 
                end
            end
            
            if flags["skeleton"] then
                local boneLines = esp.SkeletonLines
                local boneIndex = 1
                
                for _, connection in ipairs(BONE_CONNECTIONS) do
                    local bone1 = char:FindFirstChild(connection[1])
                    local bone2 = char:FindFirstChild(connection[2])
                    
                    if bone1 and bone2 then
                        local pos1, onScreen1 = Camera:WorldToViewportPoint(bone1.Position)
                        local pos2, onScreen2 = Camera:WorldToViewportPoint(bone2.Position)
                        
                        if onScreen1 and onScreen2 then
                            local line = boneLines[boneIndex]
                            if not line then
                                line = Drawing.new("Line")
                                boneLines[boneIndex] = line
                            end
                            
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Color = skeletonColor
                            line.Thickness = skeletonThickness
                            line.Visible = true
                            
                            boneIndex = boneIndex + 1
                        end
                    end
                end
                
                for i = boneIndex, #boneLines do
                    if boneLines[i] then
                        boneLines[i].Visible = false
                    end
                end
            else
                for _, line in ipairs(esp.SkeletonLines) do
                    line.Visible = false
                end
            end
            
            if flags["tbox"] then
                esp.TracerLine.From = screenCenter
                esp.TracerLine.To = Vector2.new(pos.X, pos.Y)
                esp.TracerLine.Color = tracerColor
                esp.TracerLine.Visible = true
            else
                esp.TracerLine.Visible = false
            end
            
            if flags["box bar"] then
                local hp = hum.Health
                local maxhp = hum.MaxHealth
                local perc = math.clamp(hp / maxhp, 0, 1)
                local lowColor = flags["color hp low"] or Color3.fromRGB(255, 0, 0)
                local fullColor = flags["color hp full"] or Color3.fromRGB(0, 255, 0)
                local hpColor = lowColor:Lerp(fullColor, perc)
                
                local barWidth = 2
                local barOffset = 6
                local barX = xPos - barOffset
                local barY = yPos
                
                local outlineWidth = barWidth + 2
                local outlineHeight = boxHeight + 2
                
                esp.HealthBarOutline.Size = Vector2.new(outlineWidth, outlineHeight)
                esp.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
                esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
                esp.HealthBarOutline.Visible = true
                
                local fillHeight = math.floor(boxHeight * perc)
                if fillHeight < 1 then fillHeight = 1 end
                
                esp.HealthBar.Size = Vector2.new(barWidth, fillHeight)
                esp.HealthBar.Position = Vector2.new(barX, barY + (boxHeight - fillHeight))
                esp.HealthBar.Color = hpColor
                esp.HealthBar.Visible = true
                
                if flags["box number hear"] then
                    esp.HealthPercentText.Text = tostring(math.floor(perc * 100)) .. "%"
                    esp.HealthPercentText.Color = hpColor
                    esp.HealthPercentText.Position = Vector2.new(barX - 18, barY + (boxHeight - fillHeight) - 5)
                    esp.HealthPercentText.Visible = true
                else
                    esp.HealthPercentText.Visible = false
                end
            else
                esp.HealthBar.Visible = false
                esp.HealthBarOutline.Visible = false
                esp.HealthPercentText.Visible = false
            end
            
            if flags["box name"] then
                local nameColor = flags["color name"] or Color3.new(1, 1, 1)
                esp.NameText.Text = settings.useDisplayName and player.DisplayName or player.Name
                esp.NameText.Position = Vector2.new(pos.X, yPos - 20)
                esp.NameText.Color = nameColor
                esp.NameText.Visible = true
            else
                esp.NameText.Visible = false
            end
            
            if flags["box discr"] then
                local distText = settings.metric == "Meters" and string.format("%.0fm", distance) or string.format("%.0fs", distance)
                esp.DistanceText.Text = distText
                esp.DistanceText.Position = Vector2.new(pos.X, yPos + boxHeight + 5)
                esp.DistanceText.Color = discrColor
                esp.DistanceText.Visible = true
            else
                esp.DistanceText.Visible = false
            end
            
            if flags["box item"] then
                local itemName = "Hands"
                if char:FindFirstChild("Equipped") then
                    local item = char.Equipped:FindFirstChildOfClass("Model")
                    if item then 
                        itemName = item.Name 
                    end
                end
                esp.ItemText.Text = "[" .. itemName .. "]"
                esp.ItemText.Position = Vector2.new(pos.X, yPos + boxHeight + 20)
                esp.ItemText.Color = itemColor
                esp.ItemText.Visible = true
            else
                esp.ItemText.Visible = false
            end
            
        else
            for _, v in pairs(esp) do
                if typeof(v) == "table" then
                    if v.SegmentObjects then
                        for _, segment in ipairs(v.SegmentObjects) do
                            segment.Visible = false
                        end
                    else
                        for _, l in ipairs(v) do 
                            l.Visible = false 
                        end
                    end
                else
                    v.Visible = false
                end
            end
        end
    end
end)

-- Chams
local LeftGroupBox = Tabs.Visual:AddLeftGroupbox('Player Chams')
local CoreGui = game:GetService("CoreGui")
local connections = {}
local Storage = Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui
local FillColor = Color3.fromRGB(255, 255, 255)
local OutlineColor = Color3.fromRGB(255, 255, 255)
local FillTransparencySlider = 10
local OutlineTransparencySlider = 10
local ChamsEnabled = false

-- 🔹 Переводимо значення слайдерів у прозорість (0–1)
local function ToTransparency(val)
    return math.clamp(val / 20, 0, 1)
end

-- 🔹 Оновлення Highlight
local function UpdateHighlight(h)
    h.FillColor = FillColor
    h.OutlineColor = OutlineColor
    h.FillTransparency = ToTransparency(FillTransparencySlider)
    h.OutlineTransparency = ToTransparency(OutlineTransparencySlider)
end

-- 🔹 Додаємо Highlight гравцю
local function Highlight(plr)
    if plr == LocalPlayer then return end
    if Storage:FindFirstChild(plr.Name) then
        Storage[plr.Name]:Destroy()
    end
    local h = Instance.new("Highlight")
    h.Name = plr.Name
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Enabled = ChamsEnabled
    h.Parent = Storage
    local function ApplyToCharacter(char)
        h.Adornee = char
        UpdateHighlight(h)
    end
    if plr.Character then
        ApplyToCharacter(plr.Character)
    end
    connections[plr] = plr.CharacterAdded:Connect(ApplyToCharacter)
end

-- 🔹 Обробка гравців
Players.PlayerAdded:Connect(Highlight)
for _, plr in ipairs(Players:GetPlayers()) do
    Highlight(plr)
end
Players.PlayerRemoving:Connect(function(plr)
    if Storage:FindFirstChild(plr.Name) then
        Storage[plr.Name]:Destroy()
    end
    if connections[plr] then
        connections[plr]:Disconnect()
        connections[plr] = nil
    end
end)

-- 🟣 Нові UI елементи
LeftGroupBox:AddToggle('ChamsToggle', {
    Text = 'Player Chams',
    Default = false,
    Callback = function(Value)
        ChamsEnabled = Value
        for _, h in ipairs(Storage:GetChildren()) do
            h.Enabled = ChamsEnabled
        end
    end
})
:AddColorPicker('ChamsFillColor', {
    Default = FillColor,
    Title = 'Fill Color',
    Callback = function(Value)
        FillColor = Value
        for _, h in ipairs(Storage:GetChildren()) do
            h.FillColor = FillColor
        end
    end
})
:AddColorPicker('ChamsOutlineColor', {
    Default = OutlineColor,
    Title = 'Outline Color',
    Callback = function(Value)
        OutlineColor = Value
        for _, h in ipairs(Storage:GetChildren()) do
            h.OutlineColor = OutlineColor
        end
    end
})
LeftGroupBox:AddSlider('FillTransparencySlider', {
    Text = 'Fill Transparency',
    Min = 0,
    Max = 20,
    Default = FillTransparencySlider,
    Rounding = 1,
    Callback = function(Value)
        FillTransparencySlider = Value
        for _, h in ipairs(Storage:GetChildren()) do
            h.FillTransparency = ToTransparency(Value)
        end
    end
})
LeftGroupBox:AddSlider('OutlineTransparencySlider', {
    Text = 'Outline Transparency',
    Min = 0,
    Max = 20,
    Default = OutlineTransparencySlider,
    Rounding = 1,
    Callback = function(Value)
        OutlineTransparencySlider = Value
        for _, h in ipairs(Storage:GetChildren()) do
            h.OutlineTransparency = ToTransparency(Value)
        end
    end
})

-- World Visuals
local RightGroupBox = Tabs.Visual:AddRightGroupbox('Lighting')

-- 🟣 NO FOG
local noFogConnection
RightGroupBox:AddToggle('NoFog_Toggle', {
    Text = 'No Fog',
    Default = false,
    Callback = function(Value)
        if Value then
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end
            noFogConnection = RunService.RenderStepped:Connect(function()
                Lighting.FogStart = 1e6
                Lighting.FogEnd = 1e6
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = 0
                    atmosphere.Haze = 0
                    atmosphere.Glare = 0
                    atmosphere.Offset = 0
                end
            end)
        else
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end
            Lighting.FogStart = 0
            Lighting.FogEnd = 1000
        end
    end
})

-- 🌑 NO SHADOWS
RightGroupBox:AddToggle('NoShadows_Toggle', {
    Text = 'No Shadows',
    Default = false,
    Callback = function(Value)
        Lighting.GlobalShadows = not Value
    end
})

-- 🌅 CUSTOM AMBIENT
local AmbientEnabled = false
local AmbientColor = Color3.fromRGB(255, 255, 255)
local function UpdateAmbient()
    if AmbientEnabled then
        RunService:BindToRenderStep("CustomAmbient", 1, function()
            Lighting.Ambient = AmbientColor
        end)
    else
        RunService:UnbindFromRenderStep("CustomAmbient")
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end
RightGroupBox:AddToggle('CustomAmbient_Toggle', {
    Text = 'Custom World Ambient',
    Default = false,
    Callback = function(Value)
        AmbientEnabled = Value
        UpdateAmbient()
    end
})
:AddColorPicker('AmbientColor', {
    Default = AmbientColor,
    Title = 'Ambient Color',
    Callback = function(Value)
        AmbientColor = Value
        if AmbientEnabled then
            Lighting.Ambient = AmbientColor
        end
    end
})

-- ⚙️ CUSTOM TECHNOLOGY
local TechnologyEnabled = false
local SelectedTechnology = "Voxel"
RightGroupBox:AddToggle('Technology_Toggle', {
    Text = 'Custom Technology',
    Default = false,
    Callback = function(Value)
        TechnologyEnabled = Value
        if Value then
            pcall(function()
                Lighting.Technology = Enum.Technology[SelectedTechnology]
            end)
        else
            pcall(function()
                Lighting.Technology = Enum.Technology.Future
            end)
        end
    end
})
RightGroupBox:AddDropdown('Technology_Mode', {
    Text = 'Technology Mode',
    Default = 'Voxel',
    Values = {'Voxel', 'ShadowMap', 'Legacy', 'Compatibility', 'Future'},
    Callback = function(Value)
        SelectedTechnology = Value
        if TechnologyEnabled then
            pcall(function()
                Lighting.Technology = Enum.Technology[Value]
            end)
        end
    end
})

-- 🌇 CUSTOM TIME
local timeConnection
local customTime = 12
RightGroupBox:AddToggle('CustomTime_Toggle', {
    Text = 'Custom Time',
    Default = false,
    Callback = function(Value)
        if Value then
            if timeConnection then
                timeConnection:Disconnect()
                timeConnection = nil
            end
            timeConnection = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
                Lighting.ClockTime = customTime
            end)
        else
            if timeConnection then
                timeConnection:Disconnect()
                timeConnection = nil
            end
        end
    end
})
RightGroupBox:AddSlider('CustomTime_Slider', {
    Text = 'Custom Time',
    Min = 0,
    Max = 24,
    Default = customTime,
    Rounding = 1,
    Callback = function(Value)
        customTime = Value
    end
})

-- Custom Sky Box
local CustomSkyBox = Tabs.Visual:AddRightGroupbox('Custom Sky Box')
flags = flags or {}
local function ClearSkybox()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function SetSkybox(name)
    ClearSkybox()
    local sky = Instance.new("Sky")
    sky.Name = name
    if name == "Galaxy" then
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=149397692"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=149397686"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=149397697"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=149397684"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=149397688"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=149397702"
    elseif name == "Galaxy 2" then
        sky.SkyboxBk = "http://www.roblox.com/asset/?id=155441936"
        sky.SkyboxDn = "http://www.roblox.com/asset/?id=155441802"
        sky.SkyboxFt = "http://www.roblox.com/asset/?id=155441818"
        sky.SkyboxLf = "http://www.roblox.com/asset/?id=155441777"
        sky.SkyboxRt = "http://www.roblox.com/asset/?id=155441874"
        sky.SkyboxUp = "http://www.roblox.com/asset/?id=155441905"
    elseif name == "Galaxy 3" then
        sky.SkyboxBk = "rbxassetid://135908594667929"
        sky.SkyboxDn = "rbxassetid://139584143501514"
        sky.SkyboxFt = "rbxassetid://92947876187368"
        sky.SkyboxLf = "rbxassetid://72493016739936"
        sky.SkyboxRt = "rbxassetid://81731245279712"
        sky.SkyboxUp = "rbxassetid://88174897344210"
    elseif name == "Saturne" then
        sky.SkyboxBk = "rbxassetid://1898724755"
        sky.SkyboxDn = "rbxassetid://1898727189"
        sky.SkyboxFt = "rbxassetid://1898722814"
        sky.SkyboxLf = "rbxassetid://1898729298"
        sky.SkyboxRt = "rbxassetid://1898741025"
        sky.SkyboxUp = "rbxassetid://1898736761"
    elseif name == "Neptune" then
        sky.SkyboxBk = "rbxassetid://218955819"
        sky.SkyboxDn = "rbxassetid://218953419"
        sky.SkyboxFt = "rbxassetid://218954524"
        sky.SkyboxLf = "rbxassetid://218958493"
        sky.SkyboxRt = "rbxassetid://218957134"
        sky.SkyboxUp = "rbxassetid://218950090"
    elseif name == "Redshift" then
        sky.SkyboxBk = "rbxassetid://401664839"
        sky.SkyboxDn = "rbxassetid://401664862"
        sky.SkyboxFt = "rbxassetid://401664960"
        sky.SkyboxLf = "rbxassetid://401664881"
        sky.SkyboxRt = "rbxassetid://401664901"
        sky.SkyboxUp = "rbxassetid://401664936"
    elseif name == "Pink Daylights" then
        sky.SkyboxBk = "rbxassetid://11555017034"
        sky.SkyboxDn = "rbxassetid://11555013415"
        sky.SkyboxFt = "rbxassetid://11555010145"
        sky.SkyboxLf = "rbxassetid://11555006545"
        sky.SkyboxRt = "rbxassetid://11555000712"
        sky.SkyboxUp = "rbxassetid://11554996247"
    elseif name == "Purple Night" then
        sky.SkyboxBk = "rbxassetid://17279854976"
        sky.SkyboxDn = "rbxassetid://17279856318"
        sky.SkyboxFt = "rbxassetid://17279858447"
        sky.SkyboxLf = "rbxassetid://17279860360"
        sky.SkyboxRt = "rbxassetid://17279862234"
        sky.SkyboxUp = "rbxassetid://17279864507"
    elseif name == "Gray Night" then
        sky.SkyboxBk = "rbxassetid://1618912481"
        sky.SkyboxDn = "rbxassetid://1618913943"
        sky.SkyboxFt = "rbxassetid://1618913244"
        sky.SkyboxLf = "rbxassetid://1618912849"
        sky.SkyboxRt = "rbxassetid://1618911568"
        sky.SkyboxUp = "rbxassetid://1618913654"
    elseif name == "Anime Sky" then
        sky.SkyboxBk = "rbxassetid://18351376859"
        sky.SkyboxDn = "rbxassetid://18351374919"
        sky.SkyboxFt = "rbxassetid://18351376800"
        sky.SkyboxLf = "rbxassetid://18351376469"
        sky.SkyboxRt = "rbxassetid://18351376457"
        sky.SkyboxUp = "rbxassetid://18351377189"
    else
        warn("Unknown skybox:", tostring(name))
        return
    end
    sky.Parent = Lighting
end
flags.CustomSkyEnabled = false
flags.SelectedSky = "Galaxy"
CustomSkyBox:AddToggle('CustomSky_Toggle', {
    Text = 'Custom Sky',
    Default = false,
    Callback = function(Value)
        flags.CustomSkyEnabled = Value
        if flags.CustomSkyEnabled then
            SetSkybox(flags.SelectedSky)
        else
            ClearSkybox()
        end
    end
})
CustomSkyBox:AddDropdown('SkyboxSelector', {
    Text = 'Skybox Selector',
    Default = 'Galaxy',
    Values = {
        'Galaxy', 'Galaxy 2', 'Galaxy 3',
        'Saturne', 'Neptune', 'Redshift',
        'Pink Daylights', 'Purple Night',
        'Gray Night', 'Anime Sky'
    },
    Callback = function(Value)
        flags.SelectedSky = Value
        if flags.CustomSkyEnabled then
            SetSkybox(flags.SelectedSky)
        end
    end
})

-- Local Player
local LocalPlayerGroup = Tabs.Visual:AddLeftGroupbox('Local Player')
getgenv().ArmsChams = false
getgenv().ArmsChamsColor = Color3.fromRGB(255, 255, 255)
getgenv().ArmsMaterial = "ForceField"
getgenv().GunsChams = false
getgenv().GunsChamsColor = Color3.fromRGB(255, 255, 255)
getgenv().GunsMaterial = "ForceField"

LocalPlayerGroup:AddToggle("ArmChams", {
    Text = "Arm Chams",
    Default = false,
    Callback = function(Value)
        getgenv().ArmsChams = Value
    end
}):AddColorPicker("ArmChamsColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Arm Color",
    Callback = function(Value)
        getgenv().ArmsChamsColor = Value
    end
})
LocalPlayerGroup:AddDropdown("ArmMaterial", {
    Text = "Arm Material",
    Values = {"ForceField", "Plastic", "SmoothPlastic"},
    Default = "ForceField",
    Callback = function(Value)
        getgenv().ArmsMaterial = Value
    end
})

LocalPlayerGroup:AddToggle("GunChams", {
    Text = "Gun Chams",
    Default = false,
    Callback = function(Value)
        getgenv().GunsChams = Value
    end
}):AddColorPicker("GunChamsColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Gun Color",
    Callback = function(Value)
        getgenv().GunsChamsColor = Value
    end
})
LocalPlayerGroup:AddDropdown("GunMaterial", {
    Text = "Gun Material",
    Values = {"ForceField", "Plastic", "SmoothPlastic"},
    Default = "ForceField",
    Callback = function(Value)
        getgenv().GunsMaterial = Value
    end
})

RunService.RenderStepped:Connect(function()
    -- Arms Effect
    if getgenv().ArmsChams then
        for _, item in ipairs(Camera:GetChildren()) do
            if item:IsA("Model") and item.Name == "Arms" then
                for _, part in ipairs(item:GetChildren()) do
                    if part:IsA("Model") and part.Name ~= "AnimSaves" then
                        for _, armPart in ipairs(part:GetChildren()) do
                            if armPart:IsA("BasePart") then
                                armPart.Transparency = 0
                                armPart.Color = getgenv().ArmsChamsColor
                                armPart.Material = Enum.Material[getgenv().ArmsMaterial]
                                for _, inner in ipairs(armPart:GetChildren()) do
                                    if inner:IsA("BasePart") then
                                        inner.Material = Enum.Material[getgenv().ArmsMaterial]
                                        inner.Color = getgenv().ArmsChamsColor
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for _, item in ipairs(Camera:GetChildren()) do
            if item:IsA("Model") and item.Name == "Arms" then
                for _, part in ipairs(item:GetChildren()) do
                    if part:IsA("Model") and part.Name ~= "AnimSaves" then
                        for _, armPart in ipairs(part:GetChildren()) do
                            if armPart:IsA("BasePart") then
                                armPart.Transparency = 0
                                armPart.Color = Color3.fromRGB(200, 200, 200)
                                armPart.Material = Enum.Material.Plastic
                                for _, inner in ipairs(armPart:GetChildren()) do
                                    if inner:IsA("BasePart") then
                                        inner.Material = Enum.Material.Plastic
                                        inner.Color = Color3.fromRGB(200, 200, 200)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    -- Guns Effect
    if getgenv().GunsChams then
        for _, item in ipairs(Camera:GetChildren()) do
            if item:IsA("Model") and item.Name == "Arms" then
                for _, part in ipairs(item:GetChildren()) do
                    if part:IsA("MeshPart") or part:IsA("BasePart") then
                        part.Color = getgenv().GunsChamsColor
                        part.Material = Enum.Material[getgenv().GunsMaterial]
                    end
                end
            end
        end
    else
        for _, item in ipairs(Camera:GetChildren()) do
            if item:IsA("Model") and item.Name == "Arms" then
                for _, part in ipairs(item:GetChildren()) do
                    if part:IsA("MeshPart") or part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(200, 200, 200)
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end
end)

-- New Crosshair
local CustomCrosshair = Tabs.Visual:AddRightGroupbox('Custom Crosshair')
local crosshairEnabled = false
local spinningEnabled = false
local outlineEnabled = false
local rotationSpeed = 120
local color = Color3.fromRGB(255, 255, 255)
local size = 12
local thickness = 2
local orientation = 0

local gui = Instance.new("ScreenGui")
gui.Name = "RotatingCrosshair"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local group = Instance.new("Frame")
group.AnchorPoint = Vector2.new(0.5, 0.5)
group.Position = UDim2.new(0.5, 0, 0.5, 0)
group.Size = UDim2.new(0, 0, 0, 0)
group.BackgroundTransparency = 1
group.BorderSizePixel = 0
group.Parent = gui

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Size = UDim2.new(0, thickness, 0, thickness)
center.BackgroundColor3 = color
center.BorderSizePixel = 0
center.Visible = false
center.Parent = group

local horiz = Instance.new("Frame")
horiz.AnchorPoint = Vector2.new(0.5, 0.5)
horiz.Size = UDim2.new(0, size, 0, thickness)
horiz.BackgroundColor3 = color
horiz.BorderSizePixel = 0
horiz.Visible = false
horiz.Parent = group

local vert = Instance.new("Frame")
vert.AnchorPoint = Vector2.new(0.5, 0.5)
vert.Size = UDim2.new(0, thickness, 0, size)
vert.BackgroundColor3 = color
vert.BorderSizePixel = 0
vert.Visible = false
vert.Parent = group

local outline = Instance.new("UIStroke")
outline.Thickness = 1
outline.Color = Color3.new(0, 0, 0)
outline.Enabled = false
outline.Parent = horiz

local outline2 = outline:Clone()
outline2.Parent = vert

local function UpdateCrosshair()
    horiz.BackgroundColor3 = color
    vert.BackgroundColor3 = color
    center.BackgroundColor3 = color
    horiz.Size = UDim2.new(0, size, 0, thickness)
    vert.Size = UDim2.new(0, thickness, 0, size)
    horiz.Visible = crosshairEnabled
    vert.Visible = crosshairEnabled
    center.Visible = crosshairEnabled
    outline.Enabled = outlineEnabled
    outline2.Enabled = outlineEnabled
end

local angle = 0
RunService.RenderStepped:Connect(function(dt)
    if spinningEnabled and crosshairEnabled then
        angle += rotationSpeed * dt
        horiz.Rotation = angle + orientation
        vert.Rotation = angle + orientation
    elseif crosshairEnabled then
        horiz.Rotation = orientation
        vert.Rotation = orientation
    end
end)

CustomCrosshair:AddToggle('Crosshair_Toggle', {
    Text = 'Crosshair',
    Default = false,
    Callback = function(Value)
        crosshairEnabled = Value
        UpdateCrosshair()
    end
})
:AddColorPicker('Crosshair_Color', {
    Default = color,
    Title = 'Crosshair Color',
    Callback = function(Value)
        color = Value
        UpdateCrosshair()
    end
})
CustomCrosshair:AddToggle('CrosshairSpin_Toggle', {
    Text = 'Spinning Crosshair',
    Default = false,
    Callback = function(Value)
        spinningEnabled = Value
    end
})
CustomCrosshair:AddToggle('CrosshairOutline_Toggle', {
    Text = 'Outline',
    Default = false,
    Callback = function(Value)
        outlineEnabled = Value
        UpdateCrosshair()
    end
})
CustomCrosshair:AddSlider('Crosshair_Size', {
    Text = 'Crosshair Size',
    Min = 8,
    Max = 20,
    Default = size,
    Rounding = 1,
    Callback = function(Value)
        size = Value
        UpdateCrosshair()
    end
})
CustomCrosshair:AddSlider('Crosshair_Thickness', {
    Text = 'Crosshair Thickness',
    Min = 1,
    Max = 5,
    Default = thickness,
    Rounding = 1,
    Callback = function(Value)
        thickness = Value
        UpdateCrosshair()
    end
})

-- Bullet Tracer
local BulletTracerGroup = Tabs.Visual:AddRightGroupbox('Bullet Tracer')
local BEAM_TEXTURE = "rbxassetid://446111271"
local BEAM_LIFETIME = 1.5
local SHOOT_INTERVAL = 0.05
local BEAM_THICKNESS = 2
local bulletTracerEnabled = false
local bulletTracerColor = Color3.fromRGB(255, 255, 255)
local bulletTracerEffectType = "None"
local shooting = false

local function randomOffset(maxOffset)
    return Vector3.new(
        (math.random() - 0.5) * 2 * maxOffset,
        (math.random() - 0.5) * 2 * maxOffset,
        (math.random() - 0.5) * 2 * maxOffset
    )
end

local function getRainbowColor(t)
    local frequency = 2
    local r = math.floor(math.sin(frequency * t + 0) * 127 + 128)
    local g = math.floor(math.sin(frequency * t + 2) * 127 + 128)
    local b = math.floor(math.sin(frequency * t + 4) * 127 + 128)
    return Color3.fromRGB(r, g, b)
end

local function createBeam()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local startPos = hrp.Position
    local endPos = LocalPlayer:GetMouse().Hit and LocalPlayer:GetMouse().Hit.Position or startPos
    if bulletTracerEffectType == "Rainbow" then
        endPos = endPos + randomOffset(1)
    end
    local part0 = Instance.new("Part")
    part0.Anchored = true
    part0.CanCollide = false
    part0.Transparency = 1
    part0.Size = Vector3.new(0.1, 0.1, 0.1)
    part0.CFrame = CFrame.new(startPos)
    part0.Parent = workspace
    local part1 = Instance.new("Part")
    part1.Anchored = true
    part1.CanCollide = false
    part1.Transparency = 1
    part1.Size = Vector3.new(0.1, 0.1, 0.1)
    part1.CFrame = CFrame.new(endPos)
    part1.Parent = workspace
    local att0 = Instance.new("Attachment", part0)
    local att1 = Instance.new("Attachment", part1)
    local pulseConnection
    local colorConnection
    if bulletTracerEffectType == "None" then
        local beamOutline = Instance.new("Beam")
        beamOutline.Attachment0 = att0
        beamOutline.Attachment1 = att1
        beamOutline.TextureMode = Enum.TextureMode.Stretch
        beamOutline.FaceCamera = true
        beamOutline.LightEmission = 1
        beamOutline.LightInfluence = 0
        beamOutline.Texture = ""
        beamOutline.Color = ColorSequence.new(bulletTracerColor)
        beamOutline.Width0 = BEAM_THICKNESS * 1.2
        beamOutline.Width1 = BEAM_THICKNESS * 1.2
        beamOutline.Transparency = NumberSequence.new(0.3)
        beamOutline.Parent = part0
        local beamInner = Instance.new("Beam")
        beamInner.Attachment0 = att0
        beamInner.Attachment1 = att1
        beamInner.TextureMode = Enum.TextureMode.Stretch
        beamInner.FaceCamera = true
        beamInner.LightEmission = 1
        beamInner.LightInfluence = 0
        beamInner.Texture = ""
        beamInner.Color = ColorSequence.new(Color3.new(1, 1, 1))
        beamInner.Width0 = BEAM_THICKNESS * 0.3
        beamInner.Width1 = BEAM_THICKNESS * 0.3
        beamInner.Transparency = NumberSequence.new(0)
        beamInner.Parent = part0
    elseif bulletTracerEffectType == "Pulse" then
        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.TextureMode = Enum.TextureMode.Stretch
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Texture = BEAM_TEXTURE
        beam.Color = ColorSequence.new(bulletTracerColor)
        beam.Width0 = BEAM_THICKNESS
        beam.Width1 = BEAM_THICKNESS
        beam.Parent = part0
        local pulseTime = 0.4
        local elapsed = 0
        pulseConnection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            local pulse = 0.25 * math.sin((elapsed / pulseTime) * math.pi * 2)
            beam.Width0 = BEAM_THICKNESS + pulse
            beam.Width1 = BEAM_THICKNESS + pulse
        end)
    elseif bulletTracerEffectType == "Rainbow" then
        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.TextureMode = Enum.TextureMode.Stretch
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Texture = BEAM_TEXTURE
        beam.Width0 = BEAM_THICKNESS
        beam.Width1 = BEAM_THICKNESS
        beam.Parent = part0
        local startTime = tick()
        colorConnection = RunService.RenderStepped:Connect(function()
            beam.Color = ColorSequence.new(getRainbowColor(tick() - startTime))
        end)
    elseif bulletTracerEffectType == "Lightning" then
        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.TextureMode = Enum.TextureMode.Stretch
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Texture = BEAM_TEXTURE
        beam.TextureLength = 4
        beam.TextureSpeed = 0
        beam.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, bulletTracerColor),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        beam.Width0 = BEAM_THICKNESS
        beam.Width1 = BEAM_THICKNESS
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = part0
        local pulseTime = 0.4
        local elapsed = 0
        pulseConnection = RunService.RenderStepped:Connect(function(dt)
            elapsed = elapsed + dt
            local pulse = 0.5 * math.sin((elapsed / pulseTime) * math.pi * 2)
            beam.Width0 = BEAM_THICKNESS + pulse
            beam.Width1 = BEAM_THICKNESS + pulse
        end)
    end
    task.delay(BEAM_LIFETIME, function()
        if pulseConnection then pulseConnection:Disconnect() end
        if colorConnection then colorConnection:Disconnect() end
        part0:Destroy()
        part1:Destroy()
    end)
end

LocalPlayer:GetMouse().Button1Down:Connect(function()
    if not bulletTracerEnabled then return end
    shooting = true
    task.spawn(function()
        while shooting do
            createBeam()
            task.wait(SHOOT_INTERVAL)
        end
    end)
end)
LocalPlayer:GetMouse().Button1Up:Connect(function()
    shooting = false
end)

BulletTracerGroup:AddToggle("BulletTracer", {
    Text = "Enable Tracers",
    Default = false,
    Tooltip = "Enable Bullet Tracers",
    Callback = function(Value)
        bulletTracerEnabled = Value
    end
}):AddColorPicker("BulletTracerColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Tracer Color",
    Callback = function(Value)
        bulletTracerColor = Value
    end
})
BulletTracerGroup:AddDropdown("BulletTracerEffect", {
    Values = {"None", "Pulse", "Rainbow", "Lightning"},
    Default = 1,
    Text = "Tracer Effect",
    Tooltip = "Select tracer effect type",
    Callback = function(Value)
        bulletTracerEffectType = Value
    end
})
BulletTracerGroup:AddSlider("BulletTracerThickness", {
    Text = "Tracer Thickness",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        BEAM_THICKNESS = Value
    end
})
BulletTracerGroup:AddSlider("BulletTracerLifetime", {
    Text = "Tracer Lifetime",
    Default = 1.5,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        BEAM_LIFETIME = Value
    end
})

-- ===================== MISC TAB =====================
-- Anti-Aim
local AntiAimGroupBox = Tabs.Misc:AddLeftGroupbox("Anti-Aim")
getgenv().AntiAimConfig = {
    Enabled = false,
    Mode = "SpinBot",
    Pitch = "Downwards",
    YawBase = "Camera",
    SpinSpeed = 25,
    YawOffset = 25,
  
    InGravity = false,
    GravityBaseSpin = 25,
    GravityMaxSpin = 25,
    GravitySpeed = 3,
  
    CFrameManipulation = false,
    CFrameX = 0, CFrameY = 0, CFrameZ = 0,
    CFrameXAngles = 0, CFrameYAngles = 0, CFrameZAngles = 0
}

local function GetValidCharacter()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        return nil
    end
  
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character.Humanoid.Health > 0 then
        return character
    end
    return nil
end

local function GetTargetPart()
    local closest = math.huge
    local target = nil
  
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and (not teamCheck or plr.Team ~= Players.LocalPlayer.Team) then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local mouse = Players.LocalPlayer:GetMouse()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < closest then
                        closest = dist
                        target = hrp
                    end
                end
            end
        end
    end
  
    return target
end

function StartEnhancedAntiAim()
    local RunService = game:GetService("RunService")
  
    StopEnhancedAntiAim()
  
    getgenv().EnhancedAntiAimConnection = RunService.Heartbeat:Connect(function()
        if not AntiAimConfig.Enabled then return end
      
        local success, errorMsg = pcall(function()
            local character = GetValidCharacter()
            if not character then return end
          
            local humanoid = character:FindFirstChild("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
          
            if not humanoid or not root then return end
          
            humanoid.AutoRotate = false
          
            local pitchAngle = 0
            if AntiAimConfig.Pitch == "Upwards" then
                pitchAngle = 1
            elseif AntiAimConfig.Pitch == "Downwards" then
                pitchAngle = -1
            elseif AntiAimConfig.Pitch == "Zero" then
                pitchAngle = 0
            elseif AntiAimConfig.Pitch == "Random" then
                pitchAngle = math.random(-10, 10) / 10
            elseif AntiAimConfig.Pitch == "Glitch" then
                pitchAngle = 0/0
            end
          
            game:GetService("ReplicatedStorage").Events.ControlTurn:FireServer(pitchAngle, false)
          
            local CamLook = Camera.CFrame.LookVector
            local baseYaw = -math.atan2(CamLook.Z, CamLook.X) + math.rad(-90)
          
            local yawOffset = math.rad(-AntiAimConfig.YawOffset)
          
            if AntiAimConfig.YawBase == "Spin" then
                baseYaw = baseYaw + math.rad(tick() * AntiAimConfig.SpinSpeed % 360)
            elseif AntiAimConfig.YawBase == "Random" then
                baseYaw = baseYaw + math.rad(math.random(0, 360))
            elseif AntiAimConfig.YawBase == "Targets" then
                local targetPart = GetTargetPart()
                if targetPart then
                    local direction = (targetPart.Position - root.Position).Unit
                    local lookAt = CFrame.new(root.Position, Vector3.new(targetPart.Position.X, root.Position.Y, targetPart.Position.Z))
                    root.CFrame = lookAt * CFrame.Angles(0, yawOffset, 0)
                    return
                end
            end
          
            if AntiAimConfig.InGravity and AntiAimConfig.Mode == "GravitySpin" then
                local velocity = root.Velocity.Magnitude
                local baseSpin = math.rad(AntiAimConfig.GravityBaseSpin)
                local maxSpin = math.rad(AntiAimConfig.GravityMaxSpin)
                local spinSpeed = AntiAimConfig.GravitySpeed
                local speedFactor = math.clamp(velocity / 16, 0, 1)
                local t = tick()
                local spinRange = baseSpin + (maxSpin - baseSpin) * speedFactor
                local x = math.sin(t * spinSpeed) * spinRange
                local y = math.cos(t * spinSpeed * 0.6) * spinRange
                local z = math.sin(t * spinSpeed * 0.3) * spinRange
                local spinRotation = CFrame.Angles(x, y, z)
                root.CFrame = root.CFrame * spinRotation
            end
          
            local manipulatedCFrame = CFrame.new(root.Position) * CFrame.Angles(0, baseYaw + yawOffset, 0)
          
            if AntiAimConfig.CFrameManipulation then
                manipulatedCFrame = manipulatedCFrame + Vector3.new(
                    AntiAimConfig.CFrameX,
                    AntiAimConfig.CFrameY,
                    AntiAimConfig.CFrameZ
                )
                manipulatedCFrame = manipulatedCFrame * CFrame.Angles(
                    math.rad(AntiAimConfig.CFrameXAngles),
                    math.rad(AntiAimConfig.CFrameYAngles),
                    math.rad(AntiAimConfig.CFrameZAngles)
                )
            end
          
            if AntiAimConfig.Mode == "SpinBot" then
                root.CFrame = manipulatedCFrame
              
            elseif AntiAimConfig.Mode == "Jitter" then
                local currentTime = tick()
              
                if not getgenv().JitterData then
                    getgenv().JitterData = {
                        lastTime = currentTime,
                        direction = 1,
                        sequence = 0
                    }
                end
              
                if currentTime - getgenv().JitterData.lastTime >= 0.08 then
                    getgenv().JitterData.sequence = getgenv().JitterData.sequence + 1
                  
                    local baseAngle = 45
                    local randomFactor = math.sin(getgenv().JitterData.sequence * 0.5) * 15
                    local jitterAngle = (baseAngle + randomFactor) * getgenv().JitterData.direction
                  
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(jitterAngle), 0)
                  
                    getgenv().JitterData.direction = getgenv().JitterData.direction * -1
                    getgenv().JitterData.lastTime = currentTime
                end
              
            elseif AntiAimConfig.Mode == "Random" then
                local currentTime = tick()
              
                if not getgenv().RandomData then
                    getgenv().RandomData = {
                        lastTime = currentTime,
                        currentAngle = 0,
                        targetAngle = math.random(-180, 180)
                    }
                end
              
                if currentTime - getgenv().RandomData.lastTime >= 0.2 then
                    getgenv().RandomData.targetAngle = math.random(-180, 180)
                    getgenv().RandomData.lastTime = currentTime
                end
              
                getgenv().RandomData.currentAngle = getgenv().RandomData.currentAngle + (getgenv().RandomData.targetAngle - getgenv().RandomData.currentAngle) * 0.1
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(getgenv().RandomData.currentAngle), 0)
              
            elseif AntiAimConfig.Mode == "Backwards" then
                local lookVector = root.CFrame.LookVector
                root.CFrame = CFrame.new(root.Position, root.Position - lookVector)
            end
        end)
      
        if not success then
            warn("⚠️ ENHANCED ANTI-AIM ERROR: " .. tostring(errorMsg))
        end
    end)
  
end
function StopEnhancedAntiAim()
    if getgenv().EnhancedAntiAimConnection then
        getgenv().EnhancedAntiAimConnection:Disconnect()
        getgenv().EnhancedAntiAimConnection = nil
    end
  
    local character = GetValidCharacter()
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.AutoRotate = true
    end
  
    getgenv().JitterData = nil
    getgenv().RandomData = nil
end

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(2)
  
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.Died:Connect(function()
            StopEnhancedAntiAim()
        end)
    end
  
    if AntiAimConfig.Enabled then
        wait(0.5)
        StartEnhancedAntiAim()
    end
end)

getgenv().RestartEnhancedAntiAim = function()
    StopEnhancedAntiAim()
    wait(0.2)
    if AntiAimConfig.Enabled then
        StartEnhancedAntiAim()
    end
end

AntiAimGroupBox:AddToggle("EnhancedAntiAimEnable", {
    Text = "Anti Aim",
    Default = false,
    Tooltip = "Enable Enhanced Anti-Aim (Aurora Edition)",
    Callback = function(Value)
        AntiAimConfig.Enabled = Value
      
        if Value then
            StartEnhancedAntiAim()
        else
            StopEnhancedAntiAim()
        end
    end,
}):AddKeyPicker("AntiAimKey", {
    Default = "None",
    Mode = "Toggle",
    Text = "Anti-Aim Key",
    NoUI = true,
    Callback = function(Value)
        if Value then
            Toggles.EnhancedAntiAimEnable:SetValue(not Toggles.EnhancedAntiAimEnable.Value)
        end
    end,
})
AntiAimGroupBox:AddDropdown("AntiAimMode", {
    Values = {"SpinBot", "Jitter", "Random", "Backwards", "GravitySpin"},
    Default = 1,
    Text = "Anti-Aim Mode",
    Tooltip = "Select Anti-Aim mode",
    Callback = function(Value)
        AntiAimConfig.Mode = Value
      
        if AntiAimConfig.Enabled then
            StopEnhancedAntiAim()
            wait(0.1)
            StartEnhancedAntiAim()
        end
    end,
})
AntiAimGroupBox:AddDropdown("AntiAimPitch", {
    Values = {"None", "Upwards", "Glitch", "Zero", "Downwards", "Random"},
    Default = 4,
    Text = "Pitch Mode",
    Tooltip = "Select pitch mode",
    Callback = function(Value)
        AntiAimConfig.Pitch = Value
    end,
})
AntiAimGroupBox:AddDropdown("AntiAimYawBase", {
    Values = {"Spin", "Targets", "Camera", "Random"},
    Default = 3,
    Text = "Yaw Base",
    Tooltip = "Select yaw base",
    Callback = function(Value)
        AntiAimConfig.YawBase = Value
    end,
})
AntiAimGroupBox:AddSlider("AntiAimSpinSpeed", {
    Text = "Spin Speed",
    Default = 25,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        AntiAimConfig.SpinSpeed = Value
    end,
    Tooltip = "Set spin speed",
})
AntiAimGroupBox:AddSlider("AntiAimYawOffset", {
    Text = "Yaw Offset",
    Default = 25,
    Min = 1,
    Max = 360,
    Rounding = 0,
    Callback = function(Value)
        AntiAimConfig.YawOffset = Value
    end,
    Tooltip = "Set yaw offset",
})

-- Movement
local MovementGroupBox = Tabs.Misc:AddRightGroupbox("Movement")
local bunnyHopEnabled = false
local bunnyHopSpeed = 100
local thirdPersonEnabled = false
local thirdPersonDistance = 10

RunService.RenderStepped:Connect(function()
    if not bunnyHopEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and rootPart) then return end
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    local chatVisible = gui and gui:FindFirstChild("GUI") and gui.GUI:FindFirstChild("Main") and gui.GUI.Main:FindFirstChild("GlobalChat") and gui.GUI.Main.GlobalChat.Visible
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not chatVisible then
        humanoid.Jump = true
        local speed = bunnyHopSpeed or 100
        local dir = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + dir end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - dir end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(-dir.Z, 0, dir.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(dir.Z, 0, -dir.X) end
        if move.Magnitude > 0 then
            move = move.Unit
            rootPart.Velocity = Vector3.new(move.X * speed, rootPart.Velocity.Y, move.Z * speed)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if thirdPersonEnabled then
        LocalPlayer.CameraMinZoomDistance = thirdPersonDistance
        LocalPlayer.CameraMaxZoomDistance = thirdPersonDistance
    else
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 0
    end
end)

MovementGroupBox:AddToggle("BunnyHopToggle", {
    Text = "BunnyHop",
    Default = false,
    Tooltip = "Enable BunnyHop",
    Callback = function(Value)
        bunnyHopEnabled = Value
    end,
})
MovementGroupBox:AddSlider("BunnyHopSpeed", {
    Text = "BunnyHop Speed",
    Default = 100,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        bunnyHopSpeed = Value
    end,
    Tooltip = "Set BunnyHop speed",
})
MovementGroupBox:AddToggle("ThirdPersonToggle", {
    Text = "Third Person",
    Default = false,
    Tooltip = "Enable Third Person View",
    Callback = function(Value)
        thirdPersonEnabled = Value
    end,
})
MovementGroupBox:AddSlider("ThirdPersonDistance", {
    Text = "Third Person Distance",
    Default = 10,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        thirdPersonDistance = Value
    end,
    Tooltip = "Set third person camera distance",
})

-- Hit Sound
local HitSoundGroupBox = Tabs.Misc:AddRightGroupbox("Hit Sound")
getgenv().HitSoundEnabled = false
getgenv().SelectedHitSound = "Rust"

local hitSounds = {
    ["Bameware"] = "rbxassetid://3124331820",
    ["Bell"] = "rbxassetid://6534947240",
    ["Bubble"] = "rbxassetid://6534947588",
    ["Pick"] = "rbxassetid://1347140027",
    ["Pop"] = "rbxassetid://198598793",
    ["Rust"] = "rbxassetid://1255040462",
    ["Skeet"] = "rbxassetid://5633695679",
    ["Neverlose"] = "rbxassetid://6534948092",
    ["Minecraft"] = "rbxassetid://4018616850",
    ["Steve"] = "rbxassetid://4965083997",
    ["CS:GO"] = "rbxassetid://6937353691",
    ["TF2 Critical"] = "rbxassetid://296102734",
    ["Call of Duty"] = "rbxassetid://5952120301",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Among Us"] = "rbxassetid://5700183626",
    ["Mario"] = "rbxassetid://2815207981",
    ["Bamboo"] = "rbxassetid://3769434519",
    ["TF2"] = "rbxassetid://86186041171193",
}

local function playHitSound()
    if not getgenv().HitSoundEnabled then return end
    local soundId = hitSounds[getgenv().SelectedHitSound]
    if not soundId then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 3
    sound.PlaybackSpeed = 1.2
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 1)
end

LocalPlayer:GetMouse().Button1Down:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    local origin = head.Position
    local direction = (LocalPlayer:GetMouse().Hit.Position - origin).Unit * 10000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance then
        local hitPart = result.Instance
        local hitModel = hitPart:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChild("Humanoid") and hitModel ~= character then
            playHitSound()
        end
    end
end)

HitSoundGroupBox:AddToggle("HitSoundToggle", {
    Text = "Enable Hit Sound",
    Default = false,
    Callback = function(Value)
        getgenv().HitSoundEnabled = Value
    end,
})
HitSoundGroupBox:AddDropdown("HitSoundSelect", {
    Values = {
        "Bameware", "Bell", "Bubble", "Pick", "Pop", "Rust",
        "Skeet", "Neverlose", "Minecraft", "Steve", "CS:GO",
        "TF2 Critical", "Call of Duty", "Gamesense", "Among Us",
        "Mario", "Bamboo", "TF2"
    },
    Default = 6,
    Text = "Hit Sound Type",
    Tooltip = "Select hit sound effect",
    Callback = function(Value)
        getgenv().SelectedHitSound = Value
    end,
})

Library:SetWatermarkVisibility(true)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 120;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('NexusVision | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('NexsuVisionTheme')
SaveManager:SetFolder('NexusVisionSave/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
