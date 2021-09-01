// @infinitedigits
// Malone
// Thick, organ, stepped.
 
{
	arg hz=110,amp=1.0;
	var snd,env,z,y,sndgate,chord,chordchange;
	var detuning=0.04;

	chordchange=Impulse.kr(0.06)+Impulse.kr(0)+Dust.kr(0.005);
	chord=Demand.kr(chordchange,0,Dseq([
		[0,12],
		[0,4,7,12],
		[-1,4,7,12],
		[0,0,7,12,12],
		[0,0,7,12,12],
		[0,4,7,12],
		[-3,4,7,12],
		[-3,4,7,11],
		[0,12],
		[0,4,7,12],
		[0,4,7,11],
		[-3,4,7,9],
		[0,0,7,12,12],
	],inf));
	snd=Mix.ar(Array.fill(8,{
		arg i;
		var hz_,snd_,chord_;
		chord_=Latch.kr(chord,chordchange);
		hz_=(hz.cpsmidi+TChoose.kr(Dust.kr(0.1),chord_)).midicps;
		hz_=(hz_.cpsmidi+SinOsc.kr(Rand(0.1,0.5),Rand(0,pi)).range(detuning.neg,detuning)).midicps;
		snd_=Pulse.ar(hz_,0.17);
		snd_=snd_+Pulse.ar(hz_/2,0.17);
		snd_=snd_+Pulse.ar(hz_*2,0.17);
		snd_=snd_+LFTri.ar(hz_/4);
		snd_=RLPF.ar(snd_,hz_*6,LFTri.kr([0.5,0.45]).range(0.3,1));
		// snd_=RLPF.ar(snd_,hz_*SinOsc.kr(Rand(0.1,0.2),Rand(0,pi)).range(3,10),LFTri.kr([0.5,0.45]).range(0.1,1));
		snd_=snd_*LFPar.ar(Trig.kr(chordchange,Rand(1,8))*3.5).range(0,1);
		Pan2.ar(snd_,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/5/8
	}));

	env=EnvGen.ar(Env.new([0,1],[4]));
	snd=MoogLadder.ar(snd,hz*40);

/*	snd=LPF.ar(snd,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,18000));
	snd=HPF.ar(snd,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,10,hz));*/

	// reverb predelay time :
	z = DelayN.ar(snd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	snd=snd+(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.01,0.03)*y);

	snd=HPF.ar(snd,20);
	snd=snd/2*amp
}
