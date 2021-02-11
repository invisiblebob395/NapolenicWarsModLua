
require "methods"
require "mute"
sibrand = 0
snow = 0
lucy = 0
cccp = 0
ccll = 0
wanzi = 0
ivanka = 0
nervousMan = 0
sam = 0
mingyao = 0
yanyu = 0
erichvon = 0
hiv_SJ = 0
maozi_guizu = 0
lingxiao = 0
blue = 0
jiugui = 0
moyu = 0
purplephoenix = 0
rhodock = 0
wuya = 0
kongyiji = 0
shusheng = 0
bojue = 0
xila = 0
carrot = 0
fish = 0
eric = 0
xuyimiao = 0
pengqididi = 0
liudang = 0
xiaolun = 0
hre = 0
loras = 0
napoleon = 0
soviet_newb = 0
poet = 0
VIP = {
    0--WHISPER
    sibrand,
    lucy,
    cccp,
    ccll,
    wanzi,
    nervousMan,
    sam,
    mingyao,
    erichvon,
    yanyu,
    hiv_SJ,
    maozi_guizu,
    lingxiao,
    blue,
    jiugui,
    moyu,
    purplephoenix,
    rhodock,
    wuya,
    kongyiji,
    0,
    shusheng,
    bojue,
    xila,
    carrot,
    fish,
    0,
    eric,
    0,
    xuyimiao,
    pengqididi,
    0,
    liudang,
    xiaolun,
    hre,
    loras,
    napoleon,
    soviet_newb,
    poet,
}
skins = {}
function readSkins()
    local skinFile = io.open("skins.txt", "rb")
    local content = skinFile:read "*a"
    local allSkins = split(content, "\n") --splits content using line breaks
    skinFile:close()
    for i,skinLine in ipairs(allSkins) do --loop through every skin
        table.insert(skins, {})
        local lineArgs = split(skinLine, "-")
        table.insert(skins[i], lineArgs[1])
        local guids = split(lineArgs[2], ",")
        table.insert(skins[i], {})
        for x, guid in ipairs(guids) do
            table.insert(skins[i][2], tonumber(guid)) --puts everything in
        end
        local skinArgs = split(lineArgs[3], ",")
        for x, itemID in ipairs(skinArgs) do
            table.insert(skins[i], tonumber(itemID)) --puts items in to 3-10
        end
    end
end
function giveSkin(skin, player)

end
function giveTea(player, teaID)
    if teaID == -1 then
        giveItem(player, 218 + math.random(4), -1)
    elseif teaID <= 4 and teaID >= 1 then
        giveItem(player, 218 + teaID, -1)
    else
        sendInterAdminChat("我 没 这 么 傻 别 想 着 生 成 武 器 -.-")
        return
    end
    sendInterAdminChat(player, "您 的 茶 叶")
end
function giveWood(player, id)
    if id > 0 and id < 4 then
        giveItem(player, 98 + id, -1)
    elseif id == 4 then
        giveItem(player, 163, -1)
    end
end
function actualCreateSpecialEffects()
    for curPlayer in game.playersI(1) do
        local guid = game.player_get_unique_id(0, curPlayer)
        --local isCrouching = game.agent_get_crouch_mode(0, agent)
        if guid == 1477436 and 1 == 2 then
            local agent = getAgentID(curPlayer)
            if game.agent_is_active(agent) and game.agent_is_alive(agent) then
                local horse = game.agent_get_horse(0, agent)
                game.agent_get_position(56, agent)
                --game.agent_get_position(55, agent)
                game.agent_get_speed(57, agent)
                game.position_move_x(56, round(game.position_get_x(0, 57) * 0.2))
                game.position_move_y(56, round(game.position_get_y(0, 57) * 0.2))
                if horse <= 0 then
                    --game.position_move_z(55, 140)
                    game.position_move_z(56, 170)
                --elseif isCrouching == 1 then
                  --  game.position_move_z(56, 280)
                else
                    --game.position_move_z(55, 220)
                    game.position_move_z(56, 250)
                end
                for i=1,3 do
                    --game.particle_system_burst(49, 55, 1)
                    game.particle_system_burst(49, 56, 1) --bursts large fireplace, game.preg[30]
                    --game.particle_system_burst(51, 55, 1)
                end
            end
        end
    end
end
function vipChat(player, message)
    local guid = game.player_get_unique_id(0, player)
    game.str_store_player_username(44, player)
    local mute = checkMuteActual(player, 1)
    if mute[1] then
        return
    end
    --game.server_add_message_to_log("[" .. game.sreg[44] .. "] " .. message)
    if guid == 1477436 then
        broadcastColoredChat(player, "[亚 瑟 ] [" .. game.sreg[44] .. "] " .. message, 0xFFFF22)
        return true
    elseif hasValue(VIP, guid) then
        broadcastColoredChat(player, "[VIP] [" .. game.sreg[44] .. "] " ..message, 0xFFFFFF)
        return true
    end
    return false
end
function vipKillEffect(agent, killerAgent, killerPlayer, killedPlayer)
    local killedGuid = game.player_get_unique_id(0, killedPlayer)
    if game.player_is_active(killerPlayer) then
        local guid = game.player_get_unique_id(0, killerPlayer)
        if (not hasValue(doNotDisturb, killedGuid)) and (guid == 0) then
            game.agent_get_position(56, agent)
            game.particle_system_burst(51, 56, 100) --bursts large fireplace, game.preg[30]
            game.particle_system_burst(52, 56, 100) --bursts large fireplace, game.preg[30]
            game.call_script(playSoundAtPos, 182)
        end
    end
end
function vipJoinNotification(player)
    local guid = game.player_get_unique_id(0, player)
    --vip logic
    if guid == 1890570 then
        game.player_set_username(player, "俄 罗 斯 游 击 队 队 员 ")
    elseif guid == 1963797 then
        game.player_set_username(player, "大 唐 皇 帝 李 萝 卜 ")
    elseif guid == ivanka then game.player_set_username(player, "菜 鸡 ")
    elseif guid == 1625715 then game.player_set_username(player, "猫 头 鹰 ")
    elseif guid == 683546 then game.player_set_username(player, "艾 癸 斯 ")
    elseif guid == 1888568 then game.player_set_username(player, "政 委 ")
    elseif guid == 1934868 then game.player_set_username(player, "扎 波 罗 热 哥 萨 克 ")
    elseif guid == sibrand then game.player_set_username(player, "希 伯 兰 德 ")
    elseif guid == wanzi then game.player_set_username(player, "丸 子 ")
    elseif guid == ccll then game.player_set_username(player, "执 政 官 CCLL")
    elseif guid == nervousMan then game.player_set_username(player, "紧 张 不 安 的 人 ")
    elseif guid == sam then game.player_set_username(player, "山 姆 最 强 大 ")
    elseif guid == mingyao then game.player_set_username(player, "明 辉 ")
    elseif guid == hiv_SJ then game.player_set_username(player, "人 体 免 疫 缺 陷 病 毒 ")
    elseif guid == lingxiao then game.player_set_username(player, "可 爱 的 女 装 拿 破 仑 ")
    elseif guid == yanyu then game.player_set_username(player, "烟 雨 平 生 ")
    elseif guid == jiugui then game.player_set_username(player, "闹 事 的 酒 鬼 ")
    elseif guid == purplephoenix then game.player_set_username(player, "博 斯 普 鲁 士 的 紫 凤 凰 ")
    elseif guid == rhodock then game.player_set_username(player, "酒 馆 老 板 ")
    elseif guid == wuya then game.player_set_username(player, "乌 鸦 ")
    elseif guid == bojue then game.player_set_username(player, "格 拉 摩 根 伯 爵 ")
    elseif guid == moyu then game.player_set_username(player, "鱼 子 酱 ")
    elseif guid == xila then game.player_set_username(player, "威 灵 顿 公 爵 ")
    elseif guid == 1942923 then game.player_set_username(player, "最 高 苏 维 埃 ")
    elseif guid == eric then game.player_set_username(player, "被 绑 架 的 女 孩 ")
    elseif guid == xuyimiao then game.player_set_username(player, "我 为 长 者 续 一 秒 ")
    elseif guid == pengqididi then game.player_set_username(player, "国 服 第 一 白 给 将 军 ")
    elseif guid == liudang then game.player_set_useranme(player, "流 殇 ")
    elseif guid == xiaolun then game.player_set_username(player, "罗 德 骑 士 团 第 一 收 刀 之 王 小 伦 ")
    end
    if guid == 1477436 then
        game.player_set_username(player, "亚 瑟 ")
        game.str_store_player_username(44, player)
        broadcastColoredChat(player, game.sreg[44] .. "加 入 了 游 戏 。", 0xFFFF22)
        playSound(178, 200, 200, 200)
    elseif hasValue(VIP, guid) and guid ~= 1695786 and guid ~= 1792902 and guid ~= lucy and guid ~= 1302553 then
        game.str_store_player_username(44, player)
        broadcastColoredChat(player, "尊 贵 的 VIP " .. game.sreg[44] .. "加 入 了 战 斗", 0x90EE90)
    end
end
function createSpecialEffects()
    actualCreateSpecialEffects()
end
vips = {}
vipInitInfo = {
    "/addskin: 增 加 一 个 新 的 皮 肤（会 使 用 一 个 皮 肤 配 额 )",
    "/setskin: 设 置 皮 肤",
    "/setnick STRING: 设 置 名 字（可 以 中 文 ) 列 如 /setskin 亚 瑟 ",
    "/settitle STRING: 设置说话前缀 (可 以 中 文 ) 列 如 /settitle 亚 瑟 ",
    "/setcolor HEX: 设 置 说 话 颜 色 ，请 百 度 Hex，列 如 /setcolor FFFFFF 为 白 色 ",
    "/setwelcome STRING: 设 置 进 场 通 知 [user] 为 用 户 名 列 如 /setwelcome [user] 加 入 了 游 戏 ",
    "/skins: 列 出 你 皮 肤  总 数 "
}
function getVip(guid)
    for i,array in ipairs(vips) do
        if array[1] == guid then
            return array
        end
    end
    return nil
end
function getVipIndex(guid)
    for i,m in ipairs(vips) do
        if m[1] == guid then return i end
    end
    return -1
end
function processAddingSkin(id, guid)
    local array = getVip(guid)
    if array == nil then return false end
    if (array[2] >= 3) or (array[2] > 0 and array[7] < 1) or (array[2] == 2 and array[7] < 5) then
        game.send_message_to_url("http://127.0.0.1/api.php?type=11&id=" .. id .. "&guid=" .. guid)
        return true
    end
    return false
end
function getVipLevel(guid)
    local vip = getVip(guid)
    if vip == nil then return 0
    else return vip[2] end
end
function getNickname(guid)
    local vipInfo = getVip(guid)
    if vipInfo ~= nil then return nil end
    if vipInfo[5] ~= "null" then return (getVip(guid))[3] end
    return nil
end
function getColor(guid)
    local vipInfo = getVip(guid)
    if vipInfo == nil then return nil end
    if vipInfo[4] ~= "null" and tonumber(vipInfo[4], 16) then
        return tonumber(vipInfo[4], 16)
    end
    return 0xFFFFFF
end
function getWelcomeMessage(guid)
    local vipInfo = getVip(guid)
    if vipInfo == nil then return nil end
    if vipInfo[5] ~= nil and vipInfo[5] ~= "null" then return vipInfo[5] end
    return "尊 贵 的 VIP [user] 加 入 了 游 戏 "
end
function getTitle(guid)
    local vipInfo = getVip(guid)
    if vipInfo ~= nil or vipInfo[6] ~= "null" then return vipInfo[6] end
    return "VIP"
end
function reminderNotifications(player, guid)
    local vipInfo = getVip(guid)
    game.sreg[0] = "请 用 /vipinit查 看 并 且 修 改 VIP设 置"
    game.call_script(coloredChat, player, 0xFFFF22)
    if vipInfo[7] == 0 then
        game.sreg[0] = "系 统 检 测 到 你 还 未 创 建 皮 肤 ，用 /addskin创 建 一 个 新 皮 肤 哦 "
        game.call_script(coloredChat, player, 0xFFFF22)
    end
end
--[[function vipKillEffect(agent, killerAgent, killerPlayer, killedPlayer)
    local killedGuid = game.player_get_unique_id(0, killedPlayer)
    if game.player_is_active(killerPlayer) then
        local guid = game.player_get_unique_id(0, killerPlayer)
        local vip = getVip(guid)
        if (not hasValue(doNotDisturb, guid)) and vip ~= nil and vip[2] > 2 then
            game.agent_get_position(56, agent)
            game.particle_system_burst(51, 56, 100) --bursts large fireplace, game.preg[30]
            game.particle_system_burst(52, 56, 100) --bursts large fireplace, game.preg[30]
            game.call_script(playSoundAtPos, 182)
        end
    end
end]]--
function numberToVipLevel(vipLevel)
    if vipLevel == 1 then return "VIP" end
    if vipLevel == 2 then return "铂 金 VIP" end
    if vipLevel >= 3 then return "钻 石 VIP" end
    return nil
end
