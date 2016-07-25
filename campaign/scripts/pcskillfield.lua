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


skillnames = { "Art", "Athletics", "Awareness", "Business", "Charm", "Convince", "Consume Alcohol" , "Climb" ,"Computers", 
				"Concentration","Cooking",  "Craft", "Language", "Etiquette","Firearms", "Hermetic Lore", "Hermetic Law","Engineering", "Disguise", "Escape Artist", "Finesse", 
			   "Folk Ken", "Force Theory", "Forgery","Gambling","Herblore",  "Handle Animals", "Hand to Hand", "Intimidate", 
               "Jump", "Knowledge","Language: ", "Leadership", "Magic Theory", "Medicine", "Music", "Perform", "Ranged Weapons", 
			   "Research", "Ride", "Search", "Security", "Sleight of Hand", "Stealth","Surgery", "Parma Magica", "Mental Shield", "Force Shield",
			   "Speech", "Spot", "Strategy", "Survival", "Swim", "Tactics", "Tumble", "Use Magic Device" };

function getCompletion(str)
	-- Find a matching completion for the given string
	for i = 1, #skillnames, 1 do
		if string.lower(str) == string.lower(string.sub(skillnames[i], 1, #str)) then
			return string.sub(skillnames[i], #str + 1);
		end
	end
	
	return "";
end

function parseComponents()
	-- Break the string in the control into skills and modifiers, and record their respective positions
	str = getValue();
	components = {};
	
	starts = true;
	nextindex = 1;
	
	while starts do
		-- Find component parts: label with whitespace and modifier, with optional comma and whitespace following
		starts, ends, all, skill, mod  = string.find(str, '(([%w%s\(\)]*[%w\(\)]*)%s*([%+%-]?%d*))%s*,?%s*', nextindex);
		
		-- Adjust label to strip trailing whitespace
		spaces = string.match(string.reverse(skill), '%s*()') - 1;
		skillends = starts + #skill - spaces;
		skill = string.sub(skill, 1, #skill - spaces);

		-- Missing modifier should be treated as 0, a completely empty entry is skipped
		if mod == nil then mod = 0 end;
		if starts > ends then starts = false end;
		
		-- Add component to list
		if starts then
			nextindex = ends+1;
			table.insert(components, { startpos = starts, labelendpos = skillends, endpos = starts + #all, label = skill, bonus = mod });
		end
	end

	return components;
end

function onChar()
	-- When a new character is appeneded to a skill label, autocomplete it if a match is found
	components = parseComponents();

	for i = 1, #components, 1 do
		if getCursorPosition() == components[i].labelendpos then
			completion = getCompletion(components[i].label);

			if completion ~= "" then
				value = getValue();
				newvalue = string.sub(value, 1, getCursorPosition()-1) .. completion .. string.sub(value, getCursorPosition());

				setValue(newvalue);
				setSelectionPosition(getCursorPosition() + #completion);
			end

			return;
		end
	end
end


function onDragEnd(dragdata)
	dragging = false;
end

function onClickDown(button, x, y)
	-- Suppress default processing to support dragging
	return true;
end

function onClickRelease(button, x, y)
	-- Enable edit mode on mouse release
	setFocus();
	
	local n = getIndexAt(x, y);
	
	setSelectionPosition(n);
	setCursorPosition(n);
	
	return true;
end


function onInit()


	
	
	-- Construct default skills
	--constructDefaultSkills();

	
end


-- Create default skill selection
function constructDefaultSkills()
	-- Collect existing entries
	local entrymap = {};
	local wind = self.getDatabaseNode();

	for k, w in pairs(wind) do
		local skillname = skillname.getValue(); 
	
		if skilldata[skillname] then
			if not entrymap[skillname] then
				entrymap[skillname] = { w };
			else
				table.insert(entrymap[skillname], w);
			end
		end
	end

	-- Set properties and create missing entries for all known skills
	for k, t in pairs(skilldata) do
		local matches = entrymap[k];
		
		if not matches then
			local newwin = createWindow();
			newwin.skillname.setValue(k);
			matches = { newwin };
		end
		
		
	end
end

-- Skill properties
skilldata = {
	"Athletics" ,
	"Awareness" ,
	"Speech",
	
}

