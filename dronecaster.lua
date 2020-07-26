-- DRONECASTER
--
-- k1: exit  e1: amp
--
--            e2: hz    e3: drone
--         k2: record  k3: cast
--

-- user configuration
--------------------------------------------------------------------------------
local filenamePrefix = "dronecaster_"



-- engines
--------------------------------------------------------------------------------

engine.name = "Dronecaster"



-- variables
--------------------------------------------------------------------------------

-- sounds
local drones = {"Sine", "Eno", "Belong", "Hecker", "Gristle", "Starlids", "GY!BE", "V/Vm", "Canada"}
local ampDefault = 0.02
local recording = false
local playing = false
local filename = filenamePrefix



-- ui
local recordKey = false
local castKey = false
local alertX = 20
local alertY = 40
local alertW = 87
local alertH = 12
local alertRecording = false
local startRecordingMessage = "Recording drone..."
local stopRecordingMessage = "Drone saved!"
local alertCasting = false
local startCastingMessage = "Casting drone..."
local stopCastingMessage = "Cast halted."



-- draw
local screenL = 5
local screenM = 10
local screenH = 15



-- time
local seconds = 0
local counter = metro.init()
local recordingTime = 0



-- animation
local frame = 1
local recordingFrame = 1
local birdHomeX = 25
local birdHomeY = 25
local driftMinX = birdHomeX - 5
local driftMinY = birdHomeY - 3
local driftMaxX = birdHomeX + 5
local driftMaxY = birdHomeY + 3
local thisDriftX = birdHomeX
local thisDriftY = birdHomeY
local unidentifiedAerialPhenomenon = false



-- init & core
--------------------------------------------------------------------------------

function init()

  if util.file_exists(_path.audio .. "dronecaster/") == false then
    util.make_dir(_path.audio .. "dronecaster/")
  end

  screen.clear()
  screen.aa(0)
  screen.level(screenH)
  screen.font_face(0)
  screen.font_size(8)

  counter.time = 1
  counter.count = -1
  counter.play = 1
  counter.event = theSandsOfTime
  counter:start()
      
  params:add_control("amp", "amp", controlspec.new(0, 1, "amp", 0, ampDefault, "amp"))
  params:set_action("amp", function(x) updateAmp(x) end)

  params:add_control("hz", "hz", controlspec.new(0, 20000, "lin", 0, 440, "hz"))
  params:set_action("hz", function(x) updateHz(x) end)

  params:add_control("drone","drone",controlspec.new(1, 9, "lin", 0, 1, "drone"))
  params:set_action("drone", function(x) updateDrone(x) end)

  -- dev
  -- key(3, 1) -- start
  -- key(2, 1) -- record

end



function theSandsOfTime(c)
  seconds = c
  if playing then
    frame = frame + 1  
  end
  if recording then
    recordingFrame = recordingFrame + 1
    recordingTime = recordingTime + 1
  end
  redraw()
end



function count()
  units = units + 1
  ms = units / 100
  seconds = ms % 60
  redraw()
end



function redraw()
  screen.clear()
  drawTopMenu()
  drawBirds()
  drawWind()
  drawLights()
  drawUAP()
  drawLandscape()
  drawClock()
  drawPlayStop()
  drawRecording()
  drawAlertRecording()
  drawAlertCasting()
  screen.update()
end



function updateHz(x)
  engine.hz(x)
end



function updateAmp(x)
  engine.amp(x)
end



function updateDrone(x)
  print(round(x))
  -- engine.drone(round(x))
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
      units = 0
      recordingTime = 0
      alertRecordingFrame = 1
      alertRecordingMessage = startRecordingMessage
      alertRecording = true
    else
      alertRecordingFrame = 1
      alertRecordingMessage = stopRecordingMessage
      alertRecording = true
    end
    
  end

  -- k3 cast
  if n == 3 and z == 1 then
    
    playing = not playing
    
    if playing == true then
      engine.startStop(0)
      alertCastingFrame = 1
      alertCastingMessage = startCastingMessage
      alertCasting = true
    else
      engine.startStop(1)
      alertCastingFrame = 1
      alertCastingMessage = stopCastingMessage
      alertCasting = true
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

function drawAlertCasting()

  if (alertCasting) then
    drawAlertWindow()
    drawAlertMessage(alertCastingMessage)
    alertCastingFrame = alertCastingFrame + 1
  end
  
  if (alertCastingFrame == 5) then
    alertCasting = false
    alertCastingFrame = false
    alertCastingMessage = "..."
  end

end



function drawAlertRecording()

  if (alertRecording) then
    drawAlertWindow()
    drawAlertMessage(alertRecordingMessage)
    alertRecordingFrame = alertRecordingFrame + 1
  end
  
  if (alertRecordingFrame == 5) then
    alertRecording = false
    alertRecordingFrame = false
    alertRecordingMessage = "..."
  end

end



function drawAlertWindow()
  screen.rect(alertX, alertY, alertW, alertH)
  screen.level(screenH)
  screen.stroke()
  screen.rect(alertX, alertY, alertW - 1, alertH - 1)
  screen.level(0)
  screen.fill()
end



function drawAlertMessage(x)
  screen.move((alertX + (alertW / 2)), (alertY + (alertH / 2) + 2))
  screen.level(screenL)
  screen.text_center(x)
end



function drawTopMenu()

  screen.level(screenL)

  mlrs(0, 12, 40, 0)
  mlrs(44, 12, 40, 0)
  mlrs(88, 12, 40, 0)

  screen.level(screenH)
  screen.move(2, 8)
  screen.text(round(params:get("amp"), 2) .. " amp")
  screen.move(45, 8)
  screen.text(round(params:get("hz")) .. " hz")
  screen.move(89, 8)
  screen.text(drones[round(params:get("drone"))])

end



function drawClock()
  screen.level(screenL)
  screen.move(7, 64)
  screen.text(util.s_to_hms(recordingTime))
end



function drawPlayStop()

  screen.level(screenL)

  if playing == true then
    -- play
    mls(120, 59, 120, 64)
    mls(121, 60, 121, 63)
    mls(122, 61, 122, 62)
  else
    -- stop
    mls(120, 59, 120, 64)
    mls(121, 59, 121, 64)
    mls(122, 59, 122, 64)
    mls(123, 59, 123, 64)
  end

end



function drawRecording()

  screen.level(screenL)

  if recording then
    if (recordingFrame % 2) == 1 then
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

function drawUAP()
  
  luck = math.random(0, 7)

  if playing and (luck == 3) and (unidentifiedAerialPhenomenon == false) then
    unidentifiedAerialPhenomenon = true
    uapFrame = 1
  end
  
  if (unidentifiedAerialPhenomenon) then
    if uapFrame == 1 then
      mls(100, 18, 98, 20)
      uapFrame = 2
    elseif uapFrame == 2 then
      mls(100, 18, 90, 25)
      uapFrame = 3
    elseif uapFrame == 3 then
      mls(94, 22, 89, 26)
      uapFrame = 4
    elseif uapFrame == 4 then
      mls(88, 26, 86, 28)
      uapFrame = 5
    elseif uapFrame == 5 then
      mlrs(85, 30, 1, 0)
      unidentifiedAerialPhenomenon = false
      uapFrame = false
    end
  end
  
end



function drift()
  
  xCoin = math.random(0, 1)
  yCoin = math.random(0, 1)
  thisOrThat = math.random(0, 1)
  thatOrThis = math.random(0, 1)
  
  if thisOrThat == 0 then
    checkX = (xCoin * -1) + thisDriftX
  else
    checkX = xCoin + thisDriftX
  end
  
  if thatOrThis == 0 then
    checkY = (yCoin * -1) + thisDriftY
  else
    checkY = yCoin + thisDriftY
  end

  if (checkX > driftMaxX) then
    thisDriftX = driftMaxX
  elseif  (checkX < driftMinX) then
    thisDriftX = driftMinX
  else
    thisDriftX = checkX
  end
  
  if (checkY > driftMaxY) then
    thisDriftY = driftMaxY
  elseif  (checkY < driftMinY) then
    thisDriftY = driftMinY
  else
    thisDriftY = checkY
  end

end



function drawBirds()

  screen.level(screenL)

  birdFrame = frame % 3

  if playing then
    drift()
  end

  joeNowX = thisDriftX
  joeNowY = thisDriftY
  bethNowX = thisDriftX - 5
  bethNowY = thisDriftY + 5
  alexNowX = thisDriftX + 7
  alexNowY = thisDriftY + 4


  if birdFrame == 0 then
    -- joe
    mlrs(joeNowX, joeNowY, 2, 2)
    mlrs(joeNowX, joeNowY, -2, 2)
    -- beth
    mlrs(bethNowX, bethNowY, 2, -2)
    mlrs(bethNowX, bethNowY, -2, -2)
    -- alex
    mlrs(alexNowX, alexNowY, 2, 1)
    mlrs(alexNowX, alexNowY, -2, 1)
  end

  if birdFrame == 1 then
    -- joe
    mlrs(joeNowX, joeNowY, 2, 1)
    mlrs(joeNowX, joeNowY, -2, 1)
    -- beth
    mlrs(bethNowX, bethNowY, 2, 2)
    mlrs(bethNowX, bethNowY, -2, 2)
    -- alex
    mlrs(alexNowX, alexNowY, 2, -2)
    mlrs(alexNowX, alexNowY, -2, -2)
  end

  if birdFrame == 2 then
    -- joe
    mlrs(joeNowX, joeNowY, 2, -2)
    mlrs(joeNowX, joeNowY, -2, -2)
    -- beth
    mlrs(bethNowX, bethNowY, 2, 1)
    mlrs(bethNowX, bethNowY, -2, 1)
    -- alex
    mlrs(alexNowX, alexNowY, 2, 2)
    mlrs(alexNowX, alexNowY, -2, 2)
  end

end



function drawWind()

  if not playing then
    return
  end
  
  screen.level(screenL)

  windFrame1 = frame % 20
  windFrame2 = frame % 13

  if math.random(0, 1) == 1 then
    mlrs(windFrame1 + 80, 49, 1, 0)
  end

  if math.random(0, 2) ~= 0 then
    mlrs(windFrame2 + 10, 49, 1, 0)
  end

  if math.random(0, 3) ~= 0 then
    mlrs((windFrame1 * 2), 54, 1, 0)
  end

  if math.random(0, 2) ~= 1 then
    mlrs(((windFrame1 + 4) * 3), 54, 1, 0)
   end

  if math.random(0, 4) ~= 0 then
    mlrs(((windFrame1 + 2) * 5) + 28, 54, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs((windFrame2 * 2) + 48, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs(((windFrame1 + 6) * 4) + 57, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs(((windFrame2 + 2) * 10) + 57, 61, 1, 0)
  end

  if math.random(0, 1) == 1 then
    mlrs((((windFrame2 + 3) * 8) + 57), 61, 1, 0)
  end

end



function lightOne()
  mlrs(62, 25, 1, 1)
end



function lightTwo()
  mlrs(65, 17, 1, 0)
end



function lightThree()
  mlrs(69, 23, 1, 1)
end



function lightAll()
  lightOne()
  lightTwo()
  lightThree()
end



function flareOne(x)
  screen.circle(62, 25, x)
  screen.stroke()
end



function flareTwo(x)
  screen.circle(65, 17, x)
  screen.stroke()
end



function flareThree(x)
  screen.circle(69, 23, x)
  screen.stroke()
end



function drawLights()

  screen.level(screenL)

  lightFrame = frame % 9

  if lightFrame == 1 then
    lightAll()
  elseif lightFrame == 2 then
    lightTwo()
    flareTwo(2)
    lightThree()
  elseif lightFrame == 3 then
    flareTwo(3)
    lightAll()
  elseif lightFrame == 4 then
    flareOne(2)
    flareTwo(4)
    lightThree()
  elseif lightFrame == 5 then
    lightAll()
  elseif lightFrame == 6 then
    lightTwo()
  elseif lightFrame == 7 then
    lightOne()
    lightThree()
    flareThree(5)
  elseif lightFrame == 8 then
    lightAll()
    flareThree(3)
  elseif lightFrame == 9 then
    lightTwo()
  else
    lightAll()
  end

end



function drawLandscape()

  screen.level(screenL)

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