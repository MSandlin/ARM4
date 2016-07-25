-- This file is part of the Fantasy Grounds Open Foundation Ruleset project. 
-- For the latest information, see http://www.fantasygrounds.com/
--
-- Copyright 2008 SmiteWorks Ltd.
--
-- This file is provided under the Open Game License version 1.0a
-- Refer to the license.html file for the full license text
--
-- All producers of work derived from this material are advised to
-- familiarize themselves with the license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.
--
-- All material submitted to the Open Foundation Ruleset project must
-- contain this notice in a manner applicable to the source file type.

function onInit()
  ActionsManager.registerResultHandler("dice", handleWildDice);
end

function handleWildDice(rSource, rTarget, rRoll)
    local reroll = false;
    local total = {};
    local msg2 = { };
	msg2.font = "chatgmfont";
    local firstResult = 0;
    local secondResult = 0;
    local dielist = rRoll.aDice;
	local hideWild = false
	local result
	local mult
	if rRoll.bSecret then
      hideWild = true;
      
    elseif User.isHost() and OptionsManager.isOption("REVL", "off") then
      hideWild = true;
    end
	
	
	
    if dielist then
      for i = 1, #dielist do
			--draginfo.setSlot(i);
		
			if dielist[i].type == "d10" then
			result = dielist[i].result;
			
			    if result==1 then
				msg2.icon = "wild_die";
				
				mult = 2;
					result = math.random(10);
					msg2.text = "A one, rolling again, subsequent roll is a " .. result ;
					if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
					-- Purely for effect - roll a d10
					local dice = {};
					table.insert(dice, "d10");
					Comm.throwDice("explode", dice, 0, "explode");
						while result==1 do
							mult = mult * 2;
							result = math.random(10);
							local dice = {};
							table.insert(dice, "d10");
							Comm.throwDice("explode", dice, 0, "explode");
							msg2.text = "Another one, rolling again, subsequent roll is a " .. result;
							if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
				
						end
					dielist[i].result = result * mult;
									msg2.text = "Final roll is a " .. result .. " which with a multiplier of " .. mult .. " gives us a total of " .. result * mult ;
							if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
				elseif result==10 then
					mult = -1;
					msg2.icon = "botch_die";
					dielist[i].icon = "botch_die";
					result = math.random(10);
					msg2.text = "A Zero, rolling again, subsequent roll is a " .. result;
					local dice = {};
					table.insert(dice, "d10");
					Comm.throwDice("explode", dice, 0, "explode");
							if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
						while result==10 do
							mult = mult * 2;
							result = math.random(10);
							local dice = {};
					table.insert(dice, "d10");
					Comm.throwDice("explode", dice, 0, "explode");
							msg2.text = "Another Zero, rolling again, subsequent roll is a " .. result;
							if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
							
						end
						
					dielist[i].result = result * mult;
									msg2.text = "Final roll is a " .. result .. " which with a multiplier of " .. mult .. " gives us a total of " .. result * mult ;
							if hideWild == true then 
							msg2.text = "The roll went wild!"
							msg2.icon = "hidden_wild_die"
							Comm.deliverChatMessage(msg2);
							else
							Comm.deliverChatMessage(msg2);
							
							end
				end

			end
		
		
		end
      end
    
    
    --if firstResult == 10 or secondResult == 10 then
     -- repeat
      --  local reroll = false;
      --  local dieRoll = math.random(1,10);
     --   local explode = {};
     --   explode.type = "d10";
     --   explode.result = dieRoll;
     --   table.insert(total, explode);
     --   -- Purely for effect - roll a d10
     --   local dice = {};
     --   table.insert(dice, "d10");
     --   Comm.throwDice("explode", dice, 0, "explode");
     --   if dieRoll == 10 then
     --     reroll = true;
     --   end
     -- until not reroll
    -- end
    
    local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
    rMessage.type = rRoll.sType;
    rMessage.text = rMessage.text .. rRoll.sDesc;
    rMessage.dice = dielist;
    rMessage.diemodifier = rRoll.nMod;
    
    -- Check to see if this roll should be secret (GM or dice tower tag)
    if rRoll.bSecret then
      rMessage.secret = true;
      if rRoll.bTower then
        rMessage.icon = "dicetower_icon";
      end
    elseif User.isHost() and OptionsManager.isOption("REVL", "off") then
      rMessage.secret = true;
    end
   
    
	if rRoll.sSubType=="spell" then
	
	local castSucess = { text=""}
	local Target = tonumber(rRoll.nTarget);
	local Total = rMessage.dice[1].result + rMessage.diemodifier
	
	
	local GS = Target + 10;
	
	local f1 = Target -5;
	local f2 = Target -10;
	local f3 = Target -15;
	local f4 = Target -20;
	
	
		
		if Total >= Target then
			castSucess.text="a sucess at a cost. (1 light fatigue)";
		end
	
	   if Total >= GS then
		castSucess.text="a GREAT sucess.";
	   end
	   
		if Total < Target then
		castSucess.text="minor failure! (2 light fatigue)"
		end
		
	    if Total < f1 then
		castSucess.text="A failure! (Take 1 medium fatigue)";
		end
		
		if Total <= f2 then
		castSucess.text="A bad failure! (Take 1 heavy fatigue)";
		end
		
		if Total <= f3 then
		castSucess.text="A terrible failure! (You are unconscious)";
		end
		
		if  Total <= f4 then
		castSucess.text="A critical failure! (Unconscious + wound)";
		end
	
		if not rRoll.bSecret then
			rMessage.text = rMessage.text .. " it is " .. castSucess.text
		end
	end
	
	
	
	
	
	
	
   
	
	
    -- Show total if option enabled
    if OptionsManager.isOption("TOTL", "on") then
      rMessage.dicedisplay = 1;
    end
  
    Comm.deliverChatMessage(rMessage);
	
	
	
	
	
	
    ModifierStack.reset();
    return true;
end