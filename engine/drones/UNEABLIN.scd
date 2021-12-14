// @zebra
//z =
{
	arg hz=110, amp=0.4; //, dt=23;
	var delbuf= LocalBuf.new(SampleRate.ir * 8.0);

	var dt = 23;
	var ratios = [1, 3/2, 2, 6/5, 9/5, 1/2];
	var amps = [2, -6, 0, -8, -9, -5, -10, -4].dbamp;
	var n = ratios.size;
	var fb = LocalIn.ar(n);
	var modscale = LFTri.kr(1/(dt*4), 0).squared * 0.34;
	var mod = ratios.collect({|r, i| LFSaw.kr(1/(dt*r*7+i), i.linlin(0, n-1, 3, 0) + 0.125.rand, modscale) });
	var phase = ratios.collect({|r,i|
		BufDelayL.ar(delbuf, fb.wrapAt(i+1), LFSaw.ar(1/(dt*r*4+i), i*2/n).linlin(-1, 1, 1/16, 7.99).lagud(0.0077, 0.0277)) * mod[i]
	});
	var oscs;
	var rqmod;
	var snd;
	var dst = { arg x; (x * 1.5) - (x.cubed * 0.5) };

	// amp.poll;

	oscs = ratios.collect({ arg r, i;
		var x = SinOsc.ar(hz * r + [r*0.25, r* -0.25], phase.wrapAt(i+2), amps[i]);
		var xd = dst.value(x);
		var xdd = dst.value(xd);
		var xddd = dst.value(xdd);
		var src = [x, xd, xdd, xddd,
			InsideOut.ar(xddd), InsideOut.ar(xdd), InsideOut.ar(xd), InsideOut.ar(x)];
		SelectX.ar(LFTri.kr(1/dt * (r+i/16), i/n * 0.125).linlin(-1,1,0,src.size-1), src) 
	});

	hz = hz.lag(4.0);
	LocalOut.ar(oscs);
	snd = Array.fill(n, {arg i;
		Pan2.ar(oscs[i], SinOscFB.ar(1/dt, LFTri.kr(1/(dt * ratios[i]), i.linlin(0,n-1,1,7), 0.8)));
	});
	rqmod = LFTri.kr(1/(dt * ratios * ratios.sum), 0.2.rand, 0.1, 0.34/amps.rotate(5));
	//rqmod.poll;
	snd = RLPF.ar(snd, (hz*ratios.rotate(1) * 2), rqmod);
	snd = Mix.new(snd.flatten.clump(2)) / n;
	snd = snd * amp * 0.3 * Linen.kr(attackTime:5.55);
	//Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd;
}
//.play(s);

//z.set(\hz, 330);