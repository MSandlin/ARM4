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
-- Copyright 2006 SmiteWorks Ltd.
-- Modified by Zambol
-- Modified by Oberoten

function deleteTarget(sNode)
	TargetingManager.removeTargetFromAllEntries("host", sNode);
end

function CTLoad(param)
	param = "CT"..param;
	local trackertable = CampaignRegistry[param];
	

	if trackertable then
		closeAll();

		local idmap = {};		-- Mapping id -> window
	
		-- First pass, create entries
		for k, v in ipairs(trackertable) do
			local win = createWindow();
			win.restore(v);
			idmap[k] = win;
		end

		-- Second pass, create effects with ids
		for k, v in ipairs(trackertable) do
		 idmap[k].restoreEffects(v, idmap);
		end
	end
end


function CTSave(param)
	local trackertable = {};	-- Table to receive entries to store
	local idmap = {};			-- Mapping window -> id
	local msg = {};

	-- First pass, store entries
	for k,v in ipairs(getWindows()) do
		table.insert(trackertable, v.store());
		idmap[v] = #trackertable;
	end

	-- Second pass, store effects
	  for k,v in pairs(idmap) do
		k.storeEffects(trackertable[v], idmap);
	 end

	msg.font = "systemfont";
	msg.text = "CombatTracker saved.";
	ChatManager.addMessage(msg);

	param = "CT"..param;
	CampaignRegistry[param] = trackertable;
end



function onInit()
	Interface.onHotkeyActivated = onHotkey;
	
	getWindows()[1].close();
	
	restoreFromRegistry();
	
	if #getWindows() == 0 then
		createWindow();
	end
	
	Comm.registerSlashHandler("/ctl", CTLoad);
	Comm.registerSlashHandler("/cts", CTSave);
	
end

function onClose()
	storeToRegistry();
	
end

function restoreFromRegistry()
	local trackertable = CampaignRegistry.combattracker;
	local t = CampaignRegistry.combattrackertick;
	
	if t then
		window.tickcounter.setValue(t);
		tickNote();
	end
	
	if trackertable then
		local idmap = {};		-- Mapping id -> window
	
		-- First pass, create entries
		for k, v in ipairs(trackertable) do
			local win = createWindow();
			win.restore(v);
			idmap[k] = win;
		end

		-- Second pass, create effects with ids
		for k, v in ipairs(trackertable) do
			idmap[k].restoreEffects(v, idmap);
		end
		
	end
	

end

function storeToRegistry()
	local trackertable = {};	-- Table to receive entries to store
	local idmap = {};			-- Mapping window -> id

	-- First pass, store entries
	for k,v in ipairs(getWindows()) do
		table.insert(trackertable, v.store());
		idmap[v] = #trackertable;
	end
	
	-- Second pass, store effects
	for k,v in pairs(idmap) do
		k.storeEffects(trackertable[v], idmap);
	end
	
	CampaignRegistry.combattracker = trackertable;
	CampaignRegistry.combattrackertick = window.tickcounter.getValue();
end

function onHotkey(draginfo)
	if draginfo.isType("combattrackernextactor") then
		nextActor();
		return true;
	end
end

function addPc(source, token)
	local newentry = createWindow();
	
	newentry.setType("pc");
	
	-- Shortcut
	newentry.name.setReadOnly(true);
	newentry.name.setFrame(nil);
	
	newentry.link.setValue("charsheet", source.getNodeName());
	newentry.link.setVisible(true);
	
	-- Token
if source.getChild("token") then
		-- if a token exists on the character sheet use that, otherwise use supplied image token
		newentry.token.setPrototype(source.getChild("token").getValue());
	elseif token then

		newentry.token.setPrototype(token);
	end
	
	-- FoF
	newentry.friendfoe.setState("friend");

	
	-- Linked fields
	newentry.name.setLink(source.getChild("name"));
	newentry.lwound.setLink(source.getChild("WLlw"));
	newentry.mwound.setLink(source.getChild("WLmw"));
	newentry.hwound.setLink(source.getChild("WLhw"));
	newentry.ctfatigue.setLink(source.getChild("Ftotales"));
	newentry.ctfatigue2.setLink(source.getChild("fpfatigue"));
	
	
	
	return newentry;
end

function addNpc(source)
	local newentry = createWindow();

	newentry.setType("npc");

	-- Name
	local which = 1;
	if source.getChild("name") then
		for k,v in ipairs(getWindows()) do
			if string.sub(v.name.getValue(), 1, string.len(source.getChild("name").getValue())) == source.getChild("name").getValue() then
				which = which + 1;
			end
		end
		if which > 1 then
			newentry.name.setValue(source.getChild("name").getValue() .. " " .. tostring(which));
		else
			newentry.name.setValue(source.getChild("name").getValue());
		end
	end

	-- Token
	
	-- Token

	if source.getChild("token") then

		newentry.token.setPrototype(source.getChild("token").getValue());


	end
	
	-- Dbonus
	if source.getChild("dbonus") then
		newentry.dbonus.setValue(source.getChild("dbonus").getValue());
	end
	
	-- Abonus
	if source.getChild("abonus") then
		newentry.abonus.setValue(source.getChild("abonus").getValue());
	end
		
	-- FoF
	newentry.friendfoe.setState("foe");

	return newentry;
end

function onDrop(x, y, draginfo)
	if draginfo.isType("playercharacter")  then
		local source = draginfo.getDatabaseNode();
		local token = draginfo.getTokenData();
		
		if source then
			local newentry = addPc(source, token);
		end
		
		return true;
	elseif draginfo.isType("shortcut")  then
		local class, datasource = draginfo.getShortcutData();
		local source = draginfo.getDatabaseNode();

		if source and class == "npc" then
			local newentry = addNpc(source);
			newentry.link.setValue(class, datasource);
			newentry.link.setVisible(true);
			
		elseif source and class == "charsheet" then	
			local source = draginfo.getDatabaseNode();
			local token = draginfo.getTokenData();

			if source then
				local newentry = addPc(source, token);
			end		
		end

		return true;
	end
end

function onSortCompare(w1, w2)
	return w1.initresult.getValue() > w2.initresult.getValue();
end;

function getActiveEntry()
	for k, v in ipairs(getWindows()) do
		if v.isActive() then
			return v;
		end
	end
	
	return nil;
end

function requestActivation(entry)
	for k, v in ipairs(getWindows()) do
		v.setActive(false);
	end
	
	entry.setActive(true);
	entry.initresult.setValue(entry.initresult.getValue() + entry.ActValue.getValue());
	
	if entry.getType() ~="pc" then
		GmIdentityManager.addIdentity(entry.name.getValue());
		else
		GmIdentityManager.addIdentity("GM");
	end
	
end

function firstActor()
	local entry =  getNextWindow(nil);
	
	requestActivation(entry);
end

function tickNote()
	-- Tick notification
	local a 
	a = window.tickcounter.getValue()
	if a > 0 then
	local msg = {};
	msg.text = "Segment #"..window.tickcounter.getValue();
	msg.font = "narratorfont";
	msg.icon = "indicator_timer";

	Comm.deliverChatMessage(msg);
	end;
end

function nextTick()
	
	window.tickcounter.setValue(window.tickcounter.getValue() + 1);
	window.list.applySort();
	
	local entry = getNextWindow(nil);
	
	if entry then
		if window.tickcounter.getValue() > entry.initresult.getValue() then
			window.tickcounter.setValue(window.tickcounter.getValue() - 1);
			requestActivation(entry);
		else
			tickNote();
			
			if window.tickcounter.getValue() == entry.initresult.getValue() then
				requestActivation(entry);
			end
		end
	end
	
	for k, v in ipairs(getWindows()) do
		v.effects.progressEffects(nil);
	end
	
end