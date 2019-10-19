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
	print(Text)
    --if (string.match(Text,"Elemental Fire")) then
        pName = ParseNameFromLoot(Text)
		pIndex = FindPlayerIndex(pName)
		AddFireDrop(pIndex)		
        return
    --end
end

function AddFireDrop(pIndex)
	fireDb[pIndex].Amount = fireDb[pIndex].Amount + 1
	print(fireDb[pIndex].Name .. ": " .. fireDb[pIndex].Amount)
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
	elseif args == "reset" then
		CmdReset()
	elseif args == "list" then
		CmdList()
	elseif args == "mark" then
		CmdMark()
	else
		print("Command argument was invalid. See below for help.")
		CmdMain()
	end
end

function CmdMain()
	print("Fire Mafia Commands:")
	print("  /fm reset [pname] - Resets counter for one or all players (!!pname doesnt work yet)")
	print("  /fm list - Shows counter for all players")
	print("  /fm mark - Targets & marks mobs, use this in macro")
end

function CmdReset(pName)
	fireDb = {}
	print("Elemental Fire loot counts have been reset.")
end

function CmdList()
	print("Showing all entries:")
	for key,value in pairs(fireDb) do		
		print(fireDb[key].Name .. ": " .. fireDb[key].Amount)
	end
end

function CmdMark()
	MarkTarget()
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

-- --------------
-- END COMBAT
-- --------------