
-- Add items here to make them unshared. Names are from here:
-- https://saturnyoshi.gitlab.io/RoRML-Docs/misc/objects.html?highlight=clover#vanilla-objects
local not_shared_items = {"Clover"}


-- Build interactables in the game for using later.
-- Cache original spawn cost
local interactables = {}
callback.register("postLoad", function()

	for _, interactable in ipairs(Interactable.findAll()) do
		interactables[interactable] = interactable.spawnCost
	end
	
end)

local playerCount = 1
-- Detect number of players
callback.register("globalRoomEnd", function(room)
	if not misc.getIngame() then
		local count = 1
		if room == Room.find("SelectMult") then
			count = Object.findAll("PrePlayer")
		elseif room == Room.find("SelectCoop") then
			local sCoop = Object.find("SelectCoop")
			if sCoop and sCoop:isValid() then
				count = sCoop:get("player_max_chosen")
			end
		end
		if count > 0 then
			playerCount = count
		end
	end
end)

-- Adjust spawn costs to number of players
-- Note that spawnCost is cached, so it will stay as the original value
-- preventing continual multiplication as more games are started. 
callback.register("onGameStart", function()
	log("Adjusting spawn cost to prior spawn cost * PlayerCount. PlayerCount:")
	log(playerCount)
	for interactable, spawnCost in pairs(interactables) do
		interactable.spawnCost = spawnCost * playerCount
	end
end)

-- if an item is picked by a player
-- all the others get the item too
registercallback("onItemPickup", function(item_inst, player)
	local item = item_inst:getItem()
	
	for index, a_item_name in ipairs(not_shared_items) do
		if item.displayName == a_item_name then
			log("Not Shared")
			log(item.displayName)
			return
		end
	end
	
	for index, a_player in ipairs(misc.players) do
		if a_player ~= nil and a_player:isValid() then
			if player ~= a_player and item.isUseItem == false then
				a_player:giveItem(item, 1)
			end
		end
	end
end)
