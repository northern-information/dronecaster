// (
// d =
{
	// Build multiple voices into the function directly
	arg atk=2, sus=5, rel=3, c1=1, c2=(-1),
	hz=329.63, detune=0.1, pregain=0,
	cfmin=300, cfmax=1000, rqmin=0.1, rqmax=0.2, amp=1, out=0,
	bal=0, // balance between drone (-1) and marimba (1)
	crackle=0, // amp for "dust"
	marimba_freq=1, marimba_rqmin=0.002, marimba_rqmax=0.01;

	var snd;

	var drone = {

		var sig, env;
		var notes, trigs, raw_notes;
		var base_rate = 1/8;

		raw_notes = hz.cpsmidi - [20, 13, 0, 5];

		//raw_notes = [58, 65, 78, 73]-24;
		notes = Dxrand(raw_notes.midicps, inf);
		trigs = [Impulse.kr(base_rate, 0), Impulse.kr(base_rate, 1/3), Impulse.kr(base_rate, 3/5)];

		env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), trigs);

		// demand a new note and a random amplitude at each trigger
		sig = Saw.ar(
			Demand.kr(trigs, 0, notes) * {LFNoise1.kr(0.1, detune).midiratio},
			Demand.kr(trigs, 0, pregain + Dbrown(0.6, 0.8))
		).softclip * 0.75; // scale back below unity  (need better normalizing factor)
		// maybe softclip Saw directly (or after bandpass), before envelope?
		sig = BPF.ar(
			sig,
			// center frequency
			{LFNoise1.kr(0.2).exprange(hz/2, 3*hz)}!2,
			// 1/q
			{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
		);
		//sig = Balance2.ar(sig[0], sig[1], {(pan + LFNoise1.kr(0.25, wander)).range(-1, 1)});

		// boost amp a bit to push clipping
		sig = sig * env * (amp + 1);
		// but scale clipped signal back below unity
		//sig = sig.softclip * 0.75;
		sig = Splay.ar(sig, spread:0.85);
		sig;
	};


	//~drone.set(\rqmin, 0.05, \rqmax, 0.15)
	//~drone.set(\pregain, 2)

	// Now let's add the "marimba", which is Saw -> BPF with small frequency (<10Hz), very small rq (~0.002--0.01), pitch controlled by cf. We'll want that pitch to match the droning (maybe [0.5, 1, 2, 4] * hz?). Some number of simultaneous strikes, each demanding a varying Saw(freq)--which, again, controls the rhythm.

	var marimba = {
		arg hz=1, cf=329.63, rqmin=0.002, rqmax=0.01, amp=1;

		var sig, env;
		var rhythms, pitches, trigs;
		var layers;

		rhythms = Dxrand(hz * [1/2, 3/2, 2/3, 9/4, 11/17, 1, 2, 4, 5, 9/4], inf);
		//rhythms = Dxrand(hz * [1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf);
		pitches = Drand(cf * [1/2, 1, 2, 5/4, 4], inf); // 4/5?
		trigs = Impulse.kr(1/4);

		//sig = Saw.ar(Demand.kr(trigs, 0, rhythms), mul:amp);
		//sig = BPF.ar(sig, Demand.kr(trigs, 0, pitches), {LFNoise1.kr(0.1).exprange(rqmin, rqmax)});

		layers = 3;
		sig = Splay.ar(Array.fill(layers, {
			BPF.ar(
				Saw.ar(Demand.kr(trigs, 0, rhythms),
					mul:(1 + (amp/layers)) * Demand.kr(trigs, 0, Dbrown(0.6))),
				Demand.kr(trigs, 0, pitches),
				{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}
			).tanh
		}), spread: 0.7);

		//env = EnvGen.kr(Env([0, 1, 1, 0], [3, 1, 5], [c1, 0, c2]), trigs);
		sig // * env;
	};

	// Balance between sound sources.
	// Drone is 100% when \bal = -1, marimba when \bal = 1.
	// Both are 50/50 when \bal = 0.
	var drone_amp = bal.linlin(-1, 1, 1, 0);
	var marimba_amp = bal.linlin(-1, 1, 0, 1);

	// Take drone-related sig[0..1] and marimba sig[0..1] and Mix.ar() together
	snd = Mix.ar([
		drone_amp * drone.value,
		marimba_amp * marimba.value(marimba_freq, hz),
		Splay.ar(Dust.ar(4!2, mul:crackle), spread:0.5) // bit of optional texture-dust
	]);

	// marimba.set(\amp, 4)

	// Scale drone and marimba amp with -1..1 --> 0..1 for drone, 1..0 for marimba
}
// .play
// )
//
// d.set(\crackle, 0.1)
// //d.set(\bal, 1/4)
// //d.set(\hz, 220)