local staffHeadTag = nil  -- Store the staff tag for the player

-- Event to update the staff tag on the client
RegisterNetEvent('updateStaffTag')
AddEventHandler('updateStaffTag', function(tag)
    -- Update the local staff tag based on the server's state
    staffHeadTag = tag
end)

-- Draw head tag with the staff tag if available
function DrawHeadTagText(position, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z + 0.35)
    local pCoords = GetGameplayCamCoords()
    local dist = #(pCoords - position)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(50, 210, 210, 210, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Main loop to check all players and draw the head tag
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for _, ply in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(ply)
            local position = GetEntityCoords(ped)
            local serverId = GetPlayerServerId(ply)
            local disableHeadTag = Player(serverId).state.disableHeadTag
            local customHeadTag = Player(serverId).state.customHeadTag

            if not disableHeadTag then
                local dist = #(GetEntityCoords(PlayerPedId()) - position)

                if dist < 18 and HasEntityClearLosToEntity(PlayerPedId(), ped, 17) then
                    local boneCoords = GetPedBoneCoords(ped, 31086, 0, 0, 0)
                    local name = GetPlayerName(ply)

                    -- Draw the head tag with the staff tag if set
                    if staffHeadTag then
                        if NetworkIsPlayerTalking(ply) then
                            DrawHeadTagText(boneCoords, "~y~[~w~"..staffHeadTag.."~y~] ~y~[~g~"..serverId.."~y~] ~y~[~w~"..name.."~y~]")
                        else
                            DrawHeadTagText(boneCoords, "~y~[~w~"..staffHeadTag.."~y~] ~y~[~w~"..serverId.."~y~] ~y~[~w~"..name.."~y~]")
                        end
                    else
                        if NetworkIsPlayerTalking(ply) then
                            DrawHeadTagText(boneCoords, "~y~[~g~"..serverId.."~y~] "..(customHeadTag and "~y~[~w~"..customHeadTag.."~y~]" or "").." ~y~[~w~"..name.."~y~]")
                        else
                            DrawHeadTagText(boneCoords, "~y~[~w~"..serverId.."~y~] "..(customHeadTag and "~y~[~w~"..customHeadTag.."~y~]" or "").." ~y~[~w~"..name.."~y~]")
                        end
                    end
                end
            end
        end
    end
end)