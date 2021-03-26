// Retro stylings, timeless horror
{
	arg hz,amp;

	var wet, drive, ratio, threshold, gain,
	wow, minWowRate, wowRate, maxDepth, maxLfoDepth, depth, depthLfoAmount, wowMul, maxDelay,
	tone, bitRate, noiseSignal;

	// Tape/Vinyl-esque noise as our main original signal
	wet = (Dust2.ar(10, 1) + Crackle.ar(1.95, 0.2) + SinOsc.ar((PinkNoise.ar(0.5) * 7500) + 40, 0, 0.04));

	// First we feed into a HPF to filter out sub-20Hz
	wet = HPF.ar(wet, 25);
	drive = \drive.kr(0.75);
	// Shitty compression (slow attack and release, really aggressive ratio)
	ratio = LinExp.kr(drive, 0, 1, 0.15, 0.01);
	threshold = LinLin.kr(drive, 0, 1, 0.8, 0.33);
	// We bump the gain to keep up with the threshold and ratio, then compress it
	gain = 1/(((1.0-threshold) * ratio) + threshold);
	wet = Limiter.ar(Compander.ar(wet, wet, threshold, 1.0, ratio, 0.1, 1, gain), dur: 0.0008);

	// Bandpass it at Hz
	wet = BPF.ar(wet, hz, 0.4);

	// Wow aka flutter aka warble
	wow = \wow.kr(0.6);
	minWowRate = 0.5;
	wowRate = LinExp.kr(wow, 0, 1, minWowRate, 4);
	maxDepth = 35;
	maxLfoDepth = 5;
	depth = LinExp.kr(wow, 0, 1, 1, maxDepth - maxLfoDepth);
	depthLfoAmount = LinLin.kr(wow, 0, 1, 1, maxLfoDepth).floor;
	depth = LFPar.kr(depthLfoAmount * 0.1, mul: depthLfoAmount, add: depth);
	// wowMul calculates the amplitude of the LFO for our delay to achieve the given rate and depth
	wowMul = ((2 ** (depth * 1200.reciprocal)) - 1)/(4 * wowRate);
	maxDelay = (((2 ** (maxDepth * 1200.reciprocal)) - 1)/(4 * minWowRate)) * 2.5;
	wet = DelayC.ar(wet, maxDelay, SinOsc.ar(wowRate, 2, wowMul, wowMul + ControlRate.ir.reciprocal));

	// Tape/Vinyl-esque noise
	noiseSignal = (Dust2.ar(10, 1) + Crackle.ar(1.95, 0.2) + SinOsc.ar((PinkNoise.ar(0.5) * 7500) + 40, 0, 0.006));

	// Saturation
	wet = ((wet * LinExp.kr(drive, 0, 1, 1, 2.5)) + noiseSignal).tanh;

	// A little bitcrushing
	wet = (Decimator.ar(wet, 24000, 16) * 0.33) + (wet * 0.67);

	// Bandpass it at Hz again
	wet = BPF.ar(wet, hz, 0.4);

	// Typically we're at about -24db at this point, so get back to 0
	wet = (wet * 24.dbamp * amp).softclip;

	wet.dup;
}
