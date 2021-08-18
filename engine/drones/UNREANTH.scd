// @zebra
//z =
{
	arg hz=220, amp=1.0;
	var seqbuf, seqwr, seqrd;
	var dt, ph, rst, rat, twr, trd;
	var n=64, m=17;
	var r1, r2;
	var scl = [
		1,
		20/9,
		//9/8,
		6/5,
		//5/4,
		8/3,
		3,
		8/5,
		//5/3,
		//9/5,
		//15/8,
		7/4,
		2,
		4,
		9/4
	];
	var deg, prat, freq;
	var sines, sinemix, delbuf, del, dst;
	var saws, ring;
	var snd;

	hz = hz.lag(5.5);

	//--- sequence
	r1 = [3/2, 12/5, 16/5];
	r2 = [1, 9/4, 5/2];
	rat = 19/23;
	rst = Impulse.kr(1/23);
	seqbuf = LocalBuf(n);
	dt = SinOscFB.kr(1/117, 11).linlin(-1,1,1/17,1/4) / 8;
	ph = Phasor.kr(rst, rat, n);
	twr = Pulse.kr(r1 / dt);
	trd = Pulse.kr(r2 / dt);
	seqwr = Demand.kr(twr, 0, Dbufwr(ph, seqbuf, Dseries(0, 1, n)));
	seqrd = Demand.kr(trd, 0, Dbufrd(seqbuf, ph + m));
	deg = (seqrd / n * (scl.size - 0.01)).floor;
	//deg.poll;

	//-- osc
	sines = scl.collect({|r,i|
		Array.fill(2, {|j|
			SinOsc.ar(hz * r + j) * deg[j].eq(i).lag2ud(0.01, LFTri.kr(1/(1+i+j), j).linlin(-1,1, 1.7, 4.4))
		})
	});
	sinemix = Mix.new(sines.flatten.clump(2)) / scl.size;

	delbuf = Array.fill(2, {LocalBuf(9 * SampleRate.ir, 1)});
	del = BufDelayC.ar(delbuf, LocalIn.ar(2), SinOscFB.ar(1/29, 1.7777, 0.1, [7, 8]));
	del = Mix.new(del.flatten.clump(2));

	dst = sines.collect({ arg x, i;
		var ax = x.abs;
		var a = LFTri.kr((i+2)/(i+7), i % 2).linexp(-1, 1, 0.99, 0.01);
		x * (ax + a) / (x * x + (a - 1) * ax + 1)
	});
	dst = Mix.new(dst) * 0.125;

	del = del + PitchShift.ar(Mix.new(del), 0.17, [2, 4], 0.001, 0.09, 0.07);
	del = LeakDC.ar(del * 0.5).softclip;

	saws = (Mix.new(Saw.ar([hz + (1/77),hz/2-(1/66),hz-(1/51), hz/2+(1/86)]).flatten.clump(2)) * 0.124);
	saws = SVF.ar(saws, hz*2, 0.05 + LFTri.kr(1/19, mul:0.04, add:0.04));

	ring = DiodeRingMod.ar(sinemix, saws) * -14.dbamp;
	ring = HPF.ar(ring, hz);

	saws = saws + PitchShift.ar(saws, 0.2, 0.5, 0.002, 0.06);

	snd = (sinemix + del + saws + ring) * 0.5 * amp;
	snd = Mix.new(snd.flatten.clump(2));

	LocalOut.ar(Mix.new((del.reverse + sinemix.reverse + ring).flatten.clump(2)));

	//Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd * Linen.kr(attackTime:12)

}
//.play(s);
//
//z.set(\hz, 440*2);