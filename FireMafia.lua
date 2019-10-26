FireMafia = LibStub("AceAddon-3.0"):NewAddon("FireMafia", "AceEvent-3.0", "AceConsole-3.0")

-- --------------
-- TRACKER
-- --------------
fireDb = {}
function FireMafia:OnEnable()
	FireMafia:RegisterEvent("CHAT_MSG_LOOT")
	FireMafia:RegisterEvent("TRADE_ACCEPT_UPDATE")
	FireMafia:RegisterChatCommand("fm", function(args) CommandHandler("fm", args) end )
end


local ignoreDrops = 0
function FireMafia:CHAT_MSG_LOOT(event, Text)
	-- if player looted, log it
    if (string.match(Text,"Elemental Fire")) then
		-- Ignore "drop" resulting from trade
		if (ignoreDrops > 0) then
			ignoreDrops = ignoreDrops -1
			return
		end
		
		-- Add the drop
        pName = ParseNameFromLoot(Text)
		pIndex = FindPlayerIndex(pName)
		fCount = ParseCountFromLoot(Text)
		AddFireDrop(pIndex, fCount)		
        return
    end
end

function AddFireDrop(pIndex, fCount, silent)
	fireDb[pIndex].Amount = fireDb[pIndex].Amount + fCount
	if (silent ~= true) then
		if (UnitInParty("player") == false) then
			print(fireDb[pIndex].Name .. ": " .. fireDb[pIndex].Amount)
		else
			CmdList()
		end
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

function ParseCountFromLoot(Text)
  for word in Text:gmatch("%d+") do
	if tonumber(word) <= 10 then -- string that turns chat white should be ignored. this is dodgy tho, dont use this for non-white items
		return word
	end
  end
  return 1
end

-- --------------
-- END TRACKER
-- --------------

-- --------------
-- TRADE HANDLER
-- --------------

-- triggers when trade goes through - 
-- BUG IN API: seems to not work if you're first to accept the trade
function FireMafia:TRADE_ACCEPT_UPDATE(_, playerAccepted, targetAccepted)
	-- if player looted, log it
    if (playerAccepted == 1 and targetAccepted == 1) then -- trade went through
		playerIndex = FindPlayerIndex(UnitName("player"))
		targetIndex = FindPlayerIndex(UnitName("NPC"))
		
		-- handle given
		given = TradeCountFire(0)
		AddFireDrop(playerIndex, tonumber("-"..given), true)
		AddFireDrop(targetIndex, given, true)
		
		-- handle taken
		taken = TradeCountFire(1)
		AddFireDrop(playerIndex, taken, true)
		AddFireDrop(targetIndex, tonumber("-"..taken), true)
		
		-- Show updated list
		CmdList()
    end
end

function TradeCountFire(who)
	total = 0
	
	-- Count fire being traded
	for i = 1, 6, 1 do -- check each slot
		itemName, _, amount = rGetTradeItemInfo(who, i)
		if itemName == "Elemental Fire" then
			total = total + amount
			
			-- Amount of "drops" to ignore after trade receive
			if (who == 1) then 
				ignoreDrops = ignoreDrops + 1
			end
		end
	end
	
	-- Value gold as fire at fixed rate
	moneyInput = 0
	fireGoldRate = 40000 --4g
	if who == 0 then
		moneyInput = GetPlayerTradeMoney()
	else	
		moneyInput = GetTargetTradeMoney()
	end
print(moneyInput)
	if (moneyInput > 0) then
		total = total + (moneyInput / fireGoldRate)
	end
	
	return total
end

function rGetTradeItemInfo(who, slot)
	-- Run the correct function depending on slot
	if who == 0 then
		return GetTradePlayerItemInfo(slot)
	else
		return GetTradeTargetItemInfo(slot)
	end
end
-- --------------
-- END TRADE HANDLER
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