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

	local Milestones = {
		-- 1 point per Viridian Forest Trainer
		ForestTrainer1 = { points = 1, },
		ForestTrainer2 = { points = 1, },
		ForestTrainer3 = { points = 1, },
		ForestTrainer4 = { points = 1, },
		ForestTrainer5 = { points = 1, },
		-- Rival 2 Viridian
		Rival2Viridian = {
			points = 1,
			checkIfObtained = function(this) return defeatAtLeastOne(this.trainers) end,
		},
		-- (3) Gym 1 Brock
		Gym1Brock = { points = 3, },
		-- FULL CLEAR - Mt. Moon
		MtMoon = {
			points = 1,
			zone = Zones.MtMoon,
		},
		-- FULL CLEAR - Boat Rival & SS Anne
		SSAnne = {
			points = 1,
			zone = Zones.SSAnne,
		},
		-- Gym 2 Misty & Gym 3 Surge
		Gym2MistyAnd3Surge = { points = 1, },
		-- FULL CLEAR - Rock Tunnel
		RockTunnel = {
			points = 1,
			zone = Zones.RockTunnel,
		},
		-- Giovanni 1 and Rocket Hideout
		RocketHideout = {
			points = 1,
			zone = Zones.RocketHideout,
		},
		-- FULL CLEAR - Tower Rival & Pokemon Tower
		PokemonTower = {
			points = 1,
			zone = Zones.PokemonTower,
		},
		-- Gym 4 Erika
		Gym4Erika = { points = 1, },
		-- Gym 5 Koga
		Gym5Koga = { points = 1, },
		-- Silph Rival and Giovanni 2 (Awarded on exit.)
		SilphEscape = {
			points = 1,
			zone = Zones.SilphCo,
		},
		-- (3) FULL CLEAR - Silph Co.
		SilphFullClear = {
			points = 3,
			zone = Zones.SilphCo,
		},
		-- FULL CLEAR - Cinnabar Mansion
		CinnabarMansion = {
			points = 1,
			zone = Zones.CinnabarMansion,
		},
		-- Gym 6 Sabrina
		Gym6Sabrina = { points = 1, },
		-- Gym 7 Blaine
		Gym7Blaine = { points = 1, },
		-- (2) Gym 8 Giovanni
		Gym8Giovanni = { points = 2, },
		-- VR Rival
		RivalVictoryRoad = {
			points = 1,
			checkIfObtained = function(this) return defeatAtLeastOne(this.trainers) end,
		},
		-- Lorelei
		E4Lorelei = { points = 1, },
		-- (2) Bruno
		E4Bruno = { points = 2, },
		-- (2) Agatha
		E4Agatha = { points = 2, },
		-- (3) Lance
		E4Lance = { points = 3, },
		-- (5) CHAMP
		E4Champ = {
			points = 5,
			checkIfObtained = function(this) return defeatAtLeastOne(this.trainers) end,
		},
	}
	local TrainerMilestoneMap = {
		[102] = Milestones.ForestTrainer1,
		[103] = Milestones.ForestTrainer2,
		[104] = Milestones.ForestTrainer3,
		[531] = Milestones.ForestTrainer4,
		[532] = Milestones.ForestTrainer5,
		[329] = Milestones.Rival2Viridian,
		[330] = Milestones.Rival2Viridian,
		[331] = Milestones.Rival2Viridian,
		[414] = Milestones.Gym1Brock,

		-- ALL MT MOON - 12 total
		[108] = Milestones.MtMoon,
		[109] = Milestones.MtMoon,
		[121] = Milestones.MtMoon,
		[169] = Milestones.MtMoon,
		[120] = Milestones.MtMoon,
		[91] = Milestones.MtMoon,
		[181] = Milestones.MtMoon,
		[170] = Milestones.MtMoon,
		[351] = Milestones.MtMoon,
		[352] = Milestones.MtMoon,
		[353] = Milestones.MtMoon,
		[354] = Milestones.MtMoon,

		-- ALL SS ANNE - 16 total (exclude rival, he's implied)
		[96] = Milestones.SSAnne,
		[126] = Milestones.SSAnne,
		[422] = Milestones.SSAnne,
		[421] = Milestones.SSAnne,
		[140] = Milestones.SSAnne,
		[224] = Milestones.SSAnne,
		[138] = Milestones.SSAnne,
		[139] = Milestones.SSAnne,
		[136] = Milestones.SSAnne,
		[137] = Milestones.SSAnne,
		[482] = Milestones.SSAnne,
		[223] = Milestones.SSAnne,
		[483] = Milestones.SSAnne,
		[127] = Milestones.SSAnne,
		[134] = Milestones.SSAnne,
		[135] = Milestones.SSAnne,

		[415] = Milestones.Gym2MistyAnd3Surge,
		[416] = Milestones.Gym2MistyAnd3Surge,

		-- ALL ROCK TUNNEL - 15 total
		[189] = Milestones.RockTunnel,
		[190] = Milestones.RockTunnel,
		[191] = Milestones.RockTunnel,
		[192] = Milestones.RockTunnel,
		[193] = Milestones.RockTunnel,
		[194] = Milestones.RockTunnel,
		[166] = Milestones.RockTunnel,
		[165] = Milestones.RockTunnel,
		[159] = Milestones.RockTunnel,
		[156] = Milestones.RockTunnel,
		[164] = Milestones.RockTunnel,
		[168] = Milestones.RockTunnel,
		[476] = Milestones.RockTunnel,
		[475] = Milestones.RockTunnel,
		[474] = Milestones.RockTunnel,

		[348] = Milestones.RocketHideout, -- Giovanni

		-- ALL POKEMON TOWER - 13 total (exclude rival and top grunts, they're implied)
		[441] = Milestones.PokemonTower,
		[442] = Milestones.PokemonTower,
		[443] = Milestones.PokemonTower,
		[444] = Milestones.PokemonTower,
		[445] = Milestones.PokemonTower,
		[446] = Milestones.PokemonTower,
		[447] = Milestones.PokemonTower,
		[448] = Milestones.PokemonTower,
		[449] = Milestones.PokemonTower,
		[450] = Milestones.PokemonTower,
		[451] = Milestones.PokemonTower,
		[452] = Milestones.PokemonTower,
		[453] = Milestones.PokemonTower,
		[369] = Milestones.PokemonTower,
		[370] = Milestones.PokemonTower,
		[371] = Milestones.PokemonTower,

		-- [372] = Milestones.????, -- no idea where this trainer is located

		[417] = Milestones.Gym4Erika,
		[418] = Milestones.Gym5Koga,

		[349] = Milestones.SilphEscape, -- Giovanni

		-- ALL SILPH CO - total 30 (exclude rival, he's implied)
		[336] = Milestones.SilphFullClear,
		[337] = Milestones.SilphFullClear,
		[338] = Milestones.SilphFullClear,
		[339] = Milestones.SilphFullClear,
		[340] = Milestones.SilphFullClear,
		[341] = Milestones.SilphFullClear,
		[342] = Milestones.SilphFullClear,
		[343] = Milestones.SilphFullClear,
		[344] = Milestones.SilphFullClear,
		[345] = Milestones.SilphFullClear,

		[373] = Milestones.SilphFullClear,
		[374] = Milestones.SilphFullClear,
		[375] = Milestones.SilphFullClear,
		[376] = Milestones.SilphFullClear,
		[377] = Milestones.SilphFullClear,
		[378] = Milestones.SilphFullClear,
		[379] = Milestones.SilphFullClear,
		[380] = Milestones.SilphFullClear,
		[381] = Milestones.SilphFullClear,
		[382] = Milestones.SilphFullClear,

		[383] = Milestones.SilphFullClear,
		[384] = Milestones.SilphFullClear,
		[385] = Milestones.SilphFullClear,
		[386] = Milestones.SilphFullClear,
		[387] = Milestones.SilphFullClear,
		[388] = Milestones.SilphFullClear,
		[389] = Milestones.SilphFullClear,
		[390] = Milestones.SilphFullClear,
		[391] = Milestones.SilphFullClear,
		[286] = Milestones.SilphFullClear,

		-- ALL CINNABAR MANSION - 6 total
		[216] = Milestones.CinnabarMansion,
		[218] = Milestones.CinnabarMansion,
		[219] = Milestones.CinnabarMansion,
		[534] = Milestones.CinnabarMansion,
		[335] = Milestones.CinnabarMansion,
		[346] = Milestones.CinnabarMansion,
		[347] = Milestones.CinnabarMansion,

		[420] = Milestones.Gym6Sabrina,
		[419] = Milestones.Gym7Blaine,
		[350] = Milestones.Gym8Giovanni,

		[435] = Milestones.RivalVictoryRoad,
		[436] = Milestones.RivalVictoryRoad,
		[437] = Milestones.RivalVictoryRoad,

		[410] = Milestones.E4Lorelei,
		[411] = Milestones.E4Bruno,
		[412] = Milestones.E4Agatha,
		[413] = Milestones.E4Lance,
		[438] = Milestones.E4Champ,
		[439] = Milestones.E4Champ,
		[440] = Milestones.E4Champ,
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
			label = "Current point total",
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

		-- Add the trainer list to each milestone
		for trainerId, milestone in pairs(TrainerMilestoneMap) do
			if milestone.trainers == nil then
				milestone.trainers = {}
			end
			milestone.trainers[trainerId] = false
		end
	end

	-- If conditions are met to receive milestone, mark it as obtained and add points
	local checkMilestoneForPoints = function(milestone)
		if not milestone or milestone.obtained then return end

		if type(milestone.checkIfObtained) == "function" and milestone:checkIfObtained() then
			milestone.obtained = true
		elseif defeatAll(milestone.trainers) and (not ExtSettingsData.RequireEscapeArea.value or escapedZone(milestone.zone)) then
			-- Default condition for a milestone being completed (it's the most common)
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
		local pointsAsNumber = tonumber(pointValue or "")
		if pointsAsNumber == nil then
			return
		end

		local settingsWereChange = false
		if ExtSettingsData.AutoCountPoints.value ~= autoCount then
			ExtSettingsData.AutoCountPoints.value = autoCount
			settingsWereChange = true
		end
		if ExtSettingsData.RequireEscapeArea.value ~= requireEscape then
			ExtSettingsData.RequireEscapeArea.value = requireEscape
			settingsWereChange = true
		end
		if ExtSettingsData.TotalPoints.value ~= pointsAsNumber then
			ExtSettingsData.TotalPoints.value = pointsAsNumber
			settingsWereChange = true
		end

		if settingsWereChange then
			saveSettingsData()
			Program.redraw(true)
		end
	end

	local function openOptionsPopup()
		if not Main.IsOnBizhawk() then return end

		local popupWidth, popupHeight = 480, 170
		local fontFamily, fontSize, fontColor, fontStyle = "Arial", 14, 0xFF000000, "bold"

		Program.destroyActiveForm()
		local formName = string.format("%s Settings", self.name)
		local form = forms.newform(popupWidth, popupHeight, formName, function() client.unpause() end)
		Program.activeFormId = form
		Utils.setFormLocation(form, 100, 50)


		local rightCol = popupWidth - 50
		local yOffset = 10
		local canvas = { x = 0, y = 10, width = rightCol - 40, height = popupHeight - 90, }
		canvas.area = forms.pictureBox(form, canvas.x, canvas.y, canvas.width, canvas.height)

		local optionAutoCount = forms.checkbox(form, "", rightCol, yOffset)
		forms.setproperty(optionAutoCount, "Checked", Utils.inlineIf(ExtSettingsData.AutoCountPoints.value, "True", "False"))
		forms.drawText(canvas.area, canvas.width, yOffset-6, ExtSettingsData.AutoCountPoints.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "right")
		yOffset = yOffset + 25

		local optionRequireEscape = forms.checkbox(form, "", rightCol, yOffset)
		forms.setproperty(optionRequireEscape, "Checked", Utils.inlineIf(ExtSettingsData.RequireEscapeArea.value, "True", "False"))
		forms.drawText(canvas.area, canvas.width, yOffset-6, ExtSettingsData.RequireEscapeArea.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "right")
		yOffset = yOffset + 25

		local textBox = forms.textbox(form, ExtSettingsData.TotalPoints.value or 0, 34, 20, "UNSIGNED", rightCol-20, yOffset+2)
		forms.setproperty(textBox, "TextAlign", "Right")
		forms.drawText(canvas.area, canvas.width, yOffset-6, ExtSettingsData.TotalPoints.label, fontColor, 0x00000000, fontSize, fontFamily, fontStyle, "right")
		yOffset = yOffset + 25

		yOffset = yOffset + 10
		local resetButton = forms.button(form, "Reset Points", function()
			forms.settext(textBox, 0)
		end, rightCol-75, yOffset, 90, 23)
		forms.setproperty(resetButton, "TextAlign", "Right")
		forms.button(form, "Save", function()
			local formInput = forms.gettext(textBox)
			applyOptionsCallback(forms.ischecked(optionAutoCount), forms.ischecked(optionRequireEscape), formInput)

			client.unpause()
			forms.destroy(form)
		end, 130, yOffset)
		forms.button(form, "Cancel", function()
			client.unpause()
			forms.destroy(form)
		end, 210, yOffset)
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