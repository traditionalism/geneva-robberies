if GetResourceState('ND_Core') ~= 'started' then return end

NDCore = exports["ND_Core"]:GetCoreObject()

function AddMoney(source, amount)
    NDCore.Functions.AddMoney(amount, source, "cash")
end