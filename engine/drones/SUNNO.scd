{
	arg hz=110,amp=1.0;
	var guitar,finalsnd,z,y,bass,basshz;
	hz=hz*VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.95,1);
	guitar={
		arg doFeedback=0,freqMod;
		var snd, string, delay;
		string = { |freq,odd|
			var delay,pluck,pick,snd2;
			delay = freq.reciprocal;
			pick=Impulse.kr(0)+Trig.kr(Dust.kr(0.1),0.5);
			pluck=SinOsc.ar(Line.ar(1000, 50, 0.01)) * Env.perc(0.001, 0.01).ar;
			pluck=pluck+(SinOsc.ar(EnvGen.ar(Env.new([0,1000,50],[0.002,0.01]),gate:pick))*EnvGen.ar(Env.perc(0.0001, 0.01),gate:pick));
			snd2=Pluck.ar(pluck, pick, delay, delay, 1000*odd, 0.1);
			snd2=DelayC.ar(snd2, Rand(0.01,0.06),LFNoise1.kr(Rand(1,10),0.01,0.02)/15 );
			snd2=snd2*SinOsc.kr(Rand(1,100)/1000,Rand(1,10)).abs;
		};
		snd = string.(hz*freqMod,1.neg) + string.(hz*1.5*freqMod,1);
		snd = snd + (HPF.ar(LocalIn.ar(1), 30) * VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine).range(-60,0).dbamp);
		snd = CrossoverDistortion.ar(snd,0.5);
		snd = (snd * 10.dbamp).tanh;
		// inspired by https://sccode.org/1-5aC
		snd = RLPF.ar(snd, hz*4, LinExp.kr(VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,0.2,0.6));
		snd = (snd * 32.dbamp).tanh;
		snd = RLPF.ar(snd, hz*2, LinExp.kr(VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine),-1,1,0.1,0.5));
		snd = (snd * 32.dbamp).tanh;
		snd = BHiShelf.ar(snd, hz*6, 1, -2.0);
		snd = LeakDC.ar(snd);
		LocalOut.ar(snd*doFeedback);
		snd = DelayC.ar(snd, 0.1, SinOsc.kr(Rand(1,100)/100, [0, 1pi]).range(0, 1e-4));
		snd=Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine));
	};

	finalsnd = guitar.(1,1)+guitar.(0,1)+guitar.(0,1)+guitar.(0,0.5)+(0.1*guitar.(1,2));
	finalsnd=finalsnd/30;

	//basshz=DC.kr(hz/2);
	//{basshz=Select.kr(basshz>150,[basshz,basshz/2])}!4;
	basshz=[hz/2,hz/2*1.5];
	bass=Pulse.ar(basshz,width:SinOsc.kr(1/3).range(0.2,0.4));
	bass=LPF.ar(bass,hz*SinOsc.kr(0.1).range(1,2));
	bass=bass*(60/hz);
	finalsnd=finalsnd+(bass*((SinOsc.kr(0.123).range(-25,-16)).dbamp));

	// reverb predelay time :
	z = DelayN.ar(finalsnd, 0.048);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	finalsnd=finalsnd+(VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.025,0.06)*y);

	
	finalsnd*amp;
}
