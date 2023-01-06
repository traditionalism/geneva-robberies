if GetResourceState('es_extended') ~= 'started' then return end

function AddMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(amount)
end