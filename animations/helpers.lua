function screen_shake(seconds)
    Timer.during(seconds, function()
        camShake = true
    end, function()
        camShake = false
    end)
end

-- Credits to the following functions: https://stackoverflow.com/a/25730573
-- Times between 0 and 1
function bezier_blend(time)
    return time * time * (3.0 - 2.0 * time);
end

function in_out_quad_blend(time)
    if time <= 0.5 then
        return 2.0 * time * time;
    end
    time = time - 0.5;
    return 2.0 * time * (1.0 - time) + 0.5;
end

function parametric_blend(time)
    local sqt = time * time;
    return sqt / (2.0 * (sqt - time) + 1.0);
end