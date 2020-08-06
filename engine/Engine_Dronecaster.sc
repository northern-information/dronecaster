 Engine_Dronecaster : CroneEngine {
  var <synth;
  var drones;
  var hz = 55, amp = 0.4;
  // var <in;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var baseDronePath = "/home/we/dust/code/dronecaster/engine/drones";
    var luaOsc = NetAddr("localhost", 10111);

    drones = PathName.new(baseDronePath).entries.collect({|e| 
      var name = e.fileNameWithoutExtension;
      ("sending name: " ++ name).postln;
      luaOsc.sendMsg("/add_drone", name);
      e.fileNameWithoutExtension -> e.fullPath.load;
    });
    drones.postln;
    drones = Dictionary.with(*drones);

    // SynthDef(\InJacks, {
    //   arg out;
    //   var sig_;
    //   sig_ = SoundIn.ar([0,1]);
    //   Out.ar(out, sig_);
    // }).add;

    context.server.sync;
    
    // synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
    // synth = Synth.new(\Zion, [\out, context.out_b], context.xg);
    // in = Synth.new(\InJacks, [\out, context.out_a], context.xg);
    
    this.addCommand("hz", "f", { arg msg;
      hz = msg[1];
      if (synth != nil, { synth.set(\hz, hz) });
    });
    
    this.addCommand("amp", "f", { arg msg;
      amp = msg[1];
      if (synth != nil, { synth.set(\amp, amp) });
    });
    
    this.addCommand("stop", "i", { arg msg;
        synth.free;
    });
    
    this.addCommand("start", "s", { arg msg; 
      var drone, droneName;

      if (synth != nil, { synth.free });  // Unload any playing synth
      droneName = msg[1].asString;
      droneName.postln;
      drone = drones[droneName];

      if (drone != nil, {
        synth = drone.play(context.xg, context.out_b, args: [hz: hz, amp: amp]);
      });
    });
    
    // this.addCommand("injack", "s", { arg msg;
    //   in = Synth.new(\InJacks, [\out, context.out_b], context.xg);
    // });
   
  }

  free {
    synth.free;
  }
  
}
