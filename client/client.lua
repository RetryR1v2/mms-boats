local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local FeatherMenu =  exports['feather-menu'].initiate()

local pageopened = 0
local boatSpawned = false
local spawncoords = nil
local boatheading = nil
local getboats = 0
---------------------------------------------------------------------------------
Citizen.CreateThread(function()
local BoatTraderPrompt = BccUtils.Prompts:SetupPromptGroup()
    local traderprompt = BoatTraderPrompt:RegisterPrompt(Config.PromptName, 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    if Config.TraderBlips then
        for h,v in pairs(Config.Prompts) do
        blip = BccUtils.Blips:SetBlip(Config.TraderblipName, 'blip_ambient_riverboat', 0.2, v.coords.x,v.coords.y,v.coords.z)
        end
    end
    if Config.NPC == true then
        for h,v in pairs(Config.Prompts) do
        local ped = BccUtils.Ped:Create('u_f_m_tumgeneralstoreowner_01', v.coords.x, v.coords.y, v.coords.z -1, 0, 'world', false)
        ped:Freeze()
        ped:SetHeading(v.npcheading)
        ped:Invincible()
        end
    end
    while true do
        Wait(1)
        for h,v in pairs(Config.Prompts) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - v.coords)
        if dist < 2 then
            BoatTraderPrompt:ShowGroup(Config.PromptName)

            --BccUtils.Misc.DrawText3D(plantcoords.x, plantcoords.y, plantcoords.z, _U('WaterCropPrompt'))
            if traderprompt:HasCompleted() then
                TriggerEvent('mms-boats:client:opentrader') break
            end
        end
    end
    end
end)
RegisterNetEvent('mms-boats:client:opentrader')
AddEventHandler('mms-boats:client:opentrader',function()
    BootTrader:Open({
        startupPage = BootTraderPage1,
    })
end)


---------------------------------------------------------------------------------------------------------
--------------------------------------- SEITE 1 Hauptmenü------------------------------------------------
---------------------------------------------------------------------------------------------------------


Citizen.CreateThread(function()  --- RegisterFeather Menu
    BootTrader = FeatherMenu:RegisterMenu('feather:character:boottradermenu', {
        top = '50%',
        left = '50%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '8000px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '550px'
            }
        },
        draggable = true,
    })
    BootTraderPage1 = BootTrader:RegisterPage('seite1')
    BootTraderPage1:RegisterElement('header', {
        value = Config.BoatTrader,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage1:RegisterElement('button', {
        label = Config.BuyBoats,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        if pageopened == 0 then
            TriggerEvent('mms-boats:client:kaufeboote')
            Citizen.Wait(250)
        elseif pageopened == 1 then
            BootTraderPage2:RouteTo()
        end
    end)
    BootTraderPage1:RegisterElement('button', {
        label = Config.MyBoats,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        if getboats == 0 then
            TriggerEvent('mms-boats:client:getboatsfromdb')
            Citizen.Wait(250)
        elseif getboats == 1 then
            BootTraderPage3:UnRegister()
            TriggerEvent('mms-boats:client:getboatsfromdb')
        
        end
    end)
    BootTraderPage1:RegisterElement('button', {
        label = Config.StoreBoat,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        StoreBoat()
    end)
    BootTraderPage1:RegisterElement('button', {
        label =  Config.CloseTrader,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BootTrader:Close({ 
        })
    end)
    BootTraderPage1:RegisterElement('subheader', {
        value = Config.BoatTrader,
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })


end)

---------------------------------------------------------------------------------------------------------
--------------------------------------- SEITE 2 Boote Kaufen---------------------------------------------
---------------------------------------------------------------------------------------------------------

RegisterNetEvent('mms-boats:client:kaufeboote')
AddEventHandler('mms-boats:client:kaufeboote',function()
    ----- Seite 2 Boote Kaufen

    BootTraderPage2 = BootTrader:RegisterPage('seite2')
    BootTraderPage2:RegisterElement('header', {
        value = Config.BoatTrader,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for _, v in ipairs(Config.Boats) do
        local buttonLabel =  v.name .. Config.Price .. v.price ..'$'
        local model = v.model
        local name = v.name
        local price = v.price
        local storage = v.storage
        BootTraderPage2:RegisterElement('button', {
            label = buttonLabel,
            style = {
                ['background-color'] = '#FF8C00',
                ['color'] = 'orange',
                ['border-radius'] = '6px'
            }
        }, function()
            TriggerEvent('mms-boats:client:buyboat',model,name,price,storage)
        end)
    end
    BootTraderPage2:RegisterElement('button', {
        label =  Config.BackTrader,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BootTraderPage1:RouteTo()
    end)
    BootTraderPage2:RegisterElement('button', {
        label =  Config.CloseTrader,
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BootTrader:Close({ 
        })
    end)
    BootTraderPage2:RegisterElement('subheader', {
        value = Config.BoatTrader,
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BootTraderPage2:RouteTo()
    pageopened = 1
end)


---------------------------- Buy Boat Event ------------------------------

RegisterNetEvent('mms-boats:client:buyboat')
AddEventHandler('mms-boats:client:buyboat',function(model,name,price,storage)
    for _,v in ipairs(Config.Prompts) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - v.boatspawn)
        if dist <= 50 then 
            spawncoords = v.boatspawn
            boatheading = v. boatheading
        end
    end
    if boatSpawned == false then
        local ped = PlayerPedId()
        local boathash = model
        RequestModel(boathash)
        while not HasModelLoaded(boathash) do
            Citizen.Wait(0)
        end
        boat = CreateVehicle(boathash, spawncoords,boatheading, true, false)
        SetVehicleOnGroundProperly(boat)
        SetEntityAsMissionEntity(boat,true,true)
        SetVehicleCanBreak(boat,false)
        Wait(200)
        --SetPedIntoVehicle(ped, boat, -1)
        SetModelAsNoLongerNeeded(boathash)
        FreezeEntityPosition(boat,true)
        boatSpawned = true
        local alert = lib.alertDialog({
            header = Config.BuyBoat,
            content = Config.WannaBuyBoat .. name .. Config.Really,
            centered = true,
            cancel = true,
            labels = {cancel = Config.No,confirm = Config.Yes}
        })
        if alert =='confirm' then
            DeleteVehicle(boat)
            boatSpawned = false
            BootTraderPage1:RouteTo()
            TriggerServerEvent('mms-boats:server:buyboat',model,name,price,storage)
        elseif alert == 'cancel' then
            DeleteVehicle(boat)
            boatSpawned = false
        end
    end
end)

---------------------------------------------------------------------------------------------------------
--------------------------------------- SEITE 3 Meine Boote----------------------------------------------
---------------------------------------------------------------------------------------------------------

RegisterNetEvent('mms-boats:client:getboatsfromdb')
AddEventHandler('mms-boats:client:getboatsfromdb',function()
    getboats = 1
    TriggerServerEvent('mms-boats:server:getboatsfromdb')
end)


RegisterNetEvent('mms-boats:client:noboats')
AddEventHandler('mms-boats:client:noboats',function()
    getboats = 0
    TriggerServerEvent('mms-boats:server:getboatsfromdb')
end)


RegisterNetEvent('mms-boats:client:meineboote')
AddEventHandler('mms-boats:client:meineboote',function(eintraege)
----- Seite 3 Meine Boote

BootTraderPage3 = BootTrader:RegisterPage('seite3')
BootTraderPage3:RegisterElement('header', {
    value = Config.BoatTrader,
    slot = 'header',
    style = {
    ['color'] = 'orange',
    }
})
BootTraderPage3:RegisterElement('line', {
    slot = 'header',
    style = {
    ['color'] = 'orange',
    }
})
for v, boot in ipairs(eintraege) do
    local buttonLabel =  boot.name .. Config.SellPrice .. boot.sellprice ..'$'
    local model = boot.model
    local name = boot.name
    local sellprice = boot.sellprice
    local storageid = boot.storageid
    local storagename = boot.storagename
    local storage = boot.storage
    BootTraderPage3:RegisterElement('button', {
        label = buttonLabel,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        }
    }, function()
        TriggerEvent('mms-boats:client:boatspawn',model,name,sellprice,storageid,storagename,storage)
    end)
end
BootTraderPage3:RegisterElement('button', {
    label =  Config.BackTrader,
    style = {
        ['background-color'] = '#FF8C00',
    ['color'] = 'orange',
    ['border-radius'] = '6px'
    },
}, function()
    BootTraderPage1:RouteTo()
end)
BootTraderPage3:RegisterElement('button', {
    label = Config.CloseTrader,
    style = {
        ['background-color'] = '#FF8C00',
    ['color'] = 'orange',
    ['border-radius'] = '6px'
    },
}, function()
    BootTrader:Close({ 
    })
end)
BootTraderPage3:RegisterElement('subheader', {
    value = Config.BoatTrader,
    slot = 'footer',
    style = {
    ['color'] = 'orange',
    }
})
BootTraderPage3:RegisterElement('line', {
    slot = 'footer',
    style = {
    ['color'] = 'orange',
    }
})
BootTraderPage3:RouteTo()

end)

RegisterNetEvent('mms-boats:client:boatspawn')
AddEventHandler('mms-boats:client:boatspawn',function(model,name,sellprice,storageid,storagename,storage)
    for _,v in ipairs(Config.Prompts) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - v.boatspawn)
        if dist <= 50 then 
            spawncoords = v.boatspawn
            boatheading = v. boatheading
        end
    end
    local alert = lib.alertDialog({
        header = Config.BoatOptions,
        content = Config.SpawnOrSellBoat,
        centered = true,
        cancel = true,
        labels = {cancel = Config.ButtonSpawn,confirm = Config.ButtonSell}
    })
    if alert =='cancel' and boatSpawned == false then
        local ped = PlayerPedId()
        local boathash = model
        RequestModel(boathash)
        while not HasModelLoaded(boathash) do
            Citizen.Wait(0)
        end
        boat = CreateVehicle(boathash, spawncoords,boatheading, true, false)
        SetVehicleOnGroundProperly(boat)
        SetEntityAsMissionEntity(boat,true,true)
        SetVehicleCanBreak(boat,false)
        Wait(200)
        --SetPedIntoVehicle(ped, boat, -1)
        SetModelAsNoLongerNeeded(boathash)
        boatSpawned = true
        BootTrader:Close({ 
        })
        VORPcore.NotifyTip(Config.BoatWatered, 5000)
        TriggerEvent('mms-boats:client:boatprompt',model,name,sellprice,storageid,storagename,storage)
        elseif alert == 'confirm' then
            BootTraderPage1:RouteTo()
            TriggerServerEvent('mms-boats:server:sellboat',sellprice, name,storageid)
        end
    
end)

RegisterNetEvent('mms-boats:client:boatprompt')
AddEventHandler('mms-boats:client:boatprompt',function(model,name,sellprice,storageid,storagename,storage)
    local BoatPrompt = BccUtils.Prompts:SetupPromptGroup()
    local boatgive = BoatPrompt:RegisterPrompt(Config.GiveBoat, 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    local boatstore = BoatPrompt:RegisterPrompt(Config.StoreBoat, 0x4BC9DABB, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    local boatstorage = BoatPrompt:RegisterPrompt(Config.BoatStorage, 0x4CC0E2FE, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    while true do
        Wait(1)
        if boatSpawned == true then
        local boatpos = GetEntityCoords(boat)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - boatpos)
        if dist < 3 then
            BoatPrompt:ShowGroup('Boot')
            

            --BccUtils.Misc.DrawText3D(plantcoords.x, plantcoords.y, plantcoords.z, _U('WaterCropPrompt'))
            if boatgive:HasCompleted() then
                TriggerEvent('mms-boats:client:giveboat',model,name,sellprice,storageid,storagename,storage)
            end
            if boatstore:HasCompleted() then
                StoreBoat(storageid)
            end
            if boatstorage:HasCompleted() then
                TriggerServerEvent('mms-boats:server:openstorage',storageid,storagename,storage)
            end
        end
    end
    end
end)

RegisterNetEvent('mms-boats:client:giveboat')
AddEventHandler('mms-boats:client:giveboat',function(model,name,sellprice,storageid,storagename,storage)
    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer and closestDistance <= 50.0 then
        local serverId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('mms-boats:server:giveboat',model,name,sellprice,serverId,storageid,storage)
        StoreBoat(storageid)
        else
            VORPcore.NotifyTip('Niemand in der Nähe zum Weitergeben', 5000)
        end
end)

function StoreBoat(storageid)
    if boatSpawned == true then
        DeleteVehicle(boat)
        boatSpawned = false
        VORPcore.NotifyTip(Config.StoredBoat, 5000)
        TriggerServerEvent('mms-boats:server:closestorage',storageid)
    else
        VORPcore.NotifyTip(Config.NoBoatInWater, 5000)
    end
end

function GetClosestPlayer()
    local players = GetActivePlayers()
    local player = PlayerId()
    local coords = GetEntityCoords(PlayerPedId())
    local closestDistance = nil
    local closestPlayer = nil
    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])
        if players[i] ~= player then
            local distance = #(coords - GetEntityCoords(target))
            if closestDistance == nil or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end