-- ThemeTWW.lua
-- Skada-WotLK-Netic — "TWW (5Buttons)" skin support.
--
-- The theme itself is registered as `"TWW (5Buttons)"` in
-- Core/Display/Bar.lua's theme list and can be applied to any window
-- through Skada's normal "Window Skins > Themes" panel, like any
-- other theme.
--
-- This module does two extra things:
--   1. Makes the TWW look the default for brand new profiles/windows
--      (mirrors what ThemeDragon.lua does for DragonUI, and — because
--      this file loads after it — takes over as the active default).
--      Existing user profiles are NOT touched.
--   2. Adds the small visual nudge the skin needs at runtime: its bar
--      and header textures are taller than Skada's defaults, so bar
--      labels need to be shifted down a few pixels to stay vertically
--      centered. The offset is applied only to windows currently using
--      the TWW bar texture, and re-evaluated every time settings are
--      applied (theme switch, options change, login), so no extra
--      options or state are needed to keep it in sync.

local _, Skada = ...
if not Skada or not Skada.windowdefaults then return end

local Private = Skada.Private
local pairs = pairs
local hooksecurefunc = hooksecurefunc

-------------------------------------------------------------------------------
-- 1. default look for fresh profiles/windows

do
	local windefs = Skada.windowdefaults

	-- TWW palette (dark, gold titles, taller class-colored bars).
	-- Kept in sync with the "TWW (5Buttons)" entry in
	-- Core/Display/Bar.lua's theme list, so the out-of-the-box look and
	-- the manually-selectable theme produce identical results.
	local C_BAR       = {r = 0.30,   g = 0.30,   b = 0.80,   a = 1.00} -- fallback (classcolorbars overrides per-player)
	local C_BAR_BG    = {r = 0.05,   g = 0.05,   b = 0.05,   a = 0.50}
	local C_BAR_ALT   = {r = 0.45,   g = 0.45,   b = 0.80,   a = 1.00}
	local C_TITLE_TXT = {r = 1.00,   g = 0.82,   b = 0.00,   a = 1.00} -- TWW gold
	local C_TITLE_BRD = {r = 0.00,   g = 0.00,   b = 0.00,   a = 1.00}
	local C_BG        = {r = 0.094,  g = 0.094,  b = 0.094,  a = 0.00} -- fully transparent
	local C_BG_BORDER = {r = 0.00,   g = 0.00,   b = 0.00,   a = 0.00}

	-- Bars
	windefs.bartexture     = "TWW Bar"
	windefs.barfont        = "Friz Quadrata TT"
	windefs.barfontflags   = ""
	windefs.barfontsize    = 11
	windefs.numfont        = "Friz Quadrata TT"
	windefs.numfontflags   = ""
	windefs.numfontsize    = 11
	windefs.barheight      = 28
	windefs.barspacing     = 4
	windefs.barcolor       = C_BAR
	windefs.barbgcolor     = C_BAR_BG
	windefs.baraltcolor    = C_BAR_ALT
	windefs.spellschoolcolors = true
	windefs.classcolorbars    = true
	windefs.classicons        = true
	windefs.specicons         = true
	windefs.buttons = {
		menu = true,
		reset = true,
		report = true,
		mode = true,
		segment = true,
		phase = false,
		split = false,
		stop = false
	}

	-- Title bar
	if windefs.title then
		windefs.title.height         = 32
		windefs.title.font           = "Friz Quadrata TT"
		windefs.title.fontsize       = 13
		windefs.title.fontflags      = ""
		windefs.title.texture        = "TWW Header"
		windefs.title.color          = C_TITLE_TXT
		windefs.title.textcolor      = C_TITLE_TXT
		windefs.title.bordercolor    = C_TITLE_BRD
		windefs.title.bordertexture  = "None"
		windefs.title.borderthickness = 0
		windefs.title.borderinsets   = 0
		windefs.title.spacing        = 1
		windefs.title.toolbar        = 2
		windefs.title.toolbaropacity = 0.25
	end

	-- Window background: fully transparent (TWW style)
	if windefs.background then
		windefs.background.texture        = "Solid"
		windefs.background.color          = C_BG
		windefs.background.bordercolor    = C_BG_BORDER
		windefs.background.bordertexture  = "None"
		windefs.background.borderthickness = 0
		windefs.background.borderinsets   = 0
		windefs.background.tilesize       = 0
	end

	windefs.snapto = true

	-- `Skada.defaults.profile.windows[1]` was deep-copied from
	-- `Skada.windowdefaults` in `Core/Options.lua` BEFORE this module ran,
	-- so AceDB would still seed brand new profiles with whatever look was
	-- set at that point. Refresh that seed copy now so fresh installs get
	-- the TWW look out of the box.
	if Private and Private.tCopy and Skada.defaults
		and Skada.defaults.profile and Skada.defaults.profile.windows
		and Skada.defaults.profile.windows[1]
	then
		for k in pairs(Skada.defaults.profile.windows[1]) do
			Skada.defaults.profile.windows[1][k] = nil
		end
		Private.tCopy(Skada.defaults.profile.windows[1], windefs)
	end
end

-------------------------------------------------------------------------------
-- 2. runtime bar-label offset for the taller TWW bar texture

local TWW_BAR_TEXTURE = "TWW Bar"
local TWW_TEXT_Y_OFFSET = 6

local SLB = LibStub("SpecializedLibBars-1.0", true)
if not SLB then return end

-- extend SpecializedLibBars so bar groups can carry a per-window label offset.
if not SLB.barListPrototype.SetBarTextYOffset then
	local orig = SLB.barPrototype.UpdateOrientationLayout
	local LEFT_TO_RIGHT = 1

	SLB.barPrototype.UpdateOrientationLayout = function(self, orientation)
		orig(self, orientation)
		local offset = self.ownerGroup and self.ownerGroup._textYOffset or 0
		if offset == 0 then return end
		if orientation == LEFT_TO_RIGHT then
			self.timerLabel:SetPoint("RIGHT", self, "RIGHT", -5, offset)
			self.label:SetPoint("LEFT", self, "LEFT", 5, offset)
		else
			self.timerLabel:SetPoint("LEFT", self, "LEFT", 5, offset)
			self.label:SetPoint("RIGHT", self, "RIGHT", -5, offset)
		end
	end

	SLB.barListPrototype.SetBarTextYOffset = function(self, offset)
		offset = offset or 0
		if self._textYOffset == offset then return end
		self._textYOffset = offset
		for _, bar in pairs(self:GetBars()) do
			bar:UpdateOrientationLayout(self.orientation or LEFT_TO_RIGHT)
		end
	end

	local origNewBar = SLB.barListPrototype.NewBar
	SLB.barListPrototype.NewBar = function(self, name, text, value, maxVal, icon)
		local bar, isNew = origNewBar(self, name, text, value, maxVal, icon)
		if self._textYOffset and self._textYOffset ~= 0 then
			bar:UpdateOrientationLayout(self.orientation or LEFT_TO_RIGHT)
		end
		return bar, isNew
	end
end

local function SyncTextOffsets()
	local windows = Skada.windows
	for i = 1, #windows do
		local win = windows[i]
		local bargroup = win and win.bargroup
		if bargroup and bargroup.SetBarTextYOffset then
			local offset = (win.db and win.db.bartexture == TWW_BAR_TEXTURE) and TWW_TEXT_Y_OFFSET or 0
			bargroup:SetBarTextYOffset(offset)
		end
	end
end

hooksecurefunc(Skada, "ApplySettings", SyncTextOffsets)
