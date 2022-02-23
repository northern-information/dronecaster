// @zebra
//z =
{
	arg hz=110, amp=1.0; //, //spring=0.253, damp=0.0088, decay=12.0, fbamt=0.1, crack=1.97;
	var spring=0.253, damp=0.0088, decay=12.0, fbamt=0.1, crack=1.97;
	var r1 = [0.25, 0.5, 1, 3, 2, 9/4, 10/4];
	var r2 =[1, 3/2, 2, 9/4, 8/3, 14/4];
	var amps = [0, 0, 2, -9, -4, -9, -12].dbamp;
	
	var please = r2.collect({arg r,i;
		var pulse_hz = (hz * r) + LFNoise1.kr(0.0625 * r, 0.12);
		var width = EnvGen.ar(Env.perc, Impulse.kr(r * 0.25), timeScale:LFTri.kr(1/(16*r2[i]), 0, 4.0, 3.0));
		var fc = hz * 2 * r2.wrapAt(i+[2, 4, 6]);
		var rq = LFTri.ar(1/(16*r), r1.wrapAt(i+3).wrap(0, 2)).linlin(-1,1, 0.13, 0.34);
		var pulse;
		width = width.linlin(0, 1, 0.25, 0.8);
		pulse = Pulse.ar(pulse_hz, width, mul:amps[i]);
		Pan2.ar(
			RLPF.ar(pulse, fc.min(12000), rq)
		, i.linlin(0,r1.size-1, -0.8, 0.8))		
	});
	
	var snd = Mix.new(please) / please.size;
	var shiftu = PitchShift.ar(snd, 2, windowSize:0.23, timeDispersion:0.11);
	
	var shifted = Mix.new(
		(HPF.ar(RLPF.ar(shiftu, hz * 8 * [r1, r2].flatten.min(12000), 0.8), 20)* 0.5)
		.flatten.clump(2);
	);
	var del, lout, lin;
	snd = Mix.new(snd, shifted.reverse);

	lin = LocalIn.ar(2);
	del = BufAllpassC.ar(
		Array.fill(2, { LocalBuf(SampleRate.ir * 4) }),
		lin, //[lin, lin.reverse],
		LFTri.ar([1/r1.sum, 1/r2.sum]).linlin(-1, 1, 2.9, 3.8)
	);

	lout = Mix.new( (snd + (del*0.27)).flatten.clump(2) );
	lout = LPF.ar(HPF.ar(lout, 10), 10101).reverse;
	LocalOut.ar(lout);
	
	snd = Mix.new( (snd+ (del*0.33)).flatten.clump(2) ) * amp * 0.23;
	snd * Linen.kr(attackTime:7.77)		
}