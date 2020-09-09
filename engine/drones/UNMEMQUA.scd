// @zebra
{
	arg hz=110, amp=0.007, decay=1.0,
	dustDensity=17, dustLagUp=0.017, dustLagDown=0.07,
	dustAmp=0.73, brownAmp=0.05, sineAmp=0.007, rlpfAmp=0.33,
	sineHzRatio=0.25, decayRatio=256;
	var f, dust, sine, excite, klank, snd;

	dust = Array.fill(2, {LagUD.ar(Dust.ar(dustDensity, dustAmp), dustLagUp, dustLagDown) });
	dust = dust.distort.distort;
	sine = SinOsc.ar((sineHzRatio*hz) + LFNoise2.ar(1/52, 0.127), 0, sineAmp);
	excite = dust + BrownNoise.ar(brownAmp) + sine;
	hz = [hz+LFNoise2.kr(0.1), hz-LFNoise2.kr(0.1)];

	f = [1, 3, 5, 7, 11];
	f = (f ++ (f * 13) ++ (f * 23)).flatten;
	f = f.collect({|x| var y=x; while({y>4}, {y = y / 2}); y});

	klank = DynKlank.ar(`[L
		f,
		Array.geom(f.size, 1.0, 0.94),
		Array.rand(f.size, 0, pi)
	], excite, hz, 0, 1/hz * decayRatio);
	snd = Mix.new(klank.flatten.clump(2));
	snd = snd + RLPF.ar(excite, Array.fill(2, {|i| [hz*(1+(1-i)), hz/(i+2)] * 0.5 * LFNoise2.ar(1/23, 0.5, 1.25)}), rlpfAmp);
	snd = Limiter.ar(snd + (snd.tanh * 0.5), 1.0, 0.5) * amp;
	Mix.new(snd)
}