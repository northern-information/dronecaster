// @infinitedigits
// Drumm
// Sometimes gentle, the other time intense.

{
	arg hz=440,amp=0.5;
	var snd,drop,basshz,basshz2,note,sndkind,pos,speed,p,q,osc1,osc2,osc3,y,z,stomp,stomp2,imp,intro,mainrate,introp;
	osc1=LFTri.kr(Rand(1/100,1/30),Rand(0,2*pi)).range(0,2).floor;
	osc2=LFTri.kr(Rand(1/100,1/30),Rand(0,2*pi)).range(0,2).floor;
	mainrate=Rand(0.15,0.25);
	
	speed=VarLag.kr(LFNoise0.kr(0.1),10,warp:\sine).range(1/3000,1/30);
	//speed=1/Rand(30,70);//TExpRand.kr(1/300,1/10,Dust.kr(0.1));
	p=SinOsc.kr(speed);
	q=SinOsc.kr(speed,pi/2);
	intro=EnvGen.kr(Env.new([0,0,1],[4/mainrate,4/mainrate]),Impulse.kr(0));
	
	basshz2=hz;
	basshz2=Select.kr(basshz2<200,[basshz2/2,basshz2]);
	basshz2=Select.kr(basshz2<200,[basshz2/2,basshz2]);
	snd={Pulse.ar(
		basshz2,
		Lag.kr(
			A2K.kr(FBSineN.ar(Rand(22000,23000)).range(0.1,0.9)
		),0.5),
		0.3,
	)}!2;
	snd=snd+SinOsc.ar(basshz2*[2,2.01],mul:0.1);
	snd=snd+SinOsc.ar(basshz2*[4,4.01],mul:0.05);
	snd=snd+{Pulse.ar(
		(basshz2.cpsmidi+TChoose.kr(Dust.kr(0.1),[3,7,8,10])).midicps,
		Lag.kr(
			A2K.kr(FBSineN.ar(Rand(22000,23000)).range(0.12,0.9)
		),0.9),
		0.2,
	)}!2;
	basshz=hz;
	basshz=Select.kr(basshz<70,[basshz/2,basshz]);
	basshz=Select.kr(basshz<70,[basshz/2,basshz]);
	basshz=Select.kr(basshz<70,[basshz/2,basshz]);
	basshz=Select.kr(basshz<70,[basshz/2,basshz]);
	snd=snd+SinOsc.ar(basshz*[1,1.01],SinOsc.kr(basshz/16),
		mul:VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(0.1,0.3));
	snd=snd+SinOsc.ar(basshz/2*[1,1.01],SinOsc.kr(basshz/128),
		mul:VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(0.1,0.3));
	
	note=hz.cpsmidi;
	note=Select.kr(note>50,[note+12,note]);
	note=Select.kr(note>50,[note+12,note]);
	note=Select.kr(note>50,[note+12,note]);
	note=Select.kr(note>50,[note+12,note]);
	
	imp=Impulse.kr(mainrate);
	sndkind=Mix.ar(Array.fill(10,{
		arg i;
		var env,snd,noteplay,noteplay2;
		noteplay2=Select.kr(i.mod(3),[
			note+1+(7*osc1)+(12*osc2), //7  or 8
			note+(12*osc1)+(10*osc2), // 0 or 10
			note+3, // 3
		]);
		noteplay=note+Select.kr(i.mod(3),[
			Demand.kr(imp,0,Dseq([0,0,3,3,0,3,3,  2,  0,0,-2,-2,0],inf)),
			Demand.kr(imp,0,Dseq([3,3,7,8,3,8,7,  7,3,3,3,-7,  3],inf)),
			Demand.kr(imp,0,Dseq([8,7,10,12,7,12,10,10,7,8,7,5, 7],inf)),		]);
		noteplay=TChoose.kr(imp,[noteplay,noteplay,noteplay,noteplay,noteplay,noteplay]);
		snd=SinOsc.ar(noteplay.midicps,mul:0.8);
		snd=snd+VarSaw.ar(noteplay.midicps/2,width:SinOsc.kr(4).range(0.4,0.6),mul:0.8);
		snd=snd+PinkNoise.ar(q/20);
		snd=MoogFF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,noteplay.midicps,12000));
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		snd=snd*EnvGen.kr(Env.perc(3,5),imp);
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/4
	}));
	
	// filter
	snd=DFM1.ar(snd,basshz*2*p.range(1,10));
	snd=Splay.ar(snd);
	sndkind=DFM1.ar(sndkind,basshz*3*(1-p).range(1,10));
	
	drop=Clip.kr(SinOsc.kr(
		freq:VarLag.kr(LFNoise0.kr(4),1/4,warp:\sine).range(0.7,1),
		add:1.7))*2;
	snd=SineShaper.ar(snd,0.5,drop);
	stomp=EnvGen.ar(Env.new([0,1,1,0],[0.5,VarLag.kr(LFNoise0.kr(0.1),10,warp:\sine).range(5,12),0.2]),Dust.kr(1/20));
	//stomp2=EnvGen.ar(Env.new([0,1,1,0],[2,VarLag.kr(LFNoise0.kr(0.1),10,warp:\sine).range(7,15),0.2]),Dust.kr(1/15));
	//stomp2=Lag.kr(intro*q.range(0,1)>0.9);
	// snd=SelectX.ar(Clip.kr(stomp+SinOsc.kr(0.1).range(0,0.1)),[sndkind,snd*0.8+(stomp2*sndkind)]);
	introp=(1-q.range(0,1))*intro;
	snd=SelectX.ar(1-Clip.kr(introp+(SinOsc.kr(mainrate/64).range(0,0.1)*intro)),[sndkind,snd]);
	snd=FreeVerb.ar(snd,mix:SelectX.kr(Lag.kr(A2K.kr(stomp),1),[0.3,0.5]),room:drop,damp:drop);
	//snd=Compander.ar(snd,snd,0.1);
	snd*amp/2
}
