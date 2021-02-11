
require "methods"
rouletteCountDown = -1
roulettePlayers = {}
rouletteStartTime = 0
--    local killerPlayerLifeKills = game.player_get_slot(0, killerPlayer, killsThisLife)
--     game.player_set_slot(killerPlayer, killsThisLife, killerPlayerLifeKills)
function startRoulette(player)
    rouletteStartTime = os.time()
    rouletteCountDown = 60
    game.str_store_player_username(44, player)
    broadcastColoredChat(player, game.sreg[44] .. " 开 启 了  新 的 俄 罗 斯 轮 盘 赌 游 戏 。输 的 人 将 被 天 谴 。可 以 用 /roulette 报 名 参 加", 0xF70027)
end
function addPlayerToRoulette(player)
    if hasValue(roulettePlayers, player) then
        game.sreg[0] = "你 已 经 参 与 了  本 次 游 戏 ，不 可 再 参 与"
        game.call_script(coloredChat, player, 0xF70027)
    else
        table.insert(roulettePlayers, player)
        game.str_store_player_username(44, player)
        broadcastColoredChat(player, "[游 戏 ] 勇 敢 的 " .. game.sreg[44] .. " 报 名 参 加 了  俄 罗 斯 赌 盘 游 戏 。可 以 用 /roulette 参 加", 0xF70027)
    end
end
function rouletteEvaluate()
    if #roulettePlayers > 1 then
        local deadPlayerIndex = math.random(#roulettePlayers)
        local deadPlayer = roulettePlayers[deadPlayerIndex]
        if not game.player_is_active(deadPlayer) then
            table.remove(roulettePlayers, deadPlayerIndex)
            rouletteEvaluate()
            return
        else
            local deadPlayerAgent = game.player_get_agent_id(0, deadPlayer)
            if not game.agent_is_alive(deadPlayerAgent) then
                table.remove(roulettePlayers, deadPlayerIndex)
                rouletteEvaluate()
                return
            else
                game.agent_get_position(56, deadPlayerAgent)
                game.particle_system_burst(51, 56, 100) --bursts large fireplace, game.preg[30]
                game.particle_system_burst(52, 56, 100) --bursts large fireplace, game.preg[30]
                game.call_script(playSoundAtPos, 182)
                game.str_store_player_username(44, deadPlayer)
                broadcastColoredChat(0, "[游 戏 ]" .. game.sreg[44] .. " 不 幸 身 亡", 0xF70027)
                game.call_script(slayPlayer, deadPlayer, 1)
                rouletteCountDown = -1
            end
        end
    else
        broadcastColoredChat(0, "[游 戏 ] 活 着 的 参 与 人 数 不 够 多 ，至 少 需 要 两 人", 0xF70027)
        rouletteCountDown = -1
    end
    eraseTable(roulettePlayers)
end
function checkRouletteStatus()
    if rouletteCountDown < 0 then
        return
    end
    rouletteCountDown = rouletteCountDown - 1
    if rouletteCountDown == 30 or rouletteCountDown == 15 or rouletteCountDown == 5 then
        broadcastColoredChat(0, "[游 戏 ] 俄 罗 斯 赌 盘 游 戏 还 有 " .. rouletteCountDown .. "秒，可 以 用 /roulette 报 名 参 加", 0xF70027)
    elseif rouletteCountDown == 0 then
        rouletteEvaluate()
    end
end
function handleRoulette(player)
    local agentID = game.player_get_agent_id(0, player)
    if not game.agent_is_alive(agentID) then
        game.sreg[0] = "你 必 须 活 着 才 能 参 加 本 次 赌 注"
        game.call_script(coloredChat, player, 0xF70027)
        return
    end
    if rouletteCountDown > -1 then
        addPlayerToRoulette(player)
    else
        startRoulette(player)
        addPlayerToRoulette(player)
    end
end