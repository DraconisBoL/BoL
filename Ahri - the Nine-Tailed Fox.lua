local version = "1.51"

--[[
	Ahri - the Nine-Tailed Fox
		Author: Draconis
		Version: 1.51
		Copyright 2016
			
	Dependency: Standalone
--]]

if myHero.charName ~= "Ahri" then return end

require 'HPrediction'

------------------------------------------------------
--			 Callbacks				
------------------------------------------------------

function OnLoad()
	print("<b><font color=\"#6699FF\">Ahri - the Nine-Tailed Fox:</font></b> <font color=\"#FFFFFF\">Good luck and have fun!</font>")
	Variables()
	Menu()
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

------------------------------------------------------
--			 Functions				
------------------------------------------------------

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.combo.comboMode == 1 then
			if Settings.combo.useR then CastR(unit) end
			CastE(unit)
			CastQ(unit)
			CastW(unit)
		else
			CastE(unit)
			CastQ(unit)
			CastW(unit)
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLow() then
		if Settings.harass.useQ then CastQ(unit) end
		if Settings.harass.useE then CastE(unit) end
		if Settings.harass.useW then CastW(unit) end
	end
end

function LaneClear()
	enemyMinions:update()
	if LaneClearKey then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if Settings.lane.laneQ and GetDistance(minion) <= SkillQ.range and SkillQ.ready then
					local BestPos, BestHit = GetBestLineFarmPosition(SkillQ.range, SkillQ.width, enemyMinions.objects)
						if BestPos ~= nil then
							CastSpell(_Q, BestPos.x, BestPos.z)
						end
				end
				if Settings.lane.laneW and GetDistance(minion) <= SkillW.range and SkillW.ready then
					CastSpell(_W)
				end
			end		 
		end
	end
end

function JungleClear()
	if Settings.jungle.jungleKey then
		jungleMinions:update()
		
		for i, JungleMob in pairs(jungleMinions.objects) do
			if JungleMob ~= nil and JungleMob.health > 1 then
				if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range and SkillQ.ready then
					CastSpell(_Q, JungleMob.x, JungleMob.z)
				end
				if Settings.jungle.jungleW and GetDistance(JungleMob) <= SkillW.range and SkillW.ready then
					CastSpell(_W)
				end
			end
		end
	end
end

function CastQ(unit)	
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		local CastPosition,  HitChance = HPred:GetPredict(HPred.Presets["Ahri"]["Q"], unit, myHero)

		if CastPosition and HitChance >= 1.6 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastE(unit)
	if unit ~= nil and GetDistance(unit) <= SkillE.range and SkillE.ready then
		local CastPosition,  HitChance = HPred:GetPredict(HPred.Presets["Ahri"]["E"], unit, myHero)
			
		if CastPosition and HitChance >= 1.6 then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function CastW(unit)	
	if unit ~= nil and SkillW.ready and GetDistance(unit) <= SkillW.range then
		CastSpell(_W)
	end
end

function CastR(unit)
	if unit ~= nil then
		if SkillR.ready and GetDistance(unit) <= SkillQ.range and Settings.combo.useR == 1 then
			local Mouse = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
			CastSpell(_R, Mouse.x, Mouse.z) 
		elseif SkillR.ready and GetDistance(unit) <= SkillQ.range and Settings.combo.useR == 2 then
			CastSpell(_R, unit.x, unit.z)
		elseif Settings.combo.useR == 3 then
			return
		end
	end
end

function KillSteal()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero)
			local eDmg = getDmg("E", enemy, myHero)
			
			if enemy.health <= qDmg then
				CastQ(enemy)
			elseif enemy.health <= (qDmg + eDmg) then
				CastE(enemy)
				CastQ(enemy)
			elseif enemy.health <= eDmg then
				CastE(enemy)
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
			local eDmg = getDmg("E", enemy, myHero)
			local iDmg = getDmg("IGNITE", enemy, myHero)
			
			if enemy.health <= qDmg then
				DrawText3D(tostring("Killable: Q"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= qDmg + wDmg then
				DrawText3D(tostring("Killable: Q > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= eDmg then
				DrawText3D(tostring("Killable: E"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + eDmg) then
				DrawText3D(tostring("Killable: E > Q"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (wDmg + eDmg) then
				DrawText3D(tostring("Killable: E > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + eDmg + wDmg) then
				DrawText3D(tostring("Killable: E > Q > W"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			elseif enemy.health <= (qDmg + eDmg + wDmg + iDmg) then
				DrawText3D(tostring("Killable: E > Q > W > IGNITE"), enemy.x, enemy.y, enemy.z, 16, ARGB(255, 10, 255, 10), true)
			end
		end
	end
end

function AutoIgnite(unit)
	if ValidTarget(unit, Ignite.range) and unit.health <= 50 + (20 * myHero.level) then
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
	
	if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_2
	end
	
	Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
	
	TargetSelector:update()
	Target = GetCustomTarget()
	
	if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
	
	if Settings.combo.comboSwitch and Settings.combo.comboMode == 1 then
		Settings.combo.comboMode = 2
	elseif not Settings.combo.comboSwitch and Settings.combo.comboMode == 2 then
		Settings.combo.comboMode = 1
	end
end

function IsMyManaLow()
	if myHero.mana < (myHero.maxMana * ( Settings.harass.harassMana / 100)) then
		return true
	else
		return false
	end
end

function Menu()
	Settings = scriptConfig("Ahri - the Nine-Tailed Fox "..version.."", "DraconisAhri")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("comboSwitch", "Combo Switch", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("A"))
		Settings.combo:addParam("comboMode", "Combo Mode", SCRIPT_PARAM_LIST, 1, { "REQW", "EQW"})
		Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_LIST, 1, { "To mouse", "Toward enemy", "Don't use"})
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("comboMode")
	
	Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, false)
		Settings.harass:addParam("useE", "Use "..SkillE.name.." (E) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.harass:permaShow("harassKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
		Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.lane:addParam("laneQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:permaShow("laneKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
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
		if _G.Reborn_Loaded ~= nil then
			Settings.Orbwalking:addParam("Info", "Default orbwalker disabled", SCRIPT_PARAM_INFO, "")
		else
			NebelwolfisOrbWalkerClass(Settings.Orbwalking)
		end
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillE.range, DAMAGE_MAGIC, true)
	TargetSelector.name = "Ahri"
	Settings:addTS(TargetSelector)
end

function Variables()
	SkillQ = { name = "Orb of Deception", range = 840, delay = 0.25, speed = 1600, width = 90, ready = false }
	SkillW = { name = "Fox-Fire", range = 800, delay = nil, speed = nil, width = nil, ready = false }
	SkillE = { name = "Charm", range = 975, delay = 0.25, speed = 1500, width = 100, ready = false }
	SkillR = { name = "Spirit Rush", range = 550, delay = nil, speed = nil, width = nil, ready = false }
	Ignite = { name = "SummonerDot", range = 600, slot = nil }
	
	enemyMinions = minionManager(MINION_ENEMY, SkillQ.range, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, SkillQ.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	HPred = HPrediction()
	
	if _G.Reborn_Loaded == nil then
		require("Nebelwolfi's Orb Walker")
	end
	
	JungleMobs = {}
	JungleFocusMobs = {}
	
	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true 
	else
		TwistedTreeline = false
	end
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2	
end

function TrueRange()
	return myHero.range + GetDistance(myHero, myHero.minBBox)
end

-- Trees
function GetCustomTarget()
	TargetSelector:update() 	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
	--if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	return TargetSelector.target
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
