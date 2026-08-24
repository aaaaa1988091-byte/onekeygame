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
    },
    Rewards = {
        EatSpeed_Common = { NameKey = "Reward_EatSpeed_Common", Rarity = "Common", Weight = 300, BaseDuration = 60, Type = "Stat", Stat = "EatSpeed", Value = 1, IsUnlockedDefault = true },
        EatSpeed_Legendary = { NameKey = "Reward_EatSpeed_Legendary", Rarity = "Legendary", Weight = 10, BaseDuration = 60, Type = "Stat", Stat = "EatSpeed", Value = 5, IsUnlockedDefault = true },
        GlowCakeBoost_Rare = { NameKey = "Reward_GlowBoost_Rare", Rarity = "Rare", Weight = 50, BaseDuration = 20, Type = "GlowCakeRate", Value = 0.10, IsUnlockedDefault = false, UnlockCostWheelPoints = 50 },
        GlowCakeBoost_Mythic = { NameKey = "Reward_GlowBoost_Mythic", Rarity = "Mythic", Weight = 5, BaseDuration = 20, Type = "GlowCakeRate", Value = 0.50, IsUnlockedDefault = false, UnlockCostWheelPoints = 200 },
        AutoRoll_Common = { NameKey = "Reward_AutoRoll_Common", Rarity = "Common", Weight = 50, BaseDuration = 180, Type = "AutoRoll", Level = 1, Interval = 1.0, IsUnlockedDefault = true },
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
        Card_Gluttony = "大胃王", Card_BlackHole = "黑洞蛋糕", Cosmetic_Trail = "巧克力拖尾", Theme_Candy = "糖果地圖主題",
    },
    ["en-us"] = {
        UI_Spins_Left = "Spins Left: ", UI_WheelPoints = "Wheel Points: ", UI_CakePoints = "Cake Points: ",
        UI_AutoRoll_Active = "Auto-Roll Active...", UI_Shop_Title = "Shop Hub", UI_CakeShop_Title = "Cake Point Shop",
        UI_WheelShop_Title = "Wheel Point Shop", UI_Time_Left = "Time Left: ", UI_No_Buff = "No Active Buff", UI_Spin = "Spin",
        UI_Card_Draw = "Glow Cake Card Draw", UI_Open_Shop = "Shop", UI_Close = "Close", UI_Buy = "Buy",
        Cake_Common = "Common Cake", Cake_Rare = "Rare Cake", Cake_Epic = "Epic Cake", Cake_Legendary = "Legendary Cake", Cake_Mythic = "Mythic Cake", Cake_Special = "Glow Cake",
        Reward_EatSpeed_Common = "+1 Eat Speed (Common)", Reward_EatSpeed_Legendary = "+5 Eat Speed (Legendary)",
        Reward_GlowBoost_Rare = "+10% Glow Cake Spawn (20s)", Reward_GlowBoost_Mythic = "+50% Glow Cake Spawn (20s)", Reward_AutoRoll_Common = "Basic Auto-Roll (Common)",
        Card_Gluttony = "Gluttony", Card_BlackHole = "Black Hole Cake", Cosmetic_Trail = "Chocolate Trail", Theme_Candy = "Candy Map Theme",
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
    SinkSeconds = 1.1,
    StainVisibleSeconds = 2,
    Rarities = {
        Common = { NameKey = "Cake_Common", RarityText = "COMMON", OutlineColor = Color3.fromRGB(210, 210, 210), DropWeight = 500, Health = 10, RewardCakePoints = 1 },
        Rare = { NameKey = "Cake_Rare", RarityText = "RARE", OutlineColor = Color3.fromRGB(70, 170, 255), DropWeight = 110, Health = 22, RewardCakePoints = 3 },
        Epic = { NameKey = "Cake_Epic", RarityText = "EPIC", OutlineColor = Color3.fromRGB(185, 85, 255), DropWeight = 35, Health = 42, RewardCakePoints = 7 },
        Legendary = { NameKey = "Cake_Legendary", RarityText = "LEGENDARY", OutlineColor = Color3.fromRGB(255, 170, 0), DropWeight = 8, Health = 80, RewardCakePoints = 15 },
        Mythic = { NameKey = "Cake_Mythic", RarityText = "MYTHIC", OutlineColor = Color3.fromRGB(255, 60, 120), DropWeight = 2, Health = 140, RewardCakePoints = 40 },
    },
}
return CakeConfig
]=]

local cardConfig = getOrCreate(configsFolder, "ModuleScript", "CardConfig")
cardConfig.Source = [=[
local CardConfig = {
    Cards = {
        Card_Base_01 = { NameKey = "Card_Gluttony", Rarity = "SSR", Weight = 10, Duration = 300, Effect = "RangeEat", IsUnlockedDefault = true },
        Card_Shop_01 = { NameKey = "Card_BlackHole", Rarity = "SSR", Weight = 5, Duration = 240, Effect = "BlackHole", IsUnlockedDefault = false, UnlockCostCakePoints = 5000 },
    },
}
return CardConfig
]=]

local shopConfig = getOrCreate(configsFolder, "ModuleScript", "ShopConfig")
shopConfig.Source = [=[
local ShopConfig = {
    WheelPointShop = {
        { Id = "GlowCakeBoost_Rare", NameKey = "Reward_GlowBoost_Rare", Cost = 50, Currency = "WheelPoints", UnlockType = "WheelReward" },
        { Id = "GlowCakeBoost_Mythic", NameKey = "Reward_GlowBoost_Mythic", Cost = 200, Currency = "WheelPoints", UnlockType = "WheelReward" },
    },
    CakePointShop = {
        { Id = "Card_Shop_01", NameKey = "Card_BlackHole", Cost = 5000, Currency = "CakePoints", UnlockType = "Card" },
        { Id = "Cosmetic_Trail", NameKey = "Cosmetic_Trail", Cost = 750, Currency = "CakePoints", UnlockType = "Cosmetic" },
        { Id = "Theme_Candy", NameKey = "Theme_Candy", Cost = 2500, Currency = "CakePoints", UnlockType = "Theme" },
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
wheel.Position = UDim2.new(1, -180, 0.5, -180)
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
pointer.Position = UDim2.new(0, 125, 0.5, -29)
pointer.Font = Enum.Font.GothamBlack
pointer.Text = "◀"
pointer.TextScaled = true
pointer.TextColor3 = Color3.fromRGB(255, 240, 110)
for index = 1, 5 do
    local sector = newGui("Frame", "Sector" .. index, disc)
    sector.AnchorPoint = Vector2.new(1, 0.5)
    sector.Size = UDim2.new(0, 175, 0, 58)
    sector.Position = UDim2.new(0.5, 0, 0.5, 0)
    sector.Rotation = -72 + (index - 1) * 36
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
spinButton.Position = UDim2.new(0, 34, 0.5, -26)
spinButton.BackgroundColor3 = Color3.fromRGB(255, 185, 80)
spinButton.Font = Enum.Font.GothamBlack
spinButton.Text = "旋轉"
spinButton.TextScaled = true
spinButton.TextColor3 = Color3.fromRGB(60, 35, 10)
newGui("UICorner", "Corner", spinButton).CornerRadius = UDim.new(0, 14)

local buffFrame = newGui("Frame", "BuffStatus", mainGui)
buffFrame.Size = UDim2.new(0, 390, 0, 78)
buffFrame.Position = UDim2.new(0.5, -195, 1, -98)
buffFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
buffFrame.BackgroundTransparency = 0.12
buffFrame.Visible = false
newGui("UICorner", "Corner", buffFrame).CornerRadius = UDim.new(0, 16)
local buffLabel = newGui("TextLabel", "BuffLabel", buffFrame)
buffLabel.BackgroundTransparency = 1
buffLabel.Size = UDim2.new(1, -20, 1, -16)
buffLabel.Position = UDim2.new(0, 10, 0, 8)
buffLabel.Font = Enum.Font.GothamBold
buffLabel.TextScaled = true
buffLabel.TextColor3 = Color3.fromRGB(180, 255, 180)

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

local serverScript = getOrCreate(ServerScriptService, "Script", "CakeRainRNGServer")
serverScript.Source = [=[
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Events = ReplicatedStorage:WaitForChild("Events")
local Configs = ReplicatedStorage:WaitForChild("Configs")
local Models = ReplicatedStorage:WaitForChild("Models")
local CakeModels = Models:WaitForChild("cake")
local RequestWheelSpin = Events:WaitForChild("RequestWheelSpin")
local RequestCardDraw = Events:WaitForChild("RequestCardDraw")
local RequestShopPurchase = Events:WaitForChild("RequestShopPurchase")
local UpdateClientState = Events:WaitForChild("UpdateClientState")

local WheelConfig = require(Configs:WaitForChild("WheelConfig"))
local CakeConfig = require(Configs:WaitForChild("CakeConfig"))
local CardConfig = require(Configs:WaitForChild("CardConfig"))
local LocalizationConfig = require(Configs:WaitForChild("LocalizationConfig"))
local ShopConfig = require(Configs:WaitForChild("ShopConfig"))

local dataStore = DataStoreService:GetDataStore(CakeConfig.DataStoreKey)
local runtimeFolder = Workspace.Map:FindFirstChild("RuntimeCakes") or Instance.new("Folder")
runtimeFolder.Name = "RuntimeCakes"
runtimeFolder.Parent = Workspace.Map

local playerState = {}
local cakeOwners = {}
local eatingLoops = {}

local function getText(nameKey)
    return LocalizationConfig["zh-tw"][nameKey] or nameKey
end

local function weightedPick(entries, weightName)
    weightName = weightName or "Weight"
    local total = 0
    for _, entry in entries do
        total += entry[weightName] or 1
    end
    local roll = math.random() * total
    local cursor = 0
    for key, entry in entries do
        cursor += entry[weightName] or 1
        if roll <= cursor then
            return key, entry
        end
    end
end

local function getRandomCakeTemplate()
    local choices = CakeModels:GetChildren()
    if #choices == 0 then
        return nil
    end
    return choices[math.random(1, #choices)]
end

local function getEffectiveStat(state, statName)
    local bestValue = 0
    local bestPriority = -1
    local now = os.clock()
    for _, stack in state.Buffs[statName] or {} do
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

local function serializeBuffs(state)
    local active = {}
    local now = os.clock()
    for buffType, stacks in state.Buffs do
        local best
        for _, stack in stacks do
            if stack.ExpiresAt > now then
                local priority = WheelConfig.RarityPriority[stack.Rarity] or 0
                local bestPriority = best and (WheelConfig.RarityPriority[best.Rarity] or 0) or -1
                if priority > bestPriority then
                    best = stack
                end
            end
        end
        if best then
            active[buffType] = { Name = getText(best.NameKey), Rarity = best.Rarity, Value = best.Value or best.Level or 0, Remaining = math.max(0, math.floor(best.ExpiresAt - now)) }
        end
    end
    return active
end

local function pushState(player)
    local state = playerState[player]
    if not state then
        return
    end
    UpdateClientState:FireClient(player, {
        WheelSpins = state.WheelSpins,
        WheelPoints = state.WheelPoints,
        CakePoints = state.CakePoints,
        PendingCardDraw = state.PendingCardDraw,
        ActiveBuffs = serializeBuffs(state),
        UnlockedWheelRewards = state.UnlockedWheelRewards,
        UnlockedCards = state.UnlockedCards,
    })
end

local function savePlayer(player)
    local state = playerState[player]
    if not state then
        return
    end
    local key = "Player_" .. player.UserId
    pcall(function()
        dataStore:SetAsync(key, {
            WheelSpins = state.WheelSpins,
            WheelPoints = state.WheelPoints,
            CakePoints = state.CakePoints,
            UnlockedWheelRewards = state.UnlockedWheelRewards,
            UnlockedCards = state.UnlockedCards,
            Cosmetics = state.Cosmetics,
            Themes = state.Themes,
        })
    end)
end

local function updateLeaderstats(player)
    local state = playerState[player]
    local leaderstats = player:FindFirstChild("leaderstats")
    if not state or not leaderstats then
        return
    end
    leaderstats["Cake Points"].Value = state.CakePoints
    leaderstats["Wheel Points"].Value = state.WheelPoints
end

local function addBuff(player, key, reward)
    local state = playerState[player]
    if not state then
        return
    end
    local buffType = reward.Type == "Stat" and reward.Stat or reward.Type
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    table.insert(state.Buffs[buffType], { Key = key, NameKey = reward.NameKey, Rarity = reward.Rarity, Value = reward.Value, Level = reward.Level, ExpiresAt = os.clock() + reward.BaseDuration })
end

local function unlockedWheelEntries(state)
    local entries = {}
    for key, reward in WheelConfig.Rewards do
        if reward.IsUnlockedDefault or state.UnlockedWheelRewards[key] then
            entries[key] = reward
        end
    end
    return entries
end

local function buildWheelSlots(state)
    local pool = unlockedWheelEntries(state)
    local poolCount = 0
    for _ in pool do
        poolCount += 1
    end

    local slots = {}
    local used = {}
    local attempts = 0
    while #slots < WheelConfig.DisplayedSlots and attempts < 100 do
        attempts += 1
        local key, reward = weightedPick(pool)
        if not key then
            break
        end
        if poolCount < WheelConfig.DisplayedSlots or not used[key] then
            used[key] = true
            table.insert(slots, { Key = key, Name = getText(reward.NameKey), Rarity = reward.Rarity, Type = reward.Type, Value = reward.Value or reward.Level, Duration = reward.BaseDuration, Color = WheelConfig.RarityColors[reward.Rarity] })
        end
    end
    return slots
end

RequestWheelSpin.OnServerInvoke = function(player)
    local state = playerState[player]
    if not state or state.WheelSpins <= 0 then
        return { Ok = false, Error = "NO_SPINS" }
    end
    state.WheelSpins -= 1
    state.WheelPoints += 1
    local slots = buildWheelSlots(state)
    local pickedIndex = math.random(1, #slots)
    local picked = slots[pickedIndex]
    local reward = WheelConfig.Rewards[picked.Key]
    if reward then
        addBuff(player, picked.Key, reward)
    end
    updateLeaderstats(player)
    pushState(player)
    return { Ok = true, Slots = slots, Picked = picked, PickedIndex = pickedIndex }
end

local function unlockedCards(state)
    local entries = {}
    for key, card in CardConfig.Cards do
        if card.IsUnlockedDefault or state.UnlockedCards[key] then
            entries[key] = card
        end
    end
    return entries
end

RequestCardDraw.OnServerInvoke = function(player)
    local state = playerState[player]
    if not state or not state.PendingCardDraw then
        return { Ok = false, Error = "NO_CARD_DRAW" }
    end
    state.PendingCardDraw = false
    local key, card = weightedPick(unlockedCards(state))
    if card then
        state.Buffs[card.Effect] = state.Buffs[card.Effect] or {}
        table.insert(state.Buffs[card.Effect], { Key = key, NameKey = card.NameKey, Rarity = card.Rarity, Value = 1, ExpiresAt = os.clock() + card.Duration })
    end
    pushState(player)
    return { Ok = true, Card = card and { Key = key, Name = getText(card.NameKey), Rarity = card.Rarity, Duration = card.Duration, Effect = card.Effect } or nil }
end

local function findShopItem(itemId)
    for _, section in { ShopConfig.WheelPointShop, ShopConfig.CakePointShop } do
        for _, item in section do
            if item.Id == itemId then
                return item
            end
        end
    end
end

RequestShopPurchase.OnServerInvoke = function(player, itemId)
    local state = playerState[player]
    local item = findShopItem(itemId)
    if not state or not item then
        return { Ok = false, Error = "INVALID_ITEM" }
    end
    if item.UnlockType == "WheelReward" and state.UnlockedWheelRewards[item.Id] then
        return { Ok = false, Error = "OWNED" }
    end
    if item.UnlockType == "Card" and state.UnlockedCards[item.Id] then
        return { Ok = false, Error = "OWNED" }
    end
    if item.Currency == "WheelPoints" and state.WheelPoints < item.Cost then
        return { Ok = false, Error = "NO_WHEEL_POINTS" }
    end
    if item.Currency == "CakePoints" and state.CakePoints < item.Cost then
        return { Ok = false, Error = "NO_CAKE_POINTS" }
    end
    state[item.Currency] -= item.Cost
    if item.UnlockType == "WheelReward" then
        state.UnlockedWheelRewards[item.Id] = true
    elseif item.UnlockType == "Card" then
        state.UnlockedCards[item.Id] = true
    elseif item.UnlockType == "Cosmetic" then
        state.Cosmetics[item.Id] = true
    elseif item.UnlockType == "Theme" then
        state.Themes[item.Id] = true
    end
    updateLeaderstats(player)
    pushState(player)
    return { Ok = true }
end

local function decorateCake(cake, rarityKey, rarityData, isGlow)
    local primary = cake.PrimaryPart or cake:FindFirstChildWhichIsA("BasePart", true)
    if not primary then
        return
    end
    cake.PrimaryPart = primary
    cake:SetAttribute("RarityKey", rarityKey)
    cake:SetAttribute("Health", rarityData.Health)
    cake:SetAttribute("MaxHealth", rarityData.Health)
    cake:SetAttribute("RewardCakePoints", rarityData.RewardCakePoints)
    cake:SetAttribute("IsGlow", isGlow)

    for _, part in cake:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = true
        end
    end

    local outline = Instance.new("Highlight")
    outline.Name = "RarityOutline"
    outline.FillTransparency = 1
    outline.OutlineTransparency = 0
    outline.OutlineColor = rarityData.OutlineColor
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.Parent = cake

    if isGlow then
        local attachment = Instance.new("Attachment")
        attachment.Name = "GlowAttachment"
        attachment.Parent = primary
        local sparkles = Instance.new("ParticleEmitter")
        sparkles.Name = "GlowCakeSparkles"
        sparkles.Color = ColorSequence.new(Color3.fromRGB(120, 255, 255))
        sparkles.LightEmission = 0.8
        sparkles.Rate = 22
        sparkles.Lifetime = NumberRange.new(0.7, 1.4)
        sparkles.Speed = NumberRange.new(0.4, 1.8)
        sparkles.SpreadAngle = Vector2.new(360, 360)
        sparkles.Parent = attachment
        local light = Instance.new("PointLight")
        light.Name = "GlowCakeLight"
        light.Color = Color3.fromRGB(120, 255, 255)
        light.Brightness = 1.2
        light.Range = 12
        light.Parent = primary
    end

    local label = Instance.new("BillboardGui")
    label.Name = "CakeLabel"
    label.AlwaysOnTop = true
    label.Size = UDim2.new(0, 300, 0, 62)
    label.StudsOffset = Vector3.new(0, 4.2, 0)
    label.Parent = primary
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeColor3 = rarityData.OutlineColor
    text.TextStrokeTransparency = 0
    text.Parent = label
end

local function refreshCakeLabel(cake)
    local rarityData = CakeConfig.Rarities[cake:GetAttribute("RarityKey")] or CakeConfig.Rarities.Common
    local hp = math.max(0, cake:GetAttribute("Health") or rarityData.Health)
    local maxHp = cake:GetAttribute("MaxHealth") or rarityData.Health
    local isGlow = cake:GetAttribute("IsGlow") == true
    local primary = cake.PrimaryPart
    local label = primary and primary:FindFirstChild("CakeLabel")
    local text = label and label:FindFirstChild("Text")
    if text then
        text.Text = string.format("[%s] %s (HP: %d/%d)", isGlow and "SPECIAL" or rarityData.RarityText, isGlow and getText("Cake_Special") or getText(rarityData.NameKey), hp, maxHp)
    end
end

local function finishCake(player, cake)
    local state = playerState[player]
    if not state or not cake.Parent then
        return
    end
    cakeOwners[cake] = nil
    state.CakePoints += cake:GetAttribute("RewardCakePoints") or 1
    state.WheelSpins += 1
    if cake:GetAttribute("IsGlow") == true then
        state.PendingCardDraw = true
    end
    updateLeaderstats(player)
    pushState(player)

    local primary = cake.PrimaryPart
    local finalPosition = primary and primary.Position or Vector3.new()
    local stain = Instance.new("Part")
    stain.Name = "CakeStain"
    stain.Anchored = true
    stain.CanCollide = false
    stain.Shape = Enum.PartType.Cylinder
    stain.Size = Vector3.new(0.08, 5.5, 5.5)
    stain.CFrame = CFrame.new(finalPosition.X, 0.02, finalPosition.Z) * CFrame.Angles(0, 0, math.rad(90))
    stain.Color = Color3.fromRGB(92, 55, 28)
    stain.Material = Enum.Material.SmoothPlastic
    stain.Transparency = 0.45
    stain.Parent = Workspace.Map
    TweenService:Create(stain, TweenInfo.new(CakeConfig.StainVisibleSeconds), { Transparency = 1 }):Play()
    Debris:AddItem(stain, CakeConfig.StainVisibleSeconds + 0.15)

    for _, part in cake:GetDescendants() do
        if part:IsA("BasePart") then
            part.CanCollide = false
            TweenService:Create(part, TweenInfo.new(CakeConfig.SinkSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = part.Position - Vector3.new(0, 8, 0), Transparency = 1 }):Play()
        end
    end
    Debris:AddItem(cake, CakeConfig.SinkSeconds + 0.2)
end

local function beginAutoEat(player, cake)
    if eatingLoops[cake] then
        return
    end
    eatingLoops[cake] = true
    task.spawn(function()
        while cake.Parent and cakeOwners[cake] == player do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local primary = cake.PrimaryPart
            if not root or not primary or (root.Position - primary.Position).Magnitude > 8 then
                break
            end
            local state = playerState[player]
            if not state then
                break
            end
            local hp = (cake:GetAttribute("Health") or 1) - (CakeConfig.BaseEatDamagePerSecond + getEffectiveStat(state, "EatSpeed"))
            cake:SetAttribute("Health", hp)
            refreshCakeLabel(cake)
            if hp <= 0 then
                finishCake(player, cake)
                break
            end
            task.wait(CakeConfig.EatTickSeconds)
        end
        eatingLoops[cake] = nil
    end)
end

local function hookCakeTouches(cake)
    for _, part in cake:GetDescendants() do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if player and cakeOwners[cake] == player then
                    beginAutoEat(player, cake)
                end
            end)
        end
    end
end

local function countPlayerCakes(player)
    local count = 0
    for cake, owner in cakeOwners do
        if owner == player and cake.Parent then
            count += 1
        end
    end
    return count
end

local function spawnCakeNear(player)
    local state = playerState[player]
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not state or not root or countPlayerCakes(player) >= CakeConfig.MaxCakesPerPlayer then
        return
    end
    local template = getRandomCakeTemplate()
    if not template then
        return
    end
    local rarityKey, rarityData = weightedPick(CakeConfig.Rarities, "DropWeight")
    local isGlow = math.random() < (CakeConfig.GlowBaseChance + getEffectiveStat(state, "GlowCakeRate"))
    local cake = template:Clone()
    cake.Name = (isGlow and "Glow" or rarityKey) .. "_" .. template.Name
    local angle = math.random() * math.pi * 2
    local radius = math.random(14, CakeConfig.SpawnRadius)
    local spawnPos = root.Position + Vector3.new(math.cos(angle) * radius, CakeConfig.SpawnHeight, math.sin(angle) * radius)
    cake.Parent = runtimeFolder
    local primary = cake.PrimaryPart or cake:FindFirstChildWhichIsA("BasePart", true)
    if primary then
        cake.PrimaryPart = primary
        cake:PivotTo(CFrame.new(spawnPos) * CFrame.Angles(0, math.random() * math.pi * 2, 0))
    end
    decorateCake(cake, rarityKey, rarityData, isGlow)
    refreshCakeLabel(cake)
    cakeOwners[cake] = player
    hookCakeTouches(cake)
    task.delay(70, function()
        if cake.Parent and cakeOwners[cake] == player then
            cakeOwners[cake] = nil
            cake:Destroy()
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local cakePointsValue = Instance.new("IntValue")
    cakePointsValue.Name = "Cake Points"
    cakePointsValue.Parent = leaderstats
    local wheelPointsValue = Instance.new("IntValue")
    wheelPointsValue.Name = "Wheel Points"
    wheelPointsValue.Parent = leaderstats

    local loaded = {}
    pcall(function()
        loaded = dataStore:GetAsync("Player_" .. player.UserId) or {}
    end)
    playerState[player] = {
        WheelSpins = loaded.WheelSpins or 0,
        WheelPoints = loaded.WheelPoints or 0,
        CakePoints = loaded.CakePoints or 0,
        PendingCardDraw = false,
        Buffs = {},
        UnlockedWheelRewards = loaded.UnlockedWheelRewards or {},
        UnlockedCards = loaded.UnlockedCards or {},
        Cosmetics = loaded.Cosmetics or {},
        Themes = loaded.Themes or {},
    }
    updateLeaderstats(player)
    pushState(player)

    task.spawn(function()
        while player.Parent do
            spawnCakeNear(player)
            pushState(player)
            task.wait(CakeConfig.SpawnInterval)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    playerState[player] = nil
    for cake, owner in cakeOwners do
        if owner == player then
            cakeOwners[cake] = nil
            if cake.Parent then
                cake:Destroy()
            end
        end
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayer(player)
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
local buffFrame = gui:WaitForChild("BuffStatus")
local buffLabel = buffFrame:WaitForChild("BuffLabel")
local cardFrame = gui:WaitForChild("CardDraw")
local drawButton = cardFrame:WaitForChild("DrawButton")
local cardResult = cardFrame:WaitForChild("Result")
local shopButton = gui:WaitForChild("ShopButton")
local shopHub = gui:WaitForChild("ShopHub")
local closeShop = shopHub:WaitForChild("CloseButton")

local state = { WheelSpins = 0, WheelPoints = 0, CakePoints = 0, ActiveBuffs = {}, PendingCardDraw = false }
local spinning = false

local function buttonLabel(item)
    local name = L[item.NameKey] or item.NameKey
    return string.format("%s\n%s %d", name, item.Currency == "WheelPoints" and "轉盤點數" or "蛋糕積分", item.Cost)
end

local function bindShopButtons()
    local cakePane = shopHub:WaitForChild("CakePointShop")
    for index, item in ShopConfig.CakePointShop do
        local button = cakePane:FindFirstChild("Buy" .. index)
        if button then
            button.Text = buttonLabel(item)
            button.Activated:Connect(function()
                RequestShopPurchase:InvokeServer(item.Id)
            end)
        end
    end
    local wheelPane = shopHub:WaitForChild("WheelPointShop")
    for index, item in ShopConfig.WheelPointShop do
        local button = wheelPane:FindFirstChild("Buy" .. index)
        if button then
            button.Text = buttonLabel(item)
            button.Activated:Connect(function()
                RequestShopPurchase:InvokeServer(item.Id)
            end)
        end
    end
end
bindShopButtons()

local function refreshStats()
    stats.CakePointsLabel.Text = L.UI_CakePoints .. tostring(state.CakePoints)
    stats.WheelPointsLabel.Text = L.UI_WheelPoints .. tostring(state.WheelPoints)
    stats.SpinsLabel.Text = L.UI_Spins_Left .. tostring(state.WheelSpins)
    wheel.Visible = state.WheelSpins > 0
    cardFrame.Visible = state.PendingCardDraw
    local text
    for _, buff in state.ActiveBuffs do
        text = string.format("%s [%s] +%s / %ss", buff.Name, buff.Rarity, tostring(buff.Value), tostring(buff.Remaining))
        break
    end
    buffFrame.Visible = text ~= nil
    buffLabel.Text = text or L.UI_No_Buff
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
    local targetRotation = 1080 + ((pickedIndex - 1) * 36)
    local tween = TweenService:Create(disc, TweenInfo.new(2.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = targetRotation })
    tween:Play()
    tween.Completed:Wait()
    paintSlots(slots, pickedIndex)
    local pulse = TweenService:Create(disc, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 1, true), { Size = UDim2.new(0, 374, 0, 374), Position = UDim2.new(0, -7, 0, -7) })
    pulse:Play()
end

spinButton.Activated:Connect(function()
    if spinning then
        return
    end
    spinning = true
    local result = RequestWheelSpin:InvokeServer()
    if result and result.Ok then
        playWheelAnimation(result.Slots, result.PickedIndex)
    end
    spinning = false
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

Selection:Set({serverScript, clientScript, mainGui, wheelConfig, cakeConfig, cardConfig, shopConfig, uiConfig, localizationConfig, cakeModelsFolder, mapBase})
print("✅ Cake Rain RNG 已重構完成：靜態 UI/HUB/轉盤分區、動畫抽獎、非錨定下落蛋糕、自動吞食、稀有度 outline、發光特效、下沉與咖啡色痕跡、DataStore 個人資料皆已配置。")
