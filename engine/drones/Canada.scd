// @infinitedigits                                                                                   
// Canada
// Scientific, detuned, dignified.

{
	arg amp=1.0,hz=240;
	var snd,snd2;
	// var detuning=MouseX.kr(0.001,1,1);
	var detuning=VarLag.kr(TExpRand.kr(0.0001,1,Impulse.kr(1/10)),10,warp:\sine);
	var changes=VarLag.kr(TExpRand.kr(0.1,10,Impulse.kr(1/10)),10,warp:\sine);
	hz=hz/2;
	snd=Splay.ar({
		var sound, freqs, envs, rings, numvoices, env;
		var pink;
		var time=LFNoise0.kr(1/30).range(10,30)/changes;
		freqs={
			var dd=[ 0, 12, 24, 36, 48];
			var dd2=[ 0, 2, 4, 5, 7, 9, 11 ];
			(hz.cpsmidi+
				SelectX.kr(detuning,[0,rrand(-1.5,1.5)])+
				Demand.kr(Impulse.kr(1/time),0,Dxrand(dd,inf))+Demand.kr(Impulse.kr(1/time),0,Dxrand(dd2,inf))).midicps
		}!2;
		rings = {
			LFNoise0.kr(1/time).range(0.2,1)
		}!2;
		envs = {
			LFNoise0.kr(1/time).range(0.1,0.8);
		}!2;

		pink = PinkNoise.ar(2.reciprocal!2)*VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.01,0.5);
		sound = DynKlank.ar(`[freqs,envs,rings], LPF.ar(pink,hz*VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(2,6)) );
		sound = sound * EnvGen.kr(Env.linen(LFNoise0.kr(1/time).range(0.1,time),LFNoise0.kr(1/time).range(0.1,time)/3,LFNoise0.kr(1/time).range(0.1,time)), Impulse.kr(1/time));

		// limit the bell klanks
		Limiter.ar(sound,VarLag.kr(LFNoise0.kr(1/10),10,warp:\sine).range(0.1,0.2),0.1)
	}!6);
	snd=LeakDC.ar(snd);
	snd = LPF.ar(snd, 4000);
	snd = HPF.ar(snd, hz/2);
	snd=Compander.ar(snd,snd);
	snd=Limiter.ar(snd,0.95,0.1);
	snd=snd*amp;
}
