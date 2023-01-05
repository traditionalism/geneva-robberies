local storesToReset = {}
local storePeds = {}
local helpShownRecently = false
local closedHelpTextRecentlyShown = false
local random = math.random
local serverId = GetPlayerServerId(PlayerId())
local name = GetCurrentResourceName()
local state = LocalPlayer.state
local cam = 0
local cam2 = 0

local function setupStores()
    local stores = Config.stores

    AddTextEntry('robStore', 'Rob the cash register by pointing a weapon at the store clerk.')
    AddTextEntry('waitForTheCashier', 'Wait for the store clerk to empty the register to get the full amount of cash.')
    AddTextEntry('emptyRegisterManuallyNeeded', 'The store clerk is no longer able to empty the register. Go up to the register the store clerk was using and empty it manually with ~INPUT_CONTEXT~')
    AddTextEntry('takeCash', 'Press ~INPUT_CONTEXT~ to take cash.')
    AddTextEntry('24/7_storeClosed', '24/7 is closed. Please come back within 5-15 minutes.')

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

local function spawnClerk(clerk, coords)
    RequestModel(clerk)
    repeat Wait(0) until HasModelLoaded(clerk)
    local ped = CreatePed(26, clerk, coords.x, coords.y, coords.z, coords.w, true, false)
    if clerk == `mp_m_shopkeep_01` then
        SetPedComponentVariation(ped, 3, random(1, 2), 0, 0)
        SetPedComponentVariation(ped, 2, random(1, 3), 0, 0)
        SetPedComponentVariation(ped, 0, random(1, 3), 0, 0)
        SetPedPropIndex(ped, 1, random(1, 3), 0, true)
    end
    SetModelAsNoLongerNeeded(clerk)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetRagdollBlockingFlags(ped, 16)
    SetPedCanEvasiveDive(ped, false)
    SetPedFleeAttributes(ped, 1024, true)
    storePeds[#storePeds + 1] = ped
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

local function createFirstCamera()
    local plyPed = PlayerPedId()

    cam = CreateCameraWithParams(`DEFAULT_SCRIPTED_CAMERA`, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0, false, 2)
    AttachCamToEntity(cam, plyPed, -0.1878, 3.0635, 0.68, true)
    PointCamAtEntity(cam, plyPed, -0.0129, 0.0927, 0.3008, true)
    SetCamFov(cam, 35.0)
    ShakeCam(cam, 'HAND_SHAKE', 0.1)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 3000, true, false)
end

local function createSecondCamera()
    local plyPed = PlayerPedId()

    cam2 = CreateCameraWithParams(`DEFAULT_SCRIPTED_CAMERA`, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0, false, 2)
    AttachCamToEntity(cam2, plyPed, -1.0346, 2.9183, 0.68, true)
    PointCamAtEntity(cam2, plyPed, -0.0574, 0.1074, 0.3008, true)
    SetCamFov(cam2, 35.0)
    ShakeCam(cam2, 'HAND_SHAKE', 0.3)
    SetCamActiveWithInterp(cam2, cam, 8000, 1, 1)
end

local function notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local function checkForManualEmpty()
    local plyPed = PlayerPedId()
    local sleep = 1000

    RequestAnimDict('oddjobs@shop_robbery@rob_till')
    repeat Wait(0) until HasAnimDictLoaded('oddjobs@shop_robbery@rob_till')

    while state.manualRegisterEmptyNeeded do
        local plyCoords = GetEntityCoords(plyPed)
        local dist = #(plyCoords - vec3(24.5, -1344.98, 29.5))

        if dist <= 1.0 then
            sleep = 0
            DisplayHelpTextThisFrame('takeCash', true)

            if IsControlJustPressed(0, 51) then
                ClearHelp(true)
                TaskGoStraightToCoord(plyPed, 24.5, -1344.98, 29.5, 2.0, 2000, 275.16, 0.1)
                repeat Wait(0) until GetScriptTaskStatus(plyPed, 0x7D8F4411) == 7
                local _, prevWeapon = GetCurrentPedWeapon(plyPed, true)
                SetCurrentPedWeapon(plyPed, `WEAPON_UNARMED`, true)
                FreezeEntityPosition(plyPed, true)
                ClearPedTasksImmediately(plyPed)
                DisplayRadar(false)
                createFirstCamera()
                createSecondCamera()
                local registerCoords = GetEntityCoords(GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 5.0, `prop_till_01`, false, false, false))
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'enter', 8.0, -8.0, -1, 0, 0.0, false, false, false)
                CreateModelSwap(registerCoords.x, registerCoords.y, registerCoords.z, 0.5, `prop_till_01`, `prop_till_01_dam`, false)
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'loop', 8.0, -8.0, 4000, 1, 0.0, false, false, false)
                Wait(4000)
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'exit', 8.0, -1.5, -1, 0, 0.0, false, false, false)
                RemoveAnimDict('oddjobs@shop_robbery@rob_till')
                SetCamActive(cam2, false)
                RenderScriptCams(false, false, 3000, true, false)
                state:set('manualRegisterEmptyNeeded', false, false)
                state:set('isRobbing', false, false)
                SetGameplayCamRelativeHeading(0.0)
                SetGameplayCamRelativePitch(0.0, 1.0)
                DestroyCam(cam2, false)
                DisplayRadar(true)
                SetCurrentPedWeapon(plyPed, prevWeapon, true)
                FreezeEntityPosition(plyPed, false)
                notify('You have stolen $' .. tostring(random(750, 3000)) .. '.')
                storesToReset[#storesToReset + 1] = state.currentStore
            end
        else
            sleep = 1000
        end

        Wait(sleep)
    end
end

local function checkForClerkLife()
    local clerk = state.storeClerk

    while state.isRobbing do
        if IsPedDeadOrDying(clerk, true) then
            -- close store after robbery, and add it to the list of stores needing to be re-opened.
            state:set('manualRegisterEmptyNeeded', true, false)
            CreateThread(function()
                DisplayHelpTextThisFrame('emptyRegisterManuallyNeeded', true)
            end)
            checkForManualEmpty()
            return
        end

        Wait(1000)
    end
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

        if not state.isRobbing and inStore and IsPedArmed(ped, 4) and state.storeClerk and not Entity(state.storeClerk).state.beingRobbed then
            state:set('isRobbing', true, false)
            Entity(state.storeClerk).state:set('beingRobbed', true, false)
        elseif state.isRobbing and not inStore then
            notify('You have left the store and aborted the robbery.')
            state:set('isRobbing', false, false)
            state:set('currentStore', nil, false)
            state:set('inStore', false, false)
            Entity(state.storeClerk).state:set('beingRobbed', false, false)
        elseif inStore and state.storeClerk and Entity(state.storeClerk).state.beingRobbed and not state.isRobbing and not closedHelpTextRecentlyShown then
            closedHelpTextRecentlyShown = true
            DisplayHelpTextThisFrame('24/7_storeClosed', true)
        end

        Wait(1500)
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        helpShownRecently = false
        closedHelpTextRecentlyShown = false
    end
end)

CreateThread(function()
    while true do
        Wait(random(300000, 900000))
        for i = 1, #storesToReset do
            local storeCoords, _ = GetInteriorLocationAndNamehash(storesToReset[i])
            ClearArea(storeCoords.x, storeCoords.y, storeCoords.z, 20.0, false, false, false, false)
            DeletePed(state.storeClerk)
            storePeds[state.storeClerk] = nil
            state:set('storeClerk', nil, false)
            spawnClerk(Config.stores[storesToReset[i]].model, Config.stores[storesToReset[i]].clerkCoords)
            storesToReset[i] = nil
        end
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

        DisplayHelpTextThisFrame('robStore', true)
    end
end)

AddStateBagChangeHandler('isRobbing', ('player:%s'):format(serverId), function(_, _, value)
    if not value then return end

    CreateThread(checkForShooting)
    CreateThread(checkForClerkLife)

    if random(0, 100) >= 20 then
        ---normal robbery
        CreateThread(function()
            ClearHelp(true)
            DisplayHelpTextThisFrame('waitForTheCashier', true)
        end)
    else
        ---fight back
    end
end)