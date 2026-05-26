--
-- **LibCompat-1.0** provides few handy functions that can be embed to addons.
-- This library was originally created for Skada as of 1.8.50.
-- @author: Kader B (https://github.com/bkader/LibCompat-1.0)
--

local MAJOR, MINOR = "LibCompat-1.0-Skada", 43
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.embeds = lib.embeds or {}
lib.EmptyFunc = Multibar_EmptyFunc

local _G, pairs, type, max = _G, pairs, type, math.max
local setmetatable, rawset = setmetatable, rawset
local format, tonumber = format or string.format, tonumber
local _

local Dispatch
local GetUnitIdFromGUID

-------------------------------------------------------------------------------

local Units
do
	-- solo, group, pets and targets
	local solo = {"player", "pet"}
	local group = {player = true}
	local grouppet = {playerpet = true}
	local target = {"target", "targettarget", "pettarget", "pettargettarget", "focus", "focustarget", "mouseover", "mouseovertarget"}

	-- party
	local party = {}
	local partypet = {}
	for i = 1, 4 do
		local unit = format("party%d", i)
		party[i] = unit
		group[unit] = true

		unit = format("partypet%d", i)
		partypet[i] = unit
		grouppet[unit] = true

		target[#target + 1] = format("party%dtarget", i)
		target[#target + 1] = format("partypet%dtarget", i)
	end

	-- raid
	local raid = {}
	local raidpet = {}
	for i = 1, 40 do
		local unit = format("raid%d", i)
		raid[i] = unit
		group[unit] = true

		unit = format("raidpet%d", i)
		raidpet[i] = unit
		grouppet[unit] = true

		target[#target + 1] = format("raid%dtarget", i)
		target[#target + 1] = format("raidpet%dtarget", i)
	end

	-- arena
	local arena = {}
	local arenapet = {}
	for i = 1, 5 do
		arena[i] = format("arena%d", i)
		arenapet[i] = format("arenapet%d", i)
		target[#target + 1] = format("arena%dtarget", i)
		target[#target + 1] = format("arenapet%dtarget", i)
	end

	-- boss
	local boss = {}
	for i = 1, 5 do
		boss[i] = format("boss%d", i)
		target[#target + 1] = format("boss%dtarget", i)
	end

	lib.Units = {
		-- solo and targets
		solo = solo,
		group = group,
		grouppet = grouppet,
		target = target,
		-- party units and pets
		party = party,
		partypet = partypet,
		-- raid units and pets
		raid = raid,
		raidpet = raidpet,
		-- arena units and pets
		arena = arena,
		arenapet = arenapet,
		-- boss units
		boss = boss
	}
	Units = lib.Units
end

-------------------------------------------------------------------------------

do
	local wipe, select, tconcat = wipe, select, table.concat
	local temp = {}
	local function _print(...)
		wipe(temp)
		for i = 1, select("#", ...) do
			temp[#temp + 1] = select(i, ...)
		end
		DEFAULT_CHAT_FRAME:AddMessage(tconcat(temp, " "))
	end

	function Dispatch(func, ...)
		if type(func) ~= "function" then
			_print("\124cffff9900Error\124r: Dispatch requires a function.")
			return
		end
		return func(...)
	end


	local pcall = pcall
	local function QuickDispatch(func, ...)
		if type(func) ~= "function" then return end
		local ok, err = pcall(func, ...)
		if not ok then
			_print("\124cffff9900Error\124r:" .. (err or "<no error given>"))
			return
		end
		return true
	end

	lib.Dispatch = Dispatch
	lib.QuickDispatch = QuickDispatch
end

-------------------------------------------------------------------------------

do
	local UnitExists, UnitAffectingCombat, UnitIsDeadOrGhost = _G.UnitExists, _G.UnitAffectingCombat, _G.UnitIsDeadOrGhost
	local UnitHealth, UnitHealthMax, UnitPower, UnitPowerMax = _G.UnitHealth, _G.UnitHealthMax, _G.UnitPower, _G.UnitPowerMax
	local GetNumRaidMembers, GetNumPartyMembers = _G.GetNumRaidMembers, _G.GetNumPartyMembers

	local IsInRaid = _G.IsInRaid
	if not IsInRaid then
		IsInRaid = function()
			return (GetNumRaidMembers() > 0)
		end
	end

	local IsInGroup = _G.IsInGroup
	if not IsInGroup then
		IsInGroup = function()
			return (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0)
		end
	end

	local GetNumGroupMembers = _G.GetNumGroupMembers
	if not GetNumGroupMembers then
		GetNumGroupMembers = function()
			return IsInRaid() and GetNumRaidMembers() or GetNumPartyMembers()
		end
	end

	local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
	if not GetNumSubgroupMembers then
		GetNumSubgroupMembers = function()
			return GetNumPartyMembers()
		end
	end

	local function GetGroupTypeAndCount()
		if IsInRaid() then
			return "raid", 1, GetNumGroupMembers()
		elseif IsInGroup() then
			return "party", 0, GetNumSubgroupMembers()
		else
			return "solo", 0, 0
		end
	end

	local UnitIterator
	do
		local nmem, step, count

		local function SelfIterator(excPets)
			while step do
				local unit, owner
				if step == 1 then
					unit, owner, step = "player", nil, 2
				elseif step == 2 then
					if not excPets then
						unit, owner = "pet", "player"
					end
					step = nil
				end
				if unit and UnitExists(unit) then
					return unit, owner
				end
			end
		end

		local party = Units.party
		local partypet = Units.partypet
		local function PartyIterator(excPets)
			while step do
				local unit, owner
				if step <= 2 then
					unit, owner = SelfIterator(excPets)
					step = step or 3
				elseif step == 3 then
					unit, owner, step = party[count], nil, 4
				elseif step == 4 then
					if not excPets then
						unit, owner = partypet[count], party[count]
					end
					count = count + 1
					step = count <= nmem and 3 or nil
				end
				if unit and UnitExists(unit) then
					return unit, owner
				end
			end
		end

		local raid = Units.raid
		local raidpet = Units.raidpet
		local function RaidIterator(excPets)
			while step do
				local unit, owner
				if step == 1 then
					unit, owner, step = raid[count], nil, 2
				elseif step == 2 then
					if not excPets then
						unit, owner = raidpet[count], raid[count]
					end
					count = count + 1
					step = count <= nmem and 1 or nil
				end
				if unit and UnitExists(unit) then
					return unit, owner
				end
			end
		end

		function UnitIterator(excPets)
			nmem, step = GetNumGroupMembers(), 1
			if nmem == 0 then
				return SelfIterator, excPets
			end
			count = 1
			if IsInRaid() then
				return RaidIterator, excPets
			end
			return PartyIterator, excPets
		end
	end

	local function IsGroupDead()
		for unit in UnitIterator(true) do
			if not UnitIsDeadOrGhost(unit) then
				return false
			end
		end
		return true
	end

	local function IsGroupInCombat()
		for unit in UnitIterator() do
			if UnitAffectingCombat(unit) then
				return true
			end
		end
		return false
	end

	local function GroupIterator(func, ...)
		for unit, owner in UnitIterator() do
			Dispatch(func, unit, owner, ...)
		end
	end

	do
		local target = Units.target
		function GetUnitIdFromGUID(guid, grouped)
			if not grouped then
				for _, unit in pairs(target) do
					if UnitExists(unit) and UnitGUID(unit) == guid then
						return unit
					end
				end
			end

			for unit in UnitIterator() do
				if UnitGUID(unit) == guid then
					return unit
				end
			end
		end
	end

	local UnitClass = UnitClass
	local function GetClassFromGUID(guid)
		local unit = GetUnitIdFromGUID(guid)
		local class
		if unit and unit:find("pet") then
			class = "PET"
		elseif unit and unit:find("boss") then
			class = "BOSS"
		elseif unit then
			_, class = UnitClass(unit)
		end
		return class, unit
	end

	local GetCreatureId = setmetatable({}, {
		__mode = "kv", -- make it weak
		__index = function(self, guid)
			if guid then
				local id = tonumber(guid:sub(9, 12), 16) or 0
				rawset(self, guid, id) -- cache it
				return id
			end
			return 0
		end,
		__newindex = function(self, guid, id)
			rawset(self, guid, id)
		end,
		__call = function(self, guid)
			return self[guid]
		end
	})

	local unknownUnits = {[_G.UKNOWNBEING] = true, [_G.UNKNOWNOBJECT] = true}

	local function UnitHealthInfo(unit, guid)
		unit = (unit and not unknownUnits[unit] and UnitExists(unit)) and unit or (guid and GetUnitIdFromGUID(guid) or nil)
		if not unit or not UnitExists(unit) then return end

		local health, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
		local percent = (health and maxhealth) and (100 * health / max(1, maxhealth)) or nil
		return percent, health, maxhealth
	end

	local function UnitPowerInfo(unit, guid, powerType)
		unit = (unit and not unknownUnits[unit] and UnitExists(unit)) and unit or (guid and GetUnitIdFromGUID(guid) or nil)
		if not unit or not UnitExists(unit) then return end

		local power, maxpower = UnitPower(unit, powerType), UnitPowerMax(unit, powerType)
		local percent = (power and maxpower) and (100 * power / max(1, maxpower)) or nil
		return percent, power, maxpower
	end

	lib.IsInRaid = IsInRaid
	lib.IsInGroup = IsInGroup
	lib.GetNumGroupMembers = GetNumGroupMembers
	lib.GetNumSubgroupMembers = GetNumSubgroupMembers
	lib.GetGroupTypeAndCount = GetGroupTypeAndCount
	lib.IsGroupDead = IsGroupDead
	lib.IsGroupInCombat = IsGroupInCombat
	lib.GroupIterator = GroupIterator
	lib.UnitIterator = UnitIterator
	lib.GetUnitIdFromGUID = GetUnitIdFromGUID
	lib.GetClassFromGUID = GetClassFromGUID
	lib.GetCreatureId = GetCreatureId
	lib.UnitHealthInfo = UnitHealthInfo
	lib.UnitPowerInfo = UnitPowerInfo
end

-------------------------------------------------------------------------------
-- Specs and Roles

do
	local rawget = rawget
	local MAX_TALENT_TABS = _G.MAX_TALENT_TABS or 3

	local LGT = LibStub("LibGroupTalents-1.0")
	local LGTRoleTable = {melee = "DAMAGER", caster = "DAMAGER", healer = "HEALER", tank = "TANK"}
	local FixRoleTable = {HUNTER = "DAMAGER", MAGE = "DAMAGER", ROGUE = "DAMAGER", WARLOCK = "DAMAGER"}

	-- list of class to specs
	local specsTable = {
		MAGE = {62, 63, 64},
		PRIEST = {256, 257, 258},
		ROGUE = {259, 260, 261},
		WARLOCK = {265, 266, 267},
		WARRIOR = {71, 72, 73},
		PALADIN = {65, 66, 70},
		DEATHKNIGHT = {250, 251, 252},
		DRUID = {102, 103, 104, 105},
		HUNTER = {253, 254, 255},
		SHAMAN = {262, 263, 264}
	}

	-- cached talents
	local cached_talents = setmetatable({}, {__mode = "kv"})

	-- retrieves real spec
	local function CalculateSpec(guid, n1, n2, n3)
		local actor = guid and LGT.roster[guid]
		if not actor or not actor.class or not specsTable[actor.class] then return end

		if not n1 or not n2 or not n3 then
			local talentGroup = LGT:GetActiveTalentGroup(actor.unit)
			_, n1, n2, n3 = LGT:GetGUIDTalentSpec(guid, talentGroup)
		end

		-- LGT can transiently return nil values during roster transitions;
		-- normalize to 0 so format/max logic stays safe.
		n1 = tonumber(n1) or 0
		n2 = tonumber(n2) or 0
		n3 = tonumber(n3) or 0
		rawset(cached_talents, guid, format("%s/%s/%s", n1, n2, n3))

		local nx = max(n1, n2, n3) -- highest in points spent
		if nx == 0 then -- no talents spent anywhere?
			return 0
		end

		local index = nx == n1 and 1 or nx == n2 and 2 or nx == n3 and 3
		if actor.class == "DRUID" and index >= 2 then
			index = index == 3 and 4 or actor.role == "tank" and 3 or 2
		end

		return specsTable[actor.class][index] or 0
	end

	-- cached specs
	local GetUnitSpec = setmetatable({}, {
		__index = function(self, guid)
			local spec = CalculateSpec(guid)
			rawset(self, guid, spec)
			return spec
		end,
		__newindex = function(self, guid, spec)
			rawset(self, guid, spec)
		end,
		__call = function(self, guid)
			return self[guid], rawget(cached_talents, guid)
		end
	})

	-- cached roles
	local GetUnitRole = setmetatable({}, {
		__index = function(self, guid)
			local role = LGTRoleTable[LGT:GetGUIDRole(guid)] or "NONE"
			rawset(self, guid, role)
			return role
		end,
		__newindex = function(self, guid, role)
			rawset(self, guid, role)
		end,
		__call = function(self, guid)
			return self[guid]
		end
	})

	LGT:RegisterCallback("LibGroupTalents_Update", function(_, guid, _, _, n1, n2, n3)
		rawset(GetUnitSpec, guid, CalculateSpec(guid, n1, n2, n3))
	end)

	LGT:RegisterCallback("LibGroupTalents_RoleChange", function(_, guid, _, role, oldrole)
		rawset(GetUnitRole, guid, LGTRoleTable[role] or "NONE")
		if oldrole and oldrole ~= role then
			rawset(GetUnitSpec, guid, nil)
		end
	end)

	lib.GetUnitSpec = GetUnitSpec
	lib.GetUnitRole = GetUnitRole
end

-------------------------------------------------------------------------------
-- Pvp

do
	local IsInInstance, instanceType = IsInInstance, nil

	local function IsInPvP()
		_, instanceType = IsInInstance()
		return (instanceType == "pvp" or instanceType == "arena")
	end

	lib.IsInPvP = IsInPvP
end

-------------------------------------------------------------------------------

local mixins = {
	"Units",
	"EmptyFunc",
	"Dispatch",
	"QuickDispatch",
	-- roster util
	"IsInRaid",
	"IsInGroup",
	"IsInPvP",
	"GetNumGroupMembers",
	"GetNumSubgroupMembers",
	"GetGroupTypeAndCount",
	"IsGroupDead",
	"IsGroupInCombat",
	"GroupIterator",
	"UnitIterator",
	-- unit util
	"GetUnitIdFromGUID",
	"GetClassFromGUID",
	"GetCreatureId",
	"UnitHealthInfo",
	"UnitPowerInfo",
	"GetUnitSpec",
	"GetUnitRole"
}

function lib:Embed(target)
	for _, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

for addon in pairs(lib.embeds) do
	lib:Embed(addon)
end
