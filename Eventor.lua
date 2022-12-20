Eventor = {
	TITLE = "Eventor - Events Spam Online",	-- Not codereview friendly but enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "One stop event add-on about the numerous ticket giving ESO events to keep track what you have done, how many and when. Keeps up your exp buff too. Also warns if you can't fit any more tickets.",
	VERSION = "1036.221220",
	VARIABLEVERSION = "32",
	LIECENSE = "CC BY-SA 4.0 = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/Eventor",
}
local ADDON = "Eventor"	-- Variable used to refer to this add-on. Codereview friendly.
local eventIsActive = false	-- default is that there is no event on.

-- THESE SHOULD BE LOCAL but nice to have for /zgoo accountEventLootHistory
accountEventLootHistory = {}
accountEventLootHistory[CURT_EVENT_TICKETS] = {}

local eventorSettings = {	-- default settings
	ticketThresholdAlarm =  GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) - 3,	-- 3 has been maximum reward of tickets this far
	alarmAnnoyance	= 99999,	-- How many times user is reminded
	longestEvent	= 35,	-- Longest known event this far in days
	keepEventBuffsOn = true,
	eventBuffsThreshold = 60,
	lastTimeSomeoneGainedEventBuff = 1640820402,
	lastTimeEventLootWasGained = 1640820402,
	whenOurEventBuffRunsOut = 1618495200,
}

local alarmsRemaining = eventorSettings.alarmAnnoyance or 9999
local dailysReseted = os.time() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY) - 86400	-- 24h*60min*60sec = 86400 seconds
local dailysReset = os.time() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)
-- if timedActivityId 
--/script d (  ZO_FormatTimeLargestTwo( TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)  , TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))
local todaysYear = tonumber(os.date("%Y", dailysReseted))
local todaysDate = tonumber(os.date("%Y%m%d", dailysReseted))
-- local _, _, delay = GetFenceLaunderTransactionInfo()

local EVENTLOOT = {
	-- W03	Undaunted Celebration
	[156679] = 2,	-- Undaunted Reward Box
	[156717] = 1,	-- Hefty Undaunted Reward Box
	[171267] = 2,	-- Undaunted Reward Box
	[171268] = 1, -- Glorious Undaunted Reward Box
	[182317] = 2, -- Undaunted Reward Box	2021-11-18
	[182318] = 1, --	Glorious Undaunted Reward Box	2021-11-18
	--	2022-09-08
	[190173] = 1, --	Glorious Undaunted Box: Arx Corinium
	[190166] = 1, --	Glorious Undaunted Box: Banished Cells
	[190200] = 1, --	Glorious Undaunted Box: Black Drake Villa
	[190178] = 1, --	Glorious Undaunted Box: Blackheart Haven
	[190179] = 1, --	Glorious Undaunted Box: Blessed Crucible
	[190187] = 1, --	Glorious Undaunted Box: Bloodroot Forge
	[190198] = 1, --	Glorious Undaunted Box: Castle Thorn
	[190174] = 1, --	Glorious Undaunted Box: City of Ash
	[190204] = 1, --	Glorious Undaunted Box: Coral Aerie
	[190185] = 1, --	Glorious Undaunted Box: Cradle of Shadows
	[190172] = 1, --	Glorious Undaunted Box: Crypt of Hearts
	[190169] = 1, --	Glorious Undaunted Box: Darkshade Cavern
	[190192] = 1, --	Glorious Undaunted Box: Depths of Malatar
	[190175] = 1, --	Glorious Undaunted Box: Direfrost Keep
	[190206] = 1, --	Glorious Undaunted Box: Earthen Root Enclave
	[190170] = 1, --	Glorious Undaunted Box: Elden Hollow
	[190186] = 1, --	Glorious Undaunted Box: Falkreath Hold
	[190188] = 1, --	Glorious Undaunted Box: Fang Lair
	[190193] = 1, --	Glorious Undaunted Box: Frostvault
	[190167] = 1, --	Glorious Undaunted Box: Fungal Grotto
	[190207] = 1, --	Glorious Undaunted Box: Graven Deep
	[190196] = 1, --	Glorious Undaunted Box: Icereach
	[190182] = 1, --	Glorious Undaunted Box: Imperial City Prison
	[190195] = 1, --	Glorious Undaunted Box: Lair of Maarselok
	[190191] = 1, --	Glorious Undaunted Box: March of Sacrifices
	[190190] = 1, --	Glorious Undaunted Box: Moon Hunter
	[190194] = 1, --	Glorious Undaunted Box: Moongrave Fane
	[190202] = 1, --	Glorious Undaunted Box: Red Petal Bastion
	[190184] = 1, --	Glorious Undaunted Box: Ruins of Mazzatun
	[190189] = 1, --	Glorious Undaunted Box: Scalecaller Peak
	[190180] = 1, --	Glorious Undaunted Box: Selene's Web
	[190205] = 1, --	Glorious Undaunted Box: Shipwright's Regret
	[190168] = 1, --	Glorious Undaunted Box: Spindleclutch
	[190199] = 1, --	Glorious Undaunted Box: Stone Garden
	[190176] = 1, --	Glorious Undaunted Box: Tempest Island
	[190201] = 1, --	Glorious Undaunted Box: The Cauldron
	[190203] = 1, --	Glorious Undaunted Box: The Dread Cellar
	[190197] = 1, --	Glorious Undaunted Box: Unhallowed Grave
	[190181] = 1, --	Glorious Undaunted Box: Vaults of Madness
	[190131] = 1, --	Glorious Undaunted Box: Veteran Arx Corinium
	[190124] = 1, --	Glorious Undaunted Box: Veteran Banished Cells
	[190158] = 1, --	Glorious Undaunted Box: Veteran Black Drake Villa
	[190136] = 1, --	Glorious Undaunted Box: Veteran Blackheart Haven
	[190137] = 1, --	Glorious Undaunted Box: Veteran Blessed Crucible
	[190145] = 1, --	Glorious Undaunted Box: Veteran Bloodroot Forge
	[190156] = 1, --	Glorious Undaunted Box: Veteran Castle Thorn
	[190132] = 1, --	Glorious Undaunted Box: Veteran City of Ash
	[190162] = 1, --	Glorious Undaunted Box: Veteran Coral Aerie
	[190143] = 1, --	Glorious Undaunted Box: Veteran Cradle of Shadows
	[190130] = 1, --	Glorious Undaunted Box: Veteran Crypt of Hearts
	[190127] = 1, --	Glorious Undaunted Box: Veteran Darkshade Cavern
	[190150] = 1, --	Glorious Undaunted Box: Veteran Depths of Malatar
	[190133] = 1, --	Glorious Undaunted Box: Veteran Direfrost Keep
	[190164] = 1, --	Glorious Undaunted Box: Veteran Earthen Root
	[190128] = 1, --	Glorious Undaunted Box: Veteran Elden Hollow
	[190144] = 1, --	Glorious Undaunted Box: Veteran Falkreath Hold
	[190146] = 1, --	Glorious Undaunted Box: Veteran Fang Lair
	[190151] = 1, --	Glorious Undaunted Box: Veteran Frostvault
	[190125] = 1, --	Glorious Undaunted Box: Veteran Fungal Grotto
	[190165] = 1, --	Glorious Undaunted Box: Veteran Graven Deep
	[190154] = 1, --	Glorious Undaunted Box: Veteran Icereach
	[190140] = 1, --	Glorious Undaunted Box: Veteran Imperial City Pris
	[190153] = 1, --	Glorious Undaunted Box: Veteran Lair of Maarselok
	[190149] = 1, --	Glorious Undaunted Box: Veteran March of Sacrifice
	[190148] = 1, --	Glorious Undaunted Box: Veteran Moon Hunter
	[190152] = 1, --	Glorious Undaunted Box: Veteran Moongrave Fane
	[190160] = 1, --	Glorious Undaunted Box: Veteran Red Petal Bastion
	[190142] = 1, --	Glorious Undaunted Box: Veteran Ruins of Mazzatun
	[190147] = 1, --	Glorious Undaunted Box: Veteran Scalecaller Peak
	[190138] = 1, --	Glorious Undaunted Box: Veteran Selene's Web
	[190163] = 1, --	Glorious Undaunted Box: Veteran Shipwright's Regre
	[190126] = 1, --	Glorious Undaunted Box: Veteran Spindleclutch
	[190157] = 1, --	Glorious Undaunted Box: Veteran Stone Garden
	[190134] = 1, --	Glorious Undaunted Box: Veteran Tempest Island
	[190159] = 1, --	Glorious Undaunted Box: Veteran the Cauldron
	[190161] = 1, --	Glorious Undaunted Box: Veteran the Dread Cellar
	[190155] = 1, --	Glorious Undaunted Box: Veteran Unhallowed Grave
	[190139] = 1, --	Glorious Undaunted Box: Veteran Vaults of Madness
	[190135] = 1, --	Glorious Undaunted Box: Veteran Volenfell
	[190129] = 1, --	Glorious Undaunted Box: Veteran Wayrest Sewers
	[190141] = 1, --	Glorious Undaunted Box: Veteran White-Gold Tower
	[190177] = 1, --	Glorious Undaunted Box: Volenfell
	[190171] = 1, --	Glorious Undaunted Box: Wayrest Sewers
	[190183] = 1, --	Glorious Undaunted Box: White-Gold Tower
	[190257] = 2, --	Undaunted Box: Arx Corinium
	[190250] = 2, --	Undaunted Box: Banished Cells
	[190284] = 2, --	Undaunted Box: Black Drake Villa
	[190262] = 2, --	Undaunted Box: Blackheart Haven
	[190263] = 2, --	Undaunted Box: Blessed Crucible
	[190271] = 2, --	Undaunted Box: Bloodroot Forge
	[190282] = 2, --	Undaunted Box: Castle Thorn
	[190258] = 2, --	Undaunted Box: City of Ash
	[190288] = 2, --	Undaunted Box: Coral Aerie
	[190269] = 2, --	Undaunted Box: Cradle of Shadows
	[190256] = 2, --	Undaunted Box: Crypt of Hearts
	[190253] = 2, --	Undaunted Box: Darkshade Cavern
	[190276] = 2, --	Undaunted Box: Depths of Malatar
	[190259] = 2, --	Undaunted Box: Direfrost Keep
	[190290] = 2, --	Undaunted Box: Earthen Root Enclave
	[190254] = 2, --	Undaunted Box: Elden Hollow
	[190270] = 2, --	Undaunted Box: Falkreath Hold
	[190272] = 2, --	Undaunted Box: Fang Lair
	[190277] = 2, --	Undaunted Box: Frostvault
	[190251] = 2, --	Undaunted Box: Fungal Grotto
	[190291] = 2, --	Undaunted Box: Graven Deep
	[190280] = 2, --	Undaunted Box: Icereach
	[190266] = 2, --	Undaunted Box: Imperial City Prison
	[190279] = 2, --	Undaunted Box: Lair of Maarselok
	[190275] = 2, --	Undaunted Box: March of Sacrifices
	[190274] = 2, --	Undaunted Box: Moon Hunter
	[190278] = 2, --	Undaunted Box: Moongrave Fane
	[190286] = 2, --	Undaunted Box: Red Petal Bastion
	[190268] = 2, --	Undaunted Box: Ruins of Mazzatun
	[190273] = 2, --	Undaunted Box: Scalecaller Peak
	[190264] = 2, --	Undaunted Box: Selene's Web
	[190289] = 2, --	Undaunted Box: Shipwright's Regret
	[190252] = 2, --	Undaunted Box: Spindleclutch
	[190283] = 2, --	Undaunted Box: Stone Garden
	[190260] = 2, --	Undaunted Box: Tempest Island
	[190285] = 2, --	Undaunted Box: The Cauldron
	[190287] = 2, --	Undaunted Box: The Dread Cellar
	[190281] = 2, --	Undaunted Box: Unhallowed Grave
	[190265] = 2, --	Undaunted Box: Vaults of Madness
	[190215] = 2, --	Undaunted Box: Veteran Arx Corinium
	[190208] = 2, --	Undaunted Box: Veteran Banished Cells
	[190242] = 2, --	Undaunted Box: Veteran Black Drake Villa
	[190220] = 2, --	Undaunted Box: Veteran Blackheart Haven
	[190221] = 2, --	Undaunted Box: Veteran Blessed Crucible
	[190229] = 2, --	Undaunted Box: Veteran Bloodroot Forge
	[190240] = 2, --	Undaunted Box: Veteran Castle Thorn
	[190216] = 2, --	Undaunted Box: Veteran City of Ash
	[190246] = 2, --	Undaunted Box: Veteran Coral Aerie
	[190227] = 2, --	Undaunted Box: Veteran Cradle of Shadows
	[190214] = 2, --	Undaunted Box: Veteran Crypt of Hearts
	[190211] = 2, --	Undaunted Box: Veteran Darkshade Cavern
	[190234] = 2, --	Undaunted Box: Veteran Depths of Malatar
	[190217] = 2, --	Undaunted Box: Veteran Direfrost Keep
	[190248] = 2, --	Undaunted Box: Veteran Earthen Root Enclave
	[190212] = 2, --	Undaunted Box: Veteran Elden Hollow
	[190228] = 2, --	Undaunted Box: Veteran Falkreath Hold
	[190230] = 2, --	Undaunted Box: Veteran Fang Lair
	[190235] = 2, --	Undaunted Box: Veteran Frostvault
	[190209] = 2, --	Undaunted Box: Veteran Fungal Grotto
	[190249] = 2, --	Undaunted Box: Veteran Graven Deep
	[190238] = 2, --	Undaunted Box: Veteran Icereach
	[190224] = 2, --	Undaunted Box: Veteran Imperial City Prison
	[190237] = 2, --	Undaunted Box: Veteran Lair of Maarselok
	[190233] = 2, --	Undaunted Box: Veteran March of Sacrifices
	[190232] = 2, --	Undaunted Box: Veteran Moon Hunter
	[190236] = 2, --	Undaunted Box: Veteran Moongrave Fane
	[190244] = 2, --	Undaunted Box: Veteran Red Petal Bastion
	[190226] = 2, --	Undaunted Box: Veteran Ruins of Mazzatun
	[190231] = 2, --	Undaunted Box: Veteran Scalecaller Peak
	[190222] = 2, --	Undaunted Box: Veteran Selene's Web
	[190247] = 2, --	Undaunted Box: Veteran Shipwright's Regret
	[190210] = 2, --	Undaunted Box: Veteran Spindleclutch
	[190241] = 2, --	Undaunted Box: Veteran Stone Garden
	[190218] = 2, --	Undaunted Box: Veteran Tempest Island
	[190243] = 2, --	Undaunted Box: Veteran the Cauldron
	[190245] = 2, --	Undaunted Box: Veteran the Dread Cellar
	[190239] = 2, --	Undaunted Box: Veteran Unhallowed Grave
	[190223] = 2, --	Undaunted Box: Veteran Vaults of Madness
	[190219] = 2, --	Undaunted Box: Veteran Volenfell
	[190213] = 2, --	Undaunted Box: Veteran Wayrest Sewers
	[190225] = 2, --	Undaunted Box: Veteran White-Gold Tower
	[190261] = 2, --	Undaunted Box: Volenfell
	[190255] = 2, --	Undaunted Box: Wayrest Sewers
	[190267] = 2, --	Undaunted Box: White-Gold Tower


	-- W03	
	[182599] = 2,	-- Daedric War Spoils
	[182592] = 1,	-- Glorious Daedric War Spoils

	-- W04 & W29	Midyear Mayhem
	[121526] = 2,	-- Pelinal's Midyear Boon Box
	[171535] = 2, -- Pelinal's Midyear Boon Box 2021-01-28
	[175563] = 2, -- Pelinal's Midyear Boon Box 2021-01-28

	-- W07 Whitestrake's Mayhem
	[182501] = 2, -- Pelinal's Midyear Boon Box 2021-02-18

	-- W07	Murkmire Celebration

	-- W08	Tribunal Celebration
	[171476] = 2,	-- Tribunal Coffer
	[171480] = 1,	-- Glorious Tribunal Coffer

	-- W09	Thieves Guild and Dark Brotherhood Celebration

	-- W12	Jester's Festival
	[171731] = 1,	-- Stupendous Jester's Festival Box
	[171732] = 2,	-- Jester's Festival Box
	[183872] = 2,	-- Jester's Festival Box	2022-03-31 +8
	[183873] = 1,	-- Stupendous Jester's Festival Box	2022-03-31 +8

	-- W13	(4th April) 	Anniversary Jubilee
	[171779] = 2,	-- 7th Anniversary Jubilee Gift Box	21-04-01 +14
	[183890] = 2,	-- 8th Anniversary Jubilee Gift Box	22-04-07 +12

	-- W18	Vampire Week

	-- W25	Midyear Mayhem

	-- W26	Zeal of Zenithar
	[187746] = 1,	-- Zenithar’s Sublime Parcel
  [187701] = 2,	-- Zenithar’s Delightful Parce

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

	-- W39	Heroes of High Isle
	[190059] = 1,	-- 22	Society of the Steadfast's Largesse
	[190058] = 2,	-- 22	Society of the Steadfast's Munificence

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
	[190013] = 1, --	22 Dremora Plunder Skull, Arena
	[190014] = 1, --	22 Dremora Plunder Skull, Incursions
	[190015] = 1, --	22 Dremora Plunder Skull, Delve
	[190016] = 1, --	22 Dremora Plunder Skull, Dungeon
	[190017] = 1, --	22 Dremora Plunder Skull, Public & Sweeper
	[190018] = 1, --	22 Dremora Plunder Skull, Trial
	[190019] = 1, --	22 Dremora Plunder Skull, World
	[190038] = 1, --	22 Dremora Plunder Skull, Crowborne Horror
	[190037] = 2, --	22 Plunder Skull

	-- W46	Dark Heart of Skyrim Celebration
	[167226] = 2, --	21 Box of Gray Host Pillage
	[167227] = 1, --	21 Bulging Box of Gray Host Pillage
	[193761] = 2, --	22 Box of Gray Host Pillage
	[193762] = 1, --	22 Glorious Box of Gray Host Pillage

	-- w50	New Life Festival
	[96390] = 2,	-- 16	New Life Festival Box
	[133557] = 2,	-- 17	New Life Festival Box.
	[141823] = 2,	-- 18	New Life Festival Box
	[159463] = 1,	-- 19	Stupendous Jester's Festival Box
	[156779] = 2,	-- 19	New Life Festival Box
	[171731] = 1,	-- 20	Stupendous Jester's Festival Box
	[171327] = 2,	-- 20	New Life Festival Box
	[182494] = 2,	-- 21	New Life Festival Box
	[182494] = 2,	-- 21	New Life Festival Box
	[183873] = 1,	-- 21	Stupendous Jester's Festival Box
	[192368] = 2,	-- 22	New Life Festival Box
}

local EVENTQUESTIDS = {
	[6695] = 1, -- Witches Festival: Plucking the Crow

	--	Jester's Festival
	[5941] = 1,	-- The Jester's Festival
		[5921] = 1,	-- Springtime Flair
		[5931] = 1,	-- A Noble Guest
		[5937] = 1,	-- Royal Revelry
		[6622] = 1,	-- A Foe Most Porcine
		[6632] = 1,	-- The King's Spoils
		[6640] = 1,	-- Prankster's Carnival

	--	The New Life Festival
	[6134] = 1,	-- The New Life Festival
		[5811] = 1,	-- Snow Bear Plunge
		[5835] = 1,	-- The Trial of Five-Clawed Guile
		[5837] = 1,	-- Lava Foot Stomp
		[5838] = 1,	-- Mud Ball Merriment
		[5839] = 1,	-- Signal Fire Sprint
		[5845] = 1,	-- Castle Charm Challenge
		[5855] = 1,	-- Fish Boon Feast
		[5856] = 1,	-- Stonetooth Bash
	[6588] = 1,	-- Old Life Observance
}

EVENTEXPBUFFS = {
	[91369]	= 1167, -- Jester's Experience Boost Pie
	[91449]	= 1168, -- Breda's Magnificent Mead
	[96118]	= 479,	-- Withcmother's Boon -> Witchmother's Whistle
	[152514]	= 9012,	-- 2021 Jubilee cake
	[167846]	= 10287,	-- 2022 Jubilee cake
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

			if dailysReset <= os.time() then	-- if playing past the reset time the reset time needs to be refreshed
				dailysReseted = os.time() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY) - 86400	-- 24h*60min*60sec = 86400 seconds
				dailysReset = os.time() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)
				todaysYear = tonumber(os.date("%Y", dailysReseted))
				todaysDate = tonumber(os.date("%Y%m%d", dailysReseted))
			end

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
local collectibleCooldownEnds = 0
local function GiveThatSweetExpBoost( abilityId )

	if	eventorSettings.keepEventBuffsOn  and
	(eventorSettings.whenOurEventBuffRunsOut or 0) + (eventorSettings.eventBuffsThreshold * 60)	<	os.time()	and
	collectibleCooldownEnds < os.time()	then

			if abilityId and IsCollectibleUsable(EVENTEXPBUFFS[abilityId])	then
				UseCollectible( EVENTEXPBUFFS[abilityId] )
				local cooldownRemaining, _ = GetCollectibleCooldownAndDuration(EVENTEXPBUFFS[abilityId])
				collectibleCooldownEnds = os.time() + cooldownRemaining
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
	if not EVENTEXPBUFFS[abilityId] then return end	-- Not an event buff so ending

--	ticketAlert()

	if (beginTime + 7190 < endTime) then	-- 2h buff is 7200 seconds and logout takes 10 seconds.
		eventorSettings.lastTimeSomeoneGainedEventBuff = os.time()
		eventorSettings.lastEventBuffId = abilityId
--		d ( ADDON .. ": " .. zo_iconTextFormat(GetAbilityIcon(abilityId) , "100%", "100%", GetAbilityName(abilityId) ) .. " was gained by " .. unitName)
	end

	if unitTag == "player"	then
		if changeType == EFFECT_RESULT_GAINED then	-- Player got an event buff
			eventorSettings.whenOurEventBuffRunsOut	= os.time() + (endTime - beginTime)
			activePlayerBuffs[abilityId] = eventorSettings.whenOurEventBuffRunsOut
--			d( ADDON .. ": " .. unitName .. " gained " .. zo_iconTextFormat(GetAbilityIcon(abilityId) , "100%", "100%", GetAbilityName(abilityId) ) .. " timeleft:" .. ZO_FormatTimeLargestTwo((endTime - beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL) )

		elseif changeType == EFFECT_RESULT_UPDATED then	-- Player event buff for refreshed
			eventorSettings.whenOurEventBuffRunsOut	= os.time() + (endTime - beginTime)
			activePlayerBuffs[abilityId] = eventorSettings.whenOurEventBuffRunsOut
		--	d( ADDON .. ": players " .. tostring(abilityId) .. "/" .. effectName .. " was refreshed for " .. ZO_FormatTimeLargestTwo((endTime-beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))
		elseif changeType == EFFECT_RESULT_FADED	then	-- Player lost event buff
			activePlayerBuffs[abilityId] = false
			eventorSettings.whenOurEventBuffRunsOut	= os.time()
		--	d( ADDON .. ": players " .. tostring(abilityId) .. "/" .. effectName .. " faded" )
			GiveThatSweetExpBoost(abilityId)
		end
	else	-- Someone else gained a event buff
		if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED)
		and	beginTime + 7190 < endTime	-- 2h buff is 7200 seconds and logout takes 10 seconds.
		and	not activePlayerBuffs[abilityId] then	-- Player is missing the buff and someone else actually got a new buff.
--			d( ADDON .. ": " .. ZO_LinkHandler_CreateLinkWithoutBrackets(unitName, nil, CHARACTER_LINK_TYPE, unitName) ..  tostring(abilityId) .. "/" .. effectName .. " gained(1) or updated(3) =" .. changeType .. " timeleft: " .. ZO_FormatTimeLargestTwo((endTime-beginTime), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL) )
		GiveThatSweetExpBoost(abilityId)
		end
	end
end

-- Lets fire up the add-on by registering for events and loading variables
function Eventor.Initialize()
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_LOOT_RECEIVED, Eventor.lootedEventBox)	-- Start listening to gained loot
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CURRENCY_UPDATE, Eventor.EVENT_CURRENCY_UPDATE)	-- Start listening to gained tickets
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, Eventor.EVENT_PLAYER_ACTIVATED)

  accountEventLootHistory   = ZO_SavedVars:NewAccountWide("Eventor_accountEventLootHistory", 1, nil, {}, GetWorldName() )	-- Load event loot history
	eventorSettings   = ZO_SavedVars:NewAccountWide("Eventor_eventorSettings", 1, nil, {}, GetWorldName() )	-- Load settings

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

-- Registering for the add on loading loop
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, Eventor.EVENT_ADD_ON_LOADED)