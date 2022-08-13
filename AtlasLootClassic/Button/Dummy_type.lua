local ALName, ALPrivate = ...

local _G = _G
local AtlasLoot = _G.AtlasLoot
local AL, ALIL = AtlasLoot.Locales, AtlasLoot.IngameLocales
local ClickHandler = AtlasLoot.ClickHandler
local Token = AtlasLoot.Data.Token

local TYPE, ID_INV, ID_ICON, ID_ABILITY, ID_ADDON, ID_CLASS = "Dummy", "INV_", "ICON_", "ABILITY_", "ADDON_", "CLASS_"
local Dummy = AtlasLoot.Button:AddType(TYPE, ID_INV)
AtlasLoot.Button:DisableDescriptionReplaceForce(TYPE, true)
local Dummy_ID_ICON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ICON)
local Ability_ID_ICON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ABILITY)
local Dummy_ID_ADDON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ADDON)
local Dummy_ID_CLASS = AtlasLoot.Button:AddIdentifier(TYPE, ID_CLASS)

-- lua
local format, str_match = string.format, _G.string.match

-- WoW


local ITEM_DESC_EXTRA_SEP = "%s | %s"
local DUMMY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local INTERFACE_PATH = "Interface\\Icons\\"


local ItemClickHandler = nil
ClickHandler:Add(
	"Dummy",
	{
		ShowExtraItems = { "LeftButton", "None" },
		types = {
			ShowExtraItems = true,
		},
	},
	{
		{ "ShowExtraItems", AL["Show extra items"], 	AL["Shows extra items (tokens,mats)"] },
	}
)

local function OnInit()
	if not ItemClickHandler then
		ItemClickHandler = ClickHandler:GetHandler("Dummy")
	end
	Dummy.ItemClickHandler = ItemClickHandler
end
AtlasLoot:AddInitFunc(OnInit)

function Dummy.OnSet(button, second)
	if not button then return end
	if second and button.__atlaslootinfo.secType then
		button.secButton.Texture = button.__atlaslootinfo.secType[2]
		button.secButton.Name = button.__atlaslootinfo.Name
		button.secButton.Description = button.__atlaslootinfo.Description
		button.secButton.Extra = button.__atlaslootinfo.Extra
		Dummy.Refresh(button.secButton)
	else
		button.Texture = button.__atlaslootinfo.type[2]
		button.Name = button.__atlaslootinfo.Name
		button.Description = button.__atlaslootinfo.Description
		button.Extra = button.__atlaslootinfo.Extra
		Dummy.Refresh(button)
	end
end

function Dummy.OnClear(button)
	button.Texture = nil
	button.Name = nil
	button.Description = nil
	button.Extra = nil
	button.secButton.Texture = nil
	button.secButton.Name = nil
	button.secButton.Description = nil
	button.secButton.Extra = nil

	if button.ExtraFrameShown then
		AtlasLoot.Button:ExtraItemFrame_ClearFrame()
		button.ExtraFrameShown = false
	end
end

function Dummy.Refresh(button)
	if button.type == "secButton" then

	else
		button.name:SetText(button.Name)
		local desc
		if button.Extra and Token.IsToken(button.Extra) then
			local tokenDesc = Token.GetTokenDescription(button.Extra)
			if button.Description and Token.TokenTypeAddDescription(button.Extra) then
				desc = format(ITEM_DESC_EXTRA_SEP, button.Description, tokenDesc)
			else
				desc = tokenDesc
			end
		else
			desc = button.Description
		end
		button.extra:SetText(desc)
	end
	button.overlay:Hide()
	button.icon:SetTexture(tonumber(button.Texture) or (button.Texture and button.Texture or DUMMY_ICON))
end

function Dummy.OnMouseAction(button, mouseButton)
	if not mouseButton then return end

	mouseButton = ItemClickHandler:Get(mouseButton) or mouseButton
	if mouseButton == "ShowExtraItems" then
		if button.Extra and Token.IsToken(button.Extra) then
			button.ExtraFrameShown = true
			AtlasLoot.Button:ExtraItemFrame_GetFrame(button, Token.GetTokenData(button.Extra))
		end
	end

end

function Dummy.GetStringContent(str)
	return INTERFACE_PATH..ID_INV..str
end

function Dummy_ID_ICON.GetStringContent(str)
	return INTERFACE_PATH..str
end

function Dummy_ID_ADDON.GetStringContent(str)
	return ALPrivate.ICONS_PATH..str
end

function Dummy_ID_CLASS.GetStringContent(str)
	return ALPrivate.CLASS_ICON_PATH[str]
end