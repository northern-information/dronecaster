// @zebra
{
	arg hz=110, amp=0.1, hzRatio=2.0,
	 aMin=1.0, aMax=1.3,
	 bMin=0.1, bMax=0.3;
	var snd;
	var aArr, bArr;
	// defines tonality:
	var ratios = [0.5, 1, 2, 15/8, 6/5];
	//
	aArr = Array.fill(ratios.size, {LFNoise2.ar(1/19).linlin(-1, 1, aMin, aMax)});
	bArr = Array.fill(ratios.size, {LFNoise2.ar(1/29).linlin(-1, 1, bMin, bMax)});
	snd = ratios.size.collect({
		arg i;
		Pan2.ar(
			HenonL.ar(
				hz * hzRatio * ratios + LFNoise2.ar(1/14, 0.4),
				aArr[i], bArr[i], 0, 0.1
			),
			SinOsc.ar(1/31, (i*14).wrap(0, pi))
		)
	});
	snd = LeakDC.ar(snd);
	snd = Mix.new(snd.flatten.clump(2));
	snd = (RLPF.ar(snd, hz*6) + RLPF.ar(Normalizer.ar(snd.tanh), hz * 0.5, 0.2));
	snd * amp * 0.5
}
