-- k1: exit  e1: drone
--
--
--       e2: hz          e3: amp
--
--    k2: record      k3: cast
--
--
-- ................................................................
-- contributors:
-- "Mt. Zion" by @license
-- "Supersaw" by @cfd90
-- "Mt. Lion" by @license
-- ................................................................
-- borrowings:
-- levels/fx parameter code by
-- @21echoes via pedalboard
-- ................................................................
-- l.llllllll.co/dronecaster
-- <3 @tyleretters & @license
-- v0.0.4-beta

-- engines & includes
--------------------------------------------------------------------------------
engine.name = "Dronecaster"
draw = include "lib/draw"

-- variables
--------------------------------------------------------------------------------
local initital_monitor_level
local initital_reverb_onoff

filename_prefix = "dronecaster_"
save_path = _path.audio .. "dronecaster/"
amp_default = .4
hz_default = 55
drone_default = 1
drones = {}
recording = false
playing = false
counter = metro.init()
recording_time = 0
playing_frame = 1
recording_frame = 1
messages = {}
messages["empty"] = "..."
messages["start_recording"] = "Recording..."
messages["stop_recording"] = "...saved."
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

  initital_monitor_level = params:get('monitor_level')
  params:set('monitor_level', -math.huge)
  initital_reverb_onoff = params:get('reverb')
  params:set('reverb', 1) -- 1 is OFF

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
  params:set_action("amp", engine.amp)
  params:add_control("hz", "hz", controlspec.new(0, 20000, "lin", 0, hz_default, "hz"))
  params:set_action("hz", engine.hz)
  params:add_control("drone","drone",controlspec.new(1, #drones, "lin", 0, drone_default, "drone"))
  params:set_action("drone", play_drone)
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

-- encs & keys
--------------------------------------------------------------------------------
function enc(n,d)
  if n == 1 then
    params:set("drone", util.clamp(params:get("drone") + d, 1, #drones))
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
      local record_path = make_filename()
      recording_time = 0
      alert["recording_message"] = messages["start_recording"]
      print("recording to file " .. record_path)
      engine.record_start(record_path)
    else
      alert["recording_message"] = messages["stop_recording"]
      engine.record_stop(1)
    end
  elseif n == 3 and z == 1 then
    playing = not playing
    alert["casting"] = true
    alert["casting_frame"] = 1
    if playing == true then
      play_drone()
      alert["casting_message"] = messages["start_casting"]
    else
      engine.stop(1)
      alert["casting_message"] = messages["stop_casting"]
    end
  end
  redraw()
end

function play_drone()
    local droneIndex = params:get("drone")
    playing = true
    if droneIndex > 0 and droneIndex <= #drones then
      engine.start(drones[droneIndex])
    end
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

function osc_in(path, msg)
  if path == "/add_drone" then
    print("adding drone" .. msg[1])
    table.insert(drones, msg[1])
  end
end

function cleanup()
  -- Put user's audio settings back where they were
  params:set('monitor_level', initital_monitor_level)
  params:set('reverb', initital_reverb_onoff)
  engine.record_stop(1)
end

osc.event = osc_in -- should probably go in init? race conditions tho?
