
require "VIP"
require "methods"
require "admintools"
require "playerTools"
require "killStreak"
require "mute"
require "minigame"
require "methods"
require "jailbreak"
require "economy"
require "molotovs"
require "zombie"
apiFile = "api.php"
zombieMode = 0
--SLOTS --PLAYERS
muteSlot = 41
muteTime = 42
whisperSlot = 43
--global variable declarations
forcePartizan = 0 --forces partizan when second team is russia
infiniteBPAdmins = 0
ratioBalanceUsed = 0
--tick
ticks = 0
roundTime = 0
--current round time
root = {1477436, 1397826, 1302553 }

molotovsEnabled = true
lastSceneProp = -1


skins = {} --skins: skins[x][1] = name skins[x][2] = all guids available to, skins[x][3-10] = items, this is a 3D array
function reloadFile(player)
    dofile("main.lua") --reloads main.lua
    dofile("methods.lua")
    dofile("VIP.lua")
    dofile("mute.lua")
    dofile("killStreak.lua")
    dofile("jailbreak.lua")
    dofile("adminTools.lua")
    dofile("playerTools.lua ")
    dofile("minigame.lua")
    dofile("methods.lua")
    dofile("economy.lua")
    dofile("molotovs.lua")
    dofile("zombie.lua")
    sendInterAdminChat(player, "Reloaded lua file")
end

function handleSpawnItem(player, message, itemType)
    local args = split(message, " ")
    if not tonumber(args[2]) then
        sendInterAdminChat(player, "Invalid ID")
    else
        local itemID = tonumber(args[2])
        if itemType == 0 and giveItem(player, itemID, -1) then
            game.str_store_item_name(50, itemID)
            sendInterAdminChat(player, "You have equipped " .. game.sreg[50])
        elseif itemType == 1 and spawnHorse(player, itemID) then
            game.str_store_item_name(50, itemID)
            sendInterAdminChat(player, "You have spawned a " .. game.sreg[50])
        elseif itemType == 2 and spawnItem(player, itemID) then
        elseif itemType == 3 then
            if #args == 2 and tonumber(args[2]) then
                spawnItem(tonumber(args[2]))
                game.agent_get_position(2, game.player_get_agent_id(0, player))
                game.position_move_y(2, 200)
                game.set_spawn_position(2)
                game.spawn_scene_prop(tonumber(args[2]))
                lastSceneProp = game.reg[0]
                table.insert(instances, lastSceneProp)
                sendInterAdminChat(player, "Success")
            elseif #args == 5 and tonumber(args[2]) and tonumber(args[3]) and tonumber(args[4]) and tonumber(args[5]) then
                game.position_set_x(2, tonumber(args[3]))
                game.position_set_y(2, tonumber(args[4]))
                game.position_set_z(2, tonumber(args[5]))
                game.set_spawn_position(2)
                game.spawn_scene_prop(tonumber(args[2]))
                local instance = game.reg[0]
                table.insert(instances, lastSceneProp)
                lastSceneProp = instance
                sendInterAdminChat(player, "Success")
            else
                sendInterAdminChat(player, "Failed")
            end
        else
            sendInterAdminChat(player, "Failed!")
        end
    end
end
function handleEquipItem(player, message)
    local args = split(message, " ")
    if not tonumber(args[2]) and tonumber(args[3]) then
        sendInterAdminChat(player, "Invalid arguments")
    else
        local itemSlot = math.floor(tonumber(args[2]))
        local itemID = math.floor(tonumber(args[3]))
        if equipItem(player, itemSlot, itemID) then
            game.str_store_item_name(50, itemID)
            sendInterAdminChat(player, "你 装 备 了 " .. game.sreg[50])
        else
            sendInterAdminChat(player, "Failed!")
        end
    end
end
function showSkins(player)
    local guid = game.player_get_unique_id(0, player)
    game.sreg[0] = "你 的 皮 肤"
    game.call_script(coloredChat, player, 0xFFFF22)
    for i, m in ipairs(skins) do
        if(hasValue(m[2], guid)) then
            game.sreg[0] = m[1]
            game.call_script(coloredChat, player, 0xFFFF22)
        end
    end
end
function handleSkin(player, message)
    local guid = game.player_get_unique_id(0, player)
    local args = split(message, " ")
    if #args < 2 then
        game.sreg[0] = "请 加 上 你 的  皮 肤 名 字 。如 果 不 知 道 ，用 /skins 查 找 "
        game.call_script(coloredChat, player, 0xFFFF22)
    end
    for i, m in ipairs(skins) do
        if(m[1] == args[2]) and hasValue(m[2], guid) then
            --applies skin

        end
    end
end
function playerInitial(player)
    local guid = game.player_get_unique_id(0, player)
    game.str_store_player_username(44, player)
    game.reg[45] = 100
    game.send_message_to_url("http://127.0.0.1/api.php?type=1&guid=" .. guid .. "&id=" .. player .. "&username=" .. game.sreg[44])
end
function playerJoined(player)
    --sends welcome message
    game.str_store_player_username(44, player)
    sendInterAdminChat(player, "欢 迎 加 入 本 服 务 器 。指 令 列 表 请 按 T 然 后 输 入 /bangzhu。请 遵 守 服 务 器 规 章 制 度")
    sendInterAdminChat(player, "-------新 闻-------")
    for i,m in ipairs(news) do
        sendInterAdminChat(player, i .. ". " .. m)
    end
    if jailbreakMode == true then
        broadcastJailbreakRules(player)
    end
    local guid = game.player_get_unique_id(0, player)
    vipJoinNotification(player)
    resetKills(player, true)
    --set beauty to 0
    resetBeauty(player)
    --set mute to 0
end
function agentKilled(agent, killerAgent)
    local killTime = game.store_mission_timer_a(0)
    local killerPlayer = game.agent_get_player_id(0, killerAgent)
    local killedPlayer = game.agent_get_player_id(0, agent)
    local teamNoKilledPlayer = game.agent_get_team(0, agent)
    local teamNoKillerPlayer = game.agent_get_team(0, killerAgent)
    local guidKiller = game.player_get_unique_id(0, killerPlayer)
    local guidKilled = game.player_get_unique_id(0, killedPlayer)
    if zombieModeEnabled and teamNoKilledPlayer == 0 and roundTime > 10 then zombieDeathStatusUpdate() end
    if not(game.player_is_active(killedPlayer) and game.player_is_active(killedPlayer)) or killedPlayer == killerPlayer or killerPlayer == 0 then
        return
    end
    vipKillEffect(agent, killerAgent, killerPlayer, killedPlayer)

    --if teamNoKilledPlayer ~= teamNoKillerPlayer then
    game.reg[45] = 100
    game.send_message_to_url("http://127.0.0.1/api.php?type=4&guid=" .. guidKiller .. "&id=" .. killerPlayer .. "&kills=1")
    game.send_message_to_url("http://127.0.0.1/api.php?type=5&guid=" .. guidKilled .. "&id=" .. killedPlayer)
    game.send_message_to_url("http://127.0.0.1/api.php?type=8&id=1&killerid=" .. guidKiller .. "&deadid=" .. guidKilled)
    --elseif killerPlayer ~= killedPlayer and killerPlayer ~= 0 then
    --    game.reg[45] = 100
    --    game.send_message_to_url("http://127.0.0.1/api.php?type=4&guid=" .. guidKiller .. "&id=" .. killerPlayer .. "&kills=-1")
    --    game.send_message_to_url("http://127.0.0.1/api.php?type=8&id=1&killerid=" .. guidKilled .. "&deadid=" .. guidKiller)
    -- end
    --tests for jailbreak
    if jailbreakMode == true and teamNoKillerPlayer == 0 and teamNoKilledPlayer == 1 then
        if isValidKillJailbreak(agent) == false then
            game.str_store_player_username(44, killerPlayer)
            broadcastColoredChat(0, game.sreg[44] .. "系 统 检 测 你 刚 刚 杀 的 农 奴 没 有 使 用 武 器 ，也 没 有 正 常 的 外 漏 武 器 。请 给 个 杀 人 原 因", 0xFFFF22)
        end
    end
    --reset beauty when dead
    resetBeauty(killedPlayer)
    --kill streak logic
    if killStreakEnabled and teamNoKilledPlayer ~= teamNoKillerPlayer then
        incrementKillStreak(killerPlayer)
        showKillStreakEnd(killerPlayer, killedPlayer)
        showKillStreak(killerPlayer)
    end
    resetKills(killedPlayer, true)
end
function showSettings(player, ID)
    if ID == -1 then
        for i, m in ipairs(settings) do
            sendInterAdminChat(player, m)
        end
    end
end
function whisper(playerFrom, playerTo, message)
    game.str_store_player_username(44, playerFrom)
    sendInterAdminChat(playerTo, game.sreg[44] .. "跟 你 发 起 了 私 聊 。你 可 以 用 /r回 复 他 （列如/r 你 好 )")
    game.sreg[0] = "[" .. game.sreg[44] .. "] " .. message
end
function handleWhisper(player, message)
    local args = split(message, " ")
    if tonumber(args[2]) then
        local playerWhisperedTo = math.floor(tonumber(args[2]))
        if not game.player_is_active(playerWhisperedTo) then
            return
        else
            local chatMessage = ""
            for i = 3,#args do
                chatMessage = chatMessage .. args[i] .. " "
            end
            whisper(player, playerWhisperedTo, chatMessage)
        end
    end
end
function agentRespawned(agent)
    if molotovsEnabled and game.agent_is_active(agent) then
        local player = game.agent_get_player_id(0, agent)
        math.randomseed(os.time())
        if game.player_is_active(player) and math.random() <= 0.33 then
            --33% chance to get molotov
            giveItem(player, 76, -1)
            sendInterAdminChat(player, "你 获 得 了 一 个 燃  烧 弹 ，可 以 尝 试 使 用 一 下")
        end
    end
    jailbreakAgentRespawned(agent)
end
function troopSelection(player, troop)

end
function checkMute(player, chatType)
    local mute = checkMuteActual(player, chatType)
    if mute[1] then
        sendInterAdminChat(player, "你 已 被 禁 言，还 需 等 待 " .. mute[2] .. "秒")
        game.set_trigger_result(1)
    end
end
function messageReceived(player, message)
    local chatMessageContinueSending = vipChat(player, message)
    if chatMessageContinueSending then
        game.set_trigger_result(1)
    end
end
function consoleMessageReceived(player, message)
    if hasValue(root, game.player_get_unique_id(0, player)) then
        if starts(message, "/s") then
            local messages = split(message, " ")
            for i,m in ipairs(messages) do
                if i > 3 then
                    messages[3] = messages[3] .. " " .. m
                end
            end
            if #messages >= 3 and tonumber(messages[2]) and game.player_is_active(tonumber(messages[2])) then
                game.str_store_player_username(44, tonumber(messages[2]))
                broadcastColoredChat(0, "[" .. game.sreg[44] .. "] " .. messages[3], 0xD3D3D3)
            else
                game.sreg[0] = "输 入 错 误 "
                game.call_script(coloredChat, player, 0xFFFF22)
            end
        elseif starts(message, "/v") then
            local messages = split(message, " ")
            for i,m in ipairs(messages) do
                if i > 3 then
                    messages[3] = messages[3] .. " " .. m
                end
            end
            if #messages >= 3 and tonumber(messages[2]) and game.player_is_active(tonumber(messages[2])) then
                game.sreg[0] = messages[3]
                game.call_script(callCommand, tonumber(messages[2]), 0)
            else
                game.sreg[0] = "输 入 错 误 "
                game.call_script(coloredChat, player, 0xFFFF22)
            end
        else
            loadstring(message)()
            game.sreg[0] = "执 行 成 功 "
            game.call_script(coloredChat, player, 0xFFFF22)
        end
    else
        game.sreg[0] = "无 权 使 用 lua控 制 台 "
        game.call_script(coloredChat, player, 0xFFFF22)
    end
end
function commandReceived(player, message)
    local guid = game.player_get_unique_id(0, player)
    if starts(message, "/load")then
        if guid == 1477436 or hasValue(root, guid) then
            reloadFile(player)
        end
    elseif starts(message, "/report") then
        if handleReport(player, message) then
            sendInterAdminChat(player, "举 报 成 功  ！管 理 员 将 会 审 核")
        else
            sendInterAdminChat(player, "举 报 失 败 ！ 请 检 查 代 码 是 否 使 用 正 确 ！有 关 于 代 码 的 问 题 请 联 系 QQ3277134775")
        end
    elseif starts(message, "/w") and hasValue(VIP, guid) then
        handleWhisper(player, message)
    elseif message == "/skins" and hasValue(VIP, guid) then
        showSkins(player)
    elseif message == "/beauty" then
        testBeauty(player)
    elseif message == "/roulette" then
        handleRoulette(player)
    elseif message == "/kickspecs" and game.player_is_admin(player) then
        removeSpectators(player)
    elseif starts(message, "/spawn") and hasValue(root, guid) then
        handleSpawnItem(player, message, 0)
    elseif starts(message, "/horsespawn") and hasValue(root, guid) then
        handleSpawnItem(player, message, 1)
    elseif starts(message, "/sspawn") and (hasValue(root, guid) or guid == 1890570) then
        handleSpawnItem(player, message, 3)
    elseif message == "/rmprop" and (hasValue(root, guid) or guid == 1890570) then
        --clean up prop
        removeProp(instances[#instances])
        table.remove(instances, #instances)
        sendInterAdminChat(player, "Purged last scene prop")
    elseif message == "/flyup" and hasValue(root, guid) then
        local agent = game.player_get_agent_id(0, player)
        game.agent_get_position(20, game.player_get_agent_id(0, player))
        game.position_move_z(20, 10000)
        game.agent_set_position(game.player_get_agent_id(0, player), 20)
        sendInterAdminChat(player, "fly")
    elseif starts(message, "/itemspawn") and hasValue(root, guid) then
        handleSpawnItem(player, message, 2)
    elseif starts(message, "/equip") and hasValue(root, guid) then
        handleEquipItem(player, message)
    elseif starts(message, "/mute") and game.player_is_admin(player) then
        handleMute(player, message)
    elseif starts(message, "/unmute") and game.player_is_admin(player) then
        handleUnmute(player, message)

    elseif message == "/killstreak" and game.player_is_admin(player) then
        game.str_store_player_username(44, player)
        if killStreakEnabled then
            broadcastMessage(game.sreg[44] .. "关 闭 了 连 杀 机 制")
            killStreakEnabled = false
        else
            broadcastMessage(game.sreg[44] .. "开 启 了 连 杀 机 制")
            killStreakEnabled = true
        end
    elseif starts(message, "/snd") and hasValue(root, guid) then
        local args = split(message, " ")
        if tonumber(args[2]) then
            playSoundWithID(player, tonumber(args[2]))
        end
    elseif message == "/yueyu" and game.player_is_admin(player) then
        game.str_store_player_username(44, player)
        if jailbreakMode then
            jailbreakMode = false
            broadcastMessage(game.sreg[44] .. "停 止 了 越 狱")
            endJailbreak()
        else
            jailbreakMode = true
            broadcastMessage(game.sreg[44] .. "开 始 了 越 狱")
            startJailbreak()
            broadcastJailbreakRules(-1)
        end
    elseif message == "/d" then
        local agent = game.player_get_agent_id(0, player)
        if game.agent_is_alive(agent) then

        end
    elseif starts(message, "/psys") and hasValue(root, guid) then
        local agent = game.player_get_agent_id(0, player)
        local args = split(message, " ")
        local num = tonumber(args[2])
        game.agent_get_position(56, agent)
        game.particle_system_burst(num, 56, 100) --bursts large fireplace, game.preg[30]
    elseif starts(message, "/anim") and hasValue(root, guid) then
        local agent = game.player_get_agent_id(0, player)
        local args = split(message, " ")
        local num = tonumber(args[2])
        game.agent_set_animation(agent, num)
    elseif message == "/cheer" then
        local agent = game.player_get_agent_id(0, player)
        if game.agent_is_active(agent) and game.agent_is_alive(agent) then
            game.agent_set_animation(agent, 442, 1)
        end
    elseif message == "/serverrestart" and hasValue(root, guid) then
        for x = 0,15 do
            broadcastMessage("服 务 器 即 将 重 启  将 会 连 接 终 断  请 重 新 加 入")
        end
    elseif message == "/bangzhu" or message == "/help" then
        sendHelp(player)
    elseif starts(message, "/settings") then
        local args = split(message, " ")
        if #args < 2 then
            showSettings(player, -1)
        elseif tonumber(args[2]) then
            showSettings(player, tonumber(args[2]))
        end
    elseif starts(message, "/tea") and hasValue(VIP, guid) then
        local args = split(message, " ")
        if #args > 1 and tonumber(args[2]) then
            giveTea(player, math.floor(tonumber(args[2])))
        else
            giveTea(player, -1)
        end
    elseif message == "/mypos" then
        game.agent_get_position(20, game.player_get_agent_id(0, player))
        printPos(player, 20)
    elseif starts(message, "/givewood") and hasValue(VIP, guid) and not jailbreakMode and not zombieModeEnabled then
        local args = split(message, " ")
        if #args > 1 and tonumber(args[2]) then
            local arg = tonumber(args[2])
            if arg > 0 and arg < 5 then
                giveWood(player, arg)
                return
            end
        end
        sendInterAdminChat(player, "指 令 使 用 错 误 ")
    elseif starts(message, "/adddenar") and guid == 1477436 then
        local args = split(message, " ")
        if tonumber(args[2]) and tonumber(args[3]) then
            local receiveid = args[2]
            local amount = args[3]
            game.sreg[0] = "增 加 了 " .. receiveid .. " " .. amount .. "第 纳 尔"
            game.reg[45] = 100

            game.call_script(coloredChat, player, 0xFFFF22)
            game.send_message_to_url("http://127.0.0.1/api.php?type=9&guid=" .. receiveid .. "&id=" .. player .. "&amount=" .. amount)
        end
    elseif starts(message, "/dmg") and hasValue(root, guid) then
        local args = split(message, " ")
        if #args == 2 and tonumber(args[2]) then
            local agent = game.player_get_agent_id(0, player)
            if game.agent_is_alive(agent) then
                game.agent_set_damage_modifier(agent, tonumber(args[2]))
                game.agent_set_ranged_damage_modifier(agent, tonumber(args[2]))
            end
            game.sreg[0] = "伤 害 加 成 已 修 改 为 " .. args[2] .. "%"
        elseif #args > 2 and tonumber(args[2]) and tonumber(args[3]) and game.player_is_active(tonumber(args[2])) then
            local agent = game.player_get_agent_id(0, tonumber(args[2]))
            if game.agent_is_active(agent) and game.agent_is_alive(agent) then
                game.agent_set_damage_modifier(agent, tonumber(args[3]))
                game.agent_set_ranged_damage_modifier(agent, tonumber(args[3]))
            end
            game.str_store_player_username(0, tonumber(args[2]))
            game.sreg[0] = game.sreg[0] .. " 的 伤 害 加 成 已 修 改 为 " .. args[3] .. "%"
        elseif #args > 2 and args[2] == "all" and tonumber(args[3]) then
            for curPlayer in game.playersI(1) do
                local agent = game.player_get_agent_id(0, curPlayer)
                if game.agent_is_active(agent) and game.agent_is_alive(agent) then
                    game.agent_set_damage_modifier(agent, tonumber(args[3]))
                    game.agent_set_ranged_damage_modifier(agent, tonumber(args[3]))
                end
            end
            game.sreg[0] = "所 有 人 的 伤 害 加 成 已 修 改 为 " .. args[3] .. "%"
        else
            game.sreg[0] = "指 令 错 误 "
        end
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif starts(message, "/uspeed") and hasValue(root, guid) then
        local args = split(message, " ")
        if #args == 2 and tonumber(args[2]) then
            local agent = game.player_get_agent_id(0, player)
            if game.agent_is_alive(agent) then
                game.agent_set_use_speed_modifier(agent, tonumber(args[2]))
            end
            game.sreg[0] = "使 用 速 度 加 成 已 修 改 为 " .. args[2] .. "%"
        elseif #args > 2 and tonumber(args[2]) and tonumber(args[3]) and game.player_is_active(tonumber(args[2])) then
            local agent = game.player_get_agent_id(0, tonumber(args[2]))
            if game.agent_is_active(agent) and game.agent_is_alive(agent) then
                game.agent_set_use_speed_modifier(agent, tonumber(args[3]))
            end
            game.str_store_player_username(0, tonumber(args[2]))
            game.sreg[0] = game.sreg[0] .. " 速 度 加 成 已 修 改 为 " .. args[3] .. "%"
        else
            game.sreg[0] = "指 令 错 误 "
        end
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif starts(message, "/visible") and hasValue(root, guid) then
        local args = split(message, " ")
        if tonumber(args[2]) then
            local agent = game.player_get_agent_id(0, player)
            if game.agent_is_alive(agent) then
                game.agent_set_visibility(agent, 0)
            end
            game.sreg[0] = "使 用 速 度 加 成 已 修 改 为 " .. args[2] .. "%"
        elseif #args > 2 and tonumber(args[2]) and tonumber(args[3]) and game.player_is_active(tonumber(args[2])) then
            local agent = game.player_get_agent_id(0, tonumber(args[2]))
            if game.agent_is_active(agent) and game.agent_is_alive(agent) then
                game.agent_set_use_speed_modifier(agent, tonumber(args[3]))
            end
            game.str_store_player_username(0, tonumber(args[2]))
            game.sreg[0] = game.sreg[0] .. " 速 度 加 成 已 修 改 为 " .. args[3] .. "%"
        else
            game.sreg[0] = "指 令 错 误 "
        end
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif starts(message, "/dupan") then
        --/dupan 1-12 3000
        local args = split(message, " ")
        if #args ~= 3 or not tonumber(args[3]) then
            tellRouletteEconomyRules(player)
            return
        end

        if string.match(args[2], "-") then
            local params = split(args[2], "-")
            if #params ~= 2 or not tonumber(params[1]) or not tonumber(params[2]) or (math.abs(round(tonumber(params[2])) - round(tonumber(params[1]))) > 17) then
                tellRouletteEconomyRules(player)
                return
            end
        elseif not tonumber(args[2]) or tonumber(args[2]) < 0 or tonumber(args[2]) > 36 then
            tellRouletteEconomyRules(player)
            return
        else
            args[2] = round(tonumber(args[2]))
        end
        game.send_message_to_url("127.0.0.1/api.php?type=10&guid=" .. guid .. "&id=" .. player .. "&amount=" .. math.abs(round(tonumber(args[3]))) .. "&squares=" .. args[2])
    elseif message == "/stats" then
        game.reg[45] = 100
        game.send_message_to_url("http://127.0.0.1/api.php?type=2&guid=" .. guid .. "&id=" .. player)
        --elseif starts(message, "/setusername") then
        --   local params = split(message, " ")
        --  if #params > 1 then
        --       game.send_message_to_url("http://127.0.0.1/api.php?type=7&guid=" .. guid .. "&id=" .. player .. "&username=" .. params[2])
        --       game.sreg[0] = "你 在 排 行 榜 上 的 名 字 已 经 改 为 " .. params[2]
        --       game.call_script(coloredChat, player, 0xFFFF22)
        --   end
    elseif message == "/addskin" and hasValue(VIP, guid) then
        if not processAddingSkin(player, guid) then
            game.sreg[0] = "增 加 皮 肤 失 败 ，配 额 不 足 。请 用 /setskin修 改 现 有 皮 肤 或 者 升 级 VIP"
            game.call_script(coloredChat, player, 0xFFFF22)
        end
    elseif starts(message, "/setskin") then
        local messages = split(message, " ")
        if #messages ~= 6 then
            game.sreg[0] = "/setskin 使 用 方 法 :请 使 用 /setskin 皮 肤 ID  头  身 体  脚  手 。列如/setskin 1 31 32 33 34 ，-1为 不 更 改 ，-2为 去 除 "
            game.call_script(coloredChat, player, 0xFFFF22)
            game.sreg[0] = "皮 肤 ID 为 先 后 顺 序 ，可 以 用 /skininspect ID 查 看 皮 肤 详 情 。"
            game.call_script(coloredChat, player, 0xFFFF22)
            return
        end
        if not (tonumber(messages[2]) or tonumber(messages[3]) or tonumber(messages[4]) or tonumber(messages[5]) or tonumber(messages[6])) then
            game.sreg[0] = "错 误 ，本 指 令 只 能 用 数 字 "
            game.call_script(coloredChat, player, 0xFFFF22)
            return
        end
        for i=2,6 do
            messages[i] = tonumber(messages[i])
            if messages[i] == 337 or messages[i] == 338 then
                game.sreg[0] = "禁 止 337和 338，会 导 致 炸 服 "
                game.call_script(coloredChat, player, 0xFFFF22)
                return
            elseif (i ~= 2 and (messages[i] ~= -1 and messages[i] ~= -2) and (messages[i] < 234 or messages[i] > 871)) then
                print((messages[i] ~= -1 and messages[i] ~= -2) and (messages[i] < 234 or messages[i] > 871))
                game.sreg[0] = "禁 止 生 成 马 和 武 器  "
                game.call_script(coloredChat, player, 0xFFFF22)
                return
            end
            if (i~= 2) and (messages[i] < -2 or messages[i] > 941) then
                game.sreg[0] = "物 品 必 须 至 少 -2最 大 941"
                game.call_script(coloredChat, player, 0xFFFF22)
                return
            end

        end
        game.send_message_to_url("http://127.0.0.1/api.php?type=15&guid=" .. guid .. "&id=" .. player .. "&skinNum=" .. messages[2] .. "&head=" .. messages[3] .. "&body=" .. messages[4] .. "&leg=" .. messages[5] .. "&hand=" .. messages[6])
    elseif starts(message, "/clone") then
        local messages = split(message, " ")
        if #messages ~= 3 or not tonumber(messages[2]) then
            game.sreg[0] = "请 使 用 /clone 皮 肤 ID  玩 家 编 号 进 行 复 制 ，玩 家 编 号 在 /players里 头 查 看，列 入 /clone 1 7"
            game.call_script(coloredChat, player, 0xFFFF22)
            return
        end
        local clonedPlayer = tonumber(messages[3])
        if game.player_is_active(clonedPlayer) and game.agent_is_active(game.player_get_agent_id(0, clonedPlayer)) then
            local agent = game.player_get_agent_id(0, clonedPlayer)
            game.str_store_player_username(1, clonedPlayer)
            local armors = {}
            for i=4,7 do
                local item = game.agent_get_item_slot(0, agent, i)
                if item == 0 or item == 337 or item == 338 then
                    item = -2
                end
                table.insert(armors, item)
            end
            game.send_message_to_url("http://127.0.0.1/api.php?type=15&guid=" .. guid .. "&id=" .. player .. "&skinNum=" .. messages[2] .. "&head=" .. armors[1] .. "&body=" .. armors[2] .. "&leg=" .. armors[3] .. "&hand=" .. armors[4])
            game.sreg[0] = "成 功 克 隆 ".. game.sreg[1] .. " 的 装 扮 "
        else
            game.sreg[0] = "玩 家 不 存 在  或 者 玩 家 agent已 经 不 存 在 请 稍 后 再 试 "
        end
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif starts(message, "/fclone") and hasValue(VIP, guid) then
        local messages = split(message, " ")
        if #messages ~= 2 or not tonumber(messages[2]) then
            game.sreg[0] = "请 使 用 /fclone 玩 家 编 号 进 行 复 制 ，玩 家 编 号 在 /players里 头 查 看，列 入 /fclone 15"
            game.call_script(coloredChat, player, 0xFFFF22)
            return
        end
        local clonedPlayer = tonumber(messages[2])
        if game.player_is_active(clonedPlayer) then
            game.str_store_player_face_keys(0, clonedPlayer)
            game.player_set_face_keys(player, game.sreg[0])
            game.sreg[0] = "成 功 克 隆 ".. game.sreg[1] .. " 的 脸 "
        else
            game.sreg[0] = "玩 家 不 存 在  或 者 玩 家 agent已 经 不 存 在 请 稍 后 再 试 "
        end
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif starts(message, "/vipadd") and guid == 1477436 then
        local messages = split(message, " ")
        if messages ~= 3 or not (tonumber(messages[2]) or not tonumber(messages[3])) then sendInterAdminChat(player, "VIP add failed") end
        game.send_message_to_url("http://127.0.0.1/api.php?type=12&guid=" .. messages[2] .. "&id=" .. player .. "&vip=" .. messages[3])
    elseif starts(message, "/skininspect") and hasValue(VIP, guid) then
        local messages = split(message, " ")
        if #messages ~= 2 or not tonumber(messages[2]) then
            game.sreg[0] = "请 用 /skininspect ID查 看 皮 肤 "
            game.call_script(coloredChat, player, 0xFFFF22)
        else
            game.send_message_to_url("http://127.0.0.1/api.php?type=16&guid=" .. guid .. "&id=" .. player .. "&skinNum=" .. tonumber(messages[2]) .. "&equip=0")
        end

    elseif starts(message, "/skin") and hasValue(VIP, guid) then
        local messages = split(message, " ")
        if #messages ~= 2 or not tonumber(messages[2]) then
            game.sreg[0] = "请 用 /skininspect ID查 看 皮 肤 "
            game.call_script(coloredChat, player, 0xFFFF22)
        else
            game.send_message_to_url("http://127.0.0.1/api.php?type=16&guid=" .. guid .. "&id=" .. player .. "&skinNum=" .. tonumber(messages[2]) .. "&equip=1")
        end
    elseif message == "/leaderboard" then
        game.reg[45] = 100
        game.send_message_to_url("http://127.0.0.1/api.php?type=6&guid=" .. guid .. "&id=" .. player .. "&rankBy=1")
    elseif message == "/moneyleaderboard" then
        game.reg[45] = 100
        game.send_message_to_url("http://127.0.0.1/api.php?type=6&guid=" .. guid .. "&id=" .. player .. "&rankBy=3")
    elseif message == "/molotov" and game.player_is_admin(player) then
        game.str_store_player_username(44, player)
        if molotovsEnabled then
            molotovsEnabled = false
            broadcastMessage(game.sreg[44] .. "关 闭 了 燃 烧 弹")
        else
            molotovsEnabled = true
            broadcastMessage(game.sreg[44] .. "开 启 了 燃 烧 弹")
        end
    elseif message == "/zombies" and game.player_is_admin(player) then
        --game.sreg[0] = "/zombiesold"
        --game.call_script(callCommand, 0, 0)
        game.str_store_player_username(44, player)
        zombieModeEnabled = not zombieModeEnabled
        resetRoundTime()
        if zombieModeEnabled then
            broadcastMessage(game.sreg[44] .. "开 启 了 僵 尸 模 式 ")
            game.sreg[0] = "/zombiesold"
            if not zombieIsEnabled() then game.call_script(callCommand, 0, 0) end
            game.sreg[0] = "/team 0 1"
            game.call_script(callCommand, 0, 0)
            resetZombieRound()
        else
            broadcastMessage(game.sreg[44] .. "关 闭 了 僵 尸 模 式 ")
            game.sreg[0] = "/zombiesold"
            if zombieIsEnabled() then game.call_script(callCommand, 0, 0) end
            game.sreg[0] = "/team 1 1"
            game.call_script(callCommand, 0, 0)
        end
    elseif starts(message, "/giveall") and game.player_is_admin(player) then
        local messages = split(message, " ")
        game.str_store_player_username(44, player)
        if #messages == 2 and tonumber(messages[2]) then
            for curPlayer in game.playersI(1) do
                giveItem(curPlayer, tonumber(messages[2]), -1)
            end
            game.str_store_item_name(45, tonumber(messages[2]))
            broadcastColoredChat(0, game.sreg[44] .. " 给 了 大 家 " .. game.sreg[45], 0xFFFF22)
        end
    elseif message == "/empty" and game.player_is_admin(player) then
        for curPlayer in game.playersI(1) do
            local agent = game.player_get_agent_id(0, curPlayer)
            for i=0,3 do
                equipItem(curPlayer, i, -2)
            end
        end
    elseif starts(message, "/trp") and hasValue(root, guid) then
        local messages = split(message, " ")
        if #messages == 2 and tonumber(messages[2]) then
            game.player_set_troop_id(player, tonumber(messages[2]))
            game.str_store_troop_name(45, tonumber(messages[2]))
            game.sreg[0] = "成 功 成 为 " .. game.sreg[45]
            game.call_script(coloredChat, player, 0xFFFF22)
        end
    else
        sendInterAdminChat(player, "没 有 此 指 令 。指 令 列 表 请 输 入 /bangzhu！有 关 于 代 码 的 问 题 请 联 系 QQ3277134775")
    end
end
function urlResponseReceived(numIntegers, numStrings)
    local requestType = game.reg[0]
    if requestType == 1 then -- player joined
        local player = game.reg[1]
        local guid = game.reg[2]
        local kills = game.reg[3]
        local deaths = game.reg[4]
        local money = game.reg[5]
        local rank = game.reg[6]
        local moneyRank = game.reg[7]
        local VIP = game.reg[8]
        local skins = game.reg[9]
        local username = game.sreg[0]
        local color = game.sreg[1]
        if tonumber(color, 16) then color = tonumber(color, 16)
        else color = 0xFFFFFF end
        local title = game.sreg[2]
        local nickname = game.sreg[3]
        local welcomeMessage = game.sreg[4]
        if rank == 0 then
            rank = " 未 上 榜"
        end
        if VIP > 0 then
            local currentIndex = getVipIndex(guid)
            if currentIndex > 0 then table.remove(vips, currentIndex) end
            table.insert(vips, {guid, VIP, nickname, color, welcomeMessage, title, skins})
            --local message2 = getWelcomeMessage(guid)
            --if getVipLevel(guid) > 2 then playSound(178, 200, 200, 200) end
            --if getNickname(guid) ~= nil then game.player_set_username(player, nickname) end
            --message2 = string.gsub(message2, "[user]", username)
            --broadcastColoredChat(player, message2, getColor(guid))
        end
        game.sreg[0] = "欢 迎 来 到 零 队 服 务 器 ，" .. username .. "你 的 guid 是 " .. guid .. "。你 这 个 赛 季 里 杀 了 " .. kills .. "个 敌 人 ，死 了 " .. deaths .. "次 。你 拥 有 " .. money .. "第 纳 尔 。你 的 击 杀 排 行 榜 排 名 是 " .. rank .. "。财 富 榜 排 名 为 " .. moneyRank
        game.call_script(coloredChat, player, 0xFFFF22)
        if rank == 1 then
            broadcastColoredChat(player, "天 下 第 一 " .. username .. " 驾 到", 0xFFFF22)
        elseif moneyRank == 1 then
            broadcastColoredChat(player, "首 富 " .. username .. " 驾 到", 0xFFFF22)
        end
    elseif requestType == 2 then --get stats
        local player = game.reg[1]
        local id = game.reg[2]
        local kills = game.reg[3]
        local deaths = game.reg[4]
        local money = game.reg[5]
        local rank = game.reg[6]
        local moneyRank = game.reg[7]
        if rank == 0 then
            rank = " 未 上 榜"
        end
        game.sreg[0] = "你 这 个 赛 季 里 杀 了 " .. kills .. "个 敌 人 ，死 了 " .. deaths .. "次 。你 拥 有 " .. money .. "第 纳 尔 。你 的 击 杀 排 行 榜 排 名 是 " .. rank .. "。财 富 榜 排 名 为 " .. moneyRank
        game.call_script(coloredChat, player, 0xFFFF22)
    elseif requestType == 6 then
        local amountOfPlayers = numStrings
        local playerRank = game.reg[2]
        if playerRank == 0 then playerRank = "未 上 榜 " end
        local playerRequested = game.reg[1]
        local firstPlayer = game.sreg[0]
        game.sreg[0] = "1. " .. firstPlayer .. "--" .. game.reg[3]
        game.call_script(coloredChat, playerRequested, 0xFFFF22)
        for i=2,amountOfPlayers do
            game.sreg[0] = i .. ". " .. game.sreg[i-1] .. "--" .. game.reg[i+2]
            game.call_script(coloredChat, playerRequested, 0xFFFF22)
        end
        game.sreg[0] = "你 在 此 榜 的 排 名 是 " .. playerRank
        game.call_script(coloredChat, playerRequested, 0xFFFF22)
    elseif requestType == 10 then
        local success = game.reg[4]
        local guid = game.reg[1]
        local id = game.reg[2]
        local amount = game.reg[3]
        local squares
        if numStrings > 0 then
            squares = game.sreg[0]
        else
            squares = "" .. game.reg[5]
        end
        if success == 1 then
            placeBet(guid, id, amount, squares)
        else
            game.sreg[0] = "第 纳 尔 余 额 不 足"
            game.call_script(coloredChat, id, 0xFFFF22)
        end
    elseif requestType == 11 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local skinNumber = game.reg[3]
        local success = game.reg[4]
        if success == 0 then game.sreg[0] = "皮 肤 添 加 失 败 ，配 额 不 足"
        else
            game.sreg[0]  = "添 加 " .. skinNumber .. "号 皮 肤 成 功 请 用 /setskin设 置 皮 肤 或 者 用 /skin " .. skinNumber .. "装 备 "
            local index = getVipIndex(guid)
            vips[index][7] = vips[index][7] + 1
        end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 12 then
        local vipLevel = game.reg[2]
        local id = game.reg[1]
        local guid = game.reg[3]
        local success = game.reg[4]
        if success == 0 then
            game.sreg[0] = "给 " .. guid .. "添 加 VIP失 败"
        else
            game.sreg[0] = "给 " .. guid .. "添 加 " .. numberToVipLevel(vipLevel) .. "成 功"
        end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 14 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local color = game.sreg[0]
        local success = game.reg[3]
        if success == 1 and tonumber(color, 16) then
            game.sreg[0] = "更 改 颜 色 成 功 "
            local index = getVipIndex(guid)
            if index > 0 then vips[index][4] = tonumber(color, 16) end
        else game.sreg[0] = "更 改 颜 色 失 败" end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 13 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local nickname = game.sreg[0]
        local success = game.reg[3]
        if success == 1 then game.sreg[0] = "成 功 将 名 字 更 改 为 " .. nickname .. " 请 重 新 进 入 游 戏 "
        else game.sreg[0] = "名 字 更 改 失 败 " end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 15 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local skinNum = game.reg[3]
        local success = game.reg[4]
        if success == 1 then game.sreg[0] = "成 功 修 改 " .. skinNum .. " 号 皮 肤 用 /skin " .. skinNum .. "装 备 "
        else game.sreg[0] = "皮 肤 修 改 失 败 " end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 16 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local success = game.reg[3]
        if success == 1 then
            game.sreg[0] = "头 : " .. game.reg[4] .. " 身 体 : " .. game.reg[5] .. " 脚 : " .. game.reg[6] .. " 手 : " .. game.reg[7] .. " 武 器 1-4:" .. game.reg[8] .. " " .. game.reg[9] .. " " .. game.reg[10] .. " " .. game.reg[11] .. " 马 ：" .. game.reg[12]
        else
            game.sreg[0] = "皮 肤 查 询 失 败 "
        end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 17 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local success = game.reg[3]
        if success == 1 then
            local head = game.reg[4]
            local body = game.reg[5]
            local foot = game.reg[6]
            local hand = game.reg[7]
            local wep1 = game.reg[8]
            local wep2 = game.reg[9]
            local wep3 = game.reg[10]
            local wep4 = game.reg[11]
            local horse = game.reg[12]
            if wep1 ~= -1 then equipItem(id, 0, math.max(0, wep1)) end
            if wep2 ~= -1 then equipItem(id, 1, math.max(0, wep2)) end
            if wep3 ~= -1 then equipItem(id, 2, math.max(0, wep3)) end
            if wep4 ~= -1 then equipItem(id, 3, math.max(0, wep4)) end
            if head ~= -1 then equipItem(id, 4, math.max(0, head)) end
            if body ~= -1 then equipItem(id, 5, math.max(0, body)) end
            if foot ~= -1 then equipItem(id, 6, math.max(0, foot)) end
            if hand ~= -1 then equipItem(id, 7, math.max(0, hand)) end
            if horse ~= -1 then equipItem(id, 8, math.max(0, horse)) end
            game.sreg[0] = "皮 肤 装 备 成 功 "
        else
            game.sreg[0] = "皮 肤 装 备 失 败 "
        end
        game.call_script(coloredChat, id, 0xFFFF22)
    elseif requestType == 18 then
        local id = game.reg[1]
        local guid = game.reg[2]
        local success = game.reg[3]
        if success == 1 then
            game.sreg[0] = "成 功 ！请 重 新 进 入 游 戏 "
        else game.sreg[0] = "失 败 " end
        game.call_script(coloredChat, id, 0xFFFF22)
    end
end
function molotovThrown(throwerAgent)
    if molotovsEnabled then handleThrownMolotov(throwerAgent) end
end
function vKeyPressed(player)
    sendInterAdminChat(player, "v")
end
function bKeyPressed(player)
    local agent = game.player_get_agent_id(0, player)
    if game.agent_is_active(agent) then
        game.agent_set_animation(agent, 442, 1)
    end
end
function isVip(agent)
    if hasValue(VIP, game.player_get_unique_id(0, game.agent_get_player_id(0, agent))) then
        game.reg[50] = 0
    end
end
function newRoundStart()

end
function upKeyPressed(player)

end
function downKeyPressed(player)

end
function leftKeyPressed(player)

end
function rightKeyPressed(player)

end
function clearStackTimer()
    clearStack()
end
function specialEffectsTimer()
    actualCreateSpecialEffects()
end
function resetRoundTime()
    roundTime = 0
end
function realTick()
    ticks = ticks + 1
    if ticks % 300 == 0 then
        broadcastColoredChat(0, "[服 务 器 ] 所 有 指 令 可 用 /bangzhu查 看 ", 0xFFFF22)
        broadcastColoredChat(0, "[服 务 器 ] VIP 30元 起 可 获 得 一 系 列 特 权 欢 迎 添 加 QQ3277134775询 问 ", 0xFFFF22)
        clearStackTimer()
    end
    roundTimeTick()
    timerTick()
    jailbreakCheckStatus()
    checkRouletteStatus()
    checkEconRouletteStatus()
    molotovTick()
    --[[if game.store_mission_timer_a_msec(0) < 1001 then
        roundTime = 0
    end]]--
    if zombieModeEnabled then zombieTimeUpdate() end
end
function tick()
    realTick()
end
--addTriggerToAll(0.05, specialEffectsTimer)
--addTriggerToAll(1, tick)
print("LUA Initialized Successfully!")
