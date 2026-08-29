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
local legacyCakeModelsFolder = getOrCreate(modelsFolder, "Folder", "cake")
local cakeModelsFolder = getOrCreate(ReplicatedStorage, "Folder", "cake")
local mapFolder = getOrCreate(Workspace, "Folder", "Map")

local requestWheelSpin = getOrCreate(eventsFolder, "RemoteFunction", "RequestWheelSpin")
local requestCardDraw = getOrCreate(eventsFolder, "RemoteFunction", "RequestCardDraw")
local requestShopPurchase = getOrCreate(eventsFolder, "RemoteFunction", "RequestShopPurchase")
local requestAbilityUpgrade = getOrCreate(eventsFolder, "RemoteFunction", "RequestAbilityUpgrade")
local requestEquipSkill = getOrCreate(eventsFolder, "RemoteFunction", "RequestEquipSkill")
local requestClaimDailyTask = getOrCreate(eventsFolder, "RemoteFunction", "RequestClaimDailyTask")
local requestRedeemCode = getOrCreate(eventsFolder, "RemoteFunction", "RequestRedeemCode")
local updateClientState = getOrCreate(eventsFolder, "RemoteEvent", "UpdateClientState")

local wheelConfig = getOrCreate(configsFolder, "ModuleScript", "WheelConfig")
wheelConfig.Source = [=[
local WheelConfig = {
    DisplayedSlots = 5,
    RarityPriority = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
    BaseRarityWeights = { Common = 650, Rare = 250, Epic = 80, Legendary = 18, Mythic = 2 },
    WheelLevelBonusByRarity = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    WheelLevelDurationByRarity = { Common = 45, Rare = 60, Epic = 75, Legendary = 90, Mythic = 120 },
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
        AutoRoll = { ScriptName = "AutoRoll", NameKey = "Reward_AutoRoll", Weight = 50, Icon = "rbxassetid://6031091002", IsUnlockedDefault = true },
        WheelHaste = { ScriptName = "WheelHaste", NameKey = "Reward_WheelHaste", Weight = 65, Icon = "rbxassetid://6031763426", IsUnlockedDefault = true },
        WheelLevelUp = { ScriptName = "WheelLevelUp", NameKey = "Reward_WheelLevelUp", Weight = 55, Icon = "rbxassetid://6031068426", IsUnlockedDefault = true },
        PlayerSpeed = { ScriptName = "PlayerSpeed", NameKey = "Reward_PlayerSpeed", Weight = 85, Icon = "rbxassetid://6034754445", IsUnlockedDefault = true },
        Lucky = { ScriptName = "Lucky", NameKey = "Reward_Lucky", Weight = 70, Icon = "rbxassetid://6031075938", IsUnlockedDefault = true },
        CakeSpawnHaste = { ScriptName = "CakeSpawnHaste", NameKey = "Reward_CakeSpawnHaste", Weight = 75, Icon = "rbxassetid://6031763426", IsUnlockedDefault = true },
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
        UI_Open_Shop = "Shop", UI_Open_Bag = "Bag", UI_Close = "Close", UI_Buy = "Buy", UI_Bag_Title = "Ability Bag", UI_Bag_Wheel = "Wheel Terms", UI_Bag_Cards = "Drawable Skills", UI_Locked = "Locked", UI_Unlocked = "Owned",
        Cake_Common = "Common Cake", Cake_Rare = "Rare Cake", Cake_Epic = "Epic Cake", Cake_Legendary = "Legendary Cake", Cake_Mythic = "Mythic Cake", Reward_EatSpeed = "Eat Speed Up", Reward_AutoRoll = "Auto-Roll", Reward_WheelHaste = "Wheel Haste", Reward_WheelLevelUp = "Wheel Level Up", Reward_PlayerSpeed = "Player Speed Up", Reward_Lucky = "Lucky Up", Reward_CakeSpawnHaste = "Cake Rain Speed Up", UI_Normal_Wheel = "Reward Wheel", UI_Silver_Wheel = "Silver Wheel", UI_Merchant_Tab = "Mystery Merchant", UI_Upgrade = "Upgrade",
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
    EatRangeStuds = 9,
    SpawnInterval = 1.0,
    SpawnRadius = 30,
    SpawnHeight = 40,
    -- Cake count is intentionally unbounded; CakeLifetimeSeconds is the cleanup limiter.
    InitialBurstCount = 3,
    MeteorFallSpeed = 105,
    CakeBounciness = 0.05,
    MeteorTrailLifetime = 0.45,
    SinkSeconds = 1.1,
    EatAnimationSeconds = 0.45,
    CakeLifetimeSeconds = 20,
    MinimumSpawnDistance = 10, -- About 3 meters; keep cakes out of the immediate player area
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
        Common = { NameKey = "Cake_Common", RarityText = "COMMON", OutlineColor = Color3.fromRGB(210, 210, 210), BaseHealth = 10, Scale = 1.0 },
        Rare = { NameKey = "Cake_Rare", RarityText = "RARE", OutlineColor = Color3.fromRGB(70, 170, 255), BaseHealth = 30, Scale = 1.3, SplitChance = 0.04 },
        Epic = { NameKey = "Cake_Epic", RarityText = "EPIC", OutlineColor = Color3.fromRGB(185, 85, 255), BaseHealth = 80, Scale = 1.7, SplitChance = 0.07 },
        Legendary = { NameKey = "Cake_Legendary", RarityText = "LEGENDARY", OutlineColor = Color3.fromRGB(255, 170, 0), BaseHealth = 200, Scale = 2.2, SplitChance = 0.1 },
        Mythic = { NameKey = "Cake_Mythic", RarityText = "MYTHIC", OutlineColor = Color3.fromRGB(255, 60, 120), BaseHealth = 500, Scale = 2.8, SplitChance = 0.14 },
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
    },
    CakePointShop = {
        { Id = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1500, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421" },
        { Id = "Card_Ant", NameKey = "Card_Ant", Cost = 3000, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421" },
    },
    MysteryMerchantPool = {
        { Id = "Merchant_Tornado", Grants = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1200, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421", Weight = 2 },
        { Id = "Merchant_Ant", Grants = "Card_Ant", NameKey = "Card_Ant", Cost = 2400, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421", Weight = 1 },
    },
}
return ShopConfig
]=]

local dailyTaskConfig = getOrCreate(configsFolder, "ModuleScript", "DailyTaskConfig")
dailyTaskConfig.Source = [=[
-- Add, remove, or retune daily objectives here.  Progress type must match a server Record call.
return {
    ResetClock = "UTC",
    Tasks = {
        EatCakes = { Name = "Cake Taster", ProgressType = "EatCakes", Target = 10, Reward = { CakePoints = 120 } },
        RollWheel = { Name = "Lucky Spinner", ProgressType = "RollWheel", Target = 5, Reward = { WheelSpins = 2 } },
    },
}
]=]

local codeConfig = getOrCreate(configsFolder, "ModuleScript", "CodeConfig")
codeConfig.Source = [=[
-- Server-only code catalogue.  Codes are case-insensitive and each code can be redeemed once/player.
return {
    WELCOME = { Reward = { CakePoints = 250, WheelSpins = 2 } },
    RAINYDAY = { Reward = { CakePoints = 100 } },
}
]=]

local uiConfig = getOrCreate(configsFolder, "ModuleScript", "UIConfig")
uiConfig.Source = [=[
local UIConfig = {
    Sounds = {
        CakeShrink = "rbxassetid://135833732254676",
        WheelTick = "rbxassetid://105828157215739", -- Wheel ticks intentionally share the normal button sound.
        Interact = "rbxassetid://116172477936174",
        Button = "rbxassetid://105828157215739",
    },
    WheelUI = { AutoHide = true, ShowCondition = "WheelSpins > 0", TitleKey = "UI_Spins_Left", Position = "RightSideHalfCircle", DisplayedSlots = 5 },
    AutoRollUI = { AutoHide = true, ShowCondition = "HasAutoRollTime", TitleKey = "UI_AutoRoll_Active" },
    BuffStatus = { AutoHide = true, ShowCondition = "ActiveBuffsCount > 0", TitleKey = "UI_Time_Left" },
    ShopUI = { AutoHide = true, ShowCondition = "ManualOpen", TitleKey = "UI_Shop_Title" },
}
return UIConfig
]=]

clearChildren(cakeModelsFolder)
clearChildren(legacyCakeModelsFolder)
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
    model:Clone().Parent = legacyCakeModelsFolder
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
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
clearChildren(mainGui)

local function styleTextGui(gui)
    if not (gui:IsA("TextLabel") or gui:IsA("TextButton")) then return end
    gui.Font = Enum.Font.GothamBlack
    gui.TextColor3 = Color3.fromRGB(0, 0, 0)
end

local function newGui(className, name, parent)
    local gui = Instance.new(className)
    gui.Name = name
    gui.Parent = parent
    -- Global ZIndex is deliberate: every visual child explicitly sits above its GUI parent,
    -- preventing labels and icons from disappearing behind card bodies or hard shadows.
    if gui:IsA("GuiObject") and parent and parent:IsA("GuiObject") then
        gui.ZIndex = parent.ZIndex + 1
    end
    styleTextGui(gui)
    return gui
end

local hudScale = newGui("UIScale", "ResponsiveScale", mainGui)
hudScale.Scale = 1

-- ============================================================================
-- THEME: Roblox in-world card UI with chunky borders and hard shadows.
-- Default surfaces are white cards with black borders/shadows. Green is kept only
-- as an optional theme reference and subtle texture tint, never broad panel fill.
-- ============================================================================
local Theme = {
    White = Color3.fromRGB(255, 255, 255), -- primary card/panel surface
    Black = Color3.fromRGB(0, 0, 0), -- borders, text, hard shadows
    Accent = Color3.fromRGB(241, 196, 15), -- CTA buttons, badges, highlights
    BgBase = Color3.fromRGB(255, 255, 255), -- UI surfaces remain white by default
    GridLine = Color3.fromRGB(190, 190, 190), -- neutral low-opacity panel texture only
    Green = Color3.fromRGB(22, 163, 74),
    LightGreen = Color3.fromRGB(74, 222, 128),
    Red = Color3.fromRGB(220, 38, 38),
    Gray = Color3.fromRGB(156, 163, 175),
    Text = Color3.fromRGB(0, 0, 0),
    Muted = Color3.fromRGB(48, 60, 44),
}

local function addCorner(instance, radius)
    local corner = newGui("UICorner", "Corner", instance)
    corner.CornerRadius = UDim.new(0, radius or 16)
    return corner
end

local function addChunkyStroke(instance, thickness)
    local stroke = newGui("UIStroke", "ChunkyStroke", instance)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.Black
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Thickness = thickness or 3
    return stroke
end

local ShadowStyle = {
    PANEL = 0,
    ELEMENT = 0.78,
}

-- The single card factory used by new panels, headers, and reusable card components.  Its
-- ShadowFrame never moves; interaction tweens only move BodyFrame for a tactile hard-shadow feel.
local function createCard(config)
    local zBase = config.zIndexBase or 2
    local card = newGui("Frame", config.name or "CardFrame", config.parent)
    card.Size = config.size
    card.Position = config.position or UDim2.fromScale(0, 0)
    card.AnchorPoint = config.anchorPoint or Vector2.new(0, 0)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ZIndex = zBase

    local shadow = newGui("Frame", "ShadowFrame", card)
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.Position = UDim2.new(0, config.shadowOffset or 6, 0, config.shadowOffset or 6)
    shadow.BackgroundColor3 = Theme.Black
    shadow.BackgroundTransparency = config.shadowStyle ~= nil and config.shadowStyle or ShadowStyle.ELEMENT
    shadow.BorderSizePixel = 0
    shadow.ZIndex = zBase
    addCorner(shadow, config.cornerRadius or 16)

    local body = newGui("Frame", "BodyFrame", card)
    body.Size = UDim2.fromScale(1, 1)
    body.BackgroundColor3 = config.bodyColor or Theme.White
    body.BackgroundTransparency = config.bodyTransparency or 0
    body.BorderSizePixel = 0
    body.ZIndex = zBase + 1
    addCorner(body, config.cornerRadius or 16)
    addChunkyStroke(body, config.strokeThickness or 3)
    return card, shadow, body
end

local function addHardShadow(target, offset, radius, transparency)
    local shadow = newGui("Frame", target.Name .. "Shadow", target.Parent)
    shadow.AnchorPoint = target.AnchorPoint
    shadow.Size = target.Size
    shadow.Position = target.Position + UDim2.new(0, offset or 6, 0, offset or 6)
    shadow.BackgroundColor3 = Theme.Black
    shadow.BackgroundTransparency = transparency == nil and ShadowStyle.ELEMENT or transparency
    shadow.BorderSizePixel = 0
    shadow.ZIndex = math.max(0, target.ZIndex - 1)
    shadow.Visible = target.Visible
    addCorner(shadow, radius or 16)
    target.ZIndex = math.max(target.ZIndex, shadow.ZIndex + 1)
    shadow:SetAttribute("HardShadowFor", target.Name)
    return shadow
end

-- Fixed, black title plaque for every independent panel.  Text always receives an explicit
-- ZIndex above the plaque to remain readable with ScreenGui.ZIndexBehavior = Global.
local function createPanelTitleHeader(parent, text, width)
    local card, _, body = createCard({
        name = "PanelTitleHeader", size = UDim2.new(0, width or 170, 0, 44),
        position = UDim2.new(0, 22, 0, -21), parent = parent,
        shadowStyle = ShadowStyle.ELEMENT, shadowOffset = 4, cornerRadius = 12,
        zIndexBase = math.max(10, parent.ZIndex + 4), bodyColor = Theme.Black,
    })
    local label = newGui("TextLabel", "TitleLabel", body)
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBlack
    label.Text = text
    label.TextColor3 = Theme.White
    label.TextSize = 22
    label.ZIndex = body.ZIndex + 1
    local padding = newGui("UIPadding", "Padding", body)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    return card
end

local function addPanelGrid(parent)
    local grid = newGui("ImageLabel", "PanelGrid", parent)
    grid.AnchorPoint = Vector2.new(0, 0)
    grid.Size = UDim2.fromScale(1, 1)
    grid.Position = UDim2.fromScale(0, 0)
    grid.BackgroundTransparency = 1
    grid.BorderSizePixel = 0
    grid.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    grid.ImageColor3 = Theme.GridLine
    grid.ImageTransparency = 0.85
    grid.ScaleType = Enum.ScaleType.Tile
    grid.TileSize = UDim2.new(0, 28, 0, 28)
    grid.ZIndex = parent.ZIndex
    return grid
end

local function addTag(parent, text, accentColor)
    local tag = newGui("Frame", "Tag", parent)
    tag.AnchorPoint = Vector2.new(0, 0)
    tag.Size = UDim2.new(0, 132, 0, 30)
    tag.Position = UDim2.new(0, 20, 0, -16)
    tag.BackgroundColor3 = accentColor or Theme.Black
    tag.BorderSizePixel = 0
    tag.ZIndex = parent.ZIndex + 2
    addCorner(tag, 8)
    addChunkyStroke(tag, 3)

    local label = newGui("TextLabel", "Label", tag)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = Theme.White
    label.ZIndex = tag.ZIndex + 1
    return tag
end

-- Applies the shared chunky card style to floating panels.
local function applyPanel(frame, cornerRadius)
    frame.BackgroundColor3 = Theme.White
    frame.BackgroundTransparency = 0.04
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    addHardShadow(frame, 9, cornerRadius or 18, ShadowStyle.PANEL)
    addCorner(frame, cornerRadius or 18)
    addPanelGrid(frame)
    addChunkyStroke(frame, 4)
    return frame
end

-- Applies a light list well used inside panels for room/shop/bag style card rows.
local function applyWell(frame, cornerRadius)
    frame.BackgroundColor3 = Theme.White
    frame.BackgroundTransparency = 0.02
    frame.BorderSizePixel = 0
    addHardShadow(frame, 4, cornerRadius or 14, ShadowStyle.ELEMENT)
    addCorner(frame, cornerRadius or 14)
    addChunkyStroke(frame, 3)
    return frame
end

local function applyButtonStyle(button, color, textColor, radius)
    button.BackgroundColor3 = color or Theme.Black
    button.BackgroundTransparency = 0 -- Primary controls must remain solid, never washed out.
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    if button:IsA("TextButton") then
        button.TextColor3 = textColor or Theme.White
        button.Font = Enum.Font.GothamBlack
    end
    addHardShadow(button, 4, radius or 10, ShadowStyle.ELEMENT)
    addCorner(button, radius or 10)
    addChunkyStroke(button, 3)
    return button
end

-- Builds an icon+text stat row (e.g. "[cake icon] Cake Points: 120") without needing to change
-- any of the client code that just sets `label.Text = ...` -- the icon is a child overlay and a
-- UIPadding pushes the text to sit after it, so the label keeps working exactly as before.
local function addStatIcon(label, iconId, tintColor)
    local icon = newGui("ImageLabel", "Icon", label)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 0, 0.5, -12)
    icon.Image = iconId
    icon.ImageColor3 = tintColor or Theme.Text
    local padding = newGui("UIPadding", "IconPadding", label)
    padding.PaddingLeft = UDim.new(0, 32)
end

local stats = newGui("Frame", "StatsFrame", mainGui)
stats.Size = UDim2.new(0, 285, 0, 118)
stats.Position = UDim2.new(0, 18, 0, 18)
applyPanel(stats, 18)
addTag(stats, "STATS", Theme.Black)
local statRows = {
    { Name = "CakePointsLabel", Icon = "rbxassetid://6031068426", Tint = Theme.Accent },
    { Name = "WheelPointsLabel", Icon = "rbxassetid://6031091002", Tint = Theme.Black },
    { Name = "SpinsLabel", Icon = "rbxassetid://6031763426", Tint = Theme.Accent },
}
for index, row in ipairs(statRows) do
    local label = newGui("TextLabel", row.Name, stats)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 0, 32)
    label.Position = UDim2.new(0, 10, 0, 8 + (index - 1) * 34)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Theme.Text
    addStatIcon(label, row.Icon, row.Tint)
end
local shopButton = newGui("ImageButton", "ShopButton", mainGui)
shopButton.Size = UDim2.new(0, 58, 0, 58)
shopButton.Position = UDim2.new(0, 18, 0, 148)
shopButton.BackgroundColor3 = Theme.Accent
shopButton.Image = "rbxassetid://6031265976"
applyButtonStyle(shopButton, Theme.Accent, Theme.Text, 10)
local bagButton = newGui("ImageButton", "BagButton", mainGui)
bagButton.Size = UDim2.new(0, 58, 0, 58)
bagButton.Position = UDim2.new(0, 86, 0, 148)
bagButton.BackgroundColor3 = Theme.White
bagButton.Image = "rbxassetid://6031265972"
applyButtonStyle(bagButton, Theme.White, Theme.Text, 10)

local taskButton = newGui("TextButton", "TaskButton", mainGui)
taskButton.Size = UDim2.new(0, 126, 0, 46)
taskButton.Position = UDim2.new(0, 154, 0, 154)
taskButton.Text = "DAILY"
taskButton.TextScaled = true
applyButtonStyle(taskButton, Theme.Accent, Theme.Text, 10)
local codeButton = newGui("TextButton", "CodeButton", mainGui)
codeButton.Size = UDim2.new(0, 126, 0, 46)
codeButton.Position = UDim2.new(0, 154, 0, 208)
codeButton.Text = "CODES"
codeButton.TextScaled = true
applyButtonStyle(codeButton, Theme.White, Theme.Text, 10)

local taskPanel = newGui("Frame", "DailyTaskPanel", mainGui)
taskPanel.Size = UDim2.new(0, 500, 0, 440)
taskPanel.Position = UDim2.new(.5, -250, .5, -220)
taskPanel.Visible = false
applyPanel(taskPanel, 18)
createPanelTitleHeader(taskPanel, "DAILY TASKS", 205)
local closeTasks = newGui("TextButton", "CloseButton", taskPanel)
closeTasks.Size = UDim2.new(0, 82, 0, 36); closeTasks.Position = UDim2.new(1, -96, 0, 12); closeTasks.Text = "CLOSE"; closeTasks.TextScaled = true
applyButtonStyle(closeTasks, Theme.Red, Theme.White, 10)
local taskList = newGui("ScrollingFrame", "TaskList", taskPanel)
taskList.Size = UDim2.new(1, -44, 1, -88); taskList.Position = UDim2.new(0, 22, 0, 62); taskList.CanvasSize = UDim2.new(); taskList.ScrollBarThickness = 6; taskList.ScrollBarImageColor3 = Theme.Black
applyWell(taskList, 14)
local taskPadding = newGui("UIPadding", "Padding", taskList); taskPadding.PaddingLeft = UDim.new(0, 10); taskPadding.PaddingRight = UDim.new(0, 16); taskPadding.PaddingTop = UDim.new(0, 10); taskPadding.PaddingBottom = UDim.new(0, 10)
local taskLayout = newGui("UIListLayout", "Layout", taskList); taskLayout.Padding = UDim.new(0, 12)
local taskTemplate = newGui("TextButton", "TaskTemplate", taskList)
taskTemplate.Size = UDim2.new(1, -2, 0, 112); taskTemplate.BackgroundColor3 = Theme.White; taskTemplate.Visible = false; taskTemplate.Text = ""; taskTemplate.AutoButtonColor = false
applyButtonStyle(taskTemplate, Theme.White, Theme.Text, 12)
local taskName = newGui("TextLabel", "Name", taskTemplate); taskName.BackgroundTransparency = 1; taskName.Position = UDim2.new(0, 14, 0, 10); taskName.Size = UDim2.new(.62, 0, 0, 26); taskName.TextXAlignment = Enum.TextXAlignment.Left; taskName.TextScaled = true
local taskReward = newGui("TextLabel", "Reward", taskTemplate); taskReward.BackgroundTransparency = 1; taskReward.Position = UDim2.new(.62, 0, 0, 10); taskReward.Size = UDim2.new(.35, -10, 0, 26); taskReward.TextXAlignment = Enum.TextXAlignment.Right; taskReward.TextScaled = true; taskReward.TextColor3 = Theme.Accent
local progressBack = newGui("Frame", "ProgressBack", taskTemplate); progressBack.Size = UDim2.new(1, -28, 0, 18); progressBack.Position = UDim2.new(0, 14, 0, 46); progressBack.BackgroundColor3 = Theme.Black; addCorner(progressBack, 8)
local progressFill = newGui("Frame", "ProgressFill", progressBack); progressFill.Size = UDim2.new(0, 0, 1, 0); progressFill.BackgroundColor3 = Theme.Accent; addCorner(progressFill, 8)
local progressLabel = newGui("TextLabel", "ProgressLabel", taskTemplate); progressLabel.BackgroundTransparency = 1; progressLabel.Position = UDim2.new(0, 14, 0, 70); progressLabel.Size = UDim2.new(.55, 0, 0, 28); progressLabel.TextXAlignment = Enum.TextXAlignment.Left; progressLabel.TextScaled = true
local claimLabel = newGui("TextLabel", "ClaimLabel", taskTemplate); claimLabel.BackgroundColor3 = Theme.Black; claimLabel.Position = UDim2.new(.62, 0, 0, 72); claimLabel.Size = UDim2.new(.35, -10, 0, 26); claimLabel.TextColor3 = Theme.White; claimLabel.Text = "IN PROGRESS"; claimLabel.TextScaled = true; addCorner(claimLabel, 8)

local codePanel = newGui("Frame", "CodePanel", mainGui)
codePanel.Size = UDim2.new(0, 400, 0, 240); codePanel.Position = UDim2.new(.5, -200, .5, -120); codePanel.Visible = false
applyPanel(codePanel, 18)
createPanelTitleHeader(codePanel, "REDEEM CODE", 205)
local closeCode = newGui("TextButton", "CloseButton", codePanel); closeCode.Size = UDim2.new(0, 82, 0, 36); closeCode.Position = UDim2.new(1, -96, 0, 12); closeCode.Text = "CLOSE"; closeCode.TextScaled = true; applyButtonStyle(closeCode, Theme.Red, Theme.White, 10)
local codeHint = newGui("TextLabel", "Hint", codePanel); codeHint.BackgroundTransparency = 1; codeHint.Position = UDim2.new(0, 24, 0, 70); codeHint.Size = UDim2.new(1, -48, 0, 32); codeHint.Text = "Enter a reward code"; codeHint.TextScaled = true
local codeBox = newGui("TextBox", "CodeBox", codePanel); codeBox.Size = UDim2.new(1, -48, 0, 44); codeBox.Position = UDim2.new(0, 24, 0, 112); codeBox.PlaceholderText = "ENTER CODE"; codeBox.ClearTextOnFocus = false; codeBox.TextScaled = true; applyWell(codeBox, 10)
local redeemButton = newGui("TextButton", "RedeemButton", codePanel); redeemButton.Size = UDim2.new(1, -48, 0, 42); redeemButton.Position = UDim2.new(0, 24, 1, -62); redeemButton.Text = "REDEEM"; redeemButton.TextScaled = true; applyButtonStyle(redeemButton, Theme.Black, Theme.White, 10)

local wheel = newGui("Frame", "WheelPanel", mainGui)
wheel.Name = "WheelPanel"
wheel.Size = UDim2.new(0, 420, 0, 410)
wheel.AnchorPoint = Vector2.new(1, 0.5)
wheel.Position = UDim2.new(1, -20, 0.5, 0)
wheel.BackgroundTransparency = 1
wheel.Visible = false
local wheelTitle = newGui("TextLabel", "Title", wheel)
wheelTitle.Size = UDim2.new(1, 0, 0, 36)
wheelTitle.BackgroundTransparency = 1
wheelTitle.Font = Enum.Font.GothamBlack
wheelTitle.Text = "LUCKY WHEEL"
wheelTitle.TextScaled = true
wheelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
local disc = newGui("Frame", "WheelDisc", wheel)
disc.Size = UDim2.new(0, 160, 0, 300)
disc.Position = UDim2.new(1, -180, 0, 44)
applyWell(disc, 10)
disc.ClipsDescendants = true
local strip = newGui("Frame", "SlotStrip", disc)
strip.Size = UDim2.new(1, 0, 0, 0)
strip.BackgroundTransparency = 1
strip.BorderSizePixel = 0
local topShade = newGui("Frame", "TopShade", disc)
topShade.Size = UDim2.new(1, 0, 0, 100)
topShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topShade.BackgroundTransparency = 0.35
topShade.BorderSizePixel = 0
topShade.ZIndex = 5
local bottomShade = topShade:Clone()
bottomShade.Name = "BottomShade"
bottomShade.Position = UDim2.new(0, 0, 0, 200)
bottomShade.Parent = disc
local centerLine = newGui("Frame", "CenterLine", disc)
centerLine.Size = UDim2.new(1, 0, 0, 100)
centerLine.Position = UDim2.new(0, 0, 0, 100)
centerLine.BackgroundTransparency = 1
centerLine.ZIndex = 6
local centerStroke = newGui("UIStroke", "CenterStroke", centerLine)
centerStroke.Color = Theme.Accent
centerStroke.Thickness = 3
local sideGrid = newGui("Frame", "SideGrid", wheel)
sideGrid.Size = UDim2.new(0, 220, 0, 300)
sideGrid.Position = UDim2.new(0, 20, 0, 44)
sideGrid.BackgroundTransparency = 1
local sideLayout = newGui("UIGridLayout", "GridLayout", sideGrid)
sideLayout.CellSize = UDim2.new(0, 48, 0, 48)
sideLayout.CellPadding = UDim2.new(0, 6, 0, 6)
local spinButton = newGui("TextButton", "SpinButton", wheel)
spinButton.Size = UDim2.new(0, 120, 0, 44)
spinButton.Position = UDim2.new(0.5, -125, 1, -54)
spinButton.BackgroundColor3 = Theme.Accent
spinButton.Font = Enum.Font.GothamBlack
spinButton.Text = "SPIN"
spinButton.TextScaled = true
spinButton.TextColor3 = Theme.Text
applyButtonStyle(spinButton, Theme.Accent, Theme.Text, 10)
local autoRollToggle = newGui("TextButton", "AutoRollToggle", wheel)
autoRollToggle.Size = UDim2.new(0, 120, 0, 44)
autoRollToggle.Position = UDim2.new(0.5, 5, 1, -54)
autoRollToggle.BackgroundColor3 = Theme.White
autoRollToggle.Font = Enum.Font.GothamBlack
autoRollToggle.Text = "AUTO: OFF"
autoRollToggle.TextScaled = true
autoRollToggle.TextColor3 = Theme.Text
autoRollToggle.Visible = false
applyButtonStyle(autoRollToggle, Theme.Black, Theme.White, 10)
local buffFrame = newGui("Frame", "EffectBar", mainGui)
buffFrame.Size = UDim2.new(0, 392, 0, 74)
buffFrame.Position = UDim2.new(0, 18, 1, -92)
buffFrame.Visible = false
applyPanel(buffFrame, 16)
addTag(buffFrame, "BUFFS", Theme.Black)
-- The client clones this only for active effects; the empty HUD has no placeholder icons.
local effectTemplate = newGui("ImageButton", "EffectIconTemplate", buffFrame)
effectTemplate.Size = UDim2.new(0, 46, 0, 46)
effectTemplate.BackgroundColor3 = Theme.White
effectTemplate.BackgroundTransparency = 0
effectTemplate.AutoButtonColor = false
effectTemplate.Visible = false
effectTemplate.Image = ""
newGui("UICorner", "Corner", effectTemplate).CornerRadius = UDim.new(0, 10)
local templateStroke = newGui("UIStroke", "Outline", effectTemplate)
templateStroke.Thickness = 3
templateStroke.Color = Theme.Black
templateStroke.Transparency = 0
local templateCooldown = newGui("Frame", "CooldownFill", effectTemplate)
templateCooldown.AnchorPoint = Vector2.new(0, 1)
templateCooldown.Position = UDim2.new(0, 0, 1, 0)
templateCooldown.Size = UDim2.new(1, 0, 0, 0)
templateCooldown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
templateCooldown.BackgroundTransparency = 0.35
templateCooldown.BorderSizePixel = 0
templateCooldown.Visible = false
templateCooldown.ZIndex = 2
local templateCooldownText = newGui("TextLabel", "CooldownText", effectTemplate)
templateCooldownText.BackgroundTransparency = 1
templateCooldownText.Size = UDim2.fromScale(1, 1)
templateCooldownText.Font = Enum.Font.GothamBlack
templateCooldownText.TextScaled = true
templateCooldownText.TextColor3 = Theme.Text
templateCooldownText.ZIndex = 3
templateCooldownText.Visible = false

local tooltip = newGui("TextLabel", "Tooltip", buffFrame)
tooltip.Size = UDim2.new(0, 260, 0, 34)
tooltip.Position = UDim2.new(0, 8, 0, -38)
tooltip.Font = Enum.Font.GothamBlack
tooltip.TextScaled = true
tooltip.TextColor3 = Theme.Text
tooltip.Visible = false
applyPanel(tooltip, 8)

-- A short bottom status readout shows the most recent wheel reward, including rarity tier.
local currentDrawLabel = newGui("TextLabel", "CurrentDrawLabel", mainGui)
currentDrawLabel.Size = UDim2.new(0, 392, 0, 28)
currentDrawLabel.Position = UDim2.new(0, 18, 1, -124)
currentDrawLabel.Font = Enum.Font.GothamBlack
currentDrawLabel.TextScaled = true
currentDrawLabel.TextColor3 = Theme.Text
currentDrawLabel.Visible = false
applyPanel(currentDrawLabel, 8)

local shopHub = newGui("Frame", "ShopHub", mainGui)
shopHub.Size = UDim2.new(0, 700, 0, 430)
shopHub.Position = UDim2.new(0.5, -350, 0.5, -215)
shopHub.Visible = false
applyPanel(shopHub, 18)
createPanelTitleHeader(shopHub, "SHOP", 170)
local shopAspect = newGui("UIAspectRatioConstraint", "AspectRatio", shopHub)
shopAspect.AspectRatio = 1.72
shopAspect.DominantAxis = Enum.DominantAxis.Width
local closeShop = newGui("TextButton", "CloseButton", shopHub)
closeShop.Size = UDim2.new(0, 90, 0, 38)
closeShop.Position = UDim2.new(1, -104, 0, 12)
closeShop.BackgroundColor3 = Theme.Red
closeShop.Font = Enum.Font.GothamBlack
closeShop.Text = "Close"
closeShop.TextScaled = true
closeShop.TextColor3 = Theme.Text
applyButtonStyle(closeShop, Theme.Red, Theme.White, 10)
local shopGrid = newGui("ScrollingFrame", "ShopGrid", shopHub)
shopGrid.Size = UDim2.new(1, -40, 1, -82)
shopGrid.Position = UDim2.new(0, 20, 0, 62)
shopGrid.ScrollBarThickness = 8
shopGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
applyWell(shopGrid, 14)
shopGrid.ScrollBarThickness = 6
shopGrid.ScrollBarImageColor3 = Theme.Black
local shopGridPadding = newGui("UIPadding", "ListPadding", shopGrid)
shopGridPadding.PaddingLeft = UDim.new(0, 10)
shopGridPadding.PaddingRight = UDim.new(0, 16)
shopGridPadding.PaddingTop = UDim.new(0, 10)
shopGridPadding.PaddingBottom = UDim.new(0, 10)
local gridLayout = newGui("UIGridLayout", "GridLayout", shopGrid)
gridLayout.CellSize = UDim2.new(0, 128, 0, 128)
gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local shopTemplate = newGui("ImageButton", "ItemTemplate", shopGrid)
shopTemplate.Size = UDim2.new(0, 128, 0, 128)
shopTemplate.BackgroundColor3 = Theme.White
shopTemplate.BackgroundTransparency = 0
shopTemplate.AutoButtonColor = false
shopTemplate.Visible = false
newGui("UICorner", "Corner", shopTemplate).CornerRadius = UDim.new(0, 12)
local shopTemplateStroke = newGui("UIStroke", "Accent", shopTemplate)
shopTemplateStroke.Color = Theme.Black
shopTemplateStroke.Transparency = 0
shopTemplateStroke.Thickness = 3
local shopIcon = newGui("ImageLabel", "Icon", shopTemplate)
shopIcon.BackgroundTransparency = 1
shopIcon.Size = UDim2.new(0, 46, 0, 46)
shopIcon.Position = UDim2.new(0.5, -23, 0, 54)
shopIcon.Image = ""
local itemName = newGui("TextLabel", "ItemName", shopTemplate)
itemName.BackgroundTransparency = 1
itemName.Size = UDim2.new(1, -8, 0, 50)
itemName.Position = UDim2.new(0, 4, 0, 12)
itemName.Font = Enum.Font.GothamBlack
itemName.TextScaled = true
itemName.TextWrapped = true
itemName.TextColor3 = Theme.Text
local itemCost = newGui("TextLabel", "ItemCost", shopTemplate)
itemCost.BackgroundTransparency = 1
itemCost.Size = UDim2.new(1, -8, 0, 32)
itemCost.Position = UDim2.new(0, 4, 1, -40)
itemCost.Font = Enum.Font.GothamBlack
itemCost.TextScaled = true
itemCost.TextColor3 = Theme.Accent


local bagPanel = newGui("Frame", "InventoryBag", mainGui)
bagPanel.Size = UDim2.new(0, 700, 0, 430)
bagPanel.Position = UDim2.new(0.5, -350, 0.5, -215)
bagPanel.Visible = false
applyPanel(bagPanel, 18)
createPanelTitleHeader(bagPanel, "ABILITY BAG", 210)
local bagAspect = newGui("UIAspectRatioConstraint", "AspectRatio", bagPanel)
bagAspect.AspectRatio = 1.72
bagAspect.DominantAxis = Enum.DominantAxis.Width
local closeBag = newGui("TextButton", "CloseButton", bagPanel)
closeBag.Size = UDim2.new(0, 90, 0, 38)
closeBag.Position = UDim2.new(1, -104, 0, 12)
closeBag.BackgroundColor3 = Theme.Red
closeBag.Font = Enum.Font.GothamBlack
closeBag.Text = "Close"
closeBag.TextScaled = true
closeBag.TextColor3 = Theme.Text
applyButtonStyle(closeBag, Theme.Red, Theme.White, 10)
local termTabButton = newGui("TextButton", "TermTabButton", bagPanel)
termTabButton.Size = UDim2.new(0, 120, 0, 34)
termTabButton.Position = UDim2.new(0, 20, 0, 54)
termTabButton.BackgroundColor3 = Theme.White
termTabButton.Font = Enum.Font.GothamBlack
termTabButton.Text = "Terms"
termTabButton.TextScaled = true
termTabButton.TextColor3 = Theme.Text
applyButtonStyle(termTabButton, Theme.White, Theme.Text, 10)
local skillTabButton = newGui("TextButton", "SkillTabButton", bagPanel)
skillTabButton.Size = UDim2.new(0, 120, 0, 34)
skillTabButton.Position = UDim2.new(0, 148, 0, 54)
skillTabButton.BackgroundColor3 = Theme.Accent
skillTabButton.Font = Enum.Font.GothamBlack
skillTabButton.Text = "Skills"
skillTabButton.TextScaled = true
skillTabButton.TextColor3 = Theme.Text
applyButtonStyle(skillTabButton, Theme.Accent, Theme.Text, 10)
-- Equipped skill slots now live at the TOP of the bag panel (under the tabs) so they read as a
-- drag-and-drop destination row above the drawable-skill grid, and the buttons are smaller.
-- These are pure visual "boxes" -- no numbering, no fixed identity; whatever is in the player's
-- equipped-skills list just gets displayed left to right.
local equippedFrame = newGui("Frame", "EquippedSkillSlots", bagPanel)
equippedFrame.Size = UDim2.new(1, -260, 0, 46)
equippedFrame.Position = UDim2.new(0, 20, 0, 94)
equippedFrame.BackgroundTransparency = 1
equippedFrame.Visible = false
local equippedLayout = newGui("UIListLayout", "SlotLayout", equippedFrame)
equippedLayout.FillDirection = Enum.FillDirection.Horizontal
equippedLayout.Padding = UDim.new(0, 6)
for slotIndex = 1, 5 do
    local slot = newGui("ImageButton", "SkillSlot" .. tostring(slotIndex), equippedFrame)
    slot.Size = UDim2.new(0, 54, 0, 42)
    slot.BackgroundColor3 = Theme.White
    slot.BackgroundTransparency = 0
    slot.Image = "" -- empty box shows nothing; filled boxes get their skill's icon at runtime
    slot.ScaleType = Enum.ScaleType.Fit
    slot.AutoButtonColor = false
    newGui("UICorner", "Corner", slot).CornerRadius = UDim.new(0, 8)
    local boxStroke = newGui("UIStroke", "BoxStroke", slot)
    boxStroke.Color = Theme.Black
    boxStroke.Transparency = 0
    boxStroke.Thickness = 3
    -- Magnetic drop highlight: made visible while a dragged skill icon hovers over this slot.
    local highlight = newGui("UIStroke", "Highlight", slot)
    highlight.Thickness = 3
    highlight.Color = Theme.Accent
    highlight.Transparency = 1
end
local bagList = newGui("ScrollingFrame", "BagList", bagPanel)
bagList.Size = UDim2.new(1, -260, 1, -192)
bagList.Position = UDim2.new(0, 20, 0, 148)
bagList.ScrollBarThickness = 8
bagList.CanvasSize = UDim2.new(0, 0, 0, 0)
applyWell(bagList, 14)
bagList.ScrollBarThickness = 6
bagList.ScrollBarImageColor3 = Theme.Black
local bagListPadding = newGui("UIPadding", "ListPadding", bagList)
bagListPadding.PaddingLeft = UDim.new(0, 10)
bagListPadding.PaddingRight = UDim.new(0, 16)
bagListPadding.PaddingTop = UDim.new(0, 10)
bagListPadding.PaddingBottom = UDim.new(0, 10)
-- Highlighted while dragging a skill DOWN off a box, to show "drop here to put it back".
local bagDropHint = newGui("UIStroke", "UIStroke_DropHint", bagList)
bagDropHint.Thickness = 4
bagDropHint.Color = Theme.Accent
bagDropHint.Transparency = 1
local bagLayout = newGui("UIGridLayout", "GridLayout", bagList)
bagLayout.CellSize = UDim2.new(0, 128, 0, 128)
bagLayout.CellPadding = UDim2.new(0, 12, 0, 12)
bagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local bagTemplate = newGui("ImageButton", "EntryTemplate", bagList)
bagTemplate.Size = UDim2.new(0, 128, 0, 128)
bagTemplate.BackgroundColor3 = Theme.White
bagTemplate.BackgroundTransparency = 0
bagTemplate.Image = ""
bagTemplate.Visible = false
newGui("UICorner", "Corner", bagTemplate).CornerRadius = UDim.new(0, 10)
local bagTemplateStroke = newGui("UIStroke", "Accent", bagTemplate)
bagTemplateStroke.Color = Theme.Black
bagTemplateStroke.Transparency = 0
bagTemplateStroke.Thickness = 3
local bagEntryName = newGui("TextLabel", "ItemName", bagTemplate)
bagEntryName.BackgroundTransparency = 1
bagEntryName.Size = UDim2.new(1, -10, 0, 42)
bagEntryName.Position = UDim2.new(0, 5, 1, -46)
bagEntryName.Font = Enum.Font.GothamBlack
bagEntryName.TextScaled = true
bagEntryName.TextWrapped = true
bagEntryName.TextColor3 = Theme.Text
local bagDetail = newGui("Frame", "DetailPanel", bagPanel)
bagDetail.Size = UDim2.new(0, 210, 1, -82)
bagDetail.Position = UDim2.new(1, -230, 0, 62)
applyWell(bagDetail, 14)
local detailText = newGui("TextLabel", "DetailText", bagDetail)
detailText.BackgroundTransparency = 1
detailText.Size = UDim2.new(1, -16, 1, -72)
detailText.Position = UDim2.new(0, 8, 0, 8)
detailText.Font = Enum.Font.GothamBlack
detailText.TextWrapped = true
detailText.TextScaled = true
detailText.TextColor3 = Theme.Text
detailText.Text = "Select an ability"
local upgradeButton = newGui("TextButton", "UpgradeButton", bagDetail)
upgradeButton.Size = UDim2.new(1, -24, 0, 46)
upgradeButton.Position = UDim2.new(0, 12, 1, -58)
upgradeButton.BackgroundColor3 = Theme.Accent
upgradeButton.Font = Enum.Font.GothamBlack
upgradeButton.TextScaled = true
upgradeButton.TextColor3 = Theme.Text
upgradeButton.Text = "Upgrade"
applyButtonStyle(upgradeButton, Theme.Accent, Theme.Text, 10)

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
local orderedStores = {}
local memory = {}

local function getOrderedStore(name)
    if orderedStores[name] ~= nil then
        return orderedStores[name]
    end
    local ok, result = pcall(function()
        return DataStoreService:GetOrderedDataStore(CakeConfig.DataStoreKey .. "_" .. name)
    end)
    orderedStores[name] = ok and result or false
    return orderedStores[name]
end

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
    if RunService:IsStudio() then
        return memory[key] or {}
    end
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
        local cakeStore = getOrderedStore("CakePoints")
        if cakeStore then
            pcall(function()
                cakeStore:SetAsync(tostring(player.UserId), math.max(0, math.floor(tonumber(data.CakePoints) or 0)))
            end)
        end
        local spinsStore = getOrderedStore("WheelSpins")
        if spinsStore then
            pcall(function()
                spinsStore:SetAsync(tostring(player.UserId), math.max(0, math.floor(tonumber(data.TotalRolls or data.WheelPoints or data.WheelSpins) or 0)))
            end)
        end
    end
end

function DataService.GetGlobalLeaderboard(metric, limit)
    local activeStore = getOrderedStore(metric)
    if not activeStore then return {} end
    local ok, pages = pcall(function()
        return activeStore:GetSortedAsync(false, limit or 10)
    end)
    if not ok then return {} end
    local rows = {}
    for rank, entry in ipairs(pages:GetCurrentPage()) do
        table.insert(rows, { Rank = rank, UserId = tonumber(entry.key) or 0, Value = entry.value or 0 })
    end
    return rows
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
        TotalRolls = loaded.TotalRolls or loaded.WheelPoints or 0,
        WheelPoints = loaded.WheelPoints or 0,
        WheelLevel = math.max(1, loaded.WheelLevel or 1),
        PendingWheelSpin = nil,
        CakePoints = loaded.CakePoints or 0,
        LastWheelReward = nil,
        Buffs = StateService.RestoreBuffs(loaded.ActiveBuffs or loaded.Buffs),
        OwnedItems = loaded.OwnedItems or {},
        AbilityLevels = loaded.AbilityLevels or {},
        MerchantPurchases = loaded.MerchantPurchases or {},
        Stats = loaded.Stats or {},
        UnlockedWheelRewards = loaded.UnlockedWheelRewards or {},
        UnlockedCards = loaded.UnlockedCards or {},
        DailyTaskDay = loaded.DailyTaskDay or "",
        DailyTaskProgress = loaded.DailyTaskProgress or {},
        DailyTaskClaims = loaded.DailyTaskClaims or {},
        RedeemedCodes = loaded.RedeemedCodes or {},
        -- EquippedSkills is a free-form, order-free list of up to 5 skill keys (no slot numbers).
        -- pairs() here also migrates any older save data that stored it as a slot-indexed table.
        EquippedSkills = (function()
            local compact = {}
            for _, key in pairs(loaded.EquippedSkills or {}) do
                table.insert(compact, key)
            end
            return compact
        end)(),
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
        TotalRolls = state.TotalRolls,
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
        DailyTaskDay = state.DailyTaskDay,
        DailyTaskProgress = state.DailyTaskProgress,
        DailyTaskClaims = state.DailyTaskClaims,
        RedeemedCodes = state.RedeemedCodes,
        EquippedSkills = state.EquippedSkills,
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
            active[buffType] = { Name = text(best.NameKey), Rarity = best.Rarity, Value = best.Value or best.Level or 0, Remaining = math.max(0, math.floor(best.Remaining or 0)), Icon = best.Icon or "", OutlineColor = WheelConfig.RarityColors[best.Rarity] or Color3.fromRGB(74, 68, 64), Interval = best.Interval, MultiRolls = best.MultiRolls, Level = best.Level or 1, SkillId = best.SkillId, Stacks = best.Stacks or 1, CooldownRemaining = math.max(0, (best.CooldownEndsAt or 0) - now), CooldownDuration = best.TriggerInterval or 0 }
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

function StateService.IsSkillEquipped(state, key)
    for _, equippedKey in ipairs(state.EquippedSkills or {}) do
        if equippedKey == key then return true end
    end
    return false
end

local MAX_EQUIPPED_SKILLS = 5

-- Removes a key from the compact EquippedSkills array (if present) using table.remove, so the
-- array never develops gaps. Returns true if something was removed.
local function removeEquippedKey(state, key)
    for index, equippedKey in ipairs(state.EquippedSkills) do
        if equippedKey == key then
            table.remove(state.EquippedSkills, index)
            return true
        end
    end
    return false
end

-- Equip/Replace/Unequip work on a free-form, order-free list of skill keys -- there is no such
-- thing as "slot 1-5" server-side anymore, so nothing can end up in two places or land in a
-- position the client can't render.
--   action == "Equip"    : keyA is added if there's room.
--   action == "Replace"  : keyB (currently shown in the drop target) is removed, keyA takes its place.
--   action == "Unequip"  : keyA is removed (used when dragging a skill back down to the bag).
function StateService.EquipSkill(player, action, keyA, keyB)
    local state = StateService.Get(player)
    if not state then return false, "NO_STATE" end
    state.EquippedSkills = state.EquippedSkills or {}
    local SkillConfig = require(Configs.SkillConfig)

    if action == "Unequip" then
        removeEquippedKey(state, keyA)
        return true
    end

    local card = SkillConfig.Cards[keyA]
    if not card or (not card.IsUnlockedDefault and not state.UnlockedCards[keyA]) then return false, "LOCKED_SKILL" end

    if action == "Equip" then
        if not removeEquippedKey(state, keyA) and #state.EquippedSkills >= MAX_EQUIPPED_SKILLS then
            return false, "FULL"
        end
        table.insert(state.EquippedSkills, keyA)
        return true
    elseif action == "Replace" then
        removeEquippedKey(state, keyA)
        removeEquippedKey(state, keyB)
        if #state.EquippedSkills >= MAX_EQUIPPED_SKILLS then return false, "FULL" end
        table.insert(state.EquippedSkills, keyA)
        return true
    end
    return false, "BAD_ACTION"
end

function StateService.BuildInventory(player)
    local state = StateService.GetProfile(player)
    local inventory = { WheelRewards = {}, Cards = {}, EquippedSkills = state.EquippedSkills or {} }
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
        wheelReward = displayFor > 0 and { Key = wheelReward.Key, Name = wheelReward.Name, Rarity = wheelReward.Rarity, Kind = wheelReward.Kind, Stacks = wheelReward.Stacks, EffectText = wheelReward.EffectText, DisplayFor = displayFor } or nil
    end
    UpdateClientState:FireClient(player, {
        WheelSpins = state.WheelSpins, TotalRolls = state.TotalRolls, WheelPoints = state.WheelPoints, WheelLevel = state.WheelLevel, CakePoints = state.CakePoints,
        LastWheelReward = wheelReward,
        ActiveBuffs = StateService.ActiveBuffs(player), UnlockedWheelRewards = state.UnlockedWheelRewards, UnlockedCards = state.UnlockedCards,
        Inventory = StateService.BuildInventory(player),
        ShopItems = StateService.BuildShop and StateService.BuildShop(state) or nil,
        DailyTasks = StateService.BuildDailyTasks and StateService.BuildDailyTasks(player) or nil,
    })
end
return StateService
]=]

local taskService = getOrCreate(servicesPackage, "ModuleScript", "DailyTaskService")
taskService.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Configs.DailyTaskConfig)
local StateService = require(script.Parent.StateService)
local DailyTaskService = {}
local function dayKey() return os.date("!%Y-%m-%d") end
local function ensure(state)
    local day = dayKey()
    if state.DailyTaskDay ~= day then
        state.DailyTaskDay, state.DailyTaskProgress, state.DailyTaskClaims = day, {}, {}
    end
end
local function grant(state, reward)
    for currency, amount in pairs(reward or {}) do state[currency] = (state[currency] or 0) + amount end
end
function DailyTaskService.Record(player, progressType, amount)
    local state = StateService.Get(player); if not state then return end
    ensure(state)
    for id, task in pairs(Config.Tasks) do
        if task.ProgressType == progressType and not state.DailyTaskClaims[id] then
            state.DailyTaskProgress[id] = math.min(task.Target, (state.DailyTaskProgress[id] or 0) + (amount or 1))
        end
    end
end
function DailyTaskService.Build(player)
    local state = StateService.Get(player); if not state then return {} end
    ensure(state)
    local tasks = {}
    for id, task in pairs(Config.Tasks) do
        table.insert(tasks, { Id = id, Name = task.Name, Progress = state.DailyTaskProgress[id] or 0, Target = task.Target, Reward = task.Reward, Claimed = state.DailyTaskClaims[id] == true })
    end
    return tasks
end
function DailyTaskService.Claim(player, id)
    local state, task = StateService.Get(player), Config.Tasks[id]
    if not state or not task then return false, "INVALID_TASK" end
    ensure(state)
    if state.DailyTaskClaims[id] then return false, "ALREADY_CLAIMED" end
    if (state.DailyTaskProgress[id] or 0) < task.Target then return false, "NOT_COMPLETE" end
    state.DailyTaskClaims[id] = true; grant(state, task.Reward)
    StateService.UpdateLeaderstats(player); StateService.Push(player)
    return true
end
StateService.BuildDailyTasks = DailyTaskService.Build
return DailyTaskService
]=]

local codeService = getOrCreate(servicesPackage, "ModuleScript", "CodeService")
codeService.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Configs.CodeConfig)
local StateService = require(script.Parent.StateService)
local CodeService = {}
function CodeService.Redeem(player, rawCode)
    local state = StateService.Get(player)
    local code = string.upper(string.gsub(tostring(rawCode or ""), "%s+", ""))
    local entry = Config[code]
    if not state or not entry then return false, "INVALID_CODE" end
    state.RedeemedCodes = state.RedeemedCodes or {}
    if state.RedeemedCodes[code] then return false, "ALREADY_REDEEMED" end
    state.RedeemedCodes[code] = true
    for currency, amount in pairs(entry.Reward or {}) do state[currency] = (state[currency] or 0) + amount end
    StateService.UpdateLeaderstats(player); StateService.Push(player)
    return true, entry.Reward
end
return CodeService
]=]

local serverGuardService = getOrCreate(servicesPackage, "ModuleScript", "ServerGuardService")
serverGuardService.Source = [=[
local HttpService = game:GetService("HttpService")

local ServerGuardService = { Buckets = {}, ServerSecret = HttpService:GenerateGUID(false) }

function ServerGuardService.Allow(player, action, limit, windowSeconds)
    local now = os.clock()
    local key = tostring(player.UserId) .. ":" .. tostring(action)
    local bucket = ServerGuardService.Buckets[key]
    if not bucket or now - bucket.StartedAt > windowSeconds then
        bucket = { StartedAt = now, Count = 0 }
        ServerGuardService.Buckets[key] = bucket
    end
    bucket.Count += 1
    return bucket.Count <= limit
end

function ServerGuardService.ClearPlayer(player)
    local prefix = tostring(player.UserId) .. ":"
    for key in pairs(ServerGuardService.Buckets) do
        if string.sub(key, 1, #prefix) == prefix then
            ServerGuardService.Buckets[key] = nil
        end
    end
end

return ServerGuardService
]=]

local globalLeaderboardService = getOrCreate(servicesPackage, "ModuleScript", "GlobalLeaderboardService")
globalLeaderboardService.Source = [=[
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local DataService = require(script.Parent.DataService)
local StateService = require(script.Parent.StateService)

local GlobalLeaderboardService = {}
local boardGui

local function getOrCreate(parent, className, name)
    local object = parent:FindFirstChild(name)
    if object and object.ClassName ~= className then object:Destroy(); object = nil end
    if not object then object = Instance.new(className); object.Name = name; object.Parent = parent end
    return object
end

local function playerName(userId)
    local online = Players:GetPlayerByUserId(userId)
    if online then return online.DisplayName end
    local ok, name = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
    return ok and name or ("User " .. tostring(userId))
end

local function mergeOnlineRows(metric, rows)
    local seen = {}
    for _, row in ipairs(rows) do seen[row.UserId] = true end
    for player, state in pairs(StateService.States) do
        if not seen[player.UserId] then
            table.insert(rows, { UserId = player.UserId, Value = metric == "CakePoints" and (state.CakePoints or 0) or (state.TotalRolls or state.WheelPoints or 0) })
        end
    end
    table.sort(rows, function(a, b) return (a.Value or 0) > (b.Value or 0) end)
    while #rows > 10 do table.remove(rows) end
    for rank, row in ipairs(rows) do row.Rank = rank end
    return rows
end

local function formatRows(title, metric)
    local rows = mergeOnlineRows(metric, DataService.GetGlobalLeaderboard(metric, 10))
    local lines = { title }
    if #rows == 0 then
        table.insert(lines, "No scores yet")
    end
    for _, row in ipairs(rows) do
        table.insert(lines, string.format("#%d  %s  %s", row.Rank, playerName(row.UserId), tostring(row.Value or 0)))
    end
    return table.concat(lines, "\n")
end

function GlobalLeaderboardService.BuildBoard()
    local map = Workspace:FindFirstChild("Map") or Workspace
    local board = getOrCreate(map, "Part", "GlobalLeaderboardBoard")
    board.Anchored = true
    board.CanCollide = true
    board.Size = Vector3.new(28, 16, 1)
    board.CFrame = CFrame.new(0, 10, -38)
    board.Color = Color3.fromRGB(35, 27, 22)
    board.Material = Enum.Material.WoodPlanks

    boardGui = getOrCreate(board, "SurfaceGui", "GlobalLeaderboardSurface")
    boardGui.Face = Enum.NormalId.Front
    boardGui.AlwaysOnTop = false
    boardGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    boardGui.PixelsPerStud = 42

    local frame = getOrCreate(boardGui, "Frame", "LeaderboardFrame")
    frame.BackgroundColor3 = Color3.fromRGB(255, 239, 196)
    frame.BackgroundTransparency = 0.05
    frame.Size = UDim2.fromScale(1, 1)

    local cake = getOrCreate(frame, "TextLabel", "CakePointsRanking")
    cake.BackgroundTransparency = 1
    cake.Font = Enum.Font.GothamBlack
    cake.TextColor3 = Color3.fromRGB(78, 45, 31)
    cake.TextScaled = true
    cake.TextXAlignment = Enum.TextXAlignment.Left
    cake.TextYAlignment = Enum.TextYAlignment.Top
    cake.Position = UDim2.fromScale(0.04, 0.08)
    cake.Size = UDim2.fromScale(0.43, 0.84)

    local spins = getOrCreate(frame, "TextLabel", "WheelSpinsRanking")
    spins.BackgroundTransparency = 1
    spins.Font = Enum.Font.GothamBlack
    spins.TextColor3 = Color3.fromRGB(78, 45, 31)
    spins.TextScaled = true
    spins.TextXAlignment = Enum.TextXAlignment.Left
    spins.TextYAlignment = Enum.TextYAlignment.Top
    spins.Position = UDim2.fromScale(0.53, 0.08)
    spins.Size = UDim2.fromScale(0.43, 0.84)
end

function GlobalLeaderboardService.Refresh()
    if not boardGui then GlobalLeaderboardService.BuildBoard() end
    local frame = boardGui:FindFirstChild("LeaderboardFrame")
    if not frame then return end
    frame.CakePointsRanking.Text = formatRows("GLOBAL CAKE POINTS", "CakePoints")
    frame.WheelSpinsRanking.Text = formatRows("GLOBAL ROLLS", "WheelSpins")
end

function GlobalLeaderboardService.Start()
    GlobalLeaderboardService.BuildBoard()
    task.spawn(function()
        while true do
            GlobalLeaderboardService.Refresh()
            task.wait(60)
        end
    end)
end

return GlobalLeaderboardService
]=]

local cakeEffectsService = getOrCreate(servicesPackage, "ModuleScript", "CakeEffectsService")
cakeEffectsService.Source = [=[
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CakeEffectsService = {}

function CakeEffectsService.PlaySoundAt(name, soundId, position, volume)
    local soundAnchor = Instance.new("Part")
    soundAnchor.Name = name .. "Anchor"
    soundAnchor.Anchored = true
    soundAnchor.CanCollide = false
    soundAnchor.Transparency = 1
    soundAnchor.Size = Vector3.new(0.2, 0.2, 0.2)
    soundAnchor.Position = position
    soundAnchor.Parent = Workspace
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or 1
    sound.RollOffMinDistance = 8
    sound.RollOffMaxDistance = 90
    sound.Parent = soundAnchor
    sound:Play()
    Debris:AddItem(soundAnchor, math.max(3, sound.TimeLength + 0.5))
end

function CakeEffectsService.PlayOutwardSmokeEffect(cake, isGrowing)
    local primary = cake.PrimaryPart
    if not primary then return end
    local scale = cake:GetScale()
    local burst = Instance.new("ParticleEmitter")
    burst.Name = isGrowing and "CakeGrowSparkles" or "CakeShrinkCrumbs"
    burst.Texture = "rbxassetid://241876023"
    burst.Color = ColorSequence.new(isGrowing and Color3.fromRGB(255, 245, 140) or Color3.fromRGB(255, 210, 170))
    burst.Lifetime = NumberRange.new(0.22, 0.42)
    burst.Rate = 0
    burst.Speed = NumberRange.new(2 * scale, 5 * scale)
    burst.SpreadAngle = Vector2.new(180, 180)
    burst.Parent = primary
    burst:Emit(18)
    Debris:AddItem(burst, 0.6)
end

function CakeEffectsService.PlayUpgradeHighlight(cake)
    local primary = cake.PrimaryPart
    if not primary then return end
    primary.AssemblyLinearVelocity += Vector3.new(0, 32, 0)
    CakeEffectsService.PlaySoundAt("CakeUpgradeSound", 81872425338792, primary.Position, 1)
    local burst = Instance.new("ParticleEmitter")
    burst.Name = "CakeUpgradeGoldSmoke"
    burst.Texture = "rbxasset://textures/particles/smoke_main.dds"
    burst.Color = ColorSequence.new(Color3.fromRGB(255, 210, 80))
    burst.Lifetime = NumberRange.new(0.35, 0.7)
    burst.Rate = 0
    burst.Speed = NumberRange.new(8, 18)
    burst.SpreadAngle = Vector2.new(180, 180)
    burst.Parent = primary
    burst:Emit(35)
    Debris:AddItem(burst, 1)
    local outline = cake:FindFirstChild("RarityOutline")
    if outline then
        local originalColor, originalTransparency = outline.OutlineColor, outline.FillTransparency
        outline.FillColor = Color3.fromRGB(255, 230, 120)
        outline.FillTransparency = 0.35
        task.delay(0.14, function()
            if outline.Parent then
                outline.OutlineColor = originalColor
                outline.FillTransparency = originalTransparency
            end
        end)
    end
end

function CakeEffectsService.CreateDynamicGroundStain(cake, runtime, visibleSeconds)
    local primary = cake.PrimaryPart
    if not primary then return end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { cake, runtime }
    local hit = Workspace:Raycast(primary.Position, Vector3.new(0, -120, 0), rayParams)
    if not hit then return end
    local stain = Instance.new("Part")
    stain.Name = "CakeGroundStain"
    stain.Anchored = true
    stain.CanCollide = false
    stain.Transparency = 1
    stain.Size = Vector3.new(4 * cake:GetScale(), 0.04, 4 * cake:GetScale())
    stain.CFrame = CFrame.new(hit.Position + hit.Normal * 0.03)
    stain.Parent = runtime
    local decal = Instance.new("Decal")
    decal.Name = "CakeStainDecal"
    decal.Face = Enum.NormalId.Top
    decal.Texture = "rbxassetid://6880896391"
    decal.Transparency = 0.15
    decal.Parent = stain
    TweenService:Create(decal, TweenInfo.new(visibleSeconds, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
    Debris:AddItem(stain, visibleSeconds + 0.25)
end

function CakeEffectsService.PlaySpawnFadeIn(cake)
    local parts = {}
    for _, part in ipairs(cake:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            part.Transparency = 1
        end
    end
    task.delay(0.2, function()
        for _, part in ipairs(parts) do
            if part.Parent then
                TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
            end
        end
    end)
end

return CakeEffectsService
]=]

-- Cake responsibilities are intentionally split: access arbitration, movement, rain scheduling,
-- and the CakeService façade can now evolve without skill scripts mutating instances directly.
local cakeAccessService = getOrCreate(servicesPackage, "ModuleScript", "CakeAccessService")
cakeAccessService.Source = [=[
-- Tracks the single player currently eating each cake.  This is server-only state: clients and
-- skills never receive a bypass, so a cake being eaten cannot be moved, damaged, or stolen.
local CakeAccessService = { EaterByCake = {}, CakeByEater = {} }

function CakeAccessService.IsAvailableTo(player, cake)
    local eater = CakeAccessService.EaterByCake[cake]
    return eater == nil or eater == player
end

function CakeAccessService.ClaimForEating(player, cake)
    if not player or not cake or not cake.Parent or not CakeAccessService.IsAvailableTo(player, cake) then
        return false
    end
    local previous = CakeAccessService.CakeByEater[player]
    if previous and previous ~= cake then
        CakeAccessService.EaterByCake[previous] = nil
    end
    CakeAccessService.EaterByCake[cake] = player
    CakeAccessService.CakeByEater[player] = cake
    return true
end

function CakeAccessService.ReleasePlayer(player)
    local cake = CakeAccessService.CakeByEater[player]
    if cake and CakeAccessService.EaterByCake[cake] == player then
        CakeAccessService.EaterByCake[cake] = nil
    end
    CakeAccessService.CakeByEater[player] = nil
end

function CakeAccessService.ReleaseCake(cake)
    local player = CakeAccessService.EaterByCake[cake]
    if player and CakeAccessService.CakeByEater[player] == cake then
        CakeAccessService.CakeByEater[player] = nil
    end
    CakeAccessService.EaterByCake[cake] = nil
end

return CakeAccessService
]=]

local cakeMovementService = getOrCreate(servicesPackage, "ModuleScript", "CakeMovementService")
cakeMovementService.Source = [=[
-- The only low-level server movement operations for cakes.  Authorization stays in CakeService.
local CakeMovementService = {}

function CakeMovementService.Apply(cake, change)
    local primary = cake and cake.PrimaryPart
    if not primary then return false end
    if change.LinearVelocity ~= nil then
        primary.AssemblyLinearVelocity = change.LinearVelocity
    end
    if change.CFrame then
        if change.LinearVelocity == nil then primary.AssemblyLinearVelocity = Vector3.zero end
        cake:PivotTo(change.CFrame)
    end
    return true
end

return CakeMovementService
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
local CakeEffectsService = require(script.Parent.CakeEffectsService)
local CakeAccessService = require(script.Parent.CakeAccessService)
local CakeMovementService = require(script.Parent.CakeMovementService)
local DailyTaskService = require(script.Parent.DailyTaskService)
local CakeModels = ReplicatedStorage:FindFirstChild("cake") or ReplicatedStorage.Models.cake

-- Public cake API used by SkillService.  Keep all cake movement/damage here so skills
-- cannot bypass rewards, animation, or cleanup rules. Cakes are world objects: any
-- nearby player can eat them, and each eat tick reselects the nearest cake in range.
local CakeService = { Owners = {}, EatingByPlayer = {}, TouchingByPlayer = {}, Access = CakeAccessService }
local Runtime = Workspace:FindFirstChild("cake") or Instance.new("Folder")
Runtime.Name, Runtime.Parent = "cake", Workspace
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
    cake:SetAttribute("MaxHealth", rarity.BaseHealth or scaledValue(cake:GetAttribute("InitialHealth"), level, initialLevel))
    cake:SetAttribute("Health", cake:GetAttribute("MaxHealth"))
    cake:SetAttribute("RarityScale", rarity.Scale or cake:GetAttribute("RarityScale") or 1)
    cake:SetAttribute("RewardCakePoints", scaledValue(cake:GetAttribute("InitialReward"), level, initialLevel))
    cake:SetAttribute("RewardWheelTickets", scaledValue(cake:GetAttribute("InitialWheelTickets"), level, initialLevel))
    local outline = cake:FindFirstChild("RarityOutline")
    if outline then outline.OutlineColor = rarity.OutlineColor end
    local primary = cake.PrimaryPart
    local trail = primary and primary:FindFirstChild("RarityMeteorTrail")
    if trail then trail.Color = ColorSequence.new(rarity.OutlineColor) end
    local label = primary and primary:FindFirstChild("CakeLabel")
    local labelText = label and label:FindFirstChild("Text")
    if labelText then labelText.TextColor3 = Color3.new(1, 1, 1) end
    CakeService.RefreshLabel(cake)
end

function CakeService.UpdateScale(cake)
    local hp = math.max(0, cake:GetAttribute("Health") or 0)
    local maxHp = math.max(1, cake:GetAttribute("MaxHealth") or 1)
    local rarityScale = cake:GetAttribute("RarityScale") or 1
    local scale = math.max(CakeConfig.MinimumCakeScale, rarityScale * math.clamp(hp / maxHp, 0.18, 1))
    local currentScale = cake:GetScale()
    local previousTarget = cake:GetAttribute("TargetScale") or currentScale
    cake:SetAttribute("TargetScale", scale)
    if math.abs(scale - currentScale) < 0.01 then
        cake:ScaleTo(scale)
        return
    end
    local token = (cake:GetAttribute("ScaleTweenToken") or 0) + 1
    cake:SetAttribute("ScaleTweenToken", token)
    if math.abs(scale - previousTarget) > 0.025 then
        CakeEffectsService.PlayOutwardSmokeEffect(cake, scale > previousTarget)
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
    if labelText then labelText.Text = string.format("[%s] %s (HP: %d/%d)", rarity.RarityText, text(rarity.NameKey), hp, maxHp) end
    CakeService.UpdateScale(cake)
end

local function playLandingEffect(cake)
    local primary = cake.PrimaryPart
    if not primary then return end
    local scale = cake:GetAttribute("RarityScale") or cake:GetScale()
    local puff = Instance.new("Part")
    puff.Name = "CakeLandingPuff"
    puff.Anchored = true
    puff.CanCollide = false
    puff.Transparency = 1
    puff.Position = primary.Position
    puff.Parent = Runtime
    local attachment = Instance.new("Attachment")
    attachment.Parent = puff
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    emitter.Color = ColorSequence.new(Color3.fromRGB(200, 180, 150))
    emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1 * scale), NumberSequenceKeypoint.new(1, 3 * scale) })
    emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
    emitter.Lifetime = NumberRange.new(0.3, 0.6)
    emitter.Speed = NumberRange.new(10 * scale, 20 * scale)
    emitter.SpreadAngle = Vector2.new(90, 0)
    emitter.Parent = attachment
    emitter:Emit(math.max(8, math.floor(25 * scale)))
    CakeEffectsService.PlaySoundAt("CakeLandingSound", 183716578, primary.Position, 1)
    Debris:AddItem(puff, 1)
end

local function disableCakeTrails(cake)
    for _, descendant in ipairs(cake:GetDescendants()) do
        if descendant:IsA("Trail") then descendant.Enabled = false end
    end
end

local function bindLandingImpact(cake)
    local primary = cake.PrimaryPart
    if not primary then return end
    local landed = false
    primary.Touched:Connect(function(hit)
        if landed or not hit.CanCollide or hit:IsDescendantOf(Runtime) then return end
        landed = true
        disableCakeTrails(cake)
        playLandingEffect(cake)
    end)
end

function CakeService.Decorate(cake, isGlow)
    local primary = cake.PrimaryPart or cake:FindFirstChildWhichIsA("BasePart", true)
    if not primary then return end
    cake.PrimaryPart = primary
    local initialLevel = math.max(1, cake:GetAttribute("InitialCakeLevel") or 1)
    local rarityKey = rarityKeyForLevel(initialLevel)
    local rarity = CakeConfig.Rarities[rarityKey] or CakeConfig.Rarities.Common
    cake:SetAttribute("IsGlow", false)
    for _, part in ipairs(cake:GetDescendants()) do if part:IsA("BasePart") then part.Anchored, part.CanCollide = false, true; part.CustomPhysicalProperties = PhysicalProperties.new(1, .7, CakeConfig.CakeBounciness) end end
    local outline = Instance.new("Highlight"); outline.Name = "RarityOutline"; outline.FillTransparency = 1; outline.OutlineColor = rarity.OutlineColor; outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; outline.Parent = cake
    local top = Instance.new("Attachment"); top.Name = "MeteorTrailTop"; top.Position = Vector3.new(0, 2.8, 0); top.Parent = primary
    local bottom = Instance.new("Attachment"); bottom.Name = "MeteorTrailBottom"; bottom.Position = Vector3.new(0, -2.8, 0); bottom.Parent = primary
    local trail = Instance.new("Trail"); trail.Name = "RarityMeteorTrail"; trail.Attachment0, trail.Attachment1 = top, bottom; trail.Color = ColorSequence.new(rarity.OutlineColor); trail.LightEmission, trail.Lifetime = .65, CakeConfig.MeteorTrailLifetime; trail.Parent = primary
    local label = Instance.new("BillboardGui"); label.Name, label.AlwaysOnTop, label.MaxDistance, label.Size, label.StudsOffset, label.Parent = "CakeLabel", true, CakeConfig.LabelMaxDistance, UDim2.new(0,300,0,62), Vector3.new(0,4.2,0), primary
    local labelText = Instance.new("TextLabel"); labelText.Name, labelText.BackgroundTransparency, labelText.Size, labelText.Font, labelText.TextScaled, labelText.TextColor3, labelText.TextStrokeTransparency, labelText.Parent = "Text", 1, UDim2.fromScale(1,1), Enum.Font.GothamBlack, true, Color3.new(1,1,1), 1, label
    local labelStroke = Instance.new("UIStroke"); labelStroke.Name, labelStroke.Color, labelStroke.LineJoinMode, labelStroke.Thickness, labelStroke.Parent = "TextStroke", Color3.fromRGB(0, 0, 0), Enum.LineJoinMode.Round, 3, labelText
    CakeService.ApplyCakeLevel(cake, initialLevel)
end
local function stopEating(player)
    CakeAccessService.ReleasePlayer(player)
    CakeService.EatingByPlayer[player] = nil
end
local function stopEatingCake(cake)
    local eatingPlayer = CakeAccessService.EaterByCake[cake]
    CakeAccessService.ReleaseCake(cake)
    if eatingPlayer then CakeService.EatingByPlayer[eatingPlayer] = nil end
    for player, target in pairs(CakeService.EatingByPlayer) do
        if target == cake then CakeService.EatingByPlayer[player] = nil end
    end
    for _, touching in pairs(CakeService.TouchingByPlayer) do touching[cake] = nil end
end

-- Public server-side eligibility check for skill authors.  A false result means another player
-- has already claimed the cake by eating it; no skill is allowed to affect that cake.
function CakeService.CanAffectCake(player, cake)
    return cake and cake.Parent and not cake:GetAttribute("Finishing") and CakeAccessService.IsAvailableTo(player, cake)
end
local function touchedCakesFor(player)
    CakeService.TouchingByPlayer[player] = CakeService.TouchingByPlayer[player] or {}
    return CakeService.TouchingByPlayer[player]
end
local function nearestTouchedCake(player)
    local root = rootOf(player)
    if not root then return nil end
    local bestCake, bestDistance
    for cake in pairs(touchedCakesFor(player)) do
        if CakeService.CanAffectCake(player, cake) and cake.PrimaryPart then
            local distance = (cake.PrimaryPart.Position - root.Position).Magnitude
            if distance <= (CakeConfig.EatRangeStuds or 9) and (not bestDistance or distance < bestDistance) then
                bestCake, bestDistance = cake, distance
            end
        end
    end
    return bestCake
end
function CakeService.Finish(player, cake)
    if not cake.Parent or cake:GetAttribute("Finishing") then
        return
    end

    cake:SetAttribute("Finishing", true)
    CakeService.Owners[cake] = nil
    stopEatingCake(cake)
    stopEating(player)

    local state = StateService.Get(player)
    if state then
        state.CakePoints += cake:GetAttribute("RewardCakePoints") or 1
        state.WheelSpins += cake:GetAttribute("RewardWheelTickets") or 1
        DailyTaskService.Record(player, "EatCakes", 1)
        StateService.UpdateLeaderstats(player); StateService.Push(player)
    end
    -- Eating is deliberately distinct from expiry: disable physics, then shrink/fade into the player.
    local startPivot, startScale, started = cake:GetPivot(), cake:GetScale(), os.clock()
    local primary = cake.PrimaryPart
    if primary then
        local root = rootOf(player)
        local soundAnchor = Instance.new("Part")
        soundAnchor.Name = "CakeShrinkSoundAnchor"
        soundAnchor.Anchored = true
        soundAnchor.CanCollide = false
        soundAnchor.Transparency = 1
        soundAnchor.Size = Vector3.new(0.2, 0.2, 0.2)
        soundAnchor.CFrame = CFrame.new((root and root.Position or primary.Position) + Vector3.new(0, 1, 0))
        soundAnchor.Parent = Workspace

        local shrinkSound = Instance.new("Sound")
        shrinkSound.Name = "CakeShrinkSound"
        shrinkSound.SoundId = "rbxassetid://135833732254676"
        shrinkSound.Volume = 1.6
        shrinkSound.RollOffMinDistance = 8
        shrinkSound.RollOffMaxDistance = 90
        shrinkSound.Parent = soundAnchor
        shrinkSound:Play()
        Debris:AddItem(soundAnchor, math.max(3, shrinkSound.TimeLength + 0.5))
    end
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
    stopEatingCake(cake)
    CakeEffectsService.CreateDynamicGroundStain(cake, Runtime, CakeConfig.StainVisibleSeconds)

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
function CakeService.ApplyServerCakeChange(player, cake, change)
    if not CakeService.CanAffectCake(player, cake) then return false, "CAKE_BEING_EATEN" end
    change = change or {}
    local damage = math.max(0, tonumber(change.Damage) or 0)
    if change.DamagePercent then
        local percentDamage = (cake:GetAttribute("Health") or 0) * (tonumber(change.DamagePercent) or 0)
        if percentDamage > 0 then damage += math.max(0.01, percentDamage) end
    end
    if damage > 0 then
        damage = math.floor(damage + 0.5)
    end
    if damage > 0 then
        local currentHealth = math.floor(math.max(0, cake:GetAttribute("Health") or 1) + 0.5)
        local hp = math.max(0, currentHealth - damage)
        cake:SetAttribute("Health", hp)
        if cake.PrimaryPart then CakeEffectsService.PlaySoundAt("CakeBiteSound", 86778542937419, cake.PrimaryPart.Position, 1) end
        CakeService.RefreshLabel(cake)
        if hp <= 0 then
            CakeService.Finish(player, cake)
            return true
        end
    end
    CakeMovementService.Apply(cake, change)
    return true
end

-- Explicit server APIs for skills that change cake coordinates or vectors.  They route through
-- the same access guard as damage and therefore cannot influence another player's active meal.
function CakeService.SetCakeVelocity(player, cake, velocity)
    return CakeService.ApplyServerCakeChange(player, cake, { LinearVelocity = velocity })
end
function CakeService.SetCakeCFrame(player, cake, cframe)
    return CakeService.ApplyServerCakeChange(player, cake, { CFrame = cframe })
end
function CakeService.DamageCake(player, cake, amount)
    return CakeService.ApplyServerCakeChange(player, cake, { Damage = amount })
end
function CakeService.GetCakes(player, maximum, minimumDistance, maximumDistance)
    local root, results = rootOf(player), {}
    if not root then return results end
    for cake in pairs(CakeService.Owners) do
        if CakeService.CanAffectCake(player, cake) and cake.PrimaryPart then
            local distance = (cake.PrimaryPart.Position - root.Position).Magnitude
            if (not minimumDistance or distance >= minimumDistance) and (not maximumDistance or distance <= maximumDistance) then table.insert(results, { Cake = cake, Distance = distance }) end
        end
    end
    table.sort(results, function(a,b) return a.Distance < b.Distance end)
    while #results > (maximum or #results) do table.remove(results) end
    return results
end
function CakeService.MoveNearPlayer(player, cake, distance, travelSeconds)
    local root = rootOf(player)
    if not root or not CakeService.CanAffectCake(player, cake) or not cake.PrimaryPart then return false end
    local angle = math.random() * math.pi * 2
    local destination = CFrame.new(root.Position + Vector3.new(math.cos(angle) * distance, 2, math.sin(angle) * distance))
    CakeService.ApplyServerCakeChange(player, cake, { LinearVelocity = Vector3.zero })
    if travelSeconds and travelSeconds > 0 then
        TweenService:Create(cake.PrimaryPart, TweenInfo.new(travelSeconds, Enum.EasingStyle.Linear), { CFrame = destination }):Play()
    else
        CakeService.ApplyServerCakeChange(player, cake, { CFrame = destination })
    end
    return destination
end
function CakeService.BeginAutoEat(player)
    if CakeService.EatingByPlayer[player] then return end
    CakeService.EatingByPlayer[player] = true
    task.spawn(function()
        while player.Parent do
            local cake = nearestTouchedCake(player)
            if not cake then break end
            -- Claim before the first bite.  Concurrent touch events can only give one player
            -- this cake; all other eaters and skills see it as unavailable immediately.
            if not CakeAccessService.ClaimForEating(player, cake) then
                continue
            end
            CakeService.EatingByPlayer[player] = cake
            if CakeService.CanAffectCake(player, cake) then
                CakeService.DamageCake(player, cake, CakeConfig.BaseEatDamagePerSecond + StateService.EffectiveStat(player, "EatSpeed"))
            end
            task.wait(CakeConfig.EatTickSeconds)
        end
        stopEating(player)
    end)
end
function CakeService.HookTouches(cake)
    for _, part in ipairs(cake:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                local toucher = Players:GetPlayerFromCharacter(hit.Parent)
                if toucher then
                    touchedCakesFor(toucher)[cake] = true
                    CakeService.BeginAutoEat(toucher)
                end
            end)
            part.TouchEnded:Connect(function(hit)
                local toucher = Players:GetPlayerFromCharacter(hit.Parent)
                if toucher and CakeService.TouchingByPlayer[toucher] then
                    CakeService.TouchingByPlayer[toucher][cake] = nil
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

function CakeService.SplitCake(player, sourceCake)
    if not player or not sourceCake or not sourceCake.Parent or not sourceCake.PrimaryPart then return end
    local clone = sourceCake:Clone()
    clone.Name = sourceCake.Name .. "_Split"
    clone:SetAttribute("Finishing", nil)
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Highlight") or descendant:IsA("BillboardGui") or descendant:IsA("Trail") or descendant.Name == "MeteorTrailTop" or descendant.Name == "MeteorTrailBottom" then
            descendant:Destroy()
        end
    end
    clone.Parent = Runtime
    clone:PivotTo(sourceCake:GetPivot() * CFrame.new(math.random(-6, 6), 4, math.random(-6, 6)))
    CakeService.Decorate(clone, clone:GetAttribute("IsGlow"))
    CakeService.Owners[clone] = player
    CakeService.ApplyServerCakeChange(player, clone, { LinearVelocity = Vector3.new(math.random(-8, 8), 18, math.random(-8, 8)) })
    CakeService.HookTouches(clone)
    bindLandingImpact(clone)
    CakeEffectsService.PlaySpawnFadeIn(clone)
    task.delay(CakeConfig.CakeLifetimeSeconds, function()
        if clone.Parent and CakeService.Owners[clone] then
            CakeService.Expire(clone)
        end
    end)
    return clone
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

    local cake = template:Clone()
    local glow = false
    cake.Name = "Cake_" .. template.Name
    cake.Parent = Runtime
    cake:PivotTo(CFrame.new(spawnPositionNear(root)))

    CakeService.Decorate(cake, glow)
    CakeEffectsService.PlaySpawnFadeIn(cake)
    CakeService.Owners[cake] = player
    CakeService.ApplyServerCakeChange(player, cake, { LinearVelocity = Vector3.new(0, -CakeConfig.MeteorFallSpeed, 0) })
    CakeService.HookTouches(cake)
    bindLandingImpact(cake)

    task.spawn(function()
        local decisions = math.floor(CakeConfig.UpgradeDecisionWindowSeconds / CakeConfig.UpgradeDecisionSeconds)
        for _ = 1, decisions do
            task.wait(CakeConfig.UpgradeDecisionSeconds)
            if not cake.Parent or cake:GetAttribute("Finishing") then
                return
            end
            local level = cake:GetAttribute("CakeLevel") or cake:GetAttribute("InitialCakeLevel") or 1
            local luckyBonus = StateService.EffectiveStat(player, "Lucky")
            local upgradeChance = math.clamp((cake:GetAttribute("InitialUpgradeChance") or 0) + luckyBonus, 0, 0.95)
            if level >= #CakeConfig.RarityOrder or math.random() >= upgradeChance then
                return
            end
            CakeService.ApplyCakeLevel(cake, level + 1)
            CakeEffectsService.PlayUpgradeHighlight(cake)
            local rarity = CakeConfig.Rarities[cake:GetAttribute("RarityKey")]
            if rarity and rarity.SplitChance and math.random() < rarity.SplitChance then
                CakeService.SplitCake(player, cake)
            end
        end
    end)

    task.delay(CakeConfig.CakeLifetimeSeconds, function()
        if cake.Parent and CakeService.Owners[cake] then
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
            local spawnHaste = StateService.EffectiveStat(player, "CakeSpawnHaste")
            task.wait(math.max(0.2, CakeConfig.SpawnInterval - spawnHaste))
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
    stopEating(player)
    CakeService.TouchingByPlayer[player] = nil
end

return CakeService
]=]

local cakeSpawnService = getOrCreate(servicesPackage, "ModuleScript", "CakeSpawnService")
cakeSpawnService.Source = [=[
-- Generation boundary.  Rain schedulers call this API instead of knowing how a cake is cloned,
-- decorated, upgraded, split, registered, or expired.
local CakeService = require(script.Parent.CakeService)
local CakeSpawnService = {}

function CakeSpawnService.SpawnNear(player)
    return CakeService.SpawnNear(player)
end

function CakeSpawnService.Split(player, sourceCake)
    return CakeService.SplitCake(player, sourceCake)
end

return CakeSpawnService
]=]

local cakeRainService = getOrCreate(servicesPackage, "ModuleScript", "CakeRainService")
cakeRainService.Source = [=[
-- Owns the per-player cake-rain schedule only; creation stays behind CakeSpawnService.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CakeConfig = require(ReplicatedStorage.Configs.CakeConfig)
local StateService = require(script.Parent.StateService)
local CakeSpawnService = require(script.Parent.CakeSpawnService)
local CakeRainService = {}

function CakeRainService.StartPlayer(player)
    local function burst()
        task.spawn(function()
            for _ = 1, CakeConfig.InitialBurstCount do
                if not player.Parent then return end
                CakeSpawnService.SpawnNear(player)
                task.wait(.18)
            end
        end)
    end
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 10)
        task.wait(.35)
        burst()
    end)
    if player.Character then burst() end
    task.spawn(function()
        while player.Parent do
            local character = player.Character or player.CharacterAdded:Wait()
            character:WaitForChild("HumanoidRootPart", 10)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 + StateService.EffectiveStat(player, "PlayerSpeed") end
            local ok, err = pcall(CakeSpawnService.SpawnNear, player)
            if not ok then warn("Cake Rain RNG: spawn failed; rain will continue", err) end
            StateService.Push(player)
            task.wait(math.max(.2, CakeConfig.SpawnInterval - StateService.EffectiveStat(player, "CakeSpawnHaste")))
        end
    end)
end
return CakeRainService
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
    resolved.BaseDuration = (resolved.BaseDuration or resolved.Duration or 60) * 0.5
    return StateService.AddBuff(player, key, resolved)
end
return RewardTemplate
]=]

local rewardDefinitions = {
    EatSpeed = { BuffType = "EatSpeed", Overrides = "{ Type = \"Stat\", Stat = \"EatSpeed\" }", ByRarity = "{ Common = { Value = 1, Duration = 60, MaxAbilityLevel = 3 }, Rare = { Value = 2, Duration = 70, MaxAbilityLevel = 3 }, Epic = { Value = 3, Duration = 80, MaxAbilityLevel = 3 }, Legendary = { Value = 5, Duration = 90, MaxAbilityLevel = 3 }, Mythic = { Value = 8, Duration = 105, MaxAbilityLevel = 3 } }" },
    AutoRoll = { BuffType = "AutoRoll", ByRarity = "{ Common = { Interval = 1.0, MultiRolls = 1, Duration = 180, MaxAbilityLevel = 3 }, Rare = { Interval = 0.9, MultiRolls = 2, Duration = 180, MaxAbilityLevel = 3 }, Epic = { Interval = 0.8, MultiRolls = 3, Duration = 190, MaxAbilityLevel = 3 }, Legendary = { Interval = 0.7, MultiRolls = 4, Duration = 200, MaxAbilityLevel = 3 }, Mythic = { Interval = 0.6, MultiRolls = 5, Duration = 210, MaxAbilityLevel = 3 } }" },
    WheelHaste = { BuffType = "WheelHaste", ByRarity = "{ Common = { Value = 0.10, Duration = 120, MaxAbilityLevel = 3 }, Rare = { Value = 0.22, Duration = 120, MaxAbilityLevel = 3 }, Epic = { Value = 0.36, Duration = 130, MaxAbilityLevel = 3 }, Legendary = { Value = 0.52, Duration = 140, MaxAbilityLevel = 3 }, Mythic = { Value = 0.75, Duration = 150, MaxAbilityLevel = 3 } }" },
    PlayerSpeed = { BuffType = "PlayerSpeed", Overrides = "{ Type = \"Stat\", Stat = \"PlayerSpeed\" }", ByRarity = "{ Common = { Value = 2, Duration = 90, MaxAbilityLevel = 3 }, Rare = { Value = 4, Duration = 100, MaxAbilityLevel = 3 }, Epic = { Value = 6, Duration = 110, MaxAbilityLevel = 3 }, Legendary = { Value = 8, Duration = 120, MaxAbilityLevel = 3 }, Mythic = { Value = 12, Duration = 140, MaxAbilityLevel = 3 } }" },
    Lucky = { BuffType = "Lucky", Overrides = "{ Type = \"Stat\", Stat = \"Lucky\" }", ByRarity = "{ Common = { Value = 0.02, Duration = 90, MaxAbilityLevel = 3 }, Rare = { Value = 0.035, Duration = 100, MaxAbilityLevel = 3 }, Epic = { Value = 0.05, Duration = 110, MaxAbilityLevel = 3 }, Legendary = { Value = 0.075, Duration = 120, MaxAbilityLevel = 3 }, Mythic = { Value = 0.10, Duration = 140, MaxAbilityLevel = 3 } }" },
    CakeSpawnHaste = { BuffType = "CakeSpawnHaste", Overrides = "{ Type = \"Stat\", Stat = \"CakeSpawnHaste\" }", ByRarity = "{ Common = { Value = 0.1, Duration = 90, MaxAbilityLevel = 3 }, Rare = { Value = 0.2, Duration = 100, MaxAbilityLevel = 3 }, Epic = { Value = 0.3, Duration = 110, MaxAbilityLevel = 3 }, Legendary = { Value = 0.4, Duration = 120, MaxAbilityLevel = 3 }, Mythic = { Value = 0.5, Duration = 140, MaxAbilityLevel = 3 } }" },
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
    local duration = (WheelConfig.WheelLevelDurationByRarity[reward.Rarity] or 60) * 0.5
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
        ApplyCakeChange = function(_, cake, change) return CakeService.ApplyServerCakeChange(player, cake, change) end,
        Damage = function(_, cake, amount) return CakeService.ApplyServerCakeChange(player, cake, { Damage = amount }) end,
        DamagePercent = function(_, cake, percent) return CakeService.ApplyServerCakeChange(player, cake, { DamagePercent = percent }) end,
        MoveNear = function(_, cake, distance, seconds) return CakeService.MoveNearPlayer(player, cake, distance, seconds) end,
        SetMomentum = function(_, cake, velocity) return CakeService.SetCakeVelocity(player, cake, velocity) end,
        SetPosition = function(_, cake, cframe) return CakeService.SetCakeCFrame(player, cake, cframe) end,
        CanAffectCake = function(_, cake) return CakeService.CanAffectCake(player, cake) end,
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
local ByRarity = { Common = { Duration = 45, TriggerInterval = 4, Level = 1, Parameters = { Count = 1, Distance = 2 } }, Rare = { Duration = 50, TriggerInterval = 3.5, Level = 2, Parameters = { Count = 1, Distance = 2 } }, Epic = { Duration = 55, TriggerInterval = 3, Level = 3, Parameters = { Count = 2, Distance = 2 } }, Legendary = { Duration = 60, TriggerInterval = 2.5, Level = 4, Parameters = { Count = 2, Distance = 2 } }, Mythic = { Duration = 70, TriggerInterval = 2, Level = 5, Parameters = { Count = 3, Distance = 2 } } }
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
local ByRarity = { Common = { Duration = 50, TriggerInterval = 4, Level = 1, Parameters = { MinimumDistance = 14, Distance = 4, DamagePercentPerSecond = .02 } }, Rare = { Duration = 55, TriggerInterval = 3.75, Level = 2, Parameters = { MinimumDistance = 13, Distance = 4, DamagePercentPerSecond = .022 } }, Epic = { Duration = 60, TriggerInterval = 3.5, Level = 3, Parameters = { MinimumDistance = 12, Distance = 4, DamagePercentPerSecond = .025 } }, Legendary = { Duration = 65, TriggerInterval = 3.25, Level = 4, Parameters = { MinimumDistance = 11, Distance = 4, DamagePercentPerSecond = .028 } }, Mythic = { Duration = 75, TriggerInterval = 3, Level = 5, Parameters = { MinimumDistance = 10, Distance = 4, DamagePercentPerSecond = .032 } } }
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
local ByRarity = { Common = { Duration = 60, TriggerInterval = 1, Level = 1, Parameters = { Distance = 3, DamagePercentPerSecond = .01 } }, Rare = { Duration = 65, TriggerInterval = .95, Level = 2, Parameters = { Distance = 3, DamagePercentPerSecond = .011 } }, Epic = { Duration = 70, TriggerInterval = .9, Level = 3, Parameters = { Distance = 3, DamagePercentPerSecond = .012 } }, Legendary = { Duration = 75, TriggerInterval = .85, Level = 4, Parameters = { Distance = 3, DamagePercentPerSecond = .013 } }, Mythic = { Duration = 85, TriggerInterval = .8, Level = 5, Parameters = { Distance = 3, DamagePercentPerSecond = .015 } } }
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
local DailyTaskService = require(script.Parent.DailyTaskService)
local CodeService = require(script.Parent.CodeService)
local RewardService = require(script.Parent.RewardService)
local ServerGuardService = require(script.Parent.ServerGuardService)

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
local function unlockedCards(state)
    local entries = {}
    for key, card in pairs(CardConfig.Cards) do
        if StateService.IsSkillEquipped(state, key) then entries[key] = card end
    end
    return entries
end
local function randomRarity(player, state, capOverride)
    local cap, total = math.min(maxRarityPriority(player, state), capOverride or 999), 0
    local luckyBonus = StateService.EffectiveStat(player, "Lucky")
    local minimumPriority = (luckyBonus > 0 and math.random() < luckyBonus) and math.min(cap, 2) or 1
    local weights = WheelConfig.BaseRarityWeights
    for rarity, weight in pairs(weights) do local priority = WheelConfig.RarityPriority[rarity] or 1 if priority >= minimumPriority and priority <= cap then total += weight end end
    local roll, cursor = math.random() * total, 0
    for _, rarity in ipairs(WheelConfig.RarityOrder) do
        local weight = weights[rarity] or 0
        local priority = WheelConfig.RarityPriority[rarity] or 1
        if priority >= minimumPriority and priority <= cap then
            cursor += weight
            if roll <= cursor then return rarity end
        end
    end
    return "Common"
end
local function buildSlots(player, state)
    local pool, slots, used, count = {}, {}, {}, 0
    for key, reward in pairs(unlockedRewards(state)) do
        pool["Reward_" .. key] = { Key = key, Kind = "Reward", Weight = reward.Weight, Source = reward }
        count += 1
    end
    for key, card in pairs(unlockedCards(state)) do
        pool["Card_" .. key] = { Key = key, Kind = "Card", Weight = card.Weight, Source = card }
        count += 1
    end
    local attempts = 0
    while #slots < WheelConfig.DisplayedSlots and attempts < 120 do
        attempts += 1
        local poolKey, entry = weightedPick(pool)
        if entry and (count < WheelConfig.DisplayedSlots or not used[poolKey]) then
            used[poolKey] = true
            local abilityKey = entry.Kind == "Card" and (entry.Source.AbilityKey or entry.Key) or entry.Key
            local _, abilityCap = StateService.RarityCapForAbility(player, abilityKey)
            local rarity = randomRarity(player, state, WheelConfig.RarityPriority[abilityCap])
            local color = entry.Kind == "Card" and Color3.fromRGB(190, 195, 205) or WheelConfig.RarityColors[rarity]
            table.insert(slots, { Key = entry.Key, Kind = entry.Kind, Name = text(entry.Source.NameKey), Rarity = rarity, Color = color, Icon = entry.Source.Icon or "" })
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
        if not ServerGuardService.Allow(player, "RequestWheelSpin", 12, 2) then return { Ok = false, Error = "RATE_LIMIT" } end
        local state = StateService.Get(player)
        if not state then return { Ok = false, Error = "NO_STATE" } end
        if action == "Claim" then
            local pending = state.PendingWheelSpin
            if not pending or #pending == 0 then return { Ok = false, Error = "NO_PENDING_SPIN" } end
            state.PendingWheelSpin = nil
            local claimed = {}
            for _, spin in ipairs(pending) do
                local picked = spin.Picked
                local stack
                if picked.Kind == "Card" then
                    local card = table.clone(CardConfig.Cards[picked.Key])
                    card.Rarity = picked.Rarity
                    stack = SkillService.Activate(player, picked.Key, card)
                else
                    local reward = table.clone(WheelConfig.Rewards[picked.Key])
                    reward.Rarity = picked.Rarity
                    stack = RewardService.Activate(player, picked.Key, reward)
                end
                table.insert(claimed, { Picked = picked, Stacks = stack and stack.Stacks or 1 })
                state.LastWheelReward = { Key = picked.Key, Name = picked.Name, Rarity = picked.Rarity, Kind = picked.Kind, Stacks = stack and stack.Stacks or 1, EffectText = stack and stack.EffectText, ShownUntil = os.clock() + 3 }
            end
            StateService.UpdateLeaderstats(player)
            StateService.Push(player)
            return { Ok = true, Claimed = claimed }
        end
        local count = math.clamp(math.floor(tonumber(requestedCount) or 1), 1, 6)
        count = math.min(count, state.WheelSpins)
        if count <= 0 or state.PendingWheelSpin then return { Ok = false, Error = "NO_SPINS" } end
        local pending = {}
        for _ = 1, count do
            state.WheelSpins -= 1
            state.TotalRolls = (state.TotalRolls or 0) + 1
            state.WheelPoints += 1
            local slots = buildSlots(player, state)
            if #slots == 0 then break end
            local pickedIndex = math.random(1, #slots)
            local picked = slots[pickedIndex]
            table.insert(pending, { Slots = slots, Picked = picked, PickedIndex = pickedIndex })
        end
        if #pending == 0 then return { Ok = false, Error = "EMPTY_POOL" } end
        DailyTaskService.Record(player, "RollWheel", #pending)
        state.PendingWheelSpin = pending
        StateService.UpdateLeaderstats(player)
        StateService.Push(player)
        return { Ok = true, Spins = pending }
    end

    Events.RequestClaimDailyTask.OnServerInvoke = function(player, taskId)
        if not ServerGuardService.Allow(player, "RequestClaimDailyTask", 8, 5) then return { Ok = false, Error = "RATE_LIMIT" } end
        local ok, result = DailyTaskService.Claim(player, tostring(taskId))
        return { Ok = ok, Reward = ok and result or nil, Error = ok and nil or result }
    end
    Events.RequestRedeemCode.OnServerInvoke = function(player, code)
        if not ServerGuardService.Allow(player, "RequestRedeemCode", 6, 10) then return { Ok = false, Error = "RATE_LIMIT" } end
        local ok, result = CodeService.Redeem(player, code)
        return { Ok = ok, Reward = ok and result or nil, Error = ok and nil or result }
    end

    Events.RequestCardDraw.OnServerInvoke = function(player)
        if not ServerGuardService.Allow(player, "RequestCardDraw", 4, 5) then return { Ok = false, Error = "RATE_LIMIT" } end
        return { Ok = false, Error = "SKILLS_USE_WHEEL" }
    end

    Events.RequestShopPurchase.OnServerInvoke = function(player, itemId)
        if not ServerGuardService.Allow(player, "RequestShopPurchase", 8, 5) then return { Ok = false, Error = "RATE_LIMIT" } end
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
    Events.RequestEquipSkill.OnServerInvoke = function(player, action, keyA, keyB)
        if not ServerGuardService.Allow(player, "RequestEquipSkill", 12, 5) then return { Ok = false, Error = "RATE_LIMIT" } end
        local ok, err = StateService.EquipSkill(player, tostring(action), keyA and tostring(keyA) or nil, keyB and tostring(keyB) or nil)
        if not ok then return { Ok = false, Error = err } end
        StateService.Push(player)
        return { Ok = true }
    end

    Events.RequestAbilityUpgrade.OnServerInvoke = function(player, abilityKey)
        if not ServerGuardService.Allow(player, "RequestAbilityUpgrade", 8, 5) then return { Ok = false, Error = "RATE_LIMIT" } end
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
local CakeRainService = require(script.Parent.Services.CakeRainService)
local WheelService = require(script.Parent.Services.WheelService)
local SkillService = require(script.Parent.Services.SkillService)
local GlobalLeaderboardService = require(script.Parent.Services.GlobalLeaderboardService)
local ServerGuardService = require(script.Parent.Services.ServerGuardService)

WheelService.Start()
GlobalLeaderboardService.Start()

local function setupPlayer(player)
    StateService.Create(player, DataService.Load(player))
    SkillService.ResumePlayer(player)
    CakeRainService.StartPlayer(player)
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
    ServerGuardService.ClearPlayer(player)
    StateService.Remove(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService.Save(player, StateService.Serialize(player))
    end
end)
]=]

local clientPackage = getOrCreate(ReplicatedStorage, "Folder", "ClientModules")
local clientUIService = getOrCreate(clientPackage, "ModuleScript", "ClientUIService")
clientUIService.Source = [=[
-- LocalScript UI bootstrap is isolated here so game state, wheel logic, and bag drag/drop remain
-- independently editable.  This module owns only responsive layout and card-button feedback.
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ClientUIService = {}

local function shadowFor(target)
    return target.Parent and target.Parent:FindFirstChild(target.Name .. "Shadow")
end

local function syncShadow(target, offset)
    local shadow = shadowFor(target)
    if not shadow then return end
    shadow.Visible = target.Visible
    shadow.AnchorPoint = target.AnchorPoint
    shadow.Size = target.Size
    shadow.Position = target.Position + UDim2.new(0, offset or 6, 0, offset or 6)
end

local function bindButton(button)
    local shadow = shadowFor(button)
    if not shadow then return end
    local base, baseShadow = button.Position, shadow.Position
    local function tween(position, shadowPosition)
        TweenService:Create(button, TweenInfo.new(.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = position }):Play()
        TweenService:Create(shadow, TweenInfo.new(.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = shadowPosition }):Play()
    end
    button.MouseEnter:Connect(function() tween(base + UDim2.new(0, -2, 0, -2), baseShadow + UDim2.new(0, 2, 0, 2)) end)
    button.MouseLeave:Connect(function() tween(base, baseShadow) end)
    button.MouseButton1Down:Connect(function() tween(base + UDim2.new(0, 3, 0, 3), baseShadow + UDim2.new(0, 3, 0, 3)) end)
    button.MouseButton1Up:Connect(function() tween(base, baseShadow) end)
end

function ClientUIService.Initialize(gui, refs)
    local function updateResponsiveScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport, inset = camera.ViewportSize, GuiService:GetGuiInset()
        gui.ResponsiveScale.Scale = math.clamp(math.min(viewport.X / 980, viewport.Y / 620), .78, 1)
        refs.Stats.Position = UDim2.new(0, 18 + inset.X, 0, 18 + inset.Y)
        refs.ShopButton.Position = UDim2.new(0, 18 + inset.X, 0, 148 + inset.Y)
        refs.BagButton.Position = UDim2.new(0, 86 + inset.X, 0, 148 + inset.Y)
        if viewport.X < 760 then
            refs.ShopHub.Size, refs.ShopHub.Position = UDim2.new(.92, 0, 0, 360), UDim2.new(.04, 0, .5, -180)
            refs.BagPanel.Size, refs.BagPanel.Position = UDim2.new(.92, 0, 0, 360), UDim2.new(.04, 0, .5, -180)
        else
            refs.ShopHub.Size, refs.ShopHub.Position = UDim2.new(0, 700, 0, 430), UDim2.new(.5, -350, .5, -215)
            refs.BagPanel.Size, refs.BagPanel.Position = UDim2.new(0, 700, 0, 430), UDim2.new(.5, -350, .5, -215)
        end
        for _, panel in ipairs(refs.Panels) do syncShadow(panel, 9) end
        for _, button in ipairs(refs.Buttons) do syncShadow(button, 4) end
    end
    updateResponsiveScale()
    for _, panel in ipairs(refs.Panels) do
        syncShadow(panel, 9)
        local restPosition = panel.Position
        panel:GetPropertyChangedSignal("Visible"):Connect(function()
            if not panel.Visible then syncShadow(panel, 9); return end
            local shadow = shadowFor(panel)
            panel.Position = restPosition + UDim2.new(0, 0, 0, 24)
            syncShadow(panel, 9)
            TweenService:Create(panel, TweenInfo.new(.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = restPosition }):Play()
            if shadow then
                TweenService:Create(shadow, TweenInfo.new(.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = restPosition + UDim2.new(0, 9, 0, 9) }):Play()
            end
        end)
    end
    for _, button in ipairs(refs.Buttons) do bindButton(button) end
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant.Name == "PanelGrid" and descendant:IsA("ImageLabel") then
            TweenService:Create(descendant, TweenInfo.new(12, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { ImageRectOffset = Vector2.new(28, 28) }):Play()
        end
    end
    if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale) end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateResponsiveScale)
end
return ClientUIService
]=]

local clientSoundService = getOrCreate(clientPackage, "ModuleScript", "ClientSoundService")
clientSoundService.Source = [=[
-- Keeps client audio lifecycle out of the gameplay LocalScript.
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local ClientSoundService = {}

function ClientSoundService.Create(sounds)
    local folder = Instance.new("Folder")
    folder.Name = "CakeRainSounds"
    folder.Parent = SoundService
    local volumes = { Button = 1.8, Interact = 1.6, WheelTick = .5, CakeShrink = 1.6 }
    local templates = {}
    for key, soundId in pairs(sounds or {}) do
        local sound = Instance.new("Sound")
        sound.Name, sound.SoundId, sound.Volume, sound.Parent = key .. "Template", soundId, volumes[key] or 1, folder
        templates[key] = sound
    end
    task.spawn(function()
        local preload = {}
        for _, sound in pairs(templates) do table.insert(preload, sound) end
        pcall(function() ContentProvider:PreloadAsync(preload) end)
    end)
    return function(key, volume)
        local template = templates[key]
        if not template then return end
        local sound = template:Clone()
        sound.Name, sound.Volume, sound.Parent = key .. "Sound", volume or template.Volume, folder
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
        task.delay(4, function() if sound.Parent then sound:Destroy() end end)
    end
end
return ClientSoundService
]=]

local clientScript = getOrCreate(StarterPlayer.StarterPlayerScripts, "LocalScript", "CakeRainRNGClient")
clientScript.Source = [=[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Configs = ReplicatedStorage:WaitForChild("Configs")
local RequestWheelSpin = Events:WaitForChild("RequestWheelSpin")
local RequestShopPurchase = Events:WaitForChild("RequestShopPurchase")
local RequestAbilityUpgrade = Events:WaitForChild("RequestAbilityUpgrade")
local RequestEquipSkill = Events:WaitForChild("RequestEquipSkill")
local RequestClaimDailyTask = Events:WaitForChild("RequestClaimDailyTask")
local RequestRedeemCode = Events:WaitForChild("RequestRedeemCode")
local UpdateClientState = Events:WaitForChild("UpdateClientState")
local LocalizationConfig = require(Configs:WaitForChild("LocalizationConfig"))
local ShopConfig = require(Configs:WaitForChild("ShopConfig"))
local WheelConfig = require(Configs:WaitForChild("WheelConfig"))
local SkillConfig = require(Configs:WaitForChild("SkillConfig"))
local UIConfig = require(Configs:WaitForChild("UIConfig"))
local L = LocalizationConfig["en-us"]

local gui = player:WaitForChild("PlayerGui"):WaitForChild("CakeRainRNGHUD")
local stats = gui:WaitForChild("StatsFrame")
local wheel = gui:WaitForChild("WheelPanel")
local disc = wheel:WaitForChild("WheelDisc")
local spinButton = wheel:WaitForChild("SpinButton")
local autoRollToggle = wheel:WaitForChild("AutoRollToggle")
local buffFrame = gui:WaitForChild("EffectBar")
local tooltip = buffFrame:WaitForChild("Tooltip")
local currentDrawLabel = gui:WaitForChild("CurrentDrawLabel")
local shopButton = gui:WaitForChild("ShopButton")
local bagButton = gui:WaitForChild("BagButton")
local bagPanel = gui:WaitForChild("InventoryBag")
local closeBag = bagPanel:WaitForChild("CloseButton")
local shopHub = gui:WaitForChild("ShopHub")
local closeShop = shopHub:WaitForChild("CloseButton")
local taskButton = gui:WaitForChild("TaskButton")
local taskPanel = gui:WaitForChild("DailyTaskPanel")
local closeTasks = taskPanel:WaitForChild("CloseButton")
local codeButton = gui:WaitForChild("CodeButton")
local codePanel = gui:WaitForChild("CodePanel")
local closeCode = codePanel:WaitForChild("CloseButton")

local ClientUIService = require(ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("ClientUIService"))
ClientUIService.Initialize(gui, {
    Stats = stats, ShopButton = shopButton, BagButton = bagButton, ShopHub = shopHub, BagPanel = bagPanel,
    Panels = { stats, wheel, buffFrame, currentDrawLabel, shopHub, bagPanel, taskPanel, codePanel },
    Buttons = { shopButton, bagButton, taskButton, codeButton, spinButton, autoRollToggle, closeShop, closeBag, closeTasks, closeCode, codePanel.RedeemButton, bagPanel.TermTabButton, bagPanel.SkillTabButton, bagPanel.DetailPanel.UpgradeButton },
})

local state = { WheelSpins = 0, WheelPoints = 0, WheelLevel = 1, CakePoints = 0, ActiveBuffs = {}, LastWheelReward = nil, Inventory = { WheelRewards = {}, Cards = {}, EquippedSkills = {} } }
local spinning = false
local autoRollEnabled = false
local autoRollThread = nil
local wheelRewardGeneration = 0

local ClientSoundService = require(ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("ClientSoundService"))
local playSound = ClientSoundService.Create(UIConfig.Sounds)


local function buttonLabel(item)
    local name = L[item.NameKey] or item.NameKey
    return string.format("%s\n%s %d", name, item.Currency == "WheelPoints" and "Wheel Points" or "Cake Points", item.Cost)
end

local function bindShopButtons()
    local grid, template = shopHub:WaitForChild("ShopGrid"), shopHub.ShopGrid:WaitForChild("ItemTemplate")
    for _, child in ipairs(grid:GetChildren()) do
        if child:IsA("ImageButton") and child.Name ~= "ItemTemplate" then child:Destroy() end
    end
    local items = {}
    for _, item in ipairs((state.ShopItems and state.ShopItems.Normal) or {}) do table.insert(items, item) end
    for _, item in ipairs((state.ShopItems and state.ShopItems.Merchant) or {}) do table.insert(items, item) end
    if #items == 0 then
        for _, item in ipairs(ShopConfig.WheelPointShop) do table.insert(items, item) end
        for _, item in ipairs(ShopConfig.CakePointShop) do table.insert(items, item) end
    end
    for index, item in ipairs(items) do
        local button = template:Clone()
        button.Name, button.Visible, button.LayoutOrder = "Item" .. index, true, index
        button.ItemName.Text = (L[item.NameKey] or item.NameKey) .. (string.find(item.Id, "^Merchant_") and " ★" or "")
        button.Icon.Image = item.Icon or ""
        button.ItemCost.Text = string.format("%s %d", item.Currency == "WheelPoints" and "Wheel Points" or "Cake Points", item.Cost)
        button.Activated:Connect(function() playSound("Interact"); RequestShopPurchase:InvokeServer(item.Id) end)
        button.Parent = grid
    end
    task.defer(function() grid.CanvasSize = UDim2.new(0, 0, 0, grid.GridLayout.AbsoluteContentSize.Y + 16) end)
end
bindShopButtons()

local function hasAutoRoll()
    local buff = state.ActiveBuffs and state.ActiveBuffs.AutoRoll
    return buff ~= nil and (buff.Remaining or 0) > 0
end

local function refreshEffectBar()
    for _, child in ipairs(buffFrame:GetChildren()) do
        if child:IsA("ImageButton") and child.Name ~= "EffectIconTemplate" then child:Destroy() end
    end
    local template, index = buffFrame:WaitForChild("EffectIconTemplate"), 0
    for _, buff in pairs(state.ActiveBuffs or {}) do
        index += 1
        local slot = template:Clone()
        slot.Name = "EffectIcon" .. index
        slot.Visible = true
        slot.Position = UDim2.new(0, 10 + (index - 1) * 52, 0, 14)
        slot.Image = buff.Icon or ""
        slot.Outline.Color = buff.OutlineColor or Color3.fromRGB(74, 68, 64)
        slot:SetAttribute("Tooltip", string.format("%s [%s] Stacks:%s / %ss", buff.Name, buff.Rarity, tostring(buff.Stacks or 1), tostring(buff.Remaining)))
        local cooldown, cooldownText = slot.CooldownFill, slot.CooldownText
        local remaining, duration = buff.CooldownRemaining or 0, buff.CooldownDuration or 0
        cooldown.Visible = duration > 0 and remaining > 0
        cooldown.Size = UDim2.new(1, 0, duration > 0 and math.clamp(remaining / duration, 0, 1) or 0, 0)
        cooldownText.Visible = cooldown.Visible
        cooldownText.Text = cooldown.Visible and string.format("%.1f", remaining) or ""
        slot.MouseEnter:Connect(function()
            local value = slot:GetAttribute("Tooltip")
            if value and value ~= "" then
                tooltip.Text = value
                tooltip.Visible = true
            end
        end)
        slot.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
        slot.Parent = buffFrame
    end
    buffFrame.Visible = index > 0
end

local selectedAbilityKey
local bagMode = "Terms"
local dragState = nil
local MAGNET_PADDING = 18 -- extra hit-test margin around each box so a nearby drop still "snaps" in

local function showAbilityDetail(item)
    selectedAbilityKey = item.Key
    local detail = bagPanel:WaitForChild("DetailPanel")
    detail.DetailText.Text = string.format("%s\nLevel: %d\nMax draw rarity now: %s", item.Name, item.AbilityLevel or 1, item.RarityCap or "Mythic")
    detail.UpgradeButton.Visible = item.UpgradeCost ~= nil
    detail.UpgradeButton.Text = item.UpgradeCost and string.format("Upgrade - %d Cake", item.UpgradeCost) or "Max Level"
end

-- EquippedSkills is just a free-form list (no slot numbers). isEquipped only needs to know
-- whether a key is anywhere in that list.
local function isEquipped(key)
    local equipped = (state.Inventory and state.Inventory.EquippedSkills) or {}
    for _, equippedKey in ipairs(equipped) do
        if equippedKey == key then return true end
    end
    return false
end

local function getSkillBoxes()
    return bagPanel:WaitForChild("EquippedSkillSlots")
end

local function getBagList()
    return bagPanel:WaitForChild("BagList")
end

local function setBoxHighlight(box, on)
    local stroke = box and box:FindFirstChild("Highlight")
    if stroke then stroke.Transparency = on and 0 or 1 end
end

local function clearBoxHighlights()
    local boxes = getSkillBoxes()
    for boxIndex = 1, 5 do
        setBoxHighlight(boxes:FindFirstChild("SkillSlot" .. tostring(boxIndex)), false)
    end
end

local function isPositionInFrame(position, frame)
    local topLeft = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return position.X >= topLeft.X and position.X <= topLeft.X + size.X and position.Y >= topLeft.Y and position.Y <= topLeft.Y + size.Y
end

-- Magnetic hit test: expands each box's bounds by MAGNET_PADDING so the drop doesn't need pixel precision.
-- boxIndex here is purely a *display position* (1st box, 2nd box...), never a saved identity.
local function boxUnderPosition(position)
    local boxes = getSkillBoxes()
    for boxIndex = 1, 5 do
        local box = boxes:FindFirstChild("SkillSlot" .. tostring(boxIndex))
        if box then
            local topLeft = box.AbsolutePosition - Vector2.new(MAGNET_PADDING, MAGNET_PADDING)
            local size = box.AbsoluteSize + Vector2.new(MAGNET_PADDING * 2, MAGNET_PADDING * 2)
            if position.X >= topLeft.X and position.X <= topLeft.X + size.X and position.Y >= topLeft.Y and position.Y <= topLeft.Y + size.Y then
                return box, boxIndex
            end
        end
    end
    return nil, nil
end

local function endDrag(dropPosition)
    local drag = dragState
    if not drag then return end
    dragState = nil
    if drag.inputChanged then drag.inputChanged:Disconnect() end
    if drag.inputEnded then drag.inputEnded:Disconnect() end
    clearBoxHighlights()
    drag.ghost:Destroy() -- destroy right away so the icon doesn't hang mid-air during the network round trip

    local targetBoxIndex, targetKeyAtBox, droppedInBagArea = nil, nil, false
    if dropPosition then
        local _, foundIndex = boxUnderPosition(dropPosition)
        targetBoxIndex = foundIndex
        if targetBoxIndex then
            local equipped = (state.Inventory and state.Inventory.EquippedSkills) or {}
            targetKeyAtBox = equipped[targetBoxIndex]
        else
            droppedInBagArea = isPositionInFrame(dropPosition, getBagList())
        end
    end

    local action, keyA, keyB
    if drag.fromBox then
        -- Dragging a skill OFF one of the top boxes: dropping it back down onto the bag area
        -- below is how you put it back (unequip). Dropping on any box (same or different) is a
        -- no-op since order has no meaning; dropping nowhere useful just cancels.
        if droppedInBagArea then
            action, keyA = "Unequip", drag.key
        end
    else
        -- Dragging a skill UP from the bag: dropping on an empty box equips it; dropping on a
        -- box that already shows something replaces that one.
        if targetBoxIndex and targetKeyAtBox and targetKeyAtBox ~= drag.key then
            action, keyA, keyB = "Replace", drag.key, targetKeyAtBox
        elseif targetBoxIndex then
            action, keyA = "Equip", drag.key
        end
    end

    if action then
        local ok, result = pcall(function()
            return RequestEquipSkill:InvokeServer(action, keyA, keyB)
        end)
        if ok and result and result.Ok then
            playSound("Interact")
            -- BUG FIX ("ghost slot"): UpdateClientState's broadcast isn't guaranteed to arrive
            -- before InvokeServer's response does, so refreshBag() below could still render with
            -- stale data. Apply the same change locally right now so the UI is correct
            -- immediately; the later broadcast just re-confirms the same result.
            state.Inventory = state.Inventory or {}
            state.Inventory.EquippedSkills = state.Inventory.EquippedSkills or {}
            local list = state.Inventory.EquippedSkills
            local function removeLocal(key)
                for index, existingKey in ipairs(list) do
                    if existingKey == key then table.remove(list, index) break end
                end
            end
            if action == "Unequip" then
                removeLocal(keyA)
            elseif action == "Equip" then
                removeLocal(keyA)
                table.insert(list, keyA)
            elseif action == "Replace" then
                removeLocal(keyA)
                removeLocal(keyB)
                table.insert(list, keyA)
            end
        end
    end
    refreshBag()
end

-- A real drag gesture: an icon follows the cursor/finger. fromBox marks a drag that picked its
-- skill up off one of the top boxes (as opposed to the bag list below).
local function beginDrag(key, iconImage, startPosition, fromBox)
    if dragState then return end
    local ghost = Instance.new("ImageLabel")
    ghost.Name = "SkillDragGhost"
    ghost.BackgroundTransparency = 1
    ghost.Image = iconImage or ""
    ghost.Size = UDim2.new(0, 54, 0, 54)
    ghost.AnchorPoint = Vector2.new(0.5, 0.5)
    ghost.Position = UDim2.fromOffset(startPosition.X, startPosition.Y)
    ghost.ZIndex = 500
    ghost.Parent = gui

    dragState = { key = key, ghost = ghost, fromBox = fromBox }

    dragState.inputChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            ghost.Position = UDim2.fromOffset(pos.X, pos.Y)
            clearBoxHighlights()
            if fromBox then
                -- Highlight the whole bag list to show "drop here to put it back".
                local list = getBagList()
                if isPositionInFrame(pos, list) then
                    list.UIStroke_DropHint.Transparency = 0
                else
                    list.UIStroke_DropHint.Transparency = 1
                end
            else
                local box = boxUnderPosition(pos)
                setBoxHighlight(box, true)
            end
        end
    end)
    dragState.inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            getBagList().UIStroke_DropHint.Transparency = 1
            endDrag(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)
end

local function addBagTile(template, item, order)
    if not item.Owned then return end
    local tile = template:Clone()
    tile.Name = "Entry" .. tostring(order)
    tile.LayoutOrder = order
    tile.Visible = true
    tile.Image = item.Icon or ""
    tile.ItemName.Text = item.Name
    -- A skill already sitting in a top box is locked here at the bottom: it can only be moved by
    -- dragging it FROM its box, never re-dragged from this grid.
    local lockedByEquip = bagMode == "Skills" and isEquipped(item.Key)
    tile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tile.BackgroundTransparency = 0
    if lockedByEquip then tile.BackgroundColor3 = Color3.fromRGB(156, 163, 175) end
    tile.Parent = template.Parent
    tile.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        showAbilityDetail(item)
        if bagMode == "Skills" and not lockedByEquip then
            beginDrag(item.Key, item.Icon or "", Vector2.new(input.Position.X, input.Position.Y), false)
        end
    end)
end

local function refreshBag()
    local list = getBagList()
    local template = list:WaitForChild("EntryTemplate")
    for _, child in ipairs(list:GetChildren()) do if child:IsA("ImageButton") and child.Name ~= "EntryTemplate" then child:Destroy() end end
    local order = 0
    if bagMode == "Terms" then
        for _, item in ipairs((state.Inventory and state.Inventory.WheelRewards) or {}) do
            order += 1
            addBagTile(template, item, order)
        end
    else
        for _, item in ipairs((state.Inventory and state.Inventory.Cards) or {}) do
            order += 1
            addBagTile(template, item, order)
        end
    end
    bagPanel.TermTabButton.BackgroundTransparency = 0
    bagPanel.SkillTabButton.BackgroundTransparency = 0
    bagPanel.TermTabButton.BackgroundColor3 = bagMode == "Terms" and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(255, 255, 255)
    bagPanel.SkillTabButton.BackgroundColor3 = bagMode == "Skills" and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(255, 255, 255)
    local boxes = getSkillBoxes()
    boxes.Visible = bagMode == "Skills"
    local equipped = (state.Inventory and state.Inventory.EquippedSkills) or {}
    for boxIndex = 1, 5 do
        local box = boxes:FindFirstChild("SkillSlot" .. tostring(boxIndex))
        if box then
            -- No "1/2/3/4/5" labels: a filled box shows the skill's icon, an empty one shows nothing.
            local key = equipped[boxIndex]
            local card = key and SkillConfig.Cards[key]
            box.Image = card and (card.Icon or "") or ""
        end
    end
    task.defer(function() list.CanvasSize = UDim2.new(0, 0, 0, list.GridLayout.AbsoluteContentSize.Y + 16) end)
end

local refreshDailyTasks
local function refreshStats()
    stats.CakePointsLabel.Text = tostring(state.CakePoints)
    stats.WheelPointsLabel.Text = tostring(state.WheelPoints)
    stats.SpinsLabel.Text = tostring(state.WheelSpins)
    local autoAvailable = hasAutoRoll()
    if not autoAvailable then autoRollEnabled = false end
    autoRollToggle.Visible = autoAvailable
    autoRollToggle.Text = autoRollEnabled and "Auto-Roll: ON" or "Auto-Roll: OFF"
    autoRollToggle.BackgroundColor3 = autoRollEnabled and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(255, 255, 255)
    autoRollToggle.TextColor3 = Color3.fromRGB(0, 0, 0)
    wheel.Visible = state.WheelSpins > 0 or spinning or autoAvailable
    local reward = state.LastWheelReward
    currentDrawLabel.Visible = reward ~= nil
    if reward then
        if reward.EffectText then
            currentDrawLabel.Text = string.format("Draw reward: %s [%s] | %s", reward.Name, reward.Rarity, reward.EffectText)
        else
            currentDrawLabel.Text = string.format("Draw reward: %s [%s] | Stacks %d", reward.Name, reward.Rarity, reward.Stacks or 1)
        end
    end
    refreshEffectBar()
    refreshBag()
    refreshDailyTasks()
    bindShopButtons()
end

local SLOT_ITEM_HEIGHT = 100
local SLOT_WINDOW_HEIGHT = SLOT_ITEM_HEIGHT * 3

local function applyTextStyle(textObject)
    textObject.Font = Enum.Font.GothamBlack
    textObject.TextColor3 = Color3.fromRGB(0, 0, 0)
end

local function clearRuntimeSlotChildren(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if not child:IsA("UILayout") and child.Name ~= "TopShade" and child.Name ~= "BottomShade" and child.Name ~= "CenterLine" then
            child:Destroy()
        end
    end
end

local function renderSlotItem(slot, parent)
    for _, child in ipairs(parent:GetChildren()) do
        if not child:IsA("UICorner") and not child:IsA("UIStroke") then
            child:Destroy()
        end
    end
    parent.BackgroundColor3 = slot.Color or Color3.fromRGB(34, 30, 46)
    parent.BackgroundTransparency = 0
    parent.BorderSizePixel = 0
    if not parent:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = parent
    end
    if slot.Icon and slot.Icon ~= "" then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 42, 0, 42)
        icon.Position = UDim2.new(0.5, -21, 0, 8)
        icon.BackgroundTransparency = 1
        icon.Image = slot.Icon
        icon.Parent = parent
    end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 40)
    label.Position = UDim2.new(0, 5, 1, -44)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.Text = string.format("%s\n[%s]", slot.Name or "Reward", slot.Rarity or "Common")
    label.TextScaled = true
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyTextStyle(label)
    label.Parent = parent
end

local function clearSideGrid()
    local sideGrid = wheel:FindFirstChild("SideGrid")
    if not sideGrid then return end
    for _, child in ipairs(sideGrid:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function makeMiniCell(sideGrid, order)
    local cell = Instance.new("Frame")
    cell.Name = "MiniCell" .. order
    cell.LayoutOrder = order
    cell.Size = UDim2.new(0, 0, 0, 0)
    cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cell.BorderSizePixel = 0
    cell.Parent = sideGrid
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 196, 20)
    stroke.Transparency = 0.5
    stroke.Thickness = 2
    stroke.Parent = cell

    local holder = Instance.new("Frame")
    holder.Name = "Content"
    holder.Size = UDim2.fromScale(1, 1)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Parent = cell
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    TweenService:Create(cell, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 48, 0, 48),
    }):Play()

    return cell, holder, stroke
end

local function spinMiniReel(cell, holder, stroke, spinData, duration)
    local slots = spinData.Slots or {}
    local picked = spinData.Picked
    local started = os.clock()

    while #slots > 0 and os.clock() - started < duration do
        local progress = math.clamp((os.clock() - started) / duration, 0, 1)
        renderSlotItem(slots[math.random(1, #slots)], holder)
        playSound("WheelTick")
        task.wait(0.04 + (progress ^ 2) * 0.15)
    end

    if picked then
        renderSlotItem(picked, holder)
        stroke.Color = picked.Color or Color3.fromRGB(138, 154, 134)
        stroke.Thickness = 3
    end

    TweenService:Create(cell, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 54, 0, 54),
    }):Play()
    task.wait(0.15)
    TweenService:Create(cell, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 48, 0, 48),
    }):Play()
end

local function playWheelAnimation(panel, slots, pickedIndex, speedMultiplier)
    local window = panel:WaitForChild("WheelDisc")
    local strip = window:WaitForChild("SlotStrip")
    clearRuntimeSlotChildren(strip)
    local count = #slots
    if count == 0 then return end
    local repeats = 24
    local total = count * repeats
    strip.Size = UDim2.new(1, 0, 0, total * SLOT_ITEM_HEIGHT)
    for index = 1, total do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, SLOT_ITEM_HEIGHT)
        frame.Position = UDim2.new(0, 0, 0, (index - 1) * SLOT_ITEM_HEIGHT)
        frame.Parent = strip
        renderSlotItem(slots[((index - 1) % count) + 1], frame)
    end
    local startIndex = count + 1
    strip.Position = UDim2.new(0, 0, 0, SLOT_WINDOW_HEIGHT / 2 - ((startIndex - 1) * SLOT_ITEM_HEIGHT + SLOT_ITEM_HEIGHT / 2))
    local targetIndex = startIndex + count * 4 + ((pickedIndex or 1) - 1)
    local targetY = SLOT_WINDOW_HEIGHT / 2 - ((targetIndex - 1) * SLOT_ITEM_HEIGHT + SLOT_ITEM_HEIGHT / 2)
    local duration = 2.4 / math.max(0.35, speedMultiplier or 1)
    local tween = TweenService:Create(strip, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, targetY) })
    local lastCenteredIndex = nil
    local tickConnection
    local function centeredSlotIndex()
        local centerContentY = SLOT_WINDOW_HEIGHT / 2 - strip.Position.Y.Offset
        return math.floor(centerContentY / SLOT_ITEM_HEIGHT) + 1
    end
    tickConnection = RunService.RenderStepped:Connect(function()
        local centeredIndex = centeredSlotIndex()
        if centeredIndex ~= lastCenteredIndex then
            if lastCenteredIndex ~= nil then playSound("WheelTick") end
            lastCenteredIndex = centeredIndex
        end
    end)
    tween:Play()
    tween.Completed:Wait()
    if tickConnection then tickConnection:Disconnect() end
end

local function playWheelAnimations(spins, speedMultiplier)
    clearSideGrid()
    if #spins == 0 then return end

    local sideGrid = wheel:FindFirstChild("SideGrid")
    local finished = 0
    local total = #spins

    task.spawn(function()
        playWheelAnimation(wheel, spins[1].Slots or {}, spins[1].PickedIndex or 1, speedMultiplier)
        finished += 1
    end)

    if sideGrid then
        for index = 2, #spins do
            local spin = spins[index]
            local cell, holder, stroke = makeMiniCell(sideGrid, index - 1)
            task.spawn(function()
                task.wait((index - 1) * 0.08)
                spinMiniReel(cell, holder, stroke, spin, 1.0 + math.random() * 0.3)
                finished += 1
            end)
        end
    else
        finished += #spins - 1
    end

    repeat task.wait(0.05) until finished >= total
end

local function performSpin(count)
    if spinning or state.WheelSpins <= 0 then return false end
    spinning = true
    refreshStats()
    local result = RequestWheelSpin:InvokeServer("Begin", count or 1)
    if result and result.Ok then
        local haste = state.ActiveBuffs.WheelHaste
        playWheelAnimations(result.Spins or {}, 1 + ((haste and haste.Value) or 0))
        result = RequestWheelSpin:InvokeServer("Claim")
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
                local rolls = (state.ActiveBuffs.AutoRoll and state.ActiveBuffs.AutoRoll.MultiRolls) or 1
                performSpin(math.min(rolls, state.WheelSpins))
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
    playSound("Button")
    performSpin()
end)

autoRollToggle.Activated:Connect(function()
    playSound("Button")
    if not hasAutoRoll() then return end
    autoRollEnabled = not autoRollEnabled
    refreshStats()
    if autoRollEnabled then ensureAutoRollLoop() end
end)

shopButton.Activated:Connect(function()
    playSound("Button")
    shopHub.Visible = not shopHub.Visible
    if shopHub.Visible then bagPanel.Visible = false; taskPanel.Visible = false; codePanel.Visible = false end
end)
bagButton.Activated:Connect(function()
    playSound("Button")
    bagPanel.Visible = not bagPanel.Visible
    if bagPanel.Visible then
        shopHub.Visible = false; taskPanel.Visible = false; codePanel.Visible = false
        refreshBag()
    end
end)
closeShop.Activated:Connect(function()
    playSound("Button")
    shopHub.Visible = false
end)
bagPanel.TermTabButton.Activated:Connect(function()
    bagMode = "Terms"
    refreshBag()
end)
bagPanel.SkillTabButton.Activated:Connect(function()
    bagMode = "Skills"
    refreshBag()
end)
-- The top boxes are the ONLY place an equipped skill can be picked back up and re-dragged from.
-- Drag it down onto the bag list below to put it back; they no longer "equip on click".
for boxIndex = 1, 5 do
    local box = bagPanel.EquippedSkillSlots:FindFirstChild("SkillSlot" .. tostring(boxIndex))
    if box then
        box.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if bagMode ~= "Skills" then return end
            local equipped = (state.Inventory and state.Inventory.EquippedSkills) or {}
            local key = equipped[boxIndex]
            if not key then return end
            local card = SkillConfig.Cards[key]
            beginDrag(key, card and card.Icon or "", Vector2.new(input.Position.X, input.Position.Y), true)
        end)
    end
end
bagPanel.DetailPanel.UpgradeButton.Activated:Connect(function()
    if selectedAbilityKey then playSound("Interact"); RequestAbilityUpgrade:InvokeServer(selectedAbilityKey) end
end)

closeBag.Activated:Connect(function()
    playSound("Button")
    bagPanel.Visible = false
end)

function refreshDailyTasks()
    local list, template = taskPanel.TaskList, taskPanel.TaskList.TaskTemplate
    for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") and child ~= template then child:Destroy() end end
    for order, task in ipairs(state.DailyTasks or {}) do
        local card = template:Clone(); card.Name = "Task_" .. task.Id; card.LayoutOrder = order; card.Visible = true
        card:WaitForChild("Name").Text = task.Name
        card.Reward.Text = string.format("+%s cake  +%s spin", tostring((task.Reward or {}).CakePoints or 0), tostring((task.Reward or {}).WheelSpins or 0))
        local ratio = math.clamp(task.Progress / math.max(1, task.Target), 0, 1)
        card.ProgressBack.ProgressFill.Size = UDim2.new(ratio, 0, 1, 0)
        card.ProgressLabel.Text = string.format("%d / %d", task.Progress, task.Target)
        card.ClaimLabel.Text = task.Claimed and "CLAIMED" or (ratio >= 1 and "CLAIM" or "IN PROGRESS")
        card.ClaimLabel.BackgroundColor3 = ratio >= 1 and not task.Claimed and Color3.fromRGB(241, 196, 15) or Color3.fromRGB(0, 0, 0)
        card.ClaimLabel.TextColor3 = ratio >= 1 and not task.Claimed and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        card.Activated:Connect(function()
            if not task.Claimed and ratio >= 1 then playSound("Interact"); RequestClaimDailyTask:InvokeServer(task.Id) end
        end)
        card.Parent = list
    end
    task.defer(function() list.CanvasSize = UDim2.new(0, 0, 0, list.Layout.AbsoluteContentSize.Y + 20) end)
end
local modalPanels = { shopHub, bagPanel, taskPanel, codePanel }
local function openExclusive(panel)
    for _, candidate in ipairs(modalPanels) do candidate.Visible = candidate == panel and not panel.Visible end
end
taskButton.Activated:Connect(function() playSound("Button"); openExclusive(taskPanel); refreshDailyTasks() end)
codeButton.Activated:Connect(function() playSound("Button"); openExclusive(codePanel) end)
closeTasks.Activated:Connect(function() playSound("Button"); taskPanel.Visible = false end)
closeCode.Activated:Connect(function() playSound("Button"); codePanel.Visible = false end)
codePanel.RedeemButton.Activated:Connect(function()
    local code = codePanel.CodeBox.Text
    if code ~= "" then playSound("Interact"); RequestRedeemCode:InvokeServer(code); codePanel.CodeBox.Text = "" end
end)

UpdateClientState.OnClientEvent:Connect(function(newState)
    for key, value in newState do state[key] = value end
    if newState.LastWheelReward then
        wheelRewardGeneration += 1
        local generation, seconds = wheelRewardGeneration, newState.LastWheelReward.DisplayFor or 0
        task.delay(seconds, function()
            if generation == wheelRewardGeneration then
                state.LastWheelReward = nil
                refreshStats()
            end
        end)
    end
    refreshStats()
end)

refreshStats()
]=]

if recording then
    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

Selection:Set({serverScript, clientScript, mainGui, wheelConfig, cakeConfig, skillConfig, cardConfig, shopConfig, rewardScripts, rewardService, skillScripts, uiConfig, localizationConfig, cakeModelsFolder, mapBase})
print("✅ Cake Rain RNG rebuild complete: static UI/HUB/wheel sectors, animated draws, unanchored falling cakes, auto-eating, rarity outlines, glow effects, sinking cleanup, and player DataStore are configured.")
