 Engine_Dronecaster : CroneEngine {
  var <synth;
  var drones;
  // var <in;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // TODO:
    // [ ] Get path of this file
    // [ ] Get dir from path
    // [ ] Get all files in subdir "drones"
    // [ ] Create dict of name -> implementation (from contents)
    // [ ] Shake hands via OSC if necessary (race condition?)
    // [ ] Notify Lua of names via OSC

    // SynthDef(\InJacks, {
    //   arg out;
    //   var sig_;
    //   sig_ = SoundIn.ar([0,1]);
    //   Out.ar(out, sig_);
    // }).add;

    // TODO: Lookup by string (name).
    // Meanwhile, order below *must* match drones var in Lua!
    drones = [
      /*"Mt. Zion" -> ,

      "Sine" -> , 

      "Supersaw" -> , 

      "Mt. Lion" -> , */
    ];
  
    context.server.sync;
    
    // synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
    // synth = Synth.new(\Zion, [\out, context.out_b], context.xg);
    // in = Synth.new(\InJacks, [\out, context.out_a], context.xg);
    
    this.addCommand("hz", "f", { arg msg;
      synth.set(\hz, msg[1]);
    });
    
    this.addCommand("amp", "f", { arg msg;
      synth.set(\amp, msg[1]);
    });
    
    this.addCommand("stop", "i", { arg msg;
        synth.free;
    });
    
    this.addCommand("start_drone", "i", { arg msg; 
      if (synth != nil, { synth.free });  // Unload any playing synth

      if (msg[1] < drones.size, {
        synth = drones[msg[1]].value.play(context.xg, context.out_b);
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
