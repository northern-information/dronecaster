// "kernel" class, norns-agnostic
Dronecaster {
	var <drones;
	var <socket; // a Dronecaster_SynthSocket
	var inJacks, recordBus, <recorder;
	var amp=0.4, hz=55;

	*new { arg server, baseDronePath;
		^super.new.init(server, baseDronePath)
	}

	init { arg server, baseDronePath;
		socket = DroneCaster_SynthSocket.new(server, 0, [\hz, \amp]);
		
		if (baseDronePath == nil, {
			baseDronePath = PathName(Document.current.path).pathOnly ++ "engine/drones";
		});
		postln("compiling drones in " ++ baseDronePath ++ "...");

		drones = Dictionary.new;
		PathName.new(baseDronePath).entries.do({|e|
			var name = e.fileNameWithoutExtension;
			var def = socket.wrapDef(e.fullPath.load, name, server);
			if (def.notNil, { drones[name] = def; });
		});
		drones.postln;


		recordBus = Bus.audio(server, 2);
		inJacks = { Out.ar(recordBus, SoundIn.ar([0, 1])) }.play;
		recorder = Recorder.new(server);
	}

	start { arg name;
		postln("start requested for name: " ++ name);
		if (drones.keys.includes(name), {
			socket.setSource(drones[name]);
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


		this.addCommand("initialize", "ff", { arg msg;
			if (caster==nil,{
				//  :/
				caster = Dronecaster.new(context.server, "/home/we/dust/code/dronecaster/engine/drones" );
				// caster.drones.keys.do({ arg name;
				// 	("sending name: " ++ name).postln;
				// 	luaOscAddr.sendMsg("/add_drone", name);
				// });
				caster.setHz(msg[1].asFloat);
				caster.setAmp(msg[2].asFloat);
				luaOscAddr.sendMsg("/drones_loaded",1);
			});
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
