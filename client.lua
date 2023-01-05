local storesToReset = {}
local storePeds = {}
local helpShownRecently = false
local random = math.random
local serverId = GetPlayerServerId(PlayerId())
local name = GetCurrentResourceName()
local state = LocalPlayer.state

local function setupStores()
    local stores = Config.stores

    AddTextEntry('robStoreHelp', 'Rob the cash register by pointing a weapon at the store clerk.')
    AddTextEntry('waitForTheCashier', 'Wait for the store clerk to empty the register to get the full amount of cash.')
    AddTextEntry('emptyRegisterManuallyNeeded', 'The store clerk is no longer able to empty the register. Go up to the register the store clerk was using and empty it manually with ~INPUT_CONTEXT~')
    AddTextEntry('takeCash', 'Press ~INPUT_CONTEXT~ to take cash.')

    state:set('inStore', false, false)
    state:set('isRobbing', false, false)

    for _, store in pairs(stores) do
        RequestModel(store.model)
        repeat Wait(0) until HasModelLoaded(store.model)
        local ped = CreatePed(26, store.model, store.clerkCoords.x, store.clerkCoords.y, store.clerkCoords.z, store.clerkCoords.w, true, false)
        if store.model == `mp_m_shopkeep_01` then
            SetPedComponentVariation(ped, 3, random(1, 2), 0, 0)
            SetPedComponentVariation(ped, 2, random(1, 3), 0, 0)
            SetPedComponentVariation(ped, 0, random(1, 3), 0, 0)
            SetPedPropIndex(ped, 1, random(1, 3), 0, true)
        end
        SetModelAsNoLongerNeeded(store.model)
        SetPedKeepTask(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetRagdollBlockingFlags(ped, 16)
        SetPedCanEvasiveDive(ped, false)
        SetPedFleeAttributes(ped, 1024, true)
        storePeds[#storePeds + 1] = ped
    end
end

local function getClerkForStore()
    repeat Wait(0) until #storePeds >= 1

    for i = 1, #storePeds do
        if GetInteriorFromEntity(storePeds[i]) == state.currentStore then
            return storePeds[i]
        end
    end
end

local function getVoiceForClerk()
    local face = GetPedDrawableVariation(state.storeClerk, 0)

    if face == 0 then
        return 'MP_M_SHOPKEEP_01_PAKISTANI_MINI_01'
    elseif face == 1 then
        return 'MP_M_SHOPKEEP_01_LATINO_MINI_01'
    else
        return 'MP_M_SHOPKEEP_01_CHINESE_MINI_01'
    end
end

local function checkForShooting()
    local clerk = state.storeClerk
    local plyPed = PlayerPedId()

    while state.isRobbing do
        if IsPedShooting(plyPed) and not IsAmbientSpeechPlaying(clerk) then
            PlayPedAmbientSpeechWithVoiceNative(clerk, 'SHOP_HURRYING', getVoiceForClerk(), 'SPEECH_PARAMS_FORCE', false)
        end

        Wait(0)
    end
end

local function notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local function checkForManualEmpty()
    while state.manualRegisterEmptyNeeded do
        DisplayHelpTextThisFrame('takeCash', true)

        if IsControlJustPressed(0, 51) then
            ClearHelp(true)
            notify('You have stolen $' .. tostring(random(750, 3000)) .. '.')
        end

        Wait(0)
    end
end

local function checkForClerkLife()
    local clerk = state.storeClerk

    while state.isRobbing do
        if IsPedDeadOrDying(clerk, true) then
            print('clerk dead')
            -- close store after robbery, and add it to the list of stores needing to be re-opened.
            state:set('manualRegisterEmptyNeeded', true, false)
            DisplayHelpTextThisFrame('emptyRegisterManuallyNeeded', true)
            checkForManualEmpty()
            return
        end

        Wait(1000)
    end
end

local function fightBack()
    local plyPed = PlayerPedId()

    
end

local function startRobbery()

end

local function cleanup()
    for i = 1, #storePeds do
        DeletePed(storePeds[i])
    end
end

CreateThread(setupStores)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local ourInterior = GetInteriorFromEntity(ped)
        local inStore = Config.stores[ourInterior]

        if not state.inStore and inStore then
            state:set('currentStore', ourInterior, false)
            state:set('storeClerk', getClerkForStore(), false)
            state:set('inStore', true, false)
        elseif state.inStore and not inStore and not state.isRobbing then
            state:set('currentStore', nil, false)
            state:set('inStore', false, false)
        end

        if not state.isRobbing and inStore and IsPedArmed(ped, 4) and not Entity(state.storeClerk).state.beingRobbed then
            state:set('isRobbing', true, false)
            Entity(state.storeClerk).state:set('beingRobbed', true, false)
        elseif state.isRobbing and not inStore then
            notify('You have left the store and aborted the robbery.')
            state:set('isRobbing', false, false)
            state:set('currentStore', nil, false)
            state:set('inStore', false, false)
            Entity(state.storeClerk).state:set('beingRobbed', false, false)
        end

        Wait(1500)
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        helpShownRecently = false
    end
end)

RegisterCommand('getinterior', function()
    local coords = GetEntityCoords(PlayerPedId())
    print(GetInteriorAtCoords(coords.x, coords.y, coords.z))
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= name then return end
    cleanup()
end)

AddStateBagChangeHandler('inStore', ('player:%s'):format(serverId), function(_, _, value)
    if not value then return end

    local plyPed = PlayerPedId()

    if not helpShownRecently and not IsPedArmed(plyPed, 4) then
        helpShownRecently = true

        local clerk = state.storeClerk

        TaskLookAtEntity(clerk, plyPed, 3000, 2048, 3)
        if GetEntityModel(clerk) == `mp_m_shopkeep_01` then
            PlayPedAmbientSpeechWithVoiceNative(clerk, Config.clerkVoiceLines[random(1, #Config.clerkVoiceLines)], getVoiceForClerk(), 'SPEECH_PARAMS_FORCE', true)
        end

        DisplayHelpTextThisFrame('robStoreHelp', true)
        Wait(6000)
        ClearHelp(true)
    end
end)

AddStateBagChangeHandler('isRobbing', ('player:%s'):format(serverId), function(_, _, value)
    if not value then return end

    print('starting robbery')

    storesToReset[#storesToReset + 1] = state.currentStore

    CreateThread(checkForShooting)
    CreateThread(checkForClerkLife)

    if random(0, 100) >= 20 then
        ---normal robbery
        CreateThread(function()
            DisplayHelpTextThisFrame('waitForTheCashier', true)
            Wait(6000)
            ClearHelp(true)
        end)
        startRobbery()
    else
        ---fight back
        fightBack()
    end
end)