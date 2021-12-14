// @zebra
//z =
{
	arg hz=110, amp=1.0;
	var decay=1.0,
	dustDensity=7, dustLagUp=0.017, dustLagDown=0.07,
	dustAmp=0.73, brownAmp=0.03, pinkAmp=0.03, sineAmp=0.011, rlpfAmp=0.33,
	sineHzRatio=0.25, decayRatio=256;
	var f, dust, sine, excite, klank, snd;
	var fff;

	hz = hz.lag(6);

	dust = Array.fill(2, {LagUD.ar(Dust.ar(dustDensity, dustAmp), dustLagUp, dustLagDown) });
	dust = dust.distort.distort;
	sine = SinOsc.ar((sineHzRatio*hz * [1,2]) + LFNoise2.ar([1/52, 1/53], 0.127), 0, sineAmp);
	excite = dust + BrownNoise.ar(brownAmp) + PinkNoise.ar(pinkAmp) + sine;

	f = [1, 2, 3, 5, 7, 8, 10, 12, 4, 6, 14, 12/5, 16, 1/2];
	f = (f ++ (f * 5)).flatten;
	f = f.collect({|x| var y=x;
		while({y>8}, {y = y / 3});
		y});

	hz = [hz+LFTri.kr(1/27, mul:0.04), hz-LFTri.kr(1/33, 1, mul:0.04)];

	klank = DynKlank.ar(`[
		f,
		Array.geom(f.size, 1.0, 0.99),
		f.rotate(2) / 4
	], excite, hz, 0, 1/hz * decayRatio) * 0.1;
	snd = Mix.new(klank.flatten.clump(2));
	snd = HPF.ar(snd, 4);

	fff = SVF.ar(snd.tanh, hz * [1, 2, 7/2, 4, 8, 14/2],
		LFTri.kr([1/13, 1/17, 1/18, 1/16], [0.1, 0.7]).linlin(-1,1,0.89,0.98),
		lowpass:SinOsc.kr([1/31, 1/27, 1/19, 1/20], [0.1, 0.7, 1.2, 0.6]).linlin(-1,1,-30, 0).dbamp,
		highpass:SinOsc.kr([1/23, 1/29, 1/17, 1/21], [0.1, 0.7, 0.4, 1.1]).linlin(-1,1,-40,4).dbamp)
	* -14.dbamp;
	fff = Mix.new(fff.flatten.clump(2));
	
	fff = fff + Pan2.ar(
		BufCombC.ar(LocalBuf(SampleRate.ir*4, 2), fff,
			LFTri.ar([1/16,1/14]).linlin(-1, 1, 3.7, 3.9),
			[-23, 23], mul:0.2),
	[0.8, -0.8]);

	snd = Mix.new((snd + fff).flatten.clump(2));

	snd = snd * Linen.kr(attackTime:9.93) * -32.dbamp * amp;
//	Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd
}
//.play(s);