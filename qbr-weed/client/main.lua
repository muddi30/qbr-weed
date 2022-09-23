local QBCore = exports['qbr-core']:GetCoreObject()
local mining = false
local HasVehicle = true

-- Functions
function addBlip(coords, sprite, size, colour, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipScale  (blip, size)
    SetBlipColour (blip, colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

---load dict and model
function loadModel(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

function loadDict(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

function LoadDict(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	  	Citizen.Wait(10)
    end
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

function CraftItem(item)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local inventory = QBCore.Functions.GetPlayerData().inventory
    local count = 0    
    if(count == 0) then
        count = 1
        FreezeEntityPosition(PlayerPedId(), true)
        QBCore.Functions.Progressbar("search_register", "Crafting...", 5000, false, true, {disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                            disableInventory = true,
                        }, {}, {}, {}, function()end, function()
                            
                        end)
        local dict = loadDict('script_re@gold_panner@gold_success')
        TaskPlayAnim(PlayerPedId(), dict, 'SEARCH01', 8.0, 8.0, -1, 1, false, false, false)
        Citizen.Wait(5000)
        ClearPedTasks(GetPlayerPed())
        TriggerServerEvent("crafting:process:"..item)
        FreezeEntityPosition(PlayerPedId(), false)        
    else
        QBCore.Functions.Notify('You already doing something!', 'error')
    end
end

-- Threads
for k, v in pairs(Config.Collecting) do
    if v.showBlip then
        Citizen.CreateThread(function()
            while true do       
                Citizen.Wait(1000)
                if v.Ore ~= 'none' then
                    local CollectBlip = N_0x554d9d53f696d002(1664425300, v.Collect)
                    SetBlipSprite(CollectBlip, v.Csprite)
                    SetBlipScale(CollectBlip, 0.2)
                    Citizen.InvokeNative(0x9CB1A1623062F402, tonumber(CollectBlip), "Gather Ore")

                    local ProcessBlip = N_0x554d9d53f696d002(1664425300, v.Process)
                    SetBlipSprite(ProcessBlip, v.Psprite)
                    SetBlipScale(ProcessBlip, 0.2)
                    Citizen.InvokeNative(0x9CB1A1623062F402, tonumber(ProcessBlip), "Process "..QBCore.Shared.Items[v.ItemIn].label)
                else
                    local CollectBlip = N_0x554d9d53f696d002(1664425300, v.Collect)
                    SetBlipSprite(CollectBlip, v.Csprite)
                    SetBlipScale(CollectBlip, 0.2)
                    Citizen.InvokeNative(0x9CB1A1623062F402, tonumber(CollectBlip), "Gather "..QBCore.Shared.Items[v.ItemIn].label)

                    local ProcessBlip = N_0x554d9d53f696d002(1664425300, v.Process)
                    SetBlipSprite(ProcessBlip, v.Psprite)
                    SetBlipScale(ProcessBlip, 0.2)
                    Citizen.InvokeNative(0x9CB1A1623062F402, tonumber(ProcessBlip), "Process "..QBCore.Shared.Items[v.ItemIn].label)
                end
                break
            end
        end)
    end
end

for k, v in pairs (Config.Collecting) do

    local procesX = v.Process.x
    local procesY = v.Process.y
    local procesZ = v.Process.z

    Citizen.CreateThread(function()
        while true do
        Citizen.Wait(3)
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.Process, true)
        local hasitem = false
        local hni = false
        if dist <= 2.0 then
            DrawText3D(procesX, procesY, procesZ+0.1, "Press ~d~[E]~s~ to craft "..QBCore.Shared.Items[v.ItemOut].label.."")
            if IsControlJustPressed(0, 0xCEFD9220) then 
                QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                    hasitem = result
                    hni = true
                end, v.ItemIn)
                while(not hni) do
                    Citizen.Wait(100)
                end
                if (hasitem) then
                    CraftItem(QBCore.Shared.Items[v.ItemIn].name)
                else
                    QBCore.Functions.Notify('You don\'t have '..QBCore.Shared.Items[v.ItemIn].label..'!', 'error')
                end
            end	
        end
        
    end
    end)
end

for k, v in pairs (Config.Collecting) do
    Citizen.CreateThread(function()    
        while true do
            local closeTo = 0
            local xp 
            local yp
            local zp
            for i, c in pairs(v.CollectPosition) do
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), c.coords, true) <= 2.5 then
                    closeTo = c
                    xp = c.coords.x
                    yp = c.coords.y
                    zp = c.coords.z-0.97
                    break
                end
        end
        if type(closeTo) == 'table' then
            while GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), closeTo.coords, true) <= 2.5 do
                Wait(0)
                DrawText3D(xp, yp, zp+0.97, 'Press ~d~[E]~s~ and ~d~[LMB]~s~ to gather '..QBCore.Shared.Items[v.ItemIn].label..'. Press ~d~[G]~s~ to end! ')
                local hastool = false
                local hnt = false
                if IsControlJustReleased(0, 0xCEFD9220) then
                    if v.Tool ~= 'none' then
                        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                            hastool = result
                            hnt = true
                        end, v.Tool)
                        while(not hnt) do
                            Citizen.Wait(100)
                        end
                    else 
                        hastool = true
                    end
                    if (hastool) then
                        local player, distance = QBCore.Functions.GetClosestPlayer()
                        if distance == -1 or distance <= 4.0 then
                            local axe = nil
                            mining = true
                            SetEntityCoords(PlayerPedId(), vector3(closeTo.coords.x, closeTo.coords.y, closeTo.coords.z-0.97))
                            SetEntityHeading(PlayerPedId(), closeTo.heading)
                            FreezeEntityPosition(PlayerPedId(), true)
                            if v.Objects['pickaxe'] ~= 'none' then
                                local model = loadModel(GetHashKey(v.Objects['pickaxe']))
                                axe = CreateObject(model, GetEntityCoords(PlayerPedId()), true, false, false)
                                AttachEntityToEntity(axe, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), v.AttatchPoint), v.Px, v.Py, v.Pz, v.Rx, v.Ry, v.Rz, false, true, true, true, 0, true)
                            end
                            while mining do
                                Wait(0)
                                --SetCurrentPedWeapon(PlayerPedId(), GetHashKey('w_unarmed'))
                                DisableControlAction(0, 0x07CE1E61, true)
                                if IsDisabledControlJustReleased(0, 0x07CE1E61) then
                                   local dict = loadDict(v.Dict)
                                   TaskPlayAnim(PlayerPedId(), dict, v.Anim, 8.0, 8.0, -1, 1, false, false, false)
                                    QBCore.Functions.Progressbar("gathering", "Gathering...", v.Duration, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                        disableInventory = true,
                                    }, {}, {}, {}, function()end, function()
                                        
                                    end)
                                local timer = GetGameTimer() + v.Duration
                                while GetGameTimer() <= timer do Wait(0) DisableControlAction(0, 0x07CE1E61, true) end
                                    
                                    ClearPedTasks(PlayerPedId())
                                    TriggerServerEvent(v.ItemIn..':getItem')
                                elseif IsDisabledControlJustReleased(0, 0x760A9C6F) then
                                    break
                                end
                            end
                            mining = false
                            if axe ~= nil then
                                DetachEntity(axe, true, true)
                                DeleteObject(axe)
                            end                          
                            FreezeEntityPosition(PlayerPedId(), false)
                        else
                        end
                    else
                        if v.Tool ~= 'none' then
                            QBCore.Functions.Notify('You need a Tool: '..QBCore.Shared.Items[v.Tool].label..'!', 'error')
                        end
                    end
                end
            end
        end
        Wait(250)
    end
    end)
end

-- Events
