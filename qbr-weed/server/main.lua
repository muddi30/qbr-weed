local sharedItems = exports['qbr-core']:GetItems()

for k, v in pairs(Config.Collecting) do
    RegisterServerEvent("crafting:process:"..v.ItemIn, function()       
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
                
        if Player.Functions.GetItemByName(v.ItemIn).amount >= v.Input then
            local chance = math.random(1, 8)
            Player.Functions.RemoveItem(v.ItemIn, v.Input)
            Player.Functions.AddItem(v.ItemOut, v.Output)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[v.ItemIn], "remove")
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[v.ItemOut], "add")
            TriggerClientEvent('QBCore:Notify', src, 'You have crafted '..v.Output..'x '..QBCore.Shared.Items[v.ItemOut].label..'!', "success")  
        else
            TriggerClientEvent('QBCore:Notify', src, 'You need at least '..v.Input..'x '..QBCore.Shared.Items[v.ItemIn].label ..'!', "error") 
        end
    end)
end

for k, v in pairs(Config.Collecting) do
    RegisterServerEvent(v.ItemIn..':getItem')
    AddEventHandler(v.ItemIn..':getItem', function()
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if math.random(0, 100) <= v.ChanceToGetItem then
            if v.Ore ~= 'none' then
                local randomItem = v.Ore[math.random(1, #v.Ore)]
                local Item = xPlayer.Functions.GetItemByName(v.Ore)
                if Item == nil then
                    xPlayer.Functions.AddItem(randomItem, 1)
                    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[randomItem], "add")
                else
                    if Item.amount < v.MaxItems then
                        xPlayer.Functions.AddItem(v.Ore, 1)
                        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[randomItem], "add")
                    else
                        TriggerClientEvent('QBCore:Notify', source, 'You have enough for now, go and process the '..QBCore.Shared.Items[v.Ore].label..'!', "error") 
                    end
                end                
            else
                local randomItem = v.Items[math.random(1, #v.Items)]
                local Item = xPlayer.Functions.GetItemByName(v.ItemIn)
                if Item == nil then
                    xPlayer.Functions.AddItem(randomItem, 1)
                    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[randomItem], "add")
                else
                    if Item.amount < v.MaxItems then
                        xPlayer.Functions.AddItem(randomItem, 1)
                        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[randomItem], "add")
                    else
                        TriggerClientEvent('QBCore:Notify', source, 'You have enough for now, go and process the '..QBCore.Shared.Items[v.ItemIn].label..'!', "error") 
                    end
                end
            end
        end
    end)
end
