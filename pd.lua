-- LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'LunarCore.xyz | Project Delta | v1.0',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})


local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- =============================================
-- Sections
-- =============================================
local AimbotSection = Tabs.Combat:AddLeftGroupbox('Aimbot Settings')
local GunSection = Tabs.Combat:AddRightGroupbox('Gun Settings')
local VisualsSection = Tabs.Visuals:AddLeftGroupbox('Players ESP')
local ArmsSection = Tabs.Visuals:AddRightGroupbox('Arms & Viewmodel')
local FOVSection = Tabs.Visuals:AddRightGroupbox('Camera')
local WorldSection = Tabs.Visuals:AddRightGroupbox('World')
local MiscSection = Tabs.Misc:AddLeftGroupbox('Visual Character')
local MisSection = Tabs.Misc:AddRightGroupbox('Character')
local BotSection = Tabs.Misc:AddRightGroupbox('Bot')

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
    if character.Name and string.find(character.Name, "MotionClone_") then
        return true
    end
    
    if character:FindFirstChild("IsClone") then
        return true
    end
    
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
            -- Пропускаем клона
            if isMyClone(plr) then
                continue
            end
            
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
                        if tmp then 
                            loaded_ammo = tmp 
                        end
                    end
                end
            end
            
            if loaded_ammo and aimpart_index then
                if silent_aim.tracer and silent_aim.target_part then
                    local beam, p1, p2 = make_beam(
                        args[aimpart_index].Position, 
                        silent_aim.target_part.Position, 
                        silent_aim.tracer_color
                    )
                    
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
fov_circle.Color = silent_aim.fov_color
fov_circle.Transparency = 1
fov_circle.Radius = silent_aim.fov_size

local fov_circle_outline = Drawing.new("Circle")
fov_circle_outline.Visible = false
fov_circle_outline.Thickness = 3
fov_circle_outline.NumSides = 60
fov_circle_outline.Filled = false
fov_circle_outline.Color = silent_aim.fov_outline_color
fov_circle_outline.Transparency = 1
fov_circle_outline.Radius = silent_aim.fov_size

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
        fov_circle.Position = mouse_pos
        fov_circle.Radius = silent_aim.fov_size
        fov_circle.Color = silent_aim.fov_color
        fov_circle.Visible = true
        
        if silent_aim.fov_outline then
            fov_circle_outline.Position = mouse_pos
            fov_circle_outline.Radius = silent_aim.fov_size
            fov_circle_outline.Visible = true
        else
            fov_circle_outline.Visible = false
        end
    else
        fov_circle.Visible = false
        fov_circle_outline.Visible = false
    end
    
    if silent_aim.indicator and silent_aim.target_part then
        local text = silent_aim.target_part.Parent.Name
        if silent_aim.isvisible then 
            text = text .. " (visible)" 
        end
        if silent_aim.is_npc then 
            text = text .. " (ai)" 
        end
        
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
    Callback = function(Value)
        silent_aim.enabled = Value
    end
})

AimbotSection:AddToggle('UseFOV', {
    Text = 'Use FOV',
    Default = false,
    Callback = function(Value)
        silent_aim.use_fov = Value
    end
})

AimbotSection:AddToggle('ShowFOV', {
    Text = 'Show FOV Circle',
    Default = false,
    Callback = function(Value)
        silent_aim.fov_show = Value
    end
})

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
    end
})

AimbotSection:AddLabel('FOV Color'):AddColorPicker('FOVColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'FOV Color',
    Callback = function(Value)
        silent_aim.fov_color = Value
        fov_circle.Color = Value
    end
})

AimbotSection:AddToggle('FOVOutline', {
    Text = 'FOV Outline',
    Default = true,
    Callback = function(Value)
        silent_aim.fov_outline = Value
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
            if Gui.Enabled then 
                Gui.Enabled = false 
            end
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
        if Cheat.Toggles.testing then 
            testHealthPct = math.abs(math.sin(tick() * 1)) 
        end

        local lpChar = LocalPlayer.Character
        local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
        local rsPlayers = ReplicatedStorage:FindFirstChild("Players")

        for _, player in ipairs(PlayersService:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            -- Пропускаем клона в ESP
            if isMyClone(player) then
                continue
            end

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

-- ESP UI
VisualsSection:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.Enabled = Value
    end
})

VisualsSection:AddToggle('BoxESP', {
    Text = 'Box ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.Box = Value
    end
})

VisualsSection:AddToggle('NameESP', {
    Text = 'Name ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.Name = Value
    end
})

VisualsSection:AddToggle('DistanceESP', {
    Text = 'Distance ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.Distance = Value
    end
})

VisualsSection:AddToggle('HPText', {
    Text = 'HP Text',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.HPText = Value
    end
})

VisualsSection:AddToggle('HPBar', {
    Text = 'HP Bar',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.HPBar = Value
    end
})

VisualsSection:AddToggle('WeaponESP', {
    Text = 'Weapon ESP',
    Default = false,
    Callback = function(Value)
        Cheat.Toggles.WeaponName = Value
    end
})

VisualsSection:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Box Color',
    Callback = function(Value)
        Cheat.Colors.BoxMain = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.MainStroke then
                esp.MainStroke.Color = Value
            end
        end
    end
})

VisualsSection:AddLabel('Name Color'):AddColorPicker('NameColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Name Color',
    Callback = function(Value)
        Cheat.Colors.Name = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.NameLabel then
                esp.NameLabel.TextColor3 = Value
            end
        end
    end
})

VisualsSection:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Distance Color',
    Callback = function(Value)
        Cheat.Colors.Distance = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.DistanceLabel then
                esp.DistanceLabel.TextColor3 = Value
            end
        end
    end
})

VisualsSection:AddLabel('HP Text Color'):AddColorPicker('HPTextColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'HP Text Color',
    Callback = function(Value)
        Cheat.Colors.HealthText = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.HealthText then
                esp.HealthText.TextColor3 = Value
            end
        end
    end
})

VisualsSection:AddLabel('HP Bar Start'):AddColorPicker('HPBarStart', {
    Default = Color3.new(1, 1, 1),
    Title = 'HP Bar Start',
    Callback = function(Value)
        Cheat.Colors.HealthGradientStart = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then
                esp.UpdateGradient()
            end
        end
    end
})

VisualsSection:AddLabel('HP Bar Mid'):AddColorPicker('HPBarMid', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'HP Bar Mid',
    Callback = function(Value)
        Cheat.Colors.HealthGradientMid = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then
                esp.UpdateGradient()
            end
        end
    end
})

VisualsSection:AddLabel('HP Bar End'):AddColorPicker('HPBarEnd', {
    Default = Color3.fromRGB(255,255,255),
    Title = 'HP Bar End',
    Callback = function(Value)
        Cheat.Colors.HealthGradientEnd = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.UpdateGradient then
                esp.UpdateGradient()
            end
        end
    end
})

VisualsSection:AddLabel('Weapon Color'):AddColorPicker('WeaponColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Weapon Color',
    Callback = function(Value)
        Cheat.Colors.WeaponName = Value
        for _, esp in pairs(Cheat.Boxes) do
            if esp.ToolLabel then
                esp.ToolLabel.TextColor3 = Value
            end
        end
    end
})

-- =============================================
-- Arms Chams
-- =============================================
local arms_settings = {
    Gun = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.ForceField
    },
    Arms = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.ForceField
    }
}

local originals = {}

local function saveOriginal(part)
    if not originals[part] then
        originals[part] = {
            Material = part.Material,
            Color = part.Color
        }
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
        if gunModel then
            applyGunChams(gunModel)
        end
    end
    
    if arms_settings.Arms.Enabled then
        applyArmsChams(viewModel)
    end
end

ArmsSection:AddToggle('GunChams', {
    Text = 'Gun Chams',
    Default = false,
    Callback = function(Value)
        arms_settings.Gun.Enabled = Value
        updateChams()
    end
})

ArmsSection:AddLabel('Gun Color'):AddColorPicker('GunColor', {
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
})

ArmsSection:AddLabel('Arms Color'):AddColorPicker('ArmsColor', {
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
-- Viewmodel Offset
-- =============================================
local vm_settings = {
    Enabled = false,
    Offset = Vector3.new(0, 0, 0),
}

ArmsSection:AddToggle('VMEnabled', {
    Text = 'Enable Viewmodel Offset',
    Default = false,
    Callback = function(v)
        vm_settings.Enabled = v
    end
})

ArmsSection:AddSlider('VM_X', {
    Text = 'Offset X (Left/Right)',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Callback = function(v)
        vm_settings.Offset = Vector3.new(v, vm_settings.Offset.Y, vm_settings.Offset.Z)
        applyOffsetToCurrent()
    end
})

ArmsSection:AddSlider('VM_Y', {
    Text = 'Offset Y (Up/Down)',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Callback = function(v)
        vm_settings.Offset = Vector3.new(vm_settings.Offset.X, v, vm_settings.Offset.Z)
        applyOffsetToCurrent()
    end
})

ArmsSection:AddSlider('VM_Z', {
    Text = 'Offset Z (Forward/Back)',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 2,
    Callback = function(v)
        vm_settings.Offset = Vector3.new(vm_settings.Offset.X, vm_settings.Offset.Y, v)
        applyOffsetToCurrent()
    end
})

local function findViewModelParts(vm)
    if not vm then return end
    
    local parts = {}
    local hrp = vm:FindFirstChild("HumanoidRootPart")
    if not hrp then return parts end
    
    local motor6D = hrp:FindFirstChild("Motor6D")
    if motor6D then
        table.insert(parts, motor6D)
    end
    
    local itemRoot = hrp:FindFirstChild("ItemRoot")
    if itemRoot then
        table.insert(parts, itemRoot)
    end
    
    local leftArm = hrp:FindFirstChild("LeftUpperArm")
    if leftArm then
        table.insert(parts, leftArm)
    end
    
    local rightArm = hrp:FindFirstChild("RightUpperArm")
    if rightArm then
        table.insert(parts, rightArm)
    end
    
    return parts
end

local function applyOffsetToVM(vm)
    if not vm or not vm_settings.Enabled then return end
    
    local parts = findViewModelParts(vm)
    for _, part in ipairs(parts) do
        part.C0 = part.C0 + vm_settings.Offset
    end
end

local function applyOffsetToCurrent()
    for _, child in pairs(Camera:GetChildren()) do
        if child:IsA("Model") and child.Name == "ViewModel" then
            applyOffsetToVM(child)
        end
    end
end

Camera.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "ViewModel" then
        task.wait(0.05)
        applyOffsetToVM(child)
    end
end)

task.wait(0.5)
applyOffsetToCurrent()

-- =============================================
-- Gun Settings (Rapid Fire, No Recoil)
-- =============================================
local gun_settings = {
    RapidFire = {
        Enabled = false,
        MultiTap = 3,
        Delay = 3.5,
        FireRate = 0.001
    },
    NoRecoil = false,
    NoSpread = false
}

local gun_originals = {
    FireRates = {},
    FireModes = {},
    AccuracyDeviation = {}
}

GunSection:AddToggle('RapidFire', {
    Text = 'Rapid Fire',
    Default = false,
    Callback = function(v)
        gun_settings.RapidFire.Enabled = v
        updateRapidFire()
    end
})

GunSection:AddSlider('RapidFireMultiTap', {
    Text = 'Multi-Tap',
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = 'x',
    Callback = function(v)
        gun_settings.RapidFire.MultiTap = v
    end
})

GunSection:AddSlider('RapidFireDelay', {
    Text = 'Fire Delay (ms)',
    Default = 3.5,
    Min = 1,
    Max = 15,
    Rounding = 1,
    Suffix = 'ms',
    Callback = function(v)
        gun_settings.RapidFire.Delay = v
    end
})

GunSection:AddToggle('NoRecoil', {
    Text = 'No Recoil',
    Default = false,
    Callback = function(v)
        gun_settings.NoRecoil = v
        updateNoRecoil()
    end
})

GunSection:AddToggle('NoSpreadGun', {
    Text = 'No Spread',
    Default = false,
    Callback = function(v)
        gun_settings.NoSpread = v
    end
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
                if gun_originals.FireRates[gun] then
                    sett.FireRate = gun_originals.FireRates[gun]
                end
                if gun_originals.FireModes[gun] then
                    sett.FireModes = gun_originals.FireModes[gun]
                else
                    sett.FireModes = {"Semi", "Auto", "Burst"}
                end
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
                    if gun_settings.NoRecoil then
                        return
                    end
                    return shove(...)
                end
            end
            
            if type(rawget(gc, "create")) == "function" and getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" then
                local old_create = gc.create
                gc.create = function(...)
                    local returns = old_create(...)
                    local shove = returns.shove
                    returns.shove = function(...)
                        if gun_settings.NoRecoil then
                            return
                        end
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
        if attribute == "AccuracyDeviation" then
            return 0
        end
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
            for _, gun in ipairs(inv:GetChildren()) do
                saveOriginalGunSettings(gun)
            end
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
-- World Settings
-- =============================================
local world_settings = {
    Time = {
        Enabled = false,
        Value = 14
    },
    Ambient = {
        Enabled = false,
        Color = Color3.fromRGB(90, 90, 90)
    },
    NoFog = false,
    NoGrass = false,
    NoShadows = false,
    NoLeaves = false,
}

WorldSection:AddToggle('TimeChanger', {
    Text = 'Enable Time Changer',
    Default = false,
    Callback = function(v)
        world_settings.Time.Enabled = v
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
    end
})

WorldSection:AddToggle('AmbientEnable', {
    Text = 'Enable Ambient',
    Default = false,
    Callback = function(v)
        world_settings.Ambient.Enabled = v
    end
})

WorldSection:AddLabel('Ambient Color'):AddColorPicker('AmbientColor', {
    Default = Color3.fromRGB(90, 90, 90),
    Title = 'Ambient Color',
    Callback = function(v)
        world_settings.Ambient.Color = v
    end
})

WorldSection:AddToggle('NoFog', {
    Text = 'No Fog',
    Default = false,
    Callback = function(v)
        world_settings.NoFog = v
    end
})

WorldSection:AddToggle('NoGrass', {
    Text = 'No Grass',
    Default = false,
    Callback = function(v)
        world_settings.NoGrass = v
        pcall(function()
            sethiddenproperty(Terrain, "Decoration", not v)
        end)
    end
})

WorldSection:AddToggle('NoShadows', {
    Text = 'No Shadows',
    Default = false,
    Callback = function(v)
        world_settings.NoShadows = v
    end
})

WorldSection:AddToggle('NoLeaves', {
    Text = 'No Leaves',
    Default = false,
    Callback = function(v)
        world_settings.NoLeaves = v
    end
})

local Terrain = Workspace:FindFirstChild("Terrain")

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

RunService.Heartbeat:Connect(function()
    if world_settings.Time.Enabled then
        Lighting.ClockTime = world_settings.Time.Value
    end
    
    if world_settings.Ambient.Enabled then
        Lighting.Ambient = world_settings.Ambient.Color
    end
    
    Lighting.GlobalShadows = not world_settings.NoShadows
    
    if world_settings.NoFog then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100000
    end
end)

task.spawn(function()
    while task.wait(5) do
        if world_settings.NoLeaves then
            setFoliageTransparency(true)
        end
    end
end)

-- =============================================
-- Tracer Line
-- =============================================
local tracer_settings = {
    Line = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2.5,
        Transparency = 0.9
    },
    Beam = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255)
    }
}

local TracerLine = Drawing.new("Line")
TracerLine.Thickness = tracer_settings.Line.Thickness
TracerLine.Color = tracer_settings.Line.Color
TracerLine.Transparency = tracer_settings.Line.Transparency
TracerLine.Visible = false

local function get_closest_target_tracer()
    local closest = nil
    local closestDist = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    
    for _, plr in ipairs(PlayersService:GetPlayers()) do
        if plr ~= LocalPlayer then
            if isMyClone(plr) then continue end
            
            local char = plr.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y - guiInset.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

local function make_beam_tracer(Origin, Position, Color)
    local part1 = Instance.new("Part", Workspace)
    local part2 = Instance.new("Part", Workspace)
    
    part1.Position = Origin
    part2.Position = Position
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
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color),
        ColorSequenceKeypoint.new(1, Color)
    }
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Texture = "http://www.roblox.com/asset/?id=446111271"
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.07
    Beam.Width1 = 0.07
    
    return Beam, part1, part2
end

AimbotSection:AddToggle('TracerLine', {
    Text = 'Tracer Line ',
    Default = false,
    Callback = function(v)
        tracer_settings.Line.Enabled = v
    end
})

AimbotSection:AddLabel('Line Color'):AddColorPicker('TracerLineColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Line Color',
    Callback = function(v)
        tracer_settings.Line.Color = v
        TracerLine.Color = v
    end
})

AimbotSection:AddSlider('TracerThickness', {
    Text = 'Line Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        tracer_settings.Line.Thickness = v
        TracerLine.Thickness = v
    end
})

AimbotSection:AddToggle('BulletTracer', {
    Text = 'Bullet Tracer',
    Default = false,
    Callback = function(v)
        tracer_settings.Beam.Enabled = v
    end
})

AimbotSection:AddLabel('Bullet Color'):AddColorPicker('BulletTracerColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Bullet Color',
    Callback = function(v)
        tracer_settings.Beam.Color = v
    end
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

MiscSection:AddToggle('ThirdPerson', {
    Text = 'Third Person',
    Default = false,
    Callback = function(v)
        thirdperson_settings.Enabled = v
        applyThirdPerson()
    end
})

MiscSection:AddLabel('Keybind'):AddKeyPicker('ThirdPersonKeybind', {
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

MiscSection:AddSlider('ThirdPersonDistance', {
    Text = 'Camera Distance',
    Default = 6,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(thirdperson_settings.Offset.X, thirdperson_settings.Offset.Y, v)
        if thirdperson_settings.Enabled then
            applyThirdPerson()
        end
    end
})

MiscSection:AddSlider('ThirdPersonHeight', {
    Text = 'Camera Height',
    Default = 2,
    Min = -5,
    Max = 10,
    Rounding = 1,
    Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(thirdperson_settings.Offset.X, v, thirdperson_settings.Offset.Z)
        if thirdperson_settings.Enabled then
            applyThirdPerson()
        end
    end
})

MiscSection:AddSlider('ThirdPersonSide', {
    Text = 'Camera Side Offset',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Suffix = 'studs',
    Callback = function(v)
        thirdperson_settings.Offset = Vector3.new(v, thirdperson_settings.Offset.Y, thirdperson_settings.Offset.Z)
        if thirdperson_settings.Enabled then
            applyThirdPerson()
        end
    end
})

local mt3 = getrawmetatable(game)
local old_newindex = mt3.__newindex
setreadonly(mt3, false)

mt3.__newindex = newcclosure(function(self, key, value)
    if thirdperson_settings.Enabled and self:IsA("Humanoid") and key == "CameraOffset" then
        if value ~= thirdperson_settings.Offset then
            return
        end
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
    if thirdperson_settings.Enabled then
        applyThirdPerson()
    end
end)

task.wait(1)
if thirdperson_settings.Enabled then
    applyThirdPerson()
end

-- Player Chams с плавным отставанием (с UI управлением)
-- Вставьте этот код в ваш основной скрипт

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Настройки
local chams_settings = {
    Enabled = false,
    Color = Color3.fromRGB(85, 170, 255),  -- Синий цвет
    Transparency = 0.5,
    Material = "ForceField",
    MaxOffset = 4,        -- Максимальное отставание (в студиях)
    MinOffset = 0.5,      -- Минимальное отставание
    FollowSpeed = 0.08,   -- Скорость следования (чем меньше, тем плавнее)
    Smoothness = 0.15     -- Плавность движения
}

-- Хранилище чамсов
local playerChams = {}
local targetPosition = nil
local currentPosition = nil
local lastPlayerPos = nil
local lastVelocity = nil

-- Функция создания чамсов на часть тела
local function addChamsToPart(part)
    if not part or part:FindFirstChild("ChamEffect") then return end
    
    -- Создаем копию части для чамса
    local chamPart = Instance.new("Part")
    chamPart.Size = part.Size
    chamPart.CFrame = part.CFrame
    chamPart.Anchored = true
    chamPart.CanCollide = false
    chamPart.Massless = true
    chamPart.Color = chams_settings.Color
    chamPart.Material = Enum.Material[chams_settings.Material]
    chamPart.Transparency = chams_settings.Transparency
    chamPart.Parent = workspace
    chamPart.Name = "ChamEffect"
    
    -- Добавляем текстуру
    local texture = Instance.new("Texture")
    texture.Texture = "rbxassetid://446111271"
    texture.Face = Enum.NormalId.Front
    texture.StudsPerTileU = 2
    texture.StudsPerTileV = 2
    texture.Color3 = chams_settings.Color
    texture.Transparency = chams_settings.Transparency
    texture.Parent = chamPart
    
    return chamPart
end

-- Функция создания всех чамсов персонажа
local function createAllChams(character)
    if not character then return end
    
    -- Очищаем старые чамсы
    for _, cham in pairs(playerChams) do
        if cham and cham.Parent then
            cham:Destroy()
        end
    end
    playerChams = {}
    
    -- Создаем чамсы для каждой части тела
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local cham = addChamsToPart(part)
            if cham then
                playerChams[part] = cham
            end
        end
    end
end

-- Функция удаления всех чамсов
local function removeAllChams()
    for _, cham in pairs(playerChams) do
        if cham and cham.Parent then
            cham:Destroy()
        end
    end
    playerChams = {}
    targetPosition = nil
    currentPosition = nil
    lastPlayerPos = nil
    lastVelocity = nil
end

-- Функция расчета отставания (чем быстрее движение, тем дальше отстают)
local function calculateOffset(velocity)
    local speed = velocity.Magnitude
    -- Нормализуем скорость от 0 до 1 (макс скорость 50 студий/сек)
    local speedNormalized = math.min(speed / 50, 1)
    -- Отставание увеличивается с увеличением скорости
    local offset = chams_settings.MinOffset + (chams_settings.MaxOffset - chams_settings.MinOffset) * speedNormalized
    return offset
end

-- Функция плавного обновления позиции чамсов
local function updateChamsPosition()
    if not chams_settings.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Получаем текущую позицию и скорость игрока
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local playerPos = rootPart.Position
    local velocity = rootPart.Velocity
    local speed = velocity.Magnitude
    
    -- Сохраняем скорость для плавности
    if not lastVelocity then
        lastVelocity = velocity
    else
        lastVelocity = lastVelocity:Lerp(velocity, 0.3)
    end
    
    -- Расчет отставания
    local offset = calculateOffset(lastVelocity)
    local isMoving = speed > 3  -- скорость больше 3 студий/сек считается движением
    
    if isMoving and offset > 0.1 then
        -- Получаем направление движения
        local direction = lastVelocity.Unit
        if direction.Magnitude > 0 then
            -- Целевая позиция с отставанием в направлении движения
            targetPosition = playerPos - direction * offset
        else
            targetPosition = playerPos
        end
    else
        -- Если стоим, чамсы плавно подтягиваются к игроку
        targetPosition = playerPos
    end
    
    -- Плавное движение к целевой позиции
    if currentPosition then
        currentPosition = currentPosition:Lerp(targetPosition, chams_settings.Smoothness)
    else
        currentPosition = targetPosition
    end
    
    -- Запоминаем позицию для следующего кадра
    lastPlayerPos = playerPos
    
    -- Применяем позицию ко всем чамсам с плавностью
    for originalPart, chamPart in pairs(playerChams) do
        if originalPart and originalPart.Parent and chamPart and chamPart.Parent then
            -- Сохраняем относительное положение к корню
            local offsetPos = originalPart.Position - rootPart.Position
            local targetPartPos = currentPosition + offsetPos
            
            -- Плавное движение каждой части
            local currentPartPos = chamPart.Position
            local newPos = currentPartPos:Lerp(targetPartPos, 0.2)
            chamPart.CFrame = CFrame.new(newPos)
        end
    end
end

-- Обновление цвета и прозрачности чамсов
local function updateChamsAppearance()
    for originalPart, chamPart in pairs(playerChams) do
        if chamPart and chamPart.Parent then
            chamPart.Color = chams_settings.Color
            chamPart.Transparency = chams_settings.Transparency
            chamPart.Material = Enum.Material[chams_settings.Material]
            
            local texture = chamPart:FindFirstChildOfClass("Texture")
            if texture then
                texture.Color3 = chams_settings.Color
                texture.Transparency = chams_settings.Transparency
            end
        end
    end
end

-- Функция включения/выключения
local function setEnabled(state)
    chams_settings.Enabled = state
    if state then
        if LocalPlayer.Character then
            createAllChams(LocalPlayer.Character)
            targetPosition = nil
            currentPosition = nil
            lastPlayerPos = nil
            lastVelocity = nil
        end
    else
        removeAllChams()
    end
end

-- Создаем чамсы при появлении персонажа
local function onCharacterAdded(character)
    character:WaitForChild("Humanoid")
    task.wait(0.5)
    if chams_settings.Enabled then
        createAllChams(character)
        -- Сбрасываем позиции
        targetPosition = nil
        currentPosition = nil
        lastPlayerPos = nil
        lastVelocity = nil
    end
end

-- Основной цикл обновления позиции (RenderStepped для максимальной плавности)
RunService.RenderStepped:Connect(function()
    if chams_settings.Enabled and LocalPlayer.Character then
        updateChamsPosition()
    end
end)

-- Следим за появлением персонажа
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Очистка при выгрузке
LocalPlayer.CharacterRemoving:Connect(function()
    if chams_settings.Enabled then
        removeAllChams()
    end
end)

-- =============================================
-- ДОБАВЛЯЕМ UI ЭЛЕМЕНТЫ (если у вас есть интерфейс)
-- =============================================

-- Если у вас есть секция MiscSection, добавьте туда:
MiscSection:AddToggle('TrailChams', {
    Text = 'Trail Chams',
    Default = false,
    Callback = function(v)
        setEnabled(v)
    end
})

MiscSection:AddLabel('Chams Color'):AddColorPicker('TrailChamsColor', {
    Default = Color3.fromRGB(85, 170, 255),
    Title = 'Chams Color',
    Callback = function(v)
        chams_settings.Color = v
        if chams_settings.Enabled then
            updateChamsAppearance()
        end
    end
})

MiscSection:AddSlider('TrailChamsDistance', {
    Text = 'Max Distance',
    Default = 4,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Suffix = 'studs',
    Callback = function(v)
        chams_settings.MaxOffset = v
    end
})

MiscSection:AddSlider('TrailChamsMinDistance', {
    Text = 'Min Distance',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Suffix = 'studs',
    Callback = function(v)
        chams_settings.MinOffset = v
    end
})

MiscSection:AddSlider('TrailChamsTransparency', {
    Text = 'Chams Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        chams_settings.Transparency = v
        if chams_settings.Enabled then
            updateChamsAppearance()
        end
    end
})

MiscSection:AddDropdown('TrailChamsMaterial', {
    Text = 'Chams Material',
    Values = {'Neon', 'ForceField', 'SmoothPlastic', 'Glass', 'Ice'},
    Default = 2,  -- ForceField
    Callback = function(v)
        chams_settings.Material = v
        if chams_settings.Enabled then
            updateChamsAppearance()
        end
    end
})


-- =============================================
-- Player Chams (подсветка игрока)
-- =============================================
local chams_settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 100, 150),
    Transparency = 0.5,
    Material = "ForceField"
}

local function applyChams(character)
    if not character then return end
    
    local parts = character:GetDescendants()
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if not part:GetAttribute("OriginalColor") then
                part:SetAttribute("OriginalColor", part.Color)
                part:SetAttribute("OriginalMaterial", part.Material)
                part:SetAttribute("OriginalTransparency", part.Transparency)
            end
            
            part.Color = chams_settings.Color
            part.Material = Enum.Material[chams_settings.Material]
            part.Transparency = chams_settings.Transparency
            
            if part.Name == "Head" then
                local face = part:FindFirstChild("face")
                if face then face:Destroy() end
            end
        end
    end
end

local function restoreChams(character)
    if not character then return end
    
    local parts = character:GetDescendants()
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local originalColor = part:GetAttribute("OriginalColor")
            local originalMaterial = part:GetAttribute("OriginalMaterial")
            local originalTransparency = part:GetAttribute("OriginalTransparency")
            
            if originalColor then
                part.Color = originalColor
            end
            if originalMaterial then
                part.Material = originalMaterial
            end
            if originalTransparency then
                part.Transparency = originalTransparency
            end
        end
    end
end

local function updatePlayerChams()
    local character = LocalPlayer.Character
    if not character then return end
    
    if chams_settings.Enabled then
        applyChams(character)
    else
        restoreChams(character)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    task.wait(0.5)
    updatePlayerChams()
end)

MiscSection:AddToggle('PlayerChams', {
    Text = 'Player Chams',
    Default = false,
    Callback = function(v)
        chams_settings.Enabled = v
        updatePlayerChams()
    end
})

MiscSection:AddLabel('Chams Color'):AddColorPicker('PlayerChamsColor', {
    Default = Color3.fromRGB(255, 100, 150),
    Title = 'Chams Color',
    Callback = function(v)
        chams_settings.Color = v
        if chams_settings.Enabled then
            updatePlayerChams()
        end
    end
})

MiscSection:AddSlider('PlayerChamsTransparency', {
    Text = 'Chams Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        chams_settings.Transparency = v
        if chams_settings.Enabled then
            updatePlayerChams()
        end
    end
})



task.wait(1)
updatePlayerChams()

-- =============================================
-- Speed Hack
-- =============================================
local speed_settings = {
    Enabled = false,
    Speed = 23
}

local function disableAntiCheat()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local connections = {
        {humanoid:GetPropertyChangedSignal("WalkSpeed"), "CharacterController"},
        {humanoid:GetPropertyChangedSignal("JumpHeight"), "CharacterController"},
        {humanoid:GetPropertyChangedSignal("HipHeight"), "CharacterController"},
        {Workspace:GetPropertyChangedSignal("Gravity"), "CharacterController"},
        {humanoid.StateChanged, "CharacterController"},
        {humanoid.ChildAdded, "CharacterController"},
        {humanoid.ChildRemoved, "CharacterController"}
    }
    for _, connData in ipairs(connections) do
        local signal = connData[1]
        local sourceName = connData[2]       
        for _, connection in ipairs(getconnections(signal)) do
            if connection and connection.Function then
                local success, info = pcall(function()
                    return debug.getinfo(connection.Function)
                end)
                
                if success and info and info.source then
                    if string.find(info.source, sourceName) then
                        pcall(function()
                            connection:Disable()
                        end)
                    end
                end
            end
        end
    end
end

local function applySpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if speed_settings.Enabled then
        pcall(disableAntiCheat)
        humanoid.WalkSpeed = speed_settings.Speed
    else
        humanoid.WalkSpeed = 16
    end
end

MisSection:AddToggle('SpeedHack', {
    Text = 'Speed Hack',
    Default = false,
    Callback = function(v)
        speed_settings.Enabled = v
    end
})

MisSection:AddSlider('SpeedValue', {
    Text = 'Speed',
    Default = 23,
    Min = 16,
    Max = 30,
    Rounding = 1,
    Suffix = 'sps',
    Callback = function(v)
        speed_settings.Speed = v
    end
})

RunService.Heartbeat:Connect(applySpeed)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)
task.wait(1)
applySpeed()

-- =============================================
-- FOV Changer
-- =============================================
local fov_settings = {
    Enabled = false,
    Value = 90
}

local defaultFOV = Camera.FieldOfView

local function setFOV(value)
    if fov_settings.Enabled then
        Camera.FieldOfView = value
    end
end

FOVSection:AddToggle('FOVEnabled', {
    Text = 'FOV Changer',
    Default = false,
    Callback = function(Value)
        fov_settings.Enabled = Value
        if fov_settings.Enabled then
            setFOV(fov_settings.Value)
        else
            Camera.FieldOfView = defaultFOV
        end
    end
})

FOVSection:AddSlider('FOVRadius', {
    Text = 'FOV Radius',
    Default = 90,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Suffix = 'deg',
    Callback = function(Value)
        fov_settings.Value = Value
        if fov_settings.Enabled then
            setFOV(fov_settings.Value)
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(1)
    if fov_settings.Enabled then
        Camera.FieldOfView = fov_settings.Value
    end
end)

RunService.RenderStepped:Connect(function()
    if fov_settings.Enabled and Camera.FieldOfView ~= fov_settings.Value then
        Camera.FieldOfView = fov_settings.Value
    end
end)

-- =============================================
-- Inventory Checker
-- =============================================
local inv_settings = {
    Enabled = false,
    Position = Vector2.new(200, 200),
    Delay = 0.25
}

local inv_objects = {}
local inventoryItems = {}

local function newDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    table.insert(inv_objects, obj)
    return obj
end

local function removeAllDrawings()
    for i, obj in ipairs(inv_objects) do
        pcall(function() obj:Remove() end)
        inv_objects[i] = nil
    end
    inventoryItems = {}
end

local function addInventoryText(text, size)
    local textObj = newDrawing("Text", {
        Text = text,
        Size = size,
        Font = Drawing.Fonts.Monospace,
        Outline = true,
        Center = false,
        Position = inv_settings.Position + Vector2.new(0, (size + 1) * #inventoryItems),
        Transparency = 1,
        Visible = true,
        Color = Color3.new(1, 1, 1),
        ZIndex = 1,
    })
    table.insert(inventoryItems, textObj)
end

local function clearInventory()
    for i, obj in ipairs(inventoryItems) do
        pcall(function() obj:Remove() end)
        inventoryItems[i] = nil
    end
    inventoryItems = {}
end

local function updateInventory(playerName)
    clearInventory()
    
    local rplayers = ReplicatedStorage.Players
    local targetPlayer
    
    for _, rplayer in ipairs(rplayers:GetChildren()) do
        if rplayer.Name == playerName then
            targetPlayer = rplayer
            break
        end
    end
    
    if not targetPlayer then 
        return 
    end
    
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

local InvSection = Tabs.Visuals:AddLeftGroupbox('Inventory Checker')

InvSection:AddToggle('InventoryChecker', {
    Text = 'Inventory Checker',
    Default = false,
    Callback = function(Value)
        inv_settings.Enabled = Value
        if not Value then
            clearInventory()
            for _, obj in ipairs(inv_objects) do
                obj.Visible = false
            end
        end
    end
})

InvSection:AddSlider('InvPositionX', {
    Text = 'Position X',
    Default = 200,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Suffix = 'px',
    Callback = function(Value)
        inv_settings.Position = Vector2.new(Value, inv_settings.Position.Y)
    end
})

InvSection:AddSlider('InvPositionY', {
    Text = 'Position Y',
    Default = 200,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Suffix = 'px',
    Callback = function(Value)
        inv_settings.Position = Vector2.new(inv_settings.Position.X, Value)
    end
})

InvSection:AddSlider('InvUpdateDelay', {
    Text = 'Update Delay',
    Default = 0.25,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Suffix = 's',
    Callback = function(Value)
        inv_settings.Delay = Value
    end
})

RunService.RenderStepped:Connect(function()
    for i, obj in ipairs(inventoryItems) do
        obj.Position = inv_settings.Position + Vector2.new(0, (14 + 1) * (i-1))
    end
    
    if not inv_settings.Enabled then
        for _, obj in ipairs(inv_objects) do
            obj.Visible = false
        end
        return
    else
        for _, obj in ipairs(inv_objects) do
            obj.Visible = true
        end
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

-- =============================================
-- Visibility Checker
-- =============================================
local vis_settings = {
    Enabled = false,
    TextSize = 20,
    YOffset = 50
}

local visibilityText = Drawing.new("Text")
visibilityText.Visible = false
visibilityText.Center = true
visibilityText.Size = vis_settings.TextSize
visibilityText.Outline = true
visibilityText.Font = Drawing.Fonts.Monospace
visibilityText.Color = Color3.new(1, 1, 1)

local function isVisible(targetPart)
    if not targetPart then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        Workspace:FindFirstChild("NoCollision"),
        Camera,
        LocalPlayer.Character
    }
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = Workspace:Raycast(origin, direction, params)
    
    if not result then
        return true
    end
    
    if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    
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
        if not Value then
            visibilityText.Visible = false
        end
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
        local visible = isVisible(targetPart)
        
        if visible then
            visibilityText.Text = "VISIBLE"
            visibilityText.Color = Color3.fromRGB(0, 255, 0)
        else
            visibilityText.Text = "NOT VISIBLE (BEHIND WALL)"
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
local tracer_fov_settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 2,
    Transparency = 0.8
}

local TracerLineFOV = Drawing.new("Line")
TracerLineFOV.Thickness = tracer_fov_settings.Thickness
TracerLineFOV.Color = tracer_fov_settings.Color
TracerLineFOV.Transparency = tracer_fov_settings.Transparency
TracerLineFOV.Visible = false

AimbotSection:AddLabel('Tracer Color'):AddColorPicker('TracerFOVColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Tracer Color',
    Callback = function(v)
        tracer_fov_settings.Color = v
        TracerLineFOV.Color = v
    end
})

AimbotSection:AddSlider('TracerFOVThickness', {
    Text = 'Tracer Thickness',
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        tracer_fov_settings.Thickness = v
        TracerLineFOV.Thickness = v
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

    local visible = isVisible(targetPart)
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
local resolver_settings = {
    Enabled = false,
    Velocity = 2500,
    Delay = 0.05,
    Offset = 20,
    Resolving = false
}

local function performAnchoredResolve()
    if resolver_settings.Resolving then return end
    resolver_settings.Resolving = true

    local char = LocalPlayer.Character
    if not char then
        resolver_settings.Resolving = false
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        resolver_settings.Resolving = false
        return
    end

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
        if state then
            performAnchoredResolve()
        end
    end
})

local anchoredKeybindPressed = false
MisSection:AddLabel('Keybind'):AddKeyPicker('AnchoredResolveKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Anchored Resolve Keybind',
    NoUI = false,
    Callback = function(state)
        resolver_settings.Enabled = state
        AnchoredResolveToggle:SetValue(state)
        if state then
            performAnchoredResolve()
        end
    end
})

-- =============================================
-- Fly Hack
-- =============================================
local fly_settings = {
    Enabled = false,
    Speed = 10,
    YSpeed = 10
}

local FlyToggle

FlyToggle = MisSection:AddToggle('Fly', {
    Text = 'Fly',
    Default = false,
    Callback = function(value)
        fly_settings.Enabled = value
    end
})

local flyKeybindPressed = false
MisSection:AddLabel('Keybind'):AddKeyPicker('FlyKeybind', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly Keybind',
    NoUI = false,
    Callback = function(state)
        fly_settings.Enabled = state
        FlyToggle:SetValue(state)
    end
})

MisSection:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 10,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Suffix = 'studs/s',
    Callback = function(value)
        fly_settings.Speed = value
    end
})

MisSection:AddSlider('FlyYSpeed', {
    Text = 'Y Fly Speed',
    Default = 10,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Suffix = 'studs/s',
    Callback = function(value)
        fly_settings.YSpeed = value
    end
})

RunService.Heartbeat:Connect(function(delta)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if fly_settings.Enabled and hrp then
        local camLook = Camera.CFrame.LookVector
        camLook = Vector3.new(camLook.X, 0, camLook.Z)
        
        local horDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            horDir = horDir + camLook
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            horDir = horDir - camLook
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            horDir = horDir + Vector3.new(-camLook.Z, 0, camLook.X)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            horDir = horDir + Vector3.new(camLook.Z, 0, -camLook.X)
        end
        
        local vertDir = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertDir = vertDir + 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertDir = vertDir - 1
        end
        
        if horDir ~= Vector3.zero then
            hrp.CFrame = hrp.CFrame + horDir.Unit * delta * fly_settings.Speed
        end
        if vertDir ~= 0 then
            hrp.CFrame = hrp.CFrame + Vector3.yAxis * vertDir * delta * fly_settings.YSpeed
        end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- Добавьте это в ваш существующий скрипт

local teleport_settings = {
    SelectedObject = "None"
}

-- Функция телепортации объекта к игроку
local function teleportToMe(objectName)
    if objectName == "None" then
        return false
    end
    
    local target = workspace:FindFirstChild(objectName)
    if not target then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then
        return false
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    
    local playerPos = rootPart.Position
    local targetPos = playerPos + Vector3.new(0, 2, 0)
    
    -- Телепортируем объект
    if target:IsA("BasePart") then
        target.CFrame = CFrame.new(targetPos)
    elseif target:IsA("Model") then
        local primaryPart = target.PrimaryPart
        if primaryPart then
            target:SetPrimaryPartCFrame(CFrame.new(targetPos))
        else
            local hrp = target:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(targetPos)
            end
        end
    end
    
    -- Визуальный эффект
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(3, 3, 3)
    effect.Position = targetPos
    effect.Anchored = true
    effect.CanCollide = false
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 100, 0)
    effect.Transparency = 0.3
    effect.Parent = workspace
    
    task.delay(0.5, function()
        effect:Destroy()
    end)
    return true
end

-- Дропдаун для выбора объекта
BotSection:AddDropdown('TeleportObject', {
    Text = 'Select Object to Teleport',
    Values = {"None", "Blaze", "Mihkel", "Designer", "Tarmo", "VaultManager"},
    Default = "None",
    Callback = function(v)
        teleport_settings.SelectedObject = v

    end
})

-- Кнопка для телепортации
BotSection:AddButton({
    Text = 'Teleport Bot',
    Func = function()
        if teleport_settings.SelectedObject and teleport_settings.SelectedObject ~= "None" then
            teleportToMe(teleport_settings.SelectedObject)
        else         
        end
    end,
    DoubleClick = false,
    Tooltip = ''
})






-- =============================================
-- UI Settings
-- =============================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('LunarCore')
SaveManager:SetFolder('LunarCore/ProjectDelta')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

Library:Notify('LunarCore.xyz | Project Delta v1.0 Loaded!', 5)
Library:SetWatermarkVisibility(true)
Library:SetWatermark('LunarCore.xyz | Project Delta | v1.0')
Library.KeybindFrame.Visible = true
