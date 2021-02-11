
require "methods"
persistentPositionSlot = 57
guidTable = {}
killTable = {}
deathTable = {}
moneyTable = {}
usernameTable = {}
function readStorageFromFile()
    eraseTable(guidTable)
    eraseTable(killTable)
    eraseTable(moneyTable)
    eraseTable(deathTable)
    eraseTable(usernameTable)
    local databaseContent = readFile("database.txt")
    local lines = split(databaseContent, "\n")
    for i, line in ipairs(lines) do
        local params = split(line, "-")
        table.insert(guidTable, tonumber(params[1]))
        table.insert(killTable, params[2])
        table.insert(deathTable, params[3])
    end
end
function updateFile()
    local lines = ""
    for i, content in ipairs(guidTable) do
        lines = lines .. guidTable[i] .. "-" .. killTable[i] .. "-" .. deathTable[i] .. "-" .. moneyTable[i] .. "\n"
    end
    local databaseFile = io.open("database.txt", "w")
    databaseFile:write(lines)
    databaseFile:flush()
    databaseFile:close()
end

function shiftPlayerIndices(noshift, compareIndex)

end

function registerInDatabase(player, guid, index)
    table.insert(guidTable, index, guid)
    table.insert(killTable, index, 0)
    table.insert(deathTable, index, 0)
    table.insert(moneyTable, index, 10000)
    game.str_store_player_username(44, player)
    --shifts all players rightward
    shiftPlayerIndices(player, index)
end
function playerKilledUpdateScore(killer, killed, teamNoKiller, teamNoKilled)
    --team kills don't go towards stats for killed, -1 kills for killer
    local guid = game.player_get_unique_id(0, killer)
    local killedGuid = game.player_get_unique_id(0, killed)
    local killerIndex = binarySearch(guidTable, guid)[2]
    local killedIndex = binarySearch(guidTable, killedGuid)[2]
    if teamNoKiller == teamNoKilled then -- tk
        killTable[killerIndex] = killTable[killerIndex] - 1
    else
        print(#killTable)
        killTable[killerIndex] = killTable[killerIndex] + 1
        print(#deathTable)
        deathTable[killedIndex] = deathTable[killedIndex] + 1
    end
end
function checkStats(player)
    local guid = game.player_get_unique_id(0, player)
    local index = binarySearch(guidTable, guid)[2]
    local kills = killTable[index]
    local deaths = deathTable[index]
    local KD = getKDFromScore(kills, deaths)
    return {kills, deaths, KD}
end
function checkDatabase(player)
    local guid = game.player_get_unique_id(0, player)
    local binarySearchResult = binarySearch(guidTable, guid)
    game.player_set_slot(player, persistentPositionSlot, binarySearchResult[2])
    if not binarySearchResult[1] then
        registerInDatabase(player, guid, binarySearchResult[2])
    end
    local stats = checkStats(player)
    game.sreg[0] = "你 在 本 月 总 共  击 杀 " .. stats[1] .. "个 敌 人 ，死 亡 " .. stats[2] .. "次 KD 是 " .. stats[3]
    game.call_script(coloredChat, player, 0xFFFF22)
end
--1 = kills 2 = deaths 3 = KD 4 = money
function getTopScores(type, amount)
    if type == 3 then

    end
end
function addMoneyToPlayer(player, value)
    local binarySearchResult = binarySearch(guidTable, player)
    if binarySearchResult[1] then
        moneyTable[binarySearchResult[2]] = moneyTable[binarySearchResult[2]] + value
        return true
    else
        return false
    end
end
function deductMoneyFromPlayer(player, value)
    local binarySearchResult = binarySearch(guidTable, player)
    if binarySearchResult[1] then
        moneyTable[binarySearchResult[2]] = moneyTable[binarySearchResult[2]] - value
        return true
    else
        return false
    end
end
function transferMoney(playerFrom, playerTo, transferAmount)
    if not transferAmount > 0 then return end
    local playerFromIndex = game.player_get_slot(0, playerFrom, persistentPositionSlot)
    local guid
    if game.player_is_active(playerTo) then
        guid = game.player_get_unique_id(0, playerTo)
    else
        guid = playerTo
    end
    local binarySearchResult = binarySearch(guidTable, guid)

end