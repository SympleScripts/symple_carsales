local config = require 'config'
local QBX = exports.qbx_core

local CAR_BUYER_CONFIG = config.carBuyer
local SALE_CONFIG = config.saleOptions

local carBuyerPed = nil
local carBuyerBlip = nil
local pedSpawned = false
local lastDistance = 999.0

local showCarBuyerMenu

local function setupTargeting()
    if not carBuyerPed or not DoesEntityExist(carBuyerPed) then return end
    
    exports.ox_target:addLocalEntity(carBuyerPed, {
        {
            name = 'car_buyer_interact',
            icon = 'fas fa-handshake',
            label = 'Sell Me Your Car',
            onSelect = function()
                showCarBuyerMenu()
            end,
            distance = 2.5
        }
    })
end

local function createCarBuyerNPC()
    if pedSpawned or carBuyerPed then return end
    
    lib.requestModel(CAR_BUYER_CONFIG.model, 10000)
    
    carBuyerPed = CreatePed(4, CAR_BUYER_CONFIG.model, CAR_BUYER_CONFIG.coords.x, CAR_BUYER_CONFIG.coords.y, CAR_BUYER_CONFIG.coords.z - 1.0, CAR_BUYER_CONFIG.coords.w, false, true)
    
    SetEntityInvincible(carBuyerPed, true)
    SetBlockingOfNonTemporaryEvents(carBuyerPed, true)
    FreezeEntityPosition(carBuyerPed, true)
    
    SetPedDefaultComponentVariation(carBuyerPed)
    SetPedCanPlayAmbientAnims(carBuyerPed, true)
    SetPedCanPlayAmbientBaseAnims(carBuyerPed, true)
    
    SetModelAsNoLongerNeeded(CAR_BUYER_CONFIG.model)
    
    pedSpawned = true
    
    Wait(500)
    setupTargeting()
end

local function deleteCarBuyerNPC()
    if carBuyerPed and DoesEntityExist(carBuyerPed) then
        exports.ox_target:removeLocalEntity(carBuyerPed, 'car_buyer_interact')
        
        DeleteEntity(carBuyerPed)
        carBuyerPed = nil
        pedSpawned = false
    end
end

local function createCarBuyerBlip()
    carBuyerBlip = AddBlipForCoord(CAR_BUYER_CONFIG.coords.x, CAR_BUYER_CONFIG.coords.y, CAR_BUYER_CONFIG.coords.z)
    SetBlipSprite(carBuyerBlip, CAR_BUYER_CONFIG.blip.sprite)
    SetBlipColour(carBuyerBlip, CAR_BUYER_CONFIG.blip.color)
    SetBlipScale(carBuyerBlip, CAR_BUYER_CONFIG.blip.scale)
    SetBlipAsShortRange(carBuyerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(CAR_BUYER_CONFIG.blip.name)
    EndTextCommandSetBlipName(carBuyerBlip)
end

local function getCurrentVehicleInfo()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle == 0 then
        return nil, "You need to be in a vehicle to sell it!"
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
        return nil, "You need to be the driver of the vehicle!"
    end
    
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)
    
    return {
        vehicle = vehicle,
        model = vehicleModel,
        name = vehicleName,
        plate = string.gsub(vehiclePlate, "^%s*(.-)%s*$", "%1")
    }, nil
end

local function handleVehicleSale(vehicleInfo)
    lib.callback('symple_carsales:getVehicleValue', false, function(vehicleValue)
        if not vehicleValue or vehicleValue <= 0 then
            lib.notify({
                title = 'Car Buyer',
                description = 'Sorry, I can\'t determine the value of this vehicle.',
                type = 'error'
            })
            return
        end
        
        local varianceRange = SALE_CONFIG.variance_range or 0.05
        local randomFactor1 = 1.0 + (math.random(-100, 100) / 100) * varianceRange
        local randomFactor2 = 1.0 + (math.random(-100, 100) / 100) * varianceRange
        
        local offer50Percent = math.floor(vehicleValue * SALE_CONFIG.option_a_base_percentage * randomFactor1)
        local offer40Percent = math.floor(vehicleValue * SALE_CONFIG.option_b_base_percentage * randomFactor2)
        local bonusAmount = SALE_CONFIG.option_b_bonus
        local totalOptionB = offer40Percent + bonusAmount
        
        local betterDeal = totalOptionB > offer50Percent and "Bonus Package" or "Quick Cash"
        
        local options = {
            {
                title = 'Quick Cash Deal' .. (betterDeal == "Quick Cash" and ' (Recommended)' or ''),
                description = 'Fast payment, no questions asked - immediate cash in hand',
                icon = 'fas fa-money-bill-wave',
                iconColor = '#3498db',
                metadata = {
                    {label = 'Offer Amount', value = '$' .. lib.math.groupdigits(offer50Percent), color = '#2ecc71'},
                    {label = 'Base Rate', value = string.format('%.1f%% of assessed value', (offer50Percent/vehicleValue)*100)},
                    {label = 'Payment Speed', value = 'Instant', color = '#3498db'},
                    {label = 'Market Value', value = '$' .. lib.math.groupdigits(vehicleValue), color = '#95a5a6'}
                },
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Confirm Quick Cash Deal',
                        content = string.format('Are you sure you want to sell your %s for $%s?\n\nThis is 50%% of the market value ($%s).', 
                            vehicleInfo.name, 
                            lib.math.groupdigits(offer50Percent),
                            lib.math.groupdigits(vehicleValue)
                        ),
                        centered = true,
                        cancel = true
                    })
                    
                    if alert == 'confirm' then
                        TriggerServerEvent('symple_carsales:sellVehicle', vehicleInfo, 'option_a', offer50Percent)
                    end
                end
            },
            {
                title = 'Bonus Package Deal' .. (betterDeal == "Bonus Package" and ' (Recommended)' or ''),
                description = 'Lower base rate but includes cash bonus - good for quick deals',
                icon = 'fas fa-gift',
                iconColor = '#e74c3c',
                metadata = {
                    {label = 'Base Amount', value = '$' .. lib.math.groupdigits(offer40Percent), color = '#e67e22'},
                    {label = 'Bonus Cash', value = '+$' .. lib.math.groupdigits(bonusAmount), color = '#2ecc71'},
                    {label = 'Total Payout', value = '$' .. lib.math.groupdigits(totalOptionB), color = '#2ecc71'},
                    {label = 'Base Rate', value = string.format('%.1f%% + bonus', (offer40Percent/vehicleValue)*100), color = '#e74c3c'},
                    {label = 'Market Value', value = '$' .. lib.math.groupdigits(vehicleValue), color = '#95a5a6'}
                },
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Confirm Bonus Package Deal',
                        content = string.format('Are you sure you want to sell your %s for $%s?\n\nThis includes:\n• Base: $%s (40%% of market value)\n• Bonus: +$%s\n• Total: $%s', 
                            vehicleInfo.name,
                            lib.math.groupdigits(totalOptionB),
                            lib.math.groupdigits(offer40Percent),
                            lib.math.groupdigits(bonusAmount),
                            lib.math.groupdigits(totalOptionB)
                        ),
                        centered = true,
                        cancel = true
                    })
                    
                    if alert == 'confirm' then
                        TriggerServerEvent('symple_carsales:sellVehicle', vehicleInfo, 'option_b', totalOptionB)
                    end
                end
            },
            {
                title = 'Walk Away',
                description = 'Decline both offers and keep your vehicle',
                icon = 'fas fa-times-circle',
                iconColor = '#95a5a6',
                metadata = {
                    {label = 'Action', value = 'No Sale'},
                    {label = 'Vehicle Status', value = 'Remains Yours', color = '#3498db'}
                },
                onSelect = function()
                    lib.notify({
                        title = 'Car Buyer',
                        description = 'No problem! Come back anytime if you change your mind.',
                        type = 'inform'
                    })
                end
            }
        }
        
        lib.registerContext({
            id = 'car_buyer_negotiation',
            title = string.format('Negotiation - %s', vehicleInfo.name),
            menu = 'car_buyer_main',
            options = options
        })
        
        lib.showContext('car_buyer_negotiation')
        
    end, vehicleInfo.name, vehicleInfo.plate)
end

showCarBuyerMenu = function()
    local vehicleInfo, error = getCurrentVehicleInfo()
    
    if error then
        lib.notify({
            title = '🚗 Car Buyer',
            description = error,
            type = 'error'
        })
        return
    end
    
    local options = {
        {
            title = 'Sell My Vehicle',
            description = string.format('Get cash for your %s • Plate: %s', vehicleInfo.name, vehicleInfo.plate),
            icon = 'fas fa-dollar-sign',
            iconColor = '#2ecc71',
            metadata = {
                {label = 'Vehicle', value = vehicleInfo.name},
                {label = 'License Plate', value = vehicleInfo.plate},
                {label = 'Status', value = 'Ready to Sell', color = '#2ecc71'}
            },
            onSelect = function()
                handleVehicleSale(vehicleInfo)
            end
        },
        {
            title = 'Just Browsing',
            description = 'Look around without making any deals',
            icon = 'fas fa-eye',
            iconColor = '#f39c12',
            metadata = {
                {label = 'Action', value = 'Browse Only'},
                {label = 'Commitment', value = 'None Required'}
            },
            onSelect = function()
                lib.notify({
                    title = 'Car Buyer',
                    description = 'Take your time! Come back when you\'re ready to make a deal.',
                    type = 'inform'
                })
            end
        }
    }
    
    lib.registerContext({
        id = 'car_buyer_main',
        title = 'Car Buyer - Quick Cash for Your Ride',
        options = options
    })
    
    lib.showContext('car_buyer_main')
end

local function monitorProximity()
    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - vector3(CAR_BUYER_CONFIG.coords.x, CAR_BUYER_CONFIG.coords.y, CAR_BUYER_CONFIG.coords.z))
            
            if math.abs(distance - lastDistance) > 5.0 then
                lastDistance = distance
                if distance <= CAR_BUYER_CONFIG.spawnDistance and not pedSpawned then
                    createCarBuyerNPC()
                elseif distance >= CAR_BUYER_CONFIG.deleteDistance and pedSpawned then
                    deleteCarBuyerNPC()
                end
            end
            
            if distance > CAR_BUYER_CONFIG.deleteDistance then
                Wait(2000)
            elseif distance > CAR_BUYER_CONFIG.spawnDistance then
                Wait(1000)
            else
                Wait(500)
            end
        end
    end)
end

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(100)
    end
    
    createCarBuyerBlip()
    
    monitorProximity()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        deleteCarBuyerNPC()
        
        if carBuyerBlip then
            RemoveBlip(carBuyerBlip)
        end
    end
end)

RegisterNetEvent('symple_carsales:vehicleSold', function(amount, option)
    local optionText = option == 'option_a' and 'Quick Cash Deal' or 'Bonus Package Deal'
    
    lib.notify({
        title = 'Vehicle Sold Successfully!',
        description = string.format('You received $%s from the %s\nCash has been added to your inventory', lib.math.groupdigits(amount), optionText),
        type = 'success',
        duration = 7000,
        position = 'top'
    })
    
    Wait(1000)
    lib.notify({
        title = 'Transaction Complete',
        description = 'Thanks for doing business! Come back anytime.',
        type = 'inform',
        duration = 3000
    })
end)

RegisterNetEvent('symple_carsales:saleError', function(message)
    lib.notify({
        title = 'Transaction Failed',
        description = string.format('%s\n\nPlease try again or contact support if the issue persists.', message),
        type = 'error',
        duration = 6000
    })
end)
