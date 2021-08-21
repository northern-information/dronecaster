// old version way too complicated
// we don't want xfades, we want down+up
DroneCaster_SynthSocket {
	var server, group, synth, controls, out;
	var cuedSource, doneResponder;
	var fadeTime = 1.0;

	*new {
		arg server, out, controls;
		^super.new.init(server, out, controls);
	}

	wrapDef {
		arg fn, name;
		var def, nope = false;
		postln("building synthdef: "++name);
		//		postln("fn = " ++ fn);
		//		postln("class(fn) = " ++ fn.class);
		def = SynthDef.new(name, {
			arg hz, amp=1, out=0, gate=1, attack=1, release=1;

			var aenv, snd;
			snd = { fn.value(K2A.ar(hz), K2A.ar(amp)) }.try { 
				arg err;				
				postln("failed to wrap ugen graph! error:");
				err.postln;
				nope = true;
				[Silent.ar]
			};
			aenv = EnvGen.kr(Env.asr(gate), attack, 1, release);
			// force mix down to stereo (interleaved)
			snd = Mix.new(snd.flatten.clump(2)) * aenv;
			
			Out.ar(out, snd);
		});
		if (nope, {
			^nil
		}, {
			def.load(server);
			^def;
		});
	}


	stop {
		if (synth.notNil, {
			synth.set(\gate, 0);
		});
	}

	setSource { arg def;
		cuedSource = def;
		if (synth.isNil, {
			this.performSource;
		}, {
			this.stop;
		});
	}


	setControl { arg k, v;
		controls[k].set(v);
	}

	init { arg aServer, aOut, aControls;
		server = aServer;
		out = aOut;
		controls = Dictionary.new;
		aControls.do({ arg k;
			controls[k] = Bus.control(server, 1);
		});

		group = Group.new(server);
		synth = nil;
		cuedSource = nil;

		doneResponder =  OSCFunc({ arg msg;
			var nodeId, id;
			nodeId = msg[1];
			if (synth.notNil, {
				if (nodeId == synth.nodeID, {
					this.performSource;
				});
			});
		}, '/n_end', server.addr);
	}

	free {
		controls.do({ arg bus; bus.free; });
		if (synth.notNil, { synth.free; });
	}

	///// private

	performSource {

		if (cuedSource.notNil, {
			// all this faff is just to initialize the synthdef with the values from the ctl busses.
			// there is probably a cleaner way.
			var controlVals = Dictionary.new;
			var condition = Condition.new(false);
			controls.do({ arg k, bus;
				bus.get({ arg val;
					controlVals[k] = val;
					condition.test = true;
					condition.signal;
				});
				condition.wait;
			});

			synth = Synth.new(cuedSource, [\out, out] ++ controlVals.getPairs, target:group);
			controls.do({ arg k, bus; synth.map(k, bus); });
			cuedSource = nil;
		}, {
			// no cued source
			synth = nil;
		});
	}
}



/*
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

fadeSynth = Array.fill(2, { arg i;
{
arg out=0, in, gate, time=4;
var fade, snd;
fade = EnvGen.ar(Env.asr(time, 1, time), gate);
snd = fade * In.ar(in, 2);
Out.ar(out, snd)
}.play(target:group, args: [
\out, out,
\in, inBus[i].index,
\time, fadeTime
]);
});
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
fadeSynth.do({ arg synth; synth.set(\time, fadeTime); });
}

setControl { arg key, value;
controlLag[key].set(\value, value);
}

setControlLagTime { arg time;
controlLag.do({ arg synth; synth.set(\time, time); });
}

stop {
fadeSynth.do({ arg synth; synth.set(\gate, 0); });
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
// postln("performing fade; new source index = " ++ sourceIndex);

isFading = true;

// this Routine creates a new thread
// not the most robust solution if fade times are extremely short,
// but much simpler than synchronizing with events from the server.
Routine {
sourceLast = source;
source = newFunction.play(
outbus:inBus[sourceIndex].index,
target:group,
addAction:\addToHead // <- important
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

fadeSynth[sourceIndex].set(\gate, 1);
fadeSynth[1-sourceIndex].set(\gate, 0);

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
*/
