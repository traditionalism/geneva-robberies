local storesToReset = {}
local storePeds = {}
local clerksToDelete = {}
local timeCashMultiplier = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.3, 0.3, 0.3, 0.6, 0.6, 0.8, 0.8, 1.0, 1.0, 1.5, 1.5, 2.0, 2.5, 3.0 }
local helpShownRecently = false
local closedHelpTextRecentlyShown = false
local random = math.random
local floor = math.floor
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
    AddTextEntry('storeClosed', 'This Convenience Store is closed. It was recently robbed, but will open again soon.')

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
    SetPedCombatAttributes(clerk, 46, true)
    SetPedFleeAttributes(clerk, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
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

local function getRobberyResult()
    local hour = GetClockHours()
    local hourMath = ((hour * 0.6) + 0.5) * 1000
    local finalMath = random(floor(hourMath), floor(hourMath + 5000))
    local cash = floor(finalMath / 8) * (timeCashMultiplier[hour] or 0.1)
    return floor(finalMath / 2), floor(cash)
end

local function checkForManualEmpty()
    local plyPed = PlayerPedId()
    local store = state.currentStore
    local manualEmptyCoords = Config.stores[store].manualEmptyCoords
    local sleep = 1000

    RequestAnimDict('oddjobs@shop_robbery@rob_till')
    repeat Wait(0) until HasAnimDictLoaded('oddjobs@shop_robbery@rob_till')
    while state.manualRegisterEmptyNeeded do
        local plyCoords = GetEntityCoords(plyPed)
        local dist = #(plyCoords - vec3(manualEmptyCoords.x, manualEmptyCoords.y, manualEmptyCoords.z))

        if dist <= 1.3 then
            sleep = 0
            DisplayHelpTextThisFrame('takeCash', true)

            if IsControlJustPressed(0, 51) then
                SetEntityCoords(plyPed, manualEmptyCoords.x, manualEmptyCoords.y, manualEmptyCoords.z, false, false, false, false)
                SetEntityHeading(plyPed, manualEmptyCoords.w)
                local _, prevWeapon = GetCurrentPedWeapon(plyPed, true)
                SetCurrentPedWeapon(plyPed, `WEAPON_UNARMED`, true)
                ClearPedTasksImmediately(plyPed)
                DisplayRadar(false)
                createFirstCamera()
                createSecondCamera()
                local timeToTake, pay = getRobberyResult()
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'enter', 8.0, -8.0, -1, 0, 0.0, false, false, false)
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'loop', 8.0, -8.0, timeToTake, 1, 0.0, false, false, false)
                CreateThread(function()
                    while IsEntityPlayingAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'loop', 3) do
                        local time = GetEntityAnimCurrentTime(plyPed, 'oddjobs@shop_robbery@rob_till', 'loop')
                        local playSound = time > 0.374 and time <= 0.484 or time > 0.824 and time <= 0.92

                        if playSound then
                            local soundId = GetSoundId()
                            PlaySoundFrontend(soundId, 'ROBBERY_MONEY_TOTAL', 'HUD_FRONTEND_CUSTOM_SOUNDSET', true)
                            ReleaseSoundId(soundId)
                        end

                        Wait(0)
                    end
                end)
                Wait(timeToTake)
                TaskPlayAnim(plyPed, 'oddjobs@shop_robbery@rob_till', 'exit', 8.0, -1.5, -1, 0, 0.0, false, false, false)
                local registerCoords = GetEntityCoords(GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 5.0, `prop_till_01`, false, false, false))
                CreateModelSwap(registerCoords.x, registerCoords.y, registerCoords.z, 0.5, `prop_till_01`, `prop_till_01_dam`, false)
                RemoveAnimDict('oddjobs@shop_robbery@rob_till')
                SetCamActive(cam2, false)
                RenderScriptCams(false, false, 3000, true, false)
                state:set('manualRegisterEmptyNeeded', false, false)
                state:set('isRobbing', false, false)
                SetGameplayCamRelativeHeading(0.0)
                SetGameplayCamRelativePitch(0.0, 1.0)
                DestroyCam(cam, false)
                DestroyCam(cam2, false)
                DisplayRadar(true)
                SetCurrentPedWeapon(plyPed, prevWeapon, true)
                notify(('~w~You have stolen ~g~$%s~w~.'):format(pay))
                storesToReset[#storesToReset + 1] = state.currentStore
                clerksToDelete[#clerksToDelete + 1] = state.storeClerk
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
            state:set('manualRegisterEmptyNeeded', true, false)
            CreateThread(function()
                ClearHelp(true)
                DisplayHelpTextThisFrame('emptyRegisterManuallyNeeded', true)
            end)
            checkForManualEmpty()
            return
        end

        Wait(1000)
    end
end

local function startNormalRobbery()
    local plyPed = PlayerPedId()
    local clerk = state.storeClerk

    RequestAnimDict('mp_am_hold_up')
    RequestModel(`prop_poly_bag_01`)
    repeat Wait(0) until HasAnimDictLoaded('mp_am_hold_up') and HasModelLoaded(`prop_poly_bag_01`)
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
            DisplayHelpTextThisFrame('storeClosed', true)
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
            storesToReset[i] = nil
        end

        for i = 1, #clerksToDelete do
            DeletePed(state.storeClerk)
            storePeds[state.storeClerk] = nil
            spawnClerk(Config.stores[storesToReset[i]].model, Config.stores[storesToReset[i]].clerkCoords)
            clerksToDelete[i] = nil
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
    local clerk = state.storeClerk

    if not helpShownRecently and not IsPedArmed(plyPed, 4) then
        helpShownRecently = true
        DisplayHelpTextThisFrame('robStore', true)
    end

    TaskLookAtEntity(clerk, plyPed, 3000, 2048, 3)
    if GetEntityModel(clerk) == `mp_m_shopkeep_01` then
        PlayPedAmbientSpeechWithVoiceNative(clerk, Config.clerkVoiceLines[random(1, #Config.clerkVoiceLines)], getVoiceForClerk(), 'SPEECH_PARAMS_FORCE', true)
    end
end)

AddStateBagChangeHandler('isRobbing', ('player:%s'):format(serverId), function(_, _, value)
    if not value then return end

    local clerk = state.storeClerk

    CreateThread(checkForShooting)
    CreateThread(checkForClerkLife)

    if random(0, 100) > 0 then
        ---normal robbery
        CreateThread(function()
            ClearAllHelpMessages()
            DisplayHelpTextThisFrame('waitForTheCashier', true)
        end)
        StopCurrentPlayingAmbientSpeech(clerk)
        PlayPedAmbientSpeechWithVoiceNative(clerk, 'SHOP_SCARED', getVoiceForClerk(), 'SPEECH_PARAMS_INTERRUPT_SHOUTED_CRITICAL', true)
        startNormalRobbery()
    else
        ---fight back
    end
end)