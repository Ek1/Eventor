Eventor = {
	TITLE = "Eventor - Events Spam Online",	-- Not codereview friendly but enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "One stop event add-on.",
	VERSION = "32.20201002",
	VARIABLEVERSION = "32",
	LIECENSE = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/Eventor"
}
local ADDON = "Eventor"	-- Variable used to refer to this add-on. Codereview friendly.

accountEventLootHistory = {}
accountEventLootHistory[0] = 0

todaysDate = os.date("%Y-%m-%d")

EVENTLOOT = {
    [167226] = 1,	-- Lost treasures of Skyrim, grindable
    [167227] = 2	-- Lost treasures of Skyrim, daily
}

-- Lets fire up the add-on by registering for events and loading variables
function Eventor.Initialize()
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_LOOT_RECEIVED, Eventor.lootedEventBox)	-- Start listening to gained loot
end

-- Setter that keeps count of how many boxes this character has looted 
-- 100031	EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function Eventor.lootedEventBox(eventCode, name, itemLink, quantity, itemSound, lootType, lootedByPlayer, isPickpocketLoot, questItemIcon, itemId)

	if lootedByPlayer and EVENTLOOT[itemId] then

		if not accountEventLootHistory[itemId] then	-- Does itemId loot have a table
			accountEventLootHistory[itemId] = {}	-- if not, create one
			d( ADDON .. ": creating table for " .. itemLink)
		end

		if not accountEventLootHistory[itemId][todaysDate] then	-- Is this itemId's first entry for this date?
			accountEventLootHistory[itemId][todaysDate] = 0	-- if not, create one
			d( ADDON .. ": creating datekey " .. todaysDate .. " inside " .. itemLink .. " table")
		end

		accountEventLootHistory[itemId][todaysDate] = accountEventLootHistory[itemId][todaysDate] + 1
		d( ADDON .. ": " .. (zo_strformat("<<i:1>>", accountEventLootHistory[itemId][todaysDate])) .. " ".. itemLink )
	end
end

-- Here the magic starts
local loadOrder = 1	-- Variable to keep count how many loads have been done before it was this ones turn.
function Eventor.EVENT_ADD_ON_LOADED(_, loadedAddOnName)
  if loadedAddOnName == ADDON then
	--	Seems it is our time so lets stop listening load trigger and initialize the add-on
	d( Eventor.TITLE .. ": load order " ..  loadOrder .. ", starting initalization")
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    accountEventLootHistory   = ZO_SavedVars:NewAccountWide("Eventor_accountEventLootHistory", 1, GetWorldName(), default)

	todaysDate = os.date("%Y%m%d")
	Eventor.Initialize()
  else
	loadOrder = loadOrder + 1
  end
end
-- Registering for the add on loading loop
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, Eventor.EVENT_ADD_ON_LOADED )