local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local lib = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local tm = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local sm = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local win = lib:CreateWindow({ 
    Size = UDim2.fromOffset(550, 610),
    Title = "LunarCore.xyz |PD| v1.9",
    Center = false,
    AutoShow = true
})

local tabs = {
    C = win:AddTab('Combat'),
    V = win:AddTab('Visuals'),
    M = win:AddTab('Misc'),
    U = win:AddTab('UI Settings'),
}

local a_sec = tabs.C:AddLeftGroupbox('Aimbot Settings')
local g_sec = tabs.C:AddRightGroupbox('Gun Settings')
local v_sec = tabs.V:AddLeftGroupbox('Players ESP')
local b_sec = tabs.V:AddLeftGroupbox('bot ESP')
local md_sec = tabs.V:AddLeftGroupbox('Mod Detector')
local o_sec = tabs.V:AddRightGroupbox('Other Esp')
local arm_sec = tabs.V:AddRightGroupbox('Arms & Viewmodel')
local s_sec = tabs.M:AddRightGroupbox('Peek Kill')
local char_sec = tabs.M:AddRightGroupbox('Character')
local hs_sec = tabs.M:AddRightGroupbox('Hit Sound')
local aa_sec = tabs.M:AddLeftGroupbox('AntiAim')
local w_sec = tabs.V:AddRightGroupbox('World')
local oth_sec = tabs.M:AddLeftGroupbox('Other')
local ds_sec = tabs.M:AddLeftGroupbox('Desync')

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = plrs.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera
local rep = game:GetService("ReplicatedStorage")
local cg = game:GetService("CoreGui")
local ws = workspace
local gi = game:GetService("GuiService"):GetGuiInset()

local sa = {
	enabled = false, target_ai = false, part = "Head",
	fov = false, fov_show = false, fov_color = Color3.new(1,1,1),
	fov_outline = false, fov_outline_color = Color3.new(0,0,0), fov_size = 100,
	nospread = false, instant = false, target_part = nil, is_npc = false,
	isvisible = false, tracer = false, tracer_color = Color3.new(1,1,1), 
	tracer_texture = "rbxassetid://446111271",
	tracer_size = 0.15,
	tracer_fade = 0.5,
}

local last_ammo = nil
local proj_codes = {}
local vis_params = RaycastParams.new()
vis_params.FilterType = Enum.RaycastFilterType.Exclude
vis_params.IgnoreWater = true
local is_rapid = false

local f_circ = Drawing.new("Circle")
f_circ.Thickness = 1
f_circ.Filled = false
f_circ.Transparency = 1
f_circ.Visible = false

local f_out = Drawing.new("Circle")
f_out.Thickness = 3
f_out.Filled = false
f_out.Visible = false

if not ws:FindFirstChild("NoCollision") then
	local f = Instance.new("Folder")
	f.Name = "NoCollision"
	f.Parent = ws
end

local function make_tracer(orig, dest, col, tex, sz, fade)
	local p1 = Instance.new("Part")
	local p2 = Instance.new("Part")
	p1.Size = Vector3.new(0.1, 0.1, 0.1)
	p2.Size = Vector3.new(0.1, 0.1, 0.1)
	p1.Transparency = 1
	p2.Transparency = 1
	p1.CanCollide = false
	p2.CanCollide = false
	p1.Anchored = true
	p2.Anchored = true
	p1.Position = orig
	p2.Position = dest
	p1.Parent = ws.NoCollision
	p2.Parent = ws.NoCollision
	
	local a1 = Instance.new("Attachment", p1)
	local a2 = Instance.new("Attachment", p2)
	local b = Instance.new("Beam")
	b.Attachment0 = a1
	b.Attachment1 = a2
	b.Color = ColorSequence.new(col)
	b.Width0 = sz
	b.Width1 = sz
	b.Texture = tex
	b.TextureMode = Enum.TextureMode.Static
	b.FaceCamera = true
	b.LightEmission = 1
	b.Transparency = NumberSequence.new(0)
	b.Parent = ws.NoCollision
	
	local start = tick()
	local cn
	cn = rs.RenderStepped:Connect(function()
		local el = tick() - start
		local al = math.clamp(1 - (el / fade), 0, 1)
		b.Transparency = NumberSequence.new(1 - al)
		if el >= fade then
			cn:Disconnect()
			pcall(function()
				p1:Destroy()
				p2:Destroy()
				b:Destroy()
			end)
		end
	end)
end

local function check_vis(cf, tar, tp)
	if not (tar and tp and cf) then return false end
	vis_params.FilterDescendantsInstances = { ws.NoCollision, cam, lp.Character }
	local ray = ws:Raycast(cf.Position, tp.Position - cf.Position, vis_params)
	return ray and ray.Instance and ray.Instance:IsDescendantOf(tar)
end

local function pred_vel(orig, dest, dest_vel, speed)
	local t = (dest - orig).Magnitude / speed
	local pred = dest + dest_vel * t
	t = t + ((pred - orig).Magnitude / speed) / speed
	return dest + dest_vel * t
end

local function get_target(ufov, fsz, apart, npc)
	local cl_part, isn = nil, false
	local max_d = ufov and fsz or math.huge
	local mpos = Vector2.new(mouse.X, mouse.Y)
	
	if npc then
		local az = ws:FindFirstChild("AiZones")
		if az then
			for _, z in ipairs(az:GetChildren()) do
				for _, n in ipairs(z:GetChildren()) do
					local p = n:FindFirstChild(apart)
					local h = n:FindFirstChildOfClass("Humanoid")
					if p and h and h.Health > 0 then
						local pos, vis = cam:WorldToViewportPoint(p.Position)
						local d = (Vector2.new(pos.X, pos.Y - gi.Y) - mpos).Magnitude
						if (ufov and vis or not ufov) and d < max_d then
							cl_part = p
							max_d = d
							isn = true
						end
					end
				end
			end
		end
	end
	
	for _, p in ipairs(plrs:GetPlayers()) do
		local c = p.Character
		if p ~= lp and c then
			local pt = c:FindFirstChild(apart)
			local h = c:FindFirstChildOfClass("Humanoid")
			if pt and h and h.Health > 0 then
				local pos, vis = cam:WorldToViewportPoint(pt.Position)
				local d = (Vector2.new(pos.X, pos.Y - gi.Y) - mpos).Magnitude
				if (ufov and vis or not ufov) and d <= max_d then
					cl_part = pt
					max_d = d
					isn = false
				end
			end
		end
	end
	return cl_part, isn
end

for _, gc in next, getgc(true) do
	if type(gc) == "table" and rawget(gc, "CreateBullet") then
		local old_b = gc.CreateBullet
		gc.CreateBullet = function(self, ...)
			local args = {...}
			if is_rapid then return old_b(self, unpack(args)) end
			if sa.enabled then
				local l_ammo, ap_idx
				for i, v in ipairs(args) do
					if typeof(v) == "Instance" and v.Name == "AimPart" then ap_idx = i end
					if type(v) == "string" then
						local tmp = rep.AmmoTypes:FindFirstChild(v)
						if tmp then l_ammo = tmp end
					end
				end
				last_ammo = l_ammo
				if sa.tracer and sa.target_part and ap_idx then
					task.spawn(make_tracer, args[ap_idx].Position, sa.target_part.Position, sa.tracer_color, sa.tracer_texture, sa.tracer_size, sa.tracer_fade)
				end
				if sa.instant or not sa.target_part then return old_b(self, unpack(args)) end
				if l_ammo and ap_idx then
					local orig = cam.CFrame.Position
					local dest = pred_vel(orig, sa.target_part.Position, sa.target_part.Velocity, l_ammo:GetAttribute("MuzzleVelocity"))
					args[ap_idx] = { CFrame = CFrame.new(orig, dest) }
				end
			end
			return old_b(self, unpack(args))
		end
		break
	end
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local old_nc = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	if method == "GetAttribute" then
		local attr = args[1]
		if sa.nospread and attr == "AccuracyDeviation" then return 0 end
		if sa.enabled and (attr == "ProjectileDrop" or attr == "Drag") then return 0 end
	end
	if method == "InvokeServer" and self.Name == "FireProjectile" and sa.enabled and sa.instant and sa.target_part then
		task.spawn(function()
			if last_ammo then
				proj_codes[args[2]] = {
					Origin = cam.CFrame.Position,
					Tick = args[3],
					Drag = last_ammo:GetAttribute("Drag"),
					ProjectileSpeed = last_ammo:GetAttribute("MuzzleVelocity")
				}
			end
		end)
		return old_nc(self, unpack(args))
	end
	if method == "FireServer" and self.Name == "ProjectileInflict" then
		if proj_codes[args[3]] then
			local d = proj_codes[args[3]]
			local dist = (args[1].Position - d.Origin).Magnitude
			local tth = dist / d.ProjectileSpeed
			local hit = args[1].Position + (args[1].Velocity * tth)
			local delta = (hit - args[1].Position).Magnitude
			local res = d.ProjectileSpeed - d.Drag * d.ProjectileSpeed ^ 2 * tth ^ 2
			tth = tth + (delta / res)
			if tth > 0 then d.Tick = d.Tick + tth end
			args[4] = d.Tick
		end
		return old_nc(self, unpack(args))
	end
	if method == "Raycast" and sa.enabled and sa.instant and sa.target_part then
		args[2] = (sa.target_part.Position - args[1])
		return old_nc(self, unpack(args))
	end
	return old_nc(self, ...)
end)
setreadonly(mt, true)

rs.Heartbeat:Connect(function()
	if sa.enabled then
		sa.target_part, sa.is_npc = get_target(sa.fov, sa.fov_size, sa.part, sa.target_ai)
		if sa.target_part then
			sa.isvisible = check_vis(cam.CFrame, sa.target_part.Parent, sa.target_part)
		end
	end
end)

rs.RenderStepped:Connect(function()
	local mpos = Vector2.new(mouse.X, mouse.Y + gi.Y)
	f_circ.Position = mpos
	f_circ.Radius = sa.fov_size
	f_circ.Color = sa.fov_color
	f_circ.Visible = sa.fov and sa.fov_show
	
	f_out.Position = mpos
	f_out.Radius = sa.fov_size
	f_out.Color = sa.fov_outline_color
	f_out.Visible = sa.fov and sa.fov_show and sa.fov_outline
end)

local gs = {
    RapidFire = { Enabled = false, MultiTap = 3, Delay = 3.5, FireRate = 0.001 },
    NoRecoil = false,
    NoSpread = false,
    InstantEquip = false
}
local g_orig = { FireRates = {}, FireModes = {}, AccuracyDeviation = {} }

local old_nc_anim = nil
local function setup_eq()
    if gs.InstantEquip then
        if not old_nc_anim then
            local mt_anim = getrawmetatable(game)
            setreadonly(mt_anim, false)
            old_nc_anim = mt_anim.__namecall
            mt_anim.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Play" and self.ClassName == "AnimationTrack" then
                    if self.Name == "Equip" then
                        local res = old_nc_anim(self, ...)
                        self.TimePosition = self.Length
                        return res
                    end
                end
                return old_nc_anim(self, ...)
            end)
            setreadonly(mt_anim, true)
        end
    else
        if old_nc_anim then
            local mt_anim = getrawmetatable(game)
            setreadonly(mt_anim, false)
            mt_anim.__namecall = old_nc_anim
            setreadonly(mt_anim, true)
            old_nc_anim = nil
        end
    end
end

local function save_gun(g)
    if not g then return end
    local smod = g:FindFirstChild("SettingsModule")
    if smod and not g_orig.FireRates[g] then
        local sett = require(smod)
        g_orig.FireRates[g] = sett.FireRate
        g_orig.FireModes[g] = sett.FireModes
    end
end

local function upd_rapid()
    local inf = rep.Players:FindFirstChild(lp.Name)
    if not inf then return end
    local inv = inf:FindFirstChild("Inventory")
    if not inv then return end
    for _, g in ipairs(inv:GetChildren()) do
        local smod = g:FindFirstChild("SettingsModule")
        if smod then
            save_gun(g)
            local sett = require(smod)
            if gs.RapidFire.Enabled then
                sett.FireRate = gs.RapidFire.FireRate
                sett.FireModes = {"Auto"}
            else
                if g_orig.FireRates[g] then sett.FireRate = g_orig.FireRates[g] end
                if g_orig.FireModes[g] then sett.FireModes = g_orig.FireModes[g]
                else sett.FireModes = {"Semi", "Auto", "Burst"} end
            end
        end
    end
end

local b_mod = require(rep.Modules.FPS.Bullet)
local old_cb = b_mod.CreateBullet
b_mod.CreateBullet = function(self, ...)
    local args = { ... }
    if gs.RapidFire.Enabled then
        for i = 1, gs.RapidFire.MultiTap do
            task.spawn(function()
                local delay = (i-1) * (gs.RapidFire.Delay / 1000) + math.random(1,5) * 0.001
                task.wait(delay)
                pcall(old_cb, self, unpack(args))
            end)
        end
        return
    end
    return old_cb(self, unpack(args))
end

local function upd_recoil()
    for _, gc in next, getgc(true) do
        if type(gc) == "table" then
            if rawget(gc, "shove") and rawget(gc, "update") then
                local shove = gc.shove
                gc.shove = function(...)
                    if gs.NoRecoil then return end
                    return shove(...)
                end
            end
            if type(rawget(gc, "create")) == "function" and getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" then
                local old_c = gc.create
                gc.create = function(...)
                    local ret = old_c(...)
                    local shove = ret.shove
                    ret.shove = function(...)
                        if gs.NoRecoil then return end
                        return shove(...)
                    end
                    return ret
                end
            end
        end
    end
end

local mt2 = getrawmetatable(game)
local old_nc2 = mt2.__namecall
setreadonly(mt2, false)
mt2.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if getnamecallmethod() == "GetAttribute" and gs.NoSpread then
        if args[1] == "AccuracyDeviation" then return 0 end
    end
    return old_nc2(self, ...)
end)
setreadonly(mt2, true)

a_sec:AddToggle("SilentAimEnabled", { Text = "Enable Silent Aim", Default = false, Risky = true, Callback = function(v) sa.enabled = v end })
a_sec:AddToggle("SilentAimInstant", { Text = "Instant Hit", Default = false, Risky = true, Callback = function(v) sa.instant = v end })
a_sec:AddToggle("SilentAimTargetAI", { Text = "Target AI", Default = false, Callback = function(v) sa.target_ai = v end })
a_sec:AddDropdown("SilentAimPart", { Text = "Aim Part", Values = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, Default = "Head", Risky = true, Callback = function(v) sa.part = v end })
a_sec:AddToggle("FOVEnabled", { Text = "Enable FOV", Default = false, Callback = function(v) sa.fov = v end })
a_sec:AddToggle("FOVShow", { Text = "Show FOV Circle", Default = false, Callback = function(v) sa.fov_show = v end }):AddColorPicker("FOVColor", { Text = "FOV Color", Default = Color3.new(1, 1, 1), Callback = function(c) sa.fov_color = c end })
a_sec:AddSlider("FOVSize", { Text = "FOV Size", Default = 100, Min = 10, Max = 500, Rounding = 0, Callback = function(v) sa.fov_size = v end })
a_sec:AddToggle("BulletTracerEnabled", { Text = "Bullet Tracer", Default = false, Callback = function(v) sa.tracer = v end }):AddColorPicker("BulletTracerColor", { Text = "Tracer Color", Default = Color3.new(1, 1, 1), Callback = function(c) sa.tracer_color = c end })
a_sec:AddSlider("BulletTracerSize", { Text = "Tracer Size", Default = 15, Min = 5, Max = 50, Rounding = 0, Suffix = "%", Callback = function(v) sa.tracer_size = v / 100 end })
a_sec:AddSlider("BulletTracerFadeTime", { Text = "Fade Time", Default = 0.5, Min = 0.1, Max = 2, Rounding = 1, Suffix = "s", Callback = function(v) sa.tracer_fade = v end })

g_sec:AddToggle('RapidFire', { Text = 'Rapid Fire', Default = false, Risky = true, Callback = function(v) gs.RapidFire.Enabled = v; upd_rapid() end })
g_sec:AddToggle('NoRecoil', { Text = 'No Recoil', Default = false, Callback = function(v) gs.NoRecoil = v; upd_recoil() end })
g_sec:AddToggle('NoSpreadGun', { Text = 'No Spread', Default = false, Risky = true, Callback = function(v) gs.NoSpread = v end })
g_sec:AddToggle('InstantEquip', { Text = 'Instant Equip', Default = false, Risky = true, Callback = function(v) gs.InstantEquip = v; setup_eq() end })
g_sec:AddSlider('RapidFireMultiTap', { Text = 'Multi-Tap', Default = 3, Min = 1, Max = 10, Rounding = 0, Suffix = 'x', Callback = function(v) gs.RapidFire.MultiTap = v end })
g_sec:AddSlider('RapidFireDelay', { Text = 'Fire Delay (ms)', Default = 3.5, Min = 1, Max = 15, Rounding = 1, Suffix = 'ms', Callback = function(v) gs.RapidFire.Delay = v end })

local esp_db = {
    Toggles = { Enabled = false, Box = false, Name = false, Distance = false, WeaponName = false, HPBar = false, HPText = false, Skeleton = false },
    Colors = {
        BoxOuter = Color3.new(0, 0, 0), BoxMain  = Color3.new(1, 1, 1), BoxInner = Color3.new(0, 0, 0), Name = Color3.new(1, 1, 1),
        Distance = Color3.new(1, 1, 1), WeaponName = Color3.fromRGB(255, 215, 0), HealthText = Color3.new(1, 1, 1),
        HealthGradientStart = Color3.fromRGB(255, 255, 255), HealthGradientMid = Color3.fromRGB(212, 163, 255), HealthGradientEnd = Color3.fromRGB(136, 0, 255),
        HealthMask = Color3.new(0, 0, 0), HealthMaskTransparency = 0.3, Skeleton = Color3.new(1, 1, 1), SkeletonTransparency = 0
    },
    Connections = {}, Boxes = {}
}

local esp_g = Instance.new("ScreenGui")
esp_g.DisplayOrder = 9e9
esp_g.ResetOnSpawn = false
esp_g.Parent = gethui and gethui() or cg
esp_g.Enabled = false

local function clean_esp(p)
    if esp_db.Boxes[p] then
        for _, obj in pairs(esp_db.Boxes[p]) do
            if typeof(obj) == "Instance" then obj:Destroy()
            elseif typeof(obj) == "table" and obj.Lines then
                for _, ln in ipairs(obj.Lines) do ln:Remove() end
            end
        end
        esp_db.Boxes[p] = nil
    end
end

esp_db.Connections.PlayerRemoving = plrs.PlayerRemoving:Connect(clean_esp)

local function make_box()
    local b = {}
    local n = {"Outer", "Main", "Inner"}
    for i = 1, 3 do
        local f = Instance.new("Frame")
        f.Name = n[i]
        f.BackgroundTransparency = 1
        f.Parent = esp_g
        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Parent = f
        b[n[i]] = f
        b[n[i] .. "Stroke"] = s
    end
    b.OuterStroke.Color = esp_db.Colors.BoxOuter
    b.MainStroke.Color  = esp_db.Colors.BoxMain
    b.InnerStroke.Color = esp_db.Colors.BoxInner

    local h_bg = Instance.new("Frame")
    h_bg.Name = "HealthBg"
    h_bg.BackgroundTransparency = 0
    h_bg.BorderSizePixel = 0
    h_bg.Parent = esp_g
    local gr = Instance.new("UIGradient")
    gr.Rotation = 90
    gr.Parent = h_bg

    local function upd_g()
        gr.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, esp_db.Colors.HealthGradientStart),
            ColorSequenceKeypoint.new(0.5, esp_db.Colors.HealthGradientMid),
            ColorSequenceKeypoint.new(1, esp_db.Colors.HealthGradientEnd)
        })
    end
    upd_g()
    b.UpdateGradient = upd_g

    local h_msk = Instance.new("Frame")
    h_msk.Name = "HealthMask"
    h_msk.BackgroundColor3 = esp_db.Colors.HealthMask
    h_msk.BackgroundTransparency = esp_db.Colors.HealthMaskTransparency
    h_msk.BorderSizePixel = 0
    h_msk.Parent = h_bg
    h_msk.ZIndex = h_bg.ZIndex + 1

    local h_s = Instance.new("UIStroke")
    h_s.Color = Color3.new(0,0,0)
    h_s.Thickness = 1
    h_s.Parent = h_bg

    local nl = Instance.new("TextLabel")
    nl.Name = "NameLabel"
    nl.BackgroundTransparency = 1
    nl.TextSize = 12
    nl.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.new(0,0,0)
    nl.Parent = esp_g
    nl.TextColor3 = esp_db.Colors.Name

    local ht = Instance.new("TextLabel")
    ht.Name = "HealthText"
    ht.BackgroundTransparency = 1
    ht.TextSize = 10
    ht.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    ht.TextStrokeTransparency = 0
    ht.TextStrokeColor3 = Color3.new(0,0,0)
    ht.TextXAlignment = Enum.TextXAlignment.Right
    ht.Parent = esp_g
    ht.TextColor3 = esp_db.Colors.HealthText

    local dl = Instance.new("TextLabel")
    dl.Name = "DistanceLabel"
    dl.BackgroundTransparency = 1
    dl.TextSize = 12
    dl.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    dl.TextStrokeTransparency = 0
    dl.TextStrokeColor3 = Color3.new(0,0,0)
    dl.TextXAlignment = Enum.TextXAlignment.Center
    dl.Parent = esp_g
    dl.TextColor3 = esp_db.Colors.Distance

    local tl = Instance.new("TextLabel")
    tl.Name = "ToolLabel"
    tl.BackgroundTransparency = 1
    tl.TextSize = 13
    tl.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
    tl.TextStrokeTransparency = 0.4
    tl.TextStrokeColor3 = Color3.new(0,0,0)
    tl.TextColor3 = esp_db.Colors.WeaponName
    tl.TextXAlignment = Enum.TextXAlignment.Center
    tl.Parent = esp_g

    local lines = {}
    for i = 1, 20 do
        local ln = Drawing.new("Line")
        ln.Thickness = 1
        ln.Color = esp_db.Colors.Skeleton
        ln.Transparency = 1 - esp_db.Colors.SkeletonTransparency
        ln.Visible = false
        lines[i] = ln
    end
    b.Lines = lines

    b.HealthBg = h_bg
    b.HealthMask = h_msk
    b.NameLabel = nl
    b.HealthText = ht
    b.DistanceLabel = dl
    b.ToolLabel = tl
    b.LastTool = nil
    b.VisualHealth = nil

    return b
end

local function set_esp_vis(esp, vis)
    if not esp then return end
    esp.Outer.Visible = vis
    esp.Main.Visible  = vis
    esp.Inner.Visible = vis
    if esp.Lines then
        for _, ln in ipairs(esp.Lines) do 
            ln.Visible = vis and esp_db.Toggles.Skeleton 
        end
    end
end

rs.Heartbeat:Connect(function()
    if not esp_db.Toggles.Enabled then
        if esp_g.Enabled then esp_g.Enabled = false end
        for _, esp in pairs(esp_db.Boxes) do
            if esp and esp.Lines then
                for _, ln in ipairs(esp.Lines) do ln.Visible = false end
            end
        end
        return
    end

    esp_g.Enabled = true
    local lp_char = lp.Character
    local lp_root = lp_char and lp_char:FindFirstChild("HumanoidRootPart")
    local rs_plrs = rep:FindFirstChild("Players")

    for _, p in ipairs(plrs:GetPlayers()) do
        if p == lp then continue end
        local c = p.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")

        if not c or not r or not h or h.Health <= 0 then
            if esp_db.Boxes[p] then clean_esp(p) end
            continue
        end

        local esp = esp_db.Boxes[p]
        local cf, sz = c:GetBoundingBox()
        if not cf then
            if esp then clean_esp(p) end
            continue
        end

        local h_sz = sz / 2
        local corners = {
            cf * Vector3.new(h_sz.X, h_sz.Y, h_sz.Z),
            cf * Vector3.new(h_sz.X, h_sz.Y, -h_sz.Z),
            cf * Vector3.new(h_sz.X, -h_sz.Y, h_sz.Z),
            cf * Vector3.new(h_sz.X, -h_sz.Y, -h_sz.Z),
            cf * Vector3.new(-h_sz.X, h_sz.Y, h_sz.Z),
            cf * Vector3.new(-h_sz.X, h_sz.Y, -h_sz.Z),
            cf * Vector3.new(-h_sz.X, -h_sz.Y, h_sz.Z),
            cf * Vector3.new(-h_sz.X, -h_sz.Y, -h_sz.Z)
        }

        local l, t = math.huge, math.huge
        local r_edge, b_edge = -math.huge, -math.huge
        local scr = false

        for i = 1, 8 do
            local s_pos, vis = cam:WorldToScreenPoint(corners[i])
            if vis then
                scr = true
                l = math.min(l, s_pos.X)
                t = math.min(t, s_pos.Y)
                r_edge = math.max(r_edge, s_pos.X)
                b_edge = math.max(b_edge, s_pos.Y)
            end
        end

        if scr then
            if not esp then 
                esp = make_box() 
                esp_db.Boxes[p] = esp 
            end
            set_esp_vis(esp, true)

            l = math.floor(l)
            t = math.floor(t)
            r_edge = math.ceil(r_edge)
            b_edge = math.ceil(b_edge)

            local ins = (b_edge - t) * 0.04
            l = l + ins
            t = t + ins
            r_edge = r_edge - ins
            b_edge = b_edge - ins

            local w, h_val = r_edge - l, b_edge - t
            local b_top = t - 1
            local tot_h = h_val + 2

            esp.Outer.Position = UDim2.fromOffset(l - 1, b_top)
            esp.Outer.Size     = UDim2.fromOffset(w + 2, tot_h)
            esp.Main.Position  = UDim2.fromOffset(l, t)
            esp.Main.Size      = UDim2.fromOffset(w, h_val)
            esp.Inner.Position = UDim2.fromOffset(l + 1, t + 1)
            esp.Inner.Size     = UDim2.fromOffset(w - 2, h_val - 2)

            local y_o = t - 18
            if esp_db.Toggles.Name then
                esp.NameLabel.Text = p.DisplayName or p.Name
                esp.NameLabel.Position = UDim2.fromOffset(l - 1, y_o)
                esp.NameLabel.Size = UDim2.fromOffset(w + 2, 12)
                esp.NameLabel.Visible = true
                y_o = y_o - 14
            else
                esp.NameLabel.Visible = false
            end

            local bot_y = b_edge + 2
            local t_name = nil
            local p_f = rs_plrs and rs_plrs:FindFirstChild(p.Name)
            local s_f = p_f and p_f:FindFirstChild("Status")
            local g_v = s_f and s_f:FindFirstChild("GameplayVariables")
            local eq_t = g_v and g_v:FindFirstChild("EquippedTool")
            if eq_t and eq_t.Value then
                if typeof(eq_t.Value) == "Instance" then t_name = eq_t.Value.Name
                elseif typeof(eq_t.Value) == "string" and eq_t.Value ~= "" then t_name = eq_t.Value end
            end

            if t_name ~= esp.LastTool then
                esp.ToolLabel.Text = t_name or ""
                esp.LastTool = t_name
            end

            esp.ToolLabel.Visible = esp_db.Toggles.WeaponName and t_name and t_name ~= ""
            if esp.ToolLabel.Visible then
                esp.ToolLabel.Position = UDim2.fromOffset(l - 1, bot_y)
                esp.ToolLabel.Size = UDim2.fromOffset(w + 2, 14)
                bot_y = bot_y + 16
            end

            if esp_db.Toggles.Distance and lp_root then
                local dist = math.floor((lp_root.Position - r.Position).Magnitude * 0.28)
                esp.DistanceLabel.Text = dist .. "м"
                esp.DistanceLabel.Position = UDim2.fromOffset(l - 1, bot_y)
                esp.DistanceLabel.Size = UDim2.fromOffset(w + 2, 12)
                esp.DistanceLabel.Visible = true
                bot_y = bot_y + 14
            else
                esp.DistanceLabel.Visible = false
            end

            if esp_db.Toggles.HPBar or esp_db.Toggles.HPText then
                local pct = h.Health / h.MaxHealth
                local val = math.floor(h.Health)
                if esp.VisualHealth == nil then esp.VisualHealth = pct end
                esp.VisualHealth = esp.VisualHealth + (pct - esp.VisualHealth) * 0.1

                esp.HealthText.Text = tostring(val)
                local bar_w = 2
                local m_h = tot_h * (1 - esp.VisualHealth)
                local t_y = b_top + m_h + 3 - (esp.HealthText.Size.Y.Offset / 2)

                esp.HealthText.Position = UDim2.fromOffset(l - bar_w - 30, t_y)
                esp.HealthText.Size = UDim2.fromOffset(18, 10)
                esp.HealthText.Visible = esp_db.Toggles.HPText

                esp.HealthBg.Position = UDim2.fromOffset(l - bar_w - 6, b_top)
                esp.HealthBg.Size = UDim2.fromOffset(bar_w, tot_h)
                esp.HealthMask.Position = UDim2.fromOffset(0, 0)
                esp.HealthMask.Size = UDim2.fromOffset(bar_w, m_h)
                esp.HealthBg.Visible = esp_db.Toggles.HPBar
            else
                esp.HealthBg.Visible = false
                esp.HealthText.Visible = false
            end

            if esp_db.Toggles.Skeleton and esp.Lines then
                local parts = {
                    Head = c:FindFirstChild("Head"),
                    UpperTorso = c:FindFirstChild("UpperTorso"),
                    LowerTorso = c:FindFirstChild("LowerTorso"),
                    LeftUpperArm = c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm"),
                    LeftLowerArm = c:FindFirstChild("LeftLowerArm"),
                    LeftHand = c:FindFirstChild("LeftHand"),
                    RightUpperArm = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm"),
                    RightLowerArm = c:FindFirstChild("RightLowerArm"),
                    RightHand = c:FindFirstChild("RightHand"),
                    LeftUpperLeg = c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg"),
                    LeftLowerLeg = c:FindFirstChild("LeftLowerLeg"),
                    LeftFoot = c:FindFirstChild("LeftFoot"),
                    RightUpperLeg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg"),
                    RightLowerLeg = c:FindFirstChild("RightLowerLeg"),
                    RightFoot = c:FindFirstChild("RightFoot"),
                }

                local p_sc = {}
                for nm, pt in pairs(parts) do
                    if pt then
                        local pos, vs = cam:WorldToViewportPoint(pt.Position)
                        p_sc[nm] = vs and Vector2.new(pos.X, pos.Y) or nil
                    end
                end

                local l_idx = 1
                local function draw_ln(f_p, t_p)
                    if f_p and t_p then
                        local ln = esp.Lines[l_idx]
                        ln.From = f_p
                        ln.To = t_p
                        ln.Visible = true
                        l_idx = l_idx + 1
                    end
                end

                draw_ln(p_sc.Head, p_sc.UpperTorso)
                draw_ln(p_sc.UpperTorso, p_sc.LowerTorso)
                draw_ln(p_sc.UpperTorso, p_sc.LeftUpperArm)
                if p_sc.LeftLowerArm then draw_ln(p_sc.LeftUpperArm, p_sc.LeftLowerArm) end
                if p_sc.LeftHand then draw_ln(p_sc.LeftLowerArm or p_sc.LeftUpperArm, p_sc.LeftHand) end
                draw_ln(p_sc.UpperTorso, p_sc.RightUpperArm)
                if p_sc.RightLowerArm then draw_ln(p_sc.RightUpperArm, p_sc.RightLowerArm) end
                if p_sc.RightHand then draw_ln(p_sc.RightLowerArm or p_sc.RightUpperArm, p_sc.RightHand) end
                draw_ln(p_sc.LowerTorso, p_sc.LeftUpperLeg)
                if p_sc.LeftLowerLeg then draw_ln(p_sc.LeftUpperLeg, p_sc.LeftLowerLeg) end
                if p_sc.LeftFoot then draw_ln(p_sc.LeftLowerLeg or p_sc.LeftUpperLeg, p_sc.LeftFoot) end
                draw_ln(p_sc.LowerTorso, p_sc.RightUpperLeg)
                if p_sc.RightLowerLeg then draw_ln(p_sc.RightUpperLeg, p_sc.RightLowerLeg) end
                if p_sc.RightFoot then draw_ln(p_sc.RightLowerLeg or p_sc.RightUpperLeg, p_sc.RightFoot) end

                for i = l_idx, #esp.Lines do esp.Lines[i].Visible = false end
                for _, ln in ipairs(esp.Lines) do
                    ln.Color = esp_db.Colors.Skeleton
                    ln.Transparency = 1 - esp_db.Colors.SkeletonTransparency
                end
            else
                if esp and esp.Lines then
                    for _, ln in ipairs(esp.Lines) do ln.Visible = false end
                end
            end

            esp.Outer.Visible = esp_db.Toggles.Box
            esp.Main.Visible  = esp_db.Toggles.Box
            esp.Inner.Visible = esp_db.Toggles.Box
        else
            if esp then
                set_esp_vis(esp, false)
                esp.DistanceLabel.Visible = false
                esp.NameLabel.Visible     = false
                esp.HealthText.Visible    = false
                esp.HealthBg.Visible      = false
                esp.ToolLabel.Visible     = false
            end
        end
    end
end)

v_sec:AddToggle('ESPEnabled', { Text = 'Enable ESP', Default = false, Callback = function(v) esp_db.Toggles.Enabled = v end })
v_sec:AddToggle('BoxESP', { Text = 'Box ESP', Default = false, Callback = function(v) esp_db.Toggles.Box = v end }):AddColorPicker('BoxColor', { Default = Color3.new(1, 1, 1), Title = 'Box Color', Callback = function(v) esp_db.Colors.BoxMain = v; for _, e in pairs(esp_db.Boxes) do if e.MainStroke then e.MainStroke.Color = v end end end })
v_sec:AddToggle('NameESP', { Text = 'Name ESP', Default = false, Callback = function(v) esp_db.Toggles.Name = v end }):AddColorPicker('NameColor', { Default = Color3.new(1, 1, 1), Title = 'Name Color', Callback = function(v) esp_db.Colors.Name = v; for _, e in pairs(esp_db.Boxes) do if e.NameLabel then e.NameLabel.TextColor3 = v end end end })
v_sec:AddToggle('DistanceESP', { Text = 'Distance ESP', Default = false, Callback = function(v) esp_db.Toggles.Distance = v end }):AddColorPicker('DistanceColor', { Default = Color3.new(1, 1, 1), Title = 'Distance Color', Callback = function(v) esp_db.Colors.Distance = v; for _, e in pairs(esp_db.Boxes) do if e.DistanceLabel then e.DistanceLabel.TextColor3 = v end end end })
v_sec:AddToggle('HPText', { Text = 'HP Text', Default = false, Callback = function(v) esp_db.Toggles.HPText = v end }):AddColorPicker('HPTextColor', { Default = Color3.new(1, 1, 1), Title = 'HP Text Color', Callback = function(v) esp_db.Colors.HealthText = v; for _, e in pairs(esp_db.Boxes) do if e.HealthText then e.HealthText.TextColor3 = v end end end })
v_sec:AddToggle('HPBar', { Text = 'HP Bar', Default = false, Callback = function(v) esp_db.Toggles.HPBar = v end }):AddColorPicker('HPBarStart', { Default = Color3.new(1, 1, 1), Title = 'HP Bar Start', Callback = function(v) esp_db.Colors.HealthGradientStart = v; for _, e in pairs(esp_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end }):AddColorPicker('HPBarMid', { Default = Color3.fromRGB(255,255,255), Title = 'HP Bar Mid', Callback = function(v) esp_db.Colors.HealthGradientMid = v; for _, e in pairs(esp_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end }):AddColorPicker('HPBarEnd', { Default = Color3.fromRGB(255,255,255), Title = 'HP Bar End', Callback = function(v) esp_db.Colors.HealthGradientEnd = v; for _, e in pairs(esp_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end })
v_sec:AddToggle('WeaponESP', { Text = 'Weapon ESP', Default = false, Callback = function(v) esp_db.Toggles.WeaponName = v end }):AddColorPicker('WeaponColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Weapon Color', Callback = function(v) esp_db.Colors.WeaponName = v; for _, e in pairs(esp_db.Boxes) do if e.ToolLabel then e.ToolLabel.TextColor3 = v end end end })
v_sec:AddToggle('SkeletonESP', { Text = 'Skeleton ESP', Default = false, Callback = function(v) esp_db.Toggles.Skeleton = v end }):AddColorPicker('SkeletonColor', { Default = Color3.new(1, 1, 1), Title = 'Skeleton Color', Callback = function(v) esp_db.Colors.Skeleton = v end })

local ch_en = false
local gl_en = false
local ch_col = Color3.fromRGB(255, 255, 255)
local gl_col = Color3.fromRGB(0, 0, 0)

local function rem_ad(p)
    if not p then return end
    for _, o in ipairs(p:GetChildren()) do
        if o.Name == "Chams" or o.Name == "Glow" then o:Destroy() end
    end
end

local function make_ad(p, t, col, tr, zi, sz, ex)
    ex = ex or {}
    local ad
    if t == "Cylinder" then
        ad = Instance.new("CylinderHandleAdornment")
        ad.Height = p.Size.Y + (ex.HeightOffset or 0)
        ad.Radius = (p.Size.X * 0.5) + (ex.RadiusOffset or 0)
        ad.CFrame = CFrame.new(Vector3.zero, Vector3.new(0, 1, 0))
    elseif t == "Box" then
        ad = Instance.new("BoxHandleAdornment")
        ad.Size = p.Size + (sz or Vector3.zero)
    end
    ad.Name = "Chams"
    ad.AlwaysOnTop = true
    ad.ZIndex = zi
    ad.Adornee = p
    ad.Color3 = col
    ad.Transparency = tr or 0
    if ex.Shading then ad.Shading = ex.Shading end
    ad.Parent = p
    return ad
end

local function apply_chams_to_char(char)
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            rem_ad(part)
            local is_h = part.Name == "Head" or part.Name == "FakeHead"
            if ch_en then
                make_ad(part, is_h and "Cylinder" or "Box", Color3.new(ch_col.R * 5, ch_col.G * 5, ch_col.B * 5), -1, is_h and 10 or 9, Vector3.new(0.03, 0.03, 0.03), { Shading = Enum.AdornShading.XRayShaded })
            end
            if gl_en then
                make_ad(part, is_h and "Cylinder" or "Box", gl_col, 0.3, 10, Vector3.new(0.02, 0.02, 0.02))
            end
        end
    end
end

local function update_chams_all()
    if not (ch_en or gl_en) then
        for _, p in ipairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, pt in ipairs(p.Character:GetChildren()) do
                    if pt:IsA("BasePart") then rem_ad(pt) end
                end
            end
        end
        return
    end
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character then
            apply_chams_to_char(p.Character)
        end
    end
end

plrs.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        if ch_en or gl_en then
            task.wait(0.5)
            apply_chams_to_char(c)
        end
    end)
end)

v_sec:AddToggle('ChamsToggle', { Text = 'Player Chams', Default = false, Callback = function(v) ch_en = v; update_chams_all() end }):AddColorPicker('ChamsColorPicker', { Default = ch_col, Title = 'Chams Color', Callback = function(v) ch_col = v; update_chams_all() end })
v_sec:AddToggle('GlowToggle', { Text = 'Glow', Default = false, Callback = function(v) gl_en = v; update_chams_all() end }):AddColorPicker('GlowColorPicker', { Default = gl_col, Title = 'Glow Color', Callback = function(v) gl_col = v; update_chams_all() end })

local hs_db = { Enabled = true, Volume = 1, SoundId = "rbxassetid://1255040462" }
local sounds = { Rust = "rbxassetid://1255040462", Gamesense = "rbxassetid://4817809188", Neverlose = "rbxassetid://8726881116", Bubble = "rbxassetid://198598793", Ding = "rbxassetid://2868331684", Bruh = "rbxassetid://4275842574", ["CS 1.6"] = "rbxassetid://18362692980", ["Windows XP"] = "rbxassetid://130840811", Discord = "rbxassetid://6501486918", TeamFortress = "rbxassetid://296102734", Toilet = "rbxassetid://8430024127", FAAHH = "rbxassetid://72298953503422" }

local function play_hs()
    if not hs_db.Enabled then return end
    local s = Instance.new("Sound")
    s.SoundId = hs_db.SoundId
    s.Volume = hs_db.Volume
    s.Parent = ws
    s:Play()
    task.delay(1, function() s:Destroy() end)
end

local function setup_hs()
    local function hook_s(s)
        if not s:IsA("Sound") or not hs_db.Enabled then return end
        local sid = s.SoundId or ""
        if sid:find("4585382589") or sid:find("4585351098") or sid:find("4585382046") or sid:find("4585364605") then
            s.SoundId = hs_db.SoundId
            s.Volume = hs_db.Volume
        end
    end
    local function wait_g()
        local g = lp.PlayerGui:WaitForChild("MainGui", 10)
        if g then
            g.ChildAdded:Connect(hook_s)
            for _, v in ipairs(g:GetChildren()) do hook_s(v) end
        end
    end
    task.spawn(wait_g)
    lp.CharacterAdded:Connect(function()
        task.wait(0.5)
        local g = lp.PlayerGui:FindFirstChild("MainGui")
        if g then for _, v in ipairs(g:GetChildren()) do hook_s(v) end end
    end)
end
setup_hs()

hs_sec:AddToggle("HitSoundEnabled", { Text = "Enable HitSound", Default = true, Callback = function(v) hs_db.Enabled = v end })
hs_sec:AddSlider("HitSoundVolume", { Text = "HitSound Volume", Default = 100, Min = 0, Max = 1000, Rounding = 0, Callback = function(v) hs_db.Volume = v / 100 end })
hs_sec:AddDropdown("HitSoundSelect", { Text = "Select HitSound", Values = {"Rust", "Gamesense", "Neverlose", "Bubble", "Ding", "Bruh", "CS 1.6", "Windows XP", "Discord", "TeamFortress", "Toilet", "FAAHH"}, Default = "Rust", Callback = function(v) if sounds[v] then hs_db.SoundId = sounds[v] end end })
hs_sec:AddButton("Test HitSound", play_hs)

local function init()
    task.wait(1)
    local p_f = rep.Players:FindFirstChild(lp.Name)
    if p_f then
        local inv = p_f:FindFirstChild("Inventory")
        if inv then
            for _, g in ipairs(inv:GetChildren()) do save_gun(g) end
        end
    end
    upd_rapid()
    upd_recoil()
    setup_eq()
end
task.spawn(init)

rep.ChildAdded:Connect(function(c)
    if c.Name == lp.Name then
        c.ChildAdded:Connect(function(inv_c)
            if inv_c.Name == "Inventory" then
                inv_c.ChildAdded:Connect(function(g)
                    task.wait(0.1)
                    save_gun(g)
                    upd_rapid()
                end)
            end
        end)
    end
end)

local cr_db = { Toggle = false, NameColor = Color3.new(1, 1, 1), DistColor = Color3.new(0.7, 1, 0.7), Distance = 200 }
local cr_list = {}
local cr_esp = {}

local function find_containers()
    local f = ws:FindFirstChild("Containers")
    if f then
        local res = {}
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("BasePart") or c:IsA("Model") then table.insert(res, c) end
        end
        cr_list = res
    end
end
find_containers()

local function get_cr_pos(o)
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then return o.PrimaryPart and o.PrimaryPart.Position or o:GetPivot().Position end
    return nil
end

local function get_cr_name(o)
    if o:IsA("Model") then return o.Name end
    local p = o.Parent
    return (p and (p:IsA("Model") or p:IsA("Folder"))) and p.Name or o.Name
end

local function make_cr_esp(o)
    local n_t = Drawing.new("Text")
    n_t.Size = 14
    n_t.Font = Drawing.Fonts.UI
    n_t.Color = cr_db.NameColor
    n_t.Outline = true
    n_t.OutlineColor = Color3.new(0,0,0)
    n_t.Center = true

    local d_t = Drawing.new("Text")
    d_t.Size = 12
    d_t.Font = Drawing.Fonts.UI
    d_t.Color = cr_db.DistColor
    d_t.Outline = true
    d_t.OutlineColor = Color3.new(0,0,0)
    d_t.Center = true
    cr_esp[o] = { n_t, d_t }
end

local function rem_cr_esp(o)
    local t = cr_esp[o]
    if t then
        t[1]:Remove()
        t[2]:Remove()
        cr_esp[o] = nil
    end
end

rs.RenderStepped:Connect(function()
    if not cr_db.Toggle then
        for _, t in pairs(cr_esp) do t[1].Visible = false; t[2].Visible = false end
        return
    end
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then
        for _, t in pairs(cr_esp) do t[1].Visible = false; t[2].Visible = false end
        return
    end
    local r_pos = r.Position
    local m_d = cr_db.Distance

    for o, t in pairs(cr_esp) do
        if not o or not o.Parent then rem_cr_esp(o) end
    end

    for _, cr in ipairs(cr_list) do
        if not cr or not cr.Parent then continue end
        local pos = get_cr_pos(cr)
        if not pos then continue end
        local d = (pos - r_pos).Magnitude
        if d > m_d then
            local t = cr_esp[cr]
            if t then t[1].Visible = false; t[2].Visible = false end
            continue
        end

        if not cr_esp[cr] then make_cr_esp(cr) end
        local t = cr_esp[cr]
        local s_pos, vis = cam:WorldToViewportPoint(pos)
        if vis then
            t[1].Position = Vector2.new(s_pos.X, s_pos.Y - 25)
            t[1].Text = get_cr_name(cr)
            t[1].Visible = true
            t[2].Position = Vector2.new(s_pos.X, s_pos.Y - 10)
            t[2].Text = string.format("%.1f м", d)
            t[2].Visible = true
        else
            t[1].Visible = false
            t[2].Visible = false
        end
    end
end)

o_sec:AddToggle('CrateESP', { Text = 'crate ESP', Default = false, Callback = function(v) cr_db.Toggle = v end })
:AddColorPicker('CrateNameColor', { Default = cr_db.NameColor, Title = 'Name Color', Callback = function(v) cr_db.NameColor = v; for _, t in pairs(cr_esp) do t[1].Color = v end end })
:AddColorPicker('CrateDistColor', { Default = cr_db.DistColor, Title = 'Distance Color', Callback = function(v) cr_db.DistColor = v; for _, t in pairs(cr_esp) do t[2].Color = v end end })

local dc_db = { Enabled = false, Transparency = 0.5, Color = Color3.fromRGB(255, 100, 100), Duration = 3, Material = "ForceField" }
local dc_models = {}

local function play_d_s(pos)
    if not pos then return end
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://1255040462"
    s.Volume = 5
    s.RollOffMode = Enum.RollOffMode.Linear
    s.MaxDistance = 250
    s.MinDistance = 10
    
    local sp = Instance.new("Part")
    sp.Anchored = true
    sp.CanCollide = false
    sp.Transparency = 1
    sp.Size = Vector3.new(1, 1, 1)
    sp.Position = pos
    sp.Parent = ws
    s.Parent = sp
    s:Play()
    task.delay(5, function() sp:Destroy() end)
end

local function make_dc(char, pos)
    if not char or not pos then return end
    play_d_s(pos)
    char.Archivable = true
    local cl = char:Clone()
    char.Archivable = false
    cl.Parent = ws
    cl:SetPrimaryPartCFrame(CFrame.new(pos))
    for _, pt in ipairs(cl:GetDescendants()) do
        if pt:IsA("BasePart") or pt:IsA("MeshPart") then
            pt.Anchored = true
            pt.CanCollide = false
            pt.Material = Enum.Material[dc_db.Material]
            pt.Color = dc_db.Color
            pt.Transparency = dc_db.Transparency
            for _, d in ipairs(pt:GetChildren()) do
                if d:IsA("Decal") or d:IsA("SurfaceAppearance") then d:Destroy() end
            end
        end
    end
    local h = cl:FindFirstChildOfClass("Humanoid")
    if h then h:Destroy() end
    table.insert(dc_models, cl)
    task.delay(dc_db.Duration, function()
        if cl and cl.Parent then
            cl:Destroy()
            local idx = table.find(dc_models, cl)
            if idx then table.remove(dc_models, idx) end
        end
    end)
end

local last_hp = {}
local last_pos = {}

task.spawn(function()
    while task.wait(0.15) do
        if dc_db.Enabled then
            for _, p in ipairs(plrs:GetPlayers()) do
                if p ~= lp then
                    local c = p.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h then
                        local cur_hp = h.Health
                        local l_hp = last_hp[p]
                        local l_p = last_pos[p]
                        if l_hp and l_hp > 0 and cur_hp <= 0 then
                            local r = c:FindFirstChild("HumanoidRootPart")
                            if r then make_dc(c, r.Position)
                            elseif l_p then make_dc(c, l_p) end
                        end
                        if cur_hp > 0 then
                            local r = c:FindFirstChild("HumanoidRootPart")
                            if r then last_pos[p] = r.Position end
                        end
                        last_hp[p] = cur_hp
                    end
                end
            end
        end
    end
end)

o_sec:AddToggle('DeathChams', { Text = 'Death Chams', Default = false, Callback = function(v) dc_db.Enabled = v end })

local exit_en = false
local exit_col = Color3.fromRGB(0, 255, 0)
local active_ex = {}

local function make_exit(pt)
    local t = Drawing.new("Text")
    t.Visible = false
    t.Color = exit_col
    t.Text = "EXIT"
    t.Size = 18
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Font = 2
    active_ex[t] = pt

    local cn
    cn = rs.RenderStepped:Connect(function()
        if not exit_en or not pt or not pt:IsDescendantOf(ws) then
            t.Visible = false
            if not pt or not pt:IsDescendantOf(ws) then
                t:Remove()
                active_ex[t] = nil
                cn:Disconnect()
            end
            return
        end
        local vec, vis = cam:WorldToViewportPoint(pt.Position)
        if vis then
            t.Position = Vector2.new(vec.X, vec.Y)
            t.Visible = true
        else
            t.Visible = false
        end
    end)
end

local function scan_exits()
    for _, o in ipairs(ws:GetDescendants()) do
        if o:IsA("Part") or o:IsA("MeshPart") then
            local nm = o.Name:lower()
            if nm:find("extract") or nm:find("exit") or nm:find("exfil") then make_exit(o) end
        end
    end
end
scan_exits()

local corp_en = false
local corp_col = Color3.new(1,1,1)
local corp_sz = 14
local corp_dist = 500
local corp_cache = {}

local function make_corp(o)
    if not corp_en or corp_cache[o] then return end
    local r = o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Torso") or o.PrimaryPart
    if r and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        if (lp.Character.HumanoidRootPart.Position - r.Position).Magnitude > corp_dist then return end
    end
    local bg = Instance.new("BillboardGui")
    local tx = Instance.new("TextLabel")
    local st = Instance.new("UIStroke")

    bg.Name = "CorpseESP"
    bg.Adornee = o
    bg.Size = UDim2.new(0, 100, 0, 25)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0, 2.2, 0)
    bg.Parent = o

    tx.Size = UDim2.new(1, 0, 1, 0)
    tx.BackgroundTransparency = 1
    tx.Text = "DEAD"
    tx.TextColor3 = corp_col
    tx.TextSize = corp_sz
    tx.Font = Enum.Font.GothamBold
    tx.Parent = bg

    st.Color = Color3.new(0,0,0)
    st.Thickness = 1.5
    st.Parent = tx
    corp_cache[o] = bg
end

task.spawn(function()
    while task.wait(1.5) do
        if corp_en then
            for o, bg in pairs(corp_cache) do
                if not o or not o.Parent then corp_cache[o] = nil end
            end
            for _, o in ipairs(ws:GetChildren()) do
                if o:IsA("Model") then
                    local nm = o.Name:lower()
                    if nm:find("corpse") or nm:find("ragdoll") or nm:find("dead") then
                        pcall(make_corp, o)
                    else
                        local h = o:FindFirstChild("Humanoid")
                        if h and h.Health <= 0 then pcall(make_corp, o) end
                    end
                end
            end
        end
    end
end)

o_sec:AddToggle('exit_esp_toggle', { Text = 'Exit ESP', Default = false, Callback = function(v) exit_en = v end })
:AddColorPicker('exit_esp_color', { Default = exit_col, Title = 'Exit ESP Color', Callback = function(c) exit_col = c; for l, _ in pairs(active_ex) do l.Color = c end end })

o_sec:AddToggle('corpse_esp_toggle', { Text = 'Corpse ESP', Default = false, Callback = function(v) corp_en = v; if not v then for _, bg in pairs(corp_cache) do bg:Destroy() end table.clear(corp_cache) end end })
:AddColorPicker('corpse_esp_color', { Default = corp_col, Title = 'Corpse ESP Color', Callback = function(c) corp_col = c; for _, bg in pairs(corp_cache) do local tx = bg:FindFirstChildOfClass("TextLabel") if tx then tx.TextColor3 = c end end end })
o_sec:AddSlider('corpse_esp_distance', { Text = 'Corpse Max Distance', Default = 500, Min = 50, Max = 2000, Rounding = 0, Callback = function(v) corp_dist = v end })
o_sec:AddSlider('corpse_esp_textsize', { Text = 'Corpse Text Size', Default = 14, Min = 8, Max = 30, Rounding = 0, Callback = function(v) corp_sz = v; for _, bg in pairs(corp_cache) do local tx = bg:FindFirstChildOfClass("TextLabel") if tx then tx.TextSize = v end end end })
o_sec:AddButton('Unlock Boss', function()
    local p_f = rep.Players:FindFirstChild(lp.Name)
    if p_f then
        local q = p_f.Status.Journey.Quests
        local b = q:FindFirstChild("BossFirst")
        if not b then
            local n_b = Instance.new("Folder")
            n_b.Name = "BossFirst"
            n_b:SetAttribute("State", "Complete")
            n_b.Parent = q
        else b:SetAttribute("State", "Complete") end
    end
end)

local gun_cham = false
local arm_cham = false
local g_col = Color3.fromRGB(255, 255, 255)
local g_mat = "ForceField"
local a_col = Color3.fromRGB(255, 255, 255)
local a_mat = "ForceField"

local mats = { ForceField = Enum.Material.ForceField, Neon = Enum.Material.Neon, SmoothPlastic = Enum.Material.SmoothPlastic, Glass = Enum.Material.Glass, Plastic = Enum.Material.Plastic, Wood = Enum.Material.Wood, Metal = Enum.Material.Metal }

local function apply_vm_chams()
    local vm = cam:FindFirstChildOfClass("Model")
    if not vm then return end
    local item = vm:FindFirstChild("Item")
    if gun_cham and item then
        for _, pt in ipairs(item:GetDescendants()) do
            if pt:IsA("BasePart") then
                pt.Material = mats[g_mat] or Enum.Material.ForceField
                pt.Color = g_col
                local sa = pt:FindFirstChildOfClass("SurfaceAppearance")
                if sa then sa:Destroy() end
            end
        end
    end
    if arm_cham then
        for _, pt in ipairs(vm:GetChildren()) do
            if pt:IsA("BasePart") then
                if pt.Name:find("Hand") or pt.Name:find("Arm") then
                    pt.Material = mats[a_mat] or Enum.Material.ForceField
                    pt.Color = a_col
                end
            elseif pt.ClassName == "Model" and (pt:FindFirstChild("LL") or pt:FindFirstChild("LH")) then
                for _, s_it in ipairs(pt:GetChildren()) do
                    if s_it:IsA("BasePart") then
                        s_it.Material = mats[a_mat] or Enum.Material.ForceField
                        s_it.Color = a_col
                        local sa = s_it:FindFirstChildOfClass("SurfaceAppearance")
                        if sa then sa:Destroy() end
                    end
                end
            end
        end
    end
end

cam.ChildAdded:Connect(function(c)
    if c:IsA("Model") and c.Name == "ViewModel" then
        task.wait(0.05)
        apply_vm_chams()
    end
end)

local gunChamsToggle = arm_sec:AddToggle('GunChams', { Text = 'Gun Chams', Default = false, Callback = function(v) gun_cham = v; apply_vm_chams() end })
gunChamsToggle:AddColorPicker('GunChamsColor', { Text = 'Gun Color', Default = g_col, Callback = function(v) g_col = v; apply_vm_chams() end })
arm_sec:AddDropdown('GunChamsMaterial', { Text = 'Gun Material', Values = {"ForceField", "Neon", "SmoothPlastic", "Glass", "Plastic", "Wood", "Metal"}, Default = "ForceField", Callback = function(v) g_mat = v; apply_vm_chams() end })

local armsChamsToggle = arm_sec:AddToggle('ArmsChams', { Text = 'Arms Chams', Default = false, Callback = function(v) arm_cham = v; apply_vm_chams() end })
armsChamsToggle:AddColorPicker('ArmsChamsColor', { Text = 'Arms Color', Default = a_col, Callback = function(v) a_col = v; apply_vm_chams() end })
arm_sec:AddDropdown('ArmsChamsMaterial', { Text = 'Arms Material', Values = {"ForceField", "Neon", "SmoothPlastic", "Glass", "Plastic", "Wood", "Metal"}, Default = "ForceField", Callback = function(v) a_mat = v; apply_vm_chams() end })

local vm_db = { Enabled = false, Offset = Vector3.zero }

local function get_vm_root(m)
    if not m then return nil end
    local r = m:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then return r end
    for _, c in ipairs(m:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

local function apply_vm_offset(m)
    if not m or not vm_db.Enabled then return end
    local r = get_vm_root(m)
    if r then
        r.CFrame = r.CFrame + cam.CFrame:VectorToWorldSpace(vm_db.Offset)
    end
end

local function apply_offset_all()
    for _, c in ipairs(cam:GetChildren()) do
        if c:IsA("Model") and c.Name == "ViewModel" then apply_vm_offset(c) end
    end
end

local vm_cn
arm_sec:AddToggle('VMEnabled', { Text = 'Enable Viewmodel Offset', Default = false, Callback = function(v) vm_db.Enabled = v; if v then vm_cn = rs.RenderStepped:Connect(apply_offset_all) else if vm_cn then vm_cn:Disconnect() end end end })
arm_sec:AddSlider('VM_X', { Text = 'Offset X (Left/Right)', Default = 0, Min = -5, Max = 5, Rounding = 2, Callback = function(v) vm_db.Offset = Vector3.new(v, vm_db.Offset.Y, vm_db.Offset.Z) end })
arm_sec:AddSlider('VM_Y', { Text = 'Offset Y (Up/Down)', Default = 0, Min = -5, Max = 5, Rounding = 2, Callback = function(v) vm_db.Offset = Vector3.new(vm_db.Offset.X, v, vm_db.Offset.Z) end })
arm_sec:AddSlider('VM_Z', { Text = 'Offset Z (Forward/Back)', Default = 0, Min = -5, Max = 5, Rounding = 2, Callback = function(v) vm_db.Offset = Vector3.new(vm_db.Offset.X, vm_db.Offset.Y, v) end })

local tp_en = false
local tp_bind = false
local tp_dist = 10
local old_idx

old_idx = hookmetamethod(game, "__newindex", function(self, idx, val)
    if self == cam and idx == "CFrame" and tp_en and tp_bind then
        val = val + (val.LookVector * -tp_dist)
    end
    return old_idx(self, idx, val)
end)

local tpToggle = char_sec:AddToggle('Thirdperson', { Text = 'Third Person', Default = false, Callback = function(v) tp_en = v end })
tpToggle:AddKeyPicker('ThirdpersonKeybind', { Text = 'Thirdperson Keybind', Default = '', Mode = 'Toggle', Callback = function(v) tp_bind = tp_en and v end })
char_sec:AddSlider('ThirdpersonDistance', { Text = 'Distance', Default = 10, Min = 0, Max = 20, Rounding = 1, Suffix = 'studs', Callback = function(v) tp_dist = v end })

local spin_en = false
local spin_spd = 90
local look_up_ang = -70
local cur_ang = 0
local cur_char = nil
local aa_cn = nil

local function run_spin(char, delta)
    local h = char:FindFirstChildOfClass("Humanoid")
    local r = char:FindFirstChild("HumanoidRootPart")
    local hd = char:FindFirstChild("Head")
    if h and r and h.Health > 0 then
        h.AutoRotate = false
        cur_ang = (cur_ang + (spin_spd * delta)) % 360
        r.CFrame = CFrame.lookAt(r.Position, r.Position + Vector3.new(math.sin(math.rad(cur_ang)), 0, math.cos(math.rad(cur_ang))))
        if hd then
            local n = char:FindFirstChild("Neck", true)
            if n and n:IsA("Motor6D") then
                n.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(look_up_ang), 0, 0)
            end
        end
    end
end

aa_sec:AddToggle('SpinEnabled', { Text = 'Spin', Default = false, Risky = true, Callback = function(v) spin_en = v; if v then aa_cn = rs.Heartbeat:Connect(function(d) if lp.Character then run_spin(lp.Character, d) end end) else if aa_cn then aa_cn:Disconnect() end if lp.Character then local h = lp.Character:FindFirstChildOfClass("Humanoid") if h then h.AutoRotate = true end end end end })
aa_sec:AddSlider('SpinSpeed', { Text = 'Spin Speed', Default = 90, Min = 30, Max = 2000, Rounding = 0, Suffix = '°/s', Callback = function(v) spin_spd = v end })

local speed_db = { Enabled = false, Speed = 23 }
local speed_active = false

local function set_ws_speed()
    local c = lp.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = speed_db.Enabled and speed_db.Speed or 16 end
end

char_sec:AddToggle('SpeedHack', { Text = 'Speed Hack', Default = false, Risky = true, Callback = function(v) speed_db.Enabled = v; if v then speed_active = true; task.spawn(function() while speed_active do set_ws_speed() task.wait(0.5) end end) else speed_active = false; set_ws_speed() end end })
char_sec:AddSlider('SpeedValue', { Text = 'Speed', Default = 23, Min = 16, Max = 24, Rounding = 1, Suffix = 'sps', Callback = function(v) speed_db.Speed = v; set_ws_speed() end })

local res_db = { Enabled = false, Velocity = 2500, Delay = 0.05, Offset = 20, Resolving = false }
local is_froz = false

local function run_resolve()
    if res_db.Resolving then return end
    res_db.Resolving = true
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then res_db.Resolving = false; return end
    local cached = r.CFrame
    r.Velocity = Vector3.new(0, res_db.Velocity, 0)
    task.wait(res_db.Delay)
    r.Anchored = true
    r.CFrame = cached + Vector3.new(0, res_db.Offset, 0)
    is_froz = true
    while res_db.Enabled and is_froz do
        task.wait(0.1)
        if r and r.Anchored then
            r.CFrame = cached + Vector3.new(0, res_db.Offset, 0)
            r.Velocity = Vector3.zero
        end
    end
    if r then
        r.Anchored = false
        r.CFrame = cached
        r.Velocity = Vector3.zero
    end
    is_froz = false
    res_db.Resolving = false
end

local resolve_tog = char_sec:AddToggle('AnchoredResolve', { Text = 'Anchored Resolve (Freeze)', Default = false, Risky = true, Callback = function(v) res_db.Enabled = v; if v then task.spawn(run_resolve) end end })
char_sec:AddLabel('Keybind'):AddKeyPicker('AnchoredResolveKeybind', { Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Anchored Resolve Keybind', Callback = function(v) resolve_tog:SetValue(v) end })

local fly_db = { Enabled = false, Speed = 10, YSpeed = 10 }
local fly_tog = char_sec:AddToggle('Fly', { Text = 'Fly', Default = false, Callback = function(v) fly_db.Enabled = v end })
char_sec:AddLabel('Keybind'):AddKeyPicker('FlyKeybind', { Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Fly Keybind', Callback = function(v) fly_tog:SetValue(v) end })
char_sec:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 10, Min = 1, Max = 30, Rounding = 1, Suffix = 'studs/s', Callback = function(v) fly_db.Speed = v end })
char_sec:AddSlider('FlyYSpeed', { Text = 'Y Fly Speed', Default = 10, Min = 1, Max = 30, Rounding = 1, Suffix = 'studs/s', Callback = function(v) fly_db.YSpeed = v end })

rs.Heartbeat:Connect(function(d)
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if fly_db.Enabled and r then
        local look = cam.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z)
        local h_dir = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then h_dir = h_dir + look end
        if uis:IsKeyDown(Enum.KeyCode.S) then h_dir = h_dir - look end
        if uis:IsKeyDown(Enum.KeyCode.D) then h_dir = h_dir + Vector3.new(-look.Z, 0, look.X) end
        if uis:IsKeyDown(Enum.KeyCode.A) then h_dir = h_dir + Vector3.new(look.Z, 0, -look.X) end
        local v_dir = 0
        if uis:IsKeyDown(Enum.KeyCode.Space) then v_dir = v_dir + 1 end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then v_dir = v_dir - 1 end
        if h_dir ~= Vector3.zero then r.CFrame = r.CFrame + h_dir.Unit * d * fly_db.Speed end
        if v_dir ~= 0 then r.CFrame = r.CFrame + Vector3.yAxis * v_dir * d * fly_db.YSpeed end
        for _, pt in ipairs(c:GetDescendants()) do
            if pt:IsA("BasePart") then pt.AssemblyLinearVelocity = Vector3.zero end
        end
    end
end)

local tele_settings = { SelectedObject = "None" }

local function tele_to_me(obj)
    if obj == "None" then return false end
    local tar = ws:FindFirstChild(obj)
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not tar or not r then return false end
    local dest = r.Position + Vector3.new(0, 2, 0)
    if tar:IsA("BasePart") then tar.CFrame = CFrame.new(dest)
    elseif tar:IsA("Model") then
        if tar.PrimaryPart then tar:SetPrimaryPartCFrame(CFrame.new(dest))
        else
            local hr = tar:FindFirstChild("HumanoidRootPart")
            if hr then hr.CFrame = CFrame.new(dest) end
        end
    end
    local fx = Instance.new("Part")
    fx.Size = Vector3.new(3, 3, 3)
    fx.Position = dest
    fx.Anchored = true
    fx.CanCollide = false
    fx.Material = Enum.Material.Neon
    fx.Color = Color3.fromRGB(255, 100, 0)
    fx.Transparency = 0.3
    fx.Parent = ws
    task.delay(0.5, function() fx:Destroy() end)
    return true
end

char_sec:AddDropdown('TeleportObject', { Text = 'Select Object to Teleport', Values = {"None", "Blaze", "Mihkel", "Designer", "Tarmo", "VaultManager"}, Default = "None", Callback = function(v) tele_settings.SelectedObject = v end })
char_sec:AddButton({ Text = 'Teleport Bot', Func = function() tele_to_me(tele_settings.SelectedObject) end })

local pitch_db = { Enabled = false, Value = 0 }
local update_tilt = nil

local function get_tilt()
    local r = rep:FindFirstChild("Remotes")
    if r then update_tilt = r:FindFirstChild("UpdateTilt") end
end
get_tilt()
rep.DescendantAdded:Connect(get_tilt)

rs.RenderStepped:Connect(function()
    if pitch_db.Enabled and update_tilt then
        pcall(function() update_tilt:FireServer(pitch_db.Value, 0, nil, 0) end)
    end
end)

rs.Heartbeat:Connect(function()
    if lp.Character then
        local h = lp.Character:FindFirstChildWhichIsA("Humanoid")
        if h then h.AutoRotate = not pitch_db.Enabled end
    end
end)

aa_sec:AddToggle('PitchModifier', { Text = 'Pitch Modifier', Default = false, Callback = function(v) pitch_db.Enabled = v end })
aa_sec:AddSlider('PitchValue', { Text = 'Pitch Value', Default = 0, Min = -1, Max = 1, Rounding = 2, Callback = function(v) pitch_db.Value = v end })

local bot_db = {
    Toggles = { Enabled = false, Box = false, Name = false, Distance = false, HPBar = false, HPText = false },
    Colors = { BoxMain = Color3.fromRGB(255, 50, 50), Name = Color3.new(1, 1, 1), Distance = Color3.new(1, 1, 1), HealthText = Color3.new(1, 1, 1), HealthGradientStart = Color3.fromRGB(255, 50, 50), HealthGradientMid = Color3.fromRGB(255, 100, 0), HealthGradientEnd = Color3.fromRGB(255, 0, 0), HealthMask = Color3.new(0, 0, 0), HealthMaskTransparency = 0.3 },
    Boxes = {}
}

local bot_g = Instance.new("ScreenGui")
bot_g.DisplayOrder = 9e9
bot_g.ResetOnSpawn = false
bot_g.Parent = gethui and gethui() or cg
bot_g.Enabled = false

local function clean_bot(b)
    if bot_db.Boxes[b] then
        for _, obj in pairs(bot_db.Boxes[b]) do
            if typeof(obj) == "Instance" then obj:Destroy() end
        end
        bot_db.Boxes[b] = nil
    end
end

local function get_bots()
    local res = {}
    local az = ws:FindFirstChild("AiZones")
    if az then
        for _, z in ipairs(az:GetChildren()) do
            for _, b in ipairs(z:GetChildren()) do
                if b:IsA("Model") and b:FindFirstChildOfClass("Humanoid") then table.insert(res, b) end
            end
        end
    end
    return res
end

local function make_bot_box()
    local b = {}
    local n = {"Outer", "Main", "Inner"}
    for i = 1, 3 do
        local f = Instance.new("Frame")
        f.Name = n[i]
        f.BackgroundTransparency = 1
        f.Parent = bot_g
        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Parent = f
        b[n[i]] = f
        b[n[i] .. "Stroke"] = s
    end
    b.OuterStroke.Color = Color3.new(0, 0, 0)
    b.MainStroke.Color  = bot_db.Colors.BoxMain
    b.InnerStroke.Color = Color3.new(0, 0, 0)

    local h_bg = Instance.new("Frame")
    h_bg.Name = "HealthBg"
    h_bg.BackgroundTransparency = 0
    h_bg.BorderSizePixel = 0
    h_bg.Parent = bot_g
    local gr = Instance.new("UIGradient")
    gr.Rotation = 90
    gr.Parent = h_bg

    local function upd_g()
        gr.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, bot_db.Colors.HealthGradientStart),
            ColorSequenceKeypoint.new(0.5, bot_db.Colors.HealthGradientMid),
            ColorSequenceKeypoint.new(1, bot_db.Colors.HealthGradientEnd)
        })
    end
    upd_g()
    b.UpdateGradient = upd_g

    local h_msk = Instance.new("Frame")
    h_msk.Name = "HealthMask"
    h_msk.BackgroundColor3 = bot_db.Colors.HealthMask
    h_msk.BackgroundTransparency = bot_db.Colors.HealthMaskTransparency
    h_msk.BorderSizePixel = 0
    h_msk.Parent = h_bg
    h_msk.ZIndex = h_bg.ZIndex + 1

    local h_s = Instance.new("UIStroke")
    h_s.Color = Color3.new(0,0,0)
    h_s.Thickness = 1
    h_s.Parent = h_bg

    local nl = Instance.new("TextLabel")
    nl.Name = "NameLabel"
    nl.BackgroundTransparency = 1
    nl.TextSize = 12
    nl.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.new(0,0,0)
    nl.Parent = bot_g
    nl.TextColor3 = bot_db.Colors.Name

    local ht = Instance.new("TextLabel")
    ht.Name = "HealthText"
    ht.BackgroundTransparency = 1
    ht.TextSize = 10
    ht.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    ht.TextStrokeTransparency = 0
    ht.TextStrokeColor3 = Color3.new(0,0,0)
    ht.TextXAlignment = Enum.TextXAlignment.Right
    ht.Parent = bot_g
    ht.TextColor3 = bot_db.Colors.HealthText

    local dl = Instance.new("TextLabel")
    dl.Name = "DistanceLabel"
    dl.BackgroundTransparency = 1
    dl.TextSize = 12
    dl.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    dl.TextStrokeTransparency = 0
    dl.TextStrokeColor3 = Color3.new(0,0,0)
    dl.TextXAlignment = Enum.TextXAlignment.Center
    dl.Parent = bot_g
    dl.TextColor3 = bot_db.Colors.Distance

    b.HealthBg = h_bg
    b.HealthMask = h_msk
    b.NameLabel = nl
    b.HealthText = ht
    b.DistanceLabel = dl
    return b
end

rs.Heartbeat:Connect(function()
    if not bot_db.Toggles.Enabled then
        if bot_g.Enabled then bot_g.Enabled = false end
        return
    end
    bot_g.Enabled = true
    local lp_char = lp.Character
    local lp_root = lp_char and lp_char:FindFirstChild("HumanoidRootPart")
    if not lp_root then return end

    local bots = get_bots()
    local proc = {}

    for _, bot in ipairs(bots) do
        local h = bot:FindFirstChildOfClass("Humanoid")
        local r = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
        if not r or not h or h.Health <= 0 then
            if bot_db.Boxes[bot] then clean_bot(bot) end
            continue
        end

        proc[bot] = true
        local esp = bot_db.Boxes[bot]
        local cf, sz = bot:GetBoundingBox()
        if not cf then
            if esp then clean_bot(bot) end
            continue
        end

        local h_sz = sz / 2
        local corners = {
            cf * Vector3.new(h_sz.X, h_sz.Y, h_sz.Z),
            cf * Vector3.new(h_sz.X, h_sz.Y, -h_sz.Z),
            cf * Vector3.new(h_sz.X, -h_sz.Y, h_sz.Z),
            cf * Vector3.new(h_sz.X, -h_sz.Y, -h_sz.Z),
            cf * Vector3.new(-h_sz.X, h_sz.Y, h_sz.Z),
            cf * Vector3.new(-h_sz.X, h_sz.Y, -h_sz.Z),
            cf * Vector3.new(-h_sz.X, -h_sz.Y, h_sz.Z),
            cf * Vector3.new(-h_sz.X, -h_sz.Y, -h_sz.Z)
        }

        local l, t = math.huge, math.huge
        local r_edge, b_edge = -math.huge, -math.huge
        local scr = false

        for i = 1, 8 do
            local s_pos, vis = cam:WorldToScreenPoint(corners[i])
            if vis then
                scr = true
                l = math.min(l, s_pos.X)
                t = math.min(t, s_pos.Y)
                r_edge = math.max(r_edge, s_pos.X)
                b_edge = math.max(b_edge, s_pos.Y)
            end
        end

        if scr then
            if not esp then 
                esp = make_bot_box() 
                bot_db.Boxes[bot] = esp 
            end
            esp.Outer.Visible = bot_db.Toggles.Box
            esp.Main.Visible  = bot_db.Toggles.Box
            esp.Inner.Visible = bot_db.Toggles.Box

            l = math.floor(l)
            t = math.floor(t)
            r_edge = math.ceil(r_edge)
            b_edge = math.ceil(b_edge)

            local ins = (b_edge - t) * 0.04
            l = l + ins
            t = t + ins
            r_edge = r_edge - ins
            b_edge = b_edge - ins

            local w, h_val = r_edge - l, b_edge - t
            local b_top = t - 1
            local tot_h = h_val + 2

            esp.Outer.Position = UDim2.fromOffset(l - 1, b_top)
            esp.Outer.Size     = UDim2.fromOffset(w + 2, tot_h)
            esp.Main.Position  = UDim2.fromOffset(l, t)
            esp.Main.Size      = UDim2.fromOffset(w, h_val)
            esp.Inner.Position = UDim2.fromOffset(l + 1, t + 1)
            esp.Inner.Size     = UDim2.fromOffset(w - 2, h_val - 2)

            local y_o = t - 18
            if bot_db.Toggles.Name then
                esp.NameLabel.Text = bot.Name
                esp.NameLabel.Position = UDim2.fromOffset(l - 1, y_o)
                esp.NameLabel.Size = UDim2.fromOffset(w + 2, 12)
                esp.NameLabel.Visible = true
                y_o = y_o - 14
            else
                esp.NameLabel.Visible = false
            end

            local bot_y = b_edge + 2
            if bot_db.Toggles.Distance and lp_root then
                local dist = math.floor((lp_root.Position - r.Position).Magnitude * 0.28)
                esp.DistanceLabel.Text = dist .. "м [BOT]"
                esp.DistanceLabel.Position = UDim2.fromOffset(l - 1, bot_y)
                esp.DistanceLabel.Size = UDim2.fromOffset(w + 2, 12)
                esp.DistanceLabel.Visible = true
                bot_y = bot_y + 14
            else
                esp.DistanceLabel.Visible = false
            end

            if bot_db.Toggles.HPBar or bot_db.Toggles.HPText then
                local pct = h.Health / h.MaxHealth
                local val = math.floor(h.Health)
                if esp.VisualHealth == nil then esp.VisualHealth = pct end
                esp.VisualHealth = esp.VisualHealth + (pct - esp.VisualHealth) * 0.1

                esp.HealthText.Text = tostring(val)
                local bar_w = 2
                local m_h = tot_h * (1 - esp.VisualHealth)
                local t_y = b_top + m_h + 3 - (esp.HealthText.Size.Y.Offset / 2)

                esp.HealthText.Position = UDim2.fromOffset(l - bar_w - 30, t_y)
                esp.HealthText.Size = UDim2.fromOffset(18, 10)
                esp.HealthText.Visible = bot_db.Toggles.HPText

                esp.HealthBg.Position = UDim2.fromOffset(l - bar_w - 6, b_top)
                esp.HealthBg.Size = UDim2.fromOffset(bar_w, tot_h)
                esp.HealthMask.Position = UDim2.fromOffset(0, 0)
                esp.HealthMask.Size = UDim2.fromOffset(bar_w, m_h)
                esp.HealthBg.Visible = bot_db.Toggles.HPBar
            else
                esp.HealthBg.Visible = false
                esp.HealthText.Visible = false
            end
        else
            if esp then
                esp.Outer.Visible = false
                esp.Main.Visible  = false
                esp.Inner.Visible = false
                esp.DistanceLabel.Visible = false
                esp.NameLabel.Visible     = false
                esp.HealthText.Visible    = false
                esp.HealthBg.Visible      = false
            end
        end
    end

    for b, esp in pairs(bot_db.Boxes) do
        if not proc[b] then clean_bot(b) end
    end
end)

b_sec:AddToggle('BotESPEnabled', { Text = 'Enable Bot ESP', Default = false, Callback = function(v) bot_db.Toggles.Enabled = v end })
b_sec:AddToggle('BotBoxESP', { Text = 'Bot Box ESP', Default = false, Callback = function(v) bot_db.Toggles.Box = v end }):AddColorPicker('BotBoxColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Bot Box Color', Callback = function(v) bot_db.Colors.BoxMain = v; for _, e in pairs(bot_db.Boxes) do if e.MainStroke then e.MainStroke.Color = v end end end })
b_sec:AddToggle('BotNameESP', { Text = 'Bot Name ESP', Default = false, Callback = function(v) bot_db.Toggles.Name = v end }):AddColorPicker('BotNameColor', { Default = Color3.new(1,1,1), Title = 'Bot Name Color', Callback = function(v) bot_db.Colors.Name = v; for _, e in pairs(bot_db.Boxes) do if e.NameLabel then e.NameLabel.TextColor3 = v end end end })
b_sec:AddToggle('BotDistanceESP', { Text = 'Bot Distance ESP', Default = false, Callback = function(v) bot_db.Toggles.Distance = v end }):AddColorPicker('BotDistanceColor', { Default = Color3.new(1,1,1), Title = 'Bot Distance Color', Callback = function(v) bot_db.Colors.Distance = v; for _, e in pairs(bot_db.Boxes) do if e.DistanceLabel then e.DistanceLabel.TextColor3 = v end end end })
b_sec:AddToggle('BotHPText', { Text = 'Bot HP Text', Default = false, Callback = function(v) bot_db.Toggles.HPText = v end }):AddColorPicker('BotHPTextColor', { Default = Color3.new(1,1,1), Title = 'Bot HP Text Color', Callback = function(v) bot_db.Colors.HealthText = v; for _, e in pairs(bot_db.Boxes) do if e.HealthText then e.HealthText.TextColor3 = v end end end })
b_sec:AddToggle('BotHPBar', { Text = 'Bot HP Bar', Default = false, Callback = function(v) bot_db.Toggles.HPBar = v end }):AddColorPicker('BotHPBarStart', { Default = Color3.new(1,1,1), Title = 'Bot HP Bar Start', Callback = function(v) bot_db.Colors.HealthGradientStart = v; for _, e in pairs(bot_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end }):AddColorPicker('BotHPBarMid', { Default = Color3.new(1,1,1), Title = 'Bot HP Bar Mid', Callback = function(v) bot_db.Colors.HealthGradientMid = v; for _, e in pairs(bot_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end }):AddColorPicker('BotHPBarEnd', { Default = Color3.new(1,1,1), Title = 'Bot HP Bar End', Callback = function(v) bot_db.Colors.HealthGradientEnd = v; for _, e in pairs(bot_db.Boxes) do if e.UpdateGradient then e.UpdateGradient() end end end })

local lit = game:GetService("Lighting")
local ter = ws:FindFirstChild("Terrain")

local w_db = {
    Time = { Enabled = false, Value = 14, Original = lit.ClockTime },
    Ambient = { Enabled = false, Color1 = Color3.fromRGB(90,90,90), Color2 = Color3.fromRGB(150,150,150), Original1 = lit.Ambient, Original2 = lit.OutdoorAmbient },
    NoFog = false, NoGrass = false, NoShadows = false, NoLeaves = false, Sky = { Enabled = false, Preset = "Galaxy" }
}

local orig_fog_s = lit.FogStart
local orig_fog_e = lit.FogEnd

local function set_leaves(tr)
    local t = tr and 1 or 0
    local f = ws:FindFirstChild("SpawnerZones") and ws.SpawnerZones:FindFirstChild("Foliage")
    if f then
        for _, z in ipairs(f:GetChildren()) do
            for _, item in ipairs(z:GetChildren()) do
                for _, pt in ipairs(item:GetDescendants()) do
                    if pt:IsA("BasePart") and pt:FindFirstChild("SurfaceAppearance") then pt.Transparency = t end
                end
            end
        end
    end
end

local function apply_world()
    local targetTime = w_db.Time.Enabled and w_db.Value or w_db.Time.Original
    if lit.ClockTime ~= targetTime then lit.ClockTime = targetTime end
    if w_db.Ambient.Enabled then
        if lit.Ambient ~= w_db.Ambient.Color1 then lit.Ambient = w_db.Ambient.Color1 end
        if lit.OutdoorAmbient ~= w_db.Ambient.Color2 then lit.OutdoorAmbient = w_db.Ambient.Color2 end
    else
        if lit.Ambient ~= w_db.Ambient.Original1 then lit.Ambient = w_db.Ambient.Original1 end
        if lit.OutdoorAmbient ~= w_db.Ambient.Original2 then lit.OutdoorAmbient = w_db.Ambient.Original2 end
    end
    if w_db.NoFog then
        if lit.FogStart ~= 1e5 then lit.FogStart = 1e5 end
        if lit.FogEnd ~= 1e5 then lit.FogEnd = 1e5 end
    else
        if lit.FogStart ~= orig_fog_s then lit.FogStart = orig_fog_s end
        if lit.FogEnd ~= orig_fog_e then lit.FogEnd = orig_fog_e end
    end
    if lit.GlobalShadows == w_db.NoShadows then lit.GlobalShadows = not w_db.NoShadows end
    pcall(function() sethiddenproperty(ter, "Decoration", not w_db.NoGrass) end)
    set_leaves(w_db.NoLeaves)
end

local function set_sky(pres)
    for _, c in ipairs(lit:GetChildren()) do if c:IsA("Sky") then c:Destroy() end end
    local s = Instance.new("Sky")
    s.Name = "CustomSky"
    local presets = {
        Galaxy = { Bk = "149397692", Dn = "149397686", Ft = "149397697", Lf = "149397684", Rt = "149397688", Up = "149397702" },
        Saturne = { Bk = "1898724755", Dn = "1898727189", Ft = "1898722814", Lf = "1898729298", Rt = "1898741025", Up = "1898736761" },
        Neptune = { Bk = "218955819", Dn = "218953419", Ft = "218954524", Lf = "218958493", Rt = "218957134", Up = "218950090" }
    }
    local p = presets[pres]
    if p then
        s.SkyboxBk = "rbxassetid://" .. p.Bk
        s.SkyboxDn = "rbxassetid://" .. p.Dn
        s.SkyboxFt = "rbxassetid://" .. p.Ft
        s.SkyboxLf = "rbxassetid://" .. p.Lf
        s.SkyboxRt = "rbxassetid://" .. p.Rt
        s.SkyboxUp = "rbxassetid://" .. p.Up
        s.CelestialBodiesShown = false
        s.Parent = lit
    end
end

w_sec:AddToggle('TimeChanger', { Text = 'Enable Time Changer', Default = false, Callback = function(v) w_db.Time.Enabled = v; apply_world() end })
w_sec:AddSlider('TimeValue', { Text = 'Time', Default = 14, Min = 0, Max = 24, Rounding = 1, Callback = function(v) w_db.Time.Value = v; if w_db.Time.Enabled then apply_world() end end })
local amb = w_sec:AddToggle('Ambient', { Text = 'Enable Ambient', Default = false, Callback = function(v) w_db.Ambient.Enabled = v; apply_world() end })
amb:AddColorPicker('AmbientColor1', { Default = Color3.fromRGB(90,90,90), Title = 'Ambient 1', Callback = function(v) w_db.Ambient.Color1 = v; if w_db.Ambient.Enabled then apply_world() end end })
amb:AddColorPicker('AmbientColor2', { Default = Color3.fromRGB(150,150,150), Title = 'Ambient 2', Callback = function(v) w_db.Ambient.Color2 = v; if w_db.Ambient.Enabled then apply_world() end end })
w_sec:AddToggle('NoFog', { Text = 'No Fog', Default = false, Callback = function(v) w_db.NoFog = v; apply_world() end })
w_sec:AddToggle('NoGrass', { Text = 'No Grass', Default = false, Callback = function(v) w_db.NoGrass = v; apply_world() end })
w_sec:AddToggle('NoShadows', { Text = 'No Shadows', Default = false, Callback = function(v) w_db.NoShadows = v; apply_world() end })
w_sec:AddToggle('NoLeaves', { Text = 'No Leaves', Default = false, Callback = function(v) w_db.NoLeaves = v; apply_world() end })
w_sec:AddToggle('SkyChanger', { Text = 'Custom Sky', Default = false, Callback = function(v) w_db.Sky.Enabled = v; if v then set_sky(w_db.Sky.Preset) else apply_world() end end })
w_sec:AddDropdown('SkyPreset', { Text = 'Sky Preset', Values = {"Galaxy", "Saturne", "Neptune"}, Default = "Galaxy", Callback = function(v) w_db.Sky.Preset = v; if w_db.Sky.Enabled then set_sky(v) end end })

local fov_db = { Enabled = false, Value = 40 }
local fov_t = oth_sec:AddToggle('FOVToggle', { Text = 'Zoom (FOV)', Default = false, Callback = function(v) fov_db.Enabled = v end })
oth_sec:AddLabel('Keybind'):AddKeyPicker('FOVKeybind', { Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Keybind Zoom', Callback = function(v) fov_t:SetValue(v) end })
oth_sec:AddSlider('FOVValue', { Text = 'Zoom Amount', Default = 40, Min = 1, Max = 50, Rounding = 0, Callback = function(v) fov_db.Value = v end })

rs.RenderStepped:Connect(function()
    if fov_db.Enabled and cam.FieldOfView ~= fov_db.Value then cam.FieldOfView = fov_db.Value end
end)

local inv_db = { Enabled = false, Fov = 200, Delay = 0.25, PosX = 0, PosY = 0 }
local inv_g = Instance.new("ScreenGui")
inv_g.Name = "InventoryViewer"
inv_g.ZIndexBehavior = Enum.ZIndexBehavior.Global
inv_g.Parent = cg

local out_f = Instance.new("Frame")
out_f.BackgroundColor3 = Color3.new(0,0,0)
out_f.BorderSizePixel = 0
out_f.Position = UDim2.new(0.5, 0, 0.5, 0)
out_f.Size = UDim2.new(0, 500, 0, 200)
out_f.AnchorPoint = Vector2.new(0.5, 0.5)
out_f.Visible = false
out_f.Parent = inv_g

local inn_f = Instance.new("Frame")
inn_f.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
inn_f.BorderColor3 = Color3.fromRGB(0, 85, 255)
inn_f.BorderMode = Enum.BorderMode.Inset
inn_f.Size = UDim2.new(1, -2, 1, -2)
inn_f.Parent = out_f

local sc_f = Instance.new("ScrollingFrame")
sc_f.BackgroundTransparency = 1
sc_f.Position = UDim2.fromOffset(5, 5)
sc_f.Size = UDim2.new(1, -10, 1, -10)
sc_f.ScrollBarThickness = 4
sc_f.AutomaticCanvasSize = Enum.AutomaticSize.Y
sc_f.Parent = inn_f

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(110, 100)
grid.CellPadding = UDim2.fromOffset(5, 5)
grid.Parent = sc_f

local function get_items(p)
    for _, c in ipairs(sc_f:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local p_f = rep.Players:FindFirstChild(p.Name)
    local inv = p_f and p_f:FindFirstChild("Inventory")
    if not inv then return end
    for _, item in ipairs(inv:GetChildren()) do
        local f = Instance.new("Frame")
        f.BackgroundColor3 = Color3.fromRGB(30,30,35)
        f.Parent = sc_f
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = item.Name
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextSize = 10
        lbl.Parent = f
    end
end

rs.RenderStepped:Connect(function()
    if not inv_db.Enabled then out_f.Visible = false; return end
    local cl_p, cl_d = nil, inv_db.Fov
    local m_pos = Vector2.new(mouse.X, mouse.Y + gi.Y)
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local pos, vis = cam:WorldToViewportPoint(r.Position)
                if vis then
                    local d = (Vector2.new(pos.X, pos.Y) - m_pos).Magnitude
                    if d < cl_d then cl_d = d; cl_p = p end
                end
            end
        end
    end
    if cl_p then
        out_f.Visible = true
        get_items(cl_p)
    else
        out_f.Visible = false
    end
end)

oth_sec:AddToggle('InventoryChecker', { Text = 'Inventory Checker', Default = false, Callback = function(v) inv_db.Enabled = v end })
oth_sec:AddSlider('InvFovRadius', { Text = 'FOV Radius', Default = 200, Min = 50, Max = 500, Rounding = 0, Callback = function(v) inv_db.Fov = v end })

local ds_en = false
local ds_cust = false
local ds_x, ds_y, ds_z = 0, 0, -2.5
local ds_cf = CFrame.new()

local function get_ds_offset()
    if ds_cust then return CFrame.new(ds_x, ds_y, ds_z) end
    local ping = lp:GetNetworkPing() * 1000
    return ping < 100 and CFrame.new(0, 0, -2) or (ping <= 170 and CFrame.new(0, 0, -2.7) or CFrame.new(0, 0, -3.7))
end

rs.Heartbeat:Connect(function()
    if not ds_en or not lp.Character then return end
    local r = lp.Character:FindFirstChild("HumanoidRootPart")
    if r then
        ds_cf = r.CFrame
        r.CFrame = ds_cf * get_ds_offset()
        rs.RenderStepped:Wait()
        r.CFrame = ds_cf
    end
end)

local ds_hook
ds_hook = hookmetamethod(game, "__index", newcclosure(function(self, k)
    if ds_en and not checkcaller() and k == "CFrame" and lp.Character and self == lp.Character:FindFirstChild("HumanoidRootPart") then
        return ds_cf
    end
    return ds_hook(self, k)
end))

local dsToggle = ds_sec:AddToggle('DesyncEnabled', { Text = 'Desync Enabled', Default = false, Callback = function(v) ds_en = v end })
ds_sec:AddLabel('Keybind'):AddKeyPicker('DesyncKeybind', { Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Desync Keybind', Callback = function(v) dsToggle:SetValue(v) end })
ds_sec:AddToggle('CustomDesync', { Text = 'Custom Offset Mode', Default = false, Callback = function(v) ds_cust = v end })
ds_sec:AddSlider('OffsetX', { Text = 'Offset X', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) ds_x = v end })
ds_sec:AddSlider('OffsetY', { Text = 'Offset Y', Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) ds_y = v end })
ds_sec:AddSlider('OffsetZ', { Text = 'Offset Z', Default = -2.5, Min = -10, Max = 10, Rounding = 1, Callback = function(v) ds_z = v end })

local arr_db = { Enabled = false, Color = Color3.new(1,1,1), Distance = 80 }
local arrows = {}

local function make_arrow(p)
    local t = Drawing.new("Triangle")
    t.Filled = true
    t.Thickness = 1
    t.Transparency = 1
    arrows[p] = t

    rs.RenderStepped:Connect(function()
        if not arr_db.Enabled or not p.Character or not lp.Character then t.Visible = false; return end
        local r = p.Character:FindFirstChild("HumanoidRootPart")
        local lr = lp.Character:FindFirstChild("HumanoidRootPart")
        if r and lr then
            local _, vis = cam:WorldToViewportPoint(r.Position)
            if not vis then
                local rel = CFrame.new(lr.Position, Vector3.new(r.Position.X, lr.Position.Y, r.Position.Z)):PointToObjectSpace(r.Position)
                local dir = Vector2.new(rel.X, rel.Z).unit
                local base = cam.ViewportSize/2 + dir * arr_db.Distance
                local tip = cam.ViewportSize/2 + dir * (arr_db.Distance + 15)
                local perp = Vector2.new(-dir.Y, dir.X) * 5

                t.PointA = base + perp
                t.PointB = base - perp
                t.PointC = tip
                t.Color = arr_db.Color
                t.Visible = true
            else t.Visible = false end
        else t.Visible = false end
    end)
end

for _, p in ipairs(plrs:GetPlayers()) do if p ~= lp then make_arrow(p) end end
plrs.PlayerAdded:Connect(function(p) if p ~= lp then make_arrow(p) end end)

oth_sec:AddToggle('ArrowsToggle', { Text = 'Arrows', Default = false, Callback = function(v) arr_db.Enabled = v end }):AddColorPicker('ArrowsColor', { Default = Color3.new(1,1,1), Title = 'Arrow Color', Callback = function(v) arr_db.Color = v end })
oth_sec:AddSlider('ArrowsDistance', { Text = 'Distance From Center', Default = 80, Min = 30, Max = 500, Rounding = 0, Callback = function(v) arr_db.Distance = v end })

local bt_db = { Enabled = false, Delay = 0.3, Color = Color3.fromRGB(0, 255, 255), Transparency = 0.4, Material = Enum.Material.ForceField }
local bt_rec = {}
local bt_md = nil

local function make_bt_clone(char, cf)
    if bt_md then bt_md:Destroy() end
    local r = char:FindFirstChild("HumanoidRootPart")
    if not r then return end
    bt_md = Instance.new("Model")
    bt_md.Name = "BT_Self"
    local parts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, name in ipairs(parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            local cl = p:Clone()
            cl.Anchored = true
            cl.CanCollide = false
            cl.CanQuery = false
            cl.CanTouch = false
            cl.Transparency = bt_db.Transparency
            cl.Color = bt_db.Color
            cl.Material = bt_db.Material
            for _, c in ipairs(cl:GetChildren()) do if not c:IsA("SpecialMesh") then c:Destroy() end end
            cl.CFrame = cf * r.CFrame:ToObjectSpace(p.CFrame)
            cl.Parent = bt_md
        end
    end
    bt_md.Parent = ws
end

rs.Heartbeat:Connect(function()
    if not bt_db.Enabled then if bt_md then bt_md:Destroy() bt_md = nil end return end
    local c = lp.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if r then
        table.insert(bt_rec, { time = tick(), cframe = r.CFrame })
        while #bt_rec > 200 do table.remove(bt_rec, 1) end
        local best = nil
        local target = tick() - bt_db.Delay
        local cl_d = math.huge
        for _, rec in ipairs(bt_rec) do
            local d = math.abs(rec.time - target)
            if d < cl_d then cl_d = d; best = rec end
        end
        if best then make_bt_clone(c, best.cframe) end
    end
end)

oth_sec:AddToggle('SelfBacktrack', { Text = 'SELF BACKTRACK', Default = false, Callback = function(v) bt_db.Enabled = v end })
:AddColorPicker('SelfBacktrackColor', { Default = bt_db.Color, Title = 'Backtrack Color', Callback = function(v) bt_db.Color = v end })
oth_sec:AddSlider('SelfBacktrackDelay', { Text = 'Backtrack Delay', Default = 3, Min = 1, Max = 20, Rounding = 0, Callback = function(v) bt_db.Delay = v / 10 end })

local mod_det = { Enabled = false, Mods = {} }

local function check_mods()
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= lp then
            local c = p.Character
            if c then
                for _, pt in ipairs(c:GetChildren()) do
                    if pt:IsA("BasePart") and pt.Transparency >= 0.9 and not mod_det.Mods[p.Name] then
                        mod_det.Mods[p.Name] = true
                        lib:Notify("👮 MOD on server: " .. p.Name, 7, Color3.fromRGB(255, 150, 0))
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(30) do if mod_det.Enabled then check_mods() end end
end)

md_sec:AddToggle('ModDetector', { Text = 'Auto Mod Detector', Default = false, Callback = function(v) mod_det.Enabled = v end })

local pk_db = { Enabled = false, Speed = 150 }

uis.InputBegan:Connect(function(input)
    if pk_db.Enabled and input.KeyCode == Enum.KeyCode.X then
        local r = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if r then r.Velocity = Vector3.new(r.Velocity.X, pk_db.Speed, r.Velocity.Z) end
    end
end)

s_sec:AddToggle('PeekKill', { Text = 'Peek Kill (X)', Default = false, Callback = function(v) pk_db.Enabled = v end })
s_sec:AddSlider('PeekKillSpeed', { Text = 'Peek Kill Speed', Default = 150, Min = 50, Max = 300, Rounding = 0, Callback = function(v) pk_db.Speed = v end })

local menu_g = tabs.U:AddLeftGroupbox('Menu')
menu_g:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
lib.ToggleKeybind = Options.MenuKeybind

tm:SetLibrary(lib)
sm:SetLibrary(lib)
sm:IgnoreThemeSettings()
sm:SetIgnoreIndexes({ 'MenuKeybind' })
tm:SetFolder('LunarCore')
sm:SetFolder('LunarCore/FullMenu')
sm:BuildConfigSection(tabs.U)
tm:ApplyToTab(tabs.U)

lib:Notify('Full Menu Loaded!', 5)
lib:SetWatermarkVisibility(true)

local f_t = tick()
local f_c = 0
local fps_val = 120

rs.RenderStepped:Connect(function()
    f_c = f_c + 1
    if (tick() - f_t) >= 1 then
        fps_val = f_c
        f_t = tick()
        f_c = 0
    end
    lib:SetWatermark(('Full Menu | %s fps | %s ms'):format(math.floor(fps_val), math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())))
end)
