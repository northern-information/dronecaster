// Grove
// @sixolet
// The orchestra is preparing to play among the arching roots. There is no conductor.

{ |hz=100, amp=0.8|
	var channels = 5;
	var formantHzLfos = SinOsc.kr(Rand(40!channels, 400).reciprocal, phase: Rand(0!channels, 2*pi));
	var ampLfos = SinOsc.kr(Rand(100!channels, 400).reciprocal, phase: Rand(0!channels, 2*pi));
	var tempo = Rand(1, 2.5);
	var envLfo = SinOsc.kr(Rand(200!channels, 800).reciprocal, phase: Rand(0!channels, 2*pi));
	var envLen = envLfo.linexp(-1, 1, 0.5*tempo, 8*tempo);
	var widthControl = envLfo.linexp(-1, 1, 0.005, 0.5);
	var intervalLfos = SinOsc.kr(Rand(10!channels, 400).reciprocal, phase: Rand(0!channels, 2*pi)).unipolar;
	var numerators = Drand([1, 1, 2, 3, 4, 6, 7, 8, 9], inf);
	var controlBasis = Drand([2, 4], inf);
	var controlBasis2 = Drand([2/4, 3/4, 4/4, 5/4, 6/4, 7/4, 8/4, 9/4, 10/4, 11/4, 12/4, 13/4, 14/4], inf);
	var ratio = Demand.kr(ampLfos, 0, numerators);
	var ratio2 = Demand.kr(ampLfos, 0, numerators);
	var formantHz = formantHzLfos.linexp(-1, 1,  max(55, (hz*ratio/8)), 1000);
	var controlRatio = Demand.kr(ampLfos, 0, controlBasis);
	var controlRatio2 = Demand.kr(ampLfos, 0, controlBasis2);
	var pulse = ((1 - intervalLfos) * SinOsc.ar(hz*ratio, phase: (0.02*LFNoise1.ar(hz*ratio))+Rand())) +  (intervalLfos * SinOsc.ar(hz*ratio2, phase: Rand(0!channels, 2*pi)));
	var pulseControl = Trig1.kr(SetResetFF.kr(Impulse.kr(tempo*controlRatio), Impulse.kr(tempo*controlRatio2)), dur: 0.01);
	var local = LocalIn.ar(channels);
	var localControl = LocalIn.kr(channels);
	var retrigger = Trig1.ar(pulse, 4000.reciprocal)* (1 - local);
	var retriggerControl = pulseControl * (1 - localControl);
	var width = SinOsc.kr(Rand(10!channels, 400).reciprocal).linlin(-1, 1, 0.1, 0.9);
	var guardEnv = Env.step(levels: [1, 0], times: [1, 0]);
	var guard = EnvGen.ar(guardEnv, retrigger + Impulse.ar(0!channels), timeScale: width*formantHz.reciprocal);
	var guardControl = EnvGen.kr(guardEnv, retriggerControl + Impulse.ar(0!channels), timeScale: widthControl*envLen);
	var shape = Env.perc(attackTime: width, releaseTime: 1 - width, curve: Rand(-4, 2!channels).clip(-4, 0));
	var shapeControl = Env.perc(attackTime: widthControl, releaseTime: 1 - widthControl, curve: Rand(-4!channels, 0));
	var sound = EnvGen.ar(shape, retrigger, timeScale: formantHz.reciprocal);
	var envelopes = EnvGen.kr(shapeControl, retriggerControl, timeScale: envLen);
	var backupChannel = rand(channels).floor.asInteger;
	var air;
	var pairs;
	var filtered;
	backupChannel.postln;
	ampLfos = ampLfos.clip(0, 1).lag2(4);
	ampLfos[backupChannel.asInteger] = ArrayMax.kr([ampLfos[backupChannel.asInteger], 0.4 - Mix.kr(ampLfos)]).at(0);
	air = (1+(Rand(0!channels, 4)*ampLfos))*envelopes;
	sound = LeakDC.ar(sound);
	sound = OnePole.ar((sound*air).tanh, coef: 1 - envelopes)*ampLfos;
	pairs = [guard*ampLfos, sound].flop.reshape(10);
	sound = sound/(formantHzLfos.linexp(-1, 1, 1, 7));
	sound = Splay.ar(sound, spread: 0.9);
	LocalOut.ar(guard);
	LocalOut.kr(guardControl);
	sound = Rotate2.ar(sound[0], sound[1], SinOsc.kr(1000.reciprocal, Rand(-pi, pi)));
	sound = LeakDC.ar(sound).softclip * amp;
	sound = XFade2.ar(sound, Greyhole.ar(sound, delayTime: 1.5/tempo, damp: 0.2, size: 2, diff: 0.5, feedback: 0.8), SinOsc.kr(Rand(100, 800).reciprocal, phase: Rand()).linlin(-1, 1, -1, 0));
	sound
}