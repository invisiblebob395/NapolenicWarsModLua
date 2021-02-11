require "methods"
local teamOneSpeed = 100
local teamTwoSpeed = 100
function removeSpectators(player)
    for curPlayer in game.playersI(1) do
        local team = game.player_get_team_no(0, curPlayer)
        if team == 2 then
            game.kick_player(curPlayer)
        end
    end
    game.str_store_player_username(44, player)
    broadcastMessage(game.sreg[44] .. "踢 出 了 所 有 的 旁 观 者")
end
