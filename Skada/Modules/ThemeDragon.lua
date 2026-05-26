-- ThemeDragon.lua
-- Skada-WotLK-Netic — DragonUI-style visual defaults.
--
-- This module rewrites Skada's `windowdefaults` table in place so any
-- newly-created window inherits a dark, compact, DragonUI-flavoured
-- look. Existing user profiles are NOT touched: anyone already running
-- Skada keeps their per-window settings untouched (the values only
-- apply when a new window is created or the profile is reset).
--
-- This module is intentionally lightweight: no new options panel, no
-- core rewrites, no skin registry. The user can still re-customise
-- everything from Skada's normal window settings.

local _, Skada = ...
if not Skada or not Skada.windowdefaults then return end

local Private = Skada.Private
local windefs = Skada.windowdefaults

-- DragonUI palette (kept close to DragonUI bar/frame style).
local C_BAR        = {r = 0.20, g = 0.55, b = 0.95, a = 1.00} -- accent blue
local C_BAR_BG     = {r = 0.10, g = 0.12, b = 0.16, a = 0.60}
local C_BAR_ALT    = {r = 0.30, g = 0.45, b = 0.80, a = 1.00}
local C_BG         = {r = 0.04, g = 0.06, b = 0.09, a = 0.85}
local C_BG_BORDER  = {r = 0.30, g = 0.40, b = 0.55, a = 0.80}
local C_TITLE_BG   = {r = 0.08, g = 0.10, b = 0.13, a = 0.95}
local C_TITLE_TXT  = {r = 1.00, g = 0.82, b = 0.20, a = 1.00} -- soft gold
local C_TITLE_BRD  = {r = 0.00, g = 0.00, b = 0.00, a = 1.00}

-- Bars
windefs.bartexture     = "Smooth"
windefs.barfont        = "ABF"
windefs.barfontflags   = ""
windefs.barfontsize    = 11
windefs.numfont        = "ABF"
windefs.numfontflags   = ""
windefs.numfontsize    = 11
windefs.barheight      = 16
windefs.barspacing     = 1
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
	windefs.title.height         = 18
	windefs.title.font           = "ABF"
	windefs.title.fontsize       = 12
	windefs.title.fontflags      = ""
	windefs.title.texture        = "Flat"
	windefs.title.color          = C_TITLE_BG
	windefs.title.textcolor      = C_TITLE_TXT
	windefs.title.bordertexture  = "None"
	windefs.title.bordercolor    = C_TITLE_BRD
	windefs.title.borderthickness = 1
	windefs.title.borderinsets   = 0
	windefs.title.spacing        = 1
	windefs.title.toolbar        = 2
	windefs.title.toolbaropacity = 0.25
end

-- Window background
if windefs.background then
	windefs.background.texture        = "Flat"
	windefs.background.color          = C_BG
	windefs.background.bordertexture  = "None"
	windefs.background.bordercolor    = C_BG_BORDER
	windefs.background.borderthickness = 1
	windefs.background.borderinsets   = 0
	windefs.background.tilesize       = 0
	windefs.background.height         = 200
end

-- `Skada.defaults.profile.windows[1]` was deep-copied from
-- `Skada.windowdefaults` in `Core/Options.lua` BEFORE this module ran,
-- so AceDB would still seed brand new profiles with the upstream
-- look. Refresh that seed copy now so fresh installs get the
-- DragonUI look out of the box.
if Private and Private.tCopy and Skada.defaults
	and Skada.defaults.profile and Skada.defaults.profile.windows
	and Skada.defaults.profile.windows[1]
then
	-- wipe and re-copy to avoid leftover references
	for k in pairs(Skada.defaults.profile.windows[1]) do
		Skada.defaults.profile.windows[1][k] = nil
	end
	Private.tCopy(Skada.defaults.profile.windows[1], windefs)
end
