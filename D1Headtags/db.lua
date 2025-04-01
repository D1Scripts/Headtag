local SQL = [[
    CREATE TABLE IF NOT EXISTS player_tags (
        identifier VARCHAR(50) PRIMARY KEY,
        tag1 TEXT,
        tag2 TEXT
    );
]]

-- Initialize database automatically when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Wait(1000) -- Wait for MySQL to be ready
    MySQL.Async.execute(SQL, {}, function(rowsChanged)
        if rowsChanged then
            print('^2[HeadTags] Database initialized successfully^7')
        else
            print('^1[HeadTags] Failed to initialize database^7')
        end
    end)
end)

-- Make functions globally accessible
_G.SavePlayerTags = function(identifier, tag1, tag2)
    if not identifier then 
        print('^1[HeadTags] Error: No identifier provided for SavePlayerTags^7')
        return 
    end
    
    print('^3[HeadTags] Attempting to save tags for ' .. identifier .. '^7')
    print('^3[HeadTags] Tag1: ' .. tostring(tag1) .. '^7')
    print('^3[HeadTags] Tag2: ' .. tostring(tag2) .. '^7')
    
    MySQL.Async.execute('INSERT INTO player_tags (identifier, tag1, tag2) VALUES (@identifier, @tag1, @tag2) ON DUPLICATE KEY UPDATE tag1 = @tag1, tag2 = @tag2',
        {
            ['@identifier'] = identifier,
            ['@tag1'] = tag1,
            ['@tag2'] = tag2
        }, function(affectedRows)
            if affectedRows > 0 then
                print('^2[HeadTags] Tags saved successfully for ' .. identifier .. '^7')
                -- Verify the save by immediately reading back
                MySQL.Async.fetchAll('SELECT tag1, tag2 FROM player_tags WHERE identifier = @identifier',
                    {['@identifier'] = identifier}, function(result)
                        if result and result[1] then
                            print('^2[HeadTags] Verification - Tags in database:^7')
                            print('^2[HeadTags] Tag1: ' .. tostring(result[1].tag1) .. '^7')
                            print('^2[HeadTags] Tag2: ' .. tostring(result[1].tag2) .. '^7')
                        else
                            print('^1[HeadTags] Verification failed - Could not read back tags^7')
                        end
                    end)
            else
                print('^1[HeadTags] Failed to save tags for ' .. identifier .. '^7')
            end
        end)
end

_G.LoadPlayerTags = function(identifier, callback)
    if not identifier then 
        print('^1[HeadTags] Error: No identifier provided for LoadPlayerTags^7')
        if callback then callback(nil, nil) end
        return 
    end
    
    print('^3[HeadTags] Attempting to load tags for ' .. identifier .. '^7')
    
    MySQL.Async.fetchAll('SELECT tag1, tag2 FROM player_tags WHERE identifier = @identifier',
        {['@identifier'] = identifier}, function(result)
            if result and result[1] then
                print('^2[HeadTags] Tags loaded successfully for ' .. identifier .. '^7')
                print('^2[HeadTags] Tag1: ' .. tostring(result[1].tag1) .. '^7')
                print('^2[HeadTags] Tag2: ' .. tostring(result[1].tag2) .. '^7')
                if callback then callback(result[1].tag1, result[1].tag2) end
            else
                print('^3[HeadTags] No tags found for ' .. identifier .. '^7')
                if callback then callback(nil, nil) end
            end
        end)
end 