local version = "1.21"
_G.UseUpdater = true

--[[
	Talon - Cutthroat
		Author: Draconis
		Version: 1.21
		Copyright 2015
			
	Dependency: Standalone
--]]

if myHero.charName ~= "Talon" then return end


local REQUIRED_LIBS = {
	["SxOrbwalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#6699FF\">Talon - Cutthroat:</font></b> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		if DOWNLOAD_LIB_NAME ~= "Prodiction" then require(DOWNLOAD_LIB_NAME) end
		if DOWNLOAD_LIB_NAME == "Prodiction" and VIP_USER then require(DOWNLOAD_LIB_NAME) end
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

local UPDATE_NAME = "Talon - Cutthroat"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/DraconisBoL/BoL/master/Talon%20-%20Cutthroat.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<b><font color=\"#6699FF\">"..UPDATE_NAME..":</font></b> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.UseUpdater then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 2)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

------------------------------------------------------
--			 Callbacks				
------------------------------------------------------

function OnLoad()
	print("<b><font color=\"#6699FF\">Talon - Cutthroat:</font></b> <font color=\"#FFFFFF\">Good luck and have fun!</font>")
	Variables()
	Menu()
	PriorityOnLoad()
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	HarassKey = Settings.harass.harassKey
	JungleClearKey = Settings.jungle.jungleKey
	LaneClearKey = Settings.lane.laneKey
	
	if ComboKey then
		Combo(Target)
	end
	
	if HarassKey then
		Harass(Target)
	end
	
	if JungleClearKey then
		JungleClear()
	end
	
	if LaneClearKey then
		LaneClear()
	end
	
	if Settings.ks.killSteal then
		KillSteal()
	end	
	
	Checks()
end

function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
		end
		if SkillW.ready and Settings.drawing.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, RGB(Settings.drawing.wColor[2], Settings.drawing.wColor[3], Settings.drawing.wColor[4]))
		end
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, RGB(Settings.drawing.eColor[2], Settings.drawing.eColor[3], Settings.drawing.eColor[4]))
		end
		if SkillR.ready and Settings.drawing.rDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, RGB(Settings.drawing.rColor[2], Settings.drawing.rColor[3], Settings.drawing.rColor[4]))
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange(), RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
		
		if Settings.drawing.Target and Target ~= nil then
			DrawCircle(Target.x, Target.y, Target.z, 80, ARGB(255, 10, 255, 10))
		end
		
		if Settings.drawing.Text then Calculation() end
	end
end

function OnWndMsg(msg, key)
	if msg == WM_LBUTTONDOWN then
		local enemyDistance, enemySelected = 0, nil
		for _,enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) and GetDistance(enemy, mousePos) < 200 then 
				if GetDistance(enemy, mousePos) <= enemyDistance or not enemySelected then
					enemyDistance = GetDistance(enemy, mousePos)
					enemySelected = enemy
				end
			end
		end
		
		if enemySelected then
			if not targetSelected or targetSelected.hash ~= enemySelected.hash then
				targetSelected = enemySelected
			end
		else
			targetSelected = nil
		end
	end
end

------------------------------------------------------
--			 Functions				
------------------------------------------------------

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.combo.comboMode == 1 then
			if Settings.combo.comboItems then
				UseItems(unit)
			end
			
			CastR(unit)
			if Settings.combo.useE then CastE(unit) end
			if Settings.combo.useW then CastW(unit) end
			if Settings.combo.useQ and IsRebornLoaded() then CastQ(unit) end
		elseif Settings.combo.comboMode == 2 then
			if Settings.combo.comboItems then
				UseItems(unit)
			end
			
			CastR(unit)
			if Settings.combo.useW then CastW(unit) end
			if Settings.combo.useE then CastE(unit) end
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLow("Harass") then
		if Settings.harass.harassMode == 1 then
			if Settings.harass.useW then CastW(unit) end
		elseif Settings.harass.harassMode == 2 then
			if Settings.harass.useE then CastE(unit) end
			if Settings.harass.useW then CastW(unit) end
		end
	end
end

function LaneClear()
	enemyMinions:update()
	if LaneClearKey and not IsMyManaLow("LaneClear") then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if Settings.lane.laneW and GetDistance(minion) <= SkillW.range and SkillW.ready then
					local BestPos, BestHit = GetBestLineFarmPosition(SkillW.range, SkillW.angle, enemyMinions.objects)
						if BestPos ~= nil then
							CastSpell(_W, BestPos.x, BestPos.z)
						end
				end
				
				if Settings.lane.laneQ and GetDistance(minion) <= SkillQ.range and SkillQ.ready then
					CastSpell(_Q)
					myHero:Attack(minion)
				end
				
				if GetDistance(minion) <= Items.TMT.range then CastItem(3074) end
				if GetDistance(minion) <= Items.TMT.range then CastItem(3077) end
			end		 
		end
	end
end

function JungleClear()
	if Settings.jungle.jungleKey and not IsMyManaLow("JungleClear") then
		local JungleMob = GetJungleMob()
		
		if JungleMob ~= nil then
			if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range and SkillQ.ready then
				CastSpell(_Q)
				myHero:Attack(JungleMob)
			end
			if Settings.jungle.jungleW and GetDistance(JungleMob) <= SkillW.range and SkillW.ready then
				CastSpell(_W, JungleMob.x, JungleMob.z)
			end
			if Settings.jungle.jungleE and GetDistance(JungleMob) <= SkillE.range and SkillE.ready then
				CastSpell(_E, JungleMob)
			end
			
			if GetDistance(JungleMob) <= Items.TMT.range then CastItem(3074) end
			if GetDistance(JungleMob) <= Items.TMT.range then CastItem(3077) end
		end
	end
end

function AfterAttack()
	if ComboKey and not Settings.combo.useQ then return end
	if HarassKey and IsMyManaLow("Harass") or not Settings.harass.useQ then return end
	if Target ~= nil and ValidTarget(Target) and Target.type == myHero.type and GetDistance(Target) <= SkillQ.range and SkillQ.ready then
		CastSpell(_Q)
	end
end

function CastQ(unit)
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		CastSpell(_Q)
		myHero:Attack(unit)
	end
end

function CastW(unit)
	if unit ~= nil and GetDistance(unit) <= SkillW.range and SkillW.ready then		
		local mainCastPosition, mainHitChance, maxHit = VP:GetConeAOECastPosition(unit, SkillW.delay, SkillW.angle, SkillW.range, SkillW.speed, myHero)
		
		if mainHitChance >= 2 then
			CastSpell(_W, mainCastPosition.x, mainCastPosition.z)
		end
	end
end

function CastE(unit)
	if unit ~= nil and SkillE.ready and GetDistance(unit) <= SkillE.range then
		CastSpell(_E, unit)
	end
end

function CastR(unit)
	if unit ~= nil and GetDistance(unit) <= (SkillR.range - 100) and SkillR.ready then
		local qDmg = getDmg("Q", unit, myHero)
		local wDmg = getDmg("W", unit, myHero)
		local rDmg = getDmg("R", unit, myHero, 3)
			
		if Settings.combo.useR == 1 then
			if unit.health <= qDmg + wDmg + rDmg then
				CastSpell(_R)
			end
		elseif Settings.combo.useR == 2 then
			if unit.health >= qDmg + wDmg then
				CastSpell(_R)
			end
		elseif Settings.combo.useR == 3 then
			CastSpell(_R)
		end
	end
end

function KillSteal()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero)
			local wDmg = getDmg("W", enemy, myHero)
			
			if enemy.health <= qDmg and GetDistance(enemy) <= SkillQ.range and SkillQ.ready then
				CastQ(enemy)
			elseif enemy.health <= wDmg and GetDistance(enemy) <= SkillW.range and SkillW.ready then
				CastW(enemy)
			elseif enemy.health <= qDmg + wDmg and GetDistance(enemy) <= SkillQ.range and SkillQ.ready and SkillW.ready then
				CastW(enemy)
				CastQ(enemy)
			elseif enemy.health <= qDmg + wDmg and GetDistance(enemy) > SkillQ.range and SkillQ.ready and SkillW.ready and SkillE.ready then
				CastE(enemy)
				CastW(enemy)
				CastQ(enemy)
			end

			if Settings.ks.autoIgnite then
				AutoIgnite(enemy)
			end
		end
	end
end

function Calculation()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero)
			local wDmg = getDmg("W", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero, 3)
			local iDmg = getDmg("IGNITE", enemy, myHero)
			
			if enemy.health <= qDmg and SkillQ.ready then
				DrawText3D(tostring("Killable: Q"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + wDmg) and SkillQ.ready and SkillW.ready then
				DrawText3D(tostring("Killable: Q > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= rDmg and SkillR.ready then
				DrawText3D(tostring("Killable: R"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + rDmg) and SkillR.ready and SkillQ.ready then
				DrawText3D(tostring("Killable: R > Q"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (wDmg + rDmg) and SkillR.ready and SkillQ.ready then
				DrawText3D(tostring("Killable: R > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + rDmg + wDmg) and SkillR.ready and SkillQ.ready and SkillW.ready then
				DrawText3D(tostring("Killable: R > Q > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + rDmg + wDmg + iDmg) and SkillQ.ready and SkillW.ready and SkillR.ready and Ignite.ready then
				DrawText3D(tostring("Killable: R > Q > W > IGNITE"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			end
		end
	end
end

function AutoIgnite(unit)
	if ValidTarget(unit, Ignite.range) and unit.health <= getDmg("IGNITE", unit, myHero) then
		if Ignite.ready then
			CastSpell(Ignite.slot, unit)
		end
	end
end

------------------------------------------------------
--			 Checks, menu & stuff				
------------------------------------------------------

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	
	Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
	
	Target = GetCustomTarget()
	
	if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function IsMyManaLow(mode)
	if mode == "Harass" then
		if myHero.mana < (myHero.maxMana * ( Settings.harass.harassMana / 100)) then
			return true
		else
			return false
		end
	elseif mode == "LaneClear" then
		if myHero.mana < (myHero.maxMana * ( Settings.lane.laneMana / 100)) then
			return true
		else
			return false
		end
	elseif mode == "JungleClear" then
		if myHero.mana < (myHero.maxMana * ( Settings.jungle.jungleMana / 100)) then
			return true
		else
			return false
		end
	end
end

function Menu()
	Settings = scriptConfig("Talon - Cutthroat "..version.."", "DraconisTalon")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("comboMode", "Combo Mode", SCRIPT_PARAM_LIST, 1, { "E + W + Q", "W + E + Q" })
		Settings.combo:addParam("useQ", "Use "..SkillQ.name.." (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useW", "Use "..SkillW.name.." (W) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useE", "Use "..SkillE.name.." (E) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_LIST, 1, { "Killable", "Don't waste", "Always" })
		Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:permaShow("comboKey")
	
	Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Settings.harass:addParam("harassMode", "Harass Mode", SCRIPT_PARAM_LIST, 1, { "W", "Q + W + E" })
		Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useE", "Use "..SkillE.name.." (E) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.harass:permaShow("harassKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
		Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.lane:addParam("laneQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.lane:permaShow("laneKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.jungle:permaShow("jungleKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
		Settings.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:permaShow("killSteal")
			
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("Text", "Draw Text on Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("wDraw", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("wColor", "Draw "..SkillW.name.." (W) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("eColor", "Draw "..SkillE.name.." (E) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		
		Settings.drawing:addSubMenu("Lag Free Circles", "lfc")	
			Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
			Settings.drawing.lfc:addParam("CL", "Quality", 4, 75, 75, 2000, 0)
			Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)
	
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillE.range, DAMAGE_PHYSICAL, true)
	TargetSelector.name = "Talon"
	Settings:addTS(TargetSelector)
end

function Variables()
	SkillQ = { name = "Noxian Diplomacy", range = TrueRange(), delay = nil, speed = nil, width = nil, ready = false }
	SkillW = { name = "Rake", range = 600, delay = 0.7, speed = 900, angle = 80, ready = false }
	SkillE = { name = "Cutthroat", range = 700, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Shadow Assault", range = 650, delay = nil, speed = nil, width = nil, ready = false }
	Ignite = { name = "summonerdot", range = 600, slot = nil }
	
	enemyMinions = minionManager(MINION_ENEMY, SkillW.range, myHero, MINION_SORT_HEALTH_ASC)
	
	VP = VPrediction()
	
	SxOrb:RegisterAfterAttackCallback(AfterAttack)
	
	JungleMobs = {}
	JungleFocusMobs = {}
	
	if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_2
	end
	
	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true 
	else
		TwistedTreeline = false
	end
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2	
	
	ItemNames				= {
		[3303]				= "ArchAngelsDummySpell",
		[3007]				= "ArchAngelsDummySpell",
		[3144]				= "BilgewaterCutlass",
		[3188]				= "ItemBlackfireTorch",
		[3153]				= "ItemSwordOfFeastAndFamine",
		[3405]				= "TrinketSweeperLvl1",
		[3411]				= "TrinketOrbLvl1",
		[3166]				= "TrinketTotemLvl1",
		[3450]				= "OdinTrinketRevive",
		[2041]				= "ItemCrystalFlask",
		[2054]				= "ItemKingPoroSnack",
		[2138]				= "ElixirOfIron",
		[2137]				= "ElixirOfRuin",
		[2139]				= "ElixirOfSorcery",
		[2140]				= "ElixirOfWrath",
		[3184]				= "OdinEntropicClaymore",
		[2050]				= "ItemMiniWard",
		[3401]				= "HealthBomb",
		[3363]				= "TrinketOrbLvl3",
		[3092]				= "ItemGlacialSpikeCast",
		[3460]				= "AscWarp",
		[3361]				= "TrinketTotemLvl3",
		[3362]				= "TrinketTotemLvl4",
		[3159]				= "HextechSweeper",
		[2051]				= "ItemHorn",
		[3146]				= "HextechGunblade",
		[3187]				= "HextechSweeper",
		[3190]				= "IronStylus",
		[2004]				= "FlaskOfCrystalWater",
		[3139]				= "ItemMercurial",
		[3222]				= "ItemMorellosBane",
		[3042]				= "Muramana",
		[3043]				= "Muramana",
		[3180]				= "OdynsVeil",
		[3056]				= "ItemFaithShaker",
		[2047]				= "OracleExtractSight",
		[3364]				= "TrinketSweeperLvl3",
		[2052]				= "ItemPoroSnack",
		[3140]				= "QuicksilverSash",
		[3143]				= "RanduinsOmen",
		[3074]				= "ItemTiamatCleave",
		[3800]				= "ItemRighteousGlory",
		[2045]				= "ItemGhostWard",
		[3342]				= "TrinketOrbLvl1",
		[3040]				= "ItemSeraphsEmbrace",
		[3048]				= "ItemSeraphsEmbrace",
		[2049]				= "ItemGhostWard",
		[3345]				= "OdinTrinketRevive",
		[2044]				= "SightWard",
		[3341]				= "TrinketSweeperLvl1",
		[3069]				= "shurelyascrest",
		[3599]				= "KalistaPSpellCast",
		[3185]				= "HextechSweeper",
		[3077]				= "ItemTiamatCleave",
		[2009]				= "ItemMiniRegenPotion",
		[2010]				= "ItemMiniRegenPotion",
		[3023]				= "ItemWraithCollar",
		[3290]				= "ItemWraithCollar",
		[2043]				= "VisionWard",
		[3340]				= "TrinketTotemLvl1",
		[3090]				= "ZhonyasHourglass",
		[3154]				= "wrigglelantern",
		[3142]				= "YoumusBlade",
		[3157]				= "ZhonyasHourglass",
		[3512]				= "ItemVoidGate",
		[3131]				= "ItemSoTD",
		[3137]				= "ItemDervishBlade",
		[3352]				= "RelicSpotter",
		[3350]				= "TrinketTotemLvl2",
	}

	___GetInventorySlotItem	= rawget(_G, "GetInventorySlotItem")
	_G.GetInventorySlotItem	= GetSlotItem
	
	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
			},
			
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
			},
			
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
			},
			
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
	}

	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}
	
	if not TwistedTreeline then
		JungleMobNames = { 
			["SRU_MurkwolfMini2.1.3"]	= true,
			["SRU_MurkwolfMini2.1.2"]	= true,
			["SRU_MurkwolfMini8.1.3"]	= true,
			["SRU_MurkwolfMini8.1.2"]	= true,
			["SRU_BlueMini1.1.2"]		= true,
			["SRU_BlueMini7.1.2"]		= true,
			["SRU_BlueMini21.1.3"]		= true,
			["SRU_BlueMini27.1.3"]		= true,
			["SRU_RedMini10.1.2"]		= true,
			["SRU_RedMini10.1.3"]		= true,
			["SRU_RedMini4.1.2"]		= true,
			["SRU_RedMini4.1.3"]		= true,
			["SRU_KrugMini11.1.1"]		= true,
			["SRU_KrugMini5.1.1"]		= true,
			["SRU_RazorbeakMini9.1.2"]	= true,
			["SRU_RazorbeakMini9.1.3"]	= true,
			["SRU_RazorbeakMini9.1.4"]	= true,
			["SRU_RazorbeakMini3.1.2"]	= true,
			["SRU_RazorbeakMini3.1.3"]	= true,
			["SRU_RazorbeakMini3.1.4"]	= true
		}
		
		FocusJungleNames = {
			["SRU_Blue1.1.1"]			= true,
			["SRU_Blue7.1.1"]			= true,
			["SRU_Murkwolf2.1.1"]		= true,
			["SRU_Murkwolf8.1.1"]		= true,
			["SRU_Gromp13.1.1"]			= true,
			["SRU_Gromp14.1.1"]			= true,
			["Sru_Crab16.1.1"]			= true,
			["Sru_Crab15.1.1"]			= true,
			["SRU_Red10.1.1"]			= true,
			["SRU_Red4.1.1"]			= true,
			["SRU_Krug11.1.2"]			= true,
			["SRU_Krug5.1.2"]			= true,
			["SRU_Razorbeak9.1.1"]		= true,
			["SRU_Razorbeak3.1.1"]		= true,
			["SRU_Dragon6.1.1"]			= true,
			["SRU_Baron12.1.1"]			= true
		}
	else
		FocusJungleNames = {
			["TT_NWraith1.1.1"]			= true,
			["TT_NGolem2.1.1"]			= true,
			["TT_NWolf3.1.1"]			= true,
			["TT_NWraith4.1.1"]			= true,
			["TT_NGolem5.1.1"]			= true,
			["TT_NWolf6.1.1"]			= true,
			["TT_Spiderboss8.1.1"]		= true
		}		
		JungleMobNames = {
			["TT_NWraith21.1.2"]		= true,
			["TT_NWraith21.1.3"]		= true,
			["TT_NGolem22.1.2"]			= true,
			["TT_NWolf23.1.2"]			= true,
			["TT_NWolf23.1.3"]			= true,
			["TT_NWraith24.1.2"]		= true,
			["TT_NWraith24.1.3"]		= true,
			["TT_NGolem25.1.1"]			= true,
			["TT_NWolf26.1.2"]			= true,
			["TT_NWolf26.1.3"]			= true
		}
	end
		
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			if FocusJungleNames[object.name] then
				JungleFocusMobs[#JungleFocusMobs+1] = object
			elseif JungleMobNames[object.name] then
				JungleMobs[#JungleMobs+1] = object
			end
		end
	end
end

function GetSlotItem(id, unit)
	unit = unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name	= ItemNames[id]
	
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return slot
		end
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end
 
function arrangePrioritys()
		for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,	   	enemy, 2)
		SetPriority(priorityTable.Support,  enemy, 3)
		SetPriority(priorityTable.Bruiser,  enemy, 4)
		SetPriority(priorityTable.Tank,	 	enemy, 5)
		end
end

function arrangePrioritysTT()
        for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 1)
		SetPriority(priorityTable.Support,  enemy, 2)
		SetPriority(priorityTable.Bruiser,  enemy, 2)
		SetPriority(priorityTable.Tank,     enemy, 3)
        end
end

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function PriorityOnLoad()
	if heroManager.iCount < 10 or (TwistedTreeline and heroManager.iCount < 6) then
		print("<b><font color=\"#6699FF\">Talon - Cutthroat:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function GetJungleMob()
	for _, Mob in pairs(JungleFocusMobs) do
		if ValidTarget(Mob, SkillE.range) then return Mob end
	end
	for _, Mob in pairs(JungleMobs) do
		if ValidTarget(Mob, SkillE.range) then return Mob end
	end
end

function OnCreateObj(obj)
	if obj.valid then
		if FocusJungleNames[obj.name] then
			JungleFocusMobs[#JungleFocusMobs+1] = obj
		elseif JungleMobNames[obj.name] then
			JungleMobs[#JungleMobs+1] = obj
		end
	end
end

function OnDeleteObj(obj)
	for i, Mob in pairs(JungleMobs) do
		if obj.name == Mob.name then
			table.remove(JungleMobs, i)
		end
	end
	for i, Mob in pairs(JungleFocusMobs) do
		if obj.name == Mob.name then
			table.remove(JungleFocusMobs, i)
		end
	end
end

function TrueRange()
	return myHero.range + GetDistance(myHero, myHero.minBBox)
end

function GetCustomTarget()
	if ValidTarget(targetSelected) then
		target = targetSelected
	else
		TargetSelector:update()
		target = TargetSelector.target
	end
	return target
end

function GetBestLineFarmPosition(range, width, objects)
	local BestPos 
	local BestHit = 0
	for i, object in ipairs(objects) do
		local EndPos = Vector(myHero.pos) + range * (Vector(object) - Vector(myHero.pos)):normalized()
		local hit = CountObjectsOnLineSegment(myHero.pos, EndPos, width, objects)
		if hit > BestHit then
			BestHit = hit
			BestPos = Vector(object)
			if BestHit == #objects then
			   break
			end
		 end
	end

	return BestPos, BestHit
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
	local n = 0
	for i, object in ipairs(objects) do
		local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
		if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
			n = n + 1
		end
	end

	return n
end

-- Barasia, vadash, viseversa
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  
  DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
  
  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
    DrawCircleNextLvl(x, y, z, radius, Settings.drawing.lfc.Width, color, Settings.drawing.lfc.CL) 
  end
end

function IsRebornLoaded()
	if _G.Reborn_Loaded ~= nil then
		return true
	else
		return false
	end
end
