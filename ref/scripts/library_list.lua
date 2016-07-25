-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onFilter(w)
	if window.filter then
		local f = string.lower(window.filter.getValue());

		if f == "" then
			return true;
		end
		if string.find(string.lower(w.name.getValue()), f, 0, true) then
			return true;
		end
		
		return false;
	else
		return true;
	end
end
