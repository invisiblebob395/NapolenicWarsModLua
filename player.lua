
require "class"
players = {}

Player = class(function(player, id)
    player.id = id
    player.guid = game.player_get_unique_id(0, player)
    player.killStreak = 0
    player.killsThisLife = 0
end)
function Player:sendColoredMessage(message, color)

end
function Player:sendMessage(message)
    self:sendColoredMessage(message, 0xFFFF22)
end

