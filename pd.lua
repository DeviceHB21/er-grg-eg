-- =============================================
-- 1. ЗАГРУЗКА БИБЛИОТЕКИ LinoriaLib
-- =============================================
-- LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/refs/heads/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/sashanz/998772/refs/heads/main/2233'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/SaveManager.lua'))()  

-- =============================================
-- 2. НАСТРОЙКИ СБОРКИ
-- =============================================
-- Скрипт: PD зелёный, остальное без изменений
local Build = "paid";
local Ver = "v1.3"

-- =============================================
-- 3. СОЗДАНИЕ ГЛАВНОГО ОКНА
-- =============================================
local Window = Library:CreateWindow({ 
    Size = UDim2.fromOffset(550, 610),
    Title = "LunarCore.xyz |PD| v1.9",  -- Только PD зелёный
    Center = false,
    AutoShow = true
})

-- =============================================
-- 4. СОЗДАНИЕ ВКЛАДОК (TABS)
-- =============================================
local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Обновление цветов

-- Загрузка темы по умолчанию
function ThemeManager:LoadDefault()		
    self:ApplyTheme('Default')
    Options.ThemeManager_ThemeList:SetValue('Default')
end

-- =============================================
-- 5. СОЗДАНИЕ СЕКЦИЙ (ГРУПП)
-- =============================================
-- Вкладка Combat
local AimbotSection = Tabs.Combat:AddLeftGroupbox('Aimbot Settings')
local GunSection = Tabs.Combat:AddRightGroupbox('Gun Settings')

-- Вкладка Visuals
local VisualsSection = Tabs.Visuals:AddLeftGroupbox('Players ESP')
local VisualSection = Tabs.Visuals:AddRightGroupbox('bot ESP')
local OtheSection = Tabs.Visuals:AddLeftGroupbox('Other Esp')
local GuSection = Tabs.Visuals:AddLeftGroupbox('Croshair')
local ArmsSection = Tabs.Visuals:AddRightGroupbox('Arms & Viewmodel')
local WorldSection = Tabs.Visuals:AddRightGroupbox('World')
local SkinsSection = Tabs.Visuals:AddRightGroupbox('Skins Players')

-- Вкладка Misc
local MiscSection = Tabs.Misc:AddLeftGroupbox('Visual Character')
local DesyncSection = Tabs.Misc:AddLeftGroupbox('Desync')
local MisSection = Tabs.Misc:AddRightGroupbox('Character')
local OtherSection = Tabs.Misc:AddLeftGroupbox('Other')
local BotSection = Tabs.Misc:AddRightGroupbox('Bot')

-- =============================================
-- 6. ПОДКЛЮЧЕНИЕ СЕРВИСОВ
-- =============================================
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



do
-- =============================================
-- SILENT AIM + INSTANT HIT + BULLET TRACER (FULL)
-- БЕЗ КОНФЛИКТОВ С GUN SETTINGS
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local GuiInset = game:GetService("GuiService"):GetGuiInset()

-- =============================================
-- ПЕРЕМЕННЫЕ
-- =============================================
local silent_aim = {
	enabled = false, target_ai = false, part = "Head",
	fov = false, fov_show = false, fov_color = Color3.new(1,1,1),
	fov_outline = false, fov_outline_color = Color3.new(0,0,0), fov_size = 100,
	nospread = false, instant = false, target_part = nil, is_npc = false,
	isvisible = false, tracer = false, tracer_color = Color3.new(1,1,1), 
	tracer_texture = "rbxassetid://446111271",
	tracer_size = 0.15,
	tracer_fade = 0.5,
	team_check = false
}

local LastAmmo = nil
local ProjectileCodes = {}
local vischeck_params = RaycastParams.new()
vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
vischeck_params.IgnoreWater = true
local isRapidFiring = false

-- =============================================
-- FOV КРУГИ
-- =============================================
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.Filled = false
fov_circle.Transparency = 1
fov_circle.Visible = false

local fov_circle_outline = Drawing.new("Circle")
fov_circle_outline.Thickness = 3
fov_circle_outline.Filled = false
fov_circle_outline.Visible = false

-- =============================================
-- СОЗДАНИЕ ПАПКИ ДЛЯ ТРАССЕРОВ
-- =============================================
if not Workspace:FindFirstChild("NoCollision") then
	local folder = Instance.new("Folder")
	folder.Name = "NoCollision"
	folder.Parent = Workspace
end

-- =============================================
-- ФУНКЦИЯ СОЗДАНИЯ ТРАССЕРА (НЕ КОНФЛИКТУЕТ)
-- =============================================
local function createTracerWithAnimation(origin, targetPos, color, texture, size, fadeTime)
	local part1 = Instance.new("Part")
	local part2 = Instance.new("Part")
	
	part1.Size = Vector3.new(0.1, 0.1, 0.1)
	part2.Size = Vector3.new(0.1, 0.1, 0.1)
	part1.Transparency = 1
	part2.Transparency = 1
	part1.CanCollide = false
	part2.CanCollide = false
	part1.Anchored = true
	part2.Anchored = true
	part1.Position = origin
	part2.Position = targetPos
	part1.Parent = Workspace.NoCollision
	part2.Parent = Workspace.NoCollision
	
	local att1 = Instance.new("Attachment", part1)
	local att2 = Instance.new("Attachment", part2)
	
	local beam = Instance.new("Beam")
	beam.Attachment0 = att1
	beam.Attachment1 = att2
	beam.Color = ColorSequence.new(color)
	beam.Width0 = size
	beam.Width1 = size
	beam.Texture = texture
	beam.TextureMode = Enum.TextureMode.Static
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Transparency = NumberSequence.new(0)
	beam.Parent = Workspace.NoCollision
	
	-- Плавное исчезновение
	local startTime = tick()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		local alpha = math.clamp(1 - (elapsed / fadeTime), 0, 1)
		beam.Transparency = NumberSequence.new(1 - alpha)
		if elapsed >= fadeTime then
			conn:Disconnect()
			pcall(function()
				part1:Destroy()
				part2:Destroy()
				beam:Destroy()
			end)
		end
	end)
end

-- =============================================
-- ФУНКЦИИ
-- =============================================
local function is_visible(cframe, target, target_part)
	if not (target and target_part and cframe) then return false end
	vischeck_params.FilterDescendantsInstances = { Workspace.NoCollision, Camera, LocalPlayer.Character }
	local ray = Workspace:Raycast(cframe.Position, target_part.Position - cframe.Position, vischeck_params)
	return ray and ray.Instance and ray.Instance:IsDescendantOf(target)
end

local function predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
	local TimeToHit = (Destination - Origin).Magnitude / ProjectileSpeed
	local Predicted = Destination + DestinationVelocity * TimeToHit
	TimeToHit = TimeToHit + ((Predicted - Origin).Magnitude / ProjectileSpeed) / ProjectileSpeed
	return Destination + DestinationVelocity * TimeToHit
end

local function get_closest_target(usefov, fov_size, aimpart, npc)
	local ermm_part, isnpc = nil, false
	local maximum_distance = usefov and fov_size or math.huge
	local mousepos = Vector2.new(Mouse.X, Mouse.Y)
	
	if npc then
		local AiZones = Workspace:FindFirstChild("AiZones")
		if AiZones then
			for _, zone in pairs(AiZones:GetChildren()) do
				for _, npcs in pairs(zone:GetChildren()) do
					local part = npcs:FindFirstChild(aimpart)
					local hum = npcs:FindFirstChildOfClass("Humanoid")
					if part and hum and hum.Health > 0 then
						local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
						local dist = (Vector2.new(pos.X, pos.Y - GuiInset.Y) - mousepos).Magnitude
						if (usefov and onscreen or not usefov) and dist < maximum_distance then
							ermm_part = part
							maximum_distance = dist
							isnpc = true
						end
					end
				end
			end
		end
	end
	
	for _, plr in pairs(Players:GetPlayers()) do
		local char = plr.Character
		if plr ~= LocalPlayer and char then
			local part = char:FindFirstChild(aimpart)
			local hum = char:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
				local dist = (Vector2.new(pos.X, pos.Y - GuiInset.Y) - mousepos).Magnitude
				if (usefov and onscreen or not usefov) and dist <= maximum_distance then
					ermm_part = part
					maximum_distance = dist
					isnpc = false
				end
			end
		end
	end
	
	return ermm_part, isnpc
end

-- =============================================
-- ХУК НА CREATEBULLET (БЕЗ КОНФЛИКТА С RAPID FIRE)
-- =============================================
for _, gc in next, getgc(true) do
	if type(gc) == "table" and rawget(gc, "CreateBullet") then
		local old_bullet = gc.CreateBullet
		gc.CreateBullet = function(self, ...)
			local args = {...}
			
			-- Проверяем что это не вызов от Rapid Fire
			if isRapidFiring then
				return old_bullet(self, unpack(args))
			end
			
			if silent_aim.enabled then
				local loadedammo, aimpart_index
				for i, v in pairs(args) do
					if typeof(v) == "Instance" and v.Name == "AimPart" then
						aimpart_index = i
					end
					if type(v) == "string" then
						local tmp = ReplicatedStorage.AmmoTypes:FindFirstChild(v)
						if tmp then loadedammo = tmp end
					end
				end
				LastAmmo = loadedammo
				
				if silent_aim.tracer and silent_aim.target_part and aimpart_index then
					task.spawn(function()
						createTracerWithAnimation(
							args[aimpart_index].Position,
							silent_aim.target_part.Position,
							silent_aim.tracer_color,
							silent_aim.tracer_texture,
							silent_aim.tracer_size,
							silent_aim.tracer_fade
						)
					end)
				end
				
				if silent_aim.instant or not silent_aim.target_part then
					return old_bullet(self, unpack(args))
				end
				
				if loadedammo and aimpart_index then
					local Origin = Camera.CFrame.Position
					local Destination = predict_velocity(Origin, silent_aim.target_part.Position, silent_aim.target_part.Velocity, loadedammo:GetAttribute("MuzzleVelocity"))
					args[aimpart_index] = { CFrame = CFrame.new(Origin, Destination) }
				end
			end
			return old_bullet(self, unpack(args))
		end
		break
	end
end

-- =============================================
-- ХУК НА METAMETHODS
-- =============================================
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old_namecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	if method == "GetAttribute" then
		local attr = args[1]
		if silent_aim.nospread and attr == "AccuracyDeviation" then
			return 0
		end
		if silent_aim.enabled then
			if attr == "ProjectileDrop" then return 0 end
			if attr == "Drag" then return 0 end
		end
	end
	
	if method == "InvokeServer" and self.Name == "FireProjectile" and silent_aim.enabled and silent_aim.instant and silent_aim.target_part then
		task.spawn(function()
			if LastAmmo then
				ProjectileCodes[args[2]] = {
					Origin = Camera.CFrame.Position,
					Tick = args[3],
					Drag = LastAmmo:GetAttribute("Drag"),
					ProjectileSpeed = LastAmmo:GetAttribute("MuzzleVelocity")
				}
			end
		end)
		return old_namecall(self, unpack(args))
	end
	
	if method == "FireServer" and self.Name == "ProjectileInflict" then
		if debug.traceback() and debug.traceback():find("CharacterController") then
			return coroutine.yield()
		end
		if ProjectileCodes[args[3]] then
			local D = ProjectileCodes[args[3]]
			local Dist = (args[1].Position - D.Origin).Magnitude
			local TTH = Dist / D.ProjectileSpeed
			local HitPos = args[1].Position + (args[1].Velocity * TTH)
			local Delta = (HitPos - args[1].Position).Magnitude
			local Result = D.ProjectileSpeed - D.Drag * D.ProjectileSpeed ^ 2 * TTH ^ 2
			TTH = TTH + (Delta / Result)
			if TTH > 0 then D.Tick = D.Tick + TTH end
			args[4] = D.Tick
		end
		return old_namecall(self, unpack(args))
	end
	
	if method == "Raycast" and silent_aim.enabled and silent_aim.instant and silent_aim.target_part then
		args[2] = (silent_aim.target_part.Position - args[1])
		return old_namecall(self, unpack(args))
	end
	
	return old_namecall(self, ...)
end)
setreadonly(mt, true)

-- =============================================
-- ОСНОВНЫЕ ЦИКЛЫ
-- =============================================
RunService.Heartbeat:Connect(function()
	if silent_aim.enabled then
		silent_aim.target_part, silent_aim.is_npc = get_closest_target(
			silent_aim.fov,
			silent_aim.fov_size,
			silent_aim.part,
			silent_aim.target_ai
		)
		if silent_aim.target_part then
			silent_aim.isvisible = is_visible(Camera.CFrame, silent_aim.target_part.Parent, silent_aim.target_part)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + GuiInset.Y)
	
	fov_circle.Position = mouse_pos
	fov_circle.Radius = silent_aim.fov_size
	fov_circle.Color = silent_aim.fov_color
	fov_circle.Visible = silent_aim.fov and silent_aim.fov_show
	
	fov_circle_outline.Position = mouse_pos
	fov_circle_outline.Radius = silent_aim.fov_size
	fov_circle_outline.Color = silent_aim.fov_outline_color
	fov_circle_outline.Visible = silent_aim.fov and silent_aim.fov_show and silent_aim.fov_outline
end)

-- =============================================
-- UI В AimbotSection
-- =============================================
AimbotSection:AddToggle("SilentAimEnabled", {
	Text = "Enable Silent Aim",
	Default = false,
    Risky = true,
	Callback = function(v) silent_aim.enabled = v end
})

AimbotSection:AddToggle("SilentAimInstant", {
	Text = "Instant Hit",
	Default = false,
    Risky = true,
	Callback = function(v) silent_aim.instant = v end
})

AimbotSection:AddToggle("SilentAimTargetAI", {
	Text = "Target AI",
	Default = false,
	Callback = function(v) silent_aim.target_ai = v end
})

AimbotSection:AddDropdown("SilentAimPart", {
	Text = "Aim Part",
	Values = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
	Default = "Head",
    Risky = true,
	Callback = function(v) silent_aim.part = v end
})

AimbotSection:AddToggle("FOVEnabled", {
	Text = "Enable FOV",
	Default = false,
	Callback = function(v) silent_aim.fov = v end
})

AimbotSection:AddToggle("FOVShow", {
	Text = "Show FOV Circle",
	Default = false,
	Callback = function(v) silent_aim.fov_show = v end
}):AddColorPicker("FOVColor", {
	Text = "FOV Color",
	Default = Color3.new(1, 1, 1),
	Callback = function(c) silent_aim.fov_color = c end
})

AimbotSection:AddSlider("FOVSize", {
	Text = "FOV Size",
	Default = 100,
	Min = 10,
	Max = 500,
	Rounding = 0,
	Callback = function(v) silent_aim.fov_size = v end
})

AimbotSection:AddToggle("TracerEnabled", {
	Text = "Bullet Tracer",
	Default = false,
	Callback = function(v) silent_aim.tracer = v end
}):AddColorPicker("TracerColor", {
	Text = "Tracer Color",
	Default = Color3.new(1, 1, 1),
	Callback = function(c) silent_aim.tracer_color = c end
})

AimbotSection:AddSlider("TracerSize", {
	Text = "Tracer Size",
	Default = 15,
	Min = 5,
	Max = 50,
	Rounding = 0,
	Suffix = "%",
	Callback = function(v) silent_aim.tracer_size = v / 100 end
})

AimbotSection:AddSlider("TracerFadeTime", {
	Text = "Fade Time",
	Default = 0.5,
	Min = 0.1,
	Max = 2,
	Rounding = 1,
	Suffix = "s",
	Callback = function(v) silent_aim.tracer_fade = v end
})
end






-- =============================================
-- 10. ESP НАСТРОЙКИ
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
        NeonChams       = false,
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
-- 11. PLAYER CHAMS (HIGHLIGHT)
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

local function ToTransparency(val)
    return math.clamp(val / 20, 0, 1)
end

local function UpdateHighlight(h)
    h.FillColor = FillColor
    h.OutlineColor = OutlineColor
    h.FillTransparency = ToTransparency(FillTransparencySlider)
    h.OutlineTransparency = ToTransparency(OutlineTransparencySlider)
end

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

-- =============================================
-- 12. UI ЭЛЕМЕНТЫ ESP (VisualsSection)
-- =============================================
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
-- 13. CRATE ESP (OtheSection)
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

OtheSection:AddToggle('CrateESP', {
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
-- 14. DEATH CHAMS (OtheSection)
-- =============================================
local deathSettings = {
    Enabled = false,
    Transparency = 0.5,
    Color = Color3.fromRGB(255, 100, 100),
    Duration = 3,
    Material = "ForceField"
}

OtheSection:AddToggle('DeathChams', {
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

local function playDeathSound(position)
    if not position then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1255040462"
    sound.Volume = 5
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.MaxDistance = 250
    sound.MinDistance = 10
    
    local soundPart = Instance.new("Part")
    soundPart.Anchored = true
    soundPart.CanCollide = false
    soundPart.Transparency = 1
    soundPart.Size = Vector3.new(1, 1, 1)
    soundPart.Position = position
    soundPart.Parent = workspace
    
    sound.Parent = soundPart
    sound:Play()
    
    task.spawn(function()
        task.wait(sound.TimeLength)
        if soundPart and soundPart.Parent then
            soundPart:Destroy()
        end
    end)
end

local function createDeathChams(character, position)
    if not character or not position then return end
    
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
-- 15. ARMS CHAMS (ArmsSection)
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
-- 16. VIEWMODEL OFFSET (ArmsSection)
-- =============================================
do
    local vm_settings = { Enabled = false, Offset = Vector3.new(0, 0, 0) }
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local function getRootPart(model)
        if not model then return nil end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp end
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            end
        end
        return nil
    end

    local function applyOffsetToModel(model)
        if not model or not vm_settings.Enabled then return end
        local rootPart = getRootPart(model)
        if not rootPart then return end
        
        local offset = vm_settings.Offset
        local worldOffset = Camera.CFrame:VectorToWorldSpace(offset)
        rootPart.CFrame = rootPart.CFrame + worldOffset
    end

    local function applyOffsetToAll()
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name == "ViewModel" then
                applyOffsetToModel(child)
            end
        end
    end

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

    Camera.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name == "ViewModel" then
            task.wait(0.05)
            if vm_settings.Enabled then
                applyOffsetToModel(child)
            end
        end
    end)

    task.wait(0.5)
    if vm_settings.Enabled then
        startLoop()
    end
end




-- =============================================
-- 19. GUN SETTINGS (GunSection)
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
    Risky = true,
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
    Risky = true,
    Callback = function(v) gun_settings.NoSpread = v end
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
-- 20. WORLD SETTINGS (WorldSection)
-- =============================================
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChild("Terrain")

local world_settings = {
    Time = { Enabled = false, Value = 14, Original = nil },
    Ambient = { Enabled = false, Color1 = Color3.fromRGB(90,90,90), Color2 = Color3.fromRGB(150,150,150), Original1 = nil, Original2 = nil },
    NoFog = false,
    NoGrass = false,
    NoShadows = false,
    NoLeaves = false,
    Sky = { Enabled = false, Preset = "Galaxy" }
}

world_settings.Time.Original = Lighting.ClockTime
world_settings.Ambient.Original1 = Lighting.Ambient
world_settings.Ambient.Original2 = Lighting.OutdoorAmbient
local original_fog_start = Lighting.FogStart
local original_fog_end = Lighting.FogEnd

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

local function setNoGrass(enable)
    pcall(function()
        sethiddenproperty(Terrain, "Decoration", not enable)
    end)
end

local function ApplyWorldSettings()
    if world_settings.Time.Enabled then
        Lighting.ClockTime = world_settings.Time.Value
    else
        Lighting.ClockTime = world_settings.Time.Original
    end

    if world_settings.Ambient.Enabled then
        Lighting.Ambient = world_settings.Ambient.Color1
        Lighting.OutdoorAmbient = world_settings.Ambient.Color2
    else
        Lighting.Ambient = world_settings.Ambient.Original1
        Lighting.OutdoorAmbient = world_settings.Ambient.Original2
    end

    if world_settings.NoFog then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 100000
    else
        Lighting.FogStart = original_fog_start
        Lighting.FogEnd = original_fog_end
    end

    Lighting.GlobalShadows = not world_settings.NoShadows
    setNoGrass(world_settings.NoGrass)

    if world_settings.NoLeaves then
        setFoliageTransparency(true)
    else
        setFoliageTransparency(false)
    end
end

local function ClearSkybox()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
end

local function DisableCloudsFogAndSun()
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
        Lighting.ClockTime = 10
        DisableCloudsFogAndSun()
        SetSkybox(world_settings.Sky.Preset)
    else
        ClearSkybox()
        Lighting.ClockTime = world_settings.Time.Original
        ApplyWorldSettings()
    end
end

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

WorldSection:AddToggle('NoFog', {
    Text = 'No Fog',
    Default = false,
    Callback = function(v)
        world_settings.NoFog = v
        ApplyWorldSettings()
    end
})

WorldSection:AddToggle('NoGrass', {
    Text = 'No Grass',
    Default = false,
    Callback = function(v)
        world_settings.NoGrass = v
        ApplyWorldSettings()
    end
})

WorldSection:AddToggle('NoShadows', {
    Text = 'No Shadows',
    Default = false,
    Callback = function(v)
        world_settings.NoShadows = v
        ApplyWorldSettings()
    end
})

WorldSection:AddToggle('NoLeaves', {
    Text = 'No Leaves',
    Default = false,
    Callback = function(v)
        world_settings.NoLeaves = v
        ApplyWorldSettings()
    end
})

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

RunService.Heartbeat:Connect(function()
    if world_settings.Time.Enabled then
        Lighting.ClockTime = world_settings.Time.Value
    else
        if Lighting.ClockTime ~= world_settings.Time.Original then
            Lighting.ClockTime = world_settings.Time.Original
        end
    end
    if world_settings.Ambient.Enabled then
        Lighting.Ambient = world_settings.Ambient.Color1
        Lighting.OutdoorAmbient = world_settings.Ambient.Color2
    else
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

task.spawn(function()
    while true do
        task.wait(5)
        if world_settings.NoLeaves then
            setFoliageTransparency(true)
        end
    end
end)

ApplyWorldSettings()
if world_settings.Sky.Enabled then ApplySky() end


-- =============================================
-- 22. FOV ZOOM (OtherSection)
-- =============================================
local fov_settings = {
    Enabled = false,
    Value = 40,
}

local function applyFOV()
    local camera = workspace.CurrentCamera
    if not camera then return end
    if fov_settings.Enabled then
        camera.FieldOfView = fov_settings.Value
    else
        camera.FieldOfView = 70
    end
end

OtherSection:AddToggle('FOVToggle', {
    Text = 'Zoom (FOV)',
    Default = false,
    Callback = function(v)
        fov_settings.Enabled = v
        applyFOV()
    end
})

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

OtherSection:AddSlider('FOVValue', {
    Text = 'Zoom Amount',
    Default = 40,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Suffix = ' deg',
    Callback = function(v)
        fov_settings.Value = v
        if fov_settings.Enabled then
            applyFOV()
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if camera and fov_settings.Enabled then
        if camera.FieldOfView ~= fov_settings.Value then
            camera.FieldOfView = fov_settings.Value
        end
    end
end)

-- =============================================
-- 23. THIRD PERSON (OtherSection)
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
-- 24. SPEED HACK (MisSection)
-- =============================================
local speed_settings = { Enabled = false, Speed = 23 }
local loop_running = false

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

local function startSpeedLoop()
    if loop_running then return end
    loop_running = true

    task.spawn(function()
        while loop_running and speed_settings.Enabled do
            pcall(disableAntiCheat)
            pcall(setSpeed)
            task.wait(0.5)
        end
        loop_running = false
    end)
end

MisSection:AddToggle('SpeedHack', {
    Text = 'Speed Hack',
    Default = false,
    Risky = true,
    Callback = function(v)
        speed_settings.Enabled = v
        if v then
            startSpeedLoop()
        else
            loop_running = false
            pcall(setSpeed)
        end
    end
})

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

LocalPlayer.CharacterAdded:Connect(function()
    loop_running = false
    task.wait(0.5)
    if speed_settings.Enabled then
        startSpeedLoop()
    end
end)

task.wait(1)
if speed_settings.Enabled then
    startSpeedLoop()
end


do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    local UserInputService = game:GetService("UserInputService")

    local playersFolder = ReplicatedStorage:WaitForChild("Players")
    local itemList = ReplicatedStorage:WaitForChild("ItemsList")

    local Settings = {
        Enabled = false,
        FovRadius = 200,
        UpdateDelay = 0.25,
    }

    -- =============================================
    -- НОВОЕ GUI (квадратики 3 в строку)
    -- =============================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "InventoryViewer"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 350, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Active = true

    -- Полоска сверху
    local topBar = Instance.new("Frame")
    topBar.Parent = MainFrame
    topBar.Size = UDim2.new(1, 0, 0, 2)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(116, 62, 249)
    topBar.BorderSizePixel = 0

    -- Область для перетаскивания
    local dragBar = Instance.new("Frame")
    dragBar.Parent = MainFrame
    dragBar.Size = UDim2.new(1, 0, 0, 30)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundTransparency = 1
    dragBar.Active = true

    -- Контент (ScrollingFrame)
    local innerFrame = Instance.new("ScrollingFrame")
    innerFrame.Parent = MainFrame
    innerFrame.Size = UDim2.new(1, -20, 1, -40)
    innerFrame.Position = UDim2.new(0, 10, 0, 35)
    innerFrame.BackgroundTransparency = 1
    innerFrame.ScrollBarThickness = 4
    innerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    innerFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Grid Layout (3 колонки)
    local UIGridLayout = Instance.new("UIGridLayout")
    UIGridLayout.Parent = innerFrame
    UIGridLayout.CellSize = UDim2.new(0, 100, 0, 100)
    UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 8)
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = innerFrame
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 5)

    -- =============================================
    -- ПЕРЕТАСКИВАНИЕ
    -- =============================================
    local dragging = false
    local dragStart = nil
    local startPos = nil

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- =============================================
    -- ЛОГИКА ИНВЕНТАРЯ
    -- =============================================
    local itemFrames = {}
    local lastInventoryHash = nil
    local lastUpdateTime = 0
    local currentTarget = nil
    local isUpdating = false

    local ignoreItems = {
        "KeyChain", "DAGR", "Handcuffs", "Locked", "Unlootable",
        "QuestItem", "EventItem", "SpecialKey", "Wallet", "IDCard"
    }

    local function isIgnored(itemName)
        for _, ignore in ipairs(ignoreItems) do
            if itemName:find(ignore) then
                return true
            end
        end
        return false
    end

    local function getItemIcon(itemName)
        local itemData = itemList:FindFirstChild(itemName)
        if itemData then
            local itemProps = itemData:FindFirstChild("ItemProperties")
            if itemProps then
                local itemIcon = itemProps:FindFirstChild("ItemIcon")
                if itemIcon and itemIcon:IsA("ImageLabel") and itemIcon.Image ~= "" then
                    return itemIcon.Image
                end
            end
        end
        return nil
    end

    local function addItemToGrid(itemName, amount)
        local frame = Instance.new("Frame")
        frame.Parent = innerFrame
        frame.Size = UDim2.new(0, 100, 0, 100)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0

        local iconUrl = getItemIcon(itemName)

        local icon = Instance.new("ImageLabel")
        icon.Parent = frame
        icon.Size = UDim2.new(0, 56, 0, 56)
        icon.Position = UDim2.new(0.5, -28, 0, 8)
        icon.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        icon.BorderSizePixel = 0
        if iconUrl then
            icon.Image = iconUrl
            icon.BackgroundTransparency = 1
        end

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = frame
        nameLabel.Size = UDim2.new(1, -4, 0, 18)
        nameLabel.Position = UDim2.new(0, 2, 1, -22)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = itemName
        nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        nameLabel.TextSize = 10
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextWrapped = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center

        if amount and amount > 1 then
            local amountLabel = Instance.new("TextLabel")
            amountLabel.Parent = frame
            amountLabel.Size = UDim2.new(0, 22, 0, 14)
            amountLabel.Position = UDim2.new(1, -24, 0, 2)
            amountLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            amountLabel.BackgroundTransparency = 0.3
            amountLabel.Text = "x" .. amount
            amountLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            amountLabel.TextSize = 9
            amountLabel.Font = Enum.Font.SourceSansBold
        end

        table.insert(itemFrames, frame)
    end

    local function getInventoryHash(inventory)
        local items = {}
        for _, item in ipairs(inventory:GetChildren()) do
            local itemName = item.Name
            if not isIgnored(itemName) then
                local amount = nil
                local itemProps = item:FindFirstChild("ItemProperties")
                if itemProps then
                    amount = itemProps:GetAttribute("Amount")
                end
                table.insert(items, itemName .. (amount or ""))
            end
        end
        table.sort(items)
        return table.concat(items, "|")
    end

    local function clearInventory()
        for _, frame in pairs(itemFrames) do
            frame:Destroy()
        end
        itemFrames = {}
    end

    local function updateInventoryUI(inventory)
        local items = {}

        for _, item in ipairs(inventory:GetChildren()) do
            local itemName = item.Name
            if not isIgnored(itemName) then
                local amount = nil
                local itemProps = item:FindFirstChild("ItemProperties")
                if itemProps then
                    amount = itemProps:GetAttribute("Amount")
                end
                table.insert(items, {name = itemName, amount = amount})
            end
        end

        if #items ~= #itemFrames then
            clearInventory()
            for _, item in ipairs(items) do
                addItemToGrid(item.name, item.amount)
            end
            return
        end

        for i, item in ipairs(items) do
            local frame = itemFrames[i]
            if frame then
                local icon = frame:FindFirstChildWhichIsA("ImageLabel")
                if icon then
                    local newIcon = getItemIcon(item.name)
                    if newIcon and icon.Image ~= newIcon then
                        icon.Image = newIcon
                    end
                end

                local nameLabel = frame:FindFirstChildWhichIsA("TextLabel")
                if nameLabel and nameLabel.Text ~= item.name then
                    nameLabel.Text = item.name
                end

                local amountLabel = nil
                for _, child in ipairs(frame:GetChildren()) do
                    if child:IsA("TextLabel") and child ~= nameLabel then
                        amountLabel = child
                        break
                    end
                end

                if item.amount and item.amount > 1 then
                    local newText = "x" .. item.amount
                    if amountLabel then
                        if amountLabel.Text ~= newText then
                            amountLabel.Text = newText
                        end
                    else
                        local newAmountLabel = Instance.new("TextLabel")
                        newAmountLabel.Parent = frame
                        newAmountLabel.Size = UDim2.new(0, 22, 0, 14)
                        newAmountLabel.Position = UDim2.new(1, -24, 0, 2)
                        newAmountLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        newAmountLabel.BackgroundTransparency = 0.3
                        newAmountLabel.Text = newText
                        newAmountLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                        newAmountLabel.TextSize = 9
                        newAmountLabel.Font = Enum.Font.SourceSansBold
                    end
                elseif amountLabel then
                    amountLabel:Destroy()
                end
            end
        end
    end

    local function loadInventory(player)
        local playerFolder = playersFolder:FindFirstChild(player.Name)
        if not playerFolder then return end

        local inventory = playerFolder:FindFirstChild("Inventory")
        if not inventory then return end

        local currentHash = getInventoryHash(inventory)
        if currentHash == lastInventoryHash then
            return
        end

        lastInventoryHash = currentHash
        updateInventoryUI(inventory)
    end

    local function get_closest_target_in_fov()
        local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + 36)
        local fov_radius = Settings.FovRadius
        local closest_distance = fov_radius
        local closest_player = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                if humanoid and humanoid.Health > 0 and head then
                    local screen_pos, on_screen = Camera:WorldToViewportPoint(head.Position)
                    if on_screen then
                        local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
                        if distance < closest_distance then
                            closest_distance = distance
                            closest_player = player
                        end
                    end
                end
            end
        end
        return closest_player, closest_player ~= nil
    end

    RunService.RenderStepped:Connect(function()
        if not Settings.Enabled then
            if MainFrame.Visible then
                MainFrame.Visible = false
                currentTarget = nil
                lastInventoryHash = nil
            end
            return
        end

        local targetPlayer, isAiming = get_closest_target_in_fov()
        local currentTime = tick()

        if isAiming and targetPlayer then
            if not MainFrame.Visible then
                MainFrame.Visible = true
            end

            if targetPlayer.Name ~= currentTarget then
                currentTarget = targetPlayer.Name
                lastInventoryHash = nil
                lastUpdateTime = 0
            end

            if currentTime - lastUpdateTime >= Settings.UpdateDelay and not isUpdating then
                lastUpdateTime = currentTime
                loadInventory(targetPlayer)
            end
        else
            if MainFrame.Visible then
                MainFrame.Visible = false
                currentTarget = nil
                lastInventoryHash = nil
            end
        end
    end)

    OtherSection:AddToggle('InventoryChecker', {
        Text = 'Inventory Checker',
        Default = false,
        Callback = function(Value)
            Settings.Enabled = Value
            if not Value then
                MainFrame.Visible = false
                currentTarget = nil
                lastInventoryHash = nil
            end
        end
    })

    OtherSection:AddSlider('InvFovRadius', {
        Text = 'FOV Radius',
        Default = 200,
        Min = 50,
        Max = 500,
        Rounding = 0,
        Suffix = 'px',
        Callback = function(Value)
            Settings.FovRadius = Value
        end
    })

    OtherSection:AddSlider('InvUpdateDelay', {
        Text = 'Update Delay',
        Default = 0.25,
        Min = 0.1,
        Max = 1,
        Rounding = 2,
        Suffix = 's',
        Callback = function(Value)
            Settings.UpdateDelay = Value
        end
    })

    OtherSection:AddSlider('InvPositionX', {
        Text = 'Position X',
        Default = 170,
        Min = 180,
        Max = 200,
        Rounding = 0,
        Suffix = 'px',
        Callback = function(Value)
            MainFrame.Position = UDim2.new(0, Value, 0, MainFrame.Position.Y.Offset)
        end
    })

    OtherSection:AddSlider('InvPositionY', {
        Text = 'Position Y',
        Default = 260,
        Min = 260,
        Max = 700,
        Rounding = 0,
        Suffix = 'px',
        Callback = function(Value)
            MainFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset, 0, Value)
        end
    })
end


-- =============================================
-- 26. FOV CHANGER (OtherSection)
-- =============================================
do
    local fov_settings = { Enabled = false, Value = 90 }
    local defaultFOV = Camera.FieldOfView
    
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
-- 27. VISIBILITY CHECKER (AimbotSection)
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
-- 28. TRACER FOV (AimbotSection)
-- =============================================
local tracer_fov_settings = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.8 }
local TracerLineFOV = Drawing.new("Line")
TracerLineFOV.Thickness = tracer_fov_settings.Thickness
TracerLineFOV.Color = tracer_fov_settings.Color
TracerLineFOV.Transparency = tracer_fov_settings.Transparency
TracerLineFOV.Visible = false

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
-- 29. ANCHORED RESOLVER (MisSection)
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
    Risky = true,
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
-- 30. FLY HACK (MisSection)
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
-- 31. TELEPORT BOT (BotSection)
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

-- =============================================
-- 32. SPIN + LOOK UP (AntiAimSection)
-- =============================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local spinEnabled = false
    local spinSpeed = 90
    local lookUpAngle = -70
    local currentAngle = 0
    local currentCharacter = nil
    local connection = nil

    local function applySpin(character, delta)
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not (humanoid and rootPart) then return end
        if humanoid.Health <= 0 then return end
        
        humanoid.AutoRotate = false
        
        currentAngle = currentAngle + (spinSpeed * delta)
        if currentAngle >= 360 then currentAngle = currentAngle - 360 end
        
        local currentPos = rootPart.Position
        local lookVector = Vector3.new(math.sin(math.rad(currentAngle)), 0, math.cos(math.rad(currentAngle)))
        rootPart.CFrame = CFrame.lookAt(currentPos, currentPos + lookVector)
        
        if head then
            local neck = character:FindFirstChild("Neck", true)
            if neck and neck:IsA("Motor6D") then
                neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(lookUpAngle), 0, 0)
            end
        end
    end

    local function onHeartbeat(delta)
        if not spinEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        if character ~= currentCharacter then
            currentCharacter = character
            task.wait(0.3)
        end
        
        applySpin(character, delta)
    end

    local function setSpinEnabled(value)
        spinEnabled = value
        
        if value then
            if not connection then
                connection = RunService.Heartbeat:Connect(onHeartbeat)
            end
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if currentCharacter then
                local humanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.AutoRotate = true
                end
                local neck = currentCharacter:FindFirstChild("Neck", true)
                if neck then
                    neck.C0 = CFrame.new(0, 1, 0)
                end
            end
        end
    end

    if MisSection then
        MisSection:AddToggle('SpinEnabled', {
            Text = 'Spin',
            Default = false,
            Risky = true,
            Callback = function(v)
                setSpinEnabled(v)
            end
        })
        
        MisSection:AddSlider('SpinSpeed', {
            Text = 'Spin Speed',
            Default = 90,
            Min = 30,
            Max = 2000,
            Rounding = 0,
            Suffix = '°/s',
            Callback = function(v)
                spinSpeed = v
            end
        })
    end
end

-- =============================================
-- 33. UI SETTINGS (Вкладка UI Settings)
-- =============================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

local arrowsEnabled = false

local notifyPlayerChange = function(player, message, color)
    local prefix = "notification - player"
    Library:Notify(("%s | user: %s | %s"):format(prefix, player.DisplayName, message), 5, color)
end

local function startArrows() end
local function stopArrows() end

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

game.Players.PlayerAdded:Connect(function(player)
    if arrowsEnabled then
        notifyPlayerChange(player, "joined", Color3.fromRGB(0, 255, 0))
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if arrowsEnabled then
        notifyPlayerChange(player, "left", Color3.fromRGB(255, 0, 0))
    end
end)

-- =============================================
-- 34. CRATE DISTANCE SLIDER (OtheSection)
-- =============================================
do
    OtheSection:AddSlider('CrateDistance', {
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

-- =============================================
-- 35. VISUALIZE SERVER/STORE (MiscSection)
-- =============================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer

    flags = flags or {}
    flags["tbox"] = false
    flags["color tracer"] = Color3.new(1,1,1)
    flags["tracer transparency"] = 0
    flags["tracer smoothness"] = 0.12

    local OFFSET = 1.8
    local SMOOTHNESS = 0.12
    local TRANSPARENCY = 0

    local visuals = {}
    local renderConn

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

    local function OnToggleChanged(value)
        flags["tbox"] = value
        DisableVisuals()
        if value and LP.Character then
            EnableVisuals(LP.Character)
        end
    end

    local function OnColorChanged(value)
        flags["color tracer"] = value
        UpdateChamColor(value)
    end

    local function OnTransparencyChanged(value)
        flags["tracer transparency"] = value
        TRANSPARENCY = value
        UpdateChamTransparency(value)
    end

    local function OnSmoothnessChanged(value)
        flags["tracer smoothness"] = value
        SMOOTHNESS = value
    end

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

-- =============================================
-- 36. CROSSHAIR (GuSection) - ИСПРАВЛЕННЫЙ
-- =============================================
do
    local crosshair_settings = {
        enabled = false,
        size = 20,
        color = Color3.new(1, 1, 1),
        thickness = 2,
        outline = false,
        outline_color = Color3.new(0, 0, 0),
        outline_thickness = 1,
        dot_enabled = false,
        dot_size = 3,
        dot_color = Color3.new(1, 0, 0),
        spin = false,
        spin_speed = 1,
        style = "cross",
        y_offset = 55
    }

    local crosshair_drawings = {}
    local angle = 0

    local function getMousePosition()
        return Vector2.new(Mouse.X, Mouse.Y + crosshair_settings.y_offset)
    end

    local function createCrosshairLines()
        for _, line in ipairs(crosshair_drawings) do
            pcall(function() line:Remove() end)
        end
        crosshair_drawings = {}
        
        if crosshair_settings.style == "cross" then
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Thickness = crosshair_settings.thickness
                line.Color = crosshair_settings.color
                line.Transparency = 1
                line.Visible = false
                table.insert(crosshair_drawings, line)
            end
        elseif crosshair_settings.style == "t_shape" then
            for i = 1, 3 do
                local line = Drawing.new("Line")
                line.Thickness = crosshair_settings.thickness
                line.Color = crosshair_settings.color
                line.Transparency = 1
                line.Visible = false
                table.insert(crosshair_drawings, line)
            end
        elseif crosshair_settings.style == "dot" then
            local dot = Drawing.new("Circle")
            dot.Filled = true
            dot.Thickness = 0
            dot.NumSides = 20
            dot.Visible = false
            table.insert(crosshair_drawings, dot)
        elseif crosshair_settings.style == "circle" then
            local circle = Drawing.new("Circle")
            circle.Filled = false
            circle.Thickness = crosshair_settings.thickness
            circle.NumSides = 40
            circle.Visible = false
            table.insert(crosshair_drawings, circle)
        end
        
        if crosshair_settings.outline then
            if crosshair_settings.style == "cross" or crosshair_settings.style == "t_shape" then
                for i = 1, #crosshair_drawings do
                    local outline_line = Drawing.new("Line")
                    outline_line.Thickness = crosshair_settings.outline_thickness
                    outline_line.Color = crosshair_settings.outline_color
                    outline_line.Transparency = 1
                    outline_line.Visible = false
                    table.insert(crosshair_drawings, outline_line)
                end
            elseif crosshair_settings.style == "circle" then
                local outline_circle = Drawing.new("Circle")
                outline_circle.Filled = false
                outline_circle.Thickness = crosshair_settings.outline_thickness
                outline_circle.NumSides = 40
                outline_circle.Color = crosshair_settings.outline_color
                outline_circle.Transparency = 1
                outline_circle.Visible = false
                table.insert(crosshair_drawings, outline_circle)
            end
        end
    end

    local function updateCrosshairPosition()
        local mousePos = getMousePosition()
        local centerX, centerY = mousePos.X, mousePos.Y
        
        if crosshair_settings.style == "cross" then
            local size = crosshair_settings.size
            local lines = {}
            local outline_lines = {}
            
            for i, obj in ipairs(crosshair_drawings) do
                if obj and obj.From and obj.To then
                    if crosshair_settings.outline and i > #crosshair_drawings / 2 then
                        table.insert(outline_lines, obj)
                    else
                        table.insert(lines, obj)
                    end
                end
            end
            
            if #lines >= 4 then
                lines[1].From = Vector2.new(centerX, centerY - size)
                lines[1].To = Vector2.new(centerX, centerY - size/3)
                lines[2].From = Vector2.new(centerX, centerY + size)
                lines[2].To = Vector2.new(centerX, centerY + size/3)
                lines[3].From = Vector2.new(centerX - size, centerY)
                lines[3].To = Vector2.new(centerX - size/3, centerY)
                lines[4].From = Vector2.new(centerX + size, centerY)
                lines[4].To = Vector2.new(centerX + size/3, centerY)
            end
            
            if crosshair_settings.outline then
                for i, line in ipairs(outline_lines) do
                    if i <= 4 then
                        if i == 1 then
                            line.From = Vector2.new(centerX, centerY - size)
                            line.To = Vector2.new(centerX, centerY - size/3)
                        elseif i == 2 then
                            line.From = Vector2.new(centerX, centerY + size)
                            line.To = Vector2.new(centerX, centerY + size/3)
                        elseif i == 3 then
                            line.From = Vector2.new(centerX - size, centerY)
                            line.To = Vector2.new(centerX - size/3, centerY)
                        elseif i == 4 then
                            line.From = Vector2.new(centerX + size, centerY)
                            line.To = Vector2.new(centerX + size/3, centerY)
                        end
                    end
                end
            end
            
        elseif crosshair_settings.style == "t_shape" then
            local size = crosshair_settings.size
            local lines = {}
            
            for _, obj in ipairs(crosshair_drawings) do
                if obj and obj.From and obj.To then
                    table.insert(lines, obj)
                end
            end
            
            if #lines >= 3 then
                lines[1].From = Vector2.new(centerX, centerY - size)
                lines[1].To = Vector2.new(centerX, centerY + size/2)
                lines[2].From = Vector2.new(centerX - size/2, centerY + size/2)
                lines[2].To = Vector2.new(centerX, centerY + size/2)
                lines[3].From = Vector2.new(centerX, centerY + size/2)
                lines[3].To = Vector2.new(centerX + size/2, centerY + size/2)
            end
            
        elseif crosshair_settings.style == "dot" then
            for _, obj in ipairs(crosshair_drawings) do
                if obj and obj.Position and obj.Radius then
                    obj.Position = mousePos
                    obj.Radius = crosshair_settings.dot_size
                    obj.Color = crosshair_settings.dot_color
                end
            end
            
        elseif crosshair_settings.style == "circle" then
            for _, obj in ipairs(crosshair_drawings) do
                if obj and obj.Position and obj.Radius then
                    obj.Position = mousePos
                    obj.Radius = crosshair_settings.size
                    obj.Color = crosshair_settings.color
                    obj.Thickness = crosshair_settings.thickness
                end
            end
        end
    end

    local function updateCrosshairVisibility()
        local visible = crosshair_settings.enabled
        for _, obj in ipairs(crosshair_drawings) do
            if obj then
                obj.Visible = visible
            end
        end
    end

    local function updateCrosshairColor()
        for _, obj in ipairs(crosshair_drawings) do
            if obj and obj.Color then
                if not crosshair_settings.outline or obj.Thickness == crosshair_settings.thickness then
                    obj.Color = crosshair_settings.color
                end
            end
        end
    end

    createCrosshairLines()

    RunService.RenderStepped:Connect(function()
        if not crosshair_settings.enabled then
            return
        end
        
        if crosshair_settings.spin and crosshair_settings.style == "cross" then
            angle = angle + math.rad(crosshair_settings.spin_speed)
            local size = crosshair_settings.size
            local mousePos = getMousePosition()
            local centerX, centerY = mousePos.X, mousePos.Y
            
            local lines = {}
            for _, obj in ipairs(crosshair_drawings) do
                if obj and obj.From and obj.To then
                    table.insert(lines, obj)
                end
            end
            
            if #lines >= 4 then
                local angles = {angle, angle + math.pi, angle + math.pi/2, angle - math.pi/2}
                for i = 1, 4 do
                    local rad = angles[i]
                    local x_offset = math.cos(rad) * size
                    local y_offset = math.sin(rad) * size
                    lines[i].From = Vector2.new(centerX, centerY)
                    lines[i].To = Vector2.new(centerX + x_offset, centerY + y_offset)
                end
            end
        else
            updateCrosshairPosition()
        end
    end)

    GuSection:AddToggle('CrosshairEnable', {
        Text = 'Enable Crosshair',
        Default = false,
        Callback = function(v)
            crosshair_settings.enabled = v
            updateCrosshairVisibility()
        end
    })

    GuSection:AddDropdown('CrosshairStyle', {
        Text = 'Crosshair Style',
        Values = {"cross", "t_shape", "dot", "circle"},
        Default = "cross",
        Callback = function(v)
            crosshair_settings.style = v
            createCrosshairLines()
            updateCrosshairVisibility()
            updateCrosshairColor()
        end
    })

    GuSection:AddSlider('CrosshairSize', {
        Text = 'Crosshair Size',
        Default = 20,
        Min = 5,
        Max = 50,
        Rounding = 0,
        Callback = function(v)
            crosshair_settings.size = v
        end
    })

    GuSection:AddSlider('CrosshairThickness', {
        Text = 'Thickness',
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 0,
        Callback = function(v)
            crosshair_settings.thickness = v
            createCrosshairLines()
            updateCrosshairVisibility()
            updateCrosshairColor()
        end
    })

    -- ИСПРАВЛЕНИЕ: ColorPicker с правильным диапазоном
    local colorPickerToggle = GuSection:AddToggle('CrosshairColorToggle', {
        Text = 'Crosshair Color',
        Default = true,
        Callback = function(v) end
    })

    colorPickerToggle:AddColorPicker('CrosshairColor', {
        Default = Color3.new(1, 1, 1),
        Title = 'Pick Color',
        Callback = function(v)
            -- Принудительно зажимаем значения в диапазон [0, 1]
            crosshair_settings.color = Color3.new(
                math.clamp(v.R, 0, 1),
                math.clamp(v.G, 0, 1),
                math.clamp(v.B, 0, 1)
            )
            updateCrosshairColor()
        end
    })

    GuSection:AddToggle('CrosshairOutline', {
        Text = 'Enable Outline',
        Default = false,
        Callback = function(v)
            crosshair_settings.outline = v
            createCrosshairLines()
            updateCrosshairVisibility()
        end
    })

    local outlinePickerToggle = GuSection:AddToggle('CrosshairOutlineColorToggle', {
        Text = 'Outline Color',
        Default = true,
        Callback = function(v) end
    })

    outlinePickerToggle:AddColorPicker('CrosshairOutlineColor', {
        Default = Color3.new(0, 0, 0),
        Title = 'Pick Outline Color',
        Callback = function(v)
            -- Принудительно зажимаем значения в диапазон [0, 1]
            crosshair_settings.outline_color = Color3.new(
                math.clamp(v.R, 0, 1),
                math.clamp(v.G, 0, 1),
                math.clamp(v.B, 0, 1)
            )
            createCrosshairLines()
            updateCrosshairVisibility()
        end
    })

    GuSection:AddToggle('CrosshairSpin', {
        Text = 'Spin Crosshair',
        Default = false,
        Callback = function(v)
            crosshair_settings.spin = v
            if not v then
                angle = 0
            end
        end
    })

    GuSection:AddSlider('CrosshairSpinSpeed', {
        Text = 'Spin Speed',
        Default = 1,
        Min = 0.5,
        Max = 10,
        Rounding = 1,
        Callback = function(v)
            crosshair_settings.spin_speed = v
        end
    })
end

-- =============================================
-- 37. BOT ESP (VisualSection)
-- =============================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local CoreGui = game:GetService("CoreGui")

    local BotCheat = {
        Toggles = {
            Enabled         = false,
            Box             = false,
            Name            = false,
            Distance        = false,
            HPBar           = false,
            HPText          = false,
        },
        Colors = {
            BoxMain  = Color3.fromRGB(255, 50, 50),
            Name     = Color3.new(1, 1, 1),
            Distance = Color3.new(1, 1, 1),
            HealthText = Color3.new(1, 1, 1),
            HealthGradientStart = Color3.fromRGB(255, 50, 50),
            HealthGradientMid   = Color3.fromRGB(255, 100, 0),
            HealthGradientEnd   = Color3.fromRGB(255, 0, 0),
            HealthMask = Color3.new(0, 0, 0),
            HealthMaskTransparency = 0.3,
        },
        Boxes = {},
    }

    local BotGui = Instance.new("ScreenGui")
    BotGui.DisplayOrder = 9e9
    BotGui.ResetOnSpawn = false
    BotGui.Parent = gethui and gethui() or CoreGui
    BotGui.Enabled = false

    local function getAllBots()
        local bots = {}
        local aiZones = Workspace:FindFirstChild("AiZones")
        
        if aiZones then
            for _, zone in pairs(aiZones:GetChildren()) do
                for _, bot in pairs(zone:GetChildren()) do
                    if bot:IsA("Model") and bot:FindFirstChildOfClass("Humanoid") then
                        table.insert(bots, bot)
                    end
                end
            end
        end
        return bots
    end

    local function CleanupBot(bot)
        if BotCheat.Boxes[bot] then
            for _, obj in pairs(BotCheat.Boxes[bot]) do
                if typeof(obj) == "Instance" then 
                    obj:Destroy()
                end
            end
            BotCheat.Boxes[bot] = nil
        end
    end

    local function CreateBotBox()
        local box = {}
        local names = {"Outer", "Main", "Inner"}
        for i = 1, 3 do
            local frame = Instance.new("Frame")
            frame.Name = names[i]
            frame.BackgroundTransparency = 1
            frame.Parent = BotGui
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Parent = frame
            box[names[i]] = frame
            box[names[i] .. "Stroke"] = stroke
        end

        box.OuterStroke.Color = Color3.new(0, 0, 0)
        box.MainStroke.Color  = BotCheat.Colors.BoxMain
        box.InnerStroke.Color = Color3.new(0, 0, 0)

        local healthBg = Instance.new("Frame")
        healthBg.Name = "HealthBg"
        healthBg.BackgroundTransparency = 0
        healthBg.BorderSizePixel = 0
        healthBg.Parent = BotGui
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Parent = healthBg

        local function UpdateGradient()
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   BotCheat.Colors.HealthGradientStart),
                ColorSequenceKeypoint.new(0.5, BotCheat.Colors.HealthGradientMid),
                ColorSequenceKeypoint.new(1,   BotCheat.Colors.HealthGradientEnd)
            })
        end
        UpdateGradient()
        box.UpdateGradient = UpdateGradient

        local healthMask = Instance.new("Frame")
        healthMask.Name = "HealthMask"
        healthMask.BackgroundColor3 = BotCheat.Colors.HealthMask
        healthMask.BackgroundTransparency = BotCheat.Colors.HealthMaskTransparency
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
        nameLabel.Parent = BotGui
        nameLabel.TextColor3 = BotCheat.Colors.Name

        local healthText = Instance.new("TextLabel")
        healthText.Name = "HealthText"
        healthText.BackgroundTransparency = 1
        healthText.Text = ""
        healthText.TextSize = 10
        healthText.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        healthText.TextStrokeTransparency = 0
        healthText.TextStrokeColor3 = Color3.new(0,0,0)
        healthText.TextXAlignment = Enum.TextXAlignment.Right
        healthText.Parent = BotGui
        healthText.TextColor3 = BotCheat.Colors.HealthText

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = ""
        distanceLabel.TextSize = 12
        distanceLabel.FontFace = Font.fromEnum(Enum.Font.SourceSans)
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.new(0,0,0)
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        distanceLabel.Parent = BotGui
        distanceLabel.TextColor3 = BotCheat.Colors.Distance

        box.HealthBg    = healthBg
        box.HealthMask  = healthMask
        box.NameLabel   = nameLabel
        box.HealthText  = healthText
        box.DistanceLabel = distanceLabel

        return box
    end

    local function SetBotBoxVisible(esp, visible)
        if not esp then return end
        esp.Outer.Visible = visible
        esp.Main.Visible  = visible
        esp.Inner.Visible = visible
    end

    local function UpdateBotLoop()
        while task.wait() do
            if not BotCheat.Toggles.Enabled then
                if BotGui.Enabled then BotGui.Enabled = false end
                for _, esp in pairs(BotCheat.Boxes) do
                    if esp then
                        for _, line in pairs(esp) do
                            if line and typeof(line) == "Instance" then
                                line.Visible = false
                            end
                        end
                    end
                end
                continue
            end

            BotGui.Enabled = true

            local lpChar = LocalPlayer.Character
            local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
            
            if not lpRoot then continue end

            local bots = getAllBots()
            local processedBots = {}

            for _, bot in pairs(bots) do
                local hum = bot:FindFirstChildOfClass("Humanoid")
                local root = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
                
                if not root or not hum or hum.Health <= 0 then
                    if BotCheat.Boxes[bot] then CleanupBot(bot) end
                    continue
                end

                processedBots[bot] = true
                
                local esp = BotCheat.Boxes[bot]
                
                local cframe, size = bot:GetBoundingBox()
                if not cframe then
                    if esp then CleanupBot(bot) end
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
                        esp = CreateBotBox() 
                        BotCheat.Boxes[bot] = esp 
                    end

                    SetBotBoxVisible(esp, true)

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

                    if BotCheat.Toggles.Name then
                        esp.NameLabel.Text = bot.Name
                        esp.NameLabel.Position = UDim2.fromOffset(left - 1, yOffset)
                        esp.NameLabel.Size = UDim2.fromOffset(width + 2, 12)
                        esp.NameLabel.Visible = true
                        yOffset = yOffset - 14
                    else
                        esp.NameLabel.Visible = false
                    end

                    local bottomYOffset = bottom + 2

                    if BotCheat.Toggles.Distance and lpRoot then
                        local distInStuds = (lpRoot.Position - root.Position).Magnitude
                        local distInMeters = math.floor(distInStuds * 0.28)
                        esp.DistanceLabel.Text = distInMeters .. "м [BOT]"
                        esp.DistanceLabel.Position = UDim2.fromOffset(left - 1, bottomYOffset)
                        esp.DistanceLabel.Size = UDim2.fromOffset(width + 2, 12)
                        esp.DistanceLabel.Visible = true
                        bottomYOffset = bottomYOffset + 14
                    else
                        esp.DistanceLabel.Visible = false
                    end

                    if BotCheat.Toggles.HPBar or BotCheat.Toggles.HPText then
                        local healthPct = hum.Health / hum.MaxHealth
                        local healthValue = math.floor(hum.Health)

                        if esp.VisualHealth == nil then esp.VisualHealth = healthPct end
                        esp.VisualHealth = esp.VisualHealth + (healthPct - esp.VisualHealth) * 0.1

                        esp.HealthText.Text = tostring(healthValue)
                        local healthBarWidth = 2
                        local maskHeight = totalBoxHeight * (1 - esp.VisualHealth)
                        local healthTextY = boxTopY + maskHeight + 3 - (esp.HealthText.Size.Y.Offset / 2)

                        esp.HealthText.Position = UDim2.fromOffset(left - healthBarWidth - 30, healthTextY)
                        esp.HealthText.Size = UDim2.fromOffset(18, 10)
                        esp.HealthText.Visible = BotCheat.Toggles.HPText

                        esp.HealthBg.Position = UDim2.fromOffset(left - healthBarWidth - 6, boxTopY)
                        esp.HealthBg.Size = UDim2.fromOffset(healthBarWidth, totalBoxHeight)
                        esp.HealthMask.Position = UDim2.fromOffset(0, 0)
                        esp.HealthMask.Size = UDim2.fromOffset(healthBarWidth, maskHeight)

                        esp.HealthBg.Visible = BotCheat.Toggles.HPBar
                    else
                        esp.HealthBg.Visible = false
                        esp.HealthText.Visible = false
                    end

                    esp.Outer.Visible = BotCheat.Toggles.Box
                    esp.Main.Visible  = BotCheat.Toggles.Box
                    esp.Inner.Visible = BotCheat.Toggles.Box

                else
                    if esp then
                        SetBotBoxVisible(esp, false)
                        esp.DistanceLabel.Visible = false
                        esp.NameLabel.Visible     = false
                        esp.HealthText.Visible    = false
                        esp.HealthBg.Visible      = false
                    end
                end
            end

            for bot, esp in pairs(BotCheat.Boxes) do
                if not processedBots[bot] then
                    CleanupBot(bot)
                end
            end
        end
    end

    coroutine.wrap(UpdateBotLoop)()

    VisualSection:AddToggle('BotESPEnabled', {
        Text = 'Enable Bot ESP (AiZones)',
        Default = false,
        Callback = function(Value)
            BotCheat.Toggles.Enabled = Value
        end
    })

    VisualSection:AddToggle('BotBoxESP', {
        Text = 'Bot Box ESP',
        Default = false,
        Callback = function(Value) 
            BotCheat.Toggles.Box = Value 
        end
    }):AddColorPicker('BotBoxColor', {
        Default = Color3.fromRGB(255, 255, 255),
        Title = 'Bot Box Color',
        Callback = function(Value)
            BotCheat.Colors.BoxMain = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.MainStroke then 
                    esp.MainStroke.Color = Value 
                end
            end
        end
    })

    VisualSection:AddToggle('BotNameESP', {
        Text = 'Bot Name ESP',
        Default = false,
        Callback = function(Value) 
            BotCheat.Toggles.Name = Value 
        end
    }):AddColorPicker('BotNameColor', {
        Default = Color3.new(255,255,255),
        Title = 'Bot Name Color',
        Callback = function(Value)
            BotCheat.Colors.Name = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.NameLabel then 
                    esp.NameLabel.TextColor3 = Value 
                end
            end
        end
    })

    VisualSection:AddToggle('BotDistanceESP', {
        Text = 'Bot Distance ESP',
        Default = false,
        Callback = function(Value) 
            BotCheat.Toggles.Distance = Value 
        end
    }):AddColorPicker('BotDistanceColor', {
        Default = Color3.new(255, 255, 255),
        Title = 'Bot Distance Color',
        Callback = function(Value)
            BotCheat.Colors.Distance = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.DistanceLabel then 
                    esp.DistanceLabel.TextColor3 = Value 
                end
            end
        end
    })

    VisualSection:AddToggle('BotHPText', {
        Text = 'Bot HP Text',
        Default = false,
        Callback = function(Value) 
            BotCheat.Toggles.HPText = Value 
        end
    }):AddColorPicker('BotHPTextColor', {
        Default = Color3.new(255, 255, 255),
        Title = 'Bot HP Text Color',
        Callback = function(Value)
            BotCheat.Colors.HealthText = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.HealthText then 
                    esp.HealthText.TextColor3 = Value 
                end
            end
        end
    })

    VisualSection:AddToggle('BotHPBar', {
        Text = 'Bot HP Bar',
        Default = false,
        Callback = function(Value) 
            BotCheat.Toggles.HPBar = Value 
        end
    }):AddColorPicker('BotHPBarStart', {
        Default = Color3.fromRGB(255, 255, 255),
        Title = 'Bot HP Bar Start',
        Callback = function(Value)
            BotCheat.Colors.HealthGradientStart = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.UpdateGradient then 
                    esp.UpdateGradient() 
                end
            end
        end
    }):AddColorPicker('BotHPBarMid', {
        Default = Color3.fromRGB(255, 255,255),
        Title = 'Bot HP Bar Mid',
        Callback = function(Value)
            BotCheat.Colors.HealthGradientMid = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.UpdateGradient then 
                    esp.UpdateGradient() 
                end
            end
        end
    }):AddColorPicker('BotHPBarEnd', {
        Default = Color3.fromRGB(255, 255, 255),
        Title = 'Bot HP Bar End',
        Callback = function(Value)
            BotCheat.Colors.HealthGradientEnd = Value
            for _, esp in pairs(BotCheat.Boxes) do
                if esp and esp.UpdateGradient then 
                    esp.UpdateGradient() 
                end
            end
        end
    })
end

-- =============================================
-- 38. EXIT ESP + CORPSE ESP (OtheSection)
-- =============================================
do
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local exitEspEnabled = false
    local exitEspColor = Color3.fromRGB(0, 255, 0)
    local activeLabels = {}

    local function createExitESP(part)
        local textLabel = Drawing.new("Text")
        textLabel.Visible = false
        textLabel.Color = exitEspColor
        textLabel.Text = "EXIT"
        textLabel.Size = 18
        textLabel.Center = true
        textLabel.Outline = true
        textLabel.OutlineColor = Color3.new(0, 0, 0)
        textLabel.Font = 2
        activeLabels[textLabel] = true

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not exitEspEnabled or not part or not part:IsDescendantOf(Workspace) then
                textLabel.Visible = false
                if not part or not part:IsDescendantOf(Workspace) then
                    textLabel:Remove()
                    activeLabels[textLabel] = nil
                    connection:Disconnect()
                end
                return
            end

            local vector, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                textLabel.Position = Vector2.new(vector.X, vector.Y)
                textLabel.Visible = true
            else
                textLabel.Visible = false
            end
        end)
    end

    local function findExtractionPoints()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("extract") or name:find("exit") or name:find("exfil") then
                    createExitESP(obj)
                end
            end
        end
    end

    findExtractionPoints()
    Workspace.DescendantAdded:Connect(function(obj)
        if (obj:IsA("Part") or obj:IsA("MeshPart")) then
            local name = obj.Name:lower()
            if name:find("extract") or name:find("exit") or name:find("exfil") then
                createExitESP(obj)
            end
        end
    end)

    local corpseEspEnabled = false
    local corpseEspColor = Color3.new(1,1,1)
    local corpseEspTextSize = 14
    local corpseEspMaxDistance = 500

    local espCache = {}
    local lastCleanup = 0
    local cleanupInterval = 30
    local lastScan = 0
    local scanInterval = 0.5

    local function updateAllCorpseESP()
        for _, espGui in pairs(espCache) do
            if espGui and espGui.Parent then
                local text = espGui:FindFirstChildOfClass("TextLabel")
                if text then
                    text.TextColor3 = corpseEspColor
                    text.TextSize = corpseEspTextSize
                end
            end
        end
    end

    local function cleanupCorpseESP()
        local currentTime = tick()
        if currentTime - lastCleanup < cleanupInterval then return end
        lastCleanup = currentTime
        for obj, espGui in pairs(espCache) do
            if not obj or not obj.Parent or not espGui or not espGui.Parent then
                espCache[obj] = nil
            end
        end
    end

    local function createCorpseESP(obj)
        if not corpseEspEnabled then return end
        if espCache[obj] then return end

        local player = LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
            if root then
                local dist = (player.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if dist > corpseEspMaxDistance then return end
            end
        end

        local bg = Instance.new("BillboardGui")
        local text = Instance.new("TextLabel")
        local stroke = Instance.new("UIStroke")

        bg.Name = "CorpseESP"
        bg.Adornee = obj
        bg.Size = UDim2.new(0, 100, 0, 25)
        bg.AlwaysOnTop = true
        bg.StudsOffset = Vector3.new(0, 2.2, 0)
        bg.Parent = obj

        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "DEAD"
        text.TextColor3 = corpseEspColor
        text.TextScaled = false
        text.TextSize = corpseEspTextSize
        text.Font = Enum.Font.GothamBold
        text.Parent = bg

        stroke.Color = Color3.new(0,0,0)
        stroke.Thickness = 1.5
        stroke.Parent = text

        espCache[obj] = bg
    end

    RunService.Heartbeat:Connect(function()
        if not corpseEspEnabled then return end

        local currentTime = tick()
        if currentTime - lastScan < scanInterval then
            cleanupCorpseESP()
            return
        end
        lastScan = currentTime

        local found = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if found > 50 then break end
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if name:find("corpse") or name:find("ragdoll") or name:find("dead") then
                    pcall(function() createCorpseESP(obj) end)
                    found = found + 1
                else
                    local hum = obj:FindFirstChild("Humanoid")
                    if hum and hum.Health <= 0 and hum.Health > -math.huge then
                        pcall(function() createCorpseESP(obj) end)
                        found = found + 1
                    end
                end
            end
        end
    end)

    OtheSection:AddToggle('exit_esp_toggle', {
        Text = 'Exit ESP',
        Default = false,
        Callback = function(v)
            exitEspEnabled = v
            if not v then
                for label, _ in pairs(activeLabels) do
                    pcall(function() label.Visible = false end)
                end
            end
        end
    }):AddColorPicker('exit_esp_color', {
        Default = Color3.fromRGB(0, 255, 0),
        Title = 'Exit ESP Color',
        Transparency = 0,
        Callback = function(c)
            exitEspColor = c
            for label, _ in pairs(activeLabels) do
                label.Color = exitEspColor
            end
        end
    })

    OtheSection:AddToggle('corpse_esp_toggle', {
        Text = 'Corpse ESP',
        Default = false,
        Callback = function(v)
            corpseEspEnabled = v
            if not v then
                for obj, espGui in pairs(espCache) do
                    if espGui and espGui.Parent then
                        pcall(function() espGui:Destroy() end)
                    end
                end
                espCache = {}
            end
        end
    }):AddColorPicker('corpse_esp_color', {
        Default = Color3.new(1,1,1),
        Title = 'Corpse ESP Color',
        Transparency = 0,
        Callback = function(c)
            corpseEspColor = c
            updateAllCorpseESP()
        end
    })

    OtheSection:AddSlider('corpse_esp_distance', {
        Text = 'Corpse Max Distance',
        Default = 500,
        Min = 50,
        Max = 2000,
        Rounding = 0,
        Callback = function(v)
            corpseEspMaxDistance = v
        end
    })

    OtheSection:AddSlider('corpse_esp_textsize', {
        Text = 'Corpse Text Size',
        Default = 14,
        Min = 8,
        Max = 30,
        Rounding = 0,
        Callback = function(v)
            corpseEspTextSize = v
            updateAllCorpseESP()
        end
    })

    OtheSection:AddButton('Unlock Boss', function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ReplicatedPlayer = ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name)
        if ReplicatedPlayer then
            local Boss = ReplicatedPlayer.Status.Journey.Quests:FindFirstChild("BossFirst")
            if not Boss then
                local NewBoss = Instance.new("Folder")
                NewBoss.Name = "BossFirst"
                NewBoss:SetAttribute("State", "Complete")
                NewBoss.Parent = ReplicatedPlayer.Status.Journey.Quests
            else
                Boss:SetAttribute("State", "Complete")
            end
        end
    end)
end

-- =============================================
-- PLAYER STATS GUI (UI Settings) С FOV
-- =============================================
do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    local GuiInset = game:GetService("GuiService"):GetGuiInset()

    local guiEnabled = true
    local fovRadius = 200

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerStatsGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 90)
    frame.Position = UDim2.new(0.5, -150, 0.97, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0
    frame.Active = true
    frame.Draggable = true
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screenGui

    -- Только верхняя полоска (цвет #743ef9)
    local topLine = Instance.new("Frame")
    topLine.Parent = frame
    topLine.Size = UDim2.new(1, 0, 0, 2)
    topLine.Position = UDim2.new(0, 0, 0, 0)
    topLine.BackgroundColor3 = Color3.fromRGB(116, 62, 249)
    topLine.BorderSizePixel = 0

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(0, 55, 0, 55)
    imageLabel.Position = UDim2.new(0.13, -27, 0, 16)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 120)
    textLabel.Position = UDim2.new(0, 90, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = false
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.RichText = true
    textLabel.Parent = frame

    local function getPlayerKDR(player)
        if player == LocalPlayer then
            return "---"
        end
        
        local stats = player:FindFirstChild("leaderstats")
        if stats then
            local kills = stats:FindFirstChild("Kills") or stats:FindFirstChild("kills")
            local deaths = stats:FindFirstChild("Deaths") or stats:FindFirstChild("deaths")
            
            if kills and deaths then
                local killValue = kills.Value
                local deathValue = deaths.Value
                if deathValue == 0 then
                    return killValue > 0 and tostring(killValue) or "0"
                else
                    return math.floor((killValue / deathValue) * 100) / 100
                end
            end
        end
        return "N/A"
    end

    local function isPlayerVisible(player)
        if player == LocalPlayer then
            return false
        end
        
        local character = player.Character
        if not character then
            return false
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return false
        end
        
        local cameraPosition = Camera.CFrame.Position
        local playerPosition = humanoidRootPart.Position
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
        
        local raycastResult = workspace:Raycast(cameraPosition, (playerPosition - cameraPosition), raycastParams)
        
        if raycastResult then
            local distanceToPlayer = (raycastResult.Position - playerPosition).Magnitude
            return distanceToPlayer < 3
        end
        
        return true
    end

    local function getPlayerVisorInfo(player)
        if player == LocalPlayer then
            return "---", Color3.new(1, 1, 1)
        end
        
        local character = player.Character
        local visible = isPlayerVisible(player)
        
        local color = visible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        local status = visible and "Visible" or "Hidden"
        
        if character then
            local visor = character:FindFirstChild("Visor") or character:FindFirstChild("Gear") or character:FindFirstChild("Tool")
            if visor then
                return visor.Name .. " (" .. status .. ")", color
            end
        end
        
        return " (" .. status .. ")", color
    end

    local function colorText(text, color)
        local hex = string.format("#%02x%02x%02x", color.R * 255, color.G * 255, color.B * 255)
        return "<font color='" .. hex .. "'>" .. text .. "</font>"
    end

    -- =============================================
    -- ФУНКЦИЯ ПРОВЕРКИ В FOV
    -- =============================================
    local function isPlayerInFOV(player)
        if player == LocalPlayer then return false end
        
        local character = player.Character
        if not character then return false end
        
        local head = character:FindFirstChild("Head")
        if not head then return false end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        
        local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + GuiInset.Y)
        local screen_pos, on_screen = Camera:WorldToViewportPoint(head.Position)
        
        if not on_screen then return false end
        
        local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
        
        return distance <= fovRadius
    end

    -- =============================================
    -- ПОЛУЧЕНИЕ БЛИЖАЙШЕГО ИГРОКА В FOV
    -- =============================================
    local function getClosestPlayerInFOV()
        local closest_player = nil
        local closest_distance = fovRadius
        local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + GuiInset.Y)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if head and humanoid and humanoid.Health > 0 then
                    local screen_pos, on_screen = Camera:WorldToViewportPoint(head.Position)
                    if on_screen then
                        local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
                        if distance < closest_distance then
                            closest_distance = distance
                            closest_player = player
                        end
                    end
                end
            end
        end
        
        return closest_player
    end

    local function updatePlayerInfo(targetPlayer)
        if not guiEnabled then
            frame.Visible = false
            return
        end
        
        if not targetPlayer or targetPlayer == LocalPlayer then
            frame.Visible = false
            return
        end
        
        if not isPlayerInFOV(targetPlayer) then
            frame.Visible = false
            return
        end
        
        local userId = targetPlayer.UserId
        imageLabel.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
        
        local kdr = getPlayerKDR(targetPlayer)
        local visorText, visorColor = getPlayerVisorInfo(targetPlayer)
        local coloredVisor = colorText(visorText, visorColor)
        
        textLabel.Text = "Name: " .. targetPlayer.Name .. "\nKDR: " .. kdr .. "\nVisor: " .. coloredVisor
        
        frame.Visible = true
    end

    -- =============================================
    -- FOV КРУГ
    -- =============================================
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1
    fov_circle.Filled = false
    fov_circle.Color = Color3.fromRGB(116, 62, 249)
    fov_circle.Transparency = 0
    fov_circle.Radius = fovRadius
    fov_circle.Visible = false
    fov_circle.ZIndex = 100

    local fov_show = false

    -- =============================================
    -- ОСНОВНОЙ ЦИКЛ
    -- =============================================
    game:GetService("RunService").RenderStepped:Connect(function()
        if fov_show then
            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y + GuiInset.Y)
            fov_circle.Position = mouse_pos
            fov_circle.Visible = true
        else
            fov_circle.Visible = false
        end
        
        if guiEnabled then
            local targetPlayer = getClosestPlayerInFOV()
            updatePlayerInfo(targetPlayer)
        end
    end)

    -- =============================================
    -- UI ЭЛЕМЕНТЫ (UI Settings)
    -- =============================================
    MenuGroup:AddToggle('ArrowsToggle', {
        Text = 'Target GUI',
        Default = true,
        Callback = function(v)
            guiEnabled = v
            if not guiEnabled then
                frame.Visible = false
            end
        end
    })

    MenuGroup:AddToggle('ShowFOVCircle', {
        Text = 'Show FOV Circle',
        Default = false,
        Callback = function(v)
            fov_show = v
        end
    })
end

-- ============================================
-- DESYNC С НАСТРОЙКАМИ + БИНД
-- ============================================
do
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- ПЕРЕМЕННЫЕ
    local desyncEnabled = false
    local customDesyncEnabled = false
    local offsetX = 0
    local offsetY = 0
    local offsetZ = -2.5
    local desyncT = {enabled = false, loc = CFrame.new()}
    local prevLookVector = nil
    local isSpinning = false
    local spinThreshold = 15
    local desyncHook = nil
    
    -- ПОЛУЧАЕМ ОФФСЕТ
    local function getOffset()
        if customDesyncEnabled then
            return CFrame.new(offsetX, offsetY, offsetZ)
        else
            local ping = LocalPlayer:GetNetworkPing() * 1000
            if ping < 100 then return CFrame.new(0, 0, -2)
            elseif ping <= 170 then return CFrame.new(0, 0, -2.7)
            else return CFrame.new(0, 0, -3.7) end
        end
    end
    
    -- ФУНКЦИЯ ВКЛЮЧЕНИЯ/ВЫКЛЮЧЕНИЯ
    local function setDesyncEnabled(value)
        desyncEnabled = value
        desyncT.enabled = value
        print("[Desync] " .. (value and "ON" or "OFF"))
        
        -- Если выключили, восстанавливаем нормальное положение
        if not value and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and desyncT.loc then
                root.CFrame = desyncT.loc
            end
        end
    end
    
    -- ОСНОВНОЙ ЦИКЛ
    RunService.Heartbeat:Connect(function()
        if not desyncEnabled or not LocalPlayer.Character then return end
        
        local character = LocalPlayer.Character
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local currentLook = root.CFrame.LookVector
        if prevLookVector then
            local dot = math.clamp(prevLookVector:Dot(currentLook), -1, 1)
            local angleDiff = math.deg(math.acos(dot))
            isSpinning = angleDiff > spinThreshold
        end
        prevLookVector = currentLook
        
        if isSpinning then return end
        
        desyncT.loc = root.CFrame
        local offset = getOffset()
        local newCFrame = desyncT.loc * offset
        root.CFrame = newCFrame
        
        RunService.RenderStepped:Wait()
        root.CFrame = desyncT.loc
    end)
    
    -- ХУК
    desyncHook = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if desyncEnabled and not checkcaller() and 
           key == "CFrame" and 
           LocalPlayer.Character and 
           self == LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
           not isSpinning then
            return desyncT.loc
        end
        return desyncHook(self, key)
    end))
    
    -- ПЕРЕЗАГРУЗКА ПЕРСОНАЖА
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        prevLookVector = nil
        isSpinning = false
    end)
    
    -- ========== UI НАСТРОЙКИ ==========
    
    -- ГЛАВНЫЙ ТОГЛ (СВЯЗАН С БИНДОМ)
    local desyncToggle = DesyncSection:AddToggle('DesyncEnabled', {
        Text = 'Desync Enabled',
        Default = false,
        Callback = function(v)
            setDesyncEnabled(v)
        end
    })
    
    -- КЛАВИША ДЛЯ ТОГЛА (БИНД)
    DesyncSection:AddLabel('Keybind'):AddKeyPicker('DesyncKeybind', {
        Default = 'C',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Desync Keybind',
        NoUI = false,
        Callback = function(value)
            -- Синхронизируем состояние тогла с биндом
            desyncToggle:SetValue(value)
            setDesyncEnabled(value)
        end
    })
    
    -- КАСТОМНЫЙ РЕЖИМ
    DesyncSection:AddToggle('CustomDesync', {
        Text = 'Custom Offset Mode',
        Default = false,
        Callback = function(v)
            customDesyncEnabled = v
        end
    })
    
    -- СЛАЙДЕР X
    DesyncSection:AddSlider('OffsetX', {
        Text = 'Offset X',
        Default = 0,
        Min = -10,
        Max = 10,
        Rounding = 1,
        Compact = false
    }):OnChanged(function(v)
        offsetX = v
    end)
    
    -- СЛАЙДЕР Y
    DesyncSection:AddSlider('OffsetY', {
        Text = 'Offset Y',
        Default = 0,
        Min = -10,
        Max = 10,
        Rounding = 1,
        Compact = false
    }):OnChanged(function(v)
        offsetY = v
    end)
    
    -- СЛАЙДЕР Z
    DesyncSection:AddSlider('OffsetZ', {
        Text = 'Offset Z',
        Default = -2.5,
        Min = -10,
        Max = 10,
        Rounding = 1,
        Compact = false
    }):OnChanged(function(v)
        offsetZ = v
    end)
end



-- =============================================
-- 40. ФИНАЛЬНЫЕ НАСТРОЙКИ БИБЛИОТЕКИ
-- =============================================
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('LunarCore')
SaveManager:SetFolder('LunarCore/ProjectDelta')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- =============================================
-- 41. УВЕДОМЛЕНИЯ
-- =============================================
Library:Notify('LunarCore.xyz | Project Delta v1.3 Loaded!', 5)
Library:Notify(("Welcome thank you for using [LunarCore.xyz] - "..game.Players.LocalPlayer.Name.." 👋"), 6)
Library:Notify(("Status: 🟢 - Undetected (Safe to use)"), 6)

-- =============================================
-- 42. ВОДЯНОЙ ЗНАК
-- =============================================
Library:SetWatermarkVisibility(true)

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

    Library:SetWatermark(('LunarCore.xyz |PD| v1.3 |A| Game id:7336302630 | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

-- =============================================
-- 43. ПОКАЗ ОКНА КЛЮЧЕЙ
-- =============================================
Library.KeybindFrame.Visible = true
