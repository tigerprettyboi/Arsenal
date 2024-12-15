getgenv().Circle = Drawing.new("Circle")
if Circle then
    Circle.Color = Color3.fromRGB(22, 13, 56)
    Circle.Thickness = 1
    Circle.Radius = 250
    Circle.Visible = false 
    Circle.NumSides = 1000
    Circle.Filled = false
    Circle.Transparency = 1
end

local Shoot, Aim
UserInputService.InputBegan:Connect(function(v)
    if v.UserInputType == Enum.UserInputType.MouseButton2 then
        Shoot = true
        Aim = true
    end
end)

UserInputService.InputEnded:Connect(function(v)
    if v.UserInputType == Enum.UserInputType.MouseButton2 then
        Shoot = false
        Aim = false
    end
end)

local NotWall = function(i, v)
    if AimbotWallCheck then
        c = Workspace.CurrentCamera.CFrame.p
        a = Ray.new(c, i - c)
        f = Workspace:FindPartOnRayWithIgnoreList(a, v)
        return f == nil
    else
        return true
    end
end

local GetClosestToCuror = function()
	local Target, Mouse, IsFFA = nil, Player:GetMouse(), ReplicatedStorage.wkspc.FFA.Value
	for _,v in next, Players:GetPlayers() do
		if v ~= Player  then
            if v.Team ~= Player.Team or v.Team == Player.Team and IsFFA then
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    if Player.Character:FindFirstChildWhichIsA("Humanoid").Health ~= 0 then
                        local Point, OnScreen = Workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                            if OnScreen and NotWall(v.Character.HumanoidRootPart.Position, {Player.Character, v.Character}) then
                            local Mag = (Vector2.new(Point.X, Point.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if Mag <= FOV then
                                Target = v
                            end
                        end
                    end
                end
            end
        end
    end
	return Target
end
local ValuesTable = {}
local ChangeValue = function(NewValue, Amount, Toggle)
    for i,v in next, ReplicatedStorage.Weapons:GetChildren() do
        if not v.Model:FindFirstChild("Secondary", true) then
            if Toggle and v:FindFirstChild(NewValue) ~= nil then
                local Value1 = v:FindFirstChild(NewValue)
                print(Value1)
                ValuesTable[Value1] = Value1.Value
                VG.DisableConnection(Value1.Changed)
                Value1.Value = Amount
            elseif not Toggle and v:FindFirstChild(NewValue) ~= nil then
                local Value1 = v:FindFirstChild(NewValue)
                if table.find(ValuesTable, Value1) then
                    Value1.Value = ValuesTable[Value1]
                end
            end
        end
    end
end

spawn(function()
    while wait(3) do
        pcall(function()
            ChangeValue("Auto", true, Auto)
            ChangeValue("Ammo", 999, InfiniteAmmo)
            ChangeValue("FireRate", 0.02, FireRate)
            ChangeValue("Spread", 0, NoSpread)
            ChangeValue("MaxSpread", 0, NoSpread)
            ChangeValue("RecoilControl", 0, Recoil)
        end)
    end
end)
RunService.Stepped:connect(function()
    pcall(function()
        if ToggleAimbot and Shoot then
            local ClosestPlayer = GetClosestToCuror()
            if ClosestPlayer then
                Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, ClosestPlayer.Character.Head.CFrame.Position)
            end
        end
        if AimbotFOVEnabled then
            local Mouse = UserInputService:GetMouseLocation()
            Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
            Circle.Visible = true
        elseif not AimbotFOVEnabled then
            Circle.Visible = false
        end
        if FOV then
            Circle.Radius = FOV
        end
    end)
end)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Oxygenz Hub |: Game " .. MarketplaceService:GetProductInfo(game.PlaceId).Name,
    SubTitle = "by Oxygenz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Delete -- Used when theres no MinimizeKeybind
})


local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "" }),
    Gun = Window:AddTab({Title = "GunMods"}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Oxygenz Loaded",
        Content = "Congrats your using Oxygenz Hub " .. Verison,
        SubContent = "", -- Optional
        Duration = 10 -- Set to nil to make the notification not disappear
    })
        
    local Toggle = Tabs.Aimbot:AddToggle("v", {Title = "Aimbot Enabled", Default = false})
    Toggle:OnChanged(function()
        ToggleAimbot = Options.v.Value
    end)
    local Toggle = Tabs.Aimbot:AddToggle("v1", {Title = "Aimbot WallCheck Enabled", Default = false})
    Toggle:OnChanged(function()
        AimbotWallCheck = Options.v1.Value
    end)
    local Toggle = Tabs.Aimbot:AddToggle("v2", {Title = "Aimbot FOV Circle Enabled", Default = false})
    Toggle:OnChanged(function()
        AimbotFOVEnabled = Options.v2.Value
    end)

    local Slider = Tabs.Aimbot:AddSlider("Slider", {Title = "AimBot FOV", Description = "The amount of FOV the aimbot is allowed to check on your screen.", Default = 250, Min = 5, Max = 2500, Rounding = 1, Callback = function(Value)
        FOV = math.round(Value)
    end})
    Slider:OnChanged(function(Value)
        print("FOV changed:", math.round(Value))
    end)

    local Toggle = Tabs.Gun:AddToggle("c", {Title = "Automatic Gun", Default = false})
    Toggle:OnChanged(function()
        Auto = Options.c.Value
    end)
    local Toggle = Tabs.Gun:AddToggle("c1", {Title = "Fast Gun FirRate", Default = false})
    Toggle:OnChanged(function()
        FireRate = Options.c1.Value
    end)
    local Toggle = Tabs.Gun:AddToggle("c2", {Title = "Max Ammo", Default = false})
    Toggle:OnChanged(function()
        InfiniteAmmo = Options.c2.Value
    end)
    local Toggle = Tabs.Gun:AddToggle("c4", {Title = "No Spread", Default = false})
    Toggle:OnChanged(function()
        NoSpread = Options.c4.Value
    end)
    local Toggle = Tabs.Gun:AddToggle("c5", {Title = "No Recoil", Default = false})
    Toggle:OnChanged(function()
        Recoil = Options.c5.Value
    end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Oxygenz Hub ",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
