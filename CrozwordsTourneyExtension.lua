local function CrozwordsTourneyExtension()
	local self = {}
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	self.name = "Tourney Point Tracker"
	self.author = "UTDZac"
	self.description = "This extension adds extra functionality to the Tracker for counting and displaying points, great for friendly competitions."
	self.version = "3.0"
	self.url = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension"

	function self.checkForUpdates()
		local versionCheckUrl = "https://api.github.com/repos/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"

		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, nil)
		return isUpdateAvailable, downloadUrl
	end

	-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
	local Zones = {
		MtMoon = { [114] = true, [115] = true, [116] = true },
		SSAnne = { [120] = true, [121] = true, [122] = true, [123] = true, [177] = true, [178] = true },
		RockTunnel = { [154] = true, [155] = true },
		RocketHideout = { [27] = true, [128] = true, [129] = true, [130] = true, [131] = true, [224] = true, [225] = true },
		PokemonTower = { [161] = true, [162] = true, [163] = true, [164] = true, [165] = true, [166] = true, [167] = true },
		SilphCo = { [132] = true, [133] = true, [134] = true, [135] = true, [136] = true, [137] = true, [138] = true, [139] = true, [140] = true, [141] = true, [142] = true, [229] = true },
		CinnabarMansion = { [143] = true, [144] = true, [145] = true, [146] = true },
		Dojo = { [228] = true },
		VictoryRoad = { [125] = true, [126] = true, [127] = true, },
	}

	local listPixelIcon = {
		{1,1,1,1,1,1,0,1,1},
		{0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,0,1,1},
		{0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,0,1,1},
		{0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,0,1,1},
		{0,0,0,0,0,0,0,0,0},
	}

	-- Common conditions for obtaining milestones
	local defeatAtLeastOne = function(trainers)
		for _, isDefeated in pairs(trainers or {}) do
			if isDefeated then
				return true
			end
		end
		return false
	end
	local defeatAll = function(trainers)
		for _, isDefeated in pairs(trainers or {}) do
			if not isDefeated then
				return false
			end
		end
		return true
	end
	local escapedZone = function(zone)
		-- Escape "successful" if there is no associated zone, or the player isn't there anymore
		return not zone or not zone[TrackerAPI.getMapId()]
	end

	-- Ensures the point value is above the minimum threshold (-100) and below the max (100)
	local verifyPointMax = function(value)
		if type(value) ~= "number" then
			return 0
		elseif value > 100 then
			return 100
		elseif value < -100 then
			return -100
		end
		return value
	end

	local MilestoneTypes = {
		SingleTrainer = "Defeat a single trainer",
		AllTrainers = "Defeat all trainers",
		EscapeZone = "Defeat all required trainers and escape the area",
		FullClear = "Full clear an area; optionally must escape",
	}

	local defaultMilestones = {
		{
			key = "Rival1", -- Internal Lable used for quick reference from the milestone list
			exportKey = "R1", -- Must be exactly 2-characters and unique
			label = "Rival: Lab", -- External label shown to use
			type = MilestoneTypes.SingleTrainer, -- Requirements to obtain the milestone
			points = 1, -- Number of points awarded when obtained
			exclude = true, -- Excluded from the default list of active milestones (can be enabled in UI)
		},
		{
			key = "ForestTrainer1",
			exportKey = "F1",
			label = "Forest Trainer 1",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "ForestTrainer2",
			exportKey = "F2",
			label = "Forest Trainer 2",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "ForestTrainer3",
			exportKey = "F3",
			label = "Forest Trainer 3",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "ForestTrainer4",
			exportKey = "F4",
			label = "Forest Trainer 4",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "ForestTrainer5",
			exportKey = "F5",
			label = "Forest Trainer 5",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "Rival2",
			exportKey = "R2",
			label = "Rival: Route 22",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
			exclude = true,
		},
		{
			key = "Brock",
			exportKey = "G1",
			label = "Gym 1: Brock",
			type = MilestoneTypes.SingleTrainer,
			points = 3,
		},
		{
			key = "MtMoonEscape",
			exportKey = "ME",
			label = "Mt. Moon Exit",
			type = MilestoneTypes.EscapeZone,
			points = 1,
			zone = Zones.MtMoon,
			exclude = true,
		},
		{
			key = "MtMoonFC",
			exportKey = "MF",
			label = "Mt. Moon FC",
			type = MilestoneTypes.FullClear,
			points = 2,
			zone = Zones.MtMoon,
		},
		{
			key = "RivalBridge",
			exportKey = "R3",
			label = "Rival: Bridge",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "Misty",
			exportKey = "G2",
			label = "Gym 2: Misty",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "RivalBoat",
			exportKey = "R4",
			label = "Rival: S.S. Anne",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
			exclude = true,
		},
		{
			key = "SSAnneFC",
			exportKey = "AF",
			label = "S.S. Anne FC",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.SSAnne,
		},
		{
			key = "Surge",
			exportKey = "G3",
			label = "Gym 3: Surge",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "RockTunnelEscape",
			exportKey = "RE",
			label = "Rock Tunnel Exit",
			type = MilestoneTypes.EscapeZone,
			points = 1,
			zone = Zones.RockTunnel,
		},
		{
			key = "RockTunnelFC",
			exportKey = "RF",
			label = "Rock Tunnel FC",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.RockTunnel,
		},
		{
			key = "RivalTower",
			exportKey = "R5",
			label = "Rival: Tower",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "RocketHideout",
			exportKey = "HE",
			label = "Rocket Hideout Exit",
			type = MilestoneTypes.EscapeZone,
			points = 1,
			zone = Zones.RocketHideout,
		},
		{
			key = "PokemonTowerFC",
			exportKey = "TF",
			label = Constants.Words.POKEMON .. " Tower FC",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.PokemonTower,
			exclude = true,
		},
		{
			key = "Erika",
			exportKey = "G4",
			label = "Gym 4: Erika",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "Koga",
			exportKey = "G5",
			label = "Gym 5: Koga",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "RivalSilph",
			exportKey = "R6",
			label = "Rival: Silph Co.",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "SilphEscape",
			exportKey = "SE",
			label = "Silph Co. Exit",
			type = MilestoneTypes.EscapeZone,
			points = 1,
			zone = Zones.SilphCo,
		},
		{
			key = "SilphFC",
			exportKey = "SF",
			label = "Silph Co. FC",
			type = MilestoneTypes.FullClear,
			points = 3,
			zone = Zones.SilphCo,
		},
		{
			key = "Dojo",
			exportKey = "DJ",
			label = "Fighting Dojo",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.Dojo,
			exclude = true,
		},
		{
			key = "Sabrina",
			exportKey = "G6",
			label = "Gym 6: Sabrina",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "CinnabarFC",
			exportKey = "CF",
			label = "Cinn. Mansion FC",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.CinnabarMansion,
		},
		{
			key = "Blaine",
			exportKey = "G7",
			label = "Gym 7: Blaine",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "GiovanniGym",
			exportKey = "G8",
			label = "Gym 8: Giovanni",
			type = MilestoneTypes.SingleTrainer,
			points = 2,
		},
		{
			key = "RivalVR",
			exportKey = "R7",
			label = "Rival: Victory Road",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "VictoryRoad",
			exportKey = "VF",
			label = "Victory Road FC",
			type = MilestoneTypes.FullClear,
			points = 1,
			zone = Zones.VictoryRoad,
			exclude = true,
		},
		{
			key = "Lorelei",
			exportKey = "E1",
			label = "Elite 4: Lorelei",
			type = MilestoneTypes.SingleTrainer,
			points = 1,
		},
		{
			key = "Bruno",
			exportKey = "E2",
			label = "Elite 4: Bruno",
			type = MilestoneTypes.SingleTrainer,
			points = 2,
		},
		{
			key = "Agatha",
			exportKey = "E3",
			label = "Elite 4: Agatha",
			type = MilestoneTypes.SingleTrainer,
			points = 2,
		},
		{
			key = "Lance",
			exportKey = "E4",
			label = "Elite 4: Lance",
			type = MilestoneTypes.SingleTrainer,
			points = 3,
		},
		{
			key = "Champion",
			exportKey = "E5",
			label = "Elite 4: Champion",
			type = MilestoneTypes.SingleTrainer,
			points = 5,
		},
	}
	self.Milestones = {}
	self.ExportKeysMap = {} -- Used for quicker lookups during load/save milestone list
	for i, defaultMilestone in ipairs(defaultMilestones) do
		self.Milestones[defaultMilestone.key] = {}
		local milestone = self.Milestones[defaultMilestone.key]
		-- Copy the default milestone data
		for k, v in pairs(defaultMilestone) do
			milestone[k] = v
		end

		milestone.ordinal = i
		self.ExportKeysMap[milestone.exportKey] = milestone
	end

	local TrainerMilestoneMap = {
		-- GYMS - 8 total
		[414] = self.Milestones.Brock,
		[415] = self.Milestones.Misty,
		[416] = self.Milestones.Surge,
		[417] = self.Milestones.Erika,
		[418] = self.Milestones.Koga,
		[420] = self.Milestones.Sabrina,
		[419] = self.Milestones.Blaine,
		[350] = self.Milestones.GiovanniGym,

		-- RIVALS - 7 unique sets
		[326] = self.Milestones.Rival1,
		[327] = self.Milestones.Rival1,
		[328] = self.Milestones.Rival1,
		[329] = self.Milestones.Rival2,
		[330] = self.Milestones.Rival2,
		[331] = self.Milestones.Rival2,
		[332] = self.Milestones.RivalBridge,
		[333] = self.Milestones.RivalBridge,
		[334] = self.Milestones.RivalBridge,
		[426] = self.Milestones.RivalBoat,
		[427] = self.Milestones.RivalBoat,
		[428] = self.Milestones.RivalBoat,
		[429] = self.Milestones.RivalTower,
		[430] = self.Milestones.RivalTower,
		[431] = self.Milestones.RivalTower,
		[432] = self.Milestones.RivalSilph,
		[433] = self.Milestones.RivalSilph,
		[434] = self.Milestones.RivalSilph,
		[435] = self.Milestones.RivalVR,
		[436] = self.Milestones.RivalVR,
		[437] = self.Milestones.RivalVR,

		-- VIRIDIAN FOREST - 5 total
		[102] = self.Milestones.ForestTrainer1,
		[103] = self.Milestones.ForestTrainer2,
		[104] = self.Milestones.ForestTrainer3,
		[531] = self.Milestones.ForestTrainer4,
		[532] = self.Milestones.ForestTrainer5,

		-- ALL MT MOON - 12 total
		[108] = self.Milestones.MtMoonFC,
		[109] = self.Milestones.MtMoonFC,
		[121] = self.Milestones.MtMoonFC,
		[169] = self.Milestones.MtMoonFC,
		[120] = self.Milestones.MtMoonFC,
		[91] = self.Milestones.MtMoonFC,
		[181] = self.Milestones.MtMoonFC,
		[170] = { self.Milestones.MtMoonFC, self.Milestones.MtMoonEscape, }, -- Final required trainer Miguel
		[351] = self.Milestones.MtMoonFC,
		[352] = self.Milestones.MtMoonFC,
		[353] = self.Milestones.MtMoonFC,
		[354] = self.Milestones.MtMoonFC,

		-- ALL SS ANNE - 16 total (exclude rival, he's implied)
		[96] = self.Milestones.SSAnneFC,
		[126] = self.Milestones.SSAnneFC,
		[422] = self.Milestones.SSAnneFC,
		[421] = self.Milestones.SSAnneFC,
		[140] = self.Milestones.SSAnneFC,
		[224] = self.Milestones.SSAnneFC,
		[138] = self.Milestones.SSAnneFC,
		[139] = self.Milestones.SSAnneFC,
		[136] = self.Milestones.SSAnneFC,
		[137] = self.Milestones.SSAnneFC,
		[482] = self.Milestones.SSAnneFC,
		[223] = self.Milestones.SSAnneFC,
		[483] = self.Milestones.SSAnneFC,
		[127] = self.Milestones.SSAnneFC,
		[134] = self.Milestones.SSAnneFC,
		[135] = self.Milestones.SSAnneFC,

		-- ALL ROCK TUNNEL - 15 total
		[168] = self.Milestones.RockTunnelFC,
		[166] = self.Milestones.RockTunnelFC,
		[159] = self.Milestones.RockTunnelFC,
		[165] = self.Milestones.RockTunnelFC,
		[190] = self.Milestones.RockTunnelFC,
		[191] = self.Milestones.RockTunnelFC,
		[192] = self.Milestones.RockTunnelFC,
		[193] = self.Milestones.RockTunnelFC,
		[194] = self.Milestones.RockTunnelFC,
		[158] = self.Milestones.RockTunnelFC,
		[189] = self.Milestones.RockTunnelFC,
		[164] = self.Milestones.RockTunnelFC,
		[476] = self.Milestones.RockTunnelFC,
		[475] = self.Milestones.RockTunnelFC,
		[474] = { self.Milestones.RockTunnelFC, self.Milestones.RockTunnelEscape, }, -- Final required trainer Dana

		[348] = self.Milestones.RocketHideout, -- Giovanni

		-- ALL POKEMON TOWER - 13 total (exclude rival and top grunts, they're implied)
		[441] = self.Milestones.PokemonTowerFC,
		[442] = self.Milestones.PokemonTowerFC,
		[443] = self.Milestones.PokemonTowerFC,
		[444] = self.Milestones.PokemonTowerFC,
		[445] = self.Milestones.PokemonTowerFC,
		[446] = self.Milestones.PokemonTowerFC,
		[447] = self.Milestones.PokemonTowerFC,
		[448] = self.Milestones.PokemonTowerFC,
		[449] = self.Milestones.PokemonTowerFC,
		[450] = self.Milestones.PokemonTowerFC,
		[451] = self.Milestones.PokemonTowerFC,
		[452] = self.Milestones.PokemonTowerFC,
		[453] = self.Milestones.PokemonTowerFC,
		[369] = self.Milestones.PokemonTowerFC,
		[370] = self.Milestones.PokemonTowerFC,
		[371] = self.Milestones.PokemonTowerFC,

		[349] = { self.Milestones.SilphEscape, self.Milestones.SilphFC, }, -- Giovanni

		-- ALL SILPH CO - total 30 (exclude rival, he's implied)
		[336] = self.Milestones.SilphFC,
		[337] = self.Milestones.SilphFC,
		[338] = self.Milestones.SilphFC,
		[339] = self.Milestones.SilphFC,
		[340] = self.Milestones.SilphFC,
		[341] = self.Milestones.SilphFC,
		[342] = self.Milestones.SilphFC,
		[343] = self.Milestones.SilphFC,
		[344] = self.Milestones.SilphFC,
		[345] = self.Milestones.SilphFC,
		[373] = self.Milestones.SilphFC,
		[374] = self.Milestones.SilphFC,
		[375] = self.Milestones.SilphFC,
		[376] = self.Milestones.SilphFC,
		[377] = self.Milestones.SilphFC,
		[378] = self.Milestones.SilphFC,
		[379] = self.Milestones.SilphFC,
		[380] = self.Milestones.SilphFC,
		[381] = self.Milestones.SilphFC,
		[382] = self.Milestones.SilphFC,
		[383] = self.Milestones.SilphFC,
		[384] = self.Milestones.SilphFC,
		[385] = self.Milestones.SilphFC,
		[386] = self.Milestones.SilphFC,
		[387] = self.Milestones.SilphFC,
		[388] = self.Milestones.SilphFC,
		[389] = self.Milestones.SilphFC,
		[390] = self.Milestones.SilphFC,
		[391] = self.Milestones.SilphFC,
		[286] = self.Milestones.SilphFC,

		-- ALL FIGHTING DOJO - 5 total
		[317] = self.Milestones.Dojo,
		[318] = self.Milestones.Dojo,
		[319] = self.Milestones.Dojo,
		[320] = self.Milestones.Dojo,
		[321] = self.Milestones.Dojo,

		-- ALL CINNABAR MANSION - 6 total
		[216] = self.Milestones.CinnabarFC,
		[218] = self.Milestones.CinnabarFC,
		[219] = self.Milestones.CinnabarFC,
		[534] = self.Milestones.CinnabarFC,
		[335] = self.Milestones.CinnabarFC,
		[346] = self.Milestones.CinnabarFC,
		[347] = self.Milestones.CinnabarFC,

		-- ALL VICTORY ROAD - 12 total
		[406] = self.Milestones.VictoryRoad,
		[396] = self.Milestones.VictoryRoad,
		[325] = self.Milestones.VictoryRoad,
		[287] = self.Milestones.VictoryRoad,
		[298] = self.Milestones.VictoryRoad,
		[290] = self.Milestones.VictoryRoad,
		[393] = self.Milestones.VictoryRoad,
		[167] = self.Milestones.VictoryRoad,
		[404] = self.Milestones.VictoryRoad,
		[394] = self.Milestones.VictoryRoad,
		[403] = self.Milestones.VictoryRoad,
		[485] = self.Milestones.VictoryRoad,

		[410] = self.Milestones.Lorelei,
		[411] = self.Milestones.Bruno,
		[412] = self.Milestones.Agatha,
		[413] = self.Milestones.Lance,
		[438] = self.Milestones.Champion,
		[439] = self.Milestones.Champion,
		[440] = self.Milestones.Champion,
	}

	local saveLaterFrames = 0 -- These frames count down and will save the extension settings when it reaches 0
	local highlightFrames = 0 -- These frames count down and make the point count shown "highlighted"
	local ExtLabel = "TourneyPointTracker" -- to be prepended to all other settings here
	self.ExtSettingsData = {
		AutoCountPoints = {
			value = true, -- default
			label = "Auto count points as you play",
		},
		SkipFailedAttempts = {
			value = false, -- default
			label = "Only count runs out of the lab",
		},
		RequireEscapeArea = {
			value = false, -- default
			label = "Must exit dungeons for points",
		},
		TotalPoints = {
			value = 0, -- default
			label = "Total points for all seeds:",
			addPoints = function(this, val) if this.value then this.value = this.value + (val or 0) end end,
		},
		ObtainedMilestones = {
			value = "",
			parse = function(this, input)
				this.value = input or this.value or ""
				for key in (this.value .. ","):gmatch("([^,]*),") do
					if self.Milestones[key] then
						self.Milestones[key].obtained = true
					end
				end
			end,
			updateSelf = function(this)
				local exportTable = {}
				for key, milestone in pairs(self.Milestones) do
					if milestone.obtained then
						-- Use 'key' instead of 'exportKey' for upgrade compatibility
						table.insert(exportTable, key)
					end
				end
				if #exportTable > 0 then
					this.value = table.concat(exportTable, ",")
				else
					this.value = ""
				end
			end,
		},
		DefeatedTrainers = {
			value = "",
			-- Loads a string of numbers (TrainerIds) into all milestones that have those trainers
			parse = function(this, input)
				this.value = input or this.value or ""
				for trainerIdStr in (this.value .. ","):gmatch("([^,]*),") do
					local trainerId = tonumber(trainerIdStr)
					if trainerId then
						for _, milestone in pairs(self.Milestones) do
							if milestone.trainers == nil then
								milestone.trainers = {}
							end
							-- Only update trainers that exist in that milestone
							if milestone.trainers[trainerId] ~= nil then
								milestone.trainers[trainerId] = true
							end
						end
					end
				end
			end,
			updateSelf = function(this)
				local exportTable = {}
				for _, milestone in pairs(self.Milestones) do
					if not milestone.obtained then
						for trainerId, isDefeated in pairs(milestone.trainers or {}) do
							if isDefeated then
								table.insert(exportTable, trainerId)
							end
						end
					end
				end
				if #exportTable > 0 then
					this.value = table.concat(exportTable, ",")
				else
					this.value = ""
				end
			end,
		},
		ActiveMilestoneList = {
			value = "",
			format = "%s%s%s", -- "EXPORTKEY ACTIVE POINTS", always 2 characters + 1 character + N characters (no spaces)
			parse = function(this, input)
				this.value = input or this.value or ""
				for importValue in (this.value .. ","):gmatch("([^,]*),") do
					local exportKey = importValue:sub(1, 2)
					local activeStatusStr = importValue:sub(3, 3)
					local pointsStr = importValue:sub(4)

					local milestone = self.ExportKeysMap[exportKey]
					if milestone then
						milestone.exclude = activeStatusStr ~= "1"
						milestone.points = verifyPointMax(tonumber(pointsStr or ""))
					end
				end
			end,
			updateSelf = function(this)
				this.value = this:exportToString(self.Milestones)
			end,
			exportToString = function(this, milestoneList)
				local exportTable = {}
				-- Export in-order
				for _, m in ipairs(defaultMilestones) do
					local milestone = milestoneList[m.key] or m
					local activeStatus = Utils.inlineIf(milestone.exclude, "0", "1")
					local exportedVale = string.format(this.format, milestone.exportKey, activeStatus, milestone.points or 0)
					table.insert(exportTable, exportedVale)
				end
				if #exportTable > 0 then
					return table.concat(exportTable, ",")
				else
					return ""
				end
			end,
		},
	}
	for key, setting in pairs(self.ExtSettingsData) do
		setting.key = tostring(key)
		if type(setting.load) ~= "function" then
			setting.load = function(this)
				local loadedValue = TrackerAPI.getExtensionSetting(ExtLabel, this.key)
				if loadedValue ~= nil then
					this.value = loadedValue
				end
				return loadedValue
			end
		end
		if type(setting.save) ~= "function" then
			setting.save = function(this)
				if this.value ~= nil then
					TrackerAPI.saveExtensionSetting(ExtLabel, this.key, this.value)
				end
			end
		end
	end

	local CrozTourneyScreen = {
		Colors = {
			text = "Default text",
			border = "Upper box border",
			boxFill = "Upper box background",
		},
	}
	local ViewCurrentScoreScreen = {
		Colors = {
			text = "Default text",
			border = "Upper box border",
			boxFill = "Upper box background",
		},
	}
	local EditMilestonesScreen = {
		Colors = {
			text = "Default text",
			border = "Upper box border",
			boxFill = "Upper box background",
		},
	}
	local previousScreen = nil -- use to help navigate backward from the options menu, for ease of access

	-- Helper Functions
	local isSupported = function() return GameSettings.game == 3 end

	local shouldShowPoints = function()
		return Program.currentScreen == TrackerScreen and Tracker.Data.isViewingOwn and not TrackerScreen.canShowBallPicker()
	end

	local updateSettings = function()
		for _, setting in pairs(self.ExtSettingsData) do
			if type(setting.updateSelf) == "function" then
				setting:updateSelf()
			end
		end
	end

	local resetMilestones = function()
		-- ExtSettingsData.TotalPoints.value = 0 -- don't reset points, these need to accumulate across multiple seeds
		self.ExtSettingsData.ObtainedMilestones.value = ""

		-- Unobtain all milestones
		for _, milestone in pairs(self.Milestones) do
			milestone.obtained = false
		end

		-- Add the trainer list to each milestone
		for trainerId, milestoneList in pairs(TrainerMilestoneMap) do
			-- If an individual milestone, put it into a list instead
			if milestoneList.type then
				milestoneList = { milestoneList }
			end

			for _, milestone in pairs(milestoneList) do
				if milestone.trainers == nil then
					milestone.trainers = {}
				end
				milestone.trainers[trainerId] = false
			end
		end
	end

	local exportMilestones = function()
		local obtainedMilestones = {}
		local totalPoints = 0
		local forestTrainers = 0
		for key, milestone in pairs(self.Milestones) do
			if milestone.obtained and not milestone.exclude then
				totalPoints = totalPoints + (milestone.points or 0)
				if key:sub(1, 6) == "Forest" then
					forestTrainers = forestTrainers + 1
				else
					table.insert(obtainedMilestones, { key = key, ordinal = milestone.ordinal} )
				end
			end
		end

		-- Order the milestones based on their predefined order
		table.sort(obtainedMilestones, function(a, b) return a.ordinal < b.ordinal end)
		local outputTable = {}
		for _, milestone in ipairs(obtainedMilestones) do
			table.insert(outputTable, milestone.key)
		end
		-- Merge in the forest milestones as a single milestone
		if forestTrainers > 0 then
			table.insert(outputTable, 1, string.format("Forest(%s)", forestTrainers))
		end

		local milestoneText
		if #outputTable > 0 then
			milestoneText = table.concat(outputTable, ", ")
		else
			milestoneText = "No milestones achieved"
		end

		local includeAnS = Utils.inlineIf(totalPoints ~= 1, "s", "")
		return string.format("%s Point%s: %s", totalPoints, includeAnS, milestoneText)
	end

	local getCurrentSeedPointTotal = function()
		local totalPoints = 0
		for _, milestone in pairs(self.Milestones) do
			if milestone.obtained and not milestone.exclude then
				totalPoints = totalPoints + (milestone.points or 0)
			end
		end
		return totalPoints
	end

	local obtainMilestone = function(milestone)
		milestone.obtained = true
		if not milestone.exclude then
			self.ExtSettingsData.TotalPoints:addPoints(milestone.points or 0)
			CrozTourneyScreen.refreshButtons()
			ViewCurrentScoreScreen.refreshButtons()
			highlightFrames = 270
		end
		updateSettings()
		saveLaterFrames = 150
	end

	local unobtainMilestone = function(milestone)
		milestone.obtained = false
		for trainerId, _ in pairs(milestone.trainers or {}) do
			milestone.trainers[trainerId] = false
		end

		if not milestone.exclude then
			self.ExtSettingsData.TotalPoints:addPoints(-1 * (milestone.points or 0))
			CrozTourneyScreen.refreshButtons()
			ViewCurrentScoreScreen.refreshButtons()
			highlightFrames = 270
		end
		updateSettings()
		saveLaterFrames = 150
	end

	local countRemainingTrainers = function(milestone)
		local numNotDefeated = 0
		for _, isDefeated in pairs(milestone.trainers or {}) do
			if not isDefeated then
				numNotDefeated = numNotDefeated + 1
			end
		end
		return numNotDefeated
	end

	-- If conditions are met to receive milestone, mark it as obtained and add points
	local checkMilestoneForPoints = function(milestone)
		if not milestone or milestone.obtained then return end

		if milestone.type == MilestoneTypes.SingleTrainer then
			-- Award point as soon as any of the trainers listed are defeated (rival has 3 ids)
			if defeatAtLeastOne(milestone.trainers) then
				milestone.obtained = true
			end
		elseif milestone.type == MilestoneTypes.AllTrainers then
			-- Award point as soon as all trainers listed are defeated
			if defeatAll(milestone.trainers) then
				milestone.obtained = true
			end
		elseif milestone.type == MilestoneTypes.EscapeZone then
			-- Award point for defeating necessary story-related trainers and then escaping
			if defeatAll(milestone.trainers) and escapedZone(milestone.zone) then
				milestone.obtained = true
			end
		elseif milestone.type == MilestoneTypes.FullClear then
			-- Award point for defeating all trainers depending on if its required to escape or not
			if defeatAll(milestone.trainers) and (not self.ExtSettingsData.RequireEscapeArea.value or escapedZone(milestone.zone)) then
				milestone.obtained = true
			end
		elseif type(milestone.customCondition) == "function" and milestone:customCondition() then
			milestone.obtained = true
		end

		-- If newly obtained milestone, add points
		if milestone.obtained then
			obtainMilestone(milestone)
		end
	end

	local checkAllMilestones = function()
		for _, milestone in pairs(self.Milestones) do
			checkMilestoneForPoints(milestone)
		end
		updateSettings()
	end

	local function loadSettingsData()
		for _, optionObj in pairs(self.ExtSettingsData) do
			if type(optionObj.load) == "function" then
				optionObj:load()
			end
			if type(optionObj.parse) == "function" then
				optionObj:parse()
			end
		end
	end

	local function saveSettingsData()
		for _, optionObj in pairs(self.ExtSettingsData) do
			if type(optionObj.save) == "function" then
				optionObj:save()
			end
		end
	end

	local function applyOptionsCallback(pointValue, callback)
		local settingsWereChange = false

		if self.ExtSettingsData.TotalPoints.value ~= pointValue then
			self.ExtSettingsData.TotalPoints.value = pointValue
			settingsWereChange = true
		end

		if settingsWereChange then
			saveSettingsData()
			if type(callback) == "function" then
				callback()
			end
			Program.redraw(true)
		end
	end

	local function openEditPointsPopup(callback)
		if not Main.IsOnBizhawk() then return end

		Program.destroyActiveForm()
		local form = forms.newform(320, 130, "Edit Total Points", function() client.unpause() end)
		Program.activeFormId = form
		Utils.setFormLocation(form, 100, 50)

		forms.label(form, self.ExtSettingsData.TotalPoints.label, 54, 20, 140, 20)

		local textboxPoints = forms.textbox(form, self.ExtSettingsData.TotalPoints.value or 0, 45, 20, "UNSIGNED", 200, 18)

		local saveButton = forms.button(form, "Save", function()
			local pointsAsNumber = tonumber(forms.gettext(textboxPoints) or "") or self.ExtSettingsData.TotalPoints.value
			applyOptionsCallback(pointsAsNumber, callback)
			client.unpause()
			forms.destroy(form)
		end, 75, 50)
		local cancelButton = forms.button(form, "Cancel", function()
			client.unpause()
			forms.destroy(form)
		end, 165, 50)
	end

	local function openSharePointsPopup(callback)
		if not Main.IsOnBizhawk() then return end

		local popupWidth, popupHeight = 500, 185

		Program.destroyActiveForm()
		local form = forms.newform(popupWidth, popupHeight, "Current Points/Milestones", function() client.unpause() end)
		Program.activeFormId = form
		Utils.setFormLocation(form, 100, 50)

		local boxLabel = "Points and milestones for the current seed (excludes evo bonuses):"
		forms.label(form, boxLabel, 33, 20, 400, 20)

		local textboxShareMilestones = forms.textbox(form, exportMilestones(), 430, 60, nil, 35, 41, true, false, "Vertical")

		local resetButton = forms.button(form, "Clear Seed/Points", function()
			self.ExtSettingsData.TotalPoints.value = 0
			resetMilestones()
			saveSettingsData()
			forms.settext(textboxShareMilestones, exportMilestones())
			if type(callback) == "function" then
				callback()
			end
		end, 34, 110, 135, 23)
		local cancelButton = forms.button(form, "Close", function()
			client.unpause()
			forms.destroy(form)
		end, 390, 110)
	end

	-- Determines if the seed should be counted, for purposes of incrementing the Attempts count and showing the share button
	local shouldSeedBeCounted = function()
		-- Option isn't even enabled, then count all seeds
		if not self.ExtSettingsData.SkipFailedAttempts.value then
			return true
		end

		-- Include this attempt if the first rival was beaten or if two or more trainers were beaten.
		return self.Milestones.Rival1.obtained or Utils.getGameStat(Constants.GAME_STATS.TRAINER_BATTLES) > 1
	end

	local promptMilestoneSetPoint = function(milestone)
		local title = string.format("%s Points", milestone.label or milestone.key)
		local editLabel = string.format('Points for %s (max 100):', milestone.label or milestone.key)
		local form = Utils.createBizhawkForm(title, 320, 130)

		forms.label(form, editLabel, 48, 10, 300, 20)
		local textBox = forms.textbox(form, (milestone.points or 0), 200, 30, "SIGNED", 50, 30)
		forms.button(form, "Save", function()
			local pointNumber = tonumber(forms.gettext(textBox) or "")
			if pointNumber then
				local pointsToAdd = milestone.points - verifyPointMax(pointNumber)
				milestone.points = verifyPointMax(pointNumber)
				-- Adjust total points accordingly if the milestone has already been obtained
				if milestone.obtained and pointsToAdd ~= 0 then
					self.ExtSettingsData.TotalPoints:addPoints(pointsToAdd)
					CrozTourneyScreen.refreshButtons()
				end
				updateSettings()
				Program.redraw(true)
			end
			client.unpause()
			forms.destroy(form)
		end, 72, 60)
		forms.button(form, "Cancel", function()
			client.unpause()
			forms.destroy(form)
		end, 157, 60)
	end

	local promptLoadMilestoneList = function()
		local form = Utils.createBizhawkForm("Load/Share Milestone List", 520, 270)
		Utils.setFormLocation(form, 80, 20)

		local AMList = self.ExtSettingsData.ActiveMilestoneList
		AMList:updateSelf()
		local shareableListCurrent = AMList.value

		forms.label(form, "Load a list of milestones from someone else by pasting the list here. [Ctrl + V]", 9, 10, 495, 20)
		local importBox = forms.textbox(form, "", 485, 48, nil, 10, 32, true, false, "Vertical")

		forms.label(form, "All current milestones you're playing with. Copy the list below and share with others. [Ctrl + C]", 9, 122, 495, 20)
		local currentBox = forms.textbox(form, shareableListCurrent, 485, 48, nil, 10, 142, true, false, "Vertical")

		forms.button(form, "Load the above Milestone List", function()
			local importListCode = forms.gettext(importBox)
			if importListCode ~= nil and importListCode ~= "" then
				AMList:parse(importListCode)
				EditMilestonesScreen.refreshButtons()
				Program.redraw(true)
				client.unpause()
				forms.destroy(form)
			end
		end, 9, 86, 170, 24)
		forms.button(form, "(Default Milestone List)", function()
			local defaultList = {}
			for _, m in ipairs(defaultMilestones) do
				defaultList[m.key] = m
			end
			local defaultListCode = AMList:exportToString(defaultList)
			forms.settext(importBox, defaultListCode)
		end, 361, 86, 135, 24)
		forms.button(form, "Close", function()
			client.unpause()
			forms.destroy(form)
		end, 220, 196, 70, 24)
	end

	-----------------------
	-- CrozTourneyScreen --
	-----------------------
	CrozTourneyScreen.refreshButtons = function()
		for _, button in pairs(CrozTourneyScreen.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
	end
	CrozTourneyScreen.Buttons = {
		ViewCurrentScore = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = listPixelIcon or Constants.PixelImages.MAGNIFYING_GLASS,
			text = "Milestones",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 54, 124, 16 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function()
				ViewCurrentScoreScreen.buildOutPagedButtons()
				ViewCurrentScoreScreen.refreshButtons()
				Program.changeScreenView(ViewCurrentScoreScreen)
			end
		},
		EditMilestones = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = Constants.PixelImages.GEAR,
			text = "Edit milestone list",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 74, 124, 16 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function()
				EditMilestonesScreen.buildOutPagedButtons()
				EditMilestonesScreen.refreshButtons()
				Program.changeScreenView(EditMilestonesScreen)
			end
		},
		ShareScore = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = Constants.PixelImages.INSTALL_BOX,
			text = "Share current seed score",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 94, 124, 16 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function() openSharePointsPopup(CrozTourneyScreen.refreshButtons) end
		},
		TotalScore = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = "",
			textColor = "Intermediate text",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 101, Constants.SCREEN.MARGIN + 116, 35, 11 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			updateSelf = function(this)
				this.text = tostring(self.ExtSettingsData.TotalPoints.value or 0)
			end,
			draw = function(this, shadowcolor)
				Drawing.drawText(Constants.SCREEN.WIDTH + 8, this.box[2], self.ExtSettingsData.TotalPoints.label, Theme.COLORS[CrozTourneyScreen.Colors.text], shadowcolor)
				local iconOffsetX = this.box[1] + 25 -- Utils.calcWordPixelLength(this.text) + 5
				Drawing.drawImageAsPixels(Constants.PixelImages.NOTEPAD, iconOffsetX, this.box[2], Theme.COLORS[CrozTourneyScreen.Colors.text], shadowcolor)
			end,
			onClick = function() openEditPointsPopup(CrozTourneyScreen.refreshButtons) end
		},
		Back = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function()
				if previousScreen ~= nil then
					Program.changeScreenView(previousScreen)
					previousScreen = nil
				else
					Program.changeScreenView(SingleExtensionScreen)
				end
			end
		},
	}
	-- Add screen buttons
	local buttonOffsetY = Constants.SCREEN.MARGIN + 14
	for _, settingsOption in ipairs({self.ExtSettingsData.AutoCountPoints, self.ExtSettingsData.SkipFailedAttempts, self.ExtSettingsData.RequireEscapeArea}) do
		local screenButton = {
			type = Constants.ButtonTypes.CHECKBOX,
			text = settingsOption.label,
			getText = function(this) return settingsOption.label end, -- for 8.0.0+
			textColor = CrozTourneyScreen.Colors.text,
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			clickableArea = { Constants.SCREEN.WIDTH + 9, buttonOffsetY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	Constants.SCREEN.WIDTH + 9, buttonOffsetY, 8, 8 },
			toggleState = true,
			toggleColor = "Positive text",
			updateSelf = function(this)
				this.toggleState = settingsOption.value
			end,
			onClick = function(this)
				this.toggleState = not this.toggleState
				settingsOption.value = not settingsOption.value
				settingsOption:save()
				Program.redraw(true)
			end
		}
		table.insert(CrozTourneyScreen.Buttons, screenButton)
		buttonOffsetY = buttonOffsetY + 12
	end

	CrozTourneyScreen.checkInput = function(xmouse, ymouse)
		Input.checkButtonsClicked(xmouse, ymouse, CrozTourneyScreen.Buttons)
	end
	CrozTourneyScreen.drawScreen = function()
		Drawing.drawBackgroundAndMargins()
		gui.defaultTextBackground(Theme.COLORS[CrozTourneyScreen.Colors.boxFill])
		local topBox = {
			x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
			y = Constants.SCREEN.MARGIN + 10,
			width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
			height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
			text = Theme.COLORS[CrozTourneyScreen.Colors.text],
			border = Theme.COLORS[CrozTourneyScreen.Colors.border],
			fill = Theme.COLORS[CrozTourneyScreen.Colors.boxFill],
			shadow = Utils.calcShadowColor(Theme.COLORS[CrozTourneyScreen.Colors.boxFill]),
		}

		local headerText = "Tourney Point Tracker"
		local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
		Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText:upper(), Theme.COLORS["Header text"], headerShadow)

		gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

		for _, button in pairs(CrozTourneyScreen.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
	end

	----------------------------
	-- ViewCurrentScoreScreen --
	----------------------------
	ViewCurrentScoreScreen.refreshButtons = function()
		for _, button in pairs(ViewCurrentScoreScreen.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
		for _, button in pairs(ViewCurrentScoreScreen.Pager.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
	end
	ViewCurrentScoreScreen.Pager = {
		Buttons = {},
		currentPage = 0,
		totalPages = 0,
		realignButtonsToGrid = function(this, x, y, colSpacer, rowSpacer)
			table.sort(this.Buttons, this.defaultSort)
			local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
			local cutoffY = Constants.SCREEN.HEIGHT - 25
			local totalPages = Utils.gridAlign(this.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
			this.currentPage = 1
			this.totalPages = totalPages or 1
			ViewCurrentScoreScreen.Buttons.CurrentPage:updateSelf()
		end,
		defaultSort = function(a, b) return a.ordinal < b.ordinal end,
		getPageText = function(this)
			if this.totalPages <= 1 then return "Page" end
			return string.format("Page %s/%s", this.currentPage, this.totalPages)
		end,
		prevPage = function(this)
			if this.totalPages <= 1 then return end
			this.currentPage = ((this.currentPage - 2 + this.totalPages) % this.totalPages) + 1
		end,
		nextPage = function(this)
			if this.totalPages <= 1 then return end
			this.currentPage = (this.currentPage % this.totalPages) + 1
		end,
	}
	ViewCurrentScoreScreen.Buttons = {
		TotalScore = {
			text = "", -- Set later via updateSelf()
			isVisible = function() return false end,
			updateSelf = function(this)
				this.text = getCurrentSeedPointTotal()
			end,
		},
		ShareScore = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Share",
			textColor = ViewCurrentScoreScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 28, 11 },
			boxColors = { ViewCurrentScoreScreen.Colors.border, ViewCurrentScoreScreen.Colors.boxFill },
			onClick = function() openSharePointsPopup(ViewCurrentScoreScreen.refreshButtons) end
		},
		CurrentPage = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = "", -- Set later via updateSelf()
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 135, 50, 10, },
			isVisible = function() return ViewCurrentScoreScreen.Pager.totalPages > 1 end,
			updateSelf = function(this)
				this.text = ViewCurrentScoreScreen.Pager:getPageText()
			end,
		},
		PrevPage = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.LEFT_ARROW,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 38, Constants.SCREEN.MARGIN + 136, 10, 10, },
			isVisible = function() return ViewCurrentScoreScreen.Pager.totalPages > 1 end,
			onClick = function(this)
				ViewCurrentScoreScreen.Pager:prevPage()
				ViewCurrentScoreScreen.Buttons.CurrentPage:updateSelf()
				Program.redraw(true)
			end
		},
		NextPage = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.RIGHT_ARROW,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 97, Constants.SCREEN.MARGIN + 136, 10, 10, },
			isVisible = function() return ViewCurrentScoreScreen.Pager.totalPages > 1 end,
			onClick = function(this)
				ViewCurrentScoreScreen.Pager:nextPage()
				ViewCurrentScoreScreen.Buttons.CurrentPage:updateSelf()
				Program.redraw(true)
			end
		},
		Back = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			onClick = function(this) Program.changeScreenView(CrozTourneyScreen) end
		},
	}
	for _, button in pairs(ViewCurrentScoreScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ViewCurrentScoreScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ViewCurrentScoreScreen.Colors.border, ViewCurrentScoreScreen.Colors.boxFill }
		end
	end
	local pointsColumnOffsetX = Constants.SCREEN.WIDTH + 80
	local claimedColumnOffsetX = Constants.SCREEN.WIDTH + 108
	ViewCurrentScoreScreen.buildOutPagedButtons = function()
		ViewCurrentScoreScreen.Pager.Buttons = {}

		for key, milestone in pairs(self.Milestones) do
			if not milestone.exclude then
				local button = {
					type = Constants.ButtonTypes.NO_BORDER,
					text = milestone.label or key,
					textColor = ViewCurrentScoreScreen.Colors.text,
					boxColors = { ViewCurrentScoreScreen.Colors.border, ViewCurrentScoreScreen.Colors.boxFill, },
					key = key,
					milestone = milestone,
					ordinal = milestone.ordinal,
					dimensions = { width = 124, height = 11, },
					isVisible = function(this) return ViewCurrentScoreScreen.Pager.currentPage == this.pageVisible end,
					updateSelf = function(this)
					end,
					draw = function(this, shadowcolor)
						local pointsText = this.milestone.points or Constants.BLANKLINE
						Drawing.drawText(pointsColumnOffsetX + 9, this.box[2], pointsText, Theme.COLORS[ViewCurrentScoreScreen.Colors.text], shadowcolor)
						if this.milestone.obtained then
							Drawing.drawImageAsPixels(Constants.PixelImages.CHECKMARK, claimedColumnOffsetX + 12, this.box[2], Theme.COLORS["Positive text"], shadowcolor)
						elseif this.milestone.type == MilestoneTypes.AllTrainers or this.milestone.type == MilestoneTypes.FullClear then
							local trainersRemaining = countRemainingTrainers(this.milestone) or Constants.BLANKLINE
							Drawing.drawText(claimedColumnOffsetX + 3, this.box[2], string.format("%s left", trainersRemaining), Theme.COLORS[this.textColor], shadowcolor)
						else
							-- Removed for now
							-- Drawing.drawText(claimedColumnOffsetX + 12, this.box[2], Constants.BLANKLINE, Theme.COLORS[this.textColor], shadowcolor)
						end
					end,
					onClick = function(this)
						this.milestone.obtained = not this.milestone.obtained
						if this.milestone.obtained then
							obtainMilestone(this.milestone)
						else
							unobtainMilestone(this.milestone)
						end
						this:updateSelf()
						CrozTourneyScreen.refreshButtons()
						Program.redraw(true)
					end,
				}
				table.insert(ViewCurrentScoreScreen.Pager.Buttons, button)
			end
		end

		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
		local y = Constants.SCREEN.MARGIN + 43
		local colSpacer = 1
		local rowSpacer = 1
		ViewCurrentScoreScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

		return true
	end
	ViewCurrentScoreScreen.checkInput = function(xmouse, ymouse)
		Input.checkButtonsClicked(xmouse, ymouse, ViewCurrentScoreScreen.Buttons)
		Input.checkButtonsClicked(xmouse, ymouse, ViewCurrentScoreScreen.Pager.Buttons)
	end
	ViewCurrentScoreScreen.drawScreen = function()
		Drawing.drawBackgroundAndMargins()
		gui.defaultTextBackground(Theme.COLORS[ViewCurrentScoreScreen.Colors.boxFill])
		local topBox = {
			x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
			y = Constants.SCREEN.MARGIN,
			width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
			height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
			text = Theme.COLORS[ViewCurrentScoreScreen.Colors.text],
			border = Theme.COLORS[ViewCurrentScoreScreen.Colors.border],
			fill = Theme.COLORS[ViewCurrentScoreScreen.Colors.boxFill],
			shadow = Utils.calcShadowColor(Theme.COLORS[ViewCurrentScoreScreen.Colors.boxFill]),
		}
		local offsetY = topBox.y + 2

		gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

		Drawing.drawText(topBox.x + 3, offsetY, "Current Seed Score:", Theme.COLORS["Intermediate text"], topBox.shadow)
		local headerPoints = ViewCurrentScoreScreen.Buttons.TotalScore.text or Constants.BLANKLINE
		Drawing.drawText(claimedColumnOffsetX + 12, offsetY, headerPoints, Theme.COLORS["Positive text"], topBox.shadow)
		offsetY = offsetY + 11
		Drawing.drawText(topBox.x + 3, offsetY, "Click below to claim or remove", topBox.text, topBox.shadow)
		offsetY = offsetY + 15

		-- Draw header labels
		Drawing.drawText(topBox.x + 3, offsetY, "Milestone", Theme.COLORS["Intermediate text"], topBox.shadow)
		Drawing.drawText(pointsColumnOffsetX, offsetY, "Points", Theme.COLORS["Intermediate text"], topBox.shadow)
		Drawing.drawText(claimedColumnOffsetX, offsetY, "Claimed", Theme.COLORS["Intermediate text"], topBox.shadow)

		-- Draw header underlines
		offsetY = offsetY + 11
		gui.drawLine(topBox.x + 4, offsetY, topBox.x + 42, offsetY, topBox.border)
		gui.drawLine(pointsColumnOffsetX + 1, offsetY, pointsColumnOffsetX + 25, offsetY, topBox.border)
		gui.drawLine(claimedColumnOffsetX + 1, offsetY, claimedColumnOffsetX + 33, offsetY, topBox.border)

		for _, button in pairs(ViewCurrentScoreScreen.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
		for _, button in pairs(ViewCurrentScoreScreen.Pager.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
	end

	--------------------------
	-- EditMilestonesScreen --
	--------------------------
	EditMilestonesScreen.refreshButtons = function()
		for _, button in pairs(EditMilestonesScreen.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
		for _, button in pairs(EditMilestonesScreen.Pager.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
	end
	EditMilestonesScreen.Pager = {
		Buttons = {},
		currentPage = 0,
		totalPages = 0,
		realignButtonsToGrid = function(this, x, y, colSpacer, rowSpacer)
			table.sort(this.Buttons, this.defaultSort)
			local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
			local cutoffY = Constants.SCREEN.HEIGHT - 25
			local totalPages = Utils.gridAlign(this.Buttons, x, y, colSpacer, rowSpacer, false, cutoffX, cutoffY)
			this.currentPage = 1
			this.totalPages = totalPages or 1
			EditMilestonesScreen.Buttons.CurrentPage:updateSelf()
		end,
		defaultSort = function(a, b) return a.ordinal < b.ordinal end,
		getPageText = function(this)
			if this.totalPages <= 1 then return "Page" end
			return string.format("Page %s/%s", this.currentPage, this.totalPages)
		end,
		prevPage = function(this)
			if this.totalPages <= 1 then return end
			this.currentPage = ((this.currentPage - 2 + this.totalPages) % this.totalPages) + 1
		end,
		nextPage = function(this)
			if this.totalPages <= 1 then return end
			this.currentPage = (this.currentPage % this.totalPages) + 1
		end,
	}
	EditMilestonesScreen.Buttons = {
		CurrentPage = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = "", -- Set later via updateSelf()
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 135, 50, 10, },
			isVisible = function() return EditMilestonesScreen.Pager.totalPages > 1 end,
			updateSelf = function(this)
				this.text = EditMilestonesScreen.Pager:getPageText()
			end,
		},
		PrevPage = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.LEFT_ARROW,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 38, Constants.SCREEN.MARGIN + 136, 10, 10, },
			isVisible = function() return EditMilestonesScreen.Pager.totalPages > 1 end,
			onClick = function(this)
				EditMilestonesScreen.Pager:prevPage()
				EditMilestonesScreen.Buttons.CurrentPage:updateSelf()
				Program.redraw(true)
			end
		},
		NextPage = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.RIGHT_ARROW,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 97, Constants.SCREEN.MARGIN + 136, 10, 10, },
			isVisible = function() return EditMilestonesScreen.Pager.totalPages > 1 end,
			onClick = function(this)
				EditMilestonesScreen.Pager:nextPage()
				EditMilestonesScreen.Buttons.CurrentPage:updateSelf()
				Program.redraw(true)
			end
		},
		Load = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Load",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 24, 11 },
			onClick = function(this) promptLoadMilestoneList() end
		},
		Back = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			onClick = function(this)
				updateSettings()
				saveSettingsData()
				Program.changeScreenView(CrozTourneyScreen)
			end
		},
	}
	for _, button in pairs(EditMilestonesScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = EditMilestonesScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill }
		end
	end
	EditMilestonesScreen.buildOutPagedButtons = function()
		EditMilestonesScreen.Pager.Buttons = {}

		for key, milestone in pairs(self.Milestones) do
			local ordinalIndex = milestone.ordinal * 100
			local milestoneBoxBtn = {
				type = Constants.ButtonTypes.CHECKBOX,
				boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill, },
				key = key,
				milestone = milestone,
				ordinal = ordinalIndex,
				dimensions = { width = 8, height = 8, },
				toggleState = not milestone.exclude,
				toggleColor = "Positive text",
				isVisible = function(this) return EditMilestonesScreen.Pager.currentPage == this.pageVisible end,
				updateSelf = function(this)
					this.toggleState = not milestone.exclude
				end,
				onClick = function(this)
					milestone.exclude = not milestone.exclude
					-- If the milestone is already obtained, add/remove points
					if milestone.obtained then
						local changeToPoints = milestone.points or 0
						if milestone.exclude then
							changeToPoints = -1 * changeToPoints
						end
						if changeToPoints ~= 0 then
							self.ExtSettingsData.TotalPoints:addPoints(changeToPoints)
							updateSettings()
							saveLaterFrames = 150
						end
					end
					this:updateSelf()
					CrozTourneyScreen.refreshButtons()
					Program.redraw(true)
				end,
			}
			local milestoneTextBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				textColor = EditMilestonesScreen.Colors.text,
				boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill, },
				ordinal = ordinalIndex + 1,
				dimensions = { width = 80, height = 11, },
				isVisible = function(this) return EditMilestonesScreen.Pager.currentPage == this.pageVisible end,
				draw = function(this, shadowcolor)
					local milestoneText = milestone.label or key
					Drawing.drawText(this.box[1] + 1, this.box[2] - 2, milestoneText, Theme.COLORS[this.textColor], shadowcolor)
				end,
				onClick = function(this)
					milestoneBoxBtn:onClick()
				end,
			}
			local pointsBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				textColor = EditMilestonesScreen.Colors.text,
				boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill, },
				ordinal = ordinalIndex + 2,
				dimensions = { width = 20, height = 11, },
				isVisible = function(this) return EditMilestonesScreen.Pager.currentPage == this.pageVisible end,
				draw = function(this, shadowcolor)
					if milestone.exclude then
						return
					end

					local points = milestone.points or 0
					local pointsText = tostring(points)

					local xOffset = 1
					if points < 0 then
						xOffset = xOffset - 2 -- 2 pixels for the negative sign
					end
					if math.abs(points) < 10 then
						xOffset = xOffset + 5 -- 5 pixels for centering
					elseif math.abs(points) < 100 then
						xOffset = xOffset + 2 -- 2 pixels for centering
					end

					Drawing.drawText(this.box[1] + xOffset, this.box[2] - 2, pointsText, Theme.COLORS[this.textColor], shadowcolor)
				end,
				onClick = function(this)
					if not milestone.exclude then
						promptMilestoneSetPoint(milestone)
					end
				end,
			}
			local spacer = {
				ordinal = ordinalIndex + 3,
				dimensions = { width = 2, height = 11, },
			}
			local plusBtn = {
				type = Constants.ButtonTypes.FULL_BORDER,
				textColor = "Positive text",
				boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill, },
				ordinal = ordinalIndex + 4,
				dimensions = { width = 8, height = 8 },
				isVisible = function(this) return not milestone.exclude and EditMilestonesScreen.Pager.currentPage == this.pageVisible end,
				draw = function(this, shadowcolor)
					Drawing.drawText(this.box[1], this.box[2] - 1, "+", Theme.COLORS[this.textColor], shadowcolor)
				end,
				onClick = function(this)
					milestone.points = verifyPointMax(milestone.points + 1)
					-- Adjust total points accordingly if the milestone has already been obtained
					if milestone.obtained then
						self.ExtSettingsData.TotalPoints:addPoints(1)
						CrozTourneyScreen.refreshButtons()
					end
					Program.redraw(true)
				end,
			}
			local minusBtn = {
				type = Constants.ButtonTypes.FULL_BORDER,
				textColor = "Negative text",
				boxColors = { EditMilestonesScreen.Colors.border, EditMilestonesScreen.Colors.boxFill, },
				ordinal = ordinalIndex + 5,
				dimensions = { width = 8, height = 8, extraX = -1, },
				isVisible = function(this) return not milestone.exclude and EditMilestonesScreen.Pager.currentPage == this.pageVisible end,
				draw = function(this, shadowcolor)
					local x, y = this.box[1] + 3, this.box[2] + 4
					if Theme.DRAW_TEXT_SHADOWS then
						gui.drawLine(x + 1, y + 1, x + 3, y + 1, shadowcolor)
					end
					gui.drawLine(x, y, x + 2, y, Theme.COLORS[this.textColor])
				end,
				onClick = function(this)
					milestone.points = verifyPointMax(milestone.points - 1)
					-- Adjust total points accordingly if the milestone has already been obtained
					if milestone.obtained then
						self.ExtSettingsData.TotalPoints:addPoints(-1)
						CrozTourneyScreen.refreshButtons()
					end
					Program.redraw(true)
				end,
			}

			-- Order here doesn't matter, it's determined above by "button.ordinal"
			table.insert(EditMilestonesScreen.Pager.Buttons, milestoneBoxBtn)
			table.insert(EditMilestonesScreen.Pager.Buttons, milestoneTextBtn)
			table.insert(EditMilestonesScreen.Pager.Buttons, pointsBtn)
			table.insert(EditMilestonesScreen.Pager.Buttons, spacer)
			table.insert(EditMilestonesScreen.Pager.Buttons, minusBtn)
			table.insert(EditMilestonesScreen.Pager.Buttons, plusBtn)
		end

		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
		local y = Constants.SCREEN.MARGIN + 20
		local colSpacer = 1
		local rowSpacer = 3
		EditMilestonesScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

		return true
	end
	EditMilestonesScreen.checkInput = function(xmouse, ymouse)
		Input.checkButtonsClicked(xmouse, ymouse, EditMilestonesScreen.Buttons)
		Input.checkButtonsClicked(xmouse, ymouse, EditMilestonesScreen.Pager.Buttons)
	end
	EditMilestonesScreen.drawScreen = function()
		Drawing.drawBackgroundAndMargins()
		gui.defaultTextBackground(Theme.COLORS[EditMilestonesScreen.Colors.boxFill])
		local topBox = {
			x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
			y = Constants.SCREEN.MARGIN,
			width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
			height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
			text = Theme.COLORS[EditMilestonesScreen.Colors.text],
			border = Theme.COLORS[EditMilestonesScreen.Colors.border],
			fill = Theme.COLORS[EditMilestonesScreen.Colors.boxFill],
			shadow = Utils.calcShadowColor(Theme.COLORS[EditMilestonesScreen.Colors.boxFill]),
		}
		local offsetY = topBox.y + 2

		gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

		-- Draw header labels
		local pointsColX = topBox.x + 96
		Drawing.drawText(topBox.x + 3, offsetY, "Active Milestone", Theme.COLORS["Intermediate text"], topBox.shadow)
		Drawing.drawText(pointsColX, offsetY, "Points", Theme.COLORS["Intermediate text"], topBox.shadow)

		-- Draw header underlines
		offsetY = offsetY + 11
		gui.drawLine(topBox.x + 4, offsetY, topBox.x + 92, offsetY, topBox.border)
		gui.drawLine(pointsColX + 1, offsetY, pointsColX + 38, offsetY, topBox.border)

		for _, button in pairs(EditMilestonesScreen.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
		for _, button in pairs(EditMilestonesScreen.Pager.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
	end

	local createButtonInserts = function ()
		TrackerScreen.Buttons.PointTotalBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- text = "",
			-- getText = function() return "" end,
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + 76, 67, 22, 11 },
			isVisible = function() return shouldShowPoints() end,
			draw = function(this, shadowcolor)
				local headerText = "Points:"
				Drawing.drawText(this.box[1] - 10, this.box[2] - 10, headerText, Theme.COLORS[this.textColor], shadowcolor)

				local pointNumber = tostring(self.ExtSettingsData.TotalPoints.value or 0)
				local pointNumberColor = Utils.inlineIf(highlightFrames > 0, "Positive text", "Default text")
				Drawing.drawText(this.box[1], this.box[2], pointNumber, Theme.COLORS[pointNumberColor], shadowcolor)
			end,
			onClick = function()
				previousScreen = TrackerScreen
				CrozTourneyScreen.refreshButtons()
				Program.changeScreenView(CrozTourneyScreen)
			end,
		}
		TrackerScreen.Buttons.PointIncrementBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- text = "",
			-- getText = function() return "" end,
			textColor = "Positive text",
			box = { Constants.SCREEN.WIDTH + 70, 67, 8, 4 },
			isVisible = function() return shouldShowPoints() end,
			draw = function(this, shadowcolor)
				local text = "+"
				if Theme.DRAW_TEXT_SHADOWS then
					Drawing.drawText(this.box[1] + 1, this.box[2] + 1, text, shadowcolor, nil, 5, Constants.Font.FAMILY)
				end
				Drawing.drawText(this.box[1], this.box[2], text, Theme.COLORS[this.textColor], nil, 5, Constants.Font.FAMILY)
			end,
			onClick = function()
				self.ExtSettingsData.TotalPoints:addPoints(1)
				saveLaterFrames = 150
				Program.redraw(true)
			end,
		}
		TrackerScreen.Buttons.PointDecrementBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- text = "",
			-- getText = function() return "" end,
			textColor = "Negative text",
			box = { Constants.SCREEN.WIDTH + 70, 73, 7, 4 },
			isVisible = function() return shouldShowPoints() end,
			draw = function(this, shadowcolor)
				local text = Constants.BLANKLINE
				if Theme.DRAW_TEXT_SHADOWS then
					Drawing.drawText(this.box[1] + 1, this.box[2] + 1, text, shadowcolor, nil, 5, Constants.Font.FAMILY)
				end
				Drawing.drawText(this.box[1], this.box[2], text, Theme.COLORS[this.textColor], nil, 5, Constants.Font.FAMILY)
			end,
			onClick = function()
				self.ExtSettingsData.TotalPoints:addPoints(-1)
				saveLaterFrames = 150
				Program.redraw(true)
			end,
		}
		GameOverScreen.Buttons.ShareScore = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- text = "",
			-- getText = function() return "" end,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 23, 75, 11 },
			boxColors = { "Intermediate text", "Upper box background", },
			isVisible = function() return shouldSeedBeCounted() end,
			draw = function(this, shadowcolor)
				shadowcolor = Utils.calcShadowColor(Theme.COLORS[this.boxColors[2]])
				local text = string.format("Seed Points:  %s", getCurrentSeedPointTotal() or 0)
				Drawing.drawText(this.box[1], this.box[2], text, Theme.COLORS["Default text"], shadowcolor)

				local shareText = "(Share)"
				local offsetX = Utils.calcWordPixelLength(text) + 6
				-- Drawing.drawImageAsPixels(Constants.PixelImages.MAGNIFYING_GLASS, this.box[1] + offsetX, this.box[2] + 1, Theme.COLORS["Intermediate text"], shadowcolor)
				Drawing.drawText(this.box[1] + offsetX, this.box[2], shareText, Theme.COLORS["Intermediate text"], shadowcolor)
			end,
			onClick = function() openSharePointsPopup() end,
		}
	end
	local removeButtonInserts = function()
		TrackerScreen.Buttons.PointTotalBtn = nil
		TrackerScreen.Buttons.PointIncrementBtn = nil
		TrackerScreen.Buttons.PointDecrementBtn = nil
		GameOverScreen.Buttons.ShareScore = nil
	end

	-- EXTENSION FUNCTIONS
	function self.configureOptions()
		previousScreen = SingleExtensionScreen
		CrozTourneyScreen.refreshButtons()
		Program.changeScreenView(CrozTourneyScreen)
	end

	local originalSurvivalSetting
	function self.startup()
		if not isSupported() then return end
		originalSurvivalSetting = Options["Track PC Heals"]
		Options["Track PC Heals"] = false

		-- Temp fix until it gets fixed in main Tracker code
		-- if Constants.CharWidths["1"] == 3 then
		-- 	Constants.CharWidths["1"] = 4
		-- end

		createButtonInserts()
		resetMilestones()
		loadSettingsData()

		-- If the current game is a new game, clear out the milestones
		if Tracker.DataMessage:find(Tracker.LoadStatusMessages.fromFile) == nil then
			-- TODO: Doesn't cover a case where the extension gets updated in the middle of a run that was started on the same day.
			resetMilestones()
		end

		CrozTourneyScreen.refreshButtons()
		ViewCurrentScoreScreen.refreshButtons()
	end

	function self.unload()
		if not isSupported() then return end
		if originalSurvivalSetting ~= nil then
			Options["Track PC Heals"] = (originalSurvivalSetting == true)
		end

		removeButtonInserts()
		saveSettingsData()
	end

	function self.afterProgramDataUpdate()
		if not isSupported() then return end
		if Options["Track PC Heals"] then
			originalSurvivalSetting = Options["Track PC Heals"]
			Options["Track PC Heals"] = false
		end

		if self.ExtSettingsData.AutoCountPoints.value then
			checkAllMilestones()

			if highlightFrames > 0 then
				highlightFrames = highlightFrames - 30
			end
			if saveLaterFrames > 0 then
				saveLaterFrames = saveLaterFrames - 30
				if saveLaterFrames <= 0 then
					saveSettingsData()
				end
			end
		end
	end

	function self.afterBattleEnds()
		if not isSupported() or not self.ExtSettingsData.AutoCountPoints.value then return end

		local wonTheBattle = (Memory.readbyte(GameSettings.gBattleOutcome) == 1)
		if not wonTheBattle then
			return
		end

		-- https://github.com/pret/pokefirered/blob/03c0ed935f87e088093b14f2f39c2304f921815d/src/data/trainers.h
		-- https://kelseyyoung.github.io/FRLGIronmonMap/
		local trainerId = Memory.readword(GameSettings.gTrainerBattleOpponent_A)

		local milestoneList = TrainerMilestoneMap[trainerId] or {}
		-- If an individual milestone, put it into a list instead
		if milestoneList.type then
			milestoneList = { milestoneList }
		end

		local isMilestoneTrainerDefeated = false
		for _, milestone in pairs(milestoneList) do
			if not milestone.obtained and milestone.trainers then
				-- Mark this trainer as defeated
				milestone.trainers[trainerId] = true
				checkMilestoneForPoints(milestone)
				isMilestoneTrainerDefeated = true
			end
		end

		if isMilestoneTrainerDefeated then
			updateSettings()
			saveLaterFrames = 150
		end
	end

	-- [Bizhawk only] Executed each frame (60 frames per second)
	-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
	function self.inputCheckBizhawk()
		if Main.loadNextSeed and not shouldSeedBeCounted() then
			Main.currentSeed = Main.currentSeed - 1
		end
	end

	-- Executed once every 30 frames or after any redraw event is scheduled (i.e. most button presses)
	function self.afterRedraw()
		if not isSupported() or not Main.IsOnBizhawk() then return end

		local buttonsToDraw = {
			TrackerScreen.Buttons.PointTotalBtn,
			TrackerScreen.Buttons.PointIncrementBtn,
			TrackerScreen.Buttons.PointDecrementBtn,
		}
		for _, button in ipairs(buttonsToDraw) do
			if button and button:isVisible() then
				local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
				Drawing.drawButton(button, shadowcolor)
			end
		end
	end

	return self
end
return CrozwordsTourneyExtension