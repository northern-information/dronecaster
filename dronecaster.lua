-- DRONECASTER
--
-- k1: exit  e1: amp
--
--            e2: hz    e3: drone
--         k2: record  k3: cast
--

engine.name = 'Dronecaster'

-- variables
--------------------------------------------------------------------------------

-- sounds
local drones = {'Sine', 'Eno', 'Belong', 'Hecker', 'Gristle', 'Starlids', 'GY!BE', 'V/Vm', 'Canada'}
local ampDefault = 0.02
local recording = false

-- ui
local recordKey = false
local castKey = false

-- draw
local screenO = 0
local screenL = 5
local screenM = 10
local screenH = 15

-- time
local seconds = 0
local counter = metro.init()

-- animation
local frame = 1
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

  screen.clear()
  screen.aa(0)
  screen.level(screenH)
  screen.font_face(0)
  screen.font_size(8)

  counter.time = 1
  counter.count = -1
  counter.event = theSandsOfTime
  counter.play = 0

  params:add_control("amp", "amp", controlspec.new(0, 1, 'amp', 0, ampDefault, 'amp'))
  params:set_action("amp", function(x) updateAmp(x) end)

  params:add_control("hz", "hz", controlspec.new(0, 20000, 'lin', 0, 440, 'hz'))
  params:set_action("hz", function(x) updateHz(x) end)

  params:add_control("drone","drone",controlspec.new(1, 9, 'lin', 0, 1, 'drone'))
  params:set_action("drone", function(x) updateDrone(x) end)

  -- dev
  counter:start()
  counter.play = 1

end



function theSandsOfTime(c)
  seconds = c
  frame = frame + 1
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
  drawTape()
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



function key(n,z)

  -- k2 record
  if n == 2 and z == 1 then
    if recording == true then
      recording = false
    else
      recording = true
    end
  end

  -- k3 cast
  if n == 3 and z == 1 then
    if counter.play == 1 then
      counter:stop()
      counter.play = 0
      frame = 1
      engine.startStop(0)
    else
      counter:start()
      counter.play = 1
      units = 0
      engine.startStop(1)
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
  screen.move(89, 64)
  screen.text(util.s_to_hms(seconds))
end



function drawPlayStop()

  screen.level(screenL)

  if counter.play == 1 then
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



function drawTape()
  
  -- reels
  screen.circle(3, 61, 3)
  screen.stroke()
  screen.circle(13, 61, 3)
  screen.stroke()
  mls(3, 61, 1, 61)
  mls(13, 61, 13, 64)
  
  -- tape
  mlrs(6, 59, 2, 0)
  mlrs(9, 59, 2, 0)
  
  
  if recording then
    -- todo
  else
    
  end
end


-- everything beyond is bird, tower, and wind animations...
--------------------------------------------------------------------------------

function drawUAP()
  
  luck = math.random(0, 7)

  if (luck == 3) and (unidentifiedAerialPhenomenon == false) then
    unidentifiedAerialPhenomenon = true
    uapFrame = 1
  end
  
  if (unidentifiedAerialPhenomenon) then
    if uapFrame == 1 then
      screen.move(100, 18)
      screen.line(98, 20)
      screen.stroke()
      uapFrame = 2
    elseif uapFrame == 2 then
      screen.move(100, 18)
      screen.line(90, 25)
      screen.stroke()
      uapFrame = 3
    elseif uapFrame == 3 then
      screen.move(94, 22)
      screen.line(89, 26)
      screen.stroke()
      uapFrame = 4
    elseif uapFrame == 4 then
      screen.move(88, 26)
      screen.line(86, 28)
      screen.stroke()
      uapFrame = 5
    elseif uapFrame == 5 then
      screen.move(85, 30)
      screen.line_rel(1, 0)
      screen.stroke()
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

  drift()

  joeNowX = thisDriftX
  joeNowY = thisDriftY
  bethNowX = thisDriftX - 5
  bethNowY = thisDriftY + 5
  alexNowX = thisDriftX + 7
  alexNowY = thisDriftY + 4


  if birdFrame == 0 then
    -- joe
    screen.move(joeNowX, joeNowY)
    screen.line_rel(2, 2)
    screen.stroke()
    screen.move(joeNowX, joeNowY)
    screen.line_rel(-2, 2)
    screen.stroke()
    -- beth
    screen.move(bethNowX, bethNowY)
    screen.line_rel(2, -2)
    screen.stroke()
    screen.move(bethNowX, bethNowY)
    screen.line_rel(-2, -2)
    screen.stroke()
    -- alex
    screen.move(alexNowX, alexNowY)
    screen.line_rel(2, 1)
    screen.stroke()
    screen.move(alexNowX, alexNowY)
    screen.line_rel(-2, 1)
    screen.stroke()
  end

  if birdFrame == 1 then
    -- joe
    screen.move(joeNowX, joeNowY)
    screen.line_rel(2, 1)
    screen.stroke()
    screen.move(joeNowX, joeNowY)
    screen.line_rel(-2, 1)
    screen.stroke()
    -- beth
    screen.move(bethNowX, bethNowY)
    screen.line_rel(2, 2)
    screen.stroke()
    screen.move(bethNowX, bethNowY)
    screen.line_rel(-2, 2)
    screen.stroke()
    -- alex
    screen.move(alexNowX, alexNowY)
    screen.line_rel(2, -2)
    screen.stroke()
    screen.move(alexNowX, alexNowY)
    screen.line_rel(-2, -2)
    screen.stroke()
  end

  if birdFrame == 2 then
    -- joe
    screen.move(joeNowX, joeNowY)
    screen.line_rel(2, -2)
    screen.stroke()
    screen.move(joeNowX, joeNowY)
    screen.line_rel(-2, -2)
    screen.stroke()
    -- beth
    screen.move(bethNowX, bethNowY)
    screen.line_rel(2, 1)
    screen.stroke()
    screen.move(bethNowX, bethNowY)
    screen.line_rel(-2, 1)
    screen.stroke()
    -- alex
    screen.move(alexNowX, alexNowY)
    screen.line_rel(2, 2)
    screen.stroke()
    screen.move(alexNowX, alexNowY)
    screen.line_rel(-2, 2)
    screen.stroke()
  end

end



function drawWind()

  screen.level(screenL)

  windFrame1 = frame % 20
  windFrame2 = frame % 13

  if math.random(0, 1) == 1 then
    screen.move(windFrame1 + 80, 49)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 2) ~= 0 then
    screen.move(windFrame2 + 10, 49)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 3) ~= 0 then
    screen.move((windFrame1 * 2), 54)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 2) ~= 1 then
    screen.move(((windFrame1 + 4) * 3), 54)
    screen.line_rel(1, 0)
    screen.stroke()
   end

  if math.random(0, 4) ~= 0 then
    screen.move(((windFrame1 + 2) * 5) + 28, 54)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 1) == 1 then
    screen.move((windFrame2 * 2) + 48, 61)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 1) == 1 then
    screen.move(((windFrame1 + 6) * 4) + 57, 61)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 1) == 1 then
    screen.move(((windFrame2 + 2) * 10) + 57, 61)
    screen.line_rel(1, 0)
    screen.stroke()
  end

  if math.random(0, 1) == 1 then
    screen.move(((windFrame2 + 3) * 8) + 57, 61)
    screen.line_rel(1, 0)
    screen.stroke()
  end

end



function lightOne()
  screen.move(62, 25)
  screen.line_rel(1, 1)
  screen.stroke()
end



function lightTwo()
  screen.move(65, 17)
  screen.line_rel(1, 0)
  screen.stroke()
end



function lightThree()
  screen.move(69, 23)
  screen.line_rel(1, 1)
  screen.stroke()
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
  screen.move(62, 52)
  screen.line(66, 20)
  screen.stroke()
  screen.move(70, 53)
  screen.line(66, 20)
  screen.stroke()

  -- antenna horizontals
  screen.move(64, 34)
  screen.line_rel(3, 0)
  screen.stroke()
  screen.move(64, 39)
  screen.line_rel(3, 0)
  screen.stroke()
  screen.move(64, 45)
  screen.line_rel(3, 0)
  screen.stroke()

  -- antenna supports
  screen.move(62, 52)
  screen.line(70, 44)
  screen.stroke()
  screen.move(70, 52)
  screen.line(62, 44)
  screen.stroke()
  screen.move(70, 44)
  screen.line(63, 37)
  screen.stroke()

  -- antenna details
  screen.move(65, 19)
  screen.line_rel(2, 0)
  screen.stroke()
  screen.move(62, 30)
  screen.line_rel(2,0)
  screen.stroke()
  screen.move(67, 28)
  screen.line_rel(2, 0)
  screen.stroke()
  screen.move(62, 27)
  screen.line_rel(1, 2)
  screen.stroke()
  screen.move(69, 25)
  screen.line_rel(1, 2)
  screen.stroke()

  -- distant horizon
  screen.move(0,48)
  screen.line_rel(60, 0)
  screen.stroke()
  screen.move(72,48)
  screen.line_rel(50, 0)
  screen.stroke()

  -- second horizon
  screen.move(1, 50)
  screen.line_rel(1, 0)
  screen.stroke()
  screen.move(4, 50)
  screen.line_rel(40, 0)
  screen.stroke()
  screen.move(46, 50)
  screen.line_rel(9, 0)
  screen.stroke()
  screen.move(57, 50)
  screen.line_rel(1, 0)
  screen.stroke()
  screen.move(74, 50)
  screen.line_rel(40, 0)
  screen.stroke()
  screen.move(116, 50)
  screen.line_rel(2, 0)
  screen.stroke()

  -- third horizon
  screen.move(5, 55)
  screen.line_rel(3, 0)
  screen.stroke()
  screen.move(10, 55)
  screen.line_rel(40, 0)
  screen.stroke()
  screen.move(55, 55)
  screen.line_rel(20, 0)
  screen.stroke()
  screen.move(80, 55)
  screen.line_rel(41, 0)
  screen.stroke()

  -- closest horizon
  screen.move(23, 62)
  screen.line_rel(62, 0)
  screen.stroke()

end