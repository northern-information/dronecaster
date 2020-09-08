// @zebra
{
	arg hz=220, amp=0.125;
	var dt = 47;
	var n = 6;
	var blips, saws, ring, snd, gnar;

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
		car - (mod * DelayC.ar(inv, 0.1, delRatio/hz))
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
			delRatio: Array.fill(n, {sloth.value(dt, dt*10, 055, 0.7)})
		).clump(2)
	);

	ring = Array.fill(blips.size, { |i|
		blips[i].ring2(saws.wrapAt(i+1));
	});

	snd = (blips + saws/2 + (ring * 0.3 * LFNoise2.kr(1/dt)))/2;
	snd = Mix.new((snd + RLPF.ar(snd, hz * [0.25, 0.5] + LFNoise2.ar(1/dt, 0.5), 0.2 + LFNoise2.ar(1/dt, 0.1))).clump(2));

	gnar = Normalizer.ar(RLPF.ar(Pulse.ar(hz * 0.25).distort, hz, 0.7));

	(snd*0.9 + gnar*0.8) * amp
}