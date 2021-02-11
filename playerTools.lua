
require "methods"
beautySlot = 40
news = {
    "鉴 于 之 前 VIP数 据 丢 失 ，请 各 位 VIP用 /addskin 增 加 自 己 的 皮 肤 ",
    "长 期 战 绩 存 储 已 经 修 复 ，用 /stats 查 看 可 以 用 /bangzhu查 看 更 多",
    "新 增 加 诸 多 指 令 ，可 以 用 /bangzhu 查 看",
    "可 以 用 /cheer欢 呼"
}
commands = {
    "有 关 于 代 买 的 问 题 以 及 建 议 请 联 系 QQ3277134775",
    "/stats -- 显 示 你 的 本 月 的 击 杀 和 死 亡 以 及 第 纳 尔 数 量",
    "/dupan -- 小 游 戏 可 以  获 得 第 纳 尔",
    "/leaderboard -- 展 示 击 杀 排 行 榜 的 前 10 名 (需 要 击 杀 至 少 30 个 敌 人)",
    "/moneyleaderboard -- 展 示 第 纳 尔 最 多 的 前 10 名 玩 家",
    "/players -- 展 示 所 有 的 玩 家 暂 时 ID 以 及 名 字",
    "/report ID 原 因 -- 请 用 /players 查 找 暂 时 ID，将 会 举 报 玩 家 会 人 工 审 核 列 入 /report 20 滥 用 职 权",
    "/beauty -- 检 测 一 下 你 有 多 美 丽",
    "/roulette -- 开 始 / 加 入 俄 罗 斯 赌 盘 游 戏 ",
    "/cheer -- 欢 呼"
}
vipCommands = {
    "/tea - 随 机 给 你 生 成 一 个 茶 杯 或 者 瓶 子",
    "/tea 1-4 - 生 成 指 定 的 茶 杯 或 者 瓶 子",
    "/addskin - 增 加 皮 肤 ",
    "/setskin - 设 置 皮 肤 ",
    "/skininspect ID - 查 看 皮 肤 ，ID为 皮 肤 ID (第 一 个 皮 肤 就 是 1 以 此 类 推 )",
    "/givewood 1-4 - 生 成 木 头 武 器 1是 军 官 剑 2是 重 剑 3是 轻 骑 兵 剑 4是 木 头 火 枪 ",
    "/clone 皮 肤 ID  玩 家 编 号 - 克 隆 那 个 人 的 皮 肤 玩 家 编 号 请 在 /players里 查 找 列 入 /clone 1 22"
}
admincommands = {
    "/admins -- 显 示 所 有 在 线 管 理 员",
    "/team int1 int2 -- 自 动 平 衡 必 须 为 无 限 制，将 一 队 ：二 队 的 比 例 设 置 为 int1:int2",
    "/nodmgteam 0 1 2 3 -- 0：伤 害 开 启 1：一 队 伤 害 关 闭 2：二 队 伤 害 关 闭 3：所 有 伤 害 关 闭",
    "/partizan -- 开 启 / 关 闭 二 队 俄 罗 斯 强 制 农 名",
    "/tnt 0 1 2 3 -- 0 -- 炸 药 开 启，1 -- 一 队 可 以 使 用 ，2 -- 二  队 可 以 使 用 ，3 -- 都 不 可 以 使 用",
    "/bring 1 2 -- 召 唤 整 个 1/2 队",
    "/yueyu -- 开 启 越 狱 ，将 自 动 报 出 越 狱 规 则 ，以 及 开 启 强 制 农 名 和 1:3 的 比 例",
    "/zombies -- 开 启 / 关 闭 僵 尸 模 式",
    "/troop 0 1 2 3 -- 0: 自 动 1: 只 能 步 兵 2: 只 能 骑 兵 3: 都 可 以",
    "/killstreak -- 开 启 或 关 闭 连 杀 机 制",
    "/kickspecs -- 踢 出 所 有 旁 观 者（当 人 数 达 到 上 线 时 使 用）",
    "/mute ID time -- 禁 言 暂 时 ID (1-3 位 数 ) time 秒 列 如 /mute 20 200",
    "/unmute GUID -- 解 除 禁 言 GUID (6-7 位 数) 列 如 /unmute 123456",
    "/molotov -- 开 启 /关 闭 燃 烧 弹",
}
rootcommands = {
    "/load -- 重 新 加 载 main.lua（慎 用 ）",
    "/spawn ID -- 生 成 一 个 武 器 并 且 装 备",
    "/equip slot ID -- 装 备 ID 到 slot",
    "/horsespawn ID -- 生 成 马 匹",
    "/snd ID -- 在 你 的 位 置 播 放 ID 的 声 音",
    "/bp -- 开 启 /关 闭 管 理 员 无 限 建 造 点",
    "/serverrestart -- 发 布 重 启 服 务 器 警 告"
}
settings = {
    "/settings 1 -- 关 于 连 杀 机 制 的 设 置",
    "/settings 2 -- 关 于 僵 尸 模 式 的 设 置",
    "/settings 3 -- 关 于 VIP 机 制 的 设 置"
}
function handleReport(player, message)
    local messages = split(message, " ")
    local playerReported
    if not tonumber(messages[2]) then
        return false
    else
        playerReported = math.floor(tonumber(messages[2]))
        if not game.player_is_active(playerReported) then
            return false
        end
        local reportMessage = ""
        for x = 3, #messages, 1 do
            reportMessage = reportMessage .. " " .. messages[x]
        end
        local reportedPlayerName = game.str_store_player_username(44, playerReported)
        game.str_store_player_username(45, player)
        game.str_store_player_ip(46, player)
        local playerGUID = game.player_get_unique_id(0, player)
        local reportedPlayerGUID = game.player_get_unique_id(0, playerReported)
        local reportInfo = game.sreg[45] .. " with ID: " .. playerGUID .. " and IP " .. game.sreg[46] .. " reports " .. game.sreg[44] .. " with ID: " .. reportedPlayerGUID
        log("report.txt", reportInfo)
        log("report.txt", os.date("%Y.%m.%d, %X") .. "Reason: " .. reportMessage)
        broadcastMessage(game.sreg[45] .. " 举 报 了 玩 家 " .. game.sreg[44] ..". 原 因 是 :" .. reportMessage .. "。 如 发 现 相 应 情 况 请 使 用 /report 举 报 。举 报 会 记 录 IP ，滥 用 举 报 的 将 会 被 封 禁")
        return true
    end
end
function testBeauty(player)
    game.str_store_player_username(44, player)
    local guid = game.player_get_unique_id(0, player)
    local beautyIndicator = math.random(100)
    local currentBeauty = game.player_get_slot(0, player, beautySlot)
    if currentBeauty <= 0 then
        if beautyIndicator <= 20 then
            broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. beautyIndicator .. " 有 比 你 更 丑 的 ？用 /beauty 也 来 测 试 测 试 你 的 吧")
        elseif beautyIndicator <= 40 then
            broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. beautyIndicator .. " 真 JB 丑 ！用 /beauty 也 来 测 试 测 试 你 的 吧")
        elseif beautyIndicator <= 60 then
            broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. beautyIndicator .. " 还 算 凑 合 ！用 /beauty 也 来 测 试 测 试 你 的 吧")
        elseif beautyIndicator <= 80 then
            broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. beautyIndicator .. " 比 较 美 丽 ！用 /beauty 也 来 测 试 测 试 你 的 吧")
        else
            broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. beautyIndicator .. " 哇 ！标 准 美 男 ！用 /beauty 也 来 测 试 测 试 你 的 吧")
        end
        game.player_set_slot(player, beautySlot, beautyIndicator)
    else
        broadcastMessage(game.sreg[44] .. "的 美 丽 指 数 是 " .. currentBeauty .. "。再 测 也 掩 饰 不 了 你 的 丑 陋")
    end

end
function resetBeauty(player)
    game.player_set_slot(player, beautySlot, -1)
end
function sendHelp(player)
    local guid = game.player_get_unique_id(0, player)
    for i,m in ipairs(commands) do
        sendInterAdminChat(player, m)
    end
    if hasValue(VIP, guid) then
        sendInterAdminChat(player, "----VIP指 令----")
        for i,m in ipairs(vipCommands) do
            sendInterAdminChat(player, m)
        end
    end
    if game.player_is_admin(player) then
        sendInterAdminChat(player, "----管 理 员 指 令 ----")
        for i,m in ipairs(admincommands) do
            sendInterAdminChat(player, m)
        end
    end
    if hasValue(root, guid) then
        sendInterAdminChat(player, "----超 级 管 理 员 指 令 ----")
        for i,m in ipairs(rootcommands) do
            sendInterAdminChat(player, m)
        end
    end
end
function transferGuid(player, transferGuid, amount)
    game.send_messsage_to_url("127.")
end