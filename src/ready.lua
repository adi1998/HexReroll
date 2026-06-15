game.ScreenData.SpellScreen.ComponentData.ActionBar.Children.RerollButton = {
    Graphic = "ContextualActionButton",
    Alpha = 0.0,
    Data =
    {
        OnMouseOverFunctionName = "MouseOverContextualAction",
        OnMouseOffFunctionName = "MouseOffContextualAction",
        OnPressedFunctionName = "AttemptPanelReroll",
        ControlHotkeys = { "Reroll", },
    },
    Text = " ",
    AltText = "Boon_Reroll",
    TextArgs = game.UIData.ContextualButtonFormatRight,
}

table.insert(game.ScreenData.SpellScreen.ComponentData.ActionBar.ChildrenOrder, "RerollButton")

game.ScreenData.SpellScreen.ComponentData.RerollIcon =
{
    X = 1865,
    Y = 990,
    Animation = "RerollIcon",
    Scale = 0.6,
    Alpha = 0.0,
    AlphaTarget = 0.0,
    TextArgs = game.ScreenData.HUD.ComponentData.RerollIcon.TextArgs
}

modutil.mod.Path.Wrap("CreateSpellButtons", function (base, screen)
    local components = screen.Components
    local lootData = screen.Source

    if game.HeroHasTrait( "PanelRerollMetaUpgrade" ) and not screen[_PLUGIN.guid .. "RerollInit"] then
		screen.MovedRerollUIGroup = true
		game.RemoveFromGroup({ Id = game.ScreenAnchors.Reroll, Name = "Combat_UI" })
		game.AddToGroup({ Id = game.ScreenAnchors.Reroll, Name = "Combat_Menu_Overlay", DrawGroup = true })
		game.ModifyTextBox({ Id = components.RerollIcon.Id, Text = game.CurrentRun.NumRerolls, AutoSetDataProperties = false, })
		game.SetAlpha({ Id = components.RerollIcon.Id, Duration = game.HUDScreen.FadeInDuration, Fraction = game.ConfigOptionCache.HUDOpacity })
        screen[_PLUGIN.guid .. "RerollInit"] = true
	end

    base(screen)

    if game.HeroHasTrait( "PanelRerollMetaUpgrade" ) then
		local cost = 1
		local baseCost = cost

		local name = "Boon_Reroll"
		if cost >= 0 then

			local increment = 0
			if game.CurrentRun.CurrentRoom.SpentRerolls then
				increment = game.CurrentRun.CurrentRoom.SpentRerolls[lootData.ObjectId] or 0
			end
			cost = cost + increment
		else
			name = "RerollPanel_Blocked"
		end
		components.RerollButton.Cost = cost
		if game.CurrentRun.NumRerolls < cost or cost < 0 then
			game.SetAlpha({ Id = screen.Components.RerollButton.Id, Fraction = 0.0, Duration = 0.2 })
		elseif baseCost > 0 then
			components.RerollButton.OnPressedFunctionName = "AttemptPanelReroll"
			components.RerollButton.RerollFunctionName = _PLUGIN.guid .. "." .. "RerollSpellLoot"
			components.RerollButton.RerollColor = lootData.LootColor
			components.RerollButton.RerollId = lootData.ObjectId
			components.RerollButton.LootData = lootData
			components.RerollButton.Cost = cost
			game.ModifyTextBox({ Id = components.RerollButton.Id, Text = name, LuaKey = "TempTextData", LuaValue = { Amount = cost }})

			game.SetAlpha({ Id = screen.Components.RerollButton.Id, Fraction = 1.0, Duration = 0.2 })
		else
			game.SetAlpha({ Id = screen.Components.RerollButton.Id, Fraction = 0.0, Duration = 0.2 })
		end
	end
end)

function mod.DestroySpellButtons(screen)
    local components = screen.Components
    local toDestroy = {}
    for index = 1, 3 do
        local purchaseButtonKey = "PurchaseButton"..index
        local destroyIndexes = {
            "PurchaseButton"..index,
            "PurchaseButtonTitle"..index,
            purchaseButtonKey.."Highlight",
            "Icon"..index,
            purchaseButtonKey.."QuestIcon",
            purchaseButtonKey.."Frame",
            "DuoOverlay"..index,
            purchaseButtonKey.."MoonIcon",
            purchaseButtonKey.."OlympianDuo",
        }
        for i, indexName in pairs( destroyIndexes ) do
            if components[indexName] then
                table.insert(toDestroy, components[indexName].Id)
                components[indexName] = nil
            end
        end
    end
    game.Destroy({ Ids = toDestroy })
end

function mod.RerollSpellLoot(screen, button)
    mod.DestroySpellButtons(screen)
    game.ModifyTextBox({ Id = screen.Components.RerollIcon.Id, Text = game.CurrentRun.NumRerolls, AutoSetDataProperties = false })
    game.CreateSpellButtons(screen)
end