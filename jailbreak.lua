
require "methods"
lubenweiColor = 0xFF66FF
jailbreakMode = false
revealingItemsID = {20, 75, 82, 83, 93 }
jailbreakRules = {
    "农 奴 有 外 漏 武 器 必 须 先 警 告 ，手 上 携 带 武 器 可 以 直 接 杀 . If you see a revealing item, please warn before killing.",
    "农 奴 可 以 拳 打 脚 踢 狱 警 . Punching and kicking is allowed.",
    "农 奴 武 器 收 回 来 了 后 就 不 能 再 击 杀 ，击 杀 算 违 规 。除 非 农 奴 手 上 现 在 有 武 器 ，或 者 逃 跑 暴 动 ，否 则 不 可 击 杀 . Do not kill for past crimes."
}
function broadcastJailbreakRules(player)
    if player == -1 then
        broadcastMessage("请 认 真 仔 细 的 阅 读 以 下 越 狱 规 则")
        for i, m in ipairs(jailbreakRules) do
            broadcastMessage(i .. ". " .. m)
        end
    else
        sendInterAdminChat(player, "请 认 真 仔 细 的 阅 读 以 下 越 狱 规 则")
        for i, m in ipairs(jailbreakRules) do
            sendInterAdminChat(player, i .. ". " .. m)
        end
    end
end
function startJailbreak()
    game.sreg[0] = "/partizan"
    game.call_script(callCommand, 0, 0)
    game.sreg[0] = "/team 1 3"
    game.call_script(callCommand, 0, 0)
end
function endJailbreak()
    game.sreg[0] = "/partizan"
    game.call_script(callCommand, 0, 0)
end
function jailbreakAgentRespawned(agent)
    local time = game.store_mission_timer_a(0)
    if jailbreakMode and roundTime < 120 then
        local player = game.agent_get_player_id(0, agent)
        if game.player_is_active(player) then
            local team = game.player_get_team_no(0, player)
            if team == 1 then
                game.agent_set_damage_modifier(agent, 0)
                game.agent_set_ranged_damage_modifier(agent, 0)
                sendInterAdminChat(player, "你 暂 时 不 能 造 成 任 何 伤 害 。当 游 戏 开 始 2 分 钟 后 才 可 以 造 成 伤 害 ，请 不 要 提 前 暴 动 。You are unable to deal any damage right now, please wait until the game has progressed for two minutes")
            end
        end
    end
end
function jailbreakCheckStatus()
    local time = game.store_mission_timer_a_msec(0)
    if jailbreakMode and roundTime == 10 then
        broadcastColoredChat(0, "农 奴 要 两 分 钟 后 才 能 造 成 伤 害 ，请 勿 提 前 暴 动 。Prisoners deal no damage until 2 minutes after the game has started", 0xFFFF22)
        for curAgent in game.agentsI() do
            if game.agent_is_active(curAgent) and game.agent_is_alive(curAgent) then
                local player = game.agent_get_player_id(0, curAgent)
                if game.player_is_active(player) and game.player_get_team_no(0, player) == 1 then
                    game.agent_set_damage_modifier(curAgent, 0)
                    game.agent_set_ranged_damage_modifier(curAgent, 0)
                end
            end
        end
    end
    --time >= 120000 and time <= 121000
    if jailbreakMode and roundTime == 120 then
        for curAgent in game.agentsI() do
            if game.agent_is_active(curAgent) and game.agent_is_alive(curAgent) then
                game.agent_set_damage_modifier(curAgent, 100)
                game.agent_set_ranged_damage_modifier(curAgent, 100)
            end
        end
        broadcastColoredChat(0, "农 奴 伤 害 已 经 开 启 ，可 以 开 始 暴 动 。Prisoner damage has been enabled.", 0xFFFF22)
    end
end
function isValidKillJailbreak(agent)
    local itemWielded = game.agent_get_wielded_item(0, agent, 0)
    local itemOne = game.agent_get_item_slot(0, agent, 0)
    local itemTwo = game.agent_get_item_slot(0, agent, 1)
    local itemThree = game.agent_get_item_slot(0, agent, 2)
    local itemFour = game.agent_get_item_slot(0, agent, 3)
    if itemOne == nil then itemOne = 0 end
    if itemTwo == nil then itemTwo = 0 end
    if itemThree == nil then itemThree = 0 end
    if itemFour == nil then itemFour = 0 end
    --sendInterAdminChat(18, itemWielded .. " " .. itemOne .. " " .. itemTwo .. " " .. itemThree " " .. itemFour)
    return (itemWielded >= 0 or (itemOne > 145 or (itemOne < 127 and itemOne > 0)) or (itemTwo > 145 or (itemTwo < 127 and itemTwo > 0)) or (itemThree > 145 or (itemThree < 127 and itemThree > 0)) or (itemFour > 145 or (itemFour < 127 and itemFour > 0)))
end