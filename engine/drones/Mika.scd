// @infinitedigits
// Mika
// Hum and beeps.

{
	arg hz=220,amp=0.5;
	var snd,freq,pulse, chords, chord, basshz, bass;
	//            Am        F          C          Em
	// chords=Dseq([[33,36,40],[33,36,41],[31,36,40],[31,35,40]],inf);
	//chords=Dseq([[33,33,40],[29,29,36],[36,36,43],[28,28,35]],inf);
	hz=hz*TChoose.kr(Dust.kr(0.05),[1,1,1,2]);
	chords=Dseq([[-3,-3,-3,4,4,2],[-7,-7,-7,0,0,-3],[0,0,0,2,4,7,7],[-8,-8,7,-1,-8,-1,1]],inf);
	chord=Demand.kr(Impulse.kr(86/60/4/2),0,chords);
	freq=TChoose.kr(Impulse.kr(1.4333),(chord+hz.cpsmidi).midicps);
	snd=SinOsc.ar(freq).tanh;
	snd=AllpassC.ar(snd,0.4,TExpRand.ar(2e-4, 0.4,Impulse.ar(TChoose.kr(Dust.kr(0.1),[8,8,8,8,8,4,4,2,1]))).round([2e-3,4e-3]),2);
	//snd=snd+AllpassC.ar(snd,0.4,Demand.kr(Impulse.kr(8),0,Dseq([0.00421835,0.00460017,0.000295328,0.19721,0.101522,0.00029477,0.320863,0.001676,0.01069,0.00066,0.0011393,0.01772],inf)).round([2e-3,4e-3]),2);
	snd=LPF.ar(snd/2,VarLag.kr(LFNoise0.kr(Dust.kr(1)),1,warp:\sine).range(300,1000));
	snd=snd+PMOsc.ar([freq,freq*1.02],freq*0.98,3,mul:0.0);
	snd=Compander.ar(snd,snd);
	snd=HPF.ar(snd,70);

	// bass
	basshz=(ArrayMin.kr(chord)+hz.cpsmidi).midicps;
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	basshz=Select.kr(basshz>90,[basshz,basshz/2]);
	bass=Pulse.ar(basshz,width:SinOsc.kr(1/3).range(0.2,0.4));
	bass=bass+LPF.ar(WhiteNoise.ar(SinOsc.kr(1/rrand(3,4)).range(1,rrand(3,4))),2*basshz);
	bass = Pan2.ar(bass,LFTri.kr(1/6.12).range(-0.2,0.2));
	bass = HPF.ar(bass,20);
	bass = LPF.ar(bass,SinOsc.kr(0.1).range(2,3)*basshz);
	snd=snd+(SinOsc.kr(0.123).range(1.5,2.5)*bass);

	snd=LeakDC.ar(snd);
	snd=snd.tanh*(-20.dbamp)*amp;
}
// modified from orignal
// https://ia600202.us.archive.org/29/items/sc140/sc140_sourcecode.txt
// 16
// Batuhan Bozkurt
// play{AllpassC.ar(SinOsc.ar(55).tanh,0.4,TExpRand.ar(2e-4, 0.4,Impulse.ar(8)).round([2e-3,4e-3]),2)};// #supercollider with bass please...
