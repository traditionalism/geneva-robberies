local timeCashMultiplier = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.3, 0.3, 0.3, 0.6, 0.6, 0.8, 0.8, 1.0, 1.0, 1.5, 1.5, 2.0, 2.5, 3.0 }
local interiorsBeingRobbed = {}
local ongoingRobberies = {}
local floor = math.floor
local random = math.random

local function getRobberyResult(hour)
    local hourMath = ((hour * 0.6) + 0.5) * 1000
    local finalMath = random(floor(hourMath), floor(hourMath + 5000))
    local cash = floor(finalMath / 8) * (timeCashMultiplier[hour] or 0.1)
    return floor(finalMath / 2), floor(cash)
end

RegisterNetEvent('geneva-robberies:syncAnimation-s', function(interior)
    TriggerClientEvent('geneva-robberies:syncAnimation', -1, source, interior)
end)

lib.callback.register('geneva-robberies:robberyStarted', function(source, hour)
    local source = source
    local time, pay = getRobberyResult(hour)
    ongoingRobberies[source] = {
        startedAt = os.time(),
        amount = pay,
        time = time
    }
    return time, pay
end)

RegisterNetEvent('geneva-robberies:robberyFinished', function()
    local source = source
    local robbery = ongoingRobberies[source]
    if not robbery then return end
    if floor((robbery.startedAt + robbery.time) + 0.5) < os.time() then
        ongoingRobberies[source] = nil
        return
    end
    AddMoney(source, robbery.amount)
end)