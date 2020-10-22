Eventor = {
	TITLE = "Eventor - Events Spam Online",	-- Not codereview friendly but enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "One stop event add-on. Keeps track of the amount of event boxes you have collected and warns if you don't have room for new tickets when an event is on.",
	VERSION = "32.202010221",
	VARIABLEVERSION = "32",
	LIECENSE = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/Eventor"
}
local ADDON = "Eventor"	-- Variable used to refer to this add-on. Codereview friendly.

accountEventLootHistory = {}
accountEventLootHistory[0] = 0
accountEventLootHistory[CURT_EVENT_TICKETS] = {}

local Eventor_settings = {	-- default settings
	TicketThresholdAlarm =  GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) - 3,	-- 3 has been maximum reward of tickets this far
	AlarmAnnoyance	= 12,	-- How many times user is reminded
	LongestEvent	= 35	-- Longest known event this far in days
}

local AlarmsRemaining = Eventor_settings[AlarmAnnoyance]

local todaysDate	= os.date("%Y%m%d")
local todaysYear	= os.date("%Y")

local EVENTLOOT = {

	-- Undaunted Celebration
	[156679] = 2,	-- Undaunted Reward Box
	[156717] = 1,	-- Hefty Undaunted Reward Box

	-- Midyear Mayhem
	[121526] = 2,	-- Pelinal's Midyear Boon Box

	-- Murkmire Celebration

	-- Thieves Guild and Dark Brotherhood Celebration

	-- Jester's Festival
	[147637] = 2,	-- Stupendous Jester's Festival Box
	[147637] = 1,	-- Jester's Festival Box

	-- Anniversary Jubilee
	[147637] = 2,	-- Anniversary Jubilee Gift Box

	-- Vampire Week

	-- Midyear Mayhem

	-- Summerset Celebration

	-- Orsinium Celebration

	-- Imperial City Celebration

	-- Witches Festival
	[167234] = 2,	-- Plunder Skull
	[141771] = 1,	-- Dremora Plunder Skull, Arena
	[141772] = 1,	-- Dremora Plunder Skull, Insurgent
	[141773] = 1,	-- Dremora Plunder Skull, Delve
	[141774] = 1,	-- Dremora Plunder Skull, Dungeon
	[141775] = 1,	-- Dremora Plunder Skull, Public & Sweeper
	[141776] = 1,	-- Dremora Plunder Skull, Trial
	[141777] = 1,	-- Dremora Plunder Skull, World
	
	-- Lost treasures of Skyrim
    [167226] = 1,	-- Box of Gray Host Pillage
	[167227] = 2,	-- Bulging Box of Gray Host Pillage
	
	-- New Life Festival
	[141823] = 2	-- New Life Festival Box
}

-- Lets fire up the add-on by registering for events and loading variables
function Eventor.Initialize(loadOrder)
	d( Eventor.TITLE .. ": load order " ..  loadOrder .. ", starting initalization")
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_LOOT_RECEIVED, Eventor.lootedEventBox)	-- Start listening to gained loot
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CURRENCY_UPDATE, Eventor.EVENT_CURRENCY_UPDATE)	-- Start listening to gained loot
end

-- Setter that keeps count of how many boxes this UserID has looted 
-- 100032	EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function Eventor.lootedEventBox(eventCode, name, itemLink, quantity, itemSound, lootType, lootedByPlayer, isPickpocketLoot, questItemIcon, itemId)

	if EVENTLOOT[itemId] then	-- Only intrested about event items

		Eventor.ticketAlert()

		if lootedByPlayer then	-- Player looted it, lets make a note
		
			todaysDate = os.date("%Y%m%d")	-- maybe its a new day already, better refresh the variable

			if not accountEventLootHistory[itemId] then	-- Does itemId loot have a table
				accountEventLootHistory[itemId] = {}	-- if not, create one
				accountEventLootHistory[itemId].year = 0	-- Keeps track how many boxes in total this year
				d( ADDON .. ": creating table for " .. itemLink)
			end

			if not accountEventLootHistory[itemId].todaysDate then	-- Is this itemId's first entry for this date?
				accountEventLootHistory[itemId].todaysDate = 0	-- if not, create one
				d( ADDON .. ": creating datekey " .. todaysDate .. " inside " .. itemLink .. " table")
			end

			accountEventLootHistory[itemId].todaysDate = accountEventLootHistory[itemId].todaysDate + 1	-- increase todays counter by one
			accountEventLootHistory[itemId].todaysYear = accountEventLootHistory[itemId].todaysYear + 1	-- increase this years loot counter by one

			d( ADDON .. ": " .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId].todaysDate) .. " ".. itemLink .. " " .. zo_strformat("<<i:1>>", accountEventLootHistory[itemId].todaysYear) )
		end

	end
end

local function ticketAlert()

	if 0 < AlarmsRemaining and DoesCurrencyAmountMeetConfirmationThreshold(CURT_EVENT_TICKETS, Eventor_settings[TicketThresholdAlarm])	then	-- 
		d (ADDON .. ": " .. GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )

		local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
		messageParams:SetText( GetCurrencyAmount(9, 3) .. "/" .. ZO_Currency_FormatPlatform(CURT_EVENT_TICKETS, GetMaxPossibleCurrency(9, 3), ZO_CURRENCY_FORMAT_AMOUNT_ICON) )
		CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)

		AlarmsRemaining = AlarmsRemaining - 1
	end
end

-- Listens if the ticket currency changes for loot reasons.
-- 100032	EVENT_CURRENCY_UPDATE (number eventCode, CurrencyType currencyType, CurrencyLocation currencyLocation, number newAmount, number oldAmount, CurrencyChangeReason reason)
function Eventor.EVENT_CURRENCY_UPDATE (eventCode, currencyType, currencyLocation, newAmount, oldAmount, CurrencyChangeReason)

	-- If the currency updated was tickets and it was gained by loot or quest reward check if there is need for alert the user
	if currencyType == CURT_EVENT_TICKETS and (CurrencyChangeReason == 0 or CurrencyChangeReason == 4) then
		ticketAlert()

		accountEventLootHistory[CURT_EVENT_TICKETS][todaysDate] = (newAmount - oldAmount)	-- Saves the ammount of tickets gained today
	end
end

-- Here the magic starts
local loadOrder = 1	-- Variable to keep count how many loads have been done before it was this ones turn.
function Eventor.EVENT_ADD_ON_LOADED(_, loadedAddOnName)
  if loadedAddOnName == ADDON then

	--	Seems it is our time to shine so lets stop listening load trigger, load saved variables and initialize the add-on
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    accountEventLootHistory   = ZO_SavedVars:NewAccountWide("Eventor_accountEventLootHistory", 1, GetWorldName(), default)
    Eventor_settings   = ZO_SavedVars:NewAccountWide("Eventor_settings", 1, GetWorldName(), default)

	Eventor.Initialize(loadOrder)
  else
	loadOrder = loadOrder + 1
  end
end
-- Registering for the add on loading loop
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, Eventor.EVENT_ADD_ON_LOADED )