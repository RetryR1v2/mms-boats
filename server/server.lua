local VORPcore = exports.vorp_core:GetCore()


-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/RetryR1v2/mms-boats/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

      
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('Current Version: %s'):format(currentVersion))
            versionCheckPrint('success', ('Latest Version: %s'):format(text))
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

----------------- Buy Boat Part -------------

RegisterServerEvent('mms-boats:server:buyboat', function(model,name,price)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local price2 = tonumber(price)
    local sellprice = price2 / 2
    local maxboats = 1
    if Character.money >= price2 then
        MySQL.query('SELECT `maxboats` FROM mms_boats WHERE identifier = ?',{identifier} , function(result)
        if result[1] == nil then
            Character.removeCurrency(0, price2)
            MySQL.insert('INSERT INTO `mms_boats` (identifier, name, model, sellprice, maxboats) VALUES (?, ?, ?, ?, ?)', {
            identifier, name, model, sellprice,maxboats
            }, function(id)
            -- print(id)
            end)
            VORPcore.NotifyTip(src, Config.YouBuyedBoat.. name .. Config.For .. price .. Config.DollarBought, 5000)
        elseif result[1].maxboats < Config.MaxBoats then
            local newmaxboats = result[1].maxboats +1
            Character.removeCurrency(0, price2)
            MySQL.insert('INSERT INTO `mms_boats` (identifier, name, model, sellprice, maxboats) VALUES (?, ?, ?, ?, ?)', {identifier, name, model, sellprice, maxboats}, function() end)
            VORPcore.NotifyTip(src, Config.YouBuyedBoat.. name .. Config.For .. price .. Config.DollarBought, 5000)
            MySQL.update('UPDATE `mms_boats` SET maxboats = ? WHERE identifier = ?',{newmaxboats, identifier})
        else
            VORPcore.NotifyTip(src, Config.MaxBoatAmount, 5000)
        end
        end)
    else
        VORPcore.NotifyTip(src, Config.NotEnoghMoney, 5000)
    end
end)


RegisterServerEvent('mms-boats:server:getboatsfromdb',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    MySQL.query('SELECT `name`, `model`, `sellprice` FROM `mms_boats` WHERE `identifier` = ?', {identifier}, function(result)
        if result and #result > 0 then
            local eintraege = {}

            for _, boot in ipairs(result) do
                table.insert(eintraege, boot)
                
            end
                
                TriggerClientEvent('mms-boats:client:meineboote', src, eintraege)
        else
            VORPcore.NotifyTip(src, Config.NoBoats, 5000)
            TriggerClientEvent('mms-boats:client:noboats', src)
        end
    end)

end)

RegisterServerEvent('mms-boats:server:sellboat',function(sellprice, name)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local sellprice2 = tonumber(sellprice)
    MySQL.query('SELECT `maxboats` FROM mms_boats WHERE identifier = ?',{identifier} , function(result)
        local newmaxboats = result[1].maxboats -1
        print(newmaxboats)
        MySQL.update('UPDATE `mms_boats` SET maxboats = ? WHERE identifier = ?',{newmaxboats, identifier})
        
    end)
    MySQL.query('SELECT * FROM mms_boats WHERE identifier = ?', {identifier}, function(result)
        if result ~= nil then
            MySQL.execute('DELETE FROM mms_boats WHERE identifier = ? AND name = ?', { identifier, name }, function()
            end)
            Character.addCurrency(0, sellprice2)
            VORPcore.NotifyTip(src, Config.BoatFor .. sellprice2 .. Config.DollarSold,  5000)
        else
            VORPcore.NotifyTip(src, 'Error no Boats in Database ( Database Error)!',  5000)
        end
    end)
    
end)




--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()