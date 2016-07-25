

local topWidget = nil;
local tabIndex = 1;
local tabWidgets = {};

function activateTab(index)
	-- Hide active tab, fade text labels
	--tabWidgets[tabIndex].setColor("80ffffff");
	window[tab[tabIndex].subwindow[1]].setVisible(false);
    
	-- Set new index
	tabIndex = tonumber(index);
	
	-- Activate text label and subwindow
	--tabWidgets[tabIndex].setColor("ffffffff");

	window[tab[tabIndex].subwindow[1]].setVisible(true);
end

function activateTabOnClick(index)
	-- Hide active tab, fade text labels
	--tabWidgets[tabIndex].setColor("80ffffff");
	window[tab[tabIndex].subwindow[1]].setVisible(false);

	-- Set new index
	tabIndex = tonumber(index);

	--	assert(nil,tabIndex);
	
	-- Activate text label and subwindow
	--tabWidgets[tabIndex].setColor("ffffffff");

	window[tab[tabIndex].subwindow[1]].setVisible(true);
end

function onClickDown(button, x, y)
	local i = math.ceil(x/50);
	-- Make sure index is in range and activate selected
	if i > 0 and i < #tab+1 then
		activateTabOnClick(i);
	end
end

function onDoubleClick(x, y)
	-- Emulate single click
	onClickDown(1, x, y);
end

function onInit()
	-- Create a helper graphic widget to indicate that the selected tab is on top
	--topWidget = addBitmapWidget("tabtop");
	--topWidget.setVisible(false);
    
	-- Deactivate all labels	
	for n, v in ipairs(tab) do
		tabWidgets[n] = addBitmapWidget(v.icon[1]);
		tabWidgets[n].setPosition("topleft", 51*(n-1)+15, 27);
		--tabWidgets[n].setColor("80ffffff");
	end

	if activate then
		activateTab(activate[1]);
	else
		activateTab(1);
	end
end