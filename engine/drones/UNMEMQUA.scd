// @zebra
//z =
{
	arg hz=110, amp=1.0, decay=1.0,
	dustDensity=17, dustLagUp=0.017, dustLagDown=0.07,
	dustAmp=0.73, brownAmp=0.03, pinkAmp=0.03, sineAmp=0.009, rlpfAmp=0.33,
	sineHzRatio=0.25, decayRatio=256;
	var f, dust, sine, excite, klank, snd;

	hz = hz.lag(6);

	dust = Array.fill(2, {LagUD.ar(Dust.ar(dustDensity, dustAmp), dustLagUp, dustLagDown) });
	dust = dust.distort.distort;
	sine = SinOsc.ar((sineHzRatio*hz) + LFNoise2.ar(1/52, 0.127), 0, sineAmp);
	excite = dust + BrownNoise.ar(brownAmp) + PinkNoise.ar(pinkAmp) + sine;

	f = [1, 3, 5, 7, 11, 3, 3/2, 6/5];
	f = (f ++ (f * 13) ++ (f * 23)).flatten;
	f = f.collect({|x| var y=x; while({y>4}, {y = y / 2}); y});

	hz = [hz+LFTri.kr(1/27), hz-LFTri.kr(1/33, 1)];

	klank = DynKlank.ar(`[
		f,
		Array.geom(f.size, 1.0, 0.99),
		f.rotate(2) / 4
	], excite, hz, 0, 1/hz * decayRatio);
	snd = Mix.new(klank.flatten.clump(2));
	snd = snd * Linen.kr(attackTime:9.93) * -46.dbamp * amp;
//	Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd
}
//.play(s);