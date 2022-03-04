// Takita
// @sixolet
// Rhythmic.

{ |hz=55, amp=0.8|
	var riddim = { |
		beatTime=0.125, divEnvTime=0.99, syncTime1=0.333, syncTime2=0.2,
		tikAmp=0.5, tokAmp=0.5, tukAmp=0.5, kiAmp=0.5, kaAmp=0.5,
		tikHp=100, tokHp=200, kiHp=1200, kaHp=600,
		tikLp=800, tokLp=1000, kiLp=3000, kaLp=1500,
		tikHighres=0.1, tokHighres=0.3, kiHighres=0.4, kaHighres=0.1,
		tikLores=0.5, tokLores=0.2, kiLores=0.4, kaLores=0.3,
		tikDrumhead=1.0, tokDrumhead=1.0,
		tikTrash=0, tokTrash=0, kiTrash=0, kaTrash=0
		|
		var takitak = Impulse.ar(beatTime.reciprocal);
		var divFeedback = LocalIn.ar(1);
		var tokitokGate = Env.step(levels: [1, 0], times: [1, 0]);
		var tokitok = EnvGen.ar(tokitokGate, takitak * (1 - divFeedback) + Impulse.ar(0), timeScale: divEnvTime, doneAction: Done.none);
		var prong = Phasor.ar(tokitok, syncTime2.reciprocal / SampleRate.ir);
		var pring = Phasor.ar(tokitok, syncTime1.reciprocal / SampleRate.ir);
		var prang = Phasor.ar(tokitok, (syncTime1 + syncTime2).reciprocal / SampleRate.ir);
		var tik = SetResetFF.ar(takitak, prong > 0.1);
		var tok = SetResetFF.ar(takitak, pring > 0.1);
		var tuk = SetResetFF.ar(takitak, prang > 0.1);
		var ki = SetResetFF.ar(tik, tok);
		var ka = SetResetFF.ar(tok, tik);
		var filt = { |thing, hp, lp, highres, lowres, trash|
			var gend = EnvGen.ar(Env.perc(0.01*beatTime, 0.24*beatTime), thing, doneAction: Done.none);
			var band;
			var voices = 3;
			gend = gend + (gend * trash * PinkNoise.ar);
			band = RLPF.ar(RHPF.ar(gend, hp, highres), lp, lowres) + BPF.ar(gend, (hp + lp)/2, (highres + lowres)/2);
			band;
		};
		var drumhead = EnvGen.ar(Env.perc(0.01*beatTime, 0.24*beatTime), takitak);
		var tikF = filt.value(tik, tikHp*(1+(tikDrumhead*drumhead)), tikLp, tikHighres, tikLores, tikTrash);
		var tokF = filt.value(tok, tokHp*(1+(tokDrumhead*drumhead)), tokLp, tokHighres, tokLores, tokTrash);
		var tukF = filt.value(tuk, min(tikLp, tokLp), max(tikLp, tokLp), tikHighres, tokLores, 0);
		var kiF = filt.value(ki, kiHp, kiLp, kiHighres, kiLores, kiTrash/2)/2;
		var kaF = filt.value(ka, kaHp, kaLp, kaHighres, kaLores, kaTrash);
		var array = [kiAmp*kiF, tikAmp*tikF, tukAmp*tukF, tokAmp*tokF, kaAmp*kaF];
		var sound;
		array = [ array, LFNoise2.kr(500.reciprocal!5).clip(0, 0.5).lag2(10)*DelayC.ar(array, 0.014, 0.014*LFNoise2.kr(0.1!4).unipolar)].lace;
		sound = Splay.ar(array, spread: 0.7);
		LocalOut.ar([tokitok]);
		sound = sound;
		sound.tanh;
	};
	var isLow = (hz < 150);
	var isVeryLow = (hz < 80);
	var tikHp = isLow.if(hz, hz/2);
	var tokHp = Select.kr(isLow + isVeryLow, [hz, hz*2, hz*3]);
	var kiHp = Select.kr(isLow + isVeryLow, [hz*6, hz*9, hz*12]);
	var kaHp = isLow.if(hz*6, hz*3);
	var tikLp = isLow.if(hz*8, hz*6);
	var tokLp = isVeryLow.if(hz*12, hz*9);
	var kiLp = isLow.if(hz*30, hz*20);
	var kaLp = isVeryLow.if(hz*12, hz*15);
	var beat = LFTri.kr(4000.reciprocal, Rand(0, 2*pi)).linexp(-1, 1, 0.11, 0.22);
	var div = SinOsc.kr(2111.reciprocal, Rand(0, 2*pi)).linlin(-1, 1, 5, 20).clip(7.1, 15.9);
	var mod = SinOsc.kr(1234.reciprocal).unipolar*(SinOsc.kr((2*beat*div).reciprocal) > 0);
	var one = (LFTri.kr(1111.reciprocal, Rand(0, 2*pi))).linexp(-1, 1, 0.15, div/2) + 1 + mod;
	var two = LFTri.kr(1323.reciprocal, Rand(0, 2*pi)).linexp(-1, 1, 0.17, div/2) + 1;
	var amps = (SinOsc.kr(Rand(100!5, 500).reciprocal, Rand(0!5, 2*pi)).unipolar - 0.2).clip(0, 1).lag2(10);
	var resonances = SinOsc.kr(Rand(200!8, 800).reciprocal, Rand(0!8, 2*pi)).linexp(-1, 1, 0.06, 0.8);
	var drumheads = SinOsc.kr(Rand(200!2, 800).reciprocal, Rand(0!2, 2*pi)).linlin(-1, 1, 0, 1.4);
	var trash = SinOsc.kr(Rand(200!4, 800).reciprocal, Rand(0!4, 2*pi)).clip(0, 1);
	amps[0] = max(amps[0], 0.4 - Mix.kr(amps));

	//riddim.value(0.125, 2, MouseX.kr(0.125, 1, 1), MouseY.kr(0.125, 1, 1))
	resonances[4] = resonances[4]/2;
	riddim.value(beat, beat*div, beat*one, beat*two,
		amps[0], amps[1], amps[2], amps[3], amps[4],
		tikHp: tikHp, tokHp: tokHp,
		kiHp: kiHp, kaHp: kaHp,
		tikLp: tikLp, tokLp: tokLp,
		kiLp: kiLp, kaLp: kaLp,
		tikHighres: resonances[0], tikLores: resonances[1],
		tokHighres: resonances[2], tokLores: resonances[3],
		kiHighres: resonances[4], kiLores: resonances[5],
		kaHighres: resonances[6], kaLores: resonances[7],
		tikDrumhead: drumheads[0], tokDrumhead: drumheads[1],
		tikTrash: trash[0], tokTrash: trash[1],
		kiTrash: trash[2], kaTrash:trash[3]
	);
}

