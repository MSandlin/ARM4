-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_WHISPER = "whisper";

-- Initialization
function onInit()
	if User.isHost() then
		Module.onActivationRequested = moduleActivationRequested;
	end
	Module.onUnloadedReference = moduleUnloadedReference;

	Comm.registerSlashHandler("whisper", processWhisper);
	Comm.registerSlashHandler("w", processWhisper);
	Comm.registerSlashHandler("reply", processReply);
	Comm.registerSlashHandler("r", processReply);
	Comm.registerSlashHandler("next", processNext);
	Comm.registerSlashHandler("hr", processHorizontalRule);
	Comm.registerSlashHandler("calc", calculate);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_WHISPER, handleWhisper);
	
	Comm.registerSlashHandler("die", processDie);
	Comm.registerSlashHandler("mod", processMod);

	if User.isHost() or User.isLocal() then
		Comm.registerSlashHandler("importchar", processImport);
		Comm.registerSlashHandler("exportchar", processExport);
	end
end


-- Main function for starting the calculation
function calculate(cmd, params)
	if params == 'show' then
		Comm.addChatMessage({font = "systemfont", text = "Created constants:"});
		if CampaignRegistry.CalculatorStore then
			for i,j in pairs(CampaignRegistry.CalculatorStore) do
				Comm.addChatMessage({font = "systemfont", text = (i .. " = " .. CampaignRegistry.CalculatorStore[i])});
			end
		end
		return true;
	end
	if params:find(':=') then
		local cutpoint = params:find(':=');
		local key = strip(params:sub(1, cutpoint-1));
		local value = strip(params:sub(cutpoint+2));
		if key and value and key ~= "" and value ~= "" then 
			if not CampaignRegistry.CalculatorStore then
				CampaignRegistry.CalculatorStore = {};
			end
			CampaignRegistry.CalculatorStore[key] = value;
			Comm.addChatMessage({font = "systemfont", text = (key .. " = " .. value .. " was successfully added")});
		else
			Comm.addChatMessage({font = "systemfont", text = "Error while inserting constant value"});
		end
		return true;
	end
	local string = params;
	if strip(string) == "" or string == nil then
		Comm.addChatMessage({font = "systemfont", text = "Calculator Usage:"});
		Comm.addChatMessage({font = "systemfont", text = "/calc exp  (Calculates exp mathematical expression. Possible operations are +, -, *, /, ^ and Sqrt)"});
		Comm.addChatMessage({font = "systemfont", text = "/calc key := value  (Creates/replaces constant named key)"});
		Comm.addChatMessage({font = "systemfont", text = "/calc show  (Lists created constants)"});
		return false;
	end

	while string:lower():find('%d*d%d+') do
		local cutstart, cutend = string:lower():find('%d*d%d+');
		local startpart = string:sub(0,cutstart-1);
		local endpart = string:sub(cutend+1);

		local num, max = string:lower():sub(cutstart, cutend):match('(%d*)d(%d+)');
		local value = 0
		local rolls = ""
		if not num or num == "" then
			num = 1
		end
		for i = 1, num do
			local rand = math.random(1,max)
			value = value + rand
			rolls = rolls .. rand .. ", "
			
		end
		rolls = rolls:gsub(', $', '')
		

		string = startpart .. value .. endpart;
		
	end

	if CampaignRegistry.CalculatorStore then
		for i,j in pairs(CampaignRegistry.CalculatorStore) do
			while true do
				if string:find(i) then
					local cutstart, cutend = string:find(i);
					local startpart = string:sub(0,cutstart-1);
					local endpart = string:sub(cutend+1);
					string = startpart .. CampaignRegistry.CalculatorStore[i] .. endpart;
				else
					break;
				end
			end
		end
	end
	string = handleParenthesis(string);
	if string:find('ERROR') then 
		string = "ERROR";
	else 
		string = processOperations(string);
	end
	if string:find('ERROR') then 
		string = "ERROR";
	end
	if string ~= "ERROR" then
		local result = toNumber(string);
		local cmp = toNumber(string:match('%s*%d*%s*'));
		if result and cmp and strip(cmp) ~= ""  then
			if result-cmp >= 0.5 then cmp = math.ceil(result);
			else cmp = math.floor(result);
			end
		else 
			cmp = result;
		end
		
		local msg = {}
		msg.font = "systemfont"
		msg.dicesecret = false
		msg.text = params .. " = " .. result
		msg.dice = {}
		msg.diemodifier = cmp
		
		Comm.addChatMessage(msg)
		
		--ChatManager.processDie(cmp .. " " .. params .. " = " .. result);
	else
		Comm.addChatMessage({font = "systemfont", text = params .. " = ERROR"});
	end

end

-- Process parenthesis
function handleParenthesis(string)
	local starting;
	local ending;
	while true do
		starting = string:find('%(');
		while true and starting do
			if string.find(string:sub((starting+1)), '%(') then
				starting = starting + string.find(string:sub(starting+1), '%(');
			else break;
			end
		end
		if starting then
			ending = string.find(string:sub(starting+1), '%)');
			if ending then
				ending = ending + starting;
			end
		end
		if starting == nil or ending == nil or starting >= ending then break;
		else
			sentence = string:sub(starting+1, ending-1);
			sentence = processOperations(sentence);
			string = string:sub(0, starting-1) .. sentence .. string:sub(ending+1);
		end
	end
	return string;
end

-- Process all possible operations in order
function processOperations(sentence)
	sentence = doMath(sentence, 'SQRT');
	sentence = doMath(sentence, '%^');
	sentence = doMath(sentence, '%*');
	sentence = doMath(sentence, '/');
	sentence = arrangeSentence(sentence, '+');
	sentence = arrangeSentence(sentence, '-');
	sentence = doMath(sentence, '-');
	return sentence;
end

-- Arrange remaining sentence
function arrangeSentence(sentence, sign)
	if sign == '+' then
		local firstdigit = sentence:match('%s*[.%d]*%s*');
		if firstdigit and strip(firstdigit) ~= ""  then
			local cut = sentence:find(firstdigit);
			if cut then
				if string.find(sentence:sub(1,cut-1), '-') == nil then
					sentence = "+" .. sentence;
				end
			end
		end
	end
	local sum = 0;
	while true do
		local result = sentence:find(sign);
		if result == nil then break;
		else
			a = string.match((sentence:sub(result+1)), '%-?%s*[.%d]*%s*');
		end
		if a == nil or strip(a) == "" then return "ERROR";
		end
		sum = sum + a;
		local startcut, endcut = string.find((sentence:sub(result+1)), a);
		if endcut then
			sentence = sentence:sub(1, result-1) .. sentence:sub(endcut+1+result);
		end
	end
	if sign == '+' then
		sentence = sum .. sentence;
	elseif sign == '-' then
		sentence = sentence .. '-' .. sum;
	end
	return sentence;
end

-- Strip all whitespaces
function strip(sentence)
	return string.gsub(sentence, '%s*', "")
end

-- Get first number from string
function toNumber(variable)
	local negative = nil;
	variable = string.format('%s', variable)
	local sign = string.find(variable, '-');
	if sign then
		var = string.match(variable:sub(sign+1), '%-?%s*[.%d]*%s*');
		negative = true;
	else
		var = string.match(variable, '%-?%s*[.%d]*%s*');
	end
	if variable == nil or strip(variable) == "" then
		return "";
	else
		if negative then
			var = var * (-1);
		end
		return var;
	end
end

-- Get last number from string
function getLast(sentence)
	cut = 0;
	local number = toNumber(sentence);
	while true do
		sign = string.find(sentence, "[%+%-/%*%^]");
		if sign == nil then break;
		end
		sign = sentence:sub(sign, sign);
		part = string.find(sentence, sign);
		cut = cut + part;
		number = string.match(sentence:sub(part+1), '%-?%s*[.%d]*%s*');
		if number or strip(number) ~= "" then
			sentence = sentence:sub((part+1));
		else
			number = "";
			break;
		end
	end
	return number, cut;
end

-- Do mathematical calculations
function doMath(sentence, sign)
	while true do
		if sign == '%*' or sign == '/' then
			local ml = sentence:find('%*');
			local dv = string.find(sentence:upper(), '/');
			if ml == nil then ml = 1000;
			end
			if dv == nil then dv = 1000; 
			end
			if dv < ml then sign = '/';
			elseif ml < dv then sign = '%*';
			else break;
			end
		elseif sign == "%^" or sign == "SQRT" then
			local pt = sentence:find('%^');
			local sq = string.find(sentence:upper(), 'SQRT');
			if pt == nil then pt = 1000;
			end
			if sq == nil then sq = 1000;
			end
			if sq < pt then sign = "SQRT";
			elseif pt < sq then sign = '%^';
			else break;
			end
		end
		result = string.find(sentence:upper(), sign);
		if result == nil then break;
		elseif sign == "SQRT" then
			a = string.match((sentence:sub(result+4)), '%-?%s*[.%d]*%s*');
			b = 0;
			cut = string.find(sentence:upper(), 'SQRT');
			cut = cut-1;
		else
			a = string.match((sentence:sub(result+1)), '%-?%s*[.%d]*%s*');
			b, cut = getLast(sentence:sub(1,result-1));
		end
		if a == nil or b == nil or strip(a) == "" or strip(b) == "" then
			if (a and strip(a) ~= "") and (b == nil or strip(b) == "") then
				local startcut, endcut = sentence:find(a);
				if string.find((sentence:sub(0, startcut-1)), '-') then
					return sentence;
				else return "ERROR";
				end
			else return "ERROR";
			end
		end
		if sign == '%^' then replacement = math.pow(b,a);
		elseif sign:upper() == 'SQRT' then replacement = math.sqrt(a);
		elseif sign == '%*' then replacement = a * b;
		elseif sign == '/' then replacement = b/a;
		elseif sign == '+' then replacement = a + b;
		elseif sign == '-' then replacement = b - a;
		end
		local tmp, endpart = string.find((sentence:sub(result+1)), a);
		sentence = sentence:sub(0, cut) .. replacement .. sentence:sub(endpart+1+result);
	end
	return sentence;
end




-- Horizontal rule
function processHorizontalRule()
	local msg = {};
	msg.font = "systemfont";
	msg.text = "";
	msg.icon = "hrbar";
	Comm.deliverChatMessage(msg);
	msg = {};
	msg.font = "systemfont";
	
		Comm.deliverChatMessage(msg);
end




--
-- MeNext
--

function processNext()
	local msg = {};
	msg.font = "systemfont";
	msg.text = " wants to talk next";
	msg.icon = "hand";

	if User.isHost() then
				msg.sender = GmIdentityManager.getCurrent();
			else
				msg.sender = User.getIdentityLabel();
			end
		
	
		Comm.deliverChatMessage(msg);
		
end




--
-- Rolling them bones... 
--


function d10Check(type, bonus, name)
	if control then
		local dice = {};
		table.insert(dice, type);
		control.throwDice("skillcheck", dice, bonus, name);
	end
end


function d10CheckVS(type, bonus, name,VS)
	if control then
		local dice = {};
		table.insert(dice, type);
		control.throwDice("dice", dice, bonus, name, VS);
	end
end


--
-- MODULE NOTIFICATIONS
--

function moduleActivationRequested(sModule)
	local msg = {};
	msg.text = Interface.getString("module_message_request") .. " (" .. sModule .. ")";
	msg.font = "systemfont";
	msg.icon = "module_loaded";
	Comm.addChatMessage(msg);
end

function moduleUnloadedReference(sModule)
	local msg = {};
	msg.text = Interface.getString("module_message_unloaded") .. " (" .. sModule .. ")";
	msg.font = "systemfont";
	Comm.addChatMessage(msg);
end

--
-- LAUNCH MESSAGES
--

launchmsg = {};

function registerLaunchMessage(msg)
	table.insert(launchmsg, msg);
end

function retrieveLaunchMessages()
	return launchmsg;
end

--
-- SLASH COMMAND HANDLER
--

function onSlashCommand(command, parameters)
	SystemMessage(Interface.getString("message_slashcommands"));
	SystemMessage("----------------");
	if User.isHost() then
		SystemMessage("/clear");
		SystemMessage("/console");
		SystemMessage("/day");
		SystemMessage("/die [NdN+N] <message>");
		SystemMessage("/emote [message]");
		SystemMessage("/export");
		SystemMessage("/exportchar");
		SystemMessage("/exportchar [name]");
		SystemMessage("/flushdb");
		SystemMessage("/gmid [name]");
		SystemMessage("/identity [name]");
		SystemMessage("/importchar");
		SystemMessage("/lighting [RGB hex value]");
		SystemMessage("/mod [N] <message>");
		SystemMessage("/mood [mood] <message>");
		SystemMessage("/mood ([multiword mood]) <message>");
		SystemMessage("/ooc [message]");
		SystemMessage("/night");
		SystemMessage("/reload");
		SystemMessage("/reply [message]");
		SystemMessage("/save");
		SystemMessage("/scaleui [50-200]");
		SystemMessage("/story [message]");
		SystemMessage("/vote <message>");
		SystemMessage("/whisper [character] [message]");
	else
		SystemMessage("/action [message]");
		SystemMessage("/console");
		SystemMessage("/die [NdN+N] <message>");
		SystemMessage("/emote [message]");
		SystemMessage("/mod [N] <message>");
		SystemMessage("/mood [mood] <message>");
		SystemMessage("/mood ([multiword mood]) <message>");
		SystemMessage("/ooc [message]");
		SystemMessage("/reply [message]");
		SystemMessage("/save");
		SystemMessage("/scaleui [50-200]");
		SystemMessage("/vote <message>");
		SystemMessage("/whisper GM [message]");
		SystemMessage("/whisper [character] [message]");
	end
end

--
-- AUTO-COMPLETE
--

function searchForIdentity(sSearch)
	for _,sIdentity in ipairs(User.getAllActiveIdentities()) do
		local sLabel = User.getIdentityLabel(sIdentity);
		if string.find(string.lower(sLabel), string.lower(sSearch), 1, true) == 1 then
			if User.getIdentityOwner(sIdentity) then
				return sIdentity;
			end
		end
	end

	return nil;
end

function doUserAutoComplete(ctrl)
	local buffer = ctrl.getValue();
	if buffer == "" then 
		return ;
	end

	-- Parse the string, adding one chunk at a time, looking for the maximum possible match
	local sReplacement = nil;
	local nStart = 2;
	while not sReplacement do
		local nSpace = string.find(string.reverse(buffer), " ", nStart, true);

		if nSpace then
			local sSearch = string.sub(buffer, #buffer - nSpace + 2);

			if not string.match(sSearch, "^%s$") then
				local sIdentity = searchForIdentity(sSearch);
				if sIdentity then
					local sRemainder = string.sub(buffer, 1, #buffer - nSpace + 1);
					sReplacement = sRemainder .. User.getIdentityLabel(sIdentity) .. " ";
					break;
				end
			end
		else
			local sIdentity = searchForIdentity(buffer);
			if sIdentity then
				sReplacement = User.getIdentityLabel(sIdentity) .. " ";
				break;
			end
			
			return;
		end

		nStart = nSpace + 1;
	end

	if sReplacement then
		ctrl.setValue(sReplacement);
		ctrl.setCursorPosition(#sReplacement + 1);
		ctrl.setSelectionPosition(#sReplacement + 1);
	end
end

--
-- DICE AND MOD SLASH HANDLERS
--

function processDie(sCommand, sParams)
	if User.isHost() then
		if sParams == "reveal" then
			OptionsManager.setOption("REVL", "on");
			SystemMessage(Interface.getString("message_slashREVLon"));
			return;
		end
		if sParams == "hide" then
			OptionsManager.setOption("REVL", "off");
			SystemMessage(Interface.getString("message_slashREVLoff"));
			return;
		end
	end

	local sDice, sDesc = string.match(sParams, "%s*(%S+)%s*(.*)");
	
	if not StringManager.isDiceString(sDice) then
		SystemMessage("Usage: /die [dice] [description]");
		return;
	end
	
	local aDice, nMod = StringManager.convertStringToDice(sDice);
	
	local aRulesetDice = Interface.getDice();
	local aFinalDice = {};
	local aNonStandardResults = {};
	for k,v in ipairs(aDice) do
		if StringManager.contains(aRulesetDice, v) then
			table.insert(aFinalDice, v);
		elseif v:sub(1,1) == "-" and StringManager.contains(aRulesetDice, v:sub(2)) then
			table.insert(aFinalDice, v);
		else
			local sSign, sDieSides = v:match("^([%-%+]?)[dD]([%dF]+)");
			if sDieSides then
				local nResult;
				if sDieSides == "F" then
					local nRandom = math.random(3);
					if nRandom == 1 then
						nResult = -1;
					elseif nRandom == 3 then
						nResult = 1;
					end
				else
					local nDieSides = tonumber(sDieSides) or 0;
					nResult = math.random(nDieSides);
				end
				
				if sSign == "-" then
					nResult = 0 - nResult;
				end
				
				nMod = nMod + nResult;
				table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
			end
		end
	end
	
	if sDesc ~= "" then
		sDesc = string.format("%s (%s)", sDesc, sDice);
	else
		sDesc = sDice;
	end
	if #aNonStandardResults > 0 then
		sDesc = sDesc .. table.concat(aNonStandardResults, "");
	end
	
	local rRoll = { sType = "dice", sDesc = sDesc, aDice = aFinalDice, nMod = nMod };
	ActionsManager.actionDirect(nil, "dice", { rRoll });
end

function processMod(sCommand, sParams)
	local sMod, sDesc = string.match(sParams, "%s*(%S+)%s*(.*)");
	
	local nMod = tonumber(sMod);
	if not nMod then
		SystemMessage("Usage: /mod [number] [description]");
		return;
	end
	
	ModifierStack.addSlot(sDesc, nMod);
end

function processImport(sCommand, sParams)
	CampaignDataManager.importChar();
end

function processExport(sCommand, sParams)
	local nodeChar = nil;
	
	local sFind = StringManager.trim(sParams);
	if string.len(sFind) > 0 then
		for _,vChar in pairs(DB.getChildren("charsheet")) do
			local sChar = DB.getValue(vChar, "name", "");
			if string.len(sChar) > 0 then
				if string.lower(sFind) == string.lower(string.sub(sChar, 1, string.len(sFind))) then
					nodeChar = vChar;
					break;
				end
			end
		end
		if not nodeChar then
			SystemMessage(Interface.getString("error_slashexportcharmissing") .. " (" .. sParams .. ")");
			return;
		end
	end
	
	CampaignDataManager.exportChar(nodeChar);
end

--
--
-- MESSAGES
--
--

function createBaseMessage(rSource, sUser)
	-- Set up the basic message components
	local msg = {font = "systemfont", text = "", secret = false};

	-- Use portrait chat?
	if OptionsManager.isOption("PCHT", "on") then
		if User.isHost() then
			msg.icon = "portrait_gm_token";
		else
			local sActorType, nodeActor = ActorManager.getTypeAndNode(rSource);
			if sActorType == "pc" then
				msg.icon = "portrait_" .. nodeActor.getName() .. "_chat";
			else
				local sIdentity = User.getCurrentIdentity();
				if sIdentity then
					msg.icon = "portrait_" .. User.getCurrentIdentity() .. "_chat";
				end
			end
		end
	end

	-- If actor specified
	if rSource then
		msg.sender = rSource.sName;
		
	-- Otherwise, use provided user name
	elseif sUser then
		msg.sender = sUser;
	
	-- Otherwise, use the current identity or user name
	else
		if User.isHost() then
			msg.sender = GmIdentityManager.getCurrent()
		else
			msg.sender = User.getIdentityLabel();
		end

		if not msg.sender or msg.sender == "" then
			msg.sender = User.getUsername();
		end
	end
	
	-- RESULTS
	return msg;
end

-- Message: prints a message in the Chatwindow
function Message(msgtxt, broadcast, rActor)
	local msg = createBaseMessage(rActor);
	msg.text = msg.text .. msgtxt;

	if broadcast then
		Comm.deliverChatMessage(msg);
	else
		msg.secret = true;
		Comm.addChatMessage(msg);
	end
end

-- SystemMessage: prints a message in the Chatwindow
function SystemMessage(sText)
	local msg = {font = "systemfont"};
	msg.text = sText;
	Comm.addChatMessage(msg);
end

-----------------------
-- WHISPERS
-----------------------

function processWhisper(sCommand, sParams)
	-- Find the target user for the whisper
	local sLowerParams = string.lower(sParams);
	local sGMIdentity = "gm ";

	local sRecipient = nil;
	if string.sub(sLowerParams, 1, string.len(sGMIdentity)) == sGMIdentity then
		sRecipient = "GM";
	else
		for _,vID in ipairs(User.getAllActiveIdentities()) do
			local sIdentity = User.getIdentityLabel(vID);

			local sIdentityMatch = string.lower(sIdentity) .. " ";
			if string.sub(sLowerParams, 1, string.len(sIdentityMatch)) == sIdentityMatch then
				if sRecipient then
					if #sRecipient < #sIdentity then
						sRecipient = sIdentity;
					end
				else
					sRecipient = sIdentity;
				end
			end
		end
	end
	
	local sMessage;
	if sRecipient then
		sMessage = string.sub(sParams, #sRecipient + 2)
	else
		sMessage = sParams;
	end
	
	processWhisperHelper(sRecipient, sMessage);
end

sLastWhisperer = nil;

function processReply(sCommand, sParams)
	if not sLastWhisperer then
		ChatManager.SystemMessage(Interface.getString("error_slashreplytargetmissing"));
		return;
	end
	processWhisperHelper(sLastWhisperer, sParams);
end

function processWhisperHelper(sRecipient, sMessage)
	-- Make sure we have a valid identity and valid user owning the identity
	local sUser = nil;
	local sRecipientID = nil;
	if sRecipient then
		if sRecipient == "GM" then
			sRecipientID = "";
			sUser = "";
		else
			for _,vID in ipairs(User.getAllActiveIdentities()) do
				local sIdentity = User.getIdentityLabel(vID);
				if sIdentity == sRecipient then
					sRecipientID = vID;
					sUser = User.getIdentityOwner(vID);
				end
			end
		end
	end
	if not sRecipientID or not sUser then
		ChatManager.SystemMessage(Interface.getString("error_slashwhispertargetmissing"));
		ChatManager.SystemMessage("Usage: /w GM [message]\rUsage: /w [recipient] [message]");
		return;
	end
	
	-- Check for empty message
	if sMessage == "" then
		ChatManager.SystemMessage(Interface.getString("error_slashwhispermsgmissing"));
		ChatManager.SystemMessage("Usage: /w GM [message]\rUsage /w [recipient] [message]");
		return;
	end
	
	-- Make sure we have a user identity
	local sSender;
	if User.isHost() then
		sSender = "";
	else
		sSender = User.getCurrentIdentity();
		if not sSender then
			ChatManager.SystemMessage(Interface.getString("error_slashwhispersourcemissing"));
			return;
		end
	end
	
	-- Send the whisper
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_WHISPER;
	msgOOB.sender = sSender;
	msgOOB.receiver = sRecipientID;
	msgOOB.text = sMessage;

	if User.isHost() then
		Comm.deliverOOBMessage(msgOOB, { sUser, "" });
	else
		Comm.deliverOOBMessage(msgOOB);
	end
	
	-- Show what the user whispered
	local msg = { font = "whisperfont", sender = "[w]" };
	
	if User.isHost() then
		if OptionsManager.isOption("PCHT", "on") then
			msg.icon = "portrait_gm_token";
		end
		
	else
		if #(User.getOwnedIdentities()) > 1 then
			msg.sender = "[w] " .. User.getIdentityLabel(sSender);
		end
		
		if OptionsManager.isOption("PCHT", "on") then
			msg.icon = "portrait_" .. msgOOB.sender .. "_chat";
		end
	end

	msg.sender = msg.sender .. " -> " .. sRecipient;
	msg.text = sMessage;
	
	Comm.addChatMessage(msg);
end

function handleWhisper(msgOOB)
	-- Validate
	if not msgOOB.sender or not msgOOB.receiver or not msgOOB.text then
		return;
	end

	-- Check to see if GM has asked to see whispers
	if User.isHost() then
		if msgOOB.sender == "" then
			return;
		end
		if msgOOB.receiver ~= "" and OptionsManager.isOption("SHPW", "off") then
			return;
		end
		
	-- Ignore messages not targeted to this user
	else
		if msgOOB.receiver == "" then
			return;
		end
		if not User.isOwnedIdentity(msgOOB.receiver) then
			return;
		end
	end
	
	-- Get the send and receiver labels
	local sSender, sReceiver;
	if msgOOB.sender == "" then
		sSender = "GM";
	else
		sSender = User.getIdentityLabel(msgOOB.sender) or "<unknown>";
	end
	if msgOOB.receiver == "" then
		sReceiver = "GM";
	else
		sReceiver = User.getIdentityLabel(msgOOB.receiver) or "<unknown>";
	end
	
	-- Remember last whisperer
	if not User.isHost() or msgOOB.receiver == "" then
		sLastWhisperer = sSender;
	end
	
	-- Build the message to display
	local msg = { font = "whisperfont", text = "" };
	msg.sender = "[w] " .. sSender;
	if OptionsManager.isOption("PCHT", "on") then
		if msgOOB.sender == "" then
			msg.icon = "portrait_gm_token";
		else
			msg.icon = "portrait_" .. msgOOB.sender .. "_chat";
		end
	end
	if User.isHost() then
		if msgOOB.receiver ~= "" then
			msg.sender = msg.sender .. " -> " .. sReceiver;
		end
	else
		if #(User.getOwnedIdentities()) > 1 then
			msg.sender = msg.sender .. " -> " .. sReceiver;
		end
	end
	msg.text = msg.text .. msgOOB.text;
	
	-- Show whisper message
	Comm.addChatMessage(msg);
end
