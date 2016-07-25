-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	OptionsManager.registerOption2("REVL", true, "option_header_game", "option_label_REVL", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
			
	OptionsManager.registerOption2("CLSAM", true, "option_header_game", "option_label_CLSAM", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })

end
