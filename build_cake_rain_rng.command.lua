local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Selection = game:GetService("Selection")

local recording
local ok, result = pcall(function()
    return ChangeHistoryService:TryBeginRecording("Build_Cake_Rain_RNG_v2")
end)
if ok then
    recording = result
end

local function getOrCreate(parent, className, name)
    local existing = parent:FindFirstChild(name)
    if existing then
        return existing
    end

    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

local function clearChildren(instance)
    for _, child in instance:GetChildren() do
        child:Destroy()
    end
end

local eventsFolder = getOrCreate(ReplicatedStorage, "Folder", "Events")
local configsFolder = getOrCreate(ReplicatedStorage, "Folder", "Configs")
local modelsFolder = getOrCreate(ReplicatedStorage, "Folder", "Models")
local cakeModelsFolder = getOrCreate(modelsFolder, "Folder", "cake")
local mapFolder = getOrCreate(Workspace, "Folder", "Map")

local requestWheelSpin = getOrCreate(eventsFolder, "RemoteFunction", "RequestWheelSpin")
local requestCardDraw = getOrCreate(eventsFolder, "RemoteFunction", "RequestCardDraw")
local requestShopPurchase = getOrCreate(eventsFolder, "RemoteFunction", "RequestShopPurchase")
local updateClientState = getOrCreate(eventsFolder, "RemoteEvent", "UpdateClientState")

local wheelConfig = getOrCreate(configsFolder, "ModuleScript", "WheelConfig")
wheelConfig.Source = [=[
local WheelConfig = {
    DisplayedSlots = 5,
    RarityPriority = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    RarityColors = {
        Common = Color3.fromRGB(210, 210, 210),
        Rare = Color3.fromRGB(70, 170, 255),
        Epic = Color3.fromRGB(185, 85, 255),
        Legendary = Color3.fromRGB(255, 170, 0),
        Mythic = Color3.fromRGB(255, 60, 120),
        SSR = Color3.fromRGB(120, 255, 255),
    },
    Rewards = {
        EatSpeed_Common = { NameKey = "Reward_EatSpeed_Common", Rarity = "Common", Weight = 300, BaseDuration = 60, Type = "Stat", Stat = "EatSpeed", Value = 1, Icon = "rbxassetid://6031265976", IsUnlockedDefault = true },
        EatSpeed_Legendary = { NameKey = "Reward_EatSpeed_Legendary", Rarity = "Legendary", Weight = 10, BaseDuration = 60, Type = "Stat", Stat = "EatSpeed", Value = 5, Icon = "rbxassetid://6031265976", IsUnlockedDefault = true },
        GlowCakeBoost_Rare = { NameKey = "Reward_GlowBoost_Rare", Rarity = "Rare", Weight = 50, BaseDuration = 20, Type = "GlowCakeRate", Value = 0.10, Icon = "rbxassetid://6031075938", IsUnlockedDefault = false, UnlockCostWheelPoints = 50 },
        GlowCakeBoost_Mythic = { NameKey = "Reward_GlowBoost_Mythic", Rarity = "Mythic", Weight = 5, BaseDuration = 20, Type = "GlowCakeRate", Value = 0.50, Icon = "rbxassetid://6031075938", IsUnlockedDefault = false, UnlockCostWheelPoints = 200 },
        AutoRoll_Common = { NameKey = "Reward_AutoRoll_Common", Rarity = "Common", Weight = 50, BaseDuration = 180, Type = "AutoRoll", Level = 1, Interval = 1.0, Icon = "rbxassetid://6031094678", IsUnlockedDefault = true },
    },
}
return WheelConfig
]=]

local localizationConfig = getOrCreate(configsFolder, "ModuleScript", "LocalizationConfig")
localizationConfig.Source = [=[
local LocalizationConfig = {
    ["zh-tw"] = {
        UI_Spins_Left = "剩餘轉盤次數: ", UI_WheelPoints = "轉盤點數: ", UI_CakePoints = "蛋糕積分: ",
        UI_AutoRoll_Active = "自動抽獎運行中...", UI_Shop_Title = "商店 HUB", UI_CakeShop_Title = "蛋糕積分商店",
        UI_WheelShop_Title = "轉盤點數商店", UI_Time_Left = "剩餘時間: ", UI_No_Buff = "目前沒有 Buff", UI_Spin = "旋轉",
        UI_Card_Draw = "發光蛋糕抽卡", UI_Open_Shop = "商店", UI_Close = "關閉", UI_Buy = "購買",
        Cake_Common = "普通蛋糕", Cake_Rare = "稀有蛋糕", Cake_Epic = "史詩蛋糕", Cake_Legendary = "傳說蛋糕", Cake_Mythic = "神話蛋糕", Cake_Special = "發光蛋糕",
        Reward_EatSpeed_Common = "+1 吞食速度 (普通)", Reward_EatSpeed_Legendary = "+5 吞食速度 (傳說)",
        Reward_GlowBoost_Rare = "+10% 發光蛋糕率 (20秒)", Reward_GlowBoost_Mythic = "+50% 發光蛋糕率 (20秒)", Reward_AutoRoll_Common = "初級自動抽獎 (普通)",
        Card_Hook = "勾索", Card_Tornado = "龍捲風", Card_Ant = "螞蟻運輸隊",
    },
    ["en-us"] = {
        UI_Spins_Left = "Spins Left: ", UI_WheelPoints = "Wheel Points: ", UI_CakePoints = "Cake Points: ",
        UI_AutoRoll_Active = "Auto-Roll Active...", UI_Shop_Title = "Shop Hub", UI_CakeShop_Title = "Cake Point Shop",
        UI_WheelShop_Title = "Wheel Point Shop", UI_Time_Left = "Time Left: ", UI_No_Buff = "No Active Buff", UI_Spin = "Spin",
        UI_Card_Draw = "Glow Cake Card Draw", UI_Open_Shop = "Shop", UI_Close = "Close", UI_Buy = "Buy",
        Cake_Common = "Common Cake", Cake_Rare = "Rare Cake", Cake_Epic = "Epic Cake", Cake_Legendary = "Legendary Cake", Cake_Mythic = "Mythic Cake", Cake_Special = "Glow Cake",
        Reward_EatSpeed_Common = "+1 Eat Speed (Common)", Reward_EatSpeed_Legendary = "+5 Eat Speed (Legendary)",
        Reward_GlowBoost_Rare = "+10% Glow Cake Spawn (20s)", Reward_GlowBoost_Mythic = "+50% Glow Cake Spawn (20s)", Reward_AutoRoll_Common = "Basic Auto-Roll (Common)",
        Card_Hook = "Grappling Hook", Card_Tornado = "Tornado", Card_Ant = "Ant Courier",
    },
}
return LocalizationConfig
]=]

local cakeConfig = getOrCreate(configsFolder, "ModuleScript", "CakeConfig")
cakeConfig.Source = [=[
local CakeConfig = {
    DataStoreKey = "CakeRainRNG_PlayerData_v2",
    BaseEatDamagePerSecond = 1,
    EatTickSeconds = 1,
    SpawnInterval = 2.75,
    SpawnRadius = 55,
    SpawnHeight = 85,
    MaxCakesPerPlayer = 18,
    GlowBaseChance = 0.03,
    InitialBurstCount = 6,
    MeteorFallSpeed = 105,
    MeteorTrailLifetime = 0.45,
    SinkSeconds = 1.1,
    EatAnimationSeconds = 0.45,
    CakeLifetimeSeconds = 70,
    MinimumSpawnDistance = 4, -- 約 1 公尺；禁止落在玩家腳邊
    MinimumCakeScale = 0.28,
    MaximumCakeScale = 1.45,
    HealthForMaximumScale = 24,
    LabelMaxDistance = 33, -- 約 10 公尺；遠處不顯示實體蛋糕文字
    StainVisibleSeconds = 2,
    Rarities = {
        Common = { NameKey = "Cake_Common", RarityText = "COMMON", OutlineColor = Color3.fromRGB(210, 210, 210), DropWeight = 500, Health = 1, RewardCakePoints = 1 },
        Rare = { NameKey = "Cake_Rare", RarityText = "RARE", OutlineColor = Color3.fromRGB(70, 170, 255), DropWeight = 110, Health = 3, RewardCakePoints = 3 },
        Epic = { NameKey = "Cake_Epic", RarityText = "EPIC", OutlineColor = Color3.fromRGB(185, 85, 255), DropWeight = 35, Health = 6, RewardCakePoints = 7 },
        Legendary = { NameKey = "Cake_Legendary", RarityText = "LEGENDARY", OutlineColor = Color3.fromRGB(255, 170, 0), DropWeight = 8, Health = 12, RewardCakePoints = 15 },
        Mythic = { NameKey = "Cake_Mythic", RarityText = "MYTHIC", OutlineColor = Color3.fromRGB(255, 60, 120), DropWeight = 2, Health = 24, RewardCakePoints = 40 },
    },
}
return CakeConfig
]=]

local skillConfig = getOrCreate(configsFolder, "ModuleScript", "SkillConfig")
skillConfig.Source = [=[
-- Add a card by declaring SkillId, Duration, TriggerInterval and Parameters here,
-- then implement the matching handler in SkillService.  Purchase policy stays on the card.
local SkillConfig = {
    Cards = {
        Card_Hook = { NameKey = "Card_Hook", Rarity = "Rare", Weight = 20, Duration = 60, SkillId = "PullNearest", TriggerInterval = 5, Parameters = { Count = 1, Distance = 2 }, Icon = "rbxassetid://6031068421", IsUnlockedDefault = true },
        Card_Tornado = { NameKey = "Card_Tornado", Rarity = "Epic", Weight = 10, Duration = 60, SkillId = "Tornado", TriggerInterval = 10, Parameters = { Count = 5, DamagePercent = 0.40, Distance = 5 }, Icon = "rbxassetid://6031068421", IsUnlockedDefault = false, UnlockCostCakePoints = 1500 },
        Card_Ant = { NameKey = "Card_Ant", Rarity = "Legendary", Weight = 5, Duration = 810, SkillId = "AntCourier", TriggerInterval = 1, Parameters = { MinimumDistance = 14, DamagePercentPerSecond = 0.02, Distance = 4 }, Icon = "rbxassetid://6031068421", IsUnlockedDefault = false, UnlockCostCakePoints = 3000 },
    },
}
return SkillConfig
]=]

local cardConfig = getOrCreate(configsFolder, "ModuleScript", "CardConfig")
cardConfig.Source = [=[
-- Compatibility alias: game logic reads SkillConfig; older integrations can still require CardConfig.
return require(script.Parent.SkillConfig)
]=]

local shopConfig = getOrCreate(configsFolder, "ModuleScript", "ShopConfig")
shopConfig.Source = [=[
-- Only planned purchasable gameplay cards are listed here.  Cosmetics/themes are intentionally absent.
local ShopConfig = {
    WheelPointShop = {
        { Id = "GlowCakeBoost_Rare", NameKey = "Reward_GlowBoost_Rare", Cost = 50, Currency = "WheelPoints", UnlockType = "WheelReward" },
        { Id = "GlowCakeBoost_Mythic", NameKey = "Reward_GlowBoost_Mythic", Cost = 200, Currency = "WheelPoints", UnlockType = "WheelReward" },
    },
    CakePointShop = {
        { Id = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1500, Currency = "CakePoints", UnlockType = "Card" },
        { Id = "Card_Ant", NameKey = "Card_Ant", Cost = 3000, Currency = "CakePoints", UnlockType = "Card" },
    },
}
return ShopConfig
]=]

local uiConfig = getOrCreate(configsFolder, "ModuleScript", "UIConfig")
uiConfig.Source = [=[
local UIConfig = {
    WheelUI = { AutoHide = true, ShowCondition = "WheelSpins > 0", TitleKey = "UI_Spins_Left", Position = "RightSideHalfCircle", DisplayedSlots = 5 },
    AutoRollUI = { AutoHide = true, ShowCondition = "HasAutoRollTime", TitleKey = "UI_AutoRoll_Active" },
    CardDrawUI = { AutoHide = true, ShowCondition = "TouchedGlowCake", TitleKey = "UI_Card_Draw" },
    BuffStatus = { AutoHide = true, ShowCondition = "ActiveBuffsCount > 0", TitleKey = "UI_Time_Left" },
    ShopUI = { AutoHide = true, ShowCondition = "ManualOpen", TitleKey = "UI_Shop_Title" },
}
return UIConfig
]=]

clearChildren(cakeModelsFolder)
local function createCakeModel(name, baseColor)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = cakeModelsFolder

    local base = Instance.new("Part")
    base.Name = "CakeBody"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(1.4, 4.8, 4.8)
    base.Color = baseColor
    base.Material = Enum.Material.SmoothPlastic
    base.Anchored = false
    base.CanCollide = true
    base.TopSurface = Enum.SurfaceType.Smooth
    base.BottomSurface = Enum.SurfaceType.Smooth
    base.Parent = model
    base.CFrame = CFrame.Angles(0, 0, math.rad(90))

    local frosting = Instance.new("Part")
    frosting.Name = "Frosting"
    frosting.Shape = Enum.PartType.Cylinder
    frosting.Size = Vector3.new(0.35, 4.9, 4.9)
    frosting.Color = Color3.fromRGB(255, 245, 250)
    frosting.Material = Enum.Material.SmoothPlastic
    frosting.Anchored = false
    frosting.CanCollide = true
    frosting.TopSurface = Enum.SurfaceType.Smooth
    frosting.BottomSurface = Enum.SurfaceType.Smooth
    frosting.CFrame = base.CFrame * CFrame.new(0.9, 0, 0)
    frosting.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = base
    weld.Part1 = frosting
    weld.Parent = base

    model.PrimaryPart = base
    return model
end
createCakeModel("RoundCake", Color3.fromRGB(255, 190, 205))
createCakeModel("ChocolateCake", Color3.fromRGB(130, 75, 45))
createCakeModel("VanillaCake", Color3.fromRGB(255, 225, 160))

local mapBase = getOrCreate(mapFolder, "Part", "CakeArenaBase")
mapBase.Anchored = true
mapBase.CanCollide = true
mapBase.Size = Vector3.new(180, 2, 180)
mapBase.Position = Vector3.new(0, -1, 0)
mapBase.Color = Color3.fromRGB(116, 78, 48)
mapBase.Material = Enum.Material.WoodPlanks

local mainGui = getOrCreate(StarterGui, "ScreenGui", "CakeRainRNGHUD")
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = false
clearChildren(mainGui)

local function newGui(className, name, parent)
    local gui = Instance.new(className)
    gui.Name = name
    gui.Parent = parent
    return gui
end

local stats = newGui("Frame", "StatsFrame", mainGui)
stats.Size = UDim2.new(0, 285, 0, 118)
stats.Position = UDim2.new(0, 18, 0, 18)
stats.BackgroundColor3 = Color3.fromRGB(25, 20, 32)
stats.BackgroundTransparency = 0.12
newGui("UICorner", "Corner", stats).CornerRadius = UDim.new(0, 14)
for index, name in { "CakePointsLabel", "WheelPointsLabel", "SpinsLabel" } do
    local label = newGui("TextLabel", name, stats)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 0, 32)
    label.Position = UDim2.new(0, 10, 0, 8 + (index - 1) * 34)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
end
local shopButton = newGui("TextButton", "ShopButton", mainGui)
shopButton.Size = UDim2.new(0, 120, 0, 46)
shopButton.Position = UDim2.new(0, 18, 0, 148)
shopButton.BackgroundColor3 = Color3.fromRGB(255, 210, 110)
shopButton.Font = Enum.Font.GothamBlack
shopButton.Text = "商店"
shopButton.TextScaled = true
shopButton.TextColor3 = Color3.fromRGB(70, 40, 10)
newGui("UICorner", "Corner", shopButton).CornerRadius = UDim.new(0, 12)

local wheel = newGui("Frame", "WheelPanel", mainGui)
wheel.Size = UDim2.new(0, 360, 0, 360)
-- Keep the entire wheel on-screen; the previous top-left positioning put half of it outside the viewport.
wheel.AnchorPoint = Vector2.new(1, 0.5)
wheel.Position = UDim2.new(1, -18, 0.5, 0)
wheel.BackgroundTransparency = 1
wheel.ClipsDescendants = true
wheel.Visible = false
local disc = newGui("Frame", "WheelDisc", wheel)
disc.Size = UDim2.new(0, 360, 0, 360)
disc.Position = UDim2.new(0, 0, 0, 0)
disc.BackgroundColor3 = Color3.fromRGB(42, 30, 70)
newGui("UICorner", "Circle", disc).CornerRadius = UDim.new(1, 0)
local pointer = newGui("TextLabel", "Pointer", wheel)
pointer.BackgroundTransparency = 1
pointer.Size = UDim2.new(0, 58, 0, 58)
pointer.Position = UDim2.new(0, 4, 0.5, -29)
pointer.Font = Enum.Font.GothamBlack
pointer.Text = "▶"
pointer.TextScaled = true
pointer.TextColor3 = Color3.fromRGB(255, 240, 110)
for index = 1, 5 do
    -- Five equally spaced item panels match WheelConfig.DisplayedSlots and remain inside the 360px disc.
    local angle = -90 + (index - 1) * 72
    local sector = newGui("Frame", "Sector" .. index, disc)
    sector.AnchorPoint = Vector2.new(0.5, 0.5)
    sector.Size = UDim2.new(0, 112, 0, 48)
    sector.Position = UDim2.new(0.5, math.cos(math.rad(angle)) * 112, 0.5, math.sin(math.rad(angle)) * 112)
    sector.Rotation = 0
    sector:SetAttribute("WheelAngle", angle)
    sector.BackgroundColor3 = index % 2 == 0 and Color3.fromRGB(76, 54, 120) or Color3.fromRGB(95, 63, 145)
    sector.BorderSizePixel = 0
    newGui("UICorner", "Corner", sector).CornerRadius = UDim.new(0, 22)
    local text = newGui("TextLabel", "Text", sector)
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 12, 0, 0)
    text.Font = Enum.Font.GothamBold
    text.Text = "?"
    text.TextScaled = true
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0.45
end
local spinButton = newGui("TextButton", "SpinButton", wheel)
spinButton.Size = UDim2.new(0, 110, 0, 52)
spinButton.Position = UDim2.new(0.5, -55, 0.5, -26)
spinButton.BackgroundColor3 = Color3.fromRGB(255, 185, 80)
spinButton.Font = Enum.Font.GothamBlack
spinButton.Text = "旋轉"
spinButton.TextScaled = true
spinButton.TextColor3 = Color3.fromRGB(60, 35, 10)
newGui("UICorner", "Corner", spinButton).CornerRadius = UDim.new(0, 14)
local autoRollToggle = newGui("TextButton", "AutoRollToggle", wheel)
autoRollToggle.Size = UDim2.new(0, 150, 0, 38)
autoRollToggle.Position = UDim2.new(0, 18, 1, -48)
autoRollToggle.BackgroundColor3 = Color3.fromRGB(80, 95, 120)
autoRollToggle.Font = Enum.Font.GothamBlack
autoRollToggle.Text = "自動抽獎: OFF"
autoRollToggle.TextScaled = true
autoRollToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoRollToggle.Visible = false
newGui("UICorner", "Corner", autoRollToggle).CornerRadius = UDim.new(0, 12)

local buffFrame = newGui("Frame", "EffectBar", mainGui)
buffFrame.Size = UDim2.new(0, 392, 0, 74)
buffFrame.Position = UDim2.new(0, 18, 1, -92)
buffFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
buffFrame.BackgroundTransparency = 0.12
buffFrame.Visible = false
newGui("UICorner", "Corner", buffFrame).CornerRadius = UDim.new(0, 16)
for index = 1, 8 do
    local slot = newGui("ImageButton", "EffectIcon" .. index, buffFrame)
    slot.Size = UDim2.new(0, 46, 0, 46)
    slot.Position = UDim2.new(0, 10 + (index - 1) * 47, 0, 14)
    slot.BackgroundColor3 = Color3.fromRGB(45, 55, 70)
    slot.AutoButtonColor = false
    slot.Image = ""
    slot.Visible = false
    newGui("UICorner", "Corner", slot).CornerRadius = UDim.new(0, 10)
    local stroke = newGui("UIStroke", "Outline", slot)
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255, 255, 255)
end
local tooltip = newGui("TextLabel", "Tooltip", buffFrame)
tooltip.Size = UDim2.new(0, 260, 0, 34)
tooltip.Position = UDim2.new(0, 8, 0, -38)
tooltip.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
tooltip.BackgroundTransparency = 0.08
tooltip.Font = Enum.Font.GothamBold
tooltip.TextScaled = true
tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltip.Visible = false
newGui("UICorner", "Corner", tooltip).CornerRadius = UDim.new(0, 8)

-- Persistent bottom readout: the player can verify the most recently drawn skill and stacked time.
local currentDrawLabel = newGui("TextLabel", "CurrentDrawLabel", mainGui)
currentDrawLabel.Size = UDim2.new(0, 392, 0, 28)
currentDrawLabel.Position = UDim2.new(0, 18, 1, -124)
currentDrawLabel.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
currentDrawLabel.BackgroundTransparency = 0.12
currentDrawLabel.Font = Enum.Font.GothamBold
currentDrawLabel.TextScaled = true
currentDrawLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
currentDrawLabel.Visible = false
newGui("UICorner", "Corner", currentDrawLabel).CornerRadius = UDim.new(0, 8)

local cardFrame = newGui("Frame", "CardDraw", mainGui)
cardFrame.Size = UDim2.new(0, 420, 0, 230)
cardFrame.Position = UDim2.new(0.5, -210, 0.5, -115)
cardFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 70)
cardFrame.Visible = false
newGui("UICorner", "Corner", cardFrame).CornerRadius = UDim.new(0, 18)
local cardTitle = newGui("TextLabel", "Title", cardFrame)
cardTitle.BackgroundTransparency = 1
cardTitle.Size = UDim2.new(1, -20, 0, 52)
cardTitle.Position = UDim2.new(0, 10, 0, 16)
cardTitle.Font = Enum.Font.GothamBlack
cardTitle.Text = "發光蛋糕抽卡"
cardTitle.TextScaled = true
cardTitle.TextColor3 = Color3.fromRGB(120, 255, 255)
local cardResult = newGui("TextLabel", "Result", cardFrame)
cardResult.BackgroundTransparency = 1
cardResult.Size = UDim2.new(1, -20, 0, 68)
cardResult.Position = UDim2.new(0, 10, 0, 82)
cardResult.Font = Enum.Font.GothamBold
cardResult.Text = ""
cardResult.TextScaled = true
cardResult.TextColor3 = Color3.fromRGB(255, 255, 255)
local drawButton = newGui("TextButton", "DrawButton", cardFrame)
drawButton.Size = UDim2.new(0, 160, 0, 48)
drawButton.Position = UDim2.new(0.5, -80, 1, -62)
drawButton.BackgroundColor3 = Color3.fromRGB(110, 255, 255)
drawButton.Font = Enum.Font.GothamBlack
drawButton.Text = "DRAW"
drawButton.TextScaled = true
drawButton.TextColor3 = Color3.fromRGB(20, 30, 45)
newGui("UICorner", "Corner", drawButton).CornerRadius = UDim.new(0, 14)

local shopHub = newGui("Frame", "ShopHub", mainGui)
shopHub.Size = UDim2.new(0, 620, 0, 360)
shopHub.Position = UDim2.new(0.5, -310, 0.5, -180)
shopHub.BackgroundColor3 = Color3.fromRGB(32, 24, 40)
shopHub.Visible = false
newGui("UICorner", "Corner", shopHub).CornerRadius = UDim.new(0, 18)
local closeShop = newGui("TextButton", "CloseButton", shopHub)
closeShop.Size = UDim2.new(0, 90, 0, 38)
closeShop.Position = UDim2.new(1, -104, 0, 12)
closeShop.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeShop.Font = Enum.Font.GothamBlack
closeShop.Text = "關閉"
closeShop.TextScaled = true
closeShop.TextColor3 = Color3.fromRGB(255, 255, 255)
newGui("UICorner", "Corner", closeShop).CornerRadius = UDim.new(0, 10)
for column, frameName in { "CakePointShop", "WheelPointShop" } do
    local pane = newGui("Frame", frameName, shopHub)
    pane.Size = UDim2.new(0, 285, 0, 282)
    pane.Position = UDim2.new(0, 20 + (column - 1) * 305, 0, 62)
    pane.BackgroundColor3 = column == 1 and Color3.fromRGB(58, 38, 48) or Color3.fromRGB(38, 48, 70)
    newGui("UICorner", "Corner", pane).CornerRadius = UDim.new(0, 14)
    local title = newGui("TextLabel", "Title", pane)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -16, 0, 40)
    title.Position = UDim2.new(0, 8, 0, 8)
    title.Font = Enum.Font.GothamBlack
    title.Text = column == 1 and "蛋糕積分商店" or "轉盤點數商店"
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    for row = 1, 3 do
        local button = newGui("TextButton", "Buy" .. row, pane)
        button.Size = UDim2.new(1, -24, 0, 50)
        button.Position = UDim2.new(0, 12, 0, 54 + (row - 1) * 62)
        button.BackgroundColor3 = Color3.fromRGB(255, 230, 145)
        button.Font = Enum.Font.GothamBold
        button.Text = "-"
        button.TextScaled = true
        button.TextColor3 = Color3.fromRGB(35, 25, 20)
        newGui("UICorner", "Corner", button).CornerRadius = UDim.new(0, 10)
    end
end

local serverPackage = getOrCreate(ServerScriptService, "Folder", "CakeRainRNG")
local servicesPackage = getOrCreate(serverPackage, "Folder", "Services")

local dataService = getOrCreate(servicesPackage, "ModuleScript", "DataService")
dataService.Source = [=[
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CakeConfig = require(ReplicatedStorage.Configs.CakeConfig)

local DataService = {}
local store
local memory = {}

local function getStore()
    if store ~= nil then
        return store
    end
    local ok, result = pcall(function()
        return DataStoreService:GetDataStore(CakeConfig.DataStoreKey)
    end)
    store = ok and result or false
    return store
end

function DataService.Load(player)
    local key = "Player_" .. player.UserId
    local activeStore = getStore()
    if activeStore then
        local ok, data = pcall(function()
            return activeStore:GetAsync(key)
        end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return memory[key] or {}
end

function DataService.Save(player, data)
    local key = "Player_" .. player.UserId
    memory[key] = data
    local activeStore = getStore()
    if activeStore and not RunService:IsStudio() then
        pcall(function()
            activeStore:SetAsync(key, data)
        end)
    end
end

return DataService
]=]

local stateService = getOrCreate(servicesPackage, "ModuleScript", "StateService")
stateService.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage.Events
local Configs = ReplicatedStorage.Configs
local WheelConfig = require(Configs.WheelConfig)
local LocalizationConfig = require(Configs.LocalizationConfig)
local UpdateClientState = Events.UpdateClientState

local StateService = { States = {} }

local function text(nameKey)
    return LocalizationConfig["zh-tw"][nameKey] or nameKey
end

function StateService.Create(player, loaded)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local cakePoints = Instance.new("IntValue")
    cakePoints.Name = "Cake Points"
    cakePoints.Parent = leaderstats
    local wheelPoints = Instance.new("IntValue")
    wheelPoints.Name = "Wheel Points"
    wheelPoints.Parent = leaderstats

    StateService.States[player] = {
        WheelSpins = loaded.WheelSpins or 0,
        WheelPoints = loaded.WheelPoints or 0,
        CakePoints = loaded.CakePoints or 0,
        PendingCardDraw = false,
        LastDraw = nil,
        Buffs = {},
        UnlockedWheelRewards = loaded.UnlockedWheelRewards or {},
        UnlockedCards = loaded.UnlockedCards or {},
    }
    StateService.UpdateLeaderstats(player)
    StateService.Push(player)
end

function StateService.Get(player)
    return StateService.States[player]
end

function StateService.Serialize(player)
    local state = StateService.Get(player)
    if not state then return {} end
    return {
        WheelSpins = state.WheelSpins,
        WheelPoints = state.WheelPoints,
        CakePoints = state.CakePoints,
        UnlockedWheelRewards = state.UnlockedWheelRewards,
        UnlockedCards = state.UnlockedCards,
    }
end

function StateService.Remove(player)
    StateService.States[player] = nil
end

function StateService.UpdateLeaderstats(player)
    local state = StateService.Get(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not state or not leaderstats then return end
    leaderstats["Cake Points"].Value = state.CakePoints
    leaderstats["Wheel Points"].Value = state.WheelPoints
end

function StateService.EffectiveStat(player, statName)
    local state = StateService.Get(player)
    if not state then return 0 end
    local bestValue, bestPriority, now = 0, -1, os.clock()
    for _, stack in ipairs(state.Buffs[statName] or {}) do
        if stack.ExpiresAt > now then
            local priority = WheelConfig.RarityPriority[stack.Rarity] or 0
            if priority > bestPriority then
                bestPriority = priority
                bestValue = stack.Value or 0
            end
        end
    end
    return bestValue
end

function StateService.AddBuff(player, key, reward)
    local state = StateService.Get(player)
    if not state then return end
    local buffType = reward.Type == "Stat" and reward.Stat or reward.Type
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    table.insert(state.Buffs[buffType], { Key = key, NameKey = reward.NameKey, Rarity = reward.Rarity, Value = reward.Value, Level = reward.Level, Icon = reward.Icon, Interval = reward.Interval, ExpiresAt = os.clock() + reward.BaseDuration })
end

function StateService.AddCardBuff(player, key, card)
    local state = StateService.Get(player)
    if not state then return end
    local buffType, now = "Skill_" .. key, os.clock()
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    -- Re-drawing the same ability extends its existing timer rather than creating an invisible parallel timer.
    for _, existing in ipairs(state.Buffs[buffType]) do
        if existing.Key == key and existing.ExpiresAt > now then
            existing.ExpiresAt += card.Duration
            existing.Stacks = (existing.Stacks or 1) + 1
            return existing, false
        end
    end
    local stack = { Key = key, NameKey = card.NameKey, Rarity = card.Rarity, Value = 1, Icon = card.Icon, SkillId = card.SkillId, Parameters = card.Parameters or {}, TriggerInterval = card.TriggerInterval or 1, Stacks = 1, ExpiresAt = now + card.Duration }
    table.insert(state.Buffs[buffType], stack)
    return stack, true
end

function StateService.ActiveBuffs(player)
    local state = StateService.Get(player)
    local active, now = {}, os.clock()
    if not state then return active end
    for buffType, stacks in pairs(state.Buffs) do
        local best
        for _, stack in ipairs(stacks) do
            if stack.ExpiresAt > now then
                local priority = WheelConfig.RarityPriority[stack.Rarity] or 0
                local bestPriority = best and (WheelConfig.RarityPriority[best.Rarity] or 0) or -1
                if priority > bestPriority then best = stack end
            end
        end
        if best then
            active[buffType] = { Name = text(best.NameKey), Rarity = best.Rarity, Value = best.Value or best.Level or 0, Remaining = math.max(0, math.floor(best.ExpiresAt - now)), Icon = best.Icon or "", OutlineColor = WheelConfig.RarityColors[best.Rarity] or Color3.fromRGB(255, 255, 255), Interval = best.Interval, SkillId = best.SkillId, Stacks = best.Stacks or 1 }
        end
    end
    return active
end

function StateService.Push(player)
    local state = StateService.Get(player)
    if not state then return end
    local lastDraw = state.LastDraw
    if lastDraw and lastDraw.Key then
        local activeStack
        for _, stack in ipairs(state.Buffs["Skill_" .. lastDraw.Key] or {}) do
            if stack.Key == lastDraw.Key and stack.ExpiresAt > os.clock() then activeStack = stack break end
        end
        lastDraw = activeStack and { Key = lastDraw.Key, Name = text(activeStack.NameKey), Rarity = activeStack.Rarity, Remaining = math.max(0, math.floor(activeStack.ExpiresAt - os.clock())), Stacks = activeStack.Stacks or 1 } or nil
    end
    UpdateClientState:FireClient(player, {
        WheelSpins = state.WheelSpins,
        WheelPoints = state.WheelPoints,
        CakePoints = state.CakePoints,
        PendingCardDraw = state.PendingCardDraw,
        LastDraw = lastDraw,
        ActiveBuffs = StateService.ActiveBuffs(player),
        UnlockedWheelRewards = state.UnlockedWheelRewards,
        UnlockedCards = state.UnlockedCards,
    })
end

return StateService
]=]

local cakeService = getOrCreate(servicesPackage, "ModuleScript", "CakeService")
cakeService.Source = [=[
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Configs = ReplicatedStorage.Configs
local CakeConfig = require(Configs.CakeConfig)
local LocalizationConfig = require(Configs.LocalizationConfig)
local StateService = require(script.Parent.StateService)
local CakeModels = ReplicatedStorage.Models.cake

-- Public cake API used by SkillService.  Keep all cake movement/damage here so skills
-- cannot bypass rewards, ownership, animation, or the one-cake eating rule.
local CakeService = { Owners = {}, Eating = {}, EatingByPlayer = {} }
local Runtime = Workspace.Map:FindFirstChild("RuntimeCakes") or Instance.new("Folder")
Runtime.Name, Runtime.Parent = "RuntimeCakes", Workspace.Map
local function text(key) return LocalizationConfig["zh-tw"][key] or key end
local function rootOf(player) return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function weightedPick(entries, field)
    local total = 0
    for _, entry in pairs(entries) do total += entry[field] or 1 end
    local roll, sum = math.random() * total, 0
    for key, entry in pairs(entries) do sum += entry[field] or 1 if roll <= sum then return key, entry end end
end
local function randomTemplate()
    local choices = CakeModels:GetChildren()
    return #choices > 0 and choices[math.random(1, #choices)] or nil
end

function CakeService.UpdateScale(cake)
    local hp = math.max(0, cake:GetAttribute("Health") or 0)
    local scale = CakeConfig.MinimumCakeScale + (CakeConfig.MaximumCakeScale - CakeConfig.MinimumCakeScale) * math.clamp(hp / CakeConfig.HealthForMaximumScale, 0, 1)
    cake:ScaleTo(scale) -- Cakes visibly shrink continuously as their remaining HP falls.
end
function CakeService.RefreshLabel(cake)
    local rarity = CakeConfig.Rarities[cake:GetAttribute("RarityKey")] or CakeConfig.Rarities.Common
    local hp, maxHp = math.max(0, cake:GetAttribute("Health") or rarity.Health), cake:GetAttribute("MaxHealth") or rarity.Health
    local label = cake.PrimaryPart and cake.PrimaryPart:FindFirstChild("CakeLabel")
    local labelText = label and label:FindFirstChild("Text")
    if labelText then labelText.Text = string.format("[%s] %s (HP: %d/%d)", cake:GetAttribute("IsGlow") and "SPECIAL" or rarity.RarityText, cake:GetAttribute("IsGlow") and text("Cake_Special") or text(rarity.NameKey), hp, maxHp) end
    CakeService.UpdateScale(cake)
end
function CakeService.Decorate(cake, rarityKey, rarity, isGlow)
    local primary = cake.PrimaryPart or cake:FindFirstChildWhichIsA("BasePart", true)
    if not primary then return end
    cake.PrimaryPart = primary
    cake:SetAttribute("RarityKey", rarityKey); cake:SetAttribute("Health", rarity.Health); cake:SetAttribute("MaxHealth", rarity.Health)
    cake:SetAttribute("RewardCakePoints", rarity.RewardCakePoints); cake:SetAttribute("IsGlow", isGlow)
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Anchored, part.CanCollide = false, true end end
    local outline = Instance.new("Highlight"); outline.Name = "RarityOutline"; outline.FillTransparency = 1; outline.OutlineColor = rarity.OutlineColor; outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; outline.Parent = cake
    local top = Instance.new("Attachment"); top.Name = "MeteorTrailTop"; top.Position = Vector3.new(0, 2.8, 0); top.Parent = primary
    local bottom = Instance.new("Attachment"); bottom.Name = "MeteorTrailBottom"; bottom.Position = Vector3.new(0, -2.8, 0); bottom.Parent = primary
    local trail = Instance.new("Trail"); trail.Name = "RarityMeteorTrail"; trail.Attachment0, trail.Attachment1 = top, bottom; trail.Color = ColorSequence.new(rarity.OutlineColor); trail.LightEmission, trail.Lifetime = .65, CakeConfig.MeteorTrailLifetime; trail.Parent = primary
    if isGlow then local light = Instance.new("PointLight"); light.Color, light.Brightness, light.Range = Color3.fromRGB(120,255,255), 1.2, 12; light.Parent = primary end
    local label = Instance.new("BillboardGui"); label.Name, label.AlwaysOnTop, label.MaxDistance, label.Size, label.StudsOffset, label.Parent = "CakeLabel", true, CakeConfig.LabelMaxDistance, UDim2.new(0,300,0,62), Vector3.new(0,4.2,0), primary
    local labelText = Instance.new("TextLabel"); labelText.Name, labelText.BackgroundTransparency, labelText.Size, labelText.Font, labelText.TextScaled, labelText.TextColor3, labelText.TextStrokeColor3, labelText.TextStrokeTransparency, labelText.Parent = "Text", 1, UDim2.fromScale(1,1), Enum.Font.GothamBlack, true, Color3.new(1,1,1), rarity.OutlineColor, 0, label
end
local function stopEating(cake)
    local eater = CakeService.Eating[cake]
    if eater then CakeService.EatingByPlayer[eater] = nil end
    CakeService.Eating[cake] = nil
end
function CakeService.Finish(player, cake)
    if not cake.Parent or cake:GetAttribute("Finishing") then return end
    cake:SetAttribute("Finishing", true); CakeService.Owners[cake] = nil; stopEating(cake)
    local state = StateService.Get(player)
    if state then
        state.CakePoints += cake:GetAttribute("RewardCakePoints") or 1; state.WheelSpins += 1
        if cake:GetAttribute("IsGlow") then state.PendingCardDraw = true end
        StateService.UpdateLeaderstats(player); StateService.Push(player)
    end
    -- Eating is deliberately distinct from expiry: disable physics, then shrink/fade into the player.
    local startPivot, startScale, started = cake:GetPivot(), cake:GetScale(), os.clock()
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide, part.Anchored = false, true end end
    task.spawn(function()
        while cake.Parent do
            local alpha = math.clamp((os.clock() - started) / CakeConfig.EatAnimationSeconds, 0, 1)
            local root = rootOf(player)
            local target = CFrame.new((root and root.Position or startPivot.Position) + Vector3.new(0, 1, 0))
            cake:PivotTo(startPivot:Lerp(target, alpha)); cake:ScaleTo(math.max(.03, startScale * (1 - alpha)))
            for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Transparency = alpha end end
            if alpha >= 1 then cake:Destroy(); break end
            RunService.Heartbeat:Wait()
        end
    end)
end
function CakeService.Expire(cake)
    if not cake.Parent or cake:GetAttribute("Finishing") then return end
    cake:SetAttribute("Finishing", true); CakeService.Owners[cake] = nil; stopEating(cake)
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false; TweenService:Create(part, TweenInfo.new(CakeConfig.SinkSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = part.Position - Vector3.new(0,8,0), Transparency = 1 }):Play() end end
    Debris:AddItem(cake, CakeConfig.SinkSeconds + .1)
end
function CakeService.DamageCake(player, cake, amount)
    if CakeService.Owners[cake] ~= player or cake:GetAttribute("Finishing") then return false end
    local hp = math.max(0, (cake:GetAttribute("Health") or 1) - amount); cake:SetAttribute("Health", hp); CakeService.RefreshLabel(cake)
    if hp <= 0 then CakeService.Finish(player, cake) end
    return true
end
function CakeService.GetCakes(player, maximum, minimumDistance)
    local root, results = rootOf(player), {}
    if not root then return results end
    for cake, owner in pairs(CakeService.Owners) do
        if owner == player and cake.Parent and cake.PrimaryPart and not cake:GetAttribute("Finishing") then
            local distance = (cake.PrimaryPart.Position - root.Position).Magnitude
            if not minimumDistance or distance >= minimumDistance then table.insert(results, { Cake = cake, Distance = distance }) end
        end
    end
    table.sort(results, function(a,b) return a.Distance < b.Distance end)
    while #results > (maximum or #results) do table.remove(results) end
    return results
end
function CakeService.MoveNearPlayer(player, cake, distance, travelSeconds)
    local root = rootOf(player)
    if not root or CakeService.Owners[cake] ~= player or not cake.PrimaryPart then return false end
    local angle = math.random() * math.pi * 2
    local destination = CFrame.new(root.Position + Vector3.new(math.cos(angle) * distance, 2, math.sin(angle) * distance))
    cake.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
    if travelSeconds and travelSeconds > 0 then
        TweenService:Create(cake.PrimaryPart, TweenInfo.new(travelSeconds, Enum.EasingStyle.Linear), { CFrame = destination }):Play()
    else
        cake:PivotTo(destination)
    end
    return destination
end
function CakeService.BeginAutoEat(player, cake)
    if CakeService.EatingByPlayer[player] or CakeService.Eating[cake] or CakeService.Owners[cake] ~= player then return end
    CakeService.Eating[cake], CakeService.EatingByPlayer[player] = player, cake
    task.spawn(function()
        while cake.Parent and CakeService.EatingByPlayer[player] == cake do
            local root = rootOf(player)
            if not root or not cake.PrimaryPart or (root.Position - cake.PrimaryPart.Position).Magnitude > 9 then break end
            CakeService.DamageCake(player, cake, CakeConfig.BaseEatDamagePerSecond + StateService.EffectiveStat(player, "EatSpeed"))
            task.wait(CakeConfig.EatTickSeconds)
        end
        if CakeService.EatingByPlayer[player] == cake then stopEating(cake) end
    end)
end
function CakeService.HookTouches(player, cake)
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Touched:Connect(function(hit) if Players:GetPlayerFromCharacter(hit.Parent) == player then CakeService.BeginAutoEat(player, cake) end end) end end
end
function CakeService.Count(player) local n=0 for cake,owner in pairs(CakeService.Owners) do if owner == player and cake.Parent then n+=1 end end return n end
function CakeService.SpawnNear(player)
    local root = rootOf(player); if not root or CakeService.Count(player) >= CakeConfig.MaxCakesPerPlayer then return end
    local template = randomTemplate(); if not template then warn("Cake Rain RNG: no cake template") return end
    local rarityKey, rarity = weightedPick(CakeConfig.Rarities, "DropWeight"); local glow = math.random() < (CakeConfig.GlowBaseChance + StateService.EffectiveStat(player,"GlowCakeRate"))
    local angle, radius = math.random()*math.pi*2, math.random(CakeConfig.MinimumSpawnDistance, CakeConfig.SpawnRadius)
    local cake = template:Clone(); cake.Name = (glow and "Glow" or rarityKey).."_"..template.Name; cake.Parent = Runtime; cake:PivotTo(CFrame.new(root.Position + Vector3.new(math.cos(angle)*radius,CakeConfig.SpawnHeight,math.sin(angle)*radius)))
    CakeService.Decorate(cake,rarityKey,rarity,glow); cake.PrimaryPart.AssemblyLinearVelocity=Vector3.new(0,-CakeConfig.MeteorFallSpeed,0); CakeService.RefreshLabel(cake); CakeService.Owners[cake]=player; CakeService.HookTouches(player,cake)
    task.delay(CakeConfig.CakeLifetimeSeconds,function() if cake.Parent and CakeService.Owners[cake] == player then CakeService.Expire(cake) end end)
end
function CakeService.StartPlayer(player)
    local function burst() task.spawn(function() for _=1,CakeConfig.InitialBurstCount do if not player.Parent then return end; CakeService.SpawnNear(player); task.wait(.18) end end) end
    player.CharacterAdded:Connect(function(character) character:WaitForChild("HumanoidRootPart",10); task.wait(.35); burst() end); if player.Character then burst() end
    -- A failed individual drop must never terminate the endless rain coroutine.
    task.spawn(function()
        while player.Parent do
            local character = player.Character or player.CharacterAdded:Wait()
            character:WaitForChild("HumanoidRootPart", 10)
            local ok, err = pcall(CakeService.SpawnNear, player)
            if not ok then warn("Cake Rain RNG: spawn failed; rain will continue", err) end
            StateService.Push(player)
            task.wait(CakeConfig.SpawnInterval)
        end
    end)
end
function CakeService.CleanupPlayer(player) for cake,owner in pairs(CakeService.Owners) do if owner==player then CakeService.Owners[cake]=nil; if cake.Parent then cake:Destroy() end end end; CakeService.EatingByPlayer[player]=nil end
return CakeService
]=]

local skillService = getOrCreate(servicesPackage, "ModuleScript", "SkillService")
skillService.Source = [=[
-- Skill handler registry. Add a SkillConfig card and a handler with the matching SkillId.
-- The effects live server-side so every player sees the hook, tornado, and ant transport.
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CakeService = require(script.Parent.CakeService)
local StateService = require(script.Parent.StateService)
local SkillService = { Handlers = {} }
local Effects = Workspace.Map:FindFirstChild("SkillEffects") or Instance.new("Folder")
Effects.Name, Effects.Parent = "SkillEffects", Workspace.Map

local function rootOf(player) return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function hookEffect(root, cake)
    if not root or not cake.PrimaryPart then return end
    local source, target = Instance.new("Attachment"), Instance.new("Attachment")
    source.Parent, target.Parent = root, cake.PrimaryPart
    local beam = Instance.new("Beam")
    beam.Name, beam.Attachment0, beam.Attachment1 = "GrapplingHookChain", source, target
    beam.Color, beam.Width0, beam.Width1, beam.FaceCamera = ColorSequence.new(Color3.fromRGB(210, 210, 225)), .16, .16, true
    beam.Texture, beam.TextureSpeed, beam.TextureLength, beam.Parent = "rbxassetid://446111271", 3, 1, Effects
    local hook = Instance.new("Part")
    hook.Name, hook.Shape, hook.Size, hook.Material, hook.Color, hook.Anchored, hook.CanCollide = "HookHead", Enum.PartType.Ball, Vector3.new(.55,.55,.55), Enum.Material.Metal, Color3.fromRGB(180,180,190), true, false
    hook.CFrame, hook.Parent = cake.PrimaryPart.CFrame, Effects
    Debris:AddItem(beam, .85); Debris:AddItem(source, .85); Debris:AddItem(target, .85); Debris:AddItem(hook, .85)
end
local function tornadoEffect(root)
    if not root then return end
    local visual = Instance.new("Folder"); visual.Name, visual.Parent = "Tornado", Effects
    local pieces = {}
    for index = 1, 16 do
        local part = Instance.new("Part")
        part.Name, part.Shape, part.Size, part.Material, part.Color = "WindSpiral", Enum.PartType.Ball, Vector3.new(.35,.35,.35), Enum.Material.Neon, Color3.fromRGB(180,235,255)
        part.Anchored, part.CanCollide, part.Parent = true, false, visual
        pieces[index] = part
    end
    task.spawn(function()
        local started = os.clock()
        while visual.Parent and os.clock() - started < 1.4 do
            local elapsed = os.clock() - started
            for index, part in ipairs(pieces) do
                local height = ((index - 1) / #pieces) * 9
                local radius = 1.1 + height * .32
                local angle = elapsed * 14 + index * math.pi * 2 / #pieces
                part.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(angle)*radius, height, math.sin(angle)*radius))
            end
            RunService.Heartbeat:Wait()
        end
        visual:Destroy()
    end)
end
local function antEffect(cake, destination, seconds)
    if not cake.PrimaryPart or not destination then return end
    local ant = Instance.new("Model"); ant.Name, ant.Parent = "AntCourier", Effects
    local body = Instance.new("Part"); body.Name, body.Shape, body.Size, body.Color, body.Material = "AntBody", Enum.PartType.Ball, Vector3.new(.7,.45,.45), Color3.fromRGB(35,20,12), Enum.Material.SmoothPlastic
    body.Anchored, body.CanCollide, body.CFrame, body.Parent = true, false, cake.PrimaryPart.CFrame * CFrame.new(0,-1,0), ant
    local head = Instance.new("Part"); head.Name, head.Shape, head.Size, head.Color, head.Material = "AntHead", Enum.PartType.Ball, Vector3.new(.42,.35,.35), body.Color, body.Material
    head.Anchored, head.CanCollide, head.CFrame, head.Parent = true, false, body.CFrame * CFrame.new(.48,0,0), ant
    TweenService:Create(body, TweenInfo.new(seconds, Enum.EasingStyle.Linear), { CFrame = destination * CFrame.new(0,-1,0) }):Play()
    TweenService:Create(head, TweenInfo.new(seconds, Enum.EasingStyle.Linear), { CFrame = destination * CFrame.new(.48,-1,0) }):Play()
    Debris:AddItem(ant, seconds + .1)
end

function SkillService.Handlers.PullNearest(player, parameters)
    local item = CakeService.GetCakes(player, parameters.Count or 1)[1]
    local root = rootOf(player)
    if item then hookEffect(root, item.Cake); CakeService.MoveNearPlayer(player, item.Cake, parameters.Distance or 2, .75) end
end
function SkillService.Handlers.Tornado(player, parameters)
    local root = rootOf(player); tornadoEffect(root)
    for _, item in ipairs(CakeService.GetCakes(player, parameters.Count or 5)) do
        CakeService.MoveNearPlayer(player, item.Cake, parameters.Distance or 5, .8)
        CakeService.DamageCake(player, item.Cake, (item.Cake:GetAttribute("Health") or 0) * (parameters.DamagePercent or .4))
    end
end
function SkillService.Handlers.AntCourier(player, parameters)
    local item = CakeService.GetCakes(player, 1, parameters.MinimumDistance or 14)[1]
    if item then
        CakeService.DamageCake(player, item.Cake, (item.Cake:GetAttribute("Health") or 0) * (parameters.DamagePercentPerSecond or .02))
        if item.Cake.Parent then
            local destination = CakeService.MoveNearPlayer(player, item.Cake, parameters.Distance or 4, 1)
            antEffect(item.Cake, destination, 1)
        end
    end
end
function SkillService.Activate(player, cardKey, card)
    local stack, isNew = StateService.AddCardBuff(player, cardKey, card)
    if not stack then return end
    if isNew then
        task.spawn(function()
            local handler = SkillService.Handlers[stack.SkillId]
            while player.Parent and os.clock() < stack.ExpiresAt do
                if handler then handler(player, stack.Parameters) else warn("Cake Rain RNG: missing SkillId handler", stack.SkillId) break end
                task.wait(math.max(.1, stack.TriggerInterval))
            end
            StateService.Push(player)
        end)
    end
    return stack
end
return SkillService
]=]

local wheelService = getOrCreate(servicesPackage, "ModuleScript", "WheelService")
wheelService.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configs = ReplicatedStorage.Configs
local Events = ReplicatedStorage.Events
local WheelConfig = require(Configs.WheelConfig)
local CardConfig = require(Configs.CardConfig)
local ShopConfig = require(Configs.ShopConfig)
local LocalizationConfig = require(Configs.LocalizationConfig)
local StateService = require(script.Parent.StateService)
local SkillService = require(script.Parent.SkillService)

local WheelService = {}

local function text(nameKey) return LocalizationConfig["zh-tw"][nameKey] or nameKey end
local function weightedPick(entries)
    local total = 0
    for _, entry in pairs(entries) do total += entry.Weight or 1 end
    local roll, cursor = math.random() * total, 0
    for key, entry in pairs(entries) do cursor += entry.Weight or 1 if roll <= cursor then return key, entry end end
end
local function unlockedRewards(state)
    local entries = {}
    for key, reward in pairs(WheelConfig.Rewards) do if reward.IsUnlockedDefault or state.UnlockedWheelRewards[key] then entries[key] = reward end end
    return entries
end
local function buildSlots(state)
    local pool, slots, used, count = unlockedRewards(state), {}, {}, 0
    for _ in pairs(pool) do count += 1 end
    local attempts = 0
    while #slots < WheelConfig.DisplayedSlots and attempts < 100 do
        attempts += 1
        local key, reward = weightedPick(pool)
        if not key then break end
        if count < WheelConfig.DisplayedSlots or not used[key] then
            used[key] = true
            table.insert(slots, { Key = key, Name = text(reward.NameKey), Rarity = reward.Rarity, Type = reward.Type, Value = reward.Value or reward.Level, Duration = reward.BaseDuration, Color = WheelConfig.RarityColors[reward.Rarity] })
        end
    end
    return slots
end
local function unlockedCards(state)
    local entries = {}
    for key, card in pairs(CardConfig.Cards) do if card.IsUnlockedDefault or state.UnlockedCards[key] then entries[key] = card end end
    return entries
end
local function shopItem(itemId)
    for _, section in ipairs({ ShopConfig.WheelPointShop, ShopConfig.CakePointShop }) do
        for _, item in ipairs(section) do if item.Id == itemId then return item end end
    end
end

function WheelService.Start()
    Events.RequestWheelSpin.OnServerInvoke = function(player)
        local state = StateService.Get(player)
        if not state or state.WheelSpins <= 0 then return { Ok = false, Error = "NO_SPINS" } end
        state.WheelSpins -= 1
        state.WheelPoints += 1
        local slots = buildSlots(state)
        if #slots == 0 then return { Ok = false, Error = "EMPTY_POOL" } end
        local pickedIndex = math.random(1, #slots)
        local picked = slots[pickedIndex]
        StateService.AddBuff(player, picked.Key, WheelConfig.Rewards[picked.Key])
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true, Slots = slots, Picked = picked, PickedIndex = pickedIndex }
    end

    Events.RequestCardDraw.OnServerInvoke = function(player)
        local state = StateService.Get(player)
        if not state or not state.PendingCardDraw then return { Ok = false, Error = "NO_CARD_DRAW" } end
        state.PendingCardDraw = false
        local key, card = weightedPick(unlockedCards(state))
        local stack = card and SkillService.Activate(player, key, card)
        if stack then
            state.LastDraw = { Key = key }
        end
        StateService.Push(player)
        return { Ok = true, Card = card and { Key = key, Name = text(card.NameKey), Rarity = card.Rarity, Duration = card.Duration, Effect = card.SkillId, Stacks = stack and stack.Stacks or 1 } or nil }
    end

    Events.RequestShopPurchase.OnServerInvoke = function(player, itemId)
        local state, item = StateService.Get(player), shopItem(itemId)
        if not state or not item then return { Ok = false, Error = "INVALID_ITEM" } end
        if item.Currency == "WheelPoints" and state.WheelPoints < item.Cost then return { Ok = false, Error = "NO_WHEEL_POINTS" } end
        if item.Currency == "CakePoints" and state.CakePoints < item.Cost then return { Ok = false, Error = "NO_CAKE_POINTS" } end
        state[item.Currency] = state[item.Currency] - item.Cost
        if item.UnlockType == "WheelReward" then state.UnlockedWheelRewards[item.Id] = true end
        if item.UnlockType == "Card" then state.UnlockedCards[item.Id] = true end
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true }
    end
end

return WheelService
]=]

local serverScript = getOrCreate(serverPackage, "Script", "Main")
serverScript.Source = [=[
local Players = game:GetService("Players")
local DataService = require(script.Parent.Services.DataService)
local StateService = require(script.Parent.Services.StateService)
local CakeService = require(script.Parent.Services.CakeService)
local WheelService = require(script.Parent.Services.WheelService)

WheelService.Start()

local function setupPlayer(player)
    StateService.Create(player, DataService.Load(player))
    CakeService.StartPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
    DataService.Save(player, StateService.Serialize(player))
    CakeService.CleanupPlayer(player)
    StateService.Remove(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService.Save(player, StateService.Serialize(player))
    end
end)
]=]

local clientScript = getOrCreate(StarterPlayer.StarterPlayerScripts, "LocalScript", "CakeRainRNGClient")
clientScript.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Configs = ReplicatedStorage:WaitForChild("Configs")
local RequestWheelSpin = Events:WaitForChild("RequestWheelSpin")
local RequestCardDraw = Events:WaitForChild("RequestCardDraw")
local RequestShopPurchase = Events:WaitForChild("RequestShopPurchase")
local UpdateClientState = Events:WaitForChild("UpdateClientState")
local LocalizationConfig = require(Configs:WaitForChild("LocalizationConfig"))
local ShopConfig = require(Configs:WaitForChild("ShopConfig"))
local L = LocalizationConfig["zh-tw"]

local gui = player:WaitForChild("PlayerGui"):WaitForChild("CakeRainRNGHUD")
local stats = gui:WaitForChild("StatsFrame")
local wheel = gui:WaitForChild("WheelPanel")
local disc = wheel:WaitForChild("WheelDisc")
local spinButton = wheel:WaitForChild("SpinButton")
local autoRollToggle = wheel:WaitForChild("AutoRollToggle")
local buffFrame = gui:WaitForChild("EffectBar")
local tooltip = buffFrame:WaitForChild("Tooltip")
local currentDrawLabel = gui:WaitForChild("CurrentDrawLabel")
local cardFrame = gui:WaitForChild("CardDraw")
local drawButton = cardFrame:WaitForChild("DrawButton")
local cardResult = cardFrame:WaitForChild("Result")
local shopButton = gui:WaitForChild("ShopButton")
local shopHub = gui:WaitForChild("ShopHub")
local closeShop = shopHub:WaitForChild("CloseButton")

local state = { WheelSpins = 0, WheelPoints = 0, CakePoints = 0, ActiveBuffs = {}, PendingCardDraw = false, LastDraw = nil }
local spinning = false
local autoRollEnabled = false
local autoRollThread = nil

local function buttonLabel(item)
    local name = L[item.NameKey] or item.NameKey
    return string.format("%s\n%s %d", name, item.Currency == "WheelPoints" and "轉盤點數" or "蛋糕積分", item.Cost)
end

local function bindShopButtons()
    local cakePane = shopHub:WaitForChild("CakePointShop")
    for index, item in ShopConfig.CakePointShop do
        local button = cakePane:FindFirstChild("Buy" .. index)
        if button then
            button.Visible = true
            button.Text = buttonLabel(item)
            button.Activated:Connect(function()
                RequestShopPurchase:InvokeServer(item.Id)
            end)
        end
    end
    for index = #ShopConfig.CakePointShop + 1, 3 do cakePane:FindFirstChild("Buy" .. index).Visible = false end
    local wheelPane = shopHub:WaitForChild("WheelPointShop")
    for index, item in ShopConfig.WheelPointShop do
        local button = wheelPane:FindFirstChild("Buy" .. index)
        if button then
            button.Visible = true
            button.Text = buttonLabel(item)
            button.Activated:Connect(function()
                RequestShopPurchase:InvokeServer(item.Id)
            end)
        end
    end
    for index = #ShopConfig.WheelPointShop + 1, 3 do wheelPane:FindFirstChild("Buy" .. index).Visible = false end
end
bindShopButtons()
for index = 1, 8 do
    local slot = buffFrame:WaitForChild("EffectIcon" .. index)
    slot.MouseEnter:Connect(function()
        local text = slot:GetAttribute("Tooltip")
        if text and text ~= "" then
            tooltip.Text = text
            tooltip.Visible = true
        end
    end)
    slot.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

local function hasAutoRoll()
    local buff = state.ActiveBuffs and state.ActiveBuffs.AutoRoll
    return buff ~= nil and (buff.Remaining or 0) > 0
end

local function refreshEffectBar()
    local index = 0
    for _, buff in pairs(state.ActiveBuffs or {}) do
        index += 1
        local slot = buffFrame:FindFirstChild("EffectIcon" .. index)
        if slot then
            slot.Visible = true
            slot.Image = buff.Icon or ""
            slot.Outline.Color = buff.OutlineColor or Color3.fromRGB(255, 255, 255)
            slot:SetAttribute("Tooltip", string.format("%s [%s] 層數:%s / %ss", buff.Name, buff.Rarity, tostring(buff.Stacks or 1), tostring(buff.Remaining)))
        end
    end
    for slotIndex = index + 1, 8 do
        local slot = buffFrame:FindFirstChild("EffectIcon" .. slotIndex)
        if slot then slot.Visible = false slot.Image = "" slot:SetAttribute("Tooltip", "") end
    end
    buffFrame.Visible = index > 0
end

local function refreshStats()
    stats.CakePointsLabel.Text = L.UI_CakePoints .. tostring(state.CakePoints)
    stats.WheelPointsLabel.Text = L.UI_WheelPoints .. tostring(state.WheelPoints)
    stats.SpinsLabel.Text = L.UI_Spins_Left .. tostring(state.WheelSpins)
    local autoAvailable = hasAutoRoll()
    if not autoAvailable then autoRollEnabled = false end
    autoRollToggle.Visible = autoAvailable
    autoRollToggle.Text = autoRollEnabled and "自動抽獎: ON" or "自動抽獎: OFF"
    autoRollToggle.BackgroundColor3 = autoRollEnabled and Color3.fromRGB(95, 190, 120) or Color3.fromRGB(80, 95, 120)
    wheel.Visible = state.WheelSpins > 0 or spinning or autoAvailable
    cardFrame.Visible = state.PendingCardDraw
    local draw = state.LastDraw
    currentDrawLabel.Visible = draw ~= nil
    if draw then currentDrawLabel.Text = string.format("目前抽到：%s [%s]｜層數 %d｜剩餘 %d 秒", draw.Name, draw.Rarity, draw.Stacks or 1, draw.Remaining or 0) end
    refreshEffectBar()
end

local function paintSlots(slots, pickedIndex)
    for index = 1, 5 do
        local sector = disc:FindFirstChild("Sector" .. index)
        local label = sector and sector:FindFirstChild("Text")
        local slot = slots and slots[index]
        if sector and label and slot then
            label.Text = slot.Name
            sector.BackgroundColor3 = slot.Color or Color3.fromRGB(95, 63, 145)
            sector.BackgroundTransparency = index == pickedIndex and 0 or 0.12
        elseif label then
            label.Text = "?"
        end
    end
end

local function playWheelAnimation(slots, pickedIndex)
    paintSlots(slots, nil)
    disc.Rotation = 0
    local selectedSector = disc:FindFirstChild("Sector" .. pickedIndex)
    local selectedAngle = selectedSector and selectedSector:GetAttribute("WheelAngle") or -90
    -- The pointer faces right from the disc's left edge (180°), so finish with the selected panel under it.
    local targetRotation = 1080 + (180 - selectedAngle)
    local tween = TweenService:Create(disc, TweenInfo.new(2.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = targetRotation })
    tween:Play()
    tween.Completed:Wait()
    paintSlots(slots, pickedIndex)
    local pulse = TweenService:Create(disc, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 1, true), { Size = UDim2.new(0, 374, 0, 374), Position = UDim2.new(0, -7, 0, -7) })
    pulse:Play()
end

local function performSpin()
    if spinning or state.WheelSpins <= 0 then return false end
    spinning = true
    refreshStats()
    local result = RequestWheelSpin:InvokeServer()
    if result and result.Ok then
        playWheelAnimation(result.Slots, result.PickedIndex)
    end
    spinning = false
    refreshStats()
    return result and result.Ok
end

local function ensureAutoRollLoop()
    if autoRollThread then return end
    autoRollThread = task.spawn(function()
        while autoRollEnabled and hasAutoRoll() do
            if state.WheelSpins > 0 then
                performSpin()
            end
            local interval = (state.ActiveBuffs.AutoRoll and state.ActiveBuffs.AutoRoll.Interval) or 1
            task.wait(math.max(0.5, interval))
        end
        autoRollEnabled = false
        autoRollThread = nil
        refreshStats()
    end)
end

spinButton.Activated:Connect(function()
    performSpin()
end)

autoRollToggle.Activated:Connect(function()
    if not hasAutoRoll() then return end
    autoRollEnabled = not autoRollEnabled
    refreshStats()
    if autoRollEnabled then ensureAutoRollLoop() end
end)

drawButton.Activated:Connect(function()
    local result = RequestCardDraw:InvokeServer()
    if result and result.Ok and result.Card then
        cardResult.Text = result.Card.Name .. " [" .. result.Card.Rarity .. "]"
        cardResult.TextTransparency = 1
        TweenService:Create(cardResult, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
    end
end)

shopButton.Activated:Connect(function()
    shopHub.Visible = true
end)
closeShop.Activated:Connect(function()
    shopHub.Visible = false
end)

UpdateClientState.OnClientEvent:Connect(function(newState)
    for key, value in newState do
        state[key] = value
    end
    refreshStats()
end)

refreshStats()
]=]

if recording then
    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

Selection:Set({serverScript, clientScript, mainGui, wheelConfig, cakeConfig, skillConfig, cardConfig, shopConfig, uiConfig, localizationConfig, cakeModelsFolder, mapBase})
print("✅ Cake Rain RNG 已重構完成：靜態 UI/HUB/轉盤分區、動畫抽獎、非錨定下落蛋糕、自動吞食、稀有度 outline、發光特效、下沉與咖啡色痕跡、DataStore 個人資料皆已配置。")
