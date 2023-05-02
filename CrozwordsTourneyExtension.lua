local function CrozwordsTourneyExtension()
	local self = {}

	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	self.name = "Crozwords Tourney Tracker"
	self.author = "UTDZac"
	self.description = "This extension adds extra functionality to the Tracker for the FRLG tournament, such as counting milestone points."
	self.version = "0.5"
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
		ForestTrainer1 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		ForestTrainer2 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		ForestTrainer3 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		ForestTrainer4 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		ForestTrainer5 = 	{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Rival2 = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Brock = 			{ type = MilestoneTypes.SingleTrainer, 	points = 3, },
		MtMoonFC = 			{ type = MilestoneTypes.FullClear, 		points = 1, zone = Zones.MtMoon, },
		SSAnneFC = 			{ type = MilestoneTypes.FullClear, 		points = 1, zone = Zones.SSAnne, },
		MistySurge = 		{ type = MilestoneTypes.AllTrainers, 	points = 1, },
		RockTunnelFC = 		{ type = MilestoneTypes.FullClear, 		points = 1, zone = Zones.RockTunnel, },
		RocketHideout = 	{ type = MilestoneTypes.EscapeZone, 	points = 1, zone = Zones.RocketHideout, },
		PokemonTowerFC = 	{ type = MilestoneTypes.FullClear, 		points = 1, zone = Zones.PokemonTower, },
		Erika = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Koga = 				{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		SilphEscape = 		{ type = MilestoneTypes.EscapeZone, 	points = 1, zone = Zones.SilphCo, },
		SilphFC = 			{ type = MilestoneTypes.FullClear, 		points = 3, zone = Zones.SilphCo, },
		CinnabarFC = 		{ type = MilestoneTypes.FullClear, 		points = 1, zone = Zones.CinnabarMansion, },
		Sabrina = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Blaine = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		GiovanniGym = 		{ type = MilestoneTypes.SingleTrainer, 	points = 2, },
		RivalVR = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Lorelei = 			{ type = MilestoneTypes.SingleTrainer, 	points = 1, },
		Bruno = 			{ type = MilestoneTypes.SingleTrainer, 	points = 2, },
		Agatha = 			{ type = MilestoneTypes.SingleTrainer, 	points = 2, },
		Lance = 			{ type = MilestoneTypes.SingleTrainer, 	points = 3, },
		Champion = 			{ type = MilestoneTypes.SingleTrainer, 	points = 5, },
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
			label = "Automatically count points for milestones completed",
		},
		RequireEscapeArea = {
			value = true, -- default
			label = "Award points only after leaving a dungeon (non-gym)",
		},
		TotalPoints = {
			value = 0, -- default
			label = "Total points across all seeds",
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

	-- Helper Functions
	local isSupported = function() return GameSettings.game == 3 end

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
		local exportTable = {}
		local totalPoints = 0
		local forestTrainers = 0
		for key, milestone in pairs(Milestones) do
			if milestone.obtained then
				totalPoints = totalPoints + (milestone.points or 0)
				if key:sub(1, 6) == "Forest" then
					forestTrainers = forestTrainers + 1
				else
					table.insert(exportTable, key)
				end
			end
		end
		if forestTrainers > 0 then
			table.insert(exportTable, 1, string.format("Forest(%s)", forestTrainers))
		end

		local milestoneText
		if #exportTable > 0 then
			milestoneText = table.concat(exportTable, ", ")
		else
			milestoneText = "No milestones achieved"
		end

		return string.format("%s Points: %s", totalPoints, milestoneText)
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

	local function applyOptionsCallback(autoCount, requireEscape, pointValue)
		local settingsWereChange = false

		if ExtSettingsData.AutoCountPoints.value ~= autoCount then
			ExtSettingsData.AutoCountPoints.value = autoCount
			settingsWereChange = true
		end
		if ExtSettingsData.RequireEscapeArea.value ~= requireEscape then
			ExtSettingsData.RequireEscapeArea.value = requireEscape
			settingsWereChange = true
		end
		if ExtSettingsData.TotalPoints.value ~= pointValue then
			ExtSettingsData.TotalPoints.value = pointValue
			settingsWereChange = true
		end

		if settingsWereChange then
			saveSettingsData()
			Program.redraw(true)
		end
	end

	local function openOptionsPopup()
		if not Main.IsOnBizhawk() then return end

		local popupWidth, popupHeight = 500, 250
		local fontFamily, fontSize, fontColor, fontStyle = "Arial", 14, 0xFF000000, "bold"

		Program.destroyActiveForm()
		local formName = string.format("%s Settings", self.name)
		local form = forms.newform(popupWidth, popupHeight, formName, function() client.unpause() end)
		Program.activeFormId = form
		Utils.setFormLocation(form, 100, 50)

		local rightCol = popupWidth - 50
		local yOffset = 10
		local canvas = { x = 0, y = 10, width = rightCol - 40, height = 100, }
		canvas.area = forms.pictureBox(form, canvas.x, canvas.y, canvas.width, canvas.height)

		local optionAutoCount = forms.checkbox(form, "", rightCol, yOffset)
		forms.setproperty(optionAutoCount, "Checked", Utils.inlineIf(ExtSettingsData.AutoCountPoints.value, "True", "False"))
		forms.drawText(canvas.area, canvas.x + 34, yOffset-6, ExtSettingsData.AutoCountPoints.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "left")
		yOffset = yOffset + 25

		local optionRequireEscape = forms.checkbox(form, "", rightCol, yOffset)
		forms.setproperty(optionRequireEscape, "Checked", Utils.inlineIf(ExtSettingsData.RequireEscapeArea.value, "True", "False"))
		forms.drawText(canvas.area, canvas.x + 34, yOffset-6, ExtSettingsData.RequireEscapeArea.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "left")
		yOffset = yOffset + 25

		local textboxPoints = forms.textbox(form, ExtSettingsData.TotalPoints.value or 0, 39, 20, "UNSIGNED", rightCol-25, yOffset+2)
		forms.drawText(canvas.area, canvas.x + 34, yOffset-6, ExtSettingsData.TotalPoints.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "left")
		yOffset = yOffset + 51

		local textboxShareMilestones = forms.textbox(form, exportMilestones(), 430, 60, nil, 35, yOffset, true, false, "Vertical")
		forms.drawText(canvas.area, canvas.x + 34, yOffset-28, "Points & milestones for current seed:", fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "left")
		yOffset = yOffset + 50

		yOffset = yOffset + 20
		local resetButton = forms.button(form, "Clear Seed/Points", function()
			ExtSettingsData.TotalPoints.value = 0
			resetMilestones()
			forms.settext(textboxPoints, ExtSettingsData.TotalPoints.value)
			forms.settext(textboxShareMilestones, exportMilestones())
		end, rightCol-95, yOffset, 110, 23)
		local saveButton = forms.button(form, "Save", function()
			local pointsAsNumber = tonumber(forms.gettext(textboxPoints) or "") or ExtSettingsData.TotalPoints.value
			applyOptionsCallback(forms.ischecked(optionAutoCount), forms.ischecked(optionRequireEscape), pointsAsNumber)

			client.unpause()
			forms.destroy(form)
		end, 140, yOffset)
		local cancelButton = forms.button(form, "Cancel", function()
			client.unpause()
			forms.destroy(form)
		end, 220, yOffset)
	end

	local shouldShowPoints = function()
		return Program.currentScreen == TrackerScreen and Tracker.Data.isViewingOwn and not TrackerScreen.canShowBallPicker()
	end

	local createButtons = function ()
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
			onClick = function() openOptionsPopup() end
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
			end
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
			end
		}
	end
	local removeButtons = function()
		TrackerScreen.Buttons.PointTotalBtn = nil
		TrackerScreen.Buttons.PointIncrementBtn = nil
		TrackerScreen.Buttons.PointDecrementBtn = nil
	end

	-- EXTENSION FUNCTIONS
	function self.configureOptions()
		openOptionsPopup()
	end

	local originalSurvivalSetting
	function self.startup()
		if not isSupported() then return end
		originalSurvivalSetting = Options["Track PC Heals"]
		Options["Track PC Heals"] = false

		createButtons()
		resetMilestones()

		-- If a previous game is loaded and being continued, keep milestones; otherwise, just keep points and reset milestones
		if Tracker.DataMessage:find(Tracker.LoadStatusMessages.fromFile) ~= nil then
			loadSettingsData()
		else
			ExtSettingsData.TotalPoints:load()
			ExtSettingsData.CurrentMilestones.value = ""
			ExtSettingsData.CurrentMilestones:save()
		end
	end

	function self.unload()
		if not isSupported() then return end
		if originalSurvivalSetting ~= nil then
			Options["Track PC Heals"] = (originalSurvivalSetting == true)
		end

		removeButtons()
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
		end

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