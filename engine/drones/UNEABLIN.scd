// @zebra
//z =
{
	arg hz=110, amp=1, dt=66, modScale=7;

	var ratios = [1, 3/2, 2, 6/5, 8/3, 12/5, 14/4, 1/2, 3/4, 1/4];
	var amps = [2, -6, 0, -8, -9, -5, -10, -2, -7, -4].dbamp;
	var n = ratios.size;
	var fb = LocalIn.ar(n);
	var mod = ratios.collect({|r| LFSaw.kr(1/(dt*r*7), modScale) });
	var phase = ratios.collect({|r,i|
		DelayL.ar(fb.wrapAt(i+1), 0.2, LFSaw.ar(1/(dt*r*4)).wrap(1/16, 0.19).lagud(0.0077, 0.0277)) * mod[i]
	});
	var sines = ratios.collect({ arg r, i;
		SinOsc.ar(hz * r + [r*0.25, r* -0.25], phase.wrapAt(i+2), amps[i]);
	});
	var snd;

	sines = Mix.new(sines.flatten.clump(n));
	hz = hz.lag(4.0);
	LocalOut.ar(sines.reverse);
	snd = Array.fill(n, {arg i;
		Pan2.ar(sines[i], SinOscFB.ar(1/dt, LFSaw.kr(1/(dt * ratios[i] * 8), i/n, 2, 2)))
	});
	snd = RLPF.ar(snd, (hz*ratios*2), LFTri.kr(1/(dt * ratios * ratios.sum), 0.04, 0.2)) * amps;
	 snd = Mix.new(snd.flatten.clump(2)) / n;
	snd = snd * amp * 0.3 * Linen.kr(attackTime:5.55);
	//Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd;
}
.play(s);

//z.set(\hz, 330);