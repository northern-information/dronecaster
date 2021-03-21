// @yourname
// your drone name
// how does your drone describe itself

{
    arg hz=440, amp=0.02, amplag=0.02, hzlag=0.01;
    var amp_, hz_, sig;
    amp_ = Lag.ar(K2A.ar(amp), amplag);
    hz_ = Lag.ar(K2A.ar(hz), hzlag);
    
    // << the drone zone >>
	sig = Mix.ar(
			VarSaw.ar(
			freq:hz_*Array.fill(3,{arg i;
					2**i *
					LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.99,1.01)
			}),
			mul:amp_*Array.fill(3,{arg i;(1/2)**i}),
		)
	);
	sig = BPF.ar(sig,
			LinLin.kr(SinOsc.kr(LFNoise0.kr(1,mul:0.1)),-1,1,30,2000)
	);
	sig = Greyhole.ar(sig,delayTime:0.1);
    // << end drone zone >>

}
