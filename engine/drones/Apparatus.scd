/*
Apparatus by Josue Arias
Drone simulating old sinusoidal generators
-
Original parts by Zé Craum, modified by Bruno Ruviaro, Josh Mitchell and Josue Arias
*/

{
	arg hz = 128, amp = 0.5,
	//Noise Arguments (mainsDepth is 0 to 1)
	noiseAmp = 0.08, mainsDepth = 0.5, mainsHz = hz,
	//Sine Arguments
	vrate = 0.19, vrate2 = 0.67, vdepth = 0.007, vdepth2 = 0.01, sineClip = 0.825, 
	//interferences
	interference = 1.4;

	var noise, snd, snd2, snd3, snd4, vibrato, vibrato2, mix, dust, sndall, lfo1, lfo2;

	noise = PinkNoise.ar(noiseAmp * LFPar.ar(mainsHz * 2).range((1 - mainsDepth), 1));
	noise = noise + LFPar.ar(hz: hz, mul: noiseAmp/8);

	vibrato = hz * LFNoise2.ar(vrate).range(1/(1 + vdepth), (1 + vdepth));
	vibrato2 = (hz * 3) * LFNoise2.ar(vrate2).range(1/(1 + vdepth2), (1 + vdepth2));
	
	lfo1 = SinOsc.ar(0.009, 0.0, 1.0);
	lfo2 = SinOsc.ar(0.011, 2pi, 1.0);

	snd = Clip.ar(LFTri.ar(vibrato), -1 * sineClip, sineClip).softclip;
	snd = ((snd + noise) * amp);
	snd2 = Clip.ar(LFTri.ar(vibrato2), -1 * sineClip, 0.5).softclip;
	snd2 = (snd2 * (amp / 7));
	snd3 = Clip.ar(LFTri.ar(hz * 5 - (lfo2)), -1 * sineClip, 0.65).softclip;
	snd3 = (snd3 * lfo1);
	snd3 = (snd3 * (amp / 10));
	snd4 = Clip.ar(LFTri.ar(hz * 2 - (lfo1)), -1 * sineClip, 0.70).softclip;
	snd4 = (snd4 * lfo2);
	snd4 = (snd4 * (amp / 6));
	sndall = (snd + snd2 + snd3 + snd4);
	dust = (Dust2.ar(10, 1) + Crackle.ar(1.95, 0.2) + SinOsc.ar((PinkNoise.ar(0.5) * 7500) + 40, 0, 0.011));
	dust = HPF.ar(dust, 25);
	dust = BPF.ar(dust, (hz * 8), 1);
	dust = ((dust * (interference + noise)) * amp);
	mix = (sndall + dust);
	//mix = (Decimator.ar(mix, 16000, (noise + 7)) * 0.33) + (mix * 0.67);
	mix = LeakDC.ar(mix);
	mix.dup;
	
}
