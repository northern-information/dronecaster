// @sixolet
// Magicicada
// Unsettling, organic, chaotic

// This is a drone based on no-input mixing techniques. It has two parallel selectors between delays,
// crossfading among three delays in the first selector and six delays in the second. Because the selector
// crossfades, at any given time four different delays are participating in the feedback loop.
// These delays are then filtered/processed/warped and fed back with a small amount of additional noise.

// (

{ |hz=110, amp=0.5|
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
	var delaySel1 = SinOsc.kr(166.6.reciprocal, Rand.new(-pi, pi)).range(0, 3);
	var filterSel1 = SinOsc.kr(82.reciprocal, Rand.new(-pi, pi)).range(-0.3, 1.1).clip(0, 1);
	var delaySel2 = SinOsc.kr((pi*60).reciprocal, Rand.new(-pi, pi)).range(0, 4);
	var filterSel2 = SinOsc.kr(123.4.reciprocal, Rand.new(-pi, pi)).range(0, 3);
	var sig = fbk;
	sig = LeakDC.ar(sig);
	phased = sig;
	3.do {
		phased = BAllPass.ar(phased, freq: LFNoise2.kr(30.reciprocal).range(20, 2000), rq: 0.7);
	};

	sig = ((sig + phased)/2);
	delayIn = sig + noise;
	delayed1 = SelectX.ar(delaySel1, [
		DelayC.ar(delayIn, 2.9, beat),
		DelayC.ar(delayIn, 2, (2.0*beat)/3),
		DelayC.ar(delayIn, 1.5, (0.5*beat)),
	], wrap: 1);
	delayed1 = SelectX.ar(filterSel1, [
		RLPF.ar(delayed1, hz, lowRes),
		delayed1,
	]);

	delayInMessedUp = delayIn + delayIn.fold(-0.1, 0.1);
	delayed2 = SelectX.ar(delaySel2, [
		DelayC.ar(delayInMessedUp, 0.75, beat/4),
		DelayC.ar(delayInMessedUp, 2.5, (3/4.0)*beat),
		DelayC.ar(delayIn, 1.5, (0.5*beat)),
		DelayC.ar(delayIn, 0.3, (0.1*beat)),
	], wrap: 1);
	delayed2 = SelectX.ar(filterSel2, [
		RLPF.ar(delayed2, (12/5.0)*hz, highRes),
		SVF.ar(delayed2, (9/2)*hz, highRes, 0.0, 1.0),
		delayed2,
	], wrap: 1);

	delayed = HPF.ar((distGain*(delayed1 + delayed2)).sin, LFNoise2.kr(30.reciprocal).range(20, hz));
	LocalOut.ar(LFNoise2.kr(20.reciprocal).range(0.48, 0.75)*(delayed));

	sig = LPF.ar(
		HPF.ar(Rotate2.ar(sig[0], sig[1], LFNoise2.kr(30.reciprocal)), 20),
		LFNoise2.kr(43.reciprocal).exprange(3000, 20000));
	(sig*amp).tanh
}/*.scope
)
*/