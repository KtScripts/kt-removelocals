local removalZones = {
    {x = 65.993438720703, y =  -1750.9078369141, z = 29.614320755005}, -- Example Location
    {x = 80.105239868164, y =  -1740.9761962891, z = 29.614503860474},
    {x = 81.333930969238, y =  -1743.9250488281, z = 34.730285644531},
    {x = 65.993438720703, y =  -1750.9078369141, z = 29.614320755005},
    {x = 65.993438720703, y =  -1750.9078369141, z = 29.614320755005},
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Check every 5 seconds
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, zone in pairs(removalZones) do
            local distance = #(playerCoords - vector3(zone.x, zone.y, zone.z))
            if distance < zone.radius then
                for ped in EnumeratePeds() do
                    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                        DeleteEntity(ped)
                    end
                end
                for vehicle in EnumerateVehicles() do
                    if DoesEntityExist(vehicle) then
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
    end
end)

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
