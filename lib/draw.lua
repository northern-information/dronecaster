-- init
--------------------------------------------------------------------------------

local draw = {}


function draw.init()
  screen_levels = {}
  screen_levels["o"] = 0
  screen_levels["l"] = 5
  screen_levels["m"] = 10
  screen_levels["h"] = 15
  
  alert_x = 20
  alert_y = 40
  alert_w = 87
  alert_h = 12
  
  bird_home_x = 25
  bird_home_y = 25
  last_drift = 0
  last_wind = 0
  drift_min_x = bird_home_x - 5
  drift_min_y = bird_home_y - 3
  drift_max_x = bird_home_x + 5
  drift_max_y = bird_home_y + 3
  this_drift_x = bird_home_x
  this_drift_y = bird_home_y
  
  unidentified_aerial_phenomenon = false
end

-- utils
--------------------------------------------------------------------------------

function draw.mlrs(a, b, c, d)
  screen.move(a, b)
  screen.line_rel(c, d)
  screen.stroke()
end



function draw.mls(a, b, c, d)
  screen.move(a, b)
  screen.line(c, d)
  screen.stroke()
end



function draw.get_screen_level(s)
  return screen_levels[s]
end



-- ui
--------------------------------------------------------------------------------

function draw.top_menu(hud)

  if not alt then
    screen.level(screen_levels["h"])
    screen.move(2, 8)
    screen.text(hud)
  else
    screen.level(screen_levels["h"])    
    screen.rect(0, 0, 128, 11)
    screen.fill()
    screen.level(screen_levels["o"])
    screen.move(2, 8)
    screen.text(hud)
  end
end



function draw.play_stop(playing)
  screen.level(screen_levels["l"])
  if playing == true then
    draw.mls(121, 59, 121, 64)
    draw.mls(122, 60, 122, 63)
    draw.mls(123, 61, 123, 62)
  else
    draw.mls(120, 59, 120, 64)
    draw.mls(121, 59, 121, 64)
    draw.mls(122, 59, 122, 64)
    draw.mls(123, 59, 123, 64)
    draw.mls(124, 59, 124, 64)
  end
end



function draw.clock(recording_time)
  screen.level(screen_levels["l"])
  screen.move(2, 64)
  screen.text(util.s_to_hms(recording_time))
end



function draw.alert_casting(alert, messages)
  alert_window()
  alert_message(alert["casting_message"])
  alert["casting_frame"] = alert["casting_frame"] + 1
  if (alert["casting_frame"] == 15) then
    alert["casting"] = false
    alert["casting_frame"] = 0
    alert["casting_message"] = messages["empty"]
  end
  return alert
end



function draw.alert_recording(alert, messages)
  alert_window()
  alert_message(alert["recording_message"])
  alert["recording_frame"] = alert["recording_frame"] + 1
  if (alert["recording_frame"] == 5) then
    alert["recording"] = false
    alert["recording_frame"] = 0
    alert["recording_message"] = messages["empty"]
  end
  return alert
end



function alert_window()
  screen.rect(alert_x, alert_y, alert_w, alert_h)
  screen.level(screen_levels["h"])
  screen.stroke()
  screen.rect(alert_x, alert_y, alert_w - 1, alert_h - 1)
  screen.level(screen_levels["o"])
  screen.fill()
end



function alert_message(x)
  screen.move((alert_x + (alert_w / 2)), (alert_y + (alert_h / 2) + 2))
  screen.level(screen_levels["l"])
  screen.text_center(x)
end



-- landscape
--------------------------------------------------------------------------------

function draw.light_one() draw.mlrs(62, 25, 1, 1) end
function draw.light_two() draw.mlrs(65, 17, 1, 0) end
function draw.light_three() draw.mlrs(69, 23, 1, 1) end
function draw.light_all() draw.light_one() draw.light_two() draw.light_three() end
function draw.flare_one(x) screen.circle(62, 25, x) screen.stroke() end
function draw.flare_two(x) screen.circle(65, 17, x) screen.stroke() end
function draw.flare_three(x) screen.circle(69, 23, x) screen.stroke() end
function draw.lights(playing_frame)
  screen.level(screen_levels["l"])
  light_frame = playing_frame % 9
  if light_frame == 1 then
    draw.light_all()
  elseif light_frame == 2 then
    draw.light_two()
    draw.flare_two(2)
    draw.light_three()
  elseif light_frame == 3 then
    draw.flare_two(3)
    draw.light_all()
  elseif light_frame == 4 then
    draw.flare_one(2)
    draw.flare_two(4)
    draw.light_three()
  elseif light_frame == 5 then
    draw.light_all()
  elseif light_frame == 6 then
    draw.light_two()
  elseif light_frame == 7 then
    draw.light_one()
    draw.light_three()
    draw.flare_three(5)
  elseif light_frame == 8 then
    draw.light_all()
    draw.flare_three(3)
  elseif light_frame == 9 then
    draw.light_two()
  else
    draw.light_all()
  end
end



function draw.uap(playing_frame)
  luck = math.random(0, 7)
  uap_frame = playing_frame % 5
  if playing and (luck == 3) and (unidentified_aerial_phenomenon == false) then
    unidentified_aerial_phenomenon = true
  end
  if (unidentified_aerial_phenomenon) then
    if uap_frame == 1 then
      draw.mls(100, 18, 98, 20)
    elseif uap_frame == 2 then
      draw.mls(100, 18, 90, 25)
    elseif uap_frame == 3 then
      draw.mls(94, 22, 89, 26)
    elseif uap_frame == 4 then
      draw.mls(88, 26, 86, 28)
    elseif uap_frame == 0 then
      draw.mlrs(85, 30, 1, 0)
      unidentified_aerial_phenomenon = false
    end
  end
end



function draw.wind(playing_frame)
  if wind_drift == playing_frame then
    return
  else
    wind_drift = playing_frame
    screen.level(screen_levels["l"])
    wind_frame_1 = playing_frame % 20
    wind_frame_2 = playing_frame % 13
    if math.random(0, 1) == 1 then draw.mlrs(wind_frame_1 + 80, 49, 1, 0) end
    if math.random(0, 2) ~= 0 then draw.mlrs(wind_frame_2 + 10, 49, 1, 0) end
    if math.random(0, 3) ~= 0 then draw.mlrs((wind_frame_1 * 2), 54, 1, 0) end
    if math.random(0, 2) ~= 1 then draw.mlrs(((wind_frame_1 + 4) * 3), 54, 1, 0) end
    if math.random(0, 4) ~= 0 then draw.mlrs(((wind_frame_1 + 2) * 5) + 28, 54, 1, 0) end
    if math.random(0, 1) == 1 then draw.mlrs((wind_frame_2 * 2) + 48, 61, 1, 0) end
    if math.random(0, 1) == 1 then draw.mlrs(((wind_frame_1 + 6) * 4) + 57, 61, 1, 0) end
    if math.random(0, 1) == 1 then draw.mlrs(((wind_frame_2 + 2) * 10) + 57, 61, 1, 0) end
    if math.random(0, 1) == 1 then draw.mlrs((((wind_frame_2 + 3) * 8) + 57), 61, 1, 0) end
  end
end



function drift(playing_frame)
  if last_drift == playing_frame then
    return
  else
    last_drift = playing_frame
    x_coin = math.random(0, 1)
    y_coin = math.random(0, 1)
    this_or_that = math.random(0, 1)
    that_or_this = math.random(0, 1)
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
end



function draw.birds(playing_frame)
  screen.level(screen_levels["l"])
  bird_frame = playing_frame % 3
  if playing then
    drift()
  end
  joe_now_x = this_drift_x
  joe_now_y = this_drift_y
  bethNowX = this_drift_x - 5
  beth_now_y = this_drift_y + 5
  alex_now_x = this_drift_x + 7
  alex_now_y = this_drift_y + 4
  if bird_frame == 0 then
    -- joe
    draw.mlrs(joe_now_x, joe_now_y, 2, 2)
    draw.mlrs(joe_now_x, joe_now_y, -2, 2)
    -- beth
    draw.mlrs(bethNowX, beth_now_y, 2, -2)
    draw.mlrs(bethNowX, beth_now_y, -2, -2)
    -- alex
    draw.mlrs(alex_now_x, alex_now_y, 2, 1)
    draw.mlrs(alex_now_x, alex_now_y, -2, 1)
  elseif bird_frame == 1 then
    -- joe
    draw.mlrs(joe_now_x, joe_now_y, 2, 1)
    draw.mlrs(joe_now_x, joe_now_y, -2, 1)
    -- beth
    draw.mlrs(bethNowX, beth_now_y, 2, 2)
    draw.mlrs(bethNowX, beth_now_y, -2, 2)
    -- alex
    draw.mlrs(alex_now_x, alex_now_y, 2, -2)
    draw.mlrs(alex_now_x, alex_now_y, -2, -2)
  elseif bird_frame == 2 then
    -- joe
    draw.mlrs(joe_now_x, joe_now_y, 2, -2)
    draw.mlrs(joe_now_x, joe_now_y, -2, -2)
    -- beth
    draw.mlrs(bethNowX, beth_now_y, 2, 1)
    draw.mlrs(bethNowX, beth_now_y, -2, 1)
    -- alex
    draw.mlrs(alex_now_x, alex_now_y, 2, 2)
    draw.mlrs(alex_now_x, alex_now_y, -2, 2)
  end
end



function draw.landscape()

  screen.level(screen_levels["l"])

  -- antenna sides
  draw.mls(62, 52, 66, 20)
  draw.mls(70, 53, 66, 20)

  -- antenna horizontals
  draw.mlrs(64, 34, 3, 0)
  draw.mlrs(64, 39, 3, 0)
  draw.mlrs(64, 45, 3, 0)

  -- antenna supports
  draw.mls(62, 52, 70, 44)
  draw.mls(70, 52, 62, 44)
  draw.mls(70, 44, 63, 37)

  -- antenna details
  draw.mlrs(65, 19, 2, 0)
  draw.mlrs(62, 30, 2, 0)
  draw.mlrs(67, 28, 2, 0)
  draw.mlrs(62, 27, 1, 2)
  draw.mlrs(69, 25, 1, 2)

  -- distant horizon
  draw.mlrs(0, 48, 60, 0)
  draw.mlrs(72, 48, 50, 0)

  -- second horizon
  draw.mlrs(1, 50, 1, 0)
  draw.mlrs(4, 50, 40, 0)
  draw.mlrs(46, 50, 9, 0)
  draw.mlrs(57, 50, 1, 0)
  draw.mlrs(74, 50, 40, 0)
  draw.mlrs(116, 50, 2, 0)

  -- third horizon
  draw.mlrs(5, 55, 3, 0)
  draw.mlrs(10, 55, 40, 0)
  draw.mlrs(55, 55, 20, 0)
  draw.mlrs(80, 55, 41, 0)
  
  -- closest horizon
  draw.mlrs(33, 62, 62, 0)
  draw.mlrs(100, 62, 5, 0)
  draw.mlrs(108, 62, 2, 0)

end



-- return
--------------------------------------------------------------------------------

return draw


