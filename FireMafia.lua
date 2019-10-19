FireMafia = LibStub("AceAddon-3.0"):NewAddon("FireMafia", "AceEvent-3.0")

fireDb = {}


function FireMafia:OnEnable()
	FireMafia:RegisterEvent("CHAT_MSG_LOOT")
end

function FireMafia:CHAT_MSG_LOOT(event, Text)
	-- if player looted fire
    --if (string.find(Text,"Burning Pitch")) then
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
	newIndex = table.getn(fireDb)
	fireDb[newIndex] = {Name = pName, Amount = 0}
	return newIndex
end

function ParseNameFromLoot(Text)
  for word in Text:gmatch("%w+") do
    return word
  end  
end