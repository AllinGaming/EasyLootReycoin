local f = CreateFrame("frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
local function iPrint(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffd5a6bd[SoM] |cff52b627" ..msg, 1, 0, 0)
end

local gfind = string.gmatch or string.gfind
local auctionEnds = -1
local auctionItem = nil
local auctionState = "none" -- must be either "none", "link", "raid", "chunk"
local auctionCounterInit = 11
local arrayIndex = 1
local updateInterval = 1 
local lastUpdate = 0 
local a = {}
local memberWinnerName = "_NONE_"
local memberWinnerRoll = 0
local memberRollType = 0
local nlootText = "ROLL NOW!"
for i=1, 50 do
	a[i] = ""
end
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function onUpdate()	
	lastUpdate = lastUpdate + arg1 -- elapsed = arg1

	if lastUpdate < updateInterval then return end  
	lastUpdate = 0  		

	if auctionEnds < 0 then return end

	if auctionEnds == auctionCounterInit then
		if auctionState == "link" then
			-- lua equivalent to conditional operator: IsRaidLeader() or IsRaidOfficer() ? "RAID_WARNING" : "RAID"
			local channel = (IsRaidLeader() or IsRaidOfficer()) and "RAID_WARNING" or "RAID"
			local countdownNum = auctionCounterInit - 1
			SendChatMessage("ROLLING FOR: "..auctionItem..". REYCOINERS /ROLL 101 NOW! "..countdownNum.." second countdown!", channel)
		elseif auctionState == "chunk" then
			-- lua equivalent to conditional operator: IsRaidLeader() or IsRaidOfficer() ? "RAID_WARNING" : "RAID"
			local channel = (IsRaidLeader() or IsRaidOfficer()) and "RAID_WARNING" or "RAID"
			local countdownNum = auctionCounterInit - 1
			SendChatMessage("--- MS /roll 100 || OS /roll 99 || Tmog /roll 98 ---"..auctionItem.." ROLL NOW! "..countdownNum.." second countdown!", channel)
		end
	elseif auctionEnds < 6 and auctionEnds > 0 then
		SendChatMessage(tostring(auctionEnds), "RAID")
	elseif auctionEnds == 0 then
		if auctionState == "link" then
			SendChatMessage("Reycoin rolling ended.", "RAID")
			iPrint(auctionItem..string.format(" |cff52b627winner |cffef6dac%s|cff52b627 rolled |cffffffff%s |cff52b627with a |cffffffff(1-%s)!", memberWinnerName, memberWinnerRoll, memberRollType))
			memberWinnerName = "_NONE_"
			memberWinnerRoll = 0
			memberRollType = 0
			arrayIndex = 1
			for k in pairs (a) do
				a [k] = nil
			end
			auctionState = "none"
		elseif auctionState == "chunk" then
			local rollTypeText = "_NONE_"
			if memberRollType == 98 then
				rollTypeText = "TMOG"
			elseif memberRollType == 99 then
				rollTypeText = "OS"
			elseif memberRollType == 100 then
				rollTypeText = "MS"
			elseif memberRollType == 102 then
				rollTypeText = "SR"
			end
			if rollTypeText == "_NONE_" then
				SendChatMessage(auctionItem.." DISENCHANT.", "RAID")
			else
				SendChatMessage(auctionItem.." winner "..memberWinnerName.."with a "..rollTypeText.." roll of "..memberWinnerRoll.."!", "RAID")				
			end
			memberWinnerName = "_NONE_"
			memberWinnerRoll = 0
			memberRollType = 0
			arrayIndex = 1
			for k in pairs (a) do
				a [k] = nil
			end
			auctionState = "none"
			nlootText = "ROLL NOW!"
		end
	end

  auctionEnds = auctionEnds - 1	
end

local function isempty(s)
	return s == nil
  end

local function onEvent() 	
	if event == "CHAT_MSG_SYSTEM" and auctionState == "link" then
		local meme = string.find(arg1, "%(1%-101%)")		
		local rolltip = 101	
		local startIndex,_,roll = string.find(arg1, " rolls (.+)% [(][0-9]+-[0-9]+[)]")
		local memberName = string.sub(arg1, 1, startIndex)
		if not meme then iPrint(memberName.." WRONG ROLL TYPE, PLEASE /ROLL 101!") return end

		if has_value(a, memberName) then 
			iPrint(memberName.." rolled again. REROLL IGNORED!")
			return
		end
		a[arrayIndex] = memberName
		arrayIndex = arrayIndex + 1
		if rolltip == memberRollType then
			if tonumber(roll) > memberWinnerRoll then
				memberWinnerRoll = tonumber(roll)
				memberWinnerName = memberName
				memberRollType = rolltip
			elseif tonumber(roll) == memberWinnerRoll then
				SendChatMessage(memberName.." tied with "..memberWinnerName..". Rolled:"..memberWinnerRoll, "RAID")
			end
		end
		if rolltip > memberRollType then
			memberWinnerRoll = tonumber(roll)
			memberWinnerName = memberName
			memberRollType = rolltip
		end
	elseif event == "CHAT_MSG_SYSTEM" and auctionState == "chunk" then
		local meme = string.find(arg1, "%(1%-101%)")		
		local memeSr = string.find(arg1, "%(1%-102%)")		
		local memeMs = string.find(arg1, "%(1%-100%)")
		local memeOs = string.find(arg1, "%(1%-99%)")		
		local memeTmog = string.find(arg1, "%(1%-98%)")
		local rolltip = 97	
		if memeSr ~= nil then
			iPrint(arg1.." WRONG ROLL")
			return
		elseif meme ~= nil then
			iPrint(arg1.." WRONG ROLL")
			return
		elseif memeMs ~= nil then
			rolltip = 100
		elseif memeOs ~= nil then
			rolltip = 99
		elseif memeTmog ~= nil then
			rolltip = 98
		else 
			iPrint("INVALID ROLL")
			return
		end
		local startIndex,_,roll = string.find(arg1, " rolls (.+)% [(][0-9]+-[0-9]+[)]")
		local memberName = string.sub(arg1, 1, startIndex)
		if has_value(a, memberName) then 
			SendChatMessage(memberName.." rolled again. REROLL IGNORED!", "RAID")
			return
		end
		a[arrayIndex] = memberName
		arrayIndex = arrayIndex + 1
		if rolltip == memberRollType then
			if tonumber(roll) > memberWinnerRoll then
				memberWinnerRoll = tonumber(roll)
				memberWinnerName = memberName
				memberRollType = rolltip
			elseif tonumber(roll) == memberWinnerRoll then
				SendChatMessage(memberName.." tied with "..memberWinnerName..". Rolled:"..memberWinnerRoll, "RAID")
			end
		end
		if rolltip > memberRollType then
			memberWinnerRoll = tonumber(roll)
			memberWinnerName = memberName
			memberRollType = rolltip
		end
	elseif event == "CHAT_MSG_SYSTEM" and auctionState == "raid" then		
		local _,_,roll = string.find(arg1, UnitName("player").." rolls (.+)% [(][0-9]+-[0-9]+[)]")		
		
		-- something went wrong
		if not roll then iPrint("Roll couldn't be parsed, please contact author!"); return end 
		
		SendChatMessage(string.format("Raid member #%s is %s!", roll, UnitName("raid"..roll)), "RAID")			
		auctionState = "none"
	end
end

local function start(msg, state) 
	if not (auctionEnds < 0 and auctionState == "none") then
		iPrint("Please wait for current item distribution to end!")
	elseif not msg or string.len(msg) == 0 then
		iPrint("Please specifiy an item to distribute!")
	else
		local commandlist = { }
		local command
		for command in gfind(msg, "[^_]+") do
			table.insert(commandlist, command)
		end
		auctionItem = commandlist[1]
		auctionCounterInit = tonumber(commandlist[2]) + 1
		auctionEnds = auctionCounterInit
		auctionState = state
		lastUpdate = updateInterval
	end
end

local function testeee(msg, state) 
	for weew in string.gmatch(example, "%S+") do
		iPrint(weew)
	end
end

SLASH_REY1 = '/reycoin'
function SlashCmdList.REY(msg, editbox)	
	start(msg, "link")
end

SLASH_NLOOTMSG1 = '/nlootmsg'
function SlashCmdList.NLOOT(msg, editbox)	
	nlootText = msg
end

SLASH_MANUALEND1 = '/nend'
function SlashCmdList.MANUALEND(msg, editbox)	
	iPrint(" winner "..memberWinnerName.."!")
	iPrint(string.format("%s with a (1-%s)", memberWinnerRoll, memberRollType))
	auctionEnds = -1
	memberWinnerName = "_NONE_"
	memberWinnerRoll = 0
	memberRollType = 0
	arrayIndex = 1
	for k in pairs (a) do
		a [k] = nil
	end
	auctionState = "none"
	nlootText = "ROLL NOW!"
end

SLASH_SOMR1 = '/rollrules'
function SlashCmdList.SOMR(msg, editbox)	
	SendChatMessage("SoM - RULES FOR ROLLING IN RAID CHAT!", "RAID_WARNING")
	SendChatMessage("SR - /roll 102", "RAID")
	SendChatMessage("REYCOIN - /roll 101", "RAID")
	SendChatMessage("MS - /roll 100", "RAID")
	SendChatMessage("OS - /roll 99", "RAID")
	SendChatMessage("TMOG - /roll 98", "RAID")
end

SLASH_COIN1 = '/coinrules'
function SlashCmdList.COIN(msg, editbox)	
	SendChatMessage("xXx REYCOIN RULES IN RAID CHAT! xXx", "RAID_WARNING")
	SendChatMessage("Takes priority over MS but below SR.", "RAID")
	SendChatMessage("Earned by attending a SPECIFIC raid.", "RAID")
	SendChatMessage("Can have only one!", "RAID")
	SendChatMessage("You do not lose the coin unless you win the roll!", "RAID")	
	SendChatMessage("Expires on raid end!", "RAID")
end

SLASH_MASTERLOOTING1 = '/nloot'
function SlashCmdList.MASTERLOOTING(msg, editbox)	
	start(msg, "chunk")
end

SLASH_RAIDROLLING1, SLASH_RAIDROLLING2 = "/raidroll", "/rr"
function SlashCmdList.RAIDROLLING(msg, editbox)
	if not (auctionState == "none") then
		iPrint("Please wait for current item distribution to end!")
		return
	end

	auctionState = "raid"
	
	if msg then SendChatMessage("RANDOM ROLLING "..msg, "RAID") end
		
	RandomRoll(1, GetNumRaidMembers())
end

f:SetScript("OnUpdate", onUpdate)
f:SetScript("OnEvent", onEvent)