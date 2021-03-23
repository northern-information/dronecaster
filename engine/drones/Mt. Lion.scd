// @license
// Roars through a twisting canyon.
{
    arg hz,amp;
    var voiceCount = 9;
    var baseNote = hz.cpsmidi.round;
    var noteDetune = (baseNote - hz.cpsmidi).abs;
    var maxAmp = amp / voiceCount;

    var rand = ({|sampleFreq=1, mul=1, add=0, lag=0.5|
        Latch.kr(WhiteNoise.kr(mul, add), Dust.kr(sampleFreq)).lag(lag)
    });

    var voices = (1..voiceCount).collect({ |index|
        Pan2.ar(
        CombN.ar(
            LFPulse.ar(
            rand.(0.2, noteDetune, baseNote, 2).midicps * index,
            0,
            rand.(0.5, 0.5, 0.5)
            ),
            1,
            rand.(0.3, noteDetune, baseNote, 5).midicps.reciprocal * rand.(0.2, 3, 4).round.lag(5),
            rand.(0.2, 10, 0, 3)
        ).tanh,
        rand.(0.4, 1, 0, 2),
        rand.(0.1, maxAmp)
        )
    });
	LeakDC.ar(Mix.ar(voices))
}
