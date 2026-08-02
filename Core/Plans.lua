local _, Raid = ...
local Core = Raid.Core
local Copy = Core.Copy
local classNames = Core.classNames
local simulatedNames = Core.simulatedNames
local simulatedByRole = Core.simulatedByRole
local function SlotLabel(slot)
	return type(slot) == "table" and slot.label or tostring(slot or "")
end

Core.SlotLabel = SlotLabel

local function CompositionSlots(self, label, count, defaultSlots, role)
	local slots = {}
	for index = 1, count do
		if defaultSlots and defaultSlots[index] then
			slots[index] = defaultSlots[index]
		elseif label == "Tank" then
			slots[index] = index == 1 and self.Assignment.TANK.MAIN
			or index == 2 and self.Assignment.TANK.OFF
			or self.Assignment:Tank(
				tostring(index), ("Tank %d"):format(index), index)
		else
			slots[index] = self.DataSlot(
				label:lower() .. "." .. index,
				("%s %d"):format(label, index),
				role, role == self.Role.HEALER
				and self.AssignmentType.HEALER
				or self.AssignmentType.DAMAGE,
				role == self.Role.HEALER
				and self.AssignmentTarget.RAID or nil,
				index)
		end
	end
	return slots
end

function Raid:GetDefaultRaidComposition(raid)
	raid = raid or self.raidByKey[self.db.activeRaid]
	if not raid then
		return { tanks = 0, healers = 0, damage = 0 }
	end
	if raid.defaultComposition and raid.defaultRoleSlots then
		return raid.defaultComposition
	end
	local tanks, healers = 0, 0
	raid.defaultRoleSlots = {
		Tanks = {},
		Healing = {},
	}
	local overview = raid.encounters and raid.encounters[1]
	for _, group in ipairs(overview and overview.groups or {}) do
		if group.name == "Tanks" then
			tanks = #group.slots
			for index, label in ipairs(group.slots) do
				raid.defaultRoleSlots.Tanks[index] = label
			end
		elseif group.name == "Healing" then
			healers = #group.slots
			for index, label in ipairs(group.slots) do
				raid.defaultRoleSlots.Healing[index] = label
			end
		end
	end
	raid.defaultComposition = {
		tanks = tanks,
		healers = healers,
		damage = math.max(0, raid.size - tanks - healers),
	}
	return raid.defaultComposition
end

function Raid:GetRaidComposition(raidKey)
	local raid = self.raidByKey[raidKey or self.db.activeRaid]
	local defaultsForRaid = self:GetDefaultRaidComposition(raid)
	local override = self.db.raidCompositions[raid.key] or {}
	return {
		tanks = tonumber(override.tanks) or defaultsForRaid.tanks,
		healers = tonumber(override.healers) or defaultsForRaid.healers,
		damage = tonumber(override.damage) or defaultsForRaid.damage,
	}
end

function Raid:SetRaidCompositionCount(raidKey, role, value)
	if not self:RequireRaidEditor() then
		return
	end
	local raid = self.raidByKey[raidKey]
	if not raid then
		return
	end
	self.db.raidCompositions[raidKey] =
		self.db.raidCompositions[raidKey] or {}
	self.db.raidCompositions[raidKey][role] =
		math.max(0, math.min(raid.size, math.floor(value or 0)))
	self:ApplyRaidComposition(raid)
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("COMP", {
			raidKey, role, self.db.raidCompositions[raidKey][role],
		})
	end
	if raidKey == self.db.activeRaid then
		self:AutoSaveActiveRaid()
	end
	if self.frame and raidKey == self.db.activeRaid then
		self:RefreshAssignments()
	end
end

function Raid:ResetRaidComposition(raidKey)
	if not self:RequireRaidEditor() then
		return
	end
	local raid = self.raidByKey[raidKey]
	if not raid then
		return
	end
	self.db.raidCompositions[raidKey] = nil
	self:ApplyRaidComposition(raid)
	if self.QueueSync and self:IsLocalRaidEditor() then
		local composition = self:GetRaidComposition(raidKey)
		for _, role in ipairs({ "tanks", "healers" }) do
			self:QueueSync("COMP", {
				raidKey, role, composition[role],
			})
		end
	end
	if raidKey == self.db.activeRaid then
		self:AutoSaveActiveRaid()
	end
	if self.frame and raidKey == self.db.activeRaid then
		self:RefreshAssignments()
	end
end

function Raid:ApplyRaidComposition(raid)
	if not raid or not raid.encounters or not raid.encounters[1] then
		return
	end
	local composition = self:GetRaidComposition(raid.key)
	local defaultsForRaid = raid.defaultRoleSlots
	local overview = raid.encounters[1]
	for _, group in ipairs(overview.groups) do
		if group.name == "Tanks" then
			group.slots = CompositionSlots(
				self, "Tank", composition.tanks,
				defaultsForRaid.Tanks, self.Role.TANK)
		elseif group.name == "Healing" then
			group.slots = CompositionSlots(
				self, "Healer", composition.healers,
				defaultsForRaid.Healing, self.Role.HEALER)
		end
	end
end

function Raid:GetRaidsForExpansion()
	local result = {}
	for _, raid in ipairs(self.raids) do
		if raid.expansion == self.db.activeExpansion then
			result[#result + 1] = raid
		end
	end
	return result
end

function Raid:GetEncounter()
	local raid = self:GetRaid()
	local index = math.max(1, math.min(
		tonumber(self.db.activeEncounter) or 1, #raid.encounters))
	self.db.activeEncounter = index
	self.db.lastEncounterByRaid[raid.key] = index
	return raid.encounters[index], index
end

function Raid:GetBossOverride(create, raidKey, encounterIndex)
	local raid = self.raidByKey[raidKey or self.db.activeRaid]
	if not raid then
		return nil
	end
	encounterIndex = tonumber(encounterIndex) or self.db.activeEncounter
	if create then
		self.db.bossOverrides[raid.key] =
			self.db.bossOverrides[raid.key] or {}
		self.db.bossOverrides[raid.key][encounterIndex] =
			self.db.bossOverrides[raid.key][encounterIndex]
			or { groups = {} }
		local result = self.db.bossOverrides[raid.key][encounterIndex]
		result.groups = result.groups or {}
		return result
	end
	return self.db.bossOverrides[raid.key]
	and self.db.bossOverrides[raid.key][encounterIndex]
end

function Raid:PersistRaidConfiguration(raidKey)
	local raid = self.raidByKey[raidKey or self.db.activeRaid]
	if not raid then return end
	self.db.raidConfigurationDefaults =
		self.db.raidConfigurationDefaults or {}
	self.db.raidConfigurationDefaults[raid.key] = {
		bossOverrides = Copy(self.db.bossOverrides[raid.key] or {}),
		bossPresets = Copy(self.db.bossPresets[raid.key] or {}),
	}
	local saved = self.db.activeSavedRaid
		and self.db.savedRaids[self.db.activeSavedRaid]
	if saved and saved.raidKey == raid.key then
		saved.bossOverrides =
			Copy(self.db.bossOverrides[raid.key] or {})
		saved.bossPresets =
			Copy(self.db.bossPresets[raid.key] or {})
		saved.activeEncounter = self.db.activeEncounter
		saved.currentBoss = self:GetCurrentBossIndex(raid)
		saved.savedAt = GetServerTime and GetServerTime()
			or time and time() or saved.savedAt
	end
end

function Raid:GetEncounterGroups(encounter, raidKey, encounterIndex)
	encounter = encounter or self:GetEncounter()
	local groups = {}
	for _, group in ipairs(encounter and encounter.groups or {}) do
		groups[#groups + 1] = group
	end
	local override = self:GetBossOverride(false, raidKey, encounterIndex)
	for _, custom in ipairs(override and override.customGroups or {}) do
		groups[#groups + 1] = {
			name = custom.name, role = custom.role or self.Role.DAMAGE,
			type = custom.type or self.AssignmentType.UTILITY,
			slots = {}, custom = true, customID = custom.id,
		}
	end
	return groups
end

function Raid:GetEncounterGroupSlots(
	groupIndex, encounter, raidKey, encounterIndex)
	encounter = encounter or self:GetEncounter()
	local group = self:GetEncounterGroups(
		encounter, raidKey, encounterIndex)[groupIndex]
	if not group then
		return {}
	end
	local override = self:GetBossOverride(
		false, raidKey, encounterIndex)
	local count = override and override.groups
	and tonumber(override.groups[groupIndex]) or #group.slots
	count = math.max(0, math.floor(count or #group.slots))
	local result = {}
	local singular = group.name:gsub("s$", "")
	for index = 1, count do
		result[index] = group.slots[index]
		or self.DataSlot(
			(group.customID and ("custom." .. group.customID)
				or group.name:lower()) .. "." .. index,
			singular .. " " .. index,
			group.role or self.Role.DAMAGE,
			group.type or self.AssignmentType.UTILITY,
			nil, index)
	end
	return result
end

function Raid:SetBossGroupCount(groupIndex, count)
	if not self:RequireRaidEditor() then
		return
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	local encounter = raid.encounters[encounterIndex]
	if not self:GetEncounterGroups(encounter)[groupIndex] then
		return
	end
	local override = self:GetBossOverride(true)
	override.groups[groupIndex] = math.max(
		0, math.min(raid.size, math.floor(tonumber(count) or 0)))
	local customIndex = groupIndex - #encounter.groups
	if customIndex > 0 and override.customGroups
	and override.customGroups[customIndex]
	then
		override.customGroups[customIndex].count =
			override.groups[groupIndex]
	end
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("BOSSSET", {
			raid.key, encounterIndex, "G:" .. groupIndex,
			override.groups[groupIndex],
		})
	end
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:SetBossHealerCount(count)
	if not self:RequireRaidEditor() then
		return
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	local override = self:GetBossOverride(true)
	override.healers = math.max(
		0, math.min(raid.size, math.floor(tonumber(count) or 0)))
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("BOSSSET", {
			raid.key, encounterIndex, "HEALERS", override.healers,
		})
	end
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:ResetBossOverride()
	if not self:RequireRaidEditor() then
		return
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	if self.db.bossOverrides[raid.key] then
		self.db.bossOverrides[raid.key][encounterIndex] = nil
	end
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("BOSSRESET", { raid.key, encounterIndex })
	end
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:GetBossPresetCollection(create)
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	if create then
		self.db.bossPresets[raid.key] =
			self.db.bossPresets[raid.key] or {}
		local collection = self.db.bossPresets[raid.key][encounterIndex]
		if type(collection) ~= "table"
		or type(collection.items) ~= "table"
		then
			collection = { items = {} }
			self.db.bossPresets[raid.key][encounterIndex] = collection
		end
		return collection
	end
	local collection = self.db.bossPresets[raid.key]
	and self.db.bossPresets[raid.key][encounterIndex]
	return type(collection) == "table"
	and type(collection.items) == "table" and collection or nil
end

function Raid:GetBossPresets()
	local collection = self:GetBossPresetCollection(false)
	local presets = {}
	for _, preset in pairs(collection and collection.items or {}) do
		if type(preset) == "table" and preset.id and preset.name
		and type(preset.settings) == "table"
		then
			presets[#presets + 1] = preset
		end
	end
	table.sort(presets, function(left, right)
		if (left.savedAt or 0) ~= (right.savedAt or 0) then
			return (left.savedAt or 0) > (right.savedAt or 0)
		end
		return left.name:lower() < right.name:lower()
	end)
	return presets
end

function Raid:GetSelectedBossPreset()
	local collection = self:GetBossPresetCollection(false)
	if not collection then
		return nil
	end
	local selected = collection.selected
	and collection.items[collection.selected]
	if selected then
		return selected
	end
	local presets = self:GetBossPresets()
	if presets[1] then
		collection.selected = presets[1].id
		return presets[1]
	end
end

function Raid:GetBossPreset()
	local preset = self:GetSelectedBossPreset()
	return preset and preset.settings or nil
end

function Raid:SelectBossPreset(presetID)
	local collection = self:GetBossPresetCollection(false)
	if not collection or not collection.items[presetID] then
		return false
	end
	collection.selected = presetID
	if self.RefreshBossSettingsPanel then
		self:RefreshBossSettingsPanel()
	end
	return true
end

function Raid:CycleBossPreset(delta)
	local presets = self:GetBossPresets()
	if #presets == 0 then
		return
	end
	local selected = self:GetSelectedBossPreset()
	local index = 1
	for presetIndex, preset in ipairs(presets) do
		if selected and preset.id == selected.id then
			index = presetIndex
			break
		end
	end
	index = ((index - 1 + (delta or 1)) % #presets) + 1
	self:SelectBossPreset(presets[index].id)
end

function Raid:SyncBossSettings(kind, settings)
	if not self.QueueSync or not self:IsLocalRaidEditor() then
		return
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	self:QueueSync(kind .. "RESET", { raid.key, encounterIndex })
	if kind == "BOSS" then
		for _, custom in ipairs(settings and settings.customGroups or {}) do
			self:QueueSync("BOSSCUSTOM", {
				raid.key, encounterIndex, custom.id,
				custom.name, custom.count or 1,
			})
		end
	end
	if settings and tonumber(settings.healers) then
		self:QueueSync(kind .. "SET", {
			raid.key, encounterIndex, "HEALERS", settings.healers,
		})
	end
	for groupIndex, count in pairs(settings and settings.groups or {}) do
		self:QueueSync(kind .. "SET", {
			raid.key, encounterIndex, "G:" .. groupIndex, count,
		})
	end
end

function Raid:SaveBossPreset(name)
	if not self:RequireRaidEditor() then
		return false
	end
	name = strtrim(name or "")
	if name == "" then
		self:Print(self.L.ENTER_PRESET_NAME)
		return false
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	local override = self:GetBossOverride(false)
	local settings = override and Copy(override) or { groups = {} }
	local collection = self:GetBossPresetCollection(true)
	local preset
	for _, candidate in pairs(collection.items) do
		if candidate.name and candidate.name:lower() == name:lower() then
			preset = candidate
			break
		end
	end
	if not preset then
		local stamp = GetServerTime and GetServerTime() or time()
		local id
		repeat
			self.bossPresetSequence = (self.bossPresetSequence or 0) + 1
			id = tostring(stamp) .. "-" .. self.bossPresetSequence
		until not collection.items[id]
		preset = { id = id }
		collection.items[id] = preset
	end
	preset.name = name
	preset.settings = settings
	preset.savedAt = GetServerTime and GetServerTime() or time()
	collection.selected = preset.id
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshBossSettingsPanel then
		self:RefreshBossSettingsPanel()
	end
	self:Print(self:Localize(
		"PRESET_SAVED", name, self:GetEncounter().name))
	return true
end

function Raid:LoadBossPreset(presetID)
	if not self:RequireRaidEditor() then
		return false
	end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	if presetID then
		self:SelectBossPreset(presetID)
	end
	local selected = self:GetSelectedBossPreset()
	local preset = selected and selected.settings
	if not preset then
		self:Print(self.L.NO_CUSTOM_PRESET)
		return false
	end
	self.db.bossOverrides[raid.key] =
		self.db.bossOverrides[raid.key] or {}
	self.db.bossOverrides[raid.key][encounterIndex] = Copy(preset)
	self:PersistRaidConfiguration(raid.key)
	self:SyncBossSettings("BOSS", preset)
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
	self:Print(self:Localize(
		"PRESET_APPLIED", selected.name, self:GetEncounter().name))
	return true
end

function Raid:DeleteBossPreset(presetID)
	if not self:RequireRaidEditor() then
		return false
	end
	local collection = self:GetBossPresetCollection(false)
	presetID = presetID
	or collection and collection.selected
	local preset = collection and collection.items[presetID]
	if not preset then
		return false
	end
	collection.items[presetID] = nil
	if collection.selected == presetID then
		collection.selected = nil
	end
	self:GetSelectedBossPreset()
	self:PersistRaidConfiguration(self:GetRaid().key)
	if self.RefreshBossSettingsPanel then
		self:RefreshBossSettingsPanel()
	end
	self:Print(self:Localize(
		"PRESET_DELETED", preset.name, self:GetEncounter().name))
	return true
end

function Raid:GetPlan(create)
	local raid = self:GetRaid()
	local _, encounterIndex = self:GetEncounter()
	local plans = self.simulation.enabled
	and self.simulation.plans or self.db.plans
	if create then
		plans[raid.key] = plans[raid.key] or {}
		plans[raid.key][encounterIndex] =
			plans[raid.key][encounterIndex] or {}
	end
	return plans[raid.key]
	and plans[raid.key][encounterIndex] or nil
end

function Raid:SlotKey(groupIndex, slotIndex)
	local encounter = self:GetEncounter()
	local slots = self:GetEncounterGroupSlots(groupIndex, encounter)
	local slot = slots[slotIndex]
	if slot and slot.id then
		return "S:" .. slot.id
	end
	return ("S:group.%d.slot.%d"):format(groupIndex, slotIndex)
end

function Raid:GetAssignment(groupIndex, slotIndex)
	local plan = self:GetPlan(false)
	return plan and plan[self:SlotKey(groupIndex, slotIndex)] or nil
end

function Raid:SetAssignment(groupIndex, slotIndex, player)
	if not self:RequireRaidEditor() then
		return false
	end
	local plan = self:GetPlan(true)
	local key = self:SlotKey(groupIndex, slotIndex)
	plan[key] = player and {
		name = player.name,
		class = player.class,
	} or nil
	if self.BroadcastPlanValue then
		self:BroadcastPlanValue(key, plan[key])
	end
	if self.db.activeEncounter == 1 and player then
		self:PropagateOverviewAssignments()
	end
	self:AutoSaveActiveRaid()
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
	return true
end

local function SemanticSlotKey(slot, groupIndex, slotIndex)
	return slot and slot.id and ("S:" .. slot.id)
	or ("S:group.%d.slot.%d"):format(groupIndex, slotIndex)
end

function Raid:PropagateOverviewAssignments()
	local raid = self:GetRaid()
	local plans = self.simulation.enabled
	and self.simulation.plans or self.db.plans
	local raidPlans = plans[raid.key]
	local overviewPlan = raidPlans and raidPlans[1]
	if not overviewPlan then
		return 0
	end

	local pools = {
		[self.Role.TANK] = {},
		[self.Role.HEALER] = {},
		[self.Role.DAMAGE] = {},
	}
	local pooled = {}
	local overviewByID = {}
	local overview = raid.encounters[1]
	for groupIndex, group in ipairs(overview.groups or {}) do
		for slotIndex, slot in ipairs(group.slots or {}) do
			local assignment = overviewPlan[
			SemanticSlotKey(slot, groupIndex, slotIndex)]
			if assignment then
				local role = slot.role or group.role or self.Role.DAMAGE
				pools[role] = pools[role] or {}
				pools[role][#pools[role] + 1] = assignment
				if assignment.name then
					pooled[assignment.name:lower()] = true
				end
				overviewByID[slot.id] = assignment
			end
		end
	end
	for _, player in ipairs(self.roster or {}) do
		local name = player.name and player.name:lower()
		if name and not pooled[name] then
			local role = player.role or player.reportedRole or self.Role.DAMAGE
			if role == "NONE" or not pools[role] then
				role = self.Role.DAMAGE
			end
			pools[role][#pools[role] + 1] = player
			pooled[name] = true
		end
	end

	local propagated = 0
	for encounterIndex = 2, #raid.encounters do
		local encounter = raid.encounters[encounterIndex]
		raidPlans[encounterIndex] = raidPlans[encounterIndex] or {}
		local plan = raidPlans[encounterIndex]
		for key, assignment in pairs(plan) do
			if type(assignment) == "table" and assignment.propagated then
				plan[key] = nil
			end
		end
		for groupIndex, group in ipairs(self:GetEncounterGroups(
			encounter, raid.key, encounterIndex)) do
			local slots = self:GetEncounterGroupSlots(
				groupIndex, encounter, raid.key, encounterIndex)
			for slotIndex, slot in ipairs(slots) do
				local key =
					SemanticSlotKey(slot, groupIndex, slotIndex)
				local assignment = plan[key]
				if assignment and slot.allowedClasses
				and not slot.allowedClasses[assignment.class]
				then
					plan[key] = nil
				end
			end
		end
		local used = {}
		for groupIndex, group in ipairs(self:GetEncounterGroups(
			encounter, raid.key, encounterIndex)) do
			for slotIndex, slot in ipairs(self:GetEncounterGroupSlots(
				groupIndex, encounter, raid.key, encounterIndex))
			do
				local assignment = plan[
					SemanticSlotKey(slot, groupIndex, slotIndex)]
				if assignment and assignment.name and not slot.allowReuse then
					used[assignment.name:lower()] = true
				end
			end
		end
		for key, assignment in pairs(plan) do
			if type(key) == "string"
			and key:match("^S:healer%.raid%.%d+$")
			and type(assignment) == "table" and assignment.name
			then
				used[assignment.name:lower()] = true
			end
		end
		local cursors = {
			[self.Role.TANK] = 1,
			[self.Role.HEALER] = 1,
			[self.Role.DAMAGE] = 1,
		}
		local function IsCompatible(player, role, slot)
			if not player or not player.name then
				return false
			end
			if used[player.name:lower()]
			and not (type(slot) == "table" and slot.allowReuse)
			then
				return false
			end
			if type(slot) == "table" and slot.allowedClasses then
				return slot.allowedClasses[player.class] == true
			end
			return true
		end
		local function NextPlayer(role, preferred, slot)
			local hasRecommendations = type(slot) == "table" and (
				next(slot.recommendedClasses or {}) ~= nil
				or next(slot.recommendedSpecs or {}) ~= nil
				or next(slot.recommendedRoles or {}) ~= nil)
			if preferred and preferred.name
			and IsCompatible(preferred, role, slot)
			and not hasRecommendations
			then
				return preferred
			end
			local pool = pools[role] or {}
			if type(slot) == "table" and slot.recommendedRoles
			and next(slot.recommendedRoles) ~= nil
			then
				pool = {}
				for recommendedRole in pairs(slot.recommendedRoles) do
					for _, player in ipairs(pools[recommendedRole] or {}) do
						pool[#pool + 1] = player
					end
				end
			end
			if hasRecommendations then
				local best, bestScore
				for poolIndex, player in ipairs(pool) do
					if IsCompatible(player, role, slot) then
						local spec = tostring(player.spec or ""):lower()
						local classes = slot.recommendedClasses or {}
						local classBonus = tonumber(classes[player.class]) or 0
						local score = (tonumber(player.gearScore) or 0)
							+ classBonus
						if next(classes) == nil or classBonus > 0 then
							score = score + (tonumber(
								(slot.recommendedSpecs or {})[spec]) or 0)
						end
						score = score - (poolIndex / 1000)
						if not bestScore or score > bestScore then
							best, bestScore = player, score
						end
					end
				end
				return best
			end
			if type(slot) == "table" and slot.allowedClasses then
				for _, player in ipairs(pool) do
					if IsCompatible(player, role, slot) then
						return player
					end
				end
				return nil
			end
			local cursor = cursors[role] or 1
			while pool[cursor]
			and used[pool[cursor].name:lower()]
			do
				cursor = cursor + 1
			end
			cursors[role] = cursor + 1
			return pool[cursor]
		end
		local function Assign(key, role, preferred, slot)
			if plan[key] then
				return
			end
			local player = NextPlayer(role, preferred, slot)
			if not player then
				return
			end
			plan[key] = {
				name = player.name,
				class = player.class,
				propagated = true,
			}
			if type(slot) ~= "table" or not slot.allowReuse then
				used[player.name:lower()] = true
			end
			propagated = propagated + 1
		end
		for groupIndex, group in ipairs(self:GetEncounterGroups(
			encounter, raid.key, encounterIndex)) do
			if group.name ~= "Healing" then
				local slots = self:GetEncounterGroupSlots(
					groupIndex, encounter, raid.key, encounterIndex)
				for slotIndex, slot in ipairs(slots) do
					Assign(
						SemanticSlotKey(slot, groupIndex, slotIndex),
						slot.role or group.role or self.Role.DAMAGE,
						overviewByID[slot.id],
						slot)
				end
			end
		end
		local override = self:GetBossOverride(
			false, raid.key, encounterIndex)
		local healerCount = override and tonumber(override.healers)
		if not healerCount then
			for _, group in ipairs(encounter.groups or {}) do
				if group.role == self.Role.HEALER then
					healerCount = #group.slots
					break
				end
			end
		end
		healerCount = healerCount
		or self:GetRaidComposition(raid.key).healers
		for healerIndex = 1, healerCount do
			Assign(
				"S:healer.raid." .. healerIndex,
				self.Role.HEALER)
		end
	end
	return propagated
end

local function AssignmentRole(group, slot, healingSlot)
	if healingSlot then
		return Raid.Role.HEALER
	end
	return type(slot) == "table" and slot.role
	or group and group.role or Raid.Role.DAMAGE
end

local function AssignmentClassBonus(class, text)
	text = text:lower()
	local bonus = 0
	local function Has(word) return text:find(word, 1, true)
	end
	if Has("interrupt") then
		bonus = bonus + (({
			ROGUE = 9000, SHAMAN = 8500, MAGE = 7000,
			WARRIOR = 6500, PALADIN = 4000,
		})[class] or 0)
	end
	if Has("kiter") or Has("kite") or Has("range tank") then
		bonus = bonus + (({
			HUNTER = 9000, MAGE = 8000, WARLOCK = 7500,
		})[class] or 0)
	end
	if Has("enslave") then
		bonus = bonus + (class == "WARLOCK" and 20000 or 0)
	end
	if Has("felhunter") then
		bonus = bonus + (class == "WARLOCK" and 20000 or 0)
	end
	if Has("spellsteal") or Has("mage tank") then
		bonus = bonus + (class == "MAGE" and 20000 or 0)
	end
	if Has("polymorph") then
		bonus = bonus + (class == "MAGE" and 20000 or 0)
	end
	if Has("sheep") then
		bonus = bonus + (class == "MAGE" and 20000 or 0)
	end
	if Has("mind control") then
		bonus = bonus + (class == "PRIEST" and 20000 or 0)
	end
	if Has("tranq") then
		bonus = bonus + (class == "HUNTER" and 20000 or 0)
	end
	if Has("blessing") then
		bonus = bonus + (class == "PALADIN" and 18000 or 0)
	end
	if Has("fear ward") then
		bonus = bonus + (class == "PRIEST" and 16000 or 0)
	end
	if Has("purge") then
		bonus = bonus + (class == "SHAMAN" and 18000 or 0)
	end
	if Has("decurse") or Has("curse dispel") then
		bonus = bonus + (({
			MAGE = 12000, DRUID = 12000,
		})[class] or 0)
	end
	if Has("poison") then
		bonus = bonus + (({
			SHAMAN = 10000, DRUID = 10000, PALADIN = 9000,
		})[class] or 0)
	end
	if Has("disease") then
		bonus = bonus + (({
			PRIEST = 10000, PALADIN = 10000, SHAMAN = 9000,
		})[class] or 0)
	end
	if Has("dispel") then
		bonus = bonus + (({
			PRIEST = 8000, PALADIN = 7000, SHAMAN = 6500,
		})[class] or 0)
	end
	if Has("crowd control") or Has(" cc") then
		bonus = bonus + (({
			MAGE = 8000, HUNTER = 7000, WARLOCK = 6500,
			ROGUE = 6000,
		})[class] or 0)
	end
	if Has("aoe") then
		bonus = bonus + (({
			MAGE = 7000, WARLOCK = 6500, PALADIN = 5000,
		})[class] or 0)
	end
	return bonus
end

function Raid:AddBossCustomGroup(name)
	if not self:RequireRaidEditor() then return false end
	name = strtrim((name or ""):gsub("[%c]", " "))
	if name == "" then return false end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	local override = self:GetBossOverride(true)
	override.customGroups = override.customGroups or {}
	local stamp = GetServerTime and GetServerTime() or time()
	self.customGroupSequence = (self.customGroupSequence or 0) + 1
	local custom = {
		id = tostring(stamp) .. "-" .. self.customGroupSequence,
		name = name, count = 1,
	}
	override.customGroups[#override.customGroups + 1] = custom
	local groupIndex = #raid.encounters[encounterIndex].groups
		+ #override.customGroups
	override.groups[groupIndex] = 1
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("BOSSCUSTOM", {
			raid.key, encounterIndex, custom.id, custom.name, 1,
		})
	end
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshAssignments then self:RefreshAssignments() end
	return true
end

function Raid:RemoveBossCustomGroup(groupIndex)
	if not self:RequireRaidEditor() then return false end
	local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
	local override = self:GetBossOverride(true)
	local customIndex = groupIndex
		- #raid.encounters[encounterIndex].groups
	local custom = override.customGroups and override.customGroups[customIndex]
	if not custom then return false end
	table.remove(override.customGroups, customIndex)
	local rebuilt = {}
	for index, count in pairs(override.groups or {}) do
		if index < groupIndex then rebuilt[index] = count
		elseif index > groupIndex then rebuilt[index - 1] = count end
	end
	override.groups = rebuilt
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("BOSSCUSTOMDEL", {
			raid.key, encounterIndex, custom.id,
		})
	end
	self:PersistRaidConfiguration(raid.key)
	if self.RefreshAssignments then self:RefreshAssignments() end
	return true
end

local function AssignmentRecommendationBonus(player, slot)
	if type(slot) ~= "table" then return 0 end
	local classes = slot.recommendedClasses or {}
	local classBonus = tonumber(classes[player.class]) or 0
	local bonus = classBonus
	local spec = tostring(player.spec or ""):lower()
	if spec ~= "" and spec ~= "unknown"
	and (next(classes) == nil or classBonus > 0)
	then
		bonus = bonus + (slot.recommendedSpecs
			and tonumber(slot.recommendedSpecs[spec]) or 0)
	end
	return bonus
end

function Raid:GetAssignedPlayerNames()
	local used, plan = {}, self:GetPlan(false) or {}
	local encounter = self:GetEncounter()
	for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
		for slotIndex, slot in ipairs(self:GetEncounterGroupSlots(
			groupIndex, encounter)) do
			local assignment = plan[self:SlotKey(groupIndex, slotIndex)]
			if assignment and assignment.name and not slot.allowReuse then
				used[assignment.name:lower()] = true
			end
		end
	end
	for slotIndex = 1, self:GetHealingSlotCount() do
		local assignment = plan[self:HealingPlayerKey(slotIndex)]
		if assignment and assignment.name then
			used[assignment.name:lower()] = true
		end
	end
	return used
end

function Raid:SuggestPlayer(group, slot, used, healingSlot)
	local wantedRole = AssignmentRole(group, slot, healingSlot)
	local text = (group and group.name or "") .. " " .. SlotLabel(slot)
	local bestPlayer, bestScore
	for rosterIndex, player in ipairs(self.roster or {}) do
		local playerRole = player.role or player.reportedRole or "NONE"
		local roleAllowed = playerRole == wantedRole
			or type(slot) == "table"
				and slot.recommendedRoles
				and slot.recommendedRoles[playerRole]
		local classAllowed = type(slot) ~= "table"
		or not slot.allowedClasses
		or slot.allowedClasses[player.class]
		local available = not used[player.name and player.name:lower() or ""]
			or type(slot) == "table" and slot.allowReuse
		if player.name and roleAllowed
		and classAllowed
		and available
		then
			local score = AssignmentRecommendationBonus(player, slot)
			+ AssignmentClassBonus(player.class, text)
			+ (tonumber(player.gearScore) or 0)
			- (rosterIndex / 1000)
			if not bestScore or score > bestScore then
				bestPlayer, bestScore = player, score
			end
		end
	end
	return bestPlayer
end

function Raid:SuggestAssignment(groupIndex, slotIndex, healingSlotIndex)
	if not self:RequireRaidEditor() then
		return
	end
	local encounter = self:GetEncounter()
	local used = self:GetAssignedPlayerNames()
	local player
	if healingSlotIndex then
		local definition = self:GetHealingSlotDefinition(healingSlotIndex)
		player = self:SuggestPlayer(
			{ name = "Healing", role = self.Role.HEALER },
			definition or self.Assignment:Healer(
				self.AssignmentTarget.RAID, healingSlotIndex, "Healer"),
			used, true)
		if player then
			self:SetHealingAssignment(healingSlotIndex, player)
		end
	else
		local group = encounter.groups[groupIndex]
		local slots = group
		and self:GetEncounterGroupSlots(groupIndex, encounter)
		local label = slots and slots[slotIndex]
		player = group and self:SuggestPlayer(
			group, label, used, false)
		if player then
			self:SetAssignment(groupIndex, slotIndex, player)
		end
	end
	if not player then
		self:Print(self.L.NO_UNUSED_RAID_MEMBER)
	end
	return player
end

function Raid:AutoAssignEncounter()
	if not self:RequireRaidEditor() then
		return
	end
	local encounter = self:GetEncounter()
	local plan = self:GetPlan(true)
	local used = self:GetAssignedPlayerNames()
	local assigned = 0
	for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
		local include = encounter.name == "Raid Overview"
		or group.name ~= "Healing"
		if include then
			for slotIndex, label in ipairs(
				self:GetEncounterGroupSlots(groupIndex, encounter)) do
				local key = self:SlotKey(groupIndex, slotIndex)
				local current = plan[key]
				if current and type(label) == "table"
				and label.allowedClasses
				and not label.allowedClasses[current.class]
				then
					if current.name then
						used[current.name:lower()] = nil
					end
					plan[key] = nil
				end
				if not plan[key] then
					local player = self:SuggestPlayer(
						group, label, used, false)
					if player then
						plan[key] = {
							name = player.name, class = player.class,
						}
						if type(label) ~= "table" or not label.allowReuse then
							used[player.name:lower()] = true
						end
						assigned = assigned + 1
					end
				end
			end
		end
	end
	if encounter.name ~= "Raid Overview" then
		for slotIndex = 1, self:GetHealingSlotCount() do
			local key = self:HealingPlayerKey(slotIndex)
			if not plan[key] then
				local definition = self:GetHealingSlotDefinition(slotIndex)
				local player = self:SuggestPlayer(
					{ name = "Healing", role = self.Role.HEALER },
					definition or self.Assignment:Healer(
						self.AssignmentTarget.RAID, slotIndex, "Healer"),
					used, true)
				if player then
					plan[key] = {
						name = player.name, class = player.class,
					}
					used[player.name:lower()] = true
					assigned = assigned + 1
				end
			end
		end
	end
	if encounter.name == "Raid Overview" then
		assigned = assigned + self:PropagateOverviewAssignments()
	end
	if assigned > 0 then
		if encounter.name == "Raid Overview"
		and self.SendRaidPlanSnapshots
		then
			self:SendRaidPlanSnapshots()
		elseif self.SendPlanSnapshot then
			self:SendPlanSnapshot()
		end
	end
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
	if encounter.name == "Raid Overview" then
		self:Print(self:Localize(
			assigned == 1 and "AUTO_ASSIGNED_RAID_ONE"
				or "AUTO_ASSIGNED_RAID_MANY", assigned))
	else
		self:Print(self:Localize(
			assigned == 1 and "AUTO_ASSIGNED_ONE"
				or "AUTO_ASSIGNED_MANY", assigned))
	end
end

function Raid:GetHealingTargets()
	local encounter = self:GetEncounter()
	local targets = {}
	for groupIndex, group in ipairs(encounter.groups) do
		if group.name == "Tanks" then
			for slotIndex, slot in ipairs(
				self:GetEncounterGroupSlots(groupIndex, encounter)) do
				targets[#targets + 1] = {
					name = SlotLabel(slot),
					id = slot.id,
					groupIndex = groupIndex,
					slotIndex = slotIndex,
				}
			end
			break
		end
	end
	targets[#targets + 1] = {
		name = "Raid",
	}
	return targets
end

function Raid:GetHealingSlotCount()
	local encounter = self:GetEncounter()
	if encounter.name ~= "Raid Overview" then
		local override = self:GetBossOverride(false)
		if override and tonumber(override.healers) then
			return math.max(0, math.floor(override.healers))
		end
		for _, group in ipairs(encounter.groups or {}) do
			if group.role == self.Role.HEALER then
				return #group.slots
			end
		end
	end
	return self:GetRaidComposition(self:GetRaid().key).healers
end

function Raid:GetHealingSlotDefinition(slotIndex)
	local encounter = self:GetEncounter()
	if encounter.name == "Raid Overview" then return nil end
	for _, group in ipairs(encounter.groups or {}) do
		if group.role == self.Role.HEALER then
			return group.slots and group.slots[slotIndex] or nil
		end
	end
end

function Raid:GetHealingTargetLabel(target)
	if not target then
		return "Unknown target"
	end
	if target.groupIndex and target.slotIndex then
		local tank = self:GetAssignment(
			target.groupIndex, target.slotIndex)
		if tank and tank.name then
			return ("%s (%s)"):format(target.name, tank.name)
		end
	end
	return target.name
end

function Raid:HealingPlayerKey(slotIndex)
	return "S:healer.raid." .. tostring(slotIndex)
end

function Raid:HealingTargetKey(slotIndex)
	return "T:healer.raid." .. tostring(slotIndex)
end

function Raid:GetHealingAssignment(slotIndex)
	local plan = self:GetPlan(false)
	return plan
	and plan[self:HealingPlayerKey(slotIndex)] or nil
end

function Raid:SetHealingAssignment(slotIndex, player)
	if not self:RequireRaidEditor() then
		return false
	end
	local plan = self:GetPlan(true)
	plan[self:HealingPlayerKey(slotIndex)] =
		player and {
			name = player.name,
			class = player.class,
		} or nil
	if self.BroadcastPlanValue then
		self:BroadcastPlanValue(
			self:HealingPlayerKey(slotIndex),
			plan[self:HealingPlayerKey(slotIndex)])
	end
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
	return true
end

function Raid:GetHealingTargetIndex(slotIndex)
	local targets = self:GetHealingTargets()
	local plan = self:GetPlan(false)
	local index = plan
	and tonumber(plan[self:HealingTargetKey(slotIndex)])
	if not index then
		local definition = self:GetHealingSlotDefinition(slotIndex)
		if definition and definition.targetLabel then
			for targetIndex, target in ipairs(targets) do
				if target.name == definition.targetLabel then
					index = targetIndex
					break
				end
			end
		elseif definition
			and definition.target == self.AssignmentTarget.MAIN_TANK
		then
			index = 1
		elseif definition
			and definition.target == self.AssignmentTarget.OFF_TANK
		then
			index = math.min(2, math.max(1, #targets - 1))
		elseif definition
			and definition.target == self.AssignmentTarget.TANKS
		then
			index = math.min(slotIndex, math.max(1, #targets - 1))
		end
	end
	self:AutoSaveActiveRaid()
	return math.max(1, math.min(index or #targets, #targets))
end

function Raid:CycleHealingTarget(slotIndex)
	if not self:RequireRaidEditor() then
		return
	end
	local targets = self:GetHealingTargets()
	local index = self:GetHealingTargetIndex(slotIndex) + 1
	if index > #targets then
		index = 1
	end
	self:GetPlan(true)[self:HealingTargetKey(slotIndex)] = index
	if self.BroadcastPlanValue then
		self:BroadcastPlanValue(self:HealingTargetKey(slotIndex), index)
	end
	self:AutoSaveActiveRaid()
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:GetEncounterTargets()
	local encounter = self:GetEncounter()
	if encounter.targets and #encounter.targets > 0 then
		return encounter.targets
	end
	if encounter.name == "Raid Overview" then
		return {
			"Kill First", "Kill Second", "Kill Third",
			"Crowd Control", "Off-Tank", "Interrupt Focus",
			"Dispel / Purge", "Do Not Attack",
		}
	end
	return { encounter.name }
end

function Raid:GetDefaultMarkerAssignment(targetIndex, encounter)
	encounter = encounter or self:GetEncounter()
	local configured = encounter.defaultMarkers
	and encounter.defaultMarkers[targetIndex]
	if configured == false or configured == 0 then
		return nil
	end
	configured = tonumber(configured)
	if configured and self.markers[configured] then
		return configured
	end
	return targetIndex <= #self.markers and targetIndex or nil
end

function Raid:GetMarkerAssignment(targetIndex, plan, encounter)
	if plan == nil then
		plan = self:GetPlan(false)
	end
	local key = "M:" .. targetIndex
	if plan and plan[key] ~= nil then
		if plan[key] == false or plan[key] == 0 then
			return nil
		end
		return tonumber(plan[key])
	end
	return self:GetDefaultMarkerAssignment(targetIndex, encounter)
end

function Raid:GetMarkerChatToken(markerIndex)
	local marker = self.markers[tonumber(markerIndex)]
	return marker and ("{rt" .. marker.icon .. "}") or ""
end

function Raid:FormatMarkerTokensForLocalDisplay(text)
	return tostring(text or ""):gsub("{rt([1-8])}", function(icon)
		return ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t")
		:format(icon)
	end)
end

function Raid:GetMarkedTargetEntries()
	local entries = {}
	for targetIndex, targetName in ipairs(self:GetEncounterTargets()) do
		local markerIndex = self:GetMarkerAssignment(targetIndex)
		if markerIndex and self.markers[markerIndex] then
			entries[#entries + 1] =
				self:GetMarkerChatToken(markerIndex) .. " " .. targetName
		end
	end
	return entries
end

function Raid:GetMarkerTokenForText(text, allowSingleTargetFallback)
	text = tostring(text or ""):lower()
	local wordsInText = {}
	for word in text:gmatch("[%a']+") do
		wordsInText[word] = true
	end
	for markerIndex, marker in ipairs(self.markers or {}) do
		local markerName = marker.name and marker.name:lower()
		if markerName and (wordsInText[markerName]
		or markerName == "cross" and wordsInText.x)
		then
			return self:GetMarkerChatToken(markerIndex)
		end
	end
	local ignoredWords = {
		the = true, high = true, grand = true, lord = true,
		lady = true, king = true, tank = true, healer = true,
	}
	local targets = self:GetEncounterTargets()
	for targetIndex, targetName in ipairs(targets) do
		local markerIndex = self:GetMarkerAssignment(targetIndex)
		if markerIndex then
			for word in targetName:lower():gmatch("[%a']+") do
				if #word >= 3 and not ignoredWords[word]
				and wordsInText[word]
				then
					return self:GetMarkerChatToken(markerIndex)
				end
			end
		end
	end
	if #targets == 1 and allowSingleTargetFallback ~= false then
		return self:GetMarkerChatToken(
			self:GetMarkerAssignment(1))
	end
	return ""
end

function Raid:SetMarkerAssignment(targetIndex, markerIndex)
	if not self:RequireRaidEditor() then
		return false
	end
	local plan = self:GetPlan(true)
	if markerIndex then
		for index = 1, #self:GetEncounterTargets() do
			if index ~= targetIndex
			and self:GetMarkerAssignment(index) == markerIndex
			then
				return false
			end
		end
	end
	local storedValue = markerIndex
	if not markerIndex
	and self:GetDefaultMarkerAssignment(targetIndex)
	then
		storedValue = false
	end
	plan["M:" .. targetIndex] = storedValue
	if self.BroadcastPlanValue then
		self:BroadcastPlanValue("M:" .. targetIndex, storedValue)
	end
	self:AutoSaveActiveRaid()
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
	self:ApplyAutoMarkers()
	return true
end

function Raid:CycleMarkerAssignment(targetIndex)
	local current = self:GetMarkerAssignment(targetIndex) or 0
	for offset = 1, #self.markers do
		local markerIndex =
			((current + offset - 1) % #self.markers) + 1
		local available = true
		for index = 1, #self:GetEncounterTargets() do
			if index ~= targetIndex
			and self:GetMarkerAssignment(index) == markerIndex
			then
				available = false
				break
			end
		end
		if available then
			self:SetMarkerAssignment(targetIndex, markerIndex)
			return
		end
	end
end

function Raid:AutoAssignMarkers()
	if not self:RequireRaidEditor() then
		return
	end
	local targets = self:GetEncounterTargets()
	if #targets == 0 then
		return
	end
	local plan = self:GetPlan(true)
	for index = 1, #targets do
		plan["M:" .. index] =
			self:GetDefaultMarkerAssignment(index)
	end
	if self.SendPlanSnapshot then
		self:SendPlanSnapshot()
	end
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:IsAutoMarkerEnabled()
	if self.db.autoMarkerEnabled == nil then
		local enabled = false
		for _, raidPlans in pairs(self.db.plans or {}) do
			for _, plan in pairs(raidPlans or {}) do
				if type(plan) == "table" and plan.AUTO_MARK == true then
					enabled = true
					break
				end
			end
			if enabled then break end
		end
		self.db.autoMarkerEnabled = enabled
	end
	return self.db.autoMarkerEnabled == true
end

function Raid:ToggleAutoMarker()
	if not self:RequireRaidEditor() then
		return
	end
	self.db.autoMarkerEnabled = not self:IsAutoMarkerEnabled()
	local plan = self:GetPlan(true)
	if self.db.autoMarkerEnabled then
		local targets = self:GetEncounterTargets()
		for index = 1, #targets do
			plan["M:" .. index] =
				self:GetDefaultMarkerAssignment(index)
		end
		self:ApplyAutoMarkers()
	end
	if self.SendPlanSnapshot then
		self:SendPlanSnapshot()
	end
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

local AUTO_MARKER_UNITS = {
	"target", "focus", "mouseover",
	"boss1", "boss2", "boss3", "boss4", "boss5",
	"boss6", "boss7", "boss8", "boss9", "boss10",
}

local AUTO_MARKER_EVENT_UNIT = {
	PLAYER_TARGET_CHANGED = "target",
	PLAYER_FOCUS_CHANGED = "focus",
	UPDATE_MOUSEOVER_UNIT = "mouseover",
}

function Raid:ApplyAutoMarkers(event)
	if self.simulation.enabled or not self:IsAutoMarkerEnabled()
	or type(SetRaidTarget) ~= "function"
	then
		return
	end
	local targets = self:GetEncounterTargets()
	local byName = {}
	for index, name in ipairs(targets) do
		byName[name] = index
	end
	local changedUnit = AUTO_MARKER_EVENT_UNIT[event]
	local first, last = 1, #AUTO_MARKER_UNITS
	if changedUnit then
		first, last = 1, 1
	end
	for index = first, last do
		local unit = changedUnit or AUTO_MARKER_UNITS[index]
		if UnitExists(unit) and not UnitIsFriend("player", unit) then
			local name = UnitName(unit)
			local targetIndex = name and byName[name]
			local markerIndex =
				targetIndex and self:GetMarkerAssignment(targetIndex)
			local marker = markerIndex and self.markers[markerIndex]
			if marker and (
			not GetRaidTargetIndex
			or GetRaidTargetIndex(unit) ~= marker.icon
			) then
				pcall(SetRaidTarget, unit, marker.icon)
			elseif not marker and GetRaidTargetIndex
			and GetRaidTargetIndex(unit)
			then
				pcall(SetRaidTarget, unit, 0)
			end
		end
	end
end

function Raid:ClearPlan()
	if not self:RequireRaidEditor() then
		return
	end
	local raid = self:GetRaid()
	local _, encounterIndex = self:GetEncounter()
	local plans = self.simulation.enabled
	and self.simulation.plans or self.db.plans
	if plans[raid.key] then
		plans[raid.key][encounterIndex] = nil
	end
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("SNAP_BEGIN", { raid.key, encounterIndex })
		self:QueueSync("SNAP_END", { raid.key, encounterIndex })
	end
	self:AutoSaveActiveRaid()
	if self.RefreshAssignments then
		self:RefreshAssignments()
	end
end

function Raid:CanStartRaid()
	if IsInRaid and IsInRaid() then
		return self:IsActualRaidLeader()
	end
	if self.simulation.enabled then
		return true
	end
	return true
end

function Raid:CompleteRaid()
	if not self.db.raidLocked then
		self:Print(self.L.NO_ACTIVE_RAID)
		return false
	end
	if not self:CanStartRaid() then
		self:Print(self.L.ONLY_LEADER_COMPLETE)
		return false
	end
	local raid = self:GetRaid()
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("CLOSE", { raid.key })
	end
	self.db.raidLocked = false
	self.db.activeSavedRaid = nil
	self.selectedPlayer = nil
	self.dragPlayer = nil
	if self.HideDragGhost then
		self:HideDragGhost()
	end
	if self.RefreshPersonalAssignments then
		self:RefreshPersonalAssignments()
	end
	if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
	if self.RefreshQuickActionBar then
		self:RefreshQuickActionBar()
	end
	if self.ShowNewRaidWizard then
		self:ShowNewRaidWizard()
	end
	self:Print(self:Localize("RAID_COMPLETED", raid.name))
	return true
end

function Raid:ClearCurrentRaidSession()
	local raid = self:GetRaid()
	if self.db.raidLocked and self.QueueSync
	and self:IsLocalRaidEditor()
	then
		self:QueueSync("CLOSE", { raid.key })
	end
	self.db.plans[raid.key] = nil
	self.db.bossOverrides[raid.key] = nil
	self.db.raidCompositions[raid.key] = nil
	self.db.manualPlayers[raid.key] = nil
	if self.simulation and self.simulation.plans then
		self.simulation.plans[raid.key] = nil
	end
	self.db.raidLocked = false
	self.db.activeSavedRaid = nil
	self.selectedPlayer = nil
	self.dragPlayer = nil
	self.roster = {}
	self.remoteSimulationRoster = nil
	wipe(self.messageQueue)
	if self.messageFrame then
		self.messageFrame:Hide()
	end
	if self.HideDragGhost then
		self:HideDragGhost()
	end
	if self.RefreshPersonalAssignments then
		self:RefreshPersonalAssignments()
	end
	if self.RefreshQuickActionBar then
		self:RefreshQuickActionBar()
	end
end

function Raid:BeginRaid(raidKey)
	if not self:CanStartRaid() then
		self:Print(self.L.ONLY_LEADER_START)
		return false
	end
	local raid = self.raidByKey[raidKey]
	if not raid then
		return false
	end
	self.raidSelectionUnlocked = true
	self.db.activeRaid = raid.key
	self.db.activeExpansion = raid.expansion
	self.raidSelectionUnlocked = nil
	local plans = self.simulation.enabled
	and self.simulation.plans or self.db.plans
	plans[raid.key] = {}
	local configuration = self.db.raidConfigurationDefaults
		and self.db.raidConfigurationDefaults[raid.key]
	self.db.bossOverrides[raid.key] =
		Copy(configuration and configuration.bossOverrides or {})
	if configuration and configuration.bossPresets then
		self.db.bossPresets[raid.key] =
			Copy(configuration.bossPresets)
	end
	self.db.manualPlayers[raid.key] = {}
	local firstBoss = #raid.encounters >= 2 and 2 or 1
	self.db.currentBossByRaid[raid.key] =
		firstBoss >= 2 and firstBoss or nil
	if self.QueueSync and self:IsLocalRaidEditor() then
		self:QueueSync("RESET", { raid.key })
	end
	self.db.activeEncounter = firstBoss
	self.db.raidLocked = true
	self.db.activeSavedRaid = nil
	self.db.lastRaidByExpansion[raid.expansion] = raid.key
	self.db.lastEncounterByRaid[raid.key] = firstBoss
	self.selectedPlayer = nil
	self.dragPlayer = nil
	if self.assignmentScroll then
		self.assignmentScroll:SetVerticalScroll(0)
	end
	if self.RefreshAll then
		self:RefreshAll()
	end
	if self.RefreshQuickActionBar then
		self:RefreshQuickActionBar()
	end
	if self.BroadcastSelection then
		self:BroadcastSelection()
	end
	if self.SendPlanSnapshot then
		self:SendPlanSnapshot()
	end
	self:Print(self:Localize("PLAN_STARTED", raid.name))
	return true
end

function Raid:StartNewRaid()
	self:BeginRaid(self.db.activeRaid)
end

function Raid:ConfirmNewRaid()
	if self.ShowNewRaidWizard then
		self:ShowNewRaidWizard()
	end
end

function Raid:AutoSaveActiveRaid()
	local saved = self.db.activeSavedRaid
		and self.db.savedRaids[self.db.activeSavedRaid]
	if not saved or not self.db.raidLocked or self.receivingSync then
		return false
	end
	self:SaveCurrentRaid(saved.name, true)
	return true
end

function Raid:SaveCurrentRaid(name, silent)
	local raid = self:GetRaid()
	name = strtrim(name or "")
	if name == "" then
		name = raid.name .. " Plan"
	end
	local id = self.db.activeSavedRaid
	if not id or not self.db.savedRaids[id] then
		self.savedRaidSequence = (self.savedRaidSequence or 0) + 1
		local stamp = GetServerTime and GetServerTime()
		or time and time() or 0
		id = tostring(stamp)
		.. "-" .. self.savedRaidSequence
	end
	local plans = self.simulation.enabled
	and self.simulation.plans or self.db.plans
	local savedPlayers =
		Copy(self.db.manualPlayers[raid.key] or {})
	if self.simulation.enabled then
		for _, player in ipairs(self.roster or {}) do
			if player.name and player.name ~= "" then
				local role = player.role
				if role ~= "TANK" and role ~= "HEALER"
				and role ~= "DAMAGER"
				then
					role = "DAMAGER"
				end
				savedPlayers[player.name:lower()] = {
					name = player.name,
					class = player.class or "WARRIOR",
					className = player.className
					or classNames[player.class] or "Warrior",
					role = role,
					reportedRole = role,
					spec = player.spec or "",
					race = player.race or "Planned",
					subgroup = tonumber(player.subgroup) or 1,
					manual = true,
					simulated = nil,
				}
			end
		end
	end
	self.db.savedRaids[id] = {
		id = id,
		name = name,
		raidKey = raid.key,
		expansion = raid.expansion,
		savedAt = GetServerTime and GetServerTime()
		or time and time() or 0,
		activeEncounter = self.db.activeEncounter,
		currentBoss = self:GetCurrentBossIndex(raid),
		plans = Copy(plans[raid.key] or {}),
		bossOverrides = Copy(self.db.bossOverrides[raid.key] or {}),
		bossPresets = Copy(self.db.bossPresets[raid.key] or {}),
		raidComposition = Copy(self.db.raidCompositions[raid.key] or {}),
		manualPlayers = savedPlayers,
	}
	self.db.activeSavedRaid = id
	self:PersistRaidConfiguration(raid.key)
	if not silent then
		self:Print(self:Localize("RAID_PLAN_SAVED", name))
	end
	if not silent and self.RefreshNewRaidWizard then
		self:RefreshNewRaidWizard()
	end
end

function Raid:LoadSavedRaid(id)
	if not self:CanStartRaid() then
		self:Print(self.L.ONLY_LEADER_LOAD)
		return false
	end
	local saved = self.db.savedRaids[id]
	local raid = saved and self.raidByKey[saved.raidKey]
	if not raid then
		return false
	end
	self.db.plans[raid.key] = Copy(saved.plans or {})
	if self.simulation.enabled then
		self.simulation.plans = self.simulation.plans or {}
		self.simulation.plans[raid.key] = Copy(saved.plans or {})
	end
	self.db.bossOverrides[raid.key] = Copy(saved.bossOverrides or {})
	self.db.bossPresets[raid.key] = Copy(saved.bossPresets or {})
	self.db.raidCompositions[raid.key] =
		Copy(saved.raidComposition or {})
	self.db.manualPlayers[raid.key] = Copy(saved.manualPlayers or {})
	self.db.activeRaid = raid.key
	self.db.activeExpansion = raid.expansion
	self.db.activeEncounter = math.max(1, math.min(
		tonumber(saved.activeEncounter) or 1, #raid.encounters))
	local savedCurrentBoss = tonumber(saved.currentBoss)
	self.db.currentBossByRaid[raid.key] =
		savedCurrentBoss and savedCurrentBoss >= 2
		and savedCurrentBoss <= #raid.encounters
		and savedCurrentBoss or nil
	self.db.raidLocked = true
	self.db.activeSavedRaid = id
	self:PersistRaidConfiguration(raid.key)
	self.db.lastRaidByExpansion[raid.expansion] = raid.key
	self.db.lastEncounterByRaid[raid.key] = self.db.activeEncounter
	self:ApplyRaidComposition(raid)
	self:UpdateRoster()
	if self.RefreshAll then
		self:RefreshAll()
	end
	if self.RefreshQuickActionBar then
		self:RefreshQuickActionBar()
	end
	if self.BroadcastSelection then
		self:BroadcastSelection()
	end
	if self.SendPlanSnapshot then
		self:SendPlanSnapshot()
	end
	self:Print(self:Localize("RAID_PLAN_LOADED", saved.name))
	return true
end

function Raid:DeleteSavedRaid(id)
	local saved = id and self.db.savedRaids[id]
	if not saved then
		return false
	end
	local name = saved.name or "Saved Raid"
	self.db.savedRaids[id] = nil
	if self.db.activeSavedRaid == id then
		self.db.activeSavedRaid = nil
	end
	if self.RefreshNewRaidWizard then
		self:RefreshNewRaidWizard()
	end
	self:Print(self:Localize("RAID_PLAN_DELETED", name))
	return true
end

function Raid:SetRaid(key)
	if self.db.raidLocked and not self.raidSelectionUnlocked then
		self:Print(self.L.USE_NEW_RAID_CHANGE_RAID)
		return
	end
	if not self.raidByKey[key] then
		return
	end
	self.db.activeRaid = key
	self.db.activeExpansion = self.raidByKey[key].expansion
	self.db.lastRaidByExpansion[self.db.activeExpansion] = key
	self.db.activeEncounter =
		self.db.lastEncounterByRaid[key] or 1
	if self.assignmentScroll then
		self.assignmentScroll:SetVerticalScroll(0)
	end
	if self.RefreshAll then
		self:RefreshAll()
	end
end

function Raid:SetExpansion(key)
	if self.db.raidLocked and not self.raidSelectionUnlocked then
		self:Print(self.L.USE_NEW_RAID_CHANGE_EXPANSION)
		return
	end
	local valid
	for _, expansion in ipairs(self.expansions) do
		if expansion.key == key then
			valid = true break
		end
	end
	if not valid then
		return
	end
	self.db.activeExpansion = key
	local raids = self:GetRaidsForExpansion()
	if #raids == 0 then
		return
	end
	local remembered = self.db.lastRaidByExpansion[key]
	local rememberedRaid = remembered and self.raidByKey[remembered]
	if not rememberedRaid or rememberedRaid.expansion ~= key then
		rememberedRaid = raids[1]
	end
	self.db.activeRaid = rememberedRaid.key
	self.db.lastRaidByExpansion[key] = rememberedRaid.key
	self.db.activeEncounter =
		self.db.lastEncounterByRaid[rememberedRaid.key] or 1
	if self.assignmentScroll then
		self.assignmentScroll:SetVerticalScroll(0)
	end
	if self.RefreshAll then
		self:RefreshAll()
	end
end

function Raid:SetEncounter(index)
	local raid = self:GetRaid()
	self.db.activeEncounter =
		math.max(1, math.min(tonumber(index) or 1, #raid.encounters))
	self.db.lastEncounterByRaid[raid.key] =
		self.db.activeEncounter
	self:AutoSaveActiveRaid()
	if self.assignmentScroll then
		self.assignmentScroll:SetVerticalScroll(0)
	end
	if self.RefreshAll then
		self:RefreshAll()
	end
end

function Raid:GetCurrentBossIndex(raid)
	raid = raid or self:GetRaid()
	local index = tonumber(
		self.db.currentBossByRaid
		and self.db.currentBossByRaid[raid.key])
	if not index or index < 2 or index > #raid.encounters then
		return nil
	end
	return index
end

function Raid:SetCurrentBoss(index, fromSync)
	local raid = self:GetRaid()
	index = math.floor(tonumber(index) or 0)
	if index < 2 or index > #raid.encounters then
		return false
	end
	if not fromSync and not self:RequireRaidEditor() then
		return false
	end
	self.db.currentBossByRaid = self.db.currentBossByRaid or {}
	self.db.currentBossByRaid[raid.key] = index
	if not fromSync and self.QueueSync then
		self:QueueSync("CURRENT", { raid.key, index })
	end
	if not fromSync then self:AutoSaveActiveRaid() end
	if self.RefreshPersonalAssignments then
		self:RefreshPersonalAssignments()
	end
	if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
	if self.RefreshBossRail then
		self:RefreshBossRail()
	end
	if self.RefreshQuickActionBar then
		self:RefreshQuickActionBar()
	end
	return true
end

function Raid:NavigateBoss(direction)
	if not self.db.raidLocked or not self:RequireRaidEditor() then
		return false
	end
	local raid = self:GetRaid()
	local bossCount = #raid.encounters - 1
	if bossCount < 1 then
		return false
	end
	local current = self:GetCurrentBossIndex(raid)
	or tonumber(self.db.activeEncounter) or 2
	if current < 2 or current > #raid.encounters then
		current = 2
	end
	local viewedEncounter = tonumber(self.db.activeEncounter)
	local viewingCurrentBoss = viewedEncounter == current
	direction = tonumber(direction) or 1
	local nextBoss = math.max(
		2, math.min(#raid.encounters, current + direction))
	if nextBoss == current then
		return false
	end
	self:SetCurrentBoss(nextBoss)
	if viewingCurrentBoss then
		self:SetEncounter(nextBoss)
	end
	return true
end

local function NormalizeEncounterName(name)
	name = tostring(name or ""):lower():gsub("[^%w]", "")
	return name:gsub("^the", "")
end

local function EncounterNameMatches(encounter, encounterName)
	local wanted = NormalizeEncounterName(encounterName)
	if NormalizeEncounterName(encounter.name) == wanted then return true end
	for _, alias in ipairs(encounter.encounterNames or {}) do
		if NormalizeEncounterName(alias) == wanted then return true end
	end
	return false
end

function Raid:HandleEncounterStarted(_, encounterID, encounterName)
	self.pendingBossAdvance = nil
	if not self.db.raidLocked or not self:IsLocalRaidEditor() then return end
	encounterID = tonumber(encounterID)
	if not encounterID then return end
	local raid = self:GetRaid()
	local index = self:GetCurrentBossIndex(raid)
	local encounter = index and raid.encounters[index]
	if not encounter or not EncounterNameMatches(encounter, encounterName) then
		return
	end
	self.pendingBossAdvance = {
		raidKey = raid.key,
		index = index,
		encounterID = encounterID,
	}
end

function Raid:HandleEncounterEnded(
	_, encounterID, encounterName, difficultyID, groupSize, success)
	local pending = self.pendingBossAdvance
	self.pendingBossAdvance = nil
	if not pending or tonumber(success) ~= 1
		or tonumber(encounterID) ~= pending.encounterID
		or self.db.activeRaid ~= pending.raidKey
	then
		return
	end
	local raid = self:GetRaid()
	if self:GetCurrentBossIndex(raid) ~= pending.index then return end
	self:NavigateBoss(1)
end

function Raid:HandleBossKill(_, encounterID, encounterName)
	if self.pendingBossAdvance then
		self:HandleEncounterEnded(
			"BOSS_KILL", encounterID, encounterName, nil, nil, 1)
		return
	end
	if not self.db.raidLocked or not self:IsLocalRaidEditor() then return end
	local raid = self:GetRaid()
	local index = self:GetCurrentBossIndex(raid)
	local encounter = index and raid.encounters[index]
	if not encounter or not EncounterNameMatches(encounter, encounterName) then
		return
	end
	self:NavigateBoss(1)
end

