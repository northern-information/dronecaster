-- init
--------------------------------------------------------------------------------

local midicontrol =  {}

function midicontrol.init()
  -- midi vars
  midi_enabled = 0
  midi_devices = {}
  midi_device = 0
  midi_channel = 0
  midi_amp_control = 1
  midi_transport = 0
  midi_amp_cc = 0
  midi_drone_cc = 0
end

-- midi functions
--------------------------------------------------------------------------------

function midicontrol.build_midi_device_list()
  midi_devices = {}
  for i = 1,#midi.vports do
    local long_name = midi.vports[i].name
    table.insert(midi_devices,i..": "..long_name)
  end
end

function midicontrol.midi_event(data)
  -- global midi setting
  if midi_enabled == 0 then
    return
  end
  msg = midi.to_msg(data)
  -- filter channel
  if msg.ch == midi_channel then
    --msg debug print
    -- if msg.type ~= "clock" then tab.print(msg) end
    --note message
    if msg.type == "note_on" then
      params:set("note",msg.note)
      -- amp control
      if midi_amp_control == 2 then
        amp = math.min(msg.vel/100, 1)
      end
      if midi_amp_control == 3 then
        amp = math.min(msg.key_pressure/100, 1)
      end
      if midi_amp_control ~= 1 then
        params:set("amp",amp)
      end
    end
    --cc message
    if msg.type == "cc" then
      if msg.cc == midi_amp_cc then
        params:set("amp", (msg.val/127))
      end
      if msg.cc == midi_drone_cc then
        minval = math.min(msg.val, #drones)
        params:set("drone", minval)
      end
    end
    -- program change message
    if msg.type == "program_change" then
      minval = math.min(msg.val, #drones)
      params:set("drone", minval)
    end
  end
  -- transport
  if midi_transport == 3 then
    return
  end
  if msg.type == "start" then
    play_drone()
  end
  if msg.type == "stop" and midi_transport ~= 2 then
    engine.stop(1)
  end
end

function midicontrol.build_midi_params()
  midicontrol.build_midi_device_list()
  params:add_separator("midi")
  params:add_binary("midi_enabled", "enable midi", "toggle", 1)
  params:set_action("midi_enabled",function(x)
    if x == 0 then
      midi_enabled = 0
      params:hide("midi_device")
      params:hide("midi_in_channel")
      params:hide("midi_amp_control")
      params:hide("midi_transport")
      params:hide("midi_amp_cc")
      params:hide("midi_drone_cc")
    elseif x == 1 then
      midi_enabled = 1
      params:show("midi_device")
      params:show("midi_in_channel")
      params:show("midi_amp_control")
      params:show("midi_transport")
      params:show("midi_amp_cc")
      params:show("midi_drone_cc")
    end
    _menu.rebuild_params()
  end)
  params:add{type = "option", id = "midi_device", name = "device",
    options = midi_devices, default = 1,
    action = function(value) 
      midi_device = midi.connect(value)
      midi_device.event = midicontrol.midi_event
      end}
  params:add{type = "number", id = "midi_in_channel", name = "channel",
    min = 1, max = 16, default = 1,
    action = function(value)
      midi_channel = value
    end}
  params:add{type = "option", id = "midi_amp_control", name = "amp note ctrl",
    options = {"none","velocity","key pressure"}, default = 1,
    action = function(value) 
      midi_amp_control = value
    end}
  params:add{type = "option", id = "midi_transport", name = "transport",
    options = {"all","ignore stop","none"}, default = 1,
    action = function(value) 
      midi_transport = value
    end} 
  params:add_number("midi_amp_cc", "amp cc", 0, 127, 76)
  params:set_action("midi_amp_cc",function(v)
			      midi_amp_cc = v
	end)
	params:add_number("midi_drone_cc", "drone cc", 0, 127, 75)
  params:set_action("midi_drone_cc",function(v)
			      midi_drone_cc = v
  end)
  params:bang()
end


return midicontrol