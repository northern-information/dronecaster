// @infinitedigits
// Coil
// Traversing the tunnels of goats.

{
	arg hz=170,amp=1.0;
	var y,z;
	var detuning=0.5;
	var finalsnd;
	finalsnd=Mix.ar({
		arg i;
		var snd,env,env2,env3,snd1,snd2;
		var attack,release,pulse,pulseHit;
		var panl,panr,whichsound;
		pulse=Dust.kr(0.5)+Impulse.kr(0);
		pulseHit=Dust.kr(1);
		attack=Latch.kr(LFNoise0.kr(0.2).range(0.5,3),pulse);
		release=Latch.kr(LFNoise0.kr(0.2).range(0.1,3),pulse);
		env=EnvGen.ar(Env.new([0,1,0],[attack,release],curve:\sine),gate:Trig.kr(pulseHit,attack+release));

		panl=TChoose.kr(pulse,[-1,1]);
		panr=TChoose.kr(pulse,[-1,1]);
		whichsound=TChoose.kr(pulse,[0,1]);
		env2=EnvGen.ar(Env.new([0,panl,panr],[0.001,attack+release]),gate:Trig.kr(pulseHit,attack+release));
		env3=EnvGen.ar(Env.new([0,whichsound,1-whichsound],[0.001,attack+release]),gate:Trig.kr(pulseHit,attack+release));

		snd1=SinOscFB.ar(hz+(SinOsc.kr(0.1*i).range(hz.cpsmidi-(detuning*i),hz.cpsmidi+(detuning*i))),SinOsc.kr(0.2,Rand(0,2*pi)).range(0,0.5));
		snd2=WhiteNoise.ar(0.1);
		snd=SelectX.ar(env3,[snd1,snd2]);
		snd=BLowPass.ar(snd,hz*6,0.6);
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		snd=snd*env;
		snd=Pan2.ar(snd,env2)
	}!12);

	finalsnd=finalsnd*amp;

	// reverb predelay time :
	z = DelayN.ar(finalsnd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	finalsnd=finalsnd+(0.05*y);

	finalsnd=finalsnd*(-20.dbamp);
}
