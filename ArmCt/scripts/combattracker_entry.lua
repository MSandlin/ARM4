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
forcedefensive = false;
forceeffects = false;
defensiveon = false;
activeon = false;
effectson = false;

charactertype = nil;

function setSpacerState()
	if defensiveon or activeon or effectson then
		spacer.setVisible(true);
	else
		spacer.setVisible(false);
	end
end

function setDefensiveVisible(status)
	if forcedefensive then
		status = true;
	end
	if not targeting.isEmpty() then
		status = true;
	end
	
	defensiveon = status;

	dbonus.setVisible(status);
	deflabel.setVisible(status);
	targeting.setVisible(status);
	defensiveicon.setVisible(status);
	
	setSpacerState();
end

function setActiveVisible(status)
	if forceactive then
		status = true;
	end
	if active.getState() then
		status = true;
	end
	
	local usernode = link.getTargetDatabaseNode()
	
	if usernode then
		User.ringBell(usernode.getName());
	end
	
	activeon = status;
    abonus.setVisible(status);
	attlabel.setVisible(status);
	activeicon.setVisible(status);
	-- damage.setVisible(status);
	-- penetration.setVisible(status);
	setSpacerState();
end

function toggleForceEffects()
	forceeffects = not forceeffects;
	
	if forceeffects then
		activateeffects.setColor("ffffffff");
	else
		activateeffects.setColor("7fffffff");
	end
end

function toggleForceActive()
	forceactive = not forceactive;
	
	if forceactive then
		activateactive.setColor("ffffffff");
	else
		activateactive.setColor("7fffffff");
	end
end

function toggleForceDefensive()
	forcedefensive = not forcedefensive;
	
	if forcedefensive then
		activatedefensive.setColor("ffffffff");
	else
		activatedefensive.setColor("7fffffff");
	end
end

-- FoF State

function getFoF()
	return friendorfoe;
end

function setFoF(state)
	friendorfoe = state;
	token.updateUnderlay();
end

-- Activity state

function isActive()
	return active.getState();
end

function setActive(state)
	active.setState(state);
	
	
	
--	if state and charactertype == "pc" then
	if state then
		-- Turn notification
		local msg = {};
		msg.text = name.getValue();
		msg.font = "narratorfont";
		msg.icon = "indicator_flag";
		
		Comm.deliverChatMessage(msg);
		
		local usernode = link.getTargetDatabaseNode();
				if usernode then
					local ownerid = User.getIdentityOwner(usernode.getName());
					if ownerid then
						User.ringBell(ownerid);
					end
				end
	
		
	end
end

function setEffectsVisible(status)
	if forceeffects then
		status = true;
	end
	
	effectson = status;
	
	effecticon.setVisible(status);
	effects.setVisible(status);
	
	setSpacerState();
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

--	registerMenuItem("Delete Item", "delete", 6);
	setDefensiveVisible(false);
	setActiveVisible(false);
	setEffectsVisible(false);
end

function onMenuSelection(selection)
	if selection == 6 then
		delete();
	end
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


function delete()
	-- Remember node name
	local sNode = name.getValue();
	-- remove token from map if an npc
  if getType()=="npc" then
    token.deleteReference();
  end
  -- advance tracker, if this entry is active
  if isActive() and #(windowlist.getWindows())>1 then
    local next = windowlist.getNextWindow(self);
    if next then
      next.setActive();
    end
  end
  -- delete database node (also closes window)
  getDatabaseNode().delete();
	
	-- Update list information (global subsection toggles, targeting)
	windowlist.deleteTarget(sNode);
end

function refDeleted(deleted)
	-- CLEAR REFERENCE
	ref = nil;
end


function store()
	local entry = {};

	-- Name, type and link target
	entry.name = name.getValue();
	entry.type = charactertype;
	
	if link.getTargetDatabaseNode() then
		entry.dbnode = link.getTargetDatabaseNode().getNodeName();
	end

	-- Token and token instance
	entry.token = token.getPrototype();

	if token.ref and token.ref.getContainerNode() then
		entry.tokenrefnode = token.ref.getContainerNode().getNodeName();
		entry.tokenrefid = token.ref.getId();
	end
	
	-- Active state
	entry.active = active.getState();
	
	-- FoF
	entry.fof = getFoF();

	-- Value fields
	entry.initresult = initresult.getValue();
	entry.ActValue = ActValue.getValue();
	entry.abonus = abonus.getValue();
	entry.dbonus = dbonus.getValue();
	entry.lwound = lwound.getValue();
	entry.mwound = mwound.getValue();
	entry.hwound = hwound.getValue();
	entry.ctfatigue = ctfatigue.getValue();
	entry.ctfatigue2 = ctfatigue2.getValue();
	entry.wfpen = wfpen.getValue();
	entry.troops = troops.getValue();
	
	
	return entry;
end

function restore(entry)
	-- Name, type and linking
	name.setValue(entry.name);

	local targetnode = nil;
	if entry.dbnode then
		targetnode = DB.findNode(entry.dbnode);
	end
	
	if entry.type == "pc" and targetnode then
		charactertype = "pc";
		link.setValue("charsheet", entry.dbnode);
		link.setVisible(true);
		
		name.setReadOnly(true);
		name.setFrame(nil);
		
		-- Links to data
		name.setLink(targetnode.getChild("name"));
		lwound.setLink(targetnode.getChild("WLlw"));
		mwound.setLink(targetnode.getChild("WLmw"));
		hwound.setLink(targetnode.getChild("WLhw"));
		ctfatigue.setLink(targetnode.getChild("Ftotales"));
	    ctfatigue2.setLink(targetnode.getChild("fpfatigue"));
	    
		
		
	else
		if entry.type == "npc" and targetnode then
			charactertype = "npc";
			link.setValue("npc", entry.dbnode);
			link.setVisible(true);
		end
		
	end
	
	-- Token
	if entry.tokenrefnode and entry.tokenrefid then
		token.acquireReference(token.populateFromImageNode(entry.tokenrefnode, entry.tokenrefid));
	elseif entry.token then
		token.setPrototype(entry.token);
	end

	-- Active state
	setActive(entry.active)
	--active.setState(entry.active);
	
	-- FoF
	friendfoe.setState(entry.fof);
	
	-- Value fields
	initresult.setValue(entry.initresult);
	ActValue.setValue(entry.ActValue);
	dbonus.setValue(entry.dbonus);
	abonus.setValue(entry.abonus);
	lwound.setValue(entry.lwound);
	mwound.setValue(entry.mwound);
	hwound.setValue(entry.hwound);
	ctfatigue.setValue(entry.ctfatigue);
	ctfatigue2.setValue(entry.ctfatigue2);
	wfpen.setValue(entry.wfpen);
	troops.setValue(entry.troops);
	
end

function storeEffects(entry, idmap)
	-- effects
	local e = {};
	for k, v in ipairs(effects.getWindows()) do
		local effect = {};
		effect.label = v.label.getValue();
		effect.duration = v.duration.getValue();
		effect.adjustment = v.adjustment.getValue();
		if v.caster.sourceentry then
			effect.sourceid = idmap[v.caster.sourceentry];
		end
		
		table.insert(e, effect);
	end
	
	entry.effects = e;
end	

function restoreEffects(entry, idmap)
	effects.clearAndDisableCheck();

	if entry.effects then
		for k,v in ipairs(entry.effects) do
			local win = effects.createWindow();
			win.label.setValue(v.label);
			win.duration.setValue(v.duration);
			win.adjustment.setValue(v.adjustment);
			win.caster.setSource(idmap[v.sourceid]);
		end
	end
	
	effects.enableCheck();
end
