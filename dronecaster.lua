-- DRONECASTER
--
-- k1: exit  e1: amp
--
--            e2: hz    e3: drone
--         k2: record  k3: cast
--

-- user configuration
--------------------------------------------------------------------------------
local filename_prefix = "dronecaster_"



-- engines
--------------------------------------------------------------------------------

engine.name = "Dronecaster"



-- variables
--------------------------------------------------------------------------------

-- sounds
local drones = {"Sine", "Eno", "Belong", "Hecker", "Gristle", "Starlids", "GY!BE", "V/Vm", "Canada"}
local amp_default = 0.02
local recording = false
local playing = false
local filename = filename_prefix



-- ui
local alert_x = 20
local alert_y = 40
local alert_w = 87
local alert_h = 12
local alert_recording = false
local alert_recording_frame = false
local alert_recording_message = "..."
local start_recording_message = "Recording drone..."
local stop_recording_message = "Drone saved!"
local alert_casting = false
local alert_casting_frame = false
local alert_casting_message = "..."
local start_casting_message = "Casting drone..."
local stop_casting_message = "Cast halted."



-- draw
local screen_l = 5
local screen_m = 10
local screen_h = 15



-- time
local recording_time = 0
local counter = metro.init()



-- animation
local playing_frame = 1
local recording_frame = 1
local bird_home_x = 25
local bird_home_y = 25
local last_drift = 0
local last_wind = 0
local drift_min_x = bird_home_x - 5
local drift_min_y = bird_home_y - 3
local drift_max_x = bird_home_x + 5
local drift_max_y = bird_home_y + 3
local this_drift_x = bird_home_x
local this_drift_y = bird_home_y
local unidentified_aerial_phenomenon = false



-- init & core
--------------------------------------------------------------------------------

function init()

  if util.file_exists(_path.audio .. "dronecaster/") == false then
    util.make_dir(_path.audio .. "dronecaster/")
  end

  screen.clear()
  screen.aa(0)
  screen.level(screen_h)
  screen.font_face(0)
  screen.font_size(8)

  counter.time = 1
  counter.count = -1
  counter.play = 1
  counter.event = the_sands_of_time
  counter:start()
      
  params:add_control("amp", "amp", controlspec.new(0, 1, "amp", 0, amp_default, "amp"))
  params:set_action("amp", function(x) update_amp(x) end)

  params:add_control("hz", "hz", controlspec.new(0, 20000, "lin", 0, 440, "hz"))
  params:set_action("hz", function(x) update_hz(x) end)

  params:add_control("drone","drone",controlspec.new(1, 9, "lin", 0, 1, "drone"))
  params:set_action("drone", function(x) update_drone(x) end)

  engine.stop(1) -- todo: how to not have the engine automatically start?

  -- dev
  -- key(3, 1) -- start
  -- key(2, 1) -- record

end



function the_sands_of_time()
  
  if playing then
    playing_frame = playing_frame + 1  
  end
  
  if recording then
    recording_frame = recording_frame + 1
    recording_time = recording_time + 1
  end
  
  redraw()

end



function redraw()
  
  screen.clear()
  
  draw_birds()
  draw_wind()
  draw_lights()
  draw_uap()
  draw_landscape()
  
  draw_top_menu()
  draw_clock()
  draw_play_stop()
  draw_recording()
  draw_alert_recording()
  draw_alert_casting()
  
  screen.update()
    
end



function update_hz(x)
  
  if playing then 
    engine.hz(x)
  end
  
end



function update_amp(x)
  
  if playing then
    engine.amp(x)
  end
  
end



function update_drone(x)
  
  if playing then
    engine.drone(round(x))
  end
  
end



-- encs & keys
--------------------------------------------------------------------------------

function enc(n,d)

  -- amp
  if n == 1 then
    params:delta("amp", d * .1)
  end

  -- hz
  if n == 2 then
    params:delta("hz", d * .001)
  end

  -- drone
  if n == 3 then
     params:delta("drone", d)
  end

  redraw()

end



function key(n, z)

  -- k2 record
  if n == 2 and z == 1 then
    
    recording = not recording
    
    if recording == true then
      recording_time = 0
      alert_recording_frame = 1
      alert_recording_message = start_recording_message
      alert_recording = true
    else
      alert_recording_frame = 1
      alert_recording_message = stop_recording_message
      alert_recording = true
    end
    
  end

  -- k3 cast
  if n == 3 and z == 1 then
    
    playing = not playing

    alert_casting_frame = 1
    alert_casting = true
    
    if playing == true then
      engine.start(1)
      engine.amp(params:get("amp"))
      engine.hz(params:get("hz"))
      alert_casting_message = start_casting_message
    else
      engine.stop(1)
      alert_casting_message = stop_casting_message
    end
    
  end

  redraw()

end



-- utils
--------------------------------------------------------------------------------

function round(num, places)
  
  if places and places > 0 then
    local mult = 10 ^ places
    return math.floor(num * mult + 0.5) / mult
  end
  
  return math.floor(num + 0.5)
  
end



function mlrs(a, b, c, d)
  
  screen.move(a, b)
  screen.line_rel(c, d)
  screen.stroke()
  
end



function mls(a, b, c, d)
  
  screen.move(a, b)
  screen.line(c, d)
  screen.stroke()
  
end



-- ui draws
--------------------------------------------------------------------------------

function draw_alert_casting()

  if (alert_casting) then
    draw_alert_window()
    draw_alert_message(alert_casting_message)
    alert_casting_frame = alert_casting_frame + 1
  end
  
  if (alert_casting_frame == 5) then
    alert_casting = false
    alert_casting_frame = false
    alert_casting_message = "..."
  end

end



function draw_alert_recording()

  if (alert_recording) then
    draw_alert_window()
    draw_alert_message(alert_recording_message)
    alert_recording_frame = alert_recording_frame + 1
  end
  
  if (alert_recording_frame == 5) then
    alert_recording = false
    alert_recording_frame = false
    alert_recording_message = "..."
  end

end



function draw_alert_window()
  
  screen.rect(alert_x, alert_y, alert_w, alert_h)
  screen.level(screen_h)
  screen.stroke()
  screen.rect(alert_x, alert_y, alert_w - 1, alert_h - 1)
  screen.level(0)
  screen.fill()
  
end



function draw_alert_message(x)
  
  screen.move((alert_x + (alert_w / 2)), (alert_y + (alert_h / 2) + 2))
  screen.level(screen_l)
  screen.text_center(x)
  
end



function draw_top_menu()

  screen.level(screen_l)

  mlrs(0, 12, 40, 0)
  mlrs(44, 12, 40, 0)
  mlrs(88, 12, 40, 0)

  screen.level(screen_h)
  
  screen.move(2, 8)
  screen.text(round(params:get("amp"), 2) .. " amp")
  
  screen.move(45, 8)
  screen.text(round(params:get("hz")) .. " hz")
  
  screen.move(89, 8)
  screen.text(drones[round(params:get("drone"))])

end



function draw_clock()
  
  screen.level(screen_l)
  screen.move(7, 64)
  screen.text(util.s_to_hms(recording_time))
  
end



function draw_play_stop()

  screen.level(screen_l)

  if playing == true then
    -- play
    mls(121, 59, 121, 64)
    mls(122, 60, 122, 63)
    mls(123, 61, 123, 62)
  else
    -- stop
    mls(120, 59, 120, 64)
    mls(121, 59, 121, 64)
    mls(122, 59, 122, 64)
    mls(123, 59, 123, 64)
    mls(124, 59, 124, 64)
  end

end



function draw_recording()

  screen.level(screen_l)

  if recording then
    
    if (recording_frame % 2) == 1 then
      screen.circle(2, 61, 2)
      screen.fill()
    else
      screen.circle(2, 61, 2)
      screen.stroke()
    end
    
  else
    
    screen.circle(2, 61, 2)
    screen.stroke()
    
  end
  

end



-- everything beyond is bird, tower, and wind animations...
--------------------------------------------------------------------------------

function draw_uap()
  
  local luck = math.random(0, 7)
  local uap_frame = playing_frame % 5

  if playing and (luck == 3) and (unidentified_aerial_phenomenon == false) then
    unidentified_aerial_phenomenon = true
  end
  
  if (unidentified_aerial_phenomenon) then
    
    if uap_frame == 1 then
      mls(100, 18, 98, 20)
    elseif uap_frame == 2 then
      mls(100, 18, 90, 25)
    elseif uap_frame == 3 then
      mls(94, 22, 89, 26)
    elseif uap_frame == 4 then
      mls(88, 26, 86, 28)
    elseif uap_frame == 0 then
      mlrs(85, 30, 1, 0)
      unidentified_aerial_phenomenon = false
    end
    
  end
  
end



function drift()
  
  if last_drift == playing_frame then
    return
  end
  
  last_drift = playing_frame
  
  local x_coin = math.random(0, 1)
  local y_coin = math.random(0, 1)
  local this_or_that = math.random(0, 1)
  local that_or_this = math.random(0, 1)
  
  if this_or_that == 0 then
    check_x = (x_coin * -1) + this_drift_x
  else
    check_x = x_coin + this_drift_x
  end
  
  if that_or_this == 0 then
    check_y = (y_coin * -1) + this_drift_y
  else
    check_y = y_coin + this_drift_y
  end

  if (check_x > drift_max_x) then
    this_drift_x = drift_max_x
  elseif  (check_x < drift_min_x) then
    this_drift_x = drift_min_x
  else
    this_drift_x = check_x
  end
  
  if (check_y > drift_max_y) then
    this_drift_y = drift_max_y
  elseif  (check_y < drift_min_y) then
    this_drift_y = drift_min_y
  else
    this_drift_y = check_y
  end

end



function draw_birds()

  screen.level(screen_l)

  local bird_frame = playing_frame % 3

  if playing then
    drift()
  end

  local joe_now_x = this_drift_x
  local joe_now_y = this_drift_y
  local bethNowX = this_drift_x - 5
  local beth_now_y = this_drift_y + 5
  local alex_now_x = this_drift_x + 7
  local alex_now_y = this_drift_y + 4

  if bird_frame == 0 then
    -- joe
    mlrs(joe_now_x, joe_now_y, 2, 2)
    mlrs(joe_now_x, joe_now_y, -2, 2)
    -- beth
    mlrs(bethNowX, beth_now_y, 2, -2)
    mlrs(bethNowX, beth_now_y, -2, -2)
    -- alex
    mlrs(alex_now_x, alex_now_y, 2, 1)
    mlrs(alex_now_x, alex_now_y, -2, 1)
  end

  if bird_frame == 1 then
    -- joe
    mlrs(joe_now_x, joe_now_y, 2, 1)
    mlrs(joe_now_x, joe_now_y, -2, 1)
    -- beth
    mlrs(bethNowX, beth_now_y, 2, 2)
    mlrs(bethNowX, beth_now_y, -2, 2)
    -- alex
    mlrs(alex_now_x, alex_now_y, 2, -2)
    mlrs(alex_now_x, alex_now_y, -2, -2)
  end

  if bird_frame == 2 then
    -- joe
    mlrs(joe_now_x, joe_now_y, 2, -2)
    mlrs(joe_now_x, joe_now_y, -2, -2)
    -- beth
    mlrs(bethNowX, beth_now_y, 2, 1)
    mlrs(bethNowX, beth_now_y, -2, 1)
    -- alex
    mlrs(alex_now_x, alex_now_y, 2, 2)
    mlrs(alex_now_x, alex_now_y, -2, 2)
  end

end



function draw_wind()
  
  if wind_drift == playing_frame then
    return
  end
  
  wind_drift = playing_frame

  screen.level(screen_l)

  local wind_frame_1 = playing_frame % 20
  local wind_frame_2 = playing_frame % 13

  if math.random(0, 1) == 1 then
    mlrs(wind_frame_1 + 80, 49, 1, 0)
  end

  if math.random(0, 2) ~= 0 then
    mlrs(wind_frame_2 + 10, 49, 1, 0)
  end

  if math.random(0, 3) ~= 0 then
    mlrs((wind_frame_1 * 2), 54, 1, 0)
  end

  if math.random(0, 2) ~= 1 then
    mlrs(((wind_frame_1 + 4) * 3), 54, 1, 0)
   end

  if math.random(0, 4) ~= 0 then
    mlrs(((wind_frame_1 + 2) * 5) + 28, 54, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs((wind_frame_2 * 2) + 48, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs(((wind_frame_1 + 6) * 4) + 57, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs(((wind_frame_2 + 2) * 10) + 57, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs((((wind_frame_2 + 3) * 8) + 57), 61, 1, 0)
  end

end



function light_one()
  
  mlrs(62, 25, 1, 1)
  
end



function light_two()
  
  mlrs(65, 17, 1, 0)
  
end



function light_three()
  
  mlrs(69, 23, 1, 1)
  
end



function light_all()
  
  light_one()
  light_two()
  light_three()
  
end



function flare_one(x)
  
  screen.circle(62, 25, x)
  screen.stroke()
  
end



function flare_two(x)
  
  screen.circle(65, 17, x)
  screen.stroke()
  
end



function flare_three(x)
  
  screen.circle(69, 23, x)
  screen.stroke()
  
end



function draw_lights()

  screen.level(screen_l)

  local light_frame = playing_frame % 9

  if light_frame == 1 then
    light_all()
  elseif light_frame == 2 then
    light_two()
    flare_two(2)
    light_three()
  elseif light_frame == 3 then
    flare_two(3)
    light_all()
  elseif light_frame == 4 then
    flare_one(2)
    flare_two(4)
    light_three()
  elseif light_frame == 5 then
    light_all()
  elseif light_frame == 6 then
    light_two()
  elseif light_frame == 7 then
    light_one()
    light_three()
    flare_three(5)
  elseif light_frame == 8 then
    light_all()
    flare_three(3)
  elseif light_frame == 9 then
    light_two()
  else
    light_all()
  end

end



function draw_landscape()

  screen.level(screen_l)

  -- antenna sides
  mls(62, 52, 66, 20)
  mls(70, 53, 66, 20)

  -- antenna horizontals
  mlrs(64, 34, 3, 0)
  mlrs(64, 39, 3, 0)
  mlrs(64, 45, 3, 0)

  -- antenna supports
  mls(62, 52, 70, 44)
  mls(70, 52, 62, 44)
  mls(70, 44, 63, 37)

  -- antenna details
  mlrs(65, 19, 2, 0)
  mlrs(62, 30, 2, 0)
  mlrs(67, 28, 2, 0)
  mlrs(62, 27, 1, 2)
  mlrs(69, 25, 1, 2)

  -- distant horizon
  mlrs(0, 48, 60, 0)
  mlrs(72, 48, 50, 0)

  -- second horizon
  mlrs(1, 50, 1, 0)
  mlrs(4, 50, 40, 0)
  mlrs(46, 50, 9, 0)
  mlrs(57, 50, 1, 0)
  mlrs(74, 50, 40, 0)
  mlrs(116, 50, 2, 0)

  -- third horizon
  mlrs(5, 55, 3, 0)
  mlrs(10, 55, 40, 0)
  mlrs(55, 55, 20, 0)
  mlrs(80, 55, 41, 0)
  
  -- closest horizon
  mlrs(38, 62, 62, 0)
  mlrs(102, 62, 5, 0)
  mlrs(110, 62, 2, 0)

end