package.path = package.path .. ";../?.lua"

require("consts")
local enet = require("enet")
local state = require("world")

local world = state.reset()
local direction = 0
local connected = false

local client
local server

function listen()
    if client then
        local event = client:service()
        while event do
            if event.type == "connect" then
                connected = true
            elseif event.type == "receive" then
                local data = event.data:split(" ")
                if data[1] == "state" then
                    world = state.deserialize(data[2])
                end
            end
            event = client:service()
        end
    end
end

function love.load(arg)
    local ip = arg[1] or "*"
    client = enet.host_create()
    server = client:connect(ip .. ":" .. PORT)
end

function love.update(dt)
    listen()

    if connected then
        local newDir
        if love.keyboard.isDown("w") then
            newDir = -1
        elseif love.keyboard.isDown("s") then
            newDir = 1
        else
            newDir = 0
        end
        if newDir ~= direction then
            direction = newDir
            server:send(({ [-1] = "w", [0] = ".", [1] = "s" })[direction])
        end

        -- update world
        if world.state == STATE_PLAYING then
            state.physics(world, dt)
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    if not connected then
        love.graphics.print("disconnected", 5, 5)
    end
    love.graphics.rectangle(
        "fill",
        world.lplayer.x - PADDLE_WIDTH / 2,
        world.lplayer.y - PADDLE_HEIGHT / 2,
        PADDLE_WIDTH,
        PADDLE_HEIGHT
    )
    love.graphics.rectangle(
        "fill",
        world.rplayer.x - PADDLE_WIDTH / 2,
        world.rplayer.y - PADDLE_HEIGHT / 2,
        PADDLE_WIDTH,
        PADDLE_HEIGHT
    )
    love.graphics.circle(
        "fill",
        world.ball.x,
        world.ball.y,
        BALL_RADIUS
    )

    local y = 20
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
