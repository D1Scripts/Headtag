local staffTags = {}  -- Store staff tags per player

-- When a player connects, we will send their current staff tag if they have one
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local playerId = source
    -- Check if this player has a staff tag and send it to the client
    if staffTags[playerId] then
        TriggerClientEvent('updateStaffTag', playerId, staffTags[playerId])
    end
end)

-- Handle setting the staff tag
RegisterNetEvent('setStaffTag')
AddEventHandler('setStaffTag', function(serverId, tag)
    local playerId = source
    -- Ensure that only the player who owns the serverId can set the staff tag
    if playerId == serverId then
        -- Save the staff tag for this player
        staffTags[serverId] = tag
        -- Notify the client to update the tag
        TriggerClientEvent('updateStaffTag', serverId, tag)
    end
end)

-- Handle removing the staff tag
RegisterNetEvent('removeStaffTag')
AddEventHandler('removeStaffTag', function(serverId)
    local playerId = source
    -- Ensure that only the player who owns the serverId can remove the staff tag
    if playerId == serverId then
        -- Remove the staff tag for this player
        staffTags[serverId] = nil
        -- Notify the client to remove the staff tag
        TriggerClientEvent('updateStaffTag', serverId, nil)
    end
end)

-- Listen for when the player sends the staff tag toggle request from the client
RegisterCommand("tagst", function(source, args, rawCommand)
    local serverId = source  -- Use 'source' to get the serverId (player's unique ID)

    -- Check if the player already has a staff tag
    if staffTags[serverId] == "Staff" then
        -- Remove the staff tag
        staffTags[serverId] = nil
        -- Notify the client to remove the staff tag
        TriggerClientEvent('updateStaffTag', serverId, nil)
        TriggerClientEvent('chat:addMessage', serverId, { args = { "System", "Your staff tag has been removed." } })
    else
        -- Set the staff tag
        staffTags[serverId] = "Staff"
        -- Notify the client to set the staff tag
        TriggerClientEvent('updateStaffTag', serverId, "Staff")
        TriggerClientEvent('chat:addMessage', serverId, { args = { "System", "Your staff tag has been set to 'Staff'." } })
    end
end, false)