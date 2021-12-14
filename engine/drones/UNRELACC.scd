// @zebra
//z =
{
	arg hz=110, amp=1.0; //, hzRatio=2.0;
	var hzRatio=2.0;
	var snd;
	var aaa, bbb;
	var ratios = [0.5, 1, 4/3, 7/4, 2, 12/5];
	var amps = [0, 0, 0, -5, -4, -7].dbamp;
	hz = (hz*2).lag(4);
	aaa = ratios.collect({|r,i| LFTri.kr(1/(r*9)).linlin(-1, 1, 1.01, 1.2)});
	bbb = ratios.collect({|r,i| LFTri.kr(1/(r*8)).linlin(-1, 1, 0.11, 0.214)});
	snd = ratios.collect({
		arg r, i;
		Pan2.ar(
			HenonC.ar(
				hz * hzRatio * r + LFSaw.kr((i+1)*(i+2)/14*(i*3), 0.04),
				aaa[i], bbb[i], 0, 0.7
			),
			SinOsc.ar((i+1)/31, (i*14).wrap(0, pi), 0.77)
		) * amps[i]
	});
	snd = LeakDC.ar(snd, 0.994);
	snd = Mix.new(snd.flatten.clump(2));
	snd.postln;
	snd = snd * amp * -6.dbamp * Linen.kr(attackTime:6.66);
	// Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd;
}
//.play(s);