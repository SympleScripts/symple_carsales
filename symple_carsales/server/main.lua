-- Get enhanced vehicle value with negotiation factors
lib.callback.register('symple_carsales:getVehicleValue', function(source, vehicleName, vehiclePlate)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return 0 end
    
    local vehicleData = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {
        Player.PlayerData.citizenid,
        vehiclePlate
    })
    
    if not vehicleData or #vehicleData == 0 then
        return 0
    end
    
    local vehicleInfo = MySQL.query.await('SELECT model, price FROM vehicles WHERE model = ?', {
        vehicleName:lower()
    })
    
    local basePrice = 25000
    if vehicleInfo and #vehicleInfo > 0 then
        basePrice = vehicleInfo[1].price or 25000
    end
    

    
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    local conditionMultiplier = 1.0
    if vehicle ~= 0 then
        local engineHealth = GetVehicleEngineHealth(vehicle) / 1000.0
        local bodyHealth = GetVehicleBodyHealth(vehicle) / 1000.0
        local avgHealth = (engineHealth + bodyHealth) / 2.0
        
        conditionMultiplier = math.max(0.7, avgHealth)
        print(string.format('[SYMPLE_CARSALES] Vehicle condition: %.1f%% (multiplier: %.2f)', avgHealth * 100, conditionMultiplier))
    end
    
    local vehicleClass = GetVehicleClassFromName(vehicleName)
    local classMultipliers = {
        [0] = 0.85,  [1] = 1.0,   [2] = 1.1,   [3] = 1.05,  [4] = 1.15,
        [5] = 1.2,   [6] = 1.25,  [7] = 1.3,   [8] = 0.9,   [9] = 1.05,
        [10] = 0.8,  [11] = 0.85, [12] = 0.9,  [13] = 0.6,  [14] = 1.0,
        [15] = 1.4,  [16] = 1.5,  [17] = 0.7,  [18] = 0.75, [19] = 1.2,
        [20] = 0.8,  [21] = 0.5
    }
    local demandMultiplier = classMultipliers[vehicleClass] or 1.0
    
    local finalValue = math.floor(basePrice * conditionMultiplier * demandMultiplier)
    
    print(string.format('[SYMPLE_CARSALES] Final negotiated value: $%s (condition: %.2f, demand: %.2f)', 
        finalValue, conditionMultiplier, demandMultiplier))
    
    return finalValue
end)

RegisterNetEvent('symple_carsales:sellVehicle', function(vehicleInfo, option, amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end
    
    local vehicleData = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {
        Player.PlayerData.citizenid,
        vehicleInfo.plate
    })
    
    if not vehicleData or #vehicleData == 0 then
        TriggerClientEvent('symple_carsales:saleError', src, 'You don\'t own this vehicle!')
        return
    end
    
    local playerPed = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle == 0 or GetEntityModel(vehicle) ~= vehicleInfo.model then
        TriggerClientEvent('symple_carsales:saleError', src, 'You must be in the vehicle to sell it!')
        return
    end
    
    local success = MySQL.query.await('DELETE FROM player_vehicles WHERE citizenid = ? AND plate = ?', {
        Player.PlayerData.citizenid,
        vehicleInfo.plate
    })
    
    if success then
        exports.qbx_core:AddMoney(src, 'cash', amount, 'vehicle-sale')
        
        DeleteEntity(vehicle)
        
        print(string.format('[SYMPLE_CARSALES] %s (%s) sold vehicle %s (plate: %s) for $%s using %s', 
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            Player.PlayerData.citizenid,
            vehicleInfo.name,
            vehicleInfo.plate,
            amount,
            option
        ))
        
        TriggerClientEvent('symple_carsales:vehicleSold', src, amount, option)
    else
        TriggerClientEvent('symple_carsales:saleError', src, 'Failed to process the sale. Please try again.')
    end
end)