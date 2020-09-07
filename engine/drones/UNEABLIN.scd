// @zebra
{
	arg hz=110, amp=0.125, dt=66, modScale=7;

	var ratios = [1, 23/22, 17/16, 13/12];
	var n = ratios.size;
	var fb = LocalIn.ar(n);
	var mod = Array.fill(n, { LFNoise2.ar(1/dt, modScale) });
	var phase = Array.fill(n, { arg i;
		DelayL.ar(fb.wrapAt(i+1), 0.2, LFNoise2.ar(1/dt, 0.05, 0.06)) * mod[i]
	});
	var sines = ratios.collect({ arg r, i;
		SinOsc.ar(hz * r, phase.wrapAt(i+2));
	});
	var snd;
	LocalOut.ar(sines);
	snd = Array.fill(n, {arg i;
		Pan2.ar(sines[i], SinOscFB.ar(1/dt, LFNoise2.ar(1/dt, 2, 2)))
	});
	snd = Mix.new(snd);
	snd.postln;
	snd = RLPF.ar(snd, (hz*16).min(SampleRate.ir/2), LFNoise2.ar(1/dt, 0.3, 0.31));
	snd * amp
}