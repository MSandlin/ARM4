function AbilityLevel(nLv)
	
	if (nLv == nil) then
        local Levels =
        {
            1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1,
            2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2,
            3, 3, 3, 3, 3, 3, 3, 3,
            4, 4, 4, 5
        };
        nLv = Levels[math.random(#Levels)];
    end
	
	return nLv;
end

function RollCharacteristic()

    return (math.random(3) - math.random(3));

end

function RollSize()
	
    local Levels =
    {
        -2,-1,-1,-1,
         0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 
         0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0,
         1, 1, 1, 2
    };
    nLv = Levels[math.random(#Levels)];
	
	return nLv;
end

function RollAbilities()

    local CombatAbilities =
    {
        "Brawl","Single Weapon","Shield & Weapon","Two Weapons",
        "Great Weapon","Chain Weapon","Longshaft Weapon","Thrown Weapon",
        "Bows","Crossbows","Siege Equipment"
    };
    local GeneralTalents =
    {
        "Athletics","Awareness","Charm","Climb","Folk Ken","Guile","Concentration"
    };
    local RogueAbilities =
    {
        "Disguise","Forgery","Legerdemain","Pick Locks","Stealth"
    };
    local SocialAbilities =
    {
        "Bargain","Carouse","Etiquette","Intrigue","Leadership"
    };
    local WildernessAbilities =
    {
        "Animal Handling","Hunt","Ride","Survival","Swim"
    };
    local WorkAbilities =
    {
        "Boating","Chirurgy","Craft Type*","Wagoneering"
    };               
    local CasualKnowledges =
    {
        "Area* Lore","Organization* Lore","Legend Lore","Speak Language*"
    };

	local sAbilities;
    local n,nLv;
    local e,ee;
    
    nLv = AbilityLevel();
	sAbilities = CombatAbilities[1] .. " " .. nLv;
	ee = -1;
	for n = 1, math.random(2), 1 do
	    nLv = AbilityLevel();
		e = math.random(#CombatAbilities);
		while (e == ee or e == 1) do
		    e = math.random(#CombatAbilities);
		end
	    sAbilities = sAbilities .. ",\n" .. CombatAbilities[e] .. " " .. nLv;
	    ee = e;
	end
	ee = -1;
	for n = 1, math.random(2), 1 do
	    nLv = AbilityLevel();
		e = math.random(#GeneralTalents);
		while (e == ee) do
		    e = math.random(#GeneralTalents);
		end
	    sAbilities = sAbilities .. ",\n" .. GeneralTalents[e] .. " " .. nLv;
	    ee = e;
	end
	ee = -1;
	for n = 1, math.random(0,2), 1 do
	    nLv = AbilityLevel();
		e = math.random(#RogueAbilities);
		while (e == ee) do
		    e = math.random(#RogueAbilities);
		end
	    sAbilities = sAbilities .. ",\n" .. RogueAbilities[e] .. " " .. nLv;
	    ee = e;
	end
	ee = -1;
	for n = 1, math.random(0,2), 1 do
	    nLv = AbilityLevel();
		e = math.random(#SocialAbilities);
		while (e == ee) do
		    e = math.random(#SocialAbilities);
		end
	    sAbilities = sAbilities .. ",\n" .. SocialAbilities[e] .. " " .. nLv;
	    ee = e;
	end
	ee = -1;
	for n = 1, math.random(0,2), 1 do
	    nLv = AbilityLevel();
		e = math.random(#WildernessAbilities);
		while (e == ee) do
		    e = math.random(#WildernessAbilities);
		end
	    sAbilities = sAbilities .. ",\n" .. WildernessAbilities[e] .. " " .. nLv;
	    ee = e;
	end
	ee = -1;
	for n = 1, math.random(0,1), 1 do
	    nLv = AbilityLevel();
		e = math.random(#WorkAbilities);
		while (e == ee) do
		    e = math.random(#WorkAbilities);
		end
	    sAbilities = sAbilities .. ",\n" .. WorkAbilities[e] .. " " .. nLv;
	    ee = e;
	end
    nLv = AbilityLevel(4);
	sAbilities = sAbilities .. ",\nSpeak Own Language " .. nLv;
	ee = -1;
	for n = 1, math.random(0,1), 1 do
	    nLv = AbilityLevel();
		e = math.random(#CasualKnowledges);
		while (e == ee) do
		    e = math.random(#CasualKnowledges);
		end
	    sAbilities = sAbilities .. ",\n" .. CasualKnowledges[e] .. " " .. nLv;
	    ee = e;
	end

    print(sAbilities);
    
    return sAbilities;
end
		

function onDoubleClick()

	window.getDatabaseNode().getChild("str").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("sta").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("pre").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("com").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("int").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("per").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("dex").setValue(RollCharacteristic());
	window.getDatabaseNode().getChild("qik").setValue(RollCharacteristic());
	
	window.getDatabaseNode().getChild("size").setValue(RollSize());

	window.getDatabaseNode().getChild("skills").setValue(RollAbilities());
    	
end
