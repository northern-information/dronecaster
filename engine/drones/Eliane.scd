// @sixolet
// Eliane
// Feedback, slow beatings, highs and lows

// (seven sines phase-modulating each other in a crosslinked ring)

{ |hz=60, amp=0.5|
	var base = 2.pow(1/12.0);
	var intervals = base.pow([0, 7, 14, 20, 27, 34, 41]);
	var busses = LocalIn.ar(14).reshape(7, 2);
	var nice = LFNoise2.kr(200.reciprocal);
	var bigsound, feedbacks;
	var sines = 7.collect { |x|
		var next = busses[(x+1)%7];
		var nextayim = busses[(x+2)%7];
		var mod = (((x+1)*next) + nextayim);
		var stereo;
		var pitch = hz*intervals[x];
		mod = pi * LFNoise2.kr(66.reciprocal).unipolar().pow(nice.range(0.9, 1.7)) * mod;
		stereo = SinOsc.ar(pitch + ((x/2)*LFNoise2.kr(15.reciprocal!2)), mod);
		// At high pitch, introduce subharmonics instead of high intervals.
		switch (x)
		{6} {
			stereo = SelectX.ar(hz/(150+hz), [
				stereo/((1.5*x)+1),
				SinOsc.ar(hz/2 + LFNoise2.kr(15.reciprocal!2), mod),
			]);
		}
		{5} {
			stereo = SelectX.ar(hz/(300+hz), [
				stereo/((1.3*x)+1),
				SinOsc.ar(hz/3 + LFNoise2.kr(15.reciprocal!2), mod)/2,
			]);
		}
		// default
		{
			stereo = stereo/(x+1);
		};
		stereo = Rotate2.ar(stereo[0], stereo[1], LFNoise2.kr(25.reciprocal)/2);
		stereo;
	};
	feedbacks = sines.collect { |stereo|
		stereo = stereo * LFDNoise3.kr(
			LFNoise2.kr(300.reciprocal).range(120.reciprocal, 30.reciprocal), add: 0.2,
		).clip(0, 1).lag2(13);
	};
	sines = sines.collect { |stereo|
		stereo = stereo * LFDNoise3.kr(
			LFNoise2.kr(300.reciprocal).range(120.reciprocal, 30.reciprocal), add: 0.2,
		).clip(0, 1).lag2(13);
	};
	LocalOut.ar(feedbacks.reshape(14));
	bigsound = Mix.ar(0.5*sines*amp);
	bigsound = CombN.ar(bigsound, 0.3, 0.3, LFNoise2.kr(0.02).exprange(0.3, 3.0));
	bigsound.tanh;
}
//.play