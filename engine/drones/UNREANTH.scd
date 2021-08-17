// @zebra
// z =
{
	arg hz=220, amp=1.0;
	var dt = 47;
	var n = 6;
	var blips, saws, ring, snd, gar;

	var sloth = {
		arg dt=10, ddt=30, min=0, max=1, ddtscale=1.0;
		var hzhz = 1/ddt;
		var hz = (1/dt) * LFNoise2.kr(hzhz, ddtscale, ddtscale*0.5);
		var c = (max-min)*0.5; // tmp
		LFNoise2.kr(hz, c, c+min)
	};

	var stack = {
		arg base, // center frequency
		n,        // number of voices
		m,        // number of sub-octaves
		dhz=2,
		dt=10, ddt=100;

		var oct = Array.geom(m, 2, 0.5); // sub octaves
		var hz = Array.fill(n, {
			var f = oct * base;
			sloth.value(dt, ddt, f-dhz, f+dhz)
		});
		hz.flatten
	};

	var pair = {
		arg hz,
		mod=1.0, // modulation scale
		hzMul=1.0,     // hz multiplier for cancelling saw
		delRatio=0.5;  // inverse multiplier for phase offset
		var car = Saw.ar(hz);
		var inv = Saw.ar(hz * hzMul);
		car - (mod * AllpassL.ar(inv, 0.1, delRatio/hz))
	};

	blips = Mix.new(
		Blip.ar(
			freq:stack.value(hz, 8, 3),
			numharm: sloth.value(dt, dt*10, 1, 10, 2.0),
		).clump(2)
	);

	saws = Mix.new(
		pair.value(
			hz: stack.value(hz, 8, 3),
			mod: Array.fill(n, { sloth.value(dt, dt*10, 0.51, 0.99)}),
			delRatio: Array.fill(n, {sloth.value(dt, dt*10, 0.55, 0.7)})
		).clump(2)
	);

	ring = Array.fill(blips.size, { |i|
		blips[i].ring2(saws.wrapAt(i+1));
	});

	snd = (blips + saws/2 + (ring * 0.3 * LFNoise2.kr(1/(dt*7))))/2;
	snd = Mix.new((snd + RLPF.ar(snd, hz * [0.25, 0.5] + LFNoise2.ar(1/dt, 0.5), 0.2 + LFNoise2.ar(1/dt, 0.1))).clump(2));

	gar = Normalizer.ar(RLPF.ar(Pulse.ar(hz * 0.25 + LFSaw.kr([1/17, 1/13], [0, 1], 0.2)).distort, hz, 0.7));
	snd = snd*0.36 + gar*0.29 * amp * Linen.kr(attackTime:7.79);
	// Peak.kr(Amplitude.kr(snd)).ampdb.poll;
	snd
}
//.play(s);