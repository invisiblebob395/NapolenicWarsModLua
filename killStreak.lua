
require "methods"
killStreakEnabled = true
--Kill streak slots
lastKillAt = 37
killStreak = 38
killsThisLife = 39

function resetKills(player, death)
    if game.player_is_active(player) then
        local time = game.store_mission_timer_a(0)
        game.player_set_slot(player, lastKillAt, time)
        game.player_set_slot(player, killStreak, 0)
    end
    if death == true then
        game.player_set_slot(player, killsThisLife, 0)
    end
end
function incrementKillStreak(killerPlayer)
    local killerPlayerLifeKills = game.player_get_slot(0, killerPlayer, killsThisLife)
    killerPlayerLifeKills = killerPlayerLifeKills + 1
    game.player_set_slot(killerPlayer, killsThisLife, killerPlayerLifeKills)
end
function showKillStreak(killerPlayer)
    local killTime = game.store_mission_timer_a(0)
    local lastKillTime = game.player_get_slot(0, killerPlayer, lastKillAt)
    local guid = game.player_get_unique_id(0, killerPlayer)
    if((getVip(guid) ~= nil and math.abs(killTime - lastKillTime) <= 15) or math.abs(killTime - lastKillTime) <= 12) then
        game.player_set_slot(killerPlayer, lastKillAt, killTime)
        local killStreakAmount = game.player_get_slot(0, killerPlayer, killStreak)
        killStreakAmount = killStreakAmount + 1
        game.player_set_slot(killerPlayer, killStreak, killStreakAmount)
        game.str_store_player_username(44, killerPlayer)
        if killStreakAmount >= 5 then broadcastMessage(game.sreg[44] .. "天 下 无 双 ，连 续 击 杀 了 " .. killStreakAmount .. "个 敌 人")
        elseif killStreakAmount >= 3 then broadcastMessage("勇 猛 的 " .. game.sreg[44] .. "连 续 " .. killStreakAmount .. "杀 ！")
        end
    else
        resetKills(killerPlayer, false)
        game.player_set_slot(killerPlayer, killStreak, 1)
    end
end
function showKillStreakEnd(killerPlayer, killedPlayer)
    local killedPlayerLifeKills = game.player_get_slot(0, killedPlayer, killsThisLife)
    if killedPlayerLifeKills >= 5 then
        game.str_store_player_username(44, killerPlayer)
        game.str_store_player_username(45, killedPlayer)
        broadcastMessage(game.sreg[44] .. "终 结 了 " .. game.sreg[45] .. "的 " .. killedPlayerLifeKills .. "杀")
    end
end
