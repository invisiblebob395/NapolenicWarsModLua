
require "methods"
currentMolotovs = {}
function handleThrownMolotov(agent)
    local pos = game.preg[1]
    game.particle_system_burst(51, 1, 300)
    local x = game.position_get_x(0, 1)
    local y = game.position_get_y(0, 1)
    local z = game.position_get_z(0, 1)
    print("(" .. x .. ", " .. y .. ", " .. z .. ")")
    table.insert(currentMolotovs, {{x, y, z}, agent, 0})
end

function molotovTick()
    for i,molotov in ipairs(currentMolotovs) do
        if molotov[3] < 8 then
            dealAreaDamage(molotov[2], molotov[1], 25, 400)
            molotov[3] = molotov[3] + 1
        else
            table.remove(currentMolotovs, i)
        end
    end
end