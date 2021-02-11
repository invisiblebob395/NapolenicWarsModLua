
require "methods"
require "VIP"
function requestReceived(numIntegers, numStrings)
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
            reminderNotifications(player, guid)
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
            game.sreg[0] = "头 : " .. game.reg[4] .. " 身体 : " .. game.reg[5] .. " 脚 : " .. game.reg[6] .. " 手 : " .. game.reg[7] .. " 武 器 1-4:" .. game.reg[8] .. " " .. game.reg[9] .. " " .. game.reg[10] .. " " .. game.reg[11]
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
            if wep1 ~= -1 then equipItem(id, 0, math.max(0, wep1)) end
            if wep2 ~= -1 then equipItem(id, 1, math.max(0, wep2)) end
            if wep3 ~= -1 then equipItem(id, 2, math.max(0, wep3)) end
            if wep4 ~= -1 then equipItem(id, 3, math.max(0, wep4)) end
            if head ~= -1 then equipItem(id, 4, math.max(0, head)) end
            if body ~= -1 then equipItem(id, 5, math.max(0, body)) end
            if foot ~= -1 then equipItem(id, 6, math.max(0, foot)) end
            if hand ~= -1 then equipItem(id, 7, math.max(0, hand)) end
            game.sreg[0] = "皮 肤 装 备 成 功 "
        else
            game.sreg[0] = "皮 肤 装 备 失 败 "
        end
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

