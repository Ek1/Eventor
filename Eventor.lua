Eventor = {
	TITLE = "Eventor - Events Spam Online",	-- Not codereview friendly but enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "One stop event add-on about the numerous ticket giving ESO events to keep track what you have done, how many and when. Keeps up your exp buff too. Also warns if you can't fit any more tickets.",
	VERSION = "1032.211230",
	VARIABLEVERSION = "32",
	LIECENSE = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/Eventor",
}
local ADDON = "Eventor"	-- Variable used to refer to this add-on. Codereview friendly.
local eventIsActive = false	-- default is that there is no event on.

-- THESE SHOULD BE LOCAL but nice to be not for /zgoo accountEventLootHistory
accountEventLootHistory = {}
accountEventLootHistory[CURT_EVENT_TICKETS] = {}

--/script d (  ZO_FormatTimeLargestTwo( GetTimedActivityTimeRemainingSeconds(2)  , TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))  

local eventorSettings = {	-- default settings
	ticketThresholdAlarm =  GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) - 3,	-- 3 has been maximum reward of tickets this far
	alarmAnnoyance	= 99999,	-- How many times user is reminded
	longestEvent	= 35,	-- Longest known event this far in days
	keepEventBuffsOn = true,
	eventBuffsThreshold = 60,
	lastTimeSomeoneGainedEventBuff = 1640820402,
	whenOurEventBuffRunsOut = 1618495200,
	lastTimeEventLootWasGained = 1640820402,
}

local alarmsRemaining = eventorSettings.alarmAnnoyance or 9999

local dailysReseted = os.time() + GetTimedActivityTimeRemainingSeconds(2) - 86400	-- 24h*60min*60sec = 86400 seconds

local todaysDate = tonumber(os.date("%Y%m%d"))	-- Aikaa seuraavaan daily resettii GetTimedActivityTimeRemainingSeconds(2) 
local todaysYear = tonumber(os.date("%Y"))
local _, _, delay = GetFenceLaunderTransactionInfo()

local EVENTLOOT = {
	-- W03	Undaunted Celebration
	[156679] = 2,	-- Undaunted Reward Box
	[156717] = 1,	-- Hefty Undaunted Reward Box
	[171267] = 2,	-- Undaunted Reward Box
	[171268] = 1, -- Glorious Undaunted Reward Box
	[182317] = 2,	-- Undaunted Reward Box	2021-11-18
	[182318] = 1, -- Glorious Undaunted Reward Box	2021-11-18

	-- W04 & W29	Midyear Mayhem
	[121526] = 2,	-- Pelinal's Midyear Boon Box
	[171535] = 2, -- Pelinal's Midyear Boon Box 2021-01-28
	[175563] = 2, -- Pelinal's Midyear Boon Box 2021-01-28

	-- W07	Murkmire Celebration

	-- W08	Tribunal Celebration
	[171476] = 2,	-- Tribunal Coffer
	[171480] = 1,	-- Glorious Tribunal Coffer

	-- W09	Thieves Guild and Dark Brotherhood Celebration

	-- W12	Jester's Festival
	[171731] = 1,	-- Stupendous Jester's Festival Box
	[171732] = 2,	-- Jester's Festival Box

	-- W13	(4th April) 	Anniversary Jubilee
	[171779] = 2,	-- 7th Anniversary Jubilee Gift Box

	-- W18	Vampire Week

	-- W25	Midyear Mayhem

	-- W29	Summerset Celebration

	-- W31	Orsinium Celebration

	-- w34 Year one
  [175795] = 1,	-- Glorious Year One Coffer
  [175796] = 2,	-- Year One Coffer

	-- W35	Imperial City Celebration

	-- W38	Lost treasures of Skyrim
  [167227] = 1,	-- Bulging Box of Gray Host Pillage	2020
	[167226] = 2,	-- Box of Gray Host Pillage	2020

	-- W39	Lost treasures of Skyrim
	[181433] = 1,	-- 20	Glorious Blackwood Legates' Coffer
	[178723] = 2,	-- 20	Blackwood Legates' Coffer

	-- W42	Witches Festival
	[84521] = 2,	-- 16	Plunder Skull
	[128358] = 2,	-- 17	Plunder Skull
	[141770] = 2,	-- 18	Plunder Skull
	[141771] = 1,	-- 18 Dremora Plunder Skull, Arena
	[141772] = 1,	-- 18 Dremora Plunder Skull, Insurgent
	[141773] = 1,	-- 18 Dremora Plunder Skull, Delve
	[141774] = 1,	-- 18 Dremora Plunder Skull, Dungeon
	[141775] = 1,	-- 18 Dremora Plunder Skull, Public & Sweeper
	[141776] = 1,	-- 18 Dremora Plunder Skull, Trial
	[141777] = 1,	-- 18 Dremora Plunder Skull, World
	[153502] = 2,	-- 19	Plunder Skull
	[153503] = 1,	-- 19 Dremora Plunder Skull, Arena
	[153504] = 1,	-- 19 Dremora Plunder Skull, Insurgent
	[153505] = 1,	-- 19 Dremora Plunder Skull, Delve
	[153506] = 1,	-- 19 Dremora Plunder Skull, Dungeon
	[153507] = 1,	-- 19 Dremora Plunder Skull, Public & Sweeper
	[153508] = 1,	-- 19 Dremora Plunder Skull, Trial
	[153509] = 1,	-- 19 Dremora Plunder Skull, World
	[167234] = 2,	-- 20 Plunder Skull
	[167235] = 1,	-- 20 Dremora Plunder Skull, Arena
	[167236] = 1,	-- 20 Dremora Plunder Skull, Insurgent
	[167237] = 1,	-- 20 Dremora Plunder Skull, Delve
	[167238] = 1,	-- 20 Dremora Plunder Skull, Dungeon
	[167239] = 1,	-- 20 Dremora Plunder Skull, Public & Sweeper
	[167240] = 1,	-- 20 Dremora Plunder Skull, Trial
	[167241] = 1,	-- 20 Dremora Plunder Skull, World
	[178686] = 2,	-- 21 Plunder Skull
	[178687] = 1,	-- Dremora Plunder Skull, Arena
	[178688] = 1,	-- Dremora Plunder Skull, Insurgent
	[178689] = 1,	-- Dremora Plunder Skull, Delve
	[178690] = 1,	-- Dremora Plunder Skull, Dungeon
	[178691] = 1,	-- Dremora Plunder Skull, Public & Sweeper
	[178692] = 1,	-- Dremora Plunder Skull, Trial
	[178693] = 1,	-- Dremora Plunder Skull, World

	-- w50	New Life Festival
	[96390] = 2,	-- 16	New Life Festival Box
	[133557] = 2,	-- 17	New Life Festival Box
	[141823] = 2,	-- 18	New Life Festival Box
	[159463] = 1,	-- 19	Stupendous Jester's Festival Box
	[156779] = 2,	-- 19	New Life Festival Box
	[171731] = 1,	-- 20	Stupendous Jester's Festival Box
	[171327] = 2,	-- 20	New Life Festival Box
	[182494] = 2,	-- 21	New Life Festival Box
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

	--	Jester's Festival
	[5921] = 1,	-- Springtime Flair
	[5931] = 1,	-- A Noble Guest
	[5937] = 1,	-- Royal Revelry
	[5941] = 1,	-- The Jester's Festival
	[6622] = 1,	-- A Foe Most Porcine
	[6632] = 1,	-- The King's Spoils
	[6640] = 1,	-- Prankster's Carnival
}

EVENTEXPBUFFS = {
	[91369] = 1167, -- Jester's Experience Boost Pie
	[91449] = 1168, -- Breda's Magnificent Mead
	[152514] = 9012,	-- 2021 Jubilee cake
}

local function ticketAlert()

	if 0 < alarmsRemaining and 9 < GetCurrencyAmount(CURT_EVENT_TICKETS, 3)	then
		d (ADDON .. ": " .. GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )

		local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
		messageParams:SetText( GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )
		CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
	end

	alarmsRemaining = alarmsRemaining - 1
end

-- 100033	EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)

-- Setter that keeps count of how many boxes this UserID has looted 
-- 100032	EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function Eventor.lootedEventBox(eventCode, receivedBy, itemName, quantity, ItemUISoundCategory, LootItemType, lootedByPlayer, questItemIcon, questItemIcon, StringitemId, isStolen)

	itemId = tonumber(StringitemId)
--	d( ADDON .. ": looted " .. itemName .. "(" .. itemId .. ")")

	if EVENTLOOT[itemId] then	-- Only intrested about event items
--		d( ADDON .. ": and it was found in EVENTLOOT[itemId] ")

		eventorSettings.lastTimeEventLootWasGained = os.time()
		eventIsActive = true
		ticketAlert()

		if lootedByPlayer then	-- Player looted it, lets make a note

			if dailysReseted <= os.time() + 86400	then	-- 24h*60min*60sec = 86400 seconds
				dailysReseted = os.time() + GetTimedActivityTimeRemainingSeconds(2) - 86400	-- 24h*60min*60sec = 86400 seconds
			end

			todaysYear = tonumber(os.date("%Y", dailysReseted))
			todaysDate = tonumber(os.date("%Y%m%d", dailysReseted))

			if not accountEventLootHistory[itemId] then	-- Does itemId loot have a table
				accountEventLootHistory[itemId] = {}	-- if not, create one
				accountEventLootHistory[itemId][0] = 0	-- Keeps track how many boxes in total this year of the itemId
				d( ADDON .. ": creating table for " .. itemName)
			end
			accountEventLootHistory[itemId][0] = (accountEventLootHistory[itemId][0] or 0) + 1	-- increase this years loot counter by one

			if not accountEventLootHistory[itemId][todaysDate] then	-- Is this itemId's first entry for this date?
				accountEventLootHistory[itemId][todaysDate] = 0	-- if not, create one
				d( ADDON .. ": creating datekey " .. todaysDate .. " inside " .. itemName .. " table")
			end

			if EVENTLOOT[itemId] == 1 then	-- The item has drop rate of once per day so instead of increasing the date time store the time stamp
				accountEventLootHistory[itemId][todaysDate] = os.time()	-- timestamp to store.
				d( ADDON .. ": " .. itemName .. " looted today at " .. os.date("%H:%M:%S") .. " and it was " .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][0]) )
			else
				accountEventLootHistory[itemId][todaysDate] = (accountEventLootHistory[itemId][todaysDate] or 0) + 1	-- increase todays counter by one
				accountEventLootHistory[itemId][-1] = os.time()	-- when the latest one was picked up
				d( ADDON .. ": " .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][todaysDate]) .. " ".. itemName .. " today and it was " .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId][0]) )
			end
			accountEventLootHistory[0] = (accountEventLootHistory[0] or 0) + 1	-- increase over all counter by one
		end
	end
end

-- Listens if the ticket currency changes for loot reasons.
-- 100032	EVENT_CURRENCY_UPDATE (number eventCode, CurrencyType currencyType, CurrencyLocation currencyLocation, number newAmount, number oldAmount, currencyChangeReason reason)
function Eventor.EVENT_CURRENCY_UPDATE (_, currencyType, currencyLocation, newAmount, oldAmount, currencyChangeReason)

	-- If the currency updated was tickets and it was gained by loot or quest reward check if there is need for alert the user
	if currencyType == CURT_EVENT_TICKETS
	and (currencyChangeReason == CURRENCY_CHANGE_REASON_LOOT or currencyChangeReason == CURRENCY_CHANGE_REASON_QUESTREWARD) 
	and oldAmount < newAmount then
		eventIsActive = true

		todaysDate = tonumber(os.date("%Y%m%d"))	-- maybe its a new day already, better refresh the variable
--		eventorSettings.LastEventDate = todaysDate

		ticketAlert()

		if not accountEventLootHistory[CURT_EVENT_TICKETS] then
			accountEventLootHistory[CURT_EVENT_TICKETS] = {}
		end

		accountEventLootHistory[CURT_EVENT_TICKETS][todaysDate] = (newAmount - oldAmount)	-- Saves the ammount of tickets gained today
--		d( ADDON .. ": Gained " .. accountEventLootHistory[CURT_EVENT_TICKETS][todaysDate] .. " tickets")
	end
end

function Eventor.Eventor_TEST(inpuuut)
	ticketAlert()
	Eventor.lootedEventBox(eventCode, player, itemName, 1, ItemUISoundCategory, LootItemType, true, questItemIcon, questItemIcon, inpuuut, isStolen)
end

-- Refreshes the characters exp buff
local function GiveThatSweetExpBoost( abilityId )

	if	eventorSettings.keepEventBuffsOn  and
	(eventorSettings.whenOurEventBuffRunsOut or 0) + (eventorSettings.eventBuffsThreshold * 60)	<	os.time()	then
		if abilityId ~= nil then
			UseCollectible( EVENTEXPBUFFS[abilityId] )
		else
			UseCollectible( EVENTEXPBUFFS[eventorSettings.lastEventBuffId] )
		end
	end
	ticketAlert()
end

function Eventor.EVENT_PLAYER_ACTIVATED (_, shouldBeBooleanForWasItReloaduiButIsActuallyTotalyRandom)

	if eventIsActive then
		ticketAlert()
		GiveThatSweetExpBoost()
	end
end

activePlayerBuffs = {}
--	100034	EVENT_EFFECT_CHANGED (integer eventCode, integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType, string unitName, integer unitId, integer abilityId, integer sourceUnitType)
function Eventor.ListenToEventBuffs(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
	if not EVENTEXPBUFFS[abilityId] then return end	-- Not a event buff so -> end

	ticketAlert()

	if (beginTime + 7199 < endTime) then	-- 2h buff is 7200 seconds.
		eventorSettings.lastTimeSomeoneGainedEventBuff = os.time()
		eventorSettings.lastEventBuffId = abilityId
--		d ( ADDON .. ": EVENT IS ON ")
	end

	if GetRawUnitName("player") == unitName	then
		if changeType == EFFECT_RESULT_GAINED then
			eventorSettings.whenOurEventBuffRunsOut	= os.time() + (endTime - beginTime)
			activePlayerBuffs[abilityId] = eventorSettings.whenOurEventBuffRunsOut
		--	d( ADDON .. ": player gained " .. tostring(abilityId) .. "/" .. effectName .. " timeleft:" .. ZO_FormatTimeLargestTwo((endTime - beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL) )
		elseif changeType == EFFECT_RESULT_UPDATED then
			eventorSettings.whenOurEventBuffRunsOut	= os.time() + (endTime - beginTime)
			activePlayerBuffs[abilityId] = eventorSettings.whenOurEventBuffRunsOut
		--	d( ADDON .. ": players " .. tostring(abilityId) .. "/" .. effectName .. " was refreshed for " .. ZO_FormatTimeLargestTwo((endTime-beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))
		elseif changeType == EFFECT_RESULT_FADED	then
			activePlayerBuffs[abilityId] = false
			eventorSettings.whenOurEventBuffRunsOut	= os.time() - 1
		--	d( ADDON .. ": players " .. tostring(abilityId) .. "/" .. effectName .. " faded" )
			GiveThatSweetExpBoost(abilityId)
		end
	else	-- Someone else is running around with a event buff
		if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) and not activePlayerBuffs[abilityId] then
		--	d( ADDON .. ": " .. ZO_LinkHandler_CreateLinkWithoutBrackets(unitName, nil, CHARACTER_LINK_TYPE, unitName) .. " ".. tostring(abilityId) .. "/" .. effectName .. " gained(1) or updated(3) =" .. changeType .. " timeleft: " .. ZO_FormatTimeLargestTwo((endTime-beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL) )
		GiveThatSweetExpBoost(abilityId)
		end
	end
end

-- LAM stuff
local LAM	= LibAddonMenu2
local saveData	= eventorSettings
local panelName	= "Eventor-Panel"

local panelData = {
	type = "panel",
	name = ADDON,
	displayName = Eventor.TITLE,
	author = Eventor.AUTHOR,
	version = Eventor.VERSION,
--	slashCommand = "/eventor",	--(optional) will register a keybind to open to this panel
	registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
	registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	text = Eventor.DESCRIPTION,
}
local panel = LAM:RegisterAddonPanel(panelName, panelData)

local optionsData = {
	[1] = {
			type = "description",
			--title = "My Title",	--(optional)
			title = nil,	--(optional)
			text = Eventor.DESCRIPTION,
			width = "full",	--or "half" (optional)
			registerForRefresh = true, --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		},
	[2] = {
		type = "divider",
	},
	[3] = {
		type = "checkbox",
		name = "Refresh event EXP buffs",
		default = true,
		getFunc = function() return eventorSettings.keepEventBuffsOn end,
		setFunc = function(value) eventorSettings.keepEventBuffsOn = value end,
	},
	[4] = {
		type = "slider",
		name = "Threshold in minutes when to refresh event buff",
		disabled = function() return not eventorSettings.keepEventBuffsOn end,
		tooltip = "If there less minutes left in characters event Exp buff than the given value, the add-on tries to refresh it.",
		min = 0,
		max = 105,	-- 15 mins seems to be the idle check time and we don't want to create anti-idle add-on
		default = 60,
		getFunc = function() return eventorSettings.eventBuffsThreshold end,
		setFunc = function(value) eventorSettings.eventBuffsThreshold = value end,
	},
}
LAM:RegisterOptionControls(panelName, optionsData)

-- Lets fire up the add-on by registering for events and loading variables
function Eventor.Initialize()
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_LOOT_RECEIVED, Eventor.lootedEventBox)	-- Start listening to gained loot
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CURRENCY_UPDATE, Eventor.EVENT_CURRENCY_UPDATE)	-- Start listening to gained tickets
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, Eventor.EVENT_PLAYER_ACTIVATED)

  accountEventLootHistory   = ZO_SavedVars:NewAccountWide("Eventor_accountEventLootHistory", 1, GetWorldName(), accountEventLootHistory)	-- Load event loot history
	eventorSettings   = ZO_SavedVars:NewAccountWide("Eventor_eventorSettings", 1, GetWorldName(), eventorSettings)	-- Load settings

--	if eventorSettings.keepEventBuffsOn then
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_EFFECT_CHANGED, Eventor.ListenToEventBuffs)
--	end
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
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, Eventor.EVENT_ADD_ON_LOADED)