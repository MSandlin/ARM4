-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getPercentWounded(sNodeType, node)
	local nHP = 0;
	local nWounds = 0;
	
	if sNodeType == "ct" then
		nHP = DB.getValue(node, "hptotal", 0);
		nWounds = DB.getValue(node, "wounds", 0);
	elseif sNodeType == "pc" then
		nHP = DB.getValue(node, "hp.total", 0);
		nWounds = DB.getValue(node, "hp.wounds", 0)
	end
	
	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end
	
	local sStatus;
	if OptionsManager.isOption("WNDC", "detailed") then
		if nPercentWounded <= 0 then
			sStatus = "Healthy";
		elseif nPercentWounded < .25 then
			sStatus = "Light";
		elseif nPercentWounded < .5 then
			sStatus = "Moderate";
		elseif nPercentWounded < .75 then
			sStatus = "Bloodied";
		elseif nPercentWounded < 1 then
			sStatus = "Critical";
		elseif nPercentWounded < 1.5 then
			sStatus = "Dying";
		else
			sStatus = "Dead";
		end
	else
		if nPercentWounded <= 0 then
			sStatus = "Healthy";
		elseif nPercentWounded < .5 then
			sStatus = "Wounded";
		elseif nPercentWounded < 1 then
			sStatus = "Bloodied";
		elseif nPercentWounded < 1.5 then
			sStatus = "Dying";
		else
			sStatus = "Dead";
		end
	end

	return nPercentWounded, sStatus;
end

function getWoundColor(sNodeType, node)
	local nPercentWounded, sStatus = getPercentWounded(sNodeType, node);
	
	-- Based on the percent wounded, change the font color for the Wounds field
	local sColor;
	if nPercentWounded >= 1 then
		sColor = "404040";
	elseif nPercentWounded <= 0 then
		sColor = "006600";
	elseif OptionsManager.isOption("WNDC", "detailed") then
		if nPercentWounded >= 0.75 then
			sColor = "C11B17";
		elseif nPercentWounded >= 0.5 then
			sColor = "E56717";
		elseif nPercentWounded >= 0.25 then
			sColor = "AF7817";
		else
			sColor = "408000";
		end
	else
		if nPercentWounded >= 0.5 then
			sColor = "C11B17";
		else
			sColor = "408000";
		end
	end

	return sColor, nPercentWounded, sStatus;
end

function getWoundBarColor(sNodeType, node)
	local nPercentWounded, sStatus = getPercentWounded(sNodeType, node);
	
	local nRedR = 255;
	local nRedG = 0;
	local nRedB = 0;
	local nYellowR = 255;
	local nYellowG = 191;
	local nYellowB = 0;
	local nGreenR = 0;
	local nGreenG = 255;
	local nGreenB = 0;
	
	local sColor;
	if nPercentWounded >= 1 then
		sColor = "C0C0C0";
	else
		local nBarR, nBarG, nBarB;
		if nPercentWounded >= 0.5 then
			local nPercentGrade = (nPercentWounded - 0.5) * 2;
			nBarR = math.floor((nRedR * nPercentGrade) + (nYellowR * (1.0 - nPercentGrade)) + 0.5);
			nBarG = math.floor((nRedG * nPercentGrade) + (nYellowG * (1.0 - nPercentGrade)) + 0.5);
			nBarB = math.floor((nRedB * nPercentGrade) + (nYellowB * (1.0 - nPercentGrade)) + 0.5);
		else
			local nPercentGrade = nPercentWounded * 2;
			nBarR = math.floor((nYellowR * nPercentGrade) + (nGreenR * (1.0 - nPercentGrade)) + 0.5);
			nBarG = math.floor((nYellowG * nPercentGrade) + (nGreenG * (1.0 - nPercentGrade)) + 0.5);
			nBarB = math.floor((nYellowB * nPercentGrade) + (nGreenB * (1.0 - nPercentGrade)) + 0.5);
		end
		sColor = string.format("%02X%02X%02X", nBarR, nBarG, nBarB);
	end

	return sColor, nPercentWounded, sStatus;
end

function getAbilityScore(rActor, sAbility)
	if not sAbility then
		return -1;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return -1;
	end
	
	local nStatScore = -1;
	
	local sShort = string.sub(string.lower(sAbility), 1, 3);
	if sActorType == "pc" then
		if sShort == "lev" then
			nStatScore = DB.getValue(nodeActor, "level", 0);
		elseif sShort == "str" then
			nStatScore = DB.getValue(nodeActor, "abilities.strength.score", 0);
		elseif sShort == "dex" then
			nStatScore = DB.getValue(nodeActor, "abilities.dexterity.score", 0);
		elseif sShort == "con" then
			nStatScore = DB.getValue(nodeActor, "abilities.constitution.score", 0);
		elseif sShort == "int" then
			nStatScore = DB.getValue(nodeActor, "abilities.intelligence.score", 0);
		elseif sShort == "wis" then
			nStatScore = DB.getValue(nodeActor, "abilities.wisdom.score", 0);
		elseif sShort == "cha" then
			nStatScore = DB.getValue(nodeActor, "abilities.charisma.score", 0);
		end
	else
		if sShort == "lev" then
			nStatScore = tonumber(string.match(DB.getValue(nodeActor, "levelrole", ""), "Level (%d*)")) or 0;
		elseif sShort == "str" then
			nStatScore = DB.getValue(nodeActor, "strength", 0);
		elseif sShort == "con" then
			nStatScore = DB.getValue(nodeActor, "stamina", 0);
		elseif sShort == "dex" then
			nStatScore = DB.getValue(nodeActor, "dexterity", 0);
		elseif sShort == "qui" then
			nStatScore = DB.getValue(nodeActor, "dexterity", 0);
		
		elseif sShort == "int" then
			nStatScore = DB.getValue(nodeActor, "intelligence", 0);
		elseif sShort == "will" then
			nStatScore = DB.getValue(nodeActor, "willpower", 0);
		elseif sShort == "per" then
			nStatScore = DB.getValue(nodeActor, "perception", 0);
		end
	end
	
	return nStatScore;
end

function getAbilityBonus(rActor, sAbility)
	if not sAbility then
		return 0;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return 0;
	end
	
	-- SETUP
	local sStat = sAbility;
	local bHalf = false;
	local bDouble = false;
	local nStatVal = 0;
	
	-- HANDLE HALF/DOUBLE MODIFIERS
	if string.match(sStat, "^half") then
		bHalf = true;
		sStat = string.sub(sStat, 5);
	end
	if string.match(sStat, "^double") then
		bDouble = true;
		sStat = string.sub(sStat, 7);
	end

	-- GET ABILITY VALUE
	local nStatScore = getAbilityScore(rActor, sStat);
	if nStatScore < 0 then
		return 0;
	end
	
	-- RESULTS
	return nStatVal;
end

function getDefenseInternal(sDefense)
	local sInternal = "";
	
	if sDefense then
		local sShortDef = string.sub(string.lower(sDefense), 1, 2);
		if sShortDef == "ac" then
			sInternal = "ac";
		elseif sShortDef == "fo" then
			sInternal = "fortitude";
		elseif sShortDef == "re" then
			sInternal = "reflex";
		elseif sShortDef == "wi" then
			sInternal = "will";
		end
	end
	
	return sInternal;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	-- VALIDATE
	if not rDefender or not rRoll then
		return nil, 0, 0;
	end
	
	local sAttack = rRoll.sDesc;

	-- DETERMINE ATTACK TYPE AND DEFENSE
	local sAttackType = string.match(sAttack, "%[ATTACK.*%((%w+)%)%]");
	local bOpportunity = string.match(sAttack, "%[OPPORTUNITY%]");
	local sDefense = string.match(sAttack, "%(vs%.? (%a+)%)");
	if not sDefense then
		return nil, 0, 0;
	end
	sDefense = getDefenseInternal(sDefense);
	if sDefense == "" then
		return nil, 0, 0;
	end

	-- Determine the defense database node name
	local nDefense = 10;
	local sDefenderType, nodeDefender = ActorManager.getTypeAndNode(rDefender);
	if not nodeDefender then
		return nil, 0, 0, 0;
	end
	
	if sDefenderType == "pc" then
		nDefense = DB.getValue(nodeDefender, "defenses." .. sDefense .. ".total", 10);
	else
		nDefense = DB.getValue(nodeDefender, sDefense, 10);
	end

	-- EFFECT MODIFIERS
	local nAttackEffectMod = 0;
	local nDefenseEffectMod = 0;
	if ActorManager.hasCT(rDefender) then
		-- SETUP
		local bCombatAdvantage = false;
		local bUncannyDodge = false;
		local bCheckCA = true;
		local nBonusAllDefenses = 0;
		local nBonusSpecificDefense = 0;
		local nBonusSituational = 0;
		
		-- BUILD ATTACK FILTER 
		local aAttackFilter = {};
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		elseif sAttackType == "C" then
			table.insert(aAttackFilter, "close");
		elseif sAttackType == "A" then
			table.insert(aAttackFilter, "area");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end

		-- GET ATTACKER BASE MODIFIER
		local aBonusTargetedAttackDice = {};
		local nBonusTargetedAttack = 0;
		if rAttacker then
			aBonusTargetedAttackDice, nBonusTargetedAttack = EffectManager.getEffectsBonus(rAttacker, "ATK", false, aAttackFilter, rDefender, true);
		end
		nAttackEffectMod = nAttackEffectMod + StringManager.evalDice(aBonusTargetedAttackDice, nBonusTargetedAttack);
			
		-- GET ATTACKER SITUATIONAL MODIFIERS
		-- AND CHECK WHETHER COMBAT ADVANTAGE HAS ALREADY BEEN APPLIED
		if EffectManager.hasEffectCondition(rDefender, "Uncanny Dodge") then
			bUncannyDodge = true;
			bCheckCA = false;
		end
		if string.match(sAttack, "%[CA%]") then
			bCheckCA = false;
			if bUncannyDodge then
				nBonusSituational = nBonusSituational + 2;
			end
		end
		if bCheckCA then
			if EffectManager.hasEffect(rAttacker, "CA", rDefender, true) or 
					EffectManager.hasEffect(rAttacker, "Invisible", rDefender, true) then
				bCombatAdvantage = true;
			end
		end
		
		-- GET DEFENDER ALL DEFENSE MODIFIERS
		nBonusAllDefenses = EffectManager.getEffectsBonus(rDefender, "DEF", true, aAttackFilter, rAttacker);
		
		-- GET DEFENDER SPECIFIC DEFENSE MODIFIERS
		if sDefense == "ac" then
			nBonusSpecificDefense = EffectManager.getEffectsBonus(rDefender, "AC", true, aAttackFilter, rAttacker);
		elseif sDefense == "fortitude" then
			nBonusSpecificDefense = EffectManager.getEffectsBonus(rDefender, "FORT", true, aAttackFilter, rAttacker);
		elseif sDefense == "reflex" then
			nBonusSpecificDefense = EffectManager.getEffectsBonus(rDefender, "REF", true, aAttackFilter, rAttacker);
		elseif sDefense == "will" then
			nBonusSpecificDefense = EffectManager.getEffectsBonus(rDefender, "WILL", true, aAttackFilter, rAttacker);
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - COMBAT ADVANTAGE
		if bCheckCA then
			-- CHECK ALL THE CONDITIONS THAT COULD GRANT COMBAT ADVANTAGE
			if EffectManager.hasEffect(rDefender, "GRANTCA", rAttacker) then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Blinded") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Dazed") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Dominated") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Helpless") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Prone") and (sAttackType == "M") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Restrained") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Stunned") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Surprised") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Unconscious") then
				bCombatAdvantage = true;
			end
			
			-- CHECK ALL THE OTHER EFFECTS THAT COULD GRANT COMBAT ADVANTAGE
			if EffectManager.hasEffectCondition(rDefender, "Balancing") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Climbing") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Running") then
				bCombatAdvantage = true;
			elseif EffectManager.hasEffectCondition(rDefender, "Squeezing") then
				bCombatAdvantage = true;
			end

			-- APPLY COMBAT ADVANTAGE AS DEFENSE PENALTY
			if bCombatAdvantage then
				nBonusSituational = nBonusSituational - 2;
			end
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - CONDITIONS
		if EffectManager.hasEffectCondition(rDefender, "Prone") and (sAttackType == "R") then
			nBonusSituational = nBonusSituational + 2;
		end
		if EffectManager.hasEffectCondition(rDefender, "Unconscious") then
			nBonusSituational = nBonusSituational - 5;
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - CONCEALMENT
		if sAttackType and (sAttackType == "M" or sAttackType == "R") then
			local bCheckConceal = true;
			if string.match(sAttack, "%[BLINDED%]") then
				bCheckConceal = false;
			end
			if bCheckConceal then
				local bTotalConceal = false;
				local bConceal = false;
				
				if string.match(sAttack, "%[TCONC%]") then
					bTotalConceal = true;
				elseif string.match(sAttack, "%[CONC%]") then
					bConceal = true;
				end
				
				if not bTotalConceal then
					if EffectManager.hasEffect(rDefender, "Invisible", rAttacker) then
						bTotalConceal = true;
					elseif EffectManager.hasEffect(rAttacker, "Blinded", rDefender, true) and StringManager.isWord(sAttackType, {"M", "R"}) then
						bTotalConceal = true;
					else
						local aConcealment = EffectManager.getEffectsByType(rDefender, "TCONC", aAttackFilter, rAttacker);
						if #aConcealment > 0 or EffectManager.hasEffect(rDefender, "TCONC", rAttacker) then
							bTotalConceal = true;
						elseif not bConceal then
							aConcealment = EffectManager.getEffectsByType(rDefender, "CONC", aAttackFilter, rAttacker);
							if #aConcealment > 0 or EffectManager.hasEffect(rDefender, "CONC", rAttacker) then
								bConceal = true;
							end
						end
					end
				end
			
				if bTotalConceal then
					nBonusSituational = nBonusSituational + 5;
				elseif bConceal then
					nBonusSituational = nBonusSituational + 2;
				end
			end
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - COVER
		local bSuperiorCover = false;
		local bCover = false;
		if string.match(sAttack, "%[SCOVER%]") then
			bSuperiorCover = true;
		elseif string.match(sAttack, "%[COVER%]") then
			bCover = true;
		end
				
		if not bSuperiorCover then
			local aCover = EffectManager.getEffectsByType(rDefender, "SCOVER", aAttackFilter, rAttacker);
			if #aCover > 0 or EffectManager.hasEffect(rDefender, "SCOVER", rAttacker) then
				bSuperiorCover = true;
			elseif not bCover then
				aCover = EffectManager.getEffectsByType(rDefender, "COVER", aAttackFilter, rAttacker);
				if #aCover > 0 or EffectManager.hasEffect(rDefender, "COVER", rAttacker) then
					bCover = true;
				end
			end
		end
		
		if bSuperiorCover then
			nBonusSituational = nBonusSituational + 5;
		elseif bCover then
			nBonusSituational = nBonusSituational + 2;
		end
		
		-- ADD IN EFFECT MODIFIERS
		nDefenseEffectMod = nBonusAllDefenses + nBonusSpecificDefense + nBonusSituational;
	end
	
	-- Return the final defense value
	return nDefense + nDefenseEffectMod - nAttackEffectMod, nAttackEffectMod, nDefenseEffectMod;
end

function getSave(rActor)
	local nSave = 0;
	
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sActorType == "pc" then
		nSave = DB.getValue(nodeActor, "defenses.save.total", 0);
	else
		nSave = DB.getValue(nodeActor, "save", 0);
	end
	
	return nSave;
end
