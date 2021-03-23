// @infinitedigits
// Dreamcrusher
// Chaotic, strobey, actually really nice IRL.

{
    arg hz,amp;
    var local, in, ampcheck,movement, sig;

	in = Splay.ar(Pulse.ar(Lag.ar(hz*
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)/2),-1,1,0.99,1.01),1),
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.45,0.55)
	)!1)/1;
	in = Balance2.ar(in[0] ,in[1],SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1);

	// from tape example
	// https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
    ampcheck = Amplitude.kr(Mix.ar(in));
    in = in * (ampcheck > 0.02); // noise gate
    local = LocalIn.ar(2);
    local = OnePole.ar(local, 0.4);
    local = OnePole.ar(local, -0.08);
    local = Rotate2.ar(local[0], local[1],0.2);
	local = DelayN.ar(local, 0.3,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.1),-1,1,0.15,0.3),1/0.1,warp:\sine)
	);
    local = LeakDC.ar(local);
    local = ((local + in) * 1.25).softclip;

/*	local = LPF.ar(local,MouseX.kr(40,16000));
	LocalOut.ar(local*MouseY.kr(0.5,1.5));*/

	// for the drone
    local = LPF.ar(local,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.3),-1,1,ArrayMin.kr([hz,80]),16000),1/0.3,warp:\sine)
	);
	LocalOut.ar(local*
		VarLag.kr(LinLin.kr(LFNoise0.kr(2),-1,1,1.01,1.5),1/2,warp:\sine)
	);
	sig = Balance2.ar(local[0] * 0.2,local[1]*0.2,SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1)*amp;
}
