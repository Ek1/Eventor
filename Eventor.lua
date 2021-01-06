Eventor = {
	TITLE = "Eventor - Events Spam Online",	-- Not codereview friendly but enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "One stop event add-on about the numerous ticket giving ESO events to keep track what you have done, how many and when. Keeps up your exp buff too. Also warns if you can't fit any more tickets. v33.201221.1",
	VERSION = "33.201221.1",
	VARIABLEVERSION = "32",
	LIECENSE = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/Eventor"
}
local ADDON = "Eventor"	-- Variable used to refer to this add-on. Codereview friendly.
local Event_is_active = false	-- default is that it is off.

accountEventLootHistory = {}
accountEventLootHistory[CURT_EVENT_TICKETS] = {}

local Eventor_settings = {	-- default settings
	TicketThresholdAlarm =  GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) - 3,	-- 3 has been maximum reward of tickets this far
	AlarmAnnoyance	= 99999,	-- How many times user is reminded
	LongestEvent	= 35,	-- Longest known event this far in days
	LastEventDate = 20201217
}

local AlarmsRemaining = Eventor_settings.AlarmAnnoyance or 9999

local todaysDate = tonumber(os.date("%Y%m%d"))
local todaysYear = tonumber(os.date("%Y"))

local EVENTLOOT = {
	-- Undaunted Celebration
	[156679] = 2,	-- Undaunted Reward Box
	[156717] = 1,	-- Hefty Undaunted Reward Box
	[171267] = 2,	-- Undaunted Reward Box
	[171268] = 1, -- Glorious Undaunted Reward Box

	-- Midyear Mayhem
	[121526] = 2,	-- Pelinal's Midyear Boon Box

	-- Murkmire Celebration

	-- Thieves Guild and Dark Brotherhood Celebration

	-- Jester's Festival
--	[] = 2,	-- Stupendous Jester's Festival Box
--	[] = 1,	-- Jester's Festival Box

	-- Anniversary Jubilee
--	[] = 2,	-- Anniversary Jubilee Gift Box

	-- Vampire Week

	-- Midyear Mayhem

	-- Summerset Celebration

	-- Orsinium Celebration

	-- Imperial City Celebration

	-- Witches Festival
	[167234] = 2,	-- Plunder Skull
	[167235] = 1,	-- Dremora Plunder Skull, Arena
	[167236] = 1,	-- Dremora Plunder Skull, Insurgent
	[167237] = 1,	-- Dremora Plunder Skull, Delve
	[167238] = 1,	-- Dremora Plunder Skull, Dungeon
	[167239] = 1,	-- Dremora Plunder Skull, Public & Sweeper
	[167240] = 1,	-- Dremora Plunder Skull, Trial
	[167241] = 1,	-- Dremora Plunder Skull, World
	
	-- Lost treasures of Skyrim
  [167226] = 1,	-- Box of Gray Host Pillage
	[167227] = 2,	-- Bulging Box of Gray Host Pillage
	
	-- New Life Festival
	[141823] = 2,	-- New Life Festival Box
	[171327] = 2,	-- New Life Festival Box 2020? 
	[159463] = 1,	-- Stupendous Jester's Festival Box 2020? 
}

local EVENTQUESTIDS = {
	[5811] = 1,	-- Snow Bear Plunge
	[5835] = 1,	-- The Trial of Five-Clawed Guile
	[5837] = 1,	-- Lava Foot Stomp
	[5838] = 1,	-- Mud Ball Merriment
	[5839] = 1,	-- Signal Fire Sprint
	[5845] = 1,	-- Castle Charm Challenge
	[5855] = 1,	-- Fish Boon Feast
	[5856] = 1,	-- Stonetooth Bash
	[6134] = 1,	-- The New Life Festival
	[6588] = 1,	-- Old Life Observance
}

local EVENTEXPBUFFS = {
	[91449] = "Breda's Magnificent Mead",	-- New Life Festival
}

local function ticketAlert()

	if 0 < AlarmsRemaining and 9 < GetCurrencyAmount(CURT_EVENT_TICKETS, 3)	then
		d (ADDON .. ": " .. GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )

		local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
		messageParams:SetText( GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )
		CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
	end

	AlarmsRemaining = AlarmsRemaining - 1
end

-- Setter that keeps count of how many boxes this UserID has looted 
-- 100032	EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function Eventor:lootedEventBox(_, _, itemName, _, _, _, lootedByPlayer, _, _, itemId, _)

	itemId = tonumber(itemId)

	if EVENTLOOT[itemId] then	-- Only intrested about event items

		todaysDate = tonumber(os.date("%Y%m%d"))
		Eventor_settings.LastEventDate = todaysDate
		Event_is_active = true
		ticketAlert()

		if lootedByPlayer then	-- Player looted it, lets make a note

			todaysYear = tonumber(os.date("%Y"))

			if not accountEventLootHistory[itemId] then	-- Does itemId loot have a table
				accountEventLootHistory[itemId] = {}	-- if not, create one
				accountEventLootHistory[itemId][todaysYear] = 0	-- Keeps track how many boxes in total this year of the itemId
				d( ADDON .. ": creating table for " .. itemName)
			end
			accountEventLootHistory[itemId][todaysYear] = (accountEventLootHistory[itemId][todaysYear] or 0) + 1	-- increase this years loot counter by one

			if not accountEventLootHistory[itemId][todaysDate] then	-- Is this itemId's first entry for this date?
				accountEventLootHistory[itemId][todaysDate] = 0	-- if not, create one
				d( ADDON .. ": creating datekey " .. todaysDate .. " inside " .. itemName .. " table")
			end

			if EVENTLOOT[itemId] == 1 then	-- The item has drop rate of once per day so instead of increasing the date time store the time stamp
				accountEventLootHistory[itemId][todaysDate] = os.time()	-- timestamp to store.
				d( ADDON .. ": " .. itemName .. " looted today at " .. os.date("%H:%M:%S") .. " and it was " .. accountEventLootHistory[itemId][todaysYear] .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][todaysYear]) .. " this year." )
			else
				accountEventLootHistory[itemId][todaysDate] = (accountEventLootHistory[itemId][todaysDate] or 0) + 1	-- increase todays counter by one
				accountEventLootHistory[itemId][0] = os.time()	-- when the latest one was picked up
				d( ADDON .. ": " .. accountEventLootHistory[itemId][todaysDate] .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][todaysDate]) .. " ".. itemName .. " today and it was " .. accountEventLootHistory[itemId][todaysYear] .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][todaysYear]) .. " this year." )
			end
			accountEventLootHistory[0] = (accountEventLootHistory[0] or 0) + 1	-- increase over all counter by one
		end
	end
end

-- Listens if the ticket currency changes for loot reasons.
-- 100032	EVENT_CURRENCY_UPDATE (number eventCode, CurrencyType currencyType, CurrencyLocation currencyLocation, number newAmount, number oldAmount, CurrencyChangeReason reason)
function Eventor:EVENT_CURRENCY_UPDATE (_, currencyType, currencyLocation, newAmount, oldAmount, CurrencyChangeReason)

	-- If the currency updated was tickets and it was gained by loot or quest reward check if there is need for alert the user
	if currencyType == CURT_EVENT_TICKETS
		and (CurrencyChangeReason == CURRENCY_CHANGE_REASON_LOOT or CurrencyChangeReason == CURRENCY_CHANGE_REASON_QUESTREWARD) 
		and oldAmount < newAmount then
		Event_is_active = true

		todaysDate = tonumber(os.date("%Y%m%d"))	-- maybe its a new day already, better refresh the variable
		Eventor_settings.LastEventDate = todaysDate

		ticketAlert()

		if not accountEventLootHistory[CURT_EVENT_TICKETS] then
			accountEventLootHistory[CURT_EVENT_TICKETS] = {}
		end

		accountEventLootHistory[CURT_EVENT_TICKETS][todaysDate] = (newAmount - oldAmount)	-- Saves the ammount of tickets gained today
	end
end

-- 10032	EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
function Eventor:EVENT_EFFECT_CHANGED (eventCode, MsgEffectResult, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, BuffEffectType, AbilityType, StatusEffectType, unitName, unitId, abilityId, CombatUnitTypeSourceType)
--	d( ADDON  .. ": " .. MsgEffectResult .. " " .. effectName .. " " .. unitTag .. "/" .. unitName .. " " .. beginTime)
end


function Eventor_TEST()
	ticketAlert()
end


-- "/esoui/art/icons/servicemappins/servicepin_event.dds"

--[[


/zgoo mouse

ah wait. it looks like the pin is not a POI but a location pin, which is a different api
GetNumMapLocations()
* Returns: integer* numMapLocations

IsMapLocationVisible(luaindex locationIndex)
* Returns: bool* isVisible


]]



-- Impersinator POI type =  175

-- Refreshes the characters exp buff
local function GiveThatSweetExpBoost()
	UseCollectible(1168)	-- Breda's Bottomless Mead Mug
end

function Eventor.EVENT_PLAYER_ACTIVATED (_, shouldBeBooleanForWasItReloaduiButIsActuallyTotalyRandom)
	if Event_is_active then
		ticketAlert()
		GiveThatSweetExpBoost()
	end
end

-- Lets fire up the add-on by registering for events and loading variables
function Eventor.Initialize()
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_LOOT_RECEIVED, Eventor.lootedEventBox)	-- Start listening to gained loot
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CURRENCY_UPDATE, Eventor.EVENT_CURRENCY_UPDATE)	-- Start listening to gained tickets
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, Eventor.EVENT_PLAYER_ACTIVATED)

	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_EFFECT_CHANGED, Eventor.EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:AddFilterForEvent(ADDON, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 91449)

  accountEventLootHistory   = ZO_SavedVars:NewAccountWide("Eventor_accountEventLootHistory", 1, GetWorldName(), default)	-- Load event loot history
	Eventor_settings   = ZO_SavedVars:NewAccountWide("Eventor_settings", 1, GetWorldName(), default)	-- Load settings
end

-- Here the magic starts
function Eventor.EVENT_ADD_ON_LOADED(_, loadedAddOnName)
  if loadedAddOnName == ADDON then
		--	Seems it is our time to shine so lets stop listening load trigger, load saved variables and initialize the add-on
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

		Eventor.Initialize()
  end
end
-- Registering for the add on loading loop
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, Eventor.EVENT_ADD_ON_LOADED )