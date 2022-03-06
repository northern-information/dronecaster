// @rplktr
// Ruins
// A reality darker than fiction.

// Metallic 2-op or 3-op FM hits drowned in fluttering reverb with a windy noise floor.
// FM operators based on James McCartney's "100 FM Synths" demo.
//
// Made as part of Disquiet Junto Project 0531: Noise Sculpt.
// See more at https://llllllll.co/t/disquiet-junto-project-0531-noise-sculpt/53257/

{ | group=0 |
	var the_ruin, the_metal, the_sequence, the_sound;

	~ruinAudio = Bus.audio(s, 2);
	~ruinHzControl = Bus.control(s, 1);

	the_ruin = { | hz=110, amp=1.0 |
		var in;
		var wobble_rpm = 33;
		var wobble_exp = 39;
		var flutter_fixedfreq = 6;
		var flutter_variationfreq = 2;
		var signed_wobble = 0.07 * (SinOsc.kr(wobble_rpm/60)**wobble_exp);
		var wow = Select.kr(signed_wobble > 0, signed_wobble, 0);
		var flutter = 0.04 * SinOsc.kr(flutter_fixedfreq+LFNoise2.kr(flutter_variationfreq));
		var combined_defects = 1 + wow + flutter;

		var noise_hz=VarLag.kr(LFNoise0.kr(1/10), 10).range(2000, 5000);
		var noise_vol=SinOsc.ar(0.1);
		var noise = [
			LFNoise2.ar(noise_hz, 0.0005 * noise_vol.clip(0, 1).range(0, 1)),
			LFNoise2.ar(noise_hz, 0.0005 * (1.0 - noise_vol.clip(-1, 0).range(0, 1)))
		];

		in = In.ar(~ruinAudio);
		in = Compander.ar(in, in, 0.1, 1.0, 0.1, 0.01, 0.1, 0.1, 0.0);
		in = Mix.ar([in, noise]);
		in = GVerb.ar(in, 120, 103, 0.43, 0.51, 15, -5, -26, -20, mul: combined_defects);

		Out.kr(~ruinHzControl, hz);
		Limiter.ar(in) * amp;
	};

	the_metal = { | maxAttack = 0.4 |
		var carrierF, middleF, modulatorF, makeFM;

		carrierF = { arg freq, mod=0, mix=0, gate=1;
			var e, m;
			e = Env.perc(exprand(0.001, maxAttack), exprand(0.1, 2.0));
			m = linrand(10) + 1;
			e = EnvGen.kr(e, gate, rrand(0.5, 0.6).rand.squared);
			SinOsc.ar(freq * m, mod, e, mix);
		};

		middleF = { arg freq, mod=0, mix=0, gate=1;
			var e, m;
			e = Env.perc(exprand(0.001, maxAttack), exprand(0.1, 2.0));
			m = linrand(5) + 1;
			e = EnvGen.kr(e, gate, 3.0.rand.squared);
			SinOsc.ar(freq * m, mod, e, mix);
		};

		modulatorF = { arg freq, mix=0, gate=1;
			var e, m;
			e = Env.perc(exprand(0.001, maxAttack), exprand(0.1, 2.0));
			m = linrand(5) + 1;
			e = EnvGen.kr(e, gate, 3.0.rand.squared);
			SinOsc.ar(freq * m, 1.3.rand.cubed, e, mix);
		};

		makeFM = {
			arg name = "?", kind = [0,1,2].choose, ratio = 1.8.rand2;
			SynthDef(name, {
				arg freq, velo=1.0, gate=1, pan=0;
				var c, f, m, kinds;
				// [name, "K" ++ (kind % 3), ratio].postln;  // DEBUG output
				c = 0;
				kinds = [
					{
						// sum of 3 modulator->carrier pairs
						3.do {
							f = freq + ratio.squared;
							m = modulatorF.(f, 0, gate);
							c = carrierF.(f, m, c, gate);
						}
					},
					{
						// sum of 2 modulator->modulator->carrier chains
						2.do {
							f = freq + ratio.squared;
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
							f = freq + ratio.squared;
							m = modulatorF.(f, 0, gate);
							c = carrierF.(f, m, c, gate);
							c = carrierF.(f, m, c, gate);
						}
					},
				];
				freq = freq * In.kr(~ruinHzControl);
				kinds[kind % 3].value;

				DetectSilence.ar(c, doneAction: Done.freeSelf);
				Out.ar(~ruinAudio, Pan2.ar(c, pan, velo));
			}).add;
		};

		10.do { |i| makeFM.("ruinsfm_" ++ i) };

		makeFM.("ruinsfm_10", 1, 0.20469117164612);
		makeFM.("ruinsfm_11", 1, -0.78864240646362);
		makeFM.("ruinsfm_12", 0, -0.29870753288269);
		makeFM.("ruinsfm_13", 2, 0.32451510429382);
		makeFM.("ruinsfm_14", 0, 1.4984986782074);
	};

	the_sequence = Routine({
		var name = "ruinsfm_" ++ 15.rand;
		var running = false;
		var rate, rates, velocity, chord;

		the_metal.(0.4);
		loop {
			// check if Ruins is the active drone
			block {|break|
				loop {
					OSCFunc({|msg| running = (msg.last == \Ruins)}, '/g_queryTree.reply').oneShot;
					s.sendMsg(\g_queryTree, group.nodeID, 0);
					if (running, { break.value }, { 1.wait });
				};
			};

			// we're running, let's play some random notes
			if (0.69.coin) { name = "ruinsfm_" ++ 15.rand };
			chord = [1,1,1,1,1,2,2].choose;
			rates = [
				[0.25,0.891,0.5,0.5,0.5,1,1,1,1,1,1,1.189,1.782,2,2,2,4].choose,
				[0.25,0.891,0.5,1,1.189,1.498,1.782,2,2.378].choose,
			];
			if (rates[0] == rates[1]) { rates[1] = rates[1]/3 };
			chord.do { |i|
				rate = rates[i];
				velocity = 0.25 / chord;
				if (rate > 1) { velocity = velocity / rate.squared };
				s.sendMsg(\s_new, name, s.nextNodeID, 0, group.nodeID, \freq, rate, \velo, velocity, \pan, 1.0.rand2);
			};
			// [name, chord, rates, velocity].postln; // DEBUG output
			[1, 1, 1, 2, 2, 4, 8, 16].choose.wait;
		};
	});

	the_sequence.play;
	the_ruin;
}
