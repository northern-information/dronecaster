// @zebra

// utility func to "wrap: a value to a range, by octave division
var geoWrap = { arg x, max=2, min=1;
	var y = x;
	while ({y>max}, {y=y/2});
	while ({y<min}, {y=y*2});
	y
};

var synthFunc = {
	arg hz=110, amp=0.125,
	basePeriod=47,
	attackTime=4, releaseTime=4, ampCurve= -0.5,
	panWidth=0.75;

	var gatePattern;
	var scalePattern;
	var ratioValues;
	var snd;

	// these determine the basic tonality
	ratioValues = [1, 12/5, 3/2, 8/3, 18/8, 5/3];

	gatePattern = [
		[ 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[ 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0],
		[ 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0],
		[ 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0],
	];

	scalePattern = [
		[ 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 0, 0],
		[ 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1],
		[ 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
		[ 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1]
	];

	// for each scale pattern, extend it for 1-3 periods with random (but fixed) harmonic shifts
	scalePattern = scalePattern.collect({
		arg arr;
		var harmShift = Array.series(1 + 3.rand, 1, 1 + 2.rand).scramble;
		harmShift.collect({
			arg harm;
			arr.collect({ arg degree;
				// lookup the index, apply the harmonic shift,
				// and perform "geometric wrap" to [< 4]
				geoWrap.value(ratioValues[degree] * harm, 4)
			})
		}).flatten;
	});


	// __more__
	basePeriod = [basePeriod, basePeriod*2.718];

	snd = gatePattern.size.collect({ arg i;
		var gate, env, ratio, filterRatio, pulse, snd, del, delNeg, pan, panRate;

		hz = Lag.kr(hz, 1.0);
		amp = Lag.kr(amp, 1.0);

		pulse = LFPulse.kr(1/basePeriod + LFNoise2.kr(1/basePeriod, 1));
		gate = Demand.kr(pulse, 0, Dseq(gatePattern[i], inf));
		env = EnvGen.kr(Env.asr(attackTime, 1, releaseTime, ampCurve), gate);
		ratio = Demand.kr(pulse, 0, Dseq(scalePattern[i], inf));

		// add a tiny amount of drift chaos to each sine freq
		snd = SinOsc.ar(hz * ratio * (1 + LFNoise2.ar(0.25/basePeriod[0], 0.07))) * env;
		snd = snd.distort.distort.distort;
		snd = RLPF.ar(snd,
			hz*[0.25, 0.5, 1, 1.5, 2] * Lag.kr(ratio, basePeriod) + LFNoise2.kr(1/basePeriod, 0.1),
			LFNoise2.kr(1/basePeriod, 0.1 + 0.2.rand, 0.5 + 0.5.rand));

		del = CombC.ar(snd, 0.5, 16.0/hz * LFNoise2.ar(0.125/basePeriod, 0.01, 1), basePeriod * 8);
		// comb with a negative decay time, emphasizing odd harmonics 8vb
		delNeg = CombC.ar(snd, 0.5, 4.0/hz * LFNoise2.ar(0.125/basePeriod, 0.01, 1), basePeriod * -8);
		panRate = 1/(basePeriod) * geoWrap.value((i+1)*4.33, 2.0, 0.5);
		Mix.new([
			Pan2.ar(snd, SinOsc.ar(panRate, ((i+1)*pi/4.33).wrap(pi, 8*pi), panWidth), 0.5),
			Pan2.ar(del, SinOsc.ar(panRate, ((i+3)*pi/2.78).wrap(pi, 8*pi), panWidth), 0.25),
			Pan2.ar(delNeg, SinOsc.ar(panRate, ((i+5)*pi/1.595).wrap(pi, 8*pi), panWidth), 0.5)
		])
	});

	snd = Mix.new(snd.flatten.clump(2));
	snd = snd + RLPF.ar(snd, hz * 0.5, 0.2);
	snd = (snd + [Normalizer.ar(snd[0]), Normalizer.ar(snd[1])]/2) * amp * 0.25;
	snd.flatten
};

synthFunc