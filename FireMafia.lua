FireMafia = LibStub("AceAddon-3.0"):NewAddon("FireMafia", "AceEvent-3.0", "AceConsole-3.0")

-- --------------
-- TRACKER
-- --------------
fireDb = {}
function FireMafia:OnEnable()
	FireMafia:RegisterEvent("CHAT_MSG_LOOT")
	FireMafia:RegisterChatCommand("fm", function(args) CommandHandler("fm", args) end )
end

function FireMafia:CHAT_MSG_LOOT(event, Text)
	-- if player looted, log it
    if (string.match(Text,"Elemental Fire")) then
        pName = ParseNameFromLoot(Text)
		pIndex = FindPlayerIndex(pName)
		AddFireDrop(pIndex)		
        return
    end
end

function AddFireDrop(pIndex)
	fireDb[pIndex].Amount = fireDb[pIndex].Amount + 1
	if (UnitInParty("player") == false) then
		print(fireDb[pIndex].Name .. ": " .. fireDb[pIndex].Amount)
	else
		CmdList()
	end
end

function FindPlayerIndex(pName)
	for key,value in pairs(fireDb) do
		if value.Name == pName then
			return key
		end
	end
	
	-- notfound, create new index
	fireDb[#fireDb+1] = {Name = pName, Amount = 0}
	return FindPlayerIndex(pName)
end

function ParseNameFromLoot(Text)
  for word in Text:gmatch("%w+") do
    return word
  end  
end

-- --------------
-- END TRACKER
-- --------------

-- --------------
-- COMMANDS
-- --------------
function CommandHandler(cmd, args)
	if args == "" then
		CmdMain()
	elseif args == "mark" then
		CmdMark()
	elseif args == "range" then
		CmdRange()
	elseif args == "reset" then
		CmdReset()
	elseif args == "list" then
		CmdList()
	else
		print("Command argument was invalid. See below for help.")
		CmdMain()
	end
end

function CmdMain()
	print("Fire Mafia Commands:")
	print("  /fm mark - Targets & marks mobs, use this in macro")
	print("  /fm range - does something if target is in moonfire range")
	print("  /fm reset [pname] - Resets counter for one or all players (!!pname doesnt work yet)")
	print("  /fm list - Shows counter for all players")
end

function CmdReset(pName)
	fireDb = {}
	print("Elemental Fire loot counts have been reset.")
end

function CmdList()
	strDesc = "Showing all Elemental Fire drops:"
	if (UnitInParty("player")) then
		SendChatMessage(strDesc, "PARTY", DEFAULT_CHAT_FRAME.editBox.languageID);
	else
		print(strDesc)	
	end
	
	for key,value in pairs(fireDb) do	
		
		-- Write player name and replace You with self's name
		entryStr = fireDb[key].Name
		if (entryStr == "You") then
		 entryStr = UnitName("player")
		end
		entryStr = entryStr .. ": " .. fireDb[key].Amount
		
		-- Print to party or console
		if (UnitInParty("player")) then
			SendChatMessage(entryStr, "PARTY", DEFAULT_CHAT_FRAME.editBox.languageID);
		else
			print(entryStr)	
		end
	end
end

function CmdMark()
	MarkTarget()
end

function CmdRange()
	RangeHandler()
end

-- --------------
-- END COMMANDS
-- --------------


-- --------------
-- COMBAT
-- --------------

function MarkTarget()
	if GetRaidTargetIndex("target") == nil then
		SetRaidTargetIcon("target", 8)
	end
end

lastRangeCheckTarget = nil
function RangeHandler()
	tarGuid = UnitGUID("target")
	if tarGuid ~= lastRangeCheckTarget and IsSpellInRange("Moonfire", "target") == 1 then
		lastRangeCheckTarget = tarGuid
		PlaySound(120, "master")
	end
end

-- --------------
-- END COMBAT
-- --------------