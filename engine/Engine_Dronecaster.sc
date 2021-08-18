// "kernel" class, norns-agnostic
Dronecaster {
	var <drones;
	var <socket; // a Dronecaster_SynthSocket
	var inJacks, recordBus, <recorder;
	var amp, hz;

	*new { arg server, baseDronePath;
		^super.new.init(server, baseDronePath)
	}

	init { arg server, baseDronePath;
		if (baseDronePath == nil, {
			baseDronePath = PathName(Document.current.path).pathOnly ++ "engine/drones";
		});
		postln("searching for drones at: " ++ baseDronePath);

		drones = Dictionary.new;
		PathName.new(baseDronePath).entries.do({|e|
			var name = e.fileNameWithoutExtension;
			postln('loading source: '++e.fullPath);
			drones[name] = e.fullPath.load
		});
		drones.postln;

		socket = Dronecaster_SynthSocket.new(server, 0, [\amp, \hz]);

		recordBus = Bus.audio(server, 2);
		inJacks = { Out.ar(recordBus, SoundIn.ar([0, 1])) }.play;
		recorder = Recorder.new(server);
	}

	start { arg name;
		if (drones.keys.includes(name), {
			postln('setting drone: '++name);
			socket.setSource({
			    arg hz=this.hz, amp=this.amp, amplag=0.02, hzlag=0.01;
			    var amp_, hz_;
			    amp_ = Lag.ar(K2A.ar(amp), amplag);
			    hz_ = Lag.ar(K2A.ar(hz), hzlag);
			    drones[name].value(hz:hz_,amp:amp_);
			});
		}, {
			postln("dronecaster does not know this drone: " ++ name);
		});
	}

	setAmp { arg value;
		amp = value;
		socket.setControl(\amp, amp);
	}

	setHz { arg value;
		hz = value;
		socket.setControl(\hz, hz);
	}

	stop {
		socket.stop;
	}

	record { arg path;
		recorder.record(path.asString, recordBus, 2);
	}

	free {
		inJacks.free;
		recorder.free;
		socket.free;
	}
}

// norns glue
Engine_Dronecaster : CroneEngine {
	classvar luaOscPort = 10111;

	var caster; // a Dronecaster
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		var luaOscAddr = NetAddr("localhost", luaOscPort);

		//  :/
		caster = Dronecaster.new(context.server, "/home/we/dust/code/dronecaster/engine/drones" );

		caster.drones.keys.do({ arg name;
			("sending name: " ++ name).postln;
			luaOscAddr.sendMsg("/add_drone", name);
		});

		this.addCommand("hz", "f", { arg msg;
			caster.setHz(msg[1].asFloat);
		});

		this.addCommand("amp", "f", { arg msg;
			caster.setAmp(msg[1].asFloat);
		});

		this.addCommand("fade", "f", { arg msg;
			caster.socket.setFadeTime(msg[1].asFloat);
		});

		this.addCommand("stop", "i", { arg msg;
			caster.stop(msg[1]);
		});

		this.addCommand("start", "s", { arg msg;
			caster.start(msg[1].asString);
		});

		this.addCommand("record_start", "s", { arg msg;
			caster.record(msg[1]);
		});

		this.addCommand("record_stop", "i", { arg msg;
			caster.recorder.stopRecording;
		});
	}

	free {
		caster.free;
	}
}
