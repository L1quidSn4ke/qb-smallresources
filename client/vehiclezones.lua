local QBCore = exports['qb-core']:GetCoreObject()

local polygonZones = {
    {
        name = "Downtown Area",
        points = {
            vector2(125.45, 675.90),
            vector2(145.45, 675.90),
            vector2(145.45, 695.90),
            vector2(125.45, 695.90)
        }
    },
    -- Add more zones as needed
}


local function IsPointInPolygon(point, polygon)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
            if (polygon[i].x + (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                oddNodes = not oddNodes
            end
        end
        j = i
    end
    return oddNodes
end

-- Thread for NPC vehicles
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicles = GetGamePool('CVehicle')
        
        for _, vehicle in ipairs(vehicles) do
            if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                local vehicleCoords = GetEntityCoords(vehicle)
                if #(playerCoords - vehicleCoords) < 100.0 then
                    for _, zone in ipairs(polygonZones) do
                        if IsPointInPolygon(vector2(vehicleCoords.x, vehicleCoords.y), zone.points) then
                            if not IsVehicleOccupied(vehicle) then
                                DeleteEntity(vehicle)
                            else
                                local driver = GetPedInVehicleSeat(vehicle, -1)
                                if driver ~= 0 then
                                    TaskLeaveVehicle(driver, vehicle, 0)
                                    TaskSmartFleePed(driver, PlayerPedId(), 100.0, -1, false, false)
                                end
                            end
                            SetVehicleEngineOn(vehicle, false, true, true)
                            SetVehicleUndriveable(vehicle, true)
                            
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Helper function to check if a vehicle is occupied by any ped
function IsVehicleOccupied(vehicle)
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if GetPedInVehicleSeat(vehicle, i) ~= 0 then
            return true
        end
    end
    return false
end
