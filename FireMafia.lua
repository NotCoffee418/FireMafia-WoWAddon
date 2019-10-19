FireMafia = LibStub("AceAddon-3.0"):NewAddon("FireMafia", "AceEvent-3.0")

fireDb = {}

function FireMafia:OnEnable()
	FireMafia:RegisterEvent("CHAT_MSG_LOOT")
end

function FireMafia:CHAT_MSG_LOOT(event, Text)
	-- if player looted, log it
	print(Text)
    if (string.match(Text,"Elemental Fire")) then
        pName = ParseNameFromLoot(Text)
		pIndex = FindPlayerIndex(pName)
		AddFireDrop(pIndex)		
        return
		DebugPrintDb()
    end
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

function DebugPrintDb()
	print("Showing all entries")
	for key,value in pairs(fireDb) do		
		print(fireDb[key].Name .. ": " .. fireDb[key].Amount)
	end
end