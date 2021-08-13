// @infinitedigits
// Starlids
// Symphonic, meek, radiant.

{
    arg hz,amp;
	var snd,fx;
	var note=hz.cpsmidi;
	snd=Pan2.ar(Pulse.ar((note-12).midicps,LinLin.kr(LFTri.kr(0.5),-1,1,0.2,0.8))/12*amp);
	snd=snd+Mix.ar({
		var osc1,osc2,env,snd;
		osc1=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		osc2=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		snd=SawDPW.ar((note+(4*osc1)+(5*osc2)).midicps);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000));
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/12*amp
	}!12);
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*8,hz*60));
	snd=HPF.ar(snd,20);
}

