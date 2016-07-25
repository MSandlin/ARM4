-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20
--
-- For information on the Fantasy Grounds d20 Ruleset licensing and
-- the OGL license text, see the d20 ruleset license in the program
-- options.
--
-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above licenses, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.
--
-- Copyright 2007 SmiteWorks Ltd.
--Modified by Zambol

-- Section visibility handling

forceactive = false;

activeon = true;
effectson = false;

charactertype = nil;



function setActiveVisible(status)
				
	activeon = status;
    
end

function toggleForceActive()
	forceactive = not forceactive;
	activeon = status;
    
	
	
	
	
	if forceactive then
			activateactive.setColor("ffffffff");
			shortdescription.setVisible(true);
			FinesseTag.setVisible(true);
			Skill.setVisible(true);
			QuiTag.setVisible(true);
			qsstat.setVisible(true);
			forceIbonusTag.setVisible(true);
			forceIbonus.setVisible(true);
			initTag.setVisible(true);
			init.setVisible(true);
			ActTag.setVisible(true);
			CastAct.setVisible(true);
			forcexp.setVisible(true);
			
			forceframe.setVisible(true);
			forceframesmall.setVisible(false);
		    
	else
		
			activateactive.setColor("7fffffff");
			shortdescription.setVisible(false);
			FinesseTag.setVisible(false);
			Skill.setVisible(false);
			QuiTag.setVisible(false);
			qsstat.setVisible(false);
			forceIbonusTag.setVisible(false);
			forceIbonus.setVisible(false);
			initTag.setVisible(false);
			init.setVisible(false);
			ActTag.setVisible(false);
			CastAct.setVisible(false);
			forcexp.setVisible(false);
			forceframe.setVisible(false);
			forceframesmall.setVisible(true);
			
	
	end
end

function isActive()
	return active.getState();
end

function setActive(state)
	active.setState(state);
end



-- Observers to support effects linked here

observers = {};

function addObserver(o)
	table.insert(observers, o);
end

function removeObserver(o)
	for i = 1, #observers do
		if observers[i] == o then
			table.remove(observers, i);
			break;
		end
	end
end



function onInit()

	setActiveVisible(true);
	
				
	
end

function onClose()
	for k, v in ipairs(observers) do
		v.observedClosed(self);
	end
end

function nameChanged()
	for k, v in ipairs(observers) do
		v.observedNameChanged(self);
	end
end

function setType(t)
	charactertype = t;
end

function getType()
	return charactertype;
end

