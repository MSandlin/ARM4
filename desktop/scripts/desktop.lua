-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
    local msg = {font = "emotefont"};
    msg.text = "Ars Magica Ruleset based on the Core RPG. "
 	ChatManager.registerLaunchMessage(msg);
	
	Interface.onDesktopInit = onDesktopInit;
	deliverDisclaimer();
	declareVersion();
	registerPublicNodes();
	
	buildDesktop();
	
	
end


function deliverDisclaimer()
	
	local msg = {font = "emotefont"};
	msg.sender = "";
	msg.font = "crnarratorfont";
	
	msg.text = "ARS MAGICA is a trademark of Atlas-Games, and its rules and art are copyrighted by Atlas-Games. All rights are reserved by Atlas-Games. This game aid is the original creation of Oberoten and is released for free distribution. Note that you will need the Ars Magica rulebooks to have any use out of it. Many people have helped me with this ruleset, in no particular order Thanks goes to Joshua, Foen, Saithan and Tenian as well as Mossfoot and Toadwart ";
	ChatManager.registerLaunchMessage(msg);
	

end


function declareVersion()

	local msg = {font = "crnarratorfont"};
	msg.sender = "";
	msg.text = "Version 2.0.3.20";
	msg.font = "crnarratorfont";
	ChatManager.registerLaunchMessage(msg);


end


function onDesktopInit()
	if not User.isLocal() and not User.isHost() then
		Interface.openWindow("charselect_client", "", true);
	end
end

function registerPublicNodes()
	if User.isHost() then
		DB.createNode("options").setPublic(true);
		DB.createNode("partysheet").setPublic(true);
		DB.createNode("calendar").setPublic(true);
		DB.createNode("combattracker").setPublic(true);
		DB.createNode("modifiers").setPublic(true);
		DB.createNode("effects").setPublic(true);
	end
end

function buildDesktop()
	-- Local mode
	if User.isLocal() then
		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");

		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_client");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");
		
	-- GM mode
	elseif User.isHost() then
		-- DesktopManager.registerStackShortcut2("button_ct", "button_ct_down", "sidebar_tooltip_ct", "combattracker_host", "combattracker");
		DesktopManager.registerStackShortcut("button_ct", "button_ct_down", "Combat Tracker", "combattracker", "combattracker");
		DesktopManager.registerStackShortcut2("button_partysheet", "button_partysheet_down", "sidebar_tooltip_ps", "partysheet_host", "partysheet");

		DesktopManager.registerStackShortcut2("button_tables", "button_tables_down", "sidebar_tooltip_tables", "tablelist", "tables");
		DesktopManager.registerStackShortcut2("button_calendar", "button_calendar_down", "sidebar_tooltip_calendar", "calendar", "calendar");

		DesktopManager.registerStackShortcut2("button_light", "button_light_down", "sidebar_tooltip_lighting", "lightingselection");
		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");

		DesktopManager.registerStackShortcut2("button_modifiers", "button_modifiers_down", "sidebar_tooltip_modifiers", "modifiers", "modifiers");
		DesktopManager.registerStackShortcut2("button_effects", "button_effects_down", "sidebar_tooltip_effects", "effectlist", "effects");

		DesktopManager.registerStackShortcut2("button_options", "button_options_down", "sidebar_tooltip_options", "options");
		
		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_host", "charsheet");
		DesktopManager.registerDockShortcut2("button_book", "button_book_down", "sidebar_tooltip_story", "encounterlist", "encounter");
		DesktopManager.registerDockShortcut2("button_maps", "button_maps_down", "sidebar_tooltip_image", "imagelist", "image");
		DesktopManager.registerDockShortcut2("button_people", "button_people_down", "sidebar_tooltip_npc", "npclist", "npc");
		DesktopManager.registerDockShortcut2("button_items", "button_items_down", "sidebar_tooltip_item", "itemlist", "item");
		DesktopManager.registerDockShortcut2("button_notes", "button_notes_down", "sidebar_tooltip_note", "notelist", "notes");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");
		
		DesktopManager.registerDockShortcut2("button_tokencase", "button_tokencase_down", "sidebar_tooltip_token", "tokenbag", nil, true);
		
	-- Player mode
	else
		-- DesktopManager.registerStackShortcut2("button_ct", "button_ct_down", "sidebar_tooltip_ct", "combattracker_client", "combattracker");
		DesktopManager.registerStackShortcut2("button_partysheet", "button_partysheet_down", "sidebar_tooltip_ps", "partysheet_client", "partysheet");

		DesktopManager.registerStackShortcut2("button_tables", "button_tables_down", "sidebar_tooltip_tables", "tablelist", "tables");
		DesktopManager.registerStackShortcut2("button_calendar", "button_calendar_down", "sidebar_tooltip_calendar", "calendar", "calendar");

		DesktopManager.registerStackShortcut2("button_color", "button_color_down", "sidebar_tooltip_colors", "pointerselection");
		DesktopManager.registerStackShortcut2("button_options", "button_options_down", "sidebar_tooltip_options", "options");

		DesktopManager.registerStackShortcut2("button_modifiers", "button_modifiers_down", "sidebar_tooltip_modifiers", "modifiers", "modifiers");
		DesktopManager.registerStackShortcut2("button_effects", "button_effects_down", "sidebar_tooltip_effects", "effectlist", "effects");

		DesktopManager.registerDockShortcut2("button_characters", "button_characters_down", "sidebar_tooltip_character", "charselect_client");
		DesktopManager.registerDockShortcut2("button_book", "button_book_down", "sidebar_tooltip_story", "encounterlist", "encounter");
		DesktopManager.registerDockShortcut2("button_maps", "button_maps_down", "sidebar_tooltip_image", "imagelist", "image");
		DesktopManager.registerDockShortcut2("button_people", "button_people_down", "sidebar_tooltip_npc", "npclist", "npc");
		DesktopManager.registerDockShortcut2("button_items", "button_items_down", "sidebar_tooltip_item", "itemlist", "item");
		DesktopManager.registerDockShortcut2("button_notes", "button_notes_down", "sidebar_tooltip_note", "notelist", "notes");
		DesktopManager.registerDockShortcut2("button_library", "button_library_down", "sidebar_tooltip_library", "library");
		
		DesktopManager.registerDockShortcut2("button_tokencase", "button_tokencase_down", "sidebar_tooltip_token", "tokenbag", nil, true);
	end
end
