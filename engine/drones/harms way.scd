// @moonblind
// harm's way
// 16 harmonic sines.

{
	arg hz=100, amp=0.5;
	var n = (1..16);
	var snd = Splay.ar((SinOsc.ar(hz * n) / n) * SinOsc.kr({Rand(0.001,0.02)} ! 16),0.5, amp, SinOsc.kr(0.001));
	snd;
}