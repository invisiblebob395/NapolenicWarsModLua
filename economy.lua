
require "methods"
rouletteEconomyCountDown = -1
rouletteEconomyPlayers = {}
function tellRouletteEconomyRules(player)
    game.sreg[0] = "赌 盘 一 共 有 37格 (0-36) 每 格 都 有 1/37的 几 率 获 胜 。获 胜 后 的 倍 率 为 36/格 子 数 量 。最 高 格 子 下 注 量 为 18 格 （双 倍 ） "
    game.call_script(coloredChat, player, 0xFFFF22)
    game.sreg[0] = "下 注 方 式 为 /dupan 格 子 第 纳 尔 数 量 。如 /dupan 1-12 1000 为 在 1-12 的 格 子 里 下 注 1000 第 纳 尔。/dupan 1 1000则 为 在 第 一 个 格 子 里 下 注 1000 第 纳 尔"
    game.call_script(coloredChat, player, 0xFFFF22)
end
function startRouletteEconomy(player)
    rouletteEconomyCountDown = 60
    game.str_store_player_username(44, player)
    broadcastColoredChat(player, game.sreg[44] .. " 开 启 了  新 的 第 纳 尔 赌 盘 游 戏 。可 以 获 得 加 倍 的 第 纳 尔 。可 以 用 /dupan 报 名 参 加", 0xF70027)
end
function evaluateEconomyRoulette()
    math.randomseed(os.time())
    local winSquare = math.random(37) - 1
    broadcastColoredChat(0, "[游 戏 ] 赌 盘 游 戏 结 束 ！获 胜 的 方 块 为 " .. winSquare, 0xF70027)
    for i,m in ipairs(rouletteEconomyPlayers) do
        --evaluates if win
        local win = false
        if (winSquare >= m[5] and winSquare <= m[6]) or (winSquare <= m[5] and winSquare >= m[6]) then
            addDenars(m[1], m[3])
            if #rouletteEconomyPlayers <= 15 then
                broadcastColoredChat(m[2], "[游 戏 ]" .. m[4] .. "获 得 了 " .. m[3] .. " 第 纳 尔", 0xF70027)
            else
                game.sreg[0] = "[游 戏 ] " .. "你 胜 利 了 ！获 得 了 " .. m[3] .. "第 纳 尔"
                game.call_script(coloredChat, m[2], 0xF70027)
            end
        end
    end
    eraseTable(rouletteEconomyPlayers)
end
function checkEconRouletteStatus()
    if rouletteEconomyCountDown < 0 then return end
    if rouletteEconomyCountDown == 30 or rouletteEconomyCountDown == 15 or rouletteEconomyCountDown == 5 then
        broadcastColoredChat(0, "[游 戏 ] 赌 盘 游 戏 还 有 " .. rouletteEconomyCountDown .. "秒，可 以 用 /dupan 报 名 参 加 ，获 得 加 倍 第 纳 尔", 0xF70027)
    elseif rouletteEconomyCountDown == 0 then
        rouletteEconomyCountDown = -1
        evaluateEconomyRoulette()
    end
    rouletteEconomyCountDown = rouletteEconomyCountDown - 1
end
function placeBet(guid, id, amount, squares)
    if rouletteEconomyCountDown < 0 then
        startRouletteEconomy(id)
    end
    game.str_store_player_username(44, id)
    broadcastColoredChat(player, "[游 戏 ]" .. game.sreg[44] .. " 对 " .. squares .. "下 注 了 " .. amount .. " 第 纳 尔", 0xF70027)
    local params = squares
    if not tonumber(params) then
        params = split(squares, "-")
    else
        params = {tonumber(params), tonumber(params)}
    end
    local winAmount = round((36/(math.abs(round(1 + tonumber(params[2]))-round(tonumber(params[1])))))*amount)
    game.sreg[0] = "如 果 你 获 胜 ，则 会 获 得 " .. winAmount .. "的 奖 金"
    game.call_script(coloredChat, id, 0xFFFF22)
    table.insert(rouletteEconomyPlayers, {guid, id, winAmount, game.sreg[44], round(tonumber(params[1])), round(tonumber(params[2]))})
end