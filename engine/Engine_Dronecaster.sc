// "kernel" class, norns-agnostic
Dronecaster {
	var <drones;
	// use a NodeProxy to crossfade drones without boilerplate
	var <proxy;
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
		drones = PathName.new(baseDronePath).entries.collect({|e|
			var name = e.fileNameWithoutExtension;
			e.fileNameWithoutExtension -> e.fullPath.load
		});

		drones.postln;
		drones = Dictionary.with(*drones);

		proxy = NodeProxy.audio(server, 2);

		proxy.play;

		// these things could be parameterized
		proxy.fadeTime = 8.0;
		proxy.lag(\amp, 1.0);
		proxy.lag(\hz, 1.0);

		recordBus = Bus.audio(server, 2);
		inJacks = { Out.ar(recordBus, SoundIn.ar([0, 1])) }.play;
		recorder = Recorder.new(server);
	}

	start { arg name;
		if (proxy.isPlaying.not, { proxy.play; });
		if (drones.keys.includes(name), {
			proxy.source = drones[name];
		}, {
			postln("dronecaster does not know this drone: " ++ name);
		});
	}

	setAmp { arg value;
		amp = value; proxy.set(\amp, amp);
	}

	setHz{ arg value;
		amp = value; proxy.set(\hz, hz);
	}

	stop {
		proxy.free;
	}

	record { arg path;
		recorder.record(path.asString, recordBus, 2);
	}

	free {
		inJacks.free;
		recorder.free;
		proxy.clear;
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
			caster.proxy.fadeTime = msg[1].asFloat;
		});

		this.addCommand("stop", "i", { arg msg;
			caster.stop;
		});

		this.addCommand("start", "s", { arg msg;
			caster.setDrone(msg[1].asString);
		});

		this.addCommand("record_start", "s", { arg msg;
			caster.record(msg[1]);
		});

		this.addCommand("record_stop", "i", { arg msg;
			// fugly
			caster.recorder.stopRecording;
		});
	}

	free {
		caster.free;
	}
}