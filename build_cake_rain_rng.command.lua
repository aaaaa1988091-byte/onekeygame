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
local requestAbilityUpgrade = getOrCreate(eventsFolder, "RemoteFunction", "RequestAbilityUpgrade")
local updateClientState = getOrCreate(eventsFolder, "RemoteEvent", "UpdateClientState")

local wheelConfig = getOrCreate(configsFolder, "ModuleScript", "WheelConfig")
wheelConfig.Source = [=[
local WheelConfig = {
    DisplayedSlots = 5,
    RarityPriority = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
    BaseRarityWeights = { Common = 650, Rare = 250, Epic = 80, Legendary = 18, Mythic = 2 },
    WheelLevelBonusByRarity = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    WheelLevelDurationByRarity = { Common = 45, Rare = 60, Epic = 60, Legendary = 60, Mythic = 60 },
    AbilityLevelCaps = { [1] = "Epic", [2] = "Legendary", [3] = "Mythic" },
    AbilityUpgradeCosts = { [1] = 800, [2] = 2200 },
    ServerMerchant = { RefreshSeconds = 240, SlotCount = 3 },
    RarityColors = {
        Common = Color3.fromRGB(210, 210, 210),
        Rare = Color3.fromRGB(70, 170, 255),
        Epic = Color3.fromRGB(185, 85, 255),
        Legendary = Color3.fromRGB(255, 170, 0),
        Mythic = Color3.fromRGB(255, 60, 120),
        SSR = Color3.fromRGB(120, 255, 255),
    },
    Rewards = {
        EatSpeed = { ScriptName = "EatSpeed", NameKey = "Reward_EatSpeed", Weight = 300, Icon = "rbxassetid://6031075938", IsUnlockedDefault = true },
        GlowCakeBoost = { ScriptName = "GlowRate", NameKey = "Reward_GlowBoost", Weight = 50, Icon = "rbxassetid://6031071053", IsUnlockedDefault = false, UnlockCostWheelPoints = 50 },
        AutoRoll = { ScriptName = "AutoRoll", NameKey = "Reward_AutoRoll", Weight = 50, Icon = "rbxassetid://6031091002", IsUnlockedDefault = true },
        WheelHaste = { ScriptName = "WheelHaste", NameKey = "Reward_WheelHaste", Weight = 65, Icon = "rbxassetid://6031763426", IsUnlockedDefault = true },
        WheelLevelUp = { ScriptName = "WheelLevelUp", NameKey = "Reward_WheelLevelUp", Weight = 55, Icon = "rbxassetid://6031068426", IsUnlockedDefault = true },
        PlayerSpeed = { ScriptName = "PlayerSpeed", NameKey = "Reward_PlayerSpeed", Weight = 85, Icon = "rbxassetid://6034754445", IsUnlockedDefault = true },
    },
}
return WheelConfig
]=]

local localizationConfig = getOrCreate(configsFolder, "ModuleScript", "LocalizationConfig")
localizationConfig.Source = [=[
local LocalizationConfig = {
    ["en-us"] = {
        UI_Spins_Left = "Spins Left: ", UI_WheelPoints = "Wheel Points: ", UI_CakePoints = "Cake Points: ",
        UI_AutoRoll_Active = "Auto-Roll Active...", UI_Shop_Title = "Shop Hub", UI_CakeShop_Title = "Cake Point Shop",
        UI_WheelShop_Title = "Wheel Point Shop", UI_Time_Left = "Time Left: ", UI_No_Buff = "No Active Buff", UI_Spin = "Spin",
        UI_Card_Draw = "Glow Cake Card Draw", UI_Open_Shop = "Shop", UI_Open_Bag = "Bag", UI_Close = "Close", UI_Buy = "Buy", UI_Bag_Title = "Ability Bag", UI_Bag_Wheel = "Wheel Terms", UI_Bag_Cards = "Drawable Skills", UI_Locked = "Locked", UI_Unlocked = "Owned",
        Cake_Common = "Common Cake", Cake_Rare = "Rare Cake", Cake_Epic = "Epic Cake", Cake_Legendary = "Legendary Cake", Cake_Mythic = "Mythic Cake", Cake_Special = "Glow Cake",
        Reward_EatSpeed = "Eat Speed Up", Reward_GlowBoost = "Glow Cake Rate Up", Reward_AutoRoll = "Auto-Roll", Reward_WheelHaste = "Wheel Haste", Reward_WheelLevelUp = "Wheel Level Up", Reward_PlayerSpeed = "Player Speed Up", UI_Normal_Wheel = "Reward Wheel", UI_Silver_Wheel = "Silver Wheel", UI_Merchant_Tab = "Mystery Merchant", UI_Upgrade = "Upgrade",
        Card_Hook = "Grappling Hook", Card_Tornado = "Tornado", Card_Ant = "Ant Courier", Card_Attract = "Cake Attraction",
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
    SpawnInterval = 1.25,
    SpawnRadius = 55,
    SpawnHeight = 85,
    -- Cake count is intentionally unbounded; CakeLifetimeSeconds is the cleanup limiter.
    GlowBaseChance = 0.03,
    InitialBurstCount = 6,
    MeteorFallSpeed = 105,
    CakeBounciness = 0.05,
    MeteorTrailLifetime = 0.45,
    SinkSeconds = 1.1,
    EatAnimationSeconds = 0.45,
    CakeLifetimeSeconds = 70,
    MinimumSpawnDistance = 4, -- About 1 meter; prevent drops right at the player's feet
    MinimumCakeScale = 0.28,
    MaximumCakeScale = 1.45,
    HealthForMaximumScale = 24,
    LabelMaxDistance = 33, -- About 10 meters; hide world cake text at long distance
    StainVisibleSeconds = 2,
    ValueScalePerLevel = 2.5,
    UpgradeDecisionSeconds = 0.5,
    UpgradeDecisionWindowSeconds = 3,
    RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
    Rarities = {
        Common = { NameKey = "Cake_Common", RarityText = "COMMON", OutlineColor = Color3.fromRGB(210, 210, 210) },
        Rare = { NameKey = "Cake_Rare", RarityText = "RARE", OutlineColor = Color3.fromRGB(70, 170, 255) },
        Epic = { NameKey = "Cake_Epic", RarityText = "EPIC", OutlineColor = Color3.fromRGB(185, 85, 255) },
        Legendary = { NameKey = "Cake_Legendary", RarityText = "LEGENDARY", OutlineColor = Color3.fromRGB(255, 170, 0) },
        Mythic = { NameKey = "Cake_Mythic", RarityText = "MYTHIC", OutlineColor = Color3.fromRGB(255, 60, 120) },
    },
}
return CakeConfig
]=]

local skillConfig = getOrCreate(configsFolder, "ModuleScript", "SkillConfig")
skillConfig.Source = [=[
-- Card config stays lightweight: each card declares only identity, weight, unlock policy, and script routing.
-- Rarity-specific duration, intervals, parameters, and effect strength belong in the matching skill script.
local SkillConfig = {
    Cards = {
        Card_Hook = { NameKey = "Card_Hook", Weight = 20, SkillId = "PullNearest", ScriptName = "HookSkill", AbilityKey = "Card_Hook", MaxAbilityLevel = 3, Icon = "rbxassetid://6031068421", IsUnlockedDefault = true },
        Card_Attract = { NameKey = "Card_Attract", Weight = 45, SkillId = "Attract", ScriptName = "AttractSkill", AbilityKey = "Card_Attract", MaxAbilityLevel = 3, Icon = "rbxassetid://6031068421", IsUnlockedDefault = true },
        Card_Tornado = { NameKey = "Card_Tornado", Weight = 10, SkillId = "Tornado", ScriptName = "TornadoSkill", AbilityKey = "Card_Tornado", MaxAbilityLevel = 3, Icon = "rbxassetid://6031068421", IsUnlockedDefault = false, UnlockCostCakePoints = 1500 },
        Card_Ant = { NameKey = "Card_Ant", Weight = 5, SkillId = "AntCourier", ScriptName = "AntSkill", AbilityKey = "Card_Ant", MaxAbilityLevel = 3, Icon = "rbxassetid://6031068421", IsUnlockedDefault = false, UnlockCostCakePoints = 3000 },
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
        { Id = "GlowCakeBoost", NameKey = "Reward_GlowBoost", Cost = 50, Currency = "WheelPoints", UnlockType = "WheelReward", Icon = "rbxassetid://6031071053" },
    },
    CakePointShop = {
        { Id = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1500, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421" },
        { Id = "Card_Ant", NameKey = "Card_Ant", Cost = 3000, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421" },
    },
    MysteryMerchantPool = {
        { Id = "Merchant_GlowCakeBoost", Grants = "GlowCakeBoost", NameKey = "Reward_GlowBoost", Cost = 40, Currency = "WheelPoints", UnlockType = "WheelReward", Icon = "rbxassetid://6031071053", Weight = 3 },
        { Id = "Merchant_Tornado", Grants = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1200, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421", Weight = 2 },
        { Id = "Merchant_Ant", Grants = "Card_Ant", NameKey = "Card_Ant", Cost = 2400, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421", Weight = 1 },
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
local function createCakeModel(name, baseColor, initialCakeLevel, initialHealth, initialReward, initialWheelTickets, initialUpgradeChance)
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("InitialCakeLevel", initialCakeLevel or 1)
    model:SetAttribute("InitialHealth", initialHealth or 1)
    model:SetAttribute("InitialReward", initialReward or 1)
    model:SetAttribute("InitialWheelTickets", initialWheelTickets or 1)
    model:SetAttribute("InitialUpgradeChance", initialUpgradeChance or 0.25)
    model.Parent = cakeModelsFolder

    local base = Instance.new("Part")
    base.Name = "CakeBody"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(2.8, 9.6, 9.6)
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
    frosting.Size = Vector3.new(0.7, 9.8, 9.8)
    frosting.Color = Color3.fromRGB(255, 245, 250)
    frosting.Material = Enum.Material.SmoothPlastic
    frosting.Anchored = false
    frosting.CanCollide = true
    frosting.TopSurface = Enum.SurfaceType.Smooth
    frosting.BottomSurface = Enum.SurfaceType.Smooth
    frosting.CFrame = base.CFrame * CFrame.new(1.8, 0, 0)
    frosting.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = base
    weld.Part1 = frosting
    weld.Parent = base

    model.PrimaryPart = base
    return model
end
createCakeModel("RoundCake", Color3.fromRGB(255, 190, 205), 1, 1, 1, 1, 0.34)
createCakeModel("VanillaCake", Color3.fromRGB(255, 225, 160), 2, 2, 2, 2, 0.24)
createCakeModel("ChocolateCake", Color3.fromRGB(130, 75, 45), 3, 4, 4, 3, 0.16)

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
    label.Font = Enum.Font.FredokaOne
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
end
local upgradeButton = newGui("TextButton", "UpgradeButton", mainGui)
upgradeButton.Size = UDim2.new(0, 180, 0, 46)
upgradeButton.Position = UDim2.new(0, 18, 0, 148)
upgradeButton.BackgroundColor3 = Color3.fromRGB(72, 150, 104)
upgradeButton.Text = "UPGRADES"
upgradeButton.TextScaled = true
newGui("UICorner", "Corner", upgradeButton).CornerRadius = UDim.new(0, 12)

local buffFrame = newGui("Frame", "EffectBar", mainGui)
buffFrame.Size = UDim2.new(0, 392, 0, 74)
buffFrame.Position = UDim2.new(0, 18, 1, -92)
buffFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
buffFrame.BackgroundTransparency = 0.12
buffFrame.Visible = false
newGui("UICorner", "Corner", buffFrame).CornerRadius = UDim.new(0, 16)
-- The client clones this only for active effects; the empty HUD has no placeholder icons.
local effectTemplate = newGui("ImageButton", "EffectIconTemplate", buffFrame)
effectTemplate.Size = UDim2.new(0, 46, 0, 46)
effectTemplate.BackgroundColor3 = Color3.fromRGB(45, 55, 70)
effectTemplate.AutoButtonColor = false
effectTemplate.Visible = false
effectTemplate.Image = ""
newGui("UICorner", "Corner", effectTemplate).CornerRadius = UDim.new(0, 10)
local templateStroke = newGui("UIStroke", "Outline", effectTemplate)
templateStroke.Thickness = 3
templateStroke.Color = Color3.fromRGB(255, 255, 255)
local templateCooldown = newGui("Frame", "CooldownFill", effectTemplate)
templateCooldown.AnchorPoint = Vector2.new(0, 1)
templateCooldown.Position = UDim2.new(0, 0, 1, 0)
templateCooldown.Size = UDim2.new(1, 0, 0, 0)
templateCooldown.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
templateCooldown.BackgroundTransparency = 0.22
templateCooldown.BorderSizePixel = 0
templateCooldown.Visible = false
templateCooldown.ZIndex = 2
local templateCooldownText = newGui("TextLabel", "CooldownText", effectTemplate)
templateCooldownText.BackgroundTransparency = 1
templateCooldownText.Size = UDim2.fromScale(1, 1)
templateCooldownText.Font = Enum.Font.FredokaOne
templateCooldownText.TextScaled = true
templateCooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
templateCooldownText.TextStrokeTransparency = 0
templateCooldownText.ZIndex = 3
templateCooldownText.Visible = false

local tooltip = newGui("TextLabel", "Tooltip", buffFrame)
tooltip.Size = UDim2.new(0, 260, 0, 34)
tooltip.Position = UDim2.new(0, 8, 0, -38)
tooltip.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
tooltip.BackgroundTransparency = 0.08
tooltip.Font = Enum.Font.FredokaOne
tooltip.TextScaled = true
tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltip.Visible = false
newGui("UICorner", "Corner", tooltip).CornerRadius = UDim.new(0, 8)

-- A short bottom status readout shows the most recent wheel reward, including rarity tier.
local currentDrawLabel = newGui("TextLabel", "CurrentDrawLabel", mainGui)
currentDrawLabel.Size = UDim2.new(0, 392, 0, 28)
currentDrawLabel.Position = UDim2.new(0, 18, 1, -124)
currentDrawLabel.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
currentDrawLabel.BackgroundTransparency = 0.12
currentDrawLabel.Font = Enum.Font.FredokaOne
currentDrawLabel.TextScaled = true
currentDrawLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
currentDrawLabel.Visible = false
newGui("UICorner", "Corner", currentDrawLabel).CornerRadius = UDim.new(0, 8)

-- The entire progression surface is editor-built here.  The client only changes visibility/text/state.
local upgradeTreeConfig = getOrCreate(configsFolder, "ModuleScript", "UpgradeTreeConfig")
upgradeTreeConfig.Source = [=[
local UpgradeTreeConfig = {
    HexImage = "rbxassetid://78177596646611",
    CurrencyIcons = { CakePoints = "rbxassetid://6031075938", WheelPoints = "rbxassetid://6031071053" },
    Nodes = {
        { Key = "EatSpeed", NameKey = "Reward_EatSpeed", Q = 0, R = 0, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "AutoRoll", NameKey = "Reward_AutoRoll", Q = 1, R = 0, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "WheelHaste", NameKey = "Reward_WheelHaste", Q = 0, R = 1, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "WheelLevelUp", NameKey = "Reward_WheelLevelUp", Q = -1, R = 1, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "PlayerSpeed", NameKey = "Reward_PlayerSpeed", Q = -1, R = 0, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "Card_Hook", NameKey = "Card_Hook", Q = 0, R = -1, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "Card_Attract", NameKey = "Card_Attract", Q = 1, R = -1, Default = true, Currency = "CakePoints", Upgrade = true },
        { Key = "GlowCakeBoost", NameKey = "Reward_GlowBoost", Q = 2, R = 0, Cost = 50, Currency = "WheelPoints", PurchaseId = "GlowCakeBoost" },
        { Key = "Card_Tornado", NameKey = "Card_Tornado", Q = 1, R = 1, Cost = 1500, Currency = "CakePoints", PurchaseId = "Card_Tornado" },
        { Key = "Card_Ant", NameKey = "Card_Ant", Q = -2, R = 1, Cost = 3000, Currency = "CakePoints", PurchaseId = "Card_Ant" },
    },
}
return UpgradeTreeConfig
]=]

local upgradeTree = newGui("Frame", "UpgradeTree", mainGui)
upgradeTree.Size = UDim2.fromScale(1, 1)
upgradeTree.Position = UDim2.fromScale(0, 0)
upgradeTree.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
upgradeTree.BackgroundTransparency = 0.38
upgradeTree.Visible = false
upgradeTree.Active = true
local treeTitle = newGui("TextLabel", "Title", upgradeTree)
treeTitle.BackgroundTransparency, treeTitle.Size, treeTitle.Position, treeTitle.Text = 1, UDim2.new(0, 300, 0, 48), UDim2.new(.5, -150, 0, 12), "UPGRADE TREE"
treeTitle.TextScaled, treeTitle.TextColor3 = true, Color3.fromRGB(255, 255, 255)
local treeClose = newGui("TextButton", "CloseButton", upgradeTree)
treeClose.Size, treeClose.Position, treeClose.Text = UDim2.new(0, 90, 0, 38), UDim2.new(1, -104, 0, 14), "CLOSE"
treeClose.BackgroundColor3, treeClose.TextScaled = Color3.fromRGB(170, 65, 65), true
newGui("UICorner", "Corner", treeClose).CornerRadius = UDim.new(0, 10)
-- The scrolling canvas is the draggable viewport: it never changes node layout at runtime.
local hexLayer = newGui("ScrollingFrame", "HexLayer", upgradeTree)
hexLayer.Size, hexLayer.Position = UDim2.new(1, -40, 1, -78), UDim2.new(0, 20, 0, 64)
hexLayer.BackgroundTransparency, hexLayer.BorderSizePixel = 1, 0
hexLayer.CanvasSize = UDim2.new(0, 1800, 0, 1400)
hexLayer.CanvasPosition = Vector2.new(540, 430)
hexLayer.ScrollBarThickness = 8
hexLayer.ScrollingDirection = Enum.ScrollingDirection.XY
hexLayer.ElasticBehavior = Enum.ElasticBehavior.Always
local treeNodes = require(upgradeTreeConfig).Nodes
local hexImage = require(upgradeTreeConfig).HexImage
-- Flat-top axial conversion, deliberately compact: x = size * 3/2*q, y = size * sqrt(3)*(r + q/2).
for _, node in ipairs(treeNodes) do
    local hex = newGui("ImageButton", "Hex_" .. node.Key, hexLayer)
    hex.AnchorPoint = Vector2.new(.5, .5)
    hex.Size = UDim2.new(0, 108, 0, 96)
    hex.Position = UDim2.new(0, 900 + 68 * 1.5 * node.Q, 0, 700 + 68 * math.sqrt(3) * (node.R + node.Q / 2))
    hex.BackgroundTransparency, hex.Image, hex.ScaleType = 1, hexImage, Enum.ScaleType.Stretch
    hex:SetAttribute("NodeKey", node.Key)
    hex:SetAttribute("Default", node.Default == true)
    hex:SetAttribute("PurchaseId", node.PurchaseId or "")
    hex:SetAttribute("Currency", node.Currency or "CakePoints")
    hex:SetAttribute("Cost", node.Cost or 0)
    local gradient = newGui("UIGradient", "StateGradient", hex)
    gradient.Color = ColorSequence.new(Color3.fromRGB(50, 55, 68), Color3.fromRGB(20, 24, 32))
    gradient.Rotation = 45
    local center = newGui("TextLabel", "CenterText", hex)
    center.BackgroundTransparency, center.Size, center.Position = 1, UDim2.new(.72, 0, .48, 0), UDim2.new(.14, 0, .20, 0)
    center.TextScaled, center.TextWrapped, center.Text = true, true, "?"
    local cost = newGui("TextLabel", "Cost", hex)
    cost.BackgroundTransparency, cost.Size, cost.Position = 1, UDim2.new(.46, 0, .20, 0), UDim2.new(.40, 0, .67, 0)
    cost.TextScaled, cost.TextXAlignment, cost.Text = true, Enum.TextXAlignment.Right, tostring(node.Cost or 0)
    local icon = newGui("ImageLabel", "CurrencyIcon", cost)
    icon.BackgroundTransparency, icon.Size, icon.Position = 1, UDim2.new(0, 20, 0, 20), UDim2.new(0, -24, .5, -10)
    icon.Image = require(upgradeTreeConfig).CurrencyIcons[node.Currency or "CakePoints"]
end

-- A single, neutral reel: manual draws are one spin; the Auto-Roll effect controls automatic draw count.
local slotMachine = newGui("Frame", "SlotMachine", mainGui)
slotMachine.AnchorPoint, slotMachine.Size, slotMachine.Position = Vector2.new(1, .5), UDim2.new(0, 300, 0, 214), UDim2.new(1, -18, .5, 0)
slotMachine.BackgroundTransparency, slotMachine.BorderSizePixel = 1, 0
local reel = newGui("TextLabel", "Reel", slotMachine)
reel.Size, reel.Position = UDim2.new(1, -24, 0, 102), UDim2.new(0, 12, 0, 12)
reel.BackgroundColor3, reel.Text, reel.TextScaled, reel.TextWrapped = Color3.fromRGB(24, 24, 28), "?", true, true
newGui("UICorner", "Corner", reel).CornerRadius = UDim.new(0, 14)
local reelStroke = newGui("UIStroke", "Outline", reel)
reelStroke.Color, reelStroke.Thickness = Color3.fromRGB(235, 235, 235), 2
local drawButton = newGui("TextButton", "DrawButton", slotMachine)
drawButton.Size, drawButton.Position, drawButton.Text, drawButton.TextScaled = UDim2.new(.48, -6, 0, 52), UDim2.new(0, 12, 1, -64), "DRAW", true
drawButton.BackgroundColor3 = Color3.fromRGB(238, 178, 70)
newGui("UICorner", "Corner", drawButton).CornerRadius = UDim.new(0, 12)
local autoDrawButton = newGui("TextButton", "AutoDrawButton", slotMachine)
autoDrawButton.Size, autoDrawButton.Position, autoDrawButton.Text, autoDrawButton.TextScaled = UDim2.new(.52, -18, 0, 52), UDim2.new(.48, 12, 1, -64), "AUTO DRAW: OFF", true
autoDrawButton.BackgroundColor3 = Color3.fromRGB(70, 105, 85)
newGui("UICorner", "Corner", autoDrawButton).CornerRadius = UDim.new(0, 12)

-- A single style pass guarantees every text object uses the same required font and round black outline.
local function applyTextStyle(root)
    for _, item in ipairs(root:GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") then
            item.Font = Enum.Font.FredokaOne
            local stroke = item:FindFirstChild("TextOutline") or newGui("UIStroke", "TextOutline", item)
            stroke.Color, stroke.LineJoinMode, stroke.Thickness = Color3.fromRGB(0, 0, 0), Enum.LineJoinMode.Round, 3
        end
    end
end
applyTextStyle(mainGui)

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
    return LocalizationConfig["en-us"][nameKey] or nameKey
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
        WheelLevel = math.max(1, loaded.WheelLevel or 1),
        PendingWheelSpin = nil,
        CakePoints = loaded.CakePoints or 0,
        PendingCardDraw = false,
        LastWheelReward = nil,
        Buffs = StateService.RestoreBuffs(loaded.ActiveBuffs or loaded.Buffs),
        OwnedItems = loaded.OwnedItems or {},
        AbilityLevels = loaded.AbilityLevels or {},
        MerchantPurchases = loaded.MerchantPurchases or {},
        Stats = loaded.Stats or {},
        UnlockedWheelRewards = loaded.UnlockedWheelRewards or {},
        UnlockedCards = loaded.UnlockedCards or {},
    }
    StateService.UpdateLeaderstats(player)
    StateService.Push(player)
end

function StateService.Get(player)
    return StateService.States[player]
end

-- Unified read/write profile accessor for services that need the player data table.
function StateService.GetProfile(player)
    local state = StateService.Get(player)
    if not state then return nil end
    return state
end

function StateService.RestoreBuffs(savedBuffs)
    local restored = {}
    for buffType, stacks in pairs(savedBuffs or {}) do
        restored[buffType] = {}
        for _, stack in ipairs(stacks) do
            local copy = table.clone(stack)
            copy.Remaining = math.max(0, copy.Remaining or 0)
            copy.ExpiresAt = nil
            copy.ActiveStartedAt = nil
            copy.CooldownEndsAt = nil
            if copy.Remaining > 0 then table.insert(restored[buffType], copy) end
        end
    end
    return restored
end

function StateService.TickBuffType(state, buffType)
    local stacks, now = state.Buffs[buffType], os.clock()
    if not stacks then return nil end
    local activeIndex, activeStack, activePriority = nil, nil, -1
    for index = #stacks, 1, -1 do
        local stack = stacks[index]
        if (stack.Remaining or 0) <= 0 then
            table.remove(stacks, index)
        else
            local priority = (stack.Level or 0) + (WheelConfig.RarityPriority[stack.Rarity] or 0)
            if priority > activePriority then activeIndex, activeStack, activePriority = index, stack, priority end
        end
    end
    for _, stack in ipairs(stacks) do
        if stack == activeStack then
            local elapsed = math.max(0, now - (stack.ActiveStartedAt or now))
            stack.Remaining = math.max(0, (stack.Remaining or 0) - elapsed)
            stack.ActiveStartedAt = now
        else
            stack.ActiveStartedAt = nil -- lower tiers are sealed: their timers do not tick.
        end
    end
    if activeStack and activeStack.Remaining <= 0 then
        table.remove(stacks, activeIndex)
        return StateService.TickBuffType(state, buffType)
    end
    return activeStack
end

function StateService.SerializeBuffs(state)
    local saved = {}
    for buffType, stacks in pairs(state.Buffs or {}) do
        StateService.TickBuffType(state, buffType)
        for _, stack in ipairs(stacks) do
            if (stack.Remaining or 0) > 0 then
                saved[buffType] = saved[buffType] or {}
                local copy = table.clone(stack)
                copy.ActiveStartedAt = nil
                copy.CooldownEndsAt = nil
                table.insert(saved[buffType], copy)
            end
        end
    end
    return saved
end

function StateService.Serialize(player)
    local state = StateService.Get(player)
    if not state then return {} end
    return {
        WheelSpins = state.WheelSpins,
        WheelPoints = state.WheelPoints,
        WheelLevel = state.WheelLevel,
        CakePoints = state.CakePoints,
        ActiveBuffs = StateService.SerializeBuffs(state),
        OwnedItems = state.OwnedItems,
        AbilityLevels = state.AbilityLevels,
        MerchantPurchases = state.MerchantPurchases,
        Stats = state.Stats,
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
    local stack = StateService.TickBuffType(state, statName)
    return stack and (stack.Value or 0) or 0
end

function StateService.AddBuff(player, key, reward)
    local state = StateService.Get(player)
    if not state then return end
    local buffType = reward.Type == "Stat" and reward.Stat or reward.Type
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    StateService.TickBuffType(state, buffType)
    local incomingPriority = WheelConfig.RarityPriority[reward.Rarity] or 0
    for _, existing in ipairs(state.Buffs[buffType]) do
        local existingPriority = WheelConfig.RarityPriority[existing.Rarity] or 0
        if existing.Key == key and existingPriority == incomingPriority then
            existing.Remaining = (existing.Remaining or 0) + reward.BaseDuration
            existing.Stacks = (existing.Stacks or 1) + 1
            return existing
        end
    end
    local stack = { Key = key, NameKey = reward.NameKey, Rarity = reward.Rarity, Value = reward.Value, Level = reward.Level, Icon = reward.Icon, Interval = reward.Interval, MultiRolls = reward.MultiRolls, Stacks = 1, Remaining = reward.BaseDuration }
    table.insert(state.Buffs[buffType], stack)
    StateService.TickBuffType(state, buffType)
    return stack
end

function StateService.AbilityLevel(player, abilityKey)
    local state = StateService.Get(player)
    if not state then return 1 end
    return math.max(1, state.AbilityLevels[abilityKey] or 1)
end

function StateService.RarityCapForAbility(player, abilityKey)
    local level = StateService.AbilityLevel(player, abilityKey)
    local cap = WheelConfig.AbilityLevelCaps[level] or "Mythic"
    return WheelConfig.RarityPriority[cap] or 5, cap
end

function StateService.AddCardBuff(player, key, card)
    local state = StateService.Get(player)
    if not state then return end
    local abilityKey = card.AbilityKey or key
    local buffType = "Skill_" .. abilityKey
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    StateService.TickBuffType(state, buffType)
    local level = card.Level or (WheelConfig.RarityPriority[card.Rarity] or 1)
    local duration = card.Duration or 60
    for _, existing in ipairs(state.Buffs[buffType]) do
        local existingLevel = existing.Level or (WheelConfig.RarityPriority[existing.Rarity] or 1)
        if existing.Key == key and existingLevel == level then
            existing.Remaining = (existing.Remaining or 0) + duration
            existing.Stacks = (existing.Stacks or 1) + 1
            return existing, false
        end
    end
    local stack = { Key = key, AbilityKey = abilityKey, NameKey = card.NameKey, Rarity = card.Rarity, Value = 1, Level = level, Icon = card.Icon, SkillId = card.SkillId, ScriptName = card.ScriptName, Parameters = card.Parameters or {}, TriggerInterval = card.TriggerInterval or 1, Stacks = 1, Remaining = duration }
    table.insert(state.Buffs[buffType], stack)
    StateService.TickBuffType(state, buffType)
    return stack, true
end

function StateService.ActiveBuffs(player)
    local state = StateService.Get(player)
    local active, now = {}, os.clock()
    if not state then return active end
    for buffType in pairs(state.Buffs) do
        local best = StateService.TickBuffType(state, buffType)
        if best then
            active[buffType] = { Name = text(best.NameKey), Rarity = best.Rarity, Value = best.Value or best.Level or 0, Remaining = math.max(0, math.floor(best.Remaining or 0)), Icon = best.Icon or "", OutlineColor = WheelConfig.RarityColors[best.Rarity] or Color3.fromRGB(255, 255, 255), Interval = best.Interval, MultiRolls = best.MultiRolls, Level = best.Level or 1, SkillId = best.SkillId, Stacks = best.Stacks or 1, CooldownRemaining = math.max(0, (best.CooldownEndsAt or 0) - now), CooldownDuration = best.TriggerInterval or 0 }
        end
    end
    return active
end

function StateService.GetLeaderboardSnapshot()
    local rows = {}
    for player, state in pairs(StateService.States) do
        table.insert(rows, { UserId = player.UserId, Name = player.Name, CakePoints = state.CakePoints or 0, WheelPoints = state.WheelPoints or 0, WheelSpins = state.WheelSpins or 0 })
    end
    table.sort(rows, function(a, b) return a.CakePoints > b.CakePoints end)
    return rows
end

function StateService.BuildInventory(player)
    local state = StateService.GetProfile(player)
    local inventory = { WheelRewards = {}, Cards = {} }
    if not state then return inventory end
    for key, reward in pairs(WheelConfig.Rewards) do
        if reward.IsUnlockedDefault or state.UnlockedWheelRewards[key] == true then
            local level = state.AbilityLevels[key] or 1
            table.insert(inventory.WheelRewards, { Key = key, Name = text(reward.NameKey), Owned = true, Icon = reward.Icon or "", AbilityLevel = level, RarityCap = WheelConfig.AbilityLevelCaps[level] or "Mythic", UpgradeCost = WheelConfig.AbilityUpgradeCosts[level] })
        end
    end
    local SkillConfig = require(Configs.SkillConfig)
    for key, card in pairs(SkillConfig.Cards) do
        if card.IsUnlockedDefault or state.UnlockedCards[key] == true then
            local level = state.AbilityLevels[key] or 1
            table.insert(inventory.Cards, { Key = key, Name = text(card.NameKey), Owned = true, Icon = card.Icon or "", AbilityLevel = level, RarityCap = WheelConfig.AbilityLevelCaps[level] or "Mythic", UpgradeCost = WheelConfig.AbilityUpgradeCosts[level] })
        end
    end
    return inventory
end

function StateService.Push(player)
    local state = StateService.Get(player)
    if not state then return end
    local wheelReward = state.LastWheelReward
    if wheelReward then
        local displayFor = math.max(0, wheelReward.ShownUntil - os.clock())
        wheelReward = displayFor > 0 and { Key = wheelReward.Key, Name = wheelReward.Name, Rarity = wheelReward.Rarity, Stacks = wheelReward.Stacks, EffectText = wheelReward.EffectText, DisplayFor = displayFor } or nil
    end
    UpdateClientState:FireClient(player, {
        WheelSpins = state.WheelSpins, WheelPoints = state.WheelPoints, WheelLevel = state.WheelLevel, CakePoints = state.CakePoints,
        PendingCardDraw = state.PendingCardDraw, LastWheelReward = wheelReward,
        ActiveBuffs = StateService.ActiveBuffs(player), UnlockedWheelRewards = state.UnlockedWheelRewards, UnlockedCards = state.UnlockedCards,
        Inventory = StateService.BuildInventory(player),
        ShopItems = StateService.BuildShop and StateService.BuildShop(state) or nil,
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
local function text(key) return LocalizationConfig["en-us"][key] or key end
local function rootOf(player) return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function weightedPick(entries, field)
    local total = 0
    for _, entry in pairs(entries) do total += entry[field] or 1 end
    local roll, sum = math.random() * total, 0
    for key, entry in pairs(entries) do sum += entry[field] or 1 if roll <= sum then return key, entry end end
end
local function templateSpawnWeight(template)
    local level = math.max(1, template:GetAttribute("InitialCakeLevel") or 1)
    return 1 / (CakeConfig.ValueScalePerLevel ^ (level - 1))
end
local function randomTemplate()
    local choices, total = CakeModels:GetChildren(), 0
    for _, template in ipairs(choices) do total += templateSpawnWeight(template) end
    if total <= 0 then return nil end
    local roll, cursor = math.random() * total, 0
    for _, template in ipairs(choices) do
        cursor += templateSpawnWeight(template)
        if roll <= cursor then return template end
    end
    return choices[#choices]
end
local function rarityKeyForLevel(level)
    return CakeConfig.RarityOrder[math.clamp(level, 1, #CakeConfig.RarityOrder)] or "Common"
end
local function scaledValue(baseValue, level, initialLevel)
    return math.max(1, math.floor((baseValue or 1) * (CakeConfig.ValueScalePerLevel ^ math.max(0, level - initialLevel)) + 0.5))
end
function CakeService.ApplyCakeLevel(cake, level)
    local initialLevel = cake:GetAttribute("InitialCakeLevel") or 1
    local rarityKey = rarityKeyForLevel(level)
    local rarity = CakeConfig.Rarities[rarityKey] or CakeConfig.Rarities.Common
    cake:SetAttribute("CakeLevel", level)
    cake:SetAttribute("RarityKey", rarityKey)
    cake:SetAttribute("MaxHealth", scaledValue(cake:GetAttribute("InitialHealth"), level, initialLevel))
    cake:SetAttribute("Health", cake:GetAttribute("MaxHealth"))
    cake:SetAttribute("RewardCakePoints", scaledValue(cake:GetAttribute("InitialReward"), level, initialLevel))
    cake:SetAttribute("RewardWheelTickets", scaledValue(cake:GetAttribute("InitialWheelTickets"), level, initialLevel))
    local outline = cake:FindFirstChild("RarityOutline")
    if outline then outline.OutlineColor = rarity.OutlineColor end
    local primary = cake.PrimaryPart
    local trail = primary and primary:FindFirstChild("RarityMeteorTrail")
    if trail then trail.Color = ColorSequence.new(rarity.OutlineColor) end
    local label = primary and primary:FindFirstChild("CakeLabel")
    local labelText = label and label:FindFirstChild("Text")
    if labelText then labelText.TextStrokeColor3 = rarity.OutlineColor end
    CakeService.RefreshLabel(cake)
end

function CakeService.UpdateScale(cake)
    local hp = math.max(0, cake:GetAttribute("Health") or 0)
    local scale = CakeConfig.MinimumCakeScale + (CakeConfig.MaximumCakeScale - CakeConfig.MinimumCakeScale) * math.clamp(hp / CakeConfig.HealthForMaximumScale, 0, 1)
    local currentScale = cake:GetScale()
    local previousTarget = cake:GetAttribute("TargetScale") or currentScale
    cake:SetAttribute("TargetScale", scale)
    if math.abs(scale - currentScale) < 0.01 then
        cake:ScaleTo(scale)
        return
    end
    local token = (cake:GetAttribute("ScaleTweenToken") or 0) + 1
    cake:SetAttribute("ScaleTweenToken", token)
    local primary = cake.PrimaryPart
    if primary and math.abs(scale - previousTarget) > 0.025 then
        local burst = Instance.new("ParticleEmitter")
        burst.Name = scale > previousTarget and "CakeGrowSparkles" or "CakeShrinkCrumbs"
        burst.Texture = "rbxassetid://241876023"
        burst.Color = ColorSequence.new(scale > previousTarget and Color3.fromRGB(255, 245, 140) or Color3.fromRGB(255, 210, 170))
        burst.Lifetime = NumberRange.new(0.22, 0.42)
        burst.Rate = 0
        burst.Speed = NumberRange.new(2, 5)
        burst.SpreadAngle = Vector2.new(180, 180)
        burst.Parent = primary
        burst:Emit(18)
        game:GetService("Debris"):AddItem(burst, 0.6)
    end
    task.spawn(function()
        local started, duration = os.clock(), 0.28
        while cake.Parent and cake:GetAttribute("ScaleTweenToken") == token do
            local alpha = math.clamp((os.clock() - started) / duration, 0, 1)
            local eased = 1 - ((1 - alpha) * (1 - alpha))
            cake:ScaleTo(currentScale + (scale - currentScale) * eased)
            if alpha >= 1 then break end
            RunService.Heartbeat:Wait()
        end
    end)
end
function CakeService.RefreshLabel(cake)
    local rarity = CakeConfig.Rarities[cake:GetAttribute("RarityKey")] or CakeConfig.Rarities.Common
    local hp, maxHp = math.max(0, cake:GetAttribute("Health") or 1), cake:GetAttribute("MaxHealth") or 1
    local label = cake.PrimaryPart and cake.PrimaryPart:FindFirstChild("CakeLabel")
    local labelText = label and label:FindFirstChild("Text")
    if labelText then labelText.Text = string.format("[%s] %s (HP: %d/%d)", cake:GetAttribute("IsGlow") and "SPECIAL" or rarity.RarityText, cake:GetAttribute("IsGlow") and text("Cake_Special") or text(rarity.NameKey), hp, maxHp) end
    CakeService.UpdateScale(cake)
end
function CakeService.Decorate(cake, isGlow)
    local primary = cake.PrimaryPart or cake:FindFirstChildWhichIsA("BasePart", true)
    if not primary then return end
    cake.PrimaryPart = primary
    local initialLevel = math.max(1, cake:GetAttribute("InitialCakeLevel") or 1)
    local rarityKey = rarityKeyForLevel(initialLevel)
    local rarity = CakeConfig.Rarities[rarityKey] or CakeConfig.Rarities.Common
    cake:SetAttribute("IsGlow", isGlow)
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Anchored, part.CanCollide = false, true; part.CustomPhysicalProperties = PhysicalProperties.new(1, .7, CakeConfig.CakeBounciness) end end
    local outline = Instance.new("Highlight"); outline.Name = "RarityOutline"; outline.FillTransparency = 1; outline.OutlineColor = rarity.OutlineColor; outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; outline.Parent = cake
    local top = Instance.new("Attachment"); top.Name = "MeteorTrailTop"; top.Position = Vector3.new(0, 2.8, 0); top.Parent = primary
    local bottom = Instance.new("Attachment"); bottom.Name = "MeteorTrailBottom"; bottom.Position = Vector3.new(0, -2.8, 0); bottom.Parent = primary
    local trail = Instance.new("Trail"); trail.Name = "RarityMeteorTrail"; trail.Attachment0, trail.Attachment1 = top, bottom; trail.Color = ColorSequence.new(rarity.OutlineColor); trail.LightEmission, trail.Lifetime = .65, CakeConfig.MeteorTrailLifetime; trail.Parent = primary
    if isGlow then local light = Instance.new("PointLight"); light.Color, light.Brightness, light.Range = Color3.fromRGB(120,255,255), 1.2, 12; light.Parent = primary end
    local label = Instance.new("BillboardGui"); label.Name, label.AlwaysOnTop, label.MaxDistance, label.Size, label.StudsOffset, label.Parent = "CakeLabel", true, CakeConfig.LabelMaxDistance, UDim2.new(0,300,0,62), Vector3.new(0,4.2,0), primary
    local labelText = Instance.new("TextLabel"); labelText.Name, labelText.BackgroundTransparency, labelText.Size, labelText.Font, labelText.TextScaled, labelText.TextColor3, labelText.TextStrokeColor3, labelText.TextStrokeTransparency, labelText.Parent = "Text", 1, UDim2.fromScale(1,1), Enum.Font.FredokaOne, true, Color3.new(1,1,1), rarity.OutlineColor, 0, label
    local labelStroke = Instance.new("UIStroke"); labelStroke.Name, labelStroke.Color, labelStroke.LineJoinMode, labelStroke.Thickness, labelStroke.Parent = "TextOutline", Color3.fromRGB(0, 0, 0), Enum.LineJoinMode.Round, 3, labelText
    CakeService.ApplyCakeLevel(cake, initialLevel)
end
local function stopEating(cake)
    local eater = CakeService.Eating[cake]
    if eater then CakeService.EatingByPlayer[eater] = nil end
    CakeService.Eating[cake] = nil
end
function CakeService.Finish(player, cake)
    if not cake.Parent or cake:GetAttribute("Finishing") then
        return
    end

    cake:SetAttribute("Finishing", true)
    CakeService.Owners[cake] = nil
    stopEating(cake)

    local state = StateService.Get(player)
    if state then
        state.CakePoints += cake:GetAttribute("RewardCakePoints") or 1
        state.WheelSpins += cake:GetAttribute("RewardWheelTickets") or 1
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
    if not cake.Parent or cake:GetAttribute("Finishing") then
        return
    end

    cake:SetAttribute("Finishing", true)
    CakeService.Owners[cake] = nil
    stopEating(cake)

    local startPivot, targetPivot, started = cake:GetPivot(), cake:GetPivot() - Vector3.new(0, 8, 0), os.clock()
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide, part.Anchored = false, true end end
    task.spawn(function()
        while cake.Parent do
            local alpha = math.clamp((os.clock() - started) / CakeConfig.SinkSeconds, 0, 1)
            local eased = alpha * alpha
            cake:PivotTo(startPivot:Lerp(targetPivot, eased))
            for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Transparency = alpha end end
            if alpha >= 1 then cake:Destroy(); break end
            RunService.Heartbeat:Wait()
        end
    end)
end
function CakeService.DamageCake(player, cake, amount)
    if CakeService.Owners[cake] ~= player or cake:GetAttribute("Finishing") then return false end
    amount = math.max(0, tonumber(amount) or 0)
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
    for _, part in ipairs(cake:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if Players:GetPlayerFromCharacter(hit.Parent) == player then
                    CakeService.BeginAutoEat(player, cake)
                end
            end)
        end
    end
end

function CakeService.Count(player)
    local count = 0
    for cake, owner in pairs(CakeService.Owners) do
        if owner == player and cake.Parent then
            count += 1
        end
    end
    return count
end

local function spawnPositionNear(root)
    local angle = math.random() * math.pi * 2
    local radius = math.random(CakeConfig.MinimumSpawnDistance, CakeConfig.SpawnRadius)
    return root.Position + Vector3.new(math.cos(angle) * radius, CakeConfig.SpawnHeight, math.sin(angle) * radius)
end

function CakeService.SpawnNear(player)
    local root = rootOf(player)
    if not root then
        return
    end

    local template = randomTemplate()
    if not template then
        warn("Cake Rain RNG: no cake template")
        return
    end

    local glowChance = CakeConfig.GlowBaseChance + StateService.EffectiveStat(player, "GlowCakeRate")
    local glow = math.random() < glowChance
    local cake = template:Clone()
    cake.Name = (glow and "Glow" or "Cake") .. "_" .. template.Name
    cake.Parent = Runtime
    cake:PivotTo(CFrame.new(spawnPositionNear(root)))

    CakeService.Decorate(cake, glow)
    cake.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, -CakeConfig.MeteorFallSpeed, 0)
    CakeService.Owners[cake] = player
    CakeService.HookTouches(player, cake)

    task.spawn(function()
        local decisions = math.floor(CakeConfig.UpgradeDecisionWindowSeconds / CakeConfig.UpgradeDecisionSeconds)
        for _ = 1, decisions do
            task.wait(CakeConfig.UpgradeDecisionSeconds)
            if not cake.Parent or cake:GetAttribute("Finishing") then
                return
            end
            local level = cake:GetAttribute("CakeLevel") or cake:GetAttribute("InitialCakeLevel") or 1
            local upgradeChance = cake:GetAttribute("InitialUpgradeChance") or 0
            if level >= #CakeConfig.RarityOrder or math.random() >= upgradeChance then
                return
            end
            CakeService.ApplyCakeLevel(cake, level + 1)
        end
    end)

    task.delay(CakeConfig.CakeLifetimeSeconds, function()
        if cake.Parent and CakeService.Owners[cake] == player then
            CakeService.Expire(cake)
        end
    end)
end

function CakeService.StartPlayer(player)
    local function burst()
        task.spawn(function()
            for _ = 1, CakeConfig.InitialBurstCount do
                if not player.Parent then
                    return
                end
                CakeService.SpawnNear(player)
                task.wait(.18)
            end
        end)
    end

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 10)
        task.wait(.35)
        burst()
    end)
    if player.Character then
        burst()
    end

    -- A failed individual drop must never terminate the endless rain coroutine.
    task.spawn(function()
        while player.Parent do
            local character = player.Character or player.CharacterAdded:Wait()
            character:WaitForChild("HumanoidRootPart", 10)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 + StateService.EffectiveStat(player, "PlayerSpeed") end
            local ok, err = pcall(CakeService.SpawnNear, player)
            if not ok then
                warn("Cake Rain RNG: spawn failed; rain will continue", err)
            end
            StateService.Push(player)
            task.wait(CakeConfig.SpawnInterval)
        end
    end)
end

function CakeService.CleanupPlayer(player)
    for cake, owner in pairs(CakeService.Owners) do
        if owner == player then
            CakeService.Owners[cake] = nil
            if cake.Parent then
                cake:Destroy()
            end
        end
    end
    CakeService.EatingByPlayer[player] = nil
end

return CakeService
]=]

-- Every wheel term chooses its own module, so its stacking and special behavior can evolve independently.
local rewardScripts = getOrCreate(servicesPackage, "Folder", "RewardScripts")
local rewardTemplate = getOrCreate(rewardScripts, "ModuleScript", "RewardTemplate")
rewardTemplate.Source = [=[
local StateService = require(script.Parent.Parent.StateService)
local WheelConfig = require(game:GetService("ReplicatedStorage").Configs.WheelConfig)
local RewardTemplate = {}
function RewardTemplate.RarityLevel(rarity)
    return WheelConfig.RarityPriority[rarity] or 1
end
function RewardTemplate.ApplyBuff(player, key, reward, buffType, rarityValues, overrides)
    local values = rarityValues and rarityValues[reward.Rarity] or {}
    local resolved = table.clone(reward)
    for valueKey, value in pairs(values) do resolved[valueKey] = value end
    for valueKey, value in pairs(overrides or {}) do resolved[valueKey] = value end
    resolved.Type = resolved.Type or buffType
    resolved.Level = resolved.Level or RewardTemplate.RarityLevel(resolved.Rarity)
    resolved.BaseDuration = resolved.BaseDuration or resolved.Duration or 60
    return StateService.AddBuff(player, key, resolved)
end
return RewardTemplate
]=]

local rewardDefinitions = {
    EatSpeed = { BuffType = "EatSpeed", Overrides = "{ Type = \"Stat\", Stat = \"EatSpeed\" }", ByRarity = "{ Common = { Value = 1, Duration = 60, MaxAbilityLevel = 3 }, Rare = { Value = 2, Duration = 60, MaxAbilityLevel = 3 }, Epic = { Value = 3, Duration = 60, MaxAbilityLevel = 3 }, Legendary = { Value = 5, Duration = 60, MaxAbilityLevel = 3 }, Mythic = { Value = 8, Duration = 60, MaxAbilityLevel = 3 } }" },
    GlowRate = { BuffType = "GlowCakeRate", ByRarity = "{ Common = { Value = 0.05, Duration = 20, MaxAbilityLevel = 3 }, Rare = { Value = 0.10, Duration = 20, MaxAbilityLevel = 3 }, Epic = { Value = 0.18, Duration = 22, MaxAbilityLevel = 3 }, Legendary = { Value = 0.30, Duration = 24, MaxAbilityLevel = 3 }, Mythic = { Value = 0.50, Duration = 26, MaxAbilityLevel = 3 } }" },
    AutoRoll = { BuffType = "AutoRoll", ByRarity = "{ Common = { Interval = 1.0, MultiRolls = 1, Duration = 60, MaxAbilityLevel = 3 }, Rare = { Interval = 0.9, MultiRolls = 2, Duration = 60, MaxAbilityLevel = 3 }, Epic = { Interval = 0.8, MultiRolls = 3, Duration = 60, MaxAbilityLevel = 3 }, Legendary = { Interval = 0.7, MultiRolls = 4, Duration = 60, MaxAbilityLevel = 3 }, Mythic = { Interval = 0.6, MultiRolls = 5, Duration = 60, MaxAbilityLevel = 3 } }" },
    WheelHaste = { BuffType = "WheelHaste", ByRarity = "{ Common = { Value = 0.10, Duration = 60, MaxAbilityLevel = 3 }, Rare = { Value = 0.22, Duration = 60, MaxAbilityLevel = 3 }, Epic = { Value = 0.36, Duration = 60, MaxAbilityLevel = 3 }, Legendary = { Value = 0.52, Duration = 60, MaxAbilityLevel = 3 }, Mythic = { Value = 0.75, Duration = 60, MaxAbilityLevel = 3 } }" },
    PlayerSpeed = { BuffType = "PlayerSpeed", Overrides = "{ Type = \"Stat\", Stat = \"PlayerSpeed\" }", ByRarity = "{ Common = { Value = 2, Duration = 60, MaxAbilityLevel = 3 }, Rare = { Value = 4, Duration = 60, MaxAbilityLevel = 3 }, Epic = { Value = 6, Duration = 60, MaxAbilityLevel = 3 }, Legendary = { Value = 8, Duration = 60, MaxAbilityLevel = 3 }, Mythic = { Value = 12, Duration = 60, MaxAbilityLevel = 3 } }" },
}
for scriptName, definition in pairs(rewardDefinitions) do
    local rewardScript = getOrCreate(rewardScripts, "ModuleScript", scriptName)
    rewardScript.Source = string.format([=[
local Template = require(script.Parent.RewardTemplate)
local ByRarity = %s
return function(player, key, reward)
    return Template.ApplyBuff(player, key, reward, %q, ByRarity, %s)
end
]=], definition.ByRarity, definition.BuffType, definition.Overrides or "nil")
end

local wheelLevelUpScript = getOrCreate(rewardScripts, "ModuleScript", "WheelLevelUp")
wheelLevelUpScript.Source = [=[
local StateService = require(script.Parent.Parent.StateService)
local WheelConfig = require(game:GetService("ReplicatedStorage").Configs.WheelConfig)
local Template = require(script.Parent.RewardTemplate)
return function(player, key, reward)
    local levelGain = WheelConfig.WheelLevelBonusByRarity[reward.Rarity] or Template.RarityLevel(reward.Rarity)
    local duration = WheelConfig.WheelLevelDurationByRarity[reward.Rarity] or 60
    local stack = StateService.AddBuff(player, key, { NameKey = reward.NameKey, Rarity = reward.Rarity, Type = "WheelLevel", Value = levelGain, Level = levelGain, Icon = reward.Icon, BaseDuration = duration })
    if stack then stack.EffectText = "+" .. tostring(levelGain) .. " wheel level for " .. tostring(duration) .. "s" end
    return stack
end
]=]

local rewardService = getOrCreate(servicesPackage, "ModuleScript", "RewardService")
rewardService.Source = [=[
local RewardScripts = script.Parent.RewardScripts
local RewardService = {}
function RewardService.Activate(player, key, reward)
    local module = RewardScripts:FindFirstChild(reward.ScriptName)
    if not module then warn("Cake Rain RNG: missing reward script", reward.ScriptName); return end
    return require(module)(player, key, reward)
end
return RewardService
]=]

local skillScripts = getOrCreate(servicesPackage, "Folder", "SkillScripts")
local skillTemplate = getOrCreate(skillScripts, "ModuleScript", "SkillTemplate")
skillTemplate.Source = [=[
-- Template for an independent skill script. Use Context:GetCakes / DamagePercent / MoveNear;
-- CakeService remains the single authority for ownership, HP, rewards, and removal.
local CakeService = require(script.Parent.Parent.CakeService)
local StateService = require(script.Parent.Parent.StateService)
local Template = {}
function Template.Resolve(card, byRarity)
    local resolved = table.clone(card)
    for key, value in pairs((byRarity and byRarity[card.Rarity]) or {}) do resolved[key] = value end
    resolved.Level = resolved.Level or 1
    resolved.Duration = resolved.Duration or 60
    resolved.Parameters = resolved.Parameters or {}
    return resolved
end
function Template.New(player, parameters)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return {
        Player = player, Parameters = parameters, Root = root,
        GetCakes = function(_, count, minimumDistance) return CakeService.GetCakes(player, count, minimumDistance) end,
        Damage = function(_, cake, amount) return CakeService.DamageCake(player, cake, amount) end,
        DamagePercent = function(_, cake, percent) local hp = cake:GetAttribute("Health") or 0; return CakeService.DamageCake(player, cake, math.max(.01, hp * percent)) end,
        MoveNear = function(_, cake, distance, seconds) return CakeService.MoveNearPlayer(player, cake, distance, seconds) end,
        GetAbilityLevel = function(_, abilityKey)
            local state, best, now = StateService.Get(player), 0, os.clock()
            if not state then return best end
            local stack = StateService.TickBuffType(state, "Skill_" .. abilityKey)
            if stack then best = math.max(best, stack.Level or 1) end
            return best
        end,
    }
end
return Template
]=]

local hookSkill = getOrCreate(skillScripts, "ModuleScript", "HookSkill")
hookSkill.Source = [=[
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Template = require(script.Parent.SkillTemplate)
local ByRarity = { Common = { Duration = 45, TriggerInterval = 4, Level = 1, Parameters = { Count = 1, Distance = 2 } }, Rare = { Duration = 50, TriggerInterval = 3.5, Level = 2, Parameters = { Count = 1, Distance = 2 } }, Epic = { Duration = 55, TriggerInterval = 3, Level = 3, Parameters = { Count = 2, Distance = 2 } }, Legendary = { Duration = 60, TriggerInterval = 2.5, Level = 4, Parameters = { Count = 2, Distance = 2 } }, Mythic = { Duration = 60, TriggerInterval = 2, Level = 5, Parameters = { Count = 3, Distance = 2 } } }
local HookSkill = {}
function HookSkill.Resolve(card) return Template.Resolve(card, ByRarity) end
function HookSkill.Run(player, parameters)
    local context = Template.New(player, parameters)
    local level = context:GetAbilityLevel("Card_Hook")
    for _, item in ipairs(context:GetCakes((parameters.Count or 1) + math.max(0, level - 1))) do
        if context.Root and item.Cake.PrimaryPart then
            local source, target = Instance.new("Attachment"), Instance.new("Attachment")
            source.Parent, target.Parent = context.Root, item.Cake.PrimaryPart
            local beam = Instance.new("Beam"); beam.Name = "GrapplingHookChain"; beam.Attachment0, beam.Attachment1 = source, target
            beam.Color, beam.Width0, beam.Width1, beam.FaceCamera = ColorSequence.new(Color3.fromRGB(210,210,225)), .16, .16, true; beam.Parent = Workspace.Map
            Debris:AddItem(beam,.8); Debris:AddItem(source,.8); Debris:AddItem(target,.8)
            context:MoveNear(item.Cake, parameters.Distance or 2, .75)
        end
    end
end
return HookSkill
]=]

local tornadoSkill = getOrCreate(skillScripts, "ModuleScript", "TornadoSkill")
tornadoSkill.Source = [=[
local Debris = game:GetService("Debris")
local Template = require(script.Parent.SkillTemplate)
local ByRarity = { Common = { Duration = 35, TriggerInterval = 7, Level = 1, Parameters = { Count = 5, Distance = 5, DamagePercent = .4 } }, Rare = { Duration = 40, TriggerInterval = 6.5, Level = 2, Parameters = { Count = 6, Distance = 5, DamagePercent = .42 } }, Epic = { Duration = 45, TriggerInterval = 6, Level = 3, Parameters = { Count = 7, Distance = 5, DamagePercent = .45 } }, Legendary = { Duration = 50, TriggerInterval = 5.5, Level = 4, Parameters = { Count = 8, Distance = 5, DamagePercent = .48 } }, Mythic = { Duration = 60, TriggerInterval = 5, Level = 5, Parameters = { Count = 10, Distance = 5, DamagePercent = .52 } } }
local TornadoSkill = {}
function TornadoSkill.Resolve(card) return Template.Resolve(card, ByRarity) end
function TornadoSkill.Run(player, parameters)
    local context = Template.New(player, parameters)
    if context.Root then
        local wind = Instance.new("Part"); wind.Name="Tornado"; wind.Shape=Enum.PartType.Cylinder; wind.Size=Vector3.new(8,1,8); wind.Material=Enum.Material.Neon; wind.Color=Color3.fromRGB(180,235,255); wind.Transparency=.35; wind.Anchored=true; wind.CanCollide=false; wind.CFrame=CFrame.new(context.Root.Position + Vector3.new(0,4,0)); wind.Parent=workspace.Map; Debris:AddItem(wind,1.2)
    end
    local level = context:GetAbilityLevel("Card_Tornado")
    for _, item in ipairs(context:GetCakes((parameters.Count or 5) + level - 1)) do context:MoveNear(item.Cake, parameters.Distance or 5, .8); context:DamagePercent(item.Cake, parameters.DamagePercent or .4) end
end
return TornadoSkill
]=]

local antSkill = getOrCreate(skillScripts, "ModuleScript", "AntSkill")
antSkill.Source = [=[
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Template = require(script.Parent.SkillTemplate)
local ByRarity = { Common = { Duration = 50, TriggerInterval = 4, Level = 1, Parameters = { MinimumDistance = 14, Distance = 4, DamagePercentPerSecond = .02 } }, Rare = { Duration = 55, TriggerInterval = 3.75, Level = 2, Parameters = { MinimumDistance = 13, Distance = 4, DamagePercentPerSecond = .022 } }, Epic = { Duration = 60, TriggerInterval = 3.5, Level = 3, Parameters = { MinimumDistance = 12, Distance = 4, DamagePercentPerSecond = .025 } }, Legendary = { Duration = 60, TriggerInterval = 3.25, Level = 4, Parameters = { MinimumDistance = 11, Distance = 4, DamagePercentPerSecond = .028 } }, Mythic = { Duration = 60, TriggerInterval = 3, Level = 5, Parameters = { MinimumDistance = 10, Distance = 4, DamagePercentPerSecond = .032 } } }
local AntSkill = {}
function AntSkill.Resolve(card) return Template.Resolve(card, ByRarity) end
function AntSkill.Run(player, parameters)
    local context = Template.New(player, parameters)
    local item = context:GetCakes(1, parameters.MinimumDistance or 14)[1]
    if not item or not item.Cake.PrimaryPart then return end
    local level = context:GetAbilityLevel("Card_Ant")
    context:DamagePercent(item.Cake, (parameters.DamagePercentPerSecond or .02) * math.max(1, level))
    local destination = context:MoveNear(item.Cake, parameters.Distance or 4, 1)
    if not destination then return end
    local ant = Instance.new("Part"); ant.Name="AntCourier"; ant.Shape=Enum.PartType.Ball; ant.Size=Vector3.new(.7,.45,.45); ant.Color=Color3.fromRGB(35,20,12); ant.Anchored=true; ant.CanCollide=false; ant.CFrame=item.Cake.PrimaryPart.CFrame; ant.Parent=workspace.Map
    TweenService:Create(ant,TweenInfo.new(1,Enum.EasingStyle.Linear),{CFrame=destination}):Play(); Debris:AddItem(ant,1.1)
end
return AntSkill
]=]

local attractSkill = getOrCreate(skillScripts, "ModuleScript", "AttractSkill")
attractSkill.Source = [=[
-- Default card: all owned cakes drift closer once per second and lose 1% current HP.
local Template = require(script.Parent.SkillTemplate)
local ByRarity = { Common = { Duration = 60, TriggerInterval = 1, Level = 1, Parameters = { Distance = 3, DamagePercentPerSecond = .01 } }, Rare = { Duration = 60, TriggerInterval = .95, Level = 2, Parameters = { Distance = 3, DamagePercentPerSecond = .011 } }, Epic = { Duration = 60, TriggerInterval = .9, Level = 3, Parameters = { Distance = 3, DamagePercentPerSecond = .012 } }, Legendary = { Duration = 60, TriggerInterval = .85, Level = 4, Parameters = { Distance = 3, DamagePercentPerSecond = .013 } }, Mythic = { Duration = 60, TriggerInterval = .8, Level = 5, Parameters = { Distance = 3, DamagePercentPerSecond = .015 } } }
local AttractSkill = {}
function AttractSkill.Resolve(card) return Template.Resolve(card, ByRarity) end
function AttractSkill.Run(player, parameters)
    local context = Template.New(player, parameters)
    for _, item in ipairs(context:GetCakes(999)) do
        context:MoveNear(item.Cake, parameters.Distance or 3, .9)
        local level = context:GetAbilityLevel("Card_Attract")
        context:DamagePercent(item.Cake, (parameters.DamagePercentPerSecond or .01) * math.max(1, level))
    end
end
return AttractSkill
]=]

local skillService = getOrCreate(servicesPackage, "ModuleScript", "SkillService")
skillService.Source = [=[
-- Generic dispatcher: a card selects one independent ModuleScript; skill visuals and movement stay there.
local StateService = require(script.Parent.StateService)
local SkillScripts = script.Parent.SkillScripts
local SkillService = {}

local function runStack(player, module, stack)
    task.spawn(function()
        while player.Parent and (stack.Remaining or 0) > 0 do
            local cooldown = math.max(.1, stack.TriggerInterval)
            stack.CooldownEndsAt = os.clock() + cooldown
            StateService.Push(player)
            local state = StateService.Get(player)
            local active = (state and stack.AbilityKey) and StateService.TickBuffType(state, "Skill_" .. stack.AbilityKey) or stack
            if active == stack then module.Run(player, stack.Parameters) end
            task.wait(cooldown)
            StateService.Push(player)
        end
        StateService.Push(player)
    end)
end

function SkillService.Activate(player, cardKey, card)
    local skill = SkillScripts:FindFirstChild(card.ScriptName)
    if not skill then warn("Cake Rain RNG: missing skill script", card.ScriptName); return end
    local module = require(skill)
    local resolvedCard = module.Resolve and module.Resolve(card) or card
    local stack, isNew = StateService.AddCardBuff(player, cardKey, resolvedCard)
    if not stack then return end
    if isNew then runStack(player, module, stack) end
    return stack
end

function SkillService.ResumePlayer(player)
    local state = StateService.Get(player)
    if not state then return end
    for buffType, stacks in pairs(state.Buffs or {}) do
        if string.sub(buffType, 1, 6) == "Skill_" then
            for _, stack in ipairs(stacks) do
                if (stack.Remaining or 0) > 0 then
                    local skill = SkillScripts:FindFirstChild(stack.ScriptName or stack.SkillId or "") or SkillScripts:FindFirstChild(({ PullNearest = "HookSkill", Attract = "AttractSkill", Tornado = "TornadoSkill", AntCourier = "AntSkill" })[stack.SkillId] or "")
                    if skill then runStack(player, require(skill), stack) end
                end
            end
        end
    end
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
local RewardService = require(script.Parent.RewardService)

local WheelService = {}

local function text(nameKey) return LocalizationConfig["en-us"][nameKey] or nameKey end
local function weightedPick(entries)
    local total = 0
    for _, entry in pairs(entries) do total += entry.Weight or 1 end
    local roll, cursor = math.random() * total, 0
    for key, entry in pairs(entries) do cursor += entry.Weight or 1 if roll <= cursor then return key, entry end end
end
local WheelLevelRarityCap = { [1] = "Rare", [2] = "Epic", [3] = "Legendary", [4] = "Mythic" }
local merchantCycleStarted, merchantItems = 0, {}
local function maxRarityPriority(player, state)
    local timedLevel = StateService.EffectiveStat(player, "WheelLevel")
    local cap = WheelLevelRarityCap[math.clamp(1 + timedLevel, 1, 4)] or "Mythic"
    return WheelConfig.RarityPriority[cap] or 2
end
local function unlockedRewards(state)
    local entries = {}
    for key, reward in pairs(WheelConfig.Rewards) do
        if reward.IsUnlockedDefault or state.UnlockedWheelRewards[key] then entries[key] = reward end
    end
    return entries
end
local function randomRarity(player, state, capOverride)
    local cap, total = math.min(maxRarityPriority(player, state), capOverride or 999), 0
    local weights = WheelConfig.BaseRarityWeights
    for rarity, weight in pairs(weights) do if (WheelConfig.RarityPriority[rarity] or 1) <= cap then total += weight end end
    local roll, cursor = math.random() * total, 0
    for _, rarity in ipairs(WheelConfig.RarityOrder) do
        local weight = weights[rarity] or 0
        if (WheelConfig.RarityPriority[rarity] or 1) <= cap then
            cursor += weight
            if roll <= cursor then return rarity end
        end
    end
    return "Common"
end
local function buildSlots(player, state)
    local pool, slots, used, count = unlockedRewards(state), {}, {}, 0
    for _ in pairs(pool) do count += 1 end
    local attempts = 0
    while #slots < WheelConfig.DisplayedSlots and attempts < 100 do
        attempts += 1
        local key, reward = weightedPick(pool)
        if not key then break end
        if count < WheelConfig.DisplayedSlots or not used[key] then
            used[key] = true
            local _, abilityCap = StateService.RarityCapForAbility(player, key)
            local rarity = randomRarity(player, state, WheelConfig.RarityPriority[abilityCap])
            table.insert(slots, { Key = key, Name = text(reward.NameKey), Rarity = rarity, Color = WheelConfig.RarityColors[rarity], Icon = reward.Icon or "" })
        end
    end
    return slots
end
local function unlockedCards(state)
    local entries = {}
    for key, card in pairs(CardConfig.Cards) do if card.IsUnlockedDefault or state.UnlockedCards[key] then entries[key] = card end end
    return entries
end
local function buildCardSlots(player, state)
    local pool, slots, used, count = unlockedCards(state), {}, {}, 0
    for _ in pairs(pool) do count += 1 end
    local attempts = 0
    while #slots < WheelConfig.DisplayedSlots and attempts < 100 do
        attempts += 1
        local key, card = weightedPick(pool)
        if key and (count < WheelConfig.DisplayedSlots or not used[key]) then
            used[key] = true
            local cap = StateService.RarityCapForAbility(player, card.AbilityKey or key)
            local rarity = randomRarity(player, state, cap)
            table.insert(slots, { Key = key, Name = text(card.NameKey), Rarity = rarity, Color = Color3.fromRGB(190, 195, 205), Icon = card.Icon or "" })
        end
    end
    return slots
end
local function refreshMerchant()
    local refreshSeconds = WheelConfig.ServerMerchant.RefreshSeconds or 240
    if os.clock() - merchantCycleStarted < refreshSeconds and #merchantItems > 0 then return end
    merchantCycleStarted, merchantItems = os.clock(), {}
    local pool, used = ShopConfig.MysteryMerchantPool or {}, {}
    while #merchantItems < (WheelConfig.ServerMerchant.SlotCount or 3) and #merchantItems < #pool do
        local key, item = weightedPick(pool)
        if item and not used[item.Id] then
            used[item.Id] = true
            table.insert(merchantItems, table.clone(item))
        end
    end
end
local function visibleShopItems(state)
    refreshMerchant()
    local items = { Normal = {}, Merchant = {}, MerchantRefreshRemaining = math.max(0, math.floor((WheelConfig.ServerMerchant.RefreshSeconds or 240) - (os.clock() - merchantCycleStarted))) }
    for _, section in ipairs({ ShopConfig.WheelPointShop, ShopConfig.CakePointShop }) do
        for _, item in ipairs(section) do
            local grants = item.Grants or item.Id
            local alreadyUnlocked = (item.UnlockType == "WheelReward" and state.UnlockedWheelRewards[grants]) or (item.UnlockType == "Card" and state.UnlockedCards[grants])
            if not state.OwnedItems[item.Id] and not state.OwnedItems[grants] and not alreadyUnlocked then table.insert(items.Normal, item) end
        end
    end
    local cycleKey = "MerchantCycle_" .. tostring(math.floor(merchantCycleStarted))
    state.MerchantPurchases = state.MerchantPurchases or {}
    state.MerchantPurchases[cycleKey] = state.MerchantPurchases[cycleKey] or {}
    for _, item in ipairs(merchantItems) do if not state.MerchantPurchases[cycleKey][item.Id] then table.insert(items.Merchant, item) end end
    return items
end
StateService.BuildShop = visibleShopItems

local function shopItem(state, itemId)
    refreshMerchant()
    for _, section in ipairs({ ShopConfig.WheelPointShop, ShopConfig.CakePointShop, merchantItems }) do
        for _, item in ipairs(section) do
            local grants = item.Grants or item.Id
            local alreadyUnlocked = not string.find(item.Id, "^Merchant_") and ((item.UnlockType == "WheelReward" and state.UnlockedWheelRewards[grants]) or (item.UnlockType == "Card" and state.UnlockedCards[grants]))
            if item.Id == itemId and not state.OwnedItems[item.Id] and not state.OwnedItems[grants] and not alreadyUnlocked then return item end
        end
    end
end

function WheelService.Start()
    Events.RequestWheelSpin.OnServerInvoke = function(player, action, requestedCount)
        local state = StateService.Get(player)
        if not state then return { Ok = false, Error = "NO_STATE" } end
        if action == "Claim" then
            local pending = state.PendingWheelSpin
            if not pending or #pending == 0 then return { Ok = false, Error = "NO_PENDING_SPIN" } end
            state.PendingWheelSpin = nil
            local claimed = {}
            for _, spin in ipairs(pending) do
                local picked = spin.Picked
                local reward = table.clone(WheelConfig.Rewards[picked.Key])
                reward.Rarity = picked.Rarity
                local stack = RewardService.Activate(player, picked.Key, reward)
                table.insert(claimed, { Picked = picked, Stacks = stack and stack.Stacks or 1 })
                state.LastWheelReward = { Key = picked.Key, Name = picked.Name, Rarity = picked.Rarity, Stacks = stack and stack.Stacks or 1, EffectText = stack and stack.EffectText, ShownUntil = os.clock() + 3 }
            end
            StateService.UpdateLeaderstats(player)
            StateService.Push(player)
            return { Ok = true, Claimed = claimed }
        end
        -- Draws always consume earned wheel spins. Manual draw is exactly one spin; only an
        -- active Auto-Roll reward may request its configured multi-roll count.
        local count = 1
        if action == "Auto" then
            local autoRoll = StateService.TickBuffType(state, "AutoRoll")
            if not autoRoll or (autoRoll.Remaining or 0) <= 0 then return { Ok = false, Error = "NO_AUTO_ROLL" } end
            count = math.clamp(math.floor(tonumber(autoRoll.MultiRolls) or 1), 1, 6)
        elseif action ~= "Begin" then
            return { Ok = false, Error = "INVALID_DRAW_ACTION" }
        end
        count = math.min(count, state.WheelSpins)
        if count <= 0 or state.PendingWheelSpin then return { Ok = false, Error = "NO_SPINS" } end
        local pending = {}
        for _ = 1, count do
            state.WheelSpins -= 1
            state.WheelPoints += 1
            local slots = buildSlots(player, state)
            if #slots == 0 then break end
            local pickedIndex = math.random(1, #slots)
            local picked = slots[pickedIndex]
            table.insert(pending, { Slots = slots, Picked = picked, PickedIndex = pickedIndex })
        end
        if #pending == 0 then return { Ok = false, Error = "EMPTY_POOL" } end
        state.PendingWheelSpin = pending
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true, Spins = pending }
    end

    Events.RequestCardDraw.OnServerInvoke = function(player)
        local state = StateService.Get(player)
        if not state or not state.PendingCardDraw then return { Ok = false, Error = "NO_CARD_DRAW" } end
        state.PendingCardDraw = false
        local slots = buildCardSlots(player, state)
        local pickedIndex = #slots > 0 and math.random(1, #slots) or 0
        local picked = slots[pickedIndex]
        local key, card = picked and picked.Key, picked and CardConfig.Cards[picked.Key]
        if card then card = table.clone(card); card.Rarity = picked.Rarity end
        local stack = card and SkillService.Activate(player, key, card)
        StateService.Push(player)
        return { Ok = true, Slots = slots, PickedIndex = pickedIndex, Card = card and { Key = key, Name = text(card.NameKey), Rarity = card.Rarity, Duration = card.Duration, Effect = card.SkillId, Level = card.Level or 1, Stacks = stack and stack.Stacks or 1 } or nil }
    end

    Events.RequestShopPurchase.OnServerInvoke = function(player, itemId)
        local state = StateService.Get(player)
        local item = state and shopItem(state, itemId)
        if not state or not item then return { Ok = false, Error = "INVALID_ITEM" } end
        if item.Currency == "WheelPoints" and state.WheelPoints < item.Cost then return { Ok = false, Error = "NO_WHEEL_POINTS" } end
        if item.Currency == "CakePoints" and state.CakePoints < item.Cost then return { Ok = false, Error = "NO_CAKE_POINTS" } end
        state[item.Currency] = state[item.Currency] - item.Cost
        local grants = item.Grants or item.Id
        if not string.find(item.Id, "^Merchant_") then state.OwnedItems[item.Id] = true end
        if item.UnlockType == "WheelReward" then state.UnlockedWheelRewards[grants] = true end
        if item.UnlockType == "Card" then state.UnlockedCards[grants] = true end
        if string.find(item.Id, "^Merchant_") then
            local cycleKey = "MerchantCycle_" .. tostring(math.floor(merchantCycleStarted))
            state.MerchantPurchases = state.MerchantPurchases or {}
            state.MerchantPurchases[cycleKey] = state.MerchantPurchases[cycleKey] or {}
            state.MerchantPurchases[cycleKey][item.Id] = true
        end
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true }
    end
    Events.RequestAbilityUpgrade.OnServerInvoke = function(player, abilityKey)
        local state = StateService.Get(player)
        if not state then return { Ok = false, Error = "NO_STATE" } end
        local nextLevel = math.max(1, state.AbilityLevels[abilityKey] or 1)
        local cost = WheelConfig.AbilityUpgradeCosts[nextLevel]
        if not cost then return { Ok = false, Error = "MAX_LEVEL" } end
        if state.CakePoints < cost then return { Ok = false, Error = "NO_CAKE_POINTS" } end
        state.CakePoints -= cost
        state.AbilityLevels[abilityKey] = nextLevel + 1
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true, Level = state.AbilityLevels[abilityKey] }
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
local SkillService = require(script.Parent.Services.SkillService)

WheelService.Start()

local function setupPlayer(player)
    StateService.Create(player, DataService.Load(player))
    SkillService.ResumePlayer(player)
    CakeService.StartPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

task.spawn(function()
    while true do
        task.wait(60)
        for _, player in ipairs(Players:GetPlayers()) do
            DataService.Save(player, StateService.Serialize(player))
        end
    end
end)

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
local RequestShopPurchase = Events:WaitForChild("RequestShopPurchase")
local RequestAbilityUpgrade = Events:WaitForChild("RequestAbilityUpgrade")
local UpdateClientState = Events:WaitForChild("UpdateClientState")
local L = require(Configs:WaitForChild("LocalizationConfig"))["en-us"]
local Tree = require(Configs:WaitForChild("UpgradeTreeConfig"))

local gui = player:WaitForChild("PlayerGui"):WaitForChild("CakeRainRNGHUD")
local stats = gui:WaitForChild("StatsFrame")
local tree = gui:WaitForChild("UpgradeTree")
local slotMachine = gui:WaitForChild("SlotMachine")
local reel = slotMachine:WaitForChild("Reel")
local drawButton = slotMachine:WaitForChild("DrawButton")
local autoDrawButton = slotMachine:WaitForChild("AutoDrawButton")
local state = { CakePoints = 0, WheelPoints = 0, WheelSpins = 0, ActiveBuffs = {}, UnlockedWheelRewards = {}, UnlockedCards = {}, Inventory = { WheelRewards = {}, Cards = {} } }
local drawing, autoDrawEnabled, autoDrawThread = false, false, nil

local function roman(number)
    local symbols = { {1000,"M"}, {900,"CM"}, {500,"D"}, {400,"CD"}, {100,"C"}, {90,"XC"}, {50,"L"}, {40,"XL"}, {10,"X"}, {9,"IX"}, {5,"V"}, {4,"IV"}, {1,"I"} }
    local value, result = math.max(1, number or 1), ""
    for _, symbol in ipairs(symbols) do while value >= symbol[1] do result, value = result .. symbol[2], value - symbol[1] end end
    return result
end

local function ownedLevel(key)
    for _, group in pairs(state.Inventory or {}) do
        for _, item in ipairs(group) do if item.Key == key and item.Owned then return item.AbilityLevel or 1 end end
    end
end
local axialNeighbors = { {1,0}, {1,-1}, {0,-1}, {-1,0}, {-1,1}, {0,1} }
local function isOwned(node)
    return node.Default or state.UnlockedWheelRewards[node.Key] or state.UnlockedCards[node.Key] or ownedLevel(node.Key) ~= nil
end
local function isVisible(node)
    if isOwned(node) then return true end
    for _, other in ipairs(Tree.Nodes) do
        if isOwned(other) then
            for _, direction in ipairs(axialNeighbors) do
                if node.Q == other.Q + direction[1] and node.R == other.R + direction[2] then return true end
            end
        end
    end
    return false
end
local function refreshTree()
    for _, node in ipairs(Tree.Nodes) do
        local hex = tree.HexLayer:FindFirstChild("Hex_" .. node.Key)
        local unlocked, visible = isOwned(node), isVisible(node)
        hex.Visible = visible
        if visible then
            local level = ownedLevel(node.Key) or 1
            hex.CenterText.Text = unlocked and ((L[node.NameKey] or node.NameKey) .. "\n" .. roman(level)) or "?"
            hex.CenterText.TextSize = unlocked and 18 or 36
            hex.Cost.Text = unlocked and (node.Upgrade and tostring((({800, 2200})[level]) or 0) or "") or tostring(node.Cost or 0)
            hex.StateGradient.Color = unlocked and ColorSequence.new(Color3.fromRGB(108, 235, 150), Color3.fromRGB(35, 105, 75)) or ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(24, 24, 24))
        end
    end
end
local function hasAutoRoll()
    local buff = state.ActiveBuffs and state.ActiveBuffs.AutoRoll
    return buff and (buff.Remaining or 0) > 0
end
local function refresh()
    stats.CakePointsLabel.Text = "CAKE POINTS: " .. state.CakePoints
    stats.WheelPointsLabel.Text = "WHEEL POINTS: " .. state.WheelPoints
    stats.SpinsLabel.Text = "SPINS: " .. state.WheelSpins
    if not hasAutoRoll() then autoDrawEnabled = false end
    autoDrawButton.Visible = hasAutoRoll()
    autoDrawButton.Text = autoDrawEnabled and "AUTO DRAW: ON" or "AUTO DRAW: OFF"
    autoDrawButton.BackgroundColor3 = autoDrawEnabled and Color3.fromRGB(85, 175, 105) or Color3.fromRGB(70, 105, 85)
    slotMachine.Visible = state.WheelSpins > 0 or drawing or hasAutoRoll()
    refreshTree()
end
for _, node in ipairs(Tree.Nodes) do
    local hex = tree.HexLayer:WaitForChild("Hex_" .. node.Key)
    hex.Activated:Connect(function()
        if not isVisible(node) then return end
        if isOwned(node) then
            if node.Upgrade then RequestAbilityUpgrade:InvokeServer(node.Key) end
        elseif node.PurchaseId then
            RequestShopPurchase:InvokeServer(node.PurchaseId)
        end
    end)
end
tree.CloseButton.Activated:Connect(function() tree.Visible = false end)
gui.UpgradeButton.Activated:Connect(function() tree.Visible = not tree.Visible end)

local function playReel(spin)
    local slots, winner = spin.Slots or {}, spin.PickedIndex or 1
    if #slots == 0 then return end
    reel.TextTransparency = 0
    -- A decelerating complete reel cycle gives every server-provided candidate time on screen.
    for tick = 1, 18 do
        local index = ((tick - 1) % #slots) + 1
        reel.Text = slots[index].Name or "?"
        task.wait(0.035 + tick * 0.009)
    end
    local picked = slots[winner] or spin.Picked
    reel.Text = picked and picked.Name or "?"
    local originalSize = reel.Size
    local pulse = TweenService:Create(reel, TweenInfo.new(.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1, true), { Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 8) })
    pulse:Play()
    pulse.Completed:Wait()
end
local function performDraw(action)
    if drawing or state.WheelSpins <= 0 then return false end
    drawing = true
    refresh()
    local response = RequestWheelSpin:InvokeServer(action)
    if response and response.Ok then
        for _, spin in ipairs(response.Spins or {}) do playReel(spin) end
        RequestWheelSpin:InvokeServer("Claim")
    end
    drawing = false
    refresh()
    return response and response.Ok
end
local function ensureAutoDrawLoop()
    if autoDrawThread then return end
    autoDrawThread = task.spawn(function()
        while autoDrawEnabled and hasAutoRoll() do
            if state.WheelSpins > 0 then performDraw("Auto") end
            local buff = state.ActiveBuffs.AutoRoll or {}
            task.wait(math.max(.5, buff.Interval or 1))
        end
        autoDrawEnabled, autoDrawThread = false, nil
        refresh()
    end)
end
drawButton.Activated:Connect(function() performDraw("Begin") end)
autoDrawButton.Activated:Connect(function()
    if not hasAutoRoll() then return end
    autoDrawEnabled = not autoDrawEnabled
    refresh()
    if autoDrawEnabled then ensureAutoDrawLoop() end
end)
UpdateClientState.OnClientEvent:Connect(function(update)
    for key, value in pairs(update) do state[key] = value end
    refresh()
end)
refresh()
]=]

if recording then
    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

Selection:Set({serverScript, clientScript, mainGui, upgradeTree, slotMachine, upgradeTreeConfig, wheelConfig, cakeConfig, skillConfig, cardConfig, shopConfig, rewardScripts, rewardService, skillScripts, uiConfig, localizationConfig, cakeModelsFolder, mapBase})
print("Cake Rain RNG rebuild complete: static upgrade tree and slot-reel UI are configured.")
