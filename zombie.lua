
--require "main"
require "methods"
zombieModeEnabled = false
huntersSpawned = false
zombieSeconds = 600
zombieRules = {
    "玩 家 死 亡 后 会 将 变 身 僵 尸 . Once killed, you will become a zombie.",
    "僵 尸 没 有 远 程 伤 害 . Zombies have no ranged damage.",
    "指 定 时 间 结 束 后 人 类 胜 利 . Humans win once the time has elapsed.",
    "当 没 有 人 类 时 僵 尸 胜 利 . Zombies win once no humans remain.",
    "最 后 两 名 人 类 将 成 为 幽 灵 猎 手 . The last two humans will receive special buffs.",
}
function broadcastZombieRules()
    broadcastColoredChat(0, "僵 尸 模 式 已 开 始  以 下 为 规 则 . Zombie mode has begun, rules are shown below.", 0xFFFF22)
    for i,m in ipairs(zombieRules) do
        broadcastColoredChat(0, i .. ". " .. m, 0xFFFF22)
    end
end
function zombieTimeUpdate()
    if roundTime == 0 then resetZombieRound() end
    if roundTime == 1 then broadcastZombieRules() end
    if zombieSeconds - roundTime == 0 then
        broadcastColoredChat(0, "人 类 胜 利 30秒 后 将 开 启 新 的 一 轮 . The round has ended in human victory. The next round will begin in 30 seconds. ", 0xFFFF22)
        addTimer("resetZombieRound()", 30)
    end
    if (zombieSeconds - roundTime) % 60 == 0  then
        broadcastColoredChat(0, "人 类 还 需 存 活 " .. (zombieSeconds - roundTime)/60 .. "分 钟 . " .. (zombieSeconds - roundTime)/60 .. " more minutes until a human victory.", 0xFFFF22)
    end
end
function zombieDeathStatusUpdate()
    local players = {}
    for curPlayer in game.playersI(1) do
        if game.player_get_team_no(0, curPlayer) == 0 then
            local agent = game.player_get_agent_id(0, curPlayer)
            if game.agent_is_active(agent) and game.agent_is_alive(agent) then table.insert(players, curPlayer) end
        end
    end
    if #players == 2 and not huntersSpawned then
        huntersSpawned = true
        broadcastColoredChat(0, "最 后 两 位 玩 家 变 身 幽 灵 猎 手  速 度 加 快  获 得 散 弹 枪 和 ban锤 . Last two players receive shotgun, banhammer, and a speed buff.", 0xFFFF22)
        for i, player in ipairs(players) do
            game.agent_set_speed_modifier(game.player_get_agent_id(0, player), 150)
            assignFinalWeapons(player)
        end
    elseif #players <= 0 and zombieSeconds - roundTime > 0 then
        broadcastColoredChat(0, "僵 尸 胜 利  人 类 已 被 灭 绝 30秒 后 将 开 启 新 的 一 轮 . The current round has ended in zombie victory. The next round will begin in 30 seconds.", 0xFFFF22)
        addTimer("resetZombieRound()", 30)
        roundTime = 2
    end
end
function resetZombieRound()
    local players = {}
    for curPlayer in game.playersI(1) do
        setPlayerTeam(curPlayer, 0)
        if game.player_get_team_no(0, curPlayer) ~= 2 and game.player_get_ping(0, curPlayer) < 100 then --specs might be afk..
            table.insert(players, curPlayer) --NO HIGH PINGERS
        end
    end
    if #players == 0 then
        for curPlayer in game.playersI(1) do
            table.insert(players, curPlayer) --no eligible.. everyone has a shot now
        end
    end
    for i=0,math.min(1, #players) do
        math.randomseed(os.time())
        local rand = math.random(#players)
        if players[rand] ~= nil then setPlayerTeam(players[rand], 1) end
        table.remove(players, rand)
    end
    huntersSpawned = false
    resetRoundTime()
    --reset round
    game.call_script(serverMessageReceived, 0, 51) --51: reset map
end
function assignFinalWeapons(player)
    --assigns shotgun, bullets, and banhammer
    equipItem(player, 2, 110)
    equipItem(player, 0, 31)
    equipItem(player, 1, 117)
    equipItem(player, 4, 627)
    equipItem(player, 5, 293)
    equipItem(player, 6, 773)
    equipItem(player, 7, 863)
end

