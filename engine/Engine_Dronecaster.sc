 Engine_Dronecaster : CroneEngine {
  var <synth;
  var <in;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
  
    SynthDef(\InJacks, {
      arg out;
      var sig_;
      sig_ = SoundIn.ar([0,1]);
      Out.ar(out, sig_);
    }).add;
  
    SynthDef(\Sine, {
      arg out, hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
      var amp_, hz_;
      amp_ = Lag.ar(K2A.ar(amp), amplag);
      hz_ = Lag.ar(K2A.ar(hz), hzlag);
      Out.ar(out, (SinOsc.ar(hz_) * amp_).dup);
    }).add;
    
    context.server.sync;
    
    //synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
    in = Synth.new(\InJacks, [\out, context.out_a], context.xg);
    
    this.addCommand("hz", "f", { arg msg;
      synth.set(\hz, msg[1]);
    });
    
    this.addCommand("amp", "f", { arg msg;
      synth.set(\amp, msg[1]);
    });

    this.addCommand("drone", "s", { arg msg;
      msg[1].postln;
    });
    
    this.addCommand("stop", "i", { arg msg;
        synth.free;
    });
    
    this.addCommand("start", "i", { arg msg;
    //  synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
    });
    
    this.addCommand("injack", "s", { arg msg;
      in = Synth.new(\InJacks, [\out, context.out_b], context.xg);
    });
   
  }

  free {
    synth.free;
  }
  
}