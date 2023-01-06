if GetResourceState('qb-core') ~= 'started' then return end

function AddMoney(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddMoney("cash", amount, reason)
    end
end