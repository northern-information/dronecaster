local record = {}

function record.init() end

function record.start()
  softcut.enable(1, 1)
  softcut.buffer(1, 1)
  softcut.level(1, 1.0)
  softcut.buffer_clear()
  audio.level_adc_cut(1)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(2, 1, 1.0)
  softcut.rec_level(1, 1)
  softcut.pre_level(1, 0)
  softcut.position(1, 0)
  softcut.play(1, 1)
  softcut.rec(1, 1)
end

function record.stop(filename)
  softcut.play(1,0)
  softcut.rec(1, 0)
  softcut.buffer_write_stereo(filename, 0, -1)
end

return record
