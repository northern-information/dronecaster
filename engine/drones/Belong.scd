// @infinitedigits                                                                                   
// Belong
// Thick, enveloping, shimmering.

{
	arg hz=215, amp=0.5,buf=0;
	var note,bass,basshz,bassnote,notes_all,chords,emin,cmaj,gmaj,dmaj;
	var env, env_times,env2, env2_times, env_select;
	var pulse, pulse_fourth,pulse_two,pulse_half,pulse_quarter, pulse_eighth, pulse_four,pulse_five, pulse_four_ar, pulse_eight, pulse_sixteen, pulse_thirtytwo;
	var bpm;
	var snd, snd2, sndkick;
	var pw,pr,sndr;
	var y,z;
	var recamt;

	bpm=rrand(60,130);

	emin=[4,7,11];
	cmaj=[0,4,7];
	gmaj=[7,11,14];
	dmaj=[2,6,9];

	chords=[
		emin.scramble,
		cmaj.scramble,
		gmaj.scramble,
		dmaj.scramble
	].scramble;
	notes_all=chords.flop.flatten;

	// pulse
	pulse=Impulse.kr(bpm/60/4);
	pulse_half=Impulse.kr(bpm/60/4/2);
	pulse_quarter=Impulse.kr(bpm/60/4/4);
	pulse_eighth=Impulse.kr(bpm/60/4/8);
	//pulse_two=Impulse.kr(bpm/60/4*2);
	//pulse_four=Impulse.kr(bpm/60/4*4);
	pulse_five=Impulse.kr(bpm/60/4*5);
	//pulse_four_ar=Impulse.ar(bpm/60/4*4);
	//pulse_sixteen=Impulse.kr(bpm/60/4*16);
	//pulse_thirtytwo=Impulse.kr(bpm/60/4*32);
	//pulse_eight=Impulse.kr(bpm/60/4*8);
	pulse_fourth=Impulse.kr(bpm/60/16);

	// note (randomly selected each pulse)
	bassnote=ArrayMin.kr(Demand.kr(pulse,0,Dseq(chords,inf)))[0];
	note=Demand.kr(Select.kr(
		TExpRand.kr(0.01,6,pulse)
		,[pulse,pulse,pulse,pulse,pulse_five,pulse_five]
	),0,Dseq(notes_all,inf));
	note=note+Demand.kr(pulse_fourth,0,Dseq([12,-12,0,24],inf));

	// envelope (randomly generated each pulse)
	env_select=SinOsc.kr(rrand(0.1,0.2),rrand(0,2)).range(0,1);
	env_times=[TExpRand.kr(0.2,trig:pulse),TExpRand.kr(trig:pulse),TExpRand.kr(trig:pulse)];
	env_times=env_times/env_times.sum;
	env=EnvGen.ar(Env.new([0,1,1,0],4*60/bpm*env_times,curve:\sine),pulse);
	env=SelectX.ar(env_select,[DC.ar(1),env]);
	env2_times=[TExpRand.kr(0.2,trig:pulse),TExpRand.kr(trig:pulse),TExpRand.kr(trig:pulse)];
	env2_times=env2_times/env2_times.sum;
	env2=EnvGen.ar(Env.new([0,1,1,0],4*60/bpm*env2_times,curve:\sine),pulse);
	env2=SelectX.ar(env_select,[DC.ar(1),env2]);

	// oscillator
	note = note + A2K.kr(hz).cpsmidi;
	snd=Mix.ar({
		var snd_;
		snd_=SawDPW.ar(Lag.kr(note.midicps,0.02));
		snd_=DelayC.ar(snd_, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd_,0)/4
	}!10);
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6)+LFNoise0.kr(0),6,warp:\sine),-1,1,hz*8,hz*15));

	// random envelopes on either side
	snd = [snd[0] * env,snd[1]*env2];

	// layer over the tape
	recamt=EnvGen.ar(Env.new([0,0,1,1],[60/bpm*16,0.1,10000]))*0.9;
	pw=Phasor.ar(0, BufRateScale.kr(buf), 0, BufSampleRate.kr(buf)*60/bpm*16);
	//pr=Phasor.ar(0, BufRateScale.kr(buf), 0, BufSampleRate.kr(buf)*60/bpm*16);
	sndr=BufRd.ar(2,buf,pw,interpolation:2);
	snd = (snd/2) + (sndr*recamt*Clip.ar(2*amp));
	//snd = Limiter.ar(snd,0.5);
	//BufWr.ar(snd,buf,Select.ar(MouseY.kr(0,2),[pw,DC.ar(0)]).poll);
	BufWr.ar(snd*EnvGen.ar(Env.new([0,1,1,0],[0.1,(1/(bpm/60/4/4))-0.2,0.1]),Impulse.kr(bpm/60/4/4)),buf,pw);


	// bass...
	basshz=(bassnote+ hz.cpsmidi).midicps;
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	bass=Pulse.ar(Lag.kr(basshz),width:SinOsc.kr(1/3).range(0.2,0.4));
	bass=bass+LPF.ar(WhiteNoise.ar(SinOsc.kr(1/rrand(3,4)).range(1,rrand(3,4))),SinOsc.kr(0.123).range(1.5,2.5)*basshz);
	bass = Pan2.ar(bass,LFTri.kr(1/6.12).range(-0.2,0.2));
	bass = HPF.ar(bass,20);
	bass = LPF.ar(bass,SinOsc.kr(0.1).range(2,3)*basshz);
	snd=snd+((SinOsc.kr(rrand(0.1,0.3),rrand(0,2)).range(0.0,0.2)+EnvGen.kr(Env.new([0,0,1,1],[6,6,60000]),1,0.2))*bass*(-20.dbamp));


	// kick... (is it even a drone anymore...)
	sndkick={
		var out2;
		var decay=60;
		var space=decay;
		var env0, env1, env1m, out;
		var pulse_=DelayN.kr(Select.kr((SinOsc.kr(1/Rand(40,80),3.141*3/2).range(0,9)),[pulse_eighth, pulse_eighth, pulse_quarter, pulse_half, pulse_half, pulse, pulse, pulse, pulse]),bpm/60/2,bpm/60/2);
		var y,z;

		env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26*decay], [-4, -2, -4]),pulse_);
		env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]),pulse_);
		env1m = env1.midicps;

		out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
		out = out + WhiteNoise.ar(1*space);
		out = LPF.ar(out, env1m*1.5, env0);
		out = out + SinOsc.ar(env1m, 0.5, env0);

		out = out * 1.2;
		out = out.clip2(1);
		out = out*EnvGen.ar(Env.perc(0.01,2),pulse_);

		out2 = DelayN.ar(out, 0.03, 0.03);
		out2 = CombN.ar(out2, 0.1, {Rand(0.01,0.099)}!16, 4);
		out2 = SplayAz.ar(2, out2);
		out2 = LPF.ar(out2, 1500);
		5.do{out2 = AllpassN.ar(out2, 0.1, {Rand(0.01,0.099)}!2, 3)};
		out2 = LPF.ar(out2, 1500);
		out = out + (0.7*out2);
		out = BPeakEQ.ar(out,basshz,1,12);
		out= out*(-24).dbamp;
	};
	//snd = Compander.ar(snd,sndkick,0.01,1,0.01,0.01,0.2);

	// reverb
	snd2 = DelayN.ar(snd, 0.03, 0.03);
	snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!8, 4);
	snd2 = SplayAz.ar(2, snd2);
	snd2 = LPF.ar(snd2, 1500);
	4.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 3)};
	snd2 = LPF.ar(snd2, 1500);
	snd = snd + (0.4*snd2);
	snd = (snd*0.6)+((A2K.kr(amp)>0.7)*sndkick);
	snd=snd*amp;

	snd=snd*EnvGen.ar(Env.new([0,1],[5]))/2;

	snd = HPF.ar(snd,40);
	snd
}