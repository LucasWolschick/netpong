local pickle = require("pickle")
require("consts")

local state = {}

function state.reset()
    return {
        state = STATE_WAITING_PLAYERS,
        lplayer = {
            x = 20,
            y = HEIGHT / 2,
        },
        rplayer = {
            x = WIDTH - 20,
            y = HEIGHT / 2,
        },
        ball = {
            x = WIDTH / 2,
            y = HEIGHT / 2,
            vx = BALL_SPEED,
            vy = BALL_SPEED
        }
    }
end

function state.physics(world, dt)
    -- colisão com as paredes
    if world.ball.y < BALL_RADIUS then
        world.ball.y = BALL_RADIUS
        world.ball.vy = -world.ball.vy
    elseif world.ball.y > HEIGHT - BALL_RADIUS then
        world.ball.y = HEIGHT - BALL_RADIUS
        world.ball.vy = -world.ball.vy
    end

    -- colisão temporária com as paredes verticais
    if world.ball.x < BALL_RADIUS then
        world.ball.x = BALL_RADIUS
        world.ball.vx = -world.ball.vx
    elseif world.ball.x > WIDTH - BALL_RADIUS then
        world.ball.x = WIDTH - BALL_RADIUS
        world.ball.vx = -world.ball.vx
    end

    -- colisão com os jogadores
    -- lplayer
    if world.ball.x < world.lplayer.x + PADDLE_WIDTH / 2 + BALL_RADIUS and
        world.ball.x > world.lplayer.x - PADDLE_WIDTH / 2 - BALL_RADIUS and
        world.ball.y < world.lplayer.y + PADDLE_HEIGHT / 2 + BALL_RADIUS and
        world.ball.y > world.lplayer.y - PADDLE_HEIGHT / 2 - BALL_RADIUS then
        world.ball.x = world.lplayer.x + PADDLE_WIDTH / 2 + BALL_RADIUS
        world.ball.vx = -world.ball.vx
    end
    -- rplayer
    if world.ball.x < world.rplayer.x + PADDLE_WIDTH / 2 + BALL_RADIUS and
        world.ball.x > world.rplayer.x - PADDLE_WIDTH / 2 - BALL_RADIUS and
        world.ball.y < world.rplayer.y + PADDLE_HEIGHT / 2 + BALL_RADIUS and
        world.ball.y > world.rplayer.y - PADDLE_HEIGHT / 2 - BALL_RADIUS then
        world.ball.x = world.rplayer.x - PADDLE_WIDTH / 2 - BALL_RADIUS
        world.ball.vx = -world.ball.vx
    end

    world.ball.x = world.ball.x + world.ball.vx * dt
    world.ball.y = world.ball.y + world.ball.vy * dt
end

function state.serialize(s)
    return pickle.pickle(s)
end

function state.deserialize(s)
    return pickle.unpickle(s)
end

return state
