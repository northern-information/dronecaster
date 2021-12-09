// @sixolet
// Magicicada
// Unsettling, organic, chaotic

// This is a drone based on no-input mixing techniques. It has two parallel selectors between delays,
// crossfading among three delays in the first selector and six delays in the second. Because the selector
// crossfades, at any given time four different delays are participating in the feedback loop.
// These delays are then filtered/processed/warped and fed back with a small amount of additional noise.

//(
{ |hz=100, amp=0.5|
	var sr = 48000;
	var big = 2.pow((sr*6).log2Ceil);
	var mediumBig = 2.pow((48000*4).log2Ceil);
	var medium = 2.pow((48000*2).log2Ceil);
	var small = 2.pow((48000).log2Ceil);
	var fbk = LocalIn.ar(2);
	var mid = PinkNoise.ar;
	var side = 0.1 * BrownNoise.ar;
	var noise = [mid + side, mid-side] * 0.01;
	var delayIn, delayInMessedUp;
	var delayed, delayed1, delayed2, phased;
	var beat = LFNoise2.kr(600.reciprocal).exprange(0.5, 2.8);
	var distGain = LFNoise2.kr(60.reciprocal).range(1, 2.5);
	var highRes = LFNoise2.kr(30.reciprocal).range(0.05, 0.2);
	var lowRes = LFNoise2.kr(30.reciprocal).range(0.05, 0.2);
	var sig = fbk;
	sig = LeakDC.ar(sig);
	phased = sig;
	3.do {
		phased = BAllPass.ar(phased, freq: LFNoise2.kr(30.reciprocal).range(20, 2000), rq: 0.7);
	};

	sig = ((sig + phased)/2);
	delayIn = sig + noise;
	delayed1 = SelectX.ar(LFNoise2.kr(200.reciprocal).range(0, 3), [
		BufDelayC.ar(LocalBuf.new(mediumBig!2), delayIn, beat),
		BufDelayC.ar(LocalBuf.new(medium!2), delayIn, (2*beat)/3.0),
		BufDelayC.ar(LocalBuf.new(medium!2), delayIn, (0.5*beat)),
	], wrap: 1);
	delayInMessedUp = delayIn + delayIn.fold(-0.1, 0.1);
	delayed2 = SelectX.ar(LFNoise2.kr(340.reciprocal).range(0, 6), [
		BLowPass.ar(
			BufDelayL.ar(LocalBuf.new(small!2), delayInMessedUp, beat/4),
			(12/5.0)*hz, highRes),
		BLowPass.ar(
			BufDelayL.ar(LocalBuf.new(medium!2), delayInMessedUp, (3/4.0)*beat),
			(9/4.0)*hz, highRes),
		BLowPass.ar(DelayC.ar(delayIn, 1.5, (0.5*beat)), (16.0/5)*hz, highRes),
		DelayC.ar(delayIn, 1.5, (0.5*beat)),
		DelayC.ar(delayIn, 0.3, (0.1*beat)),
	], wrap: 1);
	delayed1 = LFNoise2.kr(103.reciprocal).range(-0.3, 1.1).clip(0, 1).if(delayed1, BLowPass.ar(delayed1, hz, lowRes));
	delayed = HPF.ar((distGain*(delayed1 + delayed2)).sin, 20);
	LocalOut.ar(LFNoise2.kr(20.reciprocal).range(0.48, 0.75)*(delayed));

	sig = LPF.ar(
		HPF.ar(Rotate2.ar(sig[0], sig[1], LFNoise2.kr(30.reciprocal)), 20),
		LFNoise2.kr(43.reciprocal).exprange(3000, 20000));
	(sig*amp).tanh
}//.scope
//)
