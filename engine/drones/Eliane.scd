// @sixolet
// Eliane
// Feedback, slow beatings, highs and lows

// (seven sines phase-modulating each other in a crosslinked ring)

{ 
  arg hz=220,amp=1.0;
	var base = 2.pow(1/12.0);
	// All the notes in a natural minor scale, but by fifths (with one diminished).
	// root, fifth, second + 8v, minor sixth +8v, minor third +2 8v, minor seventh +2 8v, fourth +3 8v 
	var intervals = base.pow([0, 7, 14, 20, 27, 34, 41]);
	var busses = LocalIn.ar(14);
	var nice = LFNoise2.kr(200.reciprocal);
	var bigsound;
	var sines = 7.collect { |x|
		var next = (x+1)%7;
		var nextayim = (x+2)%7;
		var modulator1 = [busses[2*next], busses[2*next+1]];
		var modulator2 = [busses[2*nextayim], busses[2*nextayim+1]];
		var mod = (((x+1)*modulator1) + modulator2);
		var stereo;
		var pitch = hz*intervals[x];
		mod = pi * LFNoise2.kr(0.015).unipolar().pow(nice.range(0.9, 2)) * mod;
		stereo = SinOsc.ar(pitch + ((x/2)*LFNoise2.kr(0.1!2)), mod);
		// At high pitch, introduce subharmonics instead of high intervals.
		switch (x)
		{6} {
			stereo = SelectX.ar(hz/(150+hz), [
				stereo/(x+1),
				SinOsc.ar(hz/2 + LFNoise2.kr(0.1!2), mod),
			]);
		}
		{5} {
			stereo = SelectX.ar(hz/(300+hz), [
				stereo/(x+1),
				SinOsc.ar(hz/3 + LFNoise2.kr(0.1!2), mod)/2,
			]);
		}
		// default
		{
			stereo = stereo/(x+1);
		};
		stereo = Rotate2.ar(stereo[0], stereo[1], LFNoise2.kr(0.04)/2);
		stereo = stereo * LFDNoise3.kr(
			LFNoise2.kr(300.reciprocal).range(120.reciprocal, 30.reciprocal), add: 0.2,
		).clip(0, 1).lag2(10);
		stereo;
	};
	LocalOut.ar(sines.reshape(14));
	bigsound = Mix.ar(0.5*sines*amp);
	bigsound = CombN.ar(bigsound, 0.3, 0.3, LFNoise2.kr(0.02).exprange(0.3, 3.0));
	bigsound.tanh;
}