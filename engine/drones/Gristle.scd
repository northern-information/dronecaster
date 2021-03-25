// @infinitedigits
// Gristle
// a primal sawtooth

{
    arg hz=440, amp=0.02;
	var sig = Mix.ar(
			VarSaw.ar(
			freq:hz*Array.fill(3,{arg i;
					2**i *
					LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.99,1.01)
			}),
			mul:amp*Array.fill(3,{arg i;(1/2)**i}),
		)
	);
	sig = BPF.ar(sig,
			LinLin.kr(SinOsc.kr(LFNoise0.kr(1,mul:0.1)),-1,1,30,2000)
	);
	sig = Greyhole.ar(sig,delayTime:0.1);
}
