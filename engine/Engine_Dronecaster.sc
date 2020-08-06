 Engine_Dronecaster : CroneEngine {
  var synth;
  var drones;
  var droneGroup;
  var inJacks, recordBus, recorder;
  var hz = 55, amp = 0.4;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var baseDronePath = "/home/we/dust/code/dronecaster/engine/drones";
    var luaOsc = NetAddr("localhost", 10111);

    droneGroup = Group.new(context.xg);

    drones = PathName.new(baseDronePath).entries.collect({|e| 
      var name = e.fileNameWithoutExtension;
      ("sending name: " ++ name).postln;
      luaOsc.sendMsg("/add_drone", name);
      e.fileNameWithoutExtension -> e.fullPath.load;
    });
    drones.postln;
    drones = Dictionary.with(*drones);

    recordBus = Bus.audio(Crone.server, 2);
    // Leave it running silently - it's low-CPU & there's less juggling
    inJacks = { Out.ar(recordBus, SoundIn.ar([0, 1])) }.play;
    recorder = Recorder.new(Crone.server);

    context.server.sync;
    
    this.addCommand("hz", "f", { arg msg;
      hz = msg[1];
      if (synth != nil, { synth.set(\hz, hz) });
    });
    
    this.addCommand("amp", "f", { arg msg;
      amp = msg[1];
      if (synth != nil, { synth.set(\amp, amp) });
    });
    
    this.addCommand("stop", "i", { arg msg;
        droneGroup.freeAll;
    });
    
    this.addCommand("start", "s", { arg msg; 
      var drone, droneName;

      droneGroup.freeAll; // Unload any playing synth
      droneName = msg[1].asString;
      droneName.postln;
      drone = drones[droneName];

      if (drone != nil, {
        synth = drone.play(droneGroup, context.out_b, args: [hz: hz, amp: amp]);
      });
    });

    this.addCommand("record_start", "s", { arg msg;
      var path = msg[1].asString;
      recorder.record(path, recordBus, 2);
    });

    this.addCommand("record_stop", "i", { arg msg;
      recorder.stopRecording;
    });
  }

  free {
    droneGroup.freeAll;
    inJacks.free;
  }
}
