local playerTags = {}  -- Store player tags
local playerTags2 = {} -- Store second tags

-- Load player tags when they fully join
AddEventHandler('playerJoining', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0) -- Get the primary identifier
    local playerName = GetPlayerName(source)
    
    if identifier then
        print('^3[HeadTags] Loading tags for player: ' .. playerName .. ' (ID: ' .. identifier .. ')^7')
        LoadPlayerTags(identifier, function(tag1, tag2)
            if tag1 then 
                playerTags[source] = tag1 
                print('^2[HeadTags] Loaded tag1 for ' .. playerName .. ': ' .. tag1 .. '^7')
            end
            if tag2 then 
                playerTags2[source] = tag2 
                print('^2[HeadTags] Loaded tag2 for ' .. playerName .. ': ' .. tag2 .. '^7')
            end
            
            -- Sync tags to the player
            TriggerClientEvent('updateHeadTag', source, source, tag1, tag2)
            print('^3[HeadTags] Synced tags to player: ' .. playerName .. '^7')
        end)
    else
        print('^1[HeadTags] Failed to get identifier for player: ' .. playerName .. '^7')
    end
end)

-- Request the server to sync all existing tags when joining
RegisterNetEvent('requestTagSync')
AddEventHandler('requestTagSync', function()
    local serverId = source
    print('^3[HeadTags] Player ' .. GetPlayerName(serverId) .. ' requested tag sync^7')
    
    for id, tag in pairs(playerTags) do
        print('^3[HeadTags] Syncing tag for player ' .. GetPlayerName(id) .. ': ' .. tag .. '^7')
        TriggerClientEvent('updateHeadTag', serverId, id, tag, playerTags2[id])
    end
end)

-- Set the first tag
RegisterCommand("settag", function(source, args, rawCommand)
    local serverId = source
    local tag = table.concat(args, " ")
    local identifier = GetPlayerIdentifier(serverId, 0)
    local playerName = GetPlayerName(serverId)

    print('^3[HeadTags] Attempting to set tag for player: ' .. playerName .. '^7')
    print('^3[HeadTags] Server ID: ' .. serverId .. '^7')
    print('^3[HeadTags] Identifier: ' .. tostring(identifier) .. '^7')
    print('^3[HeadTags] Tag to set: ' .. tag .. '^7')

    if tag and tag ~= "" and identifier then
        -- First verify if the player already has tags
        LoadPlayerTags(identifier, function(existingTag1, existingTag2)
            print('^3[HeadTags] Existing tags - Tag1: ' .. tostring(existingTag1) .. ', Tag2: ' .. tostring(existingTag2) .. '^7')
            
            playerTags[serverId] = tag
            SavePlayerTags(identifier, tag, playerTags2[serverId])
            print('^2[HeadTags] Set tag1 for ' .. playerName .. ': ' .. tag .. '^7')

            -- Verify the save immediately
            LoadPlayerTags(identifier, function(verifyTag1, verifyTag2)
                print('^3[HeadTags] Verification after save - Tag1: ' .. tostring(verifyTag1) .. ', Tag2: ' .. tostring(verifyTag2) .. '^7')

                -- Send tag update to all players
                TriggerClientEvent('updateHeadTag', -1, serverId, tag, playerTags2[serverId])
                print('^3[HeadTags] Sent tag update to all players^7')
            end)
        end)
    else
        print('^1[HeadTags] Failed to set tag for ' .. playerName .. ' - Invalid tag or missing identifier^7')
        TriggerClientEvent('chat:addMessage', serverId, {
            color = {255, 0, 0},
            args = {'[HeadTags]', 'Please provide a tag to set'}
        })
    end
end, false)

-- Set the second tag
RegisterCommand("settag2", function(source, args, rawCommand)
    local serverId = source
    local tag2 = table.concat(args, " ")
    local identifier = GetPlayerIdentifier(serverId, 0)
    local playerName = GetPlayerName(serverId)

    print('^3[HeadTags] Attempting to set tag2 for player: ' .. playerName .. '^7')
    print('^3[HeadTags] Server ID: ' .. serverId .. '^7')
    print('^3[HeadTags] Identifier: ' .. tostring(identifier) .. '^7')
    print('^3[HeadTags] Tag2 to set: ' .. tag2 .. '^7')

    if tag2 and tag2 ~= "" and identifier then
        -- First verify if the player already has tags
        LoadPlayerTags(identifier, function(existingTag1, existingTag2)
            print('^3[HeadTags] Existing tags - Tag1: ' .. tostring(existingTag1) .. ', Tag2: ' .. tostring(existingTag2) .. '^7')
            
            playerTags2[serverId] = tag2
            SavePlayerTags(identifier, playerTags[serverId], tag2)
            print('^2[HeadTags] Set tag2 for ' .. playerName .. ': ' .. tag2 .. '^7')

            -- Verify the save immediately
            LoadPlayerTags(identifier, function(verifyTag1, verifyTag2)
                print('^3[HeadTags] Verification after save - Tag1: ' .. tostring(verifyTag1) .. ', Tag2: ' .. tostring(verifyTag2) .. '^7')

                -- Send tag update to all players
                TriggerClientEvent('updateHeadTag', -1, serverId, playerTags[serverId], tag2)
                print('^3[HeadTags] Sent tag update to all players^7')
            end)
        end)
    else
        print('^1[HeadTags] Failed to set tag2 for ' .. playerName .. ' - Invalid tag or missing identifier^7')
        TriggerClientEvent('chat:addMessage', serverId, {
            color = {255, 0, 0},
            args = {'[HeadTags]', 'Please provide a tag to set'}
        })
    end
end, false)

-- Clean up tags when player disconnects
AddEventHandler('playerDropped', function()
    local source = source
    playerTags[source] = nil
    playerTags2[source] = nil
end)