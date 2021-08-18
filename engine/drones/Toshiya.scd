// @infinitedigits                                                                                   
// Toshiya
// Object-bound resonate space

{
	arg hz=440,amp=1.0;
	var snd,fx,y,z;
	var note=hz.cpsmidi;
	snd=Pan2.ar(SinOsc.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8))/12*amp,SinOsc.kr(0.1,mul:0.2));
	snd=snd+Mix.ar({
		var osc1,osc2,env,snd;
		snd=SinOsc.ar((note+TChoose.kr(Impulse.kr(rrand(1/30,1/5)),[0,9,4,14,5,2,17])).midicps);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000),2);
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/NRand(10,20,3) );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/12*amp
	}!12);
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*10));


	// reverb predelay time :
	z = DelayN.ar(snd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.01,0.06)*y);

	// add some klank underneath everything
	snd=snd+(Amplitude.kr(snd)*VarLag.kr(LFNoise0.kr(1/1),1,warp:\sine).range(0,0.5)*Klank.ar(`[[hz, hz*2+23, hz*4+53], nil, [1, 1, 1]], PinkNoise.ar([0.007, 0.007])));

	snd=LPF.ar(snd,15000);
	snd=HPF.ar(snd.tanh/2,20);
}
