// @license
// Thee rusted satellites gather + sing.
{
    arg hz,amp;
    var voiceCount = 5;
    var baseNote = hz.cpsmidi.round;
    var noteDetune = (baseNote - hz.cpsmidi).abs;
    var maxAmp = amp / voiceCount;

    var rand = ({|sampleFreq=1, mul=1, add=0, lag=0.5|
        Latch.ar(WhiteNoise.ar(mul, add), Dust.ar(sampleFreq)).lag(lag)
    });

    var voices = (1..voiceCount).collect({ |index|
        Pan2.ar(
        Pulse.ar(
            rand.(0.2, noteDetune, baseNote, 2).midicps * index,
            rand.(0.5, 0.5, 1.5)
        ),
        rand.(0.3),
        rand.(0.1, maxAmp)
        );
    });
    Mix.ar(voices);
}
