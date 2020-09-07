// a primitive and limited analog to `NodeProxy`,
// which just crossfades between two stereo synth functions.
// motivation is to limit the number of active synths during crossfades,
// by specifying a shallow queuing behavior.
// @zebra

Dronecaster_SynthSocket {
	var server;          // a Server!
	var controls;        // Set of control names
	var <inBus;          // Array of 2 stereo Busses

	var group;           // a Group
	var <fadeSynth;      // synth to perform the xfade

	var <controlBus;     // Dictionary of control busses
	var <controlLag;     // Dictionary of control-rate lag synths

	var <source;         // synth-defining Function which is currently fading in or active
	var <sourceLast;     // the previously active source synth Function
	var <sourceQ;        // queued synth Function

	var <sourceIndex;    // current index of active source bus
	var <isFading;       // flag indicating xfade in progress

	var controlLagTime = 1.0;
	var fadeTime = 4.0;

	*new {
		arg server,      // instance of Server
		out,             // output bus index
		controls;        // array of control names; source synth functions should accept these args
		^super.new.init(server, out, controls);
	}

	init {
		arg s, out, ctl;

		server = s;
		controls = ctl.asSet;

		source = nil;
		sourceLast = nil;
		sourceQ = nil;

		sourceIndex = 0;
		isFading = false;

		group = Group.new(server);
		inBus = Array.fill(2, { Bus.audio(s, 2) });

		controlBus = Dictionary.new;
		controlLag = Dictionary.new;
		controls.do({ arg name;
			controlBus[name] = Bus.control(s);
			controlLag[name] = {
				arg bus, value, time = 1.0;
				ReplaceOut.kr(bus, Lag.kr(value, time));
			}.play(target:group, args:[\bus, controlBus[name].index]);
		});

		fadeSynth = {
			arg out=0, in0, in1, gate, time=4;
			var sourceIdx, fade, snd;
			fade = [
				EnvGen.ar(Env.asr(time, 1, time), 1-gate),
				EnvGen.ar(Env.asr(time, 1, time), gate)
			];
			snd = (In.ar(in0, 2) * fade[0]) + (In.ar(in1, 2) * fade[1]);
			Out.ar(out, snd)
		}.play(target:group, args: [
			\out, out,
			\in0, inBus[0].index,
			\in1, inBus[1].index,
			\time, fadeTime
		]);
	}

	setSource { arg newFunction;
		if (isFading, {
			sourceQ = newFunction;
		}, {
			this.performFade(newFunction);
		});
	}

	setFadeTime { arg time;
		fadeTime = time;
		fadeSynth.set(\time, fadeTime);
	}

	setControl { arg key, value;
		controlLag[key].set(\value, value);
	}

	setControlLagTime { arg time;
		controlLag.do({ arg synth; synth.set(\time, time); });
	}

	free {
		group.free;
		inBus.do({ arg bus; bus.free; });
		controlBus.do({ arg bus; bus.free; });
	}

	//////////////////////////////////////////
	/// private

	performFade { arg newFunction, args;
		sourceIndex = if (sourceIndex > 0, {0}, {1});
		postln("performing fade; new source index = " ++ sourceIndex);

		isFading = true;

		// this Routine creates a new thread
		// not the most robust solution if fade times are extremely short,
		// but much simpler than synchronizing with events from the server.
		Routine {
			sourceLast = source;
			source = newFunction.play(
				outbus:inBus[sourceIndex].index,
				target:fadeSynth,
				addAction:\addBefore
			);
			server.sync;

			controls.do({ arg key;
				source.map(key, controlBus[key]);
			});

			if ((args == nil).not, {
				controls.do({ arg key;
					if (args.includes(key), {
						controlBus[key].set(args[key]);
					})
				})
			});

			fadeSynth.set(\gate, sourceIndex);

			(fadeTime + 0.001).wait;
			this.finishFade;
		}.play;
	}

	finishFade {
		if ((sourceLast== nil).not, {
			sourceLast.free;
		});

		isFading = false;

		if ((sourceQ == nil).not, {
			this.performFade(sourceQ);
			sourceQ = nil;
		});
	}
}