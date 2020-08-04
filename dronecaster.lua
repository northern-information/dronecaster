-- k1: exit  e1: drone
--
--
--       e2: hz          e3: amp
--
--    k2: record      k3: cast
--
--
-- ........................................
-- contributors:
-- "Mt. Zion" by @license
-- "Mt. Lion" by @license
-- ........................................
-- l.llllllll.co/dronecaster
-- <3 @tyleretters
-- v0.0.1 ALPHA

-- engines & includes
--------------------------------------------------------------------------------
engine.name = "Dronecaster"
draw = include "lib/draw"
record = include "lib/record"

-- variables
--------------------------------------------------------------------------------
filename_prefix = "dronecaster_"
save_path = _path.audio .. "dronecaster/"
amp_default = 1.0
hz_default = 55
drone_default = 1
drones = {"Mt. Zion", "Mt. Lion", "Sine"}
recording = false
playing = false
filename = filename_prefix
counter = metro.init()
recording_time = 0
playing_frame = 1
recording_frame = 1
messages = {}
messages["empty"] = "..."
messages["start_recording"] = "Recording broken..."
messages["stop_recording"] = "...still broken."
messages["start_casting"] = "Casting drone..."
messages["stop_casting"] = "Cast halted."
alert = {}
alert["casting_message"] = messages["empty"]
alert["casting"] = false
alert["casting_frame"] = 0
alert["recording_message"] = messages["empty"]
alert["recording"] = false
alert["recording_frame"] = 0

-- init & core
--------------------------------------------------------------------------------
function init()
  audio:pitch_off()
  draw.init()
  if util.file_exists(save_path) == false then
    util.make_dir(save_path)
  end
  counter.time = 1
  counter.count = -1
  counter.play = 1
  counter.event = the_sands_of_time
  counter:start()
  params:add_control("amp", "amp", controlspec.new(0, 1, "amp", 0, amp_default, "amp"))
  params:set_action("amp", function(x) update_amp(x) end)
  params:add_control("hz", "hz", controlspec.new(0, 20000, "lin", 0, hz_default, "hz"))
  params:set_action("hz", function(x) update_hz(x) end)
  params:add_control("drone","drone",controlspec.new(1, #drones, "lin", 0, drone_default, "drone"))
  params:set_action("drone", function(x) update_drone(x) end)
  engine.stop(1) -- todo: how to not have the engine automatically start?
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
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
  pf = playing_frame
  rf = recording_time
  d = drones[round(params:get("drone"))]
  h = round(params:get("hz")) .. " hz"
  a = round(params:get("amp"), 2) .. " amp"
  p = playing
  draw.birds(pf)
  draw.wind(pf)
  draw.lights(pf)
  draw.uap(pf)
  draw.landscape()
  draw.top_menu(d, h, a)
  draw.clock(rf)
  draw.play_stop(p)
  if (alert["recording"]) then
    alert = draw.alert_recording(alert, messages)
  end
  if (alert["casting"]) then
    alert = draw.alert_casting(alert, messages)
  end
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
    stop_drone()
  end
  -- print(round(params:get("drone"))
  -- engine.drone(round(params:get("drone")))
  play_drone()
end

-- encs & keys
--------------------------------------------------------------------------------
function enc(n,d)
  if n == 1 then
    params:set("drone", util.clamp(params:get("drone") + d, 1, #drones))
    -- params:delta("drone", d)
  elseif n == 2 then
    params:delta("hz", d * .001)
  elseif n == 3 then
    params:delta("amp", d * .1)
  end
  redraw()
end

function key(n, z)
  if n == 2 and z == 1 then
    recording = not recording
    alert["recording"] = true
    alert["recording_frame"] = 1
    if recording == true then
      recording_time = 0
      alert["recording_message"] = messages["start_recording"]
      -- engine.record_start()
    else
      alert["recording_message"] = messages["stop_recording"]
      -- engine.record_stop(make_filename())
    end
  elseif n == 3 and z == 1 then
    playing = not playing
    alert["casting"] = true
    alert["casting_frame"] = 1
    if playing == true then
      play_drone()
      alert["casting_message"] = messages["start_casting"]
    else
      stop_drone()
      alert["casting_message"] = messages["stop_casting"]
    end
  end
  redraw()
end

function play_drone()
    if params:get("drone") == 1 then
      engine.start_zion(1)
    elseif params:get("drone") == 2 then
      engine.start_lion(1)
    else
      engine.start_sine(1)
    end
    engine.amp(params:get("amp"))
    engine.hz(params:get("hz"))
end

function stop_drone()
  engine.stop(1)
end

-- utils
--------------------------------------------------------------------------------
function make_filename()
  return save_path .. filename_prefix .. os.date("%Y_%m_%d_%H_%M_%S") .. ".wav"
end

function round(num, places)
  if places and places > 0 then
    mult = 10 ^ places
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end