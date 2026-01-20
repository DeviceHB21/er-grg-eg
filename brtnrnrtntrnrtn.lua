-- New example script written by wally
-- You can suggest changes with a pull request or something

local repo = 'https://github.com/DeviceHB21/Custom-Liblinoria/tree/main'

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/denlib.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeviceHB21/Custom-Liblinoria/refs/heads/main/addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'NexusVision | AR2 | v2.1',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

    local MovementBox = Tabs.Misc:AddLeftGroupbox('Movement')

task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

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
    }

    local antiAimFlags = {enabled = false, spinSpeed = 5, permaSpin = false}
		 
    MovementBox:AddToggle('WalkToggle', {
        Text = 'Walking Speed',
        Default = false,
        Callback = function(Value)
            movementFlags.walkEnabled = Value
        end
    })

    MovementBox:AddSlider('WalkSpeedSlider', {
        Text = 'Walking Speed',
        Min = 16,
        Max = 21,
        Default = 16,
        Rounding = 0,
        Callback = function(Value)
            movementFlags.walkingSpeed = Value
        end
    })

    MovementBox:AddToggle('RunToggle', {
        Text = 'Running Speed',
        Default = false,
        Callback = function(Value)
            movementFlags.runEnabled = Value
        end
    })

    MovementBox:AddSlider('RunSpeedSlider', {
        Text = 'Running Speed',
        Min = 20,
        Max = 30,
        Default = 20,
        Rounding = 0,
        Callback = function(Value)
            movementFlags.runningSpeed = Value
        end
    })
		
    local CharBox = Tabs.Misc:AddLeftGroupbox('Character')

    CharBox:AddToggle('NoSprint_Toggle', {
        Text = 'No Sprint Penalty',
        Default = false,
        Callback = function(Value)
            movementFlags.noSprintPenalty = Value
        end
    })

    CharBox:AddToggle('AntiDebuff_Toggle', {
        Text = 'Anti Debuff',
        Default = false,
        Callback = function(Value)
            movementFlags.antiDebuffEnabled = Value
        end
    })

    CharBox:AddToggle('NoRagdoll_Toggle', {
        Text = 'No Ragdoll',
        Default = false,
        Callback = function(Value)
            movementFlags.noRagdollEnabled = Value
        end
    })

    CharBox:AddToggle('InfJump_Toggle', {
        Text = 'Infinite Jump',
        Default = false,
        Callback = function(Value)
            movementFlags.infJumpEnabled = Value
        end
    })

    CharBox:AddSlider('InfJumpPower_Slider', {
        Text = 'Jump Power',
        Min = 10,
        Max = 100,
        Default = 50,
        Rounding = 0,
        Callback = function(Value)
            movementFlags.infJumpPower = Value
        end
    })

    CharBox:AddToggle('NoFall_Toggle', {
        Text = 'No Fall Speed',
        Default = false,
        Callback = function(Value)
            movementFlags.noFallEnabled = Value
        end
    })

    CharBox:AddSlider('NoFallSpeed_Slider', {
        Text = 'Fall Speed Limit',
        Min = 0,
        Max = 50,
        Default = 0,
        Rounding = 0,
        Callback = function(Value)
            movementFlags.noFallSpeed = Value
        end
    })

    local AntiAimBox = Tabs.Misc:AddRightGroupbox('Anti Aim')

    AntiAimBox:AddToggle('AntiAim_Toggle', {
        Text = 'Enable Anti-Aim',
        Default = false,
        Callback = function(Value)
            antiAimFlags.enabled = Value
        end
    })

    AntiAimBox:AddToggle('PermaSpin_Toggle', {
        Text = 'Perma Spin',
        Default = false,
        Callback = function(Value)
            antiAimFlags.permaSpin = Value
        end
    })

    AntiAimBox:AddSlider('SpinSpeed_Slider', {
        Text = 'Spin Speed',
        Min = 1,
        Max = 20,
        Default = 5,
        Rounding = 0,
        Callback = function(Value)
            antiAimFlags.spinSpeed = Value
        end
    })

    UserInputService.InputBegan:Connect(function(Input, gpe)
        if gpe then return end
        if Input.KeyCode == Enum.KeyCode.LeftShift then
            movementFlags.isRunning = true
        elseif Input.KeyCode == Enum.KeyCode.Space and movementFlags.infJumpEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, movementFlags.infJumpPower, hrp.Velocity.Z)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(Input, gpe)
        if gpe then return end
        if Input.KeyCode == Enum.KeyCode.LeftShift then
            movementFlags.isRunning = false
        end
    end)

    RunService.Heartbeat:Connect(function()
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

        if movementFlags.noFallEnabled then
            local vel = hrp.Velocity
            if vel.Y < -movementFlags.noFallSpeed then
                hrp.Velocity = Vector3.new(vel.X, -movementFlags.noFallSpeed, vel.Z)
            end
		end
				
        if movementFlags.noRagdollEnabled and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        if movementFlags.noSprintPenalty then
            hum.WalkSpeed = math.max(hum.WalkSpeed, movementFlags.runningSpeed)
        end

        if movementFlags.antiDebuffEnabled then
            for _, child in ipairs(hum:GetChildren()) do
                if (child:IsA("BoolValue") or child:IsA("NumberValue")) and
                   (child.Name:lower():find("debuff") or child.Name:lower():find("slow")) then
                    child:Destroy()
                end
            end
        end
    end)

    local angle = 0
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and antiAimFlags.enabled then
            angle += math.rad(antiAimFlags.spinSpeed)
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
        end
    end)
end)

    local LeftGroupBox = Tabs.Misc:AddRightGroupbox('Zombie')

task.spawn(function()
    local Players = game:GetService("Players")
    local workspace = game:GetService("Workspace")

    local zombiesFolder
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") and obj.Name:lower():find("zombie") then
            zombiesFolder = obj
            warn("", obj.Name)
            break
        end
    end

    if not zombiesFolder then
        warn("")
        return
    end

    local function freezeZombie(zombie)
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
    end

    local function unfreezeZombie(zombie)
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
    end

    LeftGroupBox:AddToggle('FreezeZombies_Toggle', {
        Text = 'Freeze Zombies',
        Default = false,
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

    local zombieCircleEnabled = false
    local zombieCircleDistance = 10
    local zombieCircleSpeed = 5

    local function makeZombiesCircle()
        task.spawn(function()
            while zombieCircleEnabled do
                local localPlayer = Players.LocalPlayer
                local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

                if rootPart then
                    local count = #zombiesFolder:GetChildren()
                    local angleStep = math.pi * 2 / math.max(count, 1)

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

                task.wait()
            end
        end)
    end

    LeftGroupBox:AddToggle('ZombieCircle_Toggle', {
        Text = 'Zombie Circle',
        Default = false,
        Callback = function(state)
            zombieCircleEnabled = state
            if state then
                makeZombiesCircle()
            end
        end
    })

    LeftGroupBox:AddSlider('ZombieDistance_Slider', {
        Text = 'Circle Distance',
        Min = 5,
        Max = 50,
        Default = 10,
        Rounding = 0,
        Callback = function(value)
            zombieCircleDistance = value
        end
    })

    LeftGroupBox:AddSlider('ZombieSpeed_Slider', {
        Text = 'Circle Speed',
        Min = 1,
        Max = 20,
        Default = 5,
        Rounding = 0,
        Callback = function(value)
            zombieCircleSpeed = value
        end
    })
end)

    local Game = Tabs.Misc:AddRightGroupbox('Game')

-- Функція FPS Rate
local function FPSRate(cap)
    if setfpscap then
        setfpscap(cap)
    elseif setfpslimit then
        setfpslimit(cap)
    end
end
Game:AddToggle("UnlockFPS", {
    Text = "Unlock FPS",
    Default = false,

    Callback = function(state)
        if state then
            FPSRate(999)  
        else
            FPSRate(60) 
        end
    end
})

    local Misc = Tabs.Misc:AddRightGroupbox('Misc')

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Framework = require(ReplicatedFirst:WaitForChild("Framework"))
Framework:WaitForLoaded()

Misc:AddButton({
    Text = "Bring Loot To Inventory",
    DoubleClick = false,
    Func = function()
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local value = rawget(v, "Id")
                if value ~= nil and rawget(v, "ClassName") == "Interactable" and tostring(rawget(v, "Adornee")) == "Model" then
                    local newid = string.sub(value, 37)
                    Framework.Libraries.Network:Send("Client Interacted", value, false, newid)
                end
            end
        end
    end
})

Misc:AddButton({
    Text = "Bring Loot To Ground",
    DoubleClick = false,
    Func = function()
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local value = rawget(v, "Id")
                if value ~= nil and rawget(v, "ClassName") == "Interactable" and tostring(rawget(v, "Adornee")) == "Model" then
                    local newid = string.sub(value, 37)
                    Framework.Libraries.Network:Send("Client Interacted", value, false, newid)
                    Framework.Libraries.Network:Send("Inventory Drop Item", newid)
                end
            end
        end
    end
})

Misc:AddButton({
    Text = "Open All Containers",
    DoubleClick = false,
    Func = function()
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local value = rawget(v, "Id")
                if value ~= nil and rawget(v, "ClassName") == "Entity" and rawget(v, "Type") == "Loot Group" then
                    Framework.Libraries.Network:Send("Client Interacted", value)
                end
            end
        end
    end
})

task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local UIS = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    local Framework = require(ReplicatedFirst.Framework)
    local Wrapper = getupvalue(getupvalue(Framework.require, 1), 1)
    local Bullets = Wrapper.Libraries.Bullets

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
        NoSpreadEnabled = false,
        SpreadScale = 0,     
        NoRecoilEnabled = false,
        RecoilScale = 0.1,  
        SnapLine = false,
        SnapLineColor = Color3.fromRGB(255,255,255),
        SnapLineThickness = 2,
        SnapLineOutline = false,
        SnapLineOutlineTransparency = 0.9,
        FOVEnabled = true,
        FOVColor = Color3.fromRGB(0,255,0),
        FOVRadius = 150,
        FOVThickness = 2,
        FOVFill = false,
        FOVDynamic = false,
        FOVOutline = true
    }

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
                local dist3D = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
                    and (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude or math.huge
                if dist3D > maxDistance then continue end
                local dist2D = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist2D > Settings.FOVRadius then continue end
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

    local GetSpreadAngle = getupvalue(Bullets.Fire, 1)
    local GetFireImpulse = getupvalue(Bullets.Fire, 6)

    setupvalue(Bullets.Fire, 1, function(Character, CCamera, Weapon, ...)
        if Settings.NoSpreadEnabled then
            local OldMoveState = Character.MoveState
            local OldZooming = Character.Zooming
            local OldFirstPerson = CCamera.FirstPerson
            Character.MoveState = "Walking"
            Character.Zooming = true
            CCamera.FirstPerson = true
            local ReturnArgs = {GetSpreadAngle(Character, CCamera, Weapon, ...)}
            Character.MoveState = OldMoveState
            Character.Zooming = OldZooming
            CCamera.FirstPerson = OldFirstPerson
            return unpack(ReturnArgs) * Settings.SpreadScale
        end
        return GetSpreadAngle(Character, CCamera, Weapon, ...)
    end)

    setupvalue(Bullets.Fire, 6, function(...)
        local impulse = {GetFireImpulse(...)}
        if Settings.NoRecoilEnabled then
            for i = 1, #impulse do
                impulse[i] = impulse[i] * Settings.RecoilScale
            end
        end
        return unpack(impulse)
    end)

    local oldFire
    oldFire = hookfunction(Bullets.Fire, function(w, c, _, g, origin, dir, ...)
        if not Settings.SilentEnabled then
            return oldFire(w, c, _, g, origin, dir, ...)
        end
        local target = GetClosestPlayer(Settings.SilentTargetType, Settings.SilentTargetHitbox, Settings.SilentMaxDistance)
        if target and math.random(1, 100) <= Settings.SilentHitChance then
            local part = target:FindFirstChild(Settings.SilentTargetHitbox) or target:FindFirstChild("Head")
            if part then
                dir = (part.Position - origin).Unit
            end
        end
        return oldFire(w, c, _, g, origin, dir, ...)
    end)

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Settings.AimbotHoldKey then Holding = true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Settings.AimbotHoldKey then Holding = false end
    end)

    RunService.RenderStepped:Connect(function()
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

    local Box = Tabs.Combat:AddLeftGroupbox('Aim Bot')
    Box:AddToggle('Aimbot_Toggle', {Text = 'Enable Aimbot', Default = false, Callback = function(v) Settings.AimbotEnabled = v end})
    Box:AddToggle('DistanceCheck_Toggle', {Text = 'Aimbot Distance Check', Default = false, Callback = function(v) Settings.AimbotDistanceCheck = v end})
    Box:AddSlider('MaxDist_Slider', {Text = 'Aimbot Max Distance', Min = 100, Max = 3000, Default = 1500, Rounding = 1, Callback = function(v) Settings.AimbotMaxDistance = v end})
    Box:AddSlider('Smooth_Slider', {Text = 'Smoothness', Min = 0.1, Max = 2, Default = 0.5, Rounding = 1, Callback = function(v) Settings.AimbotSmoothing = v end})
    Box:AddDropdown('Aimbot_Type', {Text = 'Aimbot Target Type', Default = 'Closest To Mouse', Values = {'Closest To Mouse', 'Closest To Player'}, Callback = function(v) Settings.AimbotTargetType = v end})
    Box:AddDropdown('Aimbot_Hitbox', {Text = 'Aimbot Hitbox', Default = 'Head', Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'}, Callback = function(v) Settings.AimbotTargetHitbox = v end})

    local SilentAimBox = Tabs.Combat:AddLeftGroupbox('Silent Aim')
    SilentAimBox:AddToggle('Silent_Toggle', {Text = 'Enable Silent Aim', Default = false, Callback = function(v) Settings.SilentEnabled = v end})
    SilentAimBox:AddSlider('HitChance_Slider', {Text = 'Hit Chance', Min = 1, Max = 100, Default = 100, Rounding = 1, Callback = function(v) Settings.SilentHitChance = v end})
    SilentAimBox:AddSlider('MaxDistance_Slider', {Text = 'Max Distance', Min = 100, Max = 3000, Default = 2000, Rounding = 1, Callback = function(v) Settings.SilentMaxDistance = v end})
    SilentAimBox:AddDropdown('Silent_Type', {Text = 'Silent Target Type', Default = 'Closest To Mouse', Values = {'Closest To Mouse', 'Closest To Player'}, Callback = function(v) Settings.SilentTargetType = v end})
    SilentAimBox:AddDropdown('Silent_Hitbox', {Text = 'Silent Hitbox', Default = 'Head', Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'}, Callback = function(v) Settings.SilentTargetHitbox = v end})

    local FOVBox = Tabs.Combat:AddRightGroupbox('FOV')
    FOVBox:AddToggle('FOV_Toggle', {Text = 'Enable FOV', Default = true, Callback = function(v) Settings.FOVEnabled = v end}):AddColorPicker('FOVColor', {Default = Settings.FOVColor, Callback = function(c) Settings.FOVColor = c end})
    FOVBox:AddToggle('FOVOutline_Toggle', {Text = 'FOV Outline', Default = true, Callback = function(v) Settings.FOVOutline = v end})
    FOVBox:AddSlider('FOVRadius_Slider', {Text = 'Field of View', Min = 50, Max = 500, Default = 150, Rounding = 1,Callback = function(v) Settings.FOVRadius = v end})
    FOVBox:AddSlider('FOVThickness_Slider', {Text = 'Circle Thickness', Min = 1, Max = 5, Default = 2, Rounding = 1, Callback = function(v) Settings.FOVThickness = v end})

    local SnapBox = Tabs.Combat:AddRightGroupbox('Snap Line')
    SnapBox:AddToggle('SnapLine_Toggle', {Text = 'Snap Line', Default = false, Callback = function(v) Settings.SnapLine = v end}):AddColorPicker('SnapColor', {Default = Settings.SnapLineColor, Callback = function(c) Settings.SnapLineColor = c end})
    SnapBox:AddToggle('SnapOutline_Toggle', {Text = 'Snap Line Outline', Default = false, Callback = function(v) Settings.SnapLineOutline = v end})
    SnapBox:AddSlider('SnapThickness_Slider', {Text = 'Snap Line Thickness', Min = 1, Max = 5, Default = 2, Rounding = 1, Callback = function(v) Settings.SnapLineThickness = v end})

        local GunModsBox = Tabs.Combat:AddRightGroupbox('Gun Mods')

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")
    local Players = game:GetService("Players")

    local LocalPlayer = Players.LocalPlayer
    local Framework = require(ReplicatedFirst:WaitForChild("Framework"))
    Framework:WaitForLoaded()

    local Firearm = nil
    task.spawn(function()
        setthreadidentity(2)
        Firearm = require(ReplicatedStorage.Client.Abstracts.ItemInitializers.Firearm)
    end)
    repeat task.wait() until Firearm

    local AnimatedReload = getupvalue(Firearm, 7)
    local InstantReloadEnabled = false 

    GunModsBox:AddToggle('InstantReload_Toggle', {
        Text = 'Instant Reload',
        Default = false,
        Risky = true,
        Callback = function(Value)
            InstantReloadEnabled = Value
        end
    })

    setupvalue(Firearm, 7, function(...)
        if InstantReloadEnabled then
            local Args = {...}
            for Index = 0, Args[3].LoopCount do
                Args[4]("Commit", "Load")
            end
            Args[4]("Commit", "End")
            return true
        end
        return AnimatedReload(...)
    end)

    GunModsBox:AddToggle('UnlockFiremodes_Toggle', {
        Text = 'Unlock Firemodes',
        Default = false,
        Callback = function(State)
            if not State then return end

            local Player = Players.LocalPlayer
            local Character = Player.Character or Player.CharacterAdded:Wait()

            repeat task.wait() until Character:FindFirstChild("Actions") and Character.Actions:FindFirstChild("ToolAction")

            local OldToolAction
            OldToolAction = hookfunction(Character.Actions.ToolAction, newcclosure(function(Self, ...)
                if not Self.EquippedItem then 
                    return OldToolAction(Self, ...) 
                end

                local FireModes = Self.EquippedItem.FireModes
                if not FireModes then 
                    return OldToolAction(Self, ...) 
                end

                -- додаємо всі режими
                for _, Mode in ipairs({"Semiautomatic", "Automatic", "Burst"}) do
                    if not table.find(FireModes, Mode) then
                        setreadonly(FireModes, false)
                        table.insert(FireModes, Mode)
                        setreadonly(FireModes, true)
                    end
                end

                return OldToolAction(Self, ...)
            end))
        end
    })

    GunModsBox:AddToggle('NoSpread_Toggle', {Text = 'No Spread', Default = false, Callback = function(v) Settings.NoSpreadEnabled = v end})
    GunModsBox:AddSlider('SpreadAmount_Slider', {Text = 'Spread Amount', Min = 0, Max = 100, Default = 0, Rounding = 1, Callback = function(v) Settings.SpreadScale = v / 100 end})

    GunModsBox:AddToggle('NoRecoil_Toggle', {Text = 'No Recoil', Default = false, Callback = function(v) Settings.NoRecoilEnabled = v end})
    GunModsBox:AddSlider('RecoilControl_Slider', {Text = 'Recoil Control', Min = 0, Max = 100, Default = 10, Rounding = 1, Callback = function(v) Settings.RecoilScale = v / 100 end})

end)

task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local ExpansionSize = Vector3.new(10, 10, 10)
    local Transparency = 0.5
    local OriginalSizes = {}
    local HeadExpandEnabled = false
    local Connections = {}

    local function expandHead(char)
        if char.Parent == LocalPlayer then return end
        local head = char:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            if not OriginalSizes[head] then
                OriginalSizes[head] = head.Size
            end
            head.Size = ExpansionSize
            head.Transparency = Transparency
            head.Material = Enum.Material.Neon
        end
    end

    local function onPlayer(plr)
        if plr == LocalPlayer then return end
        if plr.Character then expandHead(plr.Character) end
        plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            expandHead(char)
        end)
    end

    local function enableExpander()
        for _, plr in ipairs(Players:GetPlayers()) do
            onPlayer(plr)
        end
        Connections["PlayerAdded"] = Players.PlayerAdded:Connect(onPlayer)
    end

    local function disableExpander()
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

local HeadExpander = Tabs.Combat:AddRightGroupbox('Head Expander')

    HeadExpander:AddToggle('HeadExpand_Toggle', {
        Text = 'Enable Head Expander',
        Default = false,
        Callback = function(Value)
            HeadExpandEnabled = Value
            if Value then
                enableExpander()
            else
                disableExpander()
            end
        end
    })
		
    HeadExpander:AddSlider('HeadSize_Slider', {
        Text = 'Head Size',
        Min = 2,
        Max = 40,
        Default = 10,
        Rounding = 1,
        Callback = function(v)
            ExpansionSize = Vector3.new(v, v, v)
            if HeadExpandEnabled then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        expandHead(plr.Character)
                    end
                end
            end
        end
    })

    HeadExpander:AddSlider('HeadTransparency_Slider', {
        Text = 'Head Transparency',
        Min = 0,
        Max = 1,
        Default = 0.5,
        Rounding = 1,
        Callback = function(v)
            Transparency = v
            if HeadExpandEnabled then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        expandHead(plr.Character)
                    end
                end
            end
        end
    })
		
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall

    mt.__index = newcclosure(function(self, key)
        if key == "Size" and OriginalSizes[self] then
            return OriginalSizes[self]
        end
        return oldIndex(self, key)
    end)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "Size" and OriginalSizes[self] then
            return OriginalSizes[self]
        end

        return oldNamecall(self, unpack(args))
    end)

    setreadonly(mt, true)
end)

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Player Esp')
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flags = {}
local settings = {
    maxHPVisibility = 100,
    boxType = "Boxes", 
    metric = "Meters",
    useDisplayName = true
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

LeftGroupBox:AddButton({
    Text = "Map Esp",
    DoubleClick = false,
    Func = function()
        local interfaceMap = require(game:GetService("ReplicatedFirst").Framework).Interface.Map
        interfaceMap:EnableGodview()
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

LeftGroupBox:AddToggle('use display name', {
    Text = 'Use Display Name',
    Default = true,
    Callback = function(Value)
        settings.useDisplayName = Value
    end
})

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
    esp.BoxOutline.Thickness = 2  -- СТАРЕ: було 2
    esp.BoxOutline.Filled = false
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Color3.new(1,1,1)
    esp.Box.Thickness = 1  -- СТАРЕ: було 1
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
        line.Thickness = 1  -- СТАРЕ: було 1
        table.insert(esp.CornerLines, line)
    end
    
    esp.SkeletonLines = {}
    for i = 1, 20 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5  -- СТАРЕ: було 1.5
        table.insert(esp.SkeletonLines, line)
    end
    
    esp.HealthBarOutline = Drawing.new("Square")
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Color = Color3.new(0,0,0)
    esp.HealthBarOutline.Thickness = 1  -- СТАРЕ: було 1
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
    esp.TracerLine.Thickness = 1  -- СТАРЕ: було 1
    
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
            local boxThickness = 1  -- СТАРЕ: було 1
            local skeletonThickness = 1.5  -- СТАРЕ: було 1.5
            local tracerThickness = 1  -- СТАРЕ: було 1
            
            -- НОВА МЕХАНІКА: якщо персонаж присідає - робимо жирніше
            if hum then
                local isCrouching = hum.HipHeight < 2  -- перевірка на присідання
                if isCrouching then
                    boxThickness = 1.5  -- Трохи жирніше при присіданні, але не дуже
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
                
                local barWidth = 2  -- СТАРА товщина хелсбару
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

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Player Chams')

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
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
	if plr == lp then return end
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

LeftGroupBox:AddToggle('ChamsToggle', {
	Text = 'Player Chams',
	Tooltip = 'Підсвічування гравців через стіни',
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

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Corpse Esp')

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

LeftGroupBox:AddToggle('CorpseESP_Toggle', {
	Text = 'Corpse ESP',
	Default = false,
	Callback = function(Value)
		corpseESPEnabled = Value
		updateCorpseESP()
	end
})

LeftGroupBox:AddToggle('CorpseName_Toggle', {
	Text = 'Show Corpse Name',
	Default = false,
	Callback = function(Value)
		showNames = Value
		updateCorpseESP()
	end
})
:AddColorPicker('CorpseNameColor', {
	Default = corpseNameColor,
	Title = 'Name Color',
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

LeftGroupBox:AddToggle('CorpseDistance_Toggle', {
	Text = 'Show Distance',
	Default = false,
	Callback = function(Value)
		showDistance = Value
		updateCorpseESP()
	end
})
:AddColorPicker('CorpseDistanceColor', {
	Default = corpseDistanceColor,
	Title = 'Distance Color',
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

LeftGroupBox:AddSlider('CorpseDistanceCheck', {
	Text = 'Distance Check',
	Min = 1000,
	Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Vechicle Esp')

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

LeftGroupBox:AddToggle('VehicleESP_Toggle', {
	Text = 'Vehicle ESP',
	Default = false,
	Callback = function(Value)
		vehicleESPEnabled = Value
		updateVehicleESP()
	end
})

LeftGroupBox:AddToggle('VehicleName_Toggle', {
	Text = 'Show Vehicle Names',
	Default = false,
	Callback = function(Value)
		showNames = Value
		updateVehicleESP()
	end
})
:AddColorPicker('VehicleNameColor', {
	Default = vehicleNameColor,
	Title = 'Name Color',
	Callback = function(Value)
		vehicleNameColor = Value
		for _, data in pairs(espVehicles) do
			if data.nameLabel then data.nameLabel.TextColor3 = Value end
		end
	end
})

LeftGroupBox:AddToggle('VehicleDistance_Toggle', {
	Text = 'Show Distance',
	Default = false,
	Callback = function(Value)
		showDistance = Value
		updateVehicleESP()
	end
})
:AddColorPicker('VehicleDistanceColor', {
	Default = vehicleDistanceColor,
	Title = 'Distance Color',
	Callback = function(Value)
		vehicleDistanceColor = Value
		for _, data in pairs(espVehicles) do
			if data.distanceLabel then data.distanceLabel.TextColor3 = Value end
		end
	end
})

LeftGroupBox:AddSlider('VehicleDistanceCheck', {
	Text = 'Distance Check',
	Min = 1000,
	Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox('Zombie Esp')

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

LeftGroupBox:AddToggle('ZombieESP_Toggle', {
	Text = 'Zombie ESP',
	Default = false,
	Callback = function(Value)
		zombieESPEnabled = Value
		updateZombieESP()
	end
})

LeftGroupBox:AddToggle('ZombieName_Toggle', {
	Text = 'Show Zombie Names',
	Default = false,
	Callback = function(Value)
		showNames = Value
		updateZombieESP()
	end
})
:AddColorPicker('ZombieNameColor', {
	Default = zombieNameColor,
	Title = 'Name Color',
	Callback = function(Value)
		zombieNameColor = Value
		for _, data in pairs(espZombies) do
			if data.nameLabel then data.nameLabel.TextColor3 = Value end
		end
	end
})

LeftGroupBox:AddToggle('ZombieDistance_Toggle', {
	Text = 'Show Distance',
	Default = false,
	Callback = function(Value)
		showDistance = Value
		updateZombieESP()
	end
})
:AddColorPicker('ZombieDistanceColor', {
	Default = zombieDistanceColor,
	Title = 'Distance Color',
	Callback = function(Value)
		zombieDistanceColor = Value
		for _, data in pairs(espZombies) do
			if data.distanceLabel then data.distanceLabel.TextColor3 = Value end
		end
	end
})

LeftGroupBox:AddSlider('ZombieDistanceCheck', {
	Text = 'Distance Check',
	Min = 1000,
	Max = 10000,
	Default = maxDistance,
	Rounding = 1,
	Callback = function(Value)
		maxDistance = Value
	end
})

local RightGroupBox = Tabs.Visuals:AddRightGroupbox('Lighting')

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

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

RightGroupBox:AddToggle('NoShadows_Toggle', {
	Text = 'No Shadows',
	Default = false,
	Callback = function(Value)
		Lighting.GlobalShadows = not Value
	end
})

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

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local timeConnection
local customTime = 12

RightGroupBox:AddToggle('CustomTime_Toggle', {
	Text = 'Custom Time',
	Default = false,
	Callback = function(Value)
		if Value then
			-- Миттєве встановлення при увімкненні
			Lighting.ClockTime = customTime
			if timeConnection then
				timeConnection:Disconnect()
				timeConnection = nil
			end
			-- RenderStepped — виконується ПЕРЕД рендером (найвищий пріоритет, перекриває сервер)
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

RightGroupBox:AddSlider('CustomTime_Slider', {
	Text = 'Custom Time',
	Min = 0,
	Max = 24,
	Default = customTime,
	Rounding = 1,
	Callback = function(Value)
		customTime = Value
		-- Миттєве оновлення при зміні слайдера (якщо тогл увімкнено)
		if timeConnection then
			Lighting.ClockTime = customTime
		end
	end
})

local CloudsModification = Tabs.Visuals:AddRightGroupbox('Clouds Modification')

local RunService = game:GetService("RunService")
local clouds = workspace:FindFirstChildOfClass("Clouds") or workspace.Terrain:FindFirstChildOfClass("Clouds")
flags = flags or {}

local cloudColor = clouds and clouds.Color or Color3.fromRGB(255, 255, 255)
local cloudCover = clouds and clouds.Cover or 0.5
local cloudDensity = clouds and clouds.Density or 0.5
local cloudsEnabled = clouds and clouds.Enabled or true
flags.ModifyClouds = false

CloudsModification:AddToggle('EnableClouds_Toggle', {
	Text = 'Enable Clouds',
	Default = false,
	Callback = function(Value)
		cloudsEnabled = Value
	end
})
:AddColorPicker('CloudsColor', {
	Default = cloudColor,
	Title = 'Clouds Color',
	Callback = function(Value)
		cloudColor = Value
	end
})

CloudsModification:AddToggle('ModifyClouds_Toggle', {
	Text = 'Modify Clouds',
	Default = false,
	Callback = function(Value)
		flags.ModifyClouds = Value
	end
})

CloudsModification:AddSlider('CloudsCover_Slider', {
	Text = 'Clouds Cover',
	Min = 0,
	Max = 1,
	Default = 0.5,
	Rounding = 2, 
	Callback = function(Value)
		cloudCover = Value
	end
})

CloudsModification:AddSlider('CloudsDensity_Slider', {
	Text = 'Clouds Density',
	Min = 0,
	Max = 1,
	Default = 0.5,
	Rounding = 2, 
	Callback = function(Value)
		cloudDensity = Value
	end
})

RunService.RenderStepped:Connect(function()
	if clouds and flags.ModifyClouds then
		clouds.Enabled = cloudsEnabled
		clouds.Color = cloudColor
		clouds.Cover = cloudCover
		clouds.Density = cloudDensity
	end
end)

local CustomSkyBox = Tabs.Visuals:AddRightGroupbox('Custom Sky Box')

local Lighting = game:GetService("Lighting")
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

local BuletTracer = Tabs.Visuals:AddRightGroupbox('Bulet Tracer')

task.spawn(function()
local world_utilities = {
	BulletTracer = false,
	BulletTracerColor = Color3.fromRGB(255, 255, 255),
	BulletTracerLength = 3
}

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
		beam.Width0 = 0.8
		beam.Width1 = 0.25
		beam.TextureSpeed = 5
		beam.Transparency = NumberSequence.new(0.1)

		task.delay(world_utilities.BulletTracerLength, function()
			if part then part:Destroy() end
		end)
	end)
end

local replicated_first = game:GetService("ReplicatedFirst")
local framework = require(replicated_first.Framework)
local wrapper = getupvalue(getupvalue(framework.require, 1), 1)
local bullets = wrapper.Libraries.Bullets

local old_fire
old_fire = hookfunction(bullets.Fire, function(weapon_data, character_data, _, gun_data, origin, direction, ...)
	if world_utilities.BulletTracer then
		createBulletTracerBeam(origin, direction)
	end
	return old_fire(weapon_data, character_data, _, gun_data, origin, direction, ...)
end)

BuletTracer:AddToggle('BulletTracer_Toggle', {
	Text = 'Bullet Tracer',
	Default = false,
	Callback = function(Value)
		world_utilities.BulletTracer = Value
	end
})
:AddColorPicker('BulletTracer_Color', {
	Default = world_utilities.BulletTracerColor,
	Title = 'Tracer Color',
	Callback = function(Value)
		world_utilities.BulletTracerColor = Value
	end
})

BuletTracer:AddSlider('BulletTracer_Length', {
	Text = 'Tracer Lifetime',
	Min = 1,
	Max = 10,
	Default = world_utilities.BulletTracerLength,
	Rounding = 1,
	Callback = function(Value)
		world_utilities.BulletTracerLength = Value
	end
})

end)

local LocalPlayer = Tabs.Visuals:AddRightGroupbox('Local Player')

local flags = {
    ChinaHat = false,
    ChinaHatColor = Color3.fromRGB(175, 25, 255)
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function createChinaHat(character)
    if not character then return end
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    -- Видаляємо старий ChinaHat, якщо був
    local old = character:FindFirstChild("ChinaHat")
    if old then
        old:Destroy()
    end

    local cone = Instance.new("Part")
    cone.Name = "ChinaHat"
    cone.Size = Vector3.new(1, 1, 1)
    cone.Transparency = 0.8          -- сам меш майже невидимий
    cone.CanCollide = false
    cone.Anchored = false
    cone.Massless = true
    cone.CastShadow = false

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"   -- старий класичний конус
    mesh.Scale = Vector3.new(1.8, 1.1, 1.8)
    mesh.Parent = cone

    -- Позиціонуємо над головою
    cone.CFrame = head.CFrame * CFrame.new(0, 0.9, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = cone
    weld.Parent = cone

    -- Highlight (CHAMS)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = cone
    highlight.FillColor = flags.ChinaHatColor
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 1       -- без обводки
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = cone

    cone.Parent = character
end

-- Оновлення при респавні
local function onCharacterAdded(char)
    task.wait(0.3) -- маленька затримка, щоб точно все вантажилось
    if flags.ChinaHat then
        createChinaHat(char)
    end
end

-- Підписуємось один раз
player.CharacterAdded:Connect(onCharacterAdded)

-- Якщо персонаж вже завантажений на момент запуску скрипта
if player.Character then
    onCharacterAdded(player.Character)
end

-- Твій UI (наприклад Linoria / Fluxus / тощо)
LocalPlayer:AddToggle('ChinaHatToggle', {
    Text = 'China Hat',
    Default = false,
    Callback = function(Value)
        flags.ChinaHat = Value
        
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
:AddColorPicker('ChinaHatColor', {
    Default = flags.ChinaHatColor,
    Title = 'China Hat Color',
    Callback = function(Value)
        flags.ChinaHatColor = Value
        
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local enabled = false
local color = Color3.fromRGB(255, 255, 255)
local material = Enum.Material.ForceField

local function applyChams(char)
	task.wait()
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Color = color
			part.Material = material
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

LocalPlayer:AddToggle('SelfChams_Toggle', {
	Text = 'Self Chams',
	Default = false,
	Callback = function(Value)
		enabled = Value
		local char = player.Character
		if char then
			if enabled then
				applyChams(char)
			else
				clearChams(char)
			end
		end
	end
})
:AddColorPicker('SelfChams_Color', {
	Default = Color3.fromRGB(255, 255, 255),
	Title = 'Chams Color',
	Callback = function(Value)
		color = Value
		if enabled and player.Character then
			applyChams(player.Character)
		end
	end
})

LocalPlayer:AddDropdown('SelfChams_Material', {
	Text = 'Chams Material',
	Default = 'ForceField',
	Values = {'ForceField', 'Plastic', 'Wood', 'SmoothPlastic', 'Metal', 'Neon', 'Glass'},
	Callback = function(Value)
		if Value == 'ForceField' then
			material = Enum.Material.ForceField
		elseif Value == 'Plastic' then
			material = Enum.Material.Plastic
		elseif Value == 'Wood' then
			material = Enum.Material.Wood
		elseif Value == 'SmoothPlastic' then
			material = Enum.Material.SmoothPlastic
		elseif Value == 'Metal' then
			material = Enum.Material.Metal
		elseif Value == 'Neon' then
			material = Enum.Material.Neon
		elseif Value == 'Glass' then
			material = Enum.Material.Glass
		end
		if enabled and player.Character then
			applyChams(player.Character)
		end
	end
})

player.CharacterAdded:Connect(function(char)
	task.wait()
	if enabled then
		applyChams(char)
	end
end)

local gunChamsEnabled = false
local chamColor = Color3.fromRGB(250, 250, 250)
local chamMaterial = Enum.Material.Plastic
local originalProperties = {}

local function ApplyGunChams(tool)
	if not tool then return end
	for _, obj in ipairs(tool:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			if not originalProperties[obj] then
				originalProperties[obj] = {Color = obj.Color, Material = obj.Material}
			end
			obj.Material = chamMaterial
			obj.Color = chamColor
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
	local char = player.Character
	if not char then return end
	local equipped = char:FindFirstChild("Equipped")
	if equipped then
		if gunChamsEnabled then
			ApplyGunChams(equipped)
		else
			RemoveGunChams(equipped)
		end
	end
end)

LocalPlayer:AddToggle('GunChams_Toggle', {
	Text = 'Equipped Item Chams',
	Default = false,
	Callback = function(Value)
		gunChamsEnabled = Value
	end
})
:AddColorPicker('GunChams_Color', {
	Default = chamColor,
	Title = 'Gun Color',
	Callback = function(Value)
		chamColor = Value
	end
})

LocalPlayer:AddDropdown('GunChams_Material', {
	Text = 'Gun Material',
	Default = 'Plastic',
	Values = {'ForceField', 'Plastic', 'SmoothPlastic', 'Glass', 'Neon'},
	Callback = function(Value)
		if Value == 'ForceField' then
			chamMaterial = Enum.Material.ForceField
		elseif Value == 'Plastic' then
			chamMaterial = Enum.Material.Plastic
		elseif Value == 'SmoothPlastic' then
			chamMaterial = Enum.Material.SmoothPlastic
		elseif Value == 'Glass' then
			chamMaterial = Enum.Material.Glass
		elseif Value == 'Neon' then
			chamMaterial = Enum.Material.Neon
		end
	end
})

local CustomCrosshair = Tabs.Visuals:AddRightGroupbox('Custom Crosshair')

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

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
gui.Parent = lp:WaitForChild("PlayerGui")

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
