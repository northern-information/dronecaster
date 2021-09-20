// @infinitedigits
// Rehberg
// Dense, distorted, overwhelming.

{
	arg hz=55,amp=0.5;
	var snd,envinv,freq;
	var wobble_rpm=33;
	var wobble_amp=SinOsc.kr(Rand(0.01,0.02)).range(0.1,0.5);
	var wobble_exp=39;
	var flutter_amp=SinOsc.kr(Rand(0.01,0.02)).range(0.1,0.5);
	var flutter_fixedfreq=6;
	var flutter_variationfreq=2;
	var rqmin=0.005, rqmax=0.008;
	var signed_wobble = wobble_amp*(SinOsc.kr(wobble_rpm/60)**wobble_exp);
	var wow = Select.kr(signed_wobble > 0, signed_wobble, 0);
	var flutter = flutter_amp*SinOsc.kr(flutter_fixedfreq+LFNoise2.kr(flutter_variationfreq));
	var combined_defects = 1 + wow + flutter;
	freq=A2K.kr(K2A.ar(hz));
	freq=freq*(1-EnvGen.kr(Env.perc(LFNoise0.kr(0.1).range(0.0,1.0),LFNoise0.kr(0.1).range(0.0,1.0),0.5),Dust.kr(LFNoise0.kr(0.1).range(0.001,0.1))));
	freq=freq*(1+EnvGen.kr(Env.perc(LFNoise0.kr(0.1).range(0.0,1.0),LFNoise0.kr(0.1).range(0.0,1.0),1),Dust.kr(LFNoise0.kr(0.1).range(0.001,0.1))));
	envinv=1-EnvGen.ar(Env.perc(LFNoise0.kr(0.1).range(0.0,0.2),LFNoise0.kr(0.1).range(0.0,0.2),0.9),Changed.kr(freq));
	snd=Pulse.ar([freq,freq+0.1],LFTri.kr([0.5,0.51]/3).range(0.2,0.8));
	snd=snd+LPF.ar(WhiteNoise.ar(SinOsc.kr(Rand(0.01,0.02)).range(0.005,0.01)),Lag.kr(LFNoise0.kr(freq).range(20,20000),0.1));
	snd=Fold.ar(snd,-0.2,0.2);
	snd=DFM1.ar(snd,freq*24,0.3);
	snd=DFM1.ar(snd,90,type:1);
	snd=snd+SinOsc.ar(freq*1.5,SinOsc.kr(freq)*2,mul:SinOsc.kr(Rand(0.01,0.02)).range(0.01,0.2));
	snd=snd+BPF.ar(snd,freq*combined_defects, 2,SinOsc.kr(Rand(0.01,0.02)).range(0.01,0.5));
	snd=FreeVerb.ar(snd,
		room:SinOsc.kr(0.1).range(0.3,0.6),
		mix:LFNoise0.kr(0.2).range(0.1,0.6),
	);
	snd=snd*amp*envinv*0.35;
	//Out.ar(0,snd*amp*envinv);
}
