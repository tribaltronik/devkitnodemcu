
-- Pin Declarations
PIN_RED = 6
PIN_GRN = 7
PIN_BLU = 8



-- Initialization routine for RGB LED pins
function rgb_init(freq, duty)
    -- Configure PWM (freq, 50% duty cycle[512/1203])
    pwm.setup(PIN_RED, freq, duty) -- Red
    pwm.setup(PIN_GRN, freq, duty) -- Green
    pwm.setup(PIN_BLU, freq, duty) -- Blue

    -- Start the PWM on those pins (Defaults to white)
    pwm.start(PIN_RED)
    pwm.start(PIN_GRN)
    pwm.start(PIN_BLU)
end 


-- Basic color function used for boot animations.
-- Set LED red, green, blue or white
function rgb_solid(mode)
    if mode == 0 then
        -- RED MODE
        pwm.setduty(PIN_RED, 512)
        pwm.setduty(PIN_GRN, 0)
        pwm.setduty(PIN_BLU, 0)
    elseif mode == 1 then
        -- GREEN MODE
        pwm.setduty(PIN_RED, 0)
        pwm.setduty(PIN_GRN, 512)
        pwm.setduty(PIN_BLU, 0)
    elseif mode == 2 then
        -- BLUE MODE
        pwm.setduty(PIN_RED, 0)
        pwm.setduty(PIN_GRN, 0)
        pwm.setduty(PIN_BLU, 512)
    else
        -- WHITE MODE
        pwm.setduty(PIN_RED, 512)
        pwm.setduty(PIN_GRN, 512)
        pwm.setduty(PIN_BLU, 512)
    end
end


-- LED Initialization
rgb_init(500, 512)
