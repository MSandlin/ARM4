-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	
	ActionsManager.registerModHandler("ability", modRoll);
end

function performRoll(draginfo, rActor, sAbilityStat)
	local rRoll = {};
	
	-- SETUP
	rRoll.aDice = { "d10" };
	rRoll.nMod = ActorManager.getAbilityBonus(rActor, sAbilityStat);
	
	-- BUILD THE OUTPUT
	rRoll.sDesc = "Spell"
	rRoll.sDesc = rRoll.sDesc .. " check";
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modRoll(rSource, rTarget, rRoll)
	if rTarget and rTarget.nOrder then
		return;
	end
	
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	if rSource then
		local bEffects = false;

		local sActionStat = nil;
		local sAbility = string.match(rRoll.sDesc, "%[ABILITY%] (%w+) check");
		if sAbility then
			sAbility = string.lower(sAbility);
		else
			if string.match(rRoll.sDesc, "%[STABILIZATION%]") then
				sAbility = "constitution";
			end
		end

		-- GET ACTION MODIFIERS
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectsManager.getEffectsBonus(rSource, {"ABIL"}, false, {sAbility});
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- GET CONDITION MODIFIERS
		if EffectsManager.hasEffectCondition(rSource, "Frightened") or 
				EffectsManager.hasEffectCondition(rSource, "Panicked") or
				EffectsManager.hasEffectCondition(rSource, "Shaken") then
			nAddMod = nAddMod - 2;
			bEffects = true;
		end
		if EffectsManager.hasEffectCondition(rSource, "Sickened") then
			nAddMod = nAddMod - 2;
			bEffects = true;
		end

		-- GET STAT MODIFIERS
		local nBonusStat, nBonusEffects = ActorManager.getAbilityEffectsBonus(rSource, sAbility);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- HANDLE NEGATIVE LEVELS
		local nNegLevelMod, nNegLevelCount = EffectsManager.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			nAddMod = nAddMod - nNegLevelMod;
			bEffects = true;
		end

		-- IF EFFECTS HAPPENED, THEN ADD NOTE
		--if bEffects then
		--	local sEffects = "";
		--	local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
		--	if sMod ~= "" then
		--		sEffects = "[EFFECTS " .. sMod .. "]";
		--	else
		--		sEffects = "[EFFECTS]";
		--	end
		--	table.insert(aAddDesc, sEffects);
		--end
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	for _,vDie in ipairs(aAddDice) do
		table.insert(rRoll.aDice, "p" .. string.sub(vDie, 2));
	end
	rRoll.nMod = rRoll.nMod + nAddMod;
end

