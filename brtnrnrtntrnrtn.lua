-- U CAN USE TS IN UR ROBLOX GAME --

local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeviceHB21/mylib/refs/heads/main/source.lua"))()

local Notification = NeverLose:CreateNotification();
local Logging = NeverLose:CreateLogger();
local window = NeverLose:CreateWindow({
	Logo = "asssetid/115922855794150",
	Name = "LunarCore",
	Content = "AR2 | v2.3",
	Size = NeverLose.Scales.Default,
	ConfigFolder = "LunarCoreConfigs",
	Enable3DRenderer = false,
	Keybind = "End"
});

local Watermark = window:Watermark();
Watermark:SetRender(true);

local ping = Watermark:AddBlock("chart-four-vertical-bars" , "0MS");
local UITogg = Watermark:AddBlock("cube-vertexes" , "LunarCore");

UITogg:Input(function()
	window:ToggleInterface();
end);

task.spawn(function()
	while true do 
		task.wait(1)
		ping:SetText(tostring(math.random(30,90))..'MS')
	end
end)

local Rage = window:AddTab({
	Icon = 'crosshairs',
	Name = "Rage",
})

local Legit = window:AddTab({
	Icon = 'mouse-scrollwheel',
	Name = "Legit",
})

local Esp = window:AddTab({
	Icon = 'eye',
	Name = "Esp",
})

local World = window:AddTab({
	Icon = 'world',
	Name = "World",
})

local Misc = window:AddTab({
	Icon = 'cog',
	Name = "Misc"
})

local SilentAimSection = Rage:AddSection({
	Name = "SILENT AIM"
})

local FOVSection = Rage:AddSection({
	Name = "FOV",
	Position = 'right'
})

local SnapLineSection = Rage:AddSection({
	Name = "SNAP LINE",
	Position = 'right'
})

local GunModsSection = Rage:AddSection({
	Name = "GUN MODS",
	Position = 'left'
})

local AimbotSection = Legit:AddSection({
	Name = "AIM BOT"
})

local LegitFOVSection = Legit:AddSection({
	Name = "FOV",
	Position = 'right'
})

local LegitSnapLineSection = Legit:AddSection({
	Name = "SNAP LINE",
	Position = 'right'
})

local PlayerESPSection = Esp:AddSection({
	Name = "ESP PLAYER"
})

local PlayerChamsSection = Esp:AddSection({
	Name = "CHAMS",
	Position = 'left'
})

local CorpseESPSection = Esp:AddSection({
	Name = "CORPSE ESP",
	Position = 'right'
})

local VehicleESPSection = Esp:AddSection({
	Name = "VEHICLE ESP",
	Position = 'right'
})

local ZombieESPSection = Esp:AddSection({
	Name = "ZOMBIE ESP",
	Position = 'right'
})

local LightingSection = World:AddSection({
	Name = "LIGHTING"
})

local BulletTracerSection = World:AddSection({
	Name = "BULLET TRACER",
	Position = 'right'
})

local LocalPlayerSection = World:AddSection({
	Name = "LOCAL PLAYER",
	Position = 'right'
})

local CrosshairSection = World:AddSection({
	Name = "CUSTOM CROSSHAIR",
	Position = 'right'
})

local MovementSection = Misc:AddSection({
	Name = "MOVEMENT"
})

local AntiAimSection = Misc:AddSection({
	Name = "ANTI AIM",
	Position = 'left'
})

local ZombieSection = Misc:AddSection({
	Name = "ZOMBIE",
	Position = 'left'
})

local Settings = {
    AimbotEnabled = false,
    AimbotHoldKey = Enum.UserInputType.MouseButton2,
    AimbotSmoothing = 0.5,
    AimbotTargetType = "Closest To Mouse",
    AimbotTargetHitbox = "Head",
    AimbotDistanceCheck = false,
    AimbotMaxDistance = 1500,
    SilentEnabled = false,
    SilentHitChance = 100,
    SilentMaxDistance = 2000,
    SilentTargetType = "Closest To Mouse",
    SilentTargetHitbox = "Head",   
    NoRecoilEnabled = false,
    RecoilScale = 0.1,  
    SnapLine = false,
    SnapLineColor = Color3.fromRGB(255,255,255),
    SnapLineThickness = 2,
    SnapLineOutline = false,
    SnapLineOutlineTransparency = 0.9,
    FOVEnabled = false,
    FOVColor = Color3.fromRGB(0,255,0),
    FOVRadius = 150,
    FOVThickness = 2,
    FOVFill = false,
    FOVDynamic = false,
    FOVOutline = false
}

local movementFlags = {
    walkingSpeed = 16,
    runningSpeed = 20,
    walkEnabled = false,
    runEnabled = false,
    isRunning = false,
    noSprintPenalty = false,
    antiDebuffEnabled = false,
    noRagdollEnabled = false,
    infJumpEnabled = false,
    infJumpPower = 50,
    noFallEnabled = false,
    noFallSpeed = 0,
    doubleJumpEnabled = false
}

local antiAimFlags = {enabled = false, spinSpeed = 5, permaSpin = false}

local espFlags = {}
local espSettings = {
    maxHPVisibility = 100,
    boxType = "Boxes", 
    metric = "Meters",
    useDisplayName = true
}

local zombieCircleEnabled = false
local zombieCircleDistance = 10
local zombieCircleSpeed = 5
local isFreezeEnabled = false

local world_utilities = {
	BulletTracer = false,
	BulletTracerColor = Color3.fromRGB(255, 255, 255),
	BulletTracerLength = 3,
	BulletTracerThickness = 1
}

local chamsSettings = {
    ChamsEnabled = false,
    FillColor = Color3.fromRGB(255, 255, 255),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 10,
    OutlineTransparency = 10
}

local corpseSettings = {
    enabled = false,
    showNames = false,
    showDistance = false,
    maxDistance = 10000,
    nameColor = Color3.fromRGB(255, 150, 0),
    distanceColor = Color3.fromRGB(255, 255, 255)
}

local vehicleSettings = {
    enabled = false,
    showNames = false,
    showDistance = false,
    maxDistance = 10000,
    nameColor = Color3.fromRGB(0, 91, 255),
    distanceColor = Color3.fromRGB(255, 255, 255)
}

local zombieESPSettings = {
    enabled = false,
    showNames = false,
    showDistance = false,
    maxDistance = 10000,
    nameColor = Color3.fromRGB(135, 90, 90),
    distanceColor = Color3.fromRGB(255, 255, 255)
}

local headExpandSettings = {
    enabled = false,
    size = 2,
    transparency = 0.5
}

local selfChamsSettings = {
    enabled = false,
    color = Color3.fromRGB(255, 255, 255),
    material = Enum.Material.ForceField
}

local gunChamsSettings = {
    enabled = false,
    color = Color3.fromRGB(250, 250, 250),
    material = Enum.Material.Plastic
}

local crosshairSettings = {
    enabled = false,
    spinning = false,
    outline = false,
    color = Color3.fromRGB(255, 255, 255),
    size = 12,
    thickness = 2,
    rotation = 0
}

local instantReloadEnabled = false
local unlockFiremodesEnabled = false
local alwaysSuppressedEnabled = false

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local chinaHatEnabled = false
local chinaHatColor = Color3.fromRGB(255, 255, 255)

local noFogConnection = nil
local fogEnabled = false
local fogColorEnabled = false

local colorCorrectionEnabled = false
local colorCorrectionSaturation = 1
local colorCorrectionContrast = 0.5
local colorCorrectionBrightness = 1
local colorCorrectionInstance = nil

local zombiesFolder = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("zombies")
if not zombiesFolder then
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") and obj.Name:lower():find("zombie") then
            zombiesFolder = obj
            break
        end
    end
end
local OriginalSizes = {}
local Connections = {}
local headExpandEnabled = false

local function expandHead(char)
    if char.Parent == Players.LocalPlayer then return end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        if not OriginalSizes[head] then
            OriginalSizes[head] = head.Size
        end
        head.Size = Vector3.new(headExpandSettings.size, headExpandSettings.size, headExpandSettings.size)
        head.Transparency = headExpandSettings.transparency
        head.Material = Enum.Material.Neon
    end
end

local function onPlayerHead(plr)
    if plr == Players.LocalPlayer then return end
    if plr.Character then expandHead(plr.Character) end
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head")
        expandHead(char)
    end)
end

local function enableExpander()
    headExpandEnabled = true
    for _, plr in ipairs(Players:GetPlayers()) do
        onPlayerHead(plr)
    end
    Connections["PlayerAdded"] = Players.PlayerAdded:Connect(onPlayerHead)
end

local function disableExpander()
    headExpandEnabled = false
    if Connections["PlayerAdded"] then
        Connections["PlayerAdded"]:Disconnect()
        Connections["PlayerAdded"] = nil
    end
    for head, size in pairs(OriginalSizes) do
        if head and head.Parent then
            head.Size = size
            head.Transparency = 0
            head.Material = Enum.Material.Plastic
        end
    end
end

local function updateHeadExpander()
    if headExpandSettings.enabled then
        disableExpander()
        enableExpander()
    end
end

local function applyChams(char)
    task.wait()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Color = selfChamsSettings.color
            part.Material = selfChamsSettings.material
        end
    end
end

local function clearChams(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Color = Color3.fromRGB(255, 255, 255)
            part.Material = Enum.Material.Plastic
        end
    end
end

local function createChinaHat(character)
    if not character then return end
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    local old = character:FindFirstChild("ChinaHat")
    if old then
        old:Destroy()
    end

    local cone = Instance.new("Part")
    cone.Name = "ChinaHat"
    cone.Size = Vector3.new(1, 1, 1)
    cone.Transparency = 0.8
    cone.CanCollide = false
    cone.Anchored = false
    cone.Massless = true
    cone.CastShadow = false

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.8, 1.1, 1.8)
    mesh.Parent = cone

    cone.CFrame = head.CFrame * CFrame.new(0, 0.9, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = cone
    weld.Parent = cone

    local highlight = Instance.new("Highlight")
    highlight.Adornee = cone
    highlight.FillColor = chinaHatColor
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = cone

    cone.Parent = character
end

local gui = Instance.new("ScreenGui")
gui.Name = "RotatingCrosshair"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local group = Instance.new("Frame")
group.AnchorPoint = Vector2.new(0.5, 0.5)
group.Position = UDim2.new(0.5, 0, 0.5, 0)
group.Size = UDim2.new(0, 0, 0, 0)
group.BackgroundTransparency = 1
group.BorderSizePixel = 0
group.Parent = gui

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Size = UDim2.new(0, crosshairSettings.thickness, 0, crosshairSettings.thickness)
center.BackgroundColor3 = crosshairSettings.color
center.BorderSizePixel = 0
center.Visible = false
center.Parent = group

local horiz = Instance.new("Frame")
horiz.AnchorPoint = Vector2.new(0.5, 0.5)
horiz.Size = UDim2.new(0, crosshairSettings.size, 0, crosshairSettings.thickness)
horiz.BackgroundColor3 = crosshairSettings.color
horiz.BorderSizePixel = 0
horiz.Visible = false
horiz.Parent = group

local vert = Instance.new("Frame")
vert.AnchorPoint = Vector2.new(0.5, 0.5)
vert.Size = UDim2.new(0, crosshairSettings.thickness, 0, crosshairSettings.size)
vert.BackgroundColor3 = crosshairSettings.color
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
    horiz.BackgroundColor3 = crosshairSettings.color
    vert.BackgroundColor3 = crosshairSettings.color
    center.BackgroundColor3 = crosshairSettings.color
    horiz.Size = UDim2.new(0, crosshairSettings.size, 0, crosshairSettings.thickness)
    vert.Size = UDim2.new(0, crosshairSettings.thickness, 0, crosshairSettings.size)
    horiz.Visible = crosshairSettings.enabled
    vert.Visible = crosshairSettings.enabled
    center.Visible = crosshairSettings.enabled
    outline.Enabled = crosshairSettings.outline
    outline2.Enabled = crosshairSettings.outline
end

local angle = 0
RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        if crosshairSettings.spinning and crosshairSettings.enabled then
            angle = (angle + 120 * dt) % 360
            horiz.Rotation = angle
            vert.Rotation = angle
        elseif crosshairSettings.enabled then
            horiz.Rotation = 0
            vert.Rotation = 0
        end
    end)
end)

local customSkyEnabled = false
local selectedSky = "Galaxy"

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
        return
    end

    sky.Parent = Lighting
end

local function freezeZombie(zombie)
    pcall(function()
        local humanoid = zombie:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetAttribute("DefaultWalkSpeed", humanoid.WalkSpeed)
            humanoid:SetAttribute("DefaultJumpPower", humanoid.JumpPower)
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
        for _, part in ipairs(zombie:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end)
end

local function unfreezeZombie(zombie)
    pcall(function()
        local humanoid = zombie:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid:GetAttribute("DefaultWalkSpeed") or 16
            humanoid.JumpPower = humanoid:GetAttribute("DefaultJumpPower") or 50
        end
        for _, part in ipairs(zombie:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end)
end

local function updateZombieCircle()
    task.spawn(function()
        while zombieCircleEnabled do
            pcall(function()
                local localPlayer = Players.LocalPlayer
                local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

                if rootPart and zombiesFolder then
                    local count = #zombiesFolder:GetChildren()
                    if count > 0 then
                        local angleStep = math.pi * 2 / count

                        for i, zombie in ipairs(zombiesFolder:GetChildren()) do
                            local root = zombie:FindFirstChild("HumanoidRootPart")
                            if root then
                                local angle = tick() * zombieCircleSpeed + (i * angleStep)
                                local offset = Vector3.new(
                                    math.cos(angle) * zombieCircleDistance,
                                    0,
                                    math.sin(angle) * zombieCircleDistance
                                )
                                root.CFrame = CFrame.new(rootPart.Position + offset)
                            end
                        end
                    end
                end
            end)
            task.wait()
        end
    end)
end

local clouds = workspace:FindFirstChildOfClass("Clouds") or (workspace.Terrain and workspace.Terrain:FindFirstChildOfClass("Clouds"))
local cloudFlags = {
    ModifyClouds = false
}

local cloudColor = clouds and clouds.Color or Color3.fromRGB(255, 255, 255)
local cloudCover = clouds and clouds.Cover or 0.5
local cloudDensity = clouds and clouds.Density or 0.5
local cloudsEnabled = clouds and clouds.Enabled or true

local function updateColorCorrection()
    if colorCorrectionEnabled then
        if not colorCorrectionInstance then
            colorCorrectionInstance = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
            if not colorCorrectionInstance then
                colorCorrectionInstance = Instance.new("ColorCorrectionEffect")
                colorCorrectionInstance.Parent = Lighting
            end
        end
        colorCorrectionInstance.Saturation = colorCorrectionSaturation
        colorCorrectionInstance.Contrast = colorCorrectionContrast * 2
        colorCorrectionInstance.Brightness = colorCorrectionBrightness - 1
        colorCorrectionInstance.Enabled = true
    else
        if colorCorrectionInstance then
            colorCorrectionInstance.Enabled = false
        end
    end
end



task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local UIS = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    
    local Framework, Wrapper, Bullets
    pcall(function()
        Framework = require(ReplicatedFirst.Framework)
        Wrapper = getupvalue(getupvalue(Framework.require, 1), 1)
        Bullets = Wrapper.Libraries.Bullets
    end)

    local FOVCircle = Drawing.new("Circle")
    local FOVOutline = Drawing.new("Circle")
    local SnapLine = Drawing.new("Line")
    local SnapOutline = Drawing.new("Line")
    local Holding = false

    local function UpdateFOV()
        if not Settings.FOVEnabled then
            FOVCircle.Visible = false
            FOVOutline.Visible = false
            return
        end
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local radius = Settings.FOVRadius
        if Settings.FOVDynamic and Holding then
            radius = radius * 0.85
        end
        if Settings.FOVOutline then
            FOVOutline.Visible = true
            FOVOutline.Position = center
            FOVOutline.Radius = radius
            FOVOutline.Color = Color3.fromRGB(0, 0, 0)
            FOVOutline.Thickness = Settings.FOVThickness + 3
            FOVOutline.Filled = false
            FOVOutline.ZIndex = -10
            FOVOutline.Transparency = 1
        else
            FOVOutline.Visible = false
        end
        FOVCircle.Visible = true
        FOVCircle.Position = center
        FOVCircle.Radius = radius
        FOVCircle.Color = Settings.FOVColor
        FOVCircle.Thickness = Settings.FOVThickness
        FOVCircle.Filled = Settings.FOVFill
        FOVCircle.Transparency = 1
    end
        
    local function GetClosestPlayer(targetType, hitbox, maxDistance)
        local closest, shortest = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild(hitbox) then
                local char = player.Character
                local part = char[hitbox]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if not onScreen then continue end
                
                local dist3D = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    and (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude or math.huge
                    
                if dist3D > maxDistance then continue end
                
                local dist2D = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                
                local distance = (targetType == "Closest To Mouse") and dist2D or dist3D
                if distance < shortest then
                    shortest = distance
                    closest = char
                end
            end
        end
        return closest
    end

    local function MoveMouseTo(targetPos)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local delta = (Vector2.new(targetPos.X, targetPos.Y) - center) * Settings.AimbotSmoothing
        if mousemoverel then mousemoverel(delta.X, delta.Y) end
    end

    -- No Recoil 
    if Bullets and Bullets.Fire then
        local GetFireImpulse = getupvalue(Bullets.Fire, 6)
        if GetFireImpulse then
            setupvalue(Bullets.Fire, 6, function(...)
                local impulse = {GetFireImpulse(...)}
                if Settings.NoRecoilEnabled then
                    for i = 1, #impulse do
                        impulse[i] = impulse[i] * Settings.RecoilScale
                    end
                end
                return unpack(impulse)
            end)
        end
    end

    -- Silent Aim (з перевіркою)
    if Bullets and Bullets.Fire then
        local oldFire = Bullets.Fire
        Bullets.Fire = function(w, c, _, g, origin, dir, ...)
            if Settings.SilentEnabled then
                local target = GetClosestPlayer(Settings.SilentTargetType, Settings.SilentTargetHitbox, Settings.SilentMaxDistance)
                if target and math.random(1, 100) <= Settings.SilentHitChance then
                    local part = target:FindFirstChild(Settings.SilentTargetHitbox)
                    if part then
                        dir = (part.Position - origin).Unit
                    end
                end
            end
            return oldFire(w, c, _, g, origin, dir, ...)
        end
    end

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Settings.AimbotHoldKey then Holding = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Settings.AimbotHoldKey then Holding = false end
    end)

    RunService.RenderStepped:Connect(function()
        pcall(function()
            UpdateFOV()
            
            local target = GetClosestPlayer(Settings.AimbotTargetType, Settings.AimbotTargetHitbox, Settings.AimbotMaxDistance)
            
            if not target or not target:FindFirstChild(Settings.AimbotTargetHitbox) then
                SnapLine.Visible = false
                SnapOutline.Visible = false
                return
            end
            
            local part = target[Settings.AimbotTargetHitbox]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then return end

            if Settings.SnapLine then
                local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local to = Vector2.new(pos.X, pos.Y)
                if Settings.SnapLineOutline then
                    SnapOutline.Visible = true
                    SnapOutline.From = from
                    SnapOutline.To = to
                    SnapOutline.Color = Color3.fromRGB(0,0,0)
                    SnapOutline.Thickness = Settings.SnapLineThickness + 3
                    SnapOutline.Transparency = Settings.SnapLineOutlineTransparency
                    SnapOutline.ZIndex = -10
                else
                    SnapOutline.Visible = false
                end
                SnapLine.Visible = true
                SnapLine.From = from
                SnapLine.To = to
                SnapLine.Color = Settings.SnapLineColor
                SnapLine.Thickness = Settings.SnapLineThickness
                SnapLine.Transparency = 1
                SnapLine.ZIndex = 10
            else
                SnapLine.Visible = false
                SnapOutline.Visible = false
            end

            if Settings.AimbotEnabled and Holding then
                MoveMouseTo(pos)
            end
        end)
    end)
end)

-- ЗБРОЯ ФУНКЦІЇ
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local Players = game:GetService("Players")

    local LocalPlayer = Players.LocalPlayer
    
    pcall(function()
        local Framework = require(ReplicatedFirst:WaitForChild("Framework"))
        Framework:WaitForLoaded()

        local Firearm = nil
        task.spawn(function()
            setthreadidentity(2)
            Firearm = require(ReplicatedStorage.Client.Abstracts.ItemInitializers.Firearm)
        end)
        repeat task.wait() until Firearm

        local AnimatedReload = getupvalue(Firearm, 7)

        if AnimatedReload then
            setupvalue(Firearm, 7, function(...)
                if instantReloadEnabled then
                    local Args = {...}
                    for Index = 0, Args[3].LoopCount do
                        Args[4]("Commit", "Load")
                    end
                    Args[4]("Commit", "End")
                    return true
                end
                return AnimatedReload(...)
            end)
        end

        -- Unlock Firemodes
        local function setupFiremodes()
            pcall(function()
                local Framework = require(game:GetService("ReplicatedFirst"):FindFirstChild("Framework"))
                local PlayerClass = Framework.Classes.Players.get()
                
                local oldSend = Framework.Libraries.Network.Send
                
                Framework.Libraries.Network.Send = function(self, event, ...)
                    if event == "Inventory Use Item" then
                        local args = {...}
                        local itemId = args[1]
                        
                        pcall(function()
                            if Framework.Configs and Framework.Configs.ItemData then
                                local item = Framework.Configs.ItemData[itemId]
                                if item and item.FireConfig then
                                    local modes = {}
                                    for _, mode in ipairs(item.FireModes or {}) do
                                        modes[mode] = true
                                    end
                                    modes["Automatic"] = true
                                    modes["Semiautomatic"] = true
                                    modes["Burst"] = true
                                    
                                    local newModes = {}
                                    for mode, _ in pairs(modes) do
                                        table.insert(newModes, mode)
                                    end
                                    item.FireModes = newModes
                                end
                            end
                        end)
                    end
                    return oldSend(self, event, ...)
                end
                
                repeat task.wait() until PlayerClass and PlayerClass.Character
                
                local oldEquip = PlayerClass.Character.Equip
                
                PlayerClass.Character.Equip = function(self, item, ...)
                    if item and item.__item then
                        local modes = {}
                        for _, mode in ipairs(item.__item.FireModes or {}) do
                            modes[mode] = true
                        end
                        modes["Automatic"] = true
                        modes["Semiautomatic"] = true
                        modes["Burst"] = true
                        
                        local newModes = {}
                        for mode, _ in pairs(modes) do
                            table.insert(newModes, mode)
                        end
                        item.__item.FireModes = newModes
                    end
                    return oldEquip(self, item, ...)
                end
                
                if PlayerClass.Character.EquippedItem then
                    local weapon = PlayerClass.Character.EquippedItem.__item
                    if weapon then
                        local modes = {}
                        for _, mode in ipairs(weapon.FireModes or {}) do
                            modes[mode] = true
                        end
                        modes["Automatic"] = true
                        modes["Semiautomatic"] = true
                        modes["Burst"] = true
                        
                        local newModes = {}
                        for mode, _ in pairs(modes) do
                            table.insert(newModes, mode)
                        end
                        weapon.FireModes = newModes
                    end
                end
                
                task.spawn(function()
                    while unlockFiremodesEnabled do
                        task.wait(1)
                        pcall(function()
                            if PlayerClass and PlayerClass.Character and PlayerClass.Character.EquippedItem then
                                local weapon = PlayerClass.Character.EquippedItem.__item
                                if weapon then
                                    local modes = {}
                                    for _, mode in ipairs(weapon.FireModes or {}) do
                                        modes[mode] = true
                                    end
                                    modes["Automatic"] = true
                                    modes["Semiautomatic"] = true
                                    modes["Burst"] = true
                                    
                                    local newModes = {}
                                    for mode, _ in pairs(modes) do
                                        table.insert(newModes, mode)
                                    end
                                    weapon.FireModes = newModes
                                end
                            end
                        end)
                    end
                end)
            end)
        end

        -- Always Suppressed
        local function setupAlwaysSuppressed()
            pcall(function()
                local Framework = require(game:GetService("ReplicatedFirst")["Framework"])
                local oldFire = Framework["Libraries"]["Bullets"]["Fire"]
                
                Framework["Libraries"]["Bullets"]["Fire"] = function(...)
                    local args = {...}
                    if args[4] then 
                        args[4]["SuppressedByDefault"] = true 
                    end
                    return oldFire(unpack(args))
                end
            end)
        end

        task.spawn(function()
            while true do
                task.wait(0.5)
                pcall(function()
                    if unlockFiremodesEnabled then
                        setupFiremodes()
                    end
                    if alwaysSuppressedEnabled then
                        setupAlwaysSuppressed()
                    end
                end)
            end
        end)
    end)
end)

-- ESP ФУНКЦІЇ
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

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
                    for _, line in ipairs(v) do 
                        pcall(line.Remove, line) 
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
        pcall(function()
            if not espFlags["enable esp"] then
                for _, esp in pairs(ESPTable) do
                    for _, v in pairs(esp) do
                        if typeof(v) == "table" then
                            for _, l in ipairs(v) do 
                                l.Visible = false 
                            end
                        else
                            v.Visible = false
                        end
                    end
                end
                return
            end
            
            local camPos = Camera.CFrame.Position
            local maxDistance = espFlags["dis chek"] or 10000
            local viewSize = Camera.ViewportSize
            local screenCenter = Vector2.new(viewSize.X/2, viewSize.Y)
            
            for player, esp in pairs(ESPTable) do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local center, bboxSize = GetCharacterBoundingBox(char)
                    if not center then
                        center = hrp.Position
                        bboxSize = Vector3.new(4, 6, 2)
                    end
                    
                    local pos, onScreen = Camera:WorldToViewportPoint(center)
                    local distance = (camPos - center).Magnitude
                    
                    if not onScreen or distance > maxDistance then
                        for _, v in pairs(esp) do
                            if typeof(v) == "table" then
                                for _, l in ipairs(v) do 
                                    l.Visible = false 
                                end
                            else
                                v.Visible = false
                            end
                        end
                        continue
                    end
                    
                    local function GetScreenSizeFromBBox()
                        local minScreen = Vector2.new(math.huge, math.huge)
                        local maxScreen = Vector2.new(-math.huge, -math.huge)
                        
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
                    
                    local boxThickness = 1
                    local skeletonThickness = 1.5
                    local tracerThickness = 1
                    
                    if hum then
                        local isCrouching = hum.HipHeight < 2
                        if isCrouching then
                            boxThickness = 1.5
                            skeletonThickness = 2
                        end
                    end
                    
                    esp.Box.Thickness = boxThickness
                    for _, line in ipairs(esp.CornerLines) do
                        line.Thickness = boxThickness
                    end
                    esp.TracerLine.Thickness = tracerThickness
                    
                    local boxColor = espFlags["color box"] or Color3.new(1,1,1)
                    local fillColor = espFlags["color fill box"] or Color3.fromRGB(255, 255, 255)
                    local skeletonColor = espFlags["color skeleton"] or Color3.new(1,1,1)
                    local tracerColor = espFlags["color tracer"] or Color3.new(1,1,1)
                    local discrColor = espFlags["distance"] or Color3.new(1,1,1)
                    local itemColor = espFlags["color item"] or Color3.new(1,1,1)
                    
                    if espFlags["fill box"] then
                        esp.FillBox.Size = Vector2.new(boxWidth, boxHeight)
                        esp.FillBox.Position = Vector2.new(xPos, yPos)
                        esp.FillBox.Color = fillColor
                        esp.FillBox.Transparency = 0.3
                        esp.FillBox.Visible = true
                    else
                        esp.FillBox.Visible = false
                    end
                    
                    if espFlags["box"] then
                        if espSettings.boxType == "Boxes" then
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
                            
                        elseif espSettings.boxType == "Corners" then
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
                    
                    if espFlags["skeleton"] then
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
                    
                    if espFlags["tbox"] then
                        esp.TracerLine.From = screenCenter
                        esp.TracerLine.To = Vector2.new(pos.X, pos.Y)
                        esp.TracerLine.Color = tracerColor
                        esp.TracerLine.Visible = true
                    else
                        esp.TracerLine.Visible = false
                    end
                    
                    if espFlags["box bar"] then
                        local hp = hum.Health
                        local maxhp = hum.MaxHealth
                        local perc = math.clamp(hp / maxhp, 0, 1)
                        local lowColor = espFlags["color hp low"] or Color3.fromRGB(255, 0, 0)
                        local fullColor = espFlags["color hp full"] or Color3.fromRGB(0, 255, 0)
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
                        
                        if espFlags["box number hear"] then
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
                    
                    if espFlags["box name"] then
                        local nameColor = espFlags["color name"] or Color3.new(1, 1, 1)
                        esp.NameText.Text = espSettings.useDisplayName and player.DisplayName or player.Name
                        esp.NameText.Position = Vector2.new(pos.X, yPos - 20)
                        esp.NameText.Color = nameColor
                        esp.NameText.Visible = true
                    else
                        esp.NameText.Visible = false
                    end
                    
                    if espFlags["box discr"] then
                        local distText = espSettings.metric == "Meters" and string.format("%.0fm", distance) or string.format("%.0fs", distance)
                        esp.DistanceText.Text = distText
                        esp.DistanceText.Position = Vector2.new(pos.X, yPos + boxHeight + 5)
                        esp.DistanceText.Color = discrColor
                        esp.DistanceText.Visible = true
                    else
                        esp.DistanceText.Visible = false
                    end
                    
                    if espFlags["box item"] then
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
                            for _, l in ipairs(v) do 
                                l.Visible = false 
                            end
                        else
                            v.Visible = false
                        end
                    end
                end
            end
        end)
    end)
end)

-- PLAYER CHAMS ФУНКЦІЇ
task.spawn(function()
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer
    local connections = {}

    local Storage = Instance.new("Folder")
    Storage.Name = "Highlight_Storage"
    Storage.Parent = CoreGui

    local function ToTransparency(val)
        return math.clamp(val / 20, 0, 1)
    end

    local function UpdateHighlight(h)
        h.FillColor = chamsSettings.FillColor
        h.OutlineColor = chamsSettings.OutlineColor
        h.FillTransparency = ToTransparency(chamsSettings.FillTransparency)
        h.OutlineTransparency = ToTransparency(chamsSettings.OutlineTransparency)
    end

    local function Highlight(plr)
        if plr == lp then return end
        if Storage:FindFirstChild(plr.Name) then
            Storage[plr.Name]:Destroy()
        end

        local h = Instance.new("Highlight")
        h.Name = plr.Name
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Enabled = chamsSettings.ChamsEnabled
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
end)

-- BULLET TRACER ФУНКЦІЇ
task.spawn(function()
    local replicated_first = game:GetService("ReplicatedFirst")
    
    pcall(function()
        local framework = require(replicated_first.Framework)
        local wrapper = getupvalue(getupvalue(framework.require, 1), 1)
        local bullets = wrapper.Libraries.Bullets

        local BulletTracerFolder = Instance.new("Folder")
        BulletTracerFolder.Name = "BulletTracers"
        BulletTracerFolder.Parent = workspace

        function createBulletTracerBeam(origin, direct)
            if not world_utilities.BulletTracer or not origin or not direct then return end

            task.spawn(function()
                local direction = direct * 2000

                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {
                    game.Players.LocalPlayer.Character,
                    BulletTracerFolder,
                    workspace:FindFirstChild("Effects")
                }
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist

                local result = workspace:Raycast(origin, direction, rayParams)
                local target = (result and result.Position) or (origin + direction)

                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1
                part.Parent = BulletTracerFolder

                local att0 = Instance.new("Attachment", part)
                att0.WorldPosition = origin
                local att1 = Instance.new("Attachment", part)
                att1.WorldPosition = target

                local beam = Instance.new("Beam", part)
                beam.Attachment0 = att0
                beam.Attachment1 = att1
                beam.Texture = "rbxassetid://446111271"
                beam.FaceCamera = true
                beam.TextureMode = Enum.TextureMode.Stretch
                beam.Color = ColorSequence.new(world_utilities.BulletTracerColor)
                beam.LightEmission = 1
                beam.Width0 = world_utilities.BulletTracerThickness
                beam.Width1 = world_utilities.BulletTracerThickness * 0.3
                beam.TextureSpeed = 5
                beam.Transparency = NumberSequence.new(0.1)

                task.delay(world_utilities.BulletTracerLength, function()
                    if part then part:Destroy() end
                end)
            end)
        end

        if bullets and bullets.Fire then
            local old_fire
            old_fire = hookfunction(bullets.Fire, function(weapon_data, character_data, _, gun_data, origin, direction, ...)
                if world_utilities.BulletTracer then
                    createBulletTracerBeam(origin, direction)
                end
                return old_fire(weapon_data, character_data, _, gun_data, origin, direction, ...)
            end)
        end
    end)
end)

-- LOCAL PLAYER ФУНКЦІЇ
task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local function handleChinaHat(char)
        if chinaHatEnabled then
            createChinaHat(char)
        else
            local hat = char:FindFirstChild("ChinaHat")
            if hat then hat:Destroy() end
        end
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        handleChinaHat(char)
    end)

    if player.Character then
        handleChinaHat(player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        task.wait()
        if selfChamsSettings.enabled then
            applyChams(char)
        end
    end)

    local originalProperties = {}

    local function ApplyGunChams(tool)
        if not tool then return end
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                if not originalProperties[obj] then
                    originalProperties[obj] = {Color = obj.Color, Material = obj.Material}
                end
                obj.Material = gunChamsSettings.material
                obj.Color = gunChamsSettings.color
            end
        end
    end

    local function RemoveGunChams(tool)
        if not tool then return end
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                if originalProperties[obj] then
                    obj.Color = originalProperties[obj].Color
                    obj.Material = originalProperties[obj].Material
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = player.Character
            if not char then return end
            local equipped = char:FindFirstChild("Equipped")
            if equipped then
                if gunChamsSettings.enabled then
                    ApplyGunChams(equipped)
                else
                    RemoveGunChams(equipped)
                end
            end
        end)
    end)
end)

-- MOVEMENT ФУНКЦІЇ
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local jumpCount = 0
    local maxJumps = 1

    local function resetJumps(humanoid)
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            jumpCount = 0
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            movementFlags.isRunning = true
        elseif input.KeyCode == Enum.KeyCode.Space and movementFlags.doubleJumpEnabled then
            pcall(function()
                if LocalPlayer and LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        if humanoid.FloorMaterial == Enum.Material.Air and jumpCount < maxJumps then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            jumpCount = jumpCount + 1
                        end
                        
                        if humanoid.FloorMaterial ~= Enum.Material.Air then
                            jumpCount = 0
                        end
                    end
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            movementFlags.isRunning = false
        end
    end)

    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
                    
            if movementFlags.runEnabled and movementFlags.isRunning then
                hum.WalkSpeed = movementFlags.runningSpeed
            elseif movementFlags.walkEnabled then
                hum.WalkSpeed = movementFlags.walkingSpeed
            end

            resetJumps(hum)
        end)
    end)

    task.spawn(function()
        while true do
            pcall(function()
                if LocalPlayer and LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    resetJumps(humanoid)
                end
            end)
            task.wait(0.1)
        end
    end)
end)

-- ANTI-AIM ФУНКЦІЇ
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local angle = 0
    RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and antiAimFlags.enabled then
                if antiAimFlags.permaSpin then
                    angle = angle + math.rad(antiAimFlags.spinSpeed)
                end
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
            end
        end)
    end)
end)

-- ZOMBIE ФУНКЦІЇ
task.spawn(function()
    if not zombiesFolder then return end

    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                if isFreezeEnabled then
                    for _, zombie in pairs(zombiesFolder:GetChildren()) do
                        if zombie:IsA("Model") then
                            freezeZombie(zombie)
                        end
                    end
                end
            end)
        end
    end)
end)

window.UserSettings:AddLabel("Menu Keybind"):AddKeybind({
	Default = 'Insert',
	Callback = function(v)
		window.Keybind = v;
		
		Logging.new("ps4-touchpad",'Changed ui keybind to '..tostring(v),5)
	end,
})

window.UserSettings:AddLabel('Menu Scale'):AddDropdown({
	Default = "Default",
	Values = {"Default",'Large','Mobile','Small'},
	Callback = function(v)
		window:SetSize(NeverLose.Scales[v]);
		
		Logging.new("crop",'Changed ui size to '..tostring(v),5)
	end,
})

window.UserSettings:AddButton({
	Icon = 'discord',
	Name = 'Discord',
	Callback = function()
        setclipboard("https://raw.githubusercontent.com/DeviceHB21/er-grg-eg/refs/heads/main/invite")
		Logging.new("discord",'Copied discord invite link',5)
	end,
})

-- SILENT AIM
SilentAimSection:AddLabel('Silent Aim'):AddToggle({
    Default = false,
    Flag = "SilentAim",
    Callback = function(v) Settings.SilentEnabled = v end
})

SilentAimSection:AddLabel('Hit Chance'):AddSlider({
    Min = 1,
    Max = 100,
    Default = 100,
    Flag = "SilentHitChance",
    Callback = function(v) Settings.SilentHitChance = v end
})

SilentAimSection:AddLabel('Max Distance'):AddSlider({
    Min = 100,
    Max = 3000,
    Default = 2000,
    Flag = "SilentDistance",
    Callback = function(v) Settings.SilentMaxDistance = v end
})

SilentAimSection:AddLabel('Target Type'):AddDropdown({
    Default = 'Closest To Mouse',
    Values = {'Closest To Mouse', 'Closest To Player'},
    Flag = "SilentType",
    Callback = function(v) Settings.SilentTargetType = v end
})

SilentAimSection:AddLabel('Hitbox'):AddDropdown({
    Default = 'Head',
    Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'},
    Flag = "SilentHitbox",
    Callback = function(v) Settings.SilentTargetHitbox = v end
})

-- FOV (RAGE)
 fovToggle = FOVSection:AddLabel('FOV Circle')
fovToggle:AddToggle({
    Default = false,
    Flag = "RageFOV",
    Callback = function(v) Settings.FOVEnabled = v end
})
fovToggle:AddOption():AddLabel('FOV Color'):AddColorPicker({
    Default = Settings.FOVColor,
    Flag = "RageFOVColor",
    Callback = function(v) Settings.FOVColor = v end
})

FOVSection:AddLabel('FOV Outline'):AddToggle({
    Default = false,
    Flag = "RageFOVOutline",
    Callback = function(v) Settings.FOVOutline = v end
})

FOVSection:AddLabel('FOV Radius'):AddSlider({
    Min = 50,
    Max = 500,
    Default = 150,
    Flag = "RageFOVRadius",
    Callback = function(v) Settings.FOVRadius = v end
})

FOVSection:AddLabel('FOV Thickness'):AddSlider({
    Min = 1,
    Max = 5,
    Default = 2,
    Flag = "RageFOVThickness",
    Callback = function(v) Settings.FOVThickness = v end
})

-- SNAP LINE (RAGE)
snapToggle = SnapLineSection:AddLabel('Snap Line')
snapToggle:AddToggle({
    Default = false,
    Flag = "RageSnapLine",
    Callback = function(v) Settings.SnapLine = v end
})
snapToggle:AddOption():AddLabel('Snap Color'):AddColorPicker({
    Default = Settings.SnapLineColor,
    Flag = "RageSnapColor",
    Callback = function(v) Settings.SnapLineColor = v end
})

SnapLineSection:AddLabel('Snap Outline'):AddToggle({
    Default = false,
    Flag = "RageSnapOutline",
    Callback = function(v) Settings.SnapLineOutline = v end
})

SnapLineSection:AddLabel('Snap Thickness'):AddSlider({
    Min = 1,
    Max = 5,
    Default = 2,
    Flag = "RageSnapThickness",
    Callback = function(v) Settings.SnapLineThickness = v end
})

-- GUN MODS
 noRecoilToggle = GunModsSection:AddLabel('No Recoil')
noRecoilToggle:AddToggle({
    Default = false,
    Flag = "NoRecoil",
    Callback = function(v) Settings.NoRecoilEnabled = v end
})
 recoilOptions = noRecoilToggle:AddOption()
recoilOptions:AddLabel('Recoil Control'):AddSlider({
    Min = 1,
    Max = 100,
    Default = 10,
    Flag = "RecoilControl",
    Callback = function(v) Settings.RecoilScale = v / 100 end
})

GunModsSection:AddLabel('Instant Reload'):AddToggle({
    Default = false,
    Flag = "InstantReload",
    Callback = function(v) instantReloadEnabled = v end
})

GunModsSection:AddLabel('Unlock Firemodes'):AddToggle({
    Default = false,
    Flag = "UnlockFiremodes",
    Callback = function(v) unlockFiremodesEnabled = v end
})

GunModsSection:AddLabel('Always Suppressed'):AddToggle({
    Default = false,
    Flag = "AlwaysSuppressed",
    Callback = function(v) alwaysSuppressedEnabled = v end
})

-- AIM BOT
AimbotSection:AddLabel('Aim Bot'):AddToggle({
    Default = false,
    Flag = "Aimbot",
    Callback = function(v) Settings.AimbotEnabled = v end
})

AimbotSection:AddLabel('Smoothness'):AddSlider({
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Flag = "AimbotSmooth",
    Callback = function(v) Settings.AimbotSmoothing = v end
})

AimbotSection:AddLabel('Max Distance'):AddSlider({
    Min = 100,
    Max = 3000,
    Default = 1500,
    Flag = "AimbotDistance",
    Callback = function(v) Settings.AimbotMaxDistance = v end
})

AimbotSection:AddLabel('Target Type'):AddDropdown({
    Default = 'Closest To Mouse',
    Values = {'Closest To Mouse', 'Closest To Player'},
    Flag = "AimbotType",
    Callback = function(v) Settings.AimbotTargetType = v end
})

AimbotSection:AddLabel('Hitbox'):AddDropdown({
    Default = 'Head',
    Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'},
    Flag = "AimbotHitbox",
    Callback = function(v) Settings.AimbotTargetHitbox = v end
})

-- FOV (LEGIT)
 legitFovToggle = LegitFOVSection:AddLabel('FOV Circle')
legitFovToggle:AddToggle({
    Default = false,
    Flag = "LegitFOV",
    Callback = function(v) Settings.FOVEnabled = v end
})
legitFovToggle:AddOption():AddLabel('FOV Color'):AddColorPicker({
    Default = Settings.FOVColor,
    Flag = "LegitFOVColor",
    Callback = function(v) Settings.FOVColor = v end
})

LegitFOVSection:AddLabel('FOV Outline'):AddToggle({
    Default = false,
    Flag = "LegitFOVOutline",
    Callback = function(v) Settings.FOVOutline = v end
})

LegitFOVSection:AddLabel('FOV Radius'):AddSlider({
    Min = 50,
    Max = 500,
    Default = 150,
    Flag = "LegitFOVRadius",
    Callback = function(v) Settings.FOVRadius = v end
})

LegitFOVSection:AddLabel('FOV Thickness'):AddSlider({
    Min = 1,
    Max = 5,
    Default = 2,
    Flag = "LegitFOVThickness",
    Callback = function(v) Settings.FOVThickness = v end
})

-- SNAP LINE (LEGIT)
 legitSnapToggle = LegitSnapLineSection:AddLabel('Snap Line')
legitSnapToggle:AddToggle({
    Default = false,
    Flag = "LegitSnapLine",
    Callback = function(v) Settings.SnapLine = v end
})
legitSnapToggle:AddOption():AddLabel('Snap Color'):AddColorPicker({
    Default = Settings.SnapLineColor,
    Flag = "LegitSnapColor",
    Callback = function(v) Settings.SnapLineColor = v end
})

LegitSnapLineSection:AddLabel('Snap Outline'):AddToggle({
    Default = false,
    Flag = "LegitSnapOutline",
    Callback = function(v) Settings.SnapLineOutline = v end
})

LegitSnapLineSection:AddLabel('Snap Thickness'):AddSlider({
    Min = 1,
    Max = 5,
    Default = 2,
    Flag = "LegitSnapThickness",
    Callback = function(v) Settings.SnapLineThickness = v end
})

-- PLAYER ESP
 espToggle = PlayerESPSection:AddLabel('Enable ESP')
espToggle:AddToggle({
    Default = false,
    Flag = "enable esp",
    Callback = function(Value) espFlags["enable esp"] = Value end
})

-- BOX
 boxToggle = PlayerESPSection:AddLabel('Box')
boxToggle:AddToggle({
    Default = false,
    Flag = "box",
    Callback = function(Value) espFlags["box"] = Value end
})
boxOptions = boxToggle:AddOption()
boxOptions:AddLabel('Box Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "color box",
    Callback = function(Value) espFlags["color box"] = Value end
})
boxOptions:AddLabel('Box Type'):AddDropdown({
    Default = 'Boxes',
    Values = {'Boxes', 'Corners'},
    Flag = "box type",
    Callback = function(Value) espSettings.boxType = Value end
})
boxOptions:AddLabel('Fill Box'):AddToggle({
    Default = false,
    Flag = "fill box",
    Callback = function(Value) espFlags["fill box"] = Value end
})

-- SKELETON
 skeletonToggle = PlayerESPSection:AddLabel('Skeleton')
skeletonToggle:AddToggle({
    Default = false,
    Flag = "skeleton",
    Callback = function(Value) espFlags["skeleton"] = Value end
})
skeletonToggle:AddOption():AddLabel('Skeleton Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "color skeleton",
    Callback = function(Value) espFlags["color skeleton"] = Value end
})

-- HEALTH BAR
 healthToggle = PlayerESPSection:AddLabel('Health Bar')
healthToggle:AddToggle({
    Default = false,
    Flag = "box bar",
    Callback = function(Value) espFlags["box bar"] = Value end
})
 healthOptions = healthToggle:AddOption()
healthOptions:AddLabel('Full Health Color'):AddColorPicker({
    Default = Color3.fromRGB(0,255,0),
    Flag = "color hp full",
    Callback = function(Value) espFlags["color hp full"] = Value end
})
healthOptions:AddLabel('Low Health Color'):AddColorPicker({
    Default = Color3.fromRGB(255,0,0),
    Flag = "color hp low",
    Callback = function(Value) espFlags["color hp low"] = Value end
})
healthOptions:AddLabel('Health Number'):AddToggle({
    Default = false,
    Flag = "box number hear",
    Callback = function(Value) espFlags["box number hear"] = Value end
})
healthOptions:AddLabel('Max HP Visibility'):AddSlider({
    Min = 0,
    Max = 100,
    Default = 100,
    Flag = "max hp",
    Callback = function(Value) espSettings.maxHPVisibility = Value end
})

-- SHOW NAME
 nameToggle = PlayerESPSection:AddLabel('Show Name')
nameToggle:AddToggle({
    Default = false,
    Flag = "box name",
    Callback = function(Value) espFlags["box name"] = Value end
})
 nameOptions = nameToggle:AddOption()
nameOptions:AddLabel('Name Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "color name",
    Callback = function(Value) espFlags["color name"] = Value end
})
nameOptions:AddLabel('Use Display Name'):AddToggle({
    Default = true,
    Flag = "use display name",
    Callback = function(Value) espSettings.useDisplayName = Value end
})

-- DISTANCE
 distanceToggle = PlayerESPSection:AddLabel('Distance')
distanceToggle:AddToggle({
    Default = false,
    Flag = "box discr",
    Callback = function(Value) espFlags["box discr"] = Value end
})
 distanceOptions = distanceToggle:AddOption()
distanceOptions:AddLabel('Distance Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "distance",
    Callback = function(Value) espFlags["distance"] = Value end
})
distanceOptions:AddLabel('Metric'):AddDropdown({
    Default = 'Meters',
    Values = {'Meters', 'Studs'},
    Flag = "metric",
    Callback = function(Value) espSettings.metric = Value end
})
distanceOptions:AddLabel('Distance Check'):AddSlider({
    Min = 1000,
    Max = 10000,
    Default = 5000,
    Flag = "dis chek",
    Callback = function(Value) espFlags["dis chek"] = Value end
})

-- EQUIPPED ITEM
 itemToggle = PlayerESPSection:AddLabel('Equipped Item')
itemToggle:AddToggle({
    Default = false,
    Flag = "box item",
    Callback = function(Value) espFlags["box item"] = Value end
})
itemToggle:AddOption():AddLabel('Item Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "color item",
    Callback = function(Value) espFlags["color item"] = Value end
})

-- TRACER
 tracerToggle = PlayerESPSection:AddLabel('Tracer')
tracerToggle:AddToggle({
    Default = false,
    Flag = "tbox",
    Callback = function(Value) espFlags["tbox"] = Value end
})
tracerToggle:AddOption():AddLabel('Tracer Color'):AddColorPicker({
    Default = Color3.new(1,1,1),
    Flag = "color tracer",
    Callback = function(Value) espFlags["color tracer"] = Value end
})

-- MAP ESP
PlayerESPSection:AddButton({
    Name = 'Map ESP',
    Callback = function()
        pcall(function()
            local interfaceMap = require(game:GetService("ReplicatedFirst").Framework).Interface.Map
            interfaceMap:EnableGodview()
        end)
    end
})

-- PLAYER CHAMS
 chamToggle = PlayerChamsSection:AddLabel('Player Chams')
chamToggle:AddToggle({
    Default = false,
    Flag = "ChamsToggle",
    Callback = function(Value)
        chamsSettings.ChamsEnabled = Value
        for _, h in ipairs(game:GetService("CoreGui").Highlight_Storage:GetChildren()) do
            h.Enabled = chamsSettings.ChamsEnabled
        end
    end
})
 chamOptions = chamToggle:AddOption()
chamOptions:AddLabel('Fill Color'):AddColorPicker({
    Default = chamsSettings.FillColor,
    Flag = "ChamsFillColor",
    Callback = function(Value)
        chamsSettings.FillColor = Value
        for _, h in ipairs(game:GetService("CoreGui").Highlight_Storage:GetChildren()) do
            h.FillColor = chamsSettings.FillColor
        end
    end
})
chamOptions:AddLabel('Outline Color'):AddColorPicker({
    Default = chamsSettings.OutlineColor,
    Flag = "ChamsOutlineColor",
    Callback = function(Value)
        chamsSettings.OutlineColor = Value
        for _, h in ipairs(game:GetService("CoreGui").Highlight_Storage:GetChildren()) do
            h.OutlineColor = chamsSettings.OutlineColor
        end
    end
})

PlayerChamsSection:AddLabel('Fill Transparency'):AddSlider({
    Min = 0,
    Max = 20,
    Default = 10,
    Flag = "FillTransparency",
    Callback = function(Value)
        chamsSettings.FillTransparency = Value
        local trans = math.clamp(Value / 20, 0, 1)
        for _, h in ipairs(game:GetService("CoreGui").Highlight_Storage:GetChildren()) do
            h.FillTransparency = trans
        end
    end
})

PlayerChamsSection:AddLabel('Outline Transparency'):AddSlider({
    Min = 0,
    Max = 20,
    Default = 10,
    Flag = "OutlineTransparency",
    Callback = function(Value)
        chamsSettings.OutlineTransparency = Value
        local trans = math.clamp(Value / 20, 0, 1)
        for _, h in ipairs(game:GetService("CoreGui").Highlight_Storage:GetChildren()) do
            h.OutlineTransparency = trans
        end
    end
})

local corpsesFolder = workspace:WaitForChild("Corpses")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local corpseESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local corpseHighlightColor = Color3.fromRGB(255, 0, 0)
local corpseNameColor = Color3.fromRGB(255, 150, 0)
local corpseDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 11
local fontType = Enum.Font.Code

local function isIgnoredCorpse(model)
	return model.Name:lower():find("infected") ~= nil
end

local function removeESP(model)
	local highlight = model:FindFirstChild("CorpseHighlight")
	if highlight then highlight:Destroy() end
	local espGui = model:FindFirstChild("CorpseESP")
	if espGui then espGui:Destroy() end
end

local function createHighlight(model)
	if isIgnoredCorpse(model) then return end
	if not model:FindFirstChild("CorpseHighlight") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "CorpseHighlight"
		highlight.FillColor = corpseHighlightColor
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Adornee = model
		highlight.Parent = model
	end
end

local function createBillboard(model)
	if isIgnoredCorpse(model) then return end
	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then return end
	removeESP(model)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CorpseESP"
	billboard.Adornee = primary
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	if showNames then
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "CorpseName"
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextSize = fontSize + 1
		nameLabel.TextColor3 = corpseNameColor
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.Font = fontType
		nameLabel.Text = model.Name .. "'s Corpse"
		nameLabel.Parent = billboard
	end

	if showDistance then
		local distanceLabel = Instance.new("TextLabel")
		distanceLabel.Name = "CorpseDistance"
		distanceLabel.Size = UDim2.new(1, 0, 0, 20)
		distanceLabel.Position = UDim2.new(0, 0, 0, 16)
		distanceLabel.BackgroundTransparency = 1
		distanceLabel.TextSize = fontSize
		distanceLabel.TextColor3 = corpseDistanceColor
		distanceLabel.TextStrokeTransparency = 0.5
		distanceLabel.Font = fontType
		distanceLabel.Text = "..."
		distanceLabel.Parent = billboard
	end
end

local function updateCorpseESP()
	for _, corpse in pairs(corpsesFolder:GetChildren()) do
		if corpse:IsA("Model") and not isIgnoredCorpse(corpse) then
			if corpseESPEnabled then
				createHighlight(corpse)
				if showNames or showDistance then
					createBillboard(corpse)
				else
					removeESP(corpse)
				end
			else
				removeESP(corpse)
			end
		else
			removeESP(corpse)
		end
	end
end

corpsesFolder.ChildAdded:Connect(function(child)
	if corpseESPEnabled and child:IsA("Model") and not isIgnoredCorpse(child) then
		createHighlight(child)
		if showNames or showDistance then
			createBillboard(child)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not corpseESPEnabled then return end
	local camPos = Camera.CFrame.Position
	for _, corpse in pairs(corpsesFolder:GetChildren()) do
		if corpse:IsA("Model") and not isIgnoredCorpse(corpse) then
			local primary = corpse.PrimaryPart or corpse:FindFirstChildWhichIsA("BasePart")
			if primary then
				local distance = (camPos - primary.Position).Magnitude
				local inRange = distance <= maxDistance
				local transparency = 0
				local fadeStart = maxDistance * 0.9

				if distance >= maxDistance then
					transparency = 1
				elseif distance >= fadeStart then
					transparency = (distance - fadeStart) / (maxDistance * 0.1)
				end

				local espGui = corpse:FindFirstChild("CorpseESP")
				if espGui then
					local nameLabel = espGui:FindFirstChild("CorpseName")
					local distanceLabel = espGui:FindFirstChild("CorpseDistance")
					if nameLabel then
						nameLabel.Visible = showNames and inRange
						nameLabel.TextTransparency = transparency
						nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
					end
					if distanceLabel then
						distanceLabel.Visible = showDistance and inRange
						distanceLabel.TextTransparency = transparency
						distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
						if inRange then
							distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
						end
					end
				end

				local hl = corpse:FindFirstChild("CorpseHighlight")
				if hl then
					hl.FillTransparency = 0.5 + transparency / 2
					hl.OutlineTransparency = transparency
				end
			end
		end
	end
end)

 corpseToggle = CorpseESPSection:AddLabel('Corpse ESP')
corpseToggle:AddToggle({
    Default = false,
    Flag = "CorpseESP",
	Callback = function(Value)
		corpseESPEnabled = Value
		updateCorpseESP()
	end
})

local corpseNameToggle = CorpseESPSection:AddLabel('Show Corpse Name')
corpseNameToggle:AddToggle({
    Default = false,
    Flag = "CorpseName",
	Callback = function(Value)
		showNames = Value
		updateCorpseESP()
	end
})
corpseNameToggle:AddOption():AddLabel('Name Color'):AddColorPicker({
    Default = corpseSettings.nameColor,
    Flag = "CorpseNameColor",
	Callback = function(Value)
		corpseNameColor = Value
		for _, corpse in pairs(corpsesFolder:GetChildren()) do
			local espGui = corpse:FindFirstChild("CorpseESP")
			if espGui then
				local label = espGui:FindFirstChild("CorpseName")
				if label then label.TextColor3 = Value end
			end
		end
	end
})

 corpseDistToggle = CorpseESPSection:AddLabel('Show Distance')
corpseDistToggle:AddToggle({
    Default = false,
    Flag = "CorpseDistance",
	Callback = function(Value)
		showDistance = Value
		updateCorpseESP()
	end
})
corpseDistToggle:AddOption():AddLabel('Distance Color'):AddColorPicker({
    Default = corpseSettings.distanceColor,
    Flag = "CorpseDistanceColor",
	Callback = function(Value)
		corpseDistanceColor = Value
		for _, corpse in pairs(corpsesFolder:GetChildren()) do
			local espGui = corpse:FindFirstChild("CorpseESP")
			if espGui then
				local label = espGui:FindFirstChild("CorpseDistance")
				if label then label.TextColor3 = Value end
			end
		end
	end
})

CorpseESPSection:AddLabel('Distance Check'):AddSlider({
    Min = 1000,
    Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

local vehiclesFolder = workspace:WaitForChild("Vehicles")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local vehicleESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local vehicleNameColor = Color3.fromRGB(0, 91, 255)
local vehicleDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 12
local fontType = Enum.Font.Code

local espVehicles = {}
local function removeESP(model)
	local espGui = model:FindFirstChild("VehicleESP_GUI")
	if espGui then espGui:Destroy() end
	espVehicles[model] = nil
end

local function createBillboard(model)
	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then return end
	removeESP(model)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "VehicleESP_GUI"
	billboard.Adornee = primary
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local nameLabel
	if showNames then
		nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "VehicleNameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextSize = fontSize
		nameLabel.TextColor3 = vehicleNameColor
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.Font = fontType
		nameLabel.Text = model.Name
		nameLabel.Parent = billboard
	end

	local distanceLabel
	if showDistance then
		distanceLabel = Instance.new("TextLabel")
		distanceLabel.Name = "VehicleDistanceLabel"
		distanceLabel.Size = UDim2.new(1, 0, 0, 20)
		distanceLabel.Position = UDim2.new(0, 0, 0, 16)
		distanceLabel.BackgroundTransparency = 1
		distanceLabel.TextSize = fontSize
		distanceLabel.TextColor3 = vehicleDistanceColor
		distanceLabel.TextStrokeTransparency = 0.5
		distanceLabel.Font = fontType
		distanceLabel.Text = "[...]"
		distanceLabel.Parent = billboard
	end

	espVehicles[model] = {
		model = model,
		primary = primary,
		billboard = billboard,
		nameLabel = nameLabel,
		distanceLabel = distanceLabel
	}
end

local function updateVehicleESP()
	for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
		if vehicle:IsA("Model") then
			if vehicleESPEnabled and (showNames or showDistance) then
				createBillboard(vehicle)
			else
				removeESP(vehicle)
			end
		end
	end
end

vehiclesFolder.ChildAdded:Connect(function(child)
	if vehicleESPEnabled and child:IsA("Model") then
		if showNames or showDistance then
			createBillboard(child)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not vehicleESPEnabled then return end
	local camPos = Camera.CFrame.Position
	for _, data in pairs(espVehicles) do
		local model = data.model
		local primary = data.primary
		if model and model.Parent and primary and primary.Parent then
			local distance = (camPos - primary.Position).Magnitude
			local inRange = distance <= maxDistance
			local transparency = 0
			local fadeStart = maxDistance * 0.9

			if distance >= maxDistance then
				transparency = 1
			elseif distance >= fadeStart then
				transparency = (distance - fadeStart) / (maxDistance * 0.1)
			end

			if data.nameLabel then
				data.nameLabel.Visible = showNames and inRange
				data.nameLabel.TextTransparency = transparency
				data.nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
			end

			if data.distanceLabel then
				data.distanceLabel.Visible = showDistance and inRange
				data.distanceLabel.TextTransparency = transparency
				data.distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
				if inRange then
					data.distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
				end
			end
		else
			removeESP(model)
		end
	end
end)

 vehicleToggle = VehicleESPSection:AddLabel('Vehicle ESP')
vehicleToggle:AddToggle({
    Default = false,
    Flag = "VehicleESP",
	Callback = function(Value)
		vehicleESPEnabled = Value
		updateVehicleESP()
	end
})

 vehicleNameToggle = VehicleESPSection:AddLabel('Show Names')
vehicleNameToggle:AddToggle({
    Default = false,
    Flag = "VehicleName",
	Callback = function(Value)
		showNames = Value
		updateVehicleESP()
	end
})
vehicleNameToggle:AddOption():AddLabel('Name Color'):AddColorPicker({
    Default = vehicleSettings.nameColor,
    Flag = "VehicleNameColor",
	Callback = function(Value)
		vehicleNameColor = Value
		for _, data in pairs(espVehicles) do
			if data.nameLabel then data.nameLabel.TextColor3 = Value end
		end
	end
})

 vehicleDistToggle = VehicleESPSection:AddLabel('Show Distance')
vehicleDistToggle:AddToggle({
    Default = false,
    Flag = "VehicleDistance",
	Callback = function(Value)
		showDistance = Value
		updateVehicleESP()
	end
})
vehicleDistToggle:AddOption():AddLabel('Distance Color'):AddColorPicker({
    Default = vehicleSettings.distanceColor,
    Flag = "VehicleDistanceColor",
	Callback = function(Value)
		vehicleDistanceColor = Value
		for _, data in pairs(espVehicles) do
			if data.distanceLabel then data.distanceLabel.TextColor3 = Value end
		end
	end
})

VehicleESPSection:AddLabel('Distance Check'):AddSlider({
	Text = 'Distance Check',
	Min = 1000,
	Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

local zombiesFolder = workspace:WaitForChild("Zombies")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local zombieESPEnabled = false
local showNames = false
local showDistance = false
local maxDistance = 10000

local zombieNameColor = Color3.fromRGB(135, 90, 90)
local zombieDistanceColor = Color3.fromRGB(255, 255, 255)

local fontSize = 12
local fontType = Enum.Font.Code

local espZombies = {}

local function removeESP(model)
	local espGui = model:FindFirstChild("ZombieESP_GUI")
	if espGui then espGui:Destroy() end
	espZombies[model] = nil
end

local function createBillboard(model)
	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then return end
	removeESP(model)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ZombieESP_GUI"
	billboard.Adornee = primary
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local nameLabel
	if showNames then
		nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "ZombieNameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 0, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextSize = fontSize
		nameLabel.TextColor3 = zombieNameColor
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.Font = fontType
		nameLabel.Text = model.Name
		nameLabel.Parent = billboard
	end

	local distanceLabel
	if showDistance then
		distanceLabel = Instance.new("TextLabel")
		distanceLabel.Name = "ZombieDistanceLabel"
		distanceLabel.Size = UDim2.new(1, 0, 0, 20)
		distanceLabel.Position = UDim2.new(0, 0, 0, 16)
		distanceLabel.BackgroundTransparency = 1
		distanceLabel.TextSize = fontSize
		distanceLabel.TextColor3 = zombieDistanceColor
		distanceLabel.TextStrokeTransparency = 0.5
		distanceLabel.Font = fontType
		distanceLabel.Text = "[...]"
		distanceLabel.Parent = billboard
	end

	espZombies[model] = {
		model = model,
		primary = primary,
		billboard = billboard,
		nameLabel = nameLabel,
		distanceLabel = distanceLabel
	}
end

local function updateZombieESP()
	for _, zombie in pairs(zombiesFolder:GetChildren()) do
		if zombie:IsA("Model") then
			if zombieESPEnabled and (showNames or showDistance) then
				createBillboard(zombie)
			else
				removeESP(zombie)
			end
		end
	end
end

zombiesFolder.ChildAdded:Connect(function(child)
	if zombieESPEnabled and child:IsA("Model") then
		if showNames or showDistance then
			createBillboard(child)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not zombieESPEnabled then return end
	local camPos = Camera.CFrame.Position
	for _, data in pairs(espZombies) do
		local model = data.model
		local primary = data.primary
		if model and model.Parent and primary and primary.Parent then
			local distance = (camPos - primary.Position).Magnitude
			local inRange = distance <= maxDistance
			local transparency = 0
			local fadeStart = maxDistance * 0.9

			if distance >= maxDistance then
				transparency = 1
			elseif distance >= fadeStart then
				transparency = (distance - fadeStart) / (maxDistance * 0.1)
			end

			if data.nameLabel then
				data.nameLabel.Visible = showNames and inRange
				data.nameLabel.TextTransparency = transparency
				data.nameLabel.TextStrokeTransparency = 0.5 + transparency / 2
			end
			if data.distanceLabel then
				data.distanceLabel.Visible = showDistance and inRange
				data.distanceLabel.TextTransparency = transparency
				data.distanceLabel.TextStrokeTransparency = 0.5 + transparency / 2
				if inRange then
					data.distanceLabel.Text = "[" .. tostring(math.floor(distance)) .. "м]"
				end
			end
		else
			removeESP(model)
		end
	end
end)

 zombieToggle = ZombieESPSection:AddLabel('Zombie ESP')
zombieToggle:AddToggle({
    Default = false,
    Flag = "ZombieESP",
	Callback = function(Value)
		zombieESPEnabled = Value
		updateZombieESP()
	end
})

 zombieNameToggle = ZombieESPSection:AddLabel('Show Names')
zombieNameToggle:AddToggle({
    Default = false,
    Flag = "ZombieName",
	Callback = function(Value)
		showNames = Value
		updateZombieESP()
	end
})
zombieNameToggle:AddOption():AddLabel('Name Color'):AddColorPicker({
    Default = zombieESPSettings.nameColor,
    Flag = "ZombieNameColor",
	Callback = function(Value)
		zombieNameColor = Value
		for _, data in pairs(espZombies) do
			if data.nameLabel then data.nameLabel.TextColor3 = Value end
		end
	end
})

 zombieDistToggle = ZombieESPSection:AddLabel('Show Distance')
zombieDistToggle:AddToggle({
    Default = false,
    Flag = "ZombieDistance",
	Callback = function(Value)
		showDistance = Value
		updateZombieESP()
	end
})
zombieDistToggle:AddOption():AddLabel('Distance Color'):AddColorPicker({
    Default = zombieESPSettings.distanceColor,
    Flag = "ZombieDistanceColor",
	Callback = function(Value)
		zombieDistanceColor = Value
		for _, data in pairs(espZombies) do
			if data.distanceLabel then data.distanceLabel.TextColor3 = Value end
		end
	end
})

ZombieESPSection:AddLabel('Distance Check'):AddSlider({
	Text = 'Distance Check',
	Min = 1000,
	Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

-- FOG
 fogToggle = LightingSection:AddLabel('No Fog')
fogToggle:AddToggle({
    Default = false,
    Flag = "NoFog",
    Callback = function(Value)
        fogEnabled = Value
        if Value then
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end
            noFogConnection = RunService.RenderStepped:Connect(function()
                Lighting.FogStart = 9e9
                Lighting.FogEnd = 9e9
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
            Lighting.FogStart = fogStart
            Lighting.FogEnd = fogEnd
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then
                atmosphere.Density = 0.5
                atmosphere.Haze = 0.5
                atmosphere.Glare = 0.5
                atmosphere.Offset = 0.5
            end
        end
    end
})

-- No Shadows
LightingSection:AddLabel('No Shadows'):AddToggle({
    Default = false,
    Flag = "NoShadows",
    Callback = function(Value)
        Lighting.GlobalShadows = not Value
    end
})

-- ==================== CUSTOM AMBIENT ====================
 ambientToggle = LightingSection:AddLabel('Custom Ambient')
 AmbientEnabled = false
 AmbientColor = Color3.fromRGB(127, 127, 127)
 OutdoorAmbientColor = Color3.fromRGB(127, 127, 127)

ambientToggle:AddToggle({
    Default = false,
    Flag = "CustomAmbient",
    Callback = function(Value)
        AmbientEnabled = Value
        if AmbientEnabled then
            Lighting.Ambient = AmbientColor
            Lighting.OutdoorAmbient = OutdoorAmbientColor
        else
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end
})

-- Три крапки для додаткових опцій
 ambientOptions = ambientToggle:AddOption()

-- Перший ColorPicker (Ambient)
ambientOptions:AddLabel('Ambient (Indoor)'):AddColorPicker({
    Default = AmbientColor,
    Flag = "AmbientColor",
    Callback = function(Value)
        AmbientColor = Value
        if AmbientEnabled then
            Lighting.Ambient = AmbientColor
        end
    end
})

-- Другий ColorPicker (Outdoor Ambient)
ambientOptions:AddLabel('Outdoor Ambient'):AddColorPicker({
    Default = OutdoorAmbientColor,
    Flag = "OutdoorAmbientColor",
    Callback = function(Value)
        OutdoorAmbientColor = Value
        if AmbientEnabled then
            Lighting.OutdoorAmbient = OutdoorAmbientColor
        end
    end
})

-- АГРЕСИВНЕ ОНОВЛЕННЯ КОЖЕН КАДР
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    pcall(function()
        if AmbientEnabled then
            -- Примусово встановлюємо значення кожен кадр
            Lighting.Ambient = AmbientColor
            Lighting.OutdoorAmbient = OutdoorAmbientColor
        end
    end)
end)

-- ==================== ATMOSPHERE ====================

-- Custom Technology
 techToggle = LightingSection:AddLabel('Custom Technology')
 TechnologyEnabled = false
 SelectedTechnology = "Voxel"

techToggle:AddToggle({
    Default = false,
    Flag = "CustomTech",
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
techToggle:AddOption():AddLabel('Tech Mode'):AddDropdown({
    Default = 'Voxel',
    Values = {'Voxel', 'ShadowMap', 'Legacy', 'Compatibility', 'Future'},
    Flag = "TechMode",
    Callback = function(Value)
        SelectedTechnology = Value
        if TechnologyEnabled then
            pcall(function()
                Lighting.Technology = Enum.Technology[Value]
            end)
        end
    end
})

-- Custom Time
 timeToggle = LightingSection:AddLabel('Custom Time')
 customTime = 12
 timeConnection = nil
 customTimeEnabled = false

timeToggle:AddToggle({
    Default = false,
    Flag = "CustomTime",
    Callback = function(Value)
        customTimeEnabled = Value
        if Value then
            Lighting.ClockTime = customTime
            if timeConnection then
                timeConnection:Disconnect()
                timeConnection = nil
            end
            timeConnection = RunService.RenderStepped:Connect(function()
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
timeToggle:AddOption():AddLabel('Time'):AddSlider({
    Min = 0,
    Max = 24,
    Default = 12,
    Flag = "CustomTimeValue",
    Callback = function(Value)
        customTime = Value
        if customTimeEnabled then
            Lighting.ClockTime = customTime
        end
    end
})

-- CUSTOM SKYBOX
 skyToggle = LightingSection:AddLabel('Custom Sky')
skyToggle:AddToggle({
    Default = false,
    Flag = "CustomSky",
    Callback = function(Value)
        customSkyEnabled = Value
        if customSkyEnabled then
            SetSkybox(selectedSky)
        else
            ClearSkybox()
        end
    end
})
skyToggle:AddOption():AddLabel('Skybox'):AddDropdown({
    Default = 'Galaxy',
    Values = {
        'Galaxy', 'Galaxy 2', 'Galaxy 3',
        'Saturne', 'Neptune', 'Redshift',
        'Pink Daylights', 'Purple Night',
        'Gray Night', 'Anime Sky'
    },
    Flag = "SkyboxSelect",
    Callback = function(Value)
        selectedSky = Value
        if customSkyEnabled then
            SetSkybox(selectedSky)
        end
    end
})

-- CLOUDS MODS
if clouds then
     cloudsToggle = LightingSection:AddLabel('Clouds')
    cloudsToggle:AddToggle({
        Default = false,
        Flag = "EnableClouds_Toggle",
        Callback = function(Value)
            cloudsEnabled = Value
        end
    })
    
     cloudsOptions = cloudsToggle:AddOption()
    cloudsOptions:AddLabel('Clouds Color'):AddColorPicker({
        Default = cloudColor,
        Flag = "CloudsColor",
        Callback = function(Value)
            cloudColor = Value
        end
    })
    
    cloudsOptions:AddLabel('Clouds Cover'):AddSlider({
        Min = 0,
        Max = 1,
        Default = 0.5,
        Rounding = 2,
        Flag = "CloudsCover_Slider",
        Callback = function(Value)
            cloudCover = Value
        end
    })

    cloudsOptions:AddLabel('Clouds Density'):AddSlider({
        Min = 0,
        Max = 1,
        Default = 0.5,
        Rounding = 2,
        Flag = "CloudsDensity_Slider",
        Callback = function(Value)
            cloudDensity = Value
        end
    })

    cloudsOptions:AddLabel('Modify Clouds'):AddToggle({
        Default = false,
        Flag = "ModifyClouds_Toggle",
        Callback = function(Value)
            cloudFlags.ModifyClouds = Value
        end
    })

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if clouds and cloudFlags.ModifyClouds then
                clouds.Enabled = cloudsEnabled
                clouds.Color = cloudColor
                clouds.Cover = cloudCover
                clouds.Density = cloudDensity
            end
        end)
    end)
else
    LightingSection:AddLabel('Clouds not found')
end

-- COLOR CORRECTION
 colorCorrectionToggle = LightingSection:AddLabel('Color Correction')
colorCorrectionToggle:AddToggle({
    Default = false,
    Flag = "ColorCorrection",
    Callback = function(Value)
        colorCorrectionEnabled = Value
        updateColorCorrection()
    end
})
 colorCorrectionOptions = colorCorrectionToggle:AddOption()
colorCorrectionOptions:AddLabel('Saturation'):AddSlider({
    Min = 0,
    Max = 2,
    Default = 1,
    Rounding = 2,
    Flag = "ColorSaturation",
    Callback = function(Value)
        colorCorrectionSaturation = Value
        updateColorCorrection()
    end
})
colorCorrectionOptions:AddLabel('Contrast'):AddSlider({
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Flag = "ColorContrast",
    Callback = function(Value)
        colorCorrectionContrast = Value
        updateColorCorrection()
    end
})
colorCorrectionOptions:AddLabel('Brightness'):AddSlider({
    Min = 0.2,
    Max = 2,
    Default = 1,
    Rounding = 2,
    Flag = "ColorBrightness",
    Callback = function(Value)
        colorCorrectionBrightness = Value
        updateColorCorrection()
    end
})

-- ==================== BLOOM ЗМІННІ ====================
 bloomEnabled = false
 bloomIntensity = 0.5
 bloomSize = 24
 bloomThreshold = 0.8
 bloomInstance = nil

-- ==================== BLOOM UI ====================
 bloomToggle = LightingSection:AddLabel('Bloom')
bloomToggle:AddToggle({
    Default = false,
    Flag = "Bloom",
    Callback = function(Value)
        bloomEnabled = Value
    end
})
 bloomOptions = bloomToggle:AddOption()
bloomOptions:AddLabel('Intensity'):AddSlider({
    Min = 0,
    Max = 2,
    Default = 0.5,
    Rounding = 2,
    Flag = "BloomIntensity",
    Callback = function(Value)
        bloomIntensity = Value
    end
})
bloomOptions:AddLabel('Size'):AddSlider({
    Min = 0,
    Max = 128,
    Default = 24,
    Rounding = 0,
    Flag = "BloomSize",
    Callback = function(Value)
        bloomSize = Value
    end
})
bloomOptions:AddLabel('Threshold'):AddSlider({
    Min = 0,
    Max = 1,
    Default = 0.8,
    Rounding = 2,
    Flag = "BloomThreshold",
    Callback = function(Value)
        bloomThreshold = Value
    end
})

-- Функція оновлення Bloom
local function updateBloom()
    if not bloomEnabled then 
        if bloomInstance then 
            bloomInstance.Enabled = false 
        end
        return 
    end
    
    pcall(function()
        if not bloomInstance or not bloomInstance.Parent then
            bloomInstance = Lighting:FindFirstChildOfClass("BloomEffect")
            if not bloomInstance then
                bloomInstance = Instance.new("BloomEffect")
                bloomInstance.Parent = Lighting
            end
        end
        
        bloomInstance.Intensity = bloomIntensity
        bloomInstance.Size = bloomSize
        bloomInstance.Threshold = bloomThreshold
        bloomInstance.Enabled = true
    end)
end

-- Постійне оновлення (перевіряємо що RunService існує)
if RunService then
    RunService.RenderStepped:Connect(function()
        updateBloom()
    end)
else
    -- Якщо RunService ще не оголошено, використовуємо Heartbeat
    game:GetService("RunService").RenderStepped:Connect(function()
        updateBloom()
    end)
end

-- ==================== WEATHER (SNOW/RAIN) ====================
 WeatherPart = nil
 GroundPart = nil
 CurrentWeatherType = "None"
 WeatherEnabled = false
 weatherSound = nil

function UpdateWeather()
    -- Видаляємо старі частинки
    if WeatherPart then 
        WeatherPart:Destroy() 
        WeatherPart = nil 
    end
    if GroundPart then 
        GroundPart:Destroy() 
        GroundPart = nil 
    end
    if weatherSound then 
        weatherSound:Destroy() 
        weatherSound = nil 
    end
    
    if not WeatherEnabled or CurrentWeatherType == "None" then return end
    
    -- Створюємо невидиму частинку в камері для частинок зверху
    WeatherPart = Instance.new("Part")
    WeatherPart.Name = "BloxStrike_Weather_Sky"
    WeatherPart.Size = Vector3.new(500, 1, 500)
    WeatherPart.Transparency = 1
    WeatherPart.Anchored = true
    WeatherPart.CanCollide = false
    WeatherPart.Parent = workspace.CurrentCamera
    
    local SkyEmitter = Instance.new("ParticleEmitter")
    SkyEmitter.Parent = WeatherPart
    SkyEmitter.EmissionDirection = Enum.NormalId.Top  -- ЗМІНИВ НА TOP (зверху вниз)
    SkyEmitter.Enabled = true
    
    if CurrentWeatherType == "Rain" then
        -- ДОЩ - ПАДАЄ ЗВЕРХУ ВНИЗ
        SkyEmitter.Texture = "rbxassetid://241868005"
        SkyEmitter.Rate = 15000
        SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
        SkyEmitter.Transparency = NumberSequence.new(0)
        SkyEmitter.Size = NumberSequence.new(0.3, 0.6)
        SkyEmitter.Lifetime = NumberRange.new(1.5, 2)
        SkyEmitter.Speed = NumberRange.new(80, 120)  -- Швидкість вниз
        SkyEmitter.SpreadAngle = Vector2.new(5, 5)  -- Невеликий розкид
        SkyEmitter.Acceleration = Vector3.new(0, -60, 0)  -- Прискорення вниз
        SkyEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
        SkyEmitter.LightEmission = 0.5
        
        -- Бризки на землі
        GroundPart = Instance.new("Part")
        GroundPart.Name = "BloxStrike_Weather_Ground"
        GroundPart.Size = Vector3.new(100, 1, 100)
        GroundPart.Transparency = 1
        GroundPart.Anchored = true
        GroundPart.CanCollide = false
        GroundPart.Parent = workspace.CurrentCamera
        
        local GroundEmitter = Instance.new("ParticleEmitter", GroundPart)
        GroundEmitter.Texture = "rbxassetid://241576804"
        GroundEmitter.Rate = 800
        GroundEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
        GroundEmitter.Size = NumberSequence.new(0.1, 0.2)
        GroundEmitter.Lifetime = NumberRange.new(0.2, 0.4)
        GroundEmitter.Speed = NumberRange.new(1, 3)
        GroundEmitter.SpreadAngle = Vector2.new(180, 180)
        
        -- Звук дощу
        weatherSound = Instance.new("Sound", WeatherPart)
        weatherSound.SoundId = "rbxassetid://3786250088"
        weatherSound.Volume = 6
        weatherSound.Looped = true
        weatherSound.Playing = true
        
    elseif CurrentWeatherType == "Snow" then
        -- СНІГ - ПАДАЄ ПОВІЛЬНО ВНИЗ
        SkyEmitter.Texture = "rbxassetid://241396659"
        SkyEmitter.Rate = 1500
        SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        SkyEmitter.Size = NumberSequence.new(1.5, 2.5)
        SkyEmitter.Transparency = NumberSequence.new(0)
        SkyEmitter.Speed = NumberRange.new(5, 10)  -- Повільно вниз
        SkyEmitter.Lifetime = NumberRange.new(5, 8)
        SkyEmitter.Acceleration = Vector3.new(0, -3, 0)  -- Легке прискорення вниз
        SkyEmitter.SpreadAngle = Vector2.new(30, 30)
        SkyEmitter.LightEmission = 2
        SkyEmitter.Rotation = NumberRange.new(0, 360)
        SkyEmitter.RotSpeed = NumberRange.new(-20, 20)
        
        GroundPart = Instance.new("Part")
        GroundPart.Name = "BloxStrike_Weather_Ground"
        GroundPart.Size = Vector3.new(100, 1, 100)
        GroundPart.Transparency = 1
        GroundPart.Anchored = true
        GroundPart.CanCollide = false
        GroundPart.Parent = workspace.CurrentCamera
        
        local GroundEmitter = Instance.new("ParticleEmitter", GroundPart)
        GroundEmitter.Texture = "rbxassetid://241396659"
        GroundEmitter.Rate = 400
        GroundEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        GroundEmitter.Size = NumberSequence.new(0.5, 1)
        GroundEmitter.Lifetime = NumberRange.new(1, 2)
        GroundEmitter.Speed = NumberRange.new(0, 1)
        GroundEmitter.SpreadAngle = Vector2.new(360, 360)
        
    elseif CurrentWeatherType == "Heavy Snow" then
        -- БАГАТО СНІГУ
        SkyEmitter.Texture = "rbxassetid://241396659"
        SkyEmitter.Rate = 3000
        SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        SkyEmitter.Size = NumberSequence.new(1, 2)
        SkyEmitter.Transparency = NumberSequence.new(0)
        SkyEmitter.Speed = NumberRange.new(4, 8)
        SkyEmitter.Lifetime = NumberRange.new(6, 10)
        SkyEmitter.Acceleration = Vector3.new(0, -2.5, 0)
        SkyEmitter.SpreadAngle = Vector2.new(40, 40)
        SkyEmitter.LightEmission = 1.8
        
        GroundPart = Instance.new("Part")
        GroundPart.Name = "BloxStrike_Weather_Ground"
        GroundPart.Size = Vector3.new(100, 1, 100)
        GroundPart.Transparency = 1
        GroundPart.Anchored = true
        GroundPart.CanCollide = false
        GroundPart.Parent = workspace.CurrentCamera
        
        local GroundEmitter = Instance.new("ParticleEmitter", GroundPart)
        GroundEmitter.Texture = "rbxassetid://241396659"
        GroundEmitter.Rate = 800
        GroundEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        GroundEmitter.Size = NumberSequence.new(0.4, 0.8)
        GroundEmitter.Lifetime = NumberRange.new(1, 2)
        
    elseif CurrentWeatherType == "Hell Fire" then
        -- ВОГОНЬ
        SkyEmitter.Texture = "rbxassetid://242205518"
        SkyEmitter.Rate = 1500
        SkyEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 0, 0))
        SkyEmitter.Size = NumberSequence.new(1, 2)
        SkyEmitter.Transparency = NumberSequence.new(0, 0.5)
        SkyEmitter.Speed = NumberRange.new(40, 70)
        SkyEmitter.Lifetime = NumberRange.new(2, 3.5)
        SkyEmitter.Acceleration = Vector3.new(0, -20, 0)
        SkyEmitter.LightEmission = 3
        SkyEmitter.SpreadAngle = Vector2.new(10, 10)
        
        GroundPart = Instance.new("Part")
        GroundPart.Name = "BloxStrike_Weather_Ground"
        GroundPart.Size = Vector3.new(100, 1, 100)
        GroundPart.Transparency = 1
        GroundPart.Anchored = true
        GroundPart.CanCollide = false
        GroundPart.Parent = workspace.CurrentCamera
        
        local GroundEmitter = Instance.new("ParticleEmitter", GroundPart)
        GroundEmitter.Texture = "rbxassetid://242205518"
        GroundEmitter.Rate = 400
        GroundEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 60, 0), Color3.fromRGB(100, 0, 0))
        GroundEmitter.Size = NumberSequence.new(0.4, 0.8)
    end
    
    if GroundPart then
        GroundPart.Parent = workspace.CurrentCamera
    end
end
-- Додаємо Weather в UI з Toggle та Dropdown
weatherMainToggle = LightingSection:AddLabel('Weather')
weatherMainToggle:AddToggle({
    Default = false,
    Flag = "WeatherEnable",
    Callback = function(Value)
        WeatherEnabled = Value
        UpdateWeather()
    end
})
-- Три крапки для додаткових опцій
weatherOptions = weatherMainToggle:AddOption()

-- Dropdown для вибору типу погоди
weatherOptions:AddLabel('Weather Type'):AddDropdown({
    Default = 'None',
    Values = {'None', 'Snow', 'Heavy Snow', 'Rain', 'Hell Fire'},
    Flag = "WeatherType",
    Callback = function(Value)
        CurrentWeatherType = Value
        if WeatherEnabled then
            UpdateWeather()
        end
    end
})

if RunService then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if WeatherPart and WeatherPart.Parent and workspace.CurrentCamera then
                local CamCF = workspace.CurrentCamera.CFrame
                WeatherPart.CFrame = CamCF * CFrame.new(0, 45, 0)
            end
            if GroundPart and GroundPart.Parent and workspace.CurrentCamera then
                local CamCF = workspace.CurrentCamera.CFrame
                GroundPart.CFrame = CamCF * CFrame.new(0, 0.5, 12)
            end
        end)
    end)
end

-- BULLET TRACER
 tracerToggle = BulletTracerSection:AddLabel('Bullet Tracer')
tracerToggle:AddToggle({
    Default = false,
    Flag = "BulletTracer",
    Callback = function(Value)
        world_utilities.BulletTracer = Value
    end
})
 tracerOptions = tracerToggle:AddOption()
tracerOptions:AddLabel('Tracer Color'):AddColorPicker({
    Default = world_utilities.BulletTracerColor,
    Flag = "TracerColor",
    Callback = function(Value)
        world_utilities.BulletTracerColor = Value
    end
})
tracerOptions:AddLabel('Lifetime'):AddSlider({
    Min = 1,
    Max = 10,
    Default = 3,
    Flag = "TracerLifetime",
    Callback = function(Value)
        world_utilities.BulletTracerLength = Value
    end
})
tracerOptions:AddLabel('Thickness'):AddSlider({
    Min = 0.1,
    Max = 3,
    Default = 1,
    Flag = "TracerThickness",
    Callback = function(Value)
        world_utilities.BulletTracerThickness = Value
    end
})

-- LOCAL PLAYER
-- China Hat
 chinaHatToggle = LocalPlayerSection:AddLabel('China Hat')
chinaHatToggle:AddToggle({
    Default = false,
    Flag = "ChinaHat",
    Callback = function(Value)
        chinaHatEnabled = Value
        
        local char = player.Character
        if not char then return end
        
        if Value then
            createChinaHat(char)
        else
            local hat = char:FindFirstChild("ChinaHat")
            if hat then hat:Destroy() end
        end
    end
})
chinaHatToggle:AddOption():AddLabel('Hat Color'):AddColorPicker({
    Default = chinaHatColor,
    Flag = "ChinaHatColor",
    Callback = function(Value)
        chinaHatColor = Value
        
        local char = player.Character
        if not char then return end
        
        local hat = char:FindFirstChild("ChinaHat")
        if hat then
            local hl = hat:FindFirstChildOfClass("Highlight")
            if hl then
                hl.FillColor = Value
            end
        end
    end
})

-- Self Chams
selfChamsToggle = LocalPlayerSection:AddLabel('Self Chams')
selfChamsToggle:AddToggle({
    Default = false,
    Flag = "SelfChams",
    Callback = function(Value)
        selfChamsSettings.enabled = Value
        local char = player.Character
        if char then
            if selfChamsSettings.enabled then
                applyChams(char)
            else
                clearChams(char)
            end
        end
    end
})
 selfChamsOptions = selfChamsToggle:AddOption()
selfChamsOptions:AddLabel('Chams Color'):AddColorPicker({
    Default = selfChamsSettings.color,
    Flag = "SelfChamsColor",
    Callback = function(Value)
        selfChamsSettings.color = Value
        if selfChamsSettings.enabled and player.Character then
            applyChams(player.Character)
        end
    end
})
selfChamsOptions:AddLabel('Chams Material'):AddDropdown({
    Default = 'ForceField',
    Values = {'ForceField', 'Plastic', 'Wood', 'SmoothPlastic', 'Metal', 'Neon', 'Glass'},
    Flag = "SelfChamsMaterial",
    Callback = function(Value)
        if Value == 'ForceField' then
            selfChamsSettings.material = Enum.Material.ForceField
        elseif Value == 'Plastic' then
            selfChamsSettings.material = Enum.Material.Plastic
        elseif Value == 'Wood' then
            selfChamsSettings.material = Enum.Material.Wood
        elseif Value == 'SmoothPlastic' then
            selfChamsSettings.material = Enum.Material.SmoothPlastic
        elseif Value == 'Metal' then
            selfChamsSettings.material = Enum.Material.Metal
        elseif Value == 'Neon' then
            selfChamsSettings.material = Enum.Material.Neon
        elseif Value == 'Glass' then
            selfChamsSettings.material = Enum.Material.Glass
        end
        if selfChamsSettings.enabled and player.Character then
            applyChams(player.Character)
        end
    end
})

-- Gun Chams
 gunChamsToggle = LocalPlayerSection:AddLabel('Gun Chams')
gunChamsToggle:AddToggle({
    Default = false,
    Flag = "GunChams",
    Callback = function(Value)
        gunChamsSettings.enabled = Value
    end
})
 gunChamsOptions = gunChamsToggle:AddOption()
gunChamsOptions:AddLabel('Gun Color'):AddColorPicker({
    Default = gunChamsSettings.color,
    Flag = "GunChamsColor",
    Callback = function(Value)
        gunChamsSettings.color = Value
    end
})
gunChamsOptions:AddLabel('Gun Material'):AddDropdown({
    Default = 'Plastic',
    Values = {'ForceField', 'Plastic', 'SmoothPlastic', 'Glass', 'Neon'},
    Flag = "GunChamsMaterial",
    Callback = function(Value)
        if Value == 'ForceField' then
            gunChamsSettings.material = Enum.Material.ForceField
        elseif Value == 'Plastic' then
            gunChamsSettings.material = Enum.Material.Plastic
        elseif Value == 'SmoothPlastic' then
            gunChamsSettings.material = Enum.Material.SmoothPlastic
        elseif Value == 'Glass' then
            gunChamsSettings.material = Enum.Material.Glass
        elseif Value == 'Neon' then
            gunChamsSettings.material = Enum.Material.Neon
        end
    end
})

-- CUSTOM CROSSHAIR
 crosshairToggle = CrosshairSection:AddLabel('Crosshair')
crosshairToggle:AddToggle({
    Default = false,
    Flag = "Crosshair",
    Callback = function(Value)
        crosshairSettings.enabled = Value
        UpdateCrosshair()
    end
})
crosshairToggle:AddOption():AddLabel('Color'):AddColorPicker({
    Default = crosshairSettings.color,
    Flag = "CrosshairColor",
    Callback = function(Value)
        crosshairSettings.color = Value
        UpdateCrosshair()
    end
})

CrosshairSection:AddLabel('Spinning'):AddToggle({
    Default = false,
    Flag = "CrosshairSpin",
    Callback = function(Value)
        crosshairSettings.spinning = Value
    end
})

CrosshairSection:AddLabel('Outline'):AddToggle({
    Default = false,
    Flag = "CrosshairOutline",
    Callback = function(Value)
        crosshairSettings.outline = Value
        UpdateCrosshair()
    end
})

CrosshairSection:AddLabel('Size'):AddSlider({
    Min = 8,
    Max = 20,
    Default = 12,
    Flag = "CrosshairSize",
    Callback = function(Value)
        crosshairSettings.size = Value
        UpdateCrosshair()
    end
})

CrosshairSection:AddLabel('Thickness'):AddSlider({
    Min = 1,
    Max = 5,
    Default = 2,
    Flag = "CrosshairThickness",
    Callback = function(Value)
        crosshairSettings.thickness = Value
        UpdateCrosshair()
    end
})

-- MOVEMENT
MovementSection:AddLabel('Double Jump'):AddToggle({
    Default = false,
    Flag = "DoubleJump",
    Callback = function(Value)
        movementFlags.doubleJumpEnabled = Value
    end
})

walkToggle  = MovementSection:AddLabel('Walk Speed')
walkToggle:AddToggle({
    Default = false,
    Flag = "WalkSpeed",
    Callback = function(Value)
        movementFlags.walkEnabled = Value
    end
})
walkToggle:AddOption():AddLabel('Speed'):AddSlider({
    Min = 16,
    Max = 21,
    Default = 16,
    Flag = "WalkSpeedValue",
    Callback = function(Value)
        movementFlags.walkingSpeed = Value
    end
})

runToggle = MovementSection:AddLabel('Run Speed')
runToggle:AddToggle({
    Default = false,
    Flag = "RunSpeed",
    Callback = function(Value)
        movementFlags.runEnabled = Value
    end
})
runToggle:AddOption():AddLabel('Speed'):AddSlider({
    Min = 20,
    Max = 28,
    Default = 20,
    Flag = "RunSpeedValue",
    Callback = function(Value)
        movementFlags.runningSpeed = Value
    end
})

-- ANTI AIM
aaToggle = AntiAimSection:AddLabel('Anti-Aim')
aaToggle:AddToggle({
    Default = false,
    Flag = "AntiAim",
    Callback = function(Value)
        antiAimFlags.enabled = Value
    end
})

AntiAimSection:AddLabel('Perma Spin'):AddToggle({
    Default = false,
    Flag = "PermaSpin",
    Callback = function(Value)
        antiAimFlags.permaSpin = Value
    end
})

AntiAimSection:AddLabel('Spin Speed'):AddSlider({
    Min = 1,
    Max = 20,
    Default = 5,
    Flag = "SpinSpeed",
    Callback = function(Value)
        antiAimFlags.spinSpeed = Value
    end
})

if zombiesFolder then
    ZombieSection:AddLabel('Freeze Zombies'):AddToggle({
        Default = false,
        Flag = "FreezeZombies",
        Callback = function(state)
            isFreezeEnabled = state
            for _, zombie in pairs(zombiesFolder:GetChildren()) do
                if zombie:IsA("Model") then
                    if isFreezeEnabled then
                        freezeZombie(zombie)
                    else
                        unfreezeZombie(zombie)
                    end
                end
            end
        end
    })

    ZombieSection:AddLabel('Zombie Circle'):AddToggle({
        Default = false,
        Flag = "ZombieCircle",
        Callback = function(state)
            zombieCircleEnabled = state
            if state then
                updateZombieCircle()
            end
        end
    })

    ZombieSection:AddLabel('Circle Distance'):AddSlider({
        Min = 5,
        Max = 50,
        Default = 10,
        Flag = "ZombieDistance",
        Callback = function(value)
            zombieCircleDistance = value
        end
    })

    ZombieSection:AddLabel('Circle Speed'):AddSlider({
        Min = 1,
        Max = 20,
        Default = 5,
        Flag = "ZombieSpeed",
        Callback = function(value)
            zombieCircleSpeed = value
        end
    })
else
    ZombieSection:AddLabel('Zombies folder not found')
end

-- ==================== VEHICLE FLY ====================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flyEnabled = false
local targetVehicle = nil
local bodyVelocity = nil
local bodyGyro = nil
local speed = 50
local flyKeybind = "F"

local flyConnection = nil
local heartbeatConnection = nil

-- Змінні для UI
local vehicleFlyToggle = nil
local vehicleFlyToggleCallback = nil

local function getVehicleRoot(veh)
    if not veh or not veh.Parent then return nil end

    if veh.PrimaryPart and veh.PrimaryPart:IsA("BasePart") then
        return veh.PrimaryPart
    end

    for _, part in veh:GetDescendants() do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            if name:find("root") or name:find("main") or name:find("base") or name:find("chassis") or name:find("body") then
                return part
            end
        end
    end

    local bestPart, bestSize = nil, 0
    for _, part in veh:GetDescendants() do
        if part:IsA("BasePart") then
            local sz = part.Size.Magnitude
            if sz > bestSize then
                bestSize = sz
                bestPart = part
            end
        end
    end
    if bestPart then return bestPart end

    for _, part in veh:GetDescendants() do
        if part:IsA("BasePart") then return part end
    end

    return nil
end

local function isPlayerStillInVehicle()
    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent == targetVehicle
    end

    for _, part in char:GetChildren() do
        if part:IsA("VehicleSeat") and part.Parent == targetVehicle then
            return true
        end
    end

    return false
end

local function enableFly(veh)
    if flyEnabled then return true end
    if not veh or not veh.Parent then return false end

    local root = getVehicleRoot(veh)
    if not root then return false end

    targetVehicle = veh

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.P = 1250
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.D = 500
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flyEnabled = true

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled or not targetVehicle or not targetVehicle.Parent then return end

        local root = getVehicleRoot(targetVehicle)
        if not root or not root.Parent then
            task.delay(0.1, disableFly)
            return
        end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.yAxis end

        if moveDir.Magnitude > 0.01 then
            bodyVelocity.Velocity = moveDir.Unit * speed
        else
            bodyVelocity.Velocity = Vector3.zero
        end

        local lookAt = root.Position + cam.CFrame.LookVector * 50
        bodyGyro.CFrame = CFrame.new(root.Position, lookAt)
    end)

    if heartbeatConnection then heartbeatConnection:Disconnect() end
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if flyEnabled and not isPlayerStillInVehicle() then
            task.delay(0.1, function()
                pcall(disableFly)
            end)
        end
    end)

    return true
end

local function disableFly()
    flyEnabled = false
    targetVehicle = nil

    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end

    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    
    -- Оновлюємо стан toggle через callback
    if vehicleFlyToggleCallback then
        vehicleFlyToggleCallback(false)
    end
end

local function toggleFly()
    if flyEnabled then
        disableFly()
        return
    end

    local char = player.Character
    if not char then return end

    local veh = nil

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Parent then
        veh = hum.SeatPart.Parent
    end

    if not veh then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local closestDist = 12
            for _, seat in workspace:GetDescendants() do
                if seat:IsA("VehicleSeat") and seat.Parent then
                    local dist = (hrp.Position - seat.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        veh = seat.Parent
                    end
                end
            end
        end
    end

    if not veh then return end

    enableFly(veh)
    -- Оновлюємо стан toggle через callback
    if vehicleFlyToggleCallback then
        vehicleFlyToggleCallback(true)
    end
end

local function getKeyCodeFromString(keyString)
    local keyMap = {
        ["F"] = Enum.KeyCode.F,
        ["G"] = Enum.KeyCode.G,
        ["H"] = Enum.KeyCode.H,
        ["R"] = Enum.KeyCode.R,
        ["T"] = Enum.KeyCode.T,
        ["Y"] = Enum.KeyCode.Y,
        ["Q"] = Enum.KeyCode.Q,
        ["E"] = Enum.KeyCode.E,
        ["X"] = Enum.KeyCode.X,
        ["C"] = Enum.KeyCode.C,
        ["V"] = Enum.KeyCode.V,
        ["B"] = Enum.KeyCode.B,
        ["LeftShift"] = Enum.KeyCode.LeftShift,
        ["LeftControl"] = Enum.KeyCode.LeftControl,
        ["LeftAlt"] = Enum.KeyCode.LeftAlt,
        ["Space"] = Enum.KeyCode.Space,
        ["None"] = nil,
    }
    return keyMap[keyString] or Enum.KeyCode.F
end

-- Слідкуємо за натисканням клавіші
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local currentKey = getKeyCodeFromString(flyKeybind)
    if currentKey and input.KeyCode == currentKey then
        toggleFly()
    end
end)

-- ==================== UI ДЛЯ ВСТАВКИ В ТВІЙ СКРИПТ ====================
local VehicleFlySection = Misc:AddSection({
    Name = "VEHICLE FLY",
    Position = "Right"
})

-- Основний Toggle (зберігаємо callback)
local flyToggle = VehicleFlySection:AddLabel('Vehicle Fly')
flyToggle:AddToggle({
    Default = false,
    Flag = "VehicleFly",
    Callback = function(Value)
        -- Зберігаємо callback для оновлення з інших місць
        vehicleFlyToggleCallback = function(newValue)
            -- Оновлюємо стан toggle без виклику callback (щоб уникнути циклу)
            if flyToggle and flyToggle.Set then
                flyToggle:Set(newValue)
            end
        end
        
        if Value then
            toggleFly()
        else
            if flyEnabled then
                disableFly()
            end
        end
    end
})

-- Три крапки для налаштувань
local flyOptions = flyToggle:AddOption()

-- Speed Slider (1-80)
flyOptions:AddLabel('Fly Speed'):AddSlider({
    Min = 1,
    Max = 80,
    Default = 50,
    Flag = "VehicleFlySpeed",
    Callback = function(Value)
        speed = Value
    end
})

-- Keybind Picker
flyOptions:AddLabel('Fly Keybind'):AddKeybind({
    Default = 'F',
    Flag = "VehicleFlyKeybind",
    Callback = function(Value)
        if Value == "None" or Value == "" then
            flyKeybind = "F"
        elseif type(Value) == "string" then
            flyKeybind = Value
        elseif type(Value) == "table" and Value.Key then
            flyKeybind = Value.Key
        else
            flyKeybind = tostring(Value)
        end
    end
})

Notification.new({
	Title = "LunarCore",
	Content = "Menu loaded successfully",
	Duration = 3,
})

Logging.new("check",'LunarCore AR2 loaded',3)
