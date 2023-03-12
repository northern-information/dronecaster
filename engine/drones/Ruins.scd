// @rplktr and @sixolet
// Ruins
// A reality darker than fiction.

// Metallic 2-op or 3-op FM hits drowned in fluttering reverb with a windy noise floor.
// FM operators based on James McCartney's "100 FM Synths" demo.
//
// Originally made by @rplktr as part of Disquiet Junto Project 0531: Noise Sculpt.
// See more at https://llllllll.co/t/disquiet-junto-project-0531-noise-sculpt/53257/
//
// Refactored by @sixolet to become a regular single-synthdef drone definition.

{ | hz=110, amp=0.4 |
	var trigger_rates = [1, 1, 1, 1, 2, 2, 2, 4, 4, 8, 8, 16];
	var note1_intervals = [0.25,0.891,0.5,0.5,0.5,1,1,1,1,1,1,1.189,1.782,2,2,2,4];
	var note2_intervals = [0.25,0.891,0.5,1,1.189,1.498,1.782,2,2.378];
	var instrument_count = 12;
	var wobble_rpm = 33;
	var wobble_exp = 39;
	var flutter_fixedfreq = 6;
	var flutter_variationfreq = 2;
	var signed_wobble = 0.07 * (SinOsc.kr(wobble_rpm/60)**wobble_exp);
	var wow = Select.kr(signed_wobble > 0, [signed_wobble, 0]);
	var flutter = 0.04 * SinOsc.kr(flutter_fixedfreq+LFNoise2.kr(flutter_variationfreq));
	var combined_defects = 1 + wow + flutter;

	//
	// THE WIND
	//
	var noise_hz=VarLag.kr(LFNoise0.kr(1/10), 10).range(2000, 5000);
	var noise_vol=SinOsc.ar(0.1);
	var noise = [
		LFNoise2.ar(noise_hz, 0.0005 * noise_vol.clip(0, 1).range(0, 1)),
		LFNoise2.ar(noise_hz, 0.0005 * (1.0 - noise_vol.clip(-1, 0).range(0, 1)))
	];

	//
	// THE METAL
	//
	var max_attack = 0.4;
	var carrierF = { arg freq, mod=0, mix=0, gate=1;
		var e, m;
		e = Env.perc(exprand(0.001, max_attack), exprand(0.1, 2.0));
		m = linrand(10) + 1;
		e = EnvGen.kr(e, gate, rrand(0.5, 0.6).rand.squared);
		SinOsc.ar(freq * m, mod, e, mix);
	};
	var middleF = { arg freq, mod=0, mix=0, gate=1;
		var e, m;
		e = Env.perc(exprand(0.001, max_attack), exprand(0.1, 2.0));
		m = linrand(5) + 1;
		e = EnvGen.kr(e, gate, 3.0.rand.squared);
		SinOsc.ar(freq * m, mod, e, mix);
	};
	var modulatorF = { arg freq, mix=0, gate=1;
		var e, m;
		e = Env.perc(exprand(0.001, max_attack), exprand(0.1, 2.0));
		m = linrand(5) + 1;
		e = EnvGen.kr(e, gate, 3.0.rand.squared);
		SinOsc.ar(freq * m, 1.3.rand.cubed, e, mix);
	};
	var makeFM = {
		arg freq, velo=1.0, gate=1, pan=0;
		var kind = [0,1,2].choose;
		var detune = 1.8.rand2;
		var c, f, m, kinds;
		// ["K" ++ (kind % 3), detune].postln;  // DEBUG output
		c = 0;
		kinds = [
			{
				// sum of 3 modulator->carrier pairs
				3.do {
					f = freq + detune.squared;
					m = modulatorF.(f, 0, gate);
					c = carrierF.(f, m, c, gate);
				}
			},
			{
				// sum of 2 modulator->modulator->carrier chains
				2.do {
					f = freq + detune.squared;
					m = modulatorF.(f, 0, gate);
					m = middleF.(f, m, 0, gate);
					c = carrierF.(f, m, c, gate);
				}
			},
			{
				// sum of 2 modulator-+->carrier
				//                    |
				//                    +->carrier
				2.do {
					f = freq + detune.squared;
					m = modulatorF.(f, 0, gate);
					c = carrierF.(f, m, c, gate);
					c = carrierF.(f, m, c, gate);
				}
			},
		];
		kinds[kind % 3].value;
		Pan2.ar(c, pan, velo);
	};

	//
	// THE SEQUENCE OF EVENTS
	//

	// Feed the rate back into triggering the change in the rate.
	// See the LocalOut() line below for where that happens, right before returning the sound.
	var trigger = LocalIn.kr(1);
	// Choose the rate of triggering every time we trigger.
	var rate = Demand.kr(trigger + Impulse.kr(0), 0, [Drand(trigger_rates, inf)]);

	// Choose a couple intervals every time we trigger.
	var intervals1 = Demand.kr(trigger, 0, [Drand(note1_intervals, inf)]);
	var intervals2 = Demand.kr(trigger, 0, [Drand(note2_intervals, inf)]);
	var chord = Demand.kr(trigger, 0, Drand([0, 0, 0, 0, 1, 1, 1], inf));
	var velo = Demand.kr(trigger, 0, Drand([1.0, 1.0, 1.0, 0.66, 0.66, 0.33, 0.1], inf));
	// The ! operator is super useful to create copies of something. Careful what level you put it at.
	// This creates two independent slow-slewed noise things to make the OSCs modulate panning.
	var pans = LFNoise2.kr(20.reciprocal!2);
	// Pick which instrument to use every time we trigger, but only change it 69% of the time.
	var whichInstrument = Demand.kr(CoinGate.kr(0.69, trigger), 0, [Drand(Array.series(instrument_count), inf)]);
	var sound, instruments, intervals;
	// only sometimes make intervals2 different from intervals1.
	intervals2 = Select.kr(chord, [intervals1, intervals2]);
	// Consolidate these into an array so array expansion will make some extra oscillators for us.
	intervals = [intervals1, intervals2];

	instruments = 0.5 * Array.fill(instrument_count, { |i|
		Mix.ar(makeFM.(freq: hz * intervals, velo: velo, gate: trigger, pan: pans))
	});
	sound = 0.2 * Select.ar(whichInstrument, instruments);
	sound = Compander.ar(sound, sound, 0.1, 1.0, 0.1, 0.01, 0.1, 0.1, 0.0);
	sound = Mix.ar([sound, noise]);
	sound = GVerb.ar(sound, 120, 103, 0.43, 0.51, 15, -5, -26, -20, mul: combined_defects);

    	// See LocalIn above.
	LocalOut.kr([Impulse.kr(rate.reciprocal)]);

	Limiter.ar(sound, dur: 0.1) * amp;
}

/* // SELF TEST
{ruin.(110, 1.0)}.play;
*/
