local function CrozwordsTourneyExtension()
	local self = {}

	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	self.name = "Crozwords Tourney Tracker"
	self.author = "UTDZac"
	self.description = "This extension adds extra functionality to the Tracker for the FRLG tournament, such as counting milestone points."
	self.version = "0.8"
	self.url = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension"

	function self.checkForUpdates()
		local versionCheckUrl = "https://api.github.com/repos/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"

		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, nil)
		return isUpdateAvailable, downloadUrl
	end

	local Zones = {
		MtMoon = { [114] = true, [115] = true, [116] = true },
		SSAnne = { [120] = true, [121] = true, [122] = true, [123] = true, [177] = true, [178] = true },
		RockTunnel = { [154] = true, [155] = true },
		RocketHideout = { [27] = true, [128] = true, [129] = true, [130] = true, [131] = true, [224] = true, [225] = true },
		PokemonTower = { [161] = true, [162] = true, [163] = true, [164] = true, [165] = true, [166] = true, [167] = true },
		SilphCo = { [132] = true, [133] = true, [134] = true, [135] = true, [136] = true, [137] = true, [138] = true, [139] = true, [140] = true, [141] = true, [142] = true, [229] = true },
		CinnabarMansion = { [143] = true, [144] = true, [145] = true, [146] = true },
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
		-- "Escape" successful if there is no associated zone, or the player isn't there anymore
		return not zone or not zone[TrackerAPI.getMapId()]
	end

	local MilestoneTypes = {
		SingleTrainer = "Defeat a single trainer",
		AllTrainers = "Defeat all trainers",
		EscapeZone = "Escape an area",
		FullClear = "Full clear an area",
	}
	local Milestones = {
		ForestTrainer1 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 1, },
		ForestTrainer2 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 2, },
		ForestTrainer3 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 3, },
		ForestTrainer4 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 4, },
		ForestTrainer5 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 5, },
		Rival2 = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 6, },
		Brock = 			{ type = MilestoneTypes.SingleTrainer, 	points = 3, ordinal = 7, },
		MtMoonFC = 			{ type = MilestoneTypes.FullClear, 		points = 1, ordinal = 8, zone = Zones.MtMoon, },
		SSAnneFC = 			{ type = MilestoneTypes.FullClear, 		points = 1, ordinal = 9, zone = Zones.SSAnne, },
		MistySurge = 		{ type = MilestoneTypes.AllTrainers, 	points = 1, ordinal = 10, },
		RockTunnelFC = 		{ type = MilestoneTypes.FullClear, 		points = 1, ordinal = 11, zone = Zones.RockTunnel, },
		RocketHideout = 	{ type = MilestoneTypes.EscapeZone, 	points = 1, ordinal = 12, zone = Zones.RocketHideout, },
		PokemonTowerFC = 	{ type = MilestoneTypes.FullClear, 		points = 1, ordinal = 13, zone = Zones.PokemonTower, },
		Erika = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 14, },
		Koga = 				{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 15, },
		SilphEscape = 		{ type = MilestoneTypes.EscapeZone, 	points = 1, ordinal = 16, zone = Zones.SilphCo, },
		SilphFC = 			{ type = MilestoneTypes.FullClear, 		points = 3, ordinal = 17, zone = Zones.SilphCo, },
		CinnabarFC = 		{ type = MilestoneTypes.FullClear, 		points = 1, ordinal = 18, zone = Zones.CinnabarMansion, },
		Sabrina = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 19, },
		Blaine = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 20, },
		GiovanniGym = 		{ type = MilestoneTypes.SingleTrainer, 	points = 2, ordinal = 21, },
		RivalVR = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 22, },
		Lorelei = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, ordinal = 23, },
		Bruno = 			{ type = MilestoneTypes.SingleTrainer, 	points = 2, ordinal = 24, },
		Agatha = 			{ type = MilestoneTypes.SingleTrainer, 	points = 2, ordinal = 25, },
		Lance = 			{ type = MilestoneTypes.SingleTrainer, 	points = 3, ordinal = 26, },
		Champion = 			{ type = MilestoneTypes.SingleTrainer, 	points = 5, ordinal = 27, },
	}
	local TrainerMilestoneMap = {
		[102] = Milestones.ForestTrainer1,
		[103] = Milestones.ForestTrainer2,
		[104] = Milestones.ForestTrainer3,
		[531] = Milestones.ForestTrainer4,
		[532] = Milestones.ForestTrainer5,
		[329] = Milestones.Rival2,
		[330] = Milestones.Rival2,
		[331] = Milestones.Rival2,
		[414] = Milestones.Brock,

		-- ALL MT MOON - 12 total
		[108] = Milestones.MtMoonFC,
		[109] = Milestones.MtMoonFC,
		[121] = Milestones.MtMoonFC,
		[169] = Milestones.MtMoonFC,
		[120] = Milestones.MtMoonFC,
		[91] = Milestones.MtMoonFC,
		[181] = Milestones.MtMoonFC,
		[170] = Milestones.MtMoonFC,
		[351] = Milestones.MtMoonFC,
		[352] = Milestones.MtMoonFC,
		[353] = Milestones.MtMoonFC,
		[354] = Milestones.MtMoonFC,

		-- ALL SS ANNE - 16 total (exclude rival, he's implied)
		[96] = Milestones.SSAnneFC,
		[126] = Milestones.SSAnneFC,
		[422] = Milestones.SSAnneFC,
		[421] = Milestones.SSAnneFC,
		[140] = Milestones.SSAnneFC,
		[224] = Milestones.SSAnneFC,
		[138] = Milestones.SSAnneFC,
		[139] = Milestones.SSAnneFC,
		[136] = Milestones.SSAnneFC,
		[137] = Milestones.SSAnneFC,
		[482] = Milestones.SSAnneFC,
		[223] = Milestones.SSAnneFC,
		[483] = Milestones.SSAnneFC,
		[127] = Milestones.SSAnneFC,
		[134] = Milestones.SSAnneFC,
		[135] = Milestones.SSAnneFC,

		[415] = Milestones.MistySurge,
		[416] = Milestones.MistySurge,

		-- ALL ROCK TUNNEL - 15 total
		[189] = Milestones.RockTunnelFC,
		[190] = Milestones.RockTunnelFC,
		[191] = Milestones.RockTunnelFC,
		[192] = Milestones.RockTunnelFC,
		[193] = Milestones.RockTunnelFC,
		[194] = Milestones.RockTunnelFC,
		[166] = Milestones.RockTunnelFC,
		[165] = Milestones.RockTunnelFC,
		[159] = Milestones.RockTunnelFC,
		[156] = Milestones.RockTunnelFC,
		[164] = Milestones.RockTunnelFC,
		[168] = Milestones.RockTunnelFC,
		[476] = Milestones.RockTunnelFC,
		[475] = Milestones.RockTunnelFC,
		[474] = Milestones.RockTunnelFC,

		[348] = Milestones.RocketHideout, -- Giovanni

		-- ALL POKEMON TOWER - 13 total (exclude rival and top grunts, they're implied)
		[441] = Milestones.PokemonTowerFC,
		[442] = Milestones.PokemonTowerFC,
		[443] = Milestones.PokemonTowerFC,
		[444] = Milestones.PokemonTowerFC,
		[445] = Milestones.PokemonTowerFC,
		[446] = Milestones.PokemonTowerFC,
		[447] = Milestones.PokemonTowerFC,
		[448] = Milestones.PokemonTowerFC,
		[449] = Milestones.PokemonTowerFC,
		[450] = Milestones.PokemonTowerFC,
		[451] = Milestones.PokemonTowerFC,
		[452] = Milestones.PokemonTowerFC,
		[453] = Milestones.PokemonTowerFC,
		[369] = Milestones.PokemonTowerFC,
		[370] = Milestones.PokemonTowerFC,
		[371] = Milestones.PokemonTowerFC,

		-- [372] = Milestones.????, -- no idea where this trainer is located

		[417] = Milestones.Erika,
		[418] = Milestones.Koga,

		[349] = Milestones.SilphEscape, -- Giovanni

		-- ALL SILPH CO - total 30 (exclude rival, he's implied)
		[336] = Milestones.SilphFC,
		[337] = Milestones.SilphFC,
		[338] = Milestones.SilphFC,
		[339] = Milestones.SilphFC,
		[340] = Milestones.SilphFC,
		[341] = Milestones.SilphFC,
		[342] = Milestones.SilphFC,
		[343] = Milestones.SilphFC,
		[344] = Milestones.SilphFC,
		[345] = Milestones.SilphFC,
		[373] = Milestones.SilphFC,
		[374] = Milestones.SilphFC,
		[375] = Milestones.SilphFC,
		[376] = Milestones.SilphFC,
		[377] = Milestones.SilphFC,
		[378] = Milestones.SilphFC,
		[379] = Milestones.SilphFC,
		[380] = Milestones.SilphFC,
		[381] = Milestones.SilphFC,
		[382] = Milestones.SilphFC,
		[383] = Milestones.SilphFC,
		[384] = Milestones.SilphFC,
		[385] = Milestones.SilphFC,
		[386] = Milestones.SilphFC,
		[387] = Milestones.SilphFC,
		[388] = Milestones.SilphFC,
		[389] = Milestones.SilphFC,
		[390] = Milestones.SilphFC,
		[391] = Milestones.SilphFC,
		[286] = Milestones.SilphFC,

		-- ALL CINNABAR MANSION - 6 total
		[216] = Milestones.CinnabarFC,
		[218] = Milestones.CinnabarFC,
		[219] = Milestones.CinnabarFC,
		[534] = Milestones.CinnabarFC,
		[335] = Milestones.CinnabarFC,
		[346] = Milestones.CinnabarFC,
		[347] = Milestones.CinnabarFC,

		[420] = Milestones.Sabrina,
		[419] = Milestones.Blaine,
		[350] = Milestones.GiovanniGym,

		[435] = Milestones.RivalVR,
		[436] = Milestones.RivalVR,
		[437] = Milestones.RivalVR,

		[410] = Milestones.Lorelei,
		[411] = Milestones.Bruno,
		[412] = Milestones.Agatha,
		[413] = Milestones.Lance,
		[438] = Milestones.Champion,
		[439] = Milestones.Champion,
		[440] = Milestones.Champion,
	}

	local saveLaterFrames = 0 -- These frames count down and will save the extension settings when it reaches 0
	local highlightFrames = 0 -- These frames count down and make the point count shown "highlighted"
	local ExtLabel = "CrozwordsTourney" -- to be prepended to all other settings here
	local ExtSettingsData = {
		AutoCountPoints = {
			value = true, -- default
			label = "Auto count points as you play",
		},
		RequireEscapeArea = {
			value = false, -- default
			label = "Must exit dungeons for points",
		},
		SkipFailedAttempts = {
			value = false, -- default
			label = "Only count runs out of the lab",
		},
		TotalPoints = {
			value = 0, -- default
			label = "Total points for all seeds:",
			addPoints = function(this, val) if this.value then this.value = this.value + (val or 0) end end,
		},
		CurrentMilestones = {
			value = "",
			parseMilestones = function(this)
				this.value = this.value or ""
				for key in (this.value .. ","):gmatch("([^,]*),") do
					if Milestones[key] then
						Milestones[key].obtained = true
					end
				end
			end,
		},
	}
	for key, setting in pairs(ExtSettingsData) do
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

	-- Helper Functions
	local isSupported = function() return GameSettings.game == 3 end

	local shouldShowPoints = function()
		return Program.currentScreen == TrackerScreen and Tracker.Data.isViewingOwn and not TrackerScreen.canShowBallPicker()
	end

	local resetMilestones = function()
		-- ExtSettingsData.TotalPoints.value = 0 -- don't reset points, these need to accumulate across multiple seeds
		ExtSettingsData.CurrentMilestones.value = ""

		-- Unobtain all milestones
		for _, milestone in pairs(Milestones) do
			milestone.obtained = false
		end

		-- Add the trainer list to each milestone
		for trainerId, milestone in pairs(TrainerMilestoneMap) do
			if milestone.trainers == nil then
				milestone.trainers = {}
			end
			milestone.trainers[trainerId] = false
		end
	end

	local exportMilestones = function()
		local obtainedMilestones = {}
		local totalPoints = 0
		local forestTrainers = 0
		for key, milestone in pairs(Milestones) do
			if milestone.obtained then
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
		for _, milestone in pairs(Milestones) do
			if milestone.obtained then
				totalPoints = totalPoints + (milestone.points or 0)
			end
		end
		return totalPoints
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
			if defeatAll(milestone.trainers) and (not ExtSettingsData.RequireEscapeArea.value or escapedZone(milestone.zone)) then
				milestone.obtained = true
			end
		elseif type(milestone.customCondition) == "function" and milestone:customCondition() then
			milestone.obtained = true
		end

		-- If newly obtained milestone, add points
		if milestone.obtained then
			ExtSettingsData.TotalPoints:addPoints(milestone.points)
			CrozTourneyScreen.refreshButtons()
			ViewCurrentScoreScreen.refreshButtons()
			highlightFrames = 270
			saveLaterFrames = 150
		end
	end

	local checkAllMilestones = function()
		local exportTable = {}
		for key, milestone in pairs(Milestones) do
			checkMilestoneForPoints(milestone)
			if milestone.obtained then
				table.insert(exportTable, key)
			end
		end

		if #exportTable > 0 then
			ExtSettingsData.CurrentMilestones.value = table.concat(exportTable, ",")
		end
	end

	local function loadSettingsData()
		for _, optionObj in pairs(ExtSettingsData) do
			if type(optionObj.load) == "function" then
				optionObj:load()
			end
		end
		ExtSettingsData.CurrentMilestones:parseMilestones()
	end

	local function saveSettingsData()
		for _, optionObj in pairs(ExtSettingsData) do
			if type(optionObj.save) == "function" then
				optionObj:save()
			end
		end
	end

	local function applyOptionsCallback(pointValue, callback)
		local settingsWereChange = false

		if ExtSettingsData.TotalPoints.value ~= pointValue then
			ExtSettingsData.TotalPoints.value = pointValue
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

		forms.label(form, ExtSettingsData.TotalPoints.label, 54, 20, 140, 20)

		local textboxPoints = forms.textbox(form, ExtSettingsData.TotalPoints.value or 0, 45, 20, "UNSIGNED", 200, 18)

		local saveButton = forms.button(form, "Save", function()
			local pointsAsNumber = tonumber(forms.gettext(textboxPoints) or "") or ExtSettingsData.TotalPoints.value
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
			ExtSettingsData.TotalPoints.value = 0
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

	CrozTourneyScreen.refreshButtons = function()
		for _, button in pairs(CrozTourneyScreen.Buttons) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
	end
	CrozTourneyScreen.Buttons = {
		TotalScore = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = "",
			textColor = "Intermediate text",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 101, Constants.SCREEN.MARGIN + 14, 35, 11 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			updateSelf = function(this)
				this.text = tostring(ExtSettingsData.TotalPoints.value or 0)
			end,
			draw = function(this, shadowcolor)
				Drawing.drawText(Constants.SCREEN.WIDTH + 8, this.box[2], ExtSettingsData.TotalPoints.label, Theme.COLORS[CrozTourneyScreen.Colors.text], shadowcolor)
				local iconOffsetX = this.box[1] + 25 -- Utils.calcWordPixelLength(this.text) + 5
				Drawing.drawImageAsPixels(Constants.PixelImages.NOTEPAD, iconOffsetX, this.box[2], Theme.COLORS[CrozTourneyScreen.Colors.text], shadowcolor)
			end,
			onClick = function() openEditPointsPopup(CrozTourneyScreen.refreshButtons) end
		},
		ViewCurrentScore = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = Constants.PixelImages.MAGNIFYING_GLASS,
			text = "Points for Current Seed",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 88, 120, 16 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function()
				ViewCurrentScoreScreen.buildOutPagedButtons()
				ViewCurrentScoreScreen.refreshButtons()
				Program.changeScreenView(ViewCurrentScoreScreen)
			end
		},
		ShareScore = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Share Score",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 52, 11 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function() openSharePointsPopup(CrozTourneyScreen.refreshButtons) end
		},
		Back = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			textColor = CrozTourneyScreen.Colors.text,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			boxColors = { CrozTourneyScreen.Colors.border, CrozTourneyScreen.Colors.boxFill },
			onClick = function() Program.changeScreenView(SingleExtensionScreen) end
		},
	}
	-- Add screen buttons
	local buttonOffsetY = Constants.SCREEN.MARGIN + 32
	for _, settingsOption in ipairs({ExtSettingsData.AutoCountPoints, ExtSettingsData.RequireEscapeArea, ExtSettingsData.SkipFailedAttempts}) do
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

		local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
		Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, ("Tourney Extension Settings"):upper(), Theme.COLORS["Header text"], headerShadow)

		gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

		for _, button in pairs(CrozTourneyScreen.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
	end

	ViewCurrentScoreScreen.refreshButtons = function()
		for _, button in pairs(ViewCurrentScoreScreen.Buttons) do
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
			local cutoffY = Constants.SCREEN.HEIGHT - 20
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
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, Constants.SCREEN.MARGIN + 135, 50, 10, },
			isVisible = function() return ViewCurrentScoreScreen.Pager.totalPages > 1 end,
			updateSelf = function(this)
				this.text = ViewCurrentScoreScreen.Pager:getPageText()
			end,
		},
		PrevPage = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.LEFT_ARROW,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 39, Constants.SCREEN.MARGIN + 136, 10, 10, },
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
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, Constants.SCREEN.MARGIN + 136, 10, 10, },
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

		for key, milestone in pairs(Milestones) do
			local button = {
				type = Constants.ButtonTypes.NO_BORDER,
				text = key,
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
						Drawing.drawText(claimedColumnOffsetX + 12, this.box[2], pointsText, Theme.COLORS["Positive text"], shadowcolor)
					else
						Drawing.drawText(claimedColumnOffsetX + 12, this.box[2], Constants.BLANKLINE, Theme.COLORS[this.textColor], shadowcolor)
					end
				end,
				onClick = function(this)
					this:updateSelf()
					Program.redraw(true)
				end,
			}
			table.insert(ViewCurrentScoreScreen.Pager.Buttons, button)
		end

		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
		local y = Constants.SCREEN.MARGIN + 25
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
			y = Constants.SCREEN.MARGIN + 10,
			width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
			height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
			text = Theme.COLORS[ViewCurrentScoreScreen.Colors.text],
			border = Theme.COLORS[ViewCurrentScoreScreen.Colors.border],
			fill = Theme.COLORS[ViewCurrentScoreScreen.Colors.boxFill],
			shadow = Utils.calcShadowColor(Theme.COLORS[ViewCurrentScoreScreen.Colors.boxFill]),
		}

		local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
		Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, "Current Seed Score:", Theme.COLORS["Header text"], headerShadow)
		local headerPoints = ViewCurrentScoreScreen.Buttons.TotalScore.text or Constants.BLANKLINE
		Drawing.drawText(claimedColumnOffsetX + 12, Constants.SCREEN.MARGIN - 2, headerPoints, Theme.COLORS[Theme.headerHighlightKey], headerShadow)

		gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

		-- Draw header labels
		local offsetY = topBox.y + 2
		Drawing.drawText(topBox.x + 3, offsetY, "Milestone", Theme.COLORS["Intermediate text"], topBox.shadow)
		Drawing.drawText(pointsColumnOffsetX, offsetY, "Points", Theme.COLORS["Intermediate text"], topBox.shadow)
		Drawing.drawText(claimedColumnOffsetX, offsetY, "Claimed", Theme.COLORS["Intermediate text"], topBox.shadow)

		-- Draw header underlines
		offsetY = offsetY + 10
		gui.drawLine(topBox.x + 4, offsetY, topBox.x + 42, offsetY, Theme.COLORS[topBox.text])
		gui.drawLine(pointsColumnOffsetX + 1, offsetY, pointsColumnOffsetX + 25, offsetY, Theme.COLORS[topBox.text])
		gui.drawLine(claimedColumnOffsetX + 1, offsetY, claimedColumnOffsetX + 33, offsetY, Theme.COLORS[topBox.text])

		for _, button in pairs(ViewCurrentScoreScreen.Buttons) do
			Drawing.drawButton(button, topBox.shadow)
		end
		for _, button in pairs(ViewCurrentScoreScreen.Pager.Buttons) do
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

				local pointNumber = tostring(ExtSettingsData.TotalPoints.value or 0)
				local pointNumberColor = Utils.inlineIf(highlightFrames > 0, "Intermediate text", "Default text")
				Drawing.drawText(this.box[1], this.box[2], pointNumber, Theme.COLORS[pointNumberColor], shadowcolor)
			end,
			onClick = function() openEditPointsPopup() end,
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
				ExtSettingsData.TotalPoints:addPoints(1)
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
				ExtSettingsData.TotalPoints:addPoints(-1)
				saveLaterFrames = 150
				Program.redraw(true)
			end,
		}
		GameOverScreen.Buttons.ShareScore = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- text = "",
			-- getText = function() return "" end,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 23, 75, 11 },
			boxColors = { "Intermediate text", "Lower box background", },
			draw = function(this, shadowcolor)
				local text = string.format("Points:  %s", ExtSettingsData.TotalPoints.value or 0)
				Drawing.drawText(this.box[1], this.box[2], text, Theme.COLORS["Lower box text"], shadowcolor)

				local shareText = "(Share)"
				local offsetX = Utils.calcWordPixelLength(text) + 10
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

		if ExtSettingsData.AutoCountPoints.value then
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
		if not isSupported() or not ExtSettingsData.AutoCountPoints.value then return end

		local wonTheBattle = (Memory.readbyte(GameSettings.gBattleOutcome) == 1)
		if not wonTheBattle then
			return
		end

		-- https://github.com/pret/pokefirered/blob/03c0ed935f87e088093b14f2f39c2304f921815d/src/data/trainers.h
		-- https://kelseyyoung.github.io/FRLGIronmonMap/
		local trainerId = Memory.readword(GameSettings.gTrainerBattleOpponent_A)

		local milestone = TrainerMilestoneMap[trainerId]
		if not milestone or milestone.obtained then
			return
		end

		-- Mark this trainer as defeated
		if milestone.trainers then
			milestone.trainers[trainerId] = true
			checkMilestoneForPoints(milestone)
		end
	end

	-- [Bizhawk only] Executed each frame (60 frames per second)
	-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
	function self.inputCheckBizhawk()
		if Main.loadNextSeed and ExtSettingsData.SkipFailedAttempts.value then
			-- Skip this attempt if the rival was not beaten
			local trainersDefeated = Utils.getGameStat(Constants.GAME_STATS.TRAINER_BATTLES) or 0
			if trainersDefeated == 0 then
				Main.currentSeed = Main.currentSeed - 1
			end
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