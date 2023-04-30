local function CrozwordsTourneyExtension()
	local self = {}

	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	self.name = "Crozwords Tourney Tracker"
	self.author = "UTDZac"
	self.description = "This extension adds extra functionality to the Tracker for the FRLG tournament, such as counting milestone points."
	self.version = "0.2"
	self.url = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension"

	function self.checkForUpdates()
		local versionCheckUrl = "https://api.github.com/repos/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = "https://github.com/UTDZac/CrozwordsTourney-IronmonExtension/releases/latest"

		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, nil)
		return isUpdateAvailable, downloadUrl
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
			checkIfObtained = function(this)
				-- If any rivals are defeated
				for _, isDefeated in pairs(this.trainers or {}) do
					if isDefeated then
						this.obtained = true
						break
					end
				end
			end,
		},
		-- (3) Gym 1 Brock
		Gym1Brock = { points = 3, },
		-- FULL CLEAR - Mt. Moon
		MtMoon = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 114 and TrackerAPI.getMapId() <= 116 then
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- FULL CLEAR - Boat Rival & SS Anne
		SSAnne = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 120 and TrackerAPI.getMapId() <= 123 then
					return
				end
				if TrackerAPI.getMapId() >= 177 and TrackerAPI.getMapId() <= 178 then
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- Gym 2 Misty & Gym 3 Surge
		Gym2MistyAnd3Surge = { points = 1, },
		-- FULL CLEAR - Rock Tunnel
		RockTunnel = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 154 and TrackerAPI.getMapId() <= 155 then
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- Giovanni 1 and Rocket Hideout
		RocketHideout = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 128 and TrackerAPI.getMapId() <= 131 then
					return
				end
				if TrackerAPI.getMapId() >= 224 and TrackerAPI.getMapId() <= 225 then -- entrance and elevator
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- FULL CLEAR - Tower Rival & Pokemon Tower
		PokemonTower = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 161 and TrackerAPI.getMapId() <= 167 then
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- Gym 4 Erika
		Gym4Erika = { points = 1, },
		-- Gym 5 Koga
		Gym5Koga = { points = 1, },
		-- Silph Rival and Giovanni 2 (Awarded on exit.)
		SilphEscape = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 132 and TrackerAPI.getMapId() <= 142 then
					return
				end
				if TrackerAPI.getMapId() == 229 then -- elevator
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- (3) FULL CLEAR - Silph Co.
		SilphFullClear = {
			points = 3,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 132 and TrackerAPI.getMapId() <= 142 then
					return
				end
				if TrackerAPI.getMapId() == 229 then -- elevator
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
		},
		-- FULL CLEAR - Cinnabar Mansion
		CinnabarMansion = {
			points = 1,
			checkIfObtained = function(this)
				-- Must defeat all trainers...
				for _, isDefeated in pairs(this.trainers or {}) do
					if not isDefeated then
						return
					end
				end
				-- ... And escape the area ...
				if TrackerAPI.getMapId() >= 143 and TrackerAPI.getMapId() <= 146 then
					return
				end
				-- ... Then the milestone is obtained
				this.obtained = true
			end,
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
			checkIfObtained = function(this)
				-- If any rivals are defeated
				for _, isDefeated in pairs(this.trainers or {}) do
					if isDefeated then
						this.obtained = true
						break
					end
				end
			end,
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
			checkIfObtained = function(this)
				-- If any rivals are defeated
				for _, isDefeated in pairs(this.trainers or {}) do
					if isDefeated then
						this.obtained = true
						break
					end
				end
			end,
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
		-- [369] = Milestones.PokemonTower, -- unconfirmed/unneeded
		-- [370] = Milestones.PokemonTower, -- unconfirmed
		-- [371] = Milestones.PokemonTower, -- unconfirmed
		-- [372] = Milestones.PokemonTower, -- unconfirmed

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
		TotalPoints = {
			key = "TotalPoints",
			value = 0,
			load = function(this)
				this.value = TrackerAPI.getExtensionSetting(ExtLabel, this.key) or this.value
				return this.value
			end,
			save = function(this)
				if this.value then
					TrackerAPI.saveExtensionSetting(ExtLabel, this.key, this.value)
				end
			end,
			addPoints = function(this, val) if this.value then this.value = this.value + (val or 0) end end,
		},
		CurrentMilestones = {
			key = "CurrentMilestones",
			value = "",
			load = function(this)
				this.value = TrackerAPI.getExtensionSetting(ExtLabel, this.key) or this.value
				this:parseMilestones()
				return this.value
			end,
			save = function(this)
				if this.value then
					TrackerAPI.saveExtensionSetting(ExtLabel, this.key, this.value)
				end
			end,
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

		if type(milestone.checkIfObtained) == "function" then
			milestone:checkIfObtained()
		else
			-- Default to checking if all trainers in the milestone are defeated to obtain it
			for _, isDefeated in pairs(milestone.trainers or {}) do
				if not isDefeated then
					return
				end
			end
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
	end

	local function saveSettingsData()
		for _, optionObj in pairs(ExtSettingsData) do
			if type(optionObj.save) == "function" then
				optionObj:save()
			end
		end
	end

	local function applyOptionsCallback(formInput)
		local inputAsNumber = tonumber(formInput or "")
		if inputAsNumber == nil then
			return
		end

		if ExtSettingsData.TotalPoints.value ~= inputAsNumber then
			ExtSettingsData.TotalPoints.value = inputAsNumber
			saveSettingsData()
			Program.redraw(true)
		end

		self.textBox = nil
	end

	local function openOptionsPopup()
		if not Main.IsOnBizhawk() then return end
		Program.destroyActiveForm()
		local formName = string.format("%s Settings", self.name)
		local form = forms.newform(320, 130, formName, function() client.unpause() end)
		Program.activeFormId = form
		Utils.setFormLocation(form, 100, 50)

		forms.label(form, "Enter a number of points:", 48, 10, 175, 20)
		self.textBox = forms.textbox(form, ExtSettingsData.TotalPoints.value or 0, 175, 30, "UNSIGNED", 50, 30)

		forms.button(form, "Reset", function()
			forms.settext(self.textBox, 0)
		end, 235, 28)

		forms.button(form, "Save", function()
			local formInput = forms.gettext(self.textBox)
			applyOptionsCallback(formInput)
			client.unpause()
			forms.destroy(form)
		end, 60, 60)
		forms.button(form, "Cancel", function()
			client.unpause()
			forms.destroy(form)
		end, 145, 60)
	end

	local shouldShowPoints = function()
		return Program.currentScreen == TrackerScreen and Tracker.Data.isViewingOwn and not TrackerScreen.canShowBallPicker()
	end

	local createButtons = function ()
		TrackerScreen.Buttons.PointTotalBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = "",
			getText = function() return tostring(ExtSettingsData.TotalPoints.value or 0) end,
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
			text = "",
			getText = function() return "" end,
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
			text = "",
			getText = function() return "" end,
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

		-- If a previous game is loaded and being continued, keep milestones; otherwise, only keep points and reset milestones
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

	function self.afterBattleEnds()
		if not isSupported() then return end

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