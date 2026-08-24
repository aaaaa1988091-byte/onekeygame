local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Selection = game:GetService("Selection")

local recording
local ok, result = pcall(function()
    return ChangeHistoryService:TryBeginRecording("Build_Cake_Rain_RNG")
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

local eventsFolder = getOrCreate(ReplicatedStorage, "Folder", "Events")
local configsFolder = getOrCreate(ReplicatedStorage, "Folder", "Configs")
local modelsFolder = getOrCreate(ReplicatedStorage, "Folder", "Models")
local mapFolder = getOrCreate(Workspace, "Folder", "Map")

local requestWheelSpin = getOrCreate(eventsFolder, "RemoteFunction", "RequestWheelSpin")
local requestCardDraw = getOrCreate(eventsFolder, "RemoteFunction", "RequestCardDraw")
local updateClientState = getOrCreate(eventsFolder, "RemoteEvent", "UpdateClientState")
local cakeEatRequest = getOrCreate(eventsFolder, "RemoteEvent", "CakeEatRequest")

local wheelConfig = getOrCreate(configsFolder, "ModuleScript", "WheelConfig")
wheelConfig.Source = [=[
local WheelConfig = {
    RarityPriority = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 },
    DisplayedSlots = 5,

    Rewards = {
        EatSpeed_Common = {
            NameKey = "Reward_EatSpeed_Common",
            Rarity = "Common",
            Weight = 300,
            BaseDuration = 60,
            Type = "Stat",
            Stat = "EatSpeed",
            Value = 1,
            IsUnlockedDefault = true,
        },
        EatSpeed_Legendary = {
            NameKey = "Reward_EatSpeed_Legendary",
            Rarity = "Legendary",
            Weight = 10,
            BaseDuration = 60,
            Type = "Stat",
            Stat = "EatSpeed",
            Value = 5,
            IsUnlockedDefault = true,
        },
        GlowCakeBoost_Rare = {
            NameKey = "Reward_GlowBoost_Rare",
            Rarity = "Rare",
            Weight = 50,
            BaseDuration = 20,
            Type = "GlowCakeRate",
            Value = 0.10,
            IsUnlockedDefault = false,
            UnlockCostWheelPoints = 50,
        },
        GlowCakeBoost_Mythic = {
            NameKey = "Reward_GlowBoost_Mythic",
            Rarity = "Mythic",
            Weight = 5,
            BaseDuration = 20,
            Type = "GlowCakeRate",
            Value = 0.50,
            IsUnlockedDefault = false,
            UnlockCostWheelPoints = 200,
        },
        AutoRoll_Common = {
            NameKey = "Reward_AutoRoll_Common",
            Rarity = "Common",
            Weight = 50,
            BaseDuration = 180,
            Type = "AutoRoll",
            Level = 1,
            Interval = 1.0,
            IsUnlockedDefault = true,
        },
    },
}

return WheelConfig
]=]

local localizationConfig = getOrCreate(configsFolder, "ModuleScript", "LocalizationConfig")
localizationConfig.Source = [=[
local LocalizationConfig = {
    ["zh-tw"] = {
        UI_Spins_Left = "剩餘轉盤次數: ",
        UI_WheelPoints = "轉盤點數: ",
        UI_CakePoints = "蛋糕積分: ",
        UI_AutoRoll_Active = "自動抽獎運行中...",
        UI_Time_Left = "剩餘時間: ",
        UI_No_Buff = "目前沒有 Buff",
        UI_Spin = "旋轉",
        UI_Card_Draw = "發光蛋糕抽卡",
        Cake_Common = "普通蛋糕",
        Cake_Legendary = "傳說蛋糕",
        Cake_Special = "發光蛋糕",
        Reward_EatSpeed_Common = "+1 吞食速度 (普通)",
        Reward_EatSpeed_Legendary = "+5 吞食速度 (傳說)",
        Reward_GlowBoost_Rare = "+10% 發光蛋糕率 (20秒)",
        Reward_GlowBoost_Mythic = "+50% 發光蛋糕率 (20秒)",
        Reward_AutoRoll_Common = "初級自動抽獎 (普通)",
        Card_Gluttony = "大胃王",
        Card_BlackHole = "黑洞蛋糕",
    },
    ["en-us"] = {
        UI_Spins_Left = "Spins Left: ",
        UI_WheelPoints = "Wheel Points: ",
        UI_CakePoints = "Cake Points: ",
        UI_AutoRoll_Active = "Auto-Roll Active...",
        UI_Time_Left = "Time Left: ",
        UI_No_Buff = "No Active Buff",
        UI_Spin = "Spin",
        UI_Card_Draw = "Glow Cake Card Draw",
        Cake_Common = "Common Cake",
        Cake_Legendary = "Legendary Cake",
        Cake_Special = "Glow Cake",
        Reward_EatSpeed_Common = "+1 Eat Speed (Common)",
        Reward_EatSpeed_Legendary = "+5 Eat Speed (Legendary)",
        Reward_GlowBoost_Rare = "+10% Glow Cake Spawn (20s)",
        Reward_GlowBoost_Mythic = "+50% Glow Cake Spawn (20s)",
        Reward_AutoRoll_Common = "Basic Auto-Roll (Common)",
        Card_Gluttony = "Gluttony",
        Card_BlackHole = "Black Hole Cake",
    },
}

return LocalizationConfig
]=]

local cakeConfig = getOrCreate(configsFolder, "ModuleScript", "CakeConfig")
cakeConfig.Source = [=[
local CakeConfig = {
    BaseEatDamagePerSecond = 1,
    SpawnInterval = 3,
    SpawnRadius = 45,
    MaxCakesPerPlayer = 12,
    GlowBaseChance = 0.03,

    Rarities = {
        Common = {
            NameKey = "Cake_Common",
            RarityText = "COMMON",
            Color = Color3.fromRGB(200, 200, 200),
            DropWeight = 500,
            Health = 10,
            RewardCakePoints = 1,
        },
        Legendary = {
            NameKey = "Cake_Legendary",
            RarityText = "LEGENDARY",
            Color = Color3.fromRGB(255, 170, 0),
            DropWeight = 8,
            Health = 80,
            RewardCakePoints = 15,
        },
    },
}

return CakeConfig
]=]

local cardConfig = getOrCreate(configsFolder, "ModuleScript", "CardConfig")
cardConfig.Source = [=[
local CardConfig = {
    Cards = {
        Card_Base_01 = {
            NameKey = "Card_Gluttony",
            Rarity = "SSR",
            Weight = 10,
            Duration = 300,
            Effect = "RangeEat",
            IsUnlockedDefault = true,
        },
        Card_Shop_01 = {
            NameKey = "Card_BlackHole",
            Rarity = "SSR",
            Weight = 5,
            Duration = 240,
            Effect = "BlackHole",
            IsUnlockedDefault = false,
            UnlockCostCakePoints = 5000,
        },
    },
}

return CardConfig
]=]

local uiConfig = getOrCreate(configsFolder, "ModuleScript", "UIConfig")
uiConfig.Source = [=[
local UIConfig = {
    WheelUI = {
        AutoHide = true,
        ShowCondition = "WheelSpins > 0",
        TitleKey = "UI_Spins_Left",
        Position = "RightSideHalfCircle",
        DisplayedSlots = 5,
    },
    AutoRollUI = {
        AutoHide = true,
        ShowCondition = "HasAutoRollTime",
        TitleKey = "UI_AutoRoll_Active",
    },
    CardDrawUI = {
        AutoHide = true,
        ShowCondition = "TouchedGlowCake",
        TitleKey = "UI_Card_Draw",
    },
    BuffStatus = {
        AutoHide = true,
        ShowCondition = "ActiveBuffsCount > 0",
        TitleKey = "UI_Time_Left",
    },
}

return UIConfig
]=]

local cakeTemplate = getOrCreate(modelsFolder, "Part", "CakeTemplate")
cakeTemplate.Anchored = true
cakeTemplate.CanCollide = true
cakeTemplate.Shape = Enum.PartType.Cylinder
cakeTemplate.Size = Vector3.new(2, 4, 4)
cakeTemplate.Color = Color3.fromRGB(255, 209, 220)
cakeTemplate.Material = Enum.Material.SmoothPlastic

local mapBase = getOrCreate(mapFolder, "Part", "CakeArenaBase")
mapBase.Anchored = true
mapBase.CanCollide = true
mapBase.Size = Vector3.new(160, 2, 160)
mapBase.Position = Vector3.new(0, -1, 0)
mapBase.Color = Color3.fromRGB(116, 78, 48)
mapBase.Material = Enum.Material.WoodPlanks

local serverScript = getOrCreate(ServerScriptService, "Script", "CakeRainRNGServer")
serverScript.Source = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Events = ReplicatedStorage:WaitForChild("Events")
local Configs = ReplicatedStorage:WaitForChild("Configs")
local RequestWheelSpin = Events:WaitForChild("RequestWheelSpin")
local RequestCardDraw = Events:WaitForChild("RequestCardDraw")
local UpdateClientState = Events:WaitForChild("UpdateClientState")
local CakeEatRequest = Events:WaitForChild("CakeEatRequest")

local WheelConfig = require(Configs:WaitForChild("WheelConfig"))
local CakeConfig = require(Configs:WaitForChild("CakeConfig"))
local CardConfig = require(Configs:WaitForChild("CardConfig"))
local LocalizationConfig = require(Configs:WaitForChild("LocalizationConfig"))

local mapFolder = Workspace:WaitForChild("Map")
local runtimeFolder = mapFolder:FindFirstChild("RuntimeCakes") or Instance.new("Folder")
runtimeFolder.Name = "RuntimeCakes"
runtimeFolder.Parent = mapFolder

local playerState = {}
local cakeOwners = {}
local eatingLocks = {}

local function weightedPick(entries)
    local total = 0
    for _, entry in entries do
        total += entry.Weight or 1
    end

    local roll = math.random() * total
    local cursor = 0
    for key, entry in entries do
        cursor += entry.Weight or 1
        if roll <= cursor then
            return key, entry
        end
    end

    for key, entry in entries do
        return key, entry
    end
end

local function getText(nameKey)
    local locale = LocalizationConfig["zh-tw"]
    return locale[nameKey] or nameKey
end

local function serializeBuffs(state)
    local active = {}
    for buffType, stacks in state.Buffs do
        local best
        for _, stack in stacks do
            if stack.ExpiresAt > os.clock() then
                local currentPriority = WheelConfig.RarityPriority[stack.Rarity] or 0
                local bestPriority = best and (WheelConfig.RarityPriority[best.Rarity] or 0) or -1
                if currentPriority > bestPriority then
                    best = stack
                end
            end
        end
        if best then
            active[buffType] = {
                Name = getText(best.NameKey),
                Rarity = best.Rarity,
                Value = best.Value or best.Level or 0,
                Remaining = math.max(0, math.floor(best.ExpiresAt - os.clock())),
            }
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
        ActiveBuffs = serializeBuffs(state),
        PendingCardDraw = state.PendingCardDraw,
    })
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

local function addBuff(player, rewardKey, reward)
    local state = playerState[player]
    if not state then
        return
    end

    local buffType = reward.Type == "Stat" and reward.Stat or reward.Type
    state.Buffs[buffType] = state.Buffs[buffType] or {}
    table.insert(state.Buffs[buffType], {
        Key = rewardKey,
        NameKey = reward.NameKey,
        Rarity = reward.Rarity,
        Value = reward.Value,
        Level = reward.Level,
        ExpiresAt = os.clock() + reward.BaseDuration,
    })
end

local function getUnlockedWheelEntries(state)
    local entries = {}
    for key, reward in WheelConfig.Rewards do
        if reward.IsUnlockedDefault or state.UnlockedWheelRewards[key] then
            entries[key] = reward
        end
    end
    return entries
end

local function buildWheelSlots(state)
    local pool = getUnlockedWheelEntries(state)
    local slots = {}
    local guard = 0
    while #slots < WheelConfig.DisplayedSlots and guard < 100 do
        guard += 1
        local key, reward = weightedPick(pool)
        if key then
            table.insert(slots, {
                Key = key,
                Name = getText(reward.NameKey),
                Rarity = reward.Rarity,
                Type = reward.Type,
                Value = reward.Value or reward.Level,
                Duration = reward.BaseDuration,
            })
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
    local picked = slots[math.random(1, #slots)]
    local reward = WheelConfig.Rewards[picked.Key]
    if reward then
        addBuff(player, picked.Key, reward)
    end

    pushState(player)
    return { Ok = true, Slots = slots, Picked = picked }
end

local function getUnlockedCards(state)
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
    local key, card = weightedPick(getUnlockedCards(state))
    if card then
        state.Buffs[card.Effect] = state.Buffs[card.Effect] or {}
        table.insert(state.Buffs[card.Effect], {
            Key = key,
            NameKey = card.NameKey,
            Rarity = card.Rarity,
            Value = 1,
            ExpiresAt = os.clock() + card.Duration,
        })
    end

    pushState(player)
    return {
        Ok = true,
        Card = card and {
            Key = key,
            Name = getText(card.NameKey),
            Rarity = card.Rarity,
            Duration = card.Duration,
            Effect = card.Effect,
        } or nil,
    }
end

local function makeCakeLabel(cake, rarityData, currentHp, maxHp, isGlow)
    local label = cake:FindFirstChild("CakeLabel") or Instance.new("BillboardGui")
    label.Name = "CakeLabel"
    label.AlwaysOnTop = true
    label.Size = UDim2.new(0, 260, 0, 60)
    label.StudsOffset = Vector3.new(0, 4, 0)
    label.Parent = cake

    local text = label:FindFirstChild("Text") or Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextColor3 = isGlow and Color3.fromRGB(110, 255, 255) or rarityData.Color
    text.TextStrokeTransparency = 0.25
    text.Text = string.format("[%s] %s (HP: %d/%d)", isGlow and "SPECIAL" or rarityData.RarityText, isGlow and getText("Cake_Special") or getText(rarityData.NameKey), currentHp, maxHp)
    text.Parent = label
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

    local rarityKey, rarityData = weightedPick(CakeConfig.Rarities)
    local glowChance = CakeConfig.GlowBaseChance + getEffectiveStat(state, "GlowCakeRate")
    local isGlow = math.random() < glowChance

    local cake = Instance.new("Part")
    cake.Name = isGlow and "GlowCake" or (rarityKey .. "Cake")
    cake.Anchored = true
    cake.CanCollide = true
    cake.Shape = Enum.PartType.Cylinder
    cake.Size = Vector3.new(2, 4, 4)
    cake.Material = isGlow and Enum.Material.Neon or Enum.Material.SmoothPlastic
    cake.Color = isGlow and Color3.fromRGB(100, 255, 255) or rarityData.Color

    local angle = math.random() * math.pi * 2
    local radius = math.random(12, CakeConfig.SpawnRadius)
    cake.Position = root.Position + Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
    cake:SetAttribute("CakeId", HttpService:GenerateGUID(false))
    cake:SetAttribute("Health", rarityData.Health)
    cake:SetAttribute("MaxHealth", rarityData.Health)
    cake:SetAttribute("RewardCakePoints", rarityData.RewardCakePoints)
    cake:SetAttribute("IsGlow", isGlow)
    cake.Parent = runtimeFolder
    cakeOwners[cake] = player
    makeCakeLabel(cake, rarityData, rarityData.Health, rarityData.Health, isGlow)

    task.delay(45, function()
        if cake.Parent then
            cakeOwners[cake] = nil
            cake:Destroy()
        end
    end)
end

CakeEatRequest.OnServerEvent:Connect(function(player, cake)
    local state = playerState[player]
    if not state or typeof(cake) ~= "Instance" or not cake:IsDescendantOf(runtimeFolder) or cakeOwners[cake] ~= player then
        return
    end
    if eatingLocks[player] then
        return
    end

    eatingLocks[player] = true
    local eatPower = CakeConfig.BaseEatDamagePerSecond + getEffectiveStat(state, "EatSpeed")
    local hp = cake:GetAttribute("Health") or 1
    local maxHp = cake:GetAttribute("MaxHealth") or hp
    local reward = cake:GetAttribute("RewardCakePoints") or 1
    local isGlow = cake:GetAttribute("IsGlow") == true

    hp -= eatPower
    cake:SetAttribute("Health", hp)

    local rarityData = CakeConfig.Rarities.Common
    makeCakeLabel(cake, rarityData, math.max(0, hp), maxHp, isGlow)

    if hp <= 0 then
        state.CakePoints += reward
        state.WheelSpins += 1
        if isGlow then
            state.PendingCardDraw = true
        end
        cakeOwners[cake] = nil
        cake:Destroy()
        pushState(player)
    end

    task.delay(1, function()
        eatingLocks[player] = nil
    end)
end)

Players.PlayerAdded:Connect(function(player)
    playerState[player] = {
        WheelSpins = 0,
        WheelPoints = 0,
        CakePoints = 0,
        PendingCardDraw = false,
        Buffs = {},
        UnlockedWheelRewards = {},
        UnlockedCards = {},
    }

    task.spawn(function()
        while player.Parent do
            spawnCakeNear(player)
            pushState(player)
            task.wait(CakeConfig.SpawnInterval)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    playerState[player] = nil
    eatingLocks[player] = nil
    for cake, owner in cakeOwners do
        if owner == player then
            cakeOwners[cake] = nil
            if cake.Parent then
                cake:Destroy()
            end
        end
    end
end)
]=]

local mainGui = getOrCreate(StarterGui, "ScreenGui", "CakeRainRNGHUD")
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = false

local clientScript = getOrCreate(StarterPlayer.StarterPlayerScripts, "LocalScript", "CakeRainRNGClient")
clientScript.Source = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Configs = ReplicatedStorage:WaitForChild("Configs")
local RequestWheelSpin = Events:WaitForChild("RequestWheelSpin")
local RequestCardDraw = Events:WaitForChild("RequestCardDraw")
local UpdateClientState = Events:WaitForChild("UpdateClientState")
local CakeEatRequest = Events:WaitForChild("CakeEatRequest")
local LocalizationConfig = require(Configs:WaitForChild("LocalizationConfig"))
local L = LocalizationConfig["zh-tw"]

local gui = player:WaitForChild("PlayerGui"):WaitForChild("CakeRainRNGHUD")
gui:ClearAllChildren()

local state = {
    WheelSpins = 0,
    WheelPoints = 0,
    CakePoints = 0,
    ActiveBuffs = {},
    PendingCardDraw = false,
}

local function makeText(parent, name, text, size, position, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.35
    label.Text = text
    label.Parent = parent
    return label
end

local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0, 280, 0, 105)
statsFrame.Position = UDim2.new(0, 18, 0, 18)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 32)
statsFrame.BackgroundTransparency = 0.15
statsFrame.Parent = gui
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 14)

local spinsLabel = makeText(statsFrame, "SpinsLabel", "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 8), Color3.fromRGB(255, 224, 120))
local wheelPointsLabel = makeText(statsFrame, "WheelPointsLabel", "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 38), Color3.fromRGB(170, 220, 255))
local cakePointsLabel = makeText(statsFrame, "CakePointsLabel", "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 68), Color3.fromRGB(255, 180, 220))

local wheelFrame = Instance.new("Frame")
wheelFrame.Name = "RightHalfWheel"
wheelFrame.Size = UDim2.new(0, 300, 0, 300)
wheelFrame.Position = UDim2.new(1, -150, 0.5, -150)
wheelFrame.BackgroundColor3 = Color3.fromRGB(45, 34, 68)
wheelFrame.BackgroundTransparency = 0.08
wheelFrame.ClipsDescendants = true
wheelFrame.Visible = false
wheelFrame.Parent = gui
Instance.new("UICorner", wheelFrame).CornerRadius = UDim.new(1, 0)

local spinButton = Instance.new("TextButton")
spinButton.Name = "SpinButton"
spinButton.Size = UDim2.new(0, 120, 0, 52)
spinButton.Position = UDim2.new(0, 22, 0.5, -26)
spinButton.BackgroundColor3 = Color3.fromRGB(255, 185, 80)
spinButton.Font = Enum.Font.GothamBlack
spinButton.TextScaled = true
spinButton.Text = L.UI_Spin
spinButton.TextColor3 = Color3.fromRGB(60, 35, 10)
spinButton.Parent = wheelFrame
Instance.new("UICorner", spinButton).CornerRadius = UDim.new(0, 14)

local slotLabels = {}
for index = 1, 5 do
    local label = makeText(wheelFrame, "Slot" .. index, "?", UDim2.new(0, 145, 0, 34), UDim2.new(0, 4, 0, 20 + (index - 1) * 44), Color3.fromRGB(255, 255, 255))
    label.TextXAlignment = Enum.TextXAlignment.Left
    slotLabels[index] = label
end

local buffFrame = Instance.new("Frame")
buffFrame.Name = "BuffStatus"
buffFrame.Size = UDim2.new(0, 360, 0, 80)
buffFrame.Position = UDim2.new(0.5, -180, 1, -102)
buffFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 45)
buffFrame.BackgroundTransparency = 0.15
buffFrame.Visible = false
buffFrame.Parent = gui
Instance.new("UICorner", buffFrame).CornerRadius = UDim.new(0, 16)
local buffLabel = makeText(buffFrame, "BuffLabel", L.UI_No_Buff, UDim2.new(1, -22, 1, -16), UDim2.new(0, 11, 0, 8), Color3.fromRGB(180, 255, 180))

local cardFrame = Instance.new("Frame")
cardFrame.Name = "CardDraw"
cardFrame.Size = UDim2.new(0, 380, 0, 210)
cardFrame.Position = UDim2.new(0.5, -190, 0.5, -105)
cardFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 70)
cardFrame.Visible = false
cardFrame.Parent = gui
Instance.new("UICorner", cardFrame).CornerRadius = UDim.new(0, 18)
local cardTitle = makeText(cardFrame, "Title", L.UI_Card_Draw, UDim2.new(1, -20, 0, 48), UDim2.new(0, 10, 0, 16), Color3.fromRGB(120, 255, 255))
local cardResult = makeText(cardFrame, "Result", "", UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 76), Color3.fromRGB(255, 255, 255))
local cardButton = Instance.new("TextButton")
cardButton.Name = "DrawButton"
cardButton.Size = UDim2.new(0, 160, 0, 48)
cardButton.Position = UDim2.new(0.5, -80, 1, -62)
cardButton.BackgroundColor3 = Color3.fromRGB(110, 255, 255)
cardButton.Font = Enum.Font.GothamBlack
cardButton.TextScaled = true
cardButton.Text = "DRAW"
cardButton.TextColor3 = Color3.fromRGB(20, 30, 45)
cardButton.Parent = cardFrame
Instance.new("UICorner", cardButton).CornerRadius = UDim.new(0, 14)

local function refresh()
    spinsLabel.Text = L.UI_Spins_Left .. tostring(state.WheelSpins)
    wheelPointsLabel.Text = L.UI_WheelPoints .. tostring(state.WheelPoints)
    cakePointsLabel.Text = L.UI_CakePoints .. tostring(state.CakePoints)

    wheelFrame.Visible = state.WheelSpins > 0
    cardFrame.Visible = state.PendingCardDraw

    local bestText
    for _, buff in state.ActiveBuffs do
        bestText = string.format("%s [%s] +%s / %ss", buff.Name, buff.Rarity, tostring(buff.Value), tostring(buff.Remaining))
        break
    end
    buffFrame.Visible = bestText ~= nil
    buffLabel.Text = bestText or L.UI_No_Buff
end

UpdateClientState.OnClientEvent:Connect(function(newState)
    for key, value in newState do
        state[key] = value
    end
    refresh()
end)

spinButton.Activated:Connect(function()
    local result = RequestWheelSpin:InvokeServer()
    if not result or not result.Ok then
        return
    end
    for index, slot in result.Slots do
        if slotLabels[index] then
            slotLabels[index].Text = slot.Name
            slotLabels[index].TextColor3 = slot.Key == result.Picked.Key and Color3.fromRGB(255, 240, 120) or Color3.fromRGB(255, 255, 255)
        end
    end
end)

cardButton.Activated:Connect(function()
    local result = RequestCardDraw:InvokeServer()
    if result and result.Ok and result.Card then
        cardResult.Text = result.Card.Name .. " [" .. result.Card.Rarity .. "]"
    end
end)

local currentCake
RunService.RenderStepped:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local nearest
    local nearestDistance = 8
    local runtimeCakes = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("RuntimeCakes")
    if runtimeCakes then
        for _, cake in runtimeCakes:GetChildren() do
            if cake:IsA("BasePart") then
                local distance = (cake.Position - root.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = cake
                end
            end
        end
    end

    currentCake = nearest
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.E and currentCake then
        CakeEatRequest:FireServer(currentCake)
    end
end)

local hint = makeText(gui, "EatHint", "靠近蛋糕按 E 吞食", UDim2.new(0, 300, 0, 36), UDim2.new(0.5, -150, 0, 18), Color3.fromRGB(255, 255, 255))
refresh()
]=]

if recording then
    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

Selection:Set({serverScript, clientScript, mainGui, wheelConfig, cakeConfig, cardConfig, uiConfig, localizationConfig, mapBase, cakeTemplate})
print("✅ Cake Rain RNG（蛋糕狂降 RNG）完整模組化雛形已構建：蛋糕雨、半圓轉盤、點數、Buff 覆蓋、發光蛋糕抽卡與情境 UI 已配置完成。")
