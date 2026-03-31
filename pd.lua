 -- LinoriaLib
    local repo = 'https://github.com/DeviceHB21/Custom-Liblinoria/tree/main'

    local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/sashanz/library/refs/heads/main/1'))()
    local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/sashanz/Theme/refs/heads/main/32'))()
    local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/SaveManager.lua'))() 
local Build = "Paid";
local Color = "#FF0000";
local Ver = "v1.1"

if Build == "Paid" then 
    Color = '#FF0000' 
    Ver = "v1.1" 
end

local Window = Library:CreateWindow({ 
    Size = UDim2.fromOffset(550, 610),
    Title = "<font color=\"#f4c8ff\">LunarCore.xyz</font> | PD | <font color=\"#FF0000\">"..Ver.."</font>",
    Center = true,
    AutoShow = true
})
-- Tabs
local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}


-- Оновлюємо все, що вже створено
Library:UpdateColorsUsingRegistry()


function ThemeManager:LoadDefault()		
	self:ApplyTheme('Default')
	Options.ThemeManager_ThemeList:SetValue('Default')
end

-- =============================================
-- Sections
-- =============================================
local AimbotSection = Tabs.Combat:AddLeftGroupbox('Aimbot Settings')
local GunSection = Tabs.Combat:AddRightGroupbox('Gun Settings')
local VisualsSection = Tabs.Visuals:AddLeftGroupbox('Players ESP')
local ArmsSection = Tabs.Visuals:AddRightGroupbox('Arms & Viewmodel')

local WorldSection = Tabs.Visuals:AddRightGroupbox('World')
local MiscSection = Tabs.Misc:AddLeftGroupbox('Visual Character')
local MisSection = Tabs.Misc:AddRightGroupbox('Character')
local OtherSection = Tabs.Visuals:AddLeftGroupbox('Other')
local BotSection = Tabs.Misc:AddRightGroupbox('Bot')
local AntiAimSection = Tabs.Misc:AddLeftGroupbox('AntiAim')
local HitSection = Tabs.Misc:AddRightGroupbox("Hit Sounds")



-- Services
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = PlayersService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- =============================================
-- Функция проверки клона
-- =============================================
local function isMyClone(player)
    if not player or not player.Character then return false end
    local character = player.Character
    if character.Name and string.find(character.Name, "MotionClone_") then return true end
    if character:FindFirstChild("IsClone") then return true end
    return false
end

-- =============================================
-- Silent Aim
-- =============================================
local silent_aim = {
    enabled = false,
    target_ai = false,
    part = "Head",
    use_fov = false,
    fov_show = false,
    fov_color = Color3.new(1, 1, 1),
    fov_outline = true,
    fov_outline_color = Color3.new(0, 0, 0),
    fov_size = 300,
    indicator = false,
    nospread = false,
    instant = false,
    target_part = true,
    is_npc = false,
    isvisible = false,
    tracer = false,
    tracer_color = Color3.new(1, 1, 1)
}

local min_fov_size = 50
local max_fov_size = 500
local function percentage_to_fov_size(percentage)
    local range = max_fov_size - min_fov_size
    return math.floor(min_fov_size + (range * (percentage / 100)))
end

local function get_closest_target(usefov, fov_size, aimpart, npc)
    local target_part = nil
    local is_npc_target = false
    local max_distance = usefov and fov_size or math.huge
    local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    if npc then
        local ai_zones = Workspace:FindFirstChild("AiZones")
        if ai_zones then
            for _, zone in pairs(ai_zones:GetChildren()) do 
                for _, npc_char in pairs(zone:GetChildren()) do
                    local part = npc_char:FindFirstChild(aimpart)
                    local humanoid = npc_char:FindFirstChildOfClass("Humanoid")
                    if part and humanoid and humanoid.Health > 0 then
                        local position, on_screen = Camera:WorldToViewportPoint(part.Position)
                        if on_screen then
                            local distance = (Vector2.new(position.X, position.Y) - mouse_pos).Magnitude
                            if distance < max_distance then
                                target_part = part
                                max_distance = distance
                                is_npc_target = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    for _, plr in pairs(PlayersService:GetPlayers()) do
        if plr ~= LocalPlayer then
            if isMyClone(plr) then continue end
            local character = plr.Character
            if character then
                local part = character:FindFirstChild(aimpart)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local position, on_screen = Camera:WorldToViewportPoint(part.Position)
                    if on_screen then
                        local distance = (Vector2.new(position.X, position.Y) - mouse_pos).Magnitude
                        if distance <= max_distance then
                            target_part = part
                            max_distance = distance
                            is_npc_target = false
                        end
                    end
                end
            end
        end
    end
    return target_part, is_npc_target
end

local function predict_velocity(origin, destination, destination_velocity, projectile_speed)
    local distance = (destination - origin).Magnitude
    local time_to_hit = distance / projectile_speed
    local predicted = destination + destination_velocity * time_to_hit
    local delta = (predicted - origin).Magnitude / projectile_speed
    time_to_hit = time_to_hit + delta / projectile_speed
    return destination + destination_velocity * time_to_hit
end

local function is_visible(target_part)
    if not target_part then return false end 
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        Workspace:FindFirstChild("NoCollision"),
        Camera,
        LocalPlayer.Character
    }
    local origin = Camera.CFrame.Position
    local direction = target_part.Position - origin
    local result = Workspace:Raycast(origin, direction, params)
    return result and result.Instance and result.Instance:IsDescendantOf(target_part.Parent)
end

local function make_beam(origin, position, color)
    local part1 = Instance.new("Part")
    local part2 = Instance.new("Part")
    part1.Position = origin
    part2.Position = position
    part1.Transparency = 1
    part2.Transparency = 1
    part1.Anchored = true
    part2.Anchored = true
    part1.CanCollide = false
    part2.CanCollide = false
    part1.Size = Vector3.zero
    part2.Size = Vector3.zero
    part1.Parent = Workspace
    part2.Parent = Workspace
    
    local attachment1 = Instance.new("Attachment", part1)
    local attachment2 = Instance.new("Attachment", part2)
    
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(color)
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Texture = "rbxassetid://446111271"
    beam.Transparency = NumberSequence.new(0)
    beam.Attachment0 = attachment1
    beam.Attachment1 = attachment2
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    beam.FaceCamera = true
    beam.Parent = Workspace
    return beam, part1, part2
end

-- Hook for CreateBullet
local success, bullet_module = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FPS"):WaitForChild("Bullet"))
end)

if success and bullet_module then
    local old_create_bullet = bullet_module.CreateBullet
    bullet_module.CreateBullet = function(self, ...)
        local args = { ... }
        if silent_aim.enabled then
            local loaded_ammo = nil
            local aimpart_index = nil
            for i, v in ipairs(args) do
                if typeof(v) == "Instance" and v.Name == "AimPart" then
                    aimpart_index = i
                end
                if type(v) == "string" then
                    local tmp = ReplicatedStorage:FindFirstChild("AmmoTypes")
                    if tmp then
                        tmp = tmp:FindFirstChild(v)
                        if tmp then loaded_ammo = tmp end
                    end
                end
            end
            if loaded_ammo and aimpart_index then
                if silent_aim.tracer and silent_aim.target_part then
                    local beam, p1, p2 = make_beam(args[aimpart_index].Position, silent_aim.target_part.Position, silent_aim.tracer_color)
                    local time = 0
                    local connection = RunService.RenderStepped:Connect(function(delta)
                        time = time + delta
                        beam.Transparency = NumberSequence.new(math.clamp(time, 0, 1))
                        if time >= 1 then
                            beam:Destroy()
                            p1:Destroy()
                            p2:Destroy()
                            connection:Disconnect()
                        end
                    end)
                end
                if silent_aim.instant and silent_aim.target_part then
                    return old_create_bullet(self, unpack(args))
                end
                if silent_aim.target_part and not silent_aim.instant then
                    local projectile_speed = loaded_ammo:GetAttribute("MuzzleVelocity") or 2000
                    local destination = silent_aim.target_part.Position
                    local destination_velocity = silent_aim.target_part.Velocity
                    local origin = Camera.CFrame.Position
                    destination = predict_velocity(origin, destination, destination_velocity, projectile_speed)
                    args[aimpart_index] = { CFrame = CFrame.lookAt(origin, destination) }
                end
            end
        end
        return old_create_bullet(self, unpack(args))
    end
end

-- Hook for attributes (No Spread)
local mt = getrawmetatable(game)
if mt then
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }
        if method == "GetAttribute" and silent_aim.enabled and silent_aim.nospread then
            local attribute = args[1]
            if attribute == "AccuracyDeviation" or attribute == "Spread" then
                return 0
            end
        end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- FOV circle
local fov_circle = Drawing.new("Circle")
fov_circle.Visible = false
fov_circle.Thickness = 0.2
fov_circle.NumSides = 60
fov_circle.Filled = false
fov_circle.Color = silent_aim.fov_color or Color3.new(1, 1, 1)
fov_circle.Transparency = 0.5
fov_circle.Radius = silent_aim.fov_size

local fov_circle_outline = Drawing.new("Circle")
fov_circle_outline.Visible = false
fov_circle_outline.Thickness = 3
fov_circle_outline.NumSides = 60
fov_circle_outline.Filled = false
fov_circle_outline.Color = silent_aim.fov_outline_color or Color3.new(1, 1, 1)
fov_circle_outline.Transparency = 1
fov_circle_outline.Radius = silent_aim.fov_size

local fov_circle_filled = Drawing.new("Circle")
fov_circle_filled.Visible = false
fov_circle_filled.Thickness = 0
fov_circle_filled.NumSides = 60
fov_circle_filled.Filled = true
fov_circle_filled.Color = silent_aim.fov_filled_color or Color3.new(1, 1, 1)
fov_circle_filled.Transparency = silent_aim.fov_filled_transparency or 0.3
fov_circle_filled.Radius = silent_aim.fov_size

local indicator = Drawing.new("Text")
indicator.Visible = false
indicator.Center = true
indicator.Size = 16
indicator.Outline = true
indicator.Font = Drawing.Fonts.Monospace
indicator.Color = Color3.new(1, 1, 1)

-- Target update loop
RunService.Heartbeat:Connect(function()
    if silent_aim.enabled then
        silent_aim.target_part, silent_aim.is_npc = get_closest_target(
            silent_aim.use_fov,
            silent_aim.fov_size, 
            silent_aim.part, 
            silent_aim.target_ai
        )
        if silent_aim.target_part then
            silent_aim.isvisible = is_visible(silent_aim.target_part)
        end
    end
end)

-- Render loop for drawings
RunService.RenderStepped:Connect(function()
    local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + 36)
    if silent_aim.fov_show then
        -- Обновляем позицию для всех кругов
        fov_circle.Position = mouse_pos
        fov_circle.Radius = silent_aim.fov_size
        fov_circle.Color = silent_aim.fov_color or Color3.new(1, 1, 1)
        
        fov_circle_filled.Position = mouse_pos
        fov_circle_filled.Radius = silent_aim.fov_size
        fov_circle_filled.Color = silent_aim.fov_filled_color or Color3.new(1, 1, 1)
        fov_circle_filled.Transparency = silent_aim.fov_filled_transparency or 0.3
        
        if silent_aim.fov_outline then
            fov_circle_outline.Position = mouse_pos
            fov_circle_outline.Radius = silent_aim.fov_size
            fov_circle_outline.Color = silent_aim.fov_outline_color or Color3.new(1, 1, 1)
            fov_circle_outline.Visible = true
        else
            fov_circle_outline.Visible = false
        end
        
        -- Показываем либо обычный круг, либо залитый в зависимости от настройки
        if silent_aim.fov_filled then
            fov_circle.Visible = false
            fov_circle_filled.Visible = true
        else
            fov_circle.Visible = true
            fov_circle_filled.Visible = false
        end
    else
        fov_circle.Visible = false
        fov_circle_filled.Visible = false
        fov_circle_outline.Visible = false
    end
    
    if silent_aim.indicator and silent_aim.target_part then
        local text = silent_aim.target_part.Parent.Name
        if silent_aim.isvisible then text = text .. " (visible)" end
        if silent_aim.is_npc then text = text .. " (ai)" end
        indicator.Text = text
        indicator.Position = Vector2.new(mouse_pos.X, mouse_pos.Y + 50)
        indicator.Visible = true
    else
        indicator.Visible = false
    end
end)

-- Aimbot UI
AimbotSection:AddToggle('SilentAim', {
    Text = 'Silent Aim',
    Default = false,
    Tooltip = 'Automatically aims at enemies',
    Callback = function(Value) silent_aim.enabled = Value end
})

AimbotSection:AddToggle('UseFOV', {
    Text = 'Use FOV',
    Default = false,
    Callback = function(Value) silent_aim.use_fov = Value end
})

-- Show FOV с ColorPicker
AimbotSection:AddToggle('ShowFOV', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(Value) silent_aim.fov_show = Value end
}):AddColorPicker('FOVColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'FOV Color',
    Callback = function(Value)
        silent_aim.fov_color = Value
        fov_circle.Color = Value
    end
})

-- Filled FOV с ColorPicker
AimbotSection:AddToggle('FOVFilled', {
    Text = 'Filled FOV',
    Default = false,
    Tooltip = 'Makes the FOV circle filled with color',
    Callback = function(Value) 
        silent_aim.fov_filled = Value 
    end
}):AddColorPicker('FOVFilledColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Filled FOV Color',
    Callback = function(Value)
        silent_aim.fov_filled_color = Value
        fov_circle_filled.Color = Value
    end
})


-- Слайдер для прозрачности залитого круга (отдельный элемент)


-- FOV Size слайдер


-- FOV Outline с ColorPicker
AimbotSection:AddToggle('FOVOutline', {
    Text = 'FOV Outline',
    Default = false,
    Callback = function(Value) silent_aim.fov_outline = Value end
}):AddColorPicker('FOVOutlineColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Outline Color',
    Callback = function(Value)
        silent_aim.fov_outline_color = Value
        fov_circle_outline.Color = Value
    end
})


-- =============================================
-- ESP Settings
-- =============================================
local Cheat = {
    Toggles = {
        Enabled         = false,
        Box             = false,
        Name            = false,
        Distance        = false,
        WeaponName      = false,
        HPBar           = false,
        HPText          = false,
        Skeleton        = false,
        testing         = false,
        NeonChams       = false,   -- отдельный переключатель неоновых чамсов
    },
    Colors = {
        BoxOuter = Color3.new(0, 0, 0),
        BoxMain  = Color3.new(1, 1, 1),
        BoxInner = Color3.new(0, 0, 0),
        Name     = Color3.new(1, 1, 1),
        Distance = Color3.new(1, 1, 1),
        WeaponName = Color3.fromRGB(255, 215, 0),
        HealthText = Color3.new(1, 1, 1),
        HealthGradientStart = Color3.fromRGB(255, 255, 255),
        HealthGradientMid   = Color3.fromRGB(212, 163, 255),
        HealthGradientEnd   = Color3.fromRGB(136, 0, 255),
        HealthMask = Color3.new(0, 0, 0),
        HealthMaskTransparency = 0.3,
        Skeleton = Color3.new(1, 1, 1),
        SkeletonTransparency = 0,
    },
    Connections = {},
    Boxes = {},
}

local Gui = Instance.new("ScreenGui")
Gui.DisplayOrder = 9e9
Gui.ResetOnSpawn = false
Gui.Parent = gethui and gethui() or CoreGui
Gui.Enabled = false

local function GetHealthColor(percent)
    percent = math.clamp(percent, 0, 1)
    if percent < 0.5 then
        return Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), percent * 2)
    else
        return Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (percent - 0.5) * 2)
    end
end

local function Cleanup(player)
    if Cheat.Boxes[player] then
        for _, obj in pairs(Cheat.Boxes[player]) do
            if typeof(obj) == "Instance" then 
                obj:Destroy()
            elseif typeof(obj) == "table" and obj.Lines then
                for _, line in ipairs(obj.Lines) do 
                    line:Remove() 
                end
            end
        end
        Cheat.Boxes[player] = nil
    end
end

Cheat.Connections.PlayerRemoving = PlayersService.PlayerRemoving:Connect(Cleanup)

local function CreateBox()
    local box = {}
    local names = {"Outer", "Main", "Inner"}
    for i = 1, 3 do
        local frame = Instance.new("Frame")
        frame.Name = names[i]
        frame.BackgroundTransparency = 1
        frame.Parent = Gui
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Parent = frame
        box[names[i]] = frame
        box[names[i] .. "Stroke"] = stroke
    end

    box.OuterStroke.Color = Cheat.Colors.BoxOuter
    box.MainStroke.Color  = Cheat.Colors.BoxMain
    box.InnerStroke.Color = Cheat.Colors.BoxInner

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.BackgroundTransparency = 0
    healthBg.BorderSizePixel = 0
    healthBg.Parent = Gui
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Parent = healthBg

    local function UpdateGradient()
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Cheat.Colors.HealthGradientStart),
            ColorSequenceKeypoint.new(0.5, Cheat.Colors.HealthGradientMid),
            ColorSequenceKeypoint.new(1,   Cheat.Colors.HealthGradientEnd)
        })
    end
    UpdateGradient()
    box.UpdateGradient = UpdateGradient

    local healthMask = Instance.new("Frame")
    healthMask.Name = "HealthMask"
    healthMask.BackgroundColor3 = Cheat.Colors.HealthMask
    healthMask.BackgroundTransparency = Cheat.Colors.HealthMaskTransparency
    healthMask.BorderSizePixel = 0
    healthMask.Parent = healthBg
    healthMask.ZIndex = healthBg.ZIndex + 1

    local healthBgStroke = Instance.new("UIStroke")
    healthBgStroke.Color = Color3.new(0,0,0)
    healthBgStroke.Thickness = 1
    healthBgStroke.Parent = healthBg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = ""
    nameLabel.TextSize = 12
    nameLabel.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Parent = Gui
    nameLabel.TextColor3 = Cheat.Colors.Name

    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.BackgroundTransparency = 1
    healthText.Text = ""
    healthText.TextSize = 10
    healthText.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    healthText.TextStrokeTransparency = 0
    healthText.TextStrokeColor3 = Color3.new(0,0,0)
    healthText.TextXAlignment = Enum.TextXAlignment.Right
    healthText.Parent = Gui
    healthText.TextColor3 = Cheat.Colors.HealthText

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = ""
    distanceLabel.TextSize = 12
    distanceLabel.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    distanceLabel.Parent = Gui
    distanceLabel.TextColor3 = Cheat.Colors.Distance

    local toolLabel = Instance.new("TextLabel")
    toolLabel.Name = "ToolLabel"
    toolLabel.BackgroundTransparency = 1
    toolLabel.Text = ""
    toolLabel.TextSize = 13
    toolLabel.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
    toolLabel.TextStrokeTransparency = 0.4
    toolLabel.TextStrokeColor3 = Color3.new(0,0,0)
    toolLabel.TextColor3 = Cheat.Colors.WeaponName
    toolLabel.TextXAlignment = Enum.TextXAlignment.Center
    toolLabel.Parent = Gui

    local skeletonLines = {}
    for i = 1, 20 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = Cheat.Colors.Skeleton
        line.Transparency = 1 - Cheat.Colors.SkeletonTransparency
        line.Visible = false
        skeletonLines[i] = line
    end
    box.Lines = skeletonLines

    box.HealthBg    = healthBg
    box.HealthMask  = healthMask
    box.NameLabel   = nameLabel
    box.HealthText  = healthText
    box.DistanceLabel = distanceLabel
    box.ToolLabel   = toolLabel
    box.LastTool    = nil
    box.VisualHealth = nil

    return box
end

local function SetCoreBoxVisible(esp, visible)
    if not esp then return end
    esp.Outer.Visible = visible
    esp.Main.Visible  = visible
    esp.Inner.Visible = visible
    if esp.Lines then
        for _, line in ipairs(esp.Lines) do 
            line.Visible = visible and Cheat.Toggles.Skeleton 
        end
    end
end

local function UpdateLoop()
    while task.wait() do
        if not Cheat.Toggles.Enabled then
            if Gui.Enabled then Gui.Enabled = false end
            for _, esp in pairs(Cheat.Boxes) do
                if esp and esp.Lines then
                    for _, line in ipairs(esp.Lines) do
                        line.Visible = false
                    end
                end
            end
            continue
        end

        Gui.Enabled = true

        local testHealthPct
        if Cheat.Toggles.testing then testHealthPct = math.abs(math.sin(tick() * 1)) end

        local lpChar = LocalPlayer.Character
        local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
        local rsPlayers = ReplicatedStorage:FindFirstChild("Players")

        for _, player in ipairs(PlayersService:GetPlayers()) do
            if player == LocalPlayer then continue end
            if isMyClone and isMyClone(player) then continue end

            local char = player.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if not char or not root or not hum or (hum.Health <= 0 and not Cheat.Toggles.testing) then
                if Cheat.Boxes[player] then Cleanup(player) end
                continue
            end

            local esp = Cheat.Boxes[player]
            local cframe, size = char:GetBoundingBox()
            if not cframe then
                if esp then Cleanup(player) end
                continue
            end

            local halfSize = size / 2
            local corners = {
                cframe * Vector3.new( halfSize.X,  halfSize.Y,  halfSize.Z),
                cframe * Vector3.new( halfSize.X,  halfSize.Y, -halfSize.Z),
                cframe * Vector3.new( halfSize.X, -halfSize.Y,  halfSize.Z),
                cframe * Vector3.new( halfSize.X, -halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(-halfSize.X,  halfSize.Y,  halfSize.Z),
                cframe * Vector3.new(-halfSize.X,  halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(-halfSize.X, -halfSize.Y,  halfSize.Z),
                cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z)
            }

            local left, top = math.huge, math.huge
            local right, bottom = -math.huge, -math.huge
            local onScreen = false

            for i = 1, 8 do
                local screenPos, isVisible = Camera:WorldToScreenPoint(corners[i])
                if isVisible then
                    onScreen = true
                    left   = math.min(left,   screenPos.X)
                    top    = math.min(top,    screenPos.Y)
                    right  = math.max(right,  screenPos.X)
                    bottom = math.max(bottom, screenPos.Y)
                end
            end

            if onScreen then
                if not esp then 
                    esp = CreateBox() 
                    Cheat.Boxes[player] = esp 
                end

                SetCoreBoxVisible(esp, true)

                left   = math.floor(left)
                top    = math.floor(top)
                right  = math.ceil(right)
                bottom = math.ceil(bottom)

                local inset = (bottom - top) * 0.04
                left   = left   + inset
                top    = top    + inset
                right  = right  - inset
                bottom = bottom - inset

                local width, height = right - left, bottom - top
                local boxTopY = top - 1
                local totalBoxHeight = height + 2

                esp.Outer.Position = UDim2.fromOffset(left - 1, boxTopY)
                esp.Outer.Size     = UDim2.fromOffset(width + 2, totalBoxHeight)
                esp.Main.Position  = UDim2.fromOffset(left, top)
                esp.Main.Size      = UDim2.fromOffset(width, height)
                esp.Inner.Position = UDim2.fromOffset(left + 1, top + 1)
                esp.Inner.Size     = UDim2.fromOffset(width - 2, height - 2)

                local yOffset = top - 18

                if Cheat.Toggles.Name then
                    esp.NameLabel.Text = player.DisplayName or player.Name
                    esp.NameLabel.Position = UDim2.fromOffset(left - 1, yOffset)
                    esp.NameLabel.Size = UDim2.fromOffset(width + 2, 12)
                    esp.NameLabel.Visible = true
                    yOffset = yOffset - 14
                else
                    esp.NameLabel.Visible = false
                end

                local bottomYOffset = bottom + 2

                local toolName = nil
                local playerFolder = rsPlayers and rsPlayers:FindFirstChild(player.Name)
                local statusFolder = playerFolder and playerFolder:FindFirstChild("Status")
                local gameplayVars = statusFolder and statusFolder:FindFirstChild("GameplayVariables")
                local equippedTool = gameplayVars and gameplayVars:FindFirstChild("EquippedTool")
                if equippedTool and equippedTool.Value then
                    if typeof(equippedTool.Value) == "Instance" then 
                        toolName = equippedTool.Value.Name
                    elseif typeof(equippedTool.Value) == "string" and equippedTool.Value ~= "" then 
                        toolName = equippedTool.Value 
                    end
                end

                if toolName ~= esp.LastTool then
                    esp.ToolLabel.Text = toolName or ""
                    esp.LastTool = toolName
                end

                esp.ToolLabel.Visible = Cheat.Toggles.WeaponName and toolName and toolName ~= ""
                if esp.ToolLabel.Visible then
                    esp.ToolLabel.Position = UDim2.fromOffset(left - 1, bottomYOffset)
                    esp.ToolLabel.Size = UDim2.fromOffset(width + 2, 14)
                    bottomYOffset = bottomYOffset + 16
                end

                if Cheat.Toggles.Distance and lpRoot then
                    local distInStuds = (lpRoot.Position - root.Position).Magnitude
                    local distInMeters = math.floor(distInStuds * 0.28)
                    esp.DistanceLabel.Text = distInMeters .. "м"
                    esp.DistanceLabel.Position = UDim2.fromOffset(left - 1, bottomYOffset)
                    esp.DistanceLabel.Size = UDim2.fromOffset(width + 2, 12)
                    esp.DistanceLabel.Visible = true
                    bottomYOffset = bottomYOffset + 14
                else
                    esp.DistanceLabel.Visible = false
                end

                if Cheat.Toggles.HPBar or Cheat.Toggles.HPText then
                    local healthPct, healthValue
                    if Cheat.Toggles.testing then
                        healthPct = testHealthPct
                        healthValue = math.floor(healthPct * 100)
                    else
                        healthPct = hum.Health / hum.MaxHealth
                        healthValue = math.floor(hum.Health)
                    end

                    if esp.VisualHealth == nil then esp.VisualHealth = healthPct end
                    esp.VisualHealth = esp.VisualHealth + (healthPct - esp.VisualHealth) * 0.1

                    esp.HealthText.Text = tostring(healthValue)
                    local healthBarWidth = 2
                    local maskHeight = totalBoxHeight * (1 - esp.VisualHealth)
                    local healthTextY = boxTopY + maskHeight + 3 - (esp.HealthText.Size.Y.Offset / 2)

                    esp.HealthText.Position = UDim2.fromOffset(left - healthBarWidth - 30, healthTextY)
                    esp.HealthText.Size = UDim2.fromOffset(18, 10)
                    esp.HealthText.Visible = Cheat.Toggles.HPText

                    esp.HealthBg.Position = UDim2.fromOffset(left - healthBarWidth - 6, boxTopY)
                    esp.HealthBg.Size = UDim2.fromOffset(healthBarWidth, totalBoxHeight)
                    esp.HealthMask.Position = UDim2.fromOffset(0, 0)
                    esp.HealthMask.Size = UDim2.fromOffset(healthBarWidth, maskHeight)

                    esp.HealthBg.Visible = Cheat.Toggles.HPBar
                else
                    esp.HealthBg.Visible = false
                    esp.HealthText.Visible = false
                end

                if Cheat.Toggles.Skeleton and esp.Lines then
                    local parts = {
                        Head         = char:FindFirstChild("Head"),
                        UpperTorso   = char:FindFirstChild("UpperTorso"),
                        LowerTorso   = char:FindFirstChild("LowerTorso"),
                        LeftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
                        LeftLowerArm = char:FindFirstChild("LeftLowerArm"),
                        LeftHand     = char:FindFirstChild("LeftHand"),
                        RightUpperArm= char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
                        RightLowerArm= char:FindFirstChild("RightLowerArm"),
                        RightHand    = char:FindFirstChild("RightHand"),
                        LeftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
                        LeftLowerLeg = char:FindFirstChild("LeftLowerLeg"),
                        LeftFoot     = char:FindFirstChild("LeftFoot"),
                        RightUpperLeg= char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
                        RightLowerLeg= char:FindFirstChild("RightLowerLeg"),
                        RightFoot    = char:FindFirstChild("RightFoot"),
                    }

                    local positions = {}
                    for name, part in pairs(parts) do
                        if part then
                            local pos, vis = Camera:WorldToViewportPoint(part.Position)
                            positions[name] = vis and Vector2.new(pos.X, pos.Y) or nil
                        end
                    end

                    local lineIndex = 1
                    local function drawLine(fromPos, toPos)
                        if fromPos and toPos then
                            esp.Lines[lineIndex].From = fromPos
                            esp.Lines[lineIndex].To   = toPos
                            esp.Lines[lineIndex].Visible = true
                            lineIndex = lineIndex + 1
                        end
                    end

                    drawLine(positions.Head, positions.UpperTorso)
                    drawLine(positions.UpperTorso, positions.LowerTorso)
                    drawLine(positions.UpperTorso, positions.LeftUpperArm)
                    if positions.LeftLowerArm then drawLine(positions.LeftUpperArm, positions.LeftLowerArm) end
                    if positions.LeftHand then drawLine(positions.LeftLowerArm or positions.LeftUpperArm, positions.LeftHand) end
                    drawLine(positions.UpperTorso, positions.RightUpperArm)
                    if positions.RightLowerArm then drawLine(positions.RightUpperArm, positions.RightLowerArm) end
                    if positions.RightHand then drawLine(positions.RightLowerArm or positions.RightUpperArm, positions.RightHand) end
                    drawLine(positions.LowerTorso, positions.LeftUpperLeg)
                    if positions.LeftLowerLeg then drawLine(positions.LeftUpperLeg, positions.LeftLowerLeg) end
                    if positions.LeftFoot then drawLine(positions.LeftLowerLeg or positions.LeftUpperLeg, positions.LeftFoot) end
                    drawLine(positions.LowerTorso, positions.RightUpperLeg)
                    if positions.RightLowerLeg then drawLine(positions.RightUpperLeg, positions.RightLowerLeg) end
                    if positions.RightFoot then drawLine(positions.RightLowerLeg or positions.RightUpperLeg, positions.RightFoot) end

                    for i = lineIndex, #esp.Lines do 
                        esp.Lines[i].Visible = false 
                    end

                    for _, line in ipairs(esp.Lines) do
                        line.Color = Cheat.Colors.Skeleton
                        line.Transparency = 1 - Cheat.Colors.SkeletonTransparency
                    end
                else
                    if esp and esp.Lines then
                        for _, line in ipairs(esp.Lines) do
                            line.Visible = false
                        end
                    end
                end

                esp.Outer.Visible = Cheat.Toggles.Box
                esp.Main.Visible  = Cheat.Toggles.Box
                esp.Inner.Visible = Cheat.Toggles.Box

            else
                if esp then
                    SetCoreBoxVisible(esp, false)
                    esp.DistanceLabel.Visible = false
                    esp.NameLabel.Visible     = false
                    esp.HealthText.Visible    = false
                    esp.HealthBg.Visible      = false
                    esp.ToolLabel.Visible     = false
                end
            end
        end
    end
end

coroutine.wrap(UpdateLoop)()
-- =============================================
-- PLAYER CHAMS (Highlight Based)
-- =============================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local connections = {}
local Storage = Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui

local FillColor = Color3.fromRGB(255, 255, 255)
local OutlineColor = Color3.fromRGB(255, 255, 255)
local FillTransparencySlider = 10
local OutlineTransparencySlider = 10
local ChamsEnabled = false

-- Перевод значений слайдеров в прозрачность (0-1)
local function ToTransparency(val)
    return math.clamp(val / 20, 0, 1)
end

-- Обновление Highlight
local function UpdateHighlight(h)
    h.FillColor = FillColor
    h.OutlineColor = OutlineColor
    h.FillTransparency = ToTransparency(FillTransparencySlider)
    h.OutlineTransparency = ToTransparency(OutlineTransparencySlider)
end

-- Добавление Highlight игроку
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

-- Обработка игроков
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

-- UI элементы


-- =============================================
-- UI (VisualsSection)
-- =============================================

-- Основной переключатель ESP
VisualsSection:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.Enabled = Value
        updateNeonVisibility()   -- обновляем видимость чамсов
    end
})


-- Остальные элементы ESP
VisualsSection:AddToggle('BoxESP', {
    Text = 'Box ESP',
    Default = false,
    Callback = function(Value) Cheat.Toggles.Box = Value end
}):AddColorPicker('BoxColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Box Color',
    Callback = function(Value)
        Cheat.Colors.BoxMain = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.MainStroke then esp.MainStroke.Color = Value end
        end
    end
})

VisualsSection:AddToggle('NameESP', {
    Text = 'Name ESP',
    Default = false,
    Callback = function(Value) Cheat.Toggles.Name = Value end
}):AddColorPicker('NameColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Name Color',
    Callback = function(Value)
        Cheat.Colors.Name = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.NameLabel then esp.NameLabel.TextColor3 = Value end
        end
    end
})

VisualsSection:AddToggle('DistanceESP', {
    Text = 'Distance ESP',
    Default = false,
    Callback = function(Value) Cheat.Toggles.Distance = Value end
}):AddColorPicker('DistanceColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Distance Color',
    Callback = function(Value)
        Cheat.Colors.Distance = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.DistanceLabel then esp.DistanceLabel.TextColor3 = Value end
        end
    end
})

VisualsSection:AddToggle('HPText', {
    Text = 'HP Text',
    Default = false,
    Callback = function(Value) Cheat.Toggles.HPText = Value end
}):AddColorPicker('HPTextColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'HP Text Color',
    Callback = function(Value)
        Cheat.Colors.HealthText = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.HealthText then esp.HealthText.TextColor3 = Value end
        end
    end
})

VisualsSection:AddToggle('HPBar', {
    Text = 'HP Bar',
    Default = false,
    Callback = function(Value) Cheat.Toggles.HPBar = Value end
}):AddColorPicker('HPBarStart', {
    Default = Color3.new(1, 1, 1),
    Title = 'HP Bar Start',
    Callback = function(Value)
        Cheat.Colors.HealthGradientStart = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then esp.UpdateGradient() end
        end
    end
}):AddColorPicker('HPBarMid', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'HP Bar Mid',
    Callback = function(Value)
        Cheat.Colors.HealthGradientMid = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then esp.UpdateGradient() end
        end
    end
}):AddColorPicker('HPBarEnd', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'HP Bar End',
    Callback = function(Value)
        Cheat.Colors.HealthGradientEnd = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then esp.UpdateGradient() end
        end
    end
})

do
    VisualsSection:AddToggle('ChamsToggle', {
    Text = 'Player Chams (Local)',
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


end


VisualsSection:AddToggle('WeaponESP', {
    Text = 'Weapon ESP',
    Default = false,
    Callback = function(Value) Cheat.Toggles.WeaponName = Value end
}):AddColorPicker('WeaponColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Weapon Color',
    Callback = function(Value)
        Cheat.Colors.WeaponName = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.ToolLabel then esp.ToolLabel.TextColor3 = Value end
        end
    end
})

-- =============================================
-- Crate ESP (ящики)
-- =============================================
if not Cheat.Crate then Cheat.Crate = {} end
Cheat.Crate.Toggle = Cheat.Crate.Toggle or false
Cheat.Crate.NameColor = Cheat.Crate.NameColor or Color3.new(1, 1, 1)
Cheat.Crate.DistColor = Cheat.Crate.DistColor or Color3.new(0.7, 1, 0.7)
Cheat.Crate.Distance = Cheat.Crate.Distance or 200

local crateList = {}
local function updateCrateList()
    local containers = workspace:FindFirstChild("Containers")
    if not containers then return end
    local mainGroup = containers:GetChildren()[151]
    if not mainGroup then return end
    local indexes = {27, 29, 26, 15, 12, 11}
    local newList = {}
    for _, idx in ipairs(indexes) do
        local obj = mainGroup:GetChildren()[idx]
        if obj then table.insert(newList, obj) end
    end
    crateList = newList
end
updateCrateList()
if #crateList == 0 then
    local function scanForContainers(parent)
        local result = {}
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("Model") then
                table.insert(result, child)
            end
            local deeper = scanForContainers(child)
            for _, d in ipairs(deeper) do table.insert(result, d) end
        end
        return result
    end
    local folder = workspace:FindFirstChild("Containers")
    if folder then crateList = scanForContainers(folder) end
end

local function getCratePosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local pivot = obj:GetPivot()
        if pivot then return pivot.Position end
    end
    return nil
end

local function getCrateName(obj)
    if obj:IsA("Model") then return obj.Name end
    local parent = obj.Parent
    if parent and (parent:IsA("Model") or parent:IsA("Folder")) then return parent.Name end
    return obj.Name
end

local crateEspObjects = {}

local function createCrateESP(obj)
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Font = Drawing.Fonts.UI
    nameText.Color = Cheat.Crate.NameColor
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0,0,0)
    nameText.Center = true

    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Font = Drawing.Fonts.UI
    distText.Color = Cheat.Crate.DistColor
    distText.Outline = true
    distText.OutlineColor = Color3.new(0,0,0)
    distText.Center = true

    crateEspObjects[obj] = { nameText, distText }
end

local function removeCrateESP(obj)
    local texts = crateEspObjects[obj]
    if texts then
        texts[1]:Remove()
        texts[2]:Remove()
        crateEspObjects[obj] = nil
    end
end

local function clearCrateESP()
    for obj, texts in pairs(crateEspObjects) do
        texts[1]:Remove()
        texts[2]:Remove()
    end
    crateEspObjects = {}
end

local function applyCrateColors()
    for _, texts in pairs(crateEspObjects) do
        texts[1].Color = Cheat.Crate.NameColor
        texts[2].Color = Cheat.Crate.DistColor
    end
end

local function updateCrateESP()
    if not Cheat.Crate.Toggle then
        for _, texts in pairs(crateEspObjects) do
            texts[1].Visible = false
            texts[2].Visible = false
        end
        return
    end

    local char = LocalPlayer.Character
    if not char then
        for _, texts in pairs(crateEspObjects) do
            texts[1].Visible = false
            texts[2].Visible = false
        end
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local rootPos = root.Position
    local maxDist = Cheat.Crate.Distance

    local existing = {}
    for _, c in ipairs(crateList) do
        if c and c.Parent then existing[c] = true end
    end
    for c in pairs(crateEspObjects) do
        if not existing[c] then removeCrateESP(c) end
    end

    for _, crate in ipairs(crateList) do
        if not crate or not crate.Parent then
            if crateEspObjects[crate] then removeCrateESP(crate) end
            continue
        end

        local pos = getCratePosition(crate)
        if not pos then
            if crateEspObjects[crate] then
                crateEspObjects[crate][1].Visible = false
                crateEspObjects[crate][2].Visible = false
            end
            continue
        end

        local dist = (pos - rootPos).Magnitude
        if dist > maxDist then
            if crateEspObjects[crate] then
                crateEspObjects[crate][1].Visible = false
                crateEspObjects[crate][2].Visible = false
            end
            continue
        end

        if not crateEspObjects[crate] then createCrateESP(crate) end
        local texts = crateEspObjects[crate]
        local name = getCrateName(crate)

        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if onScreen then
            texts[1].Position = Vector2.new(screenPos.X, screenPos.Y - 25)
            texts[1].Text = name
            texts[1].Visible = true

            texts[2].Position = Vector2.new(screenPos.X, screenPos.Y - 10)
            texts[2].Text = string.format("%.1f м", dist)
            texts[2].Visible = true
        else
            texts[1].Visible = false
            texts[2].Visible = false
        end
    end
end

local crateConnection = RunService.RenderStepped:Connect(updateCrateESP)

LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        clearCrateESP()
        if crateConnection then crateConnection:Disconnect() end
    end
end)

VisualsSection:AddToggle('CrateESP', {
    Text = 'crate ESP',
    Default = Cheat.Crate.Toggle,
    Callback = function(v)
        Cheat.Crate.Toggle = v
        if not v then
            for _, texts in pairs(crateEspObjects) do
                texts[1].Visible = false
                texts[2].Visible = false
            end
        end
    end
})
:AddColorPicker('CrateNameColor', {
    Default = Cheat.Crate.NameColor,
    Title = 'Name Color',
    Callback = function(v)
        Cheat.Crate.NameColor = v
        applyCrateColors()
    end
})
:AddColorPicker('CrateDistColor', {
    Default = Cheat.Crate.DistColor,
    Title = 'Distance Color',
    Callback = function(v)
        Cheat.Crate.DistColor = v
        applyCrateColors()
    end
})



-- =============================================
-- Death Chams
-- =============================================
local deathSettings = {
    Enabled = false,
    Transparency = 0.5,
    Color = Color3.fromRGB(255, 100, 100),
    Duration = 3,
    Material = "ForceField"
}

VisualsSection:AddToggle('DeathChams', {
    Text = 'Death Chams',
    Default = deathSettings.Enabled,
    Callback = function(v)
        deathSettings.Enabled = v
        if not v then
            for _, cham in ipairs(deathChams) do
                if cham and cham.Parent then cham:Destroy() end
            end
            table.clear(deathChams)
        end
    end
})

local deathChams = {}

-- Функция для воспроизведения 3D звука на месте смерти
local function playDeathSound(position)
    if not position then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1255040462"
    sound.Volume = 5 -- Увеличиваем громкость для дальности
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.MaxDistance = 250 -- Максимальная дистанция слышимости
    sound.MinDistance = 10 -- Минимальная дистанция (на этом расстоянии звук самый громкий)
    
    -- Создаем невидимый объект в месте смерти
    local soundPart = Instance.new("Part")
    soundPart.Anchored = true
    soundPart.CanCollide = false
    soundPart.Transparency = 1
    soundPart.Size = Vector3.new(1, 1, 1)
    soundPart.Position = position
    soundPart.Parent = workspace
    
    sound.Parent = soundPart
    sound:Play()
    
    -- Удаляем объект со звуком после воспроизведения
    task.spawn(function()
        task.wait(sound.TimeLength)
        if soundPart and soundPart.Parent then
            soundPart:Destroy()
        end
    end)
end

local function createDeathChams(character, position)
    if not character or not position then return end
    
    -- Воспроизводим 3D звук на месте смерти
    playDeathSound(position)
    
    character.Archivable = true
    local clone = character:Clone()
    character.Archivable = false
    clone.Parent = Workspace
    clone:SetPrimaryPartCFrame(CFrame.new(position))
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material[deathSettings.Material]
            part.Color = deathSettings.Color
            part.Transparency = deathSettings.Transparency
            for _, decal in ipairs(part:GetChildren()) do
                if decal:IsA("Decal") or decal:IsA("SurfaceAppearance") then
                    decal:Destroy()
                end
            end
        end
    end
    local humanoid = clone:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:Destroy() end
    table.insert(deathChams, clone)
    task.spawn(function()
        task.wait(deathSettings.Duration)
        if clone and clone.Parent then
            clone:Destroy()
            for i, v in ipairs(deathChams) do
                if v == clone then
                    table.remove(deathChams, i)
                    break
                end
            end
        end
    end)
end

local lastHealth = {}
local lastPosition = {}

local function checkDeaths()
    for _, player in ipairs(PlayersService:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char.Parent then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local currentHealth = hum.Health
                    local last = lastHealth[player]
                    local lastPos = lastPosition[player]
                    if last and last > 0 and currentHealth <= 0 then
                        local deathPos = char:FindFirstChild("HumanoidRootPart")
                        if deathPos then
                            createDeathChams(char, deathPos.Position)
                        elseif lastPos then
                            createDeathChams(char, lastPos)
                        end
                    end
                    if currentHealth > 0 then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then lastPosition[player] = root.Position end
                    end
                    lastHealth[player] = currentHealth
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if deathSettings.Enabled then checkDeaths() end
    end
end)

for _, player in ipairs(PlayersService:GetPlayers()) do
    if player ~= LocalPlayer then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then lastHealth[player] = hum.Health end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then lastPosition[player] = root.Position end
    end
end

PlayersService.PlayerAdded:Connect(function(player)
    lastHealth[player] = nil
    lastPosition[player] = nil
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then lastHealth[player] = hum.Health end
    end)
end)



-- =============================================
-- Arms Chams
-- =============================================
local arms_settings = {
    Gun = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.ForceField },
    Arms = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Material = Enum.Material.ForceField }
}

local originals = {}

local function saveOriginal(part)
    if not originals[part] then
        originals[part] = { Material = part.Material, Color = part.Color }
    end
end

local function applyGunChams(gunModel)
    if not gunModel or not arms_settings.Gun.Enabled then return end
    for _, part in pairs(gunModel:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            saveOriginal(part)
            part.Material = arms_settings.Gun.Material
            part.Color = arms_settings.Gun.Color
            local surf = part:FindFirstChildOfClass("SurfaceAppearance")
            if surf then surf:Destroy() end
        end
    end
end

local function applyArmsChams(viewModel)
    if not viewModel or not arms_settings.Arms.Enabled then return end
    for _, child in pairs(viewModel:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("MeshPart") then
            local name = child.Name:lower()
            if name:find("hand") or name:find("arm") or name:find("wrist") then
                saveOriginal(child)
                child.Material = arms_settings.Arms.Material
                child.Color = arms_settings.Arms.Color
            end
        end
        if child:IsA("Model") then
            for _, part in pairs(child:GetDescendants()) do
                if (part:IsA("BasePart") or part:IsA("MeshPart")) and 
                   (part.Name:lower():find("hand") or part.Name:lower():find("arm")) then
                    saveOriginal(part)
                    part.Material = arms_settings.Arms.Material
                    part.Color = arms_settings.Arms.Color
                end
            end
        end
    end
end

function updateChams()
    local viewModel = Camera:FindFirstChild("ViewModel") or Camera:FindFirstChildOfClass("Model")
    if not viewModel or viewModel.Name ~= "ViewModel" then
        for _, child in pairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name == "ViewModel" then
                viewModel = child
                break
            end
        end
    end
    if not viewModel then return end
    if arms_settings.Gun.Enabled then
        local gunModel = viewModel:FindFirstChild("Item")
        if gunModel then applyGunChams(gunModel) end
    end
    if arms_settings.Arms.Enabled then applyArmsChams(viewModel) end
end

ArmsSection:AddToggle('GunChams', {
    Text = 'Gun Chams',
    Default = false,
    Callback = function(Value)
        arms_settings.Gun.Enabled = Value
        updateChams()
    end
}):AddColorPicker('GunColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Gun Color',
    Callback = function(Value)
        arms_settings.Gun.Color = Value
        updateChams()
    end
})

ArmsSection:AddToggle('ArmsChams', {
    Text = 'Arms Chams',
    Default = false,
    Callback = function(Value)
        arms_settings.Arms.Enabled = Value
        updateChams()
    end
}):AddColorPicker('ArmsColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Arms Color',
    Callback = function(Value)
        arms_settings.Arms.Color = Value
        updateChams()
    end
})

Camera.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "ViewModel" then
        task.wait(0.05)
        updateChams()
    end
end)
Camera.DescendantAdded:Connect(function()
    task.wait(0.03)
    updateChams()
end)
task.wait(1)
updateChams()
-- =============================================
-- Viewmodel Offset (рабочий, без ошибок CFrame)
-- =============================================
do
    local vm_settings = { Enabled = false, Offset = Vector3.new(0, 0, 0) }
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Находим корневую часть модели (HumanoidRootPart)
    local function getRootPart(model)
        if not model then return nil end
        -- Сначала ищем HumanoidRootPart
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp end
        -- Если нет, ищем любой BasePart (например, UpperTorso)
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            end
        end
        return nil
    end

    -- Применяем смещение к одной модели (сдвигаем корневую часть)
    local function applyOffsetToModel(model)
        if not model or not vm_settings.Enabled then return end
        local rootPart = getRootPart(model)
        if not rootPart then return end
        
        -- Смещение в локальной системе камеры (влево/вправо, вверх/вниз, вперёд/назад)
        local offset = vm_settings.Offset
        -- Преобразуем в мировые координаты с учётом поворота камеры
        local worldOffset = Camera.CFrame:VectorToWorldSpace(offset)
        -- Перемещаем корневую часть (остальные части пойдут за ней благодаря соединениям)
        rootPart.CFrame = rootPart.CFrame + worldOffset
    end

    -- Применяем ко всем моделям ViewModel
    local function applyOffsetToAll()
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name == "ViewModel" then
                applyOffsetToModel(child)
            end
        end
    end

    -- Сброс (возврат на исходную позицию)
    local function resetAll()
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name == "ViewModel" then
                local rootPart = getRootPart(child)
                if rootPart then
                    rootPart.CFrame = rootPart.CFrame - vm_settings.Offset
                end
            end
        end
    end

    -- Цикл обновления
    local connection
    local function startLoop()
        if connection then connection:Disconnect() end
        connection = RunService.RenderStepped:Connect(applyOffsetToAll)
    end

    local function stopLoop()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        resetAll()
    end

    -- UI (ArmsSection предполагается существующим)
    ArmsSection:AddToggle('VMEnabled', {
        Text = 'Enable Viewmodel Offset',
        Default = false,
        Callback = function(v)
            vm_settings.Enabled = v
            if v then
                startLoop()
            else
                stopLoop()
            end
        end
    })

    ArmsSection:AddSlider('VM_X', {
        Text = 'Offset X (Left/Right)',
        Default = 0, Min = -5, Max = 5, Rounding = 2,
        Callback = function(v)
            vm_settings.Offset = Vector3.new(v, vm_settings.Offset.Y, vm_settings.Offset.Z)
            if vm_settings.Enabled then applyOffsetToAll() end
        end
    })
    ArmsSection:AddSlider('VM_Y', {
        Text = 'Offset Y (Up/Down)',
        Default = 0, Min = -5, Max = 5, Rounding = 2,
        Callback = function(v)
            vm_settings.Offset = Vector3.new(vm_settings.Offset.X, v, vm_settings.Offset.Z)
            if vm_settings.Enabled then applyOffsetToAll() end
        end
    })
    ArmsSection:AddSlider('VM_Z', {
        Text = 'Offset Z (Forward/Back)',
        Default = 0, Min = -5, Max = 5, Rounding = 2,
        Callback = function(v)
            vm_settings.Offset = Vector3.new(vm_settings.Offset.X, vm_settings.Offset.Y, v)
            if vm_settings.Enabled then applyOffsetToAll() end
        end
    })

    -- Обработка появления новой модели
    Camera.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name == "ViewModel" then
            task.wait(0.05)
            if vm_settings.Enabled then
                applyOffsetToModel(child)
            end
        end
    end)

    -- Инициализация
    task.wait(0.5)
    if vm_settings.Enabled then
        startLoop()
    end
end
do
-- Целевые папки со звуками (укажите свои пути)
local targets = {
game:GetService("ReplicatedStorage").SFX.Hits.MeleeHits.Blood.Hit,
game:GetService("ReplicatedStorage").SFX.Hits.ProjectileHits.Blood.Hit
}

-- Предустановленные звуки
local presetSounds = {
    { Name = "Bameware", ID = "rbxassetid://3124331820" },
    { Name = "Bell", ID = "rbxassetid://6534947240" },
    { Name = "Bubble", ID = "rbxassetid://6534947588" },
    { Name = "Pick", ID = "rbxassetid://1347140027" },
    { Name = "Pop", ID = "rbxassetid://198598793" },
    { Name = "Rust", ID = "rbxassetid://1255040462" },
    { Name = "Skeet", ID = "rbxassetid://5633695679" },
    { Name = "Neverlose", ID = "rbxassetid://6534948092" },
    { Name = "Minecraft", ID = "rbxassetid://4018616850" },
    { Name = "Steve", ID = "rbxassetid://4965083997" },
    { Name = "CS:GO", ID = "rbxassetid://6937353691" },
    { Name = "TF2 Critical", ID = "rbxassetid://296102734" },
    { Name = "Call of Duty", ID = "rbxassetid://5952120301" },
    { Name = "Gamesense", ID = "rbxassetid://4817809188" },
    { Name = "Among Us", ID = "rbxassetid://5700183626" },
    { Name = "Mario", ID = "rbxassetid://2815207981" },
    { Name = "Bamboo", ID = "rbxassetid://3769434519" },
}

-- Переменные состояния
local enabled = false
local currentSoundId = DEFAULT_SOUND_ID
local currentVolume = 1
local originalSounds = {}
local childConnections = {}

-- Массивы для дропдауна (только названия)
local soundNames = {}
local soundIds = {}
for _, s in ipairs(presetSounds) do
    table.insert(soundNames, s.Name)
    table.insert(soundIds, s.ID)
end

-- Вспомогательные функции (логика замены)
local function getAllSounds(obj, list)
    list = list or {}
    if not obj then return list end
    if obj:IsA("Sound") then table.insert(list, obj) end
    for _, child in ipairs(obj:GetChildren()) do
        getAllSounds(child, list)
    end
    return list
end

local function applySoundReplacement(sound)
    if not sound or not sound:IsA("Sound") then return end
    if not originalSounds[sound] then
        originalSounds[sound] = sound.SoundId
    end
    sound.SoundId = currentSoundId
    sound.Volume = currentVolume
end

local function restoreOriginalSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    local originalId = originalSounds[sound]
    if originalId then
        sound.SoundId = originalId
        originalSounds[sound] = nil
    end
end

local function replaceAllSounds()
    for _, target in ipairs(targets) do
        if target then
            for _, sound in ipairs(getAllSounds(target)) do
                applySoundReplacement(sound)
            end
        end
    end
end

local function restoreAllSounds()
    for sound, _ in pairs(originalSounds) do
        restoreOriginalSound(sound)
    end
    originalSounds = {}
end

local function updateVolumeForAll()
    for sound, _ in pairs(originalSounds) do
        if sound and sound:IsA("Sound") then
            sound.Volume = currentVolume
        else
            originalSounds[sound] = nil
        end
    end
end

local function updateSoundIdForAll()
    for sound, _ in pairs(originalSounds) do
        if sound and sound:IsA("Sound") then
            sound.SoundId = currentSoundId
        else
            originalSounds[sound] = nil
        end
    end
end

local function setupChildAddedListeners()
    for _, target in ipairs(targets) do
        if target and not childConnections[target] then
            childConnections[target] = target.ChildAdded:Connect(function(child)
                if enabled then
                    task.wait()
                    for _, sound in ipairs(getAllSounds(child)) do
                        applySoundReplacement(sound)
                    end
                end
            end)
        end
    end
end

local function removeChildAddedListeners()
    for target, conn in pairs(childConnections) do
        conn:Disconnect()
        childConnections[target] = nil
    end
end

local function setEnabled(state)
    if enabled == state then return end
    enabled = state
    if enabled then
        replaceAllSounds()
        setupChildAddedListeners()
    else
        restoreAllSounds()
        removeChildAddedListeners()
    end
end

-- === СОЗДАНИЕ ПРАВОЙ ГРУППЫ ===



-- Переключатель
local Toggle = HitSection:AddToggle("EnableToggle", {
    Text = "Enable",
    Default = false,
})
Toggle:OnChanged(function()
    setEnabled(Toggle.Value)
end)

-- Ползунок громкости
local VolumeSlider = HitSection:AddSlider("VolumeSlider", {
    Text = "Volume",
    Min = 0,
    Max = 2,
    Default = 1,
    Rounding = 2,
})
VolumeSlider:OnChanged(function()
    currentVolume = VolumeSlider.Value
    if enabled then updateVolumeForAll() end
end)

-- Выпадающий список (только названия)
local SoundDropdown = HitSection:AddDropdown("SoundDropdown", {
    Values = soundNames,
    Default = 1,
    Multi = false,
    Text = "Sound Preset",
})

-- Обработка выбора
SoundDropdown:OnChanged(function()
    local selectedName = SoundDropdown.Value
    for i, name in ipairs(soundNames) do
        if name == selectedName then
            currentSoundId = soundIds[i]
            break
        end
    end
    if enabled then updateSoundIdForAll() end
end)

-- Поле ввода кастомного ID
local SoundIdInput = HitSection:AddInput("SoundIdInput", {
    Text = "Custom ID",
    Default = "rbxassetid://...",
    Placeholder = "Enter asset ID",
    Numeric = false,
    Finished = false,
})

-- Кнопка добавления звука
HitSection:AddButton({
    Text = "Add Custom",
    Func = function()
        local id = SoundIdInput.Value
        if id and id ~= "" then
            -- Проверяем уникальность ID
            for _, existingId in ipairs(soundIds) do
                if existingId == id then
                    Library:Notify("Already exists")
                    return
                end
            end
            local name = "Custom: " .. (id:match("%d+") or id)
            table.insert(soundNames, name)
            table.insert(soundIds, id)
            SoundDropdown:SetValues(soundNames)
            SoundDropdown:SetValue(name)
            currentSoundId = id
            if enabled then updateSoundIdForAll() end
            Library:Notify("Sound added")
        end
    end,
})

-- Кнопка удаления выбранного
HitSection:AddButton({
    Text = "Remove Selected",
    Func = function()
        local selectedName = SoundDropdown.Value
        if not selectedName then return end
        local index
        for i, name in ipairs(soundNames) do
            if name == selectedName then
                index = i
                break
            end
        end
        if index and index > #presetSounds then
            table.remove(soundNames, index)
            table.remove(soundIds, index)
            SoundDropdown:SetValues(soundNames)
            if #soundNames > 0 then
                SoundDropdown:SetValue(soundNames[1])
                currentSoundId = soundIds[1]
            else
                -- Восстанавливаем дефолтный пресет
                soundNames = { presetSounds[1].Name }
                soundIds = { presetSounds[1].ID }
                SoundDropdown:SetValues(soundNames)
                SoundDropdown:SetValue(soundNames[1])
                currentSoundId = presetSounds[1].ID
            end
            if enabled then updateSoundIdForAll() end
            Library:Notify("Removed")
        elseif index then
            Library:Notify("Cannot remove preset")
        end
    end,
})

-- Кнопка теста
HitSection:AddButton({
    Text = "Test Sound",
    Func = function()
        local s = Instance.new("Sound")
        s.SoundId = currentSoundId
        s.Volume = currentVolume
        s.Parent = game:GetService("SoundService")
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    end,
})

-- Информационная строка
HitSection:AddLabel("Current ID: " .. currentSoundId)
end
do
-- =============================================
-- Instant Hit (без FOV, с поддержкой GUI-кнопки)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки (убраны все параметры FOV)
local settings = {
    enabled = false,
    keybind = "E",          -- клавиша для удержания (None = постоянно)
    delay = 0.05,           -- задержка между выстрелами
    hitpart = "Head"        -- часть тела для попадания
}

-- Получить текущее оружие
local function getCurrentWeapon()
    local rpPlayers = ReplicatedStorage:FindFirstChild("Players")
    if not rpPlayers then return nil end
    
    local playerData = rpPlayers:FindFirstChild(LocalPlayer.Name)
    if not playerData then return nil end
    
    local inventory = playerData:FindFirstChild("Inventory")
    if not inventory then return nil end
    
    local status = playerData:FindFirstChild("Status")
    local gameplayVars = status and status:FindFirstChild("GameplayVariables")
    local equippedTool = gameplayVars and gameplayVars:FindFirstChild("EquippedTool")
    
    if equippedTool and equippedTool.Value then
        return inventory:FindFirstChild(equippedTool.Value.Name)
    end
    
    return nil
end

-- Получить ближайшую цель (без ограничения FOV)
local function getClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local inset = game:GetService("GuiService"):GetGuiInset().Y
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(settings.hitpart)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if targetPart and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y - inset) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- Выстрел (пакетный)
local function shootPacket(targetPart)
    local FireProjectile = ReplicatedStorage:FindFirstChild("Remotes") and 
                           ReplicatedStorage.Remotes:FindFirstChild("FireProjectile")
    local ProjectileInflict = ReplicatedStorage:FindFirstChild("Remotes") and 
                              ReplicatedStorage.Remotes:FindFirstChild("ProjectileInflict")
    
    if not FireProjectile or not ProjectileInflict then 
        return false 
    end
    
    local weapon = getCurrentWeapon()
    if not weapon then return false end
    
    local shotId = math.random(-10000, 10000)
    local shootTime = tick()
    
    -- Отправляем выстрел
    FireProjectile:InvokeServer(Vector3.new(0/0, 0/0, 0/0), shotId, shootTime)
    
    -- Отправляем попадание (мгновенное)
    ProjectileInflict:FireServer(
        targetPart,
        targetPart.CFrame:ToObjectSpace(CFrame.new(targetPart.Position + Vector3.new(0, 0.001, 0))),
        shotId,
        0/0
    )
    
    return true
end

-- Основной цикл
local lastShot = 0
local function onRender()
    if not settings.enabled then return end
    
    -- Проверка клавиши
    if settings.keybind ~= "None" then
        local key = Enum.KeyCode[settings.keybind]
        if key and not UserInputService:IsKeyDown(key) then
            return
        end
    end
    
    -- Задержка между выстрелами
    if tick() - lastShot < settings.delay then return end
    
    -- Получаем цель
    local target = getClosestTarget()
    if not target then return end
    
    -- Получаем AimPart (ствол)
    local viewModel = Camera:FindFirstChild("ViewModel")
    local aimPart = viewModel and viewModel:FindFirstChild("AimPart")
    
    if aimPart then
        -- Наводим ствол на цель
        aimPart.CFrame = CFrame.lookAt(aimPart.Position, target.Position)
        
        -- Стреляем
        shootPacket(target)
        lastShot = tick()
    end
end

-- Подключаем рендер
RunService.RenderStepped:Connect(onRender)

-- Консольные команды (без FOV-функций)
_G.Instahit = {
    Enable = function() 
        settings.enabled = true
        print("[Instahit] Включен")
    end,
    Disable = function() 
        settings.enabled = false
        print("[Instahit] Выключен")
    end,
    SetKey = function(key)
        settings.keybind = key
        print("[Instahit] Клавиша: " .. key)
    end,
    SetDelay = function(delay)
        settings.delay = delay
        print("[Instahit] Задержка: " .. delay .. "s")
    end,
    SetHitPart = function(part)
        settings.hitpart = part
        print("[Instahit] Часть тела: " .. part)
    end
}

print([[
╔════════════════════════════════════════╗
║      Instant Hit (без FOV, GUI-ready)  ║
╠════════════════════════════════════════╣
║  Команды:                              ║
║    _G.Instahit.Enable()                ║
║    _G.Instahit.Disable()               ║
║    _G.Instahit.SetKey("E")             ║
║    _G.Instahit.SetDelay(0.05)          ║
║    _G.Instahit.SetHitPart("Head")      ║
╚════════════════════════════════════════╝
]])
end
-- =============================================
-- Gun Settings (Rapid Fire, No Recoil)
-- =============================================
local gun_settings = {
    RapidFire = { Enabled = false, MultiTap = 3, Delay = 3.5, FireRate = 0.001 },
    NoRecoil = false,
    NoSpread = false
}
local gun_originals = { FireRates = {}, FireModes = {}, AccuracyDeviation = {} }

GunSection:AddToggle('RapidFire', {
    Text = 'Rapid Fire',
    Default = false,
    Callback = function(v) gun_settings.RapidFire.Enabled = v; updateRapidFire() end
})

GunSection:AddToggle('NoRecoil', {
    Text = 'No Recoil',
    Default = false,
    Callback = function(v) gun_settings.NoRecoil = v; updateNoRecoil() end
})
GunSection:AddToggle('NoSpreadGun', {
    Text = 'No Spread',
    Default = false,
    Callback = function(v) gun_settings.NoSpread = v end
})

GunSection:AddToggle('InstaHit', {
     Text = 'Insta Hit',
     Default = false,
    Callback = function(v)
         if v then
             _G.Instahit.Enable()
         else
             _G.Instahit.Disable()
         end
   end
})


GunSection:AddSlider('RapidFireMultiTap', {
    Text = 'Multi-Tap', Default = 3, Min = 1, Max = 10, Rounding = 0, Suffix = 'x',
    Callback = function(v) gun_settings.RapidFire.MultiTap = v end
})
GunSection:AddSlider('RapidFireDelay', {
    Text = 'Fire Delay (ms)', Default = 3.5, Min = 1, Max = 15, Rounding = 1, Suffix = 'ms',
    Callback = function(v) gun_settings.RapidFire.Delay = v end
})

local function saveOriginalGunSettings(gun)
    if not gun then return end
    local settModule = gun:FindFirstChild("SettingsModule")
    if settModule and not gun_originals.FireRates[gun] then
        local sett = require(settModule)
        gun_originals.FireRates[gun] = sett.FireRate
        gun_originals.FireModes[gun] = sett.FireModes
    end
end

local function updateRapidFire()
    local invFolder = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
    if not invFolder then return end
    local inv = invFolder:FindFirstChild("Inventory")
    if not inv then return end
    for _, gun in ipairs(inv:GetChildren()) do
        local settModule = gun:FindFirstChild("SettingsModule")
        if settModule then
            saveOriginalGunSettings(gun)
            local sett = require(settModule)
            if gun_settings.RapidFire.Enabled then
                sett.FireRate = gun_settings.RapidFire.FireRate
                sett.FireModes = {"Auto"}
            else
                if gun_originals.FireRates[gun] then sett.FireRate = gun_originals.FireRates[gun] end
                if gun_originals.FireModes[gun] then sett.FireModes = gun_originals.FireModes[gun]
                else sett.FireModes = {"Semi", "Auto", "Burst"} end
            end
        end
    end
end

local BulletModule = require(ReplicatedStorage.Modules.FPS.Bullet)
local old_CreateBullet = BulletModule.CreateBullet
BulletModule.CreateBullet = function(self, ...)
    local args = { ... }
    if gun_settings.RapidFire.Enabled then
        for i = 1, gun_settings.RapidFire.MultiTap do
            task.spawn(function()
                local delay = (i-1) * (gun_settings.RapidFire.Delay / 1000) + math.random(1,5) * 0.001
                task.wait(delay)
                pcall(old_CreateBullet, self, unpack(args))
            end)
        end
        return
    end
    return old_CreateBullet(self, unpack(args))
end

local function updateNoRecoil()
    for _, gc in next, getgc(true) do
        if type(gc) == "table" then
            if rawget(gc, "shove") and rawget(gc, "update") then
                local shove = gc.shove
                gc.shove = function(...)
                    if gun_settings.NoRecoil then return end
                    return shove(...)
                end
            end
            if type(rawget(gc, "create")) == "function" and getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" then
                local old_create = gc.create
                gc.create = function(...)
                    local returns = old_create(...)
                    local shove = returns.shove
                    returns.shove = function(...)
                        if gun_settings.NoRecoil then return end
                        return shove(...)
                    end
                    return returns
                end
            end
        end
    end
end

local mt2 = getrawmetatable(game)
local old_namecall2 = mt2.__namecall
setreadonly(mt2, false)
mt2.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "GetAttribute" and gun_settings.NoSpread then
        local attribute = args[1]
        if attribute == "AccuracyDeviation" then return 0 end
    end
    return old_namecall2(self, ...)
end)
setreadonly(mt2, true)

local function init()
    task.wait(1)
    local invFolder = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
    if invFolder then
        local inv = invFolder:FindFirstChild("Inventory")
        if inv then
            for _, gun in ipairs(inv:GetChildren()) do saveOriginalGunSettings(gun) end
        end
    end
    updateRapidFire()
    updateNoRecoil()
end
init()

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child.Name == LocalPlayer.Name then
        child.ChildAdded:Connect(function(invChild)
            if invChild.Name == "Inventory" then
                invChild.ChildAdded:Connect(function(gun)
                    task.wait(0.1)
                    saveOriginalGunSettings(gun)
                    updateRapidFire()
                end)
            end
        end)
    end
end)

-- =============================================
-- World Settings (исправленная версия с восстановлением)
-- =============================================
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChild("Terrain")

-- Настройки
local world_settings = {
    Time = { Enabled = false, Value = 14, Original = nil },
    Ambient = { Enabled = false, Color1 = Color3.fromRGB(90,90,90), Color2 = Color3.fromRGB(150,150,150), Original1 = nil, Original2 = nil },
    NoFog = false,
    NoGrass = false,
    NoShadows = false,
    NoLeaves = false,
    Sky = { Enabled = false, Preset = "Galaxy" }
}

-- Сохраняем оригинальные значения при запуске скрипта
world_settings.Time.Original = Lighting.ClockTime
world_settings.Ambient.Original1 = Lighting.Ambient
world_settings.Ambient.Original2 = Lighting.OutdoorAmbient
local original_fog_start = Lighting.FogStart
local original_fog_end = Lighting.FogEnd

-- Функция для листьев
local function setFoliageTransparency(transparent)
    local trans = transparent and 1 or 0
    local foliage = Workspace:FindFirstChild("SpawnerZones") and Workspace.SpawnerZones:FindFirstChild("Foliage")
    if foliage then
        for _, zone in ipairs(foliage:GetChildren()) do
            for _, item in ipairs(zone:GetChildren()) do
                for _, part in ipairs(item:GetDescendants()) do
                    if part:IsA("BasePart") and part:FindFirstChild("SurfaceAppearance") then
                        part.Transparency = trans
                    end
                end
            end
        end
    end
end

-- Функция для травы
local function setNoGrass(enable)
    pcall(function()
        sethiddenproperty(Terrain, "Decoration", not enable)
    end)
end

-- Функция, которая применяет ВСЕ настройки мира (вызывается при каждом изменении)
local function ApplyWorldSettings()
    -- Time Changer
    if world_settings.Time.Enabled then
        Lighting.ClockTime = world_settings.Time.Value
    else
        Lighting.ClockTime = world_settings.Time.Original
    end

    -- Ambient
    if world_settings.Ambient.Enabled then
        Lighting.Ambient = world_settings.Ambient.Color1
        Lighting.OutdoorAmbient = world_settings.Ambient.Color2
    else
        Lighting.Ambient = world_settings.Ambient.Original1
        Lighting.OutdoorAmbient = world_settings.Ambient.Original2
    end

    -- Fog
    if world_settings.NoFog then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100000
    else
        Lighting.FogStart = original_fog_start
        Lighting.FogEnd = original_fog_end
    end

    -- Shadows
    Lighting.GlobalShadows = not world_settings.NoShadows

    -- Grass
    setNoGrass(world_settings.NoGrass)

    -- Leaves (применяется сразу и будет поддерживаться циклом)
    if world_settings.NoLeaves then
        setFoliageTransparency(true)
    else
        setFoliageTransparency(false)
    end
end

-- =============================================
-- Небо (Sky Changer)
-- =============================================
local function ClearSkybox()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function DisableCloudsFogAndSun()
    -- Облака
    if Terrain then
        local Clouds = Terrain:FindFirstChildWhichIsA("Clouds")
        if Clouds then
            pcall(function()
                Clouds.Enabled = false
                Clouds.Cover = 0
                Clouds.Density = 0
            end)
        end
    end
    -- Атмосфера
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            pcall(function()
                obj.Density = 0
                obj.Offset = 0
                obj.Glare = 0
                obj.Haze = 0
            end)
        end
    end
    -- Убираем солнце/луну из существующих Sky
    for _, sky in pairs(Lighting:GetChildren()) do
        if sky:IsA("Sky") then
            pcall(function() sky.CelestialBodiesShown = false end)
        end
    end
end

local function SetSkybox(presetName)
    ClearSkybox()
    local sky = Instance.new("Sky")
    sky.Name = "CustomSky"

    local presets = {
        Galaxy = {
            Bk = "rbxassetid://149397692",
            Dn = "rbxassetid://149397686",
            Ft = "rbxassetid://149397697",
            Lf = "rbxassetid://149397684",
            Rt = "rbxassetid://149397688",
            Up = "rbxassetid://149397702"
        },
        ["Galaxy 2"] = {
            Bk = "rbxassetid://155441936",
            Dn = "rbxassetid://155441802",
            Ft = "rbxassetid://155441818",
            Lf = "rbxassetid://155441777",
            Rt = "rbxassetid://155441874",
            Up = "rbxassetid://155441905"
        },
        Saturne = {
            Bk = "rbxassetid://1898724755",
            Dn = "rbxassetid://1898727189",
            Ft = "rbxassetid://1898722814",
            Lf = "rbxassetid://1898729298",
            Rt = "rbxassetid://1898741025",
            Up = "rbxassetid://1898736761"
        },
        Neptune = {
            Bk = "rbxassetid://218955819",
            Dn = "rbxassetid://218953419",
            Ft = "rbxassetid://218954524",
            Lf = "rbxassetid://218958493",
            Rt = "rbxassetid://218957134",
            Up = "rbxassetid://218950090"
        },
        Redshift = {
            Bk = "rbxassetid://401664839",
            Dn = "rbxassetid://401664862",
            Ft = "rbxassetid://401664960",
            Lf = "rbxassetid://401664881",
            Rt = "rbxassetid://401664901",
            Up = "rbxassetid://401664936"
        },
        ["Pink Daylights"] = {
            Bk = "rbxassetid://11555017034",
            Dn = "rbxassetid://11555013415",
            Ft = "rbxassetid://11555010145",
            Lf = "rbxassetid://11555006545",
            Rt = "rbxassetid://11555000712",
            Up = "rbxassetid://11554996247"
        },
        ["Purple Night"] = {
            Bk = "rbxassetid://17279854976",
            Dn = "rbxassetid://17279856318",
            Ft = "rbxassetid://17279858447",
            Lf = "rbxassetid://17279860360",
            Rt = "rbxassetid://17279862234",
            Up = "rbxassetid://17279864507"
        },
        ["Anime Sky"] = {
            Bk = "rbxassetid://18351376859",
            Dn = "rbxassetid://18351374919",
            Ft = "rbxassetid://18351376800",
            Lf = "rbxassetid://18351376469",
            Rt = "rbxassetid://18351376457",
            Up = "rbxassetid://18351377189"
        }
    }

    local p = presets[presetName]
    if p then
        sky.SkyboxBk = p.Bk
        sky.SkyboxDn = p.Dn
        sky.SkyboxFt = p.Ft
        sky.SkyboxLf = p.Lf
        sky.SkyboxRt = p.Rt
        sky.SkyboxUp = p.Up
        sky.CelestialBodiesShown = false
        sky.Parent = Lighting
    end
end

local function ApplySky()
    if world_settings.Sky.Enabled then
        Lighting.ClockTime = 10          -- день
        DisableCloudsFogAndSun()
        SetSkybox(world_settings.Sky.Preset)
    else
        ClearSkybox()
        -- Восстанавливаем оригинальные настройки освещения, которые могли быть изменены
        Lighting.ClockTime = world_settings.Time.Original
        -- Возвращаем настройки fog, если нужно (но они уже восстановлены в ApplyWorldSettings)
        ApplyWorldSettings()
    end
end

-- =============================================
-- UI элементы
-- =============================================

-- Time Changer
WorldSection:AddToggle('TimeChanger', {
    Text = 'Enable Time Changer',
    Default = false,
    Callback = function(v)
        world_settings.Time.Enabled = v
        ApplyWorldSettings()
    end
})
WorldSection:AddSlider('TimeValue', {
    Text = 'Time',
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(v)
        world_settings.Time.Value = v
        if world_settings.Time.Enabled then ApplyWorldSettings() end
    end
})

-- Ambient
local ambientToggle = WorldSection:AddToggle('Ambient', {
    Text = 'Enable Ambient',
    Default = false,
    Callback = function(v)
        world_settings.Ambient.Enabled = v
        ApplyWorldSettings()
    end
})
ambientToggle:AddColorPicker('AmbientColor1', {
    Default = Color3.fromRGB(90,90,90),
    Title = 'Ambient Color 1',
    Callback = function(v)
        world_settings.Ambient.Color1 = v
        if world_settings.Ambient.Enabled then ApplyWorldSettings() end
    end
})
ambientToggle:AddColorPicker('AmbientColor2', {
    Default = Color3.fromRGB(150,150,150),
    Title = 'Ambient Color 2',
    Callback = function(v)
        world_settings.Ambient.Color2 = v
        if world_settings.Ambient.Enabled then ApplyWorldSettings() end
    end
})

-- No Fog
WorldSection:AddToggle('NoFog', {
    Text = 'No Fog',
    Default = false,
    Callback = function(v)
        world_settings.NoFog = v
        ApplyWorldSettings()
    end
})

-- No Grass
WorldSection:AddToggle('NoGrass', {
    Text = 'No Grass',
    Default = false,
    Callback = function(v)
        world_settings.NoGrass = v
        ApplyWorldSettings()
    end
})

-- No Shadows
WorldSection:AddToggle('NoShadows', {
    Text = 'No Shadows',
    Default = false,
    Callback = function(v)
        world_settings.NoShadows = v
        ApplyWorldSettings()
    end
})

-- No Leaves
WorldSection:AddToggle('NoLeaves', {
    Text = 'No Leaves',
    Default = false,
    Callback = function(v)
        world_settings.NoLeaves = v
        ApplyWorldSettings()
    end
})

-- Sky Changer
WorldSection:AddToggle('SkyChanger', {
    Text = 'Custom Sky',
    Default = false,
    Callback = function(v)
        world_settings.Sky.Enabled = v
        ApplySky()
    end
})
WorldSection:AddDropdown('SkyPreset', {
    Text = 'Sky Preset',
    Values = {
        "Galaxy",
        "Galaxy 2",
        "Saturne",
        "Neptune",
        "Redshift",
        "Pink Daylights",
        "Purple Night",
        "Anime Sky"
    },
    Default = "Galaxy",
    Callback = function(v)
        world_settings.Sky.Preset = v
        if world_settings.Sky.Enabled then ApplySky() end
    end
})

-- =============================================
-- Постоянное обновление (Heartbeat)
-- =============================================
RunService.Heartbeat:Connect(function()
    -- Эти настройки могут меняться динамически, поэтому обновляем в цикле
    if world_settings.Time.Enabled then
        Lighting.ClockTime = world_settings.Time.Value
    else
        -- Если time выключен, но какое-то другое изменение могло повлиять на время,
        -- мы его не трогаем, потому что ApplyWorldSettings уже восстановило оригинал.
        -- Однако если мы хотим быть уверены, что время не изменится без нашего ведома,
        -- можно добавить проверку:
        if Lighting.ClockTime ~= world_settings.Time.Original then
            Lighting.ClockTime = world_settings.Time.Original
        end
    end
    if world_settings.Ambient.Enabled then
        Lighting.Ambient = world_settings.Ambient.Color1
        Lighting.OutdoorAmbient = world_settings.Ambient.Color2
    else
        -- Аналогично, если ambient выключен, можно ничего не делать,
        -- но для надёжности можно вернуть оригинал:
        if Lighting.Ambient ~= world_settings.Ambient.Original1 then
            Lighting.Ambient = world_settings.Ambient.Original1
        end
        if Lighting.OutdoorAmbient ~= world_settings.Ambient.Original2 then
            Lighting.OutdoorAmbient = world_settings.Ambient.Original2
        end
    end
    if world_settings.NoFog then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100000
    else
        if Lighting.FogStart ~= original_fog_start then Lighting.FogStart = original_fog_start end
        if Lighting.FogEnd ~= original_fog_end then Lighting.FogEnd = original_fog_end end
    end
    Lighting.GlobalShadows = not world_settings.NoShadows
end)

-- Цикл для листьев (чтобы они не появлялись снова)
task.spawn(function()
    while true do
        task.wait(5)
        if world_settings.NoLeaves then
            setFoliageTransparency(true)
        end
    end
end)

-- Применяем настройки при загрузке (на случай, если они уже были включены)
ApplyWorldSettings()
if world_settings.Sky.Enabled then ApplySky() end
-- =============================================
-- Tracer Line
-- =============================================
local tracer_settings = {
    Line = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Thickness = 2.5, Transparency = 0.9 },
    Beam = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }
}

local TracerLine = Drawing.new("Line")
TracerLine.Thickness = tracer_settings.Line.Thickness
TracerLine.Color = tracer_settings.Line.Color
TracerLine.Transparency = tracer_settings.Line.Transparency
TracerLine.Visible = false
-- =============================================
-- Tracer Line (обновлённая версия)
-- =============================================
-- Замени **полностью** старую функцию get_closest_target_tracer на эту новую:

local function get_closest_target_tracer()
    local target_part = nil
    local closestDist = math.huge
    
    -- Используем ту же точку мыши, что и в Silent Aim (с учётом топбара)
    local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    -- Если включён "Use FOV" — ограничиваем по размеру FOV, иначе — по всему экрану
    local max_distance = silent_aim.use_fov and silent_aim.fov_size or math.huge

    for _, plr in ipairs(PlayersService:GetPlayers()) do
        if plr ~= LocalPlayer and not isMyClone(plr) then
            local character = plr.Character
            if character then
                local part = character:FindFirstChild("Head") -- трасса всегда на голову
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if part and humanoid and humanoid.Health > 0 then
                    local position, on_screen = Camera:WorldToViewportPoint(part.Position)
                    
                    if on_screen then
                        local distance = (Vector2.new(position.X, position.Y) - mouse_pos).Magnitude
                        
                        -- Проверяем расстояние (FOV / весь экран) И видимость через стенку
                        if distance <= max_distance and distance < closestDist and is_visible(part) then
                            target_part = part
                            closestDist = distance
                        end
                    end
                end
            end
        end
    end
    return target_part
end
local function make_beam_tracer(Origin, Position, Color)
    -- Защита от nil значений
    if not Origin or not Position then
        warn("make_beam_tracer: Origin or Position is nil")
        return nil, nil, nil
    end
    
    -- Убеждаемся, что это векторы (на случай, если переданы числа)
    local originVec = type(Origin) == "Vector3" and Origin or Vector3.new(Origin.X or 0, Origin.Y or 0, Origin.Z or 0)
    local positionVec = type(Position) == "Vector3" and Position or Vector3.new(Position.X or 0, Position.Y or 0, Position.Z or 0)
    
    local part1 = Instance.new("Part", Workspace)
    local part2 = Instance.new("Part", Workspace)
    part1.Position = originVec
    part2.Position = positionVec
    part1.Transparency = 1
    part2.Transparency = 1
    part1.CanCollide = false
    part2.CanCollide = false
    part1.Size = Vector3.zero
    part2.Size = Vector3.zero
    part1.Anchored = true
    part2.Anchored = true
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", Workspace)
    Beam.Name = "BulletTracer"
    Beam.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color) }
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Texture = "rbxassetid://12781806168"
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 1
    Beam.Width1 = 0.07
    return Beam, part1, part2
end





AimbotSection:AddToggle('BulletTracer', {
    Text = 'Bullet Tracer',
    Default = false,
    Callback = function(v) tracer_settings.Beam.Enabled = v end
}):AddColorPicker('BulletTracerColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Bullet Color',
    Callback = function(v) tracer_settings.Beam.Color = v end
})

RunService.RenderStepped:Connect(function()
    TracerLine.Thickness = tracer_settings.Line.Thickness
    TracerLine.Color = tracer_settings.Line.Color
    TracerLine.Transparency = tracer_settings.Line.Transparency
    if not tracer_settings.Line.Enabled then
        TracerLine.Visible = false
        return
    end
    local targetPart = get_closest_target_tracer()
    if not targetPart then
        TracerLine.Visible = false
        return
    end
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if onScreen then
        local topbarHeight = game:GetService("GuiService"):GetGuiInset().Y
        TracerLine.From = Vector2.new(Mouse.X, Mouse.Y + topbarHeight)
        TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
        TracerLine.Visible = true
    else
        TracerLine.Visible = false
    end
end)

local BulletModuleTracer = require(ReplicatedStorage.Modules.FPS.Bullet)
local old_CreateBulletTracer = BulletModuleTracer.CreateBullet
BulletModuleTracer.CreateBullet = function(self, ...)
    local args = { ... }
    if tracer_settings.Beam.Enabled then
        local aimpart_index
        for i, v in ipairs(args) do
            if typeof(v) == "Instance" and v.Name == "AimPart" then
                aimpart_index = i
                break
            end
        end
        if aimpart_index and args[aimpart_index] then
            local targetPart = get_closest_target_tracer()
            local startPos = args[aimpart_index].Position
            local endPos = targetPart and targetPart.Position or (args[aimpart_index].CFrame.LookVector * 10000)
            local beam, p1, p2 = make_beam_tracer(startPos, endPos, tracer_settings.Beam.Color)
            local wtf = -1
            local conn
            conn = RunService.RenderStepped:Connect(function(delta)
                wtf = wtf + delta
                beam.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
                if wtf >= 1 then
                    beam:Destroy()
                    p1:Destroy()
                    p2:Destroy()
                    conn:Disconnect()
                end
            end)
        end
    end
    return old_CreateBulletTracer(self, unpack(args))
end

-- Настройки для FOV (зум)
local fov_settings = {
    Enabled = false,
    Value = 40,      -- стандартное значение FOV в Roblox
}

-- Функция применения FOV
local function applyFOV()
    local camera = workspace.CurrentCamera
    if not camera then return end
    if fov_settings.Enabled then
        -- Устанавливаем сохранённое значение FOV
        camera.FieldOfView = fov_settings.Value
    else
        -- Если отключено, возвращаем стандартное значение 70
        camera.FieldOfView = 70
    end
end

-- Создаём элементы в MiscSection
-- 1. Переключатель "Zoom (FOV)"
OtherSection:AddToggle('FOVToggle', {
    Text = 'Zoom (FOV)',
    Default = false,
    Callback = function(v)
        fov_settings.Enabled = v
        applyFOV()
    end
})

-- 2. Кейбинд для быстрого включения/выключения (опционально)
OtherSection:AddLabel('Keybind'):AddKeyPicker('FOVKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Keybind Zoom',
    NoUI = false,
    Callback = function(Value)
        fov_settings.Enabled = Value
        applyFOV()
    end
})

-- 3. Слайдер для изменения значения FOV (от 1 до 120)
OtherSection:AddSlider('FOVValue', {
    Text = 'Zoom Amount',
    Default = 40,
    Min = 1,
    Max = 50,
    Rounding = 0,       -- целые числа
    Suffix = ' deg',
    Callback = function(v)
        fov_settings.Value = v
        if fov_settings.Enabled then
            applyFOV()
        end
    end
})

-- (Опционально) Принудительное удержание FOV каждый кадр, если игра его сбрасывает
-- Раскомментируйте, если необходимо

game:GetService("RunService").RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if camera and fov_settings.Enabled then
        if camera.FieldOfView ~= fov_settings.Value then
            camera.FieldOfView = fov_settings.Value
        end
    end
end)




-- =============================================
-- Third Person
-- =============================================
local thirdperson_settings = {
    Enabled = false,
    Offset = Vector3.new(2, 2, 6),
    MaxZoom = 400,
    MinZoom = 0.5,
    ForceVisible = true
}

local function applyThirdPerson()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    if thirdperson_settings.Enabled then
        hum.CameraOffset = thirdperson_settings.Offset
        LocalPlayer.CameraMaxZoomDistance = thirdperson_settings.MaxZoom
        LocalPlayer.CameraMinZoomDistance = thirdperson_settings.MinZoom
    else
        hum.CameraOffset = Vector3.zero
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end

OtherSection:AddToggle('ThirdPerson', {
    Text = 'Third Person',
    Default = false,
    Callback = function(v)
        thirdperson_settings.Enabled = v
        applyThirdPerson()
    end
})
OtherSection:AddLabel('Keybind'):AddKeyPicker('ThirdPersonKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Keybind Third Person',
    NoUI = false,
    Callback = function(Value)
        thirdperson_settings.Enabled = Value
        applyThirdPerson()
    end
})
OtherSection:AddSlider('ThirdPersonDistance', {
    Text = 'Camera Distance',
    Default = 6, Min = 1, Max = 20, Rounding = 1, Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(thirdperson_settings.Offset.X, thirdperson_settings.Offset.Y, v)
        if thirdperson_settings.Enabled then applyThirdPerson() end
    end
})
OtherSection:AddSlider('ThirdPersonHeight', {
    Text = 'Camera Height',
    Default = 2, Min = -5, Max = 10, Rounding = 1, Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(thirdperson_settings.Offset.X, v, thirdperson_settings.Offset.Z)
        if thirdperson_settings.Enabled then applyThirdPerson() end
    end
})
OtherSection:AddSlider('ThirdPersonSide', {
    Text = 'Camera Side Offset',
    Default = 2, Min = -10, Max = 10, Rounding = 1, Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(v, thirdperson_settings.Offset.Y, thirdperson_settings.Offset.Z)
        if thirdperson_settings.Enabled then applyThirdPerson() end
    end
})

local mt3 = getrawmetatable(game)
local old_newindex = mt3.__newindex
setreadonly(mt3, false)
mt3.__newindex = newcclosure(function(self, key, value)
    if thirdperson_settings.Enabled and self:IsA("Humanoid") and key == "CameraOffset" then
        if value ~= thirdperson_settings.Offset then return end
    end
    return old_newindex(self, key, value)
end)
setreadonly(mt3, true)

RunService.RenderStepped:Connect(function()
    if not thirdperson_settings.Enabled or not thirdperson_settings.ForceVisible then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.LocalTransparencyModifier = 0
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if thirdperson_settings.Enabled then applyThirdPerson() end
end)
task.wait(1)
if thirdperson_settings.Enabled then applyThirdPerson() end





-- =============================================
-- Speed Hack (исправленная версия)
-- =============================================

local speed_settings = { Enabled = false, Speed = 23 }
local loop_running = false
local anti_cheat_connections_disabled = false

-- Функция отключения античитовских соединений
local function disableAntiCheat()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local signals = {
        {humanoid:GetPropertyChangedSignal("WalkSpeed"), "CharacterController"},
        {humanoid:GetPropertyChangedSignal("JumpHeight"), "CharacterController"},
        {humanoid:GetPropertyChangedSignal("HipHeight"), "CharacterController"},
        {workspace:GetPropertyChangedSignal("Gravity"), "CharacterController"},
        {humanoid.StateChanged, "CharacterController"},
        {humanoid.ChildAdded, "CharacterController"},
        {humanoid.ChildRemoved, "CharacterController"}
    }

    for _, connData in ipairs(signals) do
        local signal = connData[1]
        local sourceName = connData[2]
        if signal and getconnections then
            local connections = getconnections(signal)
            if connections then
                for _, connection in ipairs(connections) do
                    if connection and connection.Function then
                        local success, info = pcall(function() return debug.getinfo(connection.Function) end)
                        if success and info and info.source then
                            if string.find(info.source, sourceName) then
                                pcall(function() connection:Disable() end)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Принудительная установка скорости
local function setSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if speed_settings.Enabled then
        humanoid.WalkSpeed = speed_settings.Speed
    else
        humanoid.WalkSpeed = 16
    end
end

-- Основной цикл поддержки скорости
local function startSpeedLoop()
    if loop_running then return end
    loop_running = true

    task.spawn(function()
        while loop_running and speed_settings.Enabled do
            -- Отключаем античит каждые 0.5 секунды, чтобы перехватить восстановленные соединения
            pcall(disableAntiCheat)
            -- Устанавливаем скорость
            pcall(setSpeed)
            task.wait(0.5)
        end
        loop_running = false
    end)
end

-- Обработчик переключения скорости
MisSection:AddToggle('SpeedHack', {
    Text = 'Speed Hack',
    Default = false,
    Callback = function(v)
        speed_settings.Enabled = v
        if v then
            startSpeedLoop()
        else
            loop_running = false
            pcall(setSpeed) -- сброс до 16
        end
    end
})

-- Ползунок скорости
MisSection:AddSlider('SpeedValue', {
    Text = 'Speed',
    Default = 23, Min = 16, Max = 30, Rounding = 1, Suffix = 'sps',
    Callback = function(v)
        speed_settings.Speed = v
        if speed_settings.Enabled then
            pcall(setSpeed)
        end
    end
})

-- Следим за сменой персонажа, перезапускаем цикл
LocalPlayer.CharacterAdded:Connect(function()
    loop_running = false
    task.wait(0.5)
    if speed_settings.Enabled then
        startSpeedLoop()
    end
end)

-- Запуск при загрузке скрипта
task.wait(1)
if speed_settings.Enabled then
    startSpeedLoop()
end

-- =============================================
-- FOV Changer
-- =============================================
-- =============================================
-- FOV Changer
-- =============================================


-- =============================================
-- Inventory Checker (включён по умолчанию)
-- =============================================

local inv_settings = { Enabled = false, Position = Vector2.new(200, 200), Delay = 0.25 }
local inv_objects = {}
local inventoryItems = {}

local function newDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do obj[i] = v end
    table.insert(inv_objects, obj)
    return obj
end

local function removeAllDrawings()
    for i, obj in ipairs(inv_objects) do pcall(function() obj:Remove() end); inv_objects[i] = nil end
    inventoryItems = {}
end

local function addInventoryText(text, size)
    local textObj = newDrawing("Text", {
        Text = text, Size = size, Font = Drawing.Fonts.Monospace, Outline = true, Center = false,
        Position = inv_settings.Position + Vector2.new(0, (size + 1) * #inventoryItems),
        Transparency = 1, Visible = true, Color = Color3.new(1, 1, 1), ZIndex = 1,
    })
    table.insert(inventoryItems, textObj)
end

local function clearInventory()
    for i, obj in ipairs(inventoryItems) do pcall(function() obj:Remove() end); inventoryItems[i] = nil end
    inventoryItems = {}
end

local function updateInventory(playerName)
    clearInventory()
    local rplayers = ReplicatedStorage.Players
    local targetPlayer
    for _, rplayer in ipairs(rplayers:GetChildren()) do
        if rplayer.Name == playerName then targetPlayer = rplayer; break end
    end
    if not targetPlayer then return end
    addInventoryText(targetPlayer.Name .. " Inventory", 13)
    addInventoryText("[Inventory]", 13)
    local inventory = targetPlayer:FindFirstChild("Inventory")
    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            addInventoryText("    " .. item.Name, 13)
        end
    end
end

local function get_closest_target_inv()
    local ermm_part = nil
    local maximum_distance = math.huge
    local mousepos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    for _, plr in ipairs(PlayersService:GetPlayers()) do
        if plr ~= LocalPlayer then
            if isMyClone(plr) then continue end
            local character = plr.Character
            if character then
                local part = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local position, onscreen = Camera:WorldToViewportPoint(part.Position)
                    local distance = (Vector2.new(position.X, position.Y - guiInset.Y) - mousepos).Magnitude
                    if onscreen and distance <= maximum_distance then
                        ermm_part = part
                        maximum_distance = distance
                    end
                end
            end
        end
    end
    return ermm_part
end

local lastUpdateInv = 0
local currentTargetInv = nil


OtherSection:AddToggle('InventoryChecker', {
    Text = 'Inventory Checker',
    Default = false,
    Callback = function(Value)
        inv_settings.Enabled = Value
        if not Value then
            clearInventory()
            for _, obj in ipairs(inv_objects) do obj.Visible = false end
        end
    end
})
OtherSection:AddSlider('InvPositionX', {
    Text = 'Position X', Default = 200, Min = 0, Max = 1000, Rounding = 0, Suffix = 'px',
    Callback = function(Value) inv_settings.Position = Vector2.new(Value, inv_settings.Position.Y) end
})
OtherSection:AddSlider('InvPositionY', {
    Text = 'Position Y', Default = 200, Min = 0, Max = 1000, Rounding = 0, Suffix = 'px',
    Callback = function(Value) inv_settings.Position = Vector2.new(inv_settings.Position.X, Value) end
})
OtherSection:AddSlider('InvUpdateDelay', {
    Text = 'Update Delay', Default = 0.25, Min = 0.1, Max = 1, Rounding = 2, Suffix = 's',
    Callback = function(Value) inv_settings.Delay = Value end
})

RunService.RenderStepped:Connect(function()
    for i, obj in ipairs(inventoryItems) do
        obj.Position = inv_settings.Position + Vector2.new(0, (14 + 1) * (i-1))
    end
    if not inv_settings.Enabled then
        for _, obj in ipairs(inv_objects) do obj.Visible = false end
        return
    else
        for _, obj in ipairs(inv_objects) do obj.Visible = true end
    end
    local targetPart = get_closest_target_inv()
    local targetName = targetPart and targetPart.Parent and targetPart.Parent.Name
    local currentTime = tick()
    if targetName and targetName ~= currentTargetInv and currentTime - lastUpdateInv >= inv_settings.Delay then
        currentTargetInv = targetName
        lastUpdateInv = currentTime
        updateInventory(targetName)
    elseif not targetName then
        clearInventory()
        currentTargetInv = nil
    end
end)


do
    local fov_settings = { Enabled = false, Value = 90 }
    local defaultFOV = Camera.FieldOfView
    
    -- Создаём секцию Other (если её ещё нет)
    
    local function setFOV(value)
        if fov_settings.Enabled then Camera.FieldOfView = value end
    end
    
    OtherSection:AddToggle('FOVEnabled', {
        Text = 'FOV Changer',
        Default = false,
        Callback = function(Value)
            fov_settings.Enabled = Value
            if fov_settings.Enabled then setFOV(fov_settings.Value)
            else Camera.FieldOfView = defaultFOV end
        end
    })
    
    OtherSection:AddSlider('FOVRadius', {
        Text = 'FOV Radius',
        Default = 90, Min = 1, Max = 200, Rounding = 0, Suffix = 'deg',
        Callback = function(Value)
            fov_settings.Value = Value
            if fov_settings.Enabled then setFOV(fov_settings.Value) end
        end
    })
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        task.wait(1)
        if fov_settings.Enabled then Camera.FieldOfView = fov_settings.Value end
    end)
    
    RunService.RenderStepped:Connect(function()
        if fov_settings.Enabled and Camera.FieldOfView ~= fov_settings.Value then
            Camera.FieldOfView = fov_settings.Value
        end
    end)
end


-- =============================================
-- Visibility Checker
-- =============================================
local vis_settings = { Enabled = false, TextSize = 13, YOffset = 50 }
local visibilityText = Drawing.new("Text")
visibilityText.Visible = false
visibilityText.Center = true
visibilityText.Size = vis_settings.TextSize
visibilityText.Outline = true
visibilityText.Font = Drawing.Fonts.Monospace
visibilityText.Color = Color3.new(1, 1, 1)

local function isVisibleTarget(targetPart)
    if not targetPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Workspace:FindFirstChild("NoCollision"), Camera, LocalPlayer.Character }
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = Workspace:Raycast(origin, direction, params)
    if not result then return true end
    if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return false
end

local function get_target_in_fov()
    local target = nil
    local closestDist = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local fovSize = silent_aim.fov_size or 300
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    for _, plr in ipairs(PlayersService:GetPlayers()) do
        if plr ~= LocalPlayer then
            if isMyClone(plr) then continue end
            local char = plr.Character
            if char then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y - guiInset.Y) - mousePos).Magnitude
                        if dist <= fovSize and dist < closestDist then
                            closestDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

AimbotSection:AddToggle('VisibilityChecker', {
    Text = 'Visibility Checker',
    Default = false,
    Callback = function(Value)
        vis_settings.Enabled = Value
        if not Value then visibilityText.Visible = false end
    end
})

RunService.RenderStepped:Connect(function()
    local screenSize = Camera.ViewportSize
    visibilityText.Position = Vector2.new(screenSize.X / 2, screenSize.Y - vis_settings.YOffset)
    visibilityText.Size = vis_settings.TextSize
    if not vis_settings.Enabled then
        visibilityText.Visible = false
        return
    end
    local targetPart = get_target_in_fov()
    if targetPart then
        local visible = isVisibleTarget(targetPart)
        if visible then
            visibilityText.Text = "VISIBLE"
            visibilityText.Color = Color3.fromRGB(0, 255, 0)
        else
            visibilityText.Text = "NOT VISIBLE"
            visibilityText.Color = Color3.fromRGB(255, 0, 0)
        end
        visibilityText.Visible = true
    else
        visibilityText.Visible = false
    end
end)

-- =============================================
-- Tracer FOV
-- =============================================
local tracer_fov_settings = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.8 }
local TracerLineFOV = Drawing.new("Line")
TracerLineFOV.Thickness = tracer_fov_settings.Thickness
TracerLineFOV.Color = tracer_fov_settings.Color
TracerLineFOV.Transparency = tracer_fov_settings.Transparency
TracerLineFOV.Visible = false

AimbotSection:AddToggle('TracerFOV', {
    Text = 'Tracer FOV',
    Default = false,
    Callback = function(v) tracer_fov_settings.Enabled = v end
}):AddColorPicker('TracerFOVColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Tracer Color',
    Callback = function(v)
        tracer_fov_settings.Color = v
        TracerLineFOV.Color = v
    end
})
AimbotSection:AddSlider('FOVFilledTransparency', {
    Text = 'Filled Transparency',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = '%',
    Callback = function(value)
        silent_aim.fov_filled_transparency = value
        fov_circle_filled.Transparency = value
    end
})

-- FOV Size слайдер
AimbotSection:AddSlider('FOVSize', {
    Text = 'FOV Size',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Suffix = '%',
    Callback = function(percent)
        local fov_size = percentage_to_fov_size(percent)
        silent_aim.fov_size = fov_size
        fov_circle.Radius = fov_size
        fov_circle_outline.Radius = fov_size
        fov_circle_filled.Radius = fov_size
    end
})
AimbotSection:AddSlider('TracerFOVThickness', {
    Text = 'Tracer Thickness',
    Default = 2, Min = 1, Max = 5, Rounding = 1,
    Callback = function(v)
        tracer_fov_settings.Thickness = v
        TracerLineFOV.Thickness = v
    end
})


AimbotSection:AddSlider('TracerThickness', {
    Text = 'Line Thickness',
    Default = 1, Min = 1, Max = 5, Rounding = 1,
    Callback = function(v)
        tracer_settings.Line.Thickness = v
        TracerLine.Thickness = v
    end
})

RunService.RenderStepped:Connect(function()
    TracerLineFOV.Thickness = tracer_fov_settings.Thickness
    TracerLineFOV.Color = tracer_fov_settings.Color
    TracerLineFOV.Transparency = tracer_fov_settings.Transparency
    if not tracer_fov_settings.Enabled then
        TracerLineFOV.Visible = false
        return
    end
    local targetPart = get_target_in_fov()
    if not targetPart then
        TracerLineFOV.Visible = false
        return
    end
    local visible = isVisibleTarget(targetPart)
    if not visible then
        TracerLineFOV.Visible = false
        return
    end
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if onScreen then
        local topbarHeight = game:GetService("GuiService"):GetGuiInset().Y
        TracerLineFOV.From = Vector2.new(Mouse.X, Mouse.Y + topbarHeight)
        TracerLineFOV.To = Vector2.new(screenPos.X, screenPos.Y)
        TracerLineFOV.Visible = true
    else
        TracerLineFOV.Visible = false
    end
end)

-- =============================================
-- Anchored Resolver
-- =============================================
local resolver_settings = { Enabled = false, Velocity = 2500, Delay = 0.05, Offset = 20, Resolving = false }

local function performAnchoredResolve()
    if resolver_settings.Resolving then return end
    resolver_settings.Resolving = true
    local char = LocalPlayer.Character
    if not char then resolver_settings.Resolving = false; return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then resolver_settings.Resolving = false; return end
    local cached = root.CFrame
    root.Velocity = Vector3.new(0, -resolver_settings.Velocity, 0)
    task.wait(resolver_settings.Delay)
    root.Anchored = true
    root.CFrame = cached + Vector3.new(0, -resolver_settings.Offset, 0)
    task.wait(resolver_settings.Delay * 10)
    root.Anchored = false
    root.CFrame = cached
    root.Velocity = Vector3.new(0, 0, 0)
    resolver_settings.Resolving = false
end

local AnchoredResolveToggle = MisSection:AddToggle('AnchoredResolve', {
    Text = 'Anchored Resolve',
    Default = false,
    Callback = function(state)
        resolver_settings.Enabled = state
        if state then performAnchoredResolve() end
    end
})
MisSection:AddLabel('Keybind'):AddKeyPicker('AnchoredResolveKeybind', {
    Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Anchored Resolve Keybind', NoUI = false,
    Callback = function(state)
        resolver_settings.Enabled = state
        AnchoredResolveToggle:SetValue(state)
        if state then performAnchoredResolve() end
    end
})

-- =============================================
-- Fly Hack
-- =============================================
local fly_settings = { Enabled = false, Speed = 10, YSpeed = 10 }
local FlyToggle = MisSection:AddToggle('Fly', {
    Text = 'Fly',
    Default = false,
    Callback = function(value) fly_settings.Enabled = value end
})
MisSection:AddLabel('Keybind'):AddKeyPicker('FlyKeybind', {
    Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Fly Keybind', NoUI = false,
    Callback = function(state)
        fly_settings.Enabled = state
        FlyToggle:SetValue(state)
    end
})
MisSection:AddSlider('FlySpeed', {
    Text = 'Fly Speed', Default = 10, Min = 1, Max = 30, Rounding = 1, Suffix = 'studs/s',
    Callback = function(value) fly_settings.Speed = value end
})
MisSection:AddSlider('FlyYSpeed', {
    Text = 'Y Fly Speed', Default = 10, Min = 1, Max = 30, Rounding = 1, Suffix = 'studs/s',
    Callback = function(value) fly_settings.YSpeed = value end
})

RunService.Heartbeat:Connect(function(delta)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if fly_settings.Enabled and hrp then
        local camLook = Camera.CFrame.LookVector
        camLook = Vector3.new(camLook.X, 0, camLook.Z)
        local horDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then horDir = horDir + camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then horDir = horDir - camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then horDir = horDir + Vector3.new(-camLook.Z, 0, camLook.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then horDir = horDir + Vector3.new(camLook.Z, 0, -camLook.X) end
        local vertDir = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertDir = vertDir + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertDir = vertDir - 1 end
        if horDir ~= Vector3.zero then hrp.CFrame = hrp.CFrame + horDir.Unit * delta * fly_settings.Speed end
        if vertDir ~= 0 then hrp.CFrame = hrp.CFrame + Vector3.yAxis * vertDir * delta * fly_settings.YSpeed end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero end
        end
    end
end)

-- =============================================
-- Teleport Bot
-- =============================================
local teleport_settings = { SelectedObject = "None" }

local function teleportToMe(objectName)
    if objectName == "None" then return false end
    local target = workspace:FindFirstChild(objectName)
    if not target then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local playerPos = rootPart.Position
    local targetPos = playerPos + Vector3.new(0, 2, 0)
    if target:IsA("BasePart") then
        target.CFrame = CFrame.new(targetPos)
    elseif target:IsA("Model") then
        local primaryPart = target.PrimaryPart
        if primaryPart then target:SetPrimaryPartCFrame(CFrame.new(targetPos))
        else
            local hrp = target:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(targetPos) end
        end
    end
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(3, 3, 3)
    effect.Position = targetPos
    effect.Anchored = true
    effect.CanCollide = false
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 100, 0)
    effect.Transparency = 0.3
    effect.Parent = workspace
    task.delay(0.5, function() effect:Destroy() end)
    return true
end

BotSection:AddDropdown('TeleportObject', {
    Text = 'Select Object to Teleport',
    Values = {"None", "Blaze", "Mihkel", "Designer", "Tarmo", "VaultManager"},
    Default = "None",
    Callback = function(v) teleport_settings.SelectedObject = v end
})
BotSection:AddButton({
    Text = 'Teleport Bot',
    Func = function()
        if teleport_settings.SelectedObject and teleport_settings.SelectedObject ~= "None" then
            teleportToMe(teleport_settings.SelectedObject)
        end
    end,
    DoubleClick = false,
    Tooltip = ''
})

-- Upside Down Anti-Aim Script
-- Перевёрнутый персонаж + компенсация камеры в первом лице
-- Управление через UI-секцию AntiAimSection

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local antiAimEnabled = false          -- текущее состояние
local currentConnection = nil         -- соединение с Heartbeat
local currentCharacter = nil           -- текущий персонаж

-- Функция, которая применяет переворот (включает эффект)
local function applyUpsideDown(character)
    if currentConnection then
        currentConnection:Disconnect()
    end
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")
    
    humanoid.AutoRotate = false
    
    currentConnection = RunService.Heartbeat:Connect(function()
        if not antiAimEnabled then return end
        if root and root.Parent and head and head.Parent then
            local pos = root.Position
            local camCf = camera.CFrame
            local lookVector = camCf.LookVector
            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            -- Устанавливаем корпус: смотрит в направлении камеры + переворот (roll 180°)
            root.CFrame = CFrame.lookAt(pos, pos + flatLook) * CFrame.Angles(0, 0, math.pi)
            -- В первом лице компенсируем переворот камеры, чтобы вид был нормальным
            if camera.CameraSubject == head then
                camera.CFrame = head.CFrame * CFrame.Angles(0, 0, -math.pi)
            end
        end
    end)
end

-- Функция, которая отключает эффект и возвращает всё в норму
local function removeUpsideDown()
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end
    if currentCharacter then
        local humanoid = currentCharacter:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
        -- Возвращаем корпус в нормальное положение (без переворота)
        local root = currentCharacter:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            local lookVector = camera.CFrame.LookVector
            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            root.CFrame = CFrame.lookAt(pos, pos + flatLook)
        end
    end
    -- Если камера была вручную изменена, сбрасываем её к голове
    if camera.CameraSubject == currentCharacter and currentCharacter then
        local head = currentCharacter:FindFirstChild("Head")
        if head then
            camera.CFrame = head.CFrame
        end
    end
end

-- Универсальная функция включения/выключения
local function setAntiAimEnabled(value)
    antiAimEnabled = value
    if antiAimEnabled then
        if currentCharacter then
            applyUpsideDown(currentCharacter)
        end
    else
        removeUpsideDown()
    end
end

-- ========== Интеграция с UI (предполагается существование AntiAimSection) ==========
do
    AntiAimSection:AddToggle('AntiAim', {
        Text = 'AntiAim',
        Default = false,
        Callback = function(v)
            setAntiAimEnabled(v)
        end
    })
    AntiAimSection:AddLabel('Keybind'):AddKeyPicker('AntiAimKeybind', {
        Default = '',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Keybind Anti Aim',
        NoUI = false,
        Callback = function(Value)
            setAntiAimEnabled(Value)
        end
    })
end

-- ========== Обработка персонажа ==========
if player.Character then
    currentCharacter = player.Character
    if antiAimEnabled then
        applyUpsideDown(currentCharacter)
    end
end

player.CharacterAdded:Connect(function(character)
    currentCharacter = character
    if antiAimEnabled then
        applyUpsideDown(character)
    end
end)
-- =============================================
-- Arrows (индикаторы за спиной)
-- =============================================
do
    local DistFromCenter = 80
    local TriangleHeight = 16
    local TriangleWidth = 16
    local TriangleFilled = true
    local TriangleTransparency = 0
    local TriangleThickness = 1
    local TriangleColor = Color3.fromRGB(255, 255, 255)
    local AntiAliasing = false
    local ArrowsEnabled = false

    local Players = game:service("Players")
    local Player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RS = game:service("RunService")

    local V3 = Vector3.new
    local V2 = Vector2.new
    local CF = CFrame.new
    local COS = math.cos
    local SIN = math.sin
    local RAD = math.rad
    local DRAWING = Drawing.new
    local CWRAP = coroutine.wrap
    local ROUND = math.round

    local function GetRelative(pos, char)
        if not char then return V2(0,0) end
        local rootP = char.PrimaryPart.Position
        local camP = Camera.CFrame.Position
        local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)
        return V2(relative.X, relative.Z)
    end

    local function RelativeToCenter(v)
        return Camera.ViewportSize/2 - v
    end

    local function RotateVect(v, a)
        a = RAD(a)
        local x = v.x * COS(a) - v.y * SIN(a)
        local y = v.x * SIN(a) + v.y * COS(a)
        return V2(x, y)
    end

    local function DrawTriangle(color)
        local l = DRAWING("Triangle")
        l.Visible = false
        l.Color = color
        l.Filled = TriangleFilled
        l.Thickness = TriangleThickness
        l.Transparency = 1 - TriangleTransparency
        return l
    end

    local function AntiA(v)
        if (not AntiAliasing) then return v end
        return V2(ROUND(v.x), ROUND(v.y))
    end

    local Arrows = {}

    local function UpdateAllArrows()
        for _, arrowData in pairs(Arrows) do
            if arrowData.Arrow then
                arrowData.Arrow.Color = TriangleColor
                arrowData.Arrow.Filled = TriangleFilled
                arrowData.Arrow.Thickness = TriangleThickness
                arrowData.Arrow.Transparency = 1 - TriangleTransparency
                arrowData.Arrow.Visible = ArrowsEnabled
            end
        end
    end

    local function ShowArrow(PLAYER)
        local Arrow = DrawTriangle(TriangleColor)
        local function Update()
            local c ; c = RS.RenderStepped:Connect(function()
                if not ArrowsEnabled then
                    if Arrow then Arrow.Visible = false end
                    return
                end
                if PLAYER and PLAYER.Character then
                    local CHAR = PLAYER.Character
                    local HUM = CHAR:FindFirstChildOfClass("Humanoid")
                    if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                        local _,vis = Camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                        if vis == false then
                            local rel = GetRelative(CHAR.PrimaryPart.Position, Player.Character)
                            local direction = rel.unit
                            local base = direction * DistFromCenter
                            local sideLength = TriangleWidth / 2
                            local baseL = base + RotateVect(direction, 90) * sideLength
                            local baseR = base + RotateVect(direction, -90) * sideLength
                            local tip = direction * (DistFromCenter + TriangleHeight)
                            Arrow.PointA = AntiA(RelativeToCenter(baseL))
                            Arrow.PointB = AntiA(RelativeToCenter(baseR))
                            Arrow.PointC = AntiA(RelativeToCenter(tip))
                            Arrow.Visible = true
                        else
                            Arrow.Visible = false
                        end
                    else
                        Arrow.Visible = false
                    end
                else
                    Arrow.Visible = false
                    if not PLAYER or not PLAYER.Parent then
                        Arrow:Remove()
                        c:Disconnect()
                        Arrows[PLAYER] = nil
                    end
                end
            end)
        end
        Arrows[PLAYER] = {Arrow = Arrow, Update = Update}
        CWRAP(Update)()
    end

    -- Настройки (кнопка и цветопикер в одном)
    VisualsSection:AddToggle('ArrowsToggle', {
        Text = 'Arrows',
        Default = false,
        Callback = function(v)
            ArrowsEnabled = v
            UpdateAllArrows()
        end
    })
    :AddColorPicker('ArrowsColor', {
        Default = Color3.new(1, 1, 1),
        Title = 'Arrow Color',
        Callback = function(v)
            TriangleColor = v
            UpdateAllArrows()
        end
    })
    
    VisualsSection:AddSlider('ArrowsDistance', {
        Text = 'Arrows Distance (px)',
        Default = 80,
        Min = 30,
        Max = 2000,
        Rounding = 0,
        Callback = function(v)
            DistFromCenter = v
        end
    })
    
    VisualsSection:AddSlider('ArrowsSize', {
        Text = 'Arrow Size (px)',
        Default = 16,
        Min = 8,
        Max = 32,
        Rounding = 0,
        Callback = function(v)
            TriangleHeight = v
            TriangleWidth = v
        end
    })
    
    VisualsSection:AddSlider('ArrowsTransparency', {
        Text = 'Arrow Transparency',
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(v)
            TriangleTransparency = v
            UpdateAllArrows()
        end
    })

    -- Инициализация
    for _, v in pairs(Players:GetChildren()) do
        if v.Name ~= Player.Name then ShowArrow(v) end
    end
    Players.PlayerAdded:Connect(function(v)
        if v.Name ~= Player.Name then ShowArrow(v) end
    end)
end
do
    VisualsSection:AddSlider('FillTransparencySlider', {
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

VisualsSection:AddSlider('OutlineTransparencySlider', {
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
end





-- =============================================
-- UI Settings
-- =============================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

-- состояние
local arrowsEnabled = false

-- уведомление
local notifyPlayerChange = function(player, message, color)
    local prefix = "notification - player"
    Library:Notify(("%s | user: %s | %s"):format(prefix, player.DisplayName, message), 5, color)
end

-- функции "стрелок" (заглушки, сюда вставь свою логику)
local function startArrows()
end

local function stopArrows()
end

-- Toggle
MenuGroup:AddToggle('ArrowsToggle', {
    Text = 'Info Server',
    Default = true,
    Callback = function(v)
        arrowsEnabled = v

        if v then
            startArrows()
        else
            stopArrows()
        end
    end
})

-- игрок зашел
game.Players.PlayerAdded:Connect(function(player)
    if arrowsEnabled then
        notifyPlayerChange(player, "joined", Color3.fromRGB(0, 255, 0))
    end
end)

-- игрок вышел
game.Players.PlayerRemoving:Connect(function(player)
    if arrowsEnabled then
        notifyPlayerChange(player, "left", Color3.fromRGB(255, 0, 0))
    end
end)

do
    VisualsSection:AddSlider('CrateDistance', {
    Text = 'Crate Distance (m)',
    Default = Cheat.Crate.Distance,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Callback = function(v)
        Cheat.Crate.Distance = v
    end
})
end

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer

    -- FLAGS (если вдруг не созданы)
    flags = flags or {}
    flags["tbox"] = false
    flags["color tracer"] = Color3.new(1,1,1)
    flags["tracer transparency"] = 0
    flags["tracer smoothness"] = 0.12

    -- НАСТРОЙКИ
    local OFFSET = 1.8         -- расстояние сзади
    local SMOOTHNESS = 0.12    -- плавность движения
    local TRANSPARENCY = 0     -- прозрачность SurfaceGui

    -- ХРАНИЛИЩЕ ВИЗУАЛОВ
    local visuals = {}
    local renderConn

    -- === CHAMS ===
    local function CreateChams(part)
        for _, face in ipairs({"Front","Back","Left","Right","Top","Bottom"}) do
            local sg = Instance.new("SurfaceGui")
            sg.Name = "cham"
            sg.Face = Enum.NormalId[face]
            sg.AlwaysOnTop = true
            sg.LightInfluence = 0
            sg.ResetOnSpawn = false
            sg.Parent = part

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,0,1,0)
            frame.BackgroundColor3 = flags["color tracer"]
            frame.BackgroundTransparency = TRANSPARENCY
            frame.BorderSizePixel = 0
            frame.Parent = sg
        end
    end

    local function UpdateChamColor(color)
        for _, data in pairs(visuals) do
            for _, sg in ipairs(data.visual:GetChildren()) do
                if sg:IsA("SurfaceGui") then
                    sg.Frame.BackgroundColor3 = color
                end
            end
        end
    end

    local function UpdateChamTransparency(transparency)
        for _, data in pairs(visuals) do
            for _, sg in ipairs(data.visual:GetChildren()) do
                if sg:IsA("SurfaceGui") then
                    sg.Frame.BackgroundTransparency = transparency
                end
            end
        end
    end

    -- === VISUAL PART ===
    local function CreateVisualPart(original)
        local vp = Instance.new("Part")
        vp.Name = "VisualCham"
        vp.Size = original.Size
        vp.CFrame = original.CFrame
        vp.Anchored = true
        vp.CanCollide = false
        vp.Transparency = 1
        vp.CastShadow = false
        vp.Parent = workspace

        CreateChams(vp)
        return vp
    end

    -- === ENABLE / DISABLE ===
    local function DisableVisuals()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end

        for _, data in pairs(visuals) do
            if data.visual then
                data.visual:Destroy()
            end
        end
        table.clear(visuals)
    end

    local function EnableVisuals(character)
        local root = character:WaitForChild("HumanoidRootPart")

        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                local vPart = CreateVisualPart(part)
                visuals[part] = {
                    visual = vPart,
                    cf = part.CFrame
                }
            end
        end

        renderConn = RunService.RenderStepped:Connect(function()
            if not flags["tbox"] then return end
            if not character.Parent then return end

            local backOffset = -root.CFrame.LookVector * OFFSET

            for original, data in pairs(visuals) do
                if original.Parent then
                    local targetCF = original.CFrame + backOffset
                    data.cf = data.cf:Lerp(targetCF, SMOOTHNESS)
                    data.visual.CFrame = data.cf
                end
            end
        end)
    end

    -- === CHARACTER LOAD ===
    local function OnCharacter(char)
        DisableVisuals()
        if flags["tbox"] then
            task.wait(0.4)
            EnableVisuals(char)
        end
    end

    if LP.Character then
        OnCharacter(LP.Character)
    end

    LP.CharacterAdded:Connect(OnCharacter)

    -- === UI CALLBACK HOOKS ===
    -- Toggle
    local function OnToggleChanged(value)
        flags["tbox"] = value
        DisableVisuals()

        if value and LP.Character then
            EnableVisuals(LP.Character)
        end
    end

    -- Color picker
    local function OnColorChanged(value)
        flags["color tracer"] = value
        UpdateChamColor(value)
    end

    -- Transparency slider
    local function OnTransparencyChanged(value)
        flags["tracer transparency"] = value
        TRANSPARENCY = value
        UpdateChamTransparency(value)
    end

    -- Smoothness slider
    local function OnSmoothnessChanged(value)
        flags["tracer smoothness"] = value
        SMOOTHNESS = value
    end

    -- 🔗 ПРИВЯЗКА К ТВОЕМУ UI
    MiscSection:AddToggle('tbox', {
        Text = 'Visualize Server/Store',
        Default = false,
        Callback = OnToggleChanged
    })
    :AddColorPicker('color tracer', {
        Default = Color3.new(1, 1, 1),
        Title = 'Visualize Color',
        Callback = OnColorChanged
    })
    
    MiscSection:AddSlider('tracer transparency', {
        Text = 'Transparency',
        Min = 0,
        Max = 1,
        Default = 0,
        Rounding = 2,
        Callback = OnTransparencyChanged
    })
    
    MiscSection:AddSlider('tracer smoothness', {
        Text = 'Smoothness (Follow Speed)',
        Min = 0.01,
        Max = 0.06,
        Default = 0.04,
        Rounding = 2,
        Callback = OnSmoothnessChanged
    })
end

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('LunarCore')
SaveManager:SetFolder('LunarCore/ProjectDelta')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:Notify('LunarCore.xyz | Project Delta v1.1 Loaded!', 5)
Library:Notify(("Welcome thank you for using [LunarCore.xyz] - "..game.Players.LocalPlayer.Name.." 👋"), 6)
Library:Notify(("Status: 🟢 - Undetected (Safe to use)"), 6)

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

    Library:SetWatermark(('LunarCore.xyz |PD| v1.1 |A| Game id:7336302630 | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);
Library.KeybindFrame.Visible = true
