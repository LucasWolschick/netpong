WIDTH = 800
HEIGHT = 600
PADDLE_HEIGHT = 100
PADDLE_WIDTH = 5
PADDLE_SPEED = 200
BALL_RADIUS = 8
BALL_SPEED = 600
PORT = 6789
STATE_WAITING_PLAYERS = 0
STATE_PLAYING = 1
SERVER_RATE = 1 / 50

function string.split(s, pattern)
    if pattern == nil then
        pattern = "%s"
    end
    local t = {}
    for str in string.gmatch(s, "([^" .. pattern .. "]+)") do
        table.insert(t, str)
    end
    return t
end
