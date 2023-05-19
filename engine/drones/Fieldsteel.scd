/*
DroneDef inspired by the inimitable source of
boundless Supercollider knowledge and masterful pedagogy,
Dr. Eli Fieldsteel.

Concept, structure, and tonality "borrowed" from
Tutorial 15: Composing a Piece, Part I
(https://www.youtube.com/watch?v=lGs7JOOVjag&t=790s)
*/

// (
// d =
{
	arg hz=220, amp=1;

	var atk=2, sus=5, rel=3, c1=1, c2=(-1),
	detune=0.1, pregain=0,
	cfmin=300, cfmax=1000, rqmin=0.1, rqmax=0.2, out=0,
	bal=(-0.35), // balance between drone (-1) and marimba (1)
	marimba_freq=1/4, marimba_rqmin=0.002, marimba_rqmax=0.01;

	var snd;

	// Band-passed saw at audio rates
	var drone = {

		var sig, env;
		var notes, trigs, raw_notes;
		var base_rate = 1/8;

		raw_notes = hz.cpsmidi - [20, 13, 0, 5];

		notes = Dxrand(raw_notes.midicps, inf);
		trigs = [Impulse.kr(base_rate, 0), Impulse.kr(base_rate, 1/3), Impulse.kr(base_rate, 3/5)];

		env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), trigs);

		// demand a new note and a random amplitude at each trigger
		sig = Saw.ar(
			Demand.kr(trigs, 0, notes) * {LFNoise1.kr(0.1, detune).midiratio},
			Demand.kr(trigs, 0, pregain + Dbrown(0.6, 0.8))
		).softclip * 0.75; // scale back below unity  (need better normalizing factor)
		sig = BPF.ar(
			sig,
			// center frequency
			{LFNoise1.kr(0.2).exprange(hz/2, 3*hz)}!2,
			// 1/q
			{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
		);

		// boost amp a bit to push clipping
		sig = sig * env * 1.5;
		// but scale clipped signal back below unity
		sig = sig.softclip;
		sig = Splay.ar(sig, spread:0.85);
		sig;
	};


	// Band-passed saw at low frequencies (rhythm rather than pitch)
	var marimba = {
		var freq=1/4;
		var rqmin=0.002, rqmax=0.01;

		var sig;
		var rhythms, pitches, trigs;
		var layers;

		rhythms = Dxrand(freq * [1/2, 3/2, 9/4, 11/17, 1, 2, 4, 5], inf);
		//rhythms = Dxrand(freq * [1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf);
		pitches = Drand(hz * [1/2, 1, 2, 5/4, 4], inf); // 4/5?
		trigs = Impulse.kr(1/4);

		layers = 3;
		sig = Splay.ar(Array.fill(layers, {
			// Filter with SVF rather than BPF (as above), because Norns is _very_ unhappy with
			// BPF and Demand. (https://llllllll.co/t/dronecaster/34737/316?u=tenenmatt)
			SVF.ar(
				LFSaw.ar(Demand.kr(trigs, 0, rhythms),
					//mul:(1 + (amp/layers)) * Demand.kr(trigs, 0, Dbrown(0.6))),
					mul:Demand.kr(trigs, 0, Dbrown(0.6))),
				cutoff: Demand.kr(trigs, 0, pitches),
				res: {1 - LFNoise1.kr(0.1).exprange(rqmin, rqmax)},
				lowpass: 0,
				bandpass: 1,
				mul: 0.1
			).softclip
		}), spread: 0.7);

		sig
	};

	// Balance between sound sources.
	// Drone is 100% when \bal = -1, marimba when \bal = 1.
	// Both are 50/50 when \bal = 0.
	var drone_amp = bal.linlin(-1, 1, 1, 0);
	var marimba_amp = bal.linlin(-1, 1, 0, 1);

	// Mix drone and marimba (stereo) signals together
	snd = Mix.new([
		drone_amp * drone.value,
		marimba_amp * marimba.value,
		//Splay.ar(Dust.ar(4!2, mul:crackle), spread:0.5) // bit of optional texture-dust
	]);

	snd * amp; // Let amp control overall output volume
}
// .play
// )
// d.set(\hz, 220)
