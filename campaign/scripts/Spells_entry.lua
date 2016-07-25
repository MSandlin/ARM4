function onSortCompare(w1, w2)
	if w1.skillname.getValue() == "" then
		return true;
	elseif w2.skillname.getValue() == "" then
		return false;
	end

	return w1.skillname.getValue() > w2.skillname.getValue();
end

function addNewInstance(label)
	local data = skilldata[label];
	
	if data and data.sublabeling then
		local newwin = createWindow();
		
		newwin.skillname.setValue(label);
		
		newwin.sublabel.setVisible(true);
		newwin.setCustom(false);
		
		newwin.sublabel.setFocus();
	end
end