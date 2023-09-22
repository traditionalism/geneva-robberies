local timeCashMultiplier = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.3, 0.3, 0.3, 0.6, 0.6, 0.8, 0.8, 1.0, 1.0, 1.5, 1.5, 2.0, 2.5, 3.0 }
local storesToReset = {}
local storesBeingRobbed = {}
local ongoingRobberies = {}
local floor = math.floor
local random = math.random

local function getRobberyResult(hour)
    local hourMath = ((hour * 0.6) + 0.5) * 1000
    local finalMath = random(floor(hourMath), floor(hourMath + 5000))
    local cash = floor(finalMath / 8) * (timeCashMultiplier[hour] or 0.1)

    return floor(finalMath / 2), floor(cash)
end

local function markStoreForReset(source, store)
    storesToReset[#storesToReset + 1] = {
        source = source,
        interior = store
    }
end

lib.callback.register('geneva-robberies:robberyStarted', function(source, hour)
    local time, pay = getRobberyResult(hour)

    ongoingRobberies[source] = {
        startedAt = os.time(),
        amount = pay,
        time = time
    }

    if Config.logging then
        print(('robbery started by %s (#%s) at hour %s. Pay: %s'):format(GetPlayerName(source), source, hour, pay))
    end

    return time, pay
end)

RegisterNetEvent('geneva-robberies:doSyncingStuff', function(store)
    if storesBeingRobbed[store] then
        storesBeingRobbed[store] = nil
    else
        storesBeingRobbed[store] = {
            store = store
        }
    end

    TriggerClientEvent('geneva-robberies:syncRobbedStoresTbl', -1, storesBeingRobbed)
end)

RegisterNetEvent('geneva-robberies:robberyAborted', function(store)
    local source = source

    markStoreForReset(source, store)

    if Config.logging then
        print(('Robbery aborted by %s (%s)'):format(GetPlayerName(source), source))
    end
end)

RegisterNetEvent('geneva-robberies:robberyFinished', function(store)
    local robbery = ongoingRobberies[source]
    local source = source

    if not robbery then return end

    if floor((robbery.startedAt + robbery.time) + 0.5) < os.time() then
        ongoingRobberies[source] = nil
        return
    end

    markStoreForReset(source, store)

    if Config.logging then
        print(('Marking store for reset: %s'):format(store))
    end

    if Config.useFramework then
        AddMoney(source, robbery.amount)
    end
end)

lib.cron.new(random(1, 2) == 1 and '*/5 * * * *' or '*/15 * * * *', function()
    if Config.logging and #storesToReset > 0 then
        print(('Resetting %s stores.'):format(#storesToReset))
    end

    for i = 1, #storesToReset do
        TriggerClientEvent('geneva-robberies:resetStore', storesToReset[i].source, storesToReset[i].interior)
        storesBeingRobbed[storesToReset[i].interior] = nil
        storesToReset[i] = nil
        TriggerClientEvent('geneva-robberies:syncRobbedStoresTbl', -1, storesBeingRobbed)
    end
end)