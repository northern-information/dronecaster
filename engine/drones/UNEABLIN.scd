// @zebra
//z =
{
	arg hz=110, amp=1, dt=43;
	var delbuf= LocalBuf.new(SampleRate.ir * 8.0);

	var ratios = [1, 3/2, 2, 6/5, 8/3, 3, 7/2, 1/2];
	var amps = [2, -6, 0, -8, -9, -5, -10, -4].dbamp;
	var n = ratios.size;
	var fb = LocalIn.ar(n);
	var modscale = LFTri.kr(1/(dt*4), 0).squared * 0.34;
	var mod = ratios.collect({|r, i| LFSaw.kr(1/(dt*r*7+i), i.linlin(0, n-1, 3, 0), modscale) });
	var phase = ratios.collect({|r,i|
		BufDelayL.ar(delbuf, fb.wrapAt(i+1), LFSaw.ar(1/(dt*r*4+i), i*2/n).linlin(-1, 1, 1/16, 7.99).lagud(0.0077, 0.0277)) * mod[i]
	});
	var sines;
	var rqmod;
	var snd;

	sines = ratios.collect({ arg r, i;
		var x = SinOsc.ar(hz * r + [r*0.25, r* -0.25], phase.wrapAt(i+2), amps[i]);
		var dst = (3*x*0.5) - 0.5*(x.cubed);
		SelectX.ar(LFTri.kr(1/dt * (r+i/16), i/n).abs, [x, dst]);
	});

	hz = hz.lag(4.0);
	LocalOut.ar(sines);
	snd = Array.fill(n, {arg i;
		Pan2.ar(sines[i], SinOscFB.ar(1/dt, LFTri.kr(1/(dt * ratios[i]), i.linlin(0,n-1,1,7), 0.8)));
	});
	rqmod = LFTri.kr(1/(dt * ratios * ratios.sum), 0, 0.1, 0.34/amps.rotate(5));
	//rqmod.poll;
	snd = RLPF.ar(snd, (hz*ratios.rotate(1) * 2), rqmod);
	snd = Mix.new(snd.flatten.clump(2)) / n;
	snd = snd * amp * 0.3 * Linen.kr(attackTime:5.55);
	//Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd;
}
//.play(s);

//z.set(\hz, 330);