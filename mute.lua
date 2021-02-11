
require "methods"
mutedPlayers = {

}
function mute(player, muteDuration)
    local guid = game.player_get_unique_id(0, player)
    local osTime = os.time()
    table.insert(mutedPlayers, {guid, osTime, muteDuration})
end
function unmute(guid)
    for i, m in ipairs(mutedPlayers) do
        if m[1] == guid then
            table.remove(mutedPlayers, i)
            return true
        end
    end
    return false
end
function handleMute(player, message)
    local guid = game.player_get_unique_id(0, player)
    local args = split(message, " ") -- args[1] = commands, 2 = player no
    if not tonumber(args[2]) or not tonumber(args[3]) then
        sendInterAdminChat(player, "ID 错 误")
    else
        local mutedPlayer = math.floor(tonumber(args[2]))
        local mutedTime = math.floor(tonumber(args[3]))
        if game.player_is_active(mutedPlayer) then
            if hasValue(root, guid) or not game.player_is_admin(mutedPlayer) then
                mute(mutedPlayer, mutedTime)
                game.str_store_player_username(1, player)
                game.str_store_player_username(12, mutedPlayer)
                broadcastMessage(game.sreg[1] .. " 禁 言 了 " .. game.sreg[12] .. mutedTime .. "秒")
            else
                game.str_store_player_username(12, mutedPlayer)
                sendInterAdminChat(player, "你 没 有 权 限 禁 言 " .. game.sreg[12])
            end
        else
            sendInterAdminChat(player, "ID 错 误")
        end
    end
end
function handleUnmute(player, message)
    local guid = game.player_get_unique_id(0, player)
    local args = split(message, " ")
    if not tonumber(args[2]) then
        sendInterAdminChat(player, "Invalid player number")
    else
        local unmuteGuid = math.floor(tonumber(args[2]))
        if unmuteGuid ~= guid or hasValue(root, guid) then
            if unmute(unmuteGuid) then
                game.str_store_player_username(44, player)
                broadcastMessage(game.sreg[44] .. "解 除 了 " .. unmuteGuid .. "的 禁 言")
            else
                sendInterAdminChat(player, "此 人 没 有 被 禁 言")
            end
        else
            sendInterAdminChat(player, "你 没 有 权 限 解 禁 此 人")
        end
    end
end
function checkMuteActual(player, chatType)
    local guid = game.player_get_unique_id(0, player)
    for i,m in ipairs(mutedPlayers) do
        if m[1] == guid then --m is an array, m[1] stores the guid, m[2] stores mute time, m[3] stores mute duration
            local time = os.time()
            local startTime = m[2]
            local duration = m[3]
            if(time - startTime <= duration) then
                return {true, math.floor(duration - (time - startTime))}
            else
                table.remove(mutedPlayers, i)
                return {false, 0}
            end
        end
    end
    return {false, 0}
end