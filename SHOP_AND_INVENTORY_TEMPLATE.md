# Shop and Inventory Configuration Template

This project now treats the shop as a configuration-driven template. Add or remove goods by editing the `ShopConfig` tables in `build_cake_rain_rng.command.lua`; the server reads those entries and the UI renders what the config returns.

## Shop item fields

```lua
{
    Id = "Unique_Item_Id",
    Grants = "Reward_Or_Card_Key", -- optional; defaults to Id
    NameKey = "Localization_Key",
    Cost = 1200,
    Currency = "CakePoints", -- "CakePoints" or "WheelPoints"
    UnlockType = "Card", -- "Card" or "WheelReward"
    Icon = "rbxassetid://6031068421",
    Weight = 1, -- optional for merchant random pools
}
```

## Example: normal Cake Point shop item

```lua
{ Id = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1500, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421" }
```

## Example: merchant item that grants an existing card

```lua
{ Id = "Merchant_Tornado", Grants = "Card_Tornado", NameKey = "Card_Tornado", Cost = 1200, Currency = "CakePoints", UnlockType = "Card", Icon = "rbxassetid://6031068421", Weight = 2 }
```

## Inventory behavior

- The bag has two modes: `Terms` for wheel terms/affixes, and `Skills` for skill cards.
- Terms keep the original upgrade flow.
- Skills are equipped into five server-saved slots via `RequestEquipSkill`.
- The reward wheel can only draw skill cards that are currently equipped in those five slots.

## Persistence checklist

The server serializes the core fields required for re-login persistence:

- `CakePoints`, `WheelPoints`, `WheelSpins`, and cumulative `TotalRolls`.
- Owned wheel terms and owned skill cards.
- Ability levels.
- Active buffs, with remaining time saved instead of client-controlled timestamps.
- Equipped skill slots.
