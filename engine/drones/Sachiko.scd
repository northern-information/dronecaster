// @infinitedigits
// Sachiko
// High-tone space-cutting

{
	arg hz, amp;
	var snd;
	var local;
	var z,y;
	var freq=hz;
	snd=Array.fill(4,{arg i;
		var snd2;
		var freq2=freq;//*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp,///(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

		// add delay!
		snd2 = snd2 + CombC.ar(snd2,
			maxdelaytime:0.5,
			delaytime:rrand(0.2,0.5)+VarLag.kr(LFNoise0.kr(rrand(1/60,1/3)),1/2,warp:\sine).range(-0.2,0),
			decaytime:rrand(5,15),
		);
		snd2=LeakDC.ar(snd2); // remove DC bias JIC
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// global moog filter
	snd=MoogFF.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/4),4,warp:\sine),-1,1,hz*10,18000));

	// reverb predelay time :
	z = DelayN.ar(snd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(0.01*y);
   	snd=snd*amp/2;
}
