local playerTags = {}  -- Store player tags
local playerTags2 = {} -- Store second tags

-- Request the server to sync all existing tags when joining
AddEventHandler('onClientMapStart', function()
    print('^3[HeadTags] Client requesting tag sync^7')
    TriggerServerEvent('requestTagSync')
end)

-- Receive updated tag for a specific player
RegisterNetEvent('updateHeadTag')
AddEventHandler('updateHeadTag', function(serverId, tag, tag2)
    print('^3[HeadTags] Received tag update for server ID: ' .. serverId .. '^7')
    print('^3[HeadTags] Tag1: ' .. tostring(tag) .. '^7')
    print('^3[HeadTags] Tag2: ' .. tostring(tag2) .. '^7')
    
    playerTags[serverId] = tag
    playerTags2[serverId] = tag2
end)

-- Main loop to draw head tags
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, ply in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(ply)
            local position = GetEntityCoords(ped)
            local serverId = GetPlayerServerId(ply)
            local name = GetPlayerName(ply)

            -- Get the first and second tags for this player
            local tag = playerTags[serverId]
            local tag2 = playerTags2[serverId]

            -- Construct the headtag text
            local headTagText = "~y~[~w~"..serverId.."~y~]"  -- Always show server ID first

            -- Add first tag if it exists
            if tag then
                headTagText = headTagText .. " ~w~[~w~"..tag.."~w~]"  -- Add first tag after server ID
            end

            -- Add second tag if it exists
            if tag2 then
                headTagText = headTagText .. " ~w~[~r~" .. tag2 .. "~w~]"  -- Add second tag after the first tag
            end

            -- Add the player's name at the end
            headTagText = headTagText .. " ~w~" .. name

            -- Only draw headtag if it exists
            if headTagText then
                local boneCoords = GetPedBoneCoords(ped, 31086, 0.5, 0.0, 0.0)  -- Adjust Z offset to 0.5 (higher)
                
                -- Check if the player is within range to display the headtag
                local onScreen, _x, _y = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y, boneCoords.z)
                local pCoords = GetGameplayCamCoords()
                local dist = #(pCoords - boneCoords)
                if onScreen and dist < 30.0 then  -- Only draw if within range (e.g., 30 meters)
                    DrawHeadTagText(_x, _y, headTagText)
                end
            end
        end
    end
end)

-- Function to draw the head tag on screen
function DrawHeadTagText(x, y, text)
    SetTextScale(0.0, 0.45)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(50, 210, 210, 210, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(x, y)
end