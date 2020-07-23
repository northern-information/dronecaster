 Engine_Dronecaster : CroneEngine {
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
	
		SynthDef(\Sine, {
      arg out, hz=440, amp=0.5, amplag=0.02, hzlag=0.01;
      var drone_, amp_, hz_;
      amp_ = Lag.ar(K2A.ar(amp), amplag);
      hz_ = Lag.ar(K2A.ar(hz), hzlag);
      Out.ar(out, (SinOsc.ar(hz_) * amp_).dup);
    }).add;
    
    SynthDef(\Eno, {
      arg out, hz=440, amp=0.5, amplag=0.02, hzlag=0.01;
      var drone_, amp_, hz_;
      amp_ = Lag.ar(K2A.ar(amp), amplag);
      hz_ = Lag.ar(K2A.ar(hz), hzlag);
      Out.ar(out, (LFTri.ar(hz_) * amp_).dup);
    }).add;
    
    context.server.sync;
    
    synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
    
    this.addCommand("drone", "i", { arg msg;
      synth.set(\drone, msg[1]);
    });
    
    this.addCommand("hz", "f", { arg msg;
      synth.set(\hz, msg[1]);
    });
    
    this.addCommand("amp", "f", { arg msg;
      synth.set(\amp, msg[1]);
    });
    
    this.addCommand("startStop", "f", { arg msg;
      if (msg[1] == 0, {
        synth.free;
      }, {
        if (synth.notNil, {
          synth = Synth.new(\Sine, [\out, context.out_b], context.xg);
        });
      });
    });	
		
	}

	free {
		synth.free;
	}
	
}

