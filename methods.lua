
doNotDisturb = {
    1397826, --lucy
    1250162, --knight
}
triggers = {}
timers = {}
instances = {}
interAdminChat = game.getScriptNo("send_inter_admin_chat")
globalBroadcast = game.getScriptNo("multiplayer_broadcast_message")
coloredChat = game.getScriptNo("send_colored_chat_s0")
playSoundAtPos = game.getScriptNo("multiplayer_server_play_sound_at_position")
callCommand = game.getScriptNo("wse_chat_message_received")
forceClientRefreshItems = game.getScriptNo("refresh_items")
slayPlayer = game.getScriptNo("multiplayer_server_slay_player")
explodeAtPos = game.getScriptNo("explosion_at_position")
caesimGiveItem = game.getScriptNo("caesim_give_item")
serverMessageReceived = game.getScriptNo("game_receive_network_message")
getZombieModeEnabled = game.getScriptNo("get_zombie_mode_enabled")
cleanUpInstance = game.getScriptNo("clean_up_prop_instance_with_childs")
roundTime = 0
timers = {}
function zombieIsEnabled()
    game.call_script(getZombieModeEnabled)
    return game.reg[51] == 1
end
function readFile(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read()
    file:close()
    return content
end
function playSoundPos(soundID, pos)
    game.preg[56] = pos
    game.call_script(playSoundAtPos, soundID)
end
function playSound(soundID, x, y, z)
    game.init_position(56)
    game.position_set_x(56, x)
    game.position_set_x(56, y)
    game.position_set_x(56, z)
    game.call_script(playSoundAtPos, soundID)
end
function broadcastMessage(message)
    game.sreg[4] = message
    game.call_script(globalBroadcast)
end
function sendInterAdminChat(player, message)
    game.sreg[4] = message
    game.call_script(interAdminChat, player)
end
function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    local i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
function starts(String,Start)
return string.sub(String,1,string.len(Start))==Start
end
function hasValue(array, value)
    if value == nil then return false end
    for i, a in ipairs(array) do
        if a == value then
            return true
        end
    end
    return false
end
function printTable(t, prefix)
    if not prefix then
        prefix = ""
    end

    for k,v in pairs(t) do
        local typ = "[" .. type(v) .. "] "
        local name = "'" .. k .. "' ="
        local val = " " .. tostring(v)

        if type(v) == "table" then
            print(prefix .. typ .. name)
            printTable(v, prefix .. "___")

        else
            print(prefix .. typ .. name .. val)
        end
    end
end
function log(path, message)
    local myLog = io.open(path, "a")
    myLog:write(message .. "\n")
    myLog:flush()
end
function addTrigger(mst, check, delay, rearm, cond, cons)
    local index
    if cons then
        index = game.addTrigger(mst, check, delay, rearm, cond, cons)
    else
        index = game.addTrigger(mst, check, delay, rearm, cond)
    end
    table.insert(triggers, index)
    return index
end

function addTriggerToAll(check, callback)
    for k,v in pairs({"dm","tdm","cf","sg","bt","duel"}) do
        addTrigger("mst_multiplayer_" .. v, check, 0, 0, callback)
    end
end
function getAgentID(player)
    local agent = game.player_get_agent_id(0, player)
    return agent
end
function clearStack()
    game.lua_set_top(0) -- prevents stack overflow errors, clears lua stack
end
function playSoundWithID(player, ID)
    local agentID = game.get_player_agent_no(0, player)
    if game.agent_is_alive(agentID) then
        game.agent_get_position(56, agentID)
        game.call_script(playSoundAtPos, ID)
    else
        playSound(ID, 200, 200, 200)
    end
end

--finds empty slot, if no empty slot is found, overwrites current slot
function giveItem(player, itemID, slot)
    local agentID = game.player_get_agent_id(0, player)
    local equippedItem = 0
    if game.agent_is_alive(agentID) then
        local slotID = 0
        if slot == -1 then
            --loop to find empty slot, if found, break loop, if not, put item in last slot
            slotID = 0
            while(slotID < 4) do
                equippedItem = game.agent_get_item_slot(0, agentID, slotID)
                if(equippedItem <= 0) then
                    break
                end
                if slotID == 3 then
                    game.agent_unequip_item(agentID,equippedItem, slotID)
                    break
                end
                slotID = slotID + 1
            end
        else
            slotID = slot
            equippedItem = game.agent_get_item_slot(0, agentID, slotID)
            if equippedItem <= -1 then
                game.agent_unequip_item(agentID, equippedItem, slotID) --unequip item if equipped
            end
        end
        if itemID > -1 then
            game.agent_equip_item(agentID, itemID, slotID) --equip item
        end
        if slotID >= 0 and slotID <= 3 then --if is wep, set as wielded
            game.agent_set_wielded_item(agentID, itemID)
        end
        game.call_script(forceClientRefreshItems, agentID, itemID, slotID)
        return true
    else
        return false
    end
end
function binarySearch (list,value)
    local mid = 0
    local low = 1
    local high = #list
    while low <= high do
        mid = math.floor((low+high)/2)
        if list[mid] > value then high = mid - 1
        elseif list[mid] < value then low = mid + 1
        else return {true, mid}
        end
    end
    if low == #list + 1 then return {false, #list + 1}
    elseif list[low] > value then return {false, low}
    else return {false, low + 1} end
end
function eraseTable(tab)
    for k,v in pairs(tab) do tab[k]=nil end
end
function equipItem(player, itemSlot, itemID)
    if itemID == -1 then
        return true
    end
    if itemSlot >= 0 and itemSlot <= 8 then
        --[[game.player_set_slot(player, itemSlot + 2, itemID)
        local agentID = game.player_get_agent_id(0, player)
        if game.agent_is_alive(agentID) then --equip immediately if alive
            giveItem(player, itemID, itemID)
        end]]
        game.call_script(caesimGiveItem, player, itemID, itemSlot)
        return true
    else
        return false
    end
end
function spawnHorse(player, horseID)
    local agentID = game.player_get_agent_id(0, player)
    if game.agent_is_alive(agentID) then
        game.agent_get_position(2, agentID)
        game.position_move_z(2, -10)
        game.position_move_y(2, 200)
        game.set_spawn_position(2)
        game.spawn_horse(horseID, 0)
        return true
    else
        return false
    end
end
function broadcastColoredChat(player, message, color)
    game.sreg[0] = message
    for curPlayer in game.playersI(1) do
        local guid = game.player_get_unique_id(0, curPlayer)
        if hasValue(doNotDisturb, guid) then
            game.call_script(coloredChat, curPlayer, 0xFFFFFF)
        else
            game.call_script(coloredChat, curPlayer, color)
        end
    end
    game.server_add_message_to_log(0)
end
function incrementSlot(player, slotID, value)
    local slotValue = game.player_get_slot(0, player, slotID)
    slotValue = slotValue + value
    game.player_set_slot(player, slotID, slotValue)
end
function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end
function roundToDecimalPlaces(number, decimalPlaces)
    return round(number*(10^decimalPlaces))*(10^(-decimalPlaces))
end
function getSlot(player, slotID)
    local slotValue = game.player_get_slot(0, player, slotID)
    return slotValue
end
function getKDFromScore(kills, deaths)
    local KD = roundToDecimalPlaces(kills/(math.max(deaths, 1)), 3)
    return KD
end
function formatAPICall(path, parameters, values)
    local url = "http://127.0.0.1/" .. path .. "?"
    if table.getn(parameters) ~= table.getn(values) then return nil end
    for i,m in ipairs(parameters) do
        url = url .. m .. "=" .. values[i]
        if i ~= table.getn(parameters) then
            url = url .. "&"
        end
    end
    return url
end
function spawnItem(player, item)

end
function generateTableOfNumbers(low, high)
    local tables = {}
    for i=low,high do
        table.insert(tables, i)
    end
    return tables
end
function addDenars(guid, denars)
    game.send_message_to_url("http://127.0.0.1/api.php?type=9&guid=" .. guid .. "&id=1" .. "&amount=" .. denars)
end
function getDistanceBetweenPos(x1, y1, z1, x2, y2, z2)
    return ((x1-x2)^2+(y1-y2)^2+(z1-z2)^2)^(0.5)
end
function dealAreaDamage(agent, position, damage, radius)
    radius = radius
    for curAgent in game.agentsI() do
        if game.agent_is_active(curAgent) and game.agent_is_alive(curAgent) then
            game.agent_get_position(49, curAgent)
            local x = game.position_get_x(0, 49)
            local y = game.position_get_y(0, 49)
            local z = game.position_get_z(0, 49)
            local x1 = position[1]
            local x2 = position[2]
            local x3 = position[3]
            if getDistanceBetweenPos(x1, x2, x3, x, y, z) <= radius then
                if not game.agent_is_active(curAgent) then
                    agent = curAgent
                end
                game.agent_deliver_damage_to_agent(agent, curAgent, damage)
            end
        end
    end
end
function setPlayerTeam(player, teamNo)
    print(player)
    if game.player_is_active(player) and teamNo >= 0 and teamNo <= 2 then
        --set player team if they aren't already on it
        local agent = game.player_get_agent_id(0, player)
        if game.agent_is_active(agent) and game.agent_is_alive(agent) then
            --no weapon dropping(ie. shotguns)
            game.agent_set_wielded_item(agent, -1)
            game.agent_set_hit_points(agent, 0, 1)
            game.agent_deliver_damage_to_agent(agent, agent, 37) --kill agent if alive
        end
        if game.player_get_team_no(0, player) ~= teamNo then game.player_set_team_no(player, teamNo) end
        game.player_set_troop_id(player, -1)
        game.multiplayer_send_message_to_player(player, 79) --79 is multiplayer_event_force_start_team_selection
    else
        print("Error in setPlayerTeam")
    end
end
function emptyAllWeapons()
    for curPlayer in game.playersI(1) do
        if game.player_is_active(player) then

        end
    end
end
function roundTimeTick()
    roundTime = roundTime + 1
end
function printPos(player, num)
    sendInterAdminChat(player, "X: " .. game.position_get_x(0, num) .. " Y: " .. game.position_get_y(0, num) .. " Z: " .. game.position_get_z(0, num))
end
function spawnSceneItem(spr, x, y, z, xrot, yrot, zrot)

end
function removeProp(instanceId)
    game.prop_instance_enable_physics(instanceId, 0)
    game.call_script(cleanUpInstance, instanceId)
    game.prop_instance_get_position(27, instanceId)
    game.position_set_z(27, -20000)
    game.prop_instance_set_position(instanceId, 27)
end
function timerTick()
    for i=#timers,1,-1 do
        timers[i][2] = timers[i][2] - 1 --tick
        if timers[i][2] <= 0 then
            loadstring(timers[i][1])()
            table.remove(timers, i)
        end
    end
end
function addTimer(func, time)
    table.insert(timers, {func, time})
end
function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end