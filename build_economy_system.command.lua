local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local Selection = game:GetService("Selection")

local recording = nil
local ok, result = pcall(function()
    return ChangeHistoryService:TryBeginRecording("Codex_Build_Economy_System")
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
local mapFolder = getOrCreate(workspace, "Folder", "Map")

local grantCoinsEvent = getOrCreate(eventsFolder, "RemoteEvent", "GrantCoinsEvent")

local economyConfig = getOrCreate(configsFolder, "ModuleScript", "EconomyConfig")
economyConfig.Source = [=[
local EconomyConfig = {
    DefaultCoins = 100,
    CoinReward = 25,
    DataStoreKey = "PlayerEconomy_v1"
}

return EconomyConfig
]=]

local dataManagerScript = getOrCreate(ServerScriptService, "Script", "DataManager")
dataManagerScript.Source = [=[
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Configs.EconomyConfig)
local GrantCoinsEvent = ReplicatedStorage.Events.GrantCoinsEvent
local playerDataStore = DataStoreService:GetDataStore(EconomyConfig.DataStoreKey)

local function getCoins(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return nil
    end

    return leaderstats:FindFirstChild("Coins")
end

local function savePlayer(player)
    local coins = getCoins(player)
    if not coins then
        return
    end

    local key = "Player_" .. player.UserId
    local success, err = pcall(function()
        playerDataStore:SetAsync(key, {
            Coins = coins.Value
        })
    end)

    if not success then
        warn("Failed to save economy data for", player.Name, err)
    end
end

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = EconomyConfig.DefaultCoins
    coins.Parent = leaderstats

    local key = "Player_" .. player.UserId
    local success, savedData = pcall(function()
        return playerDataStore:GetAsync(key)
    end)

    if success and typeof(savedData) == "table" and typeof(savedData.Coins) == "number" then
        coins.Value = savedData.Coins
    elseif not success then
        warn("Failed to load economy data for", player.Name, savedData)
    end
end)

Players.PlayerRemoving:Connect(savePlayer)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayer(player)
    end
end)

GrantCoinsEvent.OnServerEvent:Connect(function(player)
    local coins = getCoins(player)
    if not coins then
        return
    end

    coins.Value += EconomyConfig.CoinReward
end)
]=]

local mainGui = getOrCreate(StarterGui, "ScreenGui", "MainHUD")
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = false

local coinFrame = getOrCreate(mainGui, "Frame", "CoinFrame")
coinFrame.Size = UDim2.new(0, 190, 0, 52)
coinFrame.Position = UDim2.new(0, 20, 0, 20)
coinFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
coinFrame.BorderSizePixel = 0

local corner = getOrCreate(coinFrame, "UICorner", "Corner")
corner.CornerRadius = UDim.new(0, 12)

local coinText = getOrCreate(coinFrame, "TextLabel", "CoinLabel")
coinText.Size = UDim2.new(1, -16, 1, 0)
coinText.Position = UDim2.new(0, 8, 0, 0)
coinText.BackgroundTransparency = 1
coinText.Font = Enum.Font.GothamBold
coinText.TextColor3 = Color3.fromRGB(255, 215, 0)
coinText.TextSize = 20
coinText.TextXAlignment = Enum.TextXAlignment.Left
coinText.Text = "Coins: 0"

local rewardButton = getOrCreate(mainGui, "TextButton", "RewardButton")
rewardButton.Size = UDim2.new(0, 190, 0, 48)
rewardButton.Position = UDim2.new(0, 20, 0, 84)
rewardButton.BackgroundColor3 = Color3.fromRGB(72, 130, 255)
rewardButton.Font = Enum.Font.GothamBold
rewardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rewardButton.TextSize = 18
rewardButton.Text = "+25 Coins"

local buttonCorner = getOrCreate(rewardButton, "UICorner", "Corner")
buttonCorner.CornerRadius = UDim.new(0, 12)

local starterScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local uiController = getOrCreate(starterScripts, "LocalScript", "UIController")
uiController.Source = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local grantCoinsEvent = ReplicatedStorage.Events:WaitForChild("GrantCoinsEvent")

local function setupCoins()
    local leaderstats = localPlayer:WaitForChild("leaderstats", 10)
    if not leaderstats then
        return
    end

    local coins = leaderstats:WaitForChild("Coins", 10)
    if not coins then
        return
    end

    local gui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainHUD")
    local coinLabel = gui.CoinFrame.CoinLabel
    local rewardButton = gui.RewardButton

    local function updateText()
        coinLabel.Text = "Coins: " .. tostring(coins.Value)
    end

    coins.Changed:Connect(updateText)
    rewardButton.Activated:Connect(function()
        grantCoinsEvent:FireServer()
    end)
    updateText()
end

task.spawn(setupCoins)
]=]

local rewardPlatform = getOrCreate(mapFolder, "Part", "RewardPlatform")
rewardPlatform.Anchored = true
rewardPlatform.CanCollide = true
rewardPlatform.Size = Vector3.new(12, 1, 12)
rewardPlatform.Position = Vector3.new(0, 0.5, 0)
rewardPlatform.Material = Enum.Material.Neon
rewardPlatform.Color = Color3.fromRGB(255, 215, 0)

local sampleCoin = getOrCreate(modelsFolder, "Part", "SampleCoin")
sampleCoin.Anchored = true
sampleCoin.CanCollide = false
sampleCoin.Shape = Enum.PartType.Cylinder
sampleCoin.Size = Vector3.new(0.3, 3, 3)
sampleCoin.Color = Color3.fromRGB(255, 215, 0)
sampleCoin.Material = Enum.Material.Metal

if recording then
    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end

Selection:Set({dataManagerScript, mainGui, uiController, rewardPlatform, sampleCoin})
print("✅ 基礎 DataStore 經濟系統、金幣 UI、事件、設定、模型與地圖平台已完成構建。")
