// (
// d =
{
	arg hz=110, amp=1;

	var snd;

	var one = {
		SinOsc.ar(hz, mul:amp/4)!2;
	};

	var two = {
		SinOsc.ar(hz*2, mul:amp/4)!2;
	};

	snd = one.value;
}
// .play
// )
//
