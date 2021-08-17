// @zebra
//z =
{
	arg hz=110, amp=1.0, spring=0.253, damp=0.0088, decay=12.0, fbamt=0.88, crack=1.97;
	var r1 = [0.25, 0.5, 1, 3, 2, 7/4, 10/4];
	var r2 =[1, 3/2, 2, 9/4, 8/3, 14/4];
	var sprng = Mix.new((DynKlank.ar(`[r1, (1/r1).min(1), r2], HPF.ar(Crackle.ar, 10), hz * [2,4], 0.125) / r1.size * -23.dbamp).flatten.clump(2));
	var plck = RLPF.ar(
		Pulse.ar(hz * r1,
			EnvGen.kr(Env.perc, Dust.kr(0.7), 0.2, 0.4, LFNoise1.kr([0.1, 0.1], 1.0, 2.0))
		),
		hz * (LFTri.kr(1/(32*[11, 15, 21, 27, 49]), [0, 0.7, 1.5, 1, 0.4], 3.0)) * EnvGen.kr(Env.perc, Dust.kr(0.7), 2.0, 3.0, LFTri.kr(1/(16*r1), 0, 1.0, 2.0)),
		EnvGen.kr(Env.perc, Dust.kr(0.7), 0.1, 0.8, LFTri.kr(1/(16*r2), 0, 1.0, 2.0))
	) * [0, 0, 2, -9, -4, -9, -12].dbamp;
	var snd = Mix.new((RLPF.ar((sprng *0.6).tanh, (hz*r2).min(6000), 0.2) + (plck * 0.13)).flatten.clump(2));
	var shiftu = PitchShift.ar(snd, r1 + LFTri.kr(1/(16*r1), 0, 0.07, 0.021), windowSize:0.23, timeDispersion:0.21);
	var shiftd = PitchShift.ar(snd, r2/2 + LFTri.kr(1/(16*r2), 2, 0.07, 0.019), windowSize:0.36, timeDispersion:0.17);
	var lpf = RLPF.ar(Mix.new(shiftu, shiftd), hz * [r1, r2].flatten, 0.8) * 0.5;
	var fb = AllpassC.ar(LocalIn.ar(2), 0.2, (1/r2 + LFNoise1.ar(0.038, 0.01)).min(0.19)) * fbamt;
	LocalOut.ar(Mix.new(lpf.flatten.clump(2).reverse.softclip + fb*0.1));
	snd = Mix.new((amp * 0.23 * (snd + lpf)).flatten.clump(2));
	snd = snd * Linen.kr(attackTime:6.22);
	Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd
}
//.play(s);