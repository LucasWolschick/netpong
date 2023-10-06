package.path = package.path .. ";../?.lua"

require("consts")
local enet = require("enet")
local state = require("world")

local world = state.reset()
local playerIps = {}
local moves = { 0, 0 }

function update(dt)
    if world.state == STATE_WAITING_PLAYERS then
        if #playerIps == 2 then
            world.state = STATE_PLAYING
        else
            return
        end
    elseif world.state == STATE_PLAYING then
        if #playerIps < 2 then
            world = state.reset()
            return
        end
    end

    state.physics(world, dt)

    world.lplayer.y = world.lplayer.y + moves[1] * PADDLE_SPEED * dt
    if world.lplayer.y < PADDLE_HEIGHT / 2 then
        world.lplayer.y = PADDLE_HEIGHT / 2
    elseif world.lplayer.y > HEIGHT - PADDLE_HEIGHT / 2 then
        world.lplayer.y = HEIGHT - PADDLE_HEIGHT / 2
    end
    world.rplayer.y = world.rplayer.y + moves[2] * PADDLE_SPEED * dt
    if world.rplayer.y < PADDLE_HEIGHT / 2 then
        world.rplayer.y = PADDLE_HEIGHT / 2
    elseif world.rplayer.y > HEIGHT - PADDLE_HEIGHT / 2 then
        world.rplayer.y = HEIGHT - PADDLE_HEIGHT / 2
    end

    -- send game state to all players
    local serialized = state.serialize(world)
    for i = 1, #playerIps do
        playerIps[i]:send("state " .. serialized)
    end
end

-- run game loop
local lastFrame = os.clock()
local accum = 0
local updateLoop = coroutine.wrap(function()
    while true do
        local dt = os.clock() - lastFrame
        lastFrame = os.clock()
        accum = accum + dt

        while accum > SERVER_RATE do
            update(SERVER_RATE)
            accum = accum - SERVER_RATE
        end

        coroutine.yield()
    end
end)

local server
function love.load()
    server = enet.host_create("*:" .. PORT)
    print("Server started on port " .. PORT)
end

function love.draw()
    love.graphics.print("server running", 5, 5)
    -- print connected players (enet)
    local y = 20
    for i = 1, #playerIps do
        love.graphics.print("player " .. i .. ": " .. tostring(playerIps[i]), 200, y)
        y = y + 15
    end
    -- print game state
    y = 20
    for k, v in pairs(world) do
        if type(v) == "table" then
            for k2, v2 in pairs(v) do
                love.graphics.print(k .. " " .. k2 .. " = " .. v2, 400, y)
                y = y + 15
            end
        else
            love.graphics.print(k .. " = " .. v, 400, y)
            y = y + 15
        end
    end
end

function love.update()
    updateLoop()
    local event = server:service()
    while event do
        if event.type == "receive" then
            -- algum cliente mandou mensagem
            local nPlayer = 0
            for i = 1, #playerIps do
                if playerIps[i] == event.peer then
                    nPlayer = i
                end
            end

            if nPlayer ~= 0 then
                -- atualiza o estado do jogador
                if event.data == "w" then
                    moves[nPlayer] = -1
                elseif event.data == "s" then
                    moves[nPlayer] = 1
                elseif event.data == "." then
                    moves[nPlayer] = 0
                end
            end
        elseif event.type == "connect" then
            -- algum cliente se conectou
            if #playerIps < 2 then
                print(event.peer, ": novo jogador", #playerIps + 1)
                table.insert(playerIps, event.peer)
                event.peer:send("ok")
            else
                print(event.peer, ": o jogo está cheio")
                event.peer:disconnect_now()
            end
        elseif event.type == "disconnect" then
            -- algum cliente se desconectou
            print(event.peer, ": jogador desconectou")

            for i = #playerIps, 1, -1 do
                if playerIps[i] == event.peer then
                    table.remove(playerIps, i)
                end
            end
        end
        event = server:service()
    end
end
