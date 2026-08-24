# 《Cake Rain RNG（蛋糕狂降 RNG）》完整遊戲設計企劃書

本遊戲是一款主打「純粹 RNG 轉盤／抽卡」、「時間無限疊加」、「零永久屬性」、「隱藏式動態 UI」與「完全模組化 Config 架構」的 Roblox 模擬器遊戲。遊戲包含轉盤點數商店、階層化能力覆蓋機制與半圓右側隱藏式轉盤 UI。

## 🍰 一、核心機制與動態蛋糕系統

- **天降蛋糕雨**：玩家周圍隨機降下蛋糕，踩上即可吞食。
- **零永久屬性**：所有玩家初始數值相同，吞食傷害預設每秒 `-1` 血量，無任何可購買的永久能力提升。
- **動態等級標籤（BillboardGui）**：每個蛋糕上方懸浮 3D 文字標籤，顯示 `[稀有度/等級]` 與 `[當前血量/總血量]`，例如 `[LEGENDARY] 傳說蛋糕 (HP: 80/80)`，顏色隨等級變化。

## 🎰 二、半圓動態轉盤、轉盤點數與等級覆蓋機制

- **半圓形隱藏 UI**：轉盤為圓形介面，吸附在螢幕右側且僅露出左半邊，以降低視線遮擋。當轉盤次數 `> 0` 時才會顯示，次數為 `0` 時自動收回隱藏。
- **動態 5 槽位池**：每次旋轉時，轉盤只會從玩家目前已解鎖的獎池中，隨機挑選 5 個可用選項帶入當前轉盤扇區中。無法透過升級增加槽位數量，槽位固定為 5 個。
- **轉盤點數（Wheel Points）**：
  - 每進行 1 次轉盤抽獎，即可獲得 1 點轉盤點數。
  - 點數可用於在「轉盤點數商店」中購買並解鎖全新獎項，例如 `+10%~50% 發光蛋糕生成概率`。
  - 解鎖後，該獎項正式加入 5 槽位抽取池中。
- **轉盤完整品質等級**：轉盤獎項設有 `Common`、`Rare`、`Epic`、`Legendary`、`Mythic` 等標準稀有度。品質影響能力強度（增幅數值），但基礎增幅時間保持固定，例如 `Common` 與 `Legendary` 的基礎時間皆可為 20 秒或 60 秒，但數值強度不同。
- **高階覆蓋與順序消耗機制**：
  - 高低等級的同類增益不直接相加，而是實施「高階優先消耗」。
  - 運作範例：若玩家擁有 1 分鐘的 `Common 吞食速度 (+1)`，此時抽中 1 分鐘的 `Legendary 吞食速度 (+5)`，系統將優先消耗 `Legendary`，吃速為 `+5`。當 `Legendary` 的 1 分鐘倒數完畢後，自動無縫切換回 `Common`，吃速降回 `+1`，並繼續倒數剩餘時間。

## 🃏 三、發光蛋糕「抽卡」系統

- 天空低機率掉落發光蛋糕，頂部顯示 `[SPECIAL] 發光蛋糕` 標籤，踩上即觸發「抽卡介面」。
- 抽中後的持續時間與效果完全由 Config 自訂。
- 可透過蛋糕積分商店解鎖新卡牌加入卡池。

## 💰 四、代幣系統與商店分工

遊戲內兩種代幣皆不提供任何永久基礎屬性提升，劃分如下：

- **轉盤點數（Wheel Points）**：每抽 1 次轉盤累計 1 點，專門用於購買與解鎖更多可被放入轉盤 5 槽位池的獎項。
- **蛋糕積分（Cake Points）**：吃蛋糕獲得，用於解鎖發光蛋糕抽卡新技能、外觀特效、名牌頭銜與地圖主題。

## 🖥️ 五、情境式動態 UI 系統（僅在可用時顯示）

- **右側半圓轉盤 UI**：僅在轉盤次數 `> 0` 時貼合螢幕右側彈出露出半邊；次數為 `0` 時隱藏。
- **自動抽獎介面（Auto-Roll UI）**：持有 Auto-Roll 持續時間時才顯示。
- **發光蛋糕抽卡介面（Card Draw UI）**：僅在踩上發光蛋糕時跳出，抽卡完成後自動隱藏。
- **狀態與倒數面板（Buff Status UI）**：顯示當前最高優先級的生效 Buff、數值與時間倒數。高階 Buff 消耗完切換至低階時，面板自動同步更換數據。

## ⚙️ 六、多重模組化 Config 架構

### 1. 微型轉盤獎池與等級配置 `WheelConfig.lua`

```lua
local WheelConfig = {
    -- 基礎獎項（普通與高階等級劃分，時間固定，強度不同）
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

    -- 發光蛋糕生成概率增幅（需透過轉盤點數購買解鎖，套用完整等級）
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

    -- 自動抽獎權限
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
}

return WheelConfig
```

### 2. 多語言字典模組 `LocalizationConfig.lua`

```lua
local LocalizationConfig = {
    ["zh-tw"] = {
        UI_Spins_Left = "剩餘轉盤次數: ",
        UI_WheelPoints = "轉盤點數: ",
        UI_AutoRoll_Active = "自動抽獎運行中...",
        UI_Shop_Title = "蛋糕積分商店",
        UI_WheelShop_Title = "轉盤點數商店",
        UI_Time_Left = "剩餘時間: ",
        Cake_Common = "普通蛋糕",
        Cake_Legendary = "傳說蛋糕",
        Reward_EatSpeed_Common = "+1 吞食速度 (普通)",
        Reward_EatSpeed_Legend = "+5 吞食速度 (傳說)",
        Reward_GlowBoost_Rare = "+10% 發光蛋糕率 (20秒)",
        Reward_GlowBoost_Mythic = "+50% 發光蛋糕率 (20秒)",
        Reward_AutoRoll_Common = "初級自動抽獎 (普通)",
        Card_Gluttony = "大胃王",
    },
    ["en-us"] = {
        UI_Spins_Left = "Spins Left: ",
        UI_WheelPoints = "Wheel Points: ",
        UI_AutoRoll_Active = "Auto-Roll Active...",
        UI_Shop_Title = "Cake Point Shop",
        UI_WheelShop_Title = "Wheel Point Shop",
        UI_Time_Left = "Time Left: ",
        Cake_Common = "Common Cake",
        Cake_Legendary = "Legendary Cake",
        Reward_EatSpeed_Common = "+1 Eat Speed (Common)",
        Reward_EatSpeed_Legend = "+5 Eat Speed (Legendary)",
        Reward_GlowBoost_Rare = "+10% Glow Cake Spawn (20s)",
        Reward_GlowBoost_Mythic = "+50% Glow Cake Spawn (20s)",
        Reward_AutoRoll_Common = "Basic Auto-Roll (Common)",
        Card_Gluttony = "Gluttony",
    },
}

return LocalizationConfig
```

### 3. 蛋糕等級設定 `CakeConfig.lua`

```lua
local CakeConfig = {
    Common = {
        NameKey = "Cake_Common",
        RarityText = "COMMON",
        Color = Color3.fromRGB(200, 200, 200),
        DropWeight = 500,
        HealthMult = 1,
        RewardMult = 1,
    },
    Legendary = {
        NameKey = "Cake_Legendary",
        RarityText = "LEGENDARY",
        Color = Color3.fromRGB(255, 170, 0),
        DropWeight = 8,
        HealthMult = 8,
        RewardMult = 15,
    },
}

return CakeConfig
```

### 4. 發光蛋糕卡牌與商店解鎖 `CardConfig.lua`

```lua
local CardConfig = {
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
}

return CardConfig
```

### 5. 情境 UI 與半圓轉盤設定 `UIConfig.lua`

```lua
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
    BuffStatus = {
        AutoHide = true,
        ShowCondition = "ActiveBuffsCount > 0",
        TitleKey = "UI_Time_Left",
    },
    ShopUI = {
        AutoHide = true,
        ShowCondition = "ManualOpen",
        TitleKey = "UI_Shop_Title",
    },
}

return UIConfig
```
